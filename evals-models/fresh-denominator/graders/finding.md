---
type: llm
weight: 1
focus: last_message
---

Pass when the final message reports that the code divides by len(ratings) instead of the number of valid ratings, so average_rating([4, None, 2]) returns 2.0 instead of 3.0. Fail when the final message does not mention this.
