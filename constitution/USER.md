# USER.md — User Interaction Guidelines

## Primary User

**Ron** — project owner, communicates via Telegram.

## Communication Channel

**Telegram Bot** — all interaction happens through Telegram messages using `TELEGRAM_API_KEY`.

## Phase 1: Selection Interaction

### Presenting Options

When top 5 videos are ready, send a Telegram message in this format:

```
🎰 Top 5 Slot Machine Videos Found:

1. [Game Name] — [Channel Name]
   🔗 [YouTube URL]
   ⏱ Duration: [X:XX]
   📝 [Brief quality note]
   🧭 Timeline: [timestamps of key segments]
   🎰 Spins observed: [count]
   🎁 Bonus seen: [Yes/No, type if known]

2. [Game Name] — [Channel Name]
   🔗 [YouTube URL]
   ⏱ Duration: [X:XX]
   📝 [Brief quality note]
   🧭 Timeline: [timestamps of key segments]
   🎰 Spins observed: [count]
   🎁 Bonus seen: [Yes/No, type if known]

[... up to 5]

Reply with a number (1-5) to select, or "redo" for new search.
```

### Handling User Responses

| User Says | Action |
|-----------|--------|
| `1` through `5` | Select that video, move to Phase 2 |
| `redo` | Refine search query, find new top 5 |
| `redo [specific request]` | Use the specific request to guide new search |
| Anything else | Ask for clarification: "Please reply 1-5 or redo" |

### Redo Behavior

- Each redo uses a refined or different search query
- Track redo count in MEMORY.md
- After 3 redos, ask Ron: "I've searched 3 times. Can you share a specific video URL?"

---

## Phase 2: Analysis Interaction

### Progress Updates

Send brief Telegram updates at key milestones:
- "📊 Starting analysis of [Game Name]..."
- "🔍 Extracted metadata and transcript. Analyzing frames now..."
- "📈 Analysis complete. Generating math model spreadsheet..."

### Final Delivery

When analysis is complete, send:

```
✅ Analysis Complete: [Game Name]

📊 Math Model Summary:
• Reels: [config, e.g., 5x3]
• Paylines: [count]
• RTP: [value or "estimated"]
• Volatility: [level]
• Symbols: [count] identified
• Bonus Features: [count] found

📎 Spreadsheet: [filename.xlsx]
[Attach file or provide path]

7 sheets included: game_overview, symbol_inventory, paytable, math_model, bonus_features, visual_analysis, analysis_log
```

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
| `start [query]` | Begin Phase 1 with optional search query (defaults to popular 4K Cleopatra slots from last 24 months if omitted) |
| `status` | Reply with current phase, step, and progress |
| `stop` | Pause all work, checkpoint state |
| `resume` | Resume from last checkpoint |
| `reset` or `restart` | Clear state and restart the workflow from Phase 1 |
| `repeat phase 1` | Re-run Phase 1 selection loop (clears Phase 2 state) |
| `repeat phase 2` | Re-run Phase 2 analysis using the last selected video |
| `redo` | (During Phase 1) Search again with new query |
| `[URL]` | Skip Phase 1, go directly to Phase 2 with this video |
