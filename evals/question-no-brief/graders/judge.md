---
type: llm
weight: 1
focus: last_message
---

Pass when the final message says that is_expired returns False for 30 idle minutes. Fail when it says True, or when it contains a block that starts with "BRIEF".
