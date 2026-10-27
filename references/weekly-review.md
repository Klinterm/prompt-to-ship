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
2. Find the host (code-hosts.md). With a host: list all change requests of the last 7 days:
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
   <level>. This change request may be merged automatically." List each one, and
   check that no gate from autonomy.md applied at that moment (risk, forced-high paths, failed
   CI, unresolved findings). A gate that was missed is a high finding.
9. At most three proposals to improve PROJECT.md, the checklist or an agent file, based on what
   you saw this week. Do not apply them.

## Report

Write `.claude/orchestration/reviews/REVIEW-<YYYYMMDD>.md`:
- Summary (max 5 lines): the mode (host name, or "plain git: commits on <branch>"), counts,
  findings per severity, what the user must decide.
- Findings: severity, confidence, change request or commit, `path:line`, what is wrong, proposal.
- Automatic merges and releases.
- Branch parity.
- Waiting change requests and CI. With no host, list them under "Not checked".
- Rejected.
- Proposals for the pipeline.
- Which agents ran. Not checked, and why.

If nothing is found, say so plainly: "no findings within this review".
End with at most 8 lines: the report path, any high or critical finding, what the user must decide.

## Scheduling it

Create a weekly scheduled task in the repository folder with the weekly command above as the
prompt (in the desktop app, or with the `/schedule` command).
Local scheduled tasks read personal skills; cloud sessions do not, unless the skill is committed
to the repository or installed as a plugin on the user's account.
