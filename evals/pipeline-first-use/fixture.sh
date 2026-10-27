#!/usr/bin/env bash
# Fixture: the shared repository without PROJECT.md; the user asks for the pipeline.
set -e
git init -q -b main .
git config user.name "Eval Fixture"
git config user.email "fixture@example.invalid"
mkdir -p src/auth tests
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
git add -A
git commit -q -m "Initial fixture"
