# HEARTBEAT.md

## Chain-of-Thought Reasoning

**Always use detailed chain-of-thought reasoning.** Start complex steps with "Let's think step by step" and show every logical step before final conclusions.

For all decisions and analysis:
- State what you observe
- Explain your reasoning at each step
- Show intermediate conclusions
- Build toward final insights systematically
- Make thought process transparent to Ron

## Heartbeat Cycle (Every 30 Minutes)

### Initialization

1. Load GOAL.md to understand the 9-step autonomous loop
2. Load MEMORY.md to retrieve:
   - Current iteration number
   - Current step (1-9)
   - Last checkpoint state
   - Human feedback decision status
   - Any blockers or pending actions
3. Determine next action based on current state

### Execution

Execute the appropriate step based on MEMORY.md state:

**Step 1: Web Search**
- Use Brave API or web_search to find YouTube videos
- Focus on Las Vegas slot machines (e.g., CLEOPATRA)
- Find 5 high-quality videos from real casinos
- Save video URLs and metadata to MEMORY.md

**Step 2: Video Analysis**
- Use browser automation to navigate to selected video
- Capture screenshots at key timestamps
- Use Kimi vision to analyze frames
- Reverse engineer: reels, symbols (wilds/scatters/premiums/lows), colors, animations, UI elements, base mechanics, bonuses, paylines
- Document findings in MEMORY.md

**Step 3: Spreadsheet Creation**
- Create Excel file using pandas + openpyxl (`.xlsx`)
- Create sheets: iteration_log, math_model, symbol_analysis, checkpoints
- If openpyxl fails, fall back to CSV files
- Document:
  - Reel configuration (columns, rows, symbols)
  - Symbol list with types and descriptions
  - Math model (paytable, RTP, weights)
  - Color palette
  - Animation types
  - UI elements
- Save spreadsheet path in MEMORY.md
- File location: `/iterations/iteration_{N}/iteration_{N}_analysis.xlsx`

**Step 4: Asset Generation**
- Use meshy-ai or other generation tools to generate original assets:
  - 3D models matching aesthetic
  - Textures matching style
  - Particle effects for wins
  - Animations for reels and symbols
- **Critical**: Generate originals, never copy
- **Asset Storage Rules**:
  - Store all generated binary assets (textures, models, particles, animations, Godot scenes, etc.) in `assets/generated/iteration-[current iteration number]/` (e.g., `iteration-001/`, `iteration-002/`)
  - Use workspace-relative paths (no hardcoded paths outside of `assets/generated/`)
  - Store binary assets directly in repo (no Git LFS)
- Save asset references in MEMORY.md
- Update MEMORY.md with current iteration number

**Step 5: Code Generation**
- Write Godot 4.6 GDScript implementation
- Implement slot machine logic:
  - Reel spinning mechanics
  - Symbol matching and win calculation
  - Animations and transitions
  - UI/UX elements
- Save code to repository
- Update MEMORY.md with code location

**Step 6: Deploy Test Version**
- Export Godot project to HTML5
- Deploy to GitHub Pages or Vercel using gh CLI
- Generate public HTTPS URL for test harness
- Save deployment URL in MEMORY.md

**Step 7: Record Test Video**
- Use browser automation to access deployed URL
- Record 30-60 seconds of gameplay
- Use ffmpeg or browser recording
- Save video file: `/iterations/iteration_{N}/videos/`
- Update MEMORY.md with video location

**Step 8: Compare Videos**
- Use Kimi vision to compare:
  - Generated video vs original video
  - Visual match quality
  - Animation accuracy
  - Overall aesthetic fidelity
- Document comparison results in MEMORY.md

**Step 9: Human Feedback**
- Send Telegram message to Ron with:
  - Iteration number
  - Summary of work completed
  - Test URL link
  - Comparison results
  - Request: "Is it good enough? Reply 'yes' or 'no'"
- Wait for Ron's response
- Update MEMORY.md with human_decision
- If 'yes' (approved iteration):
  - **Asset Cleanup**: Delete all older iteration folders (e.g., `assets/generated/iteration-001/` to `assets/generated/iteration-[N-1]/`)
  - **Keep Only Latest**: Keep only the latest approved iteration folder (optionally copy or rename to `assets/generated/current/` if desired)
  - **Git Commit**: Commit and push only the latest approved assets + Godot code + spreadsheet to GitHub
  - **No Git LFS**: Store binaries directly in repo
  - **Save State**: Update MEMORY.md with last approved folder name and commit SHA
  - **Stop Loop**: Mark as final and stop autonomous loop
- If 'no': Increment iteration, restart at Step 2 (loop steps 2-7)
- Keep chain-of-thought reasoning and Telegram progress updates throughout

### Progress Tracking

After completing each step:
1. Update MEMORY.md with checkpoint
2. Increment step counter (or iteration if step 9 complete)
3. Save all relevant data and links
4. Prepare for next step

### Progress Summary Format

Every 30 minutes, send Telegram update with exactly 2 sentences:

**Format:**
```
Last 30 mins I worked on <step number and brief description>.
Next 30 mins I am working on <next step number and plan>.
```

**Examples:**

```
Last 30 mins I worked on Step 1 (web search) and found 5 high-quality CLEOPATRA videos.
Next 30 mins I am working on Step 2 (video analysis) using browser automation and Kimi vision.
```

```
Last 30 mins I worked on Step 4 (asset generation) creating 12 original symbol models with meshy-ai.
Next 30 mins I am working on Step 5 (code generation) implementing Godot 4.6 GDScript.
```

```
Last 30 mins I worked on Step 9 (human feedback) and sent iteration summary to Ron.
Next 30 mins I am working on waiting for Ron's yes/no decision on iteration 1.
```

### Checkpoint Management

After each step completion:
```json
{
  "iteration": 1,
  "step": 3,
  "timestamp": "2026-02-06T03:00:00Z",
  "checkpoints": [
    {"step": 1, "status": "complete", "data": "video_urls"},
    {"step": 2, "status": "complete", "data": "analysis_results"},
    {"step": 3, "status": "in_progress", "data": "asset_list"}
  ],
  "human_decision": "pending"
}
```

Save this to MEMORY.md for restart resilience.

### Iteration Loop Control

**Decision Flow:**
1. Complete all 9 steps
2. Send iteration summary to Ron
3. Wait for human decision
4. If Ron replies 'yes': 
   - **Asset Cleanup**: Delete all older iteration folders (e.g., `assets/generated/iteration-001/` to `assets/generated/iteration-[N-1]/`)
   - **Keep Only Latest**: Keep only the latest approved iteration folder (optionally copy or rename to `assets/generated/current/`)
   - **Git Commit**: Push latest approved assets, Godot code, and spreadsheet directly to GitHub (no Git LFS)
   - **Save State**: Update MEMORY.md with last approved folder name and commit SHA for Codespace restart resume
   - **Stop Loop**: STOP loop, mark as final
5. If Ron replies 'no': 
   - Increment iteration
   - Restart at Step 2 (loop steps 2-7, not step 1)
6. Update MEMORY.md with decision and new iteration state

**Resilience:**
- If process restarts, check MEMORY.md
- Resume from last completed checkpoint
- Continue from interrupted step
- Maintain iteration and step counters

### Blocker Protocol

If stuck or need clarification:
1. Identify specific blocker
2. Document in MEMORY.md
3. Send Telegram message to Ron with:
   - Current step and context
   - Specific question or issue
   - What can continue in parallel
4. Continue with other aspects if possible
5. Use chain-of-thought to explain reasoning

### State Persistence

After each heartbeat cycle:
- Update MEMORY.md with:
  - Current iteration and step
  - Checkpoint data
  - Progress summary
  - Next planned action
  - Any blockers or pending decisions
- Ensure all data needed for restart is saved
- Maintain clear audit trail of decisions
