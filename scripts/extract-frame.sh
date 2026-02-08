#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <video-path> <timestamp HH:MM:SS> [output-dir]"
  exit 1
fi

video_path="$1"
timestamp="$2"
output_dir="${3:-$(dirname "$video_path")/../frames}"

mkdir -p "$output_dir"

safe_stamp="${timestamp//:/}"
output_file="$output_dir/frame_${safe_stamp}.png"

ffmpeg -ss "$timestamp" -i "$video_path" -frames:v 1 "$output_file" -hide_banner -loglevel error

echo "Wrote $output_file"
