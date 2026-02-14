# Analysis QA Checklist (Three-Phase Workflow)

This file replaces the old mobile optimization workflow. It now defines **quality checks** for the three-phase intake, analysis, and symbol generation pipeline.

## Phase 1: Frame Extraction QA

- tags.txt exists and is human-authored at `yt/CLEOPATRA/tags.txt`
- Local video file exists under `yt/CLEOPATRA/video/`
- S3 download succeeded and file size is non-zero
- Frames output directory exists at `yt/CLEOPATRA/frames/`
- Each tags.txt entry produced the correct frames:
  - Single frame entries: one PNG
  - Animation range entries: 60fps frame sequence
- Frame filenames are unique and traceable to timestamps
- No ffmpeg errors or warnings reported
- MEMORY.md captures extraction status

## Phase 2 QA

- tags.txt present (human-authored, not modified by bot)
- analysis.md includes: symbol inventory, reel layout, paytable, math model, bonus features, animations, visual style
- analysis.md saved under `yt/CLEOPATRA/analysis.md`
- Math model spreadsheets/CSVs saved under `yt/CLEOPATRA/output/`

## Phase 3 QA

- Symbol textures exist under `yt/CLEOPATRA/output/symbols/`
- Filenames include symbol names
- Each texture is a full, clean single-symbol image (no cropped/partial symbols)
- No reel strips, neighboring symbols, or UI fragments in final textures
- User review captured (approve all, reject all, or reject list)
- Rejected symbols regenerated and re-reviewed if needed
