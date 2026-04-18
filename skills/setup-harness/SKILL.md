---
name: setup-harness
description: >
  Bootstrap a repository for agent-first development when there is no agent
  harness yet, or when the repo has only minimal ad hoc scaffolding. Use when
  the user asks to set up a new repo, scaffold an agent-ready project, add
  AGENTS.md, create harness scripts, validation gates, source-of-truth docs,
  CI, smoke or e2e loops, repo-local review skills, or automerge policy. For a
  repo that already has a working agent harness and needs modernization or
  repair, prefer update-harness.
---

# Setup Harness

Set up the repository so future agents can learn the project from committed
artifacts, run the same commands humans run, validate their own work, and leave
auditable evidence. The rule of thumb: when an agent struggles, improve the
environment before adding more prompt text.

This skill is language and framework agnostic. Discover the target repo's
toolchain first, then express the harness through that repo's existing scripts,
package manager, test runner, CI provider, and documentation style.

## Operating Rules

- Inspect before writing: read the existing README, build files, package or
  workspace manifests, CI, scripts, and docs.
- Keep `AGENTS.md` short. It is a router to deeper docs, not the encyclopedia.
- Prefer mechanical checks over advisory prose whenever a rule will matter more
  than once.
- Put durable decisions in the repo: docs, scripts, schemas, generated reports,
  tests, workflows, or repo-local skills.
- Add narrow, composable scripts. Agents should run script entrypoints, not
  reconstruct command chains from memory.
- Use the target repo's existing tooling unless there is no reasonable local
  choice. Do not impose Rust, Node, Playwright, Docker, GitHub Actions, or any
  other stack by default.
- Make expensive or environment-specific checks opt-in unless the repo's normal
  development loop already requires them.
- Preserve user work and local conventions. Do not overwrite existing harness
  files; evolve them.

## Phase 1: Orientation

Build a harness inventory before creating files:

- product or library purpose
- app type: service, frontend, CLI, library, worker, monorepo, data pipeline,
  mobile app, infrastructure repo, or mixed workspace
- language and framework surfaces
- package manager, build tool, test runner, formatter, linter, and CI provider
- local dependencies such as databases, queues, browsers, emulators, secrets, or
  external services
- existing docs, scripts, CI, PR template, repo-local skills, and agent
  instructions
- risky areas that should stay human-reviewed: migrations, auth, billing,
  credentials, sandboxing, workflow files, shared contracts, release tooling

Ask the user only for facts that are not discoverable and would materially
change the scaffold.

## Phase 2: Harness Shape

Create the smallest complete harness that fits the repo. For a new repository,
that usually means these surfaces.

### Agent Router

Create or update root `AGENTS.md` with:

- what the repo builds
- a compact repo map
- links to source-of-truth docs and generated references
- standard script entrypoints
- hard rules that should apply to every agent run
- pointers to scoped `AGENTS.md` files for large modules, packages, services, or
  ownership boundaries

Use scoped `AGENTS.md` files only where they reduce ambiguity. A small repo does
not need per-directory instructions.

### Source-Of-Truth Docs

Add a `docs/` map that routes agents to durable knowledge:

- `docs/README.md`: documentation map
- `docs/ARCHITECTURE.md`: boundaries, dependency direction, invariants
- `docs/HARNESS_ENGINEERING.md` or `docs/HARNESS.md`: harness strategy,
  required commands, validation contract, and merge policy
- `docs/PLANS.md`: execution-plan workflow and required sections
- `docs/QUALITY_SCORE.md`: current quality baseline, ratchets, and next targets
- `docs/SECURITY.md` and `docs/RELIABILITY.md` when the repo has security,
  persistence, runtime, or production reliability concerns
- `docs/behaviours/`: canonical scenarios, current validation state, and e2e or
  manual checklist
- `docs/design-docs/`, `docs/product-specs/`, or `docs/references/` when deeper
  design decisions, product behavior, or external references need a stable home
- `docs/generated/`: generated inventory, public-surface reference, quality
  snapshot, CLI help, API schema, load baseline, or whatever generated
  references are valuable for the repo

Use `last_reviewed: YYYY-MM-DD` frontmatter on source-of-truth docs if the repo
needs freshness checks.

### Execution Plans

Create `docs/exec-plans/active/` and `docs/exec-plans/completed/` for complex
work. Every non-readme plan should include:

- `## Goal`
- `## Scope`
- `## Tasks`
- `## Decision Log`
- `## Verification`

Plans are for coupled or multi-step work. Small edits should not be buried in
process.

### Script Entry Points

Add a `scripts/README.md` that catalogs all important scripts. Prefer these
entrypoints:

- `scripts/fast-feedback.sh`: local pre-PR gate for cheap deterministic checks
- `scripts/harness-check.sh`: full CI gate; includes slower tests and stricter
  drift checks
- `scripts/validate-harness-docs.sh`: required docs, links between router docs,
  plan headings, and doc structure
- `scripts/check-doc-links.*`: markdown links and source-of-truth references
- `scripts/check-agents-drift.*`: `AGENTS.md` still points at the real docs and
  repo surfaces
- `scripts/check-behaviour-docs.*`: canonical scenarios appear in current-state
  and e2e checklist docs
- `scripts/check-doc-freshness.*`: source-of-truth docs are recently reviewed
- `scripts/check-generated-docs.*`: generated references are current
- boundary checks for the repo's architecture, such as package dependencies,
  module ownership, API compatibility, or import rules
- generators for workspace inventory, public APIs, CLI help, schemas, quality
  health, or performance baselines
- local dependency helpers that allocate random ports or per-worktree data
  directories instead of assuming global ports
- an e2e or smoke runner that writes logs and artifacts and reports skipped
  environment-gated steps explicitly

Implementation language is a repo choice. Shell is useful for orchestration, but
checks can be Python, JavaScript, Go, Rust, Ruby, Make, Just, or any tool the
repo already standardizes on.

### Review Gates

If repo-local skills are supported, add narrow pre-PR skills:

- `.agents/skills/review/SKILL.md`: confirmed-issue-only correctness and
  reliability review
- `.agents/skills/security-review/SKILL.md`: confirmed high-impact security
  review

Wire a mechanical companion such as `scripts/pre-pr-review.sh` into
`fast-feedback` and `harness-check`. It should verify the review artifacts are
present and catch changed-file hazards across unstaged, staged, and committed
branch diffs.

### CI And Gardening

Use the target repo's CI provider. A good baseline has:

- a PR/push workflow that runs `scripts/harness-check.sh`
- a PR template requiring intent, behavior changes, validation evidence, and
  screenshots or artifacts when relevant
- scheduled generated-doc refresh
- scheduled doc freshness or source-of-truth review
- scheduled plan sweep for stale active plans
- scheduled boundary or dependency audit if the repo has important module
  contracts
- scheduled review-pattern mining if the team wants recurring PR feedback to
  become new checks or docs

Start automerge conservatively. Critical paths should require a human until the
repo has enough green history to widen automation. Critical paths are
repo-specific, but commonly include migrations, auth, billing, credentials,
secrets, sandboxing, workflow files, root agent instructions, harness policy,
and shared public contracts.

## Phase 3: Scaffold In Slices

Work in reviewable slices, continuing unless the user asks to pause:

1. Add the router and docs map.
2. Add execution-plan directories and plan template.
3. Add script entrypoints and script catalog.
4. Add generated docs and drift checks.
5. Add smoke or e2e runners with artifacts.
6. Add review and security review gates.
7. Add CI and scheduled gardening.
8. Add automerge only after the validation and review gates exist.

For each slice, adapt the templates in `references/` to the target repo. Treat
those files as examples, not mandatory stack choices.

## Validation Strategy

Order checks so cheap, structural failures surface first:

1. harness docs and router drift
2. markdown links and generated-doc freshness
3. behavior scenario parity
4. architecture or module-boundary checks
5. formatting, linting, typechecking, static analysis
6. unit and integration tests
7. smoke or e2e tests
8. environment-gated tests such as databases, browsers, live providers, or
   observability stacks

`fast-feedback` should be fast enough for every normal PR. `harness-check`
should match CI and can be slower. Environment-gated checks should either run
when prerequisites are present or skip with a clear reason.

If the repo already has violations, baseline them deliberately and fail only on
regressions. Tell the user what was baselined and where the burn-down target
lives.

## Definition Of Done

A setup is complete when:

- a new agent can start at `AGENTS.md` and find the right docs, scripts, and
  validation path
- repeated project rules are encoded in scripts, CI, generated docs, or
  templates
- `scripts/fast-feedback.sh` and the full CI-equivalent gate both run or have
  documented blockers
- generated docs can be refreshed and checked for drift
- behavior-changing work has a place to update canonical scenarios
- complex work has a checked-in plan lifecycle
- risky paths have a human-review or automerge refusal policy
- the final response lists the created or updated files and the validation that
  passed or could not be run
