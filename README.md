# Clawd Slots Assets Pipeline

Central pipeline and configuration hub for the Clawd virtual worker in social casino slots development.

## Overview

This repository serves as the operational control center for Clawd, an OpenClaw-based analyst for social casino slots. Clawd extracts frames from YouTube videos, performs multimodal analysis, and generates symbol texture assets to document symbols, reel layout, and animations.

### Clawd's Role

Clawd functions as an autonomous analysis specialist responsible for:

- **Video Intake**: Confirming the YouTube URL and extracting frames by timestamp
- **Frame Analysis**: Using a multimodal LLM to identify symbols, reel layout, and animations
- **Documentation**: Writing analysis.md based on frames and tags.txt
- **Symbol Textures**: Generating symbol texture assets closely matching the frames
- **Communication**: Providing progress updates via Telegram

### Technology Stack

- **AI/LLM**: Kimi K-2.5 for reasoning and vision analysis
- **Video Analysis**: Frame extraction + multimodal LLM
- **Communication**: Telegram for progress updates and human feedback
- **Documentation**: analysis.md for findings, MEMORY.md for checkpoints

## Three-Phase Workflow

Clawd operates in a three-phase workflow:

1. **Phase 1: Video Intake + Frame Extraction**
    - Use the hardcoded CLEOPATRA video source
    - Read human-authored tags.txt entries
    - Extract frames (auto-download from S3 if missing)
    - Do not modify tags.txt during extraction
2. **Phase 2: Multimodal LLM Analysis**
    - Analyze frames and tags.txt with a multimodal LLM
    - Identify symbols, reel layout, and animations
    - Write analysis.md to the video folder
3. **Phase 3: Symbol Asset Generation**
    - Generate symbol textures using frames, tags.txt, and analysis.md
    - Save textures under yt/CLEOPATRA/output/symbols/
    - Present assets for approval; regenerate rejected symbols

## Repository Structure

```
clawd-slots-assets-pipeline/
├── constitution/          # Core operational guidelines for Clawd
│   ├── SOUL.md           # Identity, mission, and values
│   ├── AGENTS.md         # AI agent capabilities and three-phase workflow
│   ├── USER.md           # User interaction guidelines (Telegram)
│   ├── TOOLS.md          # Development tools and specifications
│   ├── SKILLS.md         # Required skills for each workflow step
│   ├── HEARTBEAT.md      # 30-minute cycle execution protocol
│   ├── GOAL.md           # Three-phase workflow definition
│   └── MEMORY.md         # Checkpoint state and iteration tracking
│
├── prompts/              # AI prompt templates (legacy; not used in current workflow)
│   └── meshy-ai/         # Legacy prompt templates
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

The `constitution/` directory contains Clawd's operational framework defining the three-phase workflow:

- **SOUL.md**: Core identity as reverse-engineering architect
- **AGENTS.md**: Three-phase workflow capabilities
- **USER.md**: Telegram communication protocol
- **TOOLS.md**: Video analysis and extraction tools
- **SKILLS.md**: Required capabilities for each workflow step
- **HEARTBEAT.md**: 30-minute execution cycle protocol
- **GOAL.md**: Complete three-phase workflow definition
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
- Extracted timestamps and frame outputs based on tags.txt
- Confirmed YouTube URL
- analysis.md status
- symbol texture generation status
- File paths and reference data

## Non-Goals

- 3D asset creation or modeling
- Godot game implementation
- Deployment or playable builds

If the process restarts, Clawd resumes from the last completed checkpoint automatically.

## Getting Started

### For Ron (Human in the Loop)

1. Clawd sends Telegram updates every 30 minutes during active work
2. After Phase 2 completes, review:
    - Summary message with analysis.md findings
    - Extracted frames and tags.txt entries
3. After Phase 3 completes, review:
    - Symbol texture assets under yt/CLEOPATRA/output/symbols/
4. Provide clarification if Clawd encounters blockers

### For Clawd Operations

1. Check MEMORY.md for current iteration and step state
2. Load GOAL.md for three-phase workflow definition
3. Execute next step based on current position
4. Save checkpoint after each step completion
5. Send Telegram progress update every 30 minutes
6. Request human confirmation before Phase 2
7. Present symbol textures for review in Phase 3

## Development Workflow

### Three-Phase Execution

1. **Video Intake + Frame Extraction**: Read approved tags.txt and extract frames
2. **Multimodal LLM Analysis**: Analyze frames and tags.txt and write analysis.md
3. **Symbol Asset Generation**: Generate symbol textures and review with the user

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
- **Post-Generation**: Symbol textures created and reviewed

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
- Three-phase workflow (extraction + analysis + symbol textures)
- Checkpoint resilience with MEMORY.md state tracking
- Frame extraction with tags.txt metadata
- analysis.md generation
- symbol texture generation and review
- Human confirmation before analysis

See `/constitution/MEMORY.md` for current iteration state and progress checkpoints.

## License

Proprietary - Bettr Casino

All workflows, configurations, and generated assets are proprietary to the Bettr Casino slots development pipeline.
