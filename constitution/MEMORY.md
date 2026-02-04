# MEMORY.md

## Project Knowledge Base

### CLEOPATRA Slots Research

**Research Status**: Initialized
- Phase: Awaiting start
- Current Step: Video shortlist creation
- Next Action: Search YouTube for CLEOPATRA gameplay videos

**Video Shortlist**: Not yet created
- Target: 5 high-quality videos of real Las Vegas CLEOPATRA machines
- Criteria: Clear reels, multiple spins, bonus features, good quality

**Selected Video**: Awaiting user selection

**Reel Configuration**: To be determined

**Symbol Inventory**: To be determined

**Game Mechanics**: To be determined

**Bonus Features**: To be determined

---

### Asset Library

**Egyptian Theme**
- Symbol sets: Scarab, Eye of Ra, Ankh, Pyramid, Sphinx
- Background elements: Temple columns, hieroglyphics, sand dunes
- Win effects: Golden glow, particle bursts, coin showers

**Asset Specifications**
- All Egyptian symbols: ~1500 triangles each
- Background elements: ~800-1200 triangles
- Effect objects: ~500 triangles

### Workflow History

**Successful Patterns**
- Meshy.ai prompt templates yield consistent results
- Batch processing reduces iteration time
- Early mobile testing prevents optimization issues
- Standardized naming prevents integration errors

**Lessons Learned**
- Triangle budgets must be enforced during generation, not after
- PBR textures require validation before Unity import
- Animation timing must account for mobile frame rates
- Asset dependencies should be documented immediately

### Technical Decisions

**Unity FBX Import**
- Axis conversion: -Z forward, Y up
- Scale factor: 1.0
- Normals: Import from model
- Materials: Extract and convert to Standard Shader

**Mobile Optimization**
- ETC2 texture compression mandatory
- Level of Detail (LOD) for assets >1000 tris
- Occlusion culling for background elements
- Texture atlasing for symbol sets

### Pipeline Configurations

**Meshy.ai Settings**
- Style: Low-poly, game-ready
- Poly count target: 1500-2000
- Texture resolution: 1024x1024
- Export format: FBX

**Blender Processing**
- Clean up geometry
- Optimize UVs
- Validate normals
- Export with Unity presets

## Active Projects

Current focus: Egyptian-themed MVP slot game with mobile optimization priority.

**CLEOPATRA Slots Research**: Heartbeat-driven reverse engineering of CLEOPATRA slots from YouTube videos.
- Status: Ready to begin
- Target: Real Las Vegas casino machine gameplay
- Deliverables: Reel configuration, symbol inventory, game mechanics documentation
- Updates: Every 30 minutes via Telegram
