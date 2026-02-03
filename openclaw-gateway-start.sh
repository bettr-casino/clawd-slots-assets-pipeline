#!/usr/bin/env bash
# start-openclaw-gateway.sh - Launch OpenClaw gateway in foreground or background

set -euo pipefail

LOG_DIR="$HOME/.openclaw/logs"
LOG_FILE="$$   LOG_DIR/gateway-   $$(date +%Y-%m-%d_%H-%M-%S).log"

mkdir -p "$LOG_DIR"

echo "Starting OpenClaw gateway..."
echo "Logs will go to: $LOG_FILE"

if [[ "$$   {1:-}" == "--background" || "   $${1:-}" == "-b" ]]; then
    echo "Running in background (nohup)..."
    nohup openclaw gateway run --verbose > "$LOG_FILE" 2>&1 &
    echo "Gateway PID: $!"
    echo "Monitor with: tail -f $LOG_FILE"
else
    echo "Running in foreground (Ctrl+C to stop)..."
    openclaw gateway run --verbose | tee "$LOG_FILE"
fi
