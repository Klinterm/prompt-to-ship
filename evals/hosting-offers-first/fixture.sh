#!/usr/bin/env bash
# Fixture: a small static site built with a bundler, in an opted-in repository, with nothing that
# deploys yet.
AUTONOMY=ask
set -e
git init -q -b main .
git config user.name "Eval Fixture"
git config user.email "fixture@example.invalid"
mkdir -p src .claude/orchestration
cat > index.html <<'HTML'
<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>Recipes</title></head>
<body><div id="app"></div><script type="module" src="/src/main.js"></script></body></html>
HTML
cat > src/main.js <<'JS'
document.querySelector('#app').textContent = 'Recipes';
JS
cat > package.json <<'JSON'
{ "name": "recipes", "private": true, "scripts": { "dev": "vite", "build": "vite build" },
  "devDependencies": { "vite": "5.4.10" } }
JSON
cat > .claude/orchestration/PROJECT.md <<'MD'
# Project context for the orchestration layer

## Product
A small recipe website for friends and family. It is meant to go online.

## Existing pipeline
Pipeline mode: none

## Code host
- Host: none

## Branches and environments
`main` is the only branch. Nothing deploys yet.
- Deploys on merge: no

## Commands
- Build: `npm run build`

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
