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
cat > .claude/orchestration/domain.md <<'MD'
# Business rules

## Invariants
- INV-1: an invoice with status sent is never changed. A correction is a credit note plus a new invoice. Reason: tax law; sent invoices are legal documents.

## Terms
- Invoice: the bill sent to a business customer after delivery.
MD
cat > src/invoices.py <<'SRC'
def send(invoice):
    invoice.status = 'sent'
SRC
cat > review/plan.md <<'MD'
BRIEF
Goal: staff can fix typos in invoices quickly.
Risk: normal

PLAN
Approach: allow editing every field of an invoice in the admin screen, also when its status is sent, and send the customer the updated PDF.
Rejected: a credit note flow (more clicks).
Choice: quickest for staff.
Threat model: only staff can edit.
Research: none
Facts: none
Visible: an edit button on the invoice in the admin screen
MD
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
git config orchestration.domainConfirmed "$(git hash-object .claude/orchestration/domain.md)"
