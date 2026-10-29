# Project context for the orchestration layer

This repository runs its own pipeline on itself. This file is also a worked example of a
PROJECT.md.

## Product
A Claude Code skill and plugin that runs every coding request through one pipeline: brief,
understand, plan with fixed reviewers (a UI reviewer on a visible change), build, prove, layered
review, change request, measure, learn. Users install it once and opt in per repository with a PROJECT.md.

## Goal and success
Goal: an orchestration layer that anyone can use in any repository, whatever the language, the
stack or the code host.

Success, as checks:
1. A user installs it in under five minutes from the README, on macOS, Linux or Windows.
2. Setup produces a correct PROJECT.md for a repository in any language without manual edits to
   the skill.
3. The pipeline works with GitHub, GitLab, Bitbucket, Azure DevOps, Gitea or Forgejo, Gerrit, and
   with plain git without a code host.
4. Outside opted-in repositories the skill adds no text and no cost.
5. No file in the shipped skill names a company, product, customer or stack of a user.

Stage: working prototype, before the first public release.

## Requirements
- R1 Host neutral. Every host action (open a change request, read its status, list change requests, read CI)
  goes through `references/code-hosts.md`. PROJECT.md records the host once. No host means a
  local branch and a patch, never a failure.
- R2 Language neutral. Setup detects build, test, lint and type-check commands from the
  repository's own files for common ecosystems, and asks when it cannot. Agents never assume a
  database, a frontend, a mobile app or a framework. Each check applies "if the project has it".
- R3 Repository shapes. Single repository, monorepo (one PROJECT.md with per-package commands)
  and several repositories (one PROJECT.md each).
- R4 Silent outside opt-in. The hook prints nothing unless the project has
  `.claude/orchestration/PROJECT.md`.
- R5 Safe by default. Reviewers are read-only. The default level `ask` never merges, pushes to a
  shared branch or releases without the user's explicit word.
- R9 Optional autonomy (decided by the maintainer in 1.3.0). Each developer chooses, on the first
  load, a level: ask, change-request, merge or release. Stored in local git config, never in the
  repository. A team may cap it in PROJECT.md. Fixed gates stop every level.
- R6 Cheap where possible. Low-risk changes keep the review light. Costly runs get an estimate first.
- R7 Two install paths: copy or clone into a skills folder, or add the repository as a plugin
  marketplace.
- R8 Every behaviour change bumps the version in `plugin.json` and gets a CHANGELOG line.

## Users and roles
- Developer: installs it, runs setup, chooses an autonomy level, asks for changes, approves
  merges (or lets the pipeline merge).
- Team lead: commits PROJECT.md so the team shares one context.
- Contributor to this repository: changes the skill itself through this same pipeline.

## User interface
User interface: yes
What the user reads in the chat: the BRIEF, the plan verdicts, the setup questions, the change
request description, the weekly report. Also the README.

## Website and public presence
https://github.com/Klinterm/prompt-to-ship. The README is the home page.

## Modules and scope
- `SKILL.md`: the orchestrator. Short.
- `agents/`: six read-only reviewers, a read-only researcher for outside facts and a read-only
  debugger for shipped code.
- `hooks/`: the opt-in reminder.
- `references/`: pipeline, gates, setup, workspace, existing pipeline, debug, checklist, security
  rules, code hosts, autonomy, learning, weekly review, research, design.
- `TESTING.md`: the acceptance test before a release.
Out of scope: running code on behalf of reviewers, merges that bypass host protection, automatic
reverts, non-git version control.

## Customers, partners and integrations
Claude Code (skills, plugins, subagents, hooks). Code host CLIs: `gh`, `glab`, `az`, `tea`,
REST APIs. No paid service.

## Architecture and stack
Markdown and JSON only, plus one shell line in the hook. No build step.

## Existing pipeline
Pipeline mode: none

## Code host
- Host: github (https://github.com/Klinterm/prompt-to-ship)
- CLI: gh
- Default target branch: main

## Branches and environments
`main` is the release branch. A release is a tag `vX.Y.Z` that matches `plugin.json`.
- Release command: `git tag -a vX.Y.Z -m "prompt-to-ship X.Y.Z" <merge sha> && git push origin vX.Y.Z && gh release create vX.Y.Z --title "prompt-to-ship X.Y.Z" --notes-file <the CHANGELOG section of X.Y.Z>`
  (X.Y.Z is the version in plugin.json; only on the maintainer's word)

## Commands
- Build: none.
- Checks: `claude plugin validate .`
- Style check: no em dashes, en dashes or curly quotes in any file
  (`rg -n "[\x{2013}\x{2014}\x{2018}\x{2019}\x{201C}\x{201D}]" .` must print nothing).
- Release test: `TESTING.md`.
- Preview: install into a test repository and run the skill with `setup`.

## Design and wording
House style: the existing README, references and diagrams (docs/make-diagrams.py).
Design skill: none
English only. Short sentences, active voice, one term per concept. The skill answers users in
their own language.

## Risk table
| Risk | Examples |
|---|---|
| Low | wording in references and README that changes no behaviour (a change to a rule in references is Normal) |
| Normal | a new stage rule, a new reference file, agent instructions |
| High | the hook, the standing rules, the plugin manifest, anything about merges or secrets |

## House rules
Autonomy limit: change-request (every change here touches the skill's own rules; the maintainer
merges and tags)
Storage: shared
Markers: description
Upstream inbox: yes (this is the prompt-to-ship repository: read ~/.claude/prompt-to-ship/upstream.md at stage 0)
- Never merge, push to `main` or tag a release without the maintainer's word.
- Generic: no company, product, customer or stack names in shipped files. One recorded exception:
  the design gallery that setup suggests (decision 2026-10-29).
- The plugin name, the folder name, the agent prefixes in `SKILL.md` and the README must match.

## Documents, decisions and parked items
- `.claude/CLAUDE.md`: rules for working on this repository and the open items before release.
- `CHANGELOG.md`: what changed per version.
- Parked: agent teams as the default for stage 2 (cost).
- Decision 2026-10-27 (maintainer): evals are unparked. A `claude plugin eval` suite runs before
  each minor release, with a cost estimate first; never as a blocking check on every commit.
  The suite is in `evals/`. Run it with
  `claude plugin eval . --runs 1 --max-cost-usd 7 --no-publish --scaffold --allow-tools Edit Write`
  (15 cases; `--runs 1` of 13 cases used $4.79 of plan usage on 2026-10-29; use `--max-cost-usd 7`). This repository
  uses `--runs 1` before a release (decision 2026-10-27). The number of runs is the
  maintainer's choice: `--runs 3` with `--max-cost-usd 15` (about $11) gives more certainty.
  Native Windows has no Bash sandbox, so the cases give the agent no shell. A release states the score with the plugin and the difference from the run
  without it, or "no eval run". An llm judge checks visible text in the final message
  (`focus: last_message`, literal criteria); judges that read the whole trace gave false fails.
- Decision 2026-10-27 (maintainer), replaced on 2026-10-28: three plan reviewers always, also
  for low risk (no light lane).
- Decision 2026-10-28 (maintainer): the architect and the product expert review every plan, also
  for low risk; the UI specialist runs only on a visible change (R6: no review that can only say
  "no visible change"). On a new screen it gives a design brief. Inspiration sources are opened
  by the lead in the browser, never by a reviewer. A personal design skill guides layout with a
  house style only when the project opts in.
- Decision 2026-10-29 (maintainer): setup suggests one public design gallery (designeer.xyz) as a
  starting point for "Design inspiration". A deliberate exception to the generic rule: it is a
  suggestion the user accepts or changes, never a default.
- Decision 2026-10-29 (maintainer): quick lane for small low-risk changes (brief, build, proof,
  fresh reviewer, product expert on the result, UI on a visible diff; never merges on its own).
  It replaces "no light lane" (2026-10-27) and "the architect and product expert review every
  plan" (2026-10-28) for that lane only. Stage 1 and stage 8 stay; in mode map it never pushes. Off switch "no pipeline:" via the reminder text; a team
  turns it off with "Off switch: no".
- Decision 2026-10-29 (maintainer): debug mode for shipped code (Phase A was done in 2.7.0). The lead may read production
  systems only through the methods in a confirmed debug/access.md, with limits and timeouts;
  every write to a production system is gate 15, per action. Monitoring that runs on its own is
  out of scope (R6).
- Decision 2026-10-29 (maintainer): agent models. The architect, product expert, UI specialist,
  fresh reviewer and debugger default to sonnet; the security reviewer, validator and researcher
  keep `inherit`. A developer changes it in chat; it lives in local git config
  (`orchestration.agentModels`), never in the repository. Evidence: `evals-models/`, run with
  `bash evals-models/run.sh <haiku|sonnet|opus> --runs 2 --max-cost-usd 6` (about $2 per model
  on 2026-10-29). Its llm judge gave false fails on correct answers; read the failed runs before
  you decide. Rerun it when a new model family arrives.
- Decision 2026-10-27 (maintainer): Phase A (coherence and load) before new features.

## Security context
The hook runs a shell command on every prompt for every user. It must stay a read-only, fixed
command. Reviewers must never execute project code.

## Learning
Incidents and rules: `.claude/orchestration/incidents.md` and `rules.md` (rules.md appears at the
first stage rule). See references/learning.md.
