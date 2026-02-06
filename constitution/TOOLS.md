# TOOLS.md

## Development Tools

### Video Research & Analysis

**Web Search (Brave primary, Tavily fallback)**
- Search YouTube for Las Vegas slot machine videos using `BRAVE_API_KEY`
- If Brave fails (429, 401, timeout, invalid key, or any error), retry with Tavily using `TAVILY_API_KEY`
- If both fail, send Telegram: "Both Brave and Tavily search tools failed. Brave error: [error message]. Tavily error: [error message]. Please configure a working search API key or provide manual input."
- Evaluate video quality and content
- Build shortlists of target machines

**Browser Automation**
- Navigate to YouTube videos
- Play and control video playback
- Capture screenshots at specific timestamps
- Extract frames for analysis

**Kimi Vision (AI-powered)**
- Analyze video frames for visual elements
- Identify reel configurations and symbols
- Compare generated vs original videos
- Assess aesthetic match quality

**Video Recording Tools**
- Browser-based screen recording
- FFmpeg for video capture and processing
- Generate comparison videos

### Asset Generation

**Meshy.ai or Other Generation Tools**
- Generate original 3D models matching slot machine aesthetics
- Create textures that match style (never copy)
- Particle effects for win animations
- Animation sequences for reels and symbols
- **Important**: Always generate originals, never copy existing assets

**Asset Requirements**
- Match look and feel of original Las Vegas machines
- Original creations that capture aesthetic essence
- Optimized for web deployment
- Compatible with Godot 4.6
- **Storage**: Store binary assets directly in repo without Git LFS

### Game Engine & Deployment

**Godot 4.6**
- GDScript code generation
- Slot machine game logic implementation
- Reel mechanics and spin animations
- Win calculation and payout systems
- UI/UX elements

**Deployment Platforms**
- GitHub Pages (via gh CLI)
- Vercel (via API or CLI)
- Public URLs for testing and feedback
- Automated deployment pipeline

### Documentation & Tracking

**Excel Spreadsheets (pandas + openpyxl)**
- Primary format for iteration tracking and analysis
- Create `.xlsx` files with multiple sheets:
  - iteration_log: Track all steps, timestamps, decisions
  - math_model: Paytable, RTP calculations, symbol weights
  - symbol_analysis: Symbol descriptions, frequencies, visual attributes
  - checkpoints: Snapshot of progress for each step
- File naming: `iteration_{N}_analysis.xlsx`
- Storage: In `/iterations/iteration_{N}/` directory
- Use pandas with openpyxl engine for Excel file creation

**CSV Fallback**
- If openpyxl installation/import fails, use CSV format
- Generate separate CSV files:
  - `iteration_log.csv`
  - `math_model.csv`
  - `symbol_analysis.csv`
  - `checkpoints.csv`
- Can be imported into Excel manually by user
- Log CSV fallback usage in MEMORY.md

**MEMORY.md**
- Checkpoint state storage
- Iteration tracking (current iteration number)
- Step tracking (current step in 9-step loop)
- Human feedback decisions
- Restart resilience data
- Binary asset storage paths and management
- Rules for keeping only latest approved iteration on "yes"

### Communication

**Telegram**
- Heartbeat progress updates (every 30 minutes)
- Iteration completion notifications
- Human feedback requests
- Blocker and clarification messages
- All messages use chain-of-thought reasoning

### Code Execution

**Bash/Shell**
- Run deployment scripts
- Execute ffmpeg commands
- File system operations
- Git operations for deployment

**APIs & Integration**
- GitHub API (for Pages deployment)
- Vercel API (for hosting)
- Brave Search API (primary video discovery)
- Tavily Search API (fallback video discovery)
- pandas + openpyxl (for Excel spreadsheet generation)

## Technical Specifications

### Video Analysis

- **Frame Rate**: Extract key frames at 1-5 second intervals
- **Resolution**: Capture at original video quality
- **Format**: PNG or JPEG for frame extraction
- **Analysis**: Use Kimi vision for automated interpretation

### Asset Export

- **Format**: GLB/GLTF for Godot compatibility
- **Textures**: PNG or WebP, optimized for web
- **Animations**: FBX or Godot-native formats
- **Performance**: Target 60 FPS in browser

### Deployment

- **Build Tool**: Godot 4.6 HTML5 export
- **Hosting**: Static site hosting (GitHub Pages or Vercel)
- **URL**: Public HTTPS URL for testing
- **CI/CD**: Automated via gh CLI or Vercel CLI

### Video Recording

- **Tool**: Browser automation or ffmpeg
- **Duration**: 30-60 seconds of gameplay
- **Resolution**: 1280x720 or 1920x1080
- **Format**: MP4 with H.264 codec
- **Purpose**: Comparison with original video
