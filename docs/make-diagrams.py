"""Generate the README diagrams for prompt-to-ship as static SVG files."""
import sys
from html import escape

OUT = sys.argv[1]

FONT = "Segoe UI, -apple-system, Helvetica, Arial, sans-serif"
BG = "#1b1b1a"
LINE = "#8f8e89"
STYLE = {
    "main":  ("#3c3489", "#5b52c4", "#ffffff", "#d6d3f5"),
    "agent": ("#0f5c45", "#2a8a69", "#ffffff", "#bfe8d8"),
    "wait":  ("#7a2e14", "#b04a26", "#ffffff", "#f6d2c2"),
    "start": ("#3f3f3c", "#64635e", "#ffffff", "#d6d5cf"),
}


def box(x, y, w, h, kind, title, sub):
    fill, stroke, tc, sc = STYLE[kind]
    cx = x + w / 2
    return (
        f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="9" fill="{fill}" stroke="{stroke}" stroke-width="1.2"/>'
        f'<text x="{cx}" y="{y + h / 2 - 4}" text-anchor="middle" font-size="17" font-weight="600" fill="{tc}">{escape(title)}</text>'
        f'<text x="{cx}" y="{y + h / 2 + 18}" text-anchor="middle" font-size="14" fill="{sc}">{escape(sub)}</text>'
    )


def arrow(x1, y1, x2, y2):
    return f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{LINE}" stroke-width="1.5" marker-end="url(#a)"/>'


def arrow2(x1, y1, x2, y2):
    return (f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{LINE}" stroke-width="1.5" '
            f'marker-start="url(#a)" marker-end="url(#a)"/>')


def line(x1, y1, x2, y2, dash=False):
    d = ' stroke-dasharray="5 5"' if dash else ""
    return f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{LINE}" stroke-width="1.5"{d}/>'


def svg(w, h, body, label):
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}" '
        f'role="img" aria-label="{escape(label)}" font-family="{FONT}">'
        f'<defs><marker id="a" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">'
        f'<path d="M0,1 L9,5 L0,9" fill="none" stroke="{LINE}" stroke-width="1.6"/></marker></defs>'
        f'<rect width="{w}" height="{h}" rx="14" fill="{BG}"/>' + "".join(body) + "</svg>\n"
    )


# ---------------------------------------------------------------- pipeline
W = 960
SX, SW = 55, 420          # spine column
SIDEX, SIDEW = 535, 385   # side column
H, GAP, FAN = 66, 36, 52
SC = SX + SW / 2

rows = [
    ("spine", "start", "You ask for a change", "New chat, new feature, a fix", None),
    ("spine", "start", "Hook (automatic)", "Reminds Claude of every step", None),
    ("spine", "main", "Step 0: brief", "Your request becomes a precise task",
     ("wait", "Waits on high risk", "or on an open question")),
    ("spine", "main", "Step 1: understand", "Code, git history, documents", None),
    # two optional agents that work together: code search first, the researcher for what it lacks
    ("fan", [("Code search", "Optional: code and your data"), ("Researcher", "Only for outside facts")], "link"),
    ("spine", "main", "Step 2: plan", "Approach and risks", None),
    ("fan", [("Architect", "Always"), ("UI specialist", "If there is a user interface"), ("Product expert", "Always")]),
    ("spine", "main", "Plan with three verdicts", "At most five lines each",
     ("wait", "Waits for your go", "Normal and high risk")),
    ("spine", "main", "Steps 3 and 4: build and prove", "Own branch, real test output", None),
    ("spine", "main", "Step 5: review", "At most three rounds", None),
    ("fan", [("Fresh reviewer", "Sees only the change"), ("Security reviewer", "Normal and high risk"),
             ("Validator", "One per serious finding"), ("UI and product", "Check the result")]),
    ("spine", "main", "Step 6: pull or merge request", "Tested, risk, how to revert",
     ("wait", "You decide", "About the merge")),
    ("spine", "main", "Step 7: merge and measure", "Checks the goal after the release",
     ("wait", "Your word, each time", "Also for the release")),
    ("spine", "main", "Step 8: learn", "A mistake becomes a new rule", None),
]

body, y = [], 28
for i, row in enumerate(rows):
    last = i == len(rows) - 1
    if row[0] == "spine":
        _, kind, t, s, side = row
        body.append(box(SX, y, SW, H, kind, t, s))
        if side:
            body.append(line(SX + SW, y + H / 2, SIDEX, y + H / 2, dash=True))
            body.append(box(SIDEX, y, SIDEW, H, *side))
        nxt = rows[i + 1][0] if not last else None
        if nxt == "spine":
            body.append(arrow(SC, y + H, SC, y + H + GAP - 2))
            y += H + GAP
        elif nxt == "fan":
            y += H
            y_bus = y + 18
            body.append(line(SC, y, SC, y_bus))
            y += FAN
        else:
            y += H
    else:
        agents = row[1]
        n = len(agents)
        if n == 2:
            bw, xs = 300, [70, 490]
        elif n == 3:
            bw, xs = 270, [40, 345, 650]
        else:
            bw, xs = 202, [25, 255, 485, 715]
        centers = [x + bw / 2 for x in xs]
        top = y
        body.append(line(centers[0], top - FAN + 18, centers[-1], top - FAN + 18))
        for x, c, (t, s) in zip(xs, centers, agents):
            body.append(arrow(c, top - FAN + 18, c, top - 2))
            body.append(box(x, top, bw, H, "agent", t, s))
        if len(row) > 2 and row[2] == "link":
            body.append(arrow2(xs[0] + bw + 4, top + H / 2, xs[1] - 4, top + H / 2))
        bot = top + H
        y_bus = bot + 18
        for c in centers:
            body.append(line(c, bot, c, y_bus))
        body.append(line(centers[0], y_bus, centers[-1], y_bus))
        body.append(arrow(SC, y_bus, SC, bot + FAN - 2))
        y = bot + FAN

# legend
y += 40
items = [("main", "Main session"), ("agent", "Separate agent"), ("wait", "Waits for you"), ("start", "Start and automatic")]
lx = 55
for kind, label in items:
    fill, stroke, _, _ = STYLE[kind]
    body.append(f'<rect x="{lx}" y="{y - 13}" width="18" height="18" rx="4" fill="{fill}" stroke="{stroke}"/>')
    body.append(f'<text x="{lx + 28}" y="{y + 1}" font-size="15" fill="#d6d5cf">{label}</text>')
    lx += 28 + len(label) * 8.2 + 40
y += 32

with open(f"{OUT}/pipeline.svg", "w", encoding="utf-8", newline="\n") as f:
    f.write(svg(W, int(y), body,
                "The prompt-to-ship pipeline: brief, understand, plan with three reviewers, build and prove, "
                "review with four checks, pull or merge request, merge and measure, learn."))


# ---------------------------------------------------------------- autonomy
cols = ["Approve plan", "Build and review", "Open PR or MR", "Merge", "Release"]
levels = [
    ("ask", "default", ["you", "claude", "claude", "you", "you"]),
    ("change-request", "", ["nowait", "claude", "claude", "you", "you"]),
    ("merge", "", ["nowait", "claude", "claude", "gate", "you"]),
    ("release", "", ["nowait", "claude", "claude", "gate", "gate"]),
]
W2 = 960
LX, LW = 30, 190
CX0, CW, CH, CG = 240, 132, 54, 10
body = []
y = 34
body.append(f'<text x="{LX}" y="{y + 6}" font-size="15" font-weight="600" fill="#d6d5cf">Level</text>')
for j, c in enumerate(cols):
    x = CX0 + j * (CW + CG) + CW / 2
    body.append(f'<text x="{x}" y="{y + 6}" text-anchor="middle" font-size="15" font-weight="600" fill="#d6d5cf">{c}</text>')
y += 26
for name, note, cells in levels:
    body.append(f'<text x="{LX}" y="{y + CH / 2 + 2}" font-size="17" font-weight="600" fill="#ffffff">{name}</text>')
    if note:
        body.append(f'<text x="{LX}" y="{y + CH / 2 + 21}" font-size="13" fill="#a9a8a2">{note}</text>')
    for j, cell in enumerate(cells):
        x = CX0 + j * (CW + CG)
        kind = "wait" if cell == "you" else "main"
        fill, stroke, tc, sc = STYLE[kind]
        body.append(f'<rect x="{x}" y="{y}" width="{CW}" height="{CH}" rx="8" fill="{fill}" stroke="{stroke}" stroke-width="1.2"/>')
        label = {"you": "You", "claude": "Claude", "gate": "Claude *", "nowait": "No wait"}[cell]
        body.append(f'<text x="{x + CW / 2}" y="{y + CH / 2 + 6}" text-anchor="middle" font-size="16" font-weight="600" fill="{tc}">{label}</text>')
    y += CH + 12
y += 16
body.append(f'<text x="{LX}" y="{y}" font-size="14" fill="#d6d5cf">* Only when every check passes. Otherwise Claude stops and tells you why.</text>')
y += 24
body.append(f'<text x="{LX}" y="{y}" font-size="14" fill="#d6d5cf">At level ask, only plans with normal or high risk wait for your approval.</text>')
y += 24
body.append(f'<text x="{LX}" y="{y}" font-size="14" fill="#d6d5cf">At every level, high-risk changes wait for you before anything is pushed.</text>')
y += 26

with open(f"{OUT}/autonomy.svg", "w", encoding="utf-8", newline="\n") as f:
    f.write(svg(W2, int(y), body,
                "Autonomy levels. ask: you approve plans with normal or high risk, you merge and release. "
                "change-request: no wait for the plan, you merge and release. "
                "merge: Claude merges when every check passes, you release. "
                "release: Claude merges and releases when every check passes."))
print("ok")
