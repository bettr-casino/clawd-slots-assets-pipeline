# MEMORY.md — Checkpoint & State Persistence

## Purpose

Track progress across the 2-phase workflow. Update this file after every significant step to enable resumption after interruptions.

## Current State

```yaml
phase: idle          # idle | phase_1_selection | phase_2_analysis | complete
step: none           # Current step within the phase
status: waiting      # waiting | running | blocked | complete
last_updated: null
```

## Phase 1: Selection State

```yaml
search_query: null           # Last search query used
search_engine: null           # brave | tavily
search_results_count: 0       # Number of results found
top_5_videos: []              # Array of {title, url, quality_score, notes}
presented_to_user: false      # Whether top 5 has been sent via Telegram
user_selection: null          # Selected video URL, or "redo"
redo_count: 0                 # Number of times user requested redo
```

## Phase 2: Analysis State

```yaml
selected_video:
  title: null
  url: null
  channel: null
  duration: null

analysis_progress:
  metadata_extracted: false
  transcript_extracted: false
  frames_captured: 0
  frames_analyzed: 0
  supplementary_research_done: false

game_data:
  game_name: null
  manufacturer: null
  reel_config: null           # e.g., "5x3"
  paylines: null
  rtp: null
  volatility: null
  symbols_found: []
  bonus_features: []

spreadsheet:
  file_path: null
  sheets_completed: []        # e.g., ["game_overview", "symbol_inventory"]
  all_sheets:
    - game_overview
    - symbol_inventory
    - paytable
    - math_model
    - bonus_features
    - visual_analysis
    - analysis_log

summary_sent: false           # Whether final summary was sent to Ron
```

## Error Log

```yaml
errors: []
# Each entry: {timestamp, phase, step, error_message, fallback_used, resolved}
```

## Checkpoint Instructions

### When to checkpoint
- After completing any step in either phase
- After user interaction (selection received, redo requested)
- After any error and fallback
- Before and after long operations (video download, full analysis)

### How to checkpoint
1. Update the relevant section above with current values
2. Set `last_updated` to current timestamp
3. Set `phase` and `step` to current position
4. If error occurred, append to error log

### How to resume
1. Read this file on startup
2. Check `phase` and `step` for current position
3. Skip completed steps (check boolean flags)
4. Resume from the earliest incomplete step
