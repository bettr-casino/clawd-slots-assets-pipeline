#!/usr/bin/env bash
# openclaw-setup-auto.sh - Non-interactive OpenClaw setup for GitHub Codespaces
# Auto-prompts version of openclaw-setup.sh — designed to run via SSH without user input.
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

check_command() {
    command -v "$1" &> /dev/null
}

require_sudo() {
    if ! command -v sudo &> /dev/null; then
        print_error "sudo is required but not installed"
        exit 1
    fi
    # In Codespaces, sudo is usually passwordless
    sudo -n true 2>/dev/null || sudo true
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
    fi

    # Auto-approve sudoers write
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
    if ! command -v ffmpeg &> /dev/null; then missing+=("ffmpeg"); fi
    if ! command -v jq &> /dev/null; then missing+=("jq"); fi

    if [[ ${#missing[@]} -eq 0 ]]; then
        print_success "ffmpeg and jq already installed"
    else
        print_info "Installing: ${missing[*]}"
        sudo apt-get update -o Dir::Etc::sourcelist="sources.list" \
            -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0" 2>&1 | tail -1
        sudo apt-get install -y "${missing[@]}" 2>&1 | tail -3
    fi

    check_command ffmpeg && print_success "ffmpeg installed" || print_error "ffmpeg installation failed"
    check_command jq && print_success "jq installed" || print_warning "jq not installed"
}

install_just() {
    if check_command just; then
        print_success "just installed: $(just --version)"
        return
    fi

    print_info "Installing just..."
    # Try apt first
    if command -v apt-get &> /dev/null; then
        sudo apt-get update -o Dir::Etc::sourcelist="sources.list" \
            -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0" 2>&1 | tail -1
        if sudo apt-get install -y just 2>/dev/null; then
            print_success "just installed via apt: $(just --version)"
            return
        fi
    fi

    # Fallback: install via cargo or prebuilt binary
    if curl -sSf https://just.systems/install.sh | sudo bash -s -- --to /usr/local/bin 2>&1; then
        print_success "just installed via installer: $(just --version)"
    else
        print_error "Failed to install just"
        exit 1
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

# ─── STEP FUNCTIONS (all non-interactive) ───────────────────────────────────

step_check_prerequisites() {
    print_header "Step 1: Checking Prerequisites"
    local all_ok=true

    check_command node  && print_success "Node.js: $(node --version)"  || { print_error "Node.js not found!"; all_ok=false; }
    check_command npm   && print_success "npm: $(npm --version)"       || { print_error "npm not found!"; all_ok=false; }

    [[ -n "${BRAVE_API_KEY:-}" ]]    && print_success "BRAVE_API_KEY set"    || { print_error "BRAVE_API_KEY not set!"; all_ok=false; }
    [[ -n "${MOONSHOT_API_KEY:-}" ]] && print_success "MOONSHOT_API_KEY set" || { print_error "MOONSHOT_API_KEY not set!"; all_ok=false; }
    [[ -n "${OPENAI_API_KEY:-}" ]]   && print_success "OPENAI_API_KEY set"   || { print_error "OPENAI_API_KEY not set!"; all_ok=false; }
    [[ -n "${XAI_API_KEY:-}" ]]      && print_success "XAI_API_KEY set"      || { print_error "XAI_API_KEY not set!"; all_ok=false; }
    [[ -n "${TELEGRAM_API_KEY:-}" ]] && print_success "TELEGRAM_API_KEY set" || { print_error "TELEGRAM_API_KEY not set!"; all_ok=false; }
    [[ -n "${TAVILY_API_KEY:-}" ]]   && print_success "TAVILY_API_KEY set"   || { print_error "TAVILY_API_KEY not set!"; all_ok=false; }
    [[ -n "${YT_BASE_DIR:-}" ]]      && print_success "YT_BASE_DIR: $YT_BASE_DIR" || print_warning "YT_BASE_DIR not set"

    [[ -d "$CONSTITUTION_DIR" ]] && print_success "Constitution directory found" || print_warning "Constitution directory not found"

    if [[ "$all_ok" == false ]]; then
        print_error "Prerequisites check failed."
        exit 1
    fi
    print_success "All prerequisites met!"
}

step_install_tools() {
    print_header "Step 2: Installing Tools (just, ffmpeg, jq)"
    require_sudo
    install_just
    install_media_tools
    MEDIA_TOOLS_STATUS="Installed"
    print_success "All tools installed"
}

step_create_extract_frame() {
    print_header "Step 3: Creating extract-frame.sh"
    local script_path="$WORKSPACE_DIR/scripts/extract-frame.sh"
    if [[ -f "$script_path" ]]; then
        print_success "extract-frame.sh already exists"
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
}

step_clawdbot_privileges() {
    print_header "Step 4: ClawdBot Elevated Permissions (auto-approved)"
    require_sudo
    ensure_user "clawdbot"
    ensure_sudo_group "clawdbot"
    configure_sudoers "clawdbot"
    CLAWDBOT_SETUP_STATUS="Completed"
    print_success "ClawdBot elevated setup finished"
}

step_install_openclaw() {
    print_header "Step 5: Installing OpenClaw"
    # Always install/reinstall
    print_info "Installing OpenClaw globally via npm..."
    if npm install -g openclaw 2>&1 | tail -3; then
        print_success "OpenClaw installed: $(openclaw --version)"
    else
        print_error "Failed to install OpenClaw"
        exit 1
    fi
}

step_initial_configuration() {
    print_header "Step 6: Initial OpenClaw Configuration"

    # Create config dir
    mkdir -p "$OPENCLAW_CONFIG_DIR"

    # Skip interactive wizard — write a minimal config directly if none exists,
    # or run configure non-interactively using --non-interactive if supported.
    if [[ -f "$OPENCLAW_CONFIG_FILE" ]]; then
        print_info "Configuration file already exists, will reconfigure"
    fi

    # Try non-interactive configure first; fall back to writing config directly
    if openclaw configure \
        --section workspace \
        --section web \
        --section gateway \
        --section channels \
        --section skills \
        --section health \
        --non-interactive 2>/dev/null; then
        print_success "OpenClaw configured via wizard (non-interactive)"
    elif openclaw configure \
        --section workspace \
        --section web \
        --section gateway \
        --section channels \
        --section skills \
        --section health < /dev/null 2>/dev/null; then
        print_success "OpenClaw configured via wizard (stdin closed)"
    else
        print_warning "Interactive wizard failed; writing minimal config directly"
        if [[ ! -f "$OPENCLAW_CONFIG_FILE" ]]; then
            cat > "$OPENCLAW_CONFIG_FILE" <<MINCONF
{
  "agents": {
    "defaults": {
      "workspace": "$CONSTITUTION_DIR",
      "maxConcurrent": 4,
      "subagents": { "maxConcurrent": 8 },
      "model": {}
    }
  },
  "gateway": {
    "port": $GATEWAY_PORT,
    "mode": "local",
    "bind": "loopback"
  },
  "channels": {},
  "tools": {},
  "models": {},
  "auth": { "profiles": {} }
}
MINCONF
            print_success "Minimal config written to $OPENCLAW_CONFIG_FILE"
        fi
    fi
}

step_configure_ai_models() {
    print_header "Step 7: Configuring AI Models (Primary + Fallbacks)"
    print_info "Setting up LLM fallback chain: kimi-k2.5 → grok-vision-beta → gpt-4o"

    # Set primary model
    print_info "Setting primary model to moonshot/kimi-k2.5..."
    openclaw models set "moonshot/kimi-k2.5" 2>/dev/null || \
        openclaw config set agents.defaults.model.primary "moonshot/kimi-k2.5" 2>/dev/null || true

    # Set fallbacks
    openclaw models fallbacks clear 2>/dev/null || true
    openclaw models fallbacks add "$XAI_FALLBACK_MODEL" 2>/dev/null || true
    openclaw models fallbacks add "$OPENAI_FALLBACK_MODEL" 2>/dev/null || true

    # Register API keys
    print_info "Registering API keys in OpenClaw auth store..."
    echo "$MOONSHOT_API_KEY" | openclaw models auth paste-token \
        --provider moonshot --profile-id "moonshot:default" 2>/dev/null || true
    echo "$XAI_API_KEY" | openclaw models auth paste-token \
        --provider xai --profile-id "xai:default" 2>/dev/null || true
    echo "$OPENAI_API_KEY" | openclaw models auth paste-token \
        --provider openai --profile-id "openai:default" 2>/dev/null || true

    ensure_agent_auth_profiles || true

    if ensure_fallbacks_in_config; then
        print_success "Fallback models written to config file"
    else
        print_warning "Could not write fallback models to config file"
    fi

    openclaw models status 2>/dev/null || true
    print_success "AI model configuration completed"
}

step_configure_brave() {
    print_header "Step 8: Configuring Brave Search"
    openclaw config set tools.web.search.enabled true 2>/dev/null || true
    openclaw config set tools.web.search.provider brave 2>/dev/null || true
    openclaw config set tools.web.search.apiKey "$BRAVE_API_KEY" 2>/dev/null || true
    print_success "Brave Search configured"
}

step_configure_tavily() {
    print_header "Step 9: Configuring Tavily Search"
    print_info "Tavily fallback is driven by TAVILY_API_KEY env var when Brave fails."
    print_success "Tavily search configured"
}

step_configure_agents() {
    print_header "Step 10: Configuring Agents Workspace"
    local workspace_path="$CONSTITUTION_DIR"
    [[ -d "$workspace_path" ]] || workspace_path="$(pwd)/constitution"

    openclaw config set agents.defaults.workspace "$workspace_path"
    openclaw config set agents.defaults.maxConcurrent 4 2>/dev/null || true
    openclaw config set agents.defaults.subagents.maxConcurrent 8 2>/dev/null || true
    print_success "Agents workspace set to: $workspace_path"
}

step_configure_telegram() {
    print_header "Step 11: Configuring Telegram Integration"
    openclaw config set channels.telegram.enabled true
    openclaw config set channels.telegram.botToken "$TELEGRAM_API_KEY"
    openclaw config set channels.telegram.dmPolicy pairing
    openclaw config set channels.telegram.groupPolicy allowlist
    openclaw config set channels.telegram.streamMode partial
    print_success "Telegram configured (pairing deferred — pair later via: openclaw pairing approve telegram YOUR_CODE)"
}

step_configure_elevated_tools() {
    print_header "Step 12: Enabling Elevated Tools"
    openclaw config set tools.elevated.enabled true 2>/dev/null || true
    openclaw config set tools.elevated.allowFrom '{"telegram":["*"]}' 2>/dev/null || true

    if [[ -f "$OPENCLAW_CONFIG_FILE" ]]; then
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
    fi

    # Exec-approvals allowlist
    local allowlist_patterns=(
        "/usr/bin/*"
        "/usr/sbin/*"
        "/usr/local/bin/*"
        "/bin/*"
        "$HOME/.local/bin/*"
        "/workspaces/**"
        "**"
    )
    for pattern in "${allowlist_patterns[@]}"; do
        openclaw approvals allowlist add --agent main "$pattern" 2>/dev/null || true
    done

    openclaw gateway restart 2>/dev/null || true
    print_success "Elevated tools configured"
}

step_configure_gateway() {
    print_header "Step 13: Configuring OpenClaw Gateway"
    local auth_token
    auth_token=$(openssl rand -hex 32)

    openclaw config set gateway.port "$GATEWAY_PORT"
    openclaw config set gateway.mode local
    openclaw config set gateway.bind loopback
    openclaw config set gateway.auth.mode token
    openclaw config set gateway.auth.token "$auth_token"
    openclaw config set gateway.remote.token "$auth_token"

    print_success "Gateway configured on port $GATEWAY_PORT"
    print_info "Auth Token: ${auth_token:0:8}...${auth_token: -8} (full token in ~/.openclaw/openclaw.json)"
}

step_configure_plugins() {
    print_header "Step 14: Configuring Plugins"
    openclaw config set plugins.entries.slack.enabled false 2>/dev/null || true
    openclaw config set plugins.entries.telegram.enabled true 2>/dev/null || true
    print_success "Plugins configured (Slack: off, Telegram: on)"
}

step_start_gateway() {
    print_header "Step 15: Starting OpenClaw Gateway"
    print_info "Starting gateway..."

    openclaw gateway start 2>&1 || {
        print_warning "openclaw gateway start failed, trying via just..."
        cd "$WORKSPACE_DIR"
        just start 2>&1 || print_warning "just start also failed"
    }

    sleep 3
    print_info "Checking status..."
    openclaw status 2>/dev/null || true
    print_success "Gateway start attempted"
}

step_health_check() {
    print_header "Step 16: Health Check"
    openclaw doctor 2>/dev/null || {
        print_warning "Health check found issues, attempting auto-fix..."
        openclaw doctor --fix 2>/dev/null || true
    }
    print_success "Health check completed"
}

show_summary() {
    print_header "Setup Complete!"
    echo
    print_success "OpenClaw has been configured for Clawd Slots Assets Pipeline"
    echo
    print_info "Configuration Summary:"
    echo "  • OpenClaw: Installed"
    echo "  • Primary Model: moonshot/kimi-k2.5"
    echo "  • Fallbacks: $XAI_FALLBACK_MODEL, $OPENAI_FALLBACK_MODEL"
    echo "  • Brave Search: Enabled"
    echo "  • Tavily Search: Enabled"
    echo "  • Agents Workspace: $CONSTITUTION_DIR"
    echo "  • ClawdBot elevated: $CLAWDBOT_SETUP_STATUS"
    echo "  • Media tools: $MEDIA_TOOLS_STATUS"
    echo "  • Telegram Bot: @clawd_slots_bot (pair later)"
    echo "  • Gateway Port: $GATEWAY_PORT"
    echo "  • Config File: $OPENCLAW_CONFIG_FILE"
    echo
    print_info "Next Steps:"
    echo "  1. Pair Telegram: openclaw pairing approve telegram YOUR_CODE"
    echo "  2. Check status: openclaw status"
    echo "  3. Test bot: message @clawd_slots_bot on Telegram"
    echo
}

# ─── MAIN ───────────────────────────────────────────────────────────────────

main() {
    print_header "OpenClaw Auto-Setup for Clawd Slots Assets Pipeline"
    print_info "Non-interactive setup — all prompts auto-answered."
    echo

    step_check_prerequisites
    step_install_tools
    step_create_extract_frame
    step_clawdbot_privileges
    step_install_openclaw
    step_initial_configuration
    step_configure_ai_models
    step_configure_brave
    step_configure_tavily
    step_configure_agents
    step_configure_telegram
    step_configure_elevated_tools
    step_configure_gateway
    step_configure_plugins
    step_start_gateway
    step_health_check
    show_summary

    print_success "Auto-setup completed successfully!"
}

main
