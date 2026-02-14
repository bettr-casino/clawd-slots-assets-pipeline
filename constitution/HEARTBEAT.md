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

## Phase 0 Heartbeat Actions

| State | Action |
|-------|--------|
| `idle` / starting / Phase 0 | Do nothing — wait for human to send `start` on Telegram |
| Human sends `start` | Transition to Phase 1 |
| Human sends `status` | Reply: "Phase 0 — Waiting for you to approve tags.txt. Send `start` when ready." |

**Hard Gate Rule (Phase 0):**
- Never transition out of Phase 0 unless explicit human `start` approval is recorded in MEMORY.md.
- Existing files (tags.txt, video, frames) must never be used as implied approval.

## Phase 1 Heartbeat Actions

| State | Action |
|-------|--------|
| Phase 1 starting | Read `$YT_BASE_DIR/CLEOPATRA/tags.txt` (human-authored, already approved) |
| tags.txt read, frames not extracted | Run `extract-frame.sh` for each tags.txt entry (auto-downloads video if missing) |
| Frames extracted | Notify human via Telegram, mark phase complete, proceed to Phase 2 |

**Hard Gate Rule (Phase 1 -> Phase 2):**
- Do not enter Phase 2 unless MEMORY.md shows Phase 0 Approval as Approved (timestamped).
- Existing extracted frames must not auto-advance phase without prior Phase 0 approval.

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
| Symbols generated, quality not validated | Run quality gate: full symbol only, no cropped/partial assets, no multi-symbol/reel fragments; regenerate failed assets |
| Symbols generated, review not recorded | Present assets to user for review with approve/reject options |
| Rejected symbols provided | Regenerate only rejected symbols and re-present for review |
| Symbols approved | Mark phase complete |

## MEMORY.md Checkpoint Format

Always write MEMORY.md using this exact format. Keep it human-readable and unambiguous.

```markdown
# MEMORY.md

## Status
| Field              | Value                          |
|--------------------|--------------------------------|
| Phase              | 0 / 1 / 2 / 3 / idle          |
| Step               | (current step name)            |
| Status             | Waiting / In progress / Complete / Blocked |
| Last updated       | (ISO timestamp)                |

## Phase 0: Human Preparation
| Field              | Value                          |
|--------------------|--------------------------------|
| YouTube URL        | Hardcoded URL / Updated value  |
| tags.txt authored  | Yes / No / In progress         |
| Approval           | Waiting / Approved (timestamp) |

## Phase 1: Frame Extraction
| Field              | Value                          |
|--------------------|--------------------------------|
| tags.txt           | Not read / Read (N entries)    |
| Video              | Not downloaded / Downloaded (size) |
| Frames extracted   | None / N of M                  |
| Frame list         | (list each frame + description)|

## Phase 2: Analysis
| Field              | Value                          |
|--------------------|--------------------------------|
| Approval           | Not requested / Requested / Approved (timestamp) |
| Analysis           | Not started / In progress / Complete |
| Output files       | (list files written)           |

## Phase 3: Asset Generation
| Field              | Value                          |
|--------------------|--------------------------------|
| Symbols generated  | None / N of M                  |
| User review        | Not presented / Pending / Approved / Rejected (list) |
| Output files       | (list files written)           |

## Log
| Timestamp | Event |
|-----------|-------|
| ...       | ...   |
```

## Heartbeat Rules

1. **One step per heartbeat**: Complete one meaningful step, checkpoint, then yield
2. **Never skip checkpointing**: Always update MEMORY.md after work using the format above
3. **Respect user wait**: If waiting for user input, don't do busy work
4. **Log everything**: Every heartbeat should produce a log entry in the Log table
5. **Handle errors in-cycle**: If a step fails, try fallback, log error, checkpoint
6. **Memory source**: Always read MEMORY.md directly from disk and do not use embeddings or the memory plugin for state
7. **No inference transitions**: Never infer phase transitions from filesystem state alone; transitions must follow explicit MEMORY.md gate fields

## Idle Behavior

When the phase is complete (or no work is pending):
- Check MEMORY.md for `phase: idle`
- Send no messages
- Do nothing until triggered by user via Telegram
