#!/usr/bin/env bash
# Fixture: an empty repository with only a README; the user brings an idea.
set -e
git init -q -b main .
git config user.name "Eval Fixture"
git config user.email "fixture@example.invalid"
printf '# Tool library\n' > README.md
git add -A
git commit -q -m "Initial commit"
