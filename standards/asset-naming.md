# Asset Naming Conventions

## Overview
Consistent naming conventions ensure organization, searchability, and prevent conflicts in the asset pipeline. Follow these standards for all assets in the project.

## General Principles

### Format Structure
```
[AssetType]_[ThemeName]_[DescriptiveName]_[Variant]_[LOD]
```

### Rules
- Use PascalCase or snake_case consistently (snake_case preferred)
- No spaces (use underscores)
- No special characters except underscore and hyphen
- Keep names under 50 characters when possible
- Be descriptive but concise
- Use consistent abbreviations

## Asset Type Prefixes

### 3D Models
- `SM_` - Static Mesh (non-animated)
- `SKM_` - Skeletal Mesh (animated)
- `PROP_` - Prop/Pickup object

### Textures
- `T_` - Texture (generic)
- `TEX_` - Texture (alternative)

### Materials
- `M_` - Material
- `MI_` - Material Instance
- `MF_` - Material Function

### Animations
- `ANIM_` - Animation
- `AS_` - Animation Sequence

### Particles & Effects
- `VFX_` - Visual Effect
- `PS_` - Particle System
- `P_` - Particle (alternative)

### Audio
- `SFX_` - Sound Effect
- `MUS_` - Music
- `AMB_` - Ambient Sound

### UI
- `UI_` - UI Element
- `ICO_` - Icon
- `BTN_` - Button

### Prefabs (Unity)
- `PF_` - Prefab

## Theme Names

For Egyptian theme:
- `Egyptian`
- `Egypt`
- `EGY` (abbreviated)

Examples: `SM_Egyptian_Pharaoh`, `T_Egypt_Gold`

## Descriptive Names

### Symbols
```
SM_Egyptian_Pharaoh_Gold
SM_Egyptian_Cleopatra
SM_Egyptian_Ankh_Blue
SM_Egyptian_Scarab
SM_Egyptian_EyeOfHorus
SM_Egyptian_Pyramid
```

### Backgrounds
```
SM_Egyptian_Temple_Interior
SM_Egyptian_Tomb_Chamber
SM_Egyptian_Desert_Sunset
SM_Egyptian_ThroneRoom
```

### Effects
```
VFX_Egyptian_CoinBurst
VFX_Egyptian_GoldSparkle
VFX_Egyptian_WinGlow
PS_Egyptian_SandParticles
```

## Texture Naming

### Format
```
T_[AssetName]_[TextureType]_[Resolution]
```

### Texture Type Suffixes
- `_A` or `_Albedo` - Base color/Albedo
- `_N` or `_Normal` - Normal map
- `_M` or `_Metallic` - Metallic map
- `_R` or `_Roughness` - Roughness map
- `_AO` - Ambient Occlusion
- `_E` or `_Emission` - Emissive map
- `_H` or `_Height` - Height map
- `_O` or `_Opacity` - Opacity/Alpha
- `_MR` - Metallic + Roughness packed
- `_ORM` - Occlusion + Roughness + Metallic packed

### Examples
```
T_Egyptian_Pharaoh_A_2K.png
T_Egyptian_Pharaoh_N_2K.png
T_Egyptian_Pharaoh_MR_2K.png
T_Egyptian_Gold_A_1K.png
```

## Material Naming

### Format
```
M_[AssetName]_[MaterialType]
```

### Examples
```
M_Egyptian_Gold_PBR
M_Egyptian_Stone_Weathered
MI_Egyptian_Pharaoh_Gold (Material Instance)
```

## Animation Naming

### Format
```
ANIM_[AssetName]_[ActionName]
```

### Examples
```
ANIM_Egyptian_Scarab_Fly
ANIM_Egyptian_Symbol_Spin
ANIM_Egyptian_Coin_Flip
```

## Particle System Naming

### Format
```
PS_[ThemeName]_[EffectName]
```

### Examples
```
PS_Egyptian_CoinBurst
PS_Egyptian_GoldSparkle
PS_Egyptian_SandSwirl
PS_Egyptian_WinGlow
```

## Audio Naming

### Format
```
[AudioType]_[Context]_[DescriptiveName]
```

### Examples
```
SFX_Win_CoinShower
SFX_Symbol_Land
SFX_Reel_Spin
MUS_Egyptian_MainTheme
AMB_Egyptian_TempleWind
```

## LOD (Level of Detail) Naming

### Suffix Format
```
_LOD0  (highest detail)
_LOD1
_LOD2
_LOD3  (lowest detail)
```

### Examples
```
SM_Egyptian_Pharaoh_LOD0
SM_Egyptian_Pharaoh_LOD1
SM_Egyptian_Pharaoh_LOD2
```

## Variant Naming

When creating variants of the same asset:

### Numeric Variants
```
SM_Egyptian_Scarab_01
SM_Egyptian_Scarab_02
SM_Egyptian_Scarab_03
```

### Descriptive Variants
```
SM_Egyptian_Pharaoh_Gold
SM_Egyptian_Pharaoh_Silver
SM_Egyptian_Pharaoh_Bronze
```

### Color Variants
```
T_Egyptian_Gem_Red
T_Egyptian_Gem_Blue
T_Egyptian_Gem_Green
```

## Folder Structure

Organize assets in folders matching their type:

```
Assets/
├── Models/
│   ├── Symbols/
│   │   └── Egyptian/
│   └── Backgrounds/
│       └── Egyptian/
├── Textures/
│   ├── Symbols/
│   │   └── Egyptian/
│   └── Backgrounds/
│       └── Egyptian/
├── Materials/
│   └── Egyptian/
├── Animations/
│   └── Egyptian/
├── Effects/
│   └── Egyptian/
├── Audio/
│   ├── SFX/
│   ├── Music/
│   └── Ambient/
└── Prefabs/
    └── Egyptian/
```

## Special Cases

### Temporary Assets
Prefix with `TEMP_` or place in `/Temp/` folder:
```
TEMP_SM_Egyptian_Test
```

### Work-in-Progress
Prefix with `WIP_`:
```
WIP_SM_Egyptian_NewSymbol
```

### Archived Assets
Move to `/Archive/` folder or prefix with `OLD_`:
```
OLD_SM_Egyptian_Symbol_v1
```

## Version Control

When versioning assets (avoid if possible, prefer Git):
```
SM_Egyptian_Pharaoh_v01
SM_Egyptian_Pharaoh_v02
SM_Egyptian_Pharaoh_v03
```

Better approach: Use Git branches and commits for versioning.

## Export Naming

When exporting for different platforms:

```
SM_Egyptian_Pharaoh_Mobile
SM_Egyptian_Pharaoh_Desktop
SM_Egyptian_Pharaoh_Web
```

Or use platform folders:
```
Assets/
├── Mobile/
├── Desktop/
└── Web/
```

## Validation Checklist

Before committing assets, verify:
- [ ] Follows naming convention format
- [ ] No spaces in name
- [ ] No special characters (except _ and -)
- [ ] Appropriate prefix used
- [ ] Descriptive and searchable
- [ ] Consistent with similar assets
- [ ] LOD suffix if applicable
- [ ] Version suffix avoided (use Git instead)
- [ ] Located in correct folder

## Tools

### Unity Asset Renamer
Use scripting to batch rename assets:
```csharp
// Example Unity Editor script
// Place in Editor folder
```

### Blender Batch Rename
Use Blender's built-in batch rename:
- Select objects
- Right-click → Rename
- Use Find/Replace

## Common Mistakes to Avoid

❌ `pharaoh gold.fbx` - Has space
❌ `Egyptian-Pharaoh-Gold.fbx` - Use underscores, not hyphens for separators
❌ `pharaohgold.fbx` - Not descriptive enough
❌ `EgyptianPharaohWithGoldenHeaddress.fbx` - Too verbose
✅ `SM_Egyptian_Pharaoh_Gold.fbx` - Perfect!

## Quick Reference

**Models**: `SM_Theme_Name_Variant_LOD#.fbx`
**Textures**: `T_Name_Type_Resolution.png`
**Materials**: `M_Name_Type`
**Effects**: `VFX_Theme_Effect`
**Audio**: `SFX_Context_Name`
