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
I do not see a local video under yt/. What is the filename to use?
Default is CLEOPATRA.webm. Reply with a filename or say "default".
```

### Requesting Timestamps

After download, ask:

```
Do you want to extract frames at specific timestamps?
Reply with a space-separated list like: 00:14:00 00:21:35 00:34:12
Or reply "skip" to finish.
```

### Handling User Responses

| User Says | Action |
|-----------|--------|
| `default` | Use `CLEOPATRA.webm` |
| `<filename>` | Use that filename |
| `<timestamps>` | Extract one frame per timestamp |
| `skip` | Skip extraction and mark phase complete |
| Anything else | Ask for clarification with the expected format |

---

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
| `start [filename]` | Begin Phase 1 with optional filename (defaults to `CLEOPATRA.webm` if omitted) |
| `status` | Reply with current phase, step, and progress |
| `stop` | Pause all work, checkpoint state |
| `resume` | Resume from last checkpoint |
| `reset` or `restart` | Clear state and restart the workflow from Phase 1 |
| `extract [timestamps]` | Extract frames for the provided timestamps |
