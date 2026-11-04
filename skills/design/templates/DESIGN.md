---
# DESIGN.md tokens. The YAML block is the source of truth for values.
# The code (CSS variables, theme file, design tokens) must match it.
# Replace every <...>. Delete lines you do not use.
name: <product or screen>
status: draft            # draft | locked <date> | extracted <date>
source: new              # new | extracted from <files or URL>
colour:
  ink:     { value: "<hex or oklch>", role: "text, rules", reason: "<...>" }
  surface: { value: "<...>", role: "page background", reason: "<...>" }
  accent:  { value: "<...>", role: "primary action, focus ring", contrast_on_surface: "<x:1>", reason: "<tied to the subject>" }
  accent_text: { value: "<...>", role: "accent for small text and links", contrast_on_surface: "<x:1>", reason: "<...>" }
  # 2 or 3 colours plus variants. Each colour has one role.
type:
  display: { family: "<...>", weights: [<...>], licence: "<...>", reason: "<tied to the subject>" }
  text:    { family: "<...>", weights: [<...>], licence: "<...>", reason: "<...>" }
  utility: { family: "<optional>", use: "<metadata, tables>" }
scale:                    # 5 or 6 steps; display at least 3x body (marketing) or 1.6x (app UI)
  display: { size: "<clamp(...)>", line_height: <0.9 to 1.0>, tracking: "<-0.01em>" }
  h2:      { size: "<...>", line_height: <1.05 to 1.2> }
  h3:      { size: "<...>", line_height: <...> }
  body:    { size: "<16 to 18px>", line_height: <1.45 to 1.6>, measure: "65ch" }
  small:   { size: "<...>", use: "metadata" }
space:
  unit: <4 or 8>          # every gap is a multiple
  scale: [<4, 8, 12, 16, 24, 32, 48, 64>]
  section: { tight: "<...>", base: "<...>", wide: "<...>" }
  reason: "<density for the task, for example compact for daily data entry>"
radius: { value: "<0 | 2px | 4px | ...>", reason: "<...>" }   # one value, two at most
shadow: { value: "<none or one value>", reason: "<...>" }
motion:
  reason: "<which state changes move, and why>"
  ease: "<cubic-bezier(...)>"
  duration: { fast: "<150ms>", base: "<250ms>", slow: "<300ms>" }
  reduced_motion: "<fade or cut>"
breakpoints: [<480, 800, 1200>]
components:
  library: "<name or none>"
  icons: "<set name or none>"
# Scene mode only (references/immersive.md). Uncomment only when the user picked a scene.
# scene:
#   reason: "<what the scene shows that text cannot>"
#   elements: { "<object>": "<the thing it stands for>" }
#   budget: { first_text: "<s>", scene_download: "<MB>", frame_rate: "<fps on a named device>", frames_checked: "<n>" }
#   fallback: "poster when: no 3D support, lost context, reduced motion, save-data, frame rate under budget"
#   url: "<format for chapter and level, for example #chapter?level=plain>"
#   levels: ["<plain>", "<technical>"]
---

# <name>: design

## Product

Skip this section when the project already has a product file (for example
`.claude/orchestration/PROJECT.md`). Then write only: "Product: see <path>".

- **Users:** <who uses this, in which situation, on which device>
- **Goal:** <the one thing they must get done here>
- **Tone:** <how the product talks, with one example sentence>
- **Idea sentence:** <what this screen is and for whom, concrete nouns>
- **Details only this subject has (8 to 12):**
  1. <...>
- **Proof we have (with source):** <reviews, numbers, logos the user confirmed, or "none">

## House style

- **Exists:** <yes / no>
- **Extracted from:** <token files, theme file, component library, screens, URL>
- **Rule:** extend, never restyle. Any new value needs a line here first.
- **Drift found:** <values in the code that are not in the YAML block, with file and line>

## References

| Reference | Why the user likes it (their words) | Take | Avoid |
|---|---|---|---|
| <screenshot or URL> | <...> | <structure, proportion, rhythm> | <...> |

## Visual language

- **Name:** <for example "departure board">
- **Three words (not modern, clean, sleek, minimal):** <...>
- **Parts it produces:** <for example "status as a stamp">
- **Physical law:** <for example "everything sits on a ruled line">

## Directions

New key screen only. Three directions, hero only.

| Direction | Language | Type pair | Density | Shape | Colour logic | One risk |
|---|---|---|---|---|---|---|
| A | <...> | <...> | <...> | <...> | <...> | <...> |
| B | <...> | <...> | <...> | <...> | <...> | <...> |
| C | <...> | <...> | <...> | <...> | <...> | <...> |

**Picked:** <direction or combination>, by <user>, <date>, because <reason>.
Write "not approved by user" when you picked on the user's request.

**Rejected directions:** <direction, reason in the user's words>. Do not reuse them.

## Components

For each: states (default, hover, focus visible, active, disabled, error, empty, loading) and
the tokens it uses.

- **Primary action:** <...>
- **Second action:** <text link>
- **Navigation:** <labels in screen order>
- **Forms and errors:** <inline errors next to the field; toast only for outcomes outside the view>
- **Lists, tables, numbers:** <...>
- **Images:** <treatment, crops per width>

## Do

- <one rule with a number or a named place, for example "accent only on the primary action and the focus ring">

## Don't

- Copy the Reflex list from `references/tiers.md` here.
- No invented proof: no reviews, logos, numbers or quotes without a confirmed source.
- <project rule>

**Reflex exceptions** (a Reflex pattern kept on purpose):

| Pattern | Where | Reason: the user need it serves |
|---|---|---|
| <...> | <...> | <...> |

## Critique log

| Round | Audit (of 18) | Floor failures | Reflex hits | 5-second test | Screenshots |
|---|---|---|---|---|---|
| 1 | <...> | <...> | <...> | <pass / what they said> | <paths> |

| Round | Fix | Before (measured) | After (measured) |
|---|---|---|---|
| 1 | <...> | <...> | <...> |

Not tested, and why: <...> (scene mode: each budget number not measured)
