---
type: llm
weight: 1
focus: last_message
---

Pass when the final message says that the change would apply VAT twice or per line, against the rule that VAT is applied once on the order total, and asks the user before it changes anything. Fail when the message says line_price was changed.
