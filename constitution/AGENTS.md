# AGENTS.md

## Agent Capabilities

### AI Model Integration

- **Primary LLM**: Kimi K-2.5 (moonshot/kimi-k2.5)
- **Fallback #1**: Grok 2 Vision (xai/grok-2-vision) — activates if Kimi is unavailable
- **Fallback #2**: GPT-4o (openai/gpt-4o) — activates if both Kimi and Grok are unavailable
- **Fallback chain**: kimi-k2.5 → grok-2-vision → gpt-4o
- **Purpose**: Video search, selection, analysis, and math model extraction

### Single-Phase Workflow

Clawd operates in a single-phase workflow:

**Phase 1: Video Intake + Frame Extraction**
1. **Verify Video**: Check for a local video file under `yt/<file-name>/video/`
2. **Ask for Name**: If missing, ask the human for the filename (default: `CLEOPATRA.webm`)
3. **Download**: Pull from `s3://bettr-casino-assets/yt/<file-name>` into `yt/<file-name>/video/<file-name>`
4. **Ask for Timestamps**: Confirm whether frames are needed and collect a list (e.g., `00:14:00 00:21:35`)
5. **Extract Frames**: Use `scripts/extract-frame.sh` to extract one frame per timestamp into `yt/<file-name>/frames/`

### Frame Extraction Tools

- **ffmpeg**: Extract frames at precise timestamps
- **extract-frame.sh**: Wrapper script for consistent frame extraction

### Spreadsheet Creation

- **pandas + openpyxl**: Create Excel .xlsx with multiple sheets
- **CSV Fallback**: If openpyxl fails, generate separate CSV files
- **Sheets**: game_overview, symbol_inventory, paytable, math_model, bonus_features, visual_analysis, analysis_log

## Agent Communication Protocol

**Telegram (Primary Channel):**
- 30-minute heartbeat progress updates to Ron
- Phase 1: Ask for filename (if missing) and timestamps
- Blocker notifications and clarification questions

## Agent Responsibilities

### Workflow Execution
1. Check MEMORY.md for current phase and step
2. Execute next step in the single-phase workflow
3. Save checkpoints after each step completion
4. Update MEMORY.md with progress and state
5. Send Telegram updates every 30 minutes
6. Use chain-of-thought reasoning for all decisions
7. If a provider reports a missing API key but the env var exists, re-register the key in the OpenClaw auth store (xai/openai) before retrying

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
- Model status: Kimi K-2.5 + fallbacks (Grok Vision Beta, GPT-4o)
- Any blockers or waiting states

### Billing & Model Status
- Check if Moonshot API key is present (MOONSHOT_API_KEY)
- Check if xAI API key is present (XAI_API_KEY) for Grok fallback
- Check if OpenAI API key is present (OPENAI_API_KEY) for GPT-4o fallback
- Report all three models and their auth status
- Fallback chain: kimi-k2.5 → grok-2-vision → gpt-4o
- Verify balance if possible
- Report status clearly and professionally
