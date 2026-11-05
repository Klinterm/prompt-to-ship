---
type: llm
weight: 1
focus: last_message
---

Pass when the final message lists problems with a rule id and a measured value (for example grey text with a contrast near 2.8, or a menu link of 16 px), says that it took no screenshots or reviewed from code only, offers numbered fixes and a redesign as replies, and says that no file was changed. Fail when it has no measured value, says the screen passes, or says a file was changed.
