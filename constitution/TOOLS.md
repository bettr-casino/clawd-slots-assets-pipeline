# TOOLS.md

## Storage Tools

### Public S3 HTTP
- **Purpose**: Download source videos from the public asset bucket
- **Usage**: `curl -L https://bettr-casino-assets.s3.us-west-2.amazonaws.com/yt/CLEOPATRA.webm -o $YT_BASE_DIR/CLEOPATRA/video/CLEOPATRA.webm`
- **Requires**: `YT_BASE_DIR` set to the local yt root

## AI Models

### Kimi K-2.5 (Primary — Moonshot only)
- **Provider**: moonshot
- **Model ID**: `moonshot/kimi-k2.5`
- **Capabilities**: Vision analysis (native multimodal), reasoning, code generation, agent tasks
- **Context Window**: 256K tokens
- **Env**: `MOONSHOT_API_KEY`
- **No fallback models** — all inference runs through Moonshot

---

## Input Files

### tags.txt (human-authored)
- **Purpose**: Defines which frames/animations to extract from the video
- **Path**: `$YT_BASE_DIR/CLEOPATRA/tags.txt`
- **Format**: `START_TS END_TS\tdescription` — one entry per line
- **Single frame**: start == end (extracts one PNG)
- **Animation range**: start < end (extracts all frames at 60fps)
- **IMPORTANT**: The bot reads tags.txt — it never writes or modifies it

## Video Tools

### ffmpeg
- **Purpose**: Video frame extraction and processing
- **Install**: `apt install ffmpeg`
- **Usage**: Extract single frames or animation sequences from the video

### extract-frame.sh
- **Purpose**: Wrapper script for consistent frame extraction (single frame or range)
- **Single frame**: `/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh CLEOPATRA "00:00:16"`
- **Animation range**: `/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh CLEOPATRA "00:00:24" "00:00:32" "# complete spin"`
- **Output**: PNGs in `$YT_BASE_DIR/CLEOPATRA/frames/`

### Multimodal LLM (Kimi K2.5)
- **Purpose**: Analyze frames using tags.txt descriptions to reverse-engineer symbols, paytable, animations
- **Usage**: Run after frame extraction; use tags.txt descriptions to understand what each frame shows
- **Output**: analysis.md, math model spreadsheets

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
  - Phase 1: Notify when extraction is complete
  - Phase 2: Request approval before analysis
  - All phases: Progress updates, blocker notifications

---

## File System

### Workspace Directory
- **Path**: `/workspaces/clawd-slots-assets-pipeline`
- **Constitution**: `constitution/` — bot behavior and workflow definitions
- **Scripts**: `scripts/` — setup and utility scripts
- **Output**: Math model spreadsheets saved in `$YT_BASE_DIR/CLEOPATRA/output/`

---

## Privileges & Installation

- **Elevated Access**: ClawdBot has passwordless sudo permissions for administrative tasks
- **Tooling**: Allowed to download and install required tools (system packages and Python utilities)

---

## Tool Availability Summary

| Tool | Phase 1 | Key Required |
|------|---------|--------------|
| Public S3 HTTP | ✅ | — |
| Kimi K-2.5 | ✅ | MOONSHOT_API_KEY |
| ffmpeg | ✅ | — |
| Telegram | ✅ | TELEGRAM_API_KEY |
