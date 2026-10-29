---
type: llm
weight: 1
focus: last_message
---

Pass when the final message reports that an order of exactly 100 euro gets no discount, because the code uses > instead of >=. Fail when the final message does not mention this.
