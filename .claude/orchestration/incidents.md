Written by stage 8. Edit by hand if you like.

### INC-002 (2026-10-27, miss)
- Symptom: in a test repository whose main branch deploys on every push, autonomy level `merge`
  would let a merge reach production without the user.
- Missed at stage: 2 (plan of the autonomy levels)
- Caught at stage: after the merge (first real test run)
- Root cause: the autonomy design treated merge and release as separate steps.
- What did not work: nothing tried.
- Fix: version 2.3.0, references/autonomy.md "Deploys on merge".
- Lesson: references/autonomy.md "Deploys on merge" (skill repository only)

### INC-001 (2026-10-27, miss)
- Symptom: version 2.1.0 shipped with "version 2.0.0" in the README status line.
- Missed at stage: 4 (prove: the release checks)
- Caught at stage: after the merge (the maintainer saw it)
- Root cause: the README named the version, and no check compared it with plugin.json.
- What did not work: nothing tried.
- Fix: the README names no version and points to CHANGELOG.md.
- Lesson: check command in CI (TESTING.md static check 3, run before each release)
