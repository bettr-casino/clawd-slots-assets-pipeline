#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <file-name> <timestamp HH:MM:SS>"
  exit 1
fi

file_name_raw="$1"
timestamp="$2"

if [[ ! "$file_name_raw" =~ ^[A-Za-z0-9_-]+(\.webm)?$ ]]; then
  echo "Invalid file name: $file_name_raw"
  exit 1
fi

if [[ -z "${YT_BASE_DIR:-}" ]]; then
  echo "YT_BASE_DIR is not set"
  exit 1
fi

file_name_base="$file_name_raw"
if [[ "$file_name_base" == *.webm ]]; then
  file_name_base="${file_name_base%.webm}"
fi

video_dir="$YT_BASE_DIR/$file_name_base/video"
frames_dir="$YT_BASE_DIR/$file_name_base/frames"
video_path="$video_dir/$file_name_base.webm"

mkdir -p "$video_dir" "$frames_dir"

if [[ ! -f "$video_path" ]]; then
  curl -fL "https://bettr-casino-assets.s3.us-west-2.amazonaws.com/yt/$file_name_base.webm" \
    -o "$video_path"
fi

safe_stamp="${timestamp//:/}"
output_file="$frames_dir/frame_${safe_stamp}.png"

ffmpeg -ss "$timestamp" -i "$video_path" -frames:v 1 "$output_file" -hide_banner -loglevel error

echo "Wrote $output_file"
