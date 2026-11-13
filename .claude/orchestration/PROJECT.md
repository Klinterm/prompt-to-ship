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
1. A user installs it in under five minutes from the README, on macOS, Linux or Windows, with no
   invitation and no git sign-in.
2. Setup produces a correct PROJECT.md for a repository in any language without manual edits to
   the skill.
3. The pipeline works with GitHub, GitLab, Bitbucket, Azure DevOps, Gitea or Forgejo, Gerrit, and
   with plain git without a code host.
4. Outside opted-in repositories the hook adds no text and no cost; the skill itself runs only when
   the user calls it or the repository opted in (its daily version check runs only then).
5. No file in the shipped skill names a company, product, customer or stack of a user. The recorded
   exceptions are in House rules.

Stage: working prototype. The repository is public; the acceptance test (TESTING.md) is not complete
yet.

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
  marketplace. Neither needs an invitation or a git sign-in.
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
https://github.com/Klinterm/prompt-to-ship, public. The README is the home page.

## Modules and scope
- `SKILL.md`: the orchestrator. Short.
- `agents/`: six read-only reviewers, a read-only researcher for outside facts and a read-only
  debugger for shipped code.
- `hooks/`: the opt-in reminder (reminder.sh), with the version line from the local cache.
- `tests/reminder-test.sh`: the hook test. `tests/structure-test.sh`: references, the Read-when
  table, agent frontmatter, skills in `skills/` and the case count. Both run in CI.
- `.github/workflows/checks.yml`: CI for this repository.
- `references/`: pipeline, gates, setup, workspace, existing pipeline, debug, checklist, security
  rules, code hosts, autonomy, learning, weekly review, research, design, update, direction, ui, states, project map, hosting, diagrams.
- `skills/design/`: the built-in design skill (`prompt-to-ship:design`): workflow, tiers,
  references (with scene mode in `immersive.md` and the rebuild path in `rebuild.md`) and the
  DESIGN.md template. `SOURCES.md` credits
  the projects it learned from.
- `TESTING.md`: the acceptance test before a release.
Out of scope: running code on behalf of reviewers, merges that bypass host protection, automatic
reverts, non-git version control.

## Customers, partners and integrations
Claude Code (skills, plugins, subagents, hooks). Code host CLIs: `gh`, `glab`, `az`, `tea`,
REST APIs. No paid service. Optional: the Figma MCP connector, for `project-map` and for diagrams in a design file (edit access
to a file may need a paid Figma seat). Optional: a hosting platform the user picks in `hosting`
(Cloudflare has written steps); its account, plan and payment are the user's own.

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
- Checks: `claude plugin validate .`, `bash tests/reminder-test.sh`, `bash tests/structure-test.sh`
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
| High | the hook, `references/gates.md`, the standing rules, the plugin manifest, anything about merges or secrets |

## House rules
Autonomy limit: release (the maintainer's word on 2026-11-04; a high-risk diff still waits for the
maintainer's diff read)
Storage: shared
Markers: description
Upstream inbox: yes (this is the prompt-to-ship repository: read ~/.claude/prompt-to-ship/upstream.md at stage 0)
- Merge only through the host and push only the release tag, through the pipeline at the
  maintainer's stored level, and never past a gate.
- Release notes: every CHANGELOG section from 2.34.0 on ends with the star line ("Does
  prompt-to-ship help you? A star on GitHub helps others find it."), because that section is the
  release notes. Older GitHub releases are not edited (the maintainer's answer, 2026-11-13).
- Generic: no company, product, customer or stack names in shipped files. Four recorded exceptions:
  the design gallery that setup suggests (decision 2026-10-29), the credits in
  `skills/design/SOURCES.md` (decision 2026-11-03), Figma for the project map mode (decision
  2026-11-12), and hosting platforms for the hosting mode (decision 2026-11-13).
- The plugin name, the folder name, the agent prefixes in `SKILL.md` and the README must match.
- Extra forced-high paths (gates.md): `references/gates.md`, `hooks/**`.

## Documents, decisions and parked items
- `.claude/CLAUDE.md`: rules for working on this repository and the open items before release.
- `CHANGELOG.md`: what changed per version.
- Parked: agent teams as the default for stage 2 (cost).
- Parked (project map, decision 2026-11-12): status colours as Figma variables, an owner style step
  from a reference design, a one-page export of the Start page, and links from cards to their doc and
  change request.
- Decision 2026-10-27 (maintainer): evals are unparked. A `claude plugin eval` suite runs before
  each minor release, with a cost estimate first; never as a blocking check on every commit.
  The suite is in `evals/`. Run it with
  `claude plugin eval . --runs 1 -j 4 --max-cost-usd 12 --judge-model sonnet --no-publish --scaffold --allow-tools Edit Write`
  (`-j 4`: four runs at once, about 7 minutes instead of 25; for an interim check add
  `--ablation none`, half the runs)
  (25 cases; 21 cases with `--runs 1` used about $9.8 of plan usage on 2026-11-08; use `--max-cost-usd 12`: a run that breaches the cap skips the paid graders and loses votes). This repository
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
  only the `--max-cost-usd 12` cap), stops there for the maintainer's own typed go, and puts the
  eval result in the CHANGELOG before the diff read. A run that hits the cap stops; a failed or
  noisy case is reported as it is, with no silent retry.
- Decision 2026-11-05 (maintainer; replaced by the decision of 2026-11-09 on the public repository): keep the repository private for now ("Ja, privé houden"); the
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
- Decision 2026-11-08 (maintainer): the eval command uses `--judge-model sonnet` and
  `--max-cost-usd 12`. It extends decision 2026-10-27. The default judge failed correct messages.
  Evidence on 2.29.0, one suite run per judge, on 2026-11-06 and 2026-11-08: `direction-interview`
  went from FFF to PPP; all 60 votes without the plugin stayed the same and the same 14 cases fail;
  the judge cost went from $0.31 to $0.93, the run from $9.13 to $9.81. Limits: each judge read its
  own agent messages, sonnet split once (`quick-lane-small-fix`, FPP, which passes), and the case
  `states-report-first` from 2.30.0 was not in the comparison. Scores up to 2.30.0 come from the
  default judge: name the judge when you compare with them. The placeholder commands in `README.md`
  and `TESTING.md` have no judge flag, so they use the default judge. The `--runs 3` figure is older
  and not measured with this judge. `evals-models/` is not part of this.
- Decision 2026-11-08 (maintainer): find hidden states (2.30.0): a read-only mode that finds hidden
  states in code and written rules, and ends with numbered actions. The lead reads, with no agent run
  (R6), as in direction and UI mode (2026-11-05), so nothing checks the findings until an action
  starts the pipeline. It saves no review runs. Only the argument starts it, and it runs no command, so
  a folder's own git config starts no program and cannot forge a confirmation. The accepted limit: it
  cannot list links, so every report says so. A link check with `find` was tried and dropped: three
  review rounds each found a new problem in it. No text in the repository silences a finding; a recorded decision only adds a note, and a deliberate choice with a
  failing scenario comes back on each run (the known cost). It is not a weekly step, because
  a full scan each week repeats itself. Evidence: one audit with a pasted prompt on this
  repository, which found a rule contradiction that the weekly review and drift mode cannot find. A
  thin baseline. Measuring point: the next three uses record how many actions the user started and how
  many findings proved false or were deliberate choices; then reconsider this decision.
- Decision 2026-11-08 (maintainer's words: "Fix hash, record limit", "Accept, build it"): every stored
  file hash comes from one command with no filter (2.30.1; gates.md, "File hash"). A folder delivered
  with its own `.git` stays an accepted limit, with no detection: its config can start a program at
  git commands such as `git status`, `git diff HEAD` or `git blame`, and it can hold a false
  confirmation and level. The way out is a clone without `origin`. Evidence: a measured matrix with two
  config keys on one machine (git 2.53, Windows), and the `git` manual, section SECURITY. `git check-attr`
  first was rejected, because it starts `core.fsmonitor`. Added after the maintainer's words, as facts
  from the review: a file with a carriage return inside a line gets no hash, and a clone can hold a
  tracked bare repository in a subfolder. Unknown: the host's own git command at session start.
- Decision 2026-11-09 (maintainer's words: "Yes, fix it", to making all text say public, because
  someone will promote the repository): the repository is public. This replaces the decision of
  2026-11-05 to keep it private, and its credential helper. The daily check and the update fetch run
  no credential helper again, as in decision 2026-11-01, because a public repository needs none. The
  README stays "working prototype" until TESTING.md has run. The weekly review reads only a change
  request that is merged or comes from a branch in the repository itself. A known limit: the author
  of a merged fork request can still edit its text, and step 8 reads it.
- Decision 2026-11-09 (maintainer's words: "Record as accepted limit", "Make gates.md high risk",
  "Yes, do it here" to forced-high paths for both files): the Checks line runs two tracked scripts,
  and the timing of that run stays an accepted limit. The confirmed PROJECT.md hash covers the command
  text, not what runs. These changed files run as the local user with no new question, at stage 4,
  before the review: `tests/reminder-test.sh`, the `hooks/reminder.sh` that it runs,
  `tests/structure-test.sh`, and the file hash command in `references/gates.md` that it runs. The CI
  rule in `references/gates.md` makes both scripts forced high. House rules add `references/gates.md`
  and `hooks/**` as forced-high paths, because a row in the risk table has no check on the diff. Before
  2026-11-09 a change to the hash command alone was Normal, with no diff read by the user. For all four
  files the diff read comes at stage 6, after the local run, so it does not close the limit.
  `.claude-plugin/plugin.json` needs no new line: it is already forced high as the version file. Any
  test command in any project has the same property. Rejected: all of `tests/` in the high risk row,
  because the two scripts that run are already forced high. Added after the first words, as facts from
  the review: the CI rule, the hook, the version file and this reason for the rejection. Evidence: the
  security reviews of this line and in PRs 16 and 17, from reading only, not run.
- Decision 2026-11-12 (maintainer's answers in chat: "Third exception", "project-map", "Core + manifest
  + refresh", "Yes, full suite", then "Widen to user docs"): a project map mode (2.31.0) from a handoff
  that was used for weeks on a real project. The argument `project-map` (or `project-map refresh`)
  builds a living map in a Figma file through the official Figma MCP connector; the name avoids a
  second meaning next to pipeline mode `map`. A third exception to the generic rule: Figma may be named only in `references/project-map.md`, its README section and command row, its TESTING.md section, the CHANGELOG, and the decision, rule, integration and parked lines in PROJECT.md and `.claude/CLAUDE.md`. SKILL.md, agents, hooks, `skills/` and the eval case stay free of the name.
  The connector is optional: without it the mode stops with one line, and no other mode changes. As
  in direction, ui and states mode (R6), no reviewer agent runs; the one optional agent is the host's
  read-only search agent for large documents. The mode runs a fixed list of read-only git commands,
  each value checked and quoted, so the accepted limit of 2026-11-08 (a folder with its own git
  config) applies to them; a folder the user says arrived with its own `.git` runs no git command.
  Every write waits for the owner's own typed yes on a write list that shows the content, the risks
  and what was left out, at every autonomy level. It is its own stop, not gate 15, because a Figma
  file is no running system. The manifest lives outside the repository, as the direction note does:
  a map update then touches no forced-high path; the accepted limit is that it does not follow the
  user to another computer. A thin baseline: the eval case reaches only "asks first, writes nothing,
  no BRIEF", not the connector path. Measuring point: the next three uses record how many write
  lists the owner accepted and how many statuses proved wrong; then reconsider this decision.
- Decision 2026-11-13 (maintainer's words: "A: neutral, Cloudflare first", after research on Cloudflare
  and seven alternatives): a hosting mode (2.32.0). The argument `hosting` gives a read-only offer of
  two or three hosting platforms that fit the project, the best fit first, and never a default; this
  keeps decision 2026-10-30. Cloudflare is first only for static sites, single-page apps and
  JavaScript apps, and it is the only platform with written steps for now. Plain words run the
  normal pipeline, never the offer. The research (two runs and a check-mode run, all read on
  2026-11-13) found no single best platform: Cloudflare is strong for static and JavaScript apps,
  and an app in a Docker image needs its Containers on the paid plan. A fourth exception to the
  generic rule: Cloudflare, Vercel, Netlify, Render, Railway, Fly.io and GitHub Pages may be named in `references/hosting.md`, `references/gates.md` (its deploy-file list), the graders in `evals/hosting-offers-first/case.yaml`, the README section and command row, the TESTING.md section, the CHANGELOG, and the decision, rule, integration and parked lines in PROJECT.md and `.claude/CLAUDE.md`. setup.md, SKILL.md, agents, hooks, `skills/`, `tests/` and the
  eval prompt and fixture stay free of the names. No prices in shipped files; each claim names its
  official page and the read date, with `source:` and `valid:` (to 2027-05-13). The skill never
  creates an account, accepts terms, adds a payment method, changes DNS, or handles a token; the user
  signs in in their own terminal. Two exclusive ways to go live: deploy on push (Deploys on merge:
  yes, so a merge is a release and needs level `release`) or by hand (each deploy waits for the
  user's go). A site that may be live gets gate 15 per deploy. Not confirmed by a source: whether a
  preview shares live data, so the text treats it as able to change live data. A thin baseline: the
  eval case reaches only the offer, not a sign-in or a deploy. Measuring point: the next three uses
  record which platform the user picked, whether a step needed a command outside this file, and any
  stop at a gate; then reconsider this decision and the steps for a second platform.
- Decision 2026-11-13 (maintainer, third; words: "Doe dit dan" to the star line, "Ja, volledige eval",
  "Alleen vanaf nu"): the star line (2.34.0). The maintainer first asked to block use until the
  repository is starred. The lead advised against it: a check needs the user's GitHub sign-in, which
  breaks "no git sign-in" (success 1), host neutrality (R1) and decision 2026-11-09 (no credentials),
  and under MIT anyone can remove it. Instead the lead says one star line once per user, after the
  first task that opened a change request or merged a change, as the last line of the final message
  (references/pipeline.md, "Stage 8. Learn"), and remembers it in the empty file
  `~/.claude/prompt-to-ship/star-asked`. It never blocks, never checks, calls no network, and stays
  silent in this repository (`Upstream inbox: yes`); a fork without that line may show it once, an
  accepted limit. The line goes only into the chat, never into a commit, a change request or a file
  of the user. The line names only the plugin and its own
  address, so it is no new exception to the generic rule; users on any code host see it. No eval case
  reaches a change request, so the eval does not test it. Measuring point: the number of stars before
  2.34.0 and two releases later; a weak baseline, because stars have many causes.
- Decision 2026-11-13 (maintainer, second; words: "Rename the heading", "Argument diagram", "SVG
  file", "Trim wording"): verified diagrams (2.33.0), from a handoff after one session that needed
  five rounds to get a correct diagram. references/diagrams.md holds the method: a scope question
  first, then the lead exports the files of each area from the git refs and the host's read-only
  search agent reads that copy (at most 6 per diagram; not a reviewer, so a narrow step beyond R6, as
  project-map's optional agent), a swimlane overview, a zoom panel per service, a check list of five
  rules, and findings that start nothing. The argument `diagram` skips the BRIEF; plain words get a
  short BRIEF. Stage 2 offers a diagram once per plan when a flow changes, at normal or high risk
  only. The tool and the colours are each project's own PROJECT.md lines; without a tool, SVG files.
  The heading "Figma connector notes" in project-map.md became "Design file connector notes", so
  diagrams.md cites it without the product name and the exception of 2026-11-12 stays as it is. A thin
  baseline: the eval case reaches only the scope question; the dry run used a sample repository and
  SVG, not a design file. Measuring point: the next three diagrams record the rounds needed, the
  number of "not confirmed" boxes, and each finding that proved real; then reconsider this decision.
- Decision 2026-10-27 (maintainer): Phase A (coherence and load) before new features.

## Security context
The hook runs a fixed bash script on every prompt for every user. It must stay read-only and
offline: it prints fixed text and, from the local version cache, one line with checked numbers
only. It starts no program but grep, cat and at most one date. The reviewer agents have no shell. Reviewers must never execute project code.
The daily version check and the update fetch (references/update.md) run no credential helper and
add no credentials, to the fixed https address only; they never prompt and store or print no token.

## Learning
Incidents and rules: `.claude/orchestration/incidents.md` and `rules.md` (rules.md appears at the
first stage rule). See references/learning.md.
