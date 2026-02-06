# GOAL.md

## Primary Goal

Reverse-engineer Las Vegas slot machines (like CLEOPATRA SLOTS) from YouTube videos through a fully autonomous 9-step iterative loop. Generate original assets matching the look and feel, create Godot 4.6 implementations, deploy test versions, and iterate based on human feedback until approved.

**Key Rules:**
- Store binary assets in `assets/generated/iteration-[N]/` (e.g., `iteration-001/`, `iteration-002/`)
- Keep only the latest approved iteration's assets (delete older iteration folders on "yes")
- On human "yes": delete `iteration-001/` to `iteration-[N-1]/`, keep only latest, optionally rename to `current/`
- Commit and push only latest approved assets + Godot code + spreadsheet (no Git LFS)
- Use MEMORY.md to track current iteration number, last approved folder, and last commit SHA
- Use Excel (pandas + openpyxl) with CSV fallback if needed
- Use chain-of-thought reasoning for all decisions
- Send Telegram progress updates and wait for human "yes"/"no" after each iteration
- Save checkpoint data in MEMORY.md (iteration number, status, commit SHA, decision)

## The 9-Step Autonomous Loop

### Step 1: Web Search for YouTube Videos

**Objective**: Find 5 high-quality videos of target Las Vegas slot machines from real casinos

**Actions**:
- Attempt web_search with Brave using `BRAVE_API_KEY`
- If Brave fails (429, 401, timeout, invalid key, or any error), retry with Tavily using `TAVILY_API_KEY`
- If both fail, send Telegram: "Both Brave and Tavily search tools failed. Brave error: [error message]. Tavily error: [error message]. Please configure a working search API key or provide manual input."
- Search terms: "CLEOPATRA slots Las Vegas", "real casino slot machine gameplay", etc.
- Evaluate video quality criteria:
  - Clear reel visibility
  - Multiple spin sequences
  - Bonus feature demonstrations
  - Good audio/visual quality
  - Complete game rounds
  - Real casino footage (not mobile apps)
- Build shortlist of 5 top videos from real Las Vegas casinos

**Output**: 
- 5 video URLs saved in MEMORY.md
- Quality assessment notes
- Selected primary video for analysis

**Checkpoint**: Update MEMORY.md with `step: 1, status: complete`

---

### Step 2: Video Analysis (Frame-by-Frame)

**Objective**: Reverse engineer complete game mechanics: reel size, symbols (wilds/scatters/premiums/lows), base mechanics, bonuses, paylines, etc.

**Actions**:
- Use browser automation to navigate to selected YouTube video
- Capture screenshots at key timestamps:
  - Base game spinning
  - Win states showing paylines
  - Bonus trigger sequences
  - Special feature activations
  - UI elements and paytable screens
- Use Kimi vision to analyze each frame and reverse engineer:
  - Reel configuration (columns x rows)
  - Symbol inventory with types: wilds, scatters, premiums, lows
  - Payline patterns and count
  - Base game mechanics
  - Bonus feature mechanics
  - Color palette and visual style
  - Animation patterns and timing
  - Win celebration effects
  - UI/UX layout

**Output**: 
- Comprehensive analysis document in MEMORY.md
- Screenshot references with timestamps
- Detailed notes on game mechanics, symbols, and features

**Checkpoint**: Update MEMORY.md with `step: 2, status: complete`

---

### Step 3: Spreadsheet Creation (Excel with pandas + openpyxl)

**Objective**: Create local Excel spreadsheet (or CSV fallback) with iteration log, math model, symbol analysis, checkpoints

**Actions**:
- Use pandas with openpyxl engine to create Excel `.xlsx` file
- Create sheets/tabs:
  - **iteration_log**: Track all steps, timestamps, decisions, status updates
  - **math_model**: Paytable, RTP calculations, symbol weights, payout structure
  - **symbol_analysis**: Name, description, type (wild/scatter/premium/low), visual attributes, frequency
  - **checkpoints**: Snapshot of progress for each step with status and data
- Link to video timestamps for reference
- File naming: `iteration_{N}_analysis.xlsx`
- Storage: `/iterations/iteration_{N}/iteration_{N}_analysis.xlsx`
- **CSV Fallback**: If openpyxl fails, generate separate CSV files for each sheet and log fallback in MEMORY.md

**Output**: 
- Excel spreadsheet path saved in MEMORY.md (or CSV file paths)
- Complete asset inventory ready for generation

**Checkpoint**: Update MEMORY.md with `step: 3, status: complete`

---

### Step 4: Asset Generation (Original Assets Matching Look & Feel)

**Objective**: Generate original assets (textures, models, particles, animations) that match look & feel — NEVER copy originals

**Actions**:
- Use meshy-ai or other generation tools to create original assets:
  - **3D Models**: Reel symbols, UI elements, background objects
  - **Textures**: Match color scheme and visual style
  - **Particle Effects**: Win celebrations, sparkles, coin bursts
  - **Animations**: Reel spins, symbol animations, win sequences
- **Critical Rule**: Generate originals that capture aesthetic essence
  - Never copy existing assets
  - Match look and feel, not exact replication
  - Create variations that honor the style
- **Asset Storage Rules**:
  - Store all generated binary assets in `assets/generated/iteration-[current iteration number]/` (e.g., `iteration-001/`, `iteration-002/`, `iteration-003/`)
  - Use workspace-relative paths (no hardcoded paths outside of `assets/generated/`)
  - Organize within iteration folder: `assets/generated/iteration-[N]/symbols/`, `assets/generated/iteration-[N]/textures/`, etc.
  - Store binary assets directly in repo (no Git LFS)
- **Asset Cleanup on Human "Yes"**:
  - When human approves with "yes", delete all older iteration folders (e.g., `iteration-001/` to `iteration-[N-1]/`)
  - Keep only the latest approved iteration folder
  - Optionally copy or rename to `assets/generated/current/` if desired
  - Commit and push only latest approved assets + Godot code + spreadsheet to GitHub
- Document asset metadata (file paths, descriptions)

**Output**: 
- Generated asset files (GLB, PNG, FBX, etc.)
- Asset manifest in MEMORY.md with file paths and iteration number
- Assets stored in `assets/generated/iteration-[N]/` subdirectories

**Checkpoint**: Update MEMORY.md with `step: 4, status: complete`

---

### Step 5: Code Generation (Godot 4.6 GDScript)

**Objective**: Implement complete slot machine in Godot

**Actions**:
- Create Godot 4.6 project structure
- Write GDScript code for:
  - **Reel Controller**: Spin mechanics, stop timing, symbol selection
  - **Win Calculator**: Payline checking, win evaluation, payout logic
  - **Animation Manager**: Symbol animations, win celebrations
  - **UI Controller**: Buttons, bet controls, balance display, info screens
  - **Game State Machine**: Base game, bonus game, free spins
  - **Audio Manager**: Sound effect triggers (placeholder or simple implementation)
- Import generated assets from Step 4
- Configure scenes and resources
- Test locally to ensure basic functionality

**Output**: 
- Complete Godot project in repository
- Main game scene ready to export
- Code location saved in MEMORY.md

**Checkpoint**: Update MEMORY.md with `step: 5, status: complete`

---

### Step 6: Deploy Test Version (Public URL via GitHub Pages / Vercel)

**Objective**: Create test harness with publicly accessible URL (GitHub Pages / Vercel via gh CLI)

**Actions**:
- Export Godot project to HTML5/WebAssembly
- Choose deployment platform:
  - **GitHub Pages**: Use gh CLI to push to gh-pages branch
  - **Vercel**: Use Vercel CLI or API to deploy
- Generate public HTTPS URL for the test harness
- Verify deployment loads and runs correctly
- Test basic functionality (spin button, reels, wins)

**Output**: 
- Public test harness URL saved in MEMORY.md
- Deployment status and platform notes

**Checkpoint**: Update MEMORY.md with `step: 6, status: complete`

---

### Step 7: Record Test Video

**Objective**: Video record the test harness output for comparison

**Actions**:
- Use browser automation to navigate to deployed URL
- Record 30-60 seconds of gameplay:
  - Multiple spins
  - Win sequences
  - Bonus triggers (if implemented)
  - UI interactions
- Recording methods:
  - Browser automation with screen recording
  - FFmpeg screen capture
  - Playwright screenshot sequence -> video
- Save video file to `/iterations/iteration_{N}/videos/`

**Output**: 
- Video file path saved in MEMORY.md
- Gameplay recording ready for comparison

**Checkpoint**: Update MEMORY.md with `step: 7, status: complete`

---

### Step 8: Compare Videos (Visual Comparison to Original)

**Objective**: Compare visually to original YouTube video using Kimi vision

**Actions**:
- Use Kimi vision to analyze both videos:
  - **Visual Similarity**: Color scheme, symbol design, UI layout
  - **Animation Quality**: Smoothness, timing, feel
  - **Feature Completeness**: All mechanics present
  - **Aesthetic Match**: Overall look and feel alignment
- Generate comparison report with:
  - Strengths (what matches well)
  - Gaps (what's missing or different)
  - Quality score or assessment
  - Specific improvement suggestions
- Use chain-of-thought reasoning to explain assessment

**Output**: 
- Comparison analysis saved in MEMORY.md
- Quality assessment and improvement notes

**Checkpoint**: Update MEMORY.md with `step: 8, status: complete`

---

### Step 9: Human Feedback Loop

**Objective**: Get Ron's "yes"/"no" decision; loop steps 2-7 until human approves with "yes"

**Actions**:
- Send Telegram message to Ron with comprehensive summary:

```
Iteration <number> complete.

Summary:
- Original video: <YouTube URL>
- Assets generated: <count> symbols, <count> animations, <count> effects
- Godot implementation: <feature list>
- Comparison assessment: <brief quality notes>

Test URL: <deployed URL>
Comparison video: <URL if available>

Quality highlights:
- <strength 1>
- <strength 2>

Areas for improvement:
- <gap 1>
- <gap 2>

Is it good enough? Reply 'yes' or 'no' to stop or continue iterations.
```

- Wait for Ron's response
- Update MEMORY.md with human decision:
  - If 'yes': Set `human_decision: approved`, mark iteration as final
    - **Asset Cleanup**: Delete all older iteration folders (e.g., `assets/generated/iteration-001/` to `assets/generated/iteration-[N-1]/`)
    - **Keep Only Latest**: Keep only the latest approved iteration folder (optionally copy or rename to `assets/generated/current/`)
    - **Git Commit**: Push only the latest approved assets, Godot code, and spreadsheet to GitHub repo (no Git LFS)
    - **Save State**: Update MEMORY.md with last approved folder name and commit SHA for Codespace restart resume
    - Stop autonomous loop
  - If 'no': Set `human_decision: iterate`, increment iteration counter, restart loop at Step 2

**Output**: 
- Ron's decision saved in MEMORY.md
- Loop control state updated
- On "yes": Old iteration folders deleted, latest assets committed with SHA saved

**Checkpoint**: Update MEMORY.md with `step: 9, status: complete, human_decision: <yes/no>`

---

## Loop Control Logic

### Iteration Flow

1. Start at `iteration: 1, step: 1`
2. Execute steps 1-9 sequentially
3. After Step 9, wait for human feedback
4. **If Ron says 'yes'**:
   - Mark as `final: true` in MEMORY.md
   - **Asset Cleanup**: Delete all older iteration folders (e.g., `assets/generated/iteration-001/` to `assets/generated/iteration-[N-1]/`)
   - **Keep Only Latest**: Keep only the latest approved iteration folder (optionally copy or rename to `assets/generated/current/`)
   - **Git Commit**: Push only the latest approved assets, Godot code, and spreadsheet to GitHub repo (no Git LFS)
   - **Save State**: Update MEMORY.md with last approved folder name and commit SHA for Codespace restart resume
   - Stop autonomous loop
   - Send final confirmation to Ron
5. **If Ron says 'no'**:
   - Increment to next iteration number
   - Reset to `step: 2` (loop steps 2-7, not step 1)
   - Continue loop with improvements based on feedback
6. Repeat until approved

### Checkpoint Resilience

- Save checkpoint after each step completion
- If process restarts, load MEMORY.md
- Resume from last completed step
- Maintain iteration and step counters
- Preserve all accumulated data

### Heartbeat Integration

- Every 30 minutes, check current state
- Execute next step based on MEMORY.md
- Send progress update to Telegram
- Update checkpoints continuously

## Chain-of-Thought Requirement

**All steps must use chain-of-thought reasoning:**
- Start complex analyses with "Let's think step by step"
- Show observations before conclusions
- Explain decision-making process
- Document reasoning in MEMORY.md
- Make thought process transparent to Ron

## Success Criteria

✅ Complete all 9 steps for each iteration
✅ Generate original assets (never copy)
✅ Create functional Godot implementation
✅ Deploy with public URL for testing
✅ Compare videos with AI vision analysis
✅ Send clear feedback request to Ron
✅ Loop continues until Ron approves with 'yes'
✅ Maintain checkpoint resilience throughout
✅ Use chain-of-thought reasoning consistently
