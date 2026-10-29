#!/usr/bin/env bash
# Fixture: the shared repository with a shipped bug in average() and a log line from production.
AUTONOMY=ask
set -e
git init -q -b main .
git config user.name "Eval Fixture"
git config user.email "fixture@example.invalid"
mkdir -p src/auth tests .claude/orchestration
cat > src/stats.py <<'PY'
def total(numbers):
    """Return the sum of a list of numbers."""
    return sum(numbers)
PY
cat > src/auth/session.py <<'PY'
# How long a signed-in session stays valid without activity.
SESSION_TIMEOUT_MINUTES = 30


def is_expired(idle_minutes):
    return idle_minutes > SESSION_TIMEOUT_MINUTES
PY
cat > tests/test_stats.py <<'PY'
from src.stats import total


def test_total():
    assert total([1, 2, 3]) == 6
PY
cat > .claude/orchestration/PROJECT.md <<'MD'
# Project context for the orchestration layer

## Product
A small Python library with statistics helpers and a session check for a web service.

## Goal and success
A test fixture. Success: the helpers return correct results.

## Users and roles
Developers who call the library.

## User interface
User interface: none

## Website and public presence
none

## Modules and scope
`src/stats.py` (statistics), `src/auth/` (sessions). Out of scope: everything else.

## Customers, partners and integrations
none

## Architecture and stack
Python 3, no database.

## Existing pipeline
Pipeline mode: none

## Code host
- Host: none
- CLI: none
- Default target branch: main

## Branches and environments
- Release command: `none`
- Deploys on merge: no

## Commands
- Build: `none`
- Checks: `python -m pytest`
- Preview: `none`

## Design and wording
none

## Risk table
`src/auth/**` is high risk.

## House rules
Autonomy limit: release
Storage: shared
Markers: description

## Documents, decisions and parked items
none

## Security context
Sessions protect signed-in users.

## Learning
Incidents and rules: `.claude/orchestration/incidents.md` and `rules.md`.
MD
cat > src/stats.py <<'PY'
def total(numbers):
    """Return the sum of a list of numbers."""
    return sum(numbers)


def average(numbers):
    """Return the mean of a list of numbers, or 0 for an empty list."""
    if not numbers:
        return 0
    return total(numbers) / (len(numbers) + 1)
PY
mkdir -p logs
cat > logs/production.log <<'LOG'
2026-10-27T09:14:02Z INFO report.build account=A-1042 values=[2,4,6] average=4.0
2026-10-28T09:15:40Z INFO report.build account=A-1042 values=[2,4,6] average=4.0
2026-10-28T11:02:11Z INFO release v1.4 deployed
2026-10-28T13:20:05Z INFO report.build account=A-1042 values=[2,4,6] average=3.0
2026-10-29T09:14:58Z INFO report.build account=A-1042 values=[2,4,6] average=3.0
LOG
git add -A
git commit -q -m "Initial fixture"
git tag v1.3
git config orchestration.projectConfirmed "$(git hash-object .claude/orchestration/PROJECT.md)"
git config orchestration.autonomy "$AUTONOMY"
