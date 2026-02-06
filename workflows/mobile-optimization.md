# Analysis QA Checklist (2-Phase Workflow)

This file replaces the old mobile optimization workflow. It now defines **quality checks** for the 2-phase video analysis pipeline.

## Phase 1: Selection QA

- Video resolution is 4K
- Upload date is within the last 24 months
- Any video older than 24 months is rejected
- Date filters apply only to YouTube video searches
- Reels are clearly visible for most spins
- At least one bonus round appears (if available)
- Camera is stable with minimal glare
- Audio commentary is not required but can help

## Phase 2: Analysis QA

### Evidence Quality

- Key reels and symbols captured in screenshots
- Bonus trigger and payout screens captured
- Paytable or rules page captured if shown
- Each inferred value linked to a frame or transcript line

### Spreadsheet Completeness

- All 7 sheets included
- Required fields filled:
  - game_overview: name, provider, reels, paylines
  - symbol_inventory: symbol list and type
  - paytable: values and evidence notes
  - math_model: probabilities or assumptions
  - bonus_features: triggers and behavior
  - visual_analysis: color palette and UI notes
  - analysis_log: timestamps, decisions, sources

### Confidence Labels

- Any inferred values marked as "estimated"
- Unknown values explicitly marked "unknown"
- Evidence notes recorded for each estimate

## Delivery QA

- Telegram summary is concise and accurate
- Spreadsheet filename uses `[slot_name]_math_model.xlsx`
- MEMORY.md updated with final status
