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
# f. The plugin.json description is at most 500 characters, the upload limit on claude.ai.
# g. No rule hashes a file by path with git hash-object: that form runs a filter from the folder's
#    own git config. One line at a time, so a command split over two lines is still seen.
# h. Without a root argument: the command in gates.md, "File hash", runs against a hostile folder.
#    It starts no program, prints nothing for a missing file or a carriage return inside a line,
#    and matches the filtered hash. gates.md names the empty hash that a failed read gives.
# i. Without a root argument: the check in h changes no other repository, with inherited GIT_*
#    variables and with a failed git init inside a repository. This covers the git calls of this
#    test only, not the gates.md command in real use.
# Without a root argument it first proves itself: a planted broken reference, a planted broken
# Read-when row, a planted 501-character description and a planted hash by path in a temp copy
# must make it fail.
root="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
fail=0
err() { echo "FAIL: $*"; fail=1; }

# Call only in a subshell. A git hook sets GIT_DIR, and that variable sends git config to the real repository.
isolate_git() {
  unset GIT_TEMPLATE_DIR $(git rev-parse --local-env-vars)
  export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
}

new_repo() {
  ( isolate_git; git init -q "$1" ) >/dev/null 2>&1
  [ -f "$1/.git/config" ] || err "git init made no repository at $1"
}

repo_state() { cat "$1/.git/config"; ls -A "$1/.git"; }

# The check of section h. It prints a line for each problem, and nothing when all is well.
hash_check() {
  (
    h="$1"
    mkdir -p "$h"
    cd "$h" || exit 1
    isolate_git
    git init -q . || { echo "git init failed. The check stopped before it wrote any config."; exit 1; }
    [ "$(git rev-parse --git-dir)" = .git ] \
      || { echo "git uses another repository. The check stopped before it wrote any config."; exit 1; }
    printf 'one\ntwo\n' > lf.md
    printf 'one\r\ntwo\r\n' > crlf.md
    echo '*.md filter=probe' > .gitattributes
    git config filter.probe.clean "sh -c 'echo x > \"$h/filter.mark\"; cat'"
    git config core.fsmonitor "sh -c 'echo x > \"$h/monitor.mark\"; exit 1'"
    git hash-object lf.md >/dev/null 2>&1
    [ -e filter.mark ] || echo "the hostile filter did not run, so this check proves nothing"
    git status --short >/dev/null 2>&1
    [ -e monitor.mark ] || echo "the hostile core.fsmonitor did not run, so this check proves nothing"
    rm -f filter.mark monitor.mark
    f=lf.md bash -c "$cmd" >/dev/null 2>&1
    [ -e filter.mark ] && echo "the file hash started the filter"
    [ -e monitor.mark ] && echo "the file hash started core.fsmonitor"
    out=$(f=missing.md bash -c "$cmd" 2>/dev/null)
    [ -z "$out" ] || echo "a missing file gave a hash: $out"
    printf 'a\rb\n' > lone.md
    out=$(f=lone.md bash -c "$cmd" 2>/dev/null)
    [ -z "$out" ] || echo "a carriage return inside a line gave a hash: $out"
    rm -f lone.md
    rm -f .gitattributes
    git config --unset filter.probe.clean
    git config --unset core.fsmonitor
    git config core.autocrlf true
    for n in lf.md crlf.md; do
      a=$(git hash-object "$n" 2>/dev/null)
      b=$(f="$n" bash -c "$cmd" 2>/dev/null)
      [ "$a" = "$b" ] || echo "$n: file hash $b differs from filtered hash $a"
    done
  )
}

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
  mkdir -p "$tmp/.claude-plugin"
  long=$(printf 'a%.0s' $(seq 1 501))
  sed "s/^\( *\"description\": *\"\)[^\"]*\"/\1$long\"/" "$root/.claude-plugin/plugin.json" \
    > "$tmp/.claude-plugin/plugin.json"
  if ! bash "$0" "$tmp" 2>&1 | grep -Fq "plugin.json description is 501 characters"; then
    err "self-check: a planted 501-character description was not caught"
  fi
  printf 'Store `git hash-object planted.md`.\n' >> "$tmp/references/debug.md"
  printf 'Use `git hash-object --stdin-paths`.\n' >> "$tmp/references/learning.md"
  printf 'Use `git hash-object --stdin --path=x`.\n' >> "$tmp/references/setup.md"
  planted=$(bash "$0" "$tmp" 2>&1)
  for p in debug learning setup; do
    printf '%s\n' "$planted" | grep -Fq "hashes by path: references/$p.md" \
      || err "self-check: a planted hash by path in $p.md was not caught"
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

# f. The plugin.json description length. The sed reads a one-line description without escaped
# quotes, as plugin.json has it; any other form gives an empty match and fails.
pj="$root/.claude-plugin/plugin.json"
if [ -f "$pj" ]; then
  d=$(sed -n 's/^ *"description": *"\([^"]*\)",*[[:space:]]*$/\1/p' "$pj" | head -n 1)
  n=$(printf '%s' "$d" | LC_ALL=C.UTF-8 wc -m | tr -d ' ')
  if [ -z "$d" ]; then
    err "plugin.json has no one-line description"
  elif [ "$n" -gt 500 ]; then
    err "plugin.json description is $n characters, more than 500"
  fi
fi

# g. Hash by path.
for f in "$root/SKILL.md" "$root"/references/*.md "$root"/skills/*/references/*.md; do
  [ -f "$f" ] || continue
  while IFS= read -r hit; do
    [ -n "$hit" ] && err "hashes by path: ${f#$root/}:$hit"
  done <<< "$(sed -E 's/hash-object --stdin([^-[:alnum:]]|$)/STDIN-HASH\1/g' "$f" \
    | grep -nE 'git( -C [^ ]+)? +hash-object|STDIN-HASH[^`]*--path')"
done

# h. The file hash against a hostile folder. Run only on the real root: it needs git and a temp folder.
if [ -z "$1" ]; then
  cmd=$(grep -F '[ -f "$f" ] && ' "$root/references/gates.md" | head -n 1)
  grep -Fq 'e69de29bb2d1d6434b8b29ae775ad8c2e48c5391' "$root/references/gates.md" \
    || err 'gates.md, "File hash", does not name the empty hash'
  if [ -z "$cmd" ]; then
    err 'gates.md, "File hash", has no hash command'
  else
    hash_check "$tmp/hostile" > "$tmp/hostile.out" 2>&1
    while IFS= read -r line; do
      [ -n "$line" ] && err "file hash: $line"
    done < "$tmp/hostile.out"

    # i. Inherited GIT_* variables. Each path is absolute, because the check changes folder. Export
    # them, as a git hook does: with VAR=x before a function name, unset brings back the older value.
    t="$tmp/target"
    new_repo "$t"
    before=$(repo_state "$t")
    (
      export GIT_DIR="$t/.git" GIT_WORK_TREE="$t" GIT_INDEX_FILE="$t/.git/planted-index"
      export GIT_CONFIG_PARAMETERS="'core.autocrlf=false'" GIT_CONFIG_COUNT=1
      export GIT_CONFIG_KEY_0=core.autocrlf GIT_CONFIG_VALUE_0=false
      hash_check "$tmp/env-check"
    ) > "$tmp/env.out" 2>&1
    while IFS= read -r line; do
      [ -n "$line" ] && err "git environment: the check printed: $line"
    done < "$tmp/env.out"
    [ "$before" = "$(repo_state "$t")" ] || err "git environment: the target repository changed"

    # i. A failed git init inside a repository. A plain file named refs makes git init fail and
    # leaves no valid .git, so git would use the outer repository.
    o="$tmp/outer"
    new_repo "$o"
    mkdir -p "$o/inner/.git"
    : > "$o/inner/.git/refs"
    before=$(repo_state "$o")
    hash_check "$o/inner" > "$tmp/init.out" 2>&1
    grep -Fq 'git init failed.' "$tmp/init.out" \
      || err "failed git init: git init did not fail. This check proves nothing."
    [ "$before" = "$(repo_state "$o")" ] || err "failed git init: the outer repository changed"
  fi
fi

[ "$fail" = 0 ] && echo "structure-test: all checks pass"
exit "$fail"
