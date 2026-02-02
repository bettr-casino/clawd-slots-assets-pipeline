# Animation Timing Standards

## Overview
Standardized timing guidelines for animations in social casino slot games. Ensures responsive gameplay, consistent pacing, and optimal player experience.

## Core Principles

### Feel
- **Responsive**: Players should feel in control
- **Satisfying**: Animations should feel complete and polished
- **Clear**: Communicate game state and outcomes clearly
- **Performant**: Maintain target frame rate at all times

### Timing Philosophy
- **Fast enough**: Don't bore players
- **Slow enough**: Don't confuse players
- **Consistent**: Similar actions should take similar time
- **Tunable**: Use variables, not hard-coded values

## Reel Spin Animations

### Spin Start (Anticipation)
- **Duration**: 100-150ms
- **Easing**: Ease Out Cubic
- **Purpose**: Quick acceleration into spin

### Main Spin Loop
- **Speed**: 20-30 symbols/second per reel
- **Duration**: 1.5-3.0 seconds (adjustable by player)
- **Easing**: Linear (constant speed)
- **Variation**: Each reel stops with 200-400ms stagger

### Spin Stop (Landing)
- **Duration**: 150-200ms per reel
- **Easing**: Ease Out Back (slight overshoot)
- **Bounce**: 1-2 symbols of overshoot, then settle
- **Purpose**: Satisfying landing feel

### Quick Spin (Player Option)
- **Total Duration**: 0.8-1.2 seconds
- **Start**: 50ms
- **Main Spin**: 0.5-0.8s
- **Stop**: 100ms per reel

### Example Timing Sequence
```
Normal Spin:
- Start: 0.15s
- Spin: 2.0s
- Reel 1 Stop: 0.2s (at 2.15s)
- Reel 2 Stop: 0.2s (at 2.35s)
- Reel 3 Stop: 0.2s (at 2.55s)
- Reel 4 Stop: 0.2s (at 2.75s)
- Reel 5 Stop: 0.2s (at 2.95s)
Total: 3.15s

Quick Spin:
- Start: 0.05s
- Spin: 0.6s
- Reel 1-5 Stop: 0.1s each (0.05s stagger)
Total: 0.9s
```

## Symbol Animations

### Symbol Land
- **Duration**: 100-150ms
- **Easing**: Ease Out Quad
- **Effect**: Slight squash/stretch or bounce
- **Purpose**: Feedback that symbol has landed

### Symbol Anticipation (Pre-Win)
- **Duration**: 500-800ms
- **Animation**: Pulse, glow, or subtle shake
- **Purpose**: Build tension before revealing win
- **Frequency**: 1-2 symbols at most

### Symbol Highlight (Win)
- **Duration**: 300-500ms
- **Easing**: Ease In Out Sine
- **Animation**: Scale up 1.1-1.2x, glow pulse
- **Repetitions**: 2-3 times
- **Purpose**: Draw attention to winning symbols

### Wild Symbol Transform
- **Duration**: 400-600ms
- **Easing**: Ease Out Back
- **Animation**: Expand from center with particle burst
- **Purpose**: Exciting transformation

## Win Animations

### Small Win (1x - 5x bet)
- **Duration**: 800-1200ms
- **Particle Duration**: 600ms
- **Sound Peak**: 200-300ms in
- **Win Amount Display**: Fade in over 200ms
- **Purpose**: Quick acknowledgment

### Medium Win (5x - 20x bet)
- **Duration**: 1500-2000ms
- **Particle Duration**: 1200ms
- **Win Line Trace**: 300-500ms
- **Win Amount Display**: Count up over 500-800ms
- **Purpose**: Satisfying celebration

### Big Win (20x - 100x bet)
- **Duration**: 2500-4000ms
- **Particle Duration**: 2000ms
- **Camera**: Slight zoom or shake
- **Win Amount Display**: Count up over 1500-2500ms
- **Screen Effect**: Fade/flash overlay 200ms
- **Purpose**: Memorable excitement

### Mega Win (100x+ bet)
- **Duration**: 4000-6000ms
- **Particle Duration**: 3000ms
- **Camera**: Dramatic zoom/movement
- **Win Amount Display**: Slow dramatic count up
- **Screen Effect**: Multiple pulses/flashes
- **Celebration**: Full screen effect
- **Purpose**: Epic moment

### Win Count-Up
- **Algorithm**: Exponential or logarithmic speed
- **Start**: Fast initial counting
- **End**: Slow down as approaching final value
- **Skip**: Allow player to tap to complete instantly
- **Sound**: Tick sound per increment (throttled)

```javascript
// Example count-up timing
duration = baseTime * log(winAmount)
start_speed = 0.01s per increment
end_speed = 0.1s per increment
// Exponential easing between start and end speeds
```

## UI Animations

### Button Press
- **Duration**: 100-150ms
- **Easing**: Ease Out Quad
- **Scale**: 0.95x on press, 1.0x on release
- **Purpose**: Tactile feedback

### Button Hover (Desktop)
- **Duration**: 200ms
- **Easing**: Ease Out Sine
- **Scale/Glow**: 1.05x or subtle glow
- **Purpose**: Visual affordance

### Panel Transition
- **Duration**: 300-400ms
- **Easing**: Ease In Out Cubic
- **Type**: Slide, fade, or scale
- **Purpose**: Smooth state change

### Modal Open/Close
- **Open**: 250-350ms (Ease Out Back)
- **Close**: 200-250ms (Ease In Cubic)
- **Background Fade**: 200ms
- **Purpose**: Clear hierarchy

### Notification Toast
- **Slide In**: 300ms (Ease Out Cubic)
- **Display**: 2000-4000ms
- **Slide Out**: 250ms (Ease In Cubic)
- **Purpose**: Non-intrusive info

## Particle Effects

### Coin Burst (Small Win)
- **Spawn Duration**: 200ms
- **Particle Lifetime**: 800-1200ms
- **Count**: 20-50 particles
- **Velocity**: Medium

### Coin Shower (Big Win)
- **Spawn Duration**: 800ms
- **Particle Lifetime**: 1500-2500ms
- **Count**: 100-200 particles
- **Velocity**: Fast at start, slow at end

### Sparkle Effect
- **Duration**: 600-1000ms
- **Particle Lifetime**: 400-800ms
- **Count**: 10-30 particles
- **Purpose**: Magical enhancement

### Glow Pulse
- **Duration**: 800-1200ms (loop)
- **Easing**: Sine wave
- **Intensity**: 0.5x to 1.5x
- **Purpose**: Attention draw

## Bonus Features

### Free Spins Trigger
- **Transition In**: 800-1200ms
- **Celebration**: 2000-3000ms
- **Transition Out**: 800-1200ms
- **Total**: 3600-5400ms
- **Purpose**: Big moment, worth the time

### Free Spin Individual
- **Duration**: 60-80% of normal spin
- **Auto-play**: Slightly faster progression
- **Purpose**: Faster pace in bonus

### Wheel Spin (Bonus Wheel)
- **Acceleration**: 300-500ms
- **Full Speed**: 1500-2000ms
- **Deceleration**: 1000-1500ms
- **Final Tick**: 100-150ms per segment
- **Total**: 3000-4500ms
- **Purpose**: Build anticipation

### Pick Game
- **Object Reveal**: 300-500ms per pick
- **Outcome Display**: 800-1200ms
- **Between Picks**: 300-500ms delay
- **Purpose**: Clear progression

## Idle Animations

### Symbol Idle (Attract Mode)
- **Duration**: 3000-5000ms (loop)
- **Easing**: Ease In Out Sine
- **Animation**: Subtle float or pulse
- **Purpose**: Visual interest when not playing

### Background Ambient
- **Duration**: 5000-10000ms (loop)
- **Animation**: Gentle movement (particles, lighting)
- **Purpose**: Atmosphere without distraction

### UI Pulsing (Call-to-Action)
- **Duration**: 1500-2000ms (loop)
- **Easing**: Sine wave
- **Scale**: 1.0x to 1.05x
- **Purpose**: Gentle prompting

## Easing Functions Reference

### Common Easing Types
- **Linear**: Constant speed (use rarely)
- **Ease In**: Slow start, fast end (closing, hiding)
- **Ease Out**: Fast start, slow end (opening, showing)
- **Ease In Out**: Slow start, slow end (smooth transitions)

### Specific Easings
- **Ease Out Back**: Overshoot then settle (satisfying stop)
- **Ease Out Elastic**: Bouncy spring effect (playful)
- **Ease Out Bounce**: Multiple bounces (cartoonish)
- **Ease In Out Cubic**: Smooth and professional

### When to Use
- **Ease Out Cubic**: Most UI and symbol animations
- **Ease Out Back**: Reel stops, button releases
- **Ease In Out Sine**: Gentle loops and cycles
- **Linear**: Constant motion (reel spinning)

## Performance Considerations

### Frame Rate Targets
- **Desktop**: 60 FPS (16.67ms per frame)
- **Mobile High**: 60 FPS (16.67ms per frame)
- **Mobile Low**: 30 FPS (33.33ms per frame)

### Animation Budget
- **Active Animations**: Maximum 10-15 simultaneous
- **Particle Systems**: Maximum 5 active
- **Tweens**: Lightweight, use extensively
- **Skeletal Animations**: Minimize on mobile

### Optimization Tips
- Use object pooling for particles
- Cull animations off-screen
- Use simplified animations for low-tier devices
- Pre-calculate complex animations
- Disable animations on background apps

## Testing & Tuning

### Playtest Questions
- Does it feel too slow? (reduce by 20%)
- Does it feel too fast? (increase by 20%)
- Can player skip/speed up? (should be yes)
- Is it satisfying? (iterate on easing)
- Does it maintain frame rate? (optimize)

### A/B Testing
- Test timing variations with players
- Measure engagement and retention
- Consider player preferences options
- Balance excitement vs. pacing

### Variables to Expose
```csharp
// Example configuration
[SerializeField] float spinDuration = 2.0f;
[SerializeField] float reelStopDelay = 0.2f;
[SerializeField] float symbolBounce = 1.2f;
[SerializeField] float winDurationMultiplier = 1.0f;
// Allow designers to tune without code changes
```

## Animation Checklist

Before finalizing animations:
- [ ] Consistent timing with similar actions
- [ ] Appropriate easing for context
- [ ] Player can skip/speed up if > 2 seconds
- [ ] Maintains target frame rate
- [ ] Feels responsive and satisfying
- [ ] Clear communication of game state
- [ ] Tested on minimum spec device
- [ ] Audio synced with visual timing
- [ ] Tunable via configuration
- [ ] Documented in this guide

## Tools & Implementation

### Unity Animation Tools
- **DOTween**: Excellent for tweening (recommended)
- **Animator**: For complex skeletal animations
- **Coroutines**: Simple sequential timing
- **Timeline**: For cinematic sequences

### Code Example (DOTween)
```csharp
// Reel stop with bounce
symbol.transform.DOMoveY(targetY, 0.2f)
    .SetEase(Ease.OutBack)
    .OnComplete(() => OnSymbolLanded());

// Win count-up
DOTween.To(
    () => displayedAmount,
    x => displayedAmount = x,
    finalAmount,
    2.0f
).SetEase(Ease.OutCubic);
```

## References
- **Game Feel by Steve Swink**: Foundational timing concepts
- **The Illusion of Life**: Disney's animation principles
- **Juice It or Lose It**: GDC talk on game feel
- **Easing Functions Cheat Sheet**: easings.net
