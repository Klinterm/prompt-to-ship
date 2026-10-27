# Working on this repository

This repository is a Claude Code skill that is also a plugin and its own plugin marketplace.
Users install it with `/plugin marketplace add`, or by cloning the folder into
`~/.claude/skills/` or into a repository's `.claude/skills/`. This file lives in `.claude/` so
it is not shipped as part of the plugin root.

## Structure

- `SKILL.md`: the orchestrator. Keep it short; details go in `references/`.
- `.claude-plugin/plugin.json`: makes the folder a plugin, so `agents/` and `hooks/` load with it.
- `agents/`: six read-only reviewer agents. Their names get the plugin name as prefix.
- `hooks/`: a reminder on every prompt that stays silent outside opted-in repositories.
- `references/`: pipeline, setup, existing pipeline, checklist, code hosts, autonomy, security
  rules, weekly review.
- `.claude/orchestration/PROJECT.md`: this repository runs its own pipeline.
- `TESTING.md`: the acceptance test before a release. `CHANGELOG.md`: one section per version.

## Rules

- Everything in English. The skill answers users in their own language.
- Generic: no company, product, customer or stack names. Product knowledge belongs in each user
  repository's `.claude/orchestration/PROJECT.md`.
- No em dashes, en dashes or curly quotes.
- Host neutral: every code host action goes through `references/code-hosts.md`. Language
  neutral: no check may assume a database, a frontend or a framework.
- When you change behaviour, bump the version in `plugin.json` (semver) and add a CHANGELOG line.
- The plugin name, the folder name, the agent prefixes in `SKILL.md` and the README must match.
- Check with `claude plugin validate .` before a release.

## Open items before the first public release

1. Run `TESTING.md` in fresh sessions (both install paths, the hook, setup on two ecosystems,
   a change with and without a code host, the weekly review, the autonomy levels).
2. Remove this "Open items" section once done.

Done: `LICENSE` (MIT); both install paths (1.2.0); the name `prompt-to-ship` and the repository
https://github.com/Klinterm/prompt-to-ship (2.0.0).
