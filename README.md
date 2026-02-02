# Clawd Slots Assets Pipeline

Central pipeline and configuration hub for the Clawd virtual worker in social casino slots development.

## Overview

This repository serves as the operational control center for Clawd, an OpenClaw-based virtual developer and 3D artist specializing in social casino slots games. Clawd manages the complete asset creation pipeline from concept through Unity integration, leveraging AI-powered tools to deliver mobile-optimized game assets.

### Clawd's Role

Clawd functions as a specialized virtual team member responsible for:

- **3D Asset Generation**: Creating low-poly game-ready models using Meshy.ai
- **Pipeline Management**: Orchestrating workflows from concept to integration
- **Quality Assurance**: Ensuring all assets meet technical and performance standards
- **Unity Integration**: Preparing and optimizing assets for mobile game deployment
- **Documentation**: Maintaining comprehensive records of processes and decisions

### Technology Stack

- **AI/LLM**: Kimi K-2.5 for code generation and automation
- **3D Generation**: Meshy.ai for mesh, texture, and animation creation
- **3D Refinement**: Blender for optimization and manual adjustments
- **Game Engine**: Unity with mobile-first optimization
- **Communication**: Slack for all project coordination

## Communication Protocol

**All Clawd communication occurs exclusively through Slack.**

- Asset requests must be submitted via designated Slack channels
- Status updates and deliverables are shared through Slack
- Questions, issues, and approvals are handled in Slack threads
- No direct file system access or alternative communication methods

This ensures transparency, traceability, and team-wide visibility of all asset pipeline activities.

## Repository Structure

```
clawd-slots-assets-pipeline/
├── constitution/          # Core operational guidelines for Clawd
│   ├── SOUL.md           # Identity, mission, and values
│   ├── AGENTS.md         # AI agent capabilities and protocols
│   ├── USER.md           # User interaction guidelines
│   ├── TOOLS.md          # Development tools and specifications
│   └── MEMORY.md         # Project knowledge base and history
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

The `constitution/` directory contains Clawd's operational framework and can be symlinked to the broader OpenClaw workspace for shared agent configurations:

```bash
# Create symlink from OpenClaw workspace to this repository
ln -s /path/to/clawd-slots-assets-pipeline/constitution /path/to/openclaw-workspace/clawd-constitution
```

This enables Clawd to maintain consistent behavior across different project contexts while keeping slot game-specific configurations centralized.

## Mobile Optimization Goals

All assets must meet strict mobile performance requirements:

### Technical Targets

- **Triangle Budget**: <2,000 triangles per reel symbol, <1,200 per background element
- **Texture Compression**: ETC2 for Android, PVRTC/ASTC for iOS
- **Texture Resolution**: 1024×1024 maximum for primary assets, 512×512 for secondary
- **Frame Rate**: Consistent 60 FPS on target devices (iPhone 8+, Samsung Galaxy S9+)
- **Memory**: <100MB total texture memory footprint

### Unity FBX Requirements

Assets exported from Meshy.ai or Blender must conform to Unity's coordinate system:

- **Forward Axis**: -Z (negative Z)
- **Up Axis**: Y (positive Y)
- **Scale**: 1 unit = 1 meter
- **Format**: FBX 2020
- **Triangulation**: Applied on export
- **Smoothing**: Normal-based

### Asset Optimization Checklist

- [ ] Geometry optimized for mobile rendering
- [ ] Clean topology without unnecessary vertices
- [ ] Proper UV unwrapping without stretching
- [ ] PBR textures with appropriate compression
- [ ] LOD (Level of Detail) for complex assets
- [ ] Efficient material usage and batching
- [ ] Animation clips compressed and optimized
- [ ] Testing validated on actual mobile devices

## Getting Started

### For Users Requesting Assets

1. Review asset requirements and reference the appropriate `/prompts/` templates
2. Submit detailed request via Slack including theme, specifications, and references
3. Await acknowledgment and timeline estimate from Clawd
4. Review previews and provide feedback through Slack
5. Receive final optimized assets with integration documentation

### For Clawd Operations

1. Monitor Slack channels for incoming asset requests
2. Reference `/constitution/` for operational guidelines
3. Use `/prompts/meshy-ai/` templates for generation
4. Follow `/workflows/` for end-to-end processes
5. Adhere to `/standards/` for all technical decisions
6. Document learnings in `/constitution/MEMORY.md`
7. Deliver via Slack with complete documentation

## Development Workflow

### Asset Creation Pipeline

1. **Planning**: Define requirements, gather references
2. **Generation**: Use Meshy.ai with standardized prompts
3. **Optimization**: Refine in Blender, ensure budget compliance
4. **Export**: Apply Unity FBX settings, validate output
5. **Integration**: Import to Unity, configure materials
6. **Testing**: Validate performance on target devices
7. **Delivery**: Package and share via Slack

### Quality Gates

Each phase includes validation checkpoints:

- **Post-Generation**: Triangle count, texture resolution
- **Post-Optimization**: Mobile performance metrics
- **Post-Integration**: Unity import validation, visual quality
- **Pre-Delivery**: Final performance testing, documentation review

## Contributing

Changes to standards, workflows, or prompts should:

1. Be discussed and approved via Slack
2. Include rationale for modifications
3. Update affected documentation consistently
4. Preserve backward compatibility where possible
5. Document breaking changes clearly

## Project Status

**Current Focus**: Egyptian-themed MVP slot game development

Active development areas:
- Egyptian symbol set (8 unique reel symbols)
- Multi-layer background parallax system  
- Win celebration effect library
- Mobile optimization and performance validation

See `/constitution/MEMORY.md` for detailed project history and active tasks.

## License

Proprietary - Bettr Casino

All assets, workflows, and configurations are proprietary to the Bettr Casino slots development pipeline.
