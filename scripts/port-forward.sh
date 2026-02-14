#!/usr/bin/env bash
set -euo pipefail

REPO="${REPO:-bettr-casino/clawd-slots-assets-pipeline}"
PORT="${PORT:-18789}"
STARTUP_TIMEOUT_SECONDS="${STARTUP_TIMEOUT_SECONDS:-15}"
CHECK_INTERVAL_SECONDS="${CHECK_INTERVAL_SECONDS:-1}"

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

LOG_FILE="$(mktemp -t port-forward.XXXXXX.log)"
cleanup() {
  if [ -n "${FWD_PID:-}" ] && kill -0 "$FWD_PID" 2>/dev/null; then
    kill "$FWD_PID" 2>/dev/null || true
  fi
}
trap cleanup INT TERM EXIT

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
    exit 1
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
  exit 1
fi

# Keep running in foreground behavior; fail if forward process dies.
set +e
wait "$FWD_PID"
rc=$?
set -e

if [ "$rc" -ne 0 ]; then
  echo "Port forward exited with code $rc."
  echo "---- gh output ----"
  cat "$LOG_FILE"
fi

exit "$rc"
