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
  "human_decision": null,
  "current_iteration_folder": null,
  "last_approved_folder": null,
  "last_approved_commit_sha": null
}
```

**Iteration Tracking Fields**:
- `iteration`: Current iteration number (1, 2, 3, etc.)
- `current_iteration_folder`: Current working folder (e.g., `iteration-001`, `iteration-002`)
- `last_approved_folder`: Last human-approved iteration folder (e.g., `iteration-003`)
- `last_approved_commit_sha`: Git commit SHA of last approved state (for Codespace restart resume)

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
  "current_iteration_folder": "iteration-001",
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
        "current_iteration_folder": "iteration-001",
        "asset_dir": "assets/generated/iteration-001",
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
3. **Track iteration folders**: Update `current_iteration_folder` (e.g., `iteration-001`, `iteration-002`) as iterations progress
4. **Log human decisions** (`yes`/`no`) in iteration history for audit trail
5. **Store commit SHAs** after pushing approved iterations to track repository state
6. **On human "yes" decision**: 
   - Mark iteration as `final: true`
   - **Asset Cleanup**: Delete all older iteration folders (e.g., `assets/generated/iteration-001/` to `assets/generated/iteration-[N-1]/`)
   - **Keep Only Latest**: Update `last_approved_folder` with the approved iteration folder name (e.g., `iteration-003`)
   - **Git Commit**: Store `last_approved_commit_sha` of the final approved state
   - Optionally copy or rename approved folder to `assets/generated/current/`
   - Delete previous iteration folders (keep only latest approved assets)
7. **On Codespace restart**: 
   - Read this file to determine current iteration and step
   - Load `current_iteration_folder`, `last_approved_folder`, and `last_approved_commit_sha`
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

1. **Folder Structure**: Store binary assets in `assets/generated/iteration-[N]/` (e.g., `iteration-001/`, `iteration-002/`, `iteration-003/`)
2. **Storage Location**: All generated binary assets (textures, models, particles, animations, Godot scenes, etc.) go in the current iteration folder
3. **No Git LFS**: Store files directly in repository without LFS tracking
4. **Workspace-Relative Paths**: Use paths relative to workspace root (no hardcoded paths outside `assets/generated/`)
5. **Organization within iteration folder**:
   ```
   assets/generated/iteration-001/
     symbols/
     textures/
     particles/
     animations/
     scenes/
   ```
6. **Version Control Flow**:
   - Each iteration gets its own numbered folder
   - Track current iteration number in `current_state.current_iteration_folder`
   - On human "yes" decision:
     - Delete all older iteration folders (e.g., `iteration-001` to `iteration-[N-1]`)
     - Keep only the latest approved iteration folder
     - Update `last_approved_folder` with approved folder name
     - Optionally copy or rename to `assets/generated/current/` if desired
     - Commit and push only latest approved assets + Godot code + spreadsheet
     - Store commit SHA in `last_approved_commit_sha`
7. **Restart Resume**: On Codespace restart, read `current_iteration_folder`, `last_approved_folder`, and `last_approved_commit_sha` to resume work

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
3. **Load tracking fields**:
   - `current_iteration_folder` (e.g., `iteration-001`, `iteration-002`)
   - `last_approved_folder` (e.g., `iteration-003` if previously approved)
   - `last_approved_commit_sha` (Git SHA of last approved state)
4. **Load last completed checkpoint data** from `active_checkpoints` or `iteration_history`
5. **Resume execution**:
   - If mid-step: Continue that step from where it left off
   - If between steps: Start the next step
   - If waiting for human feedback: Check Telegram for response
6. **Send Telegram status update** indicating resume and next planned action
7. **Continue 9-step loop** until human approval or blocker

---

## Example Usage

### Starting Fresh
```json
{
  "iteration": 1,
  "step": 1,
  "status": "in_progress",
  "timestamp": "2026-02-06T03:00:00Z",
  "human_decision": null,
  "current_iteration_folder": "iteration-001",
  "last_approved_folder": null,
  "last_approved_commit_sha": null
}
```

### Mid-Iteration
```json
{
  "iteration": 1,
  "step": 5,
  "status": "in_progress",
  "timestamp": "2026-02-06T04:45:00Z",
  "human_decision": null,
  "current_iteration_folder": "iteration-001",
  "last_approved_folder": null,
  "last_approved_commit_sha": null
}
```

### Waiting for Human Feedback
```json
{
  "iteration": 1,
  "step": 9,
  "status": "awaiting_human_decision",
  "timestamp": "2026-02-06T05:30:00Z",
  "human_decision": "pending",
  "current_iteration_folder": "iteration-001",
  "last_approved_folder": null,
  "last_approved_commit_sha": null
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
  "current_iteration_folder": "iteration-001",
  "last_approved_folder": "iteration-001",
  "last_approved_commit_sha": "abc123def456..."
}
```

### Starting Next Iteration (After "No") - Restarts at Step 2

**Note**: Step 2 is correct because Step 1 (web search) is only performed once at the beginning. When the human says "no", the loop restarts at Step 2.

```json
{
  "iteration": 2,
  "step": 2,
  "status": "in_progress",
  "timestamp": "2026-02-06T06:15:00Z",
  "human_decision": null,
  "current_iteration_folder": "iteration-002",
  "last_approved_folder": null,
  "last_approved_commit_sha": null
}
```
