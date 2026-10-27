# Changelog

All notable changes. Versions follow semver and match `.claude-plugin/plugin.json`.

## 2.3.0

Lessons from the first real test run:
- A target that deploys on merge (a hosting platform that watches the branch, or a CI deploy
  job) makes every merge a release. Such a merge now needs autonomy level `release`. Setup
  detects deploy jobs and deploy files, and always asks, because a platform can watch a branch
  with no file in the repository. At level `merge` the pipeline stops before such a merge.
- The safe answer wins: a deploy job beats a "no" in PROJECT.md, and a missing line counts as
  "yes" until the user answers (also for PROJECT.md files from before 2.3.0). The answer is
  stored as `orchestration.deploysOnMerge`, and the confirm step shows the line.
- Hosting deploy files are now forced high risk.
- Map mode pushes the topic branch also when the host CLI is missing: that push needs only git.
- The map commit line is now "Reviewed by prompt-to-ship (map, level <level>).". The old line
  said "pushed automatically", which was wrong when the user pushed.

## 2.2.0

- Pipeline mode `defer` now adds a prompt-to-ship reviewer for each role that the repository's
  own agents lack or cover only partly. Before, a role with any agent counted as covered.
- Setup classifies each of the six roles as full, partial or missing, with the reason. A role is
  full only when its agent cannot edit files, runs at the same step and risk levels, covers the
  core points of the role (with a quoted line as proof) and asks for file-and-line evidence.
- The user can correct a role in the answer, for example "1, security-reviewer full".
- The question shows the extra reviewer runs per change. A role that is partial only by risk
  level gets the prompt-to-ship reviewer only when the repository's agent did not run.
- The hash of each classified agent file is stored. A changed agent is classified again.
- A repository in `defer` from 2.1.0 gets the role cover once, after the user says yes.
- The "Names" line in "Existing pipeline" is now "Brief name" plus the "Role cover" list.

## 2.1.0

- Setup detects an existing pipeline (a process in CLAUDE.md or AGENTS.md, own review agents,
  own skills or commands, a pipeline document) and asks one question: defer, map, replace or
  none. The answer goes into a new PROJECT.md section "Existing pipeline". Rules in
  `references/existing-pipeline.md`.
- defer: the existing pipeline leads; prompt-to-ship only adds the reviewers it lacks. The hook
  then prints a different, fixed reminder.
- map: prompt-to-ship runs with the existing names, house rules and git flow. A house rule
  "push straight to main" becomes: squash into one commit, push the topic branch, wait for CI on
  that commit, check the branch protection, then fast-forward main, only at autonomy level merge
  or higher.
- Agents from the repository never replace a prompt-to-ship reviewer.
- replace: prompt-to-ship leads; setup lists the CLAUDE.md lines to change and never edits them.
- A changed "Existing pipeline" section needs the user's confirmation, like the other sections.
- Repositories set up with 2.0.0 that have an existing pipeline get the mode question once,
  before the next task.
- SKILL.md: the section "Modes" is now "Arguments", so "mode" means only the pipeline mode.

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
