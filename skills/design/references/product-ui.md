# Product UI: apps, dashboards, admin screens, forms

Read this for working tools, not for marketing pages. In a tool the user comes back every day:
speed, density and clarity beat surprise.

## Start from the work, not from a hero

1. List the users and their tasks. For each task: how often, how urgent, on which device.
2. Get real data at its extremes before layout: no rows, one row, 10,000 rows, a very long name,
   a missing value, a translation 40 percent longer than English, a number with 9 digits.
3. The "hero" of an app is its main working view plus the shell: navigation, search, filters
   and the density of the main list or table. Design and approve that first.

## Density and tables

- Choose one density on purpose (compact, regular) and keep it everywhere.
- Align numbers to the right, with the same number of decimals and a tabular figure style.
- Text to the left. Never center a table column with text.
- Show the sort order. Keep the header visible on a long list.
- Truncate long text with the full value on hover or focus, never silently.
- Empty state: says why it is empty and gives the one action that fills it.

## Forms and validation

- One column. Labels above the field. Mark the optional fields, not the required ones, when most
  are required.
- Validate when the user leaves a field, not on every key.
- An error says what is wrong and how to fix it, next to the field, and keeps the input.
- The submit button says what happens ("Save invoice"), not "Submit". Show progress and block a
  double submit.

## Charts

- Every chart answers one question; write it as the title.
- Label axes and units. Start a bar chart at zero.
- Do not use colour alone: add labels, patterns or direct labels. Check for colour blindness.
- Fewer than 7 series. More: a table.

## Navigation and keyboard

- One navigation pattern for the whole product. The current place is always visible.
- Focus order follows the reading order. Every action works with the keyboard; frequent actions
  get a shortcut that is shown in the interface.
- A destructive action asks once, says what is lost, and offers undo when it can.

## States and feedback

- Every action registers. Only state changes that matter get motion (200 to 300 ms) or a
  message: money, a finished job, a level reached. Plain clicks stay quiet.
- Loading: a skeleton for content, a progress bar for work longer than 2 seconds.
- Respect reduced motion.

## Dark mode

- Only when the product needs it. Then design it, do not invert it: lower contrast for large
  surfaces, no pure black behind text, check every token in both modes.
