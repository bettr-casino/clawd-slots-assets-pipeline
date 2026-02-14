#!/usr/bin/env python3
"""
YOLO + object tracking + optional LLM review for symbol extraction.

Pipeline:
1) Read curated frames from symbol-frames.txt
2) Run YOLO detection (open-vocab world model supported) on each frame
3) Track detections across frames (ByteTrack)
4) Build candidate crops per track
5) Optionally send top-K candidates to LLM critic to pick best symbol crop
6) Export final symbol PNGs and report
"""

from __future__ import annotations

import argparse
import base64
import csv
import json
import os
import shutil
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Tuple

cv2 = None
np = None
YOLO = None
requests = None


@dataclass
class DetectionCandidate:
    track_id: str
    frame_name: str
    conf: float
    cls_id: int
    x1: int
    y1: int
    x2: int
    y2: int
    area_ratio: float
    sharpness: float
    cv_score: float
    crop_path: Path


@dataclass
class SelectedCrop:
    track_id: str
    selected_crop: Path
    source_frame: str
    reason: str
    label: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Extract symbol PNGs using YOLO detection + tracking."
    )
    parser.add_argument("--video-name", default="CLEOPATRA")
    parser.add_argument(
        "--yt-base-dir",
        default=os.environ.get("YT_BASE_DIR", "/workspaces/clawd-slots-assets-pipeline/yt"),
    )
    parser.add_argument("--symbol-frames", default=None)
    parser.add_argument("--frames-dir", default=None)
    parser.add_argument("--output-dir", default=None)
    parser.add_argument("--model", default="yolov8s-world.pt")
    parser.add_argument(
        "--prompts",
        default="slot symbol,reel symbol,icon,egyptian symbol",
        help="Comma-separated prompts for YOLO world models.",
    )
    parser.add_argument("--conf", type=float, default=0.20)
    parser.add_argument("--iou", type=float, default=0.45)
    parser.add_argument("--imgsz", type=int, default=960)
    parser.add_argument("--max-det", type=int, default=30)
    parser.add_argument("--min-area-ratio", type=float, default=0.01)
    parser.add_argument("--max-area-ratio", type=float, default=0.60)
    parser.add_argument("--padding-ratio", type=float, default=0.22)
    parser.add_argument("--min-padding", type=int, default=8)
    parser.add_argument("--max-padding", type=int, default=90)
    parser.add_argument("--max-candidates-per-track", type=int, default=6)
    parser.add_argument("--min-cv-score", type=float, default=0.15)
    parser.add_argument("--tracker", default="bytetrack.yaml")
    parser.add_argument("--no-track", action="store_true", help="Disable tracking.")
    parser.add_argument("--llm-review", action="store_true")
    parser.add_argument("--llm-topk", type=int, default=3)
    parser.add_argument("--llm-model", default="kimi-k2.5")
    parser.add_argument("--moonshot-base-url", default="https://api.moonshot.ai/v1")
    return parser.parse_args()


def lazy_imports() -> None:
    global cv2, np, YOLO, requests
    try:
        import cv2 as _cv2  # type: ignore
        import numpy as _np
        import requests as _requests
        from ultralytics import YOLO as _YOLO
    except Exception as exc:  # pragma: no cover
        raise SystemExit(
            "Missing dependencies. Install with:\n"
            "  pip install ultralytics opencv-python numpy requests\n"
        ) from exc
    cv2 = _cv2
    np = _np
    requests = _requests
    YOLO = _YOLO


def resolve_paths(args: argparse.Namespace) -> Tuple[Path, Path, Path]:
    base = Path(args.yt_base_dir).expanduser().resolve()
    root = base / args.video_name
    symbol_frames = (
        Path(args.symbol_frames).expanduser().resolve()
        if args.symbol_frames
        else (root / "symbol-frames.txt")
    )
    frames_dir = (
        Path(args.frames_dir).expanduser().resolve()
        if args.frames_dir
        else (root / "frames")
    )
    output_dir = (
        Path(args.output_dir).expanduser().resolve()
        if args.output_dir
        else (root / "output" / "symbols-yolo")
    )
    return symbol_frames, frames_dir, output_dir


def load_frame_list(path: Path) -> List[str]:
    if not path.exists():
        raise SystemExit(f"Missing symbol-frames.txt: {path}")
    frames: List[str] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        frames.append(s)
    if not frames:
        raise SystemExit(f"No frames listed in {path}")
    return frames


def img_sharpness(gray: "np.ndarray") -> float:
    return float(cv2.Laplacian(gray, cv2.CV_64F).var())


def clamp(v: int, lo: int, hi: int) -> int:
    return max(lo, min(hi, v))


def encode_image_data_uri(path: Path) -> str:
    mime = "image/png"
    data = base64.b64encode(path.read_bytes()).decode("utf-8")
    return f"data:{mime};base64,{data}"


def llm_pick_candidate(
    track_id: str,
    candidates: List[DetectionCandidate],
    model_name: str,
    base_url: str,
) -> Optional[Tuple[int, str]]:
    api_key = os.environ.get("MOONSHOT_API_KEY")
    if not api_key:
        return None

    top = sorted(candidates, key=lambda c: c.cv_score, reverse=True)[:3]
    lines = []
    for i, c in enumerate(top, start=1):
        lines.append(
            f"{i}. {c.crop_path.name} conf={c.conf:.2f} sharpness={c.sharpness:.1f} "
            f"area_ratio={c.area_ratio:.3f} cv_score={c.cv_score:.3f}"
        )
    rubric = (
        "Pick the best crop that contains one full symbol (not partial), minimal UI/border, "
        "and clean centering. Return strict JSON: "
        '{"pick": <1-based index>, "label": "<short symbol label>", "reason": "<short reason>"}'
    )

    content: List[dict] = [{"type": "text", "text": "Candidates:\n" + "\n".join(lines) + "\n" + rubric}]
    for c in top:
        content.append({"type": "image_url", "image_url": {"url": encode_image_data_uri(c.crop_path)}})

    payload = {
        "model": model_name,
        "temperature": 0,
        "messages": [{"role": "user", "content": content}],
    }
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }
    try:
        resp = requests.post(
            f"{base_url.rstrip('/')}/chat/completions",
            headers=headers,
            data=json.dumps(payload),
            timeout=45,
        )
        resp.raise_for_status()
        data = resp.json()
        text = data["choices"][0]["message"]["content"]
        if isinstance(text, list):
            text = "".join([x.get("text", "") for x in text if isinstance(x, dict)])
        text = str(text).strip()
        if text.startswith("```"):
            text = text.strip("`")
            if text.lower().startswith("json"):
                text = text[4:].strip()
        obj = json.loads(text)
        pick = int(obj.get("pick", 1))
        label = str(obj.get("label", f"track_{track_id}")).strip() or f"track_{track_id}"
        reason = str(obj.get("reason", "llm_pick")).strip() or "llm_pick"
        idx = clamp(pick - 1, 0, len(top) - 1)
        return idx, f"llm:{reason}|label:{label}"
    except Exception:
        return None


def main() -> None:
    args = parse_args()
    lazy_imports()
    symbol_frames_path, frames_dir, out_dir = resolve_paths(args)
    frames_list = load_frame_list(symbol_frames_path)

    candidates_dir = out_dir / "candidates"
    final_dir = out_dir / "final"
    out_dir.mkdir(parents=True, exist_ok=True)
    candidates_dir.mkdir(parents=True, exist_ok=True)
    final_dir.mkdir(parents=True, exist_ok=True)

    model = YOLO(args.model)
    prompt_list = [p.strip() for p in args.prompts.split(",") if p.strip()]
    if hasattr(model, "set_classes") and prompt_list:
        try:
            model.set_classes(prompt_list)
        except Exception:
            pass

    grouped: Dict[str, List[DetectionCandidate]] = {}
    track_counter = 0

    for frame_name in frames_list:
        frame_path = frames_dir / frame_name
        if not frame_path.exists():
            print(f"[WARN] Missing frame: {frame_path}")
            continue
        image = cv2.imread(str(frame_path), cv2.IMREAD_COLOR)
        if image is None:
            print(f"[WARN] Unable to read image: {frame_path}")
            continue
        h, w = image.shape[:2]
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

        if args.no_track:
            res = model.predict(
                source=str(frame_path),
                conf=args.conf,
                iou=args.iou,
                imgsz=args.imgsz,
                max_det=args.max_det,
                verbose=False,
            )
        else:
            res = model.track(
                source=str(frame_path),
                conf=args.conf,
                iou=args.iou,
                imgsz=args.imgsz,
                max_det=args.max_det,
                persist=True,
                tracker=args.tracker,
                verbose=False,
            )
        if not res:
            continue
        r = res[0]
        if r.boxes is None or len(r.boxes) == 0:
            continue

        xyxy = r.boxes.xyxy.cpu().numpy()
        confs = r.boxes.conf.cpu().numpy() if r.boxes.conf is not None else np.zeros(len(xyxy))
        clss = r.boxes.cls.cpu().numpy() if r.boxes.cls is not None else np.zeros(len(xyxy))
        ids = None
        if r.boxes.id is not None:
            ids = r.boxes.id.cpu().numpy()

        for i, box in enumerate(xyxy):
            x1, y1, x2, y2 = [int(v) for v in box]
            bw = max(1, x2 - x1)
            bh = max(1, y2 - y1)
            area_ratio = float((bw * bh) / float(w * h))
            if area_ratio < args.min_area_ratio or area_ratio > args.max_area_ratio:
                continue

            pad = int(max(bw, bh) * args.padding_ratio)
            pad = clamp(pad, args.min_padding, args.max_padding) + args.min_padding
            cx1 = clamp(x1 - pad, 0, w)
            cy1 = clamp(y1 - pad, 0, h)
            cx2 = clamp(x2 + pad, 0, w)
            cy2 = clamp(y2 + pad, 0, h)
            crop = image[cy1:cy2, cx1:cx2]
            if crop.size == 0:
                continue

            crop_gray = cv2.cvtColor(crop, cv2.COLOR_BGR2GRAY)
            sharp = img_sharpness(crop_gray)
            sharp_norm = min(1.0, sharp / 320.0)
            conf = float(confs[i]) if i < len(confs) else 0.0
            score = conf * 0.55 + sharp_norm * 0.45
            if score < args.min_cv_score:
                continue

            if ids is not None and i < len(ids):
                track_id = f"trk_{int(ids[i])}"
            else:
                track_counter += 1
                track_id = f"trk_u_{track_counter:04d}"

            crop_name = f"{Path(frame_name).stem}__{track_id}__{i:02d}.png"
            crop_path = candidates_dir / crop_name
            cv2.imwrite(str(crop_path), crop)

            cand = DetectionCandidate(
                track_id=track_id,
                frame_name=frame_name,
                conf=conf,
                cls_id=int(clss[i]) if i < len(clss) else -1,
                x1=cx1,
                y1=cy1,
                x2=cx2,
                y2=cy2,
                area_ratio=area_ratio,
                sharpness=sharp,
                cv_score=score,
                crop_path=crop_path,
            )
            grouped.setdefault(track_id, []).append(cand)

    if not grouped:
        raise SystemExit("No detection candidates found. Try lowering --conf or --min-area-ratio.")

    selections: List[SelectedCrop] = []
    for track_id, items in sorted(grouped.items()):
        items = sorted(items, key=lambda c: c.cv_score, reverse=True)[: args.max_candidates_per_track]
        pick_idx = 0
        pick_reason = "cv_top_score"
        label = track_id

        if args.llm_review and len(items) > 1:
            llm = llm_pick_candidate(track_id, items[: args.llm_topk], args.llm_model, args.moonshot_base_url)
            if llm is not None:
                pick_idx, reason = llm
                pick_idx = clamp(pick_idx, 0, len(items) - 1)
                pick_reason = reason
                if "|label:" in reason:
                    label = reason.split("|label:", 1)[1].strip().replace(" ", "_")

        chosen = items[pick_idx]
        safe_label = "".join(ch if ch.isalnum() or ch in ("_", "-") else "_" for ch in label.lower())
        final_name = f"symbol_{safe_label}.png"
        final_path = final_dir / final_name
        shutil.copy2(chosen.crop_path, final_path)

        selections.append(
            SelectedCrop(
                track_id=track_id,
                selected_crop=final_path,
                source_frame=chosen.frame_name,
                reason=pick_reason,
                label=safe_label,
            )
        )

    report_csv = out_dir / "yolo-track-report.csv"
    with report_csv.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.writer(fh)
        writer.writerow(["track_id", "label", "source_frame", "selected_crop", "reason"])
        for s in selections:
            writer.writerow([s.track_id, s.label, s.source_frame, str(s.selected_crop), s.reason])

    report_md = out_dir / "yolo-track-report.md"
    lines = [
        "# YOLO Track Symbol Extraction Report",
        "",
        f"- Frames listed: {len(frames_list)}",
        f"- Tracks selected: {len(selections)}",
        f"- Candidates dir: `{candidates_dir}`",
        f"- Final dir: `{final_dir}`",
        f"- Report CSV: `{report_csv}`",
        "",
        "## Selected outputs",
    ]
    for s in selections:
        lines.append(f"- `{s.selected_crop.name}` from `{s.source_frame}` ({s.track_id}) reason={s.reason}")
    report_md.write_text("\n".join(lines) + "\n", encoding="utf-8")

    print(f"Done. Final symbol crops: {final_dir}")
    print(f"Report: {report_csv}")


if __name__ == "__main__":
    main()
