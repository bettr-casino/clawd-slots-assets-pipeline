# AGENTS.md

## Agent Capabilities

### AI Model Integration

- **LLM**: Kimi K-2.5 (moonshot/kimi-k2.5) — Moonshot only, no fallback providers
- **Capabilities**: Native multimodal (vision + text), 256K context, agent tasks, tool calling
- **Purpose**: Frame analysis, paytable/math reverse-engineering, and symbol asset generation
- **Env**: `MOONSHOT_API_KEY`

### Four-Phase Workflow

Clawd operates in a four-phase workflow (Phase 0 through Phase 3):

**Phase 0: Human Preparation (Wait for Approval)**
- The human reviews the video and authors `tags.txt` with timestamps and descriptions
- The bot does **nothing** until the human sends `start` on Telegram
- On `status`: reply "Phase 0 — Waiting for you to approve tags.txt. Send `start` when ready."
- On `start`: transition to Phase 1
- Never infer approval from existing files (`tags.txt`, downloaded video, or extracted frames)

**Phase 1: Frame Extraction**
1. **Read tags.txt**: Read `$YT_BASE_DIR/CLEOPATRA/tags.txt` — the human has already approved it
2. **Extract Frames**: Use `/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh` for each tags.txt entry
   - Single frame entries (start == end): one PNG
   - Animation range entries (start < end): all frames at 60fps
   - The script auto-downloads `https://bettr-casino-assets.s3.us-west-2.amazonaws.com/yt/CLEOPATRA.webm` if the video is missing

**Phase 2: Multimodal LLM Analysis**
1. Ask the human for approval once via Telegram; record approval in MEMORY.md; do not re-ask on retries
2. Use Kimi K2.5 to analyze frames guided by tags.txt descriptions
3. Reverse-engineer: symbol inventory, reel layout, paytable (public info), math model, bonus features, animations, visual style
4. Use animation-range frames to document spin/landing/win animations
5. Helper scripts allowed under `/workspaces/clawd-slots-assets-pipeline/scripts/`
6. Use absolute paths under `$YT_BASE_DIR`
7. Write results to `$YT_BASE_DIR/CLEOPATRA/analysis.md`
8. Write math model spreadsheets/CSVs to `$YT_BASE_DIR/CLEOPATRA/output/`
9. If `$YT_BASE_DIR/CLEOPATRA/symbol-frames.txt` is missing, stop and ask the human to create it in the repository
10. Do not create assets or implement the game in this phase
11. If human sends `skip`, bypass analysis and transition to Phase 2.5 approval gate
12. Never present `skip` as "Skip to Phase 3" while in Phase 2

**Phase 2.5: Human Approval Gate (symbol-frames.txt)**
1. Present `symbol-frames.txt` to human for approval
2. Wait for explicit approval before Phase 3
3. Human must author entries in `symbol-frames.txt`; bot must use approved version as-is
4. If `symbol-frames.txt` is empty, remain blocked in Phase 2.5 and request entries
5. Bot must never create or edit `symbol-frames.txt`
6. `symbol-frames.txt` existence does not imply approval; only explicit human approval recorded in MEMORY.md unlocks Phase 3

**Phase 3: Symbol Asset Generation**
1. Before generation, check `$YT_BASE_DIR/CLEOPATRA/output/symbols/` for existing `symbol_*.png`
2. If existing symbols are found, ask human whether to `reuse` or `regenerate`; record decision in MEMORY.md
3. Do not treat existing symbol files as new generation output for current run without explicit `regenerate` decision
4. Use approved `symbol-frames.txt`, frames, and analysis.md to generate symbol textures
5. Ensure textures closely match the original symbols (color, shape, lighting, material)
6. Use Phase 2 analysis to identify which symbols appear in approved frame list (file contains frames only)
7. For each symbol, analyze approved frames and select the cleanest non-blurred reference frame(s).
8. Use `/workspaces/clawd-slots-assets-pipeline/scripts/extract_symbols_yolo_track.py` as the default extraction path (YOLO detection + ByteTrack + optional LLM critic).
9. If YOLO/tracking extraction fails or produces low-quality crops, pause and ask for human decision; do not auto-fallback.
10. Apply quality gate before presenting any symbol:
   - Reject cropped/partial symbols
   - Reject images containing multiple symbols or unrelated UI/reel fragments
   - Regenerate until each file is a clean, full single-symbol texture
11. Save textures to `$YT_BASE_DIR/CLEOPATRA/output/symbols/` with filenames that include the symbol name
12. Present all assets to the user for review
13. Include a compact preview set (up to 8 symbols) as 100x100 thumbnails with full-size links
14. If the user rejects all or specific symbols, regenerate only rejected assets and re-present

### Frame Extraction Tools

- **ffmpeg**: Extract frames at precise timestamps
- **extract-frame.sh**: Wrapper script for consistent frame extraction (use `/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh`)

### Spreadsheet Creation

- **pandas + openpyxl**: Create Excel .xlsx with multiple sheets
- **CSV Fallback**: If openpyxl fails, generate separate CSV files
- **Sheets**: game_overview, symbol_inventory, paytable, math_model, bonus_features, visual_analysis, analysis_log

## Agent Communication Protocol

**Telegram (Primary Channel):**
- 30-minute heartbeat progress updates to Ron
- Phase 0: Wait for `start` (tags.txt approval)
- Phase 1: Notify when frame extraction is complete
- Phase 2: Request approval before starting analysis
- Blocker notifications and clarification questions

## Agent Responsibilities

### Workflow Execution
1. Check MEMORY.md for current phase and step by reading `/workspaces/clawd-slots-assets-pipeline/constitution/MEMORY.md` directly; do not use the memory plugin or embeddings for state
2. Execute next step in the four-phase workflow (Phase 0–3)
3. Always use absolute paths for file access and tool calls
4. Save checkpoints after each step completion
5. Update MEMORY.md with progress and state
6. Send Telegram updates every 30 minutes
7. Use chain-of-thought reasoning for all decisions
8. If Moonshot reports a missing API key but MOONSHOT_API_KEY env var exists, re-register the key in the OpenClaw auth store before retrying

### Chain-of-Thought Reasoning

**Always use detailed step-by-step reasoning:**
- Start complex steps with "Let's think step by step"
- Show observations before conclusions
- Explain reasoning at each decision point
- Build toward insights systematically
- Make thought process transparent

## Status Reply Protocol

When user sends "status", provide comprehensive overview:

### Status Structure
- Current phase (single phase)
- Current step within the phase
- Last completed checkpoint
- Progress summary
- Next planned action
- Model status: Kimi K-2.5 (Moonshot only)
- Any blockers or waiting states

### Phase 2 Reply Text Rule
- When Phase 2 is waiting for approval, allowed reply options are:
  - `approve` — Start Phase 2 analysis
  - `skip` — Skip analysis to Phase 2.5 (`symbol-frames.txt` approval gate)
  - `status` — Show current status
- Never output `skip — Skip to Phase 3` from Phase 2 status or approval prompts.

### Phase Handoff Status Rule
- When Phase **N** is marked **Complete**, status must also include a short section for Phase **N+1**.
- The Phase **N+1** section must include:
  - `Readiness` (Ready / Waiting / Blocked)
  - `Required approval` (if any)
  - `Next action` (single concrete action)
- Do not skip Phase **N+1** visibility even if no work has started yet.

Example:
- `Phase 1: Complete`
- `Phase 2: Ready (Approval pending) -> Next action: Ask for analysis approval`

### Required Status Layout (Detailed Phase Cards)
When responding to `status`, always use this layout:

1) `Status Report` table (Phase 0..3 high-level state)
2) Full detail card for **current phase**
3) Full detail card for **next phase**

If current phase is complete and next phase is Phase 2, include this exact section title:
- `Phase 2: Analysis`

`Phase 2: Analysis` detail card must include:
- Objective (what Phase 2 does)
- Readiness (Ready / Waiting / Blocked)
- Approval gate (required + current state)
- Inputs (frames path, tags path)
- Planned outputs (analysis.md, spreadsheets/CSVs)
- Next action (single concrete step)

### Billing & Model Status
- Check if Moonshot API key is present (MOONSHOT_API_KEY)
- Report Kimi K-2.5 auth status (single provider, no fallbacks)
- Verify Moonshot balance if possible
- Report status clearly and professionally
