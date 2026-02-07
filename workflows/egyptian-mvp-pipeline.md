# Egyptian MVP Pipeline (2-Phase Workflow)

This workflow is for **Egyptian-themed slot machines** (Cleopatra, Luxor, etc.) using the standard 2-phase process.

## Phase 1: Selection

**Goal**: Choose the best video for analysis.

### Search Targets

- "Egyptian slot machine gameplay 4K after:2024-02-06"
- "Cleopatra slot Las Vegas gameplay 4K after:2024-02-06"
- "Anubis slot bonus"
- "Luxor slot big win"

### Selection Criteria

- Clear reels and symbols
- Multiple spins with bonus footage
- Paytable or rules visible if possible
- Real casino footage preferred
- Upload date within the last 24 months (discard older videos)
- Date filters apply **only** to YouTube video searches.

### Output

- Top 5 videos sent to Ron
- Selected video saved to MEMORY.md

---

## Phase 2: Video Analysis

**Goal**: Build a complete math model spreadsheet for the selected game.

### Video Download (MUST happen first)

1. Download the selected video: `bash scripts/cobalt-download.sh "<YouTube URL>" "<slot_name>.mp4"`
2. Verify the file exists before proceeding
3. Extract frames: `mkdir -p frames && ffmpeg -i "<slot_name>.mp4" -vf "fps=1" frames/frame_%04d.png`

### Analysis Checklist

- Game name and manufacturer
- Reel configuration and paylines
- Symbol inventory (wild, scatter, premium, low)
- Bonus features and triggers
- Paytable values from video
- RTP/volatility if visible or found in research

### Spreadsheet Output

- `[slot_name]_math_model.xlsx`
- 7 sheets: game_overview, symbol_inventory, paytable, math_model, bonus_features, visual_analysis, analysis_log

### Delivery

- Send summary + spreadsheet via Telegram
- Update MEMORY.md and mark phase complete

---

## Notes

- If multiple Egyptian variants appear, specify the exact game version.
- Any inferred values must be labeled "estimated" with evidence notes.
