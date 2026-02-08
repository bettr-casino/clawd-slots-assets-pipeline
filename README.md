# Clawd Slots Assets Pipeline

Central pipeline and configuration hub for the Clawd virtual worker in social casino slots development.

## Overview

This repository serves as the operational control center for Clawd, an OpenClaw-based analyst for social casino slots. Clawd extracts frames from YouTube videos and performs multimodal analysis to document symbols, reel layout, and animations.

### Clawd's Role

Clawd functions as an autonomous analysis specialist responsible for:

- **Video Intake**: Confirming the YouTube URL and extracting frames by timestamp
- **Frame Analysis**: Using a multimodal LLM to identify symbols, reel layout, and animations
- **Documentation**: Writing analysis.md based on frames and tags.txt
- **Communication**: Providing progress updates via Telegram

### Technology Stack

- **AI/LLM**: Kimi K-2.5 for reasoning and vision analysis
- **Video Analysis**: Frame extraction + multimodal LLM
- **Communication**: Telegram for progress updates and human feedback
- **Documentation**: analysis.md for findings, MEMORY.md for checkpoints

## Two-Phase Workflow

Clawd operates in a two-phase workflow:

1. **Phase 1: Video Intake + Frame Extraction**
    - Confirm the YouTube URL
    - Collect timestamps and optional comments
    - Extract frames (auto-download from S3 if missing)
    - Append tags to tags.txt
2. **Phase 2: Multimodal LLM Analysis**
    - Analyze frames and tags.txt with a multimodal LLM
    - Identify symbols, reel layout, and animations
    - Write analysis.md to the video folder

## Repository Structure

```
clawd-slots-assets-pipeline/
├── constitution/          # Core operational guidelines for Clawd
│   ├── SOUL.md           # Identity, mission, and values
│   ├── AGENTS.md         # AI agent capabilities and two-phase workflow
│   ├── USER.md           # User interaction guidelines (Telegram)
│   ├── TOOLS.md          # Development tools and specifications
│   ├── SKILLS.md         # Required skills for each workflow step
│   ├── HEARTBEAT.md      # 30-minute cycle execution protocol
│   ├── GOAL.md           # Two-phase workflow definition
│   └── MEMORY.md         # Checkpoint state and iteration tracking
│
├── prompts/              # AI generation prompt templates
│   └── meshy-ai/         # Meshy.ai specific prompts
│       ├── egyptian-symbols.md    # Reel symbol generation prompts
│       ├── backgrounds.md         # Background element prompts
│       └── win-effects.md         # Effect object prompts
│
├── workflows/            # End-to-end process documentation
│   ├── autonomous-9-step-loop.md   # Primary autonomous workflow (9 steps)
│   ├── cleopatra-grand-benchmark.md # Benchmark analysis workflow
│   ├── cleopatra-research.md        # Video research workflow
│   ├── egyptian-mvp-pipeline.md     # Complete Egyptian theme workflow
│   └── mobile-optimization.md       # Mobile performance optimization
│
└── standards/            # Technical standards and conventions
    ├── asset-naming.md           # File and asset naming conventions
    ├── pbr-guidelines.md         # PBR texture and material standards
    └── animation-timing.md       # Animation timing specifications
```

### Constitution Directory

The `constitution/` directory contains Clawd's operational framework defining the two-phase analysis workflow:

- **SOUL.md**: Core identity as reverse-engineering architect
- **AGENTS.md**: Two-phase workflow capabilities
- **USER.md**: Telegram communication protocol
- **TOOLS.md**: Video analysis and extraction tools
- **SKILLS.md**: Required capabilities for each workflow step
- **HEARTBEAT.md**: 30-minute execution cycle protocol
- **GOAL.md**: Complete two-phase workflow definition
- **MEMORY.md**: Checkpoint state for restart resilience

This framework can be symlinked to the broader OpenClaw workspace:

```bash
# Create symlink from OpenClaw workspace to this repository
ln -s /path/to/clawd-slots-assets-pipeline/constitution /path/to/openclaw-workspace/clawd-constitution
```

This enables Clawd to maintain consistent autonomous behavior across different project contexts.

## Checkpoint Resilience

All workflow state is saved in `constitution/MEMORY.md` with checkpoint data:

- Current phase and step
- Extracted timestamps and tags.txt updates
- Confirmed YouTube URL
- analysis.md status
- File paths and reference data

If the process restarts, Clawd resumes from the last completed checkpoint automatically.

## Getting Started

### For Ron (Human in the Loop)

1. Clawd sends Telegram updates every 30 minutes during active work
2. After Phase 2 completes, review:
    - Summary message with analysis.md findings
    - Extracted frames and tags.txt entries
3. Provide clarification if Clawd encounters blockers

### For Clawd Operations

1. Check MEMORY.md for current iteration and step state
2. Load GOAL.md for two-phase workflow definition
3. Execute next step based on current position
4. Save checkpoint after each step completion
5. Send Telegram progress update every 30 minutes
6. Request human confirmation before Phase 2

## Development Workflow

### Two-Phase Execution

1. **Video Intake + Frame Extraction**: Confirm URL, collect timestamps, extract frames, and update tags.txt
2. **Multimodal LLM Analysis**: Analyze frames and tags.txt and write analysis.md

### Chain-of-Thought Reasoning

All steps use transparent reasoning:
- Start complex analyses with "Let's think step by step"
- Show observations before conclusions
- Document decision-making process
- Save reasoning in MEMORY.md

### Quality Gates

Each run includes validation checkpoints:
- **Post-Extraction**: Frames and tags.txt present
- **Post-Analysis**: Complete symbol inventory, reel layout, and animation notes in analysis.md

## Contributing

Changes to constitution, workflows, or standards should:

1. Be discussed with Ron via Telegram if significant
2. Include rationale for modifications
3. Update affected documentation consistently
4. Preserve checkpoint resilience
5. Document changes clearly

## Project Status

**Current Focus**: Multimodal analysis of slot machine videos from YouTube

Active capabilities:
- Two-phase workflow (extraction + analysis)
- Checkpoint resilience with MEMORY.md state tracking
- Frame extraction with tags.txt metadata
- analysis.md generation
- Human confirmation before analysis

See `/constitution/MEMORY.md` for current iteration state and progress checkpoints.

## License

Proprietary - Bettr Casino

All workflows, configurations, and generated assets are proprietary to the Bettr Casino slots development pipeline.
