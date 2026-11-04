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
At levels 3 and 4 you can tell me in chat to let your go on a high-risk diff (also one that
touches the files above) cover its merge, and at level 4 its release. A new push ends it. Every
other stop stays. At level 3, a target that deploys on merge still stops before the merge.
Risk: after your go on the diff, that exact commit is merged (at level 4 also released) without a
second question.
Reply 1, 2, 3 or 4. Any other reply keeps 1.
Change it later with the argument "autonomy", or tell me in chat.
```

Accept the number or the level name in any language. Store the English key. When the user picks
`release`, check these in order:
1. The target deploys on merge: the merge itself is the release. Show the "Deploys on merge"
   line and ask to confirm it. With a release command in PROJECT.md for the step after the merge
   (for example a tag), show it, ask to confirm it, and store it as `orchestration.releaseCommand`;
   without one, leave the key empty.
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
- At level `release`, after the merge: a release command in PROJECT.md for the step after the
  merge (for example a tag and release notes) runs right away, from a clean worktree at the merge
  sha. Merge and command are one release, with one "done when" measurement after the command.
  - Gates 10 and 11 are checked before the merge, because the merge is the release.
  - Fetch the merge sha first (a squash made on the host is not in the clone yet).
  - Fill the placeholders from the merge: the version from the version file PROJECT.md names, at
    the merge sha; the merge sha from the host; release notes written from the CHANGELOG section
    into a scratch folder, never into the repository. The version must match
    `^[0-9]+\.[0-9]+\.[0-9]+$` and the sha must be 40 or 64 hex characters; otherwise stop before
    the release.
  - Check gate 10 again on the commits from the target sha that gate 10 saw before the merge to
    the merge sha. That target sha must be the first parent of a merge commit, or, for a
    fast-forward, an ancestor of the merged sha (`git merge-base --is-ancestor`).
  - Run it only when that version is higher than the latest release tag on the remote
    (`git ls-remote --tags --refs <remote>`, only `vX.Y.Z` with digits, compared as numbers). No
    tag yet: run it. The tag list cannot be read: stop before the release, never tag blind.
    Version not higher: skip it, say so in the report, and still measure "done when".
  - A step of the command fails after a successful merge: stop with `Stopped before release: the
    merge is live as <sha>; step <n> failed: <what>. Next: run the remaining steps by hand, or say
    what to do.` Keep the merge line with its revert command in the report. No retry, no revert:
    a published tag is public, so the way back is a higher version.
  Without a release command, after the merge, wait a few minutes, then measure the "done when"
  items as in stage 7.
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
5. `ask` for this task, when a gate applies (gates.md); with `orchestration.diffGoCovers`, gate 1
   only (high risk and forced-high paths) stops only until the user's go on the diff (gates.md,
   "Diff go covers merge");
6. `change-request` for the merge step, when the target deploys on merge and the effective level
   after 1 to 5 is `merge`;
7. `change-request` for a quick-lane task: it never merges on its own (pipeline.md, "Quick lane").

Show it in the BRIEF:

```
Autonomy:    merge (your level)
Autonomy:    change-request (team cap; your level is release)
Autonomy:    ask for this task (high risk: touches .github/workflows/ci.yml)
Autonomy:    change-request (bitbucket has no automatic merge; your level is merge)
Autonomy:    change-request (quick lane never merges; your level is merge)
```

Give the reason whenever the effective level is lower than the stored level.

## Automatic merge and release

At levels `merge` and `release`, when no gate applies (gates.md, which also holds the rules for
every merge):
- Merge with the command for the host in code-hosts.md, with a merge method code-hosts.md allows.
  A host or PROJECT.md that allows only a rebase merge: stop at `change-request`.
- No host and no remote: `git merge --no-ff <reviewed sha>` into the target, locally, no push.
- No host but a remote, or a host without a merge command: stop at `change-request`.
- No CI on the repository: the local checks from PROJECT.md count, and the report says so.
- Release: run `orchestration.releaseCommand` exactly, then measure "done when" as in stage 7.

Report after each automatic action, one line:

```
Merged <link or branch> into <target> as <sha> (level merge). Revert: git revert -m 1 <sha>
Merged <link or branch> into <target> as <sha> (level merge, squash). Revert: git revert <sha>
Fast-forwarded <target> to <sha> (level merge, map). Revert: git revert <sha>
Released <version> from <sha> (level release). Done when: <n> of <m> pass. Revert: <the revert command from the merge line>, then release again
Merged and deployed <link or branch> into <target> as <sha> (level release, deploys on merge). Done when: <n> of <m> pass. Revert: <revert command>, then merge again
Merged and released <version> as <sha> (level release, deploys on merge, then the release command). Done when: <n> of <m> pass. Way back: a higher version
Merged and deployed <link or branch> into <target> as <sha>; no tag: version not higher than <last tag>. Done when: <n> of <m> pass
```

At levels `merge` and `release`, the change request description carries the line
"Autonomy: <level>. This change request may be merged automatically." (with no host: the last
commit message; with "Markers: local log": the local log, plus "Merged as: <sha>" after the
merge, see learning.md).

A high-risk change merged on the user's diff go also carries "Merged on the user's diff go
(orchestration.diffGoCovers) for <reviewed sha>.": in the change request description with a host;
in the local log with no host, in mode `map` or with "Markers: local log". Never in a commit
message: that would change the reviewed sha.

The weekly review uses these lines to find and check every automatic merge and release.
