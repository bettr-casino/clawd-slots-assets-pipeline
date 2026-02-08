# SKILLS.md

## Phase 1: Video Intake + Frame Extraction Skills

### file_validation

- **Purpose**: Confirm the video file exists under `$YT_BASE_DIR/<file-name>/video/<file-name>.webm`
- **Checks**: File path exists, file size > 0

### public_url_download (curl or wget)

- **Purpose**: Download the source video from the public S3 URL
- **Command**: `curl -L "https://bettr-casino-assets.s3.us-west-2.amazonaws.com/yt/<file-name>.webm" -o "$YT_BASE_DIR/<file-name>/video/<file-name>.webm"`
- **Requirements**: `curl` or `wget`
- **Safety**: Only allow base filenames with `A-Z`, `a-z`, `0-9`, `_`, `-` (optional `.webm` suffix is stripped)

### ffmpeg_frame_extraction

- **Purpose**: Extract a single frame at a specific timestamp
- **Tool**: `/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh`
- **Input**: Base filename (optional `.webm` suffix), timestamp `HH:MM:SS`
- **Output**: One PNG per timestamp in `$YT_BASE_DIR/<file-name>/frames/` (auto-downloads video if missing)

### telegram_messaging

- **Purpose**: Communicate with Ron via Telegram
- **Usage**: Request filename, confirm timestamps, and report completion
- **Configuration**: `TELEGRAM_API_KEY` for bot token

### exec (Command Execution)

- **Purpose**: Run `/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh` (auto-downloads if missing)
- **Exec mode**: Use regular exec (non-elevated). No sudo required for ffmpeg.
- **Guardrail**: Never run frame extraction on a missing file

---

## Phase 2: Multimodal LLM Analysis Skills

### multimodal_llm_analysis
- **Purpose**: Analyze extracted frames and tags.txt for a specific video
- **Tool**: Multimodal LLM (e.g., Kimi K2.5)
- **Input**: Frames directory, tags.txt
- **Output**: analysis.md with slot symbols, reel layout, and symbol animations

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
  - Ask the human for a new filename if the object is missing
  - If a provider reports a missing API key but the env var exists, re-register the key in the OpenClaw auth store and retry
  - Send Telegram notification for unrecoverable issues
  - Never silently fail

### file_management

- **Purpose**: Organize output files
- **Videos**: `$YT_BASE_DIR/<file-name>/video/<file-name>.webm`
- **Frames**: `$YT_BASE_DIR/<file-name>/frames/frame_<timestamp>.png`
- **Logs**: Intake progress in MEMORY.md

---

## API Keys Required

| Key | Service | Purpose |
|-----|---------|---------|
| `MOONSHOT_API_KEY` | Moonshot AI | Primary LLM (Kimi K-2.5) |
| `XAI_API_KEY` | xAI | Fallback LLM #1 (Grok Vision Beta) |
| `OPENAI_API_KEY` | OpenAI | Fallback LLM #2 (GPT-4o) |
| `TELEGRAM_API_KEY` | Telegram | Bot communication |

## Tool Availability by Phase

### Phase 1: Video Intake + Frame Extraction
- file_validation
- public_url_download
- ffmpeg_frame_extraction
- telegram_messaging
- exec
- chain_of_thought
- checkpoint_management
