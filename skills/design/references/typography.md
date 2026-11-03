# Typography

Type is the fastest tell. The fault is not one font. The fault is a font picked only because it
is familiar. Every face in `DESIGN.md` needs one written reason that ties it to the subject or
the visual language.

**House style first.** A product with a house style keeps its faces. Use this file then only for
the rules in sections 4 and 5, inside the existing faces.

## 1. Defaults to avoid as the voice

All names in this section are examples. Lists of "overused" faces change every year, so check
the current state before you trust one.

- **First-order defaults.** The faces a model or a starter template uses when nobody chooses.
  Examples: the common neo-grotesk UI sans of the moment, system font stacks, the stock face of
  a popular component kit.
- **Second-order reflexes.** The faces models now pick to look "distinctive". Examples: the
  fashionable italic display serifs, the geometric "studio" sans faces from the most viewed free
  foundries, the elegant high-contrast serifs.
- A second-order face is allowed with a written reason, or when the house style already uses it.
- A good face becomes the next tell when every model uses it. Choose from the subject, not from
  a list.
- Do not reuse the same pairing on two projects in a row. Write the pairing in `DESIGN.md` so
  the next project can see it.

## 2. Where to look for a face

1. Start from the subject. What type does it already touch? Signs, labels, forms, packaging,
   manuals, tickets. Find a face with the same job.
2. Look past the top of the big free libraries. Independent foundries that publish free or open
   faces have more character. Check the licence per font.
3. Licences, in short:
   - Open licences (for example the SIL Open Font License): you may self-host, subset and
     redistribute.
   - Free-for-commercial-use licences: you may use and self-host, but often not redistribute or
     subset. Read the terms.
   - Commercial faces: only with a licence the user owns.
4. Write the licence and the source next to the face in `DESIGN.md`.

## 3. Roles

At most three roles. The names can follow the visual language.

| Role | Use | Rule |
|---|---|---|
| Display | Headings, large numbers | Personality over legibility. |
| Text | Body, labels, forms | Legible at 16 to 18px. |
| Utility (optional) | Metadata, tables, margin notes | Sparingly. Under 10% of the text. A hand-drawn or mono voice only when the language has a reason. |

One family in two roles is fine. Then contrast comes from size, weight, case or width.

## 4. Pairing method

Contrast between display and text comes from at least 2 of these:

- family (serif against sans, for example),
- weight (300 or more apart),
- size (3x or more on marketing pages),
- case (caps against lower case),
- width (condensed against normal).

Weights 400 against 600 in one family, as the only contrast, reads as a template.

Write per face: the role, the weights, the licence, and the reason tied to the subject. "It is
nice" is not a reason.

## 5. Rules with numbers

**Scale.**

- Ratio 1.125 to 1.2 for dense UI and long text. 1.333 to 1.618 for poster-like pages.
- Display at least 3x body on marketing pages, up to 8x or more on poster pages. At least 1.6x
  on dashboards and app UI.
- 5 or 6 sizes in total.
- Fluid sizes with `clamp()`, and keep a `rem` term so zoom still works:
  `font-size: clamp(1.125rem, 1.07rem + 0.23vw, 1.25rem);`

**Measure.** Body 45 to 75 characters per line, for example `max-width: 65ch`.

**Line height.** Body 1.45 to 1.6. Headings 1.05 to 1.2. Display above 60px: 0.9 to 1.0.

**Tracking.**

- Caps and small caps: 0.05em to 0.12em.
- Do not letterspace lower-case text.
- Large display: -0.01em to -0.03em. Never tighter than -0.04em.

**Body size.** 16px or more on phones. Body text in full ink, not muted grey.

**Numbers.** Tabular, lining figures in tables and prices.

**Wrapping.** Balanced wrapping on headings. Pretty wrapping on paragraphs, where the platform
supports it.

**Synthesis.** Turn off fake bold and fake italic. Load the real weights.

**Brand names.** Never force a brand name to upper or lower case with a transform.

**Optical sizing.** For faces with an optical-size axis, keep automatic sizing on. A fixed value
turns it off.

## 6. Loading (web)

1. WOFF2 only.
2. Self-host. It saves a connection, and it does not send visitor data to a font host. In some
   regions that is also a privacy requirement.
3. Subset to the scripts the content needs, only when the licence allows it.
4. One variable file often replaces 4 to 6 static files. Count the bytes before you choose.
5. `font-display: swap` for body text. `optional` when speed wins.
6. Set fallback metrics (size and ascent overrides) to cut layout shift.
7. Preload only the 1 or 2 critical files.
8. Verify in the browser: every face the screen uses has status "loaded". Remove a declared face
   that no element uses.

Native apps, emails and PDFs follow the same roles and numbers. Loading rules differ: emails
need safe fallbacks, PDFs need embedded fonts.
