#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# ai-training-setup/setup.sh
#
# Bootstraps the full ai_training workspace on a fresh macOS machine.
# Safe to re-run — all steps are idempotent.
#
# Usage:
#   chmod +x setup.sh && ./setup.sh
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✓${NC}  $1"; }
info() { echo -e "${BLUE}→${NC}  $1"; }
warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
fail() { echo -e "${RED}✗${NC}  $1"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ai_training workspace setup"
echo "  User: $USER  |  Home: $HOME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# STEP 1 — Homebrew
# ─────────────────────────────────────────────────────────────────────────────
echo "── Step 1: Homebrew ──────────────────────────────────────────"
if command -v brew &>/dev/null; then
    ok "Homebrew already installed ($(brew --version | head -1))"
else
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add to PATH for Apple Silicon
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    fi
    ok "Homebrew installed"
fi

# ─────────────────────────────────────────────────────────────────────────────
# STEP 2 — Node.js (required for Claude Code CLI)
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "── Step 2: Node.js ───────────────────────────────────────────"
if command -v node &>/dev/null; then
    ok "Node.js already installed ($(node --version))"
else
    info "Installing Node.js via Homebrew..."
    brew install node
    ok "Node.js installed"
fi

# ─────────────────────────────────────────────────────────────────────────────
# STEP 3 — Claude Code CLI
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "── Step 3: Claude Code CLI ───────────────────────────────────"
if command -v claude &>/dev/null; then
    ok "Claude Code CLI already installed ($(claude --version 2>/dev/null || echo 'version unknown'))"
else
    info "Installing Claude Code CLI via npm..."
    npm install -g @anthropic-ai/claude-code
    ok "Claude Code CLI installed"
fi
warn "Remember to run 'claude' and log in with your Anthropic account after setup."

# ─────────────────────────────────────────────────────────────────────────────
# STEP 4 — uv (Python package manager)
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "── Step 4: uv (Python package manager) ──────────────────────"
if command -v uv &>/dev/null; then
    ok "uv already installed ($(uv --version))"
else
    info "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
    ok "uv installed"
fi

# ─────────────────────────────────────────────────────────────────────────────
# STEP 5 — Java 21
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "── Step 5: Java 21 (Temurin) ─────────────────────────────────"
JAVA_VERSION=$(java --version 2>&1 | head -1 | grep -o '[0-9]\+\.' | head -1 | tr -d '.' || echo "0")
if [[ "$JAVA_VERSION" == "21" ]]; then
    ok "Java 21 already installed"
else
    info "Installing Java 21 (Eclipse Temurin)..."
    brew install --cask temurin@21
    ok "Java 21 installed"
    warn "You may need to set JAVA_HOME. Add to ~/.zshrc:"
    warn '  export JAVA_HOME=$(/usr/libexec/java_home -v 21)'
fi

# ─────────────────────────────────────────────────────────────────────────────
# STEP 6 — Docker
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "── Step 6: Docker ────────────────────────────────────────────"
if command -v docker &>/dev/null; then
    ok "Docker already installed ($(docker --version))"
else
    info "Installing Docker Desktop via Homebrew Cask..."
    brew install --cask docker
    ok "Docker Desktop installed"
    warn "Open Docker Desktop from Applications and complete initial setup before running tests."
fi

# ─────────────────────────────────────────────────────────────────────────────
# STEP 7 — GitHub CLI
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "── Step 7: GitHub CLI ────────────────────────────────────────"
if command -v gh &>/dev/null; then
    ok "GitHub CLI already installed ($(gh --version | head -1))"
else
    info "Installing GitHub CLI..."
    brew install gh
    ok "GitHub CLI installed"
    warn "Run 'gh auth login' to authenticate with GitHub."
fi

# ─────────────────────────────────────────────────────────────────────────────
# STEP 8 — Directory structure
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "── Step 8: Directory structure ───────────────────────────────"
AI_TRAINING="$HOME/ai_training"
LEARNING="$AI_TRAINING/learning to code"
SPRING_XPOSE="$AI_TRAINING/spring-xpose"

mkdir -p "$LEARNING"
mkdir -p "$SPRING_XPOSE"
mkdir -p "$LEARNING/AI docs"
ok "Directory structure created at $AI_TRAINING"

# ─────────────────────────────────────────────────────────────────────────────
# STEP 9 — Clone repos
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "── Step 9: Clone repos ───────────────────────────────────────"

clone_or_pull() {
    local url="$1"
    local dest="$2"
    local name="$3"
    if [[ -d "$dest/.git" ]]; then
        ok "$name already cloned — pulling latest"
        git -C "$dest" pull --ff-only 2>/dev/null || warn "$name: could not pull (may have local changes)"
    else
        info "Cloning $name..."
        git clone "$url" "$dest"
        ok "$name cloned"
    fi
}

clone_or_pull \
    "https://github.com/notablogger/ai-spring-kafka.git" \
    "$LEARNING/kafka-ai-spring-boot" \
    "kafka-ai-spring-boot"

clone_or_pull \
    "https://github.com/notablogger/kafka-ai-python.git" \
    "$LEARNING/kafka-ai-python" \
    "kafka-ai-python"

clone_or_pull \
    "https://github.com/notablogger/spring-xpose.git" \
    "$SPRING_XPOSE/spring-xpose" \
    "spring-xpose"

clone_or_pull \
    "https://github.com/notablogger/spring-xpose-sample-rest.git" \
    "$SPRING_XPOSE/spring-xpose-sample-rest" \
    "spring-xpose-sample-rest"

warn "python_ai is on Mercedes-Benz internal git — clone manually if needed."

# ─────────────────────────────────────────────────────────────────────────────
# STEP 10 — Claude config: CLAUDE.md
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "── Step 10: Claude config — CLAUDE.md ───────────────────────"
CLAUDE_MD_SRC="$SCRIPT_DIR/claude/CLAUDE.md"
CLAUDE_MD_DEST="$AI_TRAINING/CLAUDE.md"

if [[ -f "$CLAUDE_MD_DEST" ]]; then
    ok "CLAUDE.md already exists — skipping (run sync.sh to update)"
else
    cp "$CLAUDE_MD_SRC" "$CLAUDE_MD_DEST"
    ok "CLAUDE.md copied to $AI_TRAINING/"
fi

# ─────────────────────────────────────────────────────────────────────────────
# STEP 11 — Claude config: global settings
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "── Step 11: Claude config — global settings ──────────────────"
GLOBAL_SETTINGS_SRC="$SCRIPT_DIR/claude/settings.json"
GLOBAL_SETTINGS_DEST="$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude"

if [[ -f "$GLOBAL_SETTINGS_DEST" ]]; then
    ok "~/.claude/settings.json already exists — skipping (run sync.sh to update)"
else
    cp "$GLOBAL_SETTINGS_SRC" "$GLOBAL_SETTINGS_DEST"
    ok "Global Claude settings copied"
fi

# ─────────────────────────────────────────────────────────────────────────────
# STEP 12 — Claude config: workspace-local settings
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "── Step 12: Claude config — workspace settings ───────────────"
LOCAL_SETTINGS_DEST="$LEARNING/.claude/settings.local.json"
mkdir -p "$LEARNING/.claude"

if [[ -f "$LOCAL_SETTINGS_DEST" ]]; then
    ok "Workspace settings.local.json already exists — skipping"
else
    # Generate settings.local.json with correct home path for this user
    cat > "$LOCAL_SETTINGS_DEST" <<EOF
{
  "permissions": {
    "allow": [
      "Bash(gh auth *)",
      "Bash(gh repo *)",
      "Bash(uv --version)",
      "Bash(uv sync*)",
      "Bash(uv run*)",
      "Bash(git *)"
    ],
    "additionalDirectories": [
      "$AI_TRAINING"
    ]
  }
}
EOF
    ok "Workspace settings.local.json created"
fi

# ─────────────────────────────────────────────────────────────────────────────
# STEP 13 — Claude memory files
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "── Step 13: Claude memory files ─────────────────────────────"

# Compute the project memory key from the workspace path
# Claude replaces / and spaces in the path with - to form the directory key
WORKSPACE_PATH="$LEARNING"
# Claude Code keys memory by replacing every non-alphanumeric char with -
MEMORY_KEY=$(echo "$WORKSPACE_PATH" | sed 's|[^a-zA-Z0-9]|-|g')
MEMORY_DIR="$HOME/.claude/projects/$MEMORY_KEY/memory"
mkdir -p "$MEMORY_DIR"

for f in MEMORY.md user.md project.md; do
    src="$SCRIPT_DIR/claude/memory/$f"
    dest="$MEMORY_DIR/$f"
    if [[ -f "$dest" ]]; then
        ok "Memory: $f already exists — skipping"
    else
        cp "$src" "$dest"
        ok "Memory: $f copied"
    fi
done

# ─────────────────────────────────────────────────────────────────────────────
# STEP 14 — Conversation log
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "── Step 14: Conversation log ─────────────────────────────────"
LOG_SRC="$SCRIPT_DIR/logs/conversation-log.md"
LOG_DEST="$LEARNING/AI docs/conversation-log.md"

if [[ -f "$LOG_DEST" ]]; then
    ok "Conversation log already exists — skipping (run sync.sh to update)"
else
    cp "$LOG_SRC" "$LOG_DEST"
    ok "Conversation log copied to $LEARNING/AI docs/"
fi

# ─────────────────────────────────────────────────────────────────────────────
# STEP 15 — Claude hook: auto-sync on tracked file changes
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "── Step 15: Claude hook — auto-sync ─────────────────────────"
HOOKS_DIR="$HOME/.claude/hooks"
HOOK_DEST="$HOOKS_DIR/auto-sync.sh"
HOOK_SRC="$SCRIPT_DIR/claude/hooks/auto-sync.sh"
GLOBAL_SETTINGS="$HOME/.claude/settings.json"
mkdir -p "$HOOKS_DIR"

# Install hook script
if [[ -f "$HOOK_DEST" ]]; then
    ok "auto-sync.sh hook already installed"
else
    cp "$HOOK_SRC" "$HOOK_DEST"
    chmod +x "$HOOK_DEST"
    ok "auto-sync.sh hook installed at $HOOK_DEST"
fi

# Add hook to ~/.claude/settings.json using python3 (avoids jq dependency)
HOOK_REGISTERED=$(python3 -c "
import json, sys
with open('$GLOBAL_SETTINGS') as f:
    s = json.load(f)
hooks = s.get('hooks', {}).get('PostToolUse', [])
for h in hooks:
    if 'auto-sync' in str(h):
        print('yes')
        sys.exit()
print('no')
" 2>/dev/null || echo "no")

if [[ "$HOOK_REGISTERED" == "yes" ]]; then
    ok "auto-sync hook already registered in settings.json"
else
    python3 - <<PYEOF
import json

with open('$GLOBAL_SETTINGS') as f:
    settings = json.load(f)

settings.setdefault('hooks', {}).setdefault('PostToolUse', []).append({
    "matcher": "Edit|Write",
    "hooks": [{"type": "command", "command": "$HOOK_DEST"}]
})

with open('$GLOBAL_SETTINGS', 'w') as f:
    json.dump(settings, f, indent=2)
PYEOF
    ok "auto-sync hook registered in ~/.claude/settings.json"
    warn "Restart Claude Code for the hook to take effect."
fi

# ─────────────────────────────────────────────────────────────────────────────
# STEP 16 — Python project: install deps
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "── Step 16: Python dependencies (kafka-ai-python) ───────────"
PYTHON_PROJECT="$LEARNING/kafka-ai-python"
if [[ -d "$PYTHON_PROJECT" ]]; then
    info "Running uv sync in kafka-ai-python..."
    uv sync --all-extras --project "$PYTHON_PROJECT" 2>/dev/null && ok "Python deps installed" || warn "uv sync failed — run manually later"
else
    warn "kafka-ai-python not found — skipping"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Setup complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Next steps:"
echo "  1. Run 'claude' and log in with your Anthropic account"
echo "  2. Run 'gh auth login' to authenticate with GitHub"
if command -v docker &>/dev/null; then
    echo "  3. Ensure Docker Desktop is running before running tests"
fi
echo "  4. Open VS Code / Cursor in $LEARNING to start working"
echo "  5. For Java projects: ensure JAVA_HOME points to Java 21"
echo ""
echo "  Workspace: $AI_TRAINING"
echo "  Claude memory: $MEMORY_DIR"
echo ""
