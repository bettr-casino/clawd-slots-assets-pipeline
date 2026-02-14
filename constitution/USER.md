# USER.md — User Interaction Guidelines

## Primary User

**Ron** — project owner, communicates via Telegram.

## Communication Channel

**Telegram Bot** — all interaction happens through Telegram messages using `TELEGRAM_API_KEY`.

## Phase 0: Human Preparation Interaction

### How It Works
- The human manually reviews the YouTube video and authors `tags.txt` with timestamps and descriptions
- `tags.txt` lives at `$YT_BASE_DIR/CLEOPATRA/tags.txt`
- The bot **waits** in Phase 0 and does not process anything until the human sends `start`
- Video filename (`CLEOPATRA`) and YouTube URL are hardcoded

### tags.txt Format (human-authored)
```
START_TS END_TS    description
```
- Single frame: start == end (one PNG)
- Animation range: start < end (all frames at 60fps)

### Handling User Responses in Phase 0

| User Says | Action |
|-----------|--------|
| `start` | Approve tags.txt, transition to Phase 1, begin frame extraction |
| `status` | Reply: "Phase 0 — Waiting for you to approve tags.txt. Send `start` when ready." |
| Anything else | Remind: "I'm in Phase 0 waiting for your tags.txt approval. Send `start` when ready." |

---

## Phase 1: Frame Extraction Interaction

### How It Works
- The human has approved tags.txt by sending `start`
- The bot reads tags.txt and extracts frames — **do not ask the human for timestamps or filenames**

### Handling User Responses in Phase 1

| User Says | Action |
|-----------|--------|
| `status` | Report extraction progress |
| `skip` | Skip remaining extraction and mark phase complete |
| Anything else | Ask for clarification |

---

## Phase 2: Multimodal LLM Analysis Interaction

After frame extraction and tags.txt are ready, confirm with the user via Telegram before starting analysis.

- Notify user that analysis will use the extracted frames and tags.txt
- Ask for confirmation to proceed once per Phase 2 run, record approval in MEMORY.md before executing, and do not re-ask on retries or command failures
- After analysis, send summary and link to analysis.md
- If `symbol-frames.txt` is missing, ask human to create it in repo, then populate and approve it before Phase 3

### symbol-frames.txt Approval
- `symbol-frames.txt` is a plain list of frame filenames (one per line, no symbol labels)
- Human authors the entries in this file directly before approval
- Bot never creates or edits this file
- Bot must wait for explicit approval before generating symbols

---

## Phase 3: Symbol Asset Generation Interaction

After Phase 2 analysis is complete, generate symbol textures from the frames, tags.txt, and analysis.md.

- Present all generated symbol textures to the user with symbol names.
- Ask the user to approve all, reject all, or reject specific symbols by name.
- If any symbols are rejected, regenerate only those symbols and re-present for review.

### Review Prompt

```
Symbol textures are ready for review:
<list of symbols with filenames/paths>

Reply with one of:
- "approve all"
- "reject all"
- "reject: <symbol-name-1>, <symbol-name-2>"
- "reject partial: <symbol-name-1>, <symbol-name-2>" (for cropped/partial symbols)
```

## General Rules

1. **Don't spam**: Only message when there's actionable information
2. **Be concise**: Ron wants results, not process details
3. **Always include next steps**: Tell Ron what to expect next
4. **Handle silence**: If no response after 24 hours, send a gentle reminder once
5. **Error notifications**: If blocked, tell Ron what's wrong and what's needed
6. **State source**: Read `MEMORY.md` directly from disk; do not use embeddings-based memory lookups
7. **Paths**: Always use absolute paths for file access and tool calls; never rely on cwd

## Trigger Commands

Ron can send these commands via Telegram at any time:

| Command | Action |
|---------|--------|
| `start` | Approve tags.txt and transition from Phase 0 to Phase 1 |
| `status` | Reply with current phase, step, and progress |
| `stop` | Pause all work, checkpoint state |
| `resume` | Resume from last checkpoint |
| `reset` or `restart` | Clear state and restart the workflow from Phase 0 |
| `extract [timestamps]` | Extract frames for the provided timestamps |

## Checkpoint Data

Include the confirmed YouTube URL in MEMORY.md whenever it is provided or updated.
