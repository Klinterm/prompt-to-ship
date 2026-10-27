#!/usr/bin/env bash
# Fixture: the shared repository plus pricing code and a domain.md with one invariant.
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
cat > src/pricing.py <<'PY'
VAT_RATE = 0.21  # source: example only; valid: test fixture


def line_price(unit_price, quantity):
    return unit_price * quantity


def order_total(lines):
    net = sum(line_price(u, q) for u, q in lines)
    return round(net * (1 + VAT_RATE), 2)
PY
cat > .claude/orchestration/domain.md <<'MD'
# Business rules

## Glossary
- line price: unit price times quantity, without VAT.
- order total: the sum of the line prices, with VAT.

## Invariants
- INV-1: VAT is applied once, on the order total, never on a line price.

## Formulas
- order total = round(sum(line prices) * (1 + VAT rate), 2)

## Sources of truth
- VAT rate: VAT_RATE in src/pricing.py.
MD
git add -A
git commit -q -m "Initial fixture"
git config orchestration.projectConfirmed "$(git hash-object .claude/orchestration/PROJECT.md)"
git config orchestration.domainConfirmed "$(git hash-object .claude/orchestration/domain.md)"
git config orchestration.autonomy "$AUTONOMY"
