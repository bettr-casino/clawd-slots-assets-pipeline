# SKILLS.md

## Required Skills & Tools

This document catalogs all skills and tools required for the autonomous 9-step reverse-engineering workflow.

---

## Step 1: Web Search & Video Discovery

### web_search (Brave API)
- **Purpose**: Search YouTube for Las Vegas slot machine videos
- **Capabilities**:
  - Query YouTube with specific search terms
  - Filter by video quality, duration, view count
  - Retrieve video metadata (title, URL, description, thumbnail)
- **Configuration**: Requires Brave Search API key
- **Usage**: `web_search("CLEOPATRA slots Las Vegas gameplay")`
- **Target**: Find 5 high-quality videos from real Las Vegas casinos

### YouTube API (optional)
- **Purpose**: Get detailed video information
- **Capabilities**:
  - Retrieve video statistics
  - Check video availability
  - Get video duration and upload date
- **Configuration**: Requires YouTube Data API v3 key

---

## Step 2: Video Analysis (Frame-by-Frame)

### browser (Browser Automation)
- **Purpose**: Navigate to YouTube videos and control playback
- **Capabilities**:
  - Open YouTube URLs
  - Play/pause video
  - Seek to specific timestamps
  - Control playback speed
- **Tools**: Playwright, Puppeteer, or similar
- **Usage**: Navigate to video, pause at key frames

### screenshot (Screen Capture)
- **Purpose**: Capture video frames at specific timestamps
- **Capabilities**:
  - Screenshot full browser window or specific elements
  - Save as PNG or JPEG
  - Timestamp and annotate captures
- **Tools**: Browser automation screenshot API
- **Usage**: Capture reel states, win screens, bonus features

### kimi_vision (AI Vision Analysis)
- **Purpose**: Analyze video frames with AI
- **Capabilities**:
  - Identify visual elements (symbols, reels, UI)
  - Extract color palettes
  - Recognize patterns and configurations
  - Describe animations and effects
  - OCR for text elements
  - Reverse engineer: reel size, symbol types (wilds/scatters/premiums/lows), base mechanics, bonuses, paylines
- **Model**: Kimi K-2.5 with vision capabilities
- **Usage**: Analyze each screenshot for game elements and mechanics

### exec (Command Execution)
- **Purpose**: Run ffmpeg or other video tools
- **Capabilities**:
  - Extract frames at intervals
  - Convert video formats
  - Process video files
- **Tools**: ffmpeg, yt-dlp
- **Usage**: `ffmpeg -i video.mp4 -vf fps=1 frame_%04d.png`

---

## Step 3: Spreadsheet Creation (Excel/CSV)

### pandas + openpyxl (Excel Spreadsheet Creation)
- **Purpose**: Create local Excel spreadsheets for iteration tracking and analysis
- **Capabilities**:
  - Create `.xlsx` files with multiple sheets
  - Write structured data to Excel
  - Format cells and organize data
  - Generate sheets: iteration_log, math_model, symbol_analysis, checkpoints
- **Configuration**: Requires pandas and openpyxl Python packages
- **Usage**: 
  ```python
  import pandas as pd
  with pd.ExcelWriter('iteration_1_analysis.xlsx', engine='openpyxl') as writer:
      df_log.to_excel(writer, sheet_name='iteration_log')
      df_math.to_excel(writer, sheet_name='math_model')
      df_symbols.to_excel(writer, sheet_name='symbol_analysis')
      df_checkpoints.to_excel(writer, sheet_name='checkpoints')
  ```
- **File naming**: `iteration_{N}_analysis.xlsx`
- **Storage**: `/iterations/iteration_{N}/iteration_{N}_analysis.xlsx`

### csv_export (CSV Fallback)
- **Purpose**: Create CSV files if Excel generation fails
- **Capabilities**:
  - Write structured data to CSV format
  - Create separate CSV files for each sheet type
  - Import into Excel manually if needed
- **Tools**: Built-in Python csv module or pandas to_csv
- **Usage**: Generate `iteration_log.csv`, `math_model.csv`, `symbol_analysis.csv`, `checkpoints.csv`
- **Fallback rule**: If openpyxl installation/import fails, use CSV and log in MEMORY.md

---

## Step 4: Asset Generation (Original Assets)

### meshy_ai or other generation tools (3D Asset Generation)
- **Purpose**: Generate original 3D assets matching slot machine aesthetics
- **Capabilities**:
  - **Text-to-3D**: Generate models from descriptions
  - **Image-to-3D**: Generate models from reference images
  - **Texture Generation**: Create PBR textures matching style
  - **Animation**: Generate basic animation sequences
- **Output Formats**: GLB, FBX, OBJ with textures
- **Configuration**: Requires Meshy.ai API key or other generation tool access
- **Usage**: 
  ```
  meshy_ai.generate_model(
    prompt="Ancient Egyptian cleopatra symbol, golden headdress, ornate details",
    style="realistic, casino slot machine aesthetic",
    output_format="glb"
  )
  ```
- **Storage**: Store binary assets directly in repo without Git LFS
- **Location**: `/iterations/iteration_{N}/assets/`

### particle_effects (Effect Generation)
- **Purpose**: Create win celebration effects
- **Capabilities**:
  - Generate particle systems
  - Create sparkle/glow effects
  - Coin burst animations
  - Win streak effects
- **Tools**: Meshy-ai, Godot particle systems, or procedural generation
- **Usage**: Match original game's celebration style

### animation_tools (Animation Creation)
- **Purpose**: Create reel spin and symbol animations
- **Capabilities**:
  - Keyframe animation generation
  - Easing and timing curves
  - Loop animations
  - Trigger-based animations
- **Tools**: Meshy-ai, Blender (automated), or Godot AnimationPlayer
- **Usage**: Generate smooth reel spins matching original timing

### Important: Originality Requirement
- **Never copy existing assets directly**
- **Always generate originals** that capture the aesthetic essence
- **Match look and feel**, not exact replication
- **Create variations** that honor the original style
- Use chain-of-thought to explain design decisions
- **Storage**: Store all binary assets directly in repo without Git LFS
- **Cleanup**: On human "yes" decision, delete old iteration folders and keep only latest approved assets

---

## Step 5: Code Generation (Godot 4.6)

### code_execution (Godot GDScript)
- **Purpose**: Generate and execute Godot code
- **Capabilities**:
  - Write GDScript code for game logic
  - Create scene files (.tscn)
  - Configure resources (.tres)
  - Set up project structure
- **Language**: GDScript (Python-like syntax)
- **Version**: Godot 4.6+

### gdscript_components (Game Logic Modules)

#### ReelController
- Spin mechanics
- Symbol randomization
- Stop timing and easing
- Reel state management

#### WinCalculator
- Payline checking
- Symbol matching logic
- Payout calculation
- Win type detection (3-of-a-kind, etc.)

#### AnimationManager
- Symbol animations
- Win celebrations
- Transition effects
- UI animations

#### UIController
- Button handlers (spin, bet, info)
- Balance display updates
- Paytable screens
- Settings menu

#### GameStateMachine
- Base game state
- Bonus game state
- Free spin mode
- State transitions

#### AudioManager (optional)
- Sound effect triggers
- Background music
- Volume controls

### godot_cli (Godot Command Line)
- **Purpose**: Run Godot editor and exporter from command line
- **Capabilities**:
  - Export to HTML5/WebAssembly
  - Run project in headless mode for testing
  - Import assets automatically
- **Usage**: `godot --export-release "HTML5" output/index.html`

---

## Step 6: Deploy Test Version (Public URL)

### gh_cli (GitHub CLI)
- **Purpose**: Deploy to GitHub Pages
- **Capabilities**:
  - Create gh-pages branch
  - Push HTML5 export to branch
  - Configure GitHub Pages settings
  - Generate public HTTPS URL for test harness
- **Configuration**: Requires GitHub authentication
- **Usage**: 
  ```bash
  gh repo create my-slot-machine --public
  git push origin gh-pages
  gh browse --repo username/my-slot-machine --branch gh-pages
  ```

### vercel_cli (Vercel Deployment)
- **Purpose**: Deploy to Vercel hosting
- **Capabilities**:
  - Deploy static sites
  - Generate public URLs for test harness
  - Configure build settings
  - Manage deployments
- **Configuration**: Requires Vercel account and token
- **Usage**: 
  ```bash
  vercel --prod
  ```

### vercel_api (Vercel API)
- **Purpose**: Programmatic deployment
- **Capabilities**:
  - Create deployments via API
  - Manage projects
  - Get deployment URLs
- **Configuration**: Requires Vercel API token
- **Usage**: POST to Vercel API with files

### deployment_validation
- **Purpose**: Verify deployment is working
- **Capabilities**:
  - Check URL accessibility
  - Test basic game functionality
  - Verify asset loading
  - Screenshot deployed version
- **Tools**: Browser automation

---

## Step 7: Record Test Video

### screen_recording (Browser Recording)
- **Purpose**: Record gameplay video of deployed slot machine test harness
- **Capabilities**:
  - Browser-based screen recording
  - Video codec selection
  - Audio capture (optional)
  - Automated interaction during recording
- **Tools**: Browser automation with video capture
- **Usage**: Record 30-60 seconds of gameplay
- **Storage**: Save to `/iterations/iteration_{N}/videos/`

### ffmpeg (Video Processing)
- **Purpose**: Screen capture and video editing
- **Capabilities**:
  - Screen capture from display
  - Trim and edit videos
  - Convert video formats
  - Adjust resolution and frame rate
  - Compress videos
- **Configuration**: ffmpeg installed on system
- **Usage**: 
  ```bash
  ffmpeg -video_size 1280x720 -framerate 30 -i :0.0+0,0 \
    -t 60 -c:v libx264 output.mp4
  ```
- **Storage**: Save to `/iterations/iteration_{N}/videos/`

### playwright_video (Playwright Video Recording)
- **Purpose**: Record browser interactions
- **Capabilities**:
  - Native video recording in Playwright
  - Synchronized with browser actions
  - High quality captures
- **Configuration**: Playwright with video enabled
- **Usage**: Enable video recording in browser context

### video_upload (Video Hosting)
- **Purpose**: Host recorded videos for sharing
- **Capabilities**:
  - Upload to cloud storage
  - Generate shareable links
  - Embed in messages
- **Options**: GitHub releases, Cloudinary, Imgur, etc.

---

## Step 8: Compare Videos (AI Vision)

### kimi_vision (Video Comparison)
- **Purpose**: Compare generated vs original videos using AI
- **Capabilities**:
  - Visual similarity analysis
  - Frame-by-frame comparison
  - Color palette matching
  - Animation timing comparison
  - Feature completeness check
  - Overall aesthetic assessment
- **Model**: Kimi K-2.5 with vision capabilities
- **Usage**: 
  - Extract frames from both videos
  - Analyze each pair with Kimi vision
  - Generate comparison report with scores

### video_frames_extraction
- **Purpose**: Extract comparable frames from videos
- **Capabilities**:
  - Extract frames at matching timestamps
  - Normalize frame sizes
  - Create side-by-side comparisons
- **Tools**: ffmpeg
- **Usage**: Extract frames every N seconds from both videos

### comparison_analysis (Structured Analysis)
- **Purpose**: Generate detailed comparison reports
- **Components**:
  - Visual similarity score (0-10)
  - Animation quality score (0-10)
  - Feature completeness score (0-10)
  - List of strengths
  - List of improvements needed
  - Overall assessment
- **Output**: Structured JSON or markdown report

---

## Step 9: Human Feedback Loop

### telegram (Messaging)
- **Purpose**: Send updates and feedback requests to Ron
- **Capabilities**:
  - Send text messages
  - Send images and videos
  - Receive replies
  - Parse user responses
- **Configuration**: Requires Telegram Bot API token
- **Usage**: 
  ```
  telegram.send_message(
    chat_id=RON_CHAT_ID,
    text=iteration_summary
  )
  ```

### response_parsing (Decision Extraction)
- **Purpose**: Parse Ron's yes/no response
- **Capabilities**:
  - Detect 'yes' or 'no' in messages
  - Handle variations (Yes, yes!, YES, No, no, NO, etc.)
  - Request clarification if ambiguous
- **Logic**: Simple string matching with normalization
- **Actions on "yes"**:
  - Mark iteration as final in MEMORY.md
  - Push only latest approved assets, Godot code, and spreadsheet
  - Delete old iteration folders (keep only approved iteration)
  - Save commit SHA
  - Stop autonomous loop
- **Actions on "no"**:
  - Increment iteration counter
  - Restart loop at Step 2 (loop steps 2-7)

---

## Cross-Cutting Skills

### chain_of_thought (Reasoning)
- **Purpose**: Show transparent decision-making process
- **Usage**: 
  - Start with "Let's think step by step"
  - Explain observations before conclusions
  - Show intermediate reasoning
  - Document thought process in MEMORY.md

### checkpoint_management (State Persistence)
- **Purpose**: Save progress for restart resilience
- **Capabilities**:
  - Write checkpoint data to MEMORY.md
  - Load checkpoint state on restart
  - Maintain iteration and step counters
  - Save all reference data (URLs, file paths)
- **Format**: JSON structures in MEMORY.md

### error_handling (Resilience)
- **Purpose**: Handle failures gracefully
- **Capabilities**:
  - Detect API failures
  - Retry with exponential backoff
  - Fall back to alternative methods
  - Report blockers to Ron
  - Continue with what's possible

### file_management (Organization)
- **Purpose**: Keep generated files organized
- **Structure**:
  ```
  /iterations/
    /iteration_1/
      iteration_1_analysis.xlsx  # or CSV files if fallback
      /videos/
        original_video_info.json
        generated_gameplay.mp4
      /assets/
        /symbols/
        /textures/
        /animations/
        /effects/
      /code/
        godot_project/
      /analysis/
        frame_001.png
        frame_002.png
        comparison_report.md
  ```
- **Binary storage**: Store all assets directly in repo without Git LFS
- **Cleanup on "yes"**: Delete old iteration folders (iteration_1, iteration_2, etc.) and keep only the latest approved iteration

---

## API Keys & Configuration Required

### Required
- **Brave Search API**: For web search
- **Kimi K-2.5 (Moonshot)**: For AI reasoning and vision
- **Meshy.ai API or other generation tools**: For 3D asset generation
- **Telegram Bot API**: For communication with Ron
- **GitHub Token**: For deployment (if using GitHub Pages)
- **pandas + openpyxl**: For Excel spreadsheet creation (with CSV fallback)

### Optional
- **YouTube Data API**: For enhanced video metadata
- **Vercel Token**: For alternative deployment
- **Cloudinary/Imgur**: For video hosting

---

## Tool Availability Check

Before starting each step, verify required tools are available:

1. **Step 1**: web_search, browser
2. **Step 2**: browser, screenshot, kimi_vision
3. **Step 3**: pandas, openpyxl (or csv fallback)
4. **Step 4**: meshy_ai or other generation tools
5. **Step 5**: code_execution, godot_cli
6. **Step 6**: gh_cli or vercel_cli
7. **Step 7**: ffmpeg or browser recording
8. **Step 8**: kimi_vision, video processing
9. **Step 9**: telegram

If any required tool is missing, notify Ron via Telegram and request configuration or suggest alternatives.

**Excel/CSV Rule**: Always try pandas + openpyxl first. If it fails (import error, installation issue), fall back to CSV files and log the fallback in MEMORY.md.
