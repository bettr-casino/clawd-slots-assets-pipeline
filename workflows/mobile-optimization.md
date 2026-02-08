# Analysis QA Checklist (Single-Phase Workflow)

This file replaces the old mobile optimization workflow. It now defines **quality checks** for the single-phase intake + frame extraction pipeline.

## Phase 1: Intake QA

- Local video file exists under `yt/<file-name>/video/`
- If missing, filename was confirmed with the human (default: `CLEOPATRA.webm`)
- S3 download succeeded and file size is non-zero
- Frames output directory exists at `yt/<file-name>/frames/`
- Timestamps are in `HH:MM:SS` format

## Frame Extraction QA

- Each requested timestamp produced exactly one frame
- Frame filenames are unique and traceable to timestamps
- No ffmpeg errors or warnings reported
- MEMORY.md captures the list of timestamps extracted

## Delivery QA

- Human confirmation recorded (download and timestamps)
- MEMORY.md updated with final status
- Any bot-generated scripts must live under `/workspaces/clawd-slots-assets-pipeline/scripts/`
