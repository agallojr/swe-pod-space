---
scenario: R13.S4
mode: inspect
class: script
deliverables: [swe-pod:PROCESS.md, swe-pod:agents, swe-pod:skills/swe-pod, swe-pod:templates]
fixture: none
expected_s: 2
heavy: false
env: any
cap_s: 30
risk: at risk: the ledger and status forms carry the cap; a fix-round form that keeps a literal cap (as /5) makes a medium change's line T<n> fix round 2/3 not match the form the skill reads, so STATUS.md misreads or drops it
---

# R13.S4 The fix-round line carries the cap of the change's size

Serves R13 through contract 2.3 ("Ledger line: `T<n> fix round <r>/<cap>:
<a> addressed, <o> open, <sha7>..<sha7>`, with `<cap>` the cap of the
change's size. The skill reads `T<n> fix round` by its prefix, so any cap
reads the same.") and 2.5 (the status-format row `fix round <r>/<cap>: <a>
addressed, <o> open`). The part of the risk it covers: the lead writes, and
the skill reads, one fix-round line form at every size. If the ledger
template or the status format keeps a literal cap, a medium change's
second round, `T<n> fix round 2/3: ...`, and a small change's `2/2` do not
fit the form the skill is told to read.

## Given

`PROCESS.md`, `agents/`, `skills/swe-pod/` and `templates/` exported
read-only from swe-pod at the sha under test. Three ledger lines made for
this test from the spec's caps (R13: 2 at small, 3 at medium and large),
with invented shas:

- medium, the scenario's line: `T2 fix round 2/3: 1 addressed, 0 open,
  1a2b3c4..5d6e7f8`;
- small: `T1 fix round 2/2: 0 addressed, 1 open, 0a1b2c3..4d5e6f7`;
- large: `T4 fix round 3/3: 2 addressed, 1 open, 9a8b7c6..5d4e3f2`.

## When

```text
The runner exports the deliverables by sha and runs the check below on
them. No agent is run.
```

## Then

Text is read with backticks and emphasis removed, in lower case, with
white-space runs as one space. A form's pattern is its text with each
`<...>` placeholder read as one run of characters other than white space,
`/`, `:` and `,`, and every other character literal.

1. `templates/records/ledger.md` holds the contract 2.3 form
   `T<n> fix round <r>/<cap>: <a> addressed, <o> open, <sha7>..<sha7>`.
2. `skills/swe-pod/status-format.md` holds the contract 2.5 form
   `fix round <r>/<cap>: <a> addressed, <o> open`.
3. The fix-round form of the ledger template and of the status format
   (the first on a line that runs from `fix round <` to the next `open`,
   within one table cell), read as a pattern, matches the
   `fix round ... open` part of each of the three lines above.
4. No fix-round form in `PROCESS.md`, the role files, the skill or the
   templates keeps a literal cap: none holds `fix round <r>/` followed by
   a digit.
5. `PROCESS.md` has a unit that names `<cap>` and the size (a `size`
   word): `<cap>` is the cap of the change's size.
6. `PROCESS.md` §9's size table (as `test_R13_S1` check 1) gives medium a
   fix-rounds cap of 3, the cap the scenario's line carries.

```python check
import os
import re
import sys
from pathlib import Path

TAG = "R13.S4"
OK = []
FENCE = "`" * 3
ROOT = Path(os.environ.get("EXPORT_SWE_POD") or "/nonexistent")
SHA = os.environ.get("SHA_SWE_POD", "?")
NEG = re.compile(r"\b(?:no|not|never|nor|none|without)\b")
NUM = {"one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6}
LEDGER_FORM = ("t<n> fix round <r>/<cap>: <a> addressed, <o> open, "
               "<sha7>..<sha7>")
STATUS_FORM = "fix round <r>/<cap>: <a> addressed, <o> open"
LINES = {
    "medium": "T2 fix round 2/3: 1 addressed, 0 open, 1a2b3c4..5d6e7f8",
    "small": "T1 fix round 2/2: 0 addressed, 1 open, 0a1b2c3..4d5e6f7",
    "large": "T4 fix round 3/3: 2 addressed, 1 open, 9a8b7c6..5d4e3f2",
}


def report(n: int, ok: bool, why: str) -> None:
    OK.append(bool(ok))
    print(f"{TAG}.{n} {'pass' if ok else 'fail'} {why}")


def text(rel: str) -> str:
    p = ROOT / rel
    return p.read_text(errors="replace") if p.is_file() else ""


def flat(s: str) -> str:
    s = s.replace("`", "").replace("*", "")
    return re.sub(r"\s+", " ", s).strip().lower()


def units_ctx(s: str) -> list:
    """(unit, negated, lead-in) triples. Units under a heading holding a
    negation (as ## Never), or list items after a negated lead-in ending in
    a colon, are in a negated context. A list item's lead-in is the last
    unit before it that is not a list item and ends in a colon."""
    out = []
    state = {"head": False, "lead": False, "text": ""}

    def emit(lines: list, item: bool) -> None:
        u = flat("\n".join(lines))
        if not u:
            return
        out.append((u, state["head"] or (item and state["lead"]),
                    state["text"] if item else ""))
        if not item:
            colon = u.endswith(":")
            state["lead"] = colon and NEG.search(u) is not None
            state["text"] = u if colon else ""

    for block in re.split(r"\n[ \t]*\n", s):
        cur, item = [], False
        for line in block.splitlines():
            if line.startswith("#"):
                if cur:
                    emit(cur, item)
                cur = []
                state["head"] = NEG.search(flat(line)) is not None
                state["lead"], state["text"] = False, ""
                continue
            is_item = re.match(r"\s*(?:[-+*]|\d+\.)\s", line) is not None
            if is_item and cur:
                emit(cur, item)
                cur = []
            if not cur:
                item = is_item
            cur.append(line)
        if cur:
            emit(cur, item)
    return out


def passages(s: str) -> list:
    """Each unit, a list item read together with its lead-in."""
    return [(ld + " " + u).strip() for u, _, ld in units_ctx(s)]


def clauses(u: str) -> list:
    return [c.strip() for c in re.split(r"\.(?=\s|$)|;", u) if c.strip()]


def h2_sections(t: str) -> dict:
    out, cur, fenced = {}, None, False
    for line in t.splitlines():
        if line.lstrip().startswith(FENCE):
            fenced = not fenced
            continue
        if fenced:
            continue
        if line.startswith("## "):
            cur = line[3:].split(" ", 1)[0]
            out[cur] = []
        elif cur is not None:
            out[cur].append(line)
    return out


def tables(lines: list) -> list:
    found, cur = [], []
    for line in lines + [""]:
        if line.strip().startswith("|"):
            cur.append(line.strip())
        else:
            if len(cur) >= 2:
                rows = [[c.strip() for c in r.strip("|").split("|")]
                        for r in cur]
                body = [r for r in rows[2:] if any(c.strip("-: ")
                                                   for c in r)]
                found.append((rows[0], body))
            cur = []
    return found


def clean(c: str) -> str:
    return c.replace("*", "").replace("`", "").strip().lower()


def cap_cell(v: str):
    m = re.search(r"\b(\d+)\b|\b(one|two|three|four|five|six)\b", clean(v))
    if not m:
        return None
    return int(m.group(1)) if m.group(1) else NUM[m.group(2)]


def size_caps(t: str) -> dict:
    for head, body in tables(h2_sections(t).get("9", [])):
        col = next((i for i, h in enumerate(head)
                    if "fix round" in clean(h)), None)
        if col is None:
            continue
        caps = {}
        for r in body:
            m = re.match(r"(small|medium|large|spike)\b", clean(r[0]))
            if m and col < len(r):
                caps[m.group(1)] = cap_cell(r[col])
        if {"small", "medium", "large"} <= set(caps):
            return caps
    return {}


def short(s: str, n: int = 90) -> str:
    return s if len(s) <= n else s[:n - 3] + "..."


def form_of(t: str) -> str:
    """The first fix-round form on a line of t: from fix round to open."""
    for line in t.replace("`", "").splitlines():
        m = re.search(r"fix round <[^|]*?\bopen\b", line, re.I)
        if m:
            return m.group(0).lower()
    return ""


def pattern(form: str):
    parts = re.split(r"(<[^>]+>)", form)
    rx = "".join(r"[^\s/:,]+" if p.startswith("<") and p.endswith(">")
                 else re.escape(p) for p in parts)
    return re.compile(rx)


def part(line: str) -> str:
    m = re.search(r"fix round .*?\bopen\b", line.lower())
    return m.group(0) if m else ""


ledger = text("templates/records/ledger.md")
fmt = text("skills/swe-pod/status-format.md")
report(1, LEDGER_FORM in flat(ledger), "ledger template " + (
    "absent" if not ledger else "holds the contract 2.3 form"
    if LEDGER_FORM in flat(ledger) else "lacks the contract 2.3 form; "
    "its fix-round form is " + repr(form_of(ledger) or "<none>")))
report(2, STATUS_FORM in flat(fmt), "status-format.md " + (
    "absent" if not fmt else "holds the contract 2.5 form"
    if STATUS_FORM in flat(fmt) else "lacks the contract 2.5 form; "
    "its fix-round form is " + repr(form_of(fmt) or "<none>")))

miss = []
for name, t in (("ledger template", ledger), ("status format", fmt)):
    f = form_of(t)
    if not f:
        miss.append(f"{name}: no fix-round form")
        continue
    rx = pattern(f)
    for size, line in LINES.items():
        if not rx.fullmatch(part(line)):
            miss.append(f"{name} form {f!r} does not match the {size} "
                        f"line")
report(3, not miss, "the three lines against the forms: " + (
    "all match" if not miss else "; ".join(miss[:3])))

lit = []
scan = ["PROCESS.md"] + [str(p.relative_to(ROOT)) for d in (
    "agents", "skills/swe-pod", "templates") if (ROOT / d).is_dir()
    for p in sorted((ROOT / d).rglob("*")) if p.is_file()]
for rel in scan:
    try:
        f = flat(text(rel))
    except UnicodeDecodeError:
        continue
    for m in re.finditer(r"fix round <r>/\d+", f):
        lit.append(f"{rel}: {m.group(0)}")
report(4, not lit, "fix-round forms with a literal cap: " + (
    "none" if not lit else ", ".join(lit[:4])))

process = text("PROCESS.md")
cap_size = [u for u in passages(process) if "<cap>" in u
            and re.search(r"\bsizes?\b", u)]
report(5, bool(cap_size), "PROCESS.md " + (
    "absent" if not process else "ties <cap> to the change's size"
    if cap_size else "has no unit naming <cap> and the size"))

caps = size_caps(process)
report(6, caps.get("medium") == 3, "section 9 size table, fix rounds: " + (
    "absent (no table with small, medium, large and a fix-rounds column)"
    if not caps else f"medium {caps.get('medium')}; expected 3"))
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- The ledger template or the status format keeps a fixed cap in its
  fix-round form (as `fix round <r>/5`), or drops the form.
- A medium line `T<n> fix round 2/3: ...`, a small `2/2` or a large `3/3`
  does not fit the form the lead writes and the skill reads.
- Any fix-round form in the process, roles, skill or templates still
  carries a literal cap.
- The process does not say that `<cap>` is the cap of the change's size,
  or the size table does not give medium 3.

## At base

Expected: fail at checks 1 to 4, because at the base commit set the
fix-round form is `T<n> fix round <r>/5: ...` (Q2 lists `fix round <r>/5`
as stale), and at checks 5 and 6, because the base process has no `<cap>`
and its size table names small and project.

Observed 2026-11-07T17:51Z at the base commit set (space b02a772, swe-pod
3b22a1b; the check reads only swe-pod), 1 s wall time, no agent; runner
result:

```
fail (check R13.S4.1: ledger template lacks the contract 2.3 form; its fix-round form is 'fix round <r>/5: <a> addressed, <o> open')
```

All six checks failed: the status format's form is also
`fix round <r>/5: <a> addressed, <o> open`, so none of the three lines
fits either form, and the literal cap `/5` stands in `PROCESS.md`,
`swe-lead.md`, `status-format.md` and the ledger template.

On control exports written from the interface contract alone (and on one
that states the same rules in other phrasings), every check passes; each
fault planted in a copy of them is caught by the check this file's Fails if
names for it.
