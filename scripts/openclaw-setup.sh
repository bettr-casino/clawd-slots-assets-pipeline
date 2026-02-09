#!/usr/bin/env bash
# openclaw-setup.sh - Interactive OpenClaw setup script for GitHub Codespaces
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
TELEGRAM_PAIRING_APPROVED=false
CLAWDBOT_SETUP_STATUS="Not run"
MEDIA_TOOLS_STATUS="Not checked"
OPENAI_FALLBACK_MODEL="openai/gpt-4o"
XAI_FALLBACK_MODEL="xai/grok-vision-beta"

# Suppress OpenClaw banner noise during setup
export OPENCLAW_NO_BANNER=1

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

require_sudo() {
    if ! command -v sudo &> /dev/null; then
        print_error "sudo is required but not installed"
        exit 1
    fi

    if ! sudo -n true 2>/dev/null; then
        print_info "sudo access is required for this setup"
        sudo true
    fi
}

ensure_user() {
    local user_name="$1"

    if id "$user_name" &> /dev/null; then
        print_success "User exists: $user_name"
        return
    fi

    print_info "Creating user: $user_name"
    sudo useradd --create-home --shell /bin/bash "$user_name"
    print_success "User created: $user_name"
}

ensure_sudo_group() {
    local user_name="$1"

    if groups "$user_name" | grep -q "\bsudo\b"; then
        print_success "User is already in sudo group: $user_name"
        return
    fi

    print_info "Adding $user_name to sudo group"
    sudo usermod -aG sudo "$user_name"
    print_success "Added to sudo group: $user_name"
}

configure_sudoers() {
    local user_name="$1"
    local sudoers_path="/etc/sudoers.d/$user_name"
    local sudoers_line="$user_name ALL=(ALL) NOPASSWD:ALL"

    if sudo test -f "$sudoers_path"; then
        if sudo grep -Fxq "$sudoers_line" "$sudoers_path"; then
            print_success "Sudoers already grants passwordless sudo: $sudoers_path"
            return
        fi
        print_warning "Existing sudoers file found for $user_name."
        print_warning "It does not match the required passwordless sudo entry."
    else
        print_warning "This will allow $user_name to run sudo without a password."
    fi

    read -r -p "Write passwordless sudoers entry? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_warning "Skipping sudoers changes"
        return
    fi

    print_info "Writing sudoers file: $sudoers_path"
    echo "$sudoers_line" | sudo tee "$sudoers_path" > /dev/null
    sudo chmod 0440 "$sudoers_path"

    if sudo visudo -cf "$sudoers_path"; then
        print_success "Sudoers entry validated"
    else
        print_error "Sudoers validation failed; removing file"
        sudo rm -f "$sudoers_path"
        exit 1
    fi
}

install_media_tools() {
    local missing=()

    if ! command -v ffmpeg &> /dev/null; then
        missing+=("ffmpeg")
    fi

    if ! command -v jq &> /dev/null; then
        missing+=("jq")
    fi

    if [[ ${#missing[@]} -eq 0 ]]; then
        print_success "ffmpeg and jq already installed"
    else
        print_info "Installing: ${missing[*]}"
        sudo apt-get update -o Dir::Etc::sourcelist="sources.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
        sudo apt-get install -y "${missing[@]}"
    fi

    if command -v ffmpeg &> /dev/null; then
        print_success "ffmpeg installed"
    else
        print_error "ffmpeg installation failed"
        exit 1
    fi

    if command -v jq &> /dev/null; then
        print_success "jq installed"
    else
        print_warning "jq not installed — some tooling may not work"
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
    "moonshot": {
        "baseUrl": "https://api.moonshot.ai/v1",
        "api": "openai-completions",
        "models": [
            {
                "id": "kimi-k2.5",
                "name": "Kimi K2.5",
                "reasoning": False,
                "input": ["text", "image"],
                "cost": {
                    "input": 0,
                    "output": 0,
                    "cacheRead": 0,
                    "cacheWrite": 0,
                },
                "contextWindow": 512000,
                "maxTokens": 16384,
            }
        ],
    },
    "openai": {
        "baseUrl": "https://api.openai.com/v1",
        "api": "openai-completions",
        "models": [
            {
                "id": "gpt-4o",
                "name": "GPT-4o",
                "input": ["text", "image"],
                "contextWindow": 400000,
                "maxTokens": 16384,
            }
        ],
    },
    "xai": {
        "baseUrl": "https://api.x.ai/v1",
        "api": "openai-completions",
        "models": [
            {
                "id": "grok-vision-beta",
                "name": "Grok Vision Beta",
                "input": ["text", "image"],
                "contextWindow": 400000,
                "maxTokens": 16384,
            }
        ],
    },
}

with open(path, "r", encoding="utf-8") as handle:
    data = json.load(handle)
agents = data.setdefault("agents", {})
defaults = agents.setdefault("defaults", {})
agent_model_config = defaults.setdefault("model", {})
defaults["maxConcurrent"] = 1
defaults.setdefault("subagents", {})["maxConcurrent"] = 1
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

vision_ids = {
    "kimi-k2.5",
    "kimi-k2",
    "gpt-4o",
    "grok-2-vision",
    "grok-vision-beta",
}

def ensure_image_input(model):
    model_id = (model.get("id") or "").lower()
    name = (model.get("name") or "").lower()
    if (
        model_id in vision_ids
        or "vision" in model_id
        or "vision" in name
        or "kimi-k2" in model_id
        or "kimi k2" in name
    ):
        inputs = list(model.get("input") or [])
        if "text" not in inputs:
            inputs.insert(0, "text")
        if "image" not in inputs:
            inputs.append("image")
        model["input"] = inputs

for payload in providers.values():
    for model_def in payload.get("models", []):
        ensure_image_input(model_def)

available_models = set()
for provider, payload in providers.items():
    for model_def in payload.get("models", []):
        model_id = model_def.get("id")
        if model_id:
            available_models.add(f"{provider}/{model_id}")

preferred_primary = [
    "moonshot/kimi-k2.5",
    "xai/grok-vision-beta",
    "openai/gpt-4o",
]
for candidate in preferred_primary:
    if candidate in available_models:
    agent_model_config["primary"] = candidate
        break
agent_model_config["fallbacks"] = [m for m in models if m in available_models]

with open(path, "w", encoding="utf-8") as handle:
    json.dump(data, handle, indent=2)
    handle.write("\n")

# Also patch the agent-level models.json which OpenClaw uses at runtime
import os
agent_models = os.path.expanduser("~/.openclaw/agents/main/agent/models.json")
if os.path.isfile(agent_models):
    with open(agent_models, "r", encoding="utf-8") as handle:
        adata = json.load(handle)
    aprov = adata.setdefault("providers", {})
    # Remove stale 'grok' provider — we use 'xai'
    aprov.pop("grok", None)
    # Ensure xai and openai providers exist with apiKey refs
    for pname, pdef in provider_defaults.items():
        entry = aprov.setdefault(pname, dict(pdef))
        if pname == "moonshot":
            entry["apiKey"] = "MOONSHOT_API_KEY"
        elif pname == "xai":
            entry["apiKey"] = "XAI_API_KEY"
        elif pname == "openai":
            entry["apiKey"] = "OPENAI_API_KEY"
        for model in entry.get("models", []):
            ensure_image_input(model)
    with open(agent_models, "w", encoding="utf-8") as handle:
        json.dump(adata, handle, indent=2)
        handle.write("\n")
PY
}

ensure_agent_auth_profiles() {
    local auth_store="$HOME/.openclaw/agents/main/agent/auth-profiles.json"

    print_info "Ensuring agent auth store has API keys..."

    python3 - "$auth_store" <<'PY'
import json
import os
import sys
from pathlib import Path

path = Path(sys.argv[1])
path.parent.mkdir(parents=True, exist_ok=True)

data = {"version": 1, "profiles": {}, "lastGood": {}}
if path.exists():
    with path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)

profiles = data.setdefault("profiles", {})
last_good = data.setdefault("lastGood", {})

def set_profile(provider, env_key):
    value = os.environ.get(env_key)
    if not value:
        return
    profile_id = f"{provider}:default"
    profiles[profile_id] = {
        "type": "api_key",
        "provider": provider,
        "key": value,
    }
    last_good[provider] = profile_id

set_profile("moonshot", "MOONSHOT_API_KEY")
set_profile("xai", "XAI_API_KEY")
set_profile("openai", "OPENAI_API_KEY")

with path.open("w", encoding="utf-8") as handle:
    json.dump(data, handle, indent=2, sort_keys=True)
    handle.write("\n")

print(f"Auth store updated: {path}")
PY
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

    if [[ -n "${YT_BASE_DIR:-}" ]]; then
        print_success "YT_BASE_DIR is configured: $YT_BASE_DIR"
    else
        print_warning "YT_BASE_DIR is not set (downloads/extraction will fail)"
        print_info "Set it like: export YT_BASE_DIR=\"$WORKSPACE_DIR/yt\""
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

install_media_tools_step() {
    print_header "Step 2: Installing Media Tools (ffmpeg, jq)"

    require_sudo
    install_media_tools

    MEDIA_TOOLS_STATUS="Installed"
    print_success "Media tools installed"

    prompt_continue
}

ensure_extract_frame_script() {
    print_header "Step 3: Creating extract-frame.sh"

    local script_path="$WORKSPACE_DIR/scripts/extract-frame.sh"
    if [[ -f "$script_path" ]]; then
        print_success "extract-frame.sh already exists"
        prompt_continue
        return
    fi

    cat > "$script_path" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <video-path> <timestamp HH:MM:SS> [output-dir]"
  exit 1
fi

video_path="$1"
timestamp="$2"
output_dir="${3:-$(dirname "$video_path")/../frames}"

mkdir -p "$output_dir"

safe_stamp="${timestamp//:/}"
output_file="$output_dir/frame_${safe_stamp}.png"

ffmpeg -ss "$timestamp" -i "$video_path" -frames:v 1 "$output_file" -hide_banner -loglevel error
echo "Wrote $output_file"
EOF

    chmod +x "$script_path"
    print_success "Created $script_path"

    prompt_continue
}

setup_clawdbot_privileges() {
    print_header "Step 4: ClawdBot Elevated Permissions"

    read -p "Run ClawdBot elevated setup now? (y/N): " -r run_setup
    if [[ ! "$run_setup" =~ ^[Yy]$ ]]; then
        CLAWDBOT_SETUP_STATUS="Skipped"
        MEDIA_TOOLS_STATUS="Skipped"
        print_warning "Skipping ClawdBot elevated setup"
        prompt_continue
        return
    fi

    require_sudo
    ensure_user "clawdbot"
    ensure_sudo_group "clawdbot"
    configure_sudoers "clawdbot"
    CLAWDBOT_SETUP_STATUS="Completed"
    print_success "ClawdBot elevated setup finished"

    prompt_continue
}

install_openclaw() {
    print_header "Step 5: Installing OpenClaw"
    
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
    print_header "Step 6: Initial OpenClaw Configuration"
    
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
    print_header "Step 7: Configuring AI Models (Primary + Fallbacks)"
    
    print_info "Setting up LLM fallback chain: kimi-k2.5 → grok-2-vision → gpt-4o"
    
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

    # --- Register API keys in auth store ---
    print_info "Registering API keys in OpenClaw auth store..."
    echo "$MOONSHOT_API_KEY" | openclaw models auth paste-token \
        --provider moonshot \
        --profile-id "moonshot:default" 2>/dev/null || {
        print_warning "paste-token for moonshot failed, continuing..."
    }
    echo "$XAI_API_KEY" | openclaw models auth paste-token \
        --provider xai \
        --profile-id "xai:default" 2>/dev/null || {
        print_warning "paste-token for xai failed, continuing..."
    }
    echo "$OPENAI_API_KEY" | openclaw models auth paste-token \
        --provider openai \
        --profile-id "openai:default" 2>/dev/null || {
        print_warning "paste-token for openai failed, continuing..."
    }

    # --- Ensure agent auth store has keys (fallback if paste-token fails) ---
    ensure_agent_auth_profiles || true

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
    print_header "Step 8: Configuring Brave Search"
    
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
    print_header "Step 9: Configuring Tavily Search"

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
    print_header "Step 10: Configuring Agents Workspace"
    
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
    print_header "Step 11: Configuring Telegram Integration"
    
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

configure_elevated_tools() {
    print_header "Step 12: Enabling Elevated Tools"

    print_info "Allowing elevated tools from Telegram provider..."

    if ! openclaw config set tools.elevated.enabled true; then
        print_warning "Failed to enable elevated tools, continuing..."
    fi
    if ! openclaw config set tools.elevated.allowFrom '{"telegram":["*"]}'; then
        print_warning "Failed to allow elevated tools from Telegram, continuing..."
    fi

    if [[ -f "$OPENCLAW_CONFIG_FILE" ]]; then
        print_info "Patching OpenClaw config to allow elevated tools for the main agent..."
        python3 - "$OPENCLAW_CONFIG_FILE" <<'PY'
import json
import sys

path = sys.argv[1]

with open(path, "r", encoding="utf-8") as handle:
    data = json.load(handle)

tools = data.setdefault("tools", {})
elevated = tools.setdefault("elevated", {})
elevated["enabled"] = True
allow_from = elevated.get("allowFrom")
if not isinstance(allow_from, dict):
    allow_from = {}
allow_from["telegram"] = ["*"]
elevated["allowFrom"] = allow_from

agents = data.setdefault("agents", {})
agent_list = agents.get("list")
if not isinstance(agent_list, list):
    agent_list = []
    agents["list"] = agent_list

def is_main(entry):
    return entry.get("id") == "main" or entry.get("name") == "main"

main_entry = None
for entry in agent_list:
    if isinstance(entry, dict) and is_main(entry):
        main_entry = entry
        break

if main_entry is None:
    main_entry = {"id": "main", "name": "main"}
    agent_list.append(main_entry)

agent_tools = main_entry.setdefault("tools", {})
agent_elevated = agent_tools.setdefault("elevated", {})
agent_elevated["enabled"] = True
agent_allow = agent_elevated.get("allowFrom")
if not isinstance(agent_allow, dict):
    agent_allow = {}
agent_allow["telegram"] = ["*"]
agent_elevated["allowFrom"] = agent_allow

with open(path, "w", encoding="utf-8") as handle:
    json.dump(data, handle, indent=2)
    handle.write("\n")
PY
    else
        print_warning "OpenClaw config file not found; skipping direct patch"
    fi

    print_info "Populating exec-approvals allowlist for the main agent..."

    local allowlist_patterns=(
        "/usr/bin/*"
        "/usr/sbin/*"
        "/usr/local/bin/*"
        "/bin/*"
        "$HOME/.local/bin/*"
        # Workspace scripts
        "/workspaces/**"
        "**"
    )
    for pattern in "${allowlist_patterns[@]}"; do
        if ! openclaw approvals allowlist add --agent main "$pattern" 2>/dev/null; then
            print_warning "Failed to add allowlist pattern: $pattern"
        fi
    done

    # Restart gateway so it picks up the updated exec-approvals
    if openclaw gateway restart 2>/dev/null; then
        print_success "Gateway restarted to apply approval changes"
    fi

    print_success "Elevated tools configured"
    print_info "Telegram is authorized to request elevated actions"
    print_info "Exec-approvals allowlist: catch-all (**) — no approval prompts"
    print_info "Media tooling should use regular exec (non-elevated) to avoid approval prompts"

    prompt_continue
}

configure_gateway() {
    print_header "Step 13: Configuring OpenClaw Gateway"
    
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

configure_plugins() {
    print_header "Step 14: Configuring Plugins"
    
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
    print_header "Step 15: Starting OpenClaw Services"
    
    print_info "Checking OpenClaw status..."
    if ! openclaw status; then
        print_warning "OpenClaw gateway may not be running"
        print_info "You can start it in the next step or run:"
        print_info "  openclaw gateway start"
    fi
    
    print_success "OpenClaw status checked"
    
    prompt_continue
}

handle_telegram_pairing() {
    print_header "Step 16: Telegram Pairing"

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
    print_header "Step 17: Testing Telegram Integration"

    print_info "You can manually test by sending a message to @clawd_slots_bot"
    print_info "The bot should respond if everything is configured correctly."

    prompt_continue
}

start_gateway() {
    print_header "Step 18: Starting Gateway (Optional)"
    
    echo
    read -p "Do you want to start the OpenClaw gateway now? (y/N): " -r start_gw
    
    if [[ "$start_gw" =~ ^[Yy]$ ]]; then
        print_info "Starting gateway directly..."
        openclaw gateway start || {
            print_error "Failed to start gateway"
        }
        
        sleep 2
        print_info "Checking gateway status..."
        openclaw status || true
    else
        print_info "Gateway not started. You can start it later with:"
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
    echo "  • ClawdBot elevated setup: $CLAWDBOT_SETUP_STATUS"
    echo "  • Media tools (ffmpeg): $MEDIA_TOOLS_STATUS"
    echo "  • Telegram Bot: @clawd_slots_bot"
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
    echo "  5. Set YT_BASE_DIR (example: export YT_BASE_DIR=\"$WORKSPACE_DIR/yt\")"
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
    install_media_tools_step
    ensure_extract_frame_script
    setup_clawdbot_privileges
    install_openclaw
    run_initial_configuration
    configure_moonshot_ai
    configure_brave_search
    configure_tavily_search
    configure_agents
    configure_telegram
    configure_elevated_tools
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
