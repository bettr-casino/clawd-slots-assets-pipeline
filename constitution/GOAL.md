# GOAL.md

## Primary Goal

Prepare local video sources, analyze frames, and generate symbol textures through a **three-phase workflow**. The agent collects timestamps, ensures the video exists under the `yt/` workspace folder (downloading from S3 if needed), extracts frames at the human-provided timestamps, produces analysis, and generates symbol assets.

**Key Rules:**
- Use `ffmpeg` via `/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh` for timestamped frame extraction
- Video filename is hardcoded as `CLEOPATRA` (do not ask the human for a filename)
- Store videos under `$YT_BASE_DIR/CLEOPATRA/video/` and frames under `$YT_BASE_DIR/CLEOPATRA/frames/`
- `YT_BASE_DIR` must be set before downloads or extraction
- `/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh` takes the base file name `CLEOPATRA` (no extension)
- The script downloads from S3 if the video is missing
- S3 public URL: `https://bettr-casino-assets.s3.us-west-2.amazonaws.com/yt/CLEOPATRA.webm`
- No game implementation occurs in this workflow; asset creation is limited to Phase 3 symbol textures
- Always use absolute paths for file access and tool calls
- Send Telegram updates at each decision point
- Save checkpoint data in MEMORY.md (phase, status, decisions, confirmed YouTube URL)

## Phase 1: Video Intake + Frame Extraction

### Objective
Ensure the video file exists locally and extract frames at the requested timestamps.

### Step 1.1: Confirm YouTube URL

**Actions:**
- Ask the human to confirm the YouTube URL
- Default URL: `https://www.youtube.com/watch?v=Ks8o3bl7OYQ`
- If not confirmed, request the updated URL

### Step 1.2: Confirm Timestamps

**Actions:**
- Ask the human if they want to extract timestamps
- If yes, request a list like `00:14:00 00:21:35 00:34:12`

### Step 1.3: Extract Frames (Auto-Download if Missing)

**Actions:**
- For each timestamp, run `/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh` to capture a single frame
- If the video is missing, the script downloads it from the public S3 URL
- Public URL: `https://bettr-casino-assets.s3.us-west-2.amazonaws.com/yt/CLEOPATRA.webm`
- Store frames under `$YT_BASE_DIR/CLEOPATRA/frames/`

**Example:**

```bash
/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh "CLEOPATRA" "00:14:00"
```

**Checkpoint:** Update MEMORY.md with video status and extracted timestamps.

---

## Phase 2: Multimodal LLM Analysis

### Objective
Analyze the extracted frames and tags for the CLEOPATRA video using the multimodal LLM Kimi K2.5, after confirmation from the human via Telegram.

### Inputs
- Frames: `$YT_BASE_DIR/CLEOPATRA/frames/`
- Tags: `$YT_BASE_DIR/CLEOPATRA/tags.txt`

### Actions
- Use the tags.txt metadata to guide analysis of specific time ranges and frames.
- Ask for approval once per Phase 2 run, record approval in MEMORY.md before executing, and do not re-ask on retries or command failures
- Helper scripts are allowed if needed; bot-generated scripts must live under `/workspaces/clawd-slots-assets-pipeline/scripts/`
- Missing scripts must not block Phase 2; create them or proceed with direct multimodal analysis
- When accessing frames, use absolute paths under `$YT_BASE_DIR` to avoid cwd issues
- Identify:
	- Symbols used in the slot machine
	- Reel layout (number of reels and visible symbols per reel)
	- Symbol landing animations for some symbols
- Do not create assets or implement the game in this phase

### Output
- Generate `analysis.md` at `$YT_BASE_DIR/CLEOPATRA/analysis.md` containing the results.
- Write any math model spreadsheets and CSVs to `$YT_BASE_DIR/CLEOPATRA/output/`.

---

## Phase 3: Symbol Asset Generation

### Objective
Generate symbol texture assets that are very close to the original symbols in the extracted frames.

### Inputs
- Frames: `$YT_BASE_DIR/CLEOPATRA/frames/`
- Tags: `$YT_BASE_DIR/CLEOPATRA/tags.txt`
- Analysis: `$YT_BASE_DIR/CLEOPATRA/analysis.md`

### Actions
- Use Phase 1 frames, tags.txt, and Phase 2 analysis as the source of truth for symbol appearance.
- Generate a texture per symbol that closely matches the original symbol in color, shape, lighting, and material.
- Each asset filename must include the symbol name from the analysis.
- Present all generated symbols to the user for review.
- If the user rejects all or specific symbols, regenerate only the rejected symbols and re-present for review.

### Output
- Write symbol textures to `$YT_BASE_DIR/CLEOPATRA/output/symbols/`.
