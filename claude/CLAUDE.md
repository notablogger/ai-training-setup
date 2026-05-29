# Workspace: AI Training — Learning to Code

## Purpose

This workspace is a study in how to use AI effectively, not just a coding project. The primary goal is to understand how AI thinks, responds, and can be directed to produce production-quality work through conversation alone.

Always be aware of this framing: the user is learning AI alongside learning the tech. Explanations should cover the "why", not just the "what".

---

## Projects

### kafka-ai-spring-boot
**Path:** `learning to code/kafka-ai-spring-boot/`
**Remote:** `github.com/notablogger/ai-spring-kafka`
**Status:** Java phase complete (19 conversation entries, audited, integration tests passing)

Event-driven Java Spring Boot application. The vehicle for learning AI-assisted development. Same app will be rebuilt in Go, Python, Node.js to compare AI behaviour across ecosystems.

**Stack:** Spring Boot, Kafka, Avro, Schema Registry, PostgreSQL (write/CQRS), MongoDB (read/CQRS), Testcontainers

**Architecture:**
```
POST/PUT/DELETE → EmployeeService → Postgres (source of truth)
                        │
                EmployeeEventProducer
                        │
               employee_topic (Kafka)
                        │
              EmployeeEventConsumer
                        │
                     MongoDB (read store)
                        │
              GET → latest event snapshot per employee, DELETED excluded
```

**Build commands:**
```bash
cd "learning to code/kafka-ai-spring-boot"
./gradlew build              # compile + test
./gradlew test               # integration tests (Testcontainers — needs Docker)
./gradlew bootRun            # run app (needs docker-compose services up first)
docker-compose up -d         # start all infra (Postgres, Kafka, Schema Registry, MongoDB)
./scripts/register-schema.sh # register Avro schema with Schema Registry
```

**Key directories:**
- `src/` — application source
- `docs/` — deep-dive reference docs (Kafka, Postgres, MongoDB, Avro, build)
- `AI docs/` — meta-docs about how AI helped build this
  - `conversation-log.md` — full history of every prompt, what AI understood, what it did, Feedback
  - `how-ai-helped-me-build-this.md` — reflections on AI-assisted development
  - `prompt-new-language.md` — reusable prompt to rebuild the app in Go, Python, Node.js

**Multi-language roadmap:** Python → `kafka-ai-python/` ✅, Go → `kafka-ai-go/`, Node.js → `kafka-ai-node/` (all under `learning to code/`)

---

### spring-xpose
**Path:** `spring-xpose/spring-xpose/`
**Remote:** `github.com/notablogger/spring-xpose`
**Status:** Active, published to Maven Central (v3.0.1), has CI/CD pipelines

Java annotation processor library. Annotate a JPA entity with `@ExposeEntity` (or a MongoDB document with `@ExposeDocument`) and get a fully generated REST API at compile time — repository, DTO, MapStruct mapper, `@RestController` with OpenAPI docs, and a `SecurityFilterChain`. No runtime magic; generates real readable `.java` files.

**Module layout:**
```
spring-xpose/
├── annotations/   Pure annotation definitions — zero runtime deps
├── processor/     APT entry point + generators — compile-time only
└── starter/       Spring Boot autoconfiguration + runtime support
```

**Build commands:**
```bash
cd spring-xpose/spring-xpose
./gradlew build     # compile + test
./gradlew publish   # publish to Maven Local (for local testing)
```

**Key files:**
- `docs/tech/` — architecture, annotation reference, generator guide, branch rules
- `.github/workflows/` — `ci.yml` (build + test on PR), `pr.yml`, `release.yml` (Maven Central publish)
- `CONTRIBUTING.md` — contribution guidelines
- `prompt.md` — AI prompt used to help build this

---

### spring-xpose-sample-rest
**Path:** `spring-xpose/spring-xpose-sample-rest/`
**Remote:** `github.com/notablogger/spring-xpose-sample-rest`
**Status:** Active sample app, has CI/CD

Sample application demonstrating spring-xpose. Uses `@ExposeEntity` and `@ExposeDocument` to generate REST endpoints. Has OAuth-secured and public endpoint test suites.

**Build commands:**
```bash
cd spring-xpose/spring-xpose-sample-rest
./gradlew build
./gradlew test
docker-compose up -d  # PostgreSQL + MongoDB
```

---

### python_ai
**Path:** `python_ai/`
**Remote:** `git.i.mercedes-benz.com:NIKGOYA/python_ai` (internal — not accessible via GitHub CLI)
**Status:** Empty repo, no commits yet

Work project at Mercedes-Benz. Python AI project — purpose and scope to be established.

---

### drivin-uae.tsx
**Path:** `drivin-uae.tsx` (standalone file at workspace root)

Standalone React component. Purpose unclear — likely an experiment or prototype.

---

## Custom Skills

### /verify
**Trigger:** Any time a file, doc, prompt, or spec is referenced before acting on it.
**Action:** Read the file first. Never assume content from the filename or memory — always verify. This applies to: `prompt-new-language.md`, any doc referenced in a plan, any config file about to be modified, any schema about to be used.
**Rule:** If you haven't read it in this session, read it before acting on it.

### /standards
**Trigger:** Starting any work in a new language, framework, or library.
**Action:**
1. Research current best practices for the stack (spawn Explore agent if broad)
2. Check latest stable versions of all libraries — do not assume from training data
3. Check for deprecations before recommending a library (e.g. Motor deprecated 5/14/2025)
4. Document the stack decision (library name + version + reason) before writing any code
**Rule:** Never hardcode a library version from memory. Always verify it's still current and not deprecated.

### /log
**Trigger:** After any meaningful interaction (code written, fix made, explanation given, question answered).
**Action:** Append a new row to the workspace-level conversation log at `learning to code/AI docs/conversation-log.md`. This is a single log covering all projects in this workspace — no per-project logs.

Format:
| # | Prompt (verbatim or paraphrased) | What AI understood | What AI did | Feedback |
|---|---|---|---|---|
| N | "..." | ... | ... | Pending |

Rules:
- Log AFTER completing the work, not before
- "What AI understood" = the intent behind the prompt, not a restatement of it
- "What AI did" = actions taken, files created/modified, decisions made — concrete and specific
- "Feedback" starts as "Pending". Update when the user signals a reaction
- Increment the row number from the last entry

### /audit
**Trigger:** "does this follow standards?", "check for issues", or equivalent.
**Action:** Review current project for: missing validation, wrong config values, lazy loading risks, hardcoded values, missing error handling, incorrect dependency scopes. Report each finding with: what it is, why it matters, fix. Then apply all fixes.

### /new-language
**Trigger:** "start in Go / Python / Node", "rebuild in [language]", or equivalent.
**Action:** Read `AI docs/prompt-new-language.md`, confirm the target language, then execute the full prompt template as the starting point for the new subfolder.

### /explain
**Trigger:** "explain what you changed", "why did you do X", "walk me through it".
**Action:** For each change made: explain what it is, why it was needed, what would have happened without it, and the underlying concept. Aim at someone learning — "why this matters in production", not just "what it does".

---

## Logging Protocol

After every substantive interaction, append to `learning to code/AI docs/conversation-log.md`. Substantive = anything that creates/modifies files, explains an architectural decision, fixes a bug, or answers a meaningful technical question.

Do NOT log: short clarification questions, simple status checks.

When the user signals feedback ("liked it", "that wasn't right", etc.), find the relevant log entry and update the Feedback column.

---

## Tone and Style

- Always cover the "why" — this user is learning, not just shipping
- Never do a thing silently — state what was understood and what was done
- After any fix or generation, offer to explain it
- Match the documentation style already established in each project's `docs/` and `AI docs/`
