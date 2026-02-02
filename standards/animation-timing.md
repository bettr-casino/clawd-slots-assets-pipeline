# Animation Timing Standards

## Overview

Consistent animation timing ensures responsive gameplay feel and optimal performance across casino slot game interactions and visual effects.

## Target Frame Rate

**Mobile Target**: 60 FPS (16.67ms per frame)
- All animations must perform smoothly at 60fps
- Budget no more than 8-10ms for animation systems
- Test on lowest-spec target device

## Animation Categories

### 1. Reel Spin Animations

**Reel Spin Duration**
- **Initial Spin**: 2.0-2.5 seconds
- **Deceleration**: 0.5-1.0 seconds per reel
- **Stagger**: 0.3-0.5 seconds between reels stopping

**Timing Pattern**:
```
Reel 1: Stops at 2.0s
Reel 2: Stops at 2.4s (+0.4s)
Reel 3: Stops at 2.8s (+0.4s)
Reel 4: Stops at 3.2s (+0.4s)
Reel 5: Stops at 3.6s (+0.4s)
```

**Easing**:
- Spin: Linear or slight ease-in-out
- Stop: Strong ease-out (deceleration curve)
- Anticipation: Small ease-in before stop (optional)

**Performance**:
- Max symbols visible: 15-20 simultaneously
- Update rate: Every frame (60fps)
- Use texture animation or sprite sheets for blur effect

### 2. Symbol Animations

**Idle/Breathing Animation**
- **Duration**: 2.0-4.0 seconds
- **Loop**: Seamless
- **Intensity**: Subtle (scale 0.98-1.02 or slight rotation ±2°)
- **Offset**: Randomize start time per symbol (avoid sync)

**Win Celebration**
- **Duration**: 1.0-1.5 seconds
- **Stages**:
  - Anticipation (0.1s): Slight scale down
  - Pop (0.3s): Scale up to 1.2x, brighten
  - Settle (0.6s): Return to 1.0x with bounce
- **Easing**: Elastic or bounce easing on pop
- **FX**: Spawn particles at peak (0.4s mark)

**Expand/Feature Trigger**
- **Duration**: 0.8-1.2 seconds
- **Expand**: Scale from 1.0x to 2.0-3.0x
- **Rotation**: Optional 360° spin during expansion
- **Glow**: Increase emissive intensity
- **Audio sync**: Peak animation at 0.5s for audio hit

**Anticipation (Pre-win)**
- **Duration**: 0.5-1.0 seconds
- **Effect**: Gentle wobble or glow pulse
- **Purpose**: Build tension before win reveal
- **Frequency**: 2-3 Hz wobble/pulse

### 3. Win Effect Animations

**Particle Burst**
- **Spawn Time**: 0.1s burst
- **Lifetime**: 1.0-2.0 seconds per particle
- **Count**: 20-50 particles per burst
- **Velocity**: Radial outward, slow decay
- **Gravity**: Slight downward pull after 0.5s

**Glow/Aura Effect**
- **Fade In**: 0.2 seconds
- **Hold**: 0.5-1.0 seconds
- **Pulse**: 1.0-2.0 second cycle (optional)
- **Fade Out**: 0.3 seconds
- **Total**: 1.0-3.5 seconds

**Coin Cascade**
- **Duration**: 2.0-4.0 seconds total
- **Spawn Rate**: 5-10 coins per second
- **Fall Speed**: 2-3 units per second
- **Bounce**: 1-2 bounces on landing
- **Despawn**: Fade out after 1.0s on ground

**Light Beam**
- **Rise Time**: 0.5 seconds
- **Hold**: 0.5-1.0 seconds
- **Dissipate**: 0.3 seconds
- **Total**: 1.3-1.8 seconds
- **Intensity**: Fade-in/fade-out curve

### 4. UI Animations

**Button Press**
- **Down**: 0.05 seconds (fast response)
- **Up**: 0.1 seconds
- **Scale**: 0.95x on press
- **Color**: Slight darken (0.9x)
- **Audio**: Trigger on press start

**Button Hover (Desktop)**
- **Scale**: 1.05x
- **Duration**: 0.15 seconds
- **Easing**: Ease-out

**Panel Slide In/Out**
- **Duration**: 0.3-0.5 seconds
- **Easing**: Ease-out for in, Ease-in for out
- **Distance**: Full screen width/height
- **Overshoot**: Optional 5% bounce on slide-in

**Number Counter (Win Amount)**
- **Duration**: 1.0-2.0 seconds
- **Easing**: Ease-out (fast start, slow end)
- **Increment**: Calculate to reach target smoothly
- **Audio**: Tick sound every 0.05-0.1s

### 5. Background Animations

**Parallax Scrolling**
- **Speed**: Based on layer depth
  - Far: 0.1x speed
  - Mid: 0.3x speed
  - Near: 0.6x speed
- **Update**: Every frame
- **Loop**: Seamless repeating texture

**Ambient Movement**
- **Duration**: 10-30 seconds per cycle
- **Intensity**: Very subtle (1-2% scale or position change)
- **Purpose**: Add life without distraction
- **Examples**:
  - Palm trees sway: 8 second cycle
  - Sand shimmer: 15 second cycle
  - Cloud drift: 30 second cycle

**Lighting Effects**
- **Day/Night**: 60+ seconds full cycle (if used)
- **Torch flicker**: 0.5-1.5 second random intervals
- **Glow pulse**: 2-4 second cycles

## Animation Implementation

### Unity Animation Clips

**Frame Rate**: 60 FPS for all animation clips
- Ensures smooth playback on target devices
- Matches game engine update rate

**Compression**: Keyframe reduction
- Unity: "Optimal" compression
- Remove redundant keyframes
- Maintain visual quality

**Loop Settings**:
- Enable "Loop Time" for idle animations
- Disable for one-shot animations (wins, transitions)
- Use "Loop Pose" for seamless loops

### Animator State Machines

**Transition Duration**:
- Fast transitions: 0.05-0.1 seconds (responsive)
- Smooth transitions: 0.2-0.3 seconds (blend)
- Keep transitions short for gameplay responsiveness

**State Priority**:
- Win > Spin > Idle
- Allow interrupts for immediate feedback

### Scripted Animations

**DOTween/LeanTween Settings**:
```csharp
// Scale animation example
transform.DOScale(1.2f, 0.5f)
    .SetEase(Ease.OutBack)
    .SetLoops(-1, LoopType.Yoyo);

// Recommended easing curves:
// - OutQuad: General smooth movement
// - OutBack: Bouncy, playful
// - InOutCubic: Balanced acceleration/deceleration
// - Linear: Constant speed (rare use)
```

**Performance**:
- Pool animation objects (don't instantiate during gameplay)
- Limit simultaneous tweens (<50 active)
- Use Update loops for critical animations
- Cache transform references

## Timing Guidelines by Context

### Big Win Sequence

```
0.0s: Reel stops, winning symbol highlights
0.2s: Symbol scale + glow start
0.5s: Audio hit, particle burst
0.8s: Win UI panel slides in
1.0s: Counter starts incrementing
2.5s: Counter reaches total
3.0s: Celebration effects peak
4.0s: Effects fade out
4.5s: Ready for next spin
```

**Total**: 4.5 seconds for big win

### Normal Win Sequence

```
0.0s: Reel stops, winning symbol highlights
0.2s: Symbol pop animation
0.5s: Particle effects
1.0s: Win amount display
1.5s: Effects fade, ready for next spin
```

**Total**: 1.5 seconds for normal win

### No Win Sequence

```
0.0s: Reel stops
0.3s: Brief pause
0.5s: Ready for next spin (no animations)
```

**Total**: 0.5 seconds for no win

## Mobile Optimization

### Performance Budget

- **CPU Time**: <5ms per frame for all animations
- **GPU Time**: <3ms per frame for animation shaders
- **Memory**: <10MB for animation data

### Optimization Techniques

1. **Keyframe Reduction**
   - Remove redundant keyframes
   - Use animation compression
   - Maintain visual quality

2. **LOD for Animations**
   - Disable distant background animations
   - Reduce particle count at low settings
   - Skip non-critical animations under load

3. **Culling**
   - Disable animations for off-screen objects
   - Use occlusion culling
   - Pause when not visible

4. **Batching**
   - Animate multiple objects with same timeline
   - Use GPU instancing for particles
   - Share animation data where possible

### Mobile-Specific Timing

- Reduce particle counts by 30-50%
- Simplify complex easing curves to linear/quad
- Limit simultaneous animations to 3-5 key elements
- Disable ambient background animations on low-end devices

## Animation Validation

### Testing Checklist

- [ ] Maintains 60fps on target devices
- [ ] No stuttering or frame drops
- [ ] Timing feels responsive (button press <100ms feedback)
- [ ] Animations complete before next interaction possible
- [ ] Smooth transitions between states
- [ ] No animation "popping" or sudden changes
- [ ] Audio sync matches animation peaks
- [ ] Loops seamlessly without visible seams
- [ ] Works correctly at different time scales (if implemented)

### Profiling

**Unity Profiler**:
- Monitor Animator.Update time
- Check Animation.Update time
- Validate particle system overhead
- Ensure no garbage collection spikes

**Target Values**:
- Animator: <2ms per frame
- Animation: <1ms per frame
- Particles: <3ms per frame

## Easing Reference

### Common Easing Curves

| Curve | Use Case | Feel |
|-------|----------|------|
| Linear | Constant motion (reels spinning) | Mechanical |
| Ease-In | Acceleration (reel starting) | Gradual start |
| Ease-Out | Deceleration (reel stopping) | Smooth stop |
| Ease-In-Out | Both acceleration and deceleration | Natural |
| Bounce | Playful, energetic (wins) | Fun, bouncy |
| Elastic | Exaggerated bounce (big wins) | Exciting |
| Back | Anticipation then overshoot | Dynamic |

### Timing Function Examples

```
Linear: Constant speed throughout
Ease-In-Quad: Slow start, accelerate
Ease-Out-Quad: Fast start, decelerate
Ease-In-Out-Quad: Slow start, fast middle, slow end
Bounce: Simulates bouncing physics
Elastic: Spring-like overshoot and settle
Back: Pull back before moving forward
```

## Audio Sync

### Synchronization Guidelines

- **Animation Peak** = **Audio Hit**
- Animation should reach peak moment at same time as audio impact
- Typical sync points:
  - Symbol lands: 0.0s (audio + visual)
  - Win pop: 0.3s (animation peak + audio hit)
  - Coin impact: Match visual bounce with audio clink

### Audio Cues

- Button press: Immediate (<10ms delay)
- Symbol land: Sync with visual stop
- Win trigger: 0.1-0.2s after reel stop
- Particle spawn: Sync with visual burst
- Counter increment: Audio tick matches visual update

## Best Practices

1. **Predictable Timing**
   - Players should learn timing patterns
   - Consistency across similar interactions
   - Clear anticipation for upcoming events

2. **Responsive Feedback**
   - Immediate response to input (<100ms)
   - Clear state changes
   - Satisfying animations for actions

3. **Performance First**
   - Never sacrifice frame rate for animation
   - Degrade gracefully on low-end devices
   - Test on minimum spec hardware

4. **Clarity Over Complexity**
   - Simple, readable animations
   - Avoid visual clutter
   - Focus attention on important elements

5. **Cultural Consistency**
   - Egyptian theme: Regal, ancient, mysterious
   - Animation style matches art style
   - Appropriate pacing for theme

## Documentation

After implementing animations, document:
- Actual durations used
- Any deviations from standards (with reason)
- Performance measurements
- Player feedback on timing

Update `/constitution/MEMORY.md` with findings for future projects.
