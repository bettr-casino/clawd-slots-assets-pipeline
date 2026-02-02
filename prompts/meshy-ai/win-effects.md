# Win Effects - Meshy.ai Prompts

## Overview
Particle effects, animations, and celebratory visuals for wins, bonuses, and special features in Egyptian-themed slots. Balance visual impact with mobile performance.

## Standard Win Effects

### Golden Coin Burst
```
Explosion of golden Egyptian coins with hieroglyphic engravings, spinning and tumbling through air, glowing particles, warm golden light rays, celebratory but not overwhelming, game particle effect
```

### Hieroglyphic Symbols Swirl
```
Glowing Egyptian hieroglyphic symbols floating and swirling in magical pattern, bright gold and turquoise colors, mystical energy trails, celebratory animation for slot game win
```

### Scarab Flight
```
Group of golden scarab beetles flying in formation leaving sparkle trails, magical and elegant motion, warm lighting, celebration effect for slot game
```

## Big Win Effects

### Pyramid Power Blast
```
Egyptian pyramid releasing powerful golden energy beam upward, hieroglyphic symbols orbiting, dramatic light rays, ground particles lifting, epic big win effect for slot game
```

### Pharaoh's Blessing
```
Golden pharaoh face materializing with divine radiance, shimmering particles, ethereal glow, god rays, majestic and powerful, big win celebration effect
```

### Treasure Shower
```
Cascade of golden treasures, coins, jewels, and artifacts falling from above with impact sparkles, abundant and celebratory, big win animation for slots
```

## Feature Triggers

### Free Spins Portal
```
Swirling Egyptian portal opening with hieroglyphics rotating around edge, mystical blue and gold energy, sand particles being pulled in, gateway animation for bonus feature
```

### Bonus Unlock
```
Ancient Egyptian door or seal breaking open with golden light bursting out, hieroglyphic fragments floating away, magical unlock effect for bonus game
```

### Multiplier Build
```
Egyptian ankh symbol glowing brighter with pulsing energy rings, numbers forming in hieroglyphic style, power-up sensation, multiplier increase effect
```

## Wild Transformations

### Wild Expansion
```
Golden scarab transforming into expanding ankh symbol with ripple effect, hieroglyphic particles, mystical transformation, wild symbol expansion animation
```

### Sticky Wild Lock
```
Symbol position getting sealed with golden Egyptian seal, hieroglyphic lock effect, chain animation locking in place, sticky wild mechanic visual
```

## Ambient Effects

### Win Line Trace
```
Golden energy line tracing winning symbol combination, hieroglyphic trail effect, elegant flowing motion, highlights winning payline in slots
```

### Symbol Glow
```
Winning symbol surrounded by pulsing golden aura, subtle particle sparkles, hieroglyphic rings emanating outward, attention-drawing but not distracting
```

### Anticipation Build
```
Subtle sand particles and mystical sparkles gathering around reels before big reveal, building tension, pre-win anticipation effect
```

## Style Guidelines
- **Performance**: Optimize for mobile (limit particle count)
- **Duration**: 1-3 seconds for normal wins, 3-5 for big wins
- **Colors**: Gold primary, blue/turquoise accents
- **Transparency**: Use alpha carefully for mobile performance
- **Scale**: Adjust intensity based on win size
- **Audio Sync**: Design with audio cues in mind

## Technical Specifications
- **Particle Count**: 50-200 for normal, 200-500 for big wins
- **Texture Size**: 512x512 or 1024x1024 for particle sprites
- **Animation**: 24-30 FPS for smooth motion
- **Blending**: Additive for glows, alpha blend for smoke/dust
- **Layers**: Foreground effects in front of symbols

## Unity Integration
- Use Unity Particle System (Shuriken)
- Create prefabs for each effect type
- Implement pooling for performance
- Support different device quality tiers
- Test on target mobile devices

## Variation Notes
- Create 3-5 variants of each effect for variety
- Randomize some parameters (rotation, scale, speed)
- Tier effects: small win, medium win, big win, mega win
- Consider cultural sensitivity in designs
