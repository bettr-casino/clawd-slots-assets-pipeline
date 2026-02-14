#!/usr/bin/env python3
"""
CV-first symbol boundary extraction for slot frames.

Reads a human-curated symbol-frames.txt list, detects candidate symbol regions,
exports cropped PNGs, and writes a quality report.

This script intentionally avoids LLM-based boundary decisions.
"""

from __future__ import annotations

import argparse
import csv
import os
from dataclasses import dataclass
from pathlib import Path
from typing import List, Tuple

cv2 = None
np = None


@dataclass
class Candidate:
    frame_name: str
    contour_idx: int
    x: int
    y: int
    w: int
    h: int
    area_px: int
    sharpness: float
    edge_density: float
    score: float
    crop_path: Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Extract symbol boundary candidates from curated frame list."
    )
    parser.add_argument("--video-name", default="CLEOPATRA")
    parser.add_argument(
        "--yt-base-dir",
        default=os.environ.get(
            "YT_BASE_DIR",
            "/workspaces/clawd-slots-assets-pipeline/yt",
        ),
    )
    parser.add_argument(
        "--symbol-frames",
        default=None,
        help="Path to symbol-frames.txt (defaults under yt/<VIDEO_NAME>/symbol-frames.txt)",
    )
    parser.add_argument(
        "--frames-dir",
        default=None,
        help="Frames directory (defaults under yt/<VIDEO_NAME>/frames)",
    )
    parser.add_argument(
        "--output-dir",
        default=None,
        help="Output directory for crops and reports (defaults under yt/<VIDEO_NAME>/output/symbol-candidates)",
    )
    parser.add_argument("--min-area-ratio", type=float, default=0.005)
    parser.add_argument("--max-area-ratio", type=float, default=0.35)
    parser.add_argument("--min-aspect-ratio", type=float, default=0.35)
    parser.add_argument("--max-aspect-ratio", type=float, default=1.9)
    parser.add_argument("--padding", type=int, default=8)
    parser.add_argument(
        "--padding-ratio",
        type=float,
        default=0.22,
        help="Extra expansion around a candidate as ratio of max(box width, box height).",
    )
    parser.add_argument("--min-padding", type=int, default=10)
    parser.add_argument("--max-padding", type=int, default=80)
    parser.add_argument("--max-crops-per-frame", type=int, default=8)
    parser.add_argument(
        "--min-score",
        type=float,
        default=0.20,
        help="Lower values keep more crops; raise to filter fuzzy crops.",
    )
    return parser.parse_args()


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
        else (root / "output" / "symbol-candidates")
    )
    return symbol_frames, frames_dir, output_dir


def load_frame_list(path: Path) -> List[str]:
    if not path.exists():
        raise SystemExit(f"symbol-frames file not found: {path}")
    frames: List[str] = []
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        frames.append(line)
    if not frames:
        raise SystemExit(f"No frame entries found in {path}")
    return frames


def image_sharpness(gray: np.ndarray) -> float:
    return float(cv2.Laplacian(gray, cv2.CV_64F).var())


def nms_boxes(
    boxes: List[Tuple[int, int, int, int, float]], iou_thresh: float = 0.35
) -> List[Tuple[int, int, int, int, float]]:
    if not boxes:
        return []

    arr = np.array(boxes, dtype=np.float32)
    x1 = arr[:, 0]
    y1 = arr[:, 1]
    x2 = arr[:, 0] + arr[:, 2]
    y2 = arr[:, 1] + arr[:, 3]
    scores = arr[:, 4]
    areas = (x2 - x1 + 1) * (y2 - y1 + 1)
    order = scores.argsort()[::-1]

    keep: List[int] = []
    while order.size > 0:
        i = int(order[0])
        keep.append(i)
        xx1 = np.maximum(x1[i], x1[order[1:]])
        yy1 = np.maximum(y1[i], y1[order[1:]])
        xx2 = np.minimum(x2[i], x2[order[1:]])
        yy2 = np.minimum(y2[i], y2[order[1:]])
        w = np.maximum(0.0, xx2 - xx1 + 1)
        h = np.maximum(0.0, yy2 - yy1 + 1)
        inter = w * h
        iou = inter / (areas[i] + areas[order[1:]] - inter + 1e-7)
        inds = np.where(iou <= iou_thresh)[0]
        order = order[inds + 1]

    return [boxes[i] for i in keep]


def detect_candidates(
    image: np.ndarray,
    min_area_ratio: float,
    max_area_ratio: float,
    min_aspect_ratio: float,
    max_aspect_ratio: float,
    max_crops_per_frame: int,
) -> List[Tuple[int, int, int, int, float]]:
    h, w = image.shape[:2]
    frame_area = float(h * w)
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    blur = cv2.GaussianBlur(gray, (5, 5), 0)

    edges = cv2.Canny(blur, 40, 120)
    thresh = cv2.adaptiveThreshold(
        blur,
        255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY_INV,
        31,
        3,
    )
    mask = cv2.bitwise_or(edges, thresh)
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel, iterations=2)
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel, iterations=1)

    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    raw_boxes: List[Tuple[int, int, int, int, float]] = []
    for contour in contours:
        x, y, cw, ch = cv2.boundingRect(contour)
        area = float(cw * ch)
        area_ratio = area / frame_area
        if area_ratio < min_area_ratio or area_ratio > max_area_ratio:
            continue
        aspect = cw / max(1.0, float(ch))
        if aspect < min_aspect_ratio or aspect > max_aspect_ratio:
            continue

        # favor boxes near center and with dense edges
        patch = mask[y : y + ch, x : x + cw]
        edge_density = float(np.count_nonzero(patch)) / max(1.0, area)
        cx = x + cw / 2.0
        cy = y + ch / 2.0
        center_bias = 1.0 - (
            abs(cx - w / 2.0) / (w / 2.0) * 0.35 + abs(cy - h / 2.0) / (h / 2.0) * 0.65
        )
        area_bonus = min(1.0, area_ratio / 0.12)
        # Larger boxes are favored to reduce partial-symbol crops.
        score = (
            max(0.0, center_bias) * 0.45
            + min(1.0, edge_density * 2.0) * 0.25
            + area_bonus * 0.30
        )
        raw_boxes.append((x, y, cw, ch, score))

    merged = nms_boxes(raw_boxes, iou_thresh=0.35)
    merged.sort(key=lambda b: b[4], reverse=True)
    return merged[:max_crops_per_frame]


def save_report(candidates: List[Candidate], output_dir: Path) -> None:
    report_csv = output_dir / "boundary-report.csv"
    report_md = output_dir / "boundary-report.md"

    with report_csv.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.writer(fh)
        writer.writerow(
            [
                "frame_name",
                "contour_idx",
                "x",
                "y",
                "w",
                "h",
                "area_px",
                "sharpness",
                "edge_density",
                "score",
                "crop_path",
            ]
        )
        for c in candidates:
            writer.writerow(
                [
                    c.frame_name,
                    c.contour_idx,
                    c.x,
                    c.y,
                    c.w,
                    c.h,
                    c.area_px,
                    f"{c.sharpness:.4f}",
                    f"{c.edge_density:.4f}",
                    f"{c.score:.4f}",
                    str(c.crop_path),
                ]
            )

    by_frame: dict[str, List[Candidate]] = {}
    for c in candidates:
        by_frame.setdefault(c.frame_name, []).append(c)

    lines = [
        "# Symbol Boundary Extraction Report",
        "",
        f"- Total accepted crops: {len(candidates)}",
        f"- CSV: `{report_csv}`",
        "",
        "## Per-frame summary",
    ]
    for frame_name, rows in sorted(by_frame.items()):
        best = max(rows, key=lambda x: x.score)
        lines.append(
            f"- `{frame_name}`: {len(rows)} crops (best score={best.score:.3f}, sharpness={best.sharpness:.1f})"
        )

    report_md.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    args = parse_args()

    global cv2, np
    try:
        import cv2 as _cv2  # type: ignore
        import numpy as _np
    except ImportError as exc:  # pragma: no cover
        raise SystemExit(
            "Missing dependency: opencv-python (cv2) and numpy are required.\n"
            "Install with: pip install opencv-python numpy"
        ) from exc

    cv2 = _cv2
    np = _np

    symbol_frames_path, frames_dir, output_dir = resolve_paths(args)
    output_dir.mkdir(parents=True, exist_ok=True)

    frame_names = load_frame_list(symbol_frames_path)
    accepted: List[Candidate] = []

    for frame_name in frame_names:
        frame_path = frames_dir / frame_name
        if not frame_path.exists():
            print(f"[WARN] Missing frame: {frame_path}")
            continue

        image = cv2.imread(str(frame_path), cv2.IMREAD_COLOR)
        if image is None:
            print(f"[WARN] Failed to read image: {frame_path}")
            continue

        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        frame_sharpness = image_sharpness(gray)
        boxes = detect_candidates(
            image=image,
            min_area_ratio=args.min_area_ratio,
            max_area_ratio=args.max_area_ratio,
            min_aspect_ratio=args.min_aspect_ratio,
            max_aspect_ratio=args.max_aspect_ratio,
            max_crops_per_frame=args.max_crops_per_frame,
        )

        h, w = image.shape[:2]
        frame_stem = Path(frame_name).stem
        for idx, (x, y, bw, bh, score) in enumerate(boxes, start=1):
            dynamic_pad = int(max(bw, bh) * args.padding_ratio) + args.padding
            dynamic_pad = max(args.min_padding, min(args.max_padding, dynamic_pad))
            x0 = max(0, x - dynamic_pad)
            y0 = max(0, y - dynamic_pad)
            x1 = min(w, x + bw + dynamic_pad)
            y1 = min(h, y + bh + dynamic_pad)

            crop = image[y0:y1, x0:x1]
            if crop.size == 0:
                continue

            crop_gray = cv2.cvtColor(crop, cv2.COLOR_BGR2GRAY)
            crop_sharpness = image_sharpness(crop_gray)
            edges = cv2.Canny(crop_gray, 40, 120)
            edge_density = float(np.count_nonzero(edges)) / max(
                1.0, float(crop_gray.shape[0] * crop_gray.shape[1])
            )

            # score fusion: contour score + crop sharpness + edge density
            sharp_norm = min(1.0, crop_sharpness / 350.0)
            final_score = score * 0.45 + sharp_norm * 0.40 + min(1.0, edge_density * 3.0) * 0.15
            if final_score < args.min_score:
                continue

            crop_name = f"{frame_stem}__cand_{idx:02d}.png"
            crop_path = output_dir / crop_name
            cv2.imwrite(str(crop_path), crop)

            accepted.append(
                Candidate(
                    frame_name=frame_name,
                    contour_idx=idx,
                    x=x0,
                    y=y0,
                    w=x1 - x0,
                    h=y1 - y0,
                    area_px=(x1 - x0) * (y1 - y0),
                    sharpness=float(crop_sharpness),
                    edge_density=float(edge_density),
                    score=float(final_score),
                    crop_path=crop_path,
                )
            )

    if not accepted:
        print("No crops passed thresholds. Try lowering --min-score or --min-area-ratio.")
        return

    accepted.sort(key=lambda c: c.score, reverse=True)
    save_report(accepted, output_dir)
    print(f"Saved {len(accepted)} candidate crops to: {output_dir}")
    print(f"Report: {output_dir / 'boundary-report.csv'}")


if __name__ == "__main__":
    main()
