# Egyptian MVP Pipeline Workflow

## Overview
End-to-end workflow for developing the Egyptian-themed slot game MVP using the Clawd pipeline. This workflow integrates Kimi K-2.5 LLM, Meshy.ai, Unity, Blender, and Slack.

## Phase 1: Concept & Planning

### 1.1 Requirements Gathering
- [ ] Game designer posts theme requirements in Slack
- [ ] Kimi processes requirements and creates technical spec
- [ ] Team reviews and approves via Slack
- [ ] Mood board and reference materials collected

### 1.2 Asset List Definition
- [ ] Define all required symbols (10-12 symbols typical)
- [ ] Identify backgrounds needed (main game + bonus)
- [ ] List win effects and animations
- [ ] Prioritize assets for MVP scope

**Deliverable**: Asset specification document in `/prompts/meshy-ai/`

## Phase 2: Asset Generation

### 2.1 Symbol Generation (Meshy.ai)
- [ ] Submit symbol prompts to Meshy.ai (batch similar styles)
- [ ] Review generated models
- [ ] Iterate on any assets that don't meet standards
- [ ] Download approved models (FBX format)

**Timeline**: 2-3 days for complete symbol set

### 2.2 Background Generation (Meshy.ai)
- [ ] Generate main game background
- [ ] Generate bonus round background(s)
- [ ] Create any 3D environment elements
- [ ] Export at appropriate resolution

**Timeline**: 1-2 days

### 2.3 Effect Generation (Meshy.ai)
- [ ] Generate particle textures and elements
- [ ] Create any 3D props for effects
- [ ] Export particle sprites and meshes

**Timeline**: 1 day

## Phase 3: Asset Refinement (Blender)

### 3.1 Symbol Optimization
- [ ] Import all symbols into Blender
- [ ] Clean up topology and remove artifacts
- [ ] Optimize poly count (target: 3K-5K tris)
- [ ] Ensure proper UV mapping
- [ ] Apply PBR materials (metallic/roughness)
- [ ] Bake lighting if needed
- [ ] Export as optimized FBX

**Timeline**: 0.5 days per symbol (5-6 days total with batching)

### 3.2 Background Processing
- [ ] Import backgrounds to Blender
- [ ] Optimize for mobile (reduce complexity)
- [ ] Create parallax layers if needed
- [ ] Export textures at 4K (downsample later)
- [ ] Export 3D elements separately

**Timeline**: 1-2 days

### 3.3 Quality Check
- [ ] Verify all assets meet standards (see `/standards/`)
- [ ] Check naming conventions
- [ ] Validate file formats and sizes
- [ ] Test in Blender viewport for performance

## Phase 4: Unity Integration

### 4.1 Project Setup
- [ ] Create Unity project (URP template)
- [ ] Set up folder structure
- [ ] Configure mobile build settings
- [ ] Import asset pipeline tools

**Timeline**: 0.5 days

### 4.2 Asset Import
- [ ] Import all symbols and configure
- [ ] Import backgrounds and set up layers
- [ ] Create materials in Unity URP
- [ ] Configure texture compression for mobile

**Timeline**: 1 day

### 4.3 Effect Implementation
- [ ] Create particle systems for win effects
- [ ] Implement animations and tweens
- [ ] Set up sound effect triggers
- [ ] Configure pooling for performance

**Timeline**: 2-3 days

### 4.4 Game Logic
- [ ] Implement reel spin mechanics
- [ ] Configure paytable
- [ ] Set up win line detection
- [ ] Implement bonus features
- [ ] Add UI elements

**Timeline**: 3-5 days

## Phase 5: Optimization & Testing

### 5.1 Mobile Optimization
- [ ] Profile on target devices (see `/workflows/mobile-optimization.md`)
- [ ] Create LOD levels for symbols
- [ ] Optimize draw calls and batching
- [ ] Compress textures appropriately
- [ ] Test memory usage

**Timeline**: 2-3 days

### 5.2 QA Testing
- [ ] Test all win combinations
- [ ] Verify animations and effects
- [ ] Check for visual bugs
- [ ] Test on multiple devices
- [ ] Verify performance targets met

**Timeline**: 2-3 days

### 5.3 Polish
- [ ] Adjust timings and animations
- [ ] Fine-tune particle effects
- [ ] Balance visual intensity
- [ ] Final art direction review

**Timeline**: 1-2 days

## Phase 6: Delivery

### 6.1 Build & Deploy
- [ ] Create mobile builds (iOS/Android)
- [ ] Run automated tests
- [ ] Deploy to staging environment
- [ ] Stakeholder review via Slack

**Timeline**: 1 day

### 6.2 Documentation
- [ ] Update `/constitution/MEMORY.md` with learnings
- [ ] Document any new patterns or issues
- [ ] Create handoff documentation
- [ ] Archive project files

**Timeline**: 0.5 days

## Total Timeline Estimate
**MVP Development**: 25-35 days (5-7 weeks)

## Communication Protocol

### Daily Updates
- Post progress in Slack channel
- Share preview images/videos
- Flag blockers immediately

### Weekly Reviews
- Demo current build
- Review against milestones
- Adjust priorities if needed

### Approval Gates
- Concept approval before asset generation
- Asset approval before Unity integration
- Build approval before deployment

## Success Metrics
- [ ] All symbols render at 60 FPS on target devices
- [ ] Asset memory budget < 150MB
- [ ] Build size < 100MB
- [ ] No critical bugs in QA
- [ ] Visual quality approved by art director

## Tools & Resources
- Kimi K-2.5: Coordination and code assistance
- Slack: Communication and approvals
- Meshy.ai: Asset generation
- Blender 3.x: Asset refinement
- Unity 2021.3 LTS: Game development
- GitHub: Version control
