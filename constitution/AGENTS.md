# AGENTS.md

## Agent Capabilities

### AI Model Integration

- **Primary LLM**: Kimi K-2.5 (moonshot/kimi-k2.5)
- **Fallback #1**: Grok Vision Beta (xai/grok-vision-beta) — activates if Kimi is unavailable
- **Fallback #2**: GPT-4o (openai/gpt-4o) — activates if both Kimi and Grok are unavailable
- **Fallback chain**: kimi-k2.5 → grok-vision-beta → gpt-4o
- **Purpose**: Video search, selection, analysis, and math model extraction

### 2-Phase Workflow

Clawd operates in a 2-phase workflow:

**Phase 1: Selection** (iterative loop)
1. **Web Search**: Find 5 high-quality YouTube videos of Las Vegas slot machines from real casinos using Brave first with Tavily fallback; send Telegram if both fail
2. **Present to Human**: Send top 5 videos to Ron via Telegram with quality assessments
3. **Human Decision**: Ron picks a video (1-5) or says "redo" to search again
4. Loop continues until Ron selects a video

**Phase 2: Video Analysis**
1. **Metadata & Text Analysis**: Extract video metadata, transcript/captions, and supplementary game data from review sites
2. **Frame Analysis**: Capture screenshots and use AI vision to reverse engineer reel configuration, symbols (wilds/scatters/premiums/lows), mechanics, bonuses, paylines, visual style
3. **Math Model Spreadsheet**: Create Excel spreadsheet (pandas + openpyxl) with game overview, symbol inventory, paytable, math model, bonus features, visual analysis, and analysis log
4. **Summary to Human**: Send analysis summary to Ron via Telegram

### Video Analysis Tools

- **Browser Automation**: Navigate to YouTube, play videos, capture frames
- **Screenshot Capture**: Extract frames at specific timestamps
- **AI Vision** (Kimi K-2.5 with Grok/GPT-4o fallbacks): Analyze frames to identify:
  - Reel configurations (columns × rows)
  - Symbol designs, types, and counts
  - Color schemes and visual style
  - Animation patterns and timing
  - UI/UX elements
  - Bonus features and mechanics
  - Payline patterns

### Spreadsheet Creation

- **pandas + openpyxl**: Create Excel .xlsx with multiple sheets
- **CSV Fallback**: If openpyxl fails, generate separate CSV files
- **Sheets**: game_overview, symbol_inventory, paytable, math_model, bonus_features, visual_analysis, analysis_log

## Agent Communication Protocol

**Telegram (Primary Channel):**
- 30-minute heartbeat progress updates to Ron
- Phase 1: Present top 5 video candidates and wait for selection
- Phase 2: Send analysis summary when complete
- Blocker notifications and clarification questions

## Agent Responsibilities

### Workflow Execution
1. Check MEMORY.md for current phase and step
2. Execute next step in the 2-phase workflow
3. Save checkpoints after each step completion
4. Update MEMORY.md with progress and state
5. Send Telegram updates every 30 minutes
6. Use chain-of-thought reasoning for all decisions
7. Use Excel (pandas + openpyxl) or CSV fallback for spreadsheets

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
- Current phase (1: Selection or 2: Video Analysis)
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
- Fallback chain: kimi-k2.5 → grok-vision-beta → gpt-4o
- Verify balance if possible
- Report status clearly and professionally
