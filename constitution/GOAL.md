# GOAL.md

## Primary Goal

Reverse-engineer Las Vegas slot machines (like CLEOPATRA SLOTS) from YouTube videos through a fully autonomous 9-step iterative loop. Generate original assets matching the look and feel, create Godot 4.6 implementations, deploy test versions, and iterate based on human feedback until approved.

## The 9-Step Autonomous Loop

### Step 1: Web Search for YouTube Videos

**Objective**: Find high-quality videos of target Las Vegas slot machines

**Actions**:
- Use Brave API or web_search to query YouTube
- Search terms: "CLEOPATRA slots Las Vegas", "real casino slot machine gameplay", etc.
- Evaluate video quality criteria:
  - Clear reel visibility
  - Multiple spin sequences
  - Bonus feature demonstrations
  - Good audio/visual quality
  - Complete game rounds
  - Real casino footage (not mobile apps)
- Build shortlist of 3-5 top videos

**Output**: 
- Video URLs saved in MEMORY.md
- Quality assessment notes
- Selected primary video for analysis

**Checkpoint**: Update MEMORY.md with `step: 1, status: complete`

---

### Step 2: Video Analysis (Frame-by-Frame)

**Objective**: Extract complete game mechanics and visual design from video

**Actions**:
- Use browser automation to navigate to selected YouTube video
- Capture screenshots at key timestamps:
  - Base game spinning
  - Win states showing paylines
  - Bonus trigger sequences
  - Special feature activations
  - UI elements and paytable screens
- Use Kimi vision to analyze each frame:
  - Reel configuration (columns x rows)
  - Symbol inventory (count and descriptions)
  - Color palette and visual style
  - Animation patterns and timing
  - Win celebration effects
  - UI/UX layout
  - Bonus mechanics

**Output**: 
- Comprehensive analysis document in MEMORY.md
- Screenshot references with timestamps
- Detailed notes on game mechanics

**Checkpoint**: Update MEMORY.md with `step: 2, status: complete`

---

### Step 3: Asset List Creation (Google Sheets)

**Objective**: Create structured inventory of all required assets

**Actions**:
- Use Google Sheets API or generate CSV for documentation
- Create sheets/tabs for:
  - **Symbols**: Name, description, visual attributes, frequency
  - **Reels**: Configuration, symbol positions, spin behavior
  - **Animations**: Type, timing, triggers, visual effects
  - **UI Elements**: Buttons, displays, paytable, info screens
  - **Audio**: Sound effects needed (note: may be implemented later)
  - **Colors**: Palette with hex codes
- Link to video timestamps for reference

**Output**: 
- Google Sheet URL saved in MEMORY.md (or CSV file)
- Complete asset inventory ready for generation

**Checkpoint**: Update MEMORY.md with `step: 3, status: complete`

---

### Step 4: Asset Generation (Meshy-ai)

**Objective**: Generate original 3D assets matching look and feel

**Actions**:
- Use meshy-ai to create original assets:
  - **3D Models**: Reel symbols, UI elements, background objects
  - **Textures**: Match color scheme and visual style
  - **Particle Effects**: Win celebrations, sparkles, coin bursts
  - **Animations**: Reel spins, symbol animations, win sequences
- **Critical Rule**: Generate originals that capture aesthetic essence
  - Never copy existing assets
  - Match look and feel, not exact replication
  - Create variations that honor the style
- Save all generated assets to organized directory
- Document asset metadata (file paths, descriptions)

**Output**: 
- Generated asset files (GLB, PNG, FBX, etc.)
- Asset manifest in MEMORY.md with file paths
- Preview images or thumbnails

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

### Step 6: Deploy Test Version (Public URL)

**Objective**: Create publicly accessible test deployment

**Actions**:
- Export Godot project to HTML5/WebAssembly
- Choose deployment platform:
  - **GitHub Pages**: Use gh CLI to push to gh-pages branch
  - **Vercel**: Use Vercel CLI or API to deploy
- Generate public HTTPS URL
- Verify deployment loads and runs correctly
- Test basic functionality (spin button, reels, wins)

**Output**: 
- Public URL saved in MEMORY.md
- Deployment status and platform notes

**Checkpoint**: Update MEMORY.md with `step: 6, status: complete`

---

### Step 7: Record Test Video

**Objective**: Capture gameplay video of generated slot machine

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
- Save video file or upload to accessible location

**Output**: 
- Video file path or URL in MEMORY.md
- Gameplay recording ready for comparison

**Checkpoint**: Update MEMORY.md with `step: 7, status: complete`

---

### Step 8: Compare Videos (Kimi Vision)

**Objective**: Assess quality match between generated and original

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

**Objective**: Get Ron's decision on iteration quality

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
  - If 'no': Set `human_decision: iterate`, increment iteration counter, reset to Step 1

**Output**: 
- Ron's decision saved in MEMORY.md
- Loop control state updated

**Checkpoint**: Update MEMORY.md with `step: 9, status: complete, human_decision: <yes/no>`

---

## Loop Control Logic

### Iteration Flow

1. Start at `iteration: 1, step: 1`
2. Execute steps 1-9 sequentially
3. After Step 9, wait for human feedback
4. **If Ron says 'yes'**:
   - Mark as `final: true` in MEMORY.md
   - Stop autonomous loop
   - Send final confirmation to Ron
5. **If Ron says 'no'**:
   - Increment to `iteration: 2`
   - Reset to `step: 1`
   - Continue loop with improvements
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
