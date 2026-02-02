# PBR Guidelines - Physically Based Rendering

## Overview
Standards for creating PBR (Physically Based Rendering) materials for slot game assets. Ensures visual consistency, realistic lighting, and optimal performance across devices.

## PBR Workflow

### Metallic/Roughness Workflow
We use the **metallic/roughness** workflow (not specular/glossiness) for consistency with Unity URP and mobile optimization.

### Core Texture Maps
1. **Albedo/Base Color** - RGB channels
2. **Normal** - RGB channels (tangent space)
3. **Metallic** - Grayscale (often packed)
4. **Roughness** - Grayscale (often packed)
5. **Ambient Occlusion (AO)** - Grayscale (often baked into albedo)
6. **Emission** - RGB channels (optional, use sparingly)

## Albedo Map Guidelines

### Color Range
- **Avoid pure white** (255, 255, 255) - Use (240, 240, 240) max
- **Avoid pure black** (0, 0, 0) - Use (15, 15, 15) min
- Keep values in realistic range: 50-240 for most surfaces
- Use color picker from photo references

### Material-Specific Albedo Values

**Metals (before metallic):**
- Gold: RGB (255, 215, 0) to (212, 175, 55)
- Silver: RGB (192, 192, 192) to (180, 180, 180)
- Bronze: RGB (205, 127, 50) to (140, 85, 30)
- Copper: RGB (184, 115, 51)

**Non-Metals:**
- Stone: RGB (140, 130, 120) to (180, 170, 160)
- Wood: RGB (160, 120, 80) to (120, 80, 50)
- Fabric: RGB (100, 90, 85) to (200, 190, 180)
- Gemstones: Saturated colors, values 150-220

### Albedo Rules
- No lighting information (no shadows, highlights, or AO)
- Use AO in separate map or bake into albedo for mobile
- Uniform lighting (should look flat)
- Detail comes from normal and roughness, not albedo
- Use texture for color variation, not shading

## Metallic Map Guidelines

### Value Ranges
- **Metallic (1.0)**: Pure metals (gold, silver, bronze, steel)
  - Value: 255 (white)
- **Non-Metallic (0.0)**: Everything else (stone, wood, fabric, paint)
  - Value: 0 (black)
- **No in-between values** - Binary decision (0 or 255)

### Common Metals in Egyptian Theme
- Gold ornaments: 255 (fully metallic)
- Silver details: 255 (fully metallic)
- Bronze accents: 255 (fully metallic)
- Painted metal: 0 (non-metallic - paint is not metal)

### Common Non-Metals
- Stone (limestone, sandstone): 0
- Painted surfaces: 0
- Fabrics: 0
- Gemstones: 0 (gems are dielectric)
- Wood: 0

## Roughness Map Guidelines

### Value Ranges
- **0.0 (Smooth)**: Value 0 (black) - Mirror finish, polished metal
- **0.5 (Semi-rough)**: Value 128 (mid-gray) - Most common surfaces
- **1.0 (Rough)**: Value 255 (white) - Matte, diffuse surfaces

### Material-Specific Roughness

**Smooth (0.0 - 0.3):**
- Polished gold: 0.2
- Glass: 0.05
- Polished stone: 0.3
- Water: 0.0

**Medium (0.3 - 0.7):**
- Painted metal: 0.5
- Most stone: 0.6
- Wood (varnished): 0.4
- Most fabrics: 0.7

**Rough (0.7 - 1.0):**
- Sand: 0.9
- Rough stone: 0.8
- Unfinished wood: 0.8
- Fabric (matte): 0.9

### Roughness Rules
- Vary roughness for visual interest (use subtle texture)
- Scratches and wear increase roughness
- Fingerprints and smudges decrease roughness locally
- Edge wear typically reduces roughness on metals

## Normal Map Guidelines

### Tangent Space
- Use tangent-space normals (standard)
- RGB channels: R=X, G=Y, B=Z
- Blue-dominant appearance (Z pointing up)
- Value range: 0-255 (normalized to -1 to 1)

### Strength
- **High Detail (0.5 - 1.0)**: Close-up viewing, hero assets
- **Medium Detail (0.3 - 0.5)**: Standard symbols
- **Low Detail (0.1 - 0.3)**: Background objects, mobile optimization

### Best Practices
- Bake from high-poly to low-poly in Blender
- Use consistent tangent space calculation
- Avoid pure flat blue (128, 128, 255) - add subtle detail
- Consider mip-map appearance at distance
- Test under different lighting conditions

## Ambient Occlusion (AO)

### Purpose
- Simulates indirect shadow in crevices
- Adds depth perception
- Multiplied with albedo or used separately

### For Mobile
- Bake AO into albedo to save texture lookups
- Multiply AO (grayscale) with albedo (RGB)
- Keep AO subtle (0.5 - 1.0 range, not 0 - 1.0)

### For Desktop/High-End
- Use separate AO map
- Blend in shader for flexibility
- Can be real-time (SSAO) or baked

## Texture Packing

### Standard Packing
To optimize texture usage, pack multiple grayscale maps:

**ORM Pack** (Recommended):
- **R**: Ambient Occlusion
- **G**: Roughness
- **B**: Metallic
- **A**: (unused or height)

**MR Pack** (Alternative):
- **R**: Metallic
- **G**: Roughness
- **B**: (unused)
- **A**: Transparency (if needed)

### Benefits
- Reduces texture count from 3-4 to 1
- Better for mobile (fewer texture lookups)
- Standard in many engines including Unity

## Emission Map

### When to Use
- Glowing effects (magic, energy)
- Self-illuminated objects (lamps, crystals)
- Highlights and sparkles
- Use sparingly for performance

### Guidelines
- Start with albedo as base
- Add glow in emission (bright values: 200-255)
- Control intensity with material parameters
- Consider HDR values for bloom effect
- Optimize for mobile (emission is expensive)

## Material Values Reference

### Egyptian Theme Examples

**Polished Gold:**
- Albedo: RGB (212, 175, 55)
- Metallic: 1.0 (255)
- Roughness: 0.2 (51)
- AO: Subtle in crevices

**Weathered Stone (Sandstone):**
- Albedo: RGB (194, 178, 128)
- Metallic: 0.0 (0)
- Roughness: 0.7 (179)
- AO: Strong in gaps

**Lapis Lazuli (Gemstone):**
- Albedo: RGB (38, 97, 156)
- Metallic: 0.0 (0)
- Roughness: 0.3 (77)
- AO: Minimal

**Painted Wood:**
- Albedo: RGB (varies by paint)
- Metallic: 0.0 (0)
- Roughness: 0.6 (153)
- AO: In grain and edges

## Texture Resolution

### Symbol Assets
- **Desktop**: 2K (2048x2048)
- **Mobile**: 1K (1024x1024)
- **Low-End**: 512x512

### Background Assets
- **Desktop**: 4K (4096x4096)
- **Mobile**: 2K (2048x2048)
- **Low-End**: 1K (1024x1024)

### Compression
- Use appropriate compression per platform
- ASTC or PVRTC for iOS
- ETC2 for Android
- Maintain quality in roughness/metallic

## Blender Setup

### PBR Material Node Setup
```
Image Texture (Albedo) → Principled BSDF (Base Color)
Image Texture (Normal) → Normal Map → Principled BSDF (Normal)
Image Texture (ORM) → Separate RGB:
  - R → Principled BSDF (Ambient Occlusion via mix)
  - G → Principled BSDF (Roughness)
  - B → Principled BSDF (Metallic)
```

### Baking Settings
- Use Cycles render engine for baking
- Bake with sufficient samples (128-256)
- Use Blender's built-in PBR workflow
- Export to Unity-compatible formats

## Unity Setup

### URP/Lit Shader
- Use URP/Lit as standard
- Import textures correctly:
  - Albedo: sRGB color space
  - Normal: Normal map type
  - ORM: Linear color space
- Set up material properties
- Enable GPU instancing

### Material Parameters
- Smoothness source: Albedo Alpha or Metallic/Roughness
- Metallic/Smoothness map in appropriate slot
- Normal map with appropriate strength
- Emission if needed (keep intensity low)

## Quality Assurance

### Checklist
- [ ] Albedo has no lighting information
- [ ] Metallic is binary (0 or 255)
- [ ] Roughness values are in realistic range
- [ ] Normal map is tangent space
- [ ] AO baked into albedo for mobile
- [ ] Textures are power-of-2 dimensions
- [ ] Correct sRGB vs Linear color space
- [ ] Materials use consistent workflow
- [ ] Tested under different lighting
- [ ] Performance acceptable on target device

## Testing

### Visual Tests
- Test under neutral lighting
- Test in target game lighting
- Verify metal appearance
- Check edge definition
- Review at different distances

### Technical Tests
- Profile texture memory usage
- Check shader compilation
- Verify batching compatibility
- Test on target devices
- Measure draw calls

## Common Mistakes

❌ Baked lighting in albedo
❌ Gray values in metallic map (should be 0 or 255)
❌ Roughness too uniform (add variation)
❌ Normal map too strong (subtle is better)
❌ Pure black or white in albedo
✅ Clean separation of maps
✅ Realistic material values
✅ Optimized for target platform

## Resources

- **Disney PBR Guide**: Industry standard reference
- **Substance Academy**: Texture creation tutorials
- **Unity PBR Documentation**: Engine-specific guidelines
- **Real-world References**: Photo reference libraries
