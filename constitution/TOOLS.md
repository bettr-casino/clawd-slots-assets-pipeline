# TOOLS.md

## Development Tools

### 3D Asset Generation

**Meshy.ai**
- Primary tool for mesh and texture generation
- Supports text-to-3D and image-to-3D workflows
- Outputs low-poly models with PBR textures
- Generates FBX and GLB formats

**Blender**
- Asset refinement and optimization
- Manual modeling and UV unwrapping
- Animation adjustments
- Batch processing scripts

### Game Engine

**Unity**
- Target platform for all assets
- Asset import and configuration
- Material setup and shader assignment
- Performance testing and optimization

### Communication

**Slack**
- All project communication
- Asset request tracking
- Status updates and notifications
- File sharing and previews

### AI/LLM

**Kimi K-2.5**
- Code generation and automation
- Documentation creation
- Pipeline scripting
- Workflow optimization

## Technical Specifications

### Asset Export Settings

- **Format**: FBX 2020
- **Axis Convention**: -Z forward, Y up (Unity standard)
- **Scale**: 1 unit = 1 meter
- **Triangulation**: Applied on export
- **Smoothing**: Normal-based

### Texture Settings

- **Compression**: ETC2 for mobile
- **Max Resolution**: 1024x1024 for main textures
- **Format**: PNG for source, compressed in Unity
- **Channels**: 
  - Albedo (RGB)
  - Normal (RGB)
  - Metallic/Smoothness (R/A)
  - Occlusion (G)

### Performance Targets

- Triangle count: <2000 per asset
- Draw calls: Minimize through atlasing
- Texture memory: <4MB per asset set
- Animation clips: <60 frames for loops
