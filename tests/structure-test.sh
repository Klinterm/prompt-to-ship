#!/usr/bin/env bash
# Offline structure checks for the skill. Read-only. Run: bash tests/structure-test.sh [root]
# a. Every reference in the form `<file>.md, "<Section>"` to a file in references/ names an existing
#    heading, compared as plain text. Other citation forms are not checked.
# b. The SKILL.md "Read when" table and the files in references/ match.
# c. Every agent has name, description, tools and model; all but the researcher read only.
# d. The case count in PROJECT.md matches evals/*/case.yaml.
# Without a root argument it first proves itself: a planted broken reference in a temp copy
# must make it fail.
root="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
fail=0
err() { echo "FAIL: $*"; fail=1; }

if [ -z "$1" ]; then
  tmp=$(mktemp -d) && [ -d "$tmp" ] || { echo "FAIL: no temp folder"; exit 1; }
  trap 'rm -rf "$tmp"' EXIT
  cp -rL "$root/SKILL.md" "$root/references" "$root/agents" "$tmp/"
  mkdir -p "$tmp/evals" "$tmp/.claude/orchestration"
  cp "$root/.claude/orchestration/PROJECT.md" "$tmp/.claude/orchestration/"
  for c in "$root"/evals/*/case.yaml; do
    mkdir -p "$tmp/evals/$(basename "$(dirname "$c")")"
  done
  for c in "$root"/evals/*/case.yaml; do
    cp "$c" "$tmp/evals/$(basename "$(dirname "$c")")/"
  done
  printf '\nSee pipeline.md, "No such section".\n' >> "$tmp/references/gates.md"
  if ! bash "$0" "$tmp" 2>&1 | grep -q 'No such section'; then
    err "self-check: a planted broken reference was not caught"
  fi
fi

# a. References to sections.
refs=$(cat "$root/SKILL.md" "$root"/references/*.md "$root"/agents/*.md \
  | grep -oE '([A-Za-z0-9-]+)\.md, "[^"]+"' | sort -u)
while IFS= read -r ref; do
  [ -n "$ref" ] || continue
  file="${ref%%.md,*}.md"
  section="${ref#*\"}"
  section="${section%\"}"
  [ -f "$root/references/$file" ] || continue
  grep -E '^#{1,6} ' "$root/references/$file" | sed -E 's/^#{1,6} //' | grep -Fxq -- "$section" \
    || err "$file has no heading \"$section\" (cited as: $ref)"
done <<< "$refs"

# b. The Read-when table and references/.
table=$(grep -oE '^\| [a-z-]+\.md \|' "$root/SKILL.md" | sed -E 's/^\| ([a-z-]+\.md) \|$/\1/' | sort)
files=$(cd "$root/references" && ls *.md | sort)
[ "$table" = "$files" ] || err "SKILL.md Read-when table and references/ differ: $(diff <(echo "$table") <(echo "$files") | grep '^[<>]' | tr '\n' ' ')"

# c. Agent frontmatter.
for a in "$root"/agents/*.md; do
  name=$(basename "$a" .md)
  head=$(sed -n '1,/^---$/{p}' "$a" | sed -n '2,/^---$/p')
  for key in name description tools model; do
    printf '%s\n' "$head" | grep -q "^$key: " || err "agents/$name.md has no $key"
  done
  tools=$(printf '%s\n' "$head" | sed -n 's/^tools: //p')
  if [ "$name" != "researcher" ] && [ "$tools" != "Read, Grep, Glob" ]; then
    err "agents/$name.md tools are \"$tools\", expected \"Read, Grep, Glob\""
  fi
done

# d. The case count.
said=$(grep -oE '\(([0-9]+) cases;' "$root/.claude/orchestration/PROJECT.md" | head -n 1 | grep -oE '[0-9]+')
real=$(ls "$root"/evals/*/case.yaml 2>/dev/null | wc -l | tr -d ' ')
[ "$said" = "$real" ] || err "PROJECT.md says ${said:-no} cases, evals/ has $real"

[ "$fail" = 0 ] && echo "structure-test: all checks pass"
exit "$fail"
