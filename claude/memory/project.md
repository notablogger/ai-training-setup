---
name: project-kafka-ai
description: "Full ai_training workspace — four active projects across Java, Python, React; GitHub access as notablogger"
metadata: 
  node_type: memory
  type: project
  originSessionId: 03cc952f-83fc-4d45-9ee3-b5c18522f922
---

## Workspace: /Users/goyalnik/ai_training

### kafka-ai-spring-boot
**Remote:** `github.com/notablogger/ai-spring-kafka`
Java Spring Boot event-driven app (Kafka, Avro, Postgres CQRS write, MongoDB CQRS read, Testcontainers). **Complete** — 19 conversation log entries, production audit done, integration tests passing.

**Why:** Phase 1 of a multi-language experiment. Same app to be rebuilt in Go, Python, Node.js to compare AI behaviour across ecosystems. Prompt template at `AI docs/prompt-new-language.md`.

**How to apply:** When user says "start Go/Python/Node", read the prompt template and scaffold the new subfolder under `learning to code/`.

### spring-xpose
**Remote:** `github.com/notablogger/spring-xpose`
Java APT library — annotate JPA entities/MongoDB docs, get full REST API generated at compile time. Published to Maven Central at v3.0.1. Has CI/CD (ci.yml, pr.yml, release.yml). Active project.

### spring-xpose-sample-rest
**Remote:** `github.com/notablogger/spring-xpose-sample-rest`
Sample app demonstrating spring-xpose. OAuth-secured + public endpoint tests.

### python_ai
**Remote:** `git.i.mercedes-benz.com:NIKGOYA/python_ai` (internal, not accessible via GitHub CLI)
Work project at Mercedes-Benz. Empty repo — no commits yet.

### drivin-uae.tsx
Standalone React component at workspace root. Purpose unknown — likely an experiment.

### ai-training-setup
**Remote:** `github.com/notablogger/ai-training-setup`
Portable workspace setup repo. Run `setup.sh` on a new Mac to bootstrap everything. Run `sync.sh` to sync CLAUDE.md, memory files, settings, and conversation log back to GitHub. Should be synced before migrating machines.

## GitHub
Logged in as `notablogger` with `repo`, `workflow`, `gist`, `read:org` scopes. All public repos accessible via `gh` CLI.

Related: [[user-profile]]
