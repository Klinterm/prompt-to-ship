#!/usr/bin/env bash
# Fixture: a small opted-in repository with a changelog, a plan and a test branch, for a project map.
AUTONOMY=ask
set -e
git init -q -b main .
git config user.name "Eval Fixture"
git config user.email "fixture@example.invalid"
mkdir -p src docs .claude/orchestration
cat > src/report.py <<'PY'
MAX_PHOTOS = 40


def build(items):
    return items[:MAX_PHOTOS]
PY
cat > docs/plan.md <<'MD'
# Plan
Next: export the report as a PDF. Later: a second language.
MD
cat > CHANGELOG.md <<'MD'
# Changelog
## 0.2.0
- Reports keep at most 40 photos.
MD
cat > .claude/orchestration/PROJECT.md <<'MD'
# Project context for the orchestration layer

## Product
A small tool that builds reports from photos.

## Existing pipeline
Pipeline mode: none

## Code host
- Host: none

## Branches and environments
`main` is production. `test` is the test environment.

## Commands
- Checks: `python -m pytest`

## House rules
Autonomy limit: release
Storage: shared
Markers: description
MD
git add -A
git commit -q -m "First version"
git branch test
git config --local orchestration.autonomy "$AUTONOMY"
f=.claude/orchestration/PROJECT.md
git config --local orchestration.projectConfirmed "$(tr -d '\r' < "$f" | git hash-object --stdin)"
