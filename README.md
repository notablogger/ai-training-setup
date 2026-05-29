# ai-training-setup

Portable setup for the `ai_training` workspace. Clone this repo on any Mac, run the setup script, and get the full environment — Claude config, memory, skills, and all project repos — ready in one go.

---

## What It Contains

```
ai-training-setup/
├── setup.sh              # Bootstrap script — run this on a new machine
├── sync.sh               # Sync script — run this to update the repo from current state
├── claude/
│   ├── CLAUDE.md         # Workspace-level Claude context + custom skills
│   ├── settings.json     # Global Claude settings (model, effort level)
│   └── memory/
│       ├── MEMORY.md     # Memory index (auto-loaded by Claude Code)
│       ├── user.md       # Who you are, how you work, what you value
│       └── project.md    # Active projects, their state, and remotes
└── logs/
    └── conversation-log.md  # Full history of AI interactions across all projects
```

---

## Setup (New Machine)

```bash
# 1. Clone this repo anywhere (doesn't matter where)
git clone https://github.com/notablogger/ai-training-setup.git
cd ai-training-setup

# 2. Run the setup script
chmod +x setup.sh
./setup.sh
```

The script will:

| Step | What it does |
|---|---|
| 1 | Install Homebrew (if missing) |
| 2 | Install Node.js (required for Claude Code CLI) |
| 3 | Install Claude Code CLI via npm |
| 4 | Install uv (Python package manager) |
| 5 | Install Java 21 (Eclipse Temurin via Homebrew) |
| 6 | Install Docker Desktop (via Homebrew Cask) |
| 7 | Install GitHub CLI |
| 8 | Create `~/ai_training/` directory structure |
| 9 | Clone all project repos into the right locations |
| 10 | Copy `CLAUDE.md` to `~/ai_training/` |
| 11 | Copy global Claude settings to `~/.claude/settings.json` |
| 12 | Generate workspace `settings.local.json` with correct paths for this user |
| 13 | Copy Claude memory files to `~/.claude/projects/<key>/memory/` |
| 14 | Copy conversation log to `~/ai_training/learning to code/AI docs/` |
| 15 | Run `uv sync` on the Python project |

All steps are **idempotent** — safe to re-run if something fails partway through.

---

## After Setup

```bash
# Log in to Claude Code
claude

# Log in to GitHub
gh auth login

# Start Docker Desktop (open from Applications)

# Open VS Code / Cursor
code ~/ai_training/learning\ to\ code
```

---

## Project Repos (cloned by setup.sh)

| Repo | Cloned to |
|---|---|
| `notablogger/ai-spring-kafka` | `~/ai_training/learning to code/kafka-ai-spring-boot/` |
| `notablogger/kafka-ai-python` | `~/ai_training/learning to code/kafka-ai-python/` |
| `notablogger/spring-xpose` | `~/ai_training/spring-xpose/spring-xpose/` |
| `notablogger/spring-xpose-sample-rest` | `~/ai_training/spring-xpose/spring-xpose-sample-rest/` |

> `python_ai` is on Mercedes-Benz internal git — clone manually if needed.

---

## Keeping It Up to Date

Run `sync.sh` on your current machine before migrating or periodically to keep the repo fresh:

```bash
cd ai-training-setup
./sync.sh            # copies latest config + logs and pushes to GitHub
./sync.sh --dry-run  # preview what would change without touching anything
```

What `sync.sh` captures:

- `~/ai_training/CLAUDE.md` — custom skills and workspace context
- `~/.claude/settings.json` — global model/effort settings
- `~/.claude/projects/.../memory/` — user.md, project.md, MEMORY.md
- `~/ai_training/learning to code/AI docs/conversation-log.md` — full interaction log

---

## Custom Skills (defined in CLAUDE.md)

Once Claude Code loads `CLAUDE.md`, these skills are active in every session:

| Skill | When it triggers | What it does |
|---|---|---|
| `/log` | After any meaningful interaction | Appends a row to `conversation-log.md` |
| `/verify` | Before using any referenced file | Reads the file first — never assumes content |
| `/standards` | Before implementing in a new language | Researches best practices + latest versions |
| `/audit` | "check for issues", "does this follow standards?" | Reviews code, finds bugs, applies fixes |
| `/new-language` | "start in Go", "rebuild in Python" | Reads prompt template and scaffolds new project |
| `/explain` | "explain what you changed", "walk me through it" | Deep explanation of why, not just what |

---

## Notes

- **Username:** `setup.sh` uses `$USER` and `$HOME` — paths are computed dynamically, so it works regardless of username.
- **Memory key:** Claude Code keys memory by workspace path. The script computes `~/.claude/projects/<key>/memory/` correctly for the current user.
- **Java:** The Spring Boot projects require Java 21. `setup.sh` installs Temurin 21. You may need to set `JAVA_HOME` in `~/.zshrc`: `export JAVA_HOME=$(/usr/libexec/java_home -v 21)`.
- **Docker:** Required for Testcontainers integration tests in both Java and Python projects. Open Docker Desktop before running tests.
