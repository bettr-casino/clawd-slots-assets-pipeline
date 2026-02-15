#!/usr/bin/env python3
"""
Annotation-first symbol extraction for CLEOPATRA pipeline.

Reads frame filenames from symbol-frames.txt, loads matching Fabric JSON annotation
files (<frame_stem>_annotated.json), crops all rectangles from source frames,
deduplicates similar symbols across frames, optionally asks Kimi to label each
deduped symbol, and writes final PNGs to output/symbols.
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
from typing import Any, Dict, List, Optional

cv2 = None
np = None
requests = None


@dataclass
class CropCandidate:
    candidate_id: str
    frame_name: str
    source_json: str
    rect_idx: int
    x1: int
    y1: int
    x2: int
    y2: int
    width: int
    height: int
    area_ratio: float
    sharpness: float
    score: float
    dhash64: int
    crop_path: Path


@dataclass
class FinalSymbol:
    candidate_id: str
    output_name: str
    output_path: Path
    frame_name: str
    reason: str
    label: str
    score: float


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Extract symbols from manual annotations and deduplicate."
    )
    parser.add_argument("--video-name", default="CLEOPATRA")
    parser.add_argument(
        "--yt-base-dir",
        default=os.environ.get("YT_BASE_DIR", "/workspaces/clawd-slots-assets-pipeline/yt"),
    )
    parser.add_argument("--symbol-frames", default=None)
    parser.add_argument("--frames-dir", default=None)
    parser.add_argument("--output-dir", default=None, help="Final symbols dir (default: .../output/symbols)")
    parser.add_argument("--annotation-suffix", default="_annotated.json")
    parser.add_argument("--min-width", type=int, default=20)
    parser.add_argument("--min-height", type=int, default=20)
    parser.add_argument("--min-area-ratio", type=float, default=0.001)
    parser.add_argument("--dedup-hamming-threshold", type=int, default=8)
    parser.add_argument("--llm-label", action="store_true", help="Use Kimi to label deduped symbols.")
    parser.add_argument("--llm-model", default="kimi-k2.5")
    parser.add_argument("--moonshot-base-url", default="https://api.moonshot.ai/v1")
    return parser.parse_args()


def lazy_imports() -> None:
    global cv2, np, requests
    try:
        import cv2 as _cv2  # type: ignore
        import numpy as _np
        import requests as _requests
    except Exception as exc:  # pragma: no cover
        raise SystemExit(
            "Missing dependencies. Install with:\n"
            "  pip install opencv-python numpy requests\n"
        ) from exc
    cv2 = _cv2
    np = _np
    requests = _requests


def resolve_paths(args: argparse.Namespace) -> tuple[Path, Path, Path]:
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
        else (root / "output" / "symbols")
    )
    return symbol_frames, frames_dir, output_dir


def load_frame_list(path: Path) -> List[str]:
    if not path.exists():
        raise SystemExit(f"Missing symbol-frames.txt: {path}")
    frames: List[str] = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        frames.append(line)
    if not frames:
        raise SystemExit(f"No frames listed in {path}")
    return frames


def parse_rectangles(json_path: Path) -> List[Dict[str, Any]]:
    obj = json.loads(json_path.read_text(encoding="utf-8"))
    rows = []
    for idx, item in enumerate(obj.get("objects", []), start=1):
        if item.get("type") != "rect":
            continue
        left = float(item.get("left", 0))
        top = float(item.get("top", 0))
        width = float(item.get("width", 0)) * float(item.get("scaleX", 1))
        height = float(item.get("height", 0)) * float(item.get("scaleY", 1))
        rows.append(
            {
                "idx": idx,
                "x1": int(round(left)),
                "y1": int(round(top)),
                "x2": int(round(left + width)),
                "y2": int(round(top + height)),
            }
        )
    return rows


def image_sharpness(gray: "np.ndarray") -> float:
    return float(cv2.Laplacian(gray, cv2.CV_64F).var())


def dhash64(image: "np.ndarray") -> int:
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    resized = cv2.resize(gray, (9, 8), interpolation=cv2.INTER_AREA)
    diff = resized[:, 1:] > resized[:, :-1]
    bits = 0
    for i, v in enumerate(diff.flatten()):
        if bool(v):
            bits |= 1 << i
    return bits


def hamming(a: int, b: int) -> int:
    return (a ^ b).bit_count()


def encode_image_data_uri(path: Path) -> str:
    data = base64.b64encode(path.read_bytes()).decode("utf-8")
    return f"data:image/png;base64,{data}"


def sanitize_label(label: str) -> str:
    clean = "".join(ch if ch.isalnum() or ch in ("_", "-") else "_" for ch in label.lower().strip())
    clean = "_".join(part for part in clean.split("_") if part)
    return clean or "unknown"


def llm_label_crop(crop_path: Path, model_name: str, base_url: str) -> Optional[tuple[str, str]]:
    api_key = os.environ.get("MOONSHOT_API_KEY")
    if not api_key:
        return None
    prompt = (
        "You are labeling slot machine symbol crops.\n"
        "Return strict JSON only:\n"
        '{"label":"snake_case_symbol_name","reason":"short reason"}\n'
        "Rules:\n"
        "- label must be short, lowercase snake_case.\n"
        "- do not include 'symbol_' prefix.\n"
        "- if uncertain, still provide best short label.\n"
    )
    payload = {
        "model": model_name,
        "temperature": 0,
        "messages": [
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": prompt},
                    {"type": "image_url", "image_url": {"url": encode_image_data_uri(crop_path)}},
                ],
            }
        ],
    }
    headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}
    try:
        resp = requests.post(
            f"{base_url.rstrip('/')}/chat/completions",
            headers=headers,
            data=json.dumps(payload),
            timeout=45,
        )
        resp.raise_for_status()
        text = resp.json()["choices"][0]["message"]["content"]
        if isinstance(text, list):
            text = "".join([x.get("text", "") for x in text if isinstance(x, dict)])
        text = str(text).strip()
        if text.startswith("```"):
            text = text.strip("`")
            if text.lower().startswith("json"):
                text = text[4:].strip()
        obj = json.loads(text)
        label = sanitize_label(str(obj.get("label", "unknown")))
        reason = str(obj.get("reason", "llm_label")).strip() or "llm_label"
        return label, reason
    except Exception:
        return None


def write_reports(base_dir: Path, candidates: List[CropCandidate], finals: List[FinalSymbol]) -> None:
    csv_path = base_dir / "annotation-extract-report.csv"
    md_path = base_dir / "annotation-extract-report.md"

    with csv_path.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.writer(fh)
        writer.writerow(
            [
                "candidate_id",
                "frame_name",
                "source_json",
                "rect_idx",
                "x1",
                "y1",
                "x2",
                "y2",
                "width",
                "height",
                "area_ratio",
                "sharpness",
                "score",
                "dhash64",
                "crop_path",
            ]
        )
        for c in candidates:
            writer.writerow(
                [
                    c.candidate_id,
                    c.frame_name,
                    c.source_json,
                    c.rect_idx,
                    c.x1,
                    c.y1,
                    c.x2,
                    c.y2,
                    c.width,
                    c.height,
                    f"{c.area_ratio:.6f}",
                    f"{c.sharpness:.4f}",
                    f"{c.score:.4f}",
                    hex(c.dhash64),
                    str(c.crop_path),
                ]
            )

    lines = [
        "# Annotation Symbol Extraction Report",
        "",
        f"- Total candidates: {len(candidates)}",
        f"- Final deduplicated symbols: {len(finals)}",
        f"- Candidate report: `{csv_path}`",
        "",
        "## Final outputs",
    ]
    for s in finals:
        lines.append(
            f"- `{s.output_name}` from `{s.frame_name}` ({s.candidate_id}) score={s.score:.3f} reason={s.reason}"
        )
    md_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    args = parse_args()
    lazy_imports()
    symbol_frames, frames_dir, output_dir = resolve_paths(args)

    frame_names = load_frame_list(symbol_frames)
    output_dir.mkdir(parents=True, exist_ok=True)
    run_dir = output_dir.parent / "symbols-annotation"
    candidates_dir = run_dir / "candidates"
    run_dir.mkdir(parents=True, exist_ok=True)
    candidates_dir.mkdir(parents=True, exist_ok=True)

    candidates: List[CropCandidate] = []
    candidate_counter = 0

    for frame_name in frame_names:
        frame_path = frames_dir / frame_name
        if not frame_path.exists():
            print(f"[WARN] Missing frame: {frame_path}")
            continue
        ann_path = frame_path.with_name(f"{frame_path.stem}{args.annotation_suffix}")
        if not ann_path.exists():
            print(f"[WARN] Missing annotation JSON for frame: {ann_path.name}")
            continue

        image = cv2.imread(str(frame_path), cv2.IMREAD_COLOR)
        if image is None:
            print(f"[WARN] Unable to read frame: {frame_path}")
            continue
        h, w = image.shape[:2]
        rects = parse_rectangles(ann_path)
        if not rects:
            print(f"[WARN] No rectangle annotations in: {ann_path.name}")
            continue

        for rect in rects:
            x1 = max(0, min(w, int(rect["x1"])))
            y1 = max(0, min(h, int(rect["y1"])))
            x2 = max(0, min(w, int(rect["x2"])))
            y2 = max(0, min(h, int(rect["y2"])))
            bw = max(0, x2 - x1)
            bh = max(0, y2 - y1)
            if bw < args.min_width or bh < args.min_height:
                continue

            area_ratio = float((bw * bh) / float(w * h))
            if area_ratio < args.min_area_ratio:
                continue

            crop = image[y1:y2, x1:x2]
            if crop.size == 0:
                continue
            gray = cv2.cvtColor(crop, cv2.COLOR_BGR2GRAY)
            sharp = image_sharpness(gray)
            area_norm = min(1.0, area_ratio / 0.08)
            sharp_norm = min(1.0, sharp / 320.0)
            score = sharp_norm * 0.60 + area_norm * 0.40
            digest = dhash64(crop)

            candidate_counter += 1
            cid = f"cand_{candidate_counter:04d}"
            crop_path = candidates_dir / f"{Path(frame_name).stem}__{cid}.png"
            cv2.imwrite(str(crop_path), crop)

            candidates.append(
                CropCandidate(
                    candidate_id=cid,
                    frame_name=frame_name,
                    source_json=ann_path.name,
                    rect_idx=int(rect["idx"]),
                    x1=x1,
                    y1=y1,
                    x2=x2,
                    y2=y2,
                    width=bw,
                    height=bh,
                    area_ratio=area_ratio,
                    sharpness=sharp,
                    score=score,
                    dhash64=digest,
                    crop_path=crop_path,
                )
            )

    if not candidates:
        raise SystemExit(
            "No annotation crops found. Ensure frame entries exist in symbol-frames.txt "
            "and each frame has a matching *_annotated.json with rectangles."
        )

    # Dedup by dHash + score.
    clusters: List[List[CropCandidate]] = []
    for cand in sorted(candidates, key=lambda c: c.score, reverse=True):
        assigned = False
        for cluster in clusters:
            rep = cluster[0]
            if hamming(cand.dhash64, rep.dhash64) <= args.dedup_hamming_threshold:
                cluster.append(cand)
                assigned = True
                break
        if not assigned:
            clusters.append([cand])

    finals: List[FinalSymbol] = []
    used_names: Dict[str, int] = {}
    for idx, cluster in enumerate(clusters, start=1):
        best = sorted(cluster, key=lambda c: c.score, reverse=True)[0]
        label = f"symbol_{idx:03d}"
        reason = f"dhash_dedup(size={len(cluster)})"

        if args.llm_label:
            llm = llm_label_crop(best.crop_path, args.llm_model, args.moonshot_base_url)
            if llm is not None:
                label, llm_reason = llm
                reason = f"{reason}|{llm_reason}"

        base_name = sanitize_label(label)
        used_names[base_name] = used_names.get(base_name, 0) + 1
        suffix = f"_{used_names[base_name]:02d}" if used_names[base_name] > 1 else ""
        output_name = f"symbol_{base_name}{suffix}.png"
        out_path = output_dir / output_name
        shutil.copy2(best.crop_path, out_path)
        finals.append(
            FinalSymbol(
                candidate_id=best.candidate_id,
                output_name=output_name,
                output_path=out_path,
                frame_name=best.frame_name,
                reason=reason,
                label=base_name,
                score=best.score,
            )
        )

    write_reports(run_dir, candidates, finals)
    print(f"Done. Wrote {len(finals)} deduplicated symbols to: {output_dir}")
    print(f"Candidates: {candidates_dir}")
    print(f"Report: {run_dir / 'annotation-extract-report.csv'}")


if __name__ == "__main__":
    main()
