#!/usr/bin/env bash
# Fixture: an opted-in repository with a confirmed PROJECT.md. The sandbox gives no chat tool.
AUTONOMY=ask
set -e
git init -q -b main .
git config user.name "Eval Fixture"
git config user.email "fixture@example.invalid"
mkdir -p src .claude/orchestration
cat > src/stats.py <<'PY'
def total(numbers):
    """Return the sum of a list of numbers."""
    return sum(numbers)
PY
cat > .claude/orchestration/PROJECT.md <<'MD'
# Project context for the orchestration layer

## Product
A small library with statistics helpers.

## Existing pipeline
Pipeline mode: none

## Code host
- Host: none

## Commands
- Checks: `python -m pytest`

## House rules
Autonomy limit: release
Storage: shared
Markers: description
MD
git add -A
git commit -q -m "Initial fixture"
git config orchestration.projectConfirmed "$(git hash-object .claude/orchestration/PROJECT.md)"
git config orchestration.autonomy "$AUTONOMY"
