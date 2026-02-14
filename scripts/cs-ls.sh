#!/usr/bin/env bash
set -euo pipefail

# List files/directories inside the active Codespace from local terminal.
# Usage:
#   ./scripts/cs-ls.sh [path]
#
# Examples:
#   ./scripts/cs-ls.sh
#   ./scripts/cs-ls.sh /workspaces/clawd-slots-assets-pipeline
#   ./scripts/cs-ls.sh /workspaces/clawd-slots-assets-pipeline/yt/CLEOPATRA
#
# Optional env vars:
#   REPO=bettr-casino/clawd-slots-assets-pipeline
#   CODESPACE=<codespace-name>

REPO="${REPO:-bettr-casino/clawd-slots-assets-pipeline}"
TARGET="${1:-/workspaces/clawd-slots-assets-pipeline}"

if [ -z "${CODESPACE:-}" ]; then
  CODESPACE="$(gh codespace list -R "$REPO" --json name,state -q '.[] | select(.state=="Available") | .name' | head -n1)"
fi

if [ -z "${CODESPACE:-}" ]; then
  echo "No available Codespace found for $REPO."
  exit 1
fi

echo "Codespace: $CODESPACE"
echo "Path:      $TARGET"
gh codespace ssh -c "$CODESPACE" -- "TARGET='$TARGET' bash -lc 'ls -lah --group-directories-first \"\$TARGET\"'"
