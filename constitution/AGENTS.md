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

### Workflow Automation

- Asset naming validation
- Batch processing scripts
- Quality assurance checks
- Unity import automation

## Agent Communication Protocol

All agent activities and decisions must be communicated via Slack channels:
- Asset generation requests
- Pipeline status updates
- Quality check results
- Integration confirmations

## Agent Responsibilities

1. Monitor asset requirements
2. Generate assets via Meshy.ai
3. Validate technical specifications
4. Prepare assets for Unity import
5. Document all processes
6. Report issues and blockers

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
