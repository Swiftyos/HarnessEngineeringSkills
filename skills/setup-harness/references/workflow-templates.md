# Workflow and PR Templates

Replace `{{placeholders}}` with project-specific values. These examples use
GitHub Actions because that is common for public repos; translate the same
contract to Buildkite, GitLab, CircleCI, Jenkins, or another CI provider when
the target repo already uses one. Replace Node/Playwright setup with the repo's
actual toolchain setup.

---

## .github/pull_request_template.md

```markdown
## Intent

_What does this PR do and why?_

## Behavior changes

_What user-visible behavior changed? If none, write "No behavior changes."_

## Validation

- [ ] `./scripts/fast-feedback.sh` passed
- [ ] Relevant smoke/e2e command passed (if behavior changed)
- [ ] Behavior docs updated (if behavior changed)

## Screenshots / video

_Attach screenshots, logs, traces, or artifacts for user-facing or environment-facing changes. Write "N/A" when not relevant._
```

---

## .github/workflows/pr-fast.yml

```yaml
name: PR Fast Feedback

on:
  pull_request:
    branches: [main, master]

permissions:
  contents: read

jobs:
  fast-feedback:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Add the target repo's toolchain setup here.
      # Examples: actions/setup-node, actions/setup-python, actions/setup-go,
      # dtolnay/rust-toolchain, ruby/setup-ruby, docker/setup-buildx-action.

      - name: Install dependencies
        run: {{install_command}}

      - name: Fast feedback
        run: ./scripts/fast-feedback.sh
```

---

## .github/workflows/pr-smoke.yml

Only include if the project has a dedicated smoke/e2e suite that should run on
selected PR paths.

```yaml
name: PR Smoke

on:
  pull_request:
    branches: [main, master]
    paths:
      - '{{behavior_relevant_path}}/**'
      - 'e2e/**'
      - '{{smoke_config_glob}}'

permissions:
  contents: read

jobs:
  smoke:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Add the target repo's toolchain setup here.

      - name: Install dependencies
        run: {{install_command}}

      # Add browser/emulator/service setup only if the smoke suite needs it.

      - name: Run smoke tests
        run: {{smoke_command}}
        env:
          ARTIFACTS_DIR: ${{ github.workspace }}/test-results

      - name: Upload artifacts
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: smoke-results
          path: test-results/
          retention-days: 7
```

---

## .github/workflows/nightly-baseline.yml

```yaml
name: Nightly Baseline

on:
  schedule:
    - cron: '30 4 * * *'  # 4:30 AM UTC daily
  workflow_dispatch:

permissions:
  contents: write
  pull-requests: write

jobs:
  baseline:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Add the target repo's toolchain setup here.

      - name: Install dependencies
        run: {{install_command}}

      # Add browser/emulator/service setup only if the baseline suite needs it.

      - name: Run full test suite
        id: tests
        continue-on-error: true
        run: {{baseline_command}}
        env:
          ARTIFACTS_DIR: ${{ github.workspace }}/test-results

      - name: Upload results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: baseline-results
          path: test-results/
          retention-days: 30

      - name: Open fix-forward PR on failure
        if: steps.tests.outcome == 'failure'
        uses: peter-evans/create-pull-request@v6
        with:
          title: 'fix: nightly baseline failure'
          body: |
            The nightly baseline suite failed.
            See the [workflow run](${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}) for details.
          branch: fix/nightly-baseline
          delete-branch: true
```

---

## .github/workflows/weekly-doc-gardening.yml

```yaml
name: Weekly Doc Gardening

on:
  schedule:
    - cron: '0 9 * * 1'  # 9 AM UTC every Monday
  workflow_dispatch:

permissions:
  contents: write
  pull-requests: write

jobs:
  refresh:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Add the target repo's toolchain setup here.

      - name: Install dependencies
        run: {{install_command}}

      - name: Refresh generated docs
        run: |
          {{generate_workspace_docs_command}}
          {{refresh_quality_score_command}}

      - name: Check for changes
        id: changes
        run: |
          if git diff --quiet; then
            echo "changed=false" >> "$GITHUB_OUTPUT"
          else
            echo "changed=true" >> "$GITHUB_OUTPUT"
          fi

      - name: Open maintenance PR
        if: steps.changes.outputs.changed == 'true'
        uses: peter-evans/create-pull-request@v6
        with:
          title: 'docs: refresh generated docs'
          body: |
            Weekly automated refresh of generated documentation.
            Review the changes and merge if they look correct.
          branch: docs/weekly-refresh
          delete-branch: true
```

---

## .github/workflows/automerge.yml

```yaml
name: Automerge

on:
  pull_request_review:
    types: [submitted]
  check_suite:
    types: [completed]

permissions:
  contents: write
  pull-requests: write

jobs:
  automerge:
    runs-on: ubuntu-latest
    # Only run for PRs that are approved and all checks pass
    if: >
      github.event.review.state == 'approved' ||
      github.event.check_suite.conclusion == 'success'
    steps:
      - uses: actions/checkout@v4

      - name: Check automerge eligibility
        id: eligible
        run: |
          # Stage 1: No automerge — human merge required
          # Uncomment Stage 2 when the repo is stable enough:
          #
          # ELIGIBLE_PATHS=(
          #   "docs/"
          #   "e2e/"
          #   "**/*.test.*"
          #   "**/*.spec.*"
          # )
          #
          # PROTECTED_PATHS=(
          #   "**/migrations/**"
          #   "**/auth/**"
          #   "**/billing/**"
          #   "**/.env*"
          #   "**/credentials*"
          #   "**/secrets*"
          #   ".github/**"
          #   "AGENTS.md"
          #   "docs/HARNESS_ENGINEERING.md"
          #   "docs/HARNESS.md"
          # )

          echo "eligible=false" >> "$GITHUB_OUTPUT"
          echo "Stage 1: automerge disabled. Human merge required."

      # Uncomment when ready for Stage 2:
      # - name: Auto-merge
      #   if: steps.eligible.outputs.eligible == 'true'
      #   run: gh pr merge --auto --squash "${{ github.event.pull_request.number }}"
      #   env:
      #     GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## Automerge path classification file

Create `.github/automerge-paths.json` to configure eligible paths:

```json
{
  "stage": 1,
  "eligible_paths": [],
  "protected_paths": [
    "**/migrations/**",
    "**/auth/**",
    "**/billing/**",
    "**/.env*",
    "**/credentials*",
    "**/secrets*",
    ".github/**",
    "AGENTS.md",
    "docs/HARNESS_ENGINEERING.md",
    "docs/HARNESS.md"
  ],
  "notes": "Stage 1: no automerge. Graduate to Stage 2 after repo is stable."
}
```
