#!/usr/bin/env bash
set -euo pipefail

# validate-setup.sh
#
# Checks that a newly scaffolded agent harness has the common language-agnostic
# surfaces in place. Copy into a target repo after adapting the expected file
# list to that repo's conventions.
#
# Usage:
#   ./scripts/validate-setup.sh [--has-smoke] [--has-local-harness]
#                               [--uses-indexes] [--github-actions]
#                               [--has-review-skills]
#
# Backward-compatible aliases:
#   --has-frontend  same as --has-smoke
#   --has-harness   same as --has-local-harness

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

HAS_SMOKE=false
HAS_LOCAL_HARNESS=false
USES_INDEXES=false
GITHUB_ACTIONS=false
HAS_REVIEW_SKILLS=false

for arg in "$@"; do
  case "$arg" in
    --has-smoke|--has-frontend) HAS_SMOKE=true ;;
    --has-local-harness|--has-harness) HAS_LOCAL_HARNESS=true ;;
    --uses-indexes) USES_INDEXES=true ;;
    --github-actions) GITHUB_ACTIONS=true ;;
    --has-review-skills) HAS_REVIEW_SKILLS=true ;;
    *)
      echo "unknown argument: $arg" >&2
      exit 2
      ;;
  esac
done

PASS=0
FAIL=0
WARN=0

pass() { PASS=$((PASS + 1)); echo "  OK   $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  FAIL $1"; }
warn() { WARN=$((WARN + 1)); echo "  WARN $1"; }

check_file() {
  local path="$1"
  local label="${2:-$1}"
  if [[ -f "$REPO_ROOT/$path" ]]; then
    pass "$label"
  else
    fail "$label missing: $path"
  fi
}

check_dir() {
  local path="$1"
  local label="${2:-$1}"
  if [[ -d "$REPO_ROOT/$path" ]]; then
    pass "$label"
  else
    fail "$label missing: $path"
  fi
}

check_executable() {
  local path="$1"
  local label="${2:-$1}"
  if [[ -x "$REPO_ROOT/$path" && -f "$REPO_ROOT/$path" ]]; then
    pass "$label"
  elif [[ -f "$REPO_ROOT/$path" ]]; then
    fail "$label exists but is not executable: $path"
  else
    fail "$label missing: $path"
  fi
}

check_optional_file() {
  local path="$1"
  local label="${2:-$1}"
  if [[ -f "$REPO_ROOT/$path" ]]; then
    pass "$label"
  else
    warn "$label optional missing: $path"
  fi
}

check_any_file() {
  local label="$1"
  shift
  local path
  for path in "$@"; do
    if [[ -f "$REPO_ROOT/$path" ]]; then
      pass "$label ($path)"
      return 0
    fi
  done
  fail "$label missing one of: $*"
}

check_any_executable() {
  local label="$1"
  shift
  local path
  for path in "$@"; do
    if [[ -x "$REPO_ROOT/$path" && -f "$REPO_ROOT/$path" ]]; then
      pass "$label ($path)"
      return 0
    fi
  done
  fail "$label missing executable one of: $*"
}

check_glob() {
  local label="$1"
  local pattern="$2"
  local matches=()
  while IFS= read -r match; do
    matches+=("$match")
  done < <(cd "$REPO_ROOT" && compgen -G "$pattern" || true)
  if [[ "${#matches[@]}" -gt 0 ]]; then
    pass "$label (${matches[0]})"
  else
    fail "$label missing glob: $pattern"
  fi
}

echo
echo "=== Agent Harness Setup Validation ==="
echo "Repo: $REPO_ROOT"
echo

echo "-- Core entrypoints --"
check_file "AGENTS.md" "AGENTS.md router"
check_optional_file "README.md" "README.md"
if $USES_INDEXES; then
  check_file "INDEX.md" "root INDEX.md"
fi
echo

echo "-- Source-of-truth docs --"
check_file "docs/README.md" "docs map"
check_file "docs/ARCHITECTURE.md" "architecture doc"
check_any_file "harness strategy doc" "docs/HARNESS_ENGINEERING.md" "docs/HARNESS.md"
check_file "docs/PLANS.md" "execution-plan workflow"
check_file "docs/QUALITY_SCORE.md" "quality baseline"
check_optional_file "docs/SECURITY.md" "security doc"
check_optional_file "docs/RELIABILITY.md" "reliability doc"
echo

echo "-- Behaviour docs --"
check_file "docs/behaviours/README.md" "behaviour docs map"
check_file "docs/behaviours/platform.md" "canonical scenarios"
check_file "docs/behaviours/current-state.md" "current validation state"
check_file "docs/behaviours/e2e-checklist.md" "e2e checklist"
echo

echo "-- Execution plans and generated docs --"
check_dir "docs/exec-plans/active" "active execution plans"
check_dir "docs/exec-plans/completed" "completed execution plans"
check_dir "docs/generated" "generated docs directory"
check_optional_file "docs/generated/README.md" "generated docs map"
echo

echo "-- Script entrypoints --"
check_file "scripts/README.md" "script catalog"
check_executable "scripts/fast-feedback.sh" "fast local gate"
check_executable "scripts/harness-check.sh" "full harness gate"
check_any_executable "harness docs validator" "scripts/validate-harness-docs.sh" "scripts/validate-repo.sh"
check_glob "doc link check" "scripts/check-doc-links.*"
check_glob "AGENTS drift check" "scripts/check-agents-drift.*"
check_glob "behaviour docs check" "scripts/check-behaviour-docs.*"
check_glob "generated docs check" "scripts/check-generated-docs.*"
check_glob "workspace docs generator" "scripts/generate-workspace-docs.*"
check_glob "quality score generator" "scripts/refresh-quality-score.*"
echo

echo "-- Conditional surfaces --"
if $HAS_SMOKE; then
  check_any_executable "smoke/e2e runner" "scripts/e2e.sh" "scripts/e2e-agent.sh" "scripts/ui-smoke.sh" "scripts/smoke.sh"
else
  check_optional_file "scripts/e2e.sh" "smoke/e2e runner"
fi

if $HAS_LOCAL_HARNESS; then
  check_executable "scripts/harness/run-local.sh" "local dependency harness"
else
  check_optional_file "scripts/harness/run-local.sh" "local dependency harness"
fi

if $HAS_REVIEW_SKILLS; then
  check_file ".agents/skills/review/SKILL.md" "repo-local review skill"
  check_file ".agents/skills/security-review/SKILL.md" "repo-local security review skill"
else
  check_optional_file ".agents/skills/review/SKILL.md" "repo-local review skill"
  check_optional_file ".agents/skills/security-review/SKILL.md" "repo-local security review skill"
fi
echo

if $GITHUB_ACTIONS; then
  echo "-- GitHub workflows --"
  check_optional_file ".github/pull_request_template.md" "PR template"
  check_any_file "harness workflow" ".github/workflows/harness.yml" ".github/workflows/pr-fast.yml"
  check_optional_file ".github/workflows/weekly-doc-gardening.yml" "scheduled generated-doc refresh"
  check_optional_file ".github/workflows/automerge.yml" "automerge policy workflow"
  echo
fi

echo "----------------------------------------"
echo "Passed: $PASS    Failed: $FAIL    Optional missing: $WARN"
echo "----------------------------------------"

if [[ "$FAIL" -gt 0 ]]; then
  echo "Agent harness setup is incomplete."
  exit 1
fi

echo "Agent harness setup is complete."
