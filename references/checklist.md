# Checklist per change request

Read at stage 4, and use sections 4 and 5 at stages 6 and 7. PROJECT.md adds the commands and
rules for this repository; they win. A line that names something the project does not have (a
database, translations, CI) does not apply. The risk table and the gates are in gates.md.

## 1. Before you start

- [ ] If there is a remote: fetch. Check what others pushed to the target branch since you
      branched. If the branch is behind, rebase before the review. Never rebase after the
      review: that changes the reviewed sha (gates.md, gate 8).
- [ ] Check which remote you push to (`git remote -v`). A misnamed remote can be production.
- [ ] One topic per change request.

## 2. Build, with proof

- [ ] The build and the checks from PROJECT.md pass. Paste the last lines.
- [ ] Bug fix (a change the BRIEF calls a fix): the first line of the test's failing output from
      before the fix, or one line why there is none, for example no test harness.
- [ ] Compiler or analyzer errors about arguments, types or unresolved names are real errors,
      never "noise".
- [ ] If CI does not run for this branch, build locally. "CI will catch it" is not a safety net
      until you have seen CI run.
- [ ] If the project has a database: a schema change has a migration with a rollback, checked
      against the real schema.

## 3. Read the diff

- [ ] No secrets, tokens or passwords.
- [ ] No broken characters (encoding damage like `Ã` or `Â`), no mixed line endings in
      configuration files.
- [ ] Comments explain why, not history. No names, no dates, except the `valid:` period of an
      outside fact.
- [ ] With a confirmed `domain.md`: every invariant that the diff touches has a test, or a line
      that says why it cannot have one.
- [ ] Every outside fact in the diff is a CONFIRMED value from the fact table, with `source:` and
      `valid:` next to it (research.md).
- [ ] Unused code, keys and translations are removed, not commented out.
- [ ] Every new user-facing text exists in every supported language.

## 4. Change request (stage 6)

- [ ] The push gates in gates.md are checked.
- [ ] Only the topic branch is pushed, with an explicit refspec, to an explicit target branch.
- [ ] Description: Tested (with the marker lines), Risk, How to revert. A stage 5 finding of
      severity Medium or higher that stage 2 or 4 should have caught gives a "Near-miss" line.
- [ ] Under Tested, the findings of stage 5 in a table with the columns ID | Severity | Answer |
      Reviewer verdict | Summary (pipeline.md, "Answers" and "Loop rules"). Reviewer verdict is the
      last verdict with its reviewer and round, for example `FIXED (SR, round 2)`; `marker` for a
      Low fix that no reviewer re-read; `-` when no verdict applies (DECLINE, ESCALATE, NOT RUN, or
      no follow-up round). A row of severity Medium or higher
      without FIXED or CONTEST ACCEPTED is gate 4. Summary is one line: what the finding is, plus
      the evidence for CONTEST or the reason for DECLINE. No findings: one line "No findings". A
      reviewer that did not run: a row `<prefix> | - | NOT RUN | - | <reason>`.
- [ ] Below the table, the `Set aside:` lines of the fresh reviewer from every round, copied without
      rewording and without duplicates, at most 5 in total, then "more in the review"; only when
      there are any (also in the quick lane).
- [ ] Reviewer prompts and the CONTEST texts passed to a reviewer hold no "do not flag", no
      severity cap and no "the plan chose this" (pipeline.md, "What each reviewer gets").
- [ ] Give the link (or the branch and diff command). Level `ask`: stop.

## 5. Merge and release (stage 7)

- [ ] Levels `ask` and `change-request`: the user said go for this merge.
- [ ] Every gate in gates.md checked again right before the merge and right before the release.
- [ ] Before a release: list everything else that would go live with it.
- [ ] After the release: wait a few minutes, then measure the "done when" items.
- [ ] Automatic merge or release: the one-line report with the revert command (autonomy.md).
