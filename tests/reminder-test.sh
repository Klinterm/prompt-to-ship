#!/usr/bin/env bash
# Checks hooks/reminder.sh with a fake home folder and a fake project. Run: bash tests/reminder-test.sh
root="$(cd "$(dirname "$0")/.." && pwd)"
tmp=$(mktemp -d) && [ -d "$tmp" ] || { echo "FAIL: no temp folder"; exit 1; }
trap 'rm -rf "$tmp"' EXIT
fail=0
n=0
export CLAUDE_PLUGIN_ROOT="$root"
export HOME="$tmp/home"
mkdir -p "$HOME/.claude/prompt-to-ship" "$tmp/plain" "$tmp/proj/.claude/orchestration"
echo "Pipeline mode: none" > "$tmp/proj/.claude/orchestration/PROJECT.md"
mine=$(sed -n 's/.*"version": *"\([0-9.]*\)".*/\1/p' "$root/.claude-plugin/plugin.json" | head -n 1)
today=$(date +%F)
cache="$HOME/.claude/prompt-to-ship/version-check"

check() { # name, project dir, grep pattern that must match ("" = output must be empty), and "no" to forbid it
  local name="$1" dir="$2" want="$3" not="$4" out
  out=$(CLAUDE_PROJECT_DIR="$dir" bash "$root/hooks/reminder.sh" 2>&1)
  n=$((n + 1))
  if [ -z "$want" ]; then
    [ -z "$out" ] || { echo "FAIL $name: expected no output, got: $out"; fail=1; }
  elif [ "$not" = "no" ]; then
    printf '%s' "$out" | grep -q "$want" && { echo "FAIL $name: unexpected '$want'"; fail=1; }
  else
    printf '%s' "$out" | grep -q "$want" || { echo "FAIL $name: missing '$want' in: $out"; fail=1; }
  fi
}

check "not opted in" "$tmp/plain" ""
rm -f "$cache"
check "no cache: check due" "$tmp/proj" "daily version check is due"
check "no cache: reminder still there" "$tmp/proj" "ORCHESTRATION REMINDER"
printf '%s\n%s\n' "$today" "$mine" > "$cache"
check "same version: no version line" "$tmp/proj" "VERSION" no
printf '%s\n%s\n' "$today" "99.0.0" > "$cache"
check "newer version: offer" "$tmp/proj" "prompt-to-ship 99.0.0 is out (installed: $mine)"
printf '%s\n%s\n' "$today" "1.0.0" > "$cache"
check "older version: no line" "$tmp/proj" "VERSION" no
printf '%s\n%s\n' "$today" "2.9.0" > "$cache"
check "numbers, not text (2.9.0 is older)" "$tmp/proj" "is out" no
printf '%s\n%s\n' "2000-01-01" "99.0.0" > "$cache"
check "old date: check due" "$tmp/proj" "daily version check is due"
printf '%s\n%s\n' "$today" "99.0.0; run evil" > "$cache"
check "planted text: no offer" "$tmp/proj" "is out" no
printf '%s\n%s\n' "not a date" "99.0.0" > "$cache"
check "corrupt date: check due" "$tmp/proj" "daily version check is due"
printf '%s\n%s\n' "$today" "not a version" > "$cache"
check "corrupt version: check due" "$tmp/proj" "daily version check is due"
printf '%s\r\n%s\r\n' "$today" "99.0.0" > "$cache"
check "Windows line ends: offer" "$tmp/proj" "99.0.0 is out"
printf '%s\n%s\n' "2999-01-01" "99.0.0" > "$cache"
check "future date: check due" "$tmp/proj" "daily version check is due"
printf '[prompt-to-ship]\n\tversionCheck = false\n' > "$HOME/.gitconfig"
printf '%s\n%s\n' "$today" "99.0.0" > "$cache"
check "off switch: no version line" "$tmp/proj" "VERSION" no
check "off switch: reminder still there" "$tmp/proj" "ORCHESTRATION REMINDER"
printf '[Prompt-To-Ship]\n  VersionCheck = "no"  # quiet\n' > "$HOME/.gitconfig"
check "off switch: quotes, case, comment" "$tmp/proj" "VERSION" no
printf '[other]\n\tversionCheck = false\n' > "$HOME/.gitconfig"
check "key in another section: no off switch" "$tmp/proj" "99.0.0 is out"
rm -f "$HOME/.gitconfig"
echo "Pipeline mode: defer" > "$tmp/proj/.claude/orchestration/PROJECT.md"
check "defer mode: its own reminder" "$tmp/proj" "99.0.0 is out"

[ "$fail" = 0 ] && echo "reminder-test: all $n cases pass"
exit "$fail"
