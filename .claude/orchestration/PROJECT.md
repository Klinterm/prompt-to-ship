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
1. A user installs it in under five minutes from the README, on macOS, Linux or Windows (for
   invited users once read access is granted, while the repository is private).
2. Setup produces a correct PROJECT.md for a repository in any language without manual edits to
   the skill.
3. The pipeline works with GitHub, GitLab, Bitbucket, Azure DevOps, Gitea or Forgejo, Gerrit, and
   with plain git without a code host.
4. Outside opted-in repositories the hook adds no text and no cost; the skill itself runs only when
   the user calls it or the repository opted in (its daily version check runs only then).
5. No file in the shipped skill names a company, product, customer or stack of a user.

Stage: working prototype, before the first public release; the repository is private for now (by
invitation).

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
  marketplace. While the repository is private, both need read access and a git sign-in.
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
https://github.com/Klinterm/prompt-to-ship, private for now. The README is the home page for
invited users.

## Modules and scope
- `SKILL.md`: the orchestrator. Short.
- `agents/`: six read-only reviewers, a read-only researcher for outside facts and a read-only
  debugger for shipped code.
- `hooks/`: the opt-in reminder (reminder.sh), with the version line from the local cache.
- `tests/reminder-test.sh`: the hook test. `tests/structure-test.sh`: references, the Read-when
  table, agent frontmatter, skills in `skills/` and the case count. Both run in CI.
- `.github/workflows/checks.yml`: CI for this repository.
- `references/`: pipeline, gates, setup, workspace, existing pipeline, debug, checklist, security
  rules, code hosts, autonomy, learning, weekly review, research, design, update, direction, ui.
- `skills/design/`: the built-in design skill (`prompt-to-ship:design`): workflow, tiers,
  references (with scene mode in `immersive.md` and the rebuild path in `rebuild.md`) and the
  DESIGN.md template. `SOURCES.md` credits
  the projects it learned from.
- `TESTING.md`: the acceptance test before a release.
Out of scope: running code on behalf of reviewers, merges that bypass host protection, automatic
reverts, non-git version control.

## Customers, partners and integrations
Claude Code (skills, plugins, subagents, hooks). Code host CLIs: `gh`, `glab`, `az`, `tea`,
REST APIs. No paid service.

## Architecture and stack
Markdown and JSON, plus one bash script for the hook (hooks/reminder.sh). No build step.

## Existing pipeline
Pipeline mode: none

## Code host
- Host: github (https://github.com/Klinterm/prompt-to-ship)
- CLI: gh
- Default target branch: main

## Branches and environments
`main` is the release branch. A release is a tag `vX.Y.Z` that matches `plugin.json`.
- Release command: `git tag -a vX.Y.Z -m "prompt-to-ship X.Y.Z" <merge sha> && git push origin vX.Y.Z && gh release create vX.Y.Z --title "prompt-to-ship X.Y.Z" --notes-file <the CHANGELOG section of X.Y.Z>`
  (X.Y.Z is the version in `.claude-plugin/plugin.json`, the version file; it runs right after
  the merge at level release, when that version is higher than the latest tag; autonomy.md. The
  merge itself runs through the host; nothing is pushed to main directly.)
- Deploys on merge: yes (a marketplace install follows main)

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
Autonomy limit: release (the maintainer's word on 2026-11-04; a high-risk diff still waits for the
maintainer's diff read)
Storage: shared
Markers: description
Upstream inbox: yes (this is the prompt-to-ship repository: read ~/.claude/prompt-to-ship/upstream.md at stage 0)
- Merge only through the host and push only the release tag, through the pipeline at the
  maintainer's stored level, and never past a gate.
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
  `claude plugin eval . --runs 1 -j 4 --max-cost-usd 10 --no-publish --scaffold --allow-tools Edit Write`
  (`-j 4`: four runs at once, about 7 minutes instead of 25; for an interim check add
  `--ablation none`, half the runs)
  (21 cases; 19 cases with `--runs 1` used about $8.2 to $8.4 of plan usage on 2026-11-04; use `--max-cost-usd 10`). This repository
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
- Decision 2026-10-30 (maintainer): a new-project path in setup for an empty repository and an
  idea: idea questions, a reviewed choice of how to build it (never a default stack), 3 to 7
  slices, and slice 1 as a running empty app with one passing test, at high risk.
- Decision 2026-10-30 (maintainer): setup runs `git init` itself after one plain question, and
  offers a project folder in a folder that is too broad (2.16.0).
- Decision 2026-10-31 (maintainer): the reviewer and debugger agents have no shell (Read, Grep,
  Glob only); the lead runs the git history commands and passes the output. A guard hook was
  tried first and dropped: five security rounds kept finding ways for read-only git commands to
  start a program. A missing agent type stops the review; no general-purpose stand-in.
- Decision 2026-11-02 (maintainer): stage 5 findings get IDs and one answer (FIX, CONTEST,
  ESCALATE, DECLINE). A contest is settled only when the reviewer accepts it; at Medium or higher an
  unaccepted contest becomes ESCALATE. A required reviewer that did not run is gate 16. The weekly
  review adds a drift report by the architect (one run a week, per folder in a workspace). Ideas from
  the Elephant-Goldfish Model repository.
- Decision 2026-11-01 (maintainer): a daily version check whenever the skill runs (also at setup;
  outside opted-in repositories the hook stays silent), on by default with a global opt-out. The skill may update its own code
  only after the user's own word "update", only a clean pinned clone on main, only to the named
  release tag; otherwise it shows the command. This is not a merge, so the autonomy limit does not
  apply; the skill now runs one read-only git network call a day. The hook (not the lead's memory)
  triggers it: the eval showed the lead skips a version step in SKILL.md; the hook reads only the
  local cache.
- Decision 2026-11-01 (maintainer): two plan checks from the Elephant-Goldfish Model idea: each
  plan reviewer first restates the plan (Understood, Unclear), and the architect gives a Ready
  verdict on normal and high risk. The PLAN block names its files. No extra agent run in the
  normal case; one restart per check, then BLOCKING.
- Decision 2026-11-03 (maintainer): a built-in design skill (`skills/design/`, invoked as
  `prompt-to-ship:design`) from lessons of public design skills. The full workflow is opt-in with
  `Design skill: built-in`, so decision 2026-10-28 stands. Its tiers check every visible change:
  a Floor item (objective only: contrast, focus, keyboard, target size, broken layout, invented
  facts) is BLOCKING, which is stricter than before; Reflex is ADJUST unless the plan names a user
  need; Finish is advice. With a house style, Reflex and Finish apply only to new or changed
  code. A team turns the tier check off with `Design tiers: off`
  (confirmed PROJECT.md only; contrast and accessibility stay BLOCKING). A second
  exception to the generic rule: `skills/design/SOURCES.md` names the projects it learned from
  (credit and licence), and nowhere else. plugin.json says `"skills": ["."]` so the root skill
  keeps loading next to `skills/`.
- Decision 2026-11-04 (maintainer): scene mode in the design skill (`immersive.md`) for a page
  whose main form is a 3D scene in the browser. A design option, never a default: step 4 may offer
  it as one direction when the subject passes the reason test, and it starts only on the user's
  pick. Floor stays as it is; the HTML text stays the page. Budget numbers are the team's own and
  never BLOCKING on their own.
- Decision 2026-11-04 (maintainer): the rebuild path (2.23.0). A redesign or rebuild the user asks
  for lifts the old look for the pages in the change; `skills/design/references/rebuild.md` covers
  a site that has pages; references/design.md is the one home for who does what per stage. It
  extends decision 2026-10-28: the UI specialist's brief is now the "layout brief" (without the
  built-in skill), and a URL the user types in the chat may be opened as a reference. Decision
  2026-11-03 is unchanged: the full workflow stays opt-in with `Design skill: built-in`.
- Decision 2026-11-04 (maintainer): level release for this repository. The maintainer set
  `orchestration.diffGoCovers` in chat (the maintainer's words, translated: "Yes, for that diff",
  to the question whether a go on a high-risk diff should from now on also cover its merge and
  release; the lead records it as a standing setting, and the maintainer confirms that at the diff
  read; without that confirmation the go covers the push only and the pipeline stops before the
  merge): the go on a high-risk diff also
  covers the merge and the release of exactly that sha. Every other gate still stops, and a
  high-risk diff still waits for the maintainer's diff read. A merge to main deploys (marketplace
  installs follow main); the tag runs right after it when the version is higher. A minor version
  shows the eval cost in the BRIEF (tokens and agent runs on a subscription; the dollar amount is
  only the `--max-cost-usd 10` cap), stops there for the maintainer's own typed go, and puts the
  eval result in the CHANGELOG before the diff read. A run that hits the cap stops; a failed or
  noisy case is reported as it is, with no silent retry.
- Decision 2026-11-05 (maintainer): keep the repository private for now ("Ja, privé houden"); the
  goal text stays ("anyone"). Installs and updates use the user's own git sign-in. It extends
  decision 2026-11-01: the one read-only git network call a day may now use the user's credential
  helper, for the fixed https address only, never with a prompt; without access it stays silent,
  on purpose. Releases still run (`gh release create`) and are visible to invited users only.
- Decision 2026-11-05 (maintainer): direction mode (2.27.0) for a user who lost track: findings, an
  interview, a DIRECTION block and no agent runs. It keeps the result in a local note outside the
  repository, not in a committed file; the accepted limit is that the note does not follow the
  user to another environment. The mode does not fetch, so it stays read-only, except for the note and the version check. A step number starts
  the normal pipeline at the user's own level; no reply in this mode is a go on a plan.
- Decision 2026-11-05 (maintainer): UI mode (2.28.0): a read-only review of an existing screen, top
  problems with a rule id and a measured value, then a fix or a redesign on the user's own reply. The
  lead scores, with no agent run (R6), so the score has no independent scorer; the UI specialist
  reviews each fix in 5d. It extends, and does not replace, decisions 2026-11-03 and 2026-11-04: the
  tiers and the audit are read by path without the opt-in, the full workflow stays opt-in, a redesign
  runs at level `ask`, and a URL the user types may be the screen under review, also on localhost. The
  mode runs no command without the user's yes in chat; this is the first use of `Preview:` as a command.
  It narrows decision 2026-11-04 for one case: a go on a high-risk diff does not cover the merge of a
  redesign that this mode started.
- Decision 2026-11-06 (maintainer): faster review (2.29.0), because the pipeline took too long. It
  extends decision 2026-11-02. Round 1 stays full; a follow-up round starts only at severity Medium
  or higher, on a reopened finding or on a 5d ADJUST; a validator runs on a contest, on High or
  higher, or on doubt; the security reviewer reads a sensitive change in a follow-up round. The
  quick lane is not widened. Evidence: the last two changes had about 24 agent runs each, 14 of them
  in the part that changed, and every Medium finding that survived came from round 1. A thin baseline.
  Measuring point: the next three change requests in this repository record agent runs, findings of
  Medium or higher per round, and each `Extra reviewer` and `Security reviewer not re-run` line. A problem of severity Medium or higher
  found after stage 5 (diff read, CI, after the merge), in an area where a run was dropped, is an
  incident (learning.md); then reconsider this decision.
- Decision 2026-10-27 (maintainer): Phase A (coherence and load) before new features.

## Security context
The hook runs a fixed bash script on every prompt for every user. It must stay read-only and
offline: it prints fixed text and, from the local version cache, one line with checked numbers
only. It starts no program but grep, cat and at most one date. The reviewer agents have no shell. Reviewers must never execute project code.
The daily version check (references/update.md) may use the user's own git credential helper,
read-only, for the fixed https address only; it never prompts and stores or prints no token.

## Learning
Incidents and rules: `.claude/orchestration/incidents.md` and `rules.md` (rules.md appears at the
first stage rule). See references/learning.md.
