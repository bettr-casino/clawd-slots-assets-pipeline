#!/usr/bin/env python3
"""
Simple browser-based box annotation tool for Codespaces.

Features:
- File -> Open (browse image files under workspace root)
- Rectangle drawing
- Move/resize rectangles
- Undo / Redo
- Save annotated image with *_annotated.png suffix
"""

from __future__ import annotations

import argparse
import base64
import json
import mimetypes
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, unquote, urlparse


HTML = """<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Symbol Annotation Tool</title>
  <script src="https://cdn.jsdelivr.net/npm/fabric@5.3.0/dist/fabric.min.js"></script>
  <style>
    body { font-family: Arial, sans-serif; margin: 0; background: #111; color: #eee; }
    .topbar { display: flex; align-items: center; gap: 8px; padding: 10px 12px; background: #1b1b1b; border-bottom: 1px solid #333; }
    .btn { background: #2b2b2b; color: #eee; border: 1px solid #444; border-radius: 6px; padding: 6px 10px; cursor: pointer; }
    .btn:hover { background: #3a3a3a; }
    .btn:disabled { opacity: 0.5; cursor: not-allowed; }
    .field { background: #0e0e0e; color: #eee; border: 1px solid #444; border-radius: 6px; padding: 6px; }
    .layout { display: grid; grid-template-columns: 320px 1fr; height: calc(100vh - 54px); }
    .sidebar { border-right: 1px solid #333; padding: 10px; overflow: auto; }
    .canvas-wrap { overflow: auto; padding: 10px; }
    .file-list { margin-top: 10px; display: grid; gap: 6px; }
    .file-item { background: #171717; border: 1px solid #333; padding: 6px; border-radius: 6px; cursor: pointer; word-break: break-all; }
    .file-item:hover { background: #232323; }
    .status { margin-left: auto; font-size: 12px; color: #9ecbff; }
    #menuFile { position: relative; }
    #menuPanel { display: none; position: absolute; top: 34px; left: 0; background: #1b1b1b; border: 1px solid #444; border-radius: 6px; min-width: 140px; z-index: 10; }
    #menuPanel button { width: 100%; text-align: left; border: 0; border-bottom: 1px solid #333; border-radius: 0; background: transparent; padding: 8px 10px; color: #eee; cursor: pointer; }
    #menuPanel button:last-child { border-bottom: 0; }
    #menuPanel button:hover { background: #2b2b2b; }
    .hint { font-size: 12px; color: #bbb; margin-top: 10px; line-height: 1.45; }
    canvas { border: 1px solid #333; }
  </style>
</head>
<body>
  <div class="topbar">
    <div id="menuFile">
      <button class="btn" id="fileMenuBtn">File</button>
      <div id="menuPanel">
        <button id="openBtn">Open</button>
        <button id="saveBtn">Save</button>
      </div>
    </div>
    <button class="btn" id="rectToolBtn">Rectangle Tool</button>
    <button class="btn" id="undoBtn">Undo</button>
    <button class="btn" id="redoBtn">Redo</button>
    <div class="status" id="status">Ready</div>
  </div>

  <div class="layout">
    <div class="sidebar">
      <div><strong>Open Image</strong></div>
      <div style="margin-top:8px;">Directory (relative to workspace root)</div>
      <input id="dirInput" class="field" style="width:100%;" value="yt/CLEOPATRA/frames" />
      <div style="margin-top:8px; display:flex; gap:8px;">
        <button class="btn" id="refreshBtn">Refresh</button>
      </div>
      <div class="file-list" id="fileList"></div>
      <div class="hint">
        - Click a file to open it.<br/>
        - Draw new rectangles by dragging on empty area.<br/>
        - Click a rectangle to move/resize it.<br/>
        - Press Delete/Backspace to remove selected rectangle.
      </div>
    </div>
    <div class="canvas-wrap">
      <canvas id="c"></canvas>
    </div>
  </div>

<script>
(() => {
  const canvas = new fabric.Canvas('c', { selection: true, preserveObjectStacking: true });
  let drawRectMode = true;
  let drawing = false;
  let startX = 0, startY = 0, activeRect = null;
  let undoStack = [];
  let redoStack = [];
  let restoring = false;
  let currentImagePath = null;

  const statusEl = document.getElementById('status');
  const openBtn = document.getElementById('openBtn');
  const saveBtn = document.getElementById('saveBtn');
  const undoBtn = document.getElementById('undoBtn');
  const redoBtn = document.getElementById('redoBtn');
  const rectToolBtn = document.getElementById('rectToolBtn');
  const refreshBtn = document.getElementById('refreshBtn');
  const dirInput = document.getElementById('dirInput');
  const fileList = document.getElementById('fileList');
  const menuPanel = document.getElementById('menuPanel');
  const fileMenuBtn = document.getElementById('fileMenuBtn');

  const setStatus = (msg) => { statusEl.textContent = msg; };
  const esc = (s) => (s || '').replace(/[&<>"']/g, (m) => ({'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'}[m]));

  function pushHistory() {
    if (restoring) return;
    undoStack.push(JSON.stringify(canvas.toJSON()));
    if (undoStack.length > 100) undoStack.shift();
    redoStack = [];
    updateButtons();
  }

  function restoreState(stateStr) {
    restoring = true;
    canvas.loadFromJSON(stateStr, () => {
      canvas.renderAll();
      restoring = false;
      updateButtons();
    });
  }

  function updateButtons() {
    undoBtn.disabled = undoStack.length <= 1;
    redoBtn.disabled = redoStack.length === 0;
    rectToolBtn.textContent = drawRectMode ? 'Rectangle Tool (On)' : 'Rectangle Tool (Off)';
  }

  function normalizeRect(rect) {
    if (!rect) return;
    if (rect.width < 0) {
      rect.set({ left: rect.left + rect.width, width: Math.abs(rect.width) });
    }
    if (rect.height < 0) {
      rect.set({ top: rect.top + rect.height, height: Math.abs(rect.height) });
    }
  }

  function setupCanvasEvents() {
    canvas.on('mouse:down', (opt) => {
      if (!drawRectMode) return;
      const target = opt.target;
      if (target) return; // allow selecting/moving existing rectangles

      drawing = true;
      const p = canvas.getPointer(opt.e);
      startX = p.x; startY = p.y;
      activeRect = new fabric.Rect({
        left: startX,
        top: startY,
        width: 1,
        height: 1,
        fill: 'rgba(0, 200, 255, 0.15)',
        stroke: '#00c8ff',
        strokeWidth: 2,
        selectable: true,
      });
      canvas.add(activeRect);
      canvas.setActiveObject(activeRect);
    });

    canvas.on('mouse:move', (opt) => {
      if (!drawing || !activeRect) return;
      const p = canvas.getPointer(opt.e);
      activeRect.set({ width: p.x - startX, height: p.y - startY });
      canvas.renderAll();
    });

    canvas.on('mouse:up', () => {
      if (!drawing) return;
      drawing = false;
      normalizeRect(activeRect);
      if (activeRect && (activeRect.width < 3 || activeRect.height < 3)) {
        canvas.remove(activeRect);
      } else {
        pushHistory();
      }
      activeRect = null;
      canvas.renderAll();
    });

    canvas.on('object:modified', () => pushHistory());
    canvas.on('object:removed', () => pushHistory());
  }

  function clearAndSetImage(imageUrl) {
    canvas.clear();
    fabric.Image.fromURL(imageUrl, (img) => {
      canvas.setWidth(img.width);
      canvas.setHeight(img.height);
      canvas.setBackgroundImage(img, canvas.renderAll.bind(canvas), {
        originX: 'left',
        originY: 'top',
        crossOrigin: 'anonymous',
      });
      undoStack = [];
      redoStack = [];
      pushHistory();
      setStatus('Image loaded');
    }, { crossOrigin: 'anonymous' });
  }

  async function loadFiles() {
    const dir = dirInput.value.trim();
    if (!dir) return;
    setStatus('Loading files...');
    const resp = await fetch(`/api/list?dir=${encodeURIComponent(dir)}`);
    const data = await resp.json();
    fileList.innerHTML = '';
    if (!data.files || data.files.length === 0) {
      fileList.innerHTML = '<div class="hint">No image files found.</div>';
      setStatus('No files found');
      return;
    }
    for (const p of data.files) {
      const div = document.createElement('div');
      div.className = 'file-item';
      div.innerHTML = esc(p);
      div.onclick = () => {
        currentImagePath = p;
        clearAndSetImage(`/api/image?path=${encodeURIComponent(p)}`);
      };
      fileList.appendChild(div);
    }
    setStatus(`Loaded ${data.files.length} files`);
  }

  async function saveAnnotated() {
    if (!currentImagePath) {
      setStatus('Open an image first');
      return;
    }
    setStatus('Saving...');
    const pngDataUrl = canvas.toDataURL({ format: 'png' });
    const payload = {
      path: currentImagePath,
      image_data_url: pngDataUrl,
      objects_json: canvas.toJSON(),
    };
    const resp = await fetch('/api/save', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    const data = await resp.json();
    if (!resp.ok) {
      setStatus(`Save failed: ${data.error || 'unknown error'}`);
      return;
    }
    setStatus(`Saved: ${data.annotated_path}`);
  }

  undoBtn.onclick = () => {
    if (undoStack.length <= 1) return;
    const cur = undoStack.pop();
    redoStack.push(cur);
    restoreState(undoStack[undoStack.length - 1]);
  };

  redoBtn.onclick = () => {
    if (redoStack.length === 0) return;
    const next = redoStack.pop();
    undoStack.push(next);
    restoreState(next);
  };

  document.addEventListener('keydown', (e) => {
    if ((e.key === 'Delete' || e.key === 'Backspace') && canvas.getActiveObject()) {
      canvas.remove(canvas.getActiveObject());
      canvas.discardActiveObject();
      canvas.requestRenderAll();
    }
  });

  rectToolBtn.onclick = () => {
    drawRectMode = !drawRectMode;
    updateButtons();
  };
  refreshBtn.onclick = loadFiles;
  openBtn.onclick = loadFiles;
  saveBtn.onclick = saveAnnotated;

  fileMenuBtn.onclick = () => {
    menuPanel.style.display = menuPanel.style.display === 'block' ? 'none' : 'block';
  };
  document.addEventListener('click', (e) => {
    if (!document.getElementById('menuFile').contains(e.target)) {
      menuPanel.style.display = 'none';
    }
  });

  setupCanvasEvents();
  updateButtons();
  loadFiles();
})();
</script>
</body>
</html>
"""


def is_image_file(path: Path) -> bool:
    return path.suffix.lower() in {".png", ".jpg", ".jpeg", ".webp", ".bmp"}


def safe_resolve(root: Path, rel_path: str) -> Path:
    rel = Path(unquote(rel_path)).as_posix().lstrip("/")
    resolved = (root / rel).resolve()
    if root not in resolved.parents and resolved != root:
        raise ValueError("Path escapes workspace root")
    return resolved


class Handler(BaseHTTPRequestHandler):
    root: Path = Path.cwd()

    def _send_json(self, payload: dict, status: int = HTTPStatus.OK) -> None:
        data = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def _send_bytes(self, data: bytes, content_type: str, status: int = HTTPStatus.OK) -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def log_message(self, format: str, *args) -> None:  # noqa: A003
        return

    def do_GET(self) -> None:  # noqa: N802
        parsed = urlparse(self.path)
        if parsed.path == "/":
            self._send_bytes(HTML.encode("utf-8"), "text/html; charset=utf-8")
            return

        if parsed.path == "/api/list":
            query = parse_qs(parsed.query)
            rel_dir = query.get("dir", [""])[0]
            try:
                dir_path = safe_resolve(self.root, rel_dir)
            except ValueError as exc:
                self._send_json({"error": str(exc)}, status=HTTPStatus.BAD_REQUEST)
                return
            if not dir_path.exists() or not dir_path.is_dir():
                self._send_json({"files": []})
                return

            files = []
            for child in sorted(dir_path.iterdir()):
                if child.is_file() and is_image_file(child):
                    files.append(str(child.relative_to(self.root)).replace("\\", "/"))
            self._send_json({"files": files})
            return

        if parsed.path == "/api/image":
            query = parse_qs(parsed.query)
            rel = query.get("path", [""])[0]
            if not rel:
                self._send_json({"error": "Missing path"}, status=HTTPStatus.BAD_REQUEST)
                return
            try:
                img_path = safe_resolve(self.root, rel)
            except ValueError as exc:
                self._send_json({"error": str(exc)}, status=HTTPStatus.BAD_REQUEST)
                return
            if not img_path.exists() or not img_path.is_file() or not is_image_file(img_path):
                self._send_json({"error": "Image not found"}, status=HTTPStatus.NOT_FOUND)
                return

            content_type = mimetypes.guess_type(str(img_path))[0] or "application/octet-stream"
            self._send_bytes(img_path.read_bytes(), content_type)
            return

        self._send_json({"error": "Not found"}, status=HTTPStatus.NOT_FOUND)

    def do_POST(self) -> None:  # noqa: N802
        parsed = urlparse(self.path)
        if parsed.path != "/api/save":
            self._send_json({"error": "Not found"}, status=HTTPStatus.NOT_FOUND)
            return

        try:
            length = int(self.headers.get("Content-Length", "0"))
            raw = self.rfile.read(length)
            body = json.loads(raw.decode("utf-8"))
        except Exception:
            self._send_json({"error": "Invalid JSON body"}, status=HTTPStatus.BAD_REQUEST)
            return

        rel_path = str(body.get("path", "")).strip()
        data_url = str(body.get("image_data_url", "")).strip()
        objects_json = body.get("objects_json", {})

        if not rel_path or not data_url.startswith("data:image/png;base64,"):
            self._send_json(
                {"error": "Missing path or invalid image_data_url"},
                status=HTTPStatus.BAD_REQUEST,
            )
            return

        try:
            src = safe_resolve(self.root, rel_path)
        except ValueError as exc:
            self._send_json({"error": str(exc)}, status=HTTPStatus.BAD_REQUEST)
            return

        if not src.exists():
            self._send_json({"error": "Source image does not exist"}, status=HTTPStatus.BAD_REQUEST)
            return

        annotated_path = src.with_name(f"{src.stem}_annotated.png")
        json_path = src.with_name(f"{src.stem}_annotated.json")
        try:
            b64 = data_url.split(",", 1)[1]
            image_bytes = base64.b64decode(b64)
            annotated_path.write_bytes(image_bytes)
            json_path.write_text(json.dumps(objects_json, indent=2), encoding="utf-8")
        except Exception as exc:
            self._send_json({"error": f"Failed to save: {exc}"}, status=HTTPStatus.INTERNAL_SERVER_ERROR)
            return

        self._send_json(
            {
                "annotated_path": str(annotated_path.relative_to(self.root)).replace("\\", "/"),
                "annotations_json": str(json_path.relative_to(self.root)).replace("\\", "/"),
            }
        )


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Launch browser-based image annotation tool.")
    parser.add_argument(
        "--root",
        default=".",
        help="Workspace root directory to browse/save files (default: current directory).",
    )
    parser.add_argument("--host", default="0.0.0.0")
    parser.add_argument("--port", type=int, default=18790)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    root = Path(args.root).expanduser().resolve()
    if not root.exists() or not root.is_dir():
        raise SystemExit(f"Invalid root directory: {root}")

    Handler.root = root
    server = ThreadingHTTPServer((args.host, args.port), Handler)
    print(f"Annotation tool running at http://{args.host}:{args.port}")
    print(f"Workspace root: {root}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
