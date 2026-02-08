# Egyptian MVP Pipeline (Single-Phase Workflow)

This workflow is for **Egyptian-themed slot machines** (Cleopatra, Luxor, etc.) using the new single-phase intake + frame extraction process.

## Phase 1: Video Intake + Frame Extraction

**Goal**: Ensure the source video exists locally and extract requested frames for analysis.

### Step 1: Verify or Download the Video

1. Check for a local video file under `$YT_BASE_DIR/<file-name>/video/`.
2. If it does not exist, ask the human for the video file name (default: `CLEOPATRA.webm`).
3. Download from S3 and place it under `yt/<file-name>/video/`:

```bash
mkdir -p "$YT_BASE_DIR/<file-name>/video" "$YT_BASE_DIR/<file-name>/frames"
curl -L "https://bettr-casino-assets.s3.us-west-2.amazonaws.com/yt/<file-name>" \
	-o "$YT_BASE_DIR/<file-name>/video/<file-name>"
```

### Step 2: Collect Timestamps

After download, ask the human if they want to extract timestamps. If yes, request a list like:

```
00:14:00 00:21:35 00:34:12
```

### Step 3: Extract Frames

For each timestamp, extract a frame into `$YT_BASE_DIR/<file-name>/frames/`:

```bash
./scripts/extract-frame.sh "$YT_BASE_DIR/<file-name>/video/<file-name>" "00:14:00" "$YT_BASE_DIR/<file-name>/frames"
```

### Output

- Video stored at `$YT_BASE_DIR/<file-name>/video/<file-name>`
- Frames stored under `$YT_BASE_DIR/<file-name>/frames/`
- MEMORY.md updated with download status and extracted timestamps

---

## Notes

- Use the default `CLEOPATRA.webm` when the human does not specify a filename.
- Multiple timestamps are allowed and should be processed one-by-one.
