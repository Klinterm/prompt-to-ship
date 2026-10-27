# Autonomy levels

Read this at the first load in a repository, with the argument `autonomy`, or when the
autonomy level is above `ask`. The gates, the "Never" list and the state keys are in gates.md;
they hold at every level.

Each developer chooses how far the pipeline runs on its own in a repository. The default is `ask`.

| Level | The pipeline does on its own | The user does |
|---|---|---|
| `ask` | brief, plan, build, prove, review, push the topic branch, open the change request | says go on the plan (normal and high risk), merges, releases |
| `change-request` | as `ask`, without waiting for go on the plan; waits for CI and reports | merges, releases |
| `merge` | as `change-request`, then merges when every gate passes (not into a target that deploys on merge) | releases |
| `release` | as `merge`, then runs the confirmed release command and measures "done when" | reads the report |

## Where the level lives

`git config --local orchestration.autonomy <level>`. Git config is never committed or cloned, so
a repository cannot set it. All worktrees of a clone share it. A fresh clone has no value. The
other state keys are in gates.md, "State keys". In a workspace, see workspace.md, "State".

## First load

Before stage 0, read the level. If it is empty, PROJECT.md exists and the pipeline mode is not
`defer`, ask this as its own message (in the user's language). Without PROJECT.md (the user
skipped setup), do not ask: the level is `ask` until setup has run. In mode `defer` the existing
pipeline decides, so there is no level question.

```
How far may the pipeline go on its own in this repository?
This is your choice. It is stored only in this clone (git config), never committed.

1. ask (default): I wait for your go on the plan. You merge and release.
   Note: I still push the topic branch, so CI runs before you merge.
2. change-request: I build, review and open the change request without waiting. You merge.
   Risk: CI runs on code you have not read yet.
3. merge: as 2, then I merge when CI and all reviews pass. You release.
   Risk: a change reaches <target branch> before you read it.
   <only when the target deploys on merge:> Here a merge is a release, so I stop before it.
4. release: as 3, then I release and measure the result.
   Risk: a change reaches users before you read it.

At every level I still stop for, among others: high risk, changes to CI, build, dependency,
migration, access, secret or agent setup files, open questions, unfixed findings, failed CI and
merge conflicts.
Reply 1, 2, 3 or 4. Any other reply keeps 1.
Change it later with the argument "autonomy", or tell me in chat.
```

Accept the number or the level name in any language. Store the English key. When the user picks
`release`, check these in order:
1. The target deploys on merge: the merge itself is the release. Show the "Deploys on merge"
   line and ask to confirm it. Leave `orchestration.releaseCommand` empty: there is no command
   to run.
2. Otherwise, a release command in PROJECT.md "Branches and environments" (in a workspace: in
   the folder's block under "## Commands"): show it, ask to confirm it, and store it as
   `orchestration.releaseCommand`.
3. Otherwise: store `merge` and say "No release step in PROJECT.md: I stop after the merge."

The argument `autonomy` asks the question again and shows the current level.

## Deploys on merge

PROJECT.md records "Deploys on merge: yes (<how>)" under "Branches and environments" (setup asks
it). The short rule is in gates.md. In full:
- A merge into such a target, or a fast-forward push to it, is a release. It needs effective
  level `release`.
- Below that level, stop before the merge:
  `Stopped before merge: <target> deploys on merge, so merging is a release. Next: say "go", or choose level release.`
- At level `release`, there is no separate release command. After the merge, wait a few
  minutes, then measure the "done when" items as in stage 7.
- A deploy file or job that says yes while PROJECT.md says no: treat it as yes, show the conflict
  and propose the line for PROJECT.md.
- A missing line: ask once, together with the level question or before the next merge:
  `Does <target> deploy as soon as something lands on it? Reply yes or no.`
  Store the answer as `orchestration.deploysOnMerge`, and propose the line for PROJECT.md.

## The effective level for a task

Take the lowest of:
1. the stored level;
2. the team cap: "Autonomy limit: <level>" in PROJECT.md. A house rule that says merges need the
   user counts as `change-request`; one that says releases need the user counts as `merge`;
3. what the user asks for this task ("do this one manually" lowers it; a request can never raise
   it: say "Your level is <x>. Change it with the argument autonomy.");
4. `ask`, while `git hash-object .claude/orchestration/PROJECT.md` differs from
   `orchestration.projectConfirmed`, or PROJECT.md does not exist;
5. `ask` for this task, when a gate applies (gates.md);
6. `change-request` for the merge step, when the target deploys on merge and the effective level
   after 1 to 5 is `merge`.

Show it in the BRIEF:

```
Autonomy:    merge (your level)
Autonomy:    change-request (team cap; your level is release)
Autonomy:    ask for this task (high risk: touches .github/workflows/ci.yml)
Autonomy:    change-request (bitbucket has no automatic merge; your level is merge)
```

Give the reason whenever the effective level is lower than the stored level.

## Automatic merge and release

At levels `merge` and `release`, when no gate applies (gates.md, which also holds the rules for
every merge):
- Merge with the command for the host in code-hosts.md, with the merge method the host or
  PROJECT.md prescribes. No host and no remote: `git merge --no-ff <branch>` into the target,
  locally, no push. No host but a remote, or a host without a merge command: stop at
  `change-request`.
- No CI on the repository: the local checks from PROJECT.md count, and the report says so.
- Release: run `orchestration.releaseCommand` exactly, then measure "done when" as in stage 7.

Report after each automatic action, one line:

```
Merged <link or branch> into <target> as <sha> (level merge). Revert: git revert -m 1 <sha>
Merged <link or branch> into <target> as <sha> (level merge, squash). Revert: git revert <sha>
Fast-forwarded <target> to <sha> (level merge, map). Revert: git revert <sha>
Released <version> from <sha> (level release). Done when: <n> of <m> pass. Revert: <the revert command from the merge line>, then release again
Merged and deployed <link or branch> into <target> as <sha> (level release, deploys on merge). Done when: <n> of <m> pass. Revert: <revert command>, then merge again
```

At levels `merge` and `release`, the change request description carries the line
"Autonomy: <level>. This change request may be merged automatically." (with no host: the last
commit message; with "Markers: local log": the local log, plus "Merged as: <sha>" after the
merge, see learning.md). The weekly review uses it to find and check every automatic merge and
release.
