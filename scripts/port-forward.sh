#!/usr/bin/env bash
set -euo pipefail

REPO="${REPO:-bettr-casino/clawd-slots-assets-pipeline}"
PORT="${PORT:-18789}"
STARTUP_TIMEOUT_SECONDS="${STARTUP_TIMEOUT_SECONDS:-15}"
CHECK_INTERVAL_SECONDS="${CHECK_INTERVAL_SECONDS:-1}"
RETRY_DELAY_SECONDS="${RETRY_DELAY_SECONDS:-10}"
MAX_RETRIES="${MAX_RETRIES:-0}" # 0 = infinite
GATEWAY_READY_TIMEOUT_SECONDS="${GATEWAY_READY_TIMEOUT_SECONDS:-30}"
SSH_TIMEOUT_SECONDS="${SSH_TIMEOUT_SECONDS:-30}"

# Optional manual override:
#   CODESPACE=<name> ./scripts/port-forward.sh
if [ -z "${CODESPACE:-}" ]; then
  CODESPACE="$(gh codespace list -R "$REPO" --json name,state -q '.[] | select(.state=="Available") | .name' | head -n1)"
fi

if [ -z "${CODESPACE:-}" ]; then
  echo "No Available Codespace found for $REPO."
  echo "Start one in GitHub UI, or set CODESPACE manually:"
  echo "  CODESPACE=<name> ./scripts/port-forward.sh"
  exit 1
fi

echo "Forwarding local ${PORT} -> Codespace ${CODESPACE}:${PORT}"
echo "Retry delay: ${RETRY_DELAY_SECONDS}s (MAX_RETRIES=${MAX_RETRIES})"
echo "Gateway check timeout: ${GATEWAY_READY_TIMEOUT_SECONDS}s"
echo "SSH timeout: ${SSH_TIMEOUT_SECONDS}s"

FWD_PID=""
LOG_FILE=""
cleanup() {
  if [ -n "${FWD_PID:-}" ] && kill -0 "$FWD_PID" 2>/dev/null; then
    kill "$FWD_PID" 2>/dev/null || true
  fi
}
trap cleanup INT TERM EXIT

log() {
  echo "[$(date '+%H:%M:%S')] $*"
}

run_ssh_with_timeout() {
  # Usage: run_ssh_with_timeout "<gh codespace ssh args...>" "<label>"
  local cmd="$1"
  local label="${2:-ssh command}"
  bash -lc "$cmd" &
  local cmd_pid=$!
  local waited=0

  while kill -0 "$cmd_pid" 2>/dev/null; do
    if [ "$waited" -ge "$SSH_TIMEOUT_SECONDS" ]; then
      kill "$cmd_pid" 2>/dev/null || true
      wait "$cmd_pid" 2>/dev/null || true
      printf "\r[%s] %s timed out at %2ss/%2ss\n" "$(date '+%H:%M:%S')" "$label" "$waited" "$SSH_TIMEOUT_SECONDS"
      return 124
    fi
    printf "\r[%s] %s: %2ss/%2ss" "$(date '+%H:%M:%S')" "$label" "$waited" "$SSH_TIMEOUT_SECONDS"
    sleep 1
    waited=$((waited + 1))
  done
  printf "\r[%s] %s: done (%2ss)        \n" "$(date '+%H:%M:%S')" "$label" "$waited"

  wait "$cmd_pid"
}

countdown_retry() {
  local seconds="$1"
  while [ "$seconds" -gt 0 ]; do
    printf "\r[%s] Retrying in %2ss..." "$(date '+%H:%M:%S')" "$seconds"
    sleep 1
    seconds=$((seconds - 1))
  done
  printf "\r[%s] Retrying now...      \n" "$(date '+%H:%M:%S')"
}

run_once() {
  LOG_FILE="$(mktemp -t port-forward.XXXXXX.log)"
  gh codespace ports forward "${PORT}:${PORT}" -c "$CODESPACE" >"$LOG_FILE" 2>&1 &
  FWD_PID="$!"

  # Fail fast if tunnel never becomes reachable.
  elapsed=0
  while [ "$elapsed" -lt "$STARTUP_TIMEOUT_SECONDS" ]; do
    if ! kill -0 "$FWD_PID" 2>/dev/null; then
      wait "$FWD_PID" || true
      echo "Port forward process exited during startup."
      echo "---- gh output ----"
      cat "$LOG_FILE"
      return 1
    fi

    if curl -s -o /dev/null --max-time 2 "http://127.0.0.1:${PORT}/"; then
      echo "Port forward is live on http://127.0.0.1:${PORT}"
      break
    fi

    sleep "$CHECK_INTERVAL_SECONDS"
    elapsed=$((elapsed + CHECK_INTERVAL_SECONDS))
  done

  if ! curl -s -o /dev/null --max-time 2 "http://127.0.0.1:${PORT}/"; then
    echo "Port forward did not become reachable within ${STARTUP_TIMEOUT_SECONDS}s."
    echo "---- gh output ----"
    cat "$LOG_FILE"
    return 1
  fi

  # Block while forward is healthy; returns when process exits.
  set +e
  wait "$FWD_PID"
  rc=$?
  set -e

  if [ "$rc" -ne 0 ]; then
    echo "Port forward exited with code $rc."
    echo "---- gh output ----"
    cat "$LOG_FILE"
  fi
  return "$rc"
}

ensure_gateway_ready() {
  log "Checking gateway inside Codespace..."
  if run_ssh_with_timeout "gh codespace ssh -c \"$CODESPACE\" -- \"bash -l -c 'curl -s -o /dev/null --max-time 3 http://127.0.0.1:${PORT}/'\" >/dev/null 2>&1" "gateway probe"; then
    log "Gateway already listening on ${PORT}."
    return 0
  fi

  log "Gateway not reachable on ${PORT}; running just restart..."
  if ! run_ssh_with_timeout "gh codespace ssh -c \"$CODESPACE\" -- \"bash -l -c 'cd /workspaces/clawd-slots-assets-pipeline && just restart'\" >/dev/null 2>&1" "just restart"; then
    log "Gateway restart command timed out after ${SSH_TIMEOUT_SECONDS}s."
  fi

  elapsed=0
  while [ "$elapsed" -lt "$GATEWAY_READY_TIMEOUT_SECONDS" ]; do
    if run_ssh_with_timeout "gh codespace ssh -c \"$CODESPACE\" -- \"bash -l -c 'curl -s -o /dev/null --max-time 3 http://127.0.0.1:${PORT}/'\" >/dev/null 2>&1" "gateway probe"; then
      log "Gateway is now listening on ${PORT}."
      return 0
    fi
    sleep 2
    elapsed=$((elapsed + 2))
  done

  log "Gateway did not become ready within ${GATEWAY_READY_TIMEOUT_SECONDS}s."
  return 1
}

attempt=0
while true; do
  echo ""
  log "===== Attempt $((attempt + 1)) ====="
  if ! ensure_gateway_ready; then
    attempt=$((attempt + 1))
    if [ "$MAX_RETRIES" -gt 0 ] && [ "$attempt" -ge "$MAX_RETRIES" ]; then
      log "Reached MAX_RETRIES=${MAX_RETRIES} while waiting for gateway. Exiting."
      exit 1
    fi
    countdown_retry "$RETRY_DELAY_SECONDS"
    continue
  fi

  if run_once; then
    exit 0
  fi

  attempt=$((attempt + 1))
  if [ "$MAX_RETRIES" -gt 0 ] && [ "$attempt" -ge "$MAX_RETRIES" ]; then
    log "Reached MAX_RETRIES=${MAX_RETRIES}. Exiting."
    exit 1
  fi

  countdown_retry "$RETRY_DELAY_SECONDS"
done
