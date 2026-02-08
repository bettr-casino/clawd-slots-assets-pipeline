# GOAL.md

## Primary Goal

Prepare local video sources and extract requested frames through a **single-phase workflow**. The agent ensures the video exists under the `yt/` workspace folder, downloads it from S3 if needed, and extracts frames at human-provided timestamps.

**Key Rules:**
- Use `ffmpeg` via `scripts/extract-frame.sh` for timestamped frame extraction
- Default video name when none is provided: `CLEOPATRA.webm`
- Store videos under `$YT_BASE_DIR/<file-name>/video/` and frames under `$YT_BASE_DIR/<file-name>/frames/`
- `YT_BASE_DIR` must be set before downloads or extraction
- Send Telegram updates at each decision point
- Save checkpoint data in MEMORY.md (phase, status, decisions)

## Phase 1: Video Intake + Frame Extraction

### Objective
Ensure the video file exists locally and extract frames at the requested timestamps.

### Step 1.1: Verify or Download the Video

**Actions:**
- Check for a local video file under `$YT_BASE_DIR/<file-name>/video/`
- If missing, ask the human for the video filename (default: `CLEOPATRA.webm`)
- Download from the public URL into the local `$YT_BASE_DIR/<file-name>/video/` folder

**Download Command (Public URL):**

```bash
mkdir -p "$YT_BASE_DIR/<file-name>/video" "$YT_BASE_DIR/<file-name>/frames"
curl -L "https://bettr-casino-assets.s3.us-west-2.amazonaws.com/yt/<file-name>" \
	-o "$YT_BASE_DIR/<file-name>/video/<file-name>"
```

### Step 1.2: Confirm Timestamps

**Actions:**
- Ask the human if they want to extract timestamps
- If yes, request a list like `00:14:00 00:21:35 00:34:12`

### Step 1.3: Extract Frames

**Actions:**
- For each timestamp, run `scripts/extract-frame.sh` to capture a single frame
- Store frames under `$YT_BASE_DIR/<file-name>/frames/`

**Example:**

```bash
./scripts/extract-frame.sh "$YT_BASE_DIR/<file-name>/video/<file-name>" "00:14:00" "$YT_BASE_DIR/<file-name>/frames"
```

**Checkpoint:** Update MEMORY.md with video status and extracted timestamps.
