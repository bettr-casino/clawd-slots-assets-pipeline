# MEMORY - Knowledge Base & Context

## Purpose
This document serves as the collective memory for the Clawd system, capturing learnings, decisions, and context that inform future work.

## Project Context

### Current Focus
- Egyptian-themed slot game MVP
- Mobile-first optimization
- PBR workflow standardization

### Active Themes
- Egyptian mythology and symbols
- Ancient temple environments
- Gold and treasure aesthetics
- Mystical effects and particles

## Learnings & Best Practices

### Asset Generation
- **Egyptian Symbols**: Hieroglyphics and deity representations work best with clear reference images
- **Backgrounds**: Temple and tomb environments require careful lighting setup
- **Win Effects**: Particle-heavy effects need LOD considerations for mobile

### Performance Insights
- Target poly count: < 5K for symbols, < 20K for backgrounds
- Texture budget: 2K max for mobile, 4K for high-end
- Material complexity: Keep shader instructions under budget for older devices

### Workflow Optimizations
- Batch similar requests to Meshy.ai to maintain style consistency
- Use Blender for final polish rather than extensive manual modeling
- Establish clear approval checkpoints to avoid late-stage revisions

## Decision Log

### Recent Decisions
- Adopted PBR workflow as standard (metallic/roughness)
- Committed to Unity URP for mobile performance
- Established Egyptian theme as first major project
- Standardized asset naming conventions

## Common Issues & Solutions

### Issue: Inconsistent Art Style
**Solution**: Create mood boards and reference sheets before generation

### Issue: Assets Too Heavy for Mobile
**Solution**: Implement LOD system and aggressive optimization passes

### Issue: Long Approval Cycles
**Solution**: Use Slack previews for quick feedback loops

## Future Considerations
- Expand to additional themes beyond Egyptian
- Explore real-time procedural generation
- Investigate AI-driven animation
- Consider web-based preview tools
