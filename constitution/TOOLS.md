# TOOLS.md

## Storage Tools

### Public S3 HTTP
- **Purpose**: Download source videos from the public asset bucket
- **Usage**: `curl -L https://bettr-casino-assets.s3.us-west-2.amazonaws.com/yt/<file-name>.webm -o $YT_BASE_DIR/<file-name>/video/<file-name>.webm`
- **Requires**: `YT_BASE_DIR` set to the local yt root

## AI Models

### Kimi K-2.5 (Primary)
- **Provider**: moonshot
- **Model ID**: `moonshot/kimi-k2.5`
- **Capabilities**: Vision analysis, reasoning, code generation
- **Env**: `MOONSHOT_API_KEY`

### Grok 2 Vision (Fallback #1)
- **Provider**: xai
- **Model ID**: `xai/grok-2-vision`
- **Capabilities**: Vision analysis, reasoning
- **Env**: `XAI_API_KEY`

### GPT-4o (Fallback #2)
- **Provider**: openai
- **Model ID**: `openai/gpt-4o`
- **Capabilities**: Vision analysis, reasoning, code generation
- **Env**: `OPENAI_API_KEY`

### Fallback Chain
`kimi-k2.5` → `grok-2-vision` → `gpt-4o`

---

## Video Tools

### ffmpeg
- **Purpose**: Video frame extraction and processing
- **Install**: `apt install ffmpeg`
- **Usage**: Extract frames at exact timestamps from downloaded videos

### extract-frame.sh
- **Purpose**: Wrapper script for consistent frame extraction
- **Usage**: `/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh <file-name> <timestamp>` (optional `.webm` suffix is stripped)

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
  - Phase 1: Confirm filename and timestamps

---

## File System

### Workspace Directory
- **Path**: `/workspaces/clawd-slots-assets-pipeline`
- **Constitution**: `constitution/` — bot behavior and workflow definitions
- **Scripts**: `scripts/` — setup and utility scripts
- **Output**: Math model spreadsheets saved in workspace root or dedicated output folder

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
| Grok Vision | ✅ | XAI_API_KEY |
| GPT-4o | ✅ | OPENAI_API_KEY |
| ffmpeg | ✅ | — |
| Telegram | ✅ | TELEGRAM_API_KEY |
