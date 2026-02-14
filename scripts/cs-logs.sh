#!/usr/bin/env bash
set -euo pipefail

# View OpenClaw gateway logs from the active Codespace.
#
# Usage:
#   ./scripts/cs-logs.sh                # show last 200 lines
#   ./scripts/cs-logs.sh --follow       # follow logs live
#   ./scripts/cs-logs.sh 500            # show last 500 lines
#   ./scripts/cs-logs.sh --follow 300   # follow after showing last 300 lines
#
# Optional env vars:
#   REPO=bettr-casino/clawd-slots-assets-pipeline
#   CODESPACE=<codespace-name>

REPO="${REPO:-bettr-casino/clawd-slots-assets-pipeline}"
FOLLOW=0
LINES=200

for arg in "$@"; do
  case "$arg" in
    --follow|-f)
      FOLLOW=1
      ;;
    ''|*[!0-9]*)
      # ignore non-numeric args other than flags for simplicity
      ;;
    *)
      LINES="$arg"
      ;;
  esac
done

if [ -z "${CODESPACE:-}" ]; then
  CODESPACE="$(gh codespace list -R "$REPO" --json name,state -q '.[] | select(.state=="Available") | .name' | head -n1)"
fi

if [ -z "${CODESPACE:-}" ]; then
  echo "No available Codespace found for $REPO."
  exit 1
fi

echo "Codespace: $CODESPACE"
echo "Lines:     $LINES"

if [ "$FOLLOW" -eq 1 ]; then
  echo "Mode:      follow"
  gh codespace ssh -c "$CODESPACE" -- "LINES='$LINES' bash -lc 'openclaw logs --tail \"\$LINES\" --follow'"
else
  echo "Mode:      tail"
  gh codespace ssh -c "$CODESPACE" -- "LINES='$LINES' bash -lc 'openclaw logs --tail \"\$LINES\"'"
fi
