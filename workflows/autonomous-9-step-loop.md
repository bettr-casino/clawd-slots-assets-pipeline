# Autonomous 9-Step Reverse-Engineering Loop

## Overview

This is the primary autonomous workflow that Clawd executes to reverse-engineer Las Vegas slot machines from YouTube videos. The workflow operates in a continuous loop, generating original assets, implementing games in Godot 4.6, and iterating based on human feedback until approved.

**Key Principles:**
- **Autonomy**: Execute all 9 steps with minimal human intervention
- **Originality**: Generate assets matching look/feel, never copy existing assets
- **Resilience**: Checkpoint progress after each step for restart capability
- **Transparency**: Use chain-of-thought reasoning for all decisions
- **Iteration**: Loop through steps 2-7 until human approves with 'yes'

## The 9-Step Loop

### Step 1: Web Search for YouTube Videos

**Objective**: Find 5 high-quality videos of target Las Vegas slot machines from real casinos

**Actions**:
- [ ] Use Brave API or web_search to query YouTube
- [ ] Search terms: "[SLOT NAME] Las Vegas", "real casino slot machine gameplay", etc.
- [ ] Evaluate video quality criteria:
  - Clear reel visibility
  - Multiple spin sequences
  - Bonus feature demonstrations
  - Good audio/visual quality
  - Complete game rounds
  - Real casino footage (not mobile apps)
- [ ] Build shortlist of 5 top videos from real Las Vegas casinos
- [ ] Select primary video for detailed analysis

**Output**: 
- 5 video URLs saved in MEMORY.md
- Quality assessment notes
- Selected primary video for analysis

**Checkpoint**: Update MEMORY.md with `step: 1, status: complete`

**Chain-of-Thought**: Document reasoning for video selection in MEMORY.md

---

### Step 2: Video Analysis (Frame-by-Frame)

**Objective**: Reverse engineer complete game mechanics: reel size, symbols (wilds/scatters/premiums/lows), base mechanics, bonuses, paylines, etc.

**Actions**:
- [ ] Use browser automation to navigate to selected YouTube video
- [ ] Capture screenshots at key timestamps:
  - Base game spinning
  - Win states showing paylines
  - Bonus trigger sequences
  - Special feature activations
  - UI elements and paytable screens
- [ ] Use Kimi K-2.5 vision to analyze each frame and reverse engineer:
  - **Reel configuration** (columns x rows, e.g., 5x3)
  - **Symbol inventory** with types:
    - Wilds (substitution symbols)
    - Scatters (bonus triggers)
    - Premiums (high-value themed symbols)
    - Lows (card ranks: A, K, Q, J, 10, 9)
  - **Payline patterns** and count
  - **Base game mechanics** (win evaluation, multipliers)
  - **Bonus feature mechanics** (free spins, pick bonuses, jackpots)
  - **Color palette** and visual style
  - **Animation patterns** and timing
  - **Win celebration effects**
  - **UI/UX layout** and controls
- [ ] Use chain-of-thought reasoning to explain observations

**Output**: 
- Comprehensive analysis document in MEMORY.md
- Screenshot references with timestamps
- Detailed notes on game mechanics, symbols, and features

**Checkpoint**: Update MEMORY.md with `step: 2, status: complete`

**Chain-of-Thought**: Start with "Let's think step by step" and document analysis reasoning

---

### Step 3: Spreadsheet Creation (Excel with pandas + openpyxl)

**Objective**: Create local Excel spreadsheet (or CSV fallback) with iteration log, math model, symbol analysis, checkpoints

**Actions**:
- [ ] Use pandas with openpyxl engine to create Excel `.xlsx` file
- [ ] Create sheets/tabs:
  - **iteration_log**: Track all steps, timestamps, decisions, status updates
  - **math_model**: Paytable, RTP calculations, symbol weights, payout structure
  - **symbol_analysis**: Name, description, type (wild/scatter/premium/low), visual attributes, frequency
  - **checkpoints**: Snapshot of progress for each step with status and data
- [ ] Link to video timestamps for reference
- [ ] File naming: `iteration_{N}_analysis.xlsx`
- [ ] Storage: `/iterations/iteration_{N}/iteration_{N}_analysis.xlsx`
- [ ] **CSV Fallback**: If openpyxl fails, generate separate CSV files for each sheet and log fallback in MEMORY.md

**Output**: 
- Excel spreadsheet path saved in MEMORY.md (or CSV file paths)
- Complete asset inventory ready for generation

**Checkpoint**: Update MEMORY.md with `step: 3, status: complete`

**Chain-of-Thought**: Document spreadsheet structure and data organization decisions

---

### Step 4: Asset Generation (Original Assets Matching Look & Feel)

**Objective**: Generate original assets (textures, models, particles, animations) that match look & feel — NEVER copy originals

**Actions**:
- [ ] Use meshy-ai or other generation tools to create original assets:
  - **3D Models**: Reel symbols, UI elements, background objects
  - **Textures**: Match color scheme and visual style
  - **Particle Effects**: Win celebrations, sparkles, coin bursts
  - **Animations**: Reel spins, symbol animations, win sequences
- [ ] **Critical Rule**: Generate originals that capture aesthetic essence
  - Never copy existing assets
  - Match look and feel, not exact replication
  - Create variations that honor the style
- [ ] Save all generated assets to organized directory: `/iterations/iteration_{N}/assets/`
- [ ] Document asset metadata (file paths, descriptions)
- [ ] **Storage**: Store binary assets directly in repo without Git LFS
- [ ] Use chain-of-thought to explain generation choices

**Output**: 
- Generated asset files (GLB, PNG, FBX, etc.)
- Asset manifest in MEMORY.md with file paths
- Assets stored in `/iterations/iteration_{N}/assets/` subdirectories

**Checkpoint**: Update MEMORY.md with `step: 4, status: complete`

**Chain-of-Thought**: Document asset generation approach and design decisions

---

### Step 5: Code Generation (Godot 4.6 GDScript)

**Objective**: Implement complete slot machine in Godot 4.6 with GDScript

**Actions**:
- [ ] Create Godot 4.6 project structure
- [ ] Write GDScript code for:
  - **Reel Controller**: Spin mechanics, stop timing, symbol selection
  - **Win Calculator**: Payline checking, win evaluation, payout logic
  - **Animation Manager**: Symbol animations, win celebrations
  - **UI Controller**: Buttons, bet controls, balance display, info screens
  - **Game State Machine**: Base game, bonus game, free spins
  - **Audio Manager**: Sound effect triggers (placeholder or simple implementation)
- [ ] Import generated assets from Step 4
- [ ] Configure scenes and resources
- [ ] Test locally to ensure basic functionality
- [ ] Use chain-of-thought to explain implementation choices

**Output**: 
- Complete Godot project in repository
- Main game scene ready to export
- Code location saved in MEMORY.md

**Checkpoint**: Update MEMORY.md with `step: 5, status: complete`

**Chain-of-Thought**: Document code architecture and implementation decisions

---

### Step 6: Deploy Test Version (Public URL via GitHub Pages / Vercel)

**Objective**: Create test harness with publicly accessible URL (GitHub Pages / Vercel via gh CLI)

**Actions**:
- [ ] Export Godot project to HTML5/WebAssembly
- [ ] Choose deployment platform:
  - **GitHub Pages**: Use gh CLI to push to gh-pages branch
  - **Vercel**: Use Vercel CLI or API to deploy
- [ ] Generate public HTTPS URL for the test harness
- [ ] Verify deployment loads and runs correctly
- [ ] Test basic functionality (spin button, reels, wins)
- [ ] Use chain-of-thought to explain deployment choices

**Output**: 
- Public test harness URL saved in MEMORY.md
- Deployment status and platform notes

**Checkpoint**: Update MEMORY.md with `step: 6, status: complete`

**Chain-of-Thought**: Document deployment process and validation steps

---

### Step 7: Record Test Video

**Objective**: Video record the test harness output for comparison

**Actions**:
- [ ] Use browser automation to navigate to deployed URL
- [ ] Record 30-60 seconds of gameplay:
  - Multiple spins
  - Win sequences
  - Bonus triggers (if implemented)
  - UI interactions
- [ ] Recording methods:
  - Browser automation with screen recording
  - FFmpeg screen capture
  - Playwright screenshot sequence → video
- [ ] Save video file to `/iterations/iteration_{N}/videos/`
- [ ] Use chain-of-thought to explain recording approach

**Output**: 
- Video file path saved in MEMORY.md
- Gameplay recording ready for comparison

**Checkpoint**: Update MEMORY.md with `step: 7, status: complete`

**Chain-of-Thought**: Document video recording process

---

### Step 8: Compare Videos (Visual Comparison to Original)

**Objective**: Compare visually to original YouTube video using Kimi K-2.5 vision

**Actions**:
- [ ] Use Kimi K-2.5 vision to analyze both videos:
  - **Visual Similarity**: Color scheme, symbol design, UI layout
  - **Animation Quality**: Smoothness, timing, feel
  - **Feature Completeness**: All mechanics present
  - **Aesthetic Match**: Overall look and feel alignment
- [ ] Generate comparison report with:
  - Strengths (what matches well)
  - Gaps (what's missing or different)
  - Quality score or assessment
  - Specific improvement suggestions
- [ ] Use chain-of-thought reasoning to explain assessment
- [ ] Document findings in MEMORY.md

**Output**: 
- Comparison analysis saved in MEMORY.md
- Quality assessment and improvement notes

**Checkpoint**: Update MEMORY.md with `step: 8, status: complete`

**Chain-of-Thought**: Start with "Let's think step by step" and document comparison reasoning

---

### Step 9: Human Feedback Loop

**Objective**: Get Ron's "yes"/"no" decision; loop steps 2-7 until human approves with "yes"

**Actions**:
- [ ] Send Telegram message to Ron with comprehensive summary:

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

- [ ] Wait for Ron's response
- [ ] Update MEMORY.md with human decision:
  - **If 'yes'**: Set `human_decision: approved`, mark iteration as final
    - Push only the latest approved assets, Godot code, and spreadsheet to GitHub repo
    - Delete older iteration folders (keep only the approved iteration)
    - Save commit SHA in MEMORY.md
    - Stop autonomous loop
  - **If 'no'**: Set `human_decision: iterate`, increment iteration counter, restart loop at Step 2
- [ ] Use chain-of-thought to summarize feedback

**Output**: 
- Ron's decision saved in MEMORY.md
- Loop control state updated
- On "yes": Old iteration folders deleted, latest assets committed

**Checkpoint**: Update MEMORY.md with `step: 9, status: complete, human_decision: <yes/no>`

**Chain-of-Thought**: Document human feedback and next actions

---

## Loop Control Logic

### Iteration Flow

1. Start at `iteration: 1, step: 1`
2. Execute steps 1-9 sequentially
3. After Step 9, wait for human feedback
4. **If Ron says 'yes'**:
   - Mark as `final: true` in MEMORY.md
   - Push only the latest approved assets, Godot code, and spreadsheet to GitHub repo
   - Delete older iteration folders (keep only approved iteration)
   - Save commit SHA in MEMORY.md
   - Stop autonomous loop
   - Send final confirmation to Ron via Telegram
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

- Every 30 minutes, check current state from MEMORY.md
- Execute next step based on MEMORY.md
- Send progress update to Telegram (exactly 2 sentences):
  ```
  Last 30 mins I worked on <step number and brief description>.
  Next 30 mins I am working on <next step number and plan>.
  ```
- Update checkpoints continuously

## Chain-of-Thought Requirement

**All steps must use chain-of-thought reasoning:**
- Start complex analyses with "Let's think step by step"
- Show observations before conclusions
- Explain decision-making process
- Document reasoning in MEMORY.md
- Make thought process transparent to Ron

## Asset Storage and Management

### Binary Asset Storage Rules

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

### Originality Requirement

- **Never copy existing assets directly**
- **Always generate originals** that capture the aesthetic essence
- **Match look and feel**, not exact replication
- **Create variations** that honor the original style
- Use chain-of-thought to explain design decisions

## Success Criteria

✅ Complete all 9 steps for each iteration
✅ Generate original assets (never copy)
✅ Create functional Godot 4.6 implementation
✅ Deploy with public URL for testing
✅ Compare videos with AI vision analysis
✅ Send clear feedback request to Ron via Telegram
✅ Loop continues until Ron approves with 'yes'
✅ Maintain checkpoint resilience throughout
✅ Use chain-of-thought reasoning consistently
✅ Store binary assets directly in repo (no Git LFS)
✅ Use Excel (pandas + openpyxl) with CSV fallback for spreadsheets

## Tools Required

- **Web Search**: Brave API for YouTube video discovery
- **Browser Automation**: Playwright for video navigation and screenshots
- **Kimi K-2.5**: AI vision analysis and reasoning
- **pandas + openpyxl**: Excel spreadsheet creation (CSV fallback if needed)
- **Meshy.ai or other generation tools**: 3D asset generation (originals only)
- **Godot 4.6**: Game engine and GDScript implementation
- **gh CLI or Vercel**: Deployment platforms for public URLs
- **FFmpeg**: Video recording and processing
- **Telegram**: Communication with Ron (progress updates and feedback)

## Related Documentation

- See `/constitution/GOAL.md` for detailed 9-step loop definition
- See `/constitution/HEARTBEAT.md` for 30-minute cycle execution
- See `/constitution/MEMORY.md` for checkpoint state format
- See `/constitution/SKILLS.md` for tool-specific capabilities
- See `/constitution/AGENTS.md` for agent capabilities overview
