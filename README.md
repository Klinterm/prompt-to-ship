# prompt-to-ship

A pipeline for coding with Claude Code. A pipeline is a fixed series of steps that every change
goes through. You ask for a change in plain words. Claude turns it into a precise task and makes
a plan. Three reviewer agents check the plan. An agent is a separate Claude instance with one
task and no access to your chat. Claude then builds the change and proves that it works. Other
agents review the result. At the end, Claude opens a pull request or merge request: a request to
add the change to the main code. You decide what gets merged and released.

**For whom:** developers who use Claude Code and want changes that are planned, tested and
reviewed before they reach the main code.

**Status:** a working prototype. The acceptance test in [TESTING.md](TESTING.md) is not complete
yet. The current version and its changes are in [CHANGELOG.md](CHANGELOG.md).

It works in any git repository and in any programming language. See [Code hosts](#code-hosts)
for GitHub, GitLab and others.

## How it works

<p align="center">
  <img src="docs/pipeline.svg" width="760" alt="The pipeline. You ask for a change. A hook reminds Claude of every step. Step 0: brief, waits on high risk or an open question. Step 1: understand, with an optional search agent in a large code base. Step 2: plan, checked by the architect, the UI specialist if there is a user interface, and the product expert. The plan with three verdicts waits for your go on normal and high risk. Steps 3 and 4: build and prove. Step 5: review by a fresh reviewer, a security reviewer on normal and high risk, one validator per serious finding, and the UI and product reviewers. Step 6: pull or merge request, you decide about the merge. Step 7: merge and measure, your word each time. Step 8: learn.">
</p>

The diagram shows the default level, `ask`. At a higher level, some red "waits for you" boxes
go away. See [Autonomy](#autonomy).

## The steps

0. **Brief.** Claude reads the code and the documents first. Then it writes your request as a
   task of at most ten lines. The task gives the goal, the reason, the limits and the risk. It
   also says how to prove that the work is done. On high risk or an open question, Claude stops
   and asks you.
1. **Understand.** Claude reads the code that takes part, and the git history that explains it.
   In a large code base, a search agent does the wide search.
2. **Plan.** Claude chooses an approach and names its risks. Three reviewer agents check the plan
   at the same time. Each one gives a verdict: approve, or adjust with reasons.
   - The **architect** checks the structure, the data and whether the change can be undone.
   - The **UI specialist** checks what users will see and read. It is skipped when the product
     has no user interface.
   - The **product expert** checks whether the change fits the product and its users.
3. **Build.** Claude works on its own branch. A branch is a separate copy of the code where work
   happens before it joins the main code. Claude writes a failing test first when it can.
4. **Prove.** Claude runs the build and the tests and shows the real output. A claim without
   output does not count.
5. **Review.** More checks, each by an agent that did not write the code:
   - The **fresh reviewer** sees only the change and the brief, and looks for bugs.
   - The **security reviewer** looks for real vulnerabilities, with evidence. It runs on normal
     and high risk.
   - A **validator** tries to disprove each serious finding. False alarms drop out this way.
   - The **UI specialist** and the **product expert** check the result against the plan.

   Every finding gets an answer: fixed, or not fixed with a reason. After three rounds, Claude
   stops and asks you to rethink the approach.
6. **Pull or merge request.** The description always has three parts: what was tested, the risk,
   and how to revert the change.
7. **Merge and measure.** After the release, Claude checks that the goal from the brief is met.
8. **Learn.** When a mistake gets through, or a late review catches what an earlier step should
   have caught, Claude logs it. If the lesson is worth keeping, Claude puts it in the narrowest
   place: a test, a check command, or a rule for one step. You confirm each one. The weekly
   review shows which rules still catch problems and proposes to retire the rest. See
   [How it learns](#how-it-learns).

Each reviewer agent gets only the brief, the plan and the files. It never sees the chat. This
keeps its view fresh.

Once a week, the `weekly` command reviews the pull or merge requests of the last 7 days. It
only reads and changes nothing.

## Autonomy

The first time the skill loads in a repository, it asks how far it may go on its own. You can
change your answer at any time.

<p align="center">
  <img src="docs/autonomy.svg" width="760" alt="Autonomy levels. ask: you approve plans with normal or high risk, you merge and release. change-request: no wait for the plan, you merge and release. merge: Claude merges when every check passes, you release. release: Claude merges and releases when every check passes. At every level, high-risk changes wait for you before anything is pushed.">
</p>

At every level, Claude stops and waits for you in these cases:

- The risk is high.
- The change touches CI, build, dependency, migration, access, secret or agent setup files. CI
  (continuous integration) is the automatic build and test that your host runs. The full list of
  files is in [references/gates.md](references/gates.md).
- The brief has an open question, or a reviewer marks a point as blocking.
- A finding is not fixed, or a test or CI run fails.
- The merge has a conflict, or the branch protection on your host refuses it.
- A check fails after a release. Claude then proposes a revert, but does not run it.

Claude never approves its own pull or merge request. It never bypasses branch protection.

Does your main branch deploy as soon as something lands on it? Then a merge is a release. Setup
notes this, and only level `release` lets Claude merge there.

Claude stores your level in the git config of your own copy of the repository
(`orchestration.autonomy`). Git never commits this setting, so a repository you download cannot
raise your level. A team can set a maximum for everyone with "Autonomy limit" in its project
file.

## Code hosts

| Host | What works |
|---|---|
| GitHub (`gh`), GitLab (`glab`) | everything, including the automatic merge |
| Azure DevOps (`az`), Gitea and Forgejo (`tea`) | everything. Azure needs the `azure-devops` extension. |
| Bitbucket | pull requests by hand: Claude gives you the link. No automatic merge. |
| Gerrit | changes for review. No automatic merge, because a merge needs a +2 from another person. |
| Plain git, no host | work stays on a local branch. Claude gives you the commands to review it. |

Without the command-line tool of your host, or when it is not signed in, Claude works as with
plain git and tells you how to sign in.

## Requirements

- [Claude Code](https://code.claude.com).
- A git repository.
- Optional: the command-line tool of your host, signed in. See [Code hosts](#code-hosts).
- Windows: Git for Windows. Claude Code runs hooks in Git Bash. A hook is a small command that
  Claude Code runs on each message. Without Git Bash the hook stays silent, and the skill still
  works.

## Install

Choose one of the two ways. Did you use the earlier name `optimal-coding-orchestration`? Remove
that version first.

**A. As a plugin**

1. In Claude Code, run `/plugin marketplace add Klinterm/prompt-to-ship`.
2. Run `/plugin install prompt-to-ship@prompt-to-ship`.
3. Start a new session. The command is `/prompt-to-ship:prompt-to-ship`.

**B. As a skills folder**

1. Clone the repository into your skills folder:

   ```bash
   git clone https://github.com/Klinterm/prompt-to-ship ~/.claude/skills/prompt-to-ship
   ```

   On Windows the folder is `%USERPROFILE%\.claude\skills\prompt-to-ship`.
2. Start a new session. The command is `/prompt-to-ship`. The agents appear as
   `prompt-to-ship:architect` and so on.

To share it with a team, copy the folder into the repository's `.claude/skills/` folder and
commit it. Do not copy the `.git` folder inside it. Each teammate accepts the workspace trust
prompt once.

## Commands

Type these in the Claude Code chat. With install way B (skills folder) the command is
`/prompt-to-ship`. With way A (plugin) it is `/prompt-to-ship:prompt-to-ship`.

| Way B (skills folder) | Way A (plugin) | What it does |
|---|---|---|
| `/prompt-to-ship setup` | `/prompt-to-ship:prompt-to-ship setup` | Gets to know the repository and writes `.claude/orchestration/PROJECT.md`. Asks the pipeline mode and your autonomy level. |
| `/prompt-to-ship autonomy` | `/prompt-to-ship:prompt-to-ship autonomy` | Shows your autonomy level and lets you change it. |
| `/prompt-to-ship weekly` | `/prompt-to-ship:prompt-to-ship weekly` | Reviews the pull or merge requests of the last 7 days. Changes nothing. |
| `/prompt-to-ship <your request>` | `/prompt-to-ship:prompt-to-ship <your request>` | Runs the pipeline on your request. |

After setup you do not need the command for a change. Ask in plain words, for example "Fix the
date format on the invoice page". The hook reminds Claude to use the pipeline.

You can also say these things in the chat:

| You say | What happens |
|---|---|
| "go" | Claude continues after a stop, for example after the plan. |
| "stop" | Claude stops the current task. |
| "do this one manually" | Claude uses level `ask` for this task only. |
| "revert" | After a failed check following a release, Claude runs the revert it proposed. |

Commands for install, update and removal are in [Install](#install) and
[Update and remove](#update-and-remove).

## Use

1. Start Claude Code in the root folder of your repository.
2. Run `/prompt-to-ship setup` (see [Commands](#commands)). The first use does this
   automatically. Claude reads the code,
   the build files, the documents and the public website. It finds the git host. Then it asks
   you up to seven questions about the goal, the users and the limits. It writes the result to
   `.claude/orchestration/PROJECT.md`. Read this file and correct it. The reviewers base their
   verdicts on it.
3. Choose your autonomy level when Claude asks. Change it later with `/prompt-to-ship autonomy`.
4. Ask for a change in plain words. You see the brief first, then the plan with the three
   verdicts.
5. Run `/prompt-to-ship weekly` once a week, or schedule it.

In a repository without `.claude/orchestration/PROJECT.md`, the hook prints nothing.

### A workspace with several repositories

Do you keep one folder for a whole product, with several git repositories and documents, and
start Claude there? Then setup offers a **workspace**:

```
product/      the workspace (not a git repository)
  api/        a git repository
  web/        a git repository
  docs/       documents
```

One PROJECT.md for the workspace lists the repositories, with their target branch, code host and
commands. Each change names the repositories it touches, gets one pull or merge request per
repository, and is merged as one set in a fixed order. Everything prompt-to-ship writes stays in
the workspace folder on your machine. Start Claude in the workspace, not inside one repository.

### A repository with strict rules

Some teams allow nothing in a repository except product code, or forbid any mention of tools or
AI in commits. Setup asks two questions for this:
- **Files: local.** PROJECT.md and the learning files stay on your machine. They are not shared
  with teammates, and `git clean -x` deletes them.
- **Tool lines: local log.** Lines such as "Rules matched" go to a log inside your git folder,
  never into descriptions or commits. Claude also offers to switch off Claude Code's own
  attribution lines, in a local settings file.

### A repository with its own pipeline

Some repositories already have their own process, for example in CLAUDE.md or with their own
review agents. Setup finds this and asks you how prompt-to-ship must work with it:

| Mode | What happens |
|---|---|
| `defer` (recommended) | Your existing pipeline leads. prompt-to-ship adds its reviewer for each role that your agents lack or cover only partly. |
| `map` | prompt-to-ship runs, with your names, house rules and git flow. The prompt-to-ship reviewers always run. |
| `replace` | prompt-to-ship leads. Setup lists the lines in CLAUDE.md that you must change yourself. |
| `none` | What setup found is not a pipeline. prompt-to-ship runs as normal. |

For `defer`, setup compares each of your review agents with the matching prompt-to-ship
reviewer. It marks each role as full, partial or missing, and tells you why. You can correct
this in your answer.

Setup never edits CLAUDE.md. A push to your main branch waits for you. In `map`, `replace` and
`none`, autonomy level `merge` or higher can allow it. In `defer`, Claude always asks. To change
the mode later, run `/prompt-to-ship setup` again, or tell Claude in the chat. The full rules are
in [references/existing-pipeline.md](references/existing-pipeline.md).

## Update and remove

- **Update, way A:** run `/plugin marketplace update prompt-to-ship`.
- **Update, way B:** run `git pull` in the skills folder.
- **Remove, way A:** run `/plugin uninstall prompt-to-ship@prompt-to-ship`.
- **Remove, way B:** delete the folder `~/.claude/skills/prompt-to-ship`.

Removal leaves two things in each repository where you used it. The first is the project file
`.claude/orchestration/PROJECT.md`. The second is the git config keys that start with
`orchestration.` To remove the keys, run `git config --local --remove-section orchestration`.

## Cost

Each agent uses tokens, the units in which Claude usage is counted. So a change costs more than a
single chat answer. Agent runs per change, for one review round:

| Risk | Agent runs |
|---|---|
| Low | 6: three on the plan, the fresh reviewer, UI and product on the result |
| Normal | 7: the same, plus the security reviewer |
| High | 7, and you read the change yourself |

Each serious finding adds one validator run. A repository without a user interface can set
"User interface: none" in its project file. This saves two runs per change.

## Why it works this way

- **Layers.** Each review misses some problems. Few problems get through all of them.
- **Proof.** A test run or a screenshot shows that something works. A statement does not.
- **Short instructions.** The main file stays small; the rest loads only when a step needs it.
- **Fresh eyes.** A reviewer that did not see the chat finds what the author missed.
- **A limit on rounds.** An author agent and a reviewer agent can go on forever. Three rounds is
  the maximum.
- **Evidence for security findings.** Each finding needs a path from the input to the risk, with
  file and line. A validator tries to disprove it.
- **Learning.** Each mistake that gets through becomes a check at the step that should have
  caught it. Checks that stop paying off are retired.

## How it learns

Claude keeps two files next to PROJECT.md: `incidents.md` (what went wrong) and `rules.md` (the
checks it learned).

1. **Log.** A miss (a problem that reached your main branch or production) is logged right
   away. A near-miss
   (a late review caught what the plan should have caught) is first one line in the request.
   It becomes a lesson only when the same cause comes back.
2. **Test.** A lesson is kept only when it is non-obvious, durable and material.
3. **Narrowest home.** A test first, then a check command, then a rule for one step and the
   files it applies to.
4. **Verify.** The validator checks that the lesson would have caught the mistake, and that it
   only adds a check. A rule can never remove a reviewer, a gate or a safety rule.
5. **Confirm.** You see each lesson and decide.
6. **Use.** Each reviewer gets the rules for its own step. A finding names the rule that caused
   it.
7. **Count and retire.** The weekly review counts how often each rule applied, caught something
   or was overruled. It shows whether old mistakes come back, and proposes to retire rules that
   no longer help.

Some lessons are about the pipeline itself, not about your code: a missing question or gate that
would matter in any repository. Claude writes those as a generic proposal, with no names from
your project, in a file in your home folder. The prompt-to-ship repository reads that file, so
every project you use it in can make the pipeline better.

At the end of each change you see one line, for example: "Rules: 11 active, 3 matched this
change, 1 caught (RULE-012)." The full rules are in
[references/learning.md](references/learning.md).

## Problems and ideas

Open an issue at https://github.com/Klinterm/prompt-to-ship/issues.

## Contents

```
prompt-to-ship/
  SKILL.md                         the main instructions
  .claude-plugin/plugin.json       makes the folder a plugin, so agents and the hook load with it
  .claude-plugin/marketplace.json  lets you install this repository as a plugin
  agents/                          architect, ui-specialist, product-expert,
                                   fresh-reviewer, security-reviewer, validator (all read-only)
  hooks/                           a short reminder on each message, silent in other repositories
  references/                      pipeline, gates, setup, workspace, existing pipeline, checklist,
                                   code hosts, autonomy, learning, security rules, weekly review
  docs/                            the README diagrams, and the script that draws them
  evals/                           behaviour tests for maintainers (claude plugin eval); users do
                                   not need them
  TESTING.md                       the acceptance test before a release
  CHANGELOG.md, LICENSE
```

## Contributing

This repository uses its own pipeline. Its project file is
[.claude/orchestration/PROJECT.md](.claude/orchestration/PROJECT.md). When you change a behaviour,
raise the version in `.claude-plugin/plugin.json` and add a line to `CHANGELOG.md`. Run the checks
in [TESTING.md](TESTING.md) before a release. When a step changes, change the diagrams too:
edit `docs/make-diagrams.py` and run `python docs/make-diagrams.py docs`.

## License

MIT. See [LICENSE](LICENSE).
