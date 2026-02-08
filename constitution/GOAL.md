# GOAL.md

## Primary Goal

Prepare local video sources and extract requested frames through a **single-phase workflow**. The agent collects timestamps, ensures the video exists under the `yt/` workspace folder (downloading from S3 if needed), and extracts frames at the human-provided timestamps.

**Key Rules:**
- Use `ffmpeg` via `/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh` for timestamped frame extraction
- Default video name when none is provided: `CLEOPATRA`
- Store videos under `$YT_BASE_DIR/<file-name>/video/` and frames under `$YT_BASE_DIR/<file-name>/frames/`
- `YT_BASE_DIR` must be set before downloads or extraction
- `/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh` takes a **base file name** (no extension); if `.webm` is provided it is stripped before use
- The script downloads from S3 if the video is missing
- S3 public URL format: `https://bettr-casino-assets.s3.us-west-2.amazonaws.com/yt/<file-name>.webm`
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
- Public URL format: `https://bettr-casino-assets.s3.us-west-2.amazonaws.com/yt/<file-name>.webm`
- Store frames under `$YT_BASE_DIR/<file-name>/frames/`

**Example:**

```bash
/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh "<file-name>" "00:14:00"
```

**Checkpoint:** Update MEMORY.md with video status and extracted timestamps.
