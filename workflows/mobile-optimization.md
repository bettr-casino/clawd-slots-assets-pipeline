# Analysis QA Checklist (Three-Phase Workflow)

This file replaces the old mobile optimization workflow. It now defines **quality checks** for the three-phase intake, analysis, and symbol generation pipeline.

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

## Phase 2 QA

- tags.txt present and updated
- analysis.md includes symbol inventory, reel layout, and animation notes
- analysis.md saved under `yt/<file-name>/analysis.md`

## Phase 3 QA

- Symbol textures exist under `yt/<file-name>/output/symbols/`
- Filenames include symbol names
- User review captured (approve all, reject all, or reject list)
- Rejected symbols regenerated and re-reviewed if needed
