# TOOLS.md

## Search Tools

### Brave Search API
- **Purpose**: Primary web search for YouTube videos and slot machine research
- **Env**: `BRAVE_API_KEY`
- **Usage**: Find videos, paytable data, RTP info, manufacturer specs
- **Fallback**: Tavily

### Tavily Search API
- **Purpose**: Fallback web search when Brave fails or is rate-limited
- **Env**: `TAVILY_API_KEY`
- **Usage**: Same as Brave — automatic fallback on any Brave error

---

## AI Models

### Kimi K-2.5 (Primary)
- **Provider**: moonshot
- **Model ID**: `moonshot/kimi-k2.5`
- **Capabilities**: Vision analysis, reasoning, code generation
- **Env**: `MOONSHOT_API_KEY`

### Grok Vision Beta (Fallback #1)
- **Provider**: xai
- **Model ID**: `xai/grok-vision-beta`
- **Capabilities**: Vision analysis, reasoning
- **Env**: `XAI_API_KEY`

### GPT-4o (Fallback #2)
- **Provider**: openai
- **Model ID**: `openai/gpt-4o`
- **Capabilities**: Vision analysis, reasoning, code generation
- **Env**: `OPENAI_API_KEY`

### Fallback Chain
`kimi-k2.5` → `grok-vision-beta` → `gpt-4o`

---

## Browser & Video Tools

### Browser Automation (OpenClaw built-in)
- **Purpose**: Navigate to YouTube, interact with pages
- **Capabilities**: Navigate URLs, click elements, scroll, extract content
- **Usage**: Video playback control, metadata extraction

### Screenshot Capture (OpenClaw built-in)
- **Purpose**: Capture video frames for vision analysis
- **Capabilities**: Full-page and element screenshots
- **Usage**: Capture reel states, paytables, bonus screens

### ffmpeg
- **Purpose**: Video frame extraction and processing
- **Install**: `apt install ffmpeg`
- **Usage**: Extract frames at intervals from downloaded videos

### yt-dlp
- **Purpose**: Download YouTube videos for local processing
- **Install**: `pip install yt-dlp`
- **Usage**: Download video files for ffmpeg frame extraction

---

## Data & Spreadsheet Tools

### pandas
- **Purpose**: Data manipulation and analysis
- **Install**: `pip install pandas`
- **Usage**: Structure game data, calculate math model values

### openpyxl
- **Purpose**: Create Excel .xlsx files with formatting
- **Install**: `pip install openpyxl`
- **Usage**: Generate multi-sheet math model spreadsheets
- **Fallback**: CSV export if openpyxl unavailable

---

## Communication Tools

### Telegram Bot API
- **Purpose**: Communication with Ron
- **Env**: `TELEGRAM_API_KEY`
- **Usage**:
  - Phase 1: Present top 5 video options, receive selection
  - Phase 2: Send analysis summary and spreadsheet file

---

## File System

### Workspace Directory
- **Path**: `/workspaces/clawd-slots-assets-pipeline`
- **Constitution**: `constitution/` — bot behavior and workflow definitions
- **Scripts**: `scripts/` — setup and utility scripts
- **Output**: Math model spreadsheets saved in workspace root or dedicated output folder

---

## Tool Availability Summary

| Tool | Phase 1 | Phase 2 | Key Required |
|------|---------|---------|--------------|
| Brave Search | ✅ | ✅ | BRAVE_API_KEY |
| Tavily Search | ✅ | ✅ | TAVILY_API_KEY |
| Kimi K-2.5 | ✅ | ✅ | MOONSHOT_API_KEY |
| Grok Vision | ✅ | ✅ | XAI_API_KEY |
| GPT-4o | ✅ | ✅ | OPENAI_API_KEY |
| Browser | ❌ | ✅ | — |
| Screenshots | ❌ | ✅ | — |
| pandas/openpyxl | ❌ | ✅ | — |
| ffmpeg/yt-dlp | ❌ | ✅ | — |
| Telegram | ✅ | ✅ | TELEGRAM_API_KEY |
