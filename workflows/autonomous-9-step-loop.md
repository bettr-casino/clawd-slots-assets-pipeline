# autonomous-9-step-loop.md

This document replaces the old 9-step loop with the **single-phase workflow**.

## Phase 1: Video Intake + Frame Extraction

**Goal**: Ensure the source video exists locally and extract requested frames.

### Steps

1. **Verify Video**
	- Check for a local video file under `$YT_BASE_DIR/<file-name>/video/`.
	- If missing, ask the human for the video file name (default: `CLEOPATRA.webm`).

2. **Download**
	- Download from S3 and place it under `yt/<file-name>/video/`:

	```bash
	mkdir -p "$YT_BASE_DIR/<file-name>/video" "$YT_BASE_DIR/<file-name>/frames"
	curl -L "https://bettr-casino-assets.s3.us-west-2.amazonaws.com/yt/<file-name>" \
	  -o "$YT_BASE_DIR/<file-name>/video/<file-name>"
	```

3. **Collect Timestamps**
	- Ask if timestamps should be extracted.
	- Accept a list like `00:14:00 00:21:35 00:34:12`.

4. **Extract Frames**
	- For each timestamp, extract a frame into `$YT_BASE_DIR/<file-name>/frames/`:

	```bash
	./scripts/extract-frame.sh "$YT_BASE_DIR/<file-name>/video/<file-name>" "00:14:00" "$YT_BASE_DIR/<file-name>/frames"
	```

### Output

- Video stored at `$YT_BASE_DIR/<file-name>/video/<file-name>`
- Frames stored under `$YT_BASE_DIR/<file-name>/frames/`
- MEMORY.md updated with download status and extracted timestamps

---

## Rules

- Only this single phase is allowed.
- Always checkpoint progress in MEMORY.md.
- If the video already exists, skip the download step.
