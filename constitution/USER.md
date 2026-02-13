# USER.md — User Interaction Guidelines

## Primary User

**Ron** — project owner, communicates via Telegram.

## Communication Channel

**Telegram Bot** — all interaction happens through Telegram messages using `TELEGRAM_API_KEY`.

## Phase 1: Video Intake + Frame Extraction Interaction

Ensure `YT_BASE_DIR` is set before starting downloads or extraction.

### Filename

The video filename is hardcoded as `CLEOPATRA`. Do not ask the human for a filename.

### Requesting Timestamps

Before extraction, ask:

```
Do you want to extract frames at specific timestamps?
Reply with a space-separated list like: 00:14:00 00:21:35 00:34:12
Or reply "skip" to finish.

### YouTube URL

The YouTube URL is hardcoded as `https://www.youtube.com/watch?v=Ks8o3bl7OYQ`. Do not ask the human to confirm it.

### Handling User Responses

| User Says | Action |
|-----------|--------|
| `default` | Use `CLEOPATRA` (always) |
| `<timestamps>` | Extract one frame per timestamp |
| `skip` | Skip extraction and mark phase complete |
| Anything else | Ask for clarification with the expected format |

---

## Phase 2: Multimodal LLM Analysis Interaction

After frame extraction and tags.txt are ready, confirm with the user via Telegram before starting analysis.

- Notify user that analysis will use the extracted frames and tags.txt
- Ask for confirmation to proceed once per Phase 2 run, record approval in MEMORY.md before executing, and do not re-ask on retries or command failures
- After analysis, send summary and link to analysis.md

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
| `start` | Begin Phase 1 with hardcoded filename `CLEOPATRA` |
| `status` | Reply with current phase, step, and progress |
| `stop` | Pause all work, checkpoint state |
| `resume` | Resume from last checkpoint |
| `reset` or `restart` | Clear state and restart the workflow from Phase 1 |
| `extract [timestamps]` | Extract frames for the provided timestamps |

## Checkpoint Data

Include the confirmed YouTube URL in MEMORY.md whenever it is provided or updated.
