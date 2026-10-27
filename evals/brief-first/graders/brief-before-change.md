---
type: llm
weight: 1
focus: trace
---

Pass when the agent shows a brief with the lines "Goal", "Done when" and "Risk" before its first file change (its first Edit or Write). Pass also when the agent shows the brief and makes no file change at all. Fail when a file changes before the brief, or when no brief appears. Do not fail the run because the agent stops part way or cannot run tests.
