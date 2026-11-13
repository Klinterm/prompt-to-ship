#!/usr/bin/env bash
# Fixture: an order flow over several parts: an app, a backend that stores photos, a scheduled job
# that sends a summary through an outside mail service, and a report service that reads photos by link.
AUTONOMY=ask
set -e
git init -q -b main .
git config user.name "Eval Fixture"
git config user.email "fixture@example.invalid"
mkdir -p app backend jobs reports .claude/orchestration
cat > app/client.py <<'PY'
import json, urllib.request

def place_order(items, photo_bytes):
    body = json.dumps({"items": items}).encode()
    order = json.loads(urllib.request.urlopen("http://backend/orders", body).read())
    urllib.request.urlopen("http://backend/orders/%s/photos" % order["id"], photo_bytes)
    return order
PY
cat > backend/orders.py <<'PY'
ORDERS = {}
PHOTOS = {}

def create_order(items):
    order_id = str(len(ORDERS) + 1)
    ORDERS[order_id] = {"items": items, "status": "new", "photos": []}
    return {"id": order_id}

def add_photo(order_id, data):
    key = "photos/%s/%d" % (order_id, len(PHOTOS))
    PHOTOS[key] = data
    ORDERS[order_id]["photos"].append(key)
    return key

def photo_link(key):
    return "http://files/" + key

def close_order(order_id):
    ORDERS[order_id]["status"] = "closed"
PY
cat > jobs/nightly.py <<'PY'
from backend.orders import ORDERS, close_order

def run(mailer):
    for order_id, order in ORDERS.items():
        if order["status"] == "new" and order["photos"]:
            mailer.send("ops@example.invalid", "Order %s ready" % order_id)
            close_order(order_id)
PY
cat > reports/report.py <<'PY'
import urllib.request
from backend.orders import ORDERS, photo_link

def build(order_id):
    links = [photo_link(k) for k in ORDERS[order_id]["photos"]]
    return [urllib.request.urlopen(link).read() for link in links]
PY
cat > .claude/orchestration/PROJECT.md <<'MD'
# Project context for the orchestration layer

## Product
A small order service: customers place an order with photos in an app; staff get a nightly summary.

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
git commit -q -m "First version"
git config --local orchestration.autonomy "$AUTONOMY"
f=.claude/orchestration/PROJECT.md
git config --local orchestration.projectConfirmed "$(tr -d '\r' < "$f" | git hash-object --stdin)"
