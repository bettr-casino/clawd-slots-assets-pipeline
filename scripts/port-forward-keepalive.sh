#!/usr/bin/env bash
# port-forward-keepalive.sh
# Keeps gh codespace port forwarding alive with auto-restart and heartbeat pings.
# Ensures Codespace is awake and gateway is listening before starting the tunnel.
#
# Usage:
#   ./scripts/port-forward-keepalive.sh [codespace-name] [port]
#
# Defaults:
#   codespace: bug-free-eureka-5vrjv9qvg4h6vv
#   port: 18789

set -euo pipefail

CODESPACE="${1:-bug-free-eureka-5vrjv9qvg4h6vv}"
PORT="${2:-18789}"
PING_INTERVAL=30  # seconds between keepalive pings
MAX_FAILURES=3    # consecutive ping failures before restart
READY_TIMEOUT=120 # max seconds to wait for gateway inside Codespace

echo "=== Port Forward Keepalive ==="
echo "Codespace: $CODESPACE"
echo "Port:      $PORT"
echo "Ping every ${PING_INTERVAL}s, restart after ${MAX_FAILURES} failures"
echo "Press Ctrl+C to stop"
echo ""

cleanup() {
    echo ""
    echo "[$(date '+%H:%M:%S')] Shutting down..."
    [ -n "${FWD_PID:-}" ] && kill "$FWD_PID" 2>/dev/null
    exit 0
}
trap cleanup INT TERM

# Ensure Codespace is awake and gateway is listening on PORT before we forward.
ensure_gateway_ready() {
    echo "[$(date '+%H:%M:%S')] Ensuring Codespace is awake and gateway is listening on ${PORT}..."
    local start now elapsed
    start=$(date +%s)

    while true; do
        now=$(date +%s)
        elapsed=$((now - start))
        if [ "$elapsed" -ge "$READY_TIMEOUT" ]; then
            echo "[$(date '+%H:%M:%S')] Timeout waiting for gateway after ${READY_TIMEOUT}s"
            return 1
        fi

        # Check if port responds inside Codespace; if not, start gateway and poll until ready (gateway can take 15-30s to bind)
        if gh codespace ssh -c "$CODESPACE" -- "bash -l -c '
            if curl -s -o /dev/null -w \"\" --max-time 3 http://127.0.0.1:'"${PORT}"'/ 2>/dev/null; then exit 0; fi
            cd /workspaces/clawd-slots-assets-pipeline 2>/dev/null && just start 2>/dev/null
            i=0; while [ \"\$i\" -lt 25 ]; do sleep 2; i=\$((i+1)); if curl -s -o /dev/null -w \"\" --max-time 3 http://127.0.0.1:'"${PORT}"'/ 2>/dev/null; then exit 0; fi; done
            exit 1
        '" 2>/dev/null; then
            echo "[$(date '+%H:%M:%S')] Gateway is ready (took ${elapsed}s)"
            return 0
        fi

        echo "[$(date '+%H:%M:%S')] Waiting for gateway... (${elapsed}s)"
        sleep 10
    done
}

while true; do
    if ! ensure_gateway_ready; then
        echo "[$(date '+%H:%M:%S')] Retrying in 15s..."
        sleep 15
        continue
    fi

    echo "[$(date '+%H:%M:%S')] Starting port forward ${PORT}:${PORT}..."
    gh codespace ports forward "${PORT}:${PORT}" -c "$CODESPACE" &
    FWD_PID=$!

    # Give the tunnel time to establish (Connection refused = tunnel connected before gateway was ready)
    sleep 10

    if ! kill -0 "$FWD_PID" 2>/dev/null; then
        echo "[$(date '+%H:%M:%S')] Port forward exited. Retrying in 10s..."
        sleep 10
        continue
    fi

    echo "[$(date '+%H:%M:%S')] Port forward running (PID $FWD_PID). Starting heartbeat..."

    failures=0
    while kill -0 "$FWD_PID" 2>/dev/null; do
        sleep "$PING_INTERVAL"

        # Keepalive ping
        if curl -s -o /dev/null -w '' --max-time 5 "http://127.0.0.1:${PORT}/" 2>/dev/null; then
            failures=0
        else
            failures=$((failures + 1))
            echo "[$(date '+%H:%M:%S')] Ping failed ($failures/$MAX_FAILURES)"

            if [ "$failures" -ge "$MAX_FAILURES" ]; then
                echo "[$(date '+%H:%M:%S')] Too many failures. Killing and restarting..."
                kill "$FWD_PID" 2>/dev/null
                wait "$FWD_PID" 2>/dev/null
                break
            fi
        fi
    done

    echo "[$(date '+%H:%M:%S')] Port forward died. Restarting in 5s..."
    sleep 5
done
