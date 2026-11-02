#!/usr/bin/env bash
# The reminder on every prompt, only in a repository that opted in. Read-only and offline: it
# prints fixed text, and one line from the local version cache (references/update.md). Besides
# grep and cat it starts no program, except date on bash older than 4.2.
f="${CLAUDE_PROJECT_DIR:-.}/.claude/orchestration/PROJECT.md"
[ -f "$f" ] || exit 0
if grep -q '^Pipeline mode: defer[[:space:]]*$' "$f"; then
  cat "${CLAUDE_PLUGIN_ROOT}/hooks/reminder-defer.txt"
else
  cat "${CLAUDE_PLUGIN_ROOT}/hooks/reminder.txt"
fi

# Off switch: prompt-to-ship.versionCheck = false in the user's global git config.
# Works in bash 3.2 (macOS): no ${x,,}; the time format of printf only from bash 4.2.
shopt -s nocasematch
section=""
if [ -f "$HOME/.gitconfig" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%[#;]*}"
    line="${line//[[:space:]]/}"
    line="${line//\"/}"
    case "$line" in
      \[*) section="$line" ;;
      versioncheck=false|versioncheck=no|versioncheck=off|versioncheck=0)
        [[ "$section" == "[prompt-to-ship]" ]] && exit 0 ;;
    esac
  done < "$HOME/.gitconfig"
fi

mine=""
while IFS= read -r line || [ -n "$line" ]; do
  if [[ "$line" =~ \"version\"[[:space:]]*:[[:space:]]*\"([0-9]{1,4})\.([0-9]{1,4})\.([0-9]{1,4})\" ]]; then
    mine="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}"
    break
  fi
done < "${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json"

day="" seen=""
cache="$HOME/.claude/prompt-to-ship/version-check"
if [ -f "$cache" ]; then
  { IFS= read -r day; IFS= read -r seen; } < "$cache"
fi
day="${day%$'\r'}"
seen="${seen%$'\r'}"
# Only a real date and a plain version pass; anything else in the file counts as no check.
[[ "$day" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || day=""
[[ "$seen" =~ ^([0-9]{1,4})\.([0-9]{1,4})\.([0-9]{1,4})$ ]] || { seen=""; day=""; }
if (( BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 2) )); then
  printf -v today '%(%Y-%m-%d)T' -1
else
  today=$(date +%Y-%m-%d)
fi

num() { # a version as one number in $n, for a numeric compare, without a subshell
  local a b c
  IFS=. read -r a b c <<< "$1"
  n=$(( 10#$a * 100000000 + 10#$b * 10000 + 10#$c ))
}

if [ "$day" != "$today" ]; then
  echo "VERSION: the daily version check is due (references/update.md, \"Version check\")."
elif [ -n "$seen" ] && [ -n "$mine" ] && num "$seen" && s=$n && num "$mine" && (( s > n )); then
  echo "VERSION: prompt-to-ship $seen is out (installed: $mine). Before the BRIEF, show the offer line from references/update.md."
fi
exit 0
