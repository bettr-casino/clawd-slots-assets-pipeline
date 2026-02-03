#!/usr/bin/env bash
# start-openclaw-gateway.sh - Launch OpenClaw gateway reliably in Codespace

set -euo pipefail

LOG_DIR="$HOME/.openclaw/logs"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
LOG_FILE="$LOG_DIR/gateway-$TIMESTAMP.log"

echo "Starting OpenClaw gateway..."
echo "Logs will go to: $LOG_FILE"

if [[ "${1:-}" == "--background" || "${1:-}" == "-b" ]]; then
    echo "Launching in background (nohup)..."
    nohup openclaw gateway run --verbose > "$LOG_FILE" 2>&1 &
    GATEWAY_PID=$!
    echo "Gateway started in background with PID: $GATEWAY_PID"
    echo "Monitor live logs: tail -f $LOG_FILE"
    echo "Stop with: kill $GATEWAY_PID"
else
    echo "Launching in foreground (Ctrl+C to stop)..."
    openclaw gateway run --verbose | tee "$LOG_FILE"
fi
