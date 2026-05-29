#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# ai-training-setup/sync.sh
#
# Syncs the current state of Claude config and logs back into this repo
# so it stays up to date. Run this periodically or before migrating.
#
# Usage:
#   ./sync.sh          (copies files and commits)
#   ./sync.sh --dry-run (shows what would change)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

GREEN='\033[0;32m'; BLUE='\033[0;34m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC}  $1"; }
info() { echo -e "${BLUE}→${NC}  $1"; }

copy() {
    local src="$1" dest="$2" label="$3"
    if [[ ! -f "$src" ]]; then echo "  skip: $label (source not found)"; return; fi
    if $DRY_RUN; then
        echo "  would copy: $src → $dest"
    else
        cp "$src" "$dest"
        ok "$label"
    fi
}

AI_TRAINING="$HOME/ai_training"
LEARNING="$AI_TRAINING/learning to code"

# Compute memory key
# Claude Code keys memory by replacing every non-alphanumeric char with -
MEMORY_KEY=$(echo "$LEARNING" | sed 's|[^a-zA-Z0-9]|-|g')
MEMORY_DIR="$HOME/.claude/projects/$MEMORY_KEY/memory"

echo ""
echo "── Syncing Claude config ─────────────────────────────────────"
copy "$AI_TRAINING/CLAUDE.md"                    "$SCRIPT_DIR/claude/CLAUDE.md"              "CLAUDE.md"
copy "$HOME/.claude/settings.json"               "$SCRIPT_DIR/claude/settings.json"           "settings.json (global)"
copy "$MEMORY_DIR/MEMORY.md"                     "$SCRIPT_DIR/claude/memory/MEMORY.md"        "memory/MEMORY.md"
copy "$MEMORY_DIR/user.md"                       "$SCRIPT_DIR/claude/memory/user.md"          "memory/user.md"
copy "$MEMORY_DIR/project.md"                    "$SCRIPT_DIR/claude/memory/project.md"       "memory/project.md"

echo ""
echo "── Syncing logs ──────────────────────────────────────────────"
copy "$LEARNING/AI docs/conversation-log.md"     "$SCRIPT_DIR/logs/conversation-log.md"       "conversation-log.md"

if $DRY_RUN; then
    echo ""
    echo "Dry run complete — no files changed."
    exit 0
fi

echo ""
echo "── Committing ────────────────────────────────────────────────"
cd "$SCRIPT_DIR"
git add -A

if git diff --cached --quiet; then
    ok "Nothing changed — repo already up to date"
else
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
    git commit -m "sync: update Claude config and logs ($TIMESTAMP)"
    git push
    ok "Pushed to GitHub"
fi

echo ""
ok "Sync complete"
echo ""
