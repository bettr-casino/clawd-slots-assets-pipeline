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
│       Check current phase/step by reading directly from disk:                 │
│       /workspaces/clawd-slots-assets-pipeline/constitution/MEMORY.md           │
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
| `idle` / starting | Use hardcoded filename `CLEOPATRA` and URL `https://www.youtube.com/watch?v=Ks8o3bl7OYQ` (do not ask the human for either) |
| Ready, timestamps not requested | Ask the human for timestamps to extract |
| Timestamps provided, frames not extracted | Run `/workspaces/clawd-slots-assets-pipeline/scripts/extract-frame.sh` for each timestamp (auto-downloads if missing) |
| Frames extracted | Mark phase complete and proceed to Phase 2 |

## Phase 2 Heartbeat Actions

| State | Action |
|-------|--------|
| Frames and tags.txt ready, approval not recorded | Ask once for approval to start analysis, record approval in MEMORY.md immediately |
| Approval recorded | Run multimodal LLM analysis on frames and tags.txt (do not re-ask on retries) |
| Analysis complete | Write results to analysis.md and mark phase complete |

## Phase 3 Heartbeat Actions

| State | Action |
|-------|--------|
| Analysis ready, symbols not generated | Generate symbol textures from frames, tags.txt, and analysis.md |
| Symbols generated, review not recorded | Present assets to user for review with approve/reject options |
| Rejected symbols provided | Regenerate only rejected symbols and re-present for review |
| Symbols approved | Mark phase complete |

## Heartbeat Rules

1. **One step per heartbeat**: Complete one meaningful step, checkpoint, then yield
2. **Never skip checkpointing**: Always update MEMORY.md after work
3. **Respect user wait**: If waiting for user input, don't do busy work
4. **Log everything**: Every heartbeat should produce a log entry
5. **Handle errors in-cycle**: If a step fails, try fallback, log error, checkpoint
6. **Memory source**: Always read MEMORY.md directly from disk and do not use embeddings or the memory plugin for state

## Idle Behavior

When the phase is complete (or no work is pending):
- Check MEMORY.md for `phase: idle`
- Send no messages
- Do nothing until triggered by user via Telegram
