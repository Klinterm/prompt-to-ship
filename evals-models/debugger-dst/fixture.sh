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
cat > review/case.md <<'MD'
CASE
Symptom: order confirmation reminders reach customers in Brussels one hour early, since Sunday 27 October.
Expected: reminders at 09:00 local time.
Scope: all customers in Belgium.
Environment: production
MD
cat > review/app.log <<'LOG'
2024-10-25T07:00:00Z reminder job start (local 09:00)
2024-10-28T07:00:00Z reminder job start (local 08:00)
2024-10-29T07:00:00Z reminder job start (local 08:00)
LOG
cat > src/scheduler.py <<'SRC'
# Belgium is UTC+2, so 09:00 local is 07:00 UTC.
REMINDER_HOUR_UTC = 7

def next_run(now_utc):
    return now_utc.replace(hour=REMINDER_HOUR_UTC, minute=0, second=0)
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
