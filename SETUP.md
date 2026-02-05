# OpenClaw Setup Guide

This guide provides step-by-step instructions to install and configure OpenClaw for the Clawd Slots Assets Pipeline project.

## Prerequisites

- Node.js (v24.11.1 or later)
- npm
- Linux/macOS environment (or WSL on Windows)
- GitHub Codespaces (optional, but recommended)

## Quick Start (GitHub Codespaces)

For GitHub Codespaces users, we provide an automated interactive setup script that handles all configuration steps:

```bash
./scripts/clawdbot-setup.sh
```

This script will:
- Install OpenClaw globally
- Configure all required components (Moonshot AI, Brave Search, Telegram)
- Set up the agents workspace
- Configure and start the gateway
- Handle Telegram bot pairing
- Run health checks

**Prerequisites for automated setup:**
- `BRAVE_API_KEY` environment variable must be set
- `MOONSHOT_API_KEY` environment variable must be set
- Telegram bot token for @clawd_slots_bot

If you prefer manual setup or need to troubleshoot, continue with the detailed instructions below.

## Installation

### 1. Install OpenClaw

Install OpenClaw globally using npm:

```bash
npm install -g openclaw
```

Verify the installation:

```bash
openclaw --version
# Expected output: 2026.2.1 (or later)
```

### 2. Initial Configuration

Run the OpenClaw configuration wizard:

```bash
openclaw configure
```

This will create the configuration file at `~/.openclaw/openclaw.json`.

## Component Configuration

### 3. Configure Moonshot AI Provider

Set up the Moonshot AI provider for LLM capabilities:

```bash
# The API key will be requested during the configure command
# Or set it manually in ~/.openclaw/openclaw.json
```

The configuration includes:
- **Base URL**: `https://api.moonshot.ai/v1`
- **Models**: 
  - `kimi-k2-0905-preview` (256K context window)
  - `kimi-k2.5` (primary model)

### 4. Configure Agents

Set the default agent workspace:

```bash
openclaw config set agents.defaults.workspace "/workspaces/clawd-slots-assets-pipeline/constitution"
```

Configure concurrent execution:
- Max concurrent agents: 4
- Max concurrent subagents: 8

### 5. Configure Web Tools

Enable web search and fetch capabilities:

```bash
# Web search is enabled by default
# API key: BSA1ns5X7XYnJkHoXrMpaVmZptnFXAF (for Brave Search)
```

The configuration includes:
- **Web Search**: Enabled (requires Brave Search API key)
- **Web Fetch**: Enabled

### 6. Configure Telegram Integration

Set up Telegram bot for communication:

#### 6.1 Get Telegram Bot Token

1. Open Telegram and search for [@BotFather](https://t.me/botfather)
2. Create a new bot with `/newbot`
3. Follow the prompts to name your bot
4. Copy the bot token provided

#### 6.2 Configure Telegram in OpenClaw

```bash
openclaw config set channels.telegram.enabled true
openclaw config set channels.telegram.botToken "YOUR_BOT_TOKEN"
openclaw config set channels.telegram.dmPolicy "pairing"
openclaw config set channels.telegram.groupPolicy "allowlist"
openclaw config set channels.telegram.streamMode "partial"
```

#### 6.3 Pair with Telegram

1. Start a conversation with your bot in Telegram
2. Check for pairing requests:

```bash
openclaw status
```

3. Approve the pairing (you'll get a pairing code):

```bash
openclaw pairing approve telegram YOUR_PAIRING_CODE
```

#### 6.4 Test Telegram Integration

Use the provided test script:

```bash
./scripts/telegram-send-test-message.sh
```

Or manually test:

```bash
curl -X POST "https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage" \
  -d chat_id=YOUR_CHAT_ID \
  -d text="Test message from OpenClaw"
```

### 7. Configure Gateway

Set up the OpenClaw gateway for remote access:

#### 7.1 Generate Auth Token

```bash
# Generate a secure token
openssl rand -base64 48 | tr -d '/+=' | head -c 64
```

#### 7.2 Configure Gateway Settings

```bash
openclaw config set gateway.port 18789
openclaw config set gateway.mode "local"
openclaw config set gateway.bind "loopback"
openclaw config set gateway.auth.mode "token"
openclaw config set gateway.auth.token "YOUR_GENERATED_TOKEN"
openclaw config set gateway.remote.token "YOUR_GENERATED_TOKEN"
```

#### 7.3 Start the Gateway

Use the provided script:

```bash
# Foreground mode (Ctrl+C to stop)
./scripts/openclaw-gateway-start.sh

# Background mode
./scripts/openclaw-gateway-start.sh --background
```

Or start manually:

```bash
openclaw gateway start
```

Check gateway status:

```bash
openclaw status
```

### 8. Configure Browser Profile

Set up browser automation profile:

```bash
# Browser profile "clawd-slots" is pre-configured
# CDP Port: 18801
# Color: #0066CC
```

Start the browser:

```bash
./scripts/openclaw-browser-start.sh
```

Or manually:

```bash
openclaw browser --browser-profile clawd-slots start
```

### 9. Disable Slack Plugin

Since we're using Telegram, disable Slack:

```bash
openclaw config set plugins.entries.slack.enabled false
openclaw config set plugins.entries.telegram.enabled true
```

## Starting OpenClaw

### Start All Services

```bash
# Start OpenClaw
openclaw start

# Start Gateway (in background)
./scripts/openclaw-gateway-start.sh --background

# Start Browser (if needed)
./scripts/openclaw-browser-start.sh
```

### Check Status

```bash
# Basic status
openclaw status

# Deep status check
openclaw status --deep

# Workspace-specific status
openclaw status --workspace
```

## Troubleshooting

### Run Health Check

```bash
openclaw doctor
```

### Fix Common Issues

```bash
openclaw doctor --fix
```

### Stop and Restart

```bash
# Stop all OpenClaw processes
openclaw stop

# Or force kill if needed
pkill -f openclaw || true

# Restart
openclaw restart
```

### View Gateway Logs

```bash
# Logs are stored in ~/.openclaw/logs/
tail -f ~/.openclaw/logs/gateway-*.log
```

## Configuration File Location

The main configuration file is located at:

```
~/.openclaw/openclaw.json
```

You can view the current configuration:

```bash
openclaw config

# View specific sections
openclaw config show agents
openclaw config get gateway.auth
```

## Quick Reference Commands

| Command | Description |
|---------|-------------|
| `openclaw start` | Start OpenClaw |
| `openclaw stop` | Stop OpenClaw |
| `openclaw restart` | Restart OpenClaw |
| `openclaw status` | Check status |
| `openclaw doctor` | Run health check |
| `openclaw config` | View configuration |
| `openclaw gateway start` | Start gateway |
| `openclaw gateway stop` | Stop gateway |
| `openclaw pairing approve telegram CODE` | Approve Telegram pairing |

## Environment Variables

No special environment variables are required. All configuration is stored in `~/.openclaw/openclaw.json`.

## Next Steps

After setup is complete:

1. Verify all services are running: `openclaw status`
2. Test Telegram integration by sending a message to your bot
3. Review the constitution files in `/workspaces/clawd-slots-assets-pipeline/constitution/`
4. Start using OpenClaw for your asset pipeline workflows

## Security Notes

- Keep your API keys and tokens secure
- Never commit `~/.openclaw/openclaw.json` to version control
- Regenerate tokens if they are compromised
- Use the pairing system for Telegram access control

## Support

For issues or questions:
- Run `openclaw --help` for command reference
- Check logs in `~/.openclaw/logs/`
- Use `openclaw doctor --fix` for automatic repairs
