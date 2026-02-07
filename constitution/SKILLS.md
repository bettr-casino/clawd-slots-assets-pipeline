# SKILLS.md

## Phase 1: Selection Skills

### web_search (Brave primary, Tavily fallback)

- **Purpose**: Find **popular, 4K, recent (last 24 months)** YouTube videos of Las Vegas slot machines
- **Primary**: Brave Search API with `BRAVE_API_KEY`
- **Fallback**: Tavily Search API with `TAVILY_API_KEY`
- **Configuration**: `BRAVE_API_KEY` for primary search, `TAVILY_API_KEY` for fallback

### Web Search with Fallback

- **Primary**: Always try Brave first
- **Fallback**: On any Brave error (429, 401, timeout, invalid key, or other failures), retry immediately with Tavily using `TAVILY_API_KEY`
- **Both fail**: Send Telegram message: "Both Brave and Tavily search tools failed. Brave error: [error]. Tavily error: [error]. Please configure a working search API key or provide manual input."
- **Never skip fallback**: If Brave returns any error, always try Tavily before reporting failure

### video_evaluation

- **Purpose**: Assess YouTube video quality for slot machine analysis
- **Criteria**: Clear reel visibility, multiple spins, bonus features, real casino footage, 4K resolution, upload date within last 24 months
- **Enforcement**: Filter out any video older than 24 months using published date metadata
- **Scope**: Date filters apply only to YouTube video searches
- **Output**: Quality score, timeline timestamps, spins observed, and bonus occurrence for top 5 candidates

### telegram_messaging

- **Purpose**: Communicate with Ron via Telegram
- **Phase 1 Usage**: Present top 5 videos, receive selection or "redo" command
- **Configuration**: `TELEGRAM_API_KEY` for bot token

---

## Phase 2: Video Analysis Skills

### browser_automation

- **Purpose**: Navigate to YouTube videos and interact with web pages
- **Capabilities**:
  - Navigate to URLs
  - Play/pause video playback
  - Scroll to specific sections
  - Extract page content and metadata
  - Access video transcript/captions

### screenshot_capture

- **Purpose**: Capture video frames at specific timestamps
- **Capabilities**:
  - Capture at precise timestamps
  - Multiple frame captures in sequence
  - Full-page and element-specific captures
- **Usage**: Capture reel states, win screens, bonus features, paytable screens

### kimi_vision (AI Vision Analysis)

- **Purpose**: Analyze video frames with AI
- **Capabilities**:
  - Identify visual elements (symbols, reels, UI)
  - Extract color palettes (hex codes)
  - Recognize patterns and configurations
  - Describe animations and effects
  - OCR for text elements (paytable values, bet amounts)
  - Reverse engineer: reel size, symbol types (wilds/scatters/premiums/lows), base mechanics, bonuses, paylines
- **Model**: Kimi K-2.5 with vision capabilities
- **Fallbacks**: xai/grok-2-vision, openai/gpt-4o
- **Usage**: Analyze screenshots in batches (max 6-8 frames per request) and summarize each batch before continuing

### transcript_extraction

- **Purpose**: Extract and analyze video captions/transcripts
- **Capabilities**:
  - Access auto-generated captions
  - Parse manual captions
  - Extract game mechanic mentions from commentary
- **Usage**: Supplement visual analysis with spoken information

### supplementary_research

- **Purpose**: Find additional game data from external sources
- **Capabilities**:
  - Search slot review sites for RTP data
  - Find manufacturer paytable information
  - Locate game rules documentation
- **Tools**: Brave/Tavily web search

### pandas_openpyxl (Excel Spreadsheet Creation)

- **Purpose**: Create comprehensive math model spreadsheet
- **Capabilities**:
  - Create multi-sheet Excel .xlsx files
  - Format cells with headers and data types
  - Add formulas for calculations
  - Create structured data tables
- **Sheets**: game_overview, symbol_inventory, paytable, math_model, bonus_features, visual_analysis, analysis_log
- **Library**: pandas with openpyxl engine
- **Usage**: Generate complete slot machine math model

### csv_export (CSV Fallback)

- **Purpose**: Fallback when openpyxl is unavailable
- **Capabilities**:
  - Generate separate CSV files per sheet
  - Maintain same data structure as Excel version
  - Compatible with any spreadsheet application
- **Fallback rule**: If openpyxl installation/import fails, use CSV and log in MEMORY.md

### exec (Command Execution)

- **Purpose**: Download videos and extract frames
- **CRITICAL SEQUENCE**: Always attempt download BEFORE extracting frames
  1. `bash scripts/cobalt-download.sh "<url>" "<name>.mp4"` — download via cobalt.tools (no auth needed)
  2. **If cobalt fails**: switch to browser-screenshot mode
     - Use browser automation to play the video on YouTube
     - Capture frames via screenshots at key moments
     - Skip ffmpeg entirely — analysis proceeds from screenshots
     - Log `video_download: failed, mode: browser_screenshots` in MEMORY.md
  3. If download succeeded: verify file exists (`ls -la <name>.mp4`)
  4. Extract frames: `ffmpeg -i "<name>.mp4" -vf "fps=1" frames/frame_%04d.png`
- **Never run ffmpeg on a file that hasn't been downloaded yet**
- **Tools**: cobalt.tools (download), ffmpeg (frame extraction)

---

## Cross-Cutting Skills

### chain_of_thought

- **Purpose**: Transparent reasoning for all decisions
- **Usage**: Start complex analyses with "Let's think step by step"
- **Requirements**:
  - Show observations before conclusions
  - Explain reasoning at each step
  - Document in MEMORY.md

### checkpoint_management

- **Purpose**: Save and restore progress state
- **Usage**: After each step completion, update MEMORY.md
- **Data**: Phase, step, status, timestamps, key outputs
- **Resilience**: If process restarts, resume from last checkpoint

### error_handling

- **Purpose**: Handle failures gracefully
- **Strategy**:
  - Log errors in MEMORY.md
  - Try fallback approaches (Brave→Tavily, Excel→CSV, Kimi→Grok→GPT-4o)
  - If a provider reports a missing API key but the env var exists, re-register the key in the OpenClaw auth store and retry
  - Send Telegram notification for unrecoverable issues
  - Never silently fail

### file_management

- **Purpose**: Organize output files
- **Excel files**: `[slot_name]_math_model.xlsx`
- **Screenshots**: Organized by timestamp
- **Logs**: Analysis progress in MEMORY.md

---

## API Keys Required

| Key | Service | Purpose |
|-----|---------|---------|
| `BRAVE_API_KEY` | Brave Search | Primary web search |
| `TAVILY_API_KEY` | Tavily Search | Fallback web search |
| `MOONSHOT_API_KEY` | Moonshot AI | Primary LLM (Kimi K-2.5) |
| `XAI_API_KEY` | xAI | Fallback LLM #1 (Grok Vision Beta) |
| `OPENAI_API_KEY` | OpenAI | Fallback LLM #2 (GPT-4o) |
| `TELEGRAM_API_KEY` | Telegram | Bot communication |

## Tool Availability by Phase

### Phase 1: Selection
- web_search (Brave + Tavily)
- video_evaluation
- telegram_messaging
- chain_of_thought
- checkpoint_management

### Phase 2: Video Analysis
- browser_automation
- screenshot_capture
- kimi_vision (+ fallbacks)
- transcript_extraction
- supplementary_research
- pandas_openpyxl (+ CSV fallback)
- exec (ffmpeg)
- telegram_messaging
- chain_of_thought
- checkpoint_management
