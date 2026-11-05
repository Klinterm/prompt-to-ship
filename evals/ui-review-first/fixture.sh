#!/usr/bin/env bash
# Fixture: a small page with planted problems that map to named rules: grey body text at a contrast
# of about 2.8 (F1), a 16 px menu link (F7), and two filled primary buttons in one view (H2).
AUTONOMY=ask
set -e
git init -q -b main .
git config user.name "Eval Fixture"
git config user.email "fixture@example.invalid"
mkdir -p site .claude/orchestration
cat > site/style.css <<'CSS'
:root { --ink: #999999; --surface: #ffffff; --accent: #1a5fb4; }
body { color: var(--ink); background: var(--surface); font: 16px/1.5 sans-serif; }
.menu-link { display: inline-block; width: 16px; height: 16px; }
.button-primary { background: var(--accent); color: #ffffff; padding: 12px 20px; border: 0; }
CSS
cat > site/index.html <<'HTML'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Tool library</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <header><a class="menu-link" href="#menu" aria-label="Menu">=</a></header>
  <main>
    <h1>Borrow a tool from your street</h1>
    <p>See which tools are free and ask to borrow one.</p>
    <button class="button-primary">Find a tool</button>
    <button class="button-primary">Lend a tool</button>
  </main>
</body>
</html>
HTML
cat > .claude/orchestration/PROJECT.md <<'MD'
# Project context for the orchestration layer

## Product
A small website where neighbours lend each other tools.

## Goal and success
Goal: people on one street find a free tool. Success: they ask to borrow one.

## Users and roles
Neighbours, on a phone or a computer.

## User interface
User interface: yes
One page: `site/index.html`.

## Website and public presence
none

## Modules and scope
`site/`. Out of scope: payments.

## Customers, partners and integrations
none

## Architecture and stack
Plain HTML and CSS.

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
House style: `site/style.css`.
Design skill: none

## Risk table
Everything is normal risk.

## House rules
Autonomy limit: release
Storage: shared
Markers: description

## Documents, decisions and parked items
none

## Security context
No accounts and no personal data.

## Learning
Incidents and rules: `.claude/orchestration/incidents.md` and `rules.md`.
MD
git add -A
git commit -q -m "Initial fixture"
git config orchestration.projectConfirmed "$(git hash-object .claude/orchestration/PROJECT.md)"
git config orchestration.autonomy "$AUTONOMY"
