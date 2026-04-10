# scripts Index

## Purpose

This directory contains executable helper scripts that ship with the
`setup-harness` skill and can be copied directly into a target repository.

## File conventions

- Shell scripts should be executable, use `#!/usr/bin/env bash`, and include
  `set -euo pipefail`.
- Bundled scripts should stay generic enough to reuse across repos, with
  project-specific logic handled by templates or local adaptation.
- Scripts here should validate or support the bootstrap itself rather than
  becoming a general utility dump.

## Files

- [validate-setup.sh](validate-setup.sh) - Verifies that a scaffolded repo includes the expected bootstrap assets.

## Subdirectories

- No tracked subdirectories.
