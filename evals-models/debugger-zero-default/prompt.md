---
max_turns: 10
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Agent]
---
no pipeline: one step only. Read review/AGENT_MODEL. Start the agent prompt-to-ship:debugger and set the model of that agent call to the model named in that file. Give the agent the CASE in review/case.md, the log in review/app.log and the code in src/, as paths. Do not review the material yourself. When the agent answers, write its verdict and findings in your final message, unchanged.
