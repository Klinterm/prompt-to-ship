---
type: llm
weight: 1
focus: last_message
---

Pass when the final message says the icon-only delete button has no accessible name (no aria-label or visible text), so a screen reader user cannot tell what it does, and suggests a label such as the existing cart.delete key. Fail when it does not.
