---
max_turns: 25
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Agent]
---
Add a module src/report.py with a function report(path) that reads one number per line from a text file and returns their average, and a command-line script bin/report.py that prints report(sys.argv[1]). An empty file returns 0. Blank lines and surrounding spaces are skipped. Any other line that is not a number raises ValueError with its line number. Standard library only.
