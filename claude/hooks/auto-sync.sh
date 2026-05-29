#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# ~/.claude/hooks/auto-sync.sh
#
# Claude Code PostToolUse hook.
# Triggered after every Edit or Write tool call.
# If the modified file is one of the tracked files, runs sync.sh in the background.
# ─────────────────────────────────────────────────────────────────────────────

# Read tool call JSON from stdin (Claude Code passes it here)
INPUT=$(cat)

# Extract the file_path from tool input
FILE_PATH=$(echo "$INPUT" | python3 -c \
  "import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" \
  2>/dev/null || echo "")

[[ -z "$FILE_PATH" ]] && exit 0

# Compute memory key for this user's workspace
LEARNING="$HOME/ai_training/learning to code"
MEMORY_KEY=$(echo "$LEARNING" | sed 's|[^a-zA-Z0-9]|-|g')
MEMORY_DIR="$HOME/.claude/projects/$MEMORY_KEY/memory"

# Files that trigger a sync when changed
TRACKED=(
    "$HOME/ai_training/CLAUDE.md"
    "$HOME/.claude/settings.json"
    "$MEMORY_DIR/MEMORY.md"
    "$MEMORY_DIR/user.md"
    "$MEMORY_DIR/project.md"
    "$HOME/ai_training/learning to code/AI docs/conversation-log.md"
)

SYNC_SCRIPT="$HOME/ai_training/ai-training-setup/sync.sh"

for tracked in "${TRACKED[@]}"; do
    if [[ "$FILE_PATH" == "$tracked" ]]; then
        # Run sync in background — don't block Claude Code
        if [[ -x "$SYNC_SCRIPT" ]]; then
            "$SYNC_SCRIPT" >> "$HOME/.claude/hooks/auto-sync.log" 2>&1 &
        fi
        exit 0
    fi
done

exit 0
