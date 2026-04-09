# Harness Engineering Skills

Skills that encode the practices of **harness engineering** — the discipline of designing environments, constraints, and feedback loops so AI coding agents can work autonomously at speed.

The core idea: stop writing code, start building systems. When your attention is the only scarce resource, the leverage comes from encoding standards once and letting agents execute.

## Background

Harness engineering emerged from OpenAI's Frontier team, where three engineers built a production app with zero human-written code over five months. The key insight wasn't about better prompts — it was about better scaffolding: specs, fast build loops, observability, and automated review.

- [Harness Engineering](https://openai.com/index/harness-engineering/) — OpenAI's original post on the discipline
- [Latent Space interview](https://www.latent.space/p/harness-eng) — Deep dive with Ryan Lopopolo on the concrete practices
- [Go Faster](https://aifutureofwork.substack.com/p/go-faster) — The motive: speed through systems, not effort

## Skills

| Skill | Description |
|-------|-------------|
| [`bootstrap`](skills/bootstrap/) | Scaffold a new repo for agent-first development — docs, harness scripts, CI, smoke tests, and automerge workflows |

### Install

```bash
npx skills add Swiftyos/HarnessEngineeringSkills@bootstrap
```

## Principles

These skills encode a few hard-won ideas:

1. **Agents run scripts, not ad-hoc commands.** Scripts are the source of truth. If an agent keeps making the same mistake, the fix is a better script — not a better prompt.

2. **One-minute build loops.** Fast feedback keeps agents productive. When builds get slow, refactor the architecture rather than relaxing the constraint.

3. **Docs fail CI.** Generated docs have freshness checks. Links are validated. Drift between AGENTS.md and actual repo structure is caught automatically.

4. **Start conservative on automerge.** Green CI + agent review + human merge. Widen only after the repo proves stable.

5. **Code is disposable, structure is not.** Agents can regenerate code from specs. What matters is the scaffolding: the docs, the checks, the feedback loops.

## License

MIT
