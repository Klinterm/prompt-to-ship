# Changelog

All notable changes. Versions follow semver and match `.claude-plugin/plugin.json`.

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
