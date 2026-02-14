#!/usr/bin/env bash
set -euo pipefail

# Manage Codespace lifecycle from local terminal.
#
# Usage:
#   ./scripts/codespace.sh status
#   ./scripts/codespace.sh start
#   ./scripts/codespace.sh stop
#   ./scripts/codespace.sh restart
#
# Optional env vars:
#   REPO=bettr-casino/clawd-slots-assets-pipeline
#   CODESPACE=<codespace-name>
#   WAIT_TIMEOUT_SECONDS=120
#   POLL_SECONDS=2

REPO="${REPO:-bettr-casino/clawd-slots-assets-pipeline}"
ACTION="${1:-status}"
WAIT_TIMEOUT_SECONDS="${WAIT_TIMEOUT_SECONDS:-120}"
POLL_SECONDS="${POLL_SECONDS:-2}"

log() {
  echo "[$(date '+%H:%M:%S')] $*"
}

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI is required."
  exit 1
fi

pick_codespace() {
  if [ -n "${CODESPACE:-}" ]; then
    echo "$CODESPACE"
    return
  fi

  # Prefer an active codespace, otherwise use the first repo codespace.
  local selected
  selected="$(gh codespace list -R "$REPO" --json name,state -q '.[] | select(.state=="Available") | .name' | head -n1)"
  if [ -z "$selected" ]; then
    selected="$(gh codespace list -R "$REPO" --json name -q '.[0].name')"
  fi
  echo "$selected"
}

codespace_state() {
  local name="$1"
  gh codespace list -R "$REPO" --json name,state -q ".[] | select(.name==\"$name\") | .state" | head -n1
}

wait_for_state() {
  local name="$1"
  local target="$2"
  local elapsed=0
  while [ "$elapsed" -lt "$WAIT_TIMEOUT_SECONDS" ]; do
    local state
    state="$(codespace_state "$name")"
    if [ "$state" = "$target" ]; then
      log "Codespace $name is now $state."
      return 0
    fi
    printf "\r[%s] waiting for state=%s (current=%s) %ss/%ss" \
      "$(date '+%H:%M:%S')" "$target" "${state:-unknown}" "$elapsed" "$WAIT_TIMEOUT_SECONDS"
    sleep "$POLL_SECONDS"
    elapsed=$((elapsed + POLL_SECONDS))
  done
  echo
  log "Timed out waiting for $name to reach state=$target."
  return 1
}

NAME="$(pick_codespace)"
if [ -z "${NAME:-}" ] || [ "$NAME" = "null" ]; then
  echo "No Codespace found for $REPO."
  exit 1
fi

STATE="$(codespace_state "$NAME")"
log "Codespace: $NAME"
log "State: ${STATE:-unknown}"

case "$ACTION" in
  status)
    ;;

  start)
    if [ "$STATE" = "Available" ]; then
      log "Already running."
      exit 0
    fi
    # SSH triggers wake/start for a stopped codespace.
    log "Starting Codespace via SSH wake..."
    gh codespace ssh -c "$NAME" -- "true" >/dev/null 2>&1 || true
    wait_for_state "$NAME" "Available"
    ;;

  stop|shutdown)
    if [ "$STATE" != "Available" ]; then
      log "Already stopped (state=${STATE:-unknown})."
      exit 0
    fi
    log "Stopping Codespace..."
    gh codespace stop -c "$NAME"
    # GitHub reports stopped state as Shutdown.
    wait_for_state "$NAME" "Shutdown"
    ;;

  restart)
    if [ "$STATE" = "Available" ]; then
      log "Stopping Codespace before restart..."
      gh codespace stop -c "$NAME"
      wait_for_state "$NAME" "Shutdown"
    fi
    log "Starting Codespace..."
    gh codespace ssh -c "$NAME" -- "true" >/dev/null 2>&1 || true
    wait_for_state "$NAME" "Available"
    ;;

  *)
    echo "Unknown action: $ACTION"
    echo "Usage: ./scripts/codespace.sh [status|start|stop|shutdown|restart]"
    exit 1
    ;;
esac

