# autonomous-9-step-loop.md

This document replaces the old 9-step loop with the **2-phase workflow**.

## Phase 1: Selection

**Goal**: Find and select one high-quality YouTube video of a specific slot machine.

### Steps

1. **Search**
	- Use Brave Search with fallback to Tavily.
	- Default target when no slot name is provided: **popular, 4K Cleopatra-themed Las Vegas slots uploaded within the last 24 months**.
	- Use YouTube-focused queries (4K) to prioritize high-res videos.
	- Target: clear reel visibility, multiple spins, real casino footage, 4K resolution, last 24 months.
	- Enforce recency by discarding any result older than 24 months based on published date metadata.
	- Date filters apply **only** to YouTube video searches.

2. **Evaluate**
	- Score each candidate for clarity, duration, and variety of gameplay.
	- Capture timeline timestamps, spins observed, and whether a bonus appears.
	- Keep the top 5.

3. **Present Top 5**
	- Send a Telegram message listing the top 5.
	- Ask for selection (1-5) or "redo".

4. **Handle Response**
	- If user picks a number: proceed to Phase 2.
	- If user says "redo": run a new search and repeat Phase 1.

### Output

- Selected video URL and metadata saved to MEMORY.md.

---

## Phase 2: Video Analysis

**Goal**: Analyze the selected video and produce a complete math model spreadsheet.

### Steps

1. **Metadata & Transcript**
	- Extract title, channel, duration, and description.
	- Fetch transcript/captions if available.

2. **Frame Capture**
	- Capture key timestamps for reels, wins, bonuses, paytables.
	- Use browser screenshots or ffmpeg for frame extraction.
	- **Batch analysis**: Send frames to the model in small sets (max 6-8) and summarize each batch.

3. **Vision Analysis**
	- Analyze frames with Kimi K-2.5 (fallbacks: Grok, GPT-4o).
	- Extract symbols, reels, paylines, bonus mechanics, UI details.

4. **Supplementary Research**
	- Search for RTP, volatility, paytable details.
	- Validate any inferred values.

5. **Spreadsheet Generation**
	- Create the math model spreadsheet with 7 sheets:
	  - game_overview
	  - symbol_inventory
	  - paytable
	  - math_model
	  - bonus_features
	  - visual_analysis
	  - analysis_log

6. **Delivery**
	- Send summary + spreadsheet to Ron via Telegram.
	- Update MEMORY.md to mark phase complete.

### Output

- `[slot_name]_math_model.xlsx` with 7 sheets.
- Summary message sent via Telegram.

---

## Rules

- Only these two phases are allowed.
- Always checkpoint progress in MEMORY.md.
- Use fallbacks for search and AI vision failures.
