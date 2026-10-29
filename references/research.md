# Outside facts

The one home for research. Read it at stage 1 when the change may need an outside fact
(pipeline.md, "Terms"), and in debug mode before the researcher starts (debug.md).

Research runs only when the change needs an outside fact: an amount, rate, price, tariff, legal or
tax rule, standard, external API contract or market figure, or the period in which it is valid.
It does not run:
- for code-only work;
- when a project data source (an API or database in "Research scope") supplies the fact: the
  change reads it there;
- when the repository already holds the fact with `source:` and a `valid:` period that covers
  the reference years.

Research runs at the end of stage 1, before the plan, so the plan and its reviewers see the
confirmed fact table. How:
0. Look for the fact in the repository and in the project data sources first (in a large code
   base, with the code search agent). Ask the researcher only for what they lack.
1. Read "Research scope" in PROJECT.md. No scope, or "Research scope: none" while the change
   needs a fact: ask the user for the region, the currency and the reference years (gate 2).
   "Reference years: current" (older files: "Reference year") means the calendar year at stage 0. When the project's data holds
   costs or rates per year, propose the years the change needs from files, schemas, seeds or
   fixtures (never a query on a live database), and let the user confirm them (gate 2).
   Each research question names its year.
2. Give a cost estimate when there are more than ten questions, and wait.
3. Write the questions in public terms: no code, file contents, secrets, customer data or
   internal names. Start `prompt-to-ship:researcher` with the numbered questions and the public
   part of the scope: region, currency, reference years, trusted and excluded sources. It gets
   no project data sources, no brief and no repository access.
4. Start a second `prompt-to-ship:researcher` in check mode with the fact table and the same
   public scope, without the first run's notes. Only CONFIRMED facts go into the change.
5. A REJECTED or NEEDS USER fact, a conflict, a "not found" for a fact the change needs, or a fact
   outside the scope: gate 14 (gates.md).

In the code, every outside fact sits next to two searchable texts, in a comment, a data column or
a config entry: `source: <URL or publisher>` and `valid: <from> to <until>`. The weekly review
finds them by these texts.
