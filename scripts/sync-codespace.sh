#!/usr/bin/env bash
set -euo pipefail

# Sync local git changes to Codespace and restart gateway.
# Default flow:
#  1) Auto-commit local changes (custom COMMIT_MSG or generated from diff)
#  2) Push to GitHub
#  3) In Codespace: preserve runtime constitution/MEMORY.md
#  4) Pull latest (ff-only)
#  5) Restore runtime MEMORY.md and restart gateway
#
# Usage:
#   ./scripts/sync-codespace.sh
#   COMMIT_MSG="your message" ./scripts/sync-codespace.sh
#   AUTO_COMMIT=0 ./scripts/sync-codespace.sh
#   CODESPACE=<name> ./scripts/sync-codespace.sh
#
# Optional env vars:
#   REPO=bettr-casino/clawd-slots-assets-pipeline
#   CODESPACE=<codespace-name>
#   WORKSPACE=/workspaces/clawd-slots-assets-pipeline
#   STASH_PATH=constitution/MEMORY.md
#   COMMIT_MSG="custom commit message"
#   AUTO_COMMIT=1|0  (default: 1)

REPO="${REPO:-bettr-casino/clawd-slots-assets-pipeline}"
WORKSPACE="${WORKSPACE:-/workspaces/clawd-slots-assets-pipeline}"
STASH_PATH="${STASH_PATH:-constitution/MEMORY.md}"
AUTO_COMMIT="${AUTO_COMMIT:-1}"

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

generate_commit_message() {
  local file_count
  local files
  local preview
  local commit_type
  local changed_files
  local diff_blob

  file_count="$(git diff --cached --name-only | wc -l | tr -d ' ')"
  files="$(git diff --cached --name-only | head -n 3 | tr '\n' ', ' | sed 's/, $//')"
  changed_files="$(git diff --cached --name-only)"
  diff_blob="$(git diff --cached)"

  if [ -z "$files" ]; then
    files="repo files"
  fi

  # Conventional-commit style type detection (best-effort).
  commit_type="chore"
  if echo "$diff_blob" | grep -Eqi 'fix|bug|retry|timeout|error|refused'; then
    commit_type="fix"
  elif echo "$changed_files" | grep -Eqi '(^|/)(README|CHANGELOG|.*\.md)$'; then
    commit_type="docs"
  elif echo "$changed_files" | grep -Eqi '(^|/)(test|tests)/|(_test\.|\.spec\.|\.test\.)'; then
    commit_type="test"
  elif echo "$diff_blob" | grep -Eqi 'new|add|enable|support'; then
    commit_type="feat"
  fi

  preview="${commit_type}: sync updates for codespace deployment"
  if [ "$file_count" -eq 1 ]; then
    preview="${commit_type}: update ${files}"
  fi

  cat <<EOF
$preview

Auto-commit before codespace sync.
Changed files (${file_count}): ${files}
EOF
}

# Auto-commit local changes by default (or with custom COMMIT_MSG).
if [ -n "$(git status --porcelain)" ]; then
  if [ "$AUTO_COMMIT" = "1" ] || [ -n "${COMMIT_MSG:-}" ]; then
    log "Auto-committing local changes..."
    git add -A
    if [ -z "${COMMIT_MSG:-}" ]; then
      COMMIT_MSG="$(generate_commit_message)"
    fi
    git commit -m "$COMMIT_MSG"
  else
    echo "Local working tree is not clean."
    echo "Either set AUTO_COMMIT=1 (default) or commit manually."
    exit 1
  fi
else
  log "No local changes to commit."
fi

# Require clean local tree before sync unless COMMIT_MSG handled it.
if [ -n "$(git status --porcelain)" ]; then
  echo "Local working tree is not clean."
  echo "Commit/stash first, or run:"
  echo "  AUTO_COMMIT=1 COMMIT_MSG=\"...\" ./scripts/sync-codespace.sh"
  exit 1
fi

log "Pushing local branch..."
git push

log "Syncing in Codespace (preserve $STASH_PATH, pull, restore, restart)..."
gh codespace ssh -c "$CODESPACE" -- "WORKSPACE='$WORKSPACE' STASH_PATH='$STASH_PATH' bash -l -c '
set -eo pipefail
cd \"\$WORKSPACE\"

# Preserve runtime MEMORY.md snapshot so pull/template updates do not wipe live state.
RUNTIME_MEM_BAK=\"\"
if [ -f \"\$STASH_PATH\" ]; then
  RUNTIME_MEM_BAK=\"\$(mktemp)\"
  cp \"\$STASH_PATH\" \"\$RUNTIME_MEM_BAK\"
  echo \"Saved runtime \$STASH_PATH snapshot\"
fi

git pull --ff-only

if [ -n \"\$RUNTIME_MEM_BAK\" ] && [ -f \"\$RUNTIME_MEM_BAK\" ]; then
  cp \"\$RUNTIME_MEM_BAK\" \"\$STASH_PATH\"
  rm -f \"\$RUNTIME_MEM_BAK\"
  echo \"Restored runtime \$STASH_PATH after pull\"
fi

just restart
'"

log "Done. Codespace pulled latest and gateway restarted."
