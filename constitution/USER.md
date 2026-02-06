# USER.md

## User Interaction Guidelines

### Communication Channel

**Primary Channel**: Telegram
- All communications with Ron occur through Telegram
- Heartbeat updates every 30 minutes during active iterations
- Iteration completion notifications with feedback requests
- Blocker notifications and clarification questions
- All communication uses chain-of-thought reasoning

### Heartbeat Progress Format

Every 30 minutes, send exactly 2 sentences to Telegram:

**Format:**
```
Last 30 mins I worked on <short summary of what was done>.
Next 30 mins I am working on <short summary of the next planned step>.
```

**Rules:**
- Keep each sentence concise and specific
- Mention concrete deliverables or step numbers
- Be honest about blockers or waiting periods
- Use clear, professional language
- No additional text beyond the 2 sentences

### Iteration Completion Format

At the end of each complete 9-step iteration, send a summary to Telegram:

**Format:**
```
Iteration <number> complete.

Summary:
- Video analyzed: <YouTube link>
- Assets generated: <count> original models, textures, animations
- Godot implementation: <public URL>
- Comparison result: <brief assessment>

Test URL: <link to deployed prototype>
Comparison video: <link if available>

Is it good enough? Reply 'yes' or 'no' to continue/stop iterations.
```

### Request Format

When asking Ron for decisions or clarifications:
1. Provide clear context about the current step
2. State the specific decision needed
3. Offer options when applicable
4. Explain why the decision is needed
5. Include relevant links or screenshots

### Response Expectations

Ron can expect:
- 30-minute heartbeat updates during active work
- Iteration completion summaries with test URLs
- Immediate notification of blockers
- Transparent reasoning via chain-of-thought
- Clear requests for iteration decisions
- Checkpoint resilience (can restart at any step)

### Iteration Decision Process

After each complete iteration:
1. Clawd deploys test version with public URL
2. Clawd compares generated vs original video
3. Clawd sends summary to Ron via Telegram
4. Clawd waits for Ron's decision: 'yes' or 'no'
5. If 'yes': Loop stops, iteration is final
6. If 'no': Loop continues with new iteration
7. Clawd updates MEMORY.md with decision

## User Responsibilities

- Review iteration summaries and test URLs
- Reply 'yes' or 'no' to iteration completion requests
- Provide clarification when asked
- Report issues with deployments or tests promptly
