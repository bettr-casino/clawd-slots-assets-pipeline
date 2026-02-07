# GOAL.md

## Primary Goal

Reverse-engineer Las Vegas slot machines from YouTube videos through a 2-phase workflow. Phase 1 selects the target video through an iterative search-and-select loop with human approval. Phase 2 analyzes the selected video to produce a comprehensive Excel spreadsheet containing the math model of the slot machine.

**Key Rules:**
- Use Excel (pandas + openpyxl) with CSV fallback if needed
- Use chain-of-thought reasoning for all decisions
- Send Telegram progress updates at each decision point
- Save checkpoint data in MEMORY.md (phase, status, decisions)
- Use Brave for web search with Tavily as fallback

## Phase 1: Selection

### Objective
Find and select a single high-quality YouTube video of a Las Vegas slot machine from a real casino.

### Step 1.1: Web Search

**Actions:**
- If the human does not provide a slot name, default to **popular Cleopatra-themed Las Vegas slots** and discover **4K** videos uploaded within the **last 24 months** on YouTube.
- Attempt web_search with Brave using `BRAVE_API_KEY`
- If Brave fails (429, 401, timeout, invalid key, or any error), retry with Tavily using `TAVILY_API_KEY`
- If both fail, send Telegram: "Both Brave and Tavily search tools failed. Brave error: [error message]. Tavily error: [error message]. Please configure a working search API key or provide manual input."
- Enforce the **last 24 months** rule by filtering results using published date metadata when available. Discard any video older than 24 months.
- Search terms include:
  - "Cleopatra slot machine gameplay 4K site:youtube.com after:2024-02-06"
  - "IGT Cleopatra slot Las Vegas gameplay"
  - "Cleopatra Grand slot machine gameplay 4K after:2024-02-06"
  - "Cleopatra II slot gameplay 4K after:2024-02-06"
  - If a slot name is provided, use it in the same pattern.
- Date filters apply **only** to YouTube video searches, not to other web research sources.
- Evaluate video quality criteria:
  - Clear reel visibility
  - Multiple spin sequences
  - Bonus feature demonstrations
  - High resolution (4K required)
  - Upload date within the last 24 months
  - Complete game rounds
  - Real casino footage (not mobile apps)

**Output:**
- 5 candidate video URLs with quality notes

### Step 1.2: Present Top 5 to Human

**Actions:**
- Send Telegram message to Ron with the top 5 videos:

```
🎰 Video Selection for [SLOT NAME]

Here are the top 5 YouTube videos I found:

1. [Title] - [URL]
   Quality: [brief assessment]
  Timeline: [timestamps of key segments]
  Spins observed: [count]
  Bonus seen: [Yes/No, type if known]

2. [Title] - [URL]
   Quality: [brief assessment]
  Timeline: [timestamps of key segments]
  Spins observed: [count]
  Bonus seen: [Yes/No, type if known]

3. [Title] - [URL]
   Quality: [brief assessment]
  Timeline: [timestamps of key segments]
  Spins observed: [count]
  Bonus seen: [Yes/No, type if known]

4. [Title] - [URL]
   Quality: [brief assessment]
  Timeline: [timestamps of key segments]
  Spins observed: [count]
  Bonus seen: [Yes/No, type if known]

5. [Title] - [URL]
   Quality: [brief assessment]
  Timeline: [timestamps of key segments]
  Spins observed: [count]
  Bonus seen: [Yes/No, type if known]

Reply with a number (1-5) to select, or 'redo' to search again.
```

- Wait for Ron's response

### Step 1.3: Human Decision

**Decision outcomes:**
- **Number (1-5)**: Select that video → proceed to Phase 2
- **"redo"**: Go back to Step 1.1, refine search terms, find new videos
- **Custom input**: Ron may provide a specific URL or refined search terms

**Checkpoint:** Update MEMORY.md with selected video URL and `phase: 1, status: complete`

### Selection Loop

```
[Search] → [Present Top 5] → [Human picks 1-5 or "redo"]
    ↑                                    |
    └────── if "redo" ──────────────────-┘
```

This loop continues until the human selects a video.

---

## Phase 2: Video Analysis

### Objective
Analyze the selected YouTube video comprehensively — extracting game mechanics, symbols, math model, and visual details — and produce an Excel spreadsheet that serves as a complete math model of the slot machine.

### Step 2.1: Video Metadata & Text Analysis

**Actions:**
- Preflight model auth: verify the OpenClaw auth store has profiles for moonshot, xai, and openai. If any are missing and the matching env var exists, register it before analysis (e.g., `openclaw models auth paste-token --provider xai --profile-id xai:default`).
- Use browser automation to navigate to the selected YouTube video
- Extract video metadata:
  - Title, description, channel, upload date, view count
  - Any linked paytable or game information in description
- Extract transcript/captions (if available):
  - Auto-generated captions
  - Manual captions
  - Analyze commentary for game mechanic mentions
- Search for supplementary information:
  - Paytable images or data for the specific slot machine
  - RTP (Return to Player) data from slot review sites
  - Game rules from manufacturer documentation

**Output:**
- Video metadata saved in MEMORY.md
- Transcript text (if available)
- Supplementary game data

### Step 2.2: Video Download & Frame Extraction

**Actions:**
- **Download the video locally before any frame work.** This is mandatory — ffmpeg cannot process a file that does not exist.
  ```bash
  bash scripts/cobalt-download.sh "<YouTube URL>" "<slot_name>.mp4"
  ```
  Or manually:
  ```bash
  curl -s -X POST "https://api.cobalt.tools/" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d '{"url":"<YouTube URL>"}' \
    | jq -r '.url' | xargs curl -L -o "<slot_name>.mp4"
  ```
- **If cobalt fails**, fall back to **browser-based screenshot analysis only**:
  1. Skip the video download entirely
  2. Use browser automation to navigate to the YouTube video and play it
  3. Capture screenshots at key timestamps using the OpenClaw browser's screenshot tool
  4. Analyze the screenshots with vision AI as usual
  5. Note in MEMORY.md: `video_download: failed, mode: browser_screenshots`
  6. This is a valid analysis path — the spreadsheet can still be produced from screenshots alone
- Verify the file exists (`ls -la <slot_name>.mp4`) before proceeding.
- Extract frames at regular intervals for batch analysis:
  ```bash
  mkdir -p frames
  ffmpeg -i "<slot_name>.mp4" -vf "fps=1" frames/frame_%04d.png
  ```
- Additionally capture screenshots at key timestamps:
  - Base game idle state (reels visible)
  - Multiple spin sequences (at least 5 different outcomes)
  - Win states showing paylines lit up
  - Paytable/info screens (if shown in video)
  - Bonus trigger sequences
  - Free spins feature (if shown)
  - Special feature activations
  - UI elements (bet controls, balance, win display)
- **Batch frames** into small sets (max 6-8 frames per request) to avoid context overflow. Summarize each batch before sending the next.
- Use Kimi vision (with xai/grok-2-vision and openai/gpt-4o as fallbacks) to analyze each batch and reverse engineer:
  - **Reel Configuration**: Number of columns × rows
  - **Symbol Inventory**:
    - High-value (premium) symbols: names, descriptions, visual attributes
    - Low-value symbols: names, descriptions, visual attributes
    - Wild symbols: type (standard, expanding, sticky, etc.)
    - Scatter symbols: trigger conditions
    - Bonus symbols: mechanics
  - **Payline Patterns**: Number of paylines, visible patterns
  - **Base Game Mechanics**: How wins are formed, minimum symbols to win
  - **Bonus Features**: Free spins trigger, bonus game mechanics, multipliers
  - **Color Palette**: Dominant colors, background scheme, symbol colors
  - **Animation Patterns**: Spin timing, win celebrations, transitions
  - **UI/UX Layout**: Button positions, display areas, information panels

**Output:**
- Comprehensive analysis document in MEMORY.md
- Screenshot references with timestamps
- Detailed game mechanics breakdown

### Step 2.3: Math Model Spreadsheet Creation

**Actions:**
- Use pandas with openpyxl engine to create Excel `.xlsx` file
- Create the following sheets/tabs:

**Sheet 1: game_overview**
- Slot machine name, manufacturer, theme
- Video URL and analysis date
- Reel configuration (columns × rows)
- Number of paylines
- Bet range (min/max if visible)
- RTP (if found from research)
- Volatility assessment

**Sheet 2: symbol_inventory**
| Column | Description |
|--------|-------------|
| symbol_name | Name of the symbol |
| symbol_type | wild / scatter / premium / low / bonus / special |
| description | Visual description |
| estimated_frequency | Relative frequency on reels (if determinable) |
| color_palette | Primary colors (hex codes if possible) |
| animation_notes | Any observed animations |

**Sheet 3: paytable**
| Column | Description |
|--------|-------------|
| symbol_name | Symbol name |
| match_3 | Payout for 3 matching |
| match_4 | Payout for 4 matching |
| match_5 | Payout for 5 matching |
| notes | Special payout rules |

**Sheet 4: math_model**
- Symbol weights per reel (estimated from observation)
- Payline definitions
- Expected hit frequency per symbol combination
- Estimated RTP calculation
- Variance/volatility analysis

**Sheet 5: bonus_features**
| Column | Description |
|--------|-------------|
| feature_name | Name of bonus feature |
| trigger_condition | How it's triggered (e.g., 3 scatters) |
| mechanics | How the feature plays |
| multipliers | Any multiplier values |
| estimated_frequency | How often it triggers |
| notes | Additional observations |

**Sheet 6: visual_analysis**
| Column | Description |
|--------|-------------|
| element | Visual element name |
| description | Detailed description |
| color_hex | Color codes |
| position | Screen position |
| animation | Animation description |

**Sheet 7: analysis_log**
- Timestamps of analysis steps
- Frame capture timestamps
- Decisions and reasoning
- Data sources used

- File naming: `[slot_name]_math_model.xlsx`
- Storage: project root or designated output directory
- **CSV Fallback**: If openpyxl fails, generate separate CSV files for each sheet and log fallback in MEMORY.md

**Output:**
- Excel spreadsheet path saved in MEMORY.md
- Complete math model of the slot machine

### Step 2.4: Send Analysis Summary to Human

**Actions:**
- Send Telegram message to Ron with analysis summary:

```
📊 Video Analysis Complete for [SLOT NAME]

Video: [YouTube URL]

Key Findings:
- Reel Configuration: [columns × rows]
- Symbols: [count] total ([premium count] premium, [low count] low, [special count] special)
- Paylines: [count]
- Bonus Features: [list]
- Estimated RTP: [value if determined]

Spreadsheet: [filename] saved to repository

Analysis is complete. Let me know if you'd like me to:
- Analyze a different video (restart Phase 1)
- Deep-dive into any specific aspect
```

**Checkpoint:** Update MEMORY.md with `phase: 2, status: complete`

---

## Chain-of-Thought Requirement

**All steps must use chain-of-thought reasoning:**
- Start complex analyses with "Let's think step by step"
- Show observations before conclusions
- Explain decision-making process
- Document reasoning in MEMORY.md
- Make thought process transparent to Ron

## Success Criteria

✅ Phase 1: Human selects a video from top 5 candidates (iterative until satisfied)
✅ Phase 2: Comprehensive Excel spreadsheet with complete math model produced
✅ All analysis uses chain-of-thought reasoning
✅ Telegram updates at each decision point
✅ Checkpoint resilience via MEMORY.md
✅ Brave search with Tavily fallback for web searches
