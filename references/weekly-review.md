# Weekly review

Run the skill with the argument `weekly`, by hand or from a scheduled task. Read-only. The
command is `/prompt-to-ship weekly` for a skills-folder install and
`/prompt-to-ship:prompt-to-ship weekly` for a marketplace install.

## Rules

- Change nothing in the repositories. No merges, approvals, comments on the code host, releases.
- The only file you write is the report.
- Use the code host as described in [code-hosts.md](code-hosts.md), with the user's existing
  sign-in. Never print a token.

## Steps

1. Read `.claude/orchestration/PROJECT.md` and the previous report in
   `.claude/orchestration/reviews/` (if any), so nothing is reported twice.
2. In a workspace, do steps 2 to 8 per folder from the "Repositories" table, and write one
   report with a section per folder (workspace.md, "Weekly review").
   Find the host (code-hosts.md). With a host: list all change requests of the last 7 days:
   open, merged and closed. With no host: list the commits on the target branch of the last
   7 days, and the local branches changed in that time.
3. Per merged or open change request (or per commit range): read the diff. Find real bugs
   yourself. Give the diffs that touch entry points, permissions, queries, files, secrets, model
   prompts or dependencies to the `security-reviewer`, with the matching areas from
   security-rules.md and its path.
4. Every finding of medium or higher goes to a separate `validator`. Only what survives is a
   finding; the rest goes under "Rejected" with the reason.
5. Branch parity: if PROJECT.md has several long-lived branches (for example staging and
   production), does every change that should exist on both, exist on both?
6. Change requests open longer than 7 days (host only).
7. CI: failed runs, and releases waiting for a manual step (host only).
8. Automatic merges and releases: the change requests (or commits) with the line "Autonomy:
   <level>. This change request may be merged automatically.", and the commits on the target
   branch with "Reviewed by prompt-to-ship (map, level merge)" or "(map, level release)" (pipeline mode `map`). A map commit at
   level `ask` or `change-request` was pushed by the user: skip it. With "Markers: local log",
   find them in the local log instead (learning.md), and say that this covers this clone only.
   List each one, and check
   that no gate from gates.md applied at that moment (risk, forced-high paths, failed CI,
   unresolved findings, and a merge at level `merge` into a target that deploys on merge). A
   gate that was missed is a finding of severity High.
8b. Outside facts: search the repository for `valid:` periods that ended before today, or that
   do not cover the reference year in "Research scope". List each with its `source:`, and
   propose a refresh through research. Do not apply it.
9. Learning ([learning.md](learning.md), "Count and prune"): count the "Rules matched", "Rules
   that caught something", "Rules overruled" and "Near-miss" lines of the period, read
   incidents.md and rules.md, and carry the totals forward from the previous report. Propose
   incidents for new near-misses, a lesson for a root cause that came back, and rules to retire,
   review or merge. Do not apply them.
10. At most three proposals to improve PROJECT.md, the checklist or an agent file, based on what
   you saw this week. Do not apply them. Learning proposals do not count toward these three.

## Report

Write `.claude/orchestration/reviews/REVIEW-<YYYYMMDD>.md`. Reports stay local: if
`git check-ignore` says the folder is not ignored, add `.claude/orchestration/reviews/` to
`.git/info/exclude` first. They are never committed.
- Summary (max 5 lines): the mode (host name, or "plain git: commits on <branch>"), counts,
  findings per severity, what the user must decide.
- Findings: severity, confidence, change request or commit, `path:line`, what is wrong, proposal.
- Automatic merges and releases.
- Learning: the section from learning.md, with the rule totals table.
- Branch parity.
- Outside facts with an ended period.
- Waiting change requests and CI. With no host, list them under "Not checked".
- Rejected.
- Proposals for the pipeline.
- Which agents ran. Not checked, and why.

If nothing is found, say so plainly: "no findings within this review".
End with at most 8 lines: the report path, any finding of severity High or Critical, what the user must decide,
and the one-line rules summary (pipeline.md, "Rules").

## Scheduling it

Create a weekly scheduled task in the repository folder with the weekly command above as the
prompt (in the desktop app, or with the `/schedule` command).
Local scheduled tasks read personal skills; cloud sessions do not, unless the skill is committed
to the repository or installed as a plugin on the user's account. With "Storage: local" or
"Markers: local log", run the weekly review locally: a cloud session cannot read the local files
or the log.
