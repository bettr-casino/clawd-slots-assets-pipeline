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
               ▼
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
| `idle` / no filename | Ask the human for a base filename (default: `CLEOPATRA`); strip `.webm` if provided |
| Filename set, URL not confirmed | Confirm YouTube URL (default: `https://www.youtube.com/watch?v=Ks8o3bl7OYQ`) |
| URL confirmed, timestamps not requested | Ask whether to extract timestamps |
| Timestamps provided, frames not extracted | Run `/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh` for each timestamp (auto-downloads if missing) |
| Frames extracted | Mark phase complete and return to idle |

## Heartbeat Rules

1. **One step per heartbeat**: Complete one meaningful step, checkpoint, then yield
2. **Never skip checkpointing**: Always update MEMORY.md after work
3. **Respect user wait**: If waiting for user input, don't do busy work
4. **Log everything**: Every heartbeat should produce a log entry
5. **Handle errors in-cycle**: If a step fails, try fallback, log error, checkpoint

## Idle Behavior

When the phase is complete (or no work is pending):
- Check MEMORY.md for `phase: idle`
- Send no messages
- Do nothing until triggered by user via Telegram
