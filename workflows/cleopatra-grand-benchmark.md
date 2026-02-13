# Cleopatra Grand Benchmark (Three-Phase Workflow)
This workflow applies the three-phase intake, analysis, and symbol asset generation process to the Cleopatra Grand slot machine.

## Phase 1: Video Intake + Frame Extraction (Cleopatra Grand)

### Step 1: Collect Timestamps

YouTube URL is hardcoded: `https://www.youtube.com/watch?v=Ks8o3bl7OYQ` (do not ask for confirmation).

Ask the human for timestamps to extract, e.g.:

```
00:14:00 00:21:35 00:34:12
```

### Step 3: Extract Frames (Auto-Download if Missing)

For each timestamp, extract a frame into `$YT_BASE_DIR/CLEOPATRA/frames/`. The script downloads the video from S3 if missing:

```bash
/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh "CLEOPATRA" "00:14:00"
```

### Output

- Video stored at `$YT_BASE_DIR/CLEOPATRA/video/CLEOPATRA.webm`
- Frames stored under `$YT_BASE_DIR/CLEOPATRA/frames/`
- MEMORY.md updated with download status and extracted timestamps

---

## Phase 2: Multimodal LLM Analysis

After frame extraction and tags.txt are ready, confirm with the user before starting analysis.

- Use a multimodal LLM (e.g., Kimi K2.5) to analyze frames and tags.txt
- Identify slot symbols, reel layout, and symbol landing animations
- Write results to `$YT_BASE_DIR/CLEOPATRA/analysis.md`
- Write math model spreadsheets and CSVs to `$YT_BASE_DIR/CLEOPATRA/output/`
- Any bot-generated scripts must live under `/workspaces/clawd-slots-assets-pipeline/scripts/`

---

## Phase 3: Symbol Asset Generation

After Phase 2 analysis is complete, generate symbol textures using the frames, tags.txt, and analysis.md.

- Generate a texture per symbol that closely matches the original symbol in the frames
- Save textures under `$YT_BASE_DIR/CLEOPATRA/output/symbols/` with filenames that include the symbol name
- Present all symbol textures for review
- If the user rejects all or specific symbols, regenerate only those symbols and re-present

---

## Notes

- The filename is hardcoded as `CLEOPATRA` (do not ask the human for a filename).
- Multiple timestamps are allowed and should be processed one-by-one.
