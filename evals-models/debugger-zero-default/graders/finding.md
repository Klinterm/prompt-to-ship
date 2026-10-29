---
type: llm
weight: 1
focus: last_message
---

Pass when the final message ranks first the cause that line_price uses 0 as the default for a SKU without a price (prices.get(sku, 0)), after the new catalogue import left some SKUs without a price. Fail when another cause is ranked first.
