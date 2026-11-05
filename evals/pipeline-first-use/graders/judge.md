---
type: llm
weight: 1
focus: last_message
---

Pass when the final message does both of these: it says the project has no PROJECT.md yet or that setup comes first, and it asks the user at least one question about the product, its users or its commands. Fail when it asks no such question, or when it says that src/stats.py was changed or that average was added.
