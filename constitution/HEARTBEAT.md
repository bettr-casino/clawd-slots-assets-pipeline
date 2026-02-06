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
- Build shortlist of high-quality videos
- Save video URLs and metadata to MEMORY.md

**Step 2: Video Analysis**
- Use browser automation to navigate to selected video
- Capture screenshots at key timestamps
- Use Kimi vision to analyze frames
- Identify reels, symbols, colors, animations, UI elements
- Document findings in MEMORY.md

**Step 3: Asset List Creation**
- Create comprehensive inventory from video analysis
- Use Google Sheets API or CSV to document:
  - Reel configuration (columns, rows, symbols)
  - Symbol list with descriptions
  - Color palette
  - Animation types
  - UI elements
- Link Google Sheet in MEMORY.md

**Step 4: Asset Generation**
- Use meshy-ai to generate original assets:
  - 3D models matching aesthetic
  - Textures matching style
  - Particle effects for wins
  - Animations for reels and symbols
- **Critical**: Generate originals, never copy
- Save asset references in MEMORY.md

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
- Generate public HTTPS URL
- Save deployment URL in MEMORY.md

**Step 7: Record Test Video**
- Use browser automation to access deployed URL
- Record 30-60 seconds of gameplay
- Use ffmpeg or browser recording
- Save video file or upload link
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
4. If Ron replies 'yes': STOP loop, mark as final
5. If Ron replies 'no': Increment iteration, restart at Step 1
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
