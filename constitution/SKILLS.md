# SKILLS.md

## Phase 1: Frame Extraction Skills

### file_validation

- **Purpose**: Confirm the video file exists under `$YT_BASE_DIR/CLEOPATRA/video/CLEOPATRA.webm`
- **Checks**: File path exists, file size > 0

### public_url_download (curl or wget)

- **Purpose**: Download the source video from the public S3 URL
- **Command**: `curl -L "https://bettr-casino-assets.s3.us-west-2.amazonaws.com/yt/CLEOPATRA.webm" -o "$YT_BASE_DIR/CLEOPATRA/video/CLEOPATRA.webm"`
- **Requirements**: `curl` or `wget`
- **Note**: Filename is hardcoded as `CLEOPATRA` for now

### tags_txt_parsing

- **Purpose**: Read human-authored `$YT_BASE_DIR/CLEOPATRA/tags.txt` to get timestamps and descriptions
- **Format**: `START_TS END_TS\tdescription` — one entry per line
- **Single frame**: start == end — extract one PNG
- **Animation range**: start < end — extract all frames at 60fps

### ffmpeg_frame_extraction

- **Purpose**: Extract frames (single or animation range) from the video
- **Tool**: `/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh`
- **Input**: `CLEOPATRA` (hardcoded), start timestamp, optional end timestamp and comment
- **Output**: PNGs in `$YT_BASE_DIR/CLEOPATRA/frames/` (auto-downloads video if missing)
- **Single frame**: `frame__HH_MM_SS.01.png`
- **Animation range**: `frame__HH_MM_SS.FF.png` (FF = frame within second, 01–60)

### telegram_messaging

- **Purpose**: Communicate with Ron via Telegram
- **Usage**: Report extraction progress, request Phase 2 approval, report results
- **Configuration**: `TELEGRAM_API_KEY` for bot token

### exec (Command Execution)

- **Purpose**: Run `/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh` (auto-downloads if missing)
- **Exec mode**: Use regular exec (non-elevated). No sudo required for ffmpeg.
- **Guardrail**: Never run frame extraction on a missing file

---

## Phase 2: Multimodal LLM Analysis Skills

### multimodal_llm_analysis
- **Purpose**: Reverse-engineer slot machine from extracted frames guided by tags.txt descriptions
- **Tool**: Kimi K2.5 (multimodal vision + text)
- **Input**: Frames directory, tags.txt (use absolute paths under `$YT_BASE_DIR`)
- **Output**: analysis.md with symbol inventory, reel layout, paytable, math model, bonus features, animations, visual style
- **Animation analysis**: Use animation-range frames to document spin/landing/win sequences
- **Helper scripts**: If needed, place under `/workspaces/clawd-slots-assets-pipeline/scripts/`

---

## Phase 3: Symbol Asset Generation Skills

### symbol_texture_generation
- **Purpose**: Generate symbol texture assets closely matching the original frame symbols
- **Input**: Frames directory, tags.txt, analysis.md (use absolute paths under `$YT_BASE_DIR`)
- **Frame selection**: Evaluate all candidate frames for each symbol and pick the sharpest non-blurred frame(s) before generation
- **Output**: One texture per symbol under `$YT_BASE_DIR/CLEOPATRA/output/symbols/`
- **Naming**: Asset filenames must include the symbol name
- **Review**: Present all generated assets; regenerate only rejected symbols

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
  - Retry S3 downloads when transient failures occur
  - Report to the human via Telegram if the S3 object is missing
  - If Moonshot reports a missing API key but MOONSHOT_API_KEY env var exists, re-register the key in the OpenClaw auth store and retry
  - Send Telegram notification for unrecoverable issues
  - Never silently fail
  - Use absolute paths when referencing files in logs or commands

### file_management

- **Purpose**: Organize output files
- **Videos**: `$YT_BASE_DIR/CLEOPATRA/video/CLEOPATRA.webm` (use absolute paths)
- **Frames**: `$YT_BASE_DIR/CLEOPATRA/frames/frame_<timestamp>.png` (use absolute paths)
- **Output**: `$YT_BASE_DIR/CLEOPATRA/output/` for math model spreadsheets and CSVs
- **Symbols**: `$YT_BASE_DIR/CLEOPATRA/output/symbols/` for texture assets
- **Logs**: Intake progress in MEMORY.md

---

## API Keys Required

| Key | Service | Purpose |
|-----|---------|---------|
| `MOONSHOT_API_KEY` | Moonshot AI | LLM — Kimi K-2.5 (sole provider) |
| `TELEGRAM_API_KEY` | Telegram | Bot communication |

## Tool Availability by Phase

### Phase 1: Frame Extraction
- tags_txt_parsing
- file_validation
- public_url_download
- ffmpeg_frame_extraction
- telegram_messaging
- exec
- chain_of_thought
- checkpoint_management
