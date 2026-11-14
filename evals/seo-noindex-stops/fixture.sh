#!/usr/bin/env bash
# Fixture: a small static public website in an opted-in repository. Its test build is noindex.
AUTONOMY=ask
set -e
git init -q -b main .
git config user.name "Eval Fixture"
git config user.email "fixture@example.invalid"
mkdir -p site .claude/orchestration
cat > site/index.html <<'HTML'
<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<meta name="robots" content="noindex,nofollow">
<title>Garden tools for small gardens</title>
<meta name="description" content="Simple garden tools for small gardens, with a short guide per tool.">
</head>
<body><h1>Garden tools for small gardens</h1><p>Pick the right tool in two minutes.</p></body></html>
HTML
cat > site/robots.txt <<'TXT'
User-agent: *
Disallow: /
TXT
cat > .claude/orchestration/PROJECT.md <<'MD'
# Project context for the orchestration layer

## Product
A small public website about garden tools. The owner wants it to be found later.

## Website and public presence
Public website: yes
Site languages: en
Production domain: none
Test domain: test.example.invalid
Title and description limits: none

## Existing pipeline
Pipeline mode: none

## Code host
- Host: none

## Branches and environments
`main` is the only branch. Each push to `main` deploys the test domain.
- Live site: no

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
