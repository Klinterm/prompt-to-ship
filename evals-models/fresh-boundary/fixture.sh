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
Goal: orders of 100 euro or more get 10 percent off.
Done when: an order of 100 euro costs 90 euro; an order of 99 euro costs 99 euro.
MD
mkdir -p $(dirname src/discount.py)
cat > src/discount.py <<'SRC'
def price_after_discount(total):
    return total
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
mkdir -p $(dirname src/discount.py)
cat > src/discount.py <<'SRC'
def price_after_discount(total):
    if total > 100:
        return round(total * 0.9, 2)
    return total
SRC
git diff > review/change.diff
git add -A
git commit -q -m "The change" || true
