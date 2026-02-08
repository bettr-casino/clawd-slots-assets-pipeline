# AGENTS.md

## Agent Capabilities

### AI Model Integration

- **Primary LLM**: Kimi K-2.5 (moonshot/kimi-k2.5)
- **Fallback #1**: Grok 2 Vision (xai/grok-2-vision) — activates if Kimi is unavailable
- **Fallback #2**: GPT-4o (openai/gpt-4o) — activates if both Kimi and Grok are unavailable
- **Fallback chain**: kimi-k2.5 → grok-2-vision → gpt-4o
- **Purpose**: Video search, selection, analysis, and math model extraction

### Two-Phase Workflow

Clawd operates in a two-phase workflow:

**Phase 1: Video Intake + Frame Extraction**
1. **Ask for Name**: If missing, ask the human for the base filename (default: `CLEOPATRA`); if `.webm` is provided, strip it
2. **Confirm YouTube URL**: Default to `https://www.youtube.com/watch?v=Ks8o3bl7OYQ`, ask for updates if not confirmed
3. **Ask for Timestamps**: Confirm whether frames are needed and collect a list (e.g., `00:14:00 00:21:35`)
4. **Extract Frames**: Use `/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh` to extract one frame per timestamp into `yt/<file-name>/frames/`
	- The script downloads `https://bettr-casino-assets.s3.us-west-2.amazonaws.com/yt/<file-name>.webm` if the video is missing

**Phase 2: Multimodal LLM Analysis**
1. Confirm video and tags are ready
2. Ask the human for approval once per Phase 2 run; record approval in MEMORY.md before executing any command and do not re-ask on retries
3. Use a multimodal LLM (e.g., Kimi K2.5) to analyze frames and tags.txt for the video
4. You may create and run a helper script if it materially improves the analysis; bot-generated scripts must live under `/workspaces/clawd-slots-assets-pipeline/scripts/`
5. Do not block Phase 2 on a missing script; create it if needed or fall back to direct multimodal analysis
6. Identify slot symbols, reel layout, and symbol landing animations
7. When loading frames, use absolute paths under `$YT_BASE_DIR` (do not rely on repo-relative paths)
8. Write results to `$YT_BASE_DIR/<video-name>/analysis.md`
9. Do not create assets or implement the game in this phase

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
- Phase 1: Ask for filename (if missing) and timestamps
- Blocker notifications and clarification questions

## Agent Responsibilities

### Workflow Execution
1. Check MEMORY.md for current phase and step by reading `/workspaces/clawd-slots-assets-pipeline/constitution/MEMORY.md` directly; do not use the memory plugin or embeddings for state
2. Execute next step in the single-phase workflow
3. Always use absolute paths for file access and tool calls
4. Save checkpoints after each step completion
5. Update MEMORY.md with progress and state
6. Send Telegram updates every 30 minutes
7. Use chain-of-thought reasoning for all decisions
8. If a provider reports a missing API key but the env var exists, re-register the key in the OpenClaw auth store (xai/openai) before retrying

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
