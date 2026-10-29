#!/usr/bin/env bash
# Agent model comparison for one agent model. The lead always runs on sonnet; only the model of
# the agent call changes. Usage: evals-models/run.sh haiku|sonnet|opus [more eval flags]
# The eval tool does not pass environment variables to a fixture, so this script writes the
# model into a copy of the cases and removes the copy afterwards. Works with GNU and BSD tools.
set -e
model="$1"
case "$model" in haiku|sonnet|opus) ;; *) echo "usage: evals-models/run.sh haiku|sonnet|opus [flags]"; exit 2 ;; esac
shift
root="$(cd "$(dirname "$0")/.." && pwd)"
copy="evals-models-$model"
cd "$root"
rm -rf "$copy"
mkdir "$copy"
for d in evals-models/*/; do
  [ -f "$d/case.yaml" ] || continue
  cp -r "${d%/}" "$copy/"
done
for f in "$copy"/*/fixture.sh; do
  sed "s/\${AGENT_MODEL:-sonnet}/$model/" "$f" > "$f.new" && mv "$f.new" "$f"
done
status=0
claude plugin eval . --eval-dir "$copy" --ablation none --model sonnet --no-publish --scaffold \
  --output-dir "evals-models/results/$model" "$@" || status=$?
rm -rf "$copy"
exit $status
