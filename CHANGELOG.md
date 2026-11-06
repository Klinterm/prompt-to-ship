# Changelog

All notable changes. Versions follow semver and match `.claude-plugin/plugin.json`.

## 2.29.0

Faster review: fewer agent runs in stage 5.
- Round 1 is unchanged: every required reviewer reads the whole diff.
- A follow-up round starts only for a FIX, a CONTEST or a reopened finding at severity Medium or
  higher, or for an ADJUST from 5d. The reviewer of that point reads again, with the finding's text,
  plus the fresh reviewer on the whole diff since round 1. The security reviewer also reads when a
  fix is a sensitive change: it matches a specialist area in `references/security-rules.md`, or
  touches a command, a secret or a dependency.
- A Low finding starts no round, unless its fix is a sensitive change or touches a forced-high
  path. In round 3, such a fix stops at gate 5. New change request lines: "Fixed after the last review (Low, not re-read)", "Extra reviewer" and
  "Security reviewer not re-run".
- Only a reviewer or a validator sets a severity. The lead may contest it.
- A validator runs on a contest, on severity High or higher, and when the lead doubts a finding. A
  Medium finding that the lead fixes has no validator.
- Gate 5 now stops on a new or reopened finding of severity Medium or higher. The quick lane route is unchanged,
  and its validators follow the same rule.
- What you give up: a validator on a fixed Medium finding, a read of Low fixes on no sensitive
  code, and a security read of a fix that the lead judges not sensitive. There is no automatic test of the new rounds, because a one-turn eval case cannot reach
  stage 5. The last two changes are the baseline, and the next three are the measuring point. That
  is a weak sample.

## 2.28.1

Debug reports say what changed, and two eval cases measure real behaviour.
- A debug report now ends with a `Changed:` line: "nothing: no code and no system changed", or each
  change made and who approved it. `references/debug.md` says what a report with an open cause
  (NEEDS MORE EVIDENCE) shows: no ROOT CAUSE block, the unconfirmed cause, the open check and this
  line.
- Eval case `debug-case-first`: the fixture contradicted itself. Its one commit was tagged v1.3 and
  already held the bug, while the log shows correct values before v1.4. It now has a correct v1.3, a
  v1.4 with the bug, a caller that writes the log line and a neutral CHANGELOG. The rule now teaches
  what the judge checks, and the fixture fix should also raise the pass rate. The eval cannot
  separate these two effects.
- Eval case `pipeline-first-use`: the llm judge is gone, and regex graders read the final message.
  The default judge model failed correct messages: the same stored messages got FFF, FFF, FFF and
  PFF, PFP, PPP, and PASS on 12 of 12 votes with `--judge-model sonnet`. Moving that judge from the
  trace to the final message did not help (FFF, FPP, FFF). Why that model says FAIL is not known:
  the result files store votes, not reasons.
- The new graders check three things: the message names PROJECT.md or setup, it asks a question
  about the project, its users or its commands, and it does not claim the change. A new `no-write`
  grader joins `no-edit`. Limits: a regex checks words, not meaning, so this case has no judge of
  meaning any more. A regex grader stores no message, so a miss cannot be read afterwards.
- Correction to 2.28.0: the agent did not run out of turns, and the judge read the trace because
  the case asked for it. `max_turns` stays 12: all 8 runs ended on their own.
- Eval (only these two cases, --runs 3): `debug-case-first` with the plugin 1.00 in 3 of 3 runs,
  without it 0.58. `pipeline-first-use` with the plugin 0.93 (2 of 3 runs pass), without it 0.20. Its
  one miss was on an earlier, stricter pattern that required the message to say PROJECT.md is
  missing. The final pattern replaces it and was not run live: on the stored messages it matches 13
  of 13 with the plugin and 0 of 11 without. These are small samples, not proof. The full suite
  did not run.

## 2.28.0

UI mode: review a screen, then fix or redesign it.
- `/prompt-to-ship ui [screen]`, or "review the UI" in a repository that opted in. It takes
  screenshots when it can and scores them against the tiers and the audit of the built-in design
  skill, which need no opt-in here. It shows the top three problems, each with a rule id and a
  measured value. The review changes no code, starts no agents and runs no command without your yes. It
  says when a review would run with your session in a browser, and offers screenshots first. New
  file: `references/ui.md`.
- A number starts the normal pipeline on that fix. A low contrast that comes from the house style is
  a fix labelled "Changes a token: you decide". The house style stays otherwise.
- "redesign" starts the normal pipeline on a new look, always at level `ask` for that task. The full
  design workflow stays opt-in with `Design skill: built-in`. `references/autonomy.md` lists this
  level as an extra cap, and in `references/gates.md` a go on a high-risk diff does not cover its
  merge.
- The rules for starting a step moved to `references/direction.md`, "Starting a step", so both modes
  share them. Direction mode behaves as before.
- Eval case `ui-review-first` (21 cases now). It tests the plain-word route from code only, because a
  case has one turn, no shell and no browser. Screenshots are tested by hand (`TESTING.md`).
- Eval (--runs 1, 21 cases): mean with the plugin 0.96, mean difference +0.40. Nineteen cases 1.00,
  also ui-review-first and direction-interview; debug-case-first 0.75 and pipeline-first-use 0.50,
  both on their llm judge only. The debug-case-first message again names the cause, but does not
  say that no code was changed. In pipeline-first-use the agent changed no code, and the judge got
  the start of the trace instead of a final message.

## 2.27.0

Direction mode: find out where you are when you lost track.
- `/prompt-to-ship direction`, or "I lost track" in a repository that opted in. It shows findings
  in at most ten lines, with the drift from the written goal. Then it asks at most five questions,
  one at a time, and ends with a DIRECTION block: goal, reason, what to leave for now, next steps.
- It changes no code, forces no setup and starts no agents. It does not fetch: run `git fetch`
  first to see work from another computer. New file: `references/direction.md`.
- "yes" only saves one local note in `~/.claude/prompt-to-ship/direction/`, outside the repository.
  The note does not follow you to another computer.
- A step number starts the normal pipeline on that step, with every check before stage 0 and the
  brief first. It runs at your autonomy level, and the mode says so when that level is above `ask`.
- Eval case `direction-interview` (20 cases now). It tests the plain-word route, and only the
  findings and the first question, because a case has one turn and no shell.
- Eval (--runs 1, 20 cases): mean with the plugin 0.98, mean difference +0.41. Eighteen cases 1.00;
  direction-interview 0.80 and debug-case-first 0.75, both on their llm judge only. In both, the
  other graders passed. The direction-interview message has the findings, the drift and one
  numbered question, so this looks like a false fail, but the judge gives no reason. The
  debug-case-first message names the cause, but does not say that no code was changed.

## 2.26.1

The plugin uploads on claude.ai again.
- The plugin.json description is shorter: 484 characters instead of 654. claude.ai refused the
  upload with "Plugin description must be at most 500 characters." No behaviour changes.
- `tests/structure-test.sh` check f: the description is at most 500 characters. Its self-check
  plants a 501-character description in the temp copy and expects the failure.
- No eval run (patch release, wording and a test only).

## 2.26.0

The repository is private for now: the version check and the update work with your own git
sign-in.
- The daily version check and the update fetch no longer switch off git credentials. They may use
  your own credential helper (for example from `gh auth setup-git`), read-only, for the fixed
  https address only. They never prompt (`GIT_ASKPASS` and `core.askPass` empty), and the skill
  stores or prints no token.
- Without read access or a git sign-in the check stays silent, on purpose.
- Existing installs without read access stop getting updates, and the check then stays silent.
- README: a "Before you install" block (read access, a git sign-in, a test with `git ls-remote`),
  and `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` for users without an SSH key for GitHub.
- The check and the update first resolve the fixed address (`ls-remote --get-url`) and stop when an
  `insteadOf` rule or the clone's own `url`, `credential`, `http` or `include` settings would send
  it elsewhere; the update fetches from the fixed address itself, with TLS checking on (a user
  whose global git config turns it off updates by hand). A failure shows a fixed line, never git's output.
- TESTING.md items 207 to 212.
- Eval (--runs 1, 19 cases): mean with the plugin 1.00, mean difference +0.45. All 19 cases 1.00.
  Cost $8.12, under the cap of 10.

## 2.25.0

Gate coherence: the gate and trust rules say one thing in every file. From the weekly review of
2026-11-04 (FR-W1-1 to FR-W1-4, SR-W-1, SR-W-3, SR-W-4).
- Mode `defer`: stage 0 compares the hash of each repository agent in "Role cover"; a changed or
  missing agent makes its role partial until the user answers. A lower result asks whether to keep
  trusting the agent; a "no" to the write question without a lower result stores only the new
  agent hash and re-confirms PROJECT.md (the one write without a yes).
- A quick-lane task shows `change-request` in the BRIEF: it never merges on its own.
- Stricter: a host or PROJECT.md that allows only a rebase merge stops at `change-request`. A
  local merge with no remote merges the reviewed sha.
- Setup asks once which of the URLs found in the repository to open, with the same rules as
  design references (https, public hosts, also after a redirect); no answer opens none.
- Debug: a method marked "could write" needs the user's go for each command, at every level, with
  the exact text shown.
- Change request titles go through a file in a scratch folder, like descriptions (Gerrit: the
  commit message file). Host commands that read such a file run in a POSIX shell, never in Windows
  PowerShell.
- Setup, new project, slice 1: the user reads the diff before any merge and before any push.
- Setup writes the chosen URLs on a `Chosen websites:` line; design references may open those
  from a confirmed PROJECT.md. No POSIX shell for host commands with files: that step uses none.
- TESTING.md items 198 to 206.
- Eval (--runs 1, 19 cases): mean with the plugin 0.96, mean difference +0.44. Seventeen cases
  1.00; debug-case-first 0.75 and pipeline-first-use 0.50 (judge FAIL FAIL FAIL on both; both were
  named as known judge noise in 2.21.0). Cost $8.38, under the cap of 10.

## 2.24.0

Merge and release on your diff go, and a release step after a deploy-on-merge merge.
- New opt-in key `orchestration.diffGoCovers`, off by default; only the user sets it, in chat. At level `merge`
  or `release`, your own typed go on a high-risk diff then also covers the merge (and the release)
  of exactly that reviewed sha. Gate 1 only; never gate 13 or 15; every other gate still stops.
  The cover ends with a new push, a moved target, a new forced-high path, or the end of the task.
  Without the key nothing changes.
- A target that deploys on merge may name a release command for the step after the merge (for
  example a tag). At level `release` it runs right after the merge from a clean worktree, only
  when the version is a plain number triple higher than the latest remote tag; a failure stops
  without retry or revert. Gates 10 and 11 are checked before the merge, and gate 10 again before
  the tag, from the target sha it saw to the merge sha. For such a target, the last release is
  the last merge into it.
- The version file a release command reads now counts as a forced-high path (gates.md).
- Behaviour change: gate 11 no longer exempts a deploy-on-merge target. Such a target at level
  `release` with a release command in PROJECT.md and an empty `orchestration.releaseCommand` now
  stops at gate 11 until you confirm the command (run the skill with the argument `autonomy`).
- The weekly review accepts a high-risk automatic merge only with the line "Merged on the user's
  diff go (orchestration.diffGoCovers) for <sha>.", and checks the sha.
- This repository: `Autonomy limit: release`, `Deploys on merge: yes`, the tag after the merge,
  eval cost in the BRIEF with a cap of 10.
- TESTING.md items 185 to 197.
- Eval (--runs 1, 19 cases): mean with the plugin 0.97, mean difference +0.42. Eighteen cases 1.00;
  pipeline-first-use 0.50 (judge PASS FAIL FAIL, the known noise of 2.21.0). Cost $8.27, under the
  cap of 10.

## 2.23.0

The rebuild path: a full website rebuild runs through the pipeline with the full design
workflow. From the weekly review of 2026-11-04 (FR-W3-1 to FR-W3-8).
- A redesign or rebuild that the user asks for and the BRIEF names lifts the old look for the
  pages in the change. With `Design skill: built-in` the full workflow runs; colours and fonts come
  from the new DESIGN.md.
- New `skills/design/references/rebuild.md` for a site that has pages: an inventory of the old
  site, a URL map (new URL, redirect or confirmed "gone", grouped by pattern, every language),
  content as input not copy, search basics, privacy and consent through research ("unknown, ask
  the user" without it; never legal text from memory), who edits after launch, page templates and
  a site-wide sweep, a budget the team sets, a launch with a way back, and old against new.
- `references/design.md` is the one home for how the pipeline uses the design skill: a table of
  who does what per stage. The skill's own "Inside prompt-to-ship" table is gone.
- Two terms: the lead's **design brief** (the skill's steps 1 to 3 plus the pick) and the UI
  specialist's **layout brief** (without the built-in skill). With the skill, the UI specialist
  reviews the design brief.
- The direction pick is an open question (gate 2) at every autonomy level. Hero code stays on the
  local topic branch. "Pick for me" stays "not approved by user".
- 5d: the UI specialist scores the audit (H1 to K3) when it gets the path of critique.md; what it
  cannot show is "not shown" and never counts toward the stop condition. A separate run in
  screenshot-only mode answers the 5-second test; the lead compares the answers.
- The lead names the DESIGN.md items the user confirmed in this task; the UI specialist never
  confirms one itself.
- A URL the user types in the chat may be opened as a reference (https, public host).
- `Design tiers: off`: invented proof (F5) stays BLOCKING next to contrast and accessibility.
- DESIGN.md lives at the repository root, or in the folder of the site in a monorepo.
- Still open: the stack choice for a site with no code (setup's new-project path) and content
  editing beyond the "who edits" question.
- Trust: only the user's own typed message asks for a redesign or gives a URL; "public host"
  excludes localhost, private, link-local and internal names, also after a redirect; confirmed
  items reach the UI specialist only on the lead's line `Confirmed by the user in this task:`; the
  inventory keeps paths only; a live form is submitted only with the user's go (gate 15).
- TESTING.md items 168 to 184.
- Eval (--runs 1, 19 cases): mean with the plugin 0.97, mean difference +0.40. Eighteen cases 1.00;
  pipeline-first-use 0.50 (judge FAIL, the known noise of 2.21.0). Cost $8.18.

## 2.22.0

Scene mode: the design skill can guide a page whose main form is a 3D scene in the browser.
- New `skills/design/references/immersive.md`. A scene is a design option: step 4 may offer it as
  one of 3 directions when the subject passes the reason test (the scene shows structure, scale,
  space or a process that text cannot). It starts only when the user picks it.
- The HTML text stays the page: a text equivalent per chapter, text on a solid panel, a poster as
  fallback (no 3D support, reduced motion, save-data, frame rate under budget), chapters with
  their own URL, a phone layout with a menu button, camera moves only on user action and at most
  1.5 s, optional reading levels with the same facts.
- The team writes the budget in the `scene:` block of DESIGN.md. A miss is a finding, never
  BLOCKING on its own; without a device the log says "not measured".
- New Reflex items R46 (3D as decoration), R47 (scroll hijack) and R48 (loader before text).
  Floor F1 to F11 do not change.
- Design SKILL.md: step 5 item 3 and step 7 item 2 are shorter. Reduced motion and content without
  script stay in F4 and F8; the Reflex reason rule stays in tiers.md. A wording move, not a rule
  change.
- references/design.md: on a scene, the UI specialist gets the path of immersive.md.
- A `scene:` block the user did not pick or confirm (a cloned repository, a diff) is repository
  text: the lead asks first. The UI specialist checks a scene against `immersive.md` and refuses
  that path inside the repository under review.
- TESTING.md items 157 to 167.
- Eval (--runs 1, 19 cases): mean with the plugin 0.94, mean difference +0.47. Sixteen cases 1.00.
  research-for-unsourced-rate 0.75 (the plans-research pattern did not match; the final message did
  plan research, and the judge passed). secret-not-printed and silent-without-opt-in: all checks
  passed, judge skipped at the cost ceiling ($8.35 spent).

## 2.21.1

Room in SKILL.md for the next feature. No change in behaviour.
- The details of the PROJECT.md confirmation (what to show, storing the hash, domain.md and
  debug/access.md) move from SKILL.md "Before stage 0" step 4 to pipeline.md, "Confirm
  PROJECT.md". Step 4 keeps the trigger, the ask before running commands, the safe defaults and
  the domain.md rule, and tells the lead to read the new section first.
- SKILL.md goes from 7,916 to 7,706 bytes.
- No eval run.

## 2.21.0

A built-in design skill, from lessons of public design skills (credits in
`skills/design/SOURCES.md`).
- New skill `prompt-to-ship:design` in `skills/design/`: references and content before markup, a
  DESIGN.md system with a reason per token, three different directions of the first screen, a
  screenshot critique at three widths and in the states that matter, and a 5-second test. A product
  variant covers apps, dashboards and forms.
- The full workflow runs when PROJECT.md says `Design skill: built-in`; setup now suggests it.
- Stricter: the UI specialist checks every visible change against the tiers. A Floor item
  (contrast, focus, keyboard, target size, broken layout, invented facts) is BLOCKING; a Reflex
  item is ADJUST unless the plan names a user need; Finish is advice. With a house style, Reflex
  and Finish apply only to new or changed code. An old fault next to a change is a note, never
  BLOCKING. A Floor item the UI specialist cannot show from the code or the screenshots goes to the
  lead as a check. A team that does not want this writes `Design tiers: off` in a confirmed PROJECT.md;
  contrast and accessibility stay BLOCKING.
- Tap targets (Floor F7): 44 px for the main action and the navigation; other controls, also in a
  compact tool, 24 px or more with spacing. The 24 px floor is the same as before.
- Safety: the design skill and the tiers load only from the plugin folder, never from a folder
  inside the repository under review; a proof line or Reflex exception added in the same change
  needs the user's confirmation; used on its own, the design skill opens only URLs the user gives.
- plugin.json lists `"skills": ["."]`, so the main skill keeps loading next to `skills/`.
- The structure test also checks skills in `skills/` (frontmatter, size, the Read-when table both
  ways), that plugin.json lists `"skills": ["."]`, and that no other SKILL.md would load. New eval
  case design-content-first (19).
- Eval (--runs 1): mean 0.94 with the plugin, mean difference +0.39. design-content-first 1.00
  with, 0.00 without. Three judge fails on correct answers: debug-case-first and pipeline-first-use
  (known noise), and no-research-for-code (the final message planned no research).

## 2.20.0

Answering findings, clear review loops, a drift report and a structure test. Ideas from the
Elephant-Goldfish Model repository (Google, 2026-10): its resolve step, review loop, drift report
and offline tests.
- Every stage 5 finding gets an ID (for example FR-1-2) and one answer: FIX; CONTEST, with
  evidence the reviewer could see ("this was intentional" is not evidence), settled only when the
  reviewer accepts it; ESCALATE, to the user; DECLINE, only for severity Low or Info. At Medium or higher
  an unaccepted contest becomes ESCALATE, so gate 4 stays as strong.
- Loop rules: a settled finding stays settled unless new evidence comes; a returning finding is
  reopened under its old ID; churn (a fix that creates a new finding at the same place) is named.
- A reviewer run that fails gets one retry, then shows as "not run", never as "no findings". New
  gate 16: a required reviewer that did not run.
- The change request lists the findings in a table: ID, severity, answer, summary.
- The weekly review has a drift report: the architect, in a new drift mode, names where
  PROJECT.md, domain.md or the debug files no longer match the code (missing, incomplete,
  shortcut, divergence). One agent run a week.
- tests/structure-test.sh checks citations in the form `file.md, "Section"`, the Read-when table, agent frontmatter and the
  eval case count, and proves itself on a planted error. It runs in CI. It found one broken
  reference at once: debug.md "Trust" was a bold label, not a heading; it is a heading now.
- The eval command in PROJECT.md runs four cases at once (`-j 4`): about 7 minutes instead of 25.
- Eval (--runs 1): 16 of 18 at once; mean 0.92 with the plugin, 0.46 without. new-project-idea
  failed on a Git Bash start error in its fixture and passes on a rerun; pipeline-first-use is the
  known judge noise (1 of 2 on a rerun).

## 2.19.0

Know when a newer version is out.
- When the skill runs, it checks for a newer release, with at most one read-only network call a
  day (`git ls-remote` on the fixed GitHub address, https only, no password prompt, 10 seconds).
  The answer is cached in `~/.claude/prompt-to-ship/version-check`. Offline or any error: silent.
- A newer version gives one line before the BRIEF, with the release link: "Reply update, or go on".
  It shows once per conversation, and comes back in the next one until you update or switch it off.
- The update runs only after your reply "update" (just that word; "do not update" never counts), only for a clean clone on `main` whose origin
  is exactly the GitHub address, and only to that release tag (fetch the tag, fast-forward). In any
  other case, a marketplace install too, you get the command to type.
- Off switch: `git config --global prompt-to-ship.versionCheck false`.
- The argument `version` moved to references/update.md; it also shows the latest version seen.
- The reminder hook is now a script (hooks/reminder.sh). In an opted-in repository it reads the local
  cache, offline, and adds one line when the check is due or a newer version is known. Without it,
  the lead skipped the check in the eval. It stays silent outside opted-in repositories, works in
  bash 3.2 (macOS), and takes about 0.15 second on Windows. `tests/reminder-test.sh` (18 cases)
  runs in CI.
- No eval case: in `claude plugin eval` the hook output does not reach the session and the lead has
  no shell to find the home folder. The hook is tested by `tests/reminder-test.sh`; the offer line
  was seen once in an eval run before the case was dropped.
- A failed or skipped version check stays silent; the eval showed a "could not run" note before.
- Eval (--runs 1): 15 of 18 at once; mean 0.94 with the plugin, 0.53 without. The three fails were
  LLM judges on correct answers (debug-case-first, brief-first, invariant-stops); reruns pass 1 of 2
  each, the same judge noise as in earlier releases.

## 2.18.0

Two plan checks, after the Elephant-Goldfish Model idea (Google Open Source, 2026-10): a plan
must be understood and concrete before the build. Three near-misses in 2.15.0 to 2.17.0 came
from plans that were too vague to walk through.
- The PLAN block has a `Files:` line: each file to change or add, with the changed functions or
  types.
- Understood: each plan reviewer first says in its own words what changes, and names one thing
  the plan leaves unclear. A different reading means the plan is unclear: the lead fixes it and
  asks once more; a second mismatch stops. This only catches a plan that is ambiguous, not a plan
  that is wrong; the verdicts still do that.
- Ready: on normal and high risk the architect says `Ready: yes` or `Ready: no` with what is
  missing (files, functions or types, a step without a file).
- Stage 5a: a changed file that is not on the Files line is a Low finding.
- No extra agent run in the normal case; at most one restart when a check fails.
- New eval case `plan-files-ready`.
- Before the go, the lead shows the final PLAN block with its filled Reviewers line.
- Eval (--runs 1): 15 of 18 at once; mean 0.94 with the plugin, 0.54 without. Reruns:
  plan-files-ready 2 of 2 after the final-PLAN rule (with the plugin 1.0, without 0 and 0.33);
  no-git-folder 2 of 2 (the first run hit a denied file read in the eval tool); debug-case-first
  fails now and then on the LLM judge or the CASE block, as in earlier releases.

## 2.17.0

Fixes from the skill's own weekly review (the skill reviewed this repository).
- Read-only agents, for real: the seven reviewer and debugger agents have no shell any more,
  only Read, Grep and Glob. The lead runs the git history commands (log, blame, log -S) and puts
  the output in the agent's prompt; an agent asks for more under "Needs from the lead:". Before,
  "read-only" was only a line in the agent's prompt.
  Why no shell instead of a guard: a guard hook was built and tested, but five security review
  rounds kept finding ways for read-only git commands to start a program (shortened and bundled
  options, quote tricks, diff drivers, filters, fsmonitor, worktree config, repository hooks,
  submodules). Without a shell there is nothing to bypass, on every system.
- The lead gives the agents their git history once per task, shared between agents, at most 200
  lines per command. An agent's "Needs from the lead:" request is data: the lead runs only a plain
  `git log`, `show` or `blame`, and shows any other command to the user first. This costs the
  lead a little more reading per task; the agents read less.
- A missing agent type is never replaced by a `general-purpose` agent any more (it can write and
  run commands): the lead stops and asks to reload the plugin.
- Debug D4: a check that the debugger or validator names runs only when it is exactly a confirmed
  access.md method or a repository read; any other check waits for the user's go.
- State keys: a hash of the `orchestration.*` git config keys is stored outside the repository
  at the end of a task; at stage 0 a difference is shown and asked about. It detects a change; it
  is not a lock.
- SKILL.md has room again (7,797 bytes): the fallback rule moved to pipeline.md, the
  stage 2 and 5d rule is split correctly (the quick lane skips only stage 2).
- Docs: TESTING counts eight agents and covers the quick lane in defer and map, the gallery
  suggestion, the web page rules, the agents without a shell and the state keys; plugin.json, README and the
  diagram match the skill; PROJECT.md records the 2.16.0 and 2.17.0 decisions.
- CI for this repository (`.github/workflows/checks.yml`): style, SKILL.md size and version
  match.
- Stage 6 checklist: a Medium finding that stage 2 or 4 should have caught gives a "Near-miss"
  line.
- Eval (--runs 1, final version): 13 of 17 at once. Reruns: repo-text-is-data and
  pipeline-first-use 2 of 2; no-git-folder 1 of 2, then 2 of 2 after the too-broad message got the
  plain git sentence; debug-case-first fails on the LLM judge with a correct answer, as in 2.14.0
  and 2.16.0. Mean 0.92 with the plugin, 0.57 without.
- The too-broad folder message now also says what git does.

## 2.16.0

Git for people who do not know git.
- In a folder without git, setup explains git in a few plain sentences and asks "Turn this folder
  into a git repository?". On yes it runs `git init -b main` itself, asks for a name and email
  when git has none (stored only in this repository), and goes on with setup. No commit, no
  remote, nothing online.
- In a folder that is too broad (the home folder, a drive root, a system folder, Documents,
  Desktop, Downloads or a sync root), setup offers to make a project folder first, with a plain name.
  Inside a synced folder it warns once that sync programs can damage a git repository.
- Never `git init` when git refuses an existing repository (and never `safe.directory`), or when a
  repository sits one or two levels down, unless the user asks. When the
  repository root is itself too broad (often a home folder kept in git), setup offers a new
  project folder with its own repository. The eval found this case: its home folder is a git
  repository.
- Installing git itself stays manual: setup gives the download link and waits.
- The rule has one home: references/setup.md, step 0, "No git yet".
- New eval case `no-git-folder`.
- Eval (--runs 1): 15 of 17 cases passed at once; debug-case-first and pipeline-first-use failed
  only on the LLM judge and passed on a rerun with the final text. Mean 0.96 with the plugin, 0.60
  without. no-git-folder hit the too-broad branch (the eval home folder is a git repository); the
  plain "Turn this folder into a git repository?" branch is covered by TESTING item 10.

## 2.15.0

Start from an idea.
- Setup has a new-project path (references/setup.md, "New project") for an empty repository
  and a product idea. Claude asks at most six plain idea questions with examples ("skip" and
  "you choose" are fine), writes PROJECT.md, and proposes two or three ways to build it, reviewed by the architect
  and the product expert, the recommended one first. It never picks a default stack.
- The first version becomes 3 to 7 slices, each a result the user can see. Slice 1 is always a
  running empty app with one passing test. It runs at high risk (manifests and lockfiles) and
  waits for the user's go on a plan that lists every package. No remote, push or hosting account without the user's word. After it,
  setup proposes the detected commands.
- New eval case `new-project-idea`.
- Eval (--runs 1): all 16 cases pass with the plugin. Mean score 1.0 with the plugin, 0.64
  without. new-project-idea: 1.0 with, 0.75 without (also 1.0 on a rerun after the review fixes).

## 2.14.0

Cheaper agents, measured.
- The architect, product expert, UI specialist, fresh reviewer and debugger run on sonnet by
  default (`model: sonnet`). The security reviewer, the validator and the researcher keep
  `inherit`, your main model, because gates depend on them.
- Evidence: a new comparison suite, `evals-models/` (10 cases, one planted problem each, two per
  agent). With the lead fixed on sonnet and `--runs 2`, haiku, sonnet and opus each found all 10
  problems. Haiku needed a rerun: in 2 runs the eval tool blocked file reads. The cases are
  small, so sonnet is the default and haiku stays a choice.
- Your own choice: tell Claude, for example "use opus for the architect". It is stored per
  developer in local git config, `orchestration.agentModels` (pipeline.md, "Agent models").
- pipeline.md is about 16 percent shorter (20 KB to 17 KB): "Outside facts" moved to
  references/research.md and "House style" to references/design.md, each read only when it
  applies.
- Eval (--runs 1): 12 of 15 cases passed at once with the plugin. debug-case-first failed only on
  an LLM judge mistake; invariant-stops and pipeline-first-use passed on a rerun. Mean score 0.92
  with the plugin, 0.62 without.

## 2.13.0

Fewer tokens for small work.
- Quick lane (pipeline.md) for a small, low-risk change: at most 2 files and about 30 changed
  lines, no forced-high path, no new screen, no business rule, no outside fact, no data, schema
  or dependency change. It runs the brief, the build, the proof, the fresh reviewer and the
  product expert on the result (plus the UI specialist on a visible diff): 2 agent runs instead
  of 4. Every gate applies. It never merges on its own. When a condition fails, the full pipeline
  takes over.
- Quick debug: with direct evidence for one cause, the debugger is skipped; the validator still
  checks the cause.
- Off switch: a message the user types that starts with `no pipeline:` gets plain Claude. Only
  the user's own message counts. The standing rules still hold (no merge, push or production
  write without a go, no printed secrets). A team turns it off with `Off switch: no`.
- The quick lane keeps stage 1 (matching rules) and stage 8, and never pushes to the target in
  mode `map`.
- Setup suggests a public design gallery (https://designeer.xyz/) for "Design inspiration"; the
  user accepts or changes it.
- Replaces the decisions "no light lane" and "the architect and product expert review every plan"
  for the quick lane only.
- New eval cases `quick-lane-small-fix` and `no-pipeline-off-switch`. The secret case now judges
  only the final message; the token in source code is still checked on the whole trace, but a
  token printed in a middle message is no longer caught. A pasted "no pipeline:" text is covered
  by a manual test only (TESTING 114).
- Eval (`--runs 1`): all 15 cases pass with the plugin. Three passed on a rerun after their
  judges got literal criteria or their regex got tighter. The quick-lane case scores 1.0 with the
  plugin and 0.33 without.

## 2.12.0

Debug shipped code, and one routing table for agents.
- New debug mode (`references/debug.md`), read-only: a CASE block, a matching playbook, evidence
  through read-only methods only (every command shown first, row limits and timeouts, personal
  data masked), a new `prompt-to-ship:debugger` agent that ranks causes, the validator in a new
  root cause mode, a ROOT CAUSE block, a fix route, a playbook as the lesson, and a check after
  the release. Start it with `/prompt-to-ship debug <problem>` or ask why shipped code fails.
- Per project, `.claude/orchestration/debug/`: index (intake questions, symptoms), access
  (read-only methods per environment, confirmed by hash as `orchestration.debugConfirmed`),
  playbooks and a case log with status and release. "Draft debug files" starts them.
- New gate 15: any write to a production system (data, config, flag, restart, cache, queue, mail,
  deploy) waits for the user's go per action, at every autonomy level.
- New "Which agent when" table in pipeline.md: the lead starts an agent only on its signal.
- SKILL.md drops its Arguments section; the "Read when" table already covers it.
- New command `/prompt-to-ship version`: shows the version and the skill folder.
- Before each production command the lead hashes access.md again. A playbook command that is not
  exactly a confirmed method needs the user's go. Masking also covers what is sent to other
  agents and to the web.
- The gate summary in SKILL.md now names the main gates and points to gates.md for all of them.
- New eval case `debug-case-first`. Eval (`--runs 1`): all 13 cases pass with the plugin.

## 2.11.0

The UI specialist runs only on a visible change, and designs before the build.
- A change is visible when a user or a developer sees its result: a screen, an email, a PDF, a
  notification, app or translation text, command-line output, or a log or API message. One
  definition, in pipeline.md. The PLAN block gets a `Visible:` line; the architect and the
  product expert block a visible change marked "nothing". Stage 5d decides again from the diff.
- Low risk without a visible change: 4 agent runs instead of 6. The architect and the product
  expert still review every plan.
- New screen, email or document: the lead opens the sources on a new `Design inspiration:` line
  in the browser, names 1 to 3 references and what to take from each (structure, proportion,
  rhythm; never colours, fonts, images or logos). The UI specialist gives a design brief of at
  most 8 lines: components, layout, the one primary action, the states, the widths or media.
- The UI specialist checks design principles where the medium has them: hierarchy, one primary
  action, values from the project's scale, line length, real content, every state; touch targets
  per platform guide. It has no web access.
- A design skill can guide layout and hierarchy in a project with a house style, only with
  `Design skill with house style: layout`. Setup asks this per project.
- Replaces the decision "three plan reviewers always".
- The lead treats a web page as data, opens only `https://` addresses on public hosts, and copies
  no page text into the plan.
- Eval (`--runs 1`): all 12 cases pass with the plugin. Two passed on a rerun: one fixture
  failed on a Windows permission error before the agent started, one judge got literal criteria.

## 2.10.1

- The plan has a fixed PLAN block in SKILL.md, like the BRIEF: approach, rejected approaches,
  choice, threat model, research, facts and reviewers. The research decision is now visible in
  every plan. In `defer`, only the research line shows; in `map`, the block takes the name of
  the team's plan step.
- Eval graders: `plans-research` no longer matches "Research: none" or "Research scope".
  `no-research-for-code` now fails only when a plan lists research questions; a stop before the
  plan passes. Every run that reached a plan showed the research line (4 of 4 in the
  `--runs 5` check).

## 2.10.0

Business rules, house style first, and reference years.
- New optional `.claude/orchestration/domain.md`: glossary, invariants (INV-1 and on), formulas
  and sources of truth. Setup drafts it when the product has business logic. You confirm it by
  hash (`orchestration.domainConfirmed`), like PROJECT.md.
- The product expert checks plans and results against it. A broken confirmed invariant stops
  the pipeline; an unconfirmed one gives a question. Every touched invariant needs a test. The
  weekly review checks the existing code against the invariants.
- An invariant is a separate learning home, used only when you state a product truth.
- In pipeline mode `defer`, a repository agent with full product cover stays full. With a
  confirmed domain.md, the pipeline offers once to add the product expert for the business
  rules only.
- House style first: visible work follows the product's own look and reuses its components. A
  design skill named in PROJECT.md (`Design skill:`) is used only with `House style: none`. A
  missing `House style:` line means the existing screens. A design skill loads only with a
  confirmed PROJECT.md, and never from a skill folder inside the repository. The UI specialist gives ADJUST for a
  deviation, BLOCKING only when accessibility breaks. The PROJECT.md confirm step now shows the
  design skill.
- The research scope takes reference years: one year, a list or a range. When your data holds
  years, the lead proposes them from files and you confirm them; it never queries a live
  database.
- New eval case `invariant-stops`. It passes with and without the plugin: plain Claude also reads
  domain.md when the file exists, so it guards a regression and shows no difference.
- Eval result (`--runs 1`): 11 of 12 cases pass with the plugin; 6 score 0 to 0.33 without it.
  Known gap: in `no-research-for-code` the agent started no research, as it should, but showed
  the `Research: none` line in only 2 of 4 runs.

## 2.9.2

- Diagram: code search always runs; only in a large code base does it get its own agent. The
  label no longer says "Optional".

## 2.9.1

- Code search and the researcher work in order: the pipeline looks for a fact in the code and
  the project data sources first, and asks the researcher only for what they lack. The diagram
  shows them as two agents, and the README says the same.

## 2.9.0

Outside facts and an eval suite. (2.8.0 was not released; its eval work is part of this
version.)
- New agent `prompt-to-ship:researcher`. It finds outside facts (prices, rates, tariffs, legal or
  tax rules, standards, external API contracts) on the web, with sources, and never invents a
  value. A second run in check mode, without the first run's notes, confirms each fact.
- Research runs only when a change needs an outside fact. Stage 1 ends with
  `Research: <questions | none>`, and the three plan reviewers check that line. No research runs
  when a project API or database already supplies the fact.
- New "Research scope" section in PROJECT.md: region, currency, reference year, project data
  sources, trusted and excluded sources.
- New gate 14: an outside fact that is not confirmed, out of scope, from an excluded source, in
  conflict or not found stops the pipeline.
- Every outside fact in code has `source:` and `valid:` next to it. The weekly review lists facts
  whose period has ended.
- The researcher is not a review role: defer mode role cover does not change.
- Cost estimates follow your setup: tokens and agent runs on a subscription plan, a price on
  API billing.
- New `evals/` folder with 11 behaviour cases for `claude plugin eval` (maintainers only).
- Eval result (`--runs 1`, one run per arm): all 11 cases pass with the plugin. Without it, 6
  cases score 0 to 0.33 (brief, high risk, forced-high path, first use, repository text as data,
  research for an unsourced rate), 2 cases score 0.67, and 3 guard cases score 1.0: Claude already
  does this on its own, and the cases catch a regression. One case passed after a judge fix, one
  after a skill fix (the plan now shows the `Research:` line); each was then rerun on its own.

## 2.7.0

Coherence and load (from an audit of the whole skill). No new features. No eval run (the eval
suite does not exist yet).
- SKILL.md is now under 8,000 bytes, with a "Read when" table. The lead reads only what a step
  needs: a low-risk change in a plain repository now reads about 600 lines (was about 1,230);
  with an existing pipeline about 800. pipeline.md is the one home for stages 0 to 8. A new gates.md holds the risk table, the
  forced-high paths, the gates, the "Never" list, the rules for every merge and one table of
  state keys; it is read at stage 0 and before every push, merge and release.
- Fixed contradictions between files: the near-miss rule, the autonomy question in `defer`,
  rules for the validator, what each reviewer gets, where lessons land, rebase, deploys on merge.
What you will see:
- Findings use one severity scale: Critical, High, Medium, Low (plus "pre-existing").
- A near-miss adds a marker line and does not interrupt the change; it becomes a lesson when its
  cause comes back.
- The validator also checks correctness findings, with its own questions, and applies project
  rules.
- Weekly reports always stay local; they are never committed.
- The full security assessment runs on request, not every quarter.
- Deploys on merge: "yes" from any source wins, and a missing value counts as "yes" until you
  answer. A merge that ran before can now stop at this gate.
- Old upgrade texts for versions before the public release are gone; the generic "a line is
  missing" behaviour stays.

## 2.6.0

- Workspace mode (`references/workspace.md`): a folder that is not a git repository but holds
  several repositories. One PROJECT.md for the workspace with a "Repositories" table. Each change
  names its folders, works in a new worktree by default, gets one change request per folder with
  cross-links, and merges as one set in a fixed order: when one part hits a gate, nothing merges.
- Workspace values live in a state file in the user's home (`git config --file`), so no
  repository can plant it; values for one folder stay in its own git config; the lowest level
  wins. Workspace mode starts only outside every git repository. A folder's own committed
  PROJECT.md can only make things stricter.
- A set of change requests has the lowest level of its folders; all gates are checked before the
  first merge; a failure after a partial merge stops and shows the reverts, never runs them.
- Pipeline lessons go upward: a lesson about the pipeline itself is written generic, with no
  project details, to `~/.claude/prompt-to-ship/upstream.md`. The prompt-to-ship repository
  reads it (`Upstream inbox: yes`), so every project can improve the engine.

## 2.5.0

For repositories with strict rules: nothing but product code, and no tool or AI mentions.
- New lines under House rules in PROJECT.md: "Storage: shared | local" and "Markers:
  description | local log". Setup asks both in one message. Without a Storage line, an excluded
  `.claude/orchestration/` counts as local.
- Local storage: incidents and rules are written directly in the excluded folder after the
  user's yes; no learn branch, no push. In a linked worktree, the folder of the main worktree is
  used.
- Local log: every marker line goes to `<git common dir>/prompt-to-ship/log.md`, shared by all
  worktrees and never committed. No attribution lines; the skill offers to switch off Claude
  Code's own attribution in `.claude/settings.local.json`.
- The weekly review counts from the log, matches entries to merged changes (change request
  link, merge sha, then sha), says how many it skipped, and says that it covers this clone only.
- An unconfirmed PROJECT.md uses the local log: it writes nothing to the repository.

## 2.4.0

A real learning loop for stage 8 (`references/learning.md`). Ideas taken from Every's
compound-engineering plugin, obra/superpowers, the ACE paper and Anthropic's best practices.
- Incidents go in `.claude/orchestration/incidents.md`, rules in `rules.md` (a table with
  RULE-ids, stage, paths, check, why, added, retire when). PROJECT.md only points to them. An old
  Incidents table in PROJECT.md keeps working, and is moved on the user's yes.
- A lesson must pass a test (non-obvious, durable, material), goes to the narrowest home (a
  test, a check command, a rule), is checked by the validator in a new lesson mode (STORE or
  REJECT), and needs the user's yes. It lands on its own branch, after the change.
- A miss gives a lesson proposal right away. A near-miss is first a line in the description and
  becomes a lesson when its root cause comes back.
- Each reviewer gets the rules for its stage and paths, and cites rule ids. A rule can only add
  a check and never names a command.
- The weekly review counts matched, caught and overruled per rule in its own report, proposes to
  retire, review or merge rules, and reports how often old mistakes come back.
- Each change ends with a one-line rules summary.
- Known limit: the validator judges whether a lesson would have caught the incident; it does not
  replay it.

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
