# Checklist per change request

Stages 4, 6 and 7. PROJECT.md adds the commands and rules for this repository; they win.
A line that names something the project does not have (a database, translations, CI) does not
apply.

## 1. Before you start

- [ ] If there is a remote: fetch. Check what others pushed to the target branch since you
      branched; rebase if needed.
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
- [ ] Comments explain why, not history. No names, no dates.
- [ ] Unused code, keys and translations are removed, not commented out.
- [ ] Every new user-facing text exists in every supported language.

## 4. Fresh review

- [ ] fresh-reviewer on the diff and the brief.
- [ ] security-reviewer for normal and high risk; validator per finding of medium or higher.
- [ ] Every finding answered. At most three rounds.

## 5. Risk table (default, PROJECT.md may override)

| Risk | Examples | Extra |
|---|---|---|
| Low | text, translation, colour, documentation | fresh review, and UI and product on the result |
| Normal | a screen, a new endpoint, a new command or public function, a report | plus security review, wait for go on the plan (level `ask`) |
| High | auth and permissions, money, signatures or final documents, file storage, schema migrations, CI, releases, production, public API or file format changes | plus the user reads the diff before the push |

When in doubt, choose the higher level.

## 6. Change request

- [ ] High risk or a CI/build change: the user read the diff and said go before the push.
- [ ] Only the topic branch is pushed, with an explicit refspec.
- [ ] Target branch set explicitly.
- [ ] Description: Tested, Risk, How to revert.
- [ ] Give the link (or the branch and diff command). Level `ask`: stop.

## 7. Merge and release

- [ ] Levels `ask` and `change-request`: the user said go for this merge.
- [ ] Levels `merge` and `release`: every gate in autonomy.md checked again right before the
      merge and right before the release; no admin or bypass flags.
- [ ] Verify the merge through the host CLI, the API or git.
- [ ] Before a release: list everything else that would go live with it.
- [ ] After the release: wait a few minutes, then measure the "done when" items.
- [ ] Automatic merge or release: the one-line report with the revert command.
