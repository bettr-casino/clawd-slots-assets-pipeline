# Egyptian MVP Pipeline (Single-Phase Workflow)
This workflow is for **Egyptian-themed slot machines** (Cleopatra, Luxor, etc.) using the new single-phase intake + frame extraction process.

## Phase 1: Video Intake + Frame Extraction

### Step 1: Confirm YouTube URL

Ask the human to confirm the YouTube URL.

- Default URL: `https://www.youtube.com/watch?v=Ks8o3bl7OYQ`
- If not confirmed, request the updated URL

### Step 2: Collect Timestamps

Ask the human if they want to extract timestamps. If yes, request a list like:

```
00:14:00 00:21:35 00:34:12
```

### Step 3: Extract Frames (Auto-Download if Missing)

For each timestamp, extract a frame into `$YT_BASE_DIR/<file-name>/frames/`. The script downloads the video from S3 if missing:

```bash
/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh "<file-name>" "00:14:00"
```

### Output

- Video stored at `$YT_BASE_DIR/<file-name>/video/<file-name>.webm`
- Frames stored under `$YT_BASE_DIR/<file-name>/frames/`
- MEMORY.md updated with download status and extracted timestamps

---

## Phase 2: Multimodal LLM Analysis

After frame extraction and tags.txt are ready, confirm with the user before starting analysis.

- Use a multimodal LLM (e.g., Kimi K2.5) to analyze frames and tags.txt
- Identify slot symbols, reel layout, and symbol landing animations
- Write results to `$YT_BASE_DIR/<file-name>/analysis.md`

---

## Notes

- Use the default `CLEOPATRA` when the human does not specify a filename.
- Multiple timestamps are allowed and should be processed one-by-one.
