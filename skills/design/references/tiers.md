# Tiers: Floor, Reflex, Finish

Every rule sits in one tier.

- **Floor**: never ships. One failure blocks the release.
- **Reflex**: a default that makes screens look generated. Allowed only with a written reason in
  the plan or in the `DESIGN.md` "Reflex exceptions" table that names a user need (for example:
  "the table is the content"), not a preference. Without a reason, remove it.
- **Finish**: polish. Fix it when it is cheap. It never blocks.

A screen with zero Reflex hits can still be dull. The idea sentence and the visual language give
character. These lists only remove the defaults.

**House style first.** When the product has a house style, its own choices are not Reflex hits.
A product that already uses pill buttons keeps them. Check only new work against the Reflex
list.

A house-style value that fails a Floor item in new code (an accent with too little contrast) is
still a Floor failure. The fix is a new or changed token that the user decides, never a silent
restyle of existing screens.

A "Proof we have" line or a Reflex exception added in the same change counts only after the user
confirms it.

Column "Script": **yes** means a script or a lint rule can find it (on the code or on the
rendered page). **eye** means a person or a vision review must judge it.

## Floor

| # | Rule | Test | Script |
|---|---|---|---|
| F1 | Text contrast | Body text 4.5:1 or more against its real background. Large text and UI parts 3:1. | yes |
| F2 | Focus visible | Tab through the screen. Every control shows a clear focus ring. | yes (style present), eye (visible) |
| F3 | Keyboard use | Every action works with the keyboard alone. No click handler on a plain block element. | yes |
| F4 | Reduced motion | With reduced motion on, no element moves more than a fade. | yes |
| F5 | No invented proof | Every review, logo, number, prize and quote is on the "Proof we have" list in `DESIGN.md` or in the brief, with a source the user confirmed. | yes (against the list) |
| F6 | Phone width works | At 320 and 375: no horizontal scroll, no cut text, navigation works. | yes |
| F7 | Tap targets | Per the platform guide: the main action of a view and the navigation 44 px on the web, 44 pt on iOS, 48 dp on Android. Other controls, also in a compact tool: 24 px or more (the WCAG 2.2 minimum), with 8 px between targets. | yes |
| F8 | Content visible | Content is visible without script and with the tab in the background. Nothing stuck at opacity 0. | yes |
| F9 | Labels and names | Every input has a label. Every image has alt text (empty for decoration). The page has a language set. | yes |
| F10 | Errors in place | Each error sits next to its field, names the field and keeps the input. | yes |
| F11 | Working links | Every link and asset loads. No console errors. No link without a target. | yes |

## Reflex

Each item is allowed only with a written reason in the plan or in the `DESIGN.md` "Reflex exceptions" table that names a user need. "It looks good" is not a reason.

### Layout

| # | Pattern | Test | Script |
|---|---|---|---|
| R1 | The standard kit | 3 or more of: top bar nav, centred hero, filled button pair, row of cards. | eye |
| R2 | Hero taller than the screen | The first screen shows no content below the hero at 1440x900. | yes |
| R3 | Hero eyebrow chip | A small pill or badge above the main heading ("New", "v2 is here"). | yes |
| R4 | Eyebrow on every heading | A tracked caps label above most section headings. | yes |
| R5 | Numbered section labels | "01", "02", "03" when the content has no real order. | yes |
| R6 | Row of 3 icon cards | 3 or 4 equal boxes, each with an icon on top. | yes |
| R7 | Icon tiles | Icons inside tinted rounded squares. | yes |
| R8 | Nested cards | A bordered or shadowed box inside another one. | yes |
| R9 | Side-tab borders | A thick coloured left border on callouts or cards. | yes |
| R10 | Stock section order | Hero, logos, features, stats, testimonials, pricing, call to action band, footer. | eye |
| R11 | Signup at the end of every page | An email signup or "Ready to start?" band above every footer. | eye |
| R12 | Everything at equal weight | In a blur shot, no element stands out. Same padding on every section. | eye |
| R13 | Desktop stacked on mobile | The phone layout is the desktop layout in one column, with no new order. | eye |

### Type

| # | Pattern | Test | Script |
|---|---|---|---|
| R14 | Default face as the voice | The main face is the one a model picks when nobody chooses (see `typography.md`). | yes |
| R15 | Italic serif display | An italic serif headline, or one italic serif word in a sans headline. | yes |
| R16 | One coloured word | One word of the headline in the accent colour. | yes |
| R17 | Tracked tiny caps | Small all-caps text with wide letter spacing as decoration. | yes |
| R18 | Weak size contrast | Display less than 3x body on a marketing page, less than 1.6x on app UI. | yes |
| R19 | Mono as costume | A monospace face only to look technical. | eye |

### Colour and surface

| # | Pattern | Test | Script |
|---|---|---|---|
| R20 | Default purple | Purple, indigo or violet as the main accent. | yes |
| R21 | Gradient fill or text | A gradient on a background, a button or text. A gradient that draws a hard line (a rule, a pattern) is not a fill. | yes |
| R22 | Glow and glass | Coloured shadows, neon, blur panels, blob or aurora backgrounds. | yes |
| R23 | "AI beige" | Cream paper with terracotta, or near-black with one acid accent, with no tie to the subject. | eye |
| R24 | Too many accents | More than one loud colour, or more than 4 accents in total. | yes |
| R25 | Border plus shadow | A card with a thin border and a soft wide shadow at the same time. | yes |
| R26 | Big radius everywhere | The same large radius on cards, buttons and inputs. Pill buttons without a brand reason. | yes |
| R27 | Grey body text | Body text in a muted grey. Muted is for metadata only. | yes |

### Motion and status

| # | Pattern | Test | Script |
|---|---|---|---|
| R28 | Fade-up on every section | Each section animates in on scroll. | yes |
| R29 | Pulsing dots | A pulsing or blinking dot as a "live" sign. | yes |
| R30 | Status-chip overload | More than 3 coloured chips in one view, or a chip where plain text works. | yes |
| R31 | Count-up numbers, marquees | Numbers that count up, text that scrolls on its own. | yes |
| R32 | Toast for everything | A toast for a result the user can already see in the view. | eye |

### Copy and proof

| # | Pattern | Test | Script |
|---|---|---|---|
| R33 | Hype words | Words such as unlock, elevate, seamless, supercharge, effortless (examples). | yes |
| R34 | Twin slogans | Two short parallel sentences as a headline ("Build faster. Ship smarter."). | eye |
| R35 | Contrast formula | "Not just X, it is Y" and its variants. | yes |
| R36 | Arrow after every link | An arrow glyph after each call to action. | yes |
| R37 | Fake thanks form | A contact form that shows "Thanks!" but sends nothing. | eye |
| R38 | Emoji as icons | Emoji used as icons or bullets. | yes |

### The "not AI" kit

Models now use these moves to look less generated. They became a kit of their own. Two or more
without a reason count as one Reflex hit.

| # | Pattern | Script |
|---|---|---|
| R39 | A giant edge-to-edge wordmark | yes |
| R40 | Bracketed mono labels as decoration, such as `[01]` | yes |
| R41 | Grain on everything | yes |
| R42 | Rotated cards or stickers | yes |
| R43 | Asymmetric grid with empty decorative cells | eye |
| R44 | The same "expo out" easing curve on every transition | yes |

### System

| # | Pattern | Test | Script |
|---|---|---|---|
| R45 | Value outside the system | A new colour, font, radius or component that is not in `DESIGN.md` or the house style. | yes |

### Scene

Only on a page with a 3D scene. The scene rules are in `immersive.md`.

| # | Pattern | Test | Script |
|---|---|---|---|
| R46 | 3D as decoration | An object in the scene with no entry in the element map of the `scene:` block, or a scene with no `scene:` block (a turning logo, particles, a globe that shows no data). | yes (list the named scene objects and compare with the map), eye (what an object shows) |
| R47 | Scroll hijack | Native scroll speed or direction is replaced: the page cancels wheel or touch scroll, or uses a scroll-smoothing script, or Space, Page Down and the arrow keys stop scrolling (that last one is also F3). A scroll lock counts when it has no visible close control or stays after its menu closes. A scene that follows native scroll is fine. | yes |
| R48 | Loader before text | With the scene's files blocked or slowed, the chapter text is not visible, or is covered by the loader, before the scene finishes. | yes |

## Finish

| # | Rule | Test | Script |
|---|---|---|---|
| P1 | Line length | Body text 45 to 75 characters per line. | yes |
| P2 | Line height | Body 1.45 to 1.6. Headings 1.05 to 1.2. | yes |
| P3 | Heading wrap | Headings have no single word on the last line. | yes |
| P4 | Alignment | Related left edges sit within 2px of each other. | yes |
| P5 | Spacing on the scale | Every gap is a multiple of the base unit. | yes |
| P6 | Space follows meaning | Space between groups is larger than space inside a group. | eye |
| P7 | One primary action per view | A second action is a text link, not a second filled button. | eye |
| P8 | Concrete labels | Navigation and buttons name what happens ("See prices", not "Learn more"). | eye |
| P9 | Image sizes | Images have width and height set. Below-the-fold images load lazily. | yes |
| P10 | Fonts loaded | Every face the screen uses is loaded. No unused font declarations. | yes |
| P11 | Tabular numbers | Numbers in tables and prices line up. | yes |
| P12 | Share image | The page has a share image in the current style. | yes |
| P13 | Dark theme on purpose | A dark theme exists only when asked for, with its own contrast check. | eye |
| P14 | Helpful errors | Each error says what went wrong and what to do next. | eye |

## How to use the result

1. Count Floor failures. One or more: fix before anything else.
2. List Reflex hits. For each: write a reason that names a user need, or remove it. One instance means
   the whole class: when the user names one tic, remove every instance.
3. Pick the cheap Finish items. Leave the rest in the report.
