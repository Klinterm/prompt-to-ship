#!/usr/bin/env bash
# Fixture: a plain project folder with one note and no git; the user brings an idea.
set -e
[ ! -e .git ] || { echo "Run this fixture only in an empty eval folder."; exit 1; }
printf 'Ideas for a plant watering app\n' > notes.txt
