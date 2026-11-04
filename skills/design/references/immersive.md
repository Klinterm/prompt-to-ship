# Scene mode

Scene mode is for a page whose main form is a 3D scene in the browser: the reader moves through
chapters, and the scene shows structure, scale or space that text alone cannot show. It is a
design option, never a default. The HTML text stays the page; the scene sits on top of it as an
enhancement.

This file owns the scene rules. Floor items F1 to F11 in `tiers.md` stay as they are; this file
only says how to test them on a scene. Inside prompt-to-ship, scene mode exists only with
`Design skill: built-in`.

## 1. When

1. Step 4 may offer a scene as one of the 3 directions, only when the subject passes the reason
   test below. Show it like any direction: the hero, one line, one risk.
2. Scene mode starts only when the user picks that direction or asks for a scene. The lead never
   picks it alone, also not when the user says "pick for me".
3. Record the pick in `DESIGN.md`: uncomment the `scene:` block and fill it.

**The reason test.** The idea sentence names what the scene shows that text and images cannot:
how parts connect, how big things are compared to each other, where things are, or how a
process moves. "It looks impressive" fails. A failed test means no scene.

## 2. The scene block

The `scene:` block in `DESIGN.md` holds:
- the reason (one sentence, from the reason test);
- the element map: every object in the scene, with the named thing it stands for. An object
  without an entry is decoration (R46);
- the budget (section 8);
- the fallback trigger (section 4);
- the URL format for chapter and reading level;
- the reading levels, if any.

## 3. Text first

1. All text, navigation and controls are HTML, above the canvas. Without script, the text and the
   chapter list are there (F8).
2. Each chapter has a text equivalent of what the scene shows there, for example a list of the
   parts and how they connect. Mark the canvas as hidden from assistive technology only when that
   text exists.
3. Labels inside the scene are HTML elements placed over it, so F1 and F9 apply to them.
4. Text sits on a solid or near-solid panel, set by a token. Without a panel, measure contrast
   (F1) on fixed frames: the first frame of each chapter and the frame with the brightest
   background behind the text. Prefer the panel.
5. A dark theme needs its reason in `DESIGN.md` (P13, R23) and its own contrast check.

## 4. Fallback

The poster is a still image of the scene, with alt text, and the same text and navigation.

Show the poster when any of these is true:
- the browser has no 3D support, or the graphics context is lost;
- the user prefers reduced motion;
- the user saves data;
- the frame rate stays below the budget over the frames named in the budget.

A user may still start the live scene by a control. Then camera moves become cuts if reduced
motion is on (a cut is within F4). Stop rendering while the tab is hidden.

## 5. Loading

1. Text and navigation load first. The scene loads after them, or only on request when the user
   saves data or the connection is slow.
2. A loader is added by script, has `role="status"` and a timeout, and never covers text. At the
   timeout, the text stays and the poster shows. A loader that hides text without script fails
   F8; one that blocks text the page already has is R48.
3. The 5-second test runs on the first screen after the loader.

## 6. Chapters and navigation

1. Each chapter has its own URL. Back and forward work.
2. A table of contents in HTML lists the chapters. The current one is marked for assistive
   technology.
3. On a chapter change: focus moves to the chapter heading, and the page title changes.
4. A URL that names no chapter opens chapter 1 with a short message.
5. The scene follows the chapter state, never the other way round.
6. Scroll: the scene may follow native scroll (1:1 with the input; Space, Page Down and the arrow
   keys still scroll). Stepping from chapter to chapter happens only by the page's own controls:
   buttons, keys, or a swipe on the panel. Catching the page's wheel or touch scroll to step is
   R47.

## 7. Motion

1. The camera moves only on a user action, from one chapter to the next. A move may take longer
   than 300 ms (this overrides step 5.3 of the skill), at most 1.5 s. Any new input skips it to
   the end.
2. Idle motion (a slow turn) has a pause control and stops under reduced motion.
3. No other motion on the page goes outside step 5.3.

## 8. Budget

The team writes the budget in the `scene:` block: time to the first text, download size of the
scene, and the frame rate on a named device. These are the team's own numbers; the skill gives
none.

1. Measure each number in step 6, in scene mode only.
2. A miss is a finding to fix. It is never BLOCKING on its own: the budget is not Floor.
3. Without a device or a browser to measure, write "not measured, and why" in the critique log.
   Never invent a number.

## 9. Phone

1. The chapter list becomes a menu button of 44 px (F7).
2. Portrait: the panel sits below the scene or as a bottom sheet. Landscape: the panel sits beside
   the scene, or the scene shrinks.
3. Use dynamic viewport units, so browser bars do not cut the panel.
4. The canvas never traps page scroll: it lets vertical panning through. No scroll area inside the
   panel.
5. The canvas takes no keys and has no focus trap. Orbit controls get a keyboard path, or leave
   them out (F3).
6. A menu or sheet may lock page scroll while it is open, with a visible close control.

## 10. Reading levels (optional)

1. One switch for depth, for example a plain and a technical version: a labelled radio group. It
   is a secondary control, so 24 px is enough (F7). A change of level is announced.
2. The plain and the technical level hold the same facts. A commentary level is labelled as
   opinion.
3. Every number and quote, in every level, is on the "Proof we have" list (F5).
4. Every level exists in every language the product has.
5. The level is part of the URL, in the format the `scene:` block names.

## 11. Critique additions

In step 6, add these states to the usual 3 widths: each chapter, the poster, reduced motion, no
script, a URL that names no chapter, and the first screen after the loader. Add a landscape phone
at 667 x 375. Three rounds stay the limit.
