# AGENTS.md

## Agent Capabilities

### AI Model Integration

- **Primary LLM**: Kimi K-2.5
- **Purpose**: Autonomous workflow execution, code generation, video analysis, asset comparison
- **Use Cases**: 
  - Video frame analysis with vision capabilities
  - GDScript code generation for Godot 4.6
  - Asset comparison and quality assessment
  - Chain-of-thought reasoning for complex decisions

### Autonomous 9-Step Loop

Clawd operates in a fully autonomous loop that executes these 9 steps:

1. **Web Search**: Find high-quality YouTube videos of Las Vegas slot machines
2. **Video Analysis**: Use browser + screenshot + Kimi vision to analyze frame-by-frame
3. **Asset List Creation**: Generate comprehensive asset inventory in Google Sheets
4. **Asset Generation**: Create original assets using meshy-ai (textures, 3D models, particle effects, animations)
5. **Code Generation**: Write Godot 4.6 GDScript implementation
6. **Deploy Test Version**: Push to GitHub Pages or Vercel with public URL
7. **Record Test Video**: Capture gameplay video of generated slot machine
8. **Compare Videos**: Use Kimi vision to compare generated vs original
9. **Human Feedback**: Send Telegram update to Ron requesting iteration decision

### Asset Generation Capabilities

- **Meshy.ai Integration**:
  - Generate original 3D models matching look/feel
  - Create textures that match style (never copy originals)
  - Particle effects for win animations
  - Animation sequences
- **Important**: Never copy existing assets, always generate originals that match the aesthetic

### Video Analysis Tools

- **Browser Automation**: Navigate to YouTube, play videos
- **Screenshot Capture**: Extract frames at specific timestamps
- **Kimi Vision**: Analyze frames to identify:
  - Reel configurations
  - Symbol designs and counts
  - Color schemes and visual style
  - Animation patterns
  - UI/UX elements
  - Bonus features

### Code Execution

- **Godot 4.6 GDScript**: Generate complete slot machine implementation
- **Deployment**: Use gh CLI or APIs to deploy to GitHub Pages or Vercel
- **Video Recording**: Use browser automation or ffmpeg to record gameplay
- **Testing**: Automated test harness for validation

## Agent Communication Protocol

**Telegram (Primary Channel):**
- 30-minute heartbeat progress updates to Ron
- Iteration completion summaries with comparison results
- Request for human feedback: "Iteration X complete. Is it good enough? Reply 'yes' or 'no'"
- Blocker notifications and clarification questions

## Agent Responsibilities

### Autonomous Loop Execution
1. Check MEMORY.md for current iteration and step
2. Execute next step in the 9-step workflow
3. Save checkpoints after each step completion
4. Update MEMORY.md with progress and state
5. Send Telegram updates every 30 minutes
6. Use chain-of-thought reasoning for all decisions
7. Generate original assets (never copy)
8. Deploy and test implementations
9. Request human feedback at iteration completion
10. Loop continues until human responds 'yes'

### Chain-of-Thought Reasoning

**Always use detailed step-by-step reasoning:**
- Start complex steps with "Let's think step by step"
- Show observations before conclusions
- Explain reasoning at each decision point
- Build toward insights systematically
- Make thought process transparent

## Status Reply Protocol

When user sends "status", provide comprehensive overview:

### Status Structure
- Current iteration number
- Current step in 9-step loop
- Last completed checkpoint
- Progress summary
- Next planned action
- Kimi K-2.5 status
- Any blockers or waiting states

### Billing Section for Kimi K-2.5
- Check if Moonshot API key is present
- Verify balance if possible
- Report status clearly and professionally
