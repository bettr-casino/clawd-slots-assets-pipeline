# autonomous-9-step-loop.md
This document replaces the old 9-step loop with the **four-phase workflow** (Phase 0–3).

## Phase 0: Human Preparation

- Human reviews video, authors `tags.txt`, sends `start` on Telegram to approve
- Bot waits — does not process anything until `start` is received

## Phase 1: Frame Extraction

### Steps

1. **Read tags.txt** — human-authored file at `$YT_BASE_DIR/CLEOPATRA/tags.txt` (do not ask for timestamps)
2. **Extract Frames** — for each tags.txt entry, run `extract-frame.sh` (auto-downloads video from S3 if missing)
   - Single frame (start == end): one PNG
   - Animation range (start < end): all frames at 60fps

### Output

- Video stored at `$YT_BASE_DIR/CLEOPATRA/video/CLEOPATRA.webm`
- Frames stored under `$YT_BASE_DIR/CLEOPATRA/frames/`
- MEMORY.md updated with extraction status

---

## Phase 2: Multimodal LLM Analysis

After frame extraction and tags.txt are ready, confirm with the user before starting analysis.

- Use Kimi K2.5 to analyze frames guided by tags.txt descriptions
- Reverse-engineer: symbol inventory, reel layout, paytable, math model, bonus features, animations, visual style
- Write results to `$YT_BASE_DIR/CLEOPATRA/analysis.md`
- Write math model spreadsheets and CSVs to `$YT_BASE_DIR/CLEOPATRA/output/`
- Any bot-generated scripts must live under `/workspaces/clawd-slots-assets-pipeline/scripts/`

---

## Phase 3: Symbol Asset Generation

After Phase 2 analysis is complete, generate symbol textures using the frames, tags.txt, and analysis.md.

- Generate a texture per symbol that closely matches the original symbol in the frames
- Save textures under `$YT_BASE_DIR/CLEOPATRA/output/symbols/` with filenames that include the symbol name
- Present all symbol textures for review
- If the user rejects all or specific symbols, regenerate only those symbols and re-present

---

## Rules

- Follow all four phases (0–3) in order.
- Always checkpoint progress in MEMORY.md.
- If the video already exists, skip the download step.
