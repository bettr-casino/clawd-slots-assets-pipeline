#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <file-name> <timestamp HH:MM:SS> [end-timestamp HH:MM:SS] [# comment]"
  exit 1
fi

file_name_raw="$1"
shift
start_ts="$1"
shift
end_ts=""
comment=""

timestamp_re='^[0-9]{2}:[0-9]{2}:[0-9]{2}$'
if [[ ! "$start_ts" =~ $timestamp_re ]]; then
  echo "Invalid timestamp: $start_ts"
  exit 1
fi

if [[ $# -gt 0 && "$1" =~ $timestamp_re ]]; then
  end_ts="$1"
  shift
fi

if [[ $# -gt 0 ]]; then
  comment="$*"
  if [[ "$comment" == \#* ]]; then
    comment="${comment#\#}"
    comment="${comment# }"
  fi
fi

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

ts_to_seconds() {
  local ts="$1"
  local h m s
  IFS=: read -r h m s <<< "$ts"
  echo $((10#$h * 3600 + 10#$m * 60 + 10#$s))
}

if [[ -z "$end_ts" ]]; then
  safe_stamp="${start_ts//:/_}"
  output_file="$frames_dir/frame__${safe_stamp}.01.png"

  ffmpeg -y -ss "$start_ts" -i "$video_path" -frames:v 1 "$output_file" -hide_banner -loglevel error
  echo "Wrote $output_file"
  if [[ -n "$comment" ]]; then
    tags_file="$frames_dir/../tags.txt"
    # Format: 00:00:16.01 00:00:16.01    comment
    printf "%s %s\t%s\n" "${start_ts}.01" "${start_ts}.01" "$comment" >> "$tags_file"
  fi
  exit 0
fi

start_seconds="$(ts_to_seconds "$start_ts")"
end_seconds="$(ts_to_seconds "$end_ts")"
if (( end_seconds < start_seconds )); then
  echo "Invalid range: $start_ts to $end_ts"
  exit 1
fi

duration_seconds=$((end_seconds - start_seconds + 1))
temp_dir="$(mktemp -d)"

  ffmpeg -y -ss "$start_ts" -t "$duration_seconds" -i "$video_path" -vf "fps=60" \
    -start_number 0 "$temp_dir/frame_%06d.png" -hide_banner -loglevel error

  if [[ -n "$comment" ]]; then
    tags_file="$frames_dir/../tags.txt"
    # Format: 00:00:24.01 00:00:32.01    comment
    start_tag="${start_ts}.01"
    end_seconds=$((end_seconds + 1))
    hh=$(printf "%02d" $((end_seconds / 3600)))
    mm=$(printf "%02d" $(((end_seconds % 3600) / 60)))
    ss=$(printf "%02d" $((end_seconds % 60)))
    end_tag="${hh}:${mm}:${ss}.01"
    printf "%s %s\t%s\n" "$start_tag" "$end_tag" "$comment" >> "$tags_file"
  fi

  shopt -s nullglob
  for frame_path in "$temp_dir"/frame_*.png; do
    frame_base="$(basename "$frame_path")"
    frame_index="${frame_base#frame_}"
    frame_index="${frame_index%.png}"
    frame_index=$((10#$frame_index))

    absolute_seconds=$((start_seconds + (frame_index / 60)))
    frame_in_second=$(((frame_index % 60) + 1))

    hh=$(printf "%02d" $((absolute_seconds / 3600)))
    mm=$(printf "%02d" $(((absolute_seconds % 3600) / 60)))
    ss=$(printf "%02d" $((absolute_seconds % 60)))
    stamp="${hh}_${mm}_${ss}"
    frame_suffix=$(printf "%02d" "$frame_in_second")
    output_file="$frames_dir/frame__${stamp}.${frame_suffix}.png"

    mv "$frame_path" "$output_file"
  done

  rmdir "$temp_dir"
  echo "Wrote frames to $frames_dir"
