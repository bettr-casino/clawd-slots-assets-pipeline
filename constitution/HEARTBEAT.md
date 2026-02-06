# HEARTBEAT.md — Autonomous Execution Cycle

## Heartbeat Interval

**30 minutes** — Every 30 minutes, the agent checks its state and advances work.

## Heartbeat Cycle

```
┌─────────────────────────────────────┐
│         HEARTBEAT TRIGGERED         │
│            (every 30 min)           │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│       1. READ MEMORY.md            │
│       Check current phase/step      │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│       2. DETERMINE NEXT ACTION      │
│       Based on current state        │
└──────────────┬──────────────────────┘
               │
        ┌──────┴──────┐
        ▼             ▼
   ┌─────────┐  ┌──────────┐
   │ Phase 1 │  │ Phase 2  │
   │Selection│  │ Analysis │
   └────┬────┘  └────┬─────┘
        │             │
        ▼             ▼
┌─────────────────────────────────────┐
│       3. EXECUTE STEP               │
│       Do work for current step      │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│       4. CHECKPOINT                 │
│       Update MEMORY.md              │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│       5. COMMUNICATE                │
│       Telegram update if needed     │
└─────────────────────────────────────┘
```

## Phase 1 Heartbeat Actions

| State | Action |
|-------|--------|
| `idle` / no search done | Run search query (default to popular 4K Cleopatra search from last 24 months if none provided), evaluate results |
| Search done, top 5 not sent | Send top 5 to Ron via Telegram |
| Top 5 sent, no response | Wait (do nothing) |
| User said "redo" | Run new search with refined query |
| User selected a video | Transition to Phase 2 |

## Phase 2 Heartbeat Actions

| State | Action |
|-------|--------|
| Video selected, no metadata | Extract video metadata |
| Metadata done, no transcript | Extract transcript/captions |
| Transcript done, no frames | Capture video frames |
| Frames captured, not analyzed | Analyze frames with AI vision |
| Analysis done, no research | Do supplementary web research |
| Research done, no spreadsheet | Generate math model spreadsheet |
| Spreadsheet done, not sent | Send summary + file to Ron via Telegram |
| Summary sent | Mark phase complete, return to idle |

## Heartbeat Rules

1. **One step per heartbeat**: Complete one meaningful step, checkpoint, then yield
2. **Never skip checkpointing**: Always update MEMORY.md after work
3. **Respect user wait**: If waiting for user input, don't do busy work
4. **Log everything**: Every heartbeat should produce a log entry
5. **Handle errors in-cycle**: If a step fails, try fallback, log error, checkpoint

## Idle Behavior

When both phases are complete (or no work is pending):
- Check MEMORY.md for `phase: idle`
- Send no messages
- Do nothing until triggered by user via Telegram
