# PBR Guidelines

## Overview

Physically Based Rendering (PBR) ensures assets look consistent and realistic across different lighting conditions. This document outlines PBR workflows and standards for casino slot game assets.

## PBR Fundamentals

### Core Principles

1. **Energy Conservation**: Surface never reflects more light than it receives
2. **Microsurface Detail**: Normal maps represent small-scale surface variation
3. **Metallic Workflow**: Clear distinction between metallic and non-metallic materials
4. **Real-World Values**: Use physically accurate material properties

### PBR Texture Maps

| Map Type | Purpose | Color Space |
|----------|---------|-------------|
| Albedo | Base color (no lighting) | sRGB |
| Normal | Surface detail/bumps | Linear |
| Metallic | Metal vs. non-metal | Linear |
| Roughness | Surface smoothness | Linear |
| Ambient Occlusion | Cavity shadows | Linear |
| Emissive | Self-illumination | sRGB |

## Texture Specifications

### Albedo Map (Base Color)

**Purpose**: Pure surface color without lighting information

**Guidelines**:
- No lighting, shadows, or highlights baked in
- Use reference values:
  - Gold: RGB(255, 215, 0) to (218, 165, 32)
  - Stone/Sandstone: RGB(200, 180, 150) to (160, 140, 110)
  - Lapis Lazuli Blue: RGB(38, 66, 139) to (26, 72, 118)
- Avoid pure black (0,0,0) or pure white (255,255,255)
- Typical value range: 30-240 for most surfaces
- Metals should have muted, desaturated colors
- Non-metals can be saturated

**Egyptian Theme Values**:
- Gold metal: RGB(255, 220, 100)
- Aged stone: RGB(180, 160, 130)
- Painted blue: RGB(40, 80, 150)
- Terracotta: RGB(180, 100, 70)

### Normal Map

**Purpose**: Adds surface detail without extra geometry

**Guidelines**:
- Use tangent-space normal maps (purple/blue appearance)
- DirectX format (Y+) for Unity
- Neutral value: RGB(128, 128, 255) for flat surface
- Bake from high-poly mesh or generate from albedo
- Intensity: Moderate for mobile (not extreme)
- Resolution: Match or half of albedo resolution

**Best Practices**:
- Use for hieroglyphics, engravings, surface texture
- Don't overdo detail (keep it readable from game distance)
- Test in-engine to ensure proper appearance
- Avoid seams on UV boundaries

### Metallic Map

**Purpose**: Defines which areas are metal (white) vs. non-metal (black)

**Guidelines**:
- Binary choice: 0 (non-metal) or 1 (metal)
- Gold, silver, copper: 1 (white)
- Stone, wood, fabric: 0 (black)
- No gradual transitions (not physically accurate)
- Can combine with roughness in same texture (metallic in R channel)

**Egyptian Materials**:
- Gold jewelry/symbols: 1 (metallic)
- Stone pyramids/walls: 0 (non-metallic)
- Bronze decorations: 1 (metallic)
- Painted surfaces: 0 (non-metallic)

### Roughness/Smoothness Map

**Purpose**: Defines surface glossiness

**Guidelines**:
- **Roughness**: 0 = smooth/glossy, 1 = rough/matte
- **Smoothness**: Inverse of roughness (0 = rough, 1 = smooth)
- Unity uses Smoothness by default
- Reference values:
  - Polished gold: 0.1 roughness (0.9 smoothness)
  - Brushed metal: 0.3-0.5 roughness
  - Matte stone: 0.8-0.9 roughness
  - Glossy paint: 0.2-0.3 roughness
- Add variation for realism (not uniform)

**Egyptian Materials**:
- Polished gold: 0.2 roughness
- Aged gold: 0.4 roughness
- Smooth stone: 0.6 roughness
- Weathered stone: 0.85 roughness
- Painted surfaces: 0.3-0.5 roughness

### Ambient Occlusion (AO)

**Purpose**: Adds soft shadows in crevices and corners

**Guidelines**:
- Grayscale: White (1) = no occlusion, Black (0) = full occlusion
- Bake from 3D model geometry
- Should be subtle (not too dark)
- Typically multiplied with albedo in Unity
- Resolution: Can be lower than albedo (512×512 often sufficient)

**Usage**:
- Bake in Blender or Meshy.ai
- Helps define depth in hieroglyphics and engravings
- Particularly useful for background elements
- Can be packed into texture channels (often G channel)

### Emissive Map

**Purpose**: Self-illuminating areas (glow effects)

**Guidelines**:
- Color of emitted light
- Used for magical effects, energy, highlights
- HDR values possible (>1.0 intensity)
- Should be black (0,0,0) where no emission
- Use sparingly for performance

**Egyptian Theme Usage**:
- Glowing hieroglyphics (magic effects)
- Eye of Ra glow
- Win celebration golden glow
- Scarab mystical energy

## Material Workflows

### Metallic/Roughness Workflow (Recommended)

**Texture Set**:
1. Albedo (RGB) - sRGB
2. Normal (RGB) - Linear
3. Metallic (R) + Roughness (G) + AO (B) - Linear (packed)
4. Emissive (RGB) - sRGB (if needed)

**Advantages**:
- Efficient: 3-4 textures total
- Good for mobile performance
- Clear material definitions

### Unity Standard Shader Setup

**Import Settings**:
```
Albedo Map:
- sRGB (Color Texture): ON
- Alpha Source: From Gray Scale (if transparency needed)

Normal Map:
- Texture Type: Normal map
- Create from Grayscale: OFF (if already normal map)

Metallic/Smoothness:
- sRGB: OFF (Linear)
- Alpha Source: From Gray Scale
```

**Material Properties**:
```
Rendering Mode: Opaque (default)
Metallic: Controlled by texture
Smoothness: Controlled by texture (Metallic Alpha channel)
Normal Map: Enabled, intensity 1.0
Occlusion: If separate map, strength 0.5-1.0
Emission: Only if emissive map present
```

## Mobile Optimization

### Texture Resolution

- **Symbols**: 1024×1024 (can reduce to 512×512 if needed)
- **Backgrounds**: 1024×1024 (distant elements: 512×512)
- **Effects**: 512×512 or 256×256

### Texture Compression

- **Android**: ETC2 (RGB or RGBA)
- **iOS**: PVRTC or ASTC
- **Quality**: Normal (not High Quality for mobile)

### Texture Packing

Combine maps to reduce texture count:
```
Combined Texture (RGBA):
- R: Metallic
- G: AO (Ambient Occlusion)
- B: Detail mask (optional)
- A: Smoothness
```

### Shader Simplification

For mobile:
- Use Unity Mobile shaders when possible
- Limit texture samples
- Disable features not needed (e.g., parallax)
- Avoid transparency/alpha blending where possible

## Texture Creation Workflow

### From Meshy.ai

1. **Generate** asset with PBR textures
2. **Download** FBX with embedded textures
3. **Extract** textures in Unity or Blender
4. **Validate** each map for correctness
5. **Optimize** resolution and compression

### Manual Creation

1. **Albedo**: Paint base colors (no lighting)
2. **Normal**: Bake from high-poly or generate from albedo
3. **Metallic**: Paint mask (white=metal, black=non-metal)
4. **Roughness**: Paint variation based on material
5. **AO**: Bake from 3D model
6. **Emissive**: Paint glow areas (optional)

### Texture Baking in Blender

**Ambient Occlusion**:
```
Render Properties > Bake
Bake Type: Ambient Occlusion
Samples: 64-128
Distance: 0.1-0.5 (adjust for scale)
```

**Normal Map**:
```
Bake Type: Normal
Space: Tangent
From high-poly to low-poly mesh
```

## Quality Assurance

### Validation Checklist

- [ ] Albedo has no lighting baked in
- [ ] Normal map appears purple/blue (tangent space)
- [ ] Metallic is binary (0 or 1, no gradients)
- [ ] Roughness has variation (not uniform)
- [ ] AO is subtle (not too dark)
- [ ] Emissive is black where no glow
- [ ] All textures are same resolution (or intentional mismatch)
- [ ] Correct color space (sRGB vs Linear)
- [ ] No visible seams on UVs

### Testing in Unity

1. **Import** all textures
2. **Assign** to Standard Shader material
3. **Test** under different lighting:
   - Direct light
   - Ambient light only
   - Point lights
4. **Verify** appearance matches expectations
5. **Check** on actual mobile device

## Common Mistakes

### Albedo Issues
- ❌ Baked lighting/shadows in albedo
- ❌ Too dark (pure black) or too bright (pure white)
- ❌ Oversaturated colors for metals

### Normal Map Issues
- ❌ Using OpenGL format (Y-) instead of DirectX (Y+)
- ❌ Saved as sRGB instead of Linear
- ❌ Too intense (extreme bumps)
- ❌ Seams visible at UV boundaries

### Metallic Issues
- ❌ Using gradients instead of binary values
- ❌ Wrong materials marked as metal
- ❌ Saved in sRGB color space

### Roughness Issues
- ❌ Uniform roughness across entire surface
- ❌ Too smooth (unrealistic mirror surfaces)
- ❌ Inverted (using roughness when shader expects smoothness)

## Egyptian Theme Material Library

### Gold (Polished)
- Albedo: RGB(255, 220, 100)
- Metallic: 1.0
- Smoothness: 0.85
- Normal: Subtle engravings

### Gold (Aged)
- Albedo: RGB(218, 165, 32)
- Metallic: 1.0
- Smoothness: 0.6
- Normal: Wear and scratches
- AO: Darker in crevices

### Sandstone
- Albedo: RGB(180, 160, 130)
- Metallic: 0.0
- Smoothness: 0.15
- Normal: Rough texture
- AO: Strong in carved areas

### Lapis Lazuli
- Albedo: RGB(40, 80, 150)
- Metallic: 0.0
- Smoothness: 0.7
- Normal: Polished surface

### Painted Surface
- Albedo: RGB(varies by paint color)
- Metallic: 0.0
- Smoothness: 0.5
- Normal: Slight texture

## Resources

- **PBR Guide**: https://learnopengl.com/PBR/Theory
- **Material Values**: https://docs.unrealengine.com/en-US/Engine/Rendering/Materials/PhysicallyBased/
- **Unity Standard Shader**: https://docs.unity3d.com/Manual/StandardShaderMaterialParameters.html
- **Texture.com**: Free PBR textures for reference

## Updates and Revisions

Document any project-specific PBR adjustments or discoveries in `/constitution/MEMORY.md` for future reference.
