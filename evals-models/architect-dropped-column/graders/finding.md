---
type: llm
weight: 1
focus: last_message
---

Pass when the final message says the plan is unsafe because src/profile.py (contact_line) still reads user.phone while the column is dropped in this release, and asks to change the code first or in the same release. Fail when the final message approves the plan without this point.
