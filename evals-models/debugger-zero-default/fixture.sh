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
Symptom: some invoices show a total of 0.00 euro.
Expected: the sum of the line prices.
Scope: about 1 in 50 invoices, since the new product catalogue import on Monday.
Environment: production
MD
cat > review/app.log <<'LOG'
2024-11-04T10:12:03Z price lookup: no price for SKU BR-1042
2024-11-04T10:12:03Z invoice 88121 total 0.00
2024-11-04T10:15:44Z price lookup: no price for SKU CK-2210
2024-11-04T10:15:44Z invoice 88130 total 0.00
LOG
cat > src/invoices.py <<'SRC'
def line_price(prices, sku, qty):
    return prices.get(sku, 0) * qty

def invoice_total(prices, lines):
    return round(sum(line_price(prices, l.sku, l.qty) for l in lines), 2)
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
