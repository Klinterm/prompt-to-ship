# The pipeline in detail

Read this once per task, after the brief. SKILL.md is the summary; this file is the reference.

This file describes pipeline mode `none` and `replace`. In mode `defer` and `map`, read
[existing-pipeline.md](existing-pipeline.md) first: it says which stages change.

## Why it is built this way

- Most bugs in agent-written code are routine and caught by automation; human attention is kept
  for decisions only a human can make: what to build, risky code, architecture, approval.
- Review happens in layers. Each layer misses some things; few problems pass all of them.
- An agent must show proof (a build, a test run, a screenshot), not claim that it is done.
- A reviewer with fresh context finds what the author is blind to. Never give a reviewer the
  chat history.
- Agent author and agent reviewer can loop forever. Cap the rounds and review only new diffs.
- Every miss becomes a rule at the stage that should have caught it.

## Overview

| Stage | Name | Output | Wait for the user |
|---|---|---|---|
| 0 | Brief | a precise brief | on high risk or an open question |
| 1 | Understand | what exists and why | never |
| 2 | Plan + 3 reviewers | approach, risk, threat model, verdicts | level `ask`: on normal and high risk; other levels: at a gate |
| 3 | Build | commits on one branch | never |
| 4 | Prove | pasted output of builds and checks | never |
| 5 | Layered review | findings, each fixed or answered | when a finding needs a choice |
| 6 | Change request | link or branch | before the push on high risk or a forced-high path; level `ask` stops after it, higher levels wait for CI |
| 7 | Merge and measure | measured result | the user's word each time, unless the level is `merge` or `release` and no gate applies |
| 8 | Learn | a new rule, an incident logged | never |

## Stage 0. Brief

- Look up the context yourself. Do not ask what is in the files.
- "Done when" must be measurable: "GET /api/x returns 200 with the new field on staging", not
  "it works".
- At most ten lines.

## Stage 1. Understand

- Read the participating code end to end; follow the call chain across files.
- In a large code base, give a wide search to a read-only search agent and keep only its
  conclusion.
- `git log -S'<symbol>'`, `git log -G'<regex>'`, `git blame -L` for the reasons behind the code.
- If the project has a database: the live schema is the truth, not the ORM models.
- Read the decisions and parked items that PROJECT.md points to.
- If there is a remote: fetch, and check what others pushed since you last looked.
- In a monorepo, find the package or module that owns the change and use its commands from
  PROJECT.md.

## Stage 2. Plan

- Two or three approaches, each with its downside. Choose one and say why.
- Risk level from the risk table in PROJECT.md (default table in checklist.md). A file on the
  forced-high list in autonomy.md makes it high, whatever the table says.
- Threat model for normal and high risk, per new or changed entry point:
  1. Who may call it (anonymous, signed-in user, admin, partner, internal job)?
  2. Which object does it act on, and is ownership checked against the caller?
  3. Which outside input does it take, and where does that input end up (query, file path, HTML,
     PDF, email, model prompt, shell)?
- Start `architect`, `ui-specialist` and `product-expert` in parallel. Give each: the brief, the
  plan, the list of files, and the path to PROJECT.md. Never the chat history. Skip
  `ui-specialist` only when PROJECT.md says "User interface: none".
- First export the files from the target branch (`git show <branch>:<path>`) into a scratch folder
  and pass that folder. A working copy is often on another branch, and an agent whose shell fails
  would otherwise read the wrong version.
- Fold their verdicts into the plan. Show each verdict in at most five lines. A point marked
  BLOCKING stops the pipeline for the user's answer at every autonomy level.

## Stage 3. Build

- One branch per topic. If something else runs in parallel, use a separate worktree.
- Write the failing test first when you can; commit; make it pass.
- Visible changes: build, take a screenshot (browser preview, simulator, emulator), compare with
  what was asked, iterate until it matches. Two or three rounds usually get close to perfect.
  For a command-line tool or a library, the "screenshot" is the real output of a run or an example.
- Comments explain why, not how the code got there. No names, no dates.

## Stage 4. Prove

Run the checklist (checklist.md) and the commands from PROJECT.md. Paste the last lines of each
output. Without proof it is not done.

## Stage 5. Layered review

- 5a fresh-reviewer: diff + brief only. Always.
- 5b security-reviewer: normal and high risk. Choose specialist areas from security-rules.md by
  what changed.
- 5c validator: one per finding of medium or higher, without the reviewer's notes. Only what
  survives counts. Keep rejected findings with their reason, so they are not raised again.
- 5d ui-specialist and product-expert on the result: screenshots, texts in every language, and
  their own stage 2 verdict. Always (skip `ui-specialist` only when PROJECT.md says
  "User interface: none").
- 5e converge: every finding is fixed or answered with a reason. Three rounds with new findings
  means the approach is wrong: stop and rethink with the user. From round two, review only the
  new diff, and name the class of bug so the author fixes all instances at once.

## Stage 6. Change request

High risk, or a diff that touches a forced-high path from autonomy.md (CI files, build files,
dependency manifests and lockfiles, migrations): show the diff and wait for the user's go before
any push, at every autonomy level. A push to
any branch can start CI with the repository's secrets, and the model reviewers can be steered by
the same text that steered the author.

Then push only the topic branch and open the change request as described in code-hosts.md.
Description with three short parts:
- **Tested:** what was run or looked at, with the result.
- **Risk:** low, normal or high, and why.
- **How to revert:** revert the merge, roll back the migration (if any), switch off a flag.

One topic per change request. Give the link. With no host: give the branch name and the diff
command, and put the description in the last commit message. At levels `merge` and `release`,
add the line "Autonomy: <level>. This change request may be merged automatically." to the
description, so the weekly review can find it.

Level `ask`: stop here. Higher levels: wait for CI (autonomy.md, gate 7), report the result, and
continue to stage 7 only at levels `merge` and `release`.

## Stage 7. Merge and measure

- Levels `ask` and `change-request`: only on the user's word, each time. A question with a
  question mark is not a go.
- Levels `merge` and `release`: follow autonomy.md. Check every gate again right before the
  merge and right before the release. Report each automatic action in one line.
- Check the real merge status through the host CLI, the API or git (code-hosts.md); a message
  saying "merged" is not proof.
- Before releasing, list what else would go live with it (commits since the last release).
- After a release, wait a few minutes, then measure the "done when" items.

## Stage 8. Learn

1. Which stage should have caught this?
2. Put the rule there: PROJECT.md, checklist.md, or the agent file.
3. Log the incident in the incident table of PROJECT.md.
4. A rule that never catches anything and costs time may go. Tell the user.

## Rhythm

| When | What |
|---|---|
| Every change | stages 0 to 8 |
| Weekly | the skill with `weekly` (`/prompt-to-ship weekly`, or `/prompt-to-ship:prompt-to-ship weekly` for a marketplace install): a read-only review of recent change requests |
| Quarterly | a full security assessment, with a cost estimate first |

## Optional: agent teams

Agent teams (experimental, `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) let reviewers message and
challenge each other. They cost much more and turn every named subagent into a teammate. Keep
them off by default. A good first trial: stage 2 as a debate between architect, UI specialist
and product expert on one real feature, then compare result and cost.
