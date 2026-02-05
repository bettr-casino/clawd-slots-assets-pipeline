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
    
    print_info "Running OpenClaw configuration wizard..."
    print_info "This will prompt you for initial configuration settings."
    echo
    
    # Run the configuration wizard
    openclaw configure || {
        print_error "Configuration wizard failed"
        exit 1
    }
    
    print_success "OpenClaw configuration completed"
    prompt_continue
}

configure_moonshot_ai() {
    print_header "Step 4: Configuring Moonshot AI Provider"
    
    print_info "Setting up Moonshot AI provider with Kimi models..."
    
    # The API key should already be set during openclaw configure
    # But we can verify it's there
    if [[ -z "${MOONSHOT_API_KEY:-}" ]]; then
        print_error "MOONSHOT_API_KEY environment variable is not set"
        exit 1
    fi
    
    print_success "Moonshot AI configuration verified"
    print_info "Base URL: https://api.moonshot.ai/v1"
    print_info "Models: kimi-k2-0905-preview (256K), kimi-k2.5 (primary)"
    
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
    openclaw config set web.search.enabled true || true
    openclaw config set web.search.provider brave || true
    
    print_success "Brave Search configured"
    print_info "Web search and fetch capabilities are enabled"
    
    prompt_continue
}

configure_agents() {
    print_header "Step 6: Configuring Agents Workspace"
    
    print_info "Setting agents default workspace to constitution directory..."
    
    local workspace_path="$CONSTITUTION_DIR"
    if [[ ! -d "$workspace_path" ]]; then
        print_warning "Constitution directory not found, using current directory"
        workspace_path="$(pwd)/constitution"
    fi
    
    openclaw config set agents.defaults.workspace "$workspace_path"
    print_success "Agents workspace set to: $workspace_path"
    
    print_info "Configuring concurrent execution limits..."
    openclaw config set agents.defaults.maxConcurrentAgents 4 || true
    openclaw config set agents.defaults.maxConcurrentSubagents 8 || true
    print_success "Concurrent execution limits configured"
    
    prompt_continue
}

configure_telegram() {
    print_header "Step 7: Configuring Telegram Integration"
    
    print_info "Setting up Telegram bot: @clawd_slots_bot"
    echo
    print_info "To configure Telegram, you need the bot token."
    print_info "The bot @clawd_slots_bot should already be created."
    echo
    
    read -p "Enter the Telegram bot token: " -r bot_token
    
    if [[ -z "$bot_token" ]]; then
        print_error "Bot token cannot be empty"
        exit 1
    fi
    
    print_info "Configuring Telegram settings..."
    openclaw config set channels.telegram.enabled true
    openclaw config set channels.telegram.botToken "$bot_token"
    openclaw config set channels.telegram.dmPolicy pairing
    openclaw config set channels.telegram.groupPolicy allowlist
    openclaw config set channels.telegram.streamMode partial
    
    print_success "Telegram configuration completed"
    print_info "DM Policy: pairing (requires approval)"
    print_info "Group Policy: allowlist"
    print_info "Stream Mode: partial"
    
    prompt_continue
}

configure_gateway() {
    print_header "Step 8: Configuring OpenClaw Gateway"
    
    print_info "Generating secure authentication token..."
    local auth_token
    auth_token=$(openssl rand -base64 48 | tr -d '/+=' | head -c 64)
    
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
    print_info "Auth Token: $auth_token"
    
    echo
    print_warning "IMPORTANT: Save this auth token securely!"
    print_info "You'll need it to connect remote clients to this gateway."
    
    prompt_continue
}

configure_plugins() {
    print_header "Step 9: Configuring Plugins"
    
    print_info "Disabling Slack plugin (using Telegram instead)..."
    openclaw config set plugins.entries.slack.enabled false || true
    
    print_info "Enabling Telegram plugin..."
    openclaw config set plugins.entries.telegram.enabled true
    
    print_success "Plugin configuration completed"
    print_info "Slack: disabled"
    print_info "Telegram: enabled"
    
    prompt_continue
}

start_openclaw() {
    print_header "Step 10: Starting OpenClaw Services"
    
    print_info "Starting OpenClaw..."
    openclaw start || {
        print_warning "OpenClaw may already be running or failed to start"
        print_info "Checking status..."
    }
    
    sleep 2
    
    print_info "Checking OpenClaw status..."
    openclaw status || true
    
    print_success "OpenClaw services started"
    
    prompt_continue
}

handle_telegram_pairing() {
    print_header "Step 11: Telegram Pairing"
    
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
    print_header "Step 12: Testing Telegram Integration"
    
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
    print_header "Step 13: Starting Gateway (Optional)"
    
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
    echo "  • Brave Search: Enabled for web search"
    echo "  • Agents Workspace: $CONSTITUTION_DIR"
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
    echo "  • Telegram bot token for @clawd_slots_bot"
    echo
    prompt_continue "Press Enter to begin setup..."
    
    check_prerequisites
    install_openclaw
    run_initial_configuration
    configure_moonshot_ai
    configure_brave_search
    configure_agents
    configure_telegram
    configure_gateway
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
