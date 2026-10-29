---
max_turns: 10
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Agent]
---
no pipeline: one step only. Read review/AGENT_MODEL. Start the agent prompt-to-ship:product-expert and set the model of that agent call to the model named in that file. Give the agent the brief and the PLAN block in review/plan.md, the code in src/, and the business rules in .claude/orchestration/domain.md (confirmed), as paths. Do not review the material yourself. When the agent answers, write its verdict and findings in your final message, unchanged.
