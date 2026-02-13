# Egyptian MVP Pipeline (Three-Phase Workflow)
This workflow is for **Egyptian-themed slot machines** (Cleopatra, Luxor, etc.) using the three-phase intake, analysis, and symbol asset generation process.

## Phase 1: Frame Extraction

1. **Read tags.txt** — human-authored file at `$YT_BASE_DIR/CLEOPATRA/tags.txt` (do not ask for timestamps)
2. **Extract Frames** — for each tags.txt entry, run `extract-frame.sh` (auto-downloads video from S3 if missing)

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

## Notes

- Filename (`CLEOPATRA`) and YouTube URL are hardcoded — do not ask the human.
- The human authors tags.txt with timestamps; the bot reads it.
- Multiple timestamps are allowed and should be processed one-by-one.
