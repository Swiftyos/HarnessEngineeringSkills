# Document Templates

Customize every template below using the project details gathered during
orientation. Replace all `{{placeholders}}` with real values. Never leave TODO
placeholders in the final output.

These templates are examples, not mandatory stack choices. Omit sections that do
not fit the target repo, rename files to match established local conventions,
and prefer the repo's existing language, test runner, package manager, and CI
provider.

---

## AGENTS.md

Target: 100–140 lines. This is the entry point for any agent working in the repo.

```markdown
# {{PROJECT_NAME}}

{{one-line description}}

## Project surfaces

- Primary runtime: {{language/framework/toolchain}}
- Interfaces: {{CLI, service, frontend, library, worker, mobile app, etc.}}
- Storage or external services: {{database/queue/provider or "N/A"}}
- Package/build tooling: {{package manager, build tool, task runner}}

## Repo map

```text
{{project_name}}/
├── {{relevant top-level dirs with one-line descriptions}}
├── docs/           # Deep docs — start with docs/README.md
├── scripts/        # All standard commands live here
├── e2e/            # Smoke or end-to-end tests, if applicable
└── .github/        # Workflows and PR template
```

## Docs

| What                    | Where                          |
|-------------------------|--------------------------------|
| Architecture            | `docs/ARCHITECTURE.md`         |
| Harness strategy        | `docs/HARNESS_ENGINEERING.md`  |
| Repo health             | `docs/QUALITY_SCORE.md`        |
| Product behavior spec   | `docs/behaviours/platform.md`  |
| Execution plans         | `docs/exec-plans/`             |

## Standard commands

```bash
# Validate repo structure and docs
./scripts/validate-repo.sh

# Fast feedback loop (run before every PR)
./scripts/fast-feedback.sh

# Smoke or e2e checks when relevant
./scripts/e2e.sh

# Full CI-equivalent harness gate
./scripts/harness-check.sh

# Start local dev stack
./scripts/harness/run-local.sh
```

## Rules

1. Run `./scripts/fast-feedback.sh` before opening a PR. If it fails, fix it.
2. Do not edit generated files in `docs/generated/` by hand — run the generator.
3. Keep this file under 140 lines. Put detail in `docs/`.
4. When behavior changes, update the canonical behavior docs first.
5. Every PR must follow the PR template.
```

---

## Optional directory INDEX.md

Use this only when the target repo chooses per-directory contracts. Some mature
harnesses instead use a concise router plus a generated workspace inventory,
which is often lighter for larger repos. Keep the top two sections
hand-authored, and let generated inventory sections be refreshed by script when
the repo uses this convention.

```markdown
# {{DIRECTORY_NAME}} Index

## Purpose

{{What belongs in this directory and how it fits into the repo.}}

## File conventions

- {{Filename pattern or grouping rule}}
- {{Required content structure or frontmatter, if any}}
- {{What should not be committed here}}

## Files

- [{{FILE_1}}]({{FILE_1}}) — {{What it is for}}
- [{{FILE_2}}]({{FILE_2}}) — {{What it is for}}

## Subdirectories

- [{{SUBDIR_A}}/INDEX.md]({{SUBDIR_A}}/INDEX.md) — {{What lives there}}
- [{{SUBDIR_B}}/INDEX.md]({{SUBDIR_B}}/INDEX.md) — {{What lives there}}
```

Rules when a repo adopts directory indexes:
- each non-generated tracked directory should have an `INDEX.md`
- `INDEX.md` should link to every file in the same directory except itself
- `INDEX.md` should link to each child directory's `INDEX.md`
- the "Purpose" and "File conventions" sections explain what files belong
  there and what format they should follow

---

## docs/README.md

```markdown
# Docs Index

## Architecture and design
- [ARCHITECTURE.md](ARCHITECTURE.md) — Module boundaries and dependency direction
- [HARNESS_ENGINEERING.md](HARNESS_ENGINEERING.md) — Agent harness strategy and merge policy

## Health
- [QUALITY_SCORE.md](QUALITY_SCORE.md) — Repo health summary and incident log

## Product behavior
- [behaviours/](behaviours/) — Canonical behavior specs
  - [platform.md](behaviours/platform.md) — Full behavior spec
  - [current-state.md](behaviours/current-state.md) — What's implemented now
  - [e2e-checklist.md](behaviours/e2e-checklist.md) — Test coverage checklist

## Execution plans
- [exec-plans/](exec-plans/) — Active and completed plans
  - [active/](exec-plans/active/) — In-progress work
  - [completed/](exec-plans/completed/) — Done

## Generated docs
- [generated/](generated/) — Auto-generated docs (do not edit by hand)

## Playbooks
- [playbooks/](playbooks/) — Operational playbooks
```

---

## docs/ARCHITECTURE.md

```markdown
# Architecture

## Overview

{{PROJECT_NAME}} is a {{app type}} built with {{stack summary}}.

## Module boundaries

{{Describe the main modules/packages/services and their responsibilities.
Use a simple dependency diagram if helpful:}}

```text
┌──────────┐     ┌──────────┐
│ Frontend │────▶│   API    │
└──────────┘     └────┬─────┘
                      │
                 ┌────▼─────┐
                 │ Database │
                 └──────────┘
```

## Dependency direction

- Frontend depends on API contracts (types/schemas).
- API depends on database models.
- Database layer has no upstream dependencies.
- Shared types live in {{shared types location}}.

## Key conventions

- {{List 2-3 architectural conventions specific to this project}}
```

---

## docs/HARNESS_ENGINEERING.md or docs/HARNESS.md

```markdown
# Agent Harness Contract

## Commands agents must run

| When                          | Command                          |
|-------------------------------|----------------------------------|
| Before every PR               | `./scripts/fast-feedback.sh`     |
| CI-equivalent local gate       | `./scripts/harness-check.sh`     |
| To validate repo structure    | `./scripts/validate-harness-docs.sh` |
| To run smoke/e2e checks       | `./scripts/e2e.sh`               |
| To start local dependencies   | `./scripts/harness/run-local.sh` |

## PR requirements

Every PR must:
- [ ] Pass `fast-feedback.sh`
- [ ] Include a filled-out PR template
- [ ] Update `docs/behaviours/platform.md` if behavior changed
- [ ] Include screenshots, logs, traces, or artifacts when user-facing or environment-facing behavior changed
- [ ] Run the relevant smoke/e2e command when touching tested behavior

## Automerge eligibility

### Stage 1 (current)
- Green CI
- One independent agent review
- **Human merge required**

### Stage 2 (when repo is stable)
Automerge allowed for: docs, tests, low-risk UI, non-auth service code.

### Stage 3 (when smoke/baseline loop is proven)
Wider automerge with human override.

## Always human-reviewed

These paths never automerge:
- `**/migrations/**`
- `**/auth/**`
- `**/billing/**`
- `**/.env*`, `**/credentials*`, `**/secrets*`
- `.github/**`
- `AGENTS.md`
- `docs/HARNESS_ENGINEERING.md`, `docs/HARNESS.md`

## Failure escalation

1. If `fast-feedback.sh` fails: fix before merging. No exceptions.
2. If smoke/e2e checks fail: investigate. Do not skip without recording why.
3. If nightly baseline breaks: an auto-PR is opened. Fix forward.
4. If generated docs are stale: refresh and commit.
```

---

## docs/QUALITY_SCORE.md

```markdown
# Quality Score

Last updated: {{today's date}}

## Health summary

| Area              | Status | Notes                     |
|-------------------|--------|---------------------------|
| CI                | 🟢     | All workflows passing     |
| Test coverage     | 🟡     | Smoke tests only          |
| Doc freshness     | 🟢     | Generated docs up to date |
| Baseline debt     | 🟢     | No baselined violations   |

## Incidents

_No incidents yet._

## Next cleanup targets

1. Expand smoke test coverage beyond basic renders
2. Add integration tests for core API endpoints
3. Fill out remaining behavior scenarios in platform.md
```

---

## docs/behaviours/README.md

```markdown
# Behaviour Specs

## Files

- **platform.md** — Canonical product behavior spec. This is the source of truth.
- **current-state.md** — Summary of what's currently implemented. Validated against platform.md.
- **e2e-checklist.md** — Test coverage checklist derived from platform.md.

## Rules

1. When behavior changes, update `platform.md` first.
2. `current-state.md` and `e2e-checklist.md` are summary views — they must be consistent with `platform.md`.
3. Do not maintain summary views by vibes. Run `./scripts/check-behaviour-docs.mjs` to validate.
```

---

## docs/behaviours/platform.md

```markdown
# {{PROJECT_NAME}} — Platform Behavior Spec

## Overview

{{Brief description of what the product does and who uses it.}}

## Scenarios

### {{Scenario 1 name}}

**Given** {{precondition}}
**When** {{action}}
**Then** {{expected outcome}}

### {{Scenario 2 name}}

**Given** {{precondition}}
**When** {{action}}
**Then** {{expected outcome}}

### {{Scenario 3 name}}

**Given** {{precondition}}
**When** {{action}}
**Then** {{expected outcome}}

---

_Add new scenarios here as the product grows. Each scenario should be concrete
and testable._
```

---

## docs/behaviours/current-state.md

```markdown
# Current State

Last validated against `platform.md`: {{today's date}}

## Implemented scenarios

- [ ] {{Scenario 1}} — not yet implemented
- [ ] {{Scenario 2}} — not yet implemented
- [ ] {{Scenario 3}} — not yet implemented

## Known gaps

_List features described in platform.md that are not yet built._
```

---

## docs/behaviours/e2e-checklist.md

```markdown
# E2E Test Checklist

Derived from `platform.md`. Each scenario should have at least one test.

| Scenario              | Test file                  | Status      |
|-----------------------|----------------------------|-------------|
| {{Scenario 1}}       | `e2e/smoke.behavior.spec.ts` | ⬜ not covered |
| {{Scenario 2}}       | —                          | ⬜ not covered |
| {{Scenario 3}}       | —                          | ⬜ not covered |
```

---

## docs/exec-plans/README.md

```markdown
# Execution Plans

Plans for multi-step work that spans multiple PRs or sessions.

## Active

_No active plans._

See [active/](active/) for in-progress plans.

## Completed

See [completed/](completed/) for finished plans.

## Plan format

Each plan should include:
1. Goal — what we're trying to achieve
2. Steps — ordered list of discrete tasks
3. Dependencies — what blocks what
4. Validation — how we know it's done
```

---

## Suggested directory contracts

Use these expectations only when the repo adopts per-directory `INDEX.md`
contracts:

- Repo root: explain top-level entrypoints, which files are policy docs versus
  project docs, and point to each major directory's `INDEX.md`.
- `docs/`: explain that long-lived repo documentation lives here, written in
  Markdown with stable relative links.
- `docs/behaviours/`: explain that behavior specs are Markdown, `platform.md`
  is the source of truth, and summary docs must stay derivable from it.
- `docs/exec-plans/`: explain plan-doc structure and that child directories
  split active work from completed work.
- `docs/exec-plans/active/`: explain naming by workstream/date and required
  sections: Goal, Scope, Tasks, Decision Log, Verification.
- `docs/exec-plans/completed/`: explain that completed plans retain the same
  structure plus outcome/shipping notes.
- `docs/generated/`: explain files are script-generated and not edited by hand.
- `docs/playbooks/`: explain operational runbooks are Markdown and should
  include trigger, steps, validation, and rollback/escalation guidance.
