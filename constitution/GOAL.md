# GOAL.md

## Primary Goal

Reverse-engineer a Las Vegas CLEOPATRA slot machine from a YouTube video to build a social casino slot (not real money) with the same look, feel, and animations. The human manually reviews the video, authors `tags.txt` with timestamps and descriptions, approves it, and the bot processes those tags to extract frames, analyze symbols/paytable/animations, and generate assets.

**Key Rules:**
- Video filename: `CLEOPATRA` (hardcoded — do not ask)
- YouTube URL: `https://www.youtube.com/watch?v=Ks8o3bl7OYQ` (hardcoded — do not ask)
- S3 URL: `https://bettr-casino-assets.s3.us-west-2.amazonaws.com/yt/CLEOPATRA.webm`
- `tags.txt` is **human-authored** — the bot reads it, never writes or modifies it
- `symbol-frames.txt` is **fully human-authored** — bot must never create or modify this file
- The bot **waits in Phase 0** until the human sends `start` to approve tags.txt
- Use `ffmpeg` via `/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh` for frame extraction
- Store videos under `$YT_BASE_DIR/CLEOPATRA/video/` and frames under `$YT_BASE_DIR/CLEOPATRA/frames/`
- `YT_BASE_DIR` must be set before downloads or extraction
- Always use absolute paths for file access and tool calls
- Send Telegram updates at each decision point
- Save checkpoint data in MEMORY.md

## tags.txt Format

The human authors `$YT_BASE_DIR/CLEOPATRA/tags.txt` with one entry per line:

```
START_TS END_TS    description
```

- **Single frame**: `START_TS == END_TS` — extract one frame at that timestamp
- **Animation range**: `START_TS < END_TS` — extract all frames at 60fps across the range

Examples:
```
00:00:16.01 00:00:16.01    game banner, denom
00:00:23.01 00:00:23.01    initial screen with symbols
00:00:24.01 00:00:32.01    complete spin with animation
```

The bot must parse tags.txt and use the descriptions to understand what each frame or sequence represents.

---

## Phase 0: Human Preparation (Wait for Approval)

### Objective
Wait for the human to finish reviewing the video and authoring `tags.txt`. The bot does **nothing** until the human sends `start` on Telegram.

### What the human does (outside the bot)
1. Watch the YouTube video
2. Identify timestamps of interest (single frames for stills, ranges for animations)
3. Edit `$YT_BASE_DIR/CLEOPATRA/tags.txt` with entries
4. Send `start` on Telegram when ready

### Bot behavior during Phase 0
- **Do not** read tags.txt, extract frames, or do any processing
- **Do** respond to `status` with: "Phase 0 — Waiting for you to approve tags.txt. Send `start` when ready."
- On receiving `start`: transition to Phase 1

---

## Phase 1: Frame Extraction

### Objective
Read `tags.txt` (authored by the human), download the video if missing, and extract frames for every entry.

### Steps

1. **Read tags.txt** at `$YT_BASE_DIR/CLEOPATRA/tags.txt` — do not ask the human for timestamps; they are already in the file
2. **Download video** if missing — the script auto-downloads from S3
3. **Extract frames** for each tags.txt entry:
   - Single frame (start == end): one PNG
   - Animation range (start < end): all frames at 60fps across the range
4. **Checkpoint**: Update MEMORY.md with extraction status

### Command

```bash
# Single frame
/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh "CLEOPATRA" "00:00:16"

# Animation range
/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh "CLEOPATRA" "00:00:24" "00:00:32" "# complete spin with animation"
```

### Output
- Single frames: `$YT_BASE_DIR/CLEOPATRA/frames/frame__HH_MM_SS.01.png`
- Animation ranges: `$YT_BASE_DIR/CLEOPATRA/frames/frame__HH_MM_SS.FF.png` (FF = frame number within each second, 01–60)

---

## Phase 2: Multimodal LLM Analysis

### Objective
Analyze the extracted frames using Kimi K2.5 to reverse-engineer the slot machine: symbols, reel layout, paytable, math model, and animations.

### Inputs
- Frames: `$YT_BASE_DIR/CLEOPATRA/frames/`
- Tags: `$YT_BASE_DIR/CLEOPATRA/tags.txt` (read descriptions to understand what each frame shows)

### Actions
- Ask the human for approval once via Telegram before starting analysis; record approval in MEMORY.md; do not re-ask on retries
- If the human replies `skip`, do not run analysis and transition directly to Phase 2.5 for `symbol-frames.txt` approval
- Use tags.txt descriptions to guide which frames to analyze for what purpose
- Reverse-engineer and document:
  1. **Symbol inventory** — all symbols (low/mid/high/special), their visual appearance, and estimated frequency
  2. **Reel layout** — number of reels, visible rows per reel, total positions
  3. **Paytable** — pay values for 3/4/5-of-a-kind per symbol (this is public information for real slot machines)
  4. **Math model** — RTP estimate, hit frequency, volatility, max win
  5. **Bonus features** — free spins, multipliers, special mechanics
  6. **Animations** — symbol landing animations, spin animations, win celebrations (use animation-range frames)
  7. **Visual style** — color palette, background theme, UI elements, typography
- When accessing frames, use absolute paths under `$YT_BASE_DIR`
- Helper scripts are allowed; bot-generated scripts must live under `/workspaces/clawd-slots-assets-pipeline/scripts/`
- Do not create assets or implement the game in this phase
- If `symbol-frames.txt` is missing, stop and ask the human to create it in the repository.
- Ask the human to add frame entries manually after reviewing extracted frames.

### Output
- `$YT_BASE_DIR/CLEOPATRA/analysis.md` — comprehensive analysis document
- `$YT_BASE_DIR/CLEOPATRA/output/` — math model spreadsheets and CSVs
- `$YT_BASE_DIR/CLEOPATRA/symbol-frames.txt` — human-authored frame list (filenames only)

---

## Phase 2.5: Human Approval of symbol-frames.txt

### Objective
Pause after analysis and wait for explicit human approval of `symbol-frames.txt` before any symbol generation.

### Rules
- Do not enter Phase 3 until `symbol-frames.txt` approval is recorded in MEMORY.md
- Human must author entries in `symbol-frames.txt`; bot must use the approved version as-is
- `symbol-frames.txt` format is strict: one frame filename per line, no symbol labels
- If `symbol-frames.txt` is missing, remain in Phase 2.5 and ask human to create it
- If `symbol-frames.txt` has no entries, remain in Phase 2.5 and ask human to populate it
- `symbol-frames.txt` existing (even with entries) must never be treated as implicit approval
- Remain in Phase 2.5 until explicit human approval of `symbol-frames.txt` is recorded in MEMORY.md

---

## Phase 3: Symbol Asset Generation

### Objective
Generate symbol texture assets that closely match the original Las Vegas slot machine — colorful, vibrant, same look and feel.

### Inputs
- Frames: `$YT_BASE_DIR/CLEOPATRA/frames/`
- Tags: `$YT_BASE_DIR/CLEOPATRA/tags.txt`
- Analysis: `$YT_BASE_DIR/CLEOPATRA/analysis.md`
- Approved frame list: `$YT_BASE_DIR/CLEOPATRA/symbol-frames.txt`

### Actions
- Before generating, check for existing files matching `$YT_BASE_DIR/CLEOPATRA/output/symbols/symbol_*.png`
- If existing symbols are found, ask human whether to `reuse` existing files or `regenerate` for this run; record decision in MEMORY.md
- Do not report existing symbols as newly generated unless regeneration happened in the current run
- Use Phase 1 frames and Phase 2 analysis as the source of truth for symbol appearance
- Use only approved frames listed in `symbol-frames.txt` as visual references
- Identify which symbols appear in human-approved frames using Phase 2 analysis context (the file itself contains frame names only)
- For each symbol, scan all candidate frames in relevant tagged ranges and score frame quality (blur, occlusion, crop, symbol centering, lighting).
- Select the cleanest non-blurred frame(s) per symbol as canonical references before texture generation.
- Run CV-first boundary extraction (`/workspaces/clawd-slots-assets-pipeline/scripts/extract_symbol_boundaries.py`) on approved frames to get precise symbol crops before generation.
- Prefer YOLO object detection + ByteTrack (`/workspaces/clawd-slots-assets-pipeline/scripts/extract_symbols_yolo_track.py`) to detect and track candidate symbol objects across approved frames.
- Optionally run LLM critic selection on tracked candidates (`--llm-review`) so Kimi picks the best extraction before final symbol export.
- Generate a texture per symbol that closely matches the original in color, shape, lighting, and material
- The goal is colorful, vibrant assets that match the Las Vegas slot machine feel
- Enforce symbol quality gates before presenting to the user:
  - Full symbol only (no cropped/partial/truncated symbol content)
  - One symbol per file (no neighboring symbols, UI fragments, or reel strips)
  - Clean image composition suitable for direct in-game use
- Each asset filename must include the symbol name from the analysis
- Present all generated symbols to the user for review
- Include a compact preview set (up to 8 symbols) as 100x100 thumbnails with full-size links when available in UI
- If the user rejects all or specific symbols (including "partial/cropped"), regenerate only the rejected ones and re-present

### Output
- Symbol textures: `$YT_BASE_DIR/CLEOPATRA/output/symbols/`
