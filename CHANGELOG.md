# Changelog

All notable changes. Versions follow semver and match `.claude-plugin/plugin.json`.

## 2.0.0

- New name: `prompt-to-ship` (was `optimal-coding-orchestration`). The skill command, the agent
  prefixes and the marketplace name change with it. Reinstall, and use `/prompt-to-ship`.
- Home: https://github.com/Klinterm/prompt-to-ship
- New README with diagrams of the pipeline and the autonomy levels.

## 1.3.0

- Autonomy levels: `ask` (default, as before), `change-request`, `merge`, `release`. Each
  developer chooses on the first load in a repository; the choice is stored in local git config
  (`orchestration.autonomy`), never committed. Change it with the argument `autonomy`.
- A team can cap the level with "Autonomy limit" in PROJECT.md. An existing house rule that says
  merges need the user counts as a cap.
- Fixed gates stop every level: high risk, a fixed list of CI, build, dependency and migration
  paths, open questions, BLOCKING review points, unfixed findings, failed or missing CI, merge
  conflicts, branch protection, other people's commits in a release, a changed release command,
  a failed check after a release.
- Reviewers can mark a point BLOCKING. Merge commands per host. The BRIEF shows the active level.
  The weekly review checks every automatic merge and release.

## 1.2.0

- Works with any git host: GitHub, GitLab, Bitbucket, Azure DevOps, Gitea and Forgejo, Gerrit,
  and plain git without a host. All host actions live in `references/code-hosts.md`.
- Stage 6 is now "Change request" (pull request, merge request or change, by host).
- Setup detects build, test, lint and type-check commands for common ecosystems and handles
  monorepos. It stops with a clear message in a folder that is not a git repository.
- PROJECT.md gets a "Code host" section and a "User interface" line. Existing PROJECT.md files
  keep working: the host is detected at run time and the skill offers to add the section.
- With "User interface: none" in PROJECT.md, the UI specialist is skipped.
- The hook prints nothing outside repositories with `.claude/orchestration/PROJECT.md`.
- Agents treat database, frontend, mobile, tenant and money checks as "if the project has it".
- Safer stage 6: high-risk and CI or build changes wait for the user's go before the push. Pushes
  use an explicit refspec to the topic branch only. No token on a command line.
- The standing rules win over PROJECT.md. A PROJECT.md the user did not write is shown and
  confirmed before its commands run.
- Added LICENSE (MIT), this changelog, a marketplace entry and `TESTING.md`.

## 1.1.0

- First complete version: brief, eight stages, six reviewer agents, weekly review, setup.
