#!/usr/bin/env bash
# Fixture: an order flow with three flags and no list of its states. A cancelled order can still
# ship, a shipped order can still be cancelled, and a second file ships without the payment check.
AUTONOMY=ask
set -e
git init -q -b main .
git config user.name "Eval Fixture"
git config user.email "fixture@example.invalid"
mkdir -p src .claude/orchestration
cat > src/orders.py <<'PY'
class Order:
    def __init__(self):
        self.paid = False
        self.shipped = False
        self.cancelled = False
        self.refund_pending = False


def pay(order):
    order.paid = True


def ship(order):
    if order.paid:
        order.shipped = True


def cancel(order):
    order.cancelled = True
    if order.paid:
        order.refund_pending = True


def label(order):
    return "order" if order else "none"
PY
cat > src/warehouse.py <<'PY'
def mark_sent(order):
    order.shipped = True
PY
cat > .claude/orchestration/PROJECT.md <<'MD'
# Project context for the orchestration layer

## Product
A small library that keeps the orders of a shop.

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
