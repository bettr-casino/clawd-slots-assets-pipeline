# Clawd Slots Assets Pipeline

Central pipeline and configuration hub for the Clawd virtual worker in social casino slots development.

## Overview

This repository serves as the operational control center for Clawd, an OpenClaw-based architect and social casino slots expert. Clawd autonomously reverse-engineers Las Vegas slot machines from YouTube videos, generates original assets, creates Godot 4.6 implementations, and iterates based on human feedback.

### Clawd's Role

Clawd functions as an autonomous reverse-engineering specialist responsible for:

- **Video Analysis**: Analyzing YouTube videos of Las Vegas slot machines frame-by-frame
- **Asset Generation**: Creating original 3D models, textures, and animations using meshy-ai
- **Game Implementation**: Writing Godot 4.6 GDScript code for complete slot machines
- **Deployment**: Publishing test versions with public URLs for review
- **Iteration**: Comparing generated vs original videos and refining based on feedback
- **Communication**: Providing 30-minute progress updates via Telegram

### Technology Stack

- **AI/LLM**: Kimi K-2.5 for reasoning, code generation, and vision analysis
- **3D Generation**: Meshy-ai for original models, textures, particle effects, animations
- **Game Engine**: Godot 4.6 with GDScript for slot machine implementation
- **Deployment**: GitHub Pages or Vercel for public test URLs
- **Video Analysis**: Browser automation + screenshot + Kimi vision
- **Communication**: Telegram for progress updates and human feedback
- **Documentation**: Google Sheets for asset tracking, MEMORY.md for checkpoints

## The 9-Step Autonomous Workflow

Clawd operates in a continuous autonomous loop executing these 9 steps:

1. **Web Search**: Find high-quality YouTube videos of Las Vegas slot machines
2. **Video Analysis**: Frame-by-frame analysis using Kimi vision
3. **Asset List**: Create comprehensive inventory in Google Sheets
4. **Asset Generation**: Generate original assets with meshy-ai (never copy)
5. **Code Generation**: Implement complete game in Godot 4.6 GDScript
6. **Deploy**: Publish test version with public URL
7. **Record Video**: Capture gameplay video of generated slot
8. **Compare**: Use Kimi vision to compare generated vs original
9. **Human Feedback**: Request Ron's yes/no decision to continue or stop

The loop continues iterating until Ron approves by replying 'yes' to the iteration summary.

## Repository Structure

```
clawd-slots-assets-pipeline/
├── constitution/          # Core operational guidelines for Clawd
│   ├── SOUL.md           # Identity, mission, and values
│   ├── AGENTS.md         # AI agent capabilities and 9-step loop
│   ├── USER.md           # User interaction guidelines (Telegram)
│   ├── TOOLS.md          # Development tools and specifications
│   ├── SKILLS.md         # Required skills for each workflow step
│   ├── HEARTBEAT.md      # 30-minute cycle execution protocol
│   ├── GOAL.md           # 9-step autonomous workflow definition
│   └── MEMORY.md         # Checkpoint state and iteration tracking
│
├── prompts/              # AI generation prompt templates
│   └── meshy-ai/         # Meshy.ai specific prompts
│       ├── egyptian-symbols.md    # Reel symbol generation prompts
│       ├── backgrounds.md         # Background element prompts
│       └── win-effects.md         # Effect object prompts
│
├── workflows/            # End-to-end process documentation
│   ├── egyptian-mvp-pipeline.md   # Complete Egyptian theme workflow
│   └── mobile-optimization.md     # Mobile performance optimization
│
└── standards/            # Technical standards and conventions
    ├── asset-naming.md           # File and asset naming conventions
    ├── pbr-guidelines.md         # PBR texture and material standards
    └── animation-timing.md       # Animation timing specifications
```

### Constitution Directory

The `constitution/` directory contains Clawd's operational framework defining the autonomous 9-step reverse-engineering workflow:

- **SOUL.md**: Core identity as reverse-engineering architect
- **AGENTS.md**: 9-step autonomous loop capabilities
- **USER.md**: Telegram communication protocol
- **TOOLS.md**: Video analysis, asset generation, and deployment tools
- **SKILLS.md**: Required capabilities for each workflow step
- **HEARTBEAT.md**: 30-minute execution cycle protocol
- **GOAL.md**: Complete 9-step workflow definition
- **MEMORY.md**: Checkpoint state for restart resilience

This framework can be symlinked to the broader OpenClaw workspace:

```bash
# Create symlink from OpenClaw workspace to this repository
ln -s /path/to/clawd-slots-assets-pipeline/constitution /path/to/openclaw-workspace/clawd-constitution
```

This enables Clawd to maintain consistent autonomous behavior across different project contexts.

## Checkpoint Resilience

All workflow state is saved in `constitution/MEMORY.md` with checkpoint data:

- Current iteration number
- Current step (1-9) in the workflow
- Completed checkpoint data for each step
- Human feedback decision status
- URLs, file paths, and reference data

If the process restarts, Clawd resumes from the last completed checkpoint automatically.

## Getting Started

### For Ron (Human in the Loop)

1. Clawd sends Telegram updates every 30 minutes during active work
2. After each complete iteration (9 steps), review:
   - Summary message with test URL
   - Deployed slot machine prototype
   - Comparison analysis vs original video
3. Reply 'yes' to approve and stop iterations, or 'no' to continue refining
4. Provide clarification if Clawd encounters blockers

### For Clawd Operations

1. Check MEMORY.md for current iteration and step state
2. Load GOAL.md for 9-step workflow definition
3. Execute next step based on current position
4. Save checkpoint after each step completion
5. Send Telegram progress update every 30 minutes
6. Request human feedback after completing all 9 steps
7. Continue iterating until Ron approves with 'yes'

## Development Workflow

### Autonomous 9-Step Execution

1. **Web Search**: Find YouTube videos of target slot machines
2. **Video Analysis**: Extract game mechanics and visual design with Kimi vision
3. **Asset List**: Document comprehensive inventory in Google Sheets
4. **Asset Generation**: Create original assets with meshy-ai matching look/feel
5. **Code Generation**: Implement complete game in Godot 4.6 GDScript
6. **Deploy**: Publish to GitHub Pages or Vercel with public URL
7. **Record**: Capture gameplay video of generated slot machine
8. **Compare**: Analyze quality match with Kimi vision
9. **Feedback**: Send iteration summary to Ron and wait for yes/no decision

### Chain-of-Thought Reasoning

All steps use transparent reasoning:
- Start complex analyses with "Let's think step by step"
- Show observations before conclusions
- Document decision-making process
- Save reasoning in MEMORY.md

### Quality Gates

Each iteration includes validation checkpoints:
- **Post-Analysis**: Complete symbol and mechanics inventory
- **Post-Generation**: Original assets matching aesthetic (never copied)
- **Post-Implementation**: Functional Godot game with all features
- **Post-Deployment**: Accessible public URL with working gameplay
- **Post-Comparison**: Detailed quality assessment with improvement notes

## Contributing

Changes to constitution, workflows, or standards should:

1. Be discussed with Ron via Telegram if significant
2. Include rationale for modifications
3. Update affected documentation consistently
4. Preserve checkpoint resilience
5. Document changes clearly

## Project Status

**Current Focus**: Autonomous reverse-engineering of Las Vegas slot machines from YouTube videos

Active capabilities:
- 9-step autonomous workflow loop
- Checkpoint resilience with MEMORY.md state tracking
- Original asset generation (never copying)
- Godot 4.6 implementation and deployment
- AI-powered video comparison with Kimi vision
- Human feedback loop for iteration control

See `/constitution/MEMORY.md` for current iteration state and progress checkpoints.

## License

Proprietary - Bettr Casino

All workflows, configurations, and generated assets are proprietary to the Bettr Casino slots development pipeline.
