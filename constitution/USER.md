# USER.md — User Interaction Guidelines

## Primary User

**Ron** — project owner, communicates via Telegram.

## Communication Channel

**Telegram Bot** — all interaction happens through Telegram messages using `TELEGRAM_API_KEY`.

## Phase 1: Video Intake + Frame Extraction Interaction

Ensure `YT_BASE_DIR` is set before starting downloads or extraction.

### Requesting a Filename

If the video file is missing, ask:

```
I do not see a local video under yt/. What is the base filename to use?
Default is CLEOPATRA. Reply with a base filename (or `CLEOPATRA.webm`, which will be stripped) or say "default".
```

### Requesting Timestamps

Before extraction, ask:

```
Do you want to extract frames at specific timestamps?
Reply with a space-separated list like: 00:14:00 00:21:35 00:34:12
Or reply "skip" to finish.

### Confirming YouTube URL

Ask the user to confirm the URL before requesting timestamps:

```
Is this the correct YouTube URL?
Default: https://www.youtube.com/watch?v=Ks8o3bl7OYQ
Reply with "yes" to confirm or provide the updated URL.
```
```

### Handling User Responses

| User Says | Action |
|-----------|--------|
| `default` | Use `CLEOPATRA` |
| `<filename>` | Use that base filename |
| `<timestamps>` | Extract one frame per timestamp |
| `skip` | Skip extraction and mark phase complete |
| Anything else | Ask for clarification with the expected format |

---

## Phase 2: Multimodal LLM Analysis Interaction

After frame extraction and tags.txt are ready, confirm with the user via Telegram before starting analysis.

- Notify user that analysis will use the extracted frames and tags.txt
- Ask for confirmation to proceed
- After analysis, send summary and link to analysis.md

## General Rules

1. **Don't spam**: Only message when there's actionable information
2. **Be concise**: Ron wants results, not process details
3. **Always include next steps**: Tell Ron what to expect next
4. **Handle silence**: If no response after 24 hours, send a gentle reminder once
5. **Error notifications**: If blocked, tell Ron what's wrong and what's needed

## Trigger Commands

Ron can send these commands via Telegram at any time:

| Command | Action |
|---------|--------|
| `start [filename]` | Begin Phase 1 with optional base filename (defaults to `CLEOPATRA` if omitted) |
| `status` | Reply with current phase, step, and progress |
| `stop` | Pause all work, checkpoint state |
| `resume` | Resume from last checkpoint |
| `reset` or `restart` | Clear state and restart the workflow from Phase 1 |
| `extract [timestamps]` | Extract frames for the provided timestamps |

## Checkpoint Data

Include the confirmed YouTube URL in MEMORY.md whenever it is provided or updated.
