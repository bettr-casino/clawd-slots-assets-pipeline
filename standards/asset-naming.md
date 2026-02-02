# Asset Naming Conventions

## Overview

Consistent naming conventions ensure clarity, prevent conflicts, and enable automation across the asset pipeline.

## General Rules

1. **Use lowercase with hyphens** for all file names
   - ✅ `egyptian-scarab-symbol.fbx`
   - ❌ `EgyptianScarabSymbol.fbx`
   - ❌ `egyptian_scarab_symbol.fbx`

2. **Use descriptive, hierarchical naming**
   - Format: `{theme}-{type}-{variant}-{detail}.{extension}`
   - Example: `egyptian-symbol-scarab-gold.fbx`

3. **Avoid version numbers in file names**
   - Use version control (Git) instead
   - ❌ `scarab-v2-final.fbx`

4. **No spaces or special characters**
   - Only use: lowercase letters, numbers, hyphens
   - ❌ `scarab (final).fbx`
   - ❌ `scarab&symbol.fbx`

5. **Keep names under 50 characters**
   - Long names are difficult to work with
   - Be concise but descriptive

## Category-Specific Conventions

### Symbols (Reel Icons)

**Format**: `{theme}-symbol-{name}-{variant}`

Examples:
- `egyptian-symbol-scarab-gold`
- `egyptian-symbol-ra-eye-blue`
- `egyptian-symbol-ankh-standard`
- `egyptian-symbol-pyramid-stone`
- `egyptian-symbol-pharaoh-wild`
- `egyptian-symbol-scatter-special`

**Variants**:
- `standard` - Default version
- `gold`, `silver`, `bronze` - Material variants
- `wild`, `scatter` - Special game function
- `animated` - If separate animated version

### Background Elements

**Format**: `{theme}-bg-{layer}-{element}-{variant}`

Examples:
- `egyptian-bg-far-pyramids-sunset`
- `egyptian-bg-mid-temple-columns`
- `egyptian-bg-near-hieroglyph-wall`
- `egyptian-bg-far-sand-dunes`
- `egyptian-bg-mid-sphinx-statue`

**Layers**:
- `far` - Distant background layer
- `mid` - Middle ground layer
- `near` - Foreground layer

### Win Effects

**Format**: `{theme}-fx-{effect-type}-{element}`

Examples:
- `egyptian-fx-particle-coin-gold`
- `egyptian-fx-glow-aura-golden`
- `egyptian-fx-burst-scarab-swarm`
- `egyptian-fx-beam-pyramid-light`
- `egyptian-fx-sparkle-ankh-twinkle`

**Effect Types**:
- `particle` - Particle system objects
- `glow` - Emissive/glow effects
- `burst` - Explosive/expanding effects
- `beam` - Directional light effects
- `sparkle` - Small twinkle effects

### UI Elements

**Format**: `{theme}-ui-{element}-{state}`

Examples:
- `egyptian-ui-button-spin-normal`
- `egyptian-ui-button-spin-pressed`
- `egyptian-ui-frame-win-display`
- `egyptian-ui-border-decorative`
- `egyptian-ui-icon-settings`

### Animations

**Format**: `{asset-name}-anim-{animation-name}`

Examples:
- `egyptian-symbol-scarab-anim-idle`
- `egyptian-symbol-scarab-anim-win`
- `egyptian-symbol-pharaoh-anim-expand`
- `egyptian-fx-coin-anim-spin`

**Animation Names**:
- `idle` - Idle/default animation
- `win` - Win celebration animation
- `spin` - Rotation animation
- `expand` - Scaling up animation
- `collapse` - Scaling down animation

## File Extensions

### 3D Assets
- `.fbx` - Primary 3D model format (from Meshy.ai or Blender)
- `.blend` - Blender working files
- `.obj` - Legacy/interchange format (rarely used)

### Textures
- `.png` - Source texture files (before Unity import)
- `.tga` - Alternative source format
- `.psd` - Photoshop source files (if applicable)

### Materials
- `.mat` - Unity material files (auto-generated)

### Animations
- `.anim` - Unity animation clips (auto-generated)

### Prefabs
- `.prefab` - Unity prefab files (auto-generated)

## Unity Asset Organization

### Folder Structure

```
Assets/
├── Egyptian/
│   ├── Models/
│   │   ├── Symbols/
│   │   │   ├── egyptian-symbol-scarab-gold.fbx
│   │   │   └── egyptian-symbol-ra-eye-blue.fbx
│   │   ├── Backgrounds/
│   │   │   ├── egyptian-bg-far-pyramids-sunset.fbx
│   │   │   └── egyptian-bg-mid-temple-columns.fbx
│   │   └── Effects/
│   │       ├── egyptian-fx-particle-coin-gold.fbx
│   │       └── egyptian-fx-glow-aura-golden.fbx
│   ├── Textures/
│   │   ├── Symbols/
│   │   ├── Backgrounds/
│   │   └── Effects/
│   ├── Materials/
│   │   ├── Symbols/
│   │   ├── Backgrounds/
│   │   └── Effects/
│   ├── Animations/
│   └── Prefabs/
│       ├── Symbols/
│       ├── Backgrounds/
│       └── Effects/
```

### Texture Naming

**Format**: `{asset-name}-{map-type}`

Examples:
- `egyptian-symbol-scarab-gold-albedo.png`
- `egyptian-symbol-scarab-gold-normal.png`
- `egyptian-symbol-scarab-gold-metallic.png`
- `egyptian-symbol-scarab-gold-roughness.png`
- `egyptian-symbol-scarab-gold-ao.png` (ambient occlusion)
- `egyptian-symbol-scarab-gold-emissive.png`

**Map Types**:
- `albedo` - Base color/diffuse map
- `normal` - Normal map
- `metallic` - Metallic map
- `roughness` - Roughness/smoothness map
- `ao` - Ambient occlusion map
- `emissive` - Emission map
- `opacity` - Transparency map (if needed)

### Material Naming

**Format**: `{asset-name}-mat`

Examples:
- `egyptian-symbol-scarab-gold-mat`
- `egyptian-bg-far-pyramids-sunset-mat`
- `egyptian-fx-glow-aura-golden-mat`

### Prefab Naming

**Format**: `{asset-name}-prefab`

Examples:
- `egyptian-symbol-scarab-gold-prefab`
- `egyptian-bg-mid-temple-columns-prefab`
- `egyptian-fx-particle-coin-gold-prefab`

## Automation and Validation

### Naming Validation Script

A validation script should check:
- All lowercase with hyphens only
- Correct category prefix
- No version numbers
- Length under 50 characters
- Proper file extensions

### Batch Renaming

When renaming multiple files:
1. Use consistent pattern
2. Test on a few files first
3. Verify in version control before committing
4. Update any references in code/scenes

## Theme Prefixes

Current themes:
- `egyptian-` - Egyptian/Ancient Egypt theme
- `viking-` - Viking/Norse theme (future)
- `ocean-` - Ocean/Underwater theme (future)
- `space-` - Space/Sci-fi theme (future)

## Best Practices

1. **Name assets immediately upon creation**
   - Don't use temporary names like "test" or "temp"

2. **Be consistent within a project**
   - Use the same variant names across all assets

3. **Consider sorting and filtering**
   - Names that sort well are easier to manage

4. **Document custom conventions**
   - If you need to deviate, document why

5. **Communicate naming changes**
   - Notify team via Slack if conventions change

## Common Mistakes to Avoid

- ❌ Inconsistent capitalization: `Egyptian-Symbol` vs `egyptian-symbol`
- ❌ Mixed separators: `egyptian_symbol-scarab`
- ❌ Generic names: `symbol1`, `background`, `effect`
- ❌ Redundant information: `egyptian-symbol-egyptian-scarab`
- ❌ Platform-specific characters: `symbol:gold`, `symbol/variant`

## Renaming Existing Assets

If you need to rename assets already in use:
1. Create rename script/mapping
2. Test in development branch
3. Update all references in scenes/prefabs
4. Coordinate timing with team via Slack
5. Document in commit message
