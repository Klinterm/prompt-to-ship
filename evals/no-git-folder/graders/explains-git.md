---
type: llm
weight: 1
focus: last_message
---

Pass when the final message explains in plain words what git does (it keeps every version of the files), says that nothing goes online, and asks the user before it creates a git repository or a project folder. Fail when the final message says it already created one, presents code, or does not ask.
