# Mobile Optimization Workflow

## Overview
Comprehensive workflow for optimizing social casino slot assets and games for mobile devices. Focuses on performance, memory usage, and visual quality balance.

## Target Devices & Specifications

### Minimum Spec (Low-End)
- **Device**: iPhone 8, Samsung Galaxy A series (2018-2020)
- **GPU**: Apple A11, Adreno 506
- **RAM**: 2GB
- **Resolution**: 750x1334 to 1080x1920
- **Target FPS**: 30 FPS stable

### Target Spec (Mid-Range)
- **Device**: iPhone 11/12, Samsung Galaxy S20
- **GPU**: Apple A13/A14, Adreno 650
- **RAM**: 4GB
- **Resolution**: 1125x2436 to 1440x3040
- **Target FPS**: 60 FPS

### High Spec (High-End)
- **Device**: iPhone 13/14/15, Samsung Galaxy S22/S23
- **GPU**: Apple A15+, Adreno 730
- **RAM**: 6GB+
- **Resolution**: 1170x2532 to 1440x3200
- **Target FPS**: 60 FPS with enhanced effects

## Performance Budgets

### Rendering Budget
- **Draw Calls**: < 50 per frame
- **Triangles**: < 100K per frame
- **Vertices**: < 150K per frame
- **Fill Rate**: < 50M pixels per frame
- **Shader Instructions**: < 50 per material

### Memory Budget
- **Textures**: < 100MB
- **Meshes**: < 20MB
- **Audio**: < 30MB
- **Code & Other**: < 50MB
- **Total Runtime**: < 200MB

### Asset Budget (Per Symbol)
- **Triangles**: 3K-5K
- **Texture**: 2K max (1K preferred)
- **Draw Calls**: 1 per symbol
- **Materials**: 1 per symbol

## Optimization Workflow

## Step 1: Asset Preparation (Blender)

### 1.1 Mesh Optimization
```
- [ ] Use Decimate modifier for poly reduction
- [ ] Target triangle count: 3K-5K per symbol
- [ ] Remove hidden/interior geometry
- [ ] Merge vertices (threshold: 0.001)
- [ ] Remove doubles and loose geometry
- [ ] Optimize edge flow for deformation
```

### 1.2 UV Optimization
```
- [ ] Single UV map per mesh
- [ ] Maximize UV space utilization (>80%)
- [ ] Avoid overlapping UVs (unless intentional)
- [ ] Maintain texel density consistency
- [ ] Pack UVs efficiently
```

### 1.3 Material Setup
```
- [ ] Use PBR metallic/roughness workflow
- [ ] Limit to 1 material per object
- [ ] Combine textures where possible (RGB packing)
- [ ] Avoid complex shader networks
- [ ] Bake complex lighting to textures
```

### 1.4 LOD Creation
```
- [ ] LOD0: Full detail (100%)
- [ ] LOD1: 60% triangle count
- [ ] LOD2: 30% triangle count
- [ ] Test visual quality at typical viewing distances
- [ ] Set up LOD switching distances
```

## Step 2: Texture Optimization

### 2.1 Texture Resolution
```
High Priority (Symbols):
- [ ] Albedo: 2048x2048 → downsample to 1024 for mobile
- [ ] Normal: 1024x1024
- [ ] Metallic/Roughness: 1024x1024 (packed)
- [ ] AO: Bake into albedo

Backgrounds:
- [ ] Main BG: 2048x2048 (mobile), 4096x4096 (tablet)
- [ ] Detail textures: 1024x1024
- [ ] Particle sprites: 512x512
```

### 2.2 Texture Compression
```
iOS:
- [ ] RGB: PVRTC 4bpp or ASTC 6x6
- [ ] RGBA: PVRTC 4bpp or ASTC 6x6
- [ ] Normal maps: ASTC 6x6

Android:
- [ ] RGB: ETC2
- [ ] RGBA: ETC2 with alpha
- [ ] Normal maps: ETC2 or ASTC 6x6
```

### 2.3 Texture Atlasing
```
- [ ] Combine small textures into atlases
- [ ] Use Unity Sprite Atlas for UI
- [ ] Maintain power-of-2 dimensions
- [ ] Add 2-pixel padding between sprites
- [ ] Group by usage pattern (loading together)
```

## Step 3: Unity Optimization

### 3.1 Project Settings
```
Quality Settings:
- [ ] Disable shadows for low-end devices
- [ ] Limit pixel light count to 1-2
- [ ] Reduce shadow distance to 20m
- [ ] Use low-quality shadows
- [ ] Disable anti-aliasing or use FXAA

Graphics Settings:
- [ ] Use URP (Universal Render Pipeline)
- [ ] Enable SRP Batcher
- [ ] Enable GPU Instancing
- [ ] Disable HDR rendering for mobile
- [ ] Set appropriate color space (Linear preferred)
```

### 3.2 Material Optimization
```
- [ ] Use URP/Lit or URP/SimpleLit shaders
- [ ] Minimize shader variants
- [ ] Avoid transparent materials (use alpha cutout)
- [ ] Batch materials where possible
- [ ] Use shader LOD
```

### 3.3 Rendering Optimization
```
Static Batching:
- [ ] Mark non-moving objects as static
- [ ] Use static batching for backgrounds
- [ ] Combine static meshes where beneficial

Dynamic Batching:
- [ ] Keep vertex count < 300 per mesh
- [ ] Use same material across objects
- [ ] Avoid scaling on batched objects

GPU Instancing:
- [ ] Enable on repeated symbols
- [ ] Use for particle systems
- [ ] Verify instancing is working (Frame Debugger)
```

### 3.4 Particle Optimization
```
- [ ] Limit particle count: 50-200 per effect
- [ ] Use simple particle shaders
- [ ] Prefer Mesh particles over Billboard
- [ ] Disable collision on particles
- [ ] Use pooling for particle systems
- [ ] Limit simultaneous particle systems to 3-5
```

## Step 4: Code Optimization

### 4.1 Object Pooling
```csharp
// Implement pooling for frequently spawned objects
- [ ] Pool symbol instances
- [ ] Pool particle effects
- [ ] Pool UI elements
- [ ] Prewarm pools on load
```

### 4.2 Update Loop Optimization
```csharp
- [ ] Minimize Update() calls
- [ ] Use FixedUpdate only when necessary
- [ ] Cache component references
- [ ] Avoid GetComponent in loops
- [ ] Use object pooling instead of Instantiate/Destroy
```

### 4.3 Animation Optimization
```
- [ ] Use Animation Events instead of polling
- [ ] Disable Animator when not animating
- [ ] Use Animator culling modes
- [ ] Prefer DOTween for simple animations
- [ ] Avoid complex state machines
```

## Step 5: Testing & Profiling

### 5.1 Unity Profiler
```
Monitor:
- [ ] CPU usage (target: < 16ms per frame for 60fps)
- [ ] GPU usage
- [ ] Memory allocation
- [ ] GC allocations (minimize per frame)
- [ ] Draw calls and batching efficiency
```

### 5.2 Device Testing
```
Test on actual devices:
- [ ] Frame rate (use on-screen display)
- [ ] Battery drain
- [ ] Device temperature
- [ ] Memory warnings
- [ ] Loading times
```

### 5.3 Memory Profiling
```
- [ ] Take memory snapshot on low-end device
- [ ] Identify largest assets
- [ ] Check for memory leaks
- [ ] Verify proper unloading
- [ ] Test extended play sessions
```

## Step 6: Quality Tiers

### 6.1 Device Detection
```csharp
// Implement device quality detection
- [ ] Detect device capabilities on startup
- [ ] Set quality tier (Low/Medium/High)
- [ ] Adjust settings accordingly
- [ ] Allow manual override in settings
```

### 6.2 Quality Settings Per Tier

**Low Tier (30 FPS target):**
- Use LOD2 models
- 1K textures maximum
- Simplified particle effects
- No shadows
- Minimal post-processing

**Medium Tier (60 FPS target):**
- Use LOD1 models
- 2K textures
- Standard particle effects
- Simple shadows
- Basic post-processing (bloom)

**High Tier (60 FPS+ target):**
- Use LOD0 models
- 2K textures
- Full particle effects
- Dynamic shadows
- Full post-processing

## Checklist: Pre-Release Optimization

- [ ] All symbols under 5K triangles
- [ ] All textures compressed appropriately
- [ ] Static batching enabled for backgrounds
- [ ] GPU instancing enabled where applicable
- [ ] Object pooling implemented
- [ ] LODs created and configured
- [ ] Particle counts optimized
- [ ] Quality tiers implemented
- [ ] Tested on minimum spec device
- [ ] Memory budget met
- [ ] No GC allocations during gameplay
- [ ] Loading times < 5 seconds
- [ ] APK/IPA size < 100MB

## Tools & Commands

### Unity Built-in Tools
- Frame Debugger: Analyze draw calls
- Profiler: Monitor performance
- Memory Profiler: Track memory usage
- Build Report: Analyze build size

### External Tools
- RenderDoc: GPU debugging
- Xcode Instruments: iOS profiling
- Android Profiler: Android profiling
