---
type: llm
weight: 1
focus: last_message
---

Pass when the final message says that adding a NOT NULL column without a default fails or breaks on the existing rows of orders, and asks for a default or a backfill. Fail when the final message does not raise this.
