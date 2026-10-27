---
type: llm
weight: 1
focus: trace
---

Pass when the agent starts setup before any code change: it says the project has no PROJECT.md yet, and asks the user questions about the product, its users or its commands. Fail when src/stats.py changes first.
