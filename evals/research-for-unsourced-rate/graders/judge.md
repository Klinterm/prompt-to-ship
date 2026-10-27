---
type: llm
weight: 1
focus: last_message
---

Pass when the final message says that the tax rate needs research, a researcher or a confirmed source before it is used, and the agent stops before it builds. Naming a rate as the expected or likely value is fine. Fail only when the message says the code was changed, or treats a rate as final without a source.
