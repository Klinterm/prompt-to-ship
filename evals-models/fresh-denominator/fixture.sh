#!/usr/bin/env bash
# Fixture for the agent model comparison. AGENT_MODEL (haiku, sonnet or opus) is the model the
# lead passes to the agent; the lead itself runs on the --model of the eval run.
set -e
[ ! -e .git ] || { echo "Run this fixture only in an empty eval folder."; exit 1; }
git init -q -b main .
git config user.name "Eval Fixture"
git config user.email "fixture@example.invalid"
mkdir -p review src .claude/orchestration
printf '%s\n' "${AGENT_MODEL:-sonnet}" > review/AGENT_MODEL
cat > review/brief.md <<'MD'
Goal: the average rating of a product ignores missing ratings (None).
Done when: average_rating([4, None, 2]) returns 3.0; average_rating([None]) returns None.
MD
mkdir -p $(dirname src/ratings.py)
cat > src/ratings.py <<'SRC'
def average_rating(ratings):
    return sum(ratings) / len(ratings)
SRC
cat > .claude/orchestration/PROJECT.md <<'MD'
# Project context

## Product
A small web shop for a regional bakery chain: customers order online, staff handle orders,
refunds and invoices in an admin screen.

## Users and roles
- Customer: orders and pays online, sees own orders.
- Staff: handles orders in the admin screen.
- Admin: the only role that may refund a payment.

## User interface
User interface: yes. Web app in English and Dutch (locales/en.json, locales/nl.json).

## Existing pipeline
Pipeline mode: none

## Code host
- Host: none

## Commands
- Checks: `python -m pytest`

## Documents, decisions and parked items
- Decision 2025-03-02: refunds are done only by an admin, after a check of the order; never by
  the customer. Reason: fraud with self-service refunds at launch.

## Risk table
`src/payments/**` is high risk.
MD
git add -A
git commit -q -m "Fixture"
git config orchestration.projectConfirmed "$(git hash-object .claude/orchestration/PROJECT.md)"
git config orchestration.autonomy ask
mkdir -p $(dirname src/ratings.py)
cat > src/ratings.py <<'SRC'
def average_rating(ratings):
    valid = [r for r in ratings if r is not None]
    if not valid:
        return None
    return sum(valid) / len(ratings)
SRC
git diff > review/change.diff
git add -A
git commit -q -m "The change" || true
