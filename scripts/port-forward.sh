#!/usr/bin/env bash
set -euo pipefail

REPO="${REPO:-bettr-casino/clawd-slots-assets-pipeline}"
PORT="${PORT:-18789}"

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
gh codespace ports forward "${PORT}:${PORT}" -c "$CODESPACE"
