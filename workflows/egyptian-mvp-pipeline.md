# Egyptian MVP Pipeline

## Overview

Complete end-to-end workflow for creating Egyptian-themed slot game assets from concept to Unity integration.

## Phase 1: Planning & Requirements

### 1.1 Asset Identification
- [ ] Review game design requirements via Slack
- [ ] Identify all required assets:
  - Reel symbols (5-8 unique symbols)
  - Background elements (3-5 layers)
  - Win effect objects (5-7 types)
  - UI decorative elements
- [ ] Define technical specifications per asset type
- [ ] Create asset list with priority ranking

### 1.2 Reference Gathering
- [ ] Collect Egyptian art references
- [ ] Identify style direction (realistic vs. stylized)
- [ ] Review existing similar games for benchmarks
- [ ] Document approved aesthetic direction in Slack

## Phase 2: Asset Generation

### 2.1 Symbol Creation (Meshy.ai)
- [ ] Use prompts from `/prompts/meshy-ai/egyptian-symbols.md`
- [ ] Generate base meshes and textures:
  - Scarab, Eye of Ra, Ankh, Pyramid, Sphinx
  - Wild/Scatter special symbols
- [ ] Review generated assets for quality
- [ ] Share previews in Slack for approval
- [ ] Iterate based on feedback

### 2.2 Background Elements (Meshy.ai)
- [ ] Use prompts from `/prompts/meshy-ai/backgrounds.md`
- [ ] Generate background layers:
  - Distant layer: Pyramids, dunes
  - Mid layer: Temple columns, walls
  - Near layer: Decorative elements
- [ ] Ensure parallax depth compatibility
- [ ] Review and iterate

### 2.3 Win Effects (Meshy.ai)
- [ ] Use prompts from `/prompts/meshy-ai/win-effects.md`
- [ ] Generate effect objects:
  - Coins, particles, glow elements
  - Special celebration objects
- [ ] Optimize for particle system use
- [ ] Validate performance implications

## Phase 3: Optimization (Blender)

### 3.1 Geometry Optimization
- [ ] Import all assets into Blender
- [ ] Validate triangle counts:
  - Symbols: <2000 tris
  - Backgrounds: <1200 tris
  - Effects: <500 tris
- [ ] Clean up mesh topology
- [ ] Remove unnecessary geometry
- [ ] Optimize for mobile rendering

### 3.2 UV and Texture Optimization
- [ ] Check UV layouts for efficiency
- [ ] Reorganize UVs if needed
- [ ] Consider texture atlasing for symbol sets
- [ ] Validate texture resolutions:
  - Symbols: 1024x1024
  - Backgrounds: 1024x1024 or 512x512
  - Effects: 512x512

### 3.3 Export Preparation
- [ ] Apply naming conventions (see `/standards/asset-naming.md`)
- [ ] Set correct pivot points
- [ ] Apply transforms (location, rotation, scale)
- [ ] Validate normals and smoothing
- [ ] Export as FBX with Unity presets:
  - -Z forward, Y up
  - Scale: 1.0
  - Triangulate meshes

## Phase 4: Unity Integration

### 4.1 Asset Import
- [ ] Import FBX files into Unity project
- [ ] Configure import settings:
  - Normals: Import
  - Materials: Extract
  - Scale Factor: 1.0
  - Generate Colliders: As needed
- [ ] Verify axis orientation

### 4.2 Material Setup
- [ ] Extract and configure materials
- [ ] Apply PBR textures to Unity Standard Shader
- [ ] Set up texture compression:
  - Mobile: ETC2
  - Max size: 1024 for symbols, 512 for effects
- [ ] Configure material properties (metallic, smoothness)

### 4.3 Prefab Creation
- [ ] Create prefabs for each asset
- [ ] Set up LOD groups if needed
- [ ] Configure colliders for gameplay
- [ ] Add components for animation/effects

### 4.4 Scene Integration
- [ ] Place background elements in scene
- [ ] Set up parallax layers
- [ ] Configure symbol positions on reels
- [ ] Implement win effect particle systems

## Phase 5: Testing & Optimization

### 5.1 Performance Testing
- [ ] Test on target mobile devices
- [ ] Profile draw calls and batching
- [ ] Monitor texture memory usage
- [ ] Validate frame rate (target: 60fps)
- [ ] Check GPU/CPU usage

### 5.2 Visual Quality Assurance
- [ ] Verify assets render correctly
- [ ] Check for texture artifacts
- [ ] Validate lighting interaction
- [ ] Test animations and effects
- [ ] Confirm readability at game scale

### 5.3 Optimization Iterations
- [ ] Adjust texture sizes if needed
- [ ] Implement LOD if performance issues
- [ ] Optimize particle systems
- [ ] Enable occlusion culling
- [ ] Configure batching

### 5.4 Documentation
- [ ] Document final asset specifications
- [ ] Record any custom workflows or settings
- [ ] Update memory bank with lessons learned
- [ ] Share final deliverables via Slack

## Phase 6: Delivery

### 6.1 Package Preparation
- [ ] Organize assets in Unity project structure
- [ ] Include documentation
- [ ] Create example scenes
- [ ] Prepare asset list with specifications

### 6.2 Handoff
- [ ] Share Unity package via Slack
- [ ] Provide integration guide
- [ ] Offer support for questions
- [ ] Archive project files and prompts

## Success Metrics

- All assets under triangle budget
- 60fps on target mobile devices
- Texture memory within 50MB total
- No rendering artifacts
- Game builds successfully for mobile
- Assets approved by stakeholders

## Iteration Notes

Document any deviations, issues, or optimizations discovered during the pipeline execution for future reference in `/constitution/MEMORY.md`.
