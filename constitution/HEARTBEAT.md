# HEARTBEAT.md

## Chain-of-Thought Reasoning

**Always use detailed chain-of-thought reasoning.** Start complex steps with "Let's think step by step" and show every logical step before final conclusions.

For research and analysis tasks, break down your thinking process:
- State what you observe
- Explain your reasoning at each step
- Show intermediate conclusions
- Build toward final insights systematically

## Startup / First Heartbeat Cycle

On startup or when HEARTBEAT.md is first loaded:

1. **Read Workspace Configuration**
   - Load the current workspace path from openclaw.json or runtime configuration
   - If the workspace path is not available in config, use the current working directory as fallback

2. **Check Tool Availability**
   - Verify if `web_search` tool is available
   - Verify if `browser` tools are configured and available

3. **Send Immediate Telegram Message to Ron**
   
   Send a Telegram message with the following format:
   
   ```
   Clawd gateway started. Workspace: [current workspace path]. Model: kimi-k2.5. Starting CLEOPATRA slots research. Building shortlist of 5 Las Vegas casino gameplay videos. Will ask for your pick soon.
   ```
   
   **If web_search or browser tools are NOT configured**, append to the message:
   ```
   Step 1 blocked: web_search and browser tools not ready.
   ```

4. **Continue to Regular Heartbeat Cycle**
   - After sending the startup message, proceed with the normal 30-minute heartbeat cycle behavior below

## Heartbeat Cycle (Every 30 Minutes)

### Initialization
1. Load GOAL.md to understand current objectives
2. Load MEMORY.md to review progress and findings
3. Determine the next step in the research workflow

### Execution
1. Execute the next step in the current research phase
2. Make progress on the current task:
   - If on Step 1: Work on video shortlist creation
   - If on Step 2: Send/wait for Ron's video selection
   - If on Step 3: Analyze the selected video
   - If on Step 4: Document findings in MEMORY.md
   - If stuck: Prepare clarification questions for Ron

### Progress Tracking
Track progress internally:
- What was accomplished in the last 30 minutes
- What will be worked on in the next 30 minutes
- Any blockers or questions that need Ron's attention

### Telegram Update (End of Every Heartbeat)
At the end of every 30-minute cycle, send a Telegram message to Ron with exactly 2 sentences:

**Format:**
```
Last 30 mins I worked on <short summary of what was done>.
Next 30 mins I am working on <short summary of the next planned step>.
```

**Rules for Progress Summary:**
- Keep each sentence concise and specific
- Mention concrete deliverables or actions
- Be honest about blockers or waiting periods
- Use clear, professional language
- No additional text beyond the 2 sentences

### Examples

**During Video Shortlist Phase:**
```
Last 30 mins I worked on searching YouTube for CLEOPATRA gameplay videos and evaluating video quality.
Next 30 mins I am working on finalizing the top 5 video shortlist and preparing the Telegram message for Ron.
```

**During Waiting Phase:**
```
Last 30 mins I worked on sending the video shortlist to Ron via Telegram and waiting for his selection.
Next 30 mins I am working on continuing to wait for Ron's video selection or starting preliminary analysis on video #1.
```

**During Analysis Phase:**
```
Last 30 mins I worked on analyzing reel configuration and identifying base game symbols in the CLEOPATRA video.
Next 30 mins I am working on documenting wild symbols, bonus triggers, and special features.
```

**When Stuck:**
```
Last 30 mins I worked on analyzing the bonus game mechanics but encountered unclear free spin trigger conditions.
Next 30 mins I am working on sending clarification questions to Ron via Telegram and continuing with other analyzable features.
```

### Notification Protocol for Blockers

If stuck or need clarification:
1. Identify the specific blocker or unclear aspect
2. Formulate clear, specific questions
3. Send Telegram message to Ron with:
   - Brief context of the issue
   - Specific question or clarification needed
   - What can be continued while waiting
4. Update MEMORY.md with the blocker status
5. Continue working on other aspects if possible

### State Persistence

After each heartbeat:
- Update MEMORY.md with progress
- Save any new findings or discoveries
- Note the current step and substep
- Document any pending actions or blockers
- Prepare for the next 30-minute cycle
