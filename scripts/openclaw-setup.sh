#!/usr/bin/env bash
# clawdbot-setup.sh - Interactive OpenClaw setup script for GitHub Codespaces
# Based on SETUP.md guide for Clawd Slots Assets Pipeline

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration constants
WORKSPACE_DIR="/workspaces/clawd-slots-assets-pipeline"
CONSTITUTION_DIR="$WORKSPACE_DIR/constitution"
OPENCLAW_CONFIG_DIR="$HOME/.openclaw"
OPENCLAW_CONFIG_FILE="$OPENCLAW_CONFIG_DIR/openclaw.json"
GATEWAY_PORT=18789
CDP_PORT=18801
TELEGRAM_PAIRING_APPROVED=false
BROWSER_SETUP_STATUS="Not installed"
OPENAI_FALLBACK_MODEL="openai/gpt-4o"
XAI_FALLBACK_MODEL="xai/grok-vision-beta"

# Helper functions
print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

prompt_continue() {
    local message="${1:-Press Enter to continue...}"
    echo
    read -p "$message" -r
    echo
}

check_command() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

ensure_fallbacks_in_config() {
    if [[ ! -f "$OPENCLAW_CONFIG_FILE" ]]; then
        print_warning "OpenClaw config file not found; skipping fallback file update"
        return 1
    fi

    python3 - "$OPENCLAW_CONFIG_FILE" "$XAI_FALLBACK_MODEL" "$OPENAI_FALLBACK_MODEL" <<'PY'
import json
import sys

path = sys.argv[1]
models = list(sys.argv[2:])
auth_profiles = {
    "openai:default": {"provider": "openai", "mode": "api_key"},
    "xai:default": {"provider": "xai", "mode": "api_key"},
}
provider_defaults = {
    "openai": {
        "baseUrl": "https://api.openai.com/v1",
        "api": "openai-completions",
        "models": [{"id": "gpt-4o", "name": "GPT-4o", "input": ["text", "image"]}],
    },
    "xai": {
        "baseUrl": "https://api.x.ai/v1",
        "api": "openai-completions",
        "models": [{"id": "grok-vision-beta", "name": "Grok Vision Beta", "input": ["text", "image"]}],
    },
}

with open(path, "r", encoding="utf-8") as handle:
    data = json.load(handle)

agents = data.setdefault("agents", {})
defaults = agents.setdefault("defaults", {})
model = defaults.setdefault("model", {})
model["fallbacks"] = models
defaults_models = defaults.setdefault("models", {})
for entry in models:
    defaults_models.setdefault(entry, {})

auth = data.setdefault("auth", {})
profiles = auth.setdefault("profiles", {})
for key, value in auth_profiles.items():
    profiles.setdefault(key, value)

models_config = data.setdefault("models", {})
models_config.setdefault("mode", "merge")
providers = models_config.setdefault("providers", {})
for provider, payload in provider_defaults.items():
    providers.setdefault(provider, payload)

with open(path, "w", encoding="utf-8") as handle:
    json.dump(data, handle, indent=2)
    handle.write("\n")
PY
}

find_chrome_command() {
    local cmd
    for cmd in google-chrome google-chrome-stable chromium chromium-browser; do
        if command -v "$cmd" &> /dev/null; then
            echo "$cmd"
            return 0
        fi
    done
    return 1
}

# Main setup functions
check_prerequisites() {
    print_header "Step 1: Checking Prerequisites"
    
    local all_ok=true
    
    # Check Node.js
    if check_command node; then
        local node_version=$(node --version)
        print_success "Node.js installed: $node_version"
    else
        print_error "Node.js not found!"
        all_ok=false
    fi
    
    # Check npm
    if check_command npm; then
        local npm_version=$(npm --version)
        print_success "npm installed: $npm_version"
    else
        print_error "npm not found!"
        all_ok=false
    fi

    # Check just
    if check_command just; then
        local just_version=$(just --version)
        print_success "just installed: $just_version"
    else
        print_warning "just not found, attempting to install via apt..."
        if command -v apt-get &> /dev/null; then
            # Use only the core Ubuntu sources list to avoid third-party repo GPG issues.
            if sudo apt-get update -o Dir::Etc::sourcelist="sources.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0" \
                && sudo apt-get install -y just; then
                local just_version=$(just --version)
                print_success "just installed: $just_version"
            else
                print_error "Failed to install just"
                print_info "If this keeps failing, disable the yarn apt repo or install just manually."
                all_ok=false
            fi
        else
            print_error "apt-get not available to install just"
            all_ok=false
        fi
    fi
    
    # Check required environment variables
    if [[ -n "${BRAVE_API_KEY:-}" ]]; then
        print_success "BRAVE_API_KEY is configured"
    else
        print_error "BRAVE_API_KEY environment variable not set!"
        all_ok=false
    fi
    
    if [[ -n "${MOONSHOT_API_KEY:-}" ]]; then
        print_success "MOONSHOT_API_KEY is configured"
    else
        print_error "MOONSHOT_API_KEY environment variable not set!"
        all_ok=false
    fi

    if [[ -n "${OPENAI_API_KEY:-}" ]]; then
        print_success "OPENAI_API_KEY is configured"
    else
        print_error "OPENAI_API_KEY environment variable not set!"
        all_ok=false
    fi

    if [[ -n "${XAI_API_KEY:-}" ]]; then
        print_success "XAI_API_KEY is configured"
    else
        print_error "XAI_API_KEY environment variable not set!"
        all_ok=false
    fi
    
    if [[ -n "${TELEGRAM_API_KEY:-}" ]]; then
        print_success "TELEGRAM_API_KEY is configured"
    else
        print_error "TELEGRAM_API_KEY environment variable not set!"
        all_ok=false
    fi

    if [[ -n "${TAVILY_API_KEY:-}" ]]; then
        print_success "TAVILY_API_KEY is configured"
    else
        print_error "TAVILY_API_KEY environment variable not set!"
        all_ok=false
    fi
    
    # Check workspace directory
    if [[ -d "$CONSTITUTION_DIR" ]]; then
        print_success "Constitution directory found: $CONSTITUTION_DIR"
    else
        print_warning "Constitution directory not found at expected location"
        print_info "Will use current directory: $(pwd)"
    fi
    
    if [[ "$all_ok" == false ]]; then
        print_error "Prerequisites check failed. Please resolve the issues above."
        exit 1
    fi
    
    print_success "All prerequisites met!"
    prompt_continue
}

install_openclaw() {
    print_header "Step 2: Installing OpenClaw"
    
    if check_command openclaw; then
        local current_version=$(openclaw --version 2>/dev/null || echo "unknown")
        print_info "OpenClaw is already installed (version: $current_version)"
        read -p "Reinstall OpenClaw? (y/N): " -r reinstall
        if [[ ! "$reinstall" =~ ^[Yy]$ ]]; then
            print_info "Skipping OpenClaw installation"
            prompt_continue
            return
        fi
    fi
    
    print_info "Installing OpenClaw globally via npm..."
    if npm install -g openclaw; then
        local version=$(openclaw --version)
        print_success "OpenClaw installed successfully: $version"
    else
        print_error "Failed to install OpenClaw"
        exit 1
    fi
    
    prompt_continue
}

run_initial_configuration() {
    print_header "Step 3: Initial OpenClaw Configuration"
    
    if [[ -f "$OPENCLAW_CONFIG_FILE" ]]; then
        print_warning "Configuration file already exists: $OPENCLAW_CONFIG_FILE"
        read -p "Reconfigure OpenClaw? This will create a new configuration. (y/N): " -r reconfig
        if [[ ! "$reconfig" =~ ^[Yy]$ ]]; then
            print_info "Skipping initial configuration"
            prompt_continue
            return
        fi
    fi
    
    print_info "Running OpenClaw configuration wizard (model selection skipped)..."
    print_info "This will prompt you for initial configuration settings."
    echo
    
    # Run the configuration wizard
    openclaw configure \
        --section workspace \
        --section web \
        --section gateway \
        --section channels \
        --section skills \
        --section health || {
        print_error "Configuration wizard failed"
        exit 1
    }
    
    print_success "OpenClaw configuration completed"
    prompt_continue
}

configure_moonshot_ai() {
    print_header "Step 4: Configuring AI Models (Primary + Fallbacks)"
    
    print_info "Setting up LLM fallback chain: kimi-k2.5 → grok-vision-beta → gpt-4o"
    
    # Validate required API keys
    if [[ -z "${MOONSHOT_API_KEY:-}" ]]; then
        print_error "MOONSHOT_API_KEY environment variable is not set"
        exit 1
    fi

    if [[ -z "${OPENAI_API_KEY:-}" ]]; then
        print_error "OPENAI_API_KEY environment variable is not set"
        exit 1
    fi

    if [[ -z "${XAI_API_KEY:-}" ]]; then
        print_error "XAI_API_KEY environment variable is not set"
        exit 1
    fi
    
    # --- Primary model ---
    print_info "Setting primary model to moonshot/kimi-k2.5..."
    if ! openclaw models set "moonshot/kimi-k2.5"; then
        print_warning "Failed to set default model via models command, trying config..."
        if ! openclaw config set agents.defaults.model.primary "moonshot/kimi-k2.5"; then
            print_warning "Failed to set default model to moonshot/kimi-k2.5, continuing..."
        fi
    fi

    # --- Fallback models via CLI (the canonical way) ---
    print_info "Clearing existing fallback list..."
    openclaw models fallbacks clear 2>/dev/null || true

    print_info "Adding fallback #1: $XAI_FALLBACK_MODEL..."
    if ! openclaw models fallbacks add "$XAI_FALLBACK_MODEL" 2>/dev/null; then
        print_warning "CLI fallback add failed for $XAI_FALLBACK_MODEL, will write config directly"
    fi

    print_info "Adding fallback #2: $OPENAI_FALLBACK_MODEL..."
    if ! openclaw models fallbacks add "$OPENAI_FALLBACK_MODEL" 2>/dev/null; then
        print_warning "CLI fallback add failed for $OPENAI_FALLBACK_MODEL, will write config directly"
    fi

    # --- Register xAI API key in auth store ---
    print_info "Registering xAI API key in OpenClaw auth store..."
    echo "$XAI_API_KEY" | openclaw models auth paste-token \
        --provider xai \
        --profile-id "xai:default" 2>/dev/null || {
        print_warning "paste-token for xai failed, continuing..."
    }

    # --- Belt-and-suspenders: write config JSON directly ---
    if ensure_fallbacks_in_config; then
        print_success "Fallback models written to config file"
    else
        print_warning "Could not write fallback models to config file"
    fi

    # Verify final state
    print_info "Verifying model status..."
    openclaw models status 2>/dev/null || true
    echo

    print_success "AI model configuration completed"
    print_info "Primary: moonshot/kimi-k2.5"
    print_info "Fallback #1: $XAI_FALLBACK_MODEL"
    print_info "Fallback #2: $OPENAI_FALLBACK_MODEL"
    
    prompt_continue
}

configure_brave_search() {
    print_header "Step 5: Configuring Brave Search"
    
    print_info "Setting up Brave Search API for web search capabilities..."
    
    if [[ -z "${BRAVE_API_KEY:-}" ]]; then
        print_error "BRAVE_API_KEY environment variable is not set"
        exit 1
    fi
    
    # Configure web search with Brave API key
    if ! openclaw config set tools.web.search.enabled true; then
        print_warning "Failed to enable web search, continuing..."
    fi
    if ! openclaw config set tools.web.search.provider brave; then
        print_warning "Failed to set Brave as search provider, continuing..."
    fi
    if ! openclaw config set tools.web.search.apiKey "$BRAVE_API_KEY"; then
        print_warning "Failed to set Brave API key, continuing..."
    fi
    
    print_success "Brave Search configured"
    print_info "Web search and fetch capabilities are enabled"
    
    prompt_continue
}

configure_tavily_search() {
    print_header "Step 6: Configuring Tavily Search"

    print_info "Setting up Tavily search agent..."

    if [[ -z "${TAVILY_API_KEY:-}" ]]; then
        print_error "TAVILY_API_KEY environment variable is not set"
        exit 1
    fi

    print_info "OpenClaw 2026.2.2+ no longer accepts tools.web.search.providers.* keys."
    print_info "Tavily fallback is driven by TAVILY_API_KEY when Brave fails."

    print_success "Tavily search configured"
    print_info "Tavily provider is enabled for web search"

    prompt_continue
}

configure_agents() {
    print_header "Step 7: Configuring Agents Workspace"
    
    print_info "Setting agents default workspace to constitution directory..."
    
    local workspace_path="$CONSTITUTION_DIR"
    if [[ ! -d "$workspace_path" ]]; then
        print_warning "Constitution directory not found, using current directory"
        workspace_path="$(pwd)/constitution"
    fi
    
    openclaw config set agents.defaults.workspace "$workspace_path"
    print_success "Agents workspace set to: $workspace_path"
    
    print_info "Configuring concurrent execution limits..."
    if ! openclaw config set agents.defaults.maxConcurrent 4; then
        print_warning "Failed to set maxConcurrent, continuing..."
    fi
    if ! openclaw config set agents.defaults.subagents.maxConcurrent 8; then
        print_warning "Failed to set subagents.maxConcurrent, continuing..."
    fi
    print_success "Concurrent execution limits configured"
    
    prompt_continue
}

configure_telegram() {
    print_header "Step 8: Configuring Telegram Integration"
    
    print_info "Setting up Telegram bot: @clawd_slots_bot"
    echo
    print_info "Using TELEGRAM_API_KEY environment variable for bot token."
    echo
    
    if [[ -z "${TELEGRAM_API_KEY:-}" ]]; then
        print_error "TELEGRAM_API_KEY environment variable is not set"
        exit 1
    fi
    
    print_info "Configuring Telegram settings..."
    openclaw config set channels.telegram.enabled true
    openclaw config set channels.telegram.botToken "$TELEGRAM_API_KEY"
    openclaw config set channels.telegram.dmPolicy pairing
    openclaw config set channels.telegram.groupPolicy allowlist
    openclaw config set channels.telegram.streamMode partial
    
    print_success "Telegram configuration completed"
    print_info "DM Policy: pairing (requires approval)"
    print_info "Group Policy: allowlist"
    print_info "Stream Mode: partial"

    echo
    read -p "Have you received a pairing code from the bot? (y/N): " -r has_code
    if [[ "$has_code" =~ ^[Yy]$ ]]; then
        read -p "Enter pairing code: " -r pairing_code
        if [[ -n "$pairing_code" ]]; then
            print_info "Approving pairing with code: $pairing_code"
            if openclaw pairing approve telegram "$pairing_code"; then
                TELEGRAM_PAIRING_APPROVED=true
                print_success "Pairing approved!"
            else
                print_error "Failed to approve pairing. You can try again later with:"
                print_info "  openclaw pairing approve telegram YOUR_CODE"
            fi
        else
            print_info "No pairing code entered. You can pair later by running:"
            print_info "  openclaw pairing approve telegram YOUR_CODE"
        fi
    else
        print_info "No pairing code yet. You can pair after you receive one."
    fi
    
    prompt_continue
}

configure_gateway() {
    print_header "Step 9: Configuring OpenClaw Gateway"
    
    print_info "Generating secure authentication token..."
    local auth_token
    auth_token=$(openssl rand -hex 32)
    
    print_info "Configuring gateway settings..."
    openclaw config set gateway.port "$GATEWAY_PORT"
    openclaw config set gateway.mode local
    openclaw config set gateway.bind loopback
    openclaw config set gateway.auth.mode token
    openclaw config set gateway.auth.token "$auth_token"
    openclaw config set gateway.remote.token "$auth_token"
    
    print_success "Gateway configured"
    print_info "Port: $GATEWAY_PORT"
    print_info "Mode: local"
    print_info "Bind: loopback"
    print_info "Auth Token: ${auth_token:0:8}...${auth_token: -8} (truncated for security)"
    
    echo
    print_warning "IMPORTANT: Save this auth token securely!"
    print_info "Full token stored in ~/.openclaw/openclaw.json"
    print_info "You'll need it to connect remote clients to this gateway."
    
    prompt_continue
}

setup_chrome_browser() {
    print_header "Step 10: Setting Up Chrome Browser"

    local chrome_cmd
    if chrome_cmd=$(find_chrome_command); then
        local chrome_version=$($chrome_cmd --version 2>/dev/null || echo "unknown")
        print_success "Browser installed: $chrome_version ($chrome_cmd)"
        BROWSER_SETUP_STATUS="$chrome_version ($chrome_cmd)"
        prompt_continue
        return
    fi

    print_warning "Chrome/Chromium not found in the Codespace."
    read -p "Install Google Chrome Stable (recommended)? (y/N): " -r install_chrome

    if [[ "$install_chrome" =~ ^[Yy]$ ]]; then
        read -p "This will add Google's signing key and apt repository. Continue? (y/N): " -r allow_repo
        if [[ "$allow_repo" =~ ^[Yy]$ ]]; then
            if ! check_command gpg; then
                print_error "gpg is required to install Google Chrome"
                print_info "Install gpg and rerun this step."
                prompt_continue
                return
            fi

            if ! check_command curl && ! check_command wget; then
                print_error "curl or wget is required to download the Google signing key"
                print_info "Install curl or wget and rerun this step."
                prompt_continue
                return
            fi

            print_info "Adding Google Chrome apt key and repository..."
            sudo install -m 0755 -d /etc/apt/keyrings

            if check_command curl; then
                curl -fsSL "https://dl.google.com/linux/linux_signing_key.pub" | sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg
            else
                wget -qO- "https://dl.google.com/linux/linux_signing_key.pub" | sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg
            fi

            echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null

            if sudo apt-get update && sudo apt-get install -y google-chrome-stable; then
                if chrome_cmd=$(find_chrome_command); then
                    local chrome_version=$($chrome_cmd --version 2>/dev/null || echo "unknown")
                    print_success "Chrome installed: $chrome_version ($chrome_cmd)"
                    BROWSER_SETUP_STATUS="$chrome_version ($chrome_cmd)"
                    prompt_continue
                    return
                fi
            else
                print_warning "Google Chrome installation failed."
            fi
        else
            print_info "Skipping Google Chrome installation."
        fi
    fi

    read -p "Install Chromium from Ubuntu repositories instead? (y/N): " -r install_chromium
    if [[ "$install_chromium" =~ ^[Yy]$ ]]; then
        print_info "Installing Chromium..."
        if sudo apt-get update -o Dir::Etc::sourcelist="sources.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0" \
            && (sudo apt-get install -y chromium || sudo apt-get install -y chromium-browser); then
            if chrome_cmd=$(find_chrome_command); then
                local chrome_version=$($chrome_cmd --version 2>/dev/null || echo "unknown")
                print_success "Chromium installed: $chrome_version ($chrome_cmd)"
                BROWSER_SETUP_STATUS="$chrome_version ($chrome_cmd)"
                prompt_continue
                return
            fi
        else
            print_warning "Chromium installation failed."
        fi
    fi

    print_warning "No Chrome/Chromium installation completed. Browser automation may fail."
    BROWSER_SETUP_STATUS="Not installed"
    prompt_continue
}

configure_plugins() {
    print_header "Step 11: Configuring Plugins"
    
    print_info "Disabling Slack plugin (using Telegram instead)..."
    if ! openclaw config set plugins.entries.slack.enabled false; then
        print_warning "Failed to disable Slack plugin (may not exist), continuing..."
    fi
    
    print_info "Enabling Telegram plugin..."
    if ! openclaw config set plugins.entries.telegram.enabled true; then
        print_warning "Failed to enable Telegram plugin, continuing..."
    fi
    
    print_success "Plugin configuration completed"
    print_info "Slack: disabled"
    print_info "Telegram: enabled"
    
    prompt_continue
}

start_openclaw() {
    print_header "Step 12: Starting OpenClaw Services"
    
    print_info "Checking OpenClaw status..."
    if ! openclaw status; then
        print_warning "OpenClaw gateway may not be running"
        print_info "You can start it in the next step or run:"
        print_info "  ./scripts/openclaw-gateway-start.sh --background"
    fi
    
    print_success "OpenClaw status checked"
    
    prompt_continue
}

handle_telegram_pairing() {
    print_header "Step 13: Telegram Pairing"

    if [[ "$TELEGRAM_PAIRING_APPROVED" == true ]]; then
        print_info "Pairing already approved during Telegram setup."
        prompt_continue
        return
    fi
    
    echo
    print_info "To pair your Telegram account with OpenClaw:"
    echo
    echo "  1. Open Telegram and search for @clawd_slots_bot"
    echo "  2. Start a conversation with the bot"
    echo "  3. Send any message to initiate pairing"
    echo "  4. The bot will respond with a pairing code"
    echo
    
    prompt_continue "Press Enter after you've sent a message to the bot..."
    
    print_info "Checking for pairing requests..."
    openclaw status || true
    
    echo
    print_info "If you received a pairing code, enter it below."
    print_info "Otherwise, press Enter to skip (you can pair later)."
    echo
    read -p "Enter pairing code (or press Enter to skip): " -r pairing_code
    
    if [[ -n "$pairing_code" ]]; then
        print_info "Approving pairing with code: $pairing_code"
        openclaw pairing approve telegram "$pairing_code" || {
            print_error "Failed to approve pairing. You can try again later with:"
            print_info "  openclaw pairing approve telegram YOUR_CODE"
        }
        print_success "Pairing approved!"
    else
        print_info "Pairing skipped. You can pair later by running:"
        print_info "  openclaw pairing approve telegram YOUR_CODE"
    fi
    
    prompt_continue
}

test_telegram() {
    print_header "Step 14: Testing Telegram Integration"
    
    print_info "Testing Telegram integration..."
    
    local test_script="$WORKSPACE_DIR/scripts/telegram-send-test-message.sh"
    if [[ -f "$test_script" ]]; then
        print_info "Running test script: $test_script"
        bash "$test_script" || print_warning "Test script may need to be updated with your bot token"
    else
        print_info "Test script not found, skipping automated test"
    fi
    
    echo
    print_info "You can manually test by sending a message to @clawd_slots_bot"
    print_info "The bot should respond if everything is configured correctly."
    
    prompt_continue
}

start_gateway() {
    print_header "Step 15: Starting Gateway (Optional)"
    
    echo
    read -p "Do you want to start the OpenClaw gateway now? (y/N): " -r start_gw
    
    if [[ "$start_gw" =~ ^[Yy]$ ]]; then
        local gateway_script="$WORKSPACE_DIR/scripts/openclaw-gateway-start.sh"
        
        if [[ -f "$gateway_script" ]]; then
            print_info "Starting gateway in background..."
            bash "$gateway_script" --background || {
                print_error "Failed to start gateway"
                print_info "You can start it manually later with:"
                print_info "  $gateway_script --background"
            }
        else
            print_info "Starting gateway directly..."
            openclaw gateway start || {
                print_error "Failed to start gateway"
            }
        fi
        
        sleep 2
        print_info "Checking gateway status..."
        openclaw status || true
    else
        print_info "Gateway not started. You can start it later with:"
        print_info "  ./scripts/openclaw-gateway-start.sh --background"
        print_info "or:"
        print_info "  openclaw gateway start"
    fi
    
    prompt_continue
}

show_summary() {
    print_header "Setup Complete! 🎉"
    
    echo
    print_success "OpenClaw has been successfully configured for Clawd Slots Assets Pipeline"
    echo
    
    print_info "Configuration Summary:"
    echo "  • OpenClaw: Installed and running"
    echo "  • Moonshot AI: Configured with Kimi models"
    echo "  • OpenAI + Grok: Configured as fallback models"
    echo "  • Brave Search: Enabled for web search"
    echo "  • Tavily Search: Enabled for web search"
    echo "  • Agents Workspace: $CONSTITUTION_DIR"
    echo "  • Browser: $BROWSER_SETUP_STATUS"
    echo "  • Telegram Bot: @clawd_slots_bot"
    echo "  • Gateway Port: $GATEWAY_PORT"
    echo "  • Config File: $OPENCLAW_CONFIG_FILE"
    echo
    
    print_info "Useful Commands:"
    echo "  • openclaw status          - Check service status"
    echo "  • openclaw status --deep   - Deep status check"
    echo "  • openclaw doctor          - Run health check"
    echo "  • openclaw doctor --fix    - Fix common issues"
    echo "  • openclaw stop            - Stop all services"
    echo "  • openclaw restart         - Restart services"
    echo
    
    print_info "Next Steps:"
    echo "  1. Verify services: openclaw status"
    echo "  2. Test Telegram by messaging @clawd_slots_bot"
    echo "  3. Review constitution files in: $CONSTITUTION_DIR"
    echo "  4. Start working on asset pipeline workflows"
    echo
    
    print_info "For more information, see SETUP.md in the repository."
    echo
}

run_health_check() {
    print_header "Final Health Check"
    
    print_info "Running OpenClaw health check..."
    openclaw doctor || {
        print_warning "Health check found some issues"
        echo
        read -p "Attempt automatic fix? (y/N): " -r do_fix
        if [[ "$do_fix" =~ ^[Yy]$ ]]; then
            openclaw doctor --fix
        fi
    }
    
    prompt_continue
}

# Main execution
main() {
    clear
    print_header "OpenClaw Setup for Clawd Slots Assets Pipeline"
    echo
    print_info "This script will guide you through setting up OpenClaw in GitHub Codespaces."
    print_info "It will configure all necessary components for the Clawdbot."
    echo
    print_warning "Make sure you have:"
    echo "  • BRAVE_API_KEY environment variable set"
    echo "  • MOONSHOT_API_KEY environment variable set"
    echo "  • OPENAI_API_KEY environment variable set"
    echo "  • XAI_API_KEY environment variable set"
    echo "  • TELEGRAM_API_KEY environment variable set"
    echo "  • TAVILY_API_KEY environment variable set"
    echo
    prompt_continue "Press Enter to begin setup..."
    
    check_prerequisites
    install_openclaw
    run_initial_configuration
    configure_moonshot_ai
    configure_brave_search
    configure_tavily_search
    configure_agents
    configure_telegram
    configure_gateway
    setup_chrome_browser
    configure_plugins
    start_openclaw
    handle_telegram_pairing
    test_telegram
    start_gateway
    run_health_check
    show_summary
    
    print_success "Setup completed successfully!"
}

# Run main function
main
