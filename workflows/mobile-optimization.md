# Mobile Optimization Workflow

## Overview

Comprehensive workflow for ensuring all assets meet mobile performance requirements for iOS and Android casino slot games.

## Target Specifications

### Device Targets
- **Primary**: iPhone 12/13, Samsung Galaxy S21/S22
- **Secondary**: iPhone 8/X, Samsung Galaxy S10
- **Minimum**: iPhone 7, Samsung Galaxy S9

### Performance Goals
- **Frame Rate**: Consistent 60fps
- **Texture Memory**: <100MB total for all assets
- **Draw Calls**: <50 per frame
- **Triangle Count**: <100k total visible triangles

## Phase 1: Asset Budget Planning

### 1.1 Define Budgets
- [ ] Calculate total triangle budget
  - Symbols: 8 assets × 2000 tris = 16k
  - Background: 10 elements × 1000 tris = 10k
  - Effects: 20 instances × 500 tris = 10k
  - UI: 5k triangles
  - **Total: ~41k triangles**

- [ ] Calculate texture memory budget
  - Symbols: 8 × 1024² × 4 bytes = ~32MB
  - Backgrounds: 1024² × 4 bytes = ~4MB (atlased)
  - Effects: 512² × 4 bytes = ~1MB
  - **Total: ~37MB uncompressed**

### 1.2 Set Per-Asset Limits
- [ ] Document maximum values per asset type
- [ ] Share budget constraints with team via Telegram
- [ ] Integrate checks into pipeline validation

## Phase 2: Geometry Optimization

### 2.1 Triangle Count Reduction
- [ ] Review each asset's polygon count
- [ ] Identify and remove hidden/unnecessary faces
- [ ] Simplify areas not visible in gameplay
- [ ] Use decimation modifier in Blender if needed
- [ ] Target reductions:
  - Symbols: <2000 tris (hard limit)
  - Backgrounds: <1200 tris
  - Effects: <500 tris

### 2.2 LOD (Level of Detail) Setup
- [ ] Create LOD levels for prominent assets:
  - LOD0: 100% triangles (close view)
  - LOD1: 60% triangles (medium distance)
  - LOD2: 30% triangles (far distance)
- [ ] Configure LOD distances in Unity
- [ ] Test transitions for visual artifacts

### 2.3 Batching Optimization
- [ ] Group assets with shared materials
- [ ] Create texture atlases for symbol sets
- [ ] Ensure static objects are marked static
- [ ] Validate dynamic batching compatibility
- [ ] Target: Reduce draw calls by 50%

## Phase 3: Texture Optimization

### 3.1 Texture Resolution
- [ ] Audit all texture sizes
- [ ] Reduce resolution where possible:
  - Background distant elements: 512×512
  - Repeated patterns: 256×256
  - Small effects: 256×256 or less
- [ ] Maintain 1024×1024 only for primary symbols

### 3.2 Texture Compression
- [ ] Configure Unity texture import settings:
  - **iOS**: PVRTC or ASTC
  - **Android**: ETC2
  - **Quality**: Normal (not High Quality)
- [ ] Enable "Generate Mip Maps" for 3D objects
- [ ] Disable "Read/Write Enabled" to save memory
- [ ] Use "Clamp" wrap mode where appropriate

### 3.3 Texture Atlasing
- [ ] Combine related textures into atlases
- [ ] Group by material type (opaque, transparent, emissive)
- [ ] Pack efficiently using Unity Sprite Packer or manual tools
- [ ] Update UV coordinates and materials
- [ ] Target: 3-4 texture atlases maximum

### 3.4 Channel Packing
- [ ] Pack multiple maps into single textures:
  - Metallic (R) + Smoothness (A) + Occlusion (G)
  - Combine grayscale maps to save memory
- [ ] Adjust shader to read from correct channels
- [ ] Validate visual quality after packing

## Phase 4: Shader and Material Optimization

### 4.1 Shader Selection
- [ ] Use Unity Mobile shaders where possible
- [ ] Prefer simpler shaders (Mobile/Diffuse, Mobile/Specular)
- [ ] Avoid expensive features:
  - Avoid parallax mapping
  - Limit transparency/alpha blending
  - Minimize shader keywords

### 4.2 Material Consolidation
- [ ] Reduce total material count
- [ ] Reuse materials across assets where appropriate
- [ ] Share material instances for same properties
- [ ] Target: <10 unique materials

### 4.3 Lighting Optimization
- [ ] Use baked lighting where possible
- [ ] Minimize real-time lights
- [ ] Prefer Light Probes over per-pixel lighting
- [ ] Disable shadows for most assets
- [ ] Enable shadows only for key focal elements

## Phase 5: Animation and Effects Optimization

### 5.1 Animation Efficiency
- [ ] Reduce keyframe count in animations
- [ ] Use animation compression in Unity
- [ ] Limit bone count for skinned meshes (<30 bones)
- [ ] Share animation clips across similar objects

### 5.2 Particle System Optimization
- [ ] Limit max particle count (<50 per emitter)
- [ ] Use simple particle sprites
- [ ] Disable collision for particles
- [ ] Reduce particle size with distance
- [ ] Use GPU instancing where possible
- [ ] Cull particles not visible to camera

### 5.3 Effect Object Optimization
- [ ] Use billboards for distant effects
- [ ] Implement object pooling for repeated effects
- [ ] Disable effects when off-screen
- [ ] Limit effect duration to minimum needed

## Phase 6: Unity Build Settings

### 6.1 Graphics API
- [ ] iOS: Metal
- [ ] Android: Vulkan with OpenGL ES 3.0 fallback
- [ ] Disable unused graphics APIs

### 6.2 Quality Settings
- [ ] Create mobile-specific quality preset
- [ ] Configure settings:
  - Pixel Light Count: 1
  - Texture Quality: Medium
  - Anisotropic Textures: Per Texture
  - Anti Aliasing: 2x or disabled
  - Soft Particles: Disabled
  - Shadows: Soft shadows, low resolution

### 6.3 Build Options
- [ ] Enable "Strip Engine Code"
- [ ] Use IL2CPP for better performance
- [ ] Enable "Optimize Mesh Data"
- [ ] Configure compression (LZ4 for faster loading)

## Phase 7: Profiling and Testing

### 7.1 Unity Profiler Analysis
- [ ] Profile on actual devices (not simulator)
- [ ] Monitor key metrics:
  - CPU: <16ms per frame (60fps)
  - GPU: <16ms per frame
  - Memory: Total heap <200MB
  - Rendering: Draw calls, triangles, vertices
  - Scripts: Update/LateUpdate time

### 7.2 Device-Specific Testing
- [ ] Test on minimum spec device
- [ ] Verify thermal performance (no throttling)
- [ ] Check battery consumption
- [ ] Test various screen resolutions
- [ ] Validate aspect ratio handling

### 7.3 Optimization Iteration
- [ ] Identify bottlenecks from profiler
- [ ] Prioritize issues by impact
- [ ] Implement optimizations incrementally
- [ ] Re-test after each change
- [ ] Document changes and results

## Phase 8: Validation and Documentation

### 8.1 Performance Validation
- [ ] Confirm 60fps on all target devices
- [ ] Verify memory stays within budgets
- [ ] Check build size (<150MB)
- [ ] Validate load times (<5 seconds)

### 8.2 Documentation
- [ ] Record final asset specifications
- [ ] Document optimization techniques used
- [ ] Note any trade-offs or compromises
- [ ] Update standards and guidelines
- [ ] Share findings via Telegram and in `/constitution/MEMORY.md`

## Optimization Checklist Summary

**Geometry:**
- [x] All assets under triangle budget
- [x] LOD implemented for key assets
- [x] Draw calls minimized through batching

**Textures:**
- [x] Compression enabled (ETC2/PVRTC)
- [x] Appropriate resolutions used
- [x] Texture atlasing implemented
- [x] Channel packing applied

**Materials:**
- [x] Mobile shaders used
- [x] Material count minimized
- [x] Lighting optimized

**Performance:**
- [x] 60fps on target devices
- [x] Memory within budget
- [x] No thermal throttling

## Common Mobile Issues and Solutions

| Issue | Solution |
|-------|----------|
| Low frame rate | Reduce triangle count, optimize shaders |
| High memory usage | Compress textures, reduce resolution |
| Excessive draw calls | Texture atlasing, static batching |
| Long load times | Compress assets, use AssetBundles |
| Thermal throttling | Reduce GPU work, limit particles |
| Visual artifacts | Check normal maps, validate UVs |

## Tools and Resources

- Unity Profiler
- Unity Frame Debugger
- Xcode Instruments (iOS)
- Android Studio Profiler
- RenderDoc for GPU analysis

## Continuous Improvement

After each project, review optimization results and update this workflow with new techniques and lessons learned.
