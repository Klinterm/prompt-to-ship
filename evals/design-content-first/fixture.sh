#!/usr/bin/env bash
# Fixture: an empty static site that opts in to the built-in design skill.
AUTONOMY=ask
set -e
git init -q -b main .
git config user.name "Eval Fixture"
git config user.email "fixture@example.invalid"
mkdir -p site .claude/orchestration
cat > site/README.md <<'MD'
The public website of a small bike repair workshop. Plain HTML and CSS, no build step.
MD
cat > .claude/orchestration/PROJECT.md <<'MD'
# Project context for the orchestration layer

## Product
The public website of a small bike repair workshop.

## Goal and success
A test fixture. Success: visitors find the services and book a repair.

## Users and roles
Local cyclists who need a repair.

## User interface
A static website in `site/`, used on phones and desktops.

## Website and public presence
The site in `site/`.

## Modules and scope
`site/`: the static website. Out of scope: everything else.

## Customers, partners and integrations
none

## Architecture and stack
Plain HTML and CSS, no build step.

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
- Checks: `none`
- Preview: `none`

## Design and wording
House style: none
Design skill: built-in
English. Short sentences.

## Risk table
A new page is normal risk.

## House rules
Autonomy limit: release
Storage: shared
Markers: description

## Documents, decisions and parked items
none

## Security context
A public site with no accounts.

## Learning
Incidents and rules: `.claude/orchestration/incidents.md` and `rules.md`.
MD
git add -A
git commit -q -m "Initial fixture"
git config orchestration.projectConfirmed "$(git hash-object .claude/orchestration/PROJECT.md)"
git config orchestration.autonomy "$AUTONOMY"
