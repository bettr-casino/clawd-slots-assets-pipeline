# Win Effects - Meshy.ai Prompts

## General Settings

- **Style**: Low-poly, animated effect objects
- **Target Triangle Count**: 300-500
- **Texture Resolution**: 512x512 (effects are often animated/particle-based)
- **Material**: PBR with emissive properties
- **Export Format**: FBX with animation support

## Effect Object Prompts

### Golden Glow Aura

```
Create a low-poly glowing aura effect for Egyptian slot game wins.
Circular/radial design with Egyptian motif patterns.
Game-ready model, clean topology, approximately 400 triangles.
Include PBR textures: emissive gold albedo, subtle normal map for detail.
Designed to scale and animate (pulsing, expanding) in Unity.
Simple geometry suitable for shader-based animation.
```

### Coin Burst

```
Create a low-poly ancient Egyptian coin for win effect animations.
Circular coin with hieroglyphic or pharaoh profile on faces.
Game-ready model, clean topology, approximately 300 triangles.
Include PBR textures: metallic gold albedo, normal map for embossed details.
Lightweight for use in particle systems (multiple instances).
Will be animated in Unity for cascading/bursting effects.
```

### Scarab Particle

```
Create a low-poly miniature scarab beetle for particle win effects.
Simplified Egyptian scarab design suitable for small scale display.
Game-ready model, clean topology, approximately 250 triangles.
Include PBR textures: golden metallic material, minimal normal detail.
Ultra-lightweight for particle systems with many instances.
Will be animated flying/swarming around winning symbols.
```

### Ra Sun Disc

```
Create a low-poly Egyptian sun disc (solar symbol) for win effects.
Circular disc with radiating rays and winged motif.
Game-ready model, clean topology, approximately 500 triangles.
Include PBR textures: bright emissive albedo, golden rays, detailed normal map.
Center piece for major win celebrations.
Designed to rotate and emit particles in Unity.
```

### Pyramid Beam

```
Create a low-poly pyramid with light beam for win effects.
Small pyramid emitting upward light/energy beam.
Game-ready model, clean topology, approximately 400 triangles.
Include PBR textures: stone base with emissive beam material.
Designed for scaling animation (beam extending upward).
Suitable for progressive win indicators.
```

### Ankh Sparkle

```
Create a low-poly miniature Ankh symbol for sparkle/twinkle effects.
Simplified Ankh design suitable for small decorative particles.
Game-ready model, clean topology, approximately 200 triangles.
Include PBR textures: golden emissive material, high metallic value.
Ultra-lightweight for dense particle effects.
Will twinkle/spin around winning combinations.
```

### Hieroglyph Runes

```
Create a low-poly set of glowing hieroglyphic runes for win effects.
Individual symbols that float and glow during wins.
Game-ready models, clean topology, approximately 150-200 triangles each.
Include PBR textures: emissive glowing albedo with hieroglyph detail.
Multiple variations for variety in particle systems.
Lightweight for abundant use in celebration sequences.
```

## Animation Guidelines

**Suggested Animations** (to be created in Unity):
- **Scaling**: Expand/contract effects
- **Rotation**: Spinning coins, rotating sun discs
- **Emission**: Pulsing glow intensity
- **Translation**: Bursting/cascading movements
- **Opacity**: Fade in/out for lifetime

## Quality Checklist

- [ ] Triangle count minimal (200-500)
- [ ] Optimized for instancing (many copies)
- [ ] Emissive materials properly configured
- [ ] Suitable for Unity particle systems
- [ ] Clean geometry for shader effects
- [ ] Textures at 512x512 or lower
- [ ] Pivot points centered for rotation
- [ ] Scale appropriate for effect use
- [ ] LOD not necessary (effects are small/distant)
- [ ] Mobile performance validated
