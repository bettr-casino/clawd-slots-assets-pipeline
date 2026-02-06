# TOOLS.md

## Development Tools

### Video Research & Analysis

**Web Search (Brave API)**
- Search YouTube for Las Vegas slot machine videos
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

**Meshy.ai**
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

**Google Sheets**
- Asset inventory tracking
- Symbol and reel configuration documentation
- Progress checkpoints
- Iteration history
- Can be created via Google Sheets API or CSV export

**MEMORY.md**
- Checkpoint state storage
- Iteration tracking (current iteration number)
- Step tracking (current step in 9-step loop)
- Human feedback decisions
- Restart resilience data

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
- Google Sheets API (for documentation)
- Brave Search API (for video discovery)

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
