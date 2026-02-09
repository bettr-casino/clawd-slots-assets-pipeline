# cleopatra-research.md
This workflow is a **game-specific instance** of the three-phase pipeline, scoped to Cleopatra or Cleopatra-style slots.

## Phase 1: Video Intake + Frame Extraction (Cleopatra Focus)

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
- Write math model spreadsheets and CSVs to `$YT_BASE_DIR/<file-name>/output/`
- Any bot-generated scripts must live under `/workspaces/clawd-slots-assets-pipeline/scripts/`

---

## Phase 3: Symbol Asset Generation

After Phase 2 analysis is complete, generate symbol textures using the frames, tags.txt, and analysis.md.

- Generate a texture per symbol that closely matches the original symbol in the frames
- Save textures under `$YT_BASE_DIR/<file-name>/output/symbols/` with filenames that include the symbol name
- Present all symbol textures for review
- If the user rejects all or specific symbols, regenerate only those symbols and re-present

---

## Notes

- Use the default `CLEOPATRA` when the human does not specify a filename.
- Multiple timestamps are allowed and should be processed one-by-one.
