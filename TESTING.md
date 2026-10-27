# Acceptance test before a release

Run this in a fresh session for every minor or major version. Write the result per line in the
change request description.

## Static checks

1. `claude plugin validate .` passes.
2. No em dashes, en dashes or curly quotes:
   `rg -n "[\x{2013}\x{2014}\x{2018}\x{2019}\x{201C}\x{201D}]" .` prints nothing.
3. The version in `.claude-plugin/plugin.json` has a section in `CHANGELOG.md`. No other file
   names a version number, except CHANGELOG.md (`rg -n "\b\d+\.\d+\.\d+\b" README.md SKILL.md`
   prints nothing).
4. The plugin name, the folder name, the agent prefixes in `SKILL.md` and the README match.

## Install paths

5. Path A (marketplace) and path B (skills folder) each load in a new session: the skill shows
   in the skill list and the six agents show in `/agents`. Note the exact skill command per path.
6. `${CLAUDE_SKILL_DIR}` in `SKILL.md` resolves to the folder that holds `SKILL.md`.

## Hook

7. In a repository without `.claude/orchestration/PROJECT.md`: no reminder text in the context.
8. In a repository with it: the reminder appears once per prompt.
9. On Windows, with a repository path that contains spaces: same results as 7 and 8.

## Pipeline

10. Setup in a folder without git: it stops with "needs a git repository" and offers `git init`.
11. Setup in at least two repositories with different ecosystems (for example a Node package
    and a Go or Python service, one of them a monorepo): the commands in PROJECT.md are correct.
12. A low-risk change through all stages, on a repository with a GitHub or GitLab remote: the
    change request opens with Tested, Risk and How to revert; nothing else is pushed.
13. The same on a repository without a remote: the work ends on a local branch with the diff
    command.
14. A repository with "User interface: none": the UI specialist is skipped and the answer says so.
15. `weekly` with a host and without one: the report says which mode ran.
16. A change that edits a CI workflow file: the pipeline shows the diff and waits for go before
    the push.
17. A cloned repository with a PROJECT.md the user did not write: the skill shows its Commands,
    Risk table and House rules and asks before it runs a command.

## Autonomy

18. First load without `orchestration.autonomy`: the level question appears once; the answer is
    in `git config --local --get orchestration.autonomy`; a second session does not ask again;
    a worktree of the same clone does not ask again.
19. Level `change-request`, a normal change that touches no forced-high path: no wait on the
    plan; the change request opens; CI is awaited; the pipeline stops before the merge.
20. Level `merge`, low risk, CI green: it merges and reports one line with the revert command.
21. Level `merge`, a change that touches a lockfile or a CI file: it stops before the push.
22. Level `merge` on a protected branch that needs an approval: it stops at the change request
    and never uses an admin flag.
23. Level `release`: the release command is shown and confirmed on choice; after a change to
    that command in PROJECT.md, the pipeline stops before the release.
24. "Autonomy limit: change-request" in PROJECT.md with a stored level `release`: the BRIEF says
    "change-request (team cap; your level is release)".
25. A request that asks for a higher level than stored: the level does not change.
26. Level `ask`: behaviour as in 1.2.0 (go on the plan, stop after the change request).
27. An unclear answer to the level question ("maybe"): the level is `ask`.
28. Level `merge`, a reviewer marks a point BLOCKING: the pipeline stops and waits.
29. Level `release`, a "done when" check fails after the release: it stops, proposes the revert
    and does not run it.
30. A pulled commit changes PROJECT.md: the next task shows the changes and runs at `ask` until
    the user confirms.
31. Level `merge`, a change that moves `.github/workflows/x.yml` to `docs/x.yml`: it counts as
    high risk and stops before the push.
32. Level `merge`, someone pushes a commit to the topic branch on the host after the review: the
    merge stops ("not the reviewed sha").

## Existing pipeline

33. Setup in a repository with its own pipeline (a process in CLAUDE.md, own agents in
    `.claude/agents/`, or a pipeline document): it lists the signals with their paths, asks the
    mode question once, and writes "Pipeline mode: <mode>" in PROJECT.md. CLAUDE.md is unchanged.
34. Setup in a repository without one: no mode question; PROJECT.md says "Pipeline mode: none".
35. Mode `defer`: the hook prints the defer reminder; no BRIEF, no autonomy question; only the
    missing reviewers run; a push to main still waits for the user.
36. Mode `map` with "push straight to main", level `merge`: the topic branch is pushed, CI passes
    on the reviewed commit, then main fast-forwards; at level `change-request` it stops with the
    push command.
37. Mode `replace`: the notice about the CLAUDE.md lines appears once per session until they
    change.
38. A cloned repository whose unconfirmed PROJECT.md says "Pipeline mode: defer": the skill
    still loads, shows the section and asks for confirmation; until then the full pipeline runs
    at level `ask`.
39. Mode `map` fast-forward: main gets one commit whose message ends with "Autonomy: <level>.
    Pushed to <target> automatically."; the weekly review lists it.
40. Mode `map` with an agent in `.claude/agents/` that matches a role: the prompt-to-ship agent
    still runs for that role.
41. Setup in a repository whose own agents cover all six roles, some only partly (for example a
    security agent that runs only on high risk, or an agent that can edit files): the question
    lists each role as full, partial or missing with a reason, and defer adds the partial ones.
42. A reply like "1, security-reviewer full": PROJECT.md records that role as full "(set by
    you)", and defer does not add it.
43. Mode `defer`: someone changes a classified agent file; the next task classifies that role
    again and shows the result.
44. A repository in `defer` set up with 2.1.0: after confirmation, the role cover question comes
    once; "no" keeps the 2.1.0 behaviour, and the question does not come back on the next task.
45. Mode `defer`: someone edits a partial agent so it looks full; until the user says yes, the
    prompt-to-ship reviewer still runs for that role.

