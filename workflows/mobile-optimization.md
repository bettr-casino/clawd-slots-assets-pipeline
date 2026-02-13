# Analysis QA Checklist (Three-Phase Workflow)

This file replaces the old mobile optimization workflow. It now defines **quality checks** for the three-phase intake, analysis, and symbol generation pipeline.

## Phase 1: Intake QA

- Local video file exists under `yt/CLEOPATRA/video/`
- S3 download succeeded and file size is non-zero
- Frames output directory exists at `yt/CLEOPATRA/frames/`
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
- analysis.md saved under `yt/CLEOPATRA/analysis.md`

## Phase 3 QA

- Symbol textures exist under `yt/CLEOPATRA/output/symbols/`
- Filenames include symbol names
- User review captured (approve all, reject all, or reject list)
- Rejected symbols regenerated and re-reviewed if needed
