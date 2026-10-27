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
- [ ] Every outside fact in the diff is a CONFIRMED value from the fact table, with `source:` and
      `valid:` next to it (pipeline.md, "Outside facts").
- [ ] Unused code, keys and translations are removed, not commented out.
- [ ] Every new user-facing text exists in every supported language.

## 4. Change request (stage 6)

- [ ] The push gates in gates.md are checked.
- [ ] Only the topic branch is pushed, with an explicit refspec, to an explicit target branch.
- [ ] Description: Tested (with the marker lines), Risk, How to revert.
- [ ] Give the link (or the branch and diff command). Level `ask`: stop.

## 5. Merge and release (stage 7)

- [ ] Levels `ask` and `change-request`: the user said go for this merge.
- [ ] Every gate in gates.md checked again right before the merge and right before the release.
- [ ] Before a release: list everything else that would go live with it.
- [ ] After the release: wait a few minutes, then measure the "done when" items.
- [ ] Automatic merge or release: the one-line report with the revert command (autonomy.md).
