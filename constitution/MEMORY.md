# MEMORY.md

## Checkpoint State Persistence

This file maintains the current state of the autonomous 9-step reverse-engineering loop, enabling restart resilience after Codespace shutdowns or interruptions.

---

## Current State

```json
{
  "iteration": 0,
  "step": 0,
  "status": "idle",
  "timestamp": null,
  "human_decision": null
}
```

---

## Iteration History

### Format

Each iteration is logged with the following structure:

```json
{
  "iteration": 1,
  "started_at": "2026-02-06T03:00:00Z",
  "completed_at": "2026-02-06T05:30:00Z",
  "status": "completed",
  "human_decision": "no",
  "commit_sha": "abc123...",
  "checkpoints": [
    {
      "step": 1,
      "name": "Web Search",
      "status": "complete",
      "timestamp": "2026-02-06T03:00:00Z",
      "data": {
        "video_urls": ["https://youtube.com/watch?v=..."],
        "selected_video": "https://youtube.com/watch?v=...",
        "video_quality_notes": "Clear reels, multiple spins, bonus features visible"
      }
    },
    {
      "step": 2,
      "name": "Video Analysis",
      "status": "complete",
      "timestamp": "2026-02-06T03:30:00Z",
      "data": {
        "reel_config": "5x3",
        "symbol_count": 12,
        "screenshots": ["/path/to/frame001.png", "/path/to/frame002.png"],
        "analysis_summary": "Egyptian theme, Cleopatra wild symbol, scatter book symbols..."
      }
    },
    {
      "step": 3,
      "name": "Asset List Creation",
      "status": "complete",
      "timestamp": "2026-02-06T03:45:00Z",
      "data": {
        "spreadsheet_type": "excel",
        "spreadsheet_path": "/path/to/iteration_1_assets.xlsx",
        "csv_fallback": false,
        "sheets": ["iteration_log", "math_model", "symbol_analysis", "checkpoints"]
      }
    },
    {
      "step": 4,
      "name": "Asset Generation",
      "status": "complete",
      "timestamp": "2026-02-06T04:15:00Z",
      "data": {
        "assets_generated": 25,
        "asset_dir": "/path/to/iterations/iteration_1/assets",
        "generation_tool": "meshy-ai",
        "asset_types": ["symbols", "textures", "particles", "animations"]
      }
    },
    {
      "step": 5,
      "name": "Code Generation",
      "status": "complete",
      "timestamp": "2026-02-06T04:45:00Z",
      "data": {
        "godot_project_path": "/path/to/iterations/iteration_1/godot_project",
        "gdscript_files": ["reel_controller.gd", "win_calculator.gd", "main.gd"],
        "features_implemented": ["base_game", "reel_spins", "win_calculation"]
      }
    },
    {
      "step": 6,
      "name": "Deploy Test Version",
      "status": "complete",
      "timestamp": "2026-02-06T05:00:00Z",
      "data": {
        "deployment_platform": "github-pages",
        "public_url": "https://username.github.io/cleopatra-slot-iter1",
        "deployment_status": "success"
      }
    },
    {
      "step": 7,
      "name": "Record Test Video",
      "status": "complete",
      "timestamp": "2026-02-06T05:10:00Z",
      "data": {
        "video_path": "/path/to/iterations/iteration_1/generated_gameplay.mp4",
        "duration_seconds": 45,
        "recording_method": "browser-automation"
      }
    },
    {
      "step": 8,
      "name": "Compare Videos",
      "status": "complete",
      "timestamp": "2026-02-06T05:20:00Z",
      "data": {
        "comparison_method": "kimi-vision",
        "visual_similarity_score": 7,
        "strengths": ["Color scheme matches", "Symbol designs captured well"],
        "improvements": ["Animation timing needs work", "Bonus feature incomplete"]
      }
    },
    {
      "step": 9,
      "name": "Human Feedback",
      "status": "complete",
      "timestamp": "2026-02-06T05:30:00Z",
      "data": {
        "telegram_message_sent": true,
        "human_decision": "no",
        "feedback_notes": "Good start, need better animations"
      }
    }
  ]
}
```

---

## Active Checkpoints

Store only the current iteration's in-progress checkpoints here. Completed iterations move to the history section above.

**Current Iteration**: None active

**Next Action**: Await user command to start reverse-engineering a specific slot machine

---

## Rules

1. **Always save checkpoint data after completing each step** to ensure restart resilience
2. **Update `current_state` at the top** to reflect the latest iteration, step, and status
3. **Log human decisions** (`yes`/`no`) in iteration history for audit trail
4. **Store commit SHAs** after pushing approved iterations to track repository state
5. **On human "yes" decision**: 
   - Mark iteration as `final: true`
   - Store commit SHA of the final approved state
   - Delete previous iteration folders (keep only latest approved assets)
6. **On Codespace restart**: 
   - Read this file to determine current iteration and step
   - Resume from last completed checkpoint
   - Continue the 9-step loop where it left off

---

## Spreadsheet Management

### Excel Priority (pandas + openpyxl)

- **Primary format**: Create `.xlsx` files using pandas with openpyxl engine
- **Structure**: Multiple sheets per iteration file:
  - `iteration_log`: Tracks all steps, timestamps, decisions
  - `math_model`: Paytable, RTP calculations, symbol weights
  - `symbol_analysis`: Symbol descriptions, frequencies, visual attributes
  - `checkpoints`: Snapshot of progress for each step
- **File naming**: `iteration_{N}_analysis.xlsx`
- **Storage**: In `/iterations/iteration_{N}/` directory

### CSV Fallback

- **If openpyxl installation/import fails**: Fall back to CSV files
- **Generate separate CSV files**:
  - `iteration_log.csv`
  - `math_model.csv`
  - `symbol_analysis.csv`
  - `checkpoints.csv`
- **Can be imported into Excel manually** by user if needed
- **Log CSV fallback usage** in checkpoint data

---

## Binary Asset Storage Rules

1. **Store binary assets directly in repository** (textures, models, animations, videos)
2. **Do NOT use Git LFS** - store files directly without LFS tracking
3. **Organize by iteration**:
   ```
   /iterations/
     /iteration_1/
       /assets/
         /symbols/
         /textures/
         /particles/
         /animations/
       /videos/
       iteration_1_analysis.xlsx
       godot_project/
   ```
4. **On human "yes" decision**:
   - Keep only the latest approved iteration folder
   - Delete all previous iteration folders (`iteration_1`, `iteration_2`, etc. except the final one)
   - This prevents repository bloat while maintaining the approved version

---

## Telegram Progress Update Format

**Every 30 minutes during active work**, send exactly 2 sentences:

```
Last 30 mins I worked on <step number and brief description>.
Next 30 mins I am working on <next step number and plan>.
```

**After completing each iteration** (all 9 steps), send summary:

```
Iteration <N> complete.

Summary:
- Video analyzed: <YouTube URL>
- Assets generated: <count> original models, textures, animations
- Godot implementation: <feature list>
- Comparison result: <brief quality assessment>

Test URL: <public deployment URL>

Quality highlights:
- <strength 1>
- <strength 2>

Areas for improvement:
- <gap 1>
- <gap 2>

Is it good enough? Reply 'yes' or 'no'.
```

**Wait for human "yes"/"no" decision** before proceeding with next iteration or finalizing.

---

## Chain-of-Thought Requirement

**All complex decisions and analyses must use chain-of-thought reasoning:**

- Start with "Let's think step by step"
- Show observations before conclusions
- Explain reasoning at each decision point
- Build toward insights systematically
- Make thought process transparent
- Document reasoning in checkpoint data

---

## Resume Protocol

When Clawd restarts after a Codespace shutdown:

1. **Read this MEMORY.md file**
2. **Check `current_state` section** for iteration, step, and status
3. **Load last completed checkpoint data** from `active_checkpoints` or `iteration_history`
4. **Resume execution**:
   - If mid-step: Continue that step from where it left off
   - If between steps: Start the next step
   - If waiting for human feedback: Check Telegram for response
5. **Send Telegram status update** indicating resume and next planned action
6. **Continue 9-step loop** until human approval or blocker

---

## Example Usage

### Starting Fresh
```json
{
  "iteration": 1,
  "step": 1,
  "status": "in_progress",
  "timestamp": "2026-02-06T03:00:00Z",
  "human_decision": null
}
```

### Mid-Iteration
```json
{
  "iteration": 1,
  "step": 5,
  "status": "in_progress",
  "timestamp": "2026-02-06T04:45:00Z",
  "human_decision": null
}
```

### Waiting for Human Feedback
```json
{
  "iteration": 1,
  "step": 9,
  "status": "awaiting_human_decision",
  "timestamp": "2026-02-06T05:30:00Z",
  "human_decision": "pending"
}
```

### Iteration Approved
```json
{
  "iteration": 1,
  "step": 9,
  "status": "approved",
  "timestamp": "2026-02-06T06:00:00Z",
  "human_decision": "yes",
  "final": true,
  "commit_sha": "abc123def456..."
}
```

### Starting Next Iteration (After "No")
```json
{
  "iteration": 2,
  "step": 1,
  "status": "in_progress",
  "timestamp": "2026-02-06T06:15:00Z",
  "human_decision": null
}
```
