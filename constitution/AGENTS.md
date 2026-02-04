# AGENTS.md

## Agent Capabilities

### AI Model Integration

- **Primary LLM**: Kimi K-2.5
- **Purpose**: Code generation, documentation, pipeline automation
- **Use Cases**: Script writing, asset metadata generation, workflow optimization

### Meshy.ai Integration

- **Function**: 3D asset generation
- **Capabilities**:
  - Low-poly mesh creation
  - PBR texture generation
  - Basic animation sequences
- **Output Format**: FBX, GLB compatible with Unity

### Slots Research Capabilities

- **Function**: Reverse engineering slot games from video
- **Capabilities**:
  - YouTube video analysis and evaluation
  - Reel configuration identification
  - Symbol inventory cataloging
  - Game mechanics analysis
  - Bonus feature documentation
- **Research Focus**: CLEOPATRA slots and other Las Vegas casino games
- **Heartbeat Protocol**: 
  - Initial Telegram message on first heartbeat or gateway restart
  - 30-minute progress cycles with Telegram updates
  - Always use chain-of-thought reasoning
- **Reasoning Approach**: For research and analysis tasks, prefer step-by-step reasoning over direct answers. Use chain-of-thought to show logical progression from observations to conclusions. Always start complex steps with "Let's think step by step" and show every logical step before final conclusions.
- **Model Configuration**: kimi-k2.5 with chain-of-thought reasoning enabled
- **Research Phase**: This is research phase only — no asset generation, low-poly, tris, FBX or Unity mentions

### Workflow Automation

- Asset naming validation
- Batch processing scripts
- Quality assurance checks
- Unity import automation

## Agent Communication Protocol

All agent activities and decisions must be communicated via appropriate channels:

**Slack Channels:**
- Asset generation requests
- Pipeline status updates
- Quality check results
- Integration confirmations

**Telegram (Research Projects):**
- Initial message on first heartbeat or gateway restart
- Heartbeat progress updates (every 30 minutes)
- Video shortlist sharing
- User selection requests
- Clarification questions
- Blocker notifications

## Agent Responsibilities

1. Monitor asset requirements
2. Generate assets via Meshy.ai
3. Validate technical specifications
4. Prepare assets for Unity import
5. Document all processes
6. Report issues and blockers

**For Research Tasks:**
1. Send initial Telegram message on first heartbeat or gateway restart
2. Execute heartbeat-driven research cycles
3. Search and evaluate YouTube content
4. Analyze slot game videos for mechanics
5. Document findings systematically
6. Send 30-minute progress updates
7. Request clarification when needed
8. Always use chain-of-thought reasoning
9. If stuck or unclear, notify Ron via Telegram with a question

## Status Reply Enhancements

When user sends "status" or clawd responds to status, provide a comprehensive overview with professional markdown and neutral tone.

### Status Structure

Status replies should include:
- Overview
- Identity
- Channels
- Kimi Status
- Billing
- Warning (if applicable)

### Billing Section for Kimi K-2.5 / Moonshot

**API Key Presence Check:**
- If Moonshot API key is present: 
  - Note "kimi k-2.5 active" (normal operation)
  - Note "kimi k-2.5 needs billing update (balance low or unreachable)" if known issue exists
- If no API key is configured:
  - Add "kimi k-2.5 not fully configured – api key needed"

**Balance Check:**
- If balance check is possible: attempt `/v1/user/balance` endpoint
- If balance check fails: note the error appropriately

**Presentation:**
- Keep status reply clean and organized
- Use professional markdown formatting
- Maintain neutral tone throughout
