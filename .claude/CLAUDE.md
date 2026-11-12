# Working on this repository

This repository is a Claude Code skill that is also a plugin and its own plugin marketplace.
Users install it with `/plugin marketplace add`, or by cloning the folder into
`~/.claude/skills/` or into a repository's `.claude/skills/`. This file lives in `.claude/` so
it is not shipped as part of the plugin root.

## Structure

- `SKILL.md`: the orchestrator. At most 8,000 bytes; details go in `references/`, each read only when the "Read when" table says so. Each rule has one home.
- `.claude-plugin/plugin.json`: makes the folder a plugin, so `agents/` and `hooks/` load with it.
- `agents/`: six read-only reviewer agents, a read-only researcher for outside facts and a
  read-only debugger for shipped code. Their names get the plugin name as prefix.
- `hooks/`: a reminder on every prompt that stays silent outside opted-in repositories.
- `skills/design/`: the built-in design skill (`prompt-to-ship:design`). plugin.json lists
  `"skills": ["."]` so the root SKILL.md keeps loading.
- `references/`: pipeline, gates, setup, workspace, existing pipeline, debug, checklist, code
  hosts, autonomy, learning, security rules, weekly review, research, design, update, direction, ui, states, project map.
- Pipeline lessons from other projects arrive in `~/.claude/prompt-to-ship/upstream.md` (this
  repository's PROJECT.md says `Upstream inbox: yes`). They are generic by design; keep them so.
- `.claude/orchestration/incidents.md`: this repository's own incidents (stage 8).
- `.claude/orchestration/PROJECT.md`: this repository runs its own pipeline.
- `TESTING.md`: the acceptance test before a release. `CHANGELOG.md`: one section per version.

## Rules

- Everything in English. The skill answers users in their own language.
- Generic: no company, product, customer or stack names. Product knowledge belongs in each user
  repository's `.claude/orchestration/PROJECT.md`. Three recorded exceptions: the design gallery
  that setup suggests (PROJECT.md, decision 2026-10-29), the credits in
  `skills/design/SOURCES.md` (decision 2026-11-03), and Figma for the project map mode (decision
  2026-11-12): only in `references/project-map.md`, its README section and command row, its
  TESTING.md section, the CHANGELOG and these decision and rule lines.
- No em dashes, en dashes or curly quotes.
- Host neutral: every code host action goes through `references/code-hosts.md`. Language
  neutral: no check may assume a database, a frontend or a framework.
- When you change behaviour, bump the version in `plugin.json` (semver) and add a CHANGELOG line.
- The plugin name, the folder name, the agent prefixes in `SKILL.md` and the README must match.
- Check with `claude plugin validate .` before a release.

## Open items before wider promotion

The repository is public (decision 2026-11-09). The README status stays "working prototype" until
item 1 is done.

1. Run `TESTING.md` in fresh sessions (both install paths, the hook, setup on two ecosystems,
   a change with and without a code host, the weekly review, the autonomy levels).
2. Remove this "Open items" section once done.

Done: `LICENSE` (MIT); both install paths (1.2.0); the name `prompt-to-ship` and the repository
https://github.com/Klinterm/prompt-to-ship (2.0.0).
