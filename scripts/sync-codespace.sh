#!/usr/bin/env bash
set -euo pipefail

# Sync local git changes to Codespace and restart gateway.
# Default flow:
#  1) Ensure local tree is clean (or auto-commit if COMMIT_MSG is set)
#  2) Push to GitHub
#  3) In Codespace: stash constitution/MEMORY.md if dirty
#  4) Pull latest (ff-only)
#  5) Restart gateway via just restart
#
# Usage:
#   ./scripts/sync-codespace.sh
#   COMMIT_MSG="your message" ./scripts/sync-codespace.sh
#   CODESPACE=<name> ./scripts/sync-codespace.sh
#
# Optional env vars:
#   REPO=bettr-casino/clawd-slots-assets-pipeline
#   CODESPACE=<codespace-name>
#   WORKSPACE=/workspaces/clawd-slots-assets-pipeline
#   STASH_PATH=constitution/MEMORY.md
#   COMMIT_MSG="message to auto-commit local changes"

REPO="${REPO:-bettr-casino/clawd-slots-assets-pipeline}"
WORKSPACE="${WORKSPACE:-/workspaces/clawd-slots-assets-pipeline}"
STASH_PATH="${STASH_PATH:-constitution/MEMORY.md}"

log() {
  echo "[$(date '+%H:%M:%S')] $*"
}

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI is required."
  exit 1
fi

if [ -z "${CODESPACE:-}" ]; then
  CODESPACE="$(gh codespace list -R "$REPO" --json name,state -q '.[] | select(.state=="Available") | .name' | head -n1)"
fi

if [ -z "${CODESPACE:-}" ]; then
  echo "No available Codespace found for $REPO."
  exit 1
fi

log "Using Codespace: $CODESPACE"

# Auto-commit local changes if requested.
if [ -n "${COMMIT_MSG:-}" ]; then
  if [ -n "$(git status --porcelain)" ]; then
    log "Auto-committing local changes..."
    git add -A
    git commit -m "$COMMIT_MSG"
  else
    log "No local changes to commit."
  fi
fi

# Require clean local tree before sync unless COMMIT_MSG handled it.
if [ -n "$(git status --porcelain)" ]; then
  echo "Local working tree is not clean."
  echo "Commit/stash first, or run:"
  echo "  COMMIT_MSG=\"...\" ./scripts/sync-codespace.sh"
  exit 1
fi

log "Pushing local branch..."
git push

log "Syncing in Codespace (stash $STASH_PATH if needed, pull, restart)..."
gh codespace ssh -c "$CODESPACE" -- "WORKSPACE='$WORKSPACE' STASH_PATH='$STASH_PATH' bash -lc '
set -euo pipefail
cd \"\$WORKSPACE\"

if ! git diff --quiet -- \"\$STASH_PATH\"; then
  git stash push -m \"auto-sync: stash runtime memory state\" \"\$STASH_PATH\" >/dev/null
  echo \"Stashed \$STASH_PATH before pull\"
fi

git pull --ff-only
just restart
'"

log "Done. Codespace pulled latest and gateway restarted."
