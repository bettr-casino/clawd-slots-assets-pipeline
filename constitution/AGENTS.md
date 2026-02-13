# AGENTS.md

## Agent Capabilities

### AI Model Integration

- **LLM**: Kimi K-2.5 (moonshot/kimi-k2.5) — Moonshot only, no fallback providers
- **Capabilities**: Native multimodal (vision + text), 256K context, agent tasks, tool calling
- **Purpose**: Frame analysis, paytable/math reverse-engineering, and symbol asset generation
- **Env**: `MOONSHOT_API_KEY`

### Three-Phase Workflow

Clawd operates in a three-phase workflow:

**Phase 1: Frame Extraction**
1. **Read tags.txt**: The human authors `$YT_BASE_DIR/CLEOPATRA/tags.txt` with timestamps and descriptions — do not ask the human for timestamps; read the file
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
9. Do not create assets or implement the game in this phase

**Phase 3: Symbol Asset Generation**
1. Use frames, tags.txt, and analysis.md to generate symbol textures
2. Ensure textures closely match the original symbols (color, shape, lighting, material)
3. Save textures to `$YT_BASE_DIR/CLEOPATRA/output/symbols/` with filenames that include the symbol name
4. Present all assets to the user for review
5. If the user rejects all or specific symbols, regenerate only rejected assets and re-present

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
- Phase 1: Notify when frame extraction is complete
- Phase 2: Request approval before starting analysis
- Blocker notifications and clarification questions

## Agent Responsibilities

### Workflow Execution
1. Check MEMORY.md for current phase and step by reading `/workspaces/clawd-slots-assets-pipeline/constitution/MEMORY.md` directly; do not use the memory plugin or embeddings for state
2. Execute next step in the three-phase workflow
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

### Billing & Model Status
- Check if Moonshot API key is present (MOONSHOT_API_KEY)
- Report Kimi K-2.5 auth status (single provider, no fallbacks)
- Verify Moonshot balance if possible
- Report status clearly and professionally
