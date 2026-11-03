#!/usr/bin/env bash
# Offline structure checks for the skill. Read-only. Run: bash tests/structure-test.sh [root]
# a. Every reference in the form `<file>.md, "<Section>"` to a file in references/ names an existing
#    heading, compared as plain text. Other citation forms are not checked.
# b. The SKILL.md "Read when" table and the files in references/ match.
# c. Every agent has name, description, tools and model; all but the researcher read only.
# d. The case count in PROJECT.md matches evals/*/case.yaml.
# e. Every skill in skills/ has name and description, is at most 8,000 bytes, and its Read-when
#    table and its references/ and templates/ files match. plugin.json lists "skills": ["."];
#    no SKILL.md outside the root and skills/*/.
# Without a root argument it first proves itself: a planted broken reference in a temp copy
# must make it fail.
root="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
fail=0
err() { echo "FAIL: $*"; fail=1; }

if [ -z "$1" ]; then
  tmp=$(mktemp -d) && [ -d "$tmp" ] || { echo "FAIL: no temp folder"; exit 1; }
  trap 'rm -rf "$tmp"' EXIT
  cp -rL "$root/SKILL.md" "$root/references" "$root/agents" "$tmp/"
  [ -d "$root/skills" ] && cp -rL "$root/skills" "$tmp/"
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
  for s in "$tmp"/skills/*/SKILL.md; do
    [ -f "$s" ] || continue
    printf '| `references/planted-missing.md` | never |\n' >> "$s"
    if ! bash "$0" "$tmp" 2>&1 | grep -Fq "${s#$tmp/} names references/planted-missing.md"; then
      err "self-check: a planted broken row in ${s#$tmp/} was not caught"
    fi
  done
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

# e. Skills in skills/.
for s in "$root"/skills/*/SKILL.md; do
  [ -f "$s" ] || continue
  dir=$(dirname "$s")
  for key in name description; do
    sed -n '2,/^---$/p' "$s" | grep -q "^$key:" || err "${s#$root/} has no $key"
  done
  size=$(wc -c < "$s" | tr -d ' ')
  [ "$size" -le 8000 ] || err "${s#$root/} is $size bytes, more than 8,000"
  named=$(grep -oE '^\| `[a-zA-Z/._-]+\.md` \|' "$s" | sed -E 's/^\| `([^`]+)` \|$/\1/' | sort)
  for ref in $named; do
    [ -f "$dir/$ref" ] || err "${s#$root/} names $ref, which does not exist"
  done
  for f in $(cd "$dir" && ls references/*.md templates/*.md 2>/dev/null); do
    echo "$named" | grep -Fxq "$f" || err "${s#$root/} has no Read-when row for $f"
  done
done

if [ -d "$root/skills" ] && [ -f "$root/.claude-plugin/plugin.json" ]; then
  tr -d ' \t\r\n' < "$root/.claude-plugin/plugin.json" | grep -q '"skills":\["\."\]' \
    || err 'plugin.json has no "skills": ["."], so the root SKILL.md would not load next to skills/'
fi
stray=$(cd "$root" && find . -name SKILL.md -not -path './SKILL.md' -not -path './skills/*/SKILL.md' \
  -not -path './.git/*' -not -path './node_modules/*' -not -path '*/results/*' 2>/dev/null)
[ -z "$stray" ] || err "SKILL.md outside the root and skills/*/ would load as a skill: $stray"

[ "$fail" = 0 ] && echo "structure-test: all checks pass"
exit "$fail"
