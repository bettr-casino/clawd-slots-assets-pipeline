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

## Video Tools

### ffmpeg
- **Purpose**: Video frame extraction and processing
- **Install**: `apt install ffmpeg`
- **Usage**: Extract frames at exact timestamps from downloaded videos

### extract-frame.sh
- **Purpose**: Wrapper script for consistent frame extraction
- **Usage**: `/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh CLEOPATRA <timestamp>`

### Multimodal LLM (Kimi K2.5)
- **Purpose**: Analyze frames and tags.txt for slot machine analysis
- **Usage**: Run after frame extraction and tags.txt are ready
- **Output**: analysis.md

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
