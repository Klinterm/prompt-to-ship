#!/usr/bin/env bash
# Fixture: a repository whose written next slice is search, while the CHANGELOG shows only colour
# theme work. The evidence is in files, because the case gives the agent no shell.
AUTONOMY=ask
set -e
git init -q -b main .
git config user.name "Eval Fixture"
git config user.email "fixture@example.invalid"
mkdir -p src tests .claude/orchestration
cat > src/notes.py <<'PY'
def add(notes, text):
    """Add one note and return the list."""
    notes.append(text)
    return notes
PY
cat > tests/test_notes.py <<'PY'
from src.notes import add


def test_add():
    assert add([], "a") == ["a"]
PY
cat > CHANGELOG.md <<'MD'
# Changelog

## 0.5.0
- A third colour theme.

## 0.4.0
- A theme picker, and a second colour theme.

## 0.3.0
- A dark colour theme.

## 0.2.0
- Tags on a note (slice 2).

## 0.1.0
- Add and list notes (slice 1).
MD
cat > .claude/orchestration/PROJECT.md <<'MD'
# Project context for the orchestration layer

## Product
A small command-line tool that keeps personal notes.

## Goal and success
Goal: find any old note within ten seconds. Success: a search returns the right note.
Stage: early version.

## Users and roles
One person who keeps notes.

## User interface
User interface: yes
What the user reads in the terminal.

## Website and public presence
none

## Modules and scope
`src/notes.py`. Out of scope: sync between machines.

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
Everything is normal risk.

## House rules
Autonomy limit: release
Storage: shared
Markers: description

## Documents, decisions and parked items
Slices:
1. Add and list notes (done).
2. Tags on a note (done).
3. Search in notes (next).
4. Export notes.
Parked: sync between machines.

## Security context
Notes are personal text on the user's own computer.

## Learning
Incidents and rules: `.claude/orchestration/incidents.md` and `rules.md`.
MD
git add -A
git commit -q -m "Initial fixture"
git config orchestration.projectConfirmed "$(git hash-object .claude/orchestration/PROJECT.md)"
git config orchestration.autonomy "$AUTONOMY"
