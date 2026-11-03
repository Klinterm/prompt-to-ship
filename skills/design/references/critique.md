# Screenshot critique

Scripts catch what is broken. Only eyes catch what is dull, stiff or chaotic. This loop does
both: checks first, then a written critique of real screenshots against fixed criteria. A
screenshot without criteria is decoration.

The loop only converges on one locked system (`DESIGN.md`). Without one it churns.

## 1. Render

Each round, capture the same set, so round N compares with round N-1:

1. Widths 375, 768 and 1440. Add 320 for the overflow check.
2. Light theme. Dark theme too, if the design has one.
3. Before each capture: wait for the fonts, stop all animation, check that the page is really
   visible (a hidden browser tab does not paint, so its screenshots mean nothing).
4. Save the files when another agent must review them, for example
   `shots/<round>/<screen>-<width>.png`.

Use the browser tool that the environment offers. Examples: a built-in browser preview, or a
headless browser script. Do not install one without asking.

Two extra shots on the 1440 view:

- **Blur shot.** Blur the page by about 6px. Only blocks remain. The main heading and the
  primary action must be the two strongest shapes.
- **Grayscale shot.** Remove all colour. Order and meaning must survive.

## 2. Checks before the critique

Run the items marked "yes" in `tiers.md` first. Fix every Floor failure before you judge the
design. Deterministic checks do not drift the way taste does. Typical checks:

| Check | Pass |
|---|---|
| Token drift: count distinct fonts, sizes, colours, radii and shadows on the rendered page | Within the counts in `DESIGN.md` |
| Contrast of every text element on its real background | 0 failures |
| Overflow at 320 and 375, measured on element boxes | 0 offenders |
| Hidden content after 3 seconds, tab visible and in the background | 0 text elements at opacity 0 |
| Structure scan: rows of identical boxes, icon tiles, pills, gradients, gradient text, glow, eyebrows | Every hit fixed or written down as a Reflex exception |
| Banned characters and words in the copy | 0 hits |
| Console errors and failed assets | 0 |

## 3. The audit: hierarchy, clarity, craft

Score each criterion 0 (fails), 1 (partly) or 2 (meets). Maximum 18.

### Hierarchy

| # | Criterion | Scores 2 when |
|---|---|---|
| H1 | Focus | In the blur shot, the main heading and the primary action are the two strongest shapes. |
| H2 | One primary action | At most one primary action per view. The first view has one. |
| H3 | Grouping | Space between groups is larger than inside a group. Order survives the grayscale shot. |

### Clarity

| # | Criterion | Scores 2 when |
|---|---|---|
| C1 | 5-second test | A stranger says what the screen is and for whom after 5 seconds (section 4). |
| C2 | Claims with proof | Each section makes one claim and shows its proof. No invented proof. |
| C3 | Words | Labels name what happens. Errors say what to do. No hype words. |

### Craft

| # | Criterion | Scores 2 when |
|---|---|---|
| K1 | System | Only tokens from `DESIGN.md`. Type, colour and spacing within the counts. |
| K2 | Responsive | At 320 and 375 the hierarchy is rethought, not only stacked. No overflow. |
| K3 | States and motion | Hover, focus, active, error, empty and loading states exist. Motion only on state changes, reduced motion respected. |

For every score below 2, write the evidence: the region, the element, the broken rule and the
measured value.

- Good: "hero heading 52px against body 18px, ratio 2.9, rule needs 3".
- Bad: "the hero feels weak".

## 4. The 5-second test

1. Show the first screen at 1440 and at 375 to someone who did not build it.
2. After 5 seconds, hide it.
3. Ask: what is this, who is it for, what can you do here?
4. Pass: all three answers match the idea sentence in `DESIGN.md`.

In an agent setup, a fresh-context reviewer plays the stranger. Give it only the screenshots,
no code, no brief, no chat. Compare its answers with the idea sentence yourself.

## 5. The loop

1. Render (section 1).
2. Run the checks (section 2). Fix Floor failures.
3. Score the audit (section 3), region by region. Zoom in on the navigation, the hero, each
   section and the footer.
4. Compare with the approved hero or reference at the same width. Write 3 measured
   differences (type size ratio, section padding, accent area).
5. Pick the top 3 problems. Fix those only. Fixing everything at once causes churn.
6. Log each fix with a measured value before and after. A fix without an after value does not
   count.

## 6. Fresh reviewer

Prefer a reviewer that did not build the screen. Give it the screenshots (or a URL), `DESIGN.md`
and this file. Instruction for the reviewer:

> You did not build this. Score each audit criterion 0, 1 or 2 against DESIGN.md only. For each
> score below 2, give the region, the element, the rule and the measured value. List the 3
> worst problems. Do not propose new decoration.

The builder may not change the reviewer's scores.

## 7. Stop conditions

Stop the loop when all of these hold:

- No Floor failure.
- Every Reflex hit has a written reason or is gone.
- No audit criterion scores 0, and the total is 15 or more of 18.
- The 5-second test passes.

Stop and ask the user when:

- 3 rounds are done and the conditions do not hold. Show the last screenshots and the 3
  lowest criteria.
- Two rounds in a row bring no gain.
- The same problem fails after 2 fixes. Stop that approach and say what you tried.
- The critique starts to propose more decoration. That means the direction is weak, not the
  details.

## 8. Asking the user

After round 2, or when the loop stops, show the 1440 and 375 screenshots. Ask for a marked-up
screenshot, or one of these words: "too loud", "too busy", "too stiff", "boring". Turn the
answer into token changes. "Boring" or "still looks generated" means the direction failed: go
back to step 1 of the skill. Do not tune tokens.

## 9. Log

Write each round in `DESIGN.md` under "Critique log": round, audit scores, Floor failures,
Reflex hits, the 3 fixes with before and after values, and the screenshot paths.
