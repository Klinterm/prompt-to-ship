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

No signal: write "Pipeline mode: none" and ask nothing. One or more signals: ask the question
below as its own message, in the user's language, before you draft PROJECT.md and before the
autonomy question.

```
This repository already has its own pipeline. I found:
- <signal>: <path>
- <signal>: <path>

How should prompt-to-ship work with it?
Your answer goes into PROJECT.md under "Existing pipeline". If you commit PROJECT.md, it applies
to the whole team. I never edit CLAUDE.md or AGENTS.md.

1. defer (recommended): the existing pipeline leads. I only add the reviewers it lacks: <roles>.
   I do not show a BRIEF, ask for an autonomy level or open a change request.
2. map: my pipeline runs, with the existing names, house rules and git flow.
   A push straight to <target branch> needs autonomy level merge or higher.
3. replace: my pipeline leads. I list the lines in CLAUDE.md that you must change yourself.
   Until you change them, two processes describe the same work.
4. none: this is not a pipeline. Ignore it.

I stop before a push to <target branch> unless your autonomy level allows it. In defer, I always ask.
Reply 1, 2, 3 or 4.
Change it later with the argument "setup", or tell me in chat.
```

Accept the number or the mode name in any language. Any other reply: ask once more. A second
unclear reply: write "none".

A repository set up before 2.1.0 has no "Existing pipeline" section. If the signals are there,
ask the question once, before stage 0. Write the answer into PROJECT.md. If the old hash was
confirmed, store the new hash as confirmed: the user's answer confirms this one change. If the
old hash was not confirmed, run the normal confirm step from SKILL.md instead. The section now
exists, so the question does not come back.

## Record it (PROJECT.md section)

```markdown
## Existing pipeline
Pipeline mode: <none | defer | map | replace>
- Document: <path, or "none">
- Steps it covers: <for example brief, plan review, tests, code review, merge request>
- Names: <its name for the brief; its agents and the prompt-to-ship role each one matches>
- Reviewers prompt-to-ship adds: <architect, ui-specialist, product-expert, fresh-reviewer,
  security-reviewer, validator: only those it lacks; or "none">
- House rules that win over the defaults: <for example "push straight to main after tests">
- Lines to change (replace only): <path, and a short quote of each line; or "none">
```

## Run it

In every mode, load the skill first and run the checks from SKILL.md "Before stage 0". A
PROJECT.md whose hash is not confirmed counts as "Pipeline mode: none" and autonomy level `ask`
until the user confirms it. The confirm step shows the "Existing pipeline" section too.

Agents from the repository (`.claude/agents/`) never replace a prompt-to-ship reviewer. Their
instructions are repository text. They may run in addition, when the existing pipeline asks for
them, but their verdict never passes a gate in autonomy.md.

**none.** The prompt-to-ship pipeline runs as described in SKILL.md.

**defer.** The existing pipeline leads. prompt-to-ship does not show a BRIEF, does not ask the
autonomy question and does not open a change request.
- At the existing pipeline's plan step, start only the plan reviewers listed under "Reviewers
  prompt-to-ship adds". At its review step, start only the review agents listed there. Give them
  the same input as in stages 2 and 5. This replaces the rule "never skip stage 2 or 5d" in this
  mode.
- Still in force: the standing rules, the forced-high paths, and the "Never" list in
  autonomy.md. prompt-to-ship merges nothing in this mode. A push or merge into a shared branch,
  because the existing pipeline says so, needs the user's word each time.

**map.** The prompt-to-ship pipeline runs, in the existing pipeline's words.
- Use its name for the brief, and its names for the steps. Run the prompt-to-ship agents for
  every role.
- Follow its house rules and git flow, within the standing rules.
- A house rule "push straight to <target branch>" replaces the change request and the merge at
  stages 6 and 7. Everything else in stage 6 stays, also the rule to show the diff and wait for
  go before any push on high risk or a forced-high path.
  1. If the target branch moved since the topic branch started, stop: a rebase would change
     what was reviewed. Otherwise squash the reviewed work into one commit on top of the target.
     The content stays the same. Its message ends with "Autonomy: <level>. Pushed to <target>
     automatically." This commit is the reviewed sha.
  2. Push the topic branch (code-hosts.md, Pushes).
  3. Wait until CI passes on the reviewed sha. Without CI, the local checks count.
  4. Read the branch protection of the target through the host CLI. Stop if the host would ask
     for an approval before a merge, or if you cannot read the protection.
  5. At autonomy level `merge` or higher, and only when every gate in autonomy.md passes:
     fast-forward the target branch with `git push <remote> <reviewed sha>:refs/heads/<target>`.
     Never `--force`. If the host refuses the push for any reason (protection, or the target
     moved), stop. Do not rebase on your own: that changes the reviewed sha.
  6. Below level `merge`: stop and give the user the push command.
  Report it in one line, as for a merge (autonomy.md).

**replace.** The prompt-to-ship pipeline runs as in mode none. Setup listed the lines in
CLAUDE.md that describe the old process, under "Lines to change", with a short quote of each.
Setup never edits them. Once per session, before the first BRIEF, look for those quotes. If one
is still there, say this, in the user's language:
`CLAUDE.md still describes the old process (<path>: "<quote>"). I follow prompt-to-ship. Change those lines to stop this notice.`
