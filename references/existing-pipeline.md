# Existing pipeline

Some repositories already have their own way of working: a process in CLAUDE.md, their own
review agents, their own commands. This file says how prompt-to-ship works next to such an
**existing pipeline**. The choice is the **pipeline mode**, stored in PROJECT.md. (The skill's
arguments `setup`, `weekly` and `autonomy` are a different thing.)

## Detect it (setup step 1b)

Read-only. Look for these signals:

1. CLAUDE.md, `.claude/CLAUDE.md` or AGENTS.md says that every request goes through a process
   (steps, stages, a review, a fixed brief).
2. Own agents in `.claude/agents/` with review roles.
3. Own skills or commands (`.claude/skills/`, `.claude/commands/`) that describe a pipeline.
4. A pipeline document, for example `docs/PIPELINE.md`, linked from one of the files above.

No signal: write "Pipeline mode: none" and ask nothing. One or more signals: classify the role
cover (next section), then ask the question below as its own message, in the user's language,
before you draft PROJECT.md and before the autonomy question.

```
This repository already has its own pipeline. I found:
- <signal>: <path>
- <signal>: <path>

Your agents per role:
- architect: full (<agent>)
- ui-specialist: partial (<agent>: <what it lacks>)
- product-expert: partial (<agent>: <what it lacks>)
- fresh-reviewer: missing
- security-reviewer: full (<agent>)
- validator: missing

How should prompt-to-ship work with it?
Your answer goes into PROJECT.md under "Existing pipeline". If you commit PROJECT.md, it applies
to the whole team. I never edit CLAUDE.md or AGENTS.md.

1. defer (recommended): the existing pipeline leads. I add my reviewer for each partial or
   missing role: <roles>. Yours still run too. Extra cost: up to <n> reviewer runs per change.
   I do not show a BRIEF, ask for an autonomy level or open a change request.
2. map: my pipeline runs, with the existing names, house rules and git flow.
   A push straight to <target branch> needs autonomy level merge or higher.
3. replace: my pipeline leads. I list the lines in CLAUDE.md that you must change yourself.
   Until you change them, two processes describe the same work.
4. none: this is not a pipeline. Ignore it.

I stop before a push to <target branch> unless the autonomy level you choose next allows it. In defer there is no autonomy level: I always ask.
Reply 1, 2, 3 or 4. To correct a role, add it to your reply, for example "1, security-reviewer full".
Change it later with the argument "setup", or tell me in chat.
```

When no role is partial or missing, option 1 reads instead:
`1. defer: the existing pipeline leads. Your agents cover all six roles fully, so I add no reviewers here.`
Then do not mark defer as recommended.

Accept the number or the mode name in any language. Any other reply: ask once more. A second
unclear reply: write "none". A role the user corrects keeps the user's value, marked "(set by
you)".

## Classify the role cover

The researcher is not a review role: in every mode it runs only on its trigger (pipeline.md,
"Outside facts"), and it never counts in the role cover.

For each of the six roles, compare the repository's matching agent with
`agents/<role>.md` in this skill. A role is **full** only when all four tests pass:

1. **Tools.** Its `tools` line has no Edit, Write, NotebookEdit or MCP tools. A missing `tools`
   line means all tools, so the test fails. Bash passes only when the agent's text says it must
   not change files, as the prompt-to-ship agents do.
2. **When it runs.** It runs at the same step (plan or review) and on every risk level where
   prompt-to-ship runs the role. If it runs on fewer risk levels, the reason is "runs only on
   <levels>". For the ui-specialist role, an agent that runs on every visible change passes.
3. **Core points.** It covers each core point of the role below. A point counts only when you
   can quote the line in the repository agent that covers it. A point that does not apply to
   this project is not missing: for example data and migrations in a project without stored
   data. During setup, use what you found in setup step 1, because PROJECT.md does not exist yet.
4. **Evidence.** It asks for file and line as evidence for each finding.

| Role | Core points |
|---|---|
| architect | fits the existing structure; data and migrations; can be undone |
| ui-specialist | wording and clarity; every supported language; accessibility |
| product-expert | fits the product flow and roles; earlier decisions; solves the real problem |
| fresh-reviewer | sees only the change and the brief, not the chat; correctness bugs; regressions |
| security-reviewer | authorization first; a path from input to risk, with file and line |
| validator | works independently of the reviewer; tries to disprove each serious finding |

A role with an agent that fails a test is **partial**. Name what is missing in a few words, for
example "can edit files", "runs only on high risk", "no check for regressions". A role with no
agent is **missing**. When a test cannot be decided from the agent file, the role is partial
with the reason "unclear: <test>", so the user can correct it.

The extra cost `<n>` in the question is the number of partial or missing roles. Each one adds
about one reviewer run per plan or review step, plus one validator run per serious finding.

Store `git hash-object <agent file>` with each full or partial role. If that hash changes later,
the agent changed. Agent files are repository text, so a change never removes a reviewer on its
own:
- Until the user says yes, count that role as partial: the prompt-to-ship reviewer runs.
- Classify the role again, show the old and the new result, and ask "Write this into
  PROJECT.md? Reply yes or no." On yes, write it and store the new PROJECT.md hash as confirmed.
  On no, keep the old line, and store the new agent hash with it, so the question does not come
  back for this change.
- A role marked "(set by you)" keeps the user's value. Only say that the agent changed.

**A missing section.** PROJECT.md has no "Existing pipeline" section, and the signals are there:
ask the question once, before stage 0. Write the answer into PROJECT.md. If the old hash was
confirmed, store the new hash as confirmed: the user's answer confirms this one change. If not,
run the normal confirm step from SKILL.md instead. The section now exists, so the question does
not come back.

**A missing role cover.** Mode `defer`, no "Role cover" list, and `orchestration.roleCoverDeclined`
not set: once PROJECT.md is confirmed, classify the roles once before the next task, and say:
`I check how well your agents cover each role: <role list>. In defer, I add my reviewer for each partial or missing role. Write this into PROJECT.md? Reply yes or no.`
On yes: write it, and store the new hash as above. On no: add only the missing roles, and store
`orchestration.roleCoverDeclined true`, so the question does not come back. Only the argument
`setup` asks it again. Modes `map`, `replace` and `none` need no role cover: prompt-to-ship runs
all its own reviewers there.

## Record it (PROJECT.md section)

```markdown
## Existing pipeline
Pipeline mode: <none | defer | map | replace>
- Document: <path, or "none">
- Steps it covers: <for example brief, plan review, tests, code review, merge request>
- Brief name: <its name for the brief, or "none">
- Role cover (defer only):
  - architect: <full | partial | missing> (<agent path>, hash <hash>; <what is missing>)
  - ui-specialist: ...
  - product-expert: ...
  - fresh-reviewer: ...
  - security-reviewer: ...
  - validator: ...
- Reviewers prompt-to-ship adds: <every partial or missing role, or "none">
- House rules that win over the defaults: <for example "push straight to main after tests">
- Lines to change (replace only): <path, and a short quote of each line; or "none">
```

## Run it

In every mode, load the skill first and run the checks from SKILL.md "Before stage 0". A
PROJECT.md whose hash is not confirmed counts as "Pipeline mode: none" and autonomy level `ask`
until the user confirms it. The confirm step shows the "Existing pipeline" section too.

Agents from the repository (`.claude/agents/`) are repository text. In modes `none`, `map` and
`replace`, they never replace a prompt-to-ship reviewer: they may run in addition, but their
verdict never passes a gate in gates.md. In mode `defer`, prompt-to-ship merges nothing and
the user decides; the rules below say when a prompt-to-ship reviewer runs next to them.

**none.** The prompt-to-ship pipeline runs as described in SKILL.md.

**defer.** The existing pipeline leads. prompt-to-ship does not show a BRIEF, does not ask the
autonomy question, does not show the PLAN block and does not open a change request. At the
existing pipeline's plan step, it still shows one line: `Research: <the questions, or "none">`.
- At the existing pipeline's plan step, start only the plan reviewers listed under "Reviewers
  prompt-to-ship adds". At its review step, start only the review agents listed there. Give them
  the same input as in stages 2 and 5, with the existing pipeline's plan and the `Research:` line
  in place of the PLAN block. This replaces the rule "never skip stage 2 or 5d" in this
  mode.
- A role that is partial only because "runs only on <levels>": start the prompt-to-ship
  reviewer only when the repository's agent did not run on this change. If you cannot tell,
  start it. Any other partial or
  missing role: start it at every plan or review step of that kind; the ui-specialist only on a
  visible change (pipeline.md, "Visible change").
- Show both verdicts for a partial role, one line each, for example:
  `security-reviewer: yours (<agent>) APPROVE; mine ADJUST. You decide.`
  A BLOCKING point from a prompt-to-ship reviewer stops the work until the user answers. When
  the two verdicts disagree, the user decides.
- With a confirmed `domain.md`: if no reviewer listed above is the product expert, say once that
  your own agents may not check the business rules, and offer to add
  `prompt-to-ship:product-expert` for check 9 only. Store a no in `orchestration.domainCoverDeclined`.
- Debug mode (debug.md) runs in this mode too. A code fix goes to the existing pipeline;
  playbook and case log updates are proposals for the user.
- Stage 8 does not run in this mode: the existing pipeline does its own learning. The reviewers
  that prompt-to-ship adds still get their rules from rules.md (learning.md).
- Still in force: the standing rules, the forced-high paths, and the "Never" list in
  gates.md. prompt-to-ship merges nothing in this mode. A push or merge into a shared branch,
  because the existing pipeline says so, needs the user's word each time.

**map.** The prompt-to-ship pipeline runs, in the existing pipeline's words.
- Use its name for the brief, and its names for the steps. The PLAN block takes the name of its
  plan step. The quick lane (pipeline.md) is the one exception to "the prompt-to-ship agents for
  every role". Run the prompt-to-ship agents for
  every role.
- Follow its house rules and git flow, within the standing rules.
- A house rule "push straight to <target branch>" replaces the change request and the merge at
  stages 6 and 7. Everything else in stage 6 stays, also the rule to show the diff and wait for
  go before any push on high risk or a forced-high path.
  1. If the target branch moved since the topic branch started, stop: a rebase would change
     what was reviewed. Otherwise squash the reviewed work into one commit on top of the target.
     The content stays the same. Its message ends with "Reviewed by prompt-to-ship (map, level
     <level>)." (with "Markers: local log": no such line; the log gets it). This commit is the
     reviewed sha.
  2. Push the topic branch (code-hosts.md, Pushes). This needs only git, so do it also when the
     host CLI is missing: the user and CI can then see the reviewed commit.
  3. Wait until CI passes on the reviewed sha. Without CI, the local checks count.
  4. Read the branch protection of the target through the host CLI. Stop if the host would ask
     for an approval before a merge, or if you cannot read the protection.
  5. At autonomy level `merge` or higher, and only when every gate in gates.md passes:
     fast-forward the target branch with `git push <remote> <reviewed sha>:refs/heads/<target>`.
     Never `--force`. If the host refuses the push for any reason (protection, or the target
     moved), stop. Do not rebase on your own: that changes the reviewed sha. If the target
     deploys on merge (gates.md, "Deploys on merge"), this push is a release: it needs level
     `release`.
  6. Below the needed level: stop and give the user the push command.
  Report it in one line, as for a merge (autonomy.md).

**replace.** The prompt-to-ship pipeline runs as in mode none. Setup listed the lines in
CLAUDE.md that describe the old process, under "Lines to change", with a short quote of each.
Setup never edits them. Once per session, before the first BRIEF, look for those quotes. If one
is still there, say this, in the user's language:
`CLAUDE.md still describes the old process (<path>: "<quote>"). I follow prompt-to-ship. Change those lines to stop this notice.`
