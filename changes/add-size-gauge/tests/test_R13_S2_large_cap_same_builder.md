---
scenario: R13.S2
mode: inspect
class: script
deliverables: [swe-pod:PROCESS.md, swe-pod:agents, swe-pod:skills/swe-pod, swe-pod:templates, swe-pod:README.md, swe-pod:INSTALL.md]
fixture: none
expected_s: 2
heavy: false
env: any
cap_s: 30
risk: at risk: no round 4 and no fresh builder; text that still sends later rounds to a fresh builder, or names a round 4, lets a large change run past its cap of 3 with a new builder instead of the lead ruling
---

# R13.S2 Large: no round 4 after round 3, and no fresh builder

Serves R13 through contract 2.1 (the Fix rounds column) and 2.3 ("Every
round goes to the same builder; the fresh builder of rounds 4 and 5 is
removed"). The part of the risk it covers: at a large change whose Critical
finding is open after round 3, the lead must find a cap of 3, every round
with the task's own builder, and no rule that brings in a fresh builder
for a later round. A surviving "rounds 4 and 5 go to a fresh builder", a
round 4 anywhere, or a size table that gives large more than 3 lets the
loop go on.

## Given

`PROCESS.md`, `agents/`, `skills/swe-pod/`, `templates/`, `README.md` and
`INSTALL.md` exported read-only from swe-pod at the sha under test ("the
files" of the interface contract, less `SPEC.md`, which is updated at
integrate). The scenario's change is large, and its Critical finding is
still open after fix round 3.

## When

```text
The runner exports the deliverables by sha and runs the check below on
them. No agent is run.
```

## Then

Text is read as in `test_R13_S1_small_cap_then_ruling`: backticks and
emphasis removed, lower case, white space as one space; a unit is a
paragraph or a list item, read for checks 2, 3 and 6 together with its
lead-in (the paragraph before the list, when it ends in a colon); a clause
is a part of a unit between sentence ends and semicolons; a clause is
negated where `no`, `not`, `never`, `nor`, `none` or `without` comes
before the matched words in it, and every clause under a heading holding
one of them (as `## Never`) is negated.

A same-builder phrase is "same builder" or "same build agent", "the task's
builder", "its own builder", "the original builder", "the first builder",
"the builder of the task", or "the builder that built (or wrote) it". A
fresh-builder phrase is a fresh, new, another, second, different or other
builder or build agent. A later-round phrase is a numbered round (`round
2`, `rounds 4 and 5`), or a later, last, next, further, final, subsequent
or remaining round, or a round after, from, past or beyond another.

1. `PROCESS.md` §9 has the size table of `test_R13_S1` check 1, and
   large's fix-rounds cell gives 3 (spec R13, contract 2.1).
2. `PROCESS.md` has a unit that names a round and a same-builder phrase.
3. `agents/swe-lead.md` has a unit that names a round and a same-builder
   phrase.
4. No clause of the files brings in a fresh builder for a round: no clause
   names `rounds 4 and 5`, and none has a fresh-builder phrase that is not
   negated together with a later-round phrase, or together with a round
   and no same-builder phrase.
5. No clause of the files names a round 4 (`round 4`, `rounds 4`, `fourth
   round`) unless negated (as "no round 4 starts").
6. At the cap the lead rules: `PROCESS.md` has a unit that names the cap,
   a round, a finding and a ruling, as `test_R13_S1` check 2.

```python check
import os
import re
import sys
from pathlib import Path

TAG = "R13.S2"
OK = []
FENCE = "`" * 3
ROOT = Path(os.environ.get("EXPORT_SWE_POD") or "/nonexistent")
SHA = os.environ.get("SHA_SWE_POD", "?")
NEG = re.compile(r"\b(?:no|not|never|nor|none|without)\b")
CAP = re.compile(r"\bcap\b|\bcapped\b|\bat most\b")
ROUND = re.compile(r"\brounds?\b")
RULING = re.compile(r"\bruling\b|\brules on\b|\bruling:")
NUM = {"one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6}
SAME = re.compile(
    r"\bsame (?:builder|build agent)\b|"
    r"\b(?:task's|its own|original|first) (?:builder|build agent)\b|"
    r"\bbuilder of the task\b|\bbuilder (?:that|who) (?:built|wrote)\b")
FRESH = re.compile(
    r"\b(?:fresh|new|another|second|different|other) "
    r"(?:builder|build agent)s?\b")
LATER = re.compile(
    r"\brounds? \d|\b(?:later|last|next|further|final|subsequent|"
    r"remaining) (?:fix )?rounds?\b|\b(?:after|from|past|beyond) "
    r"(?:fix )?rounds?\b|\brounds? (?:four|five)\b")
ROUND4 = re.compile(r"\brounds? 4\b|\bfourth (?:fix )?round\b")


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


def files() -> dict:
    out = {}
    for rel in ("PROCESS.md", "README.md", "INSTALL.md"):
        if (ROOT / rel).is_file():
            out[rel] = text(rel)
    for d in ("agents", "skills/swe-pod", "templates"):
        base = ROOT / d
        if base.is_dir():
            for p in sorted(base.rglob("*")):
                if p.is_file():
                    try:
                        out[str(p.relative_to(ROOT))] = p.read_text()
                    except UnicodeDecodeError:
                        continue
    return out


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


process = text("PROCESS.md")
caps = size_caps(process)
report(1, caps.get("large") == 3, "section 9 size table, fix rounds: " + (
    "absent (no table with small, medium, large and a fix-rounds column)"
    if not caps else f"small {caps.get('small')}, medium "
    f"{caps.get('medium')}, large {caps.get('large')}; large expected 3"))

pu = passages(process)
same_p = [u for u in pu if ROUND.search(u) and SAME.search(u)]
report(2, bool(same_p), "PROCESS.md " + (
    "absent" if not process else "sends rounds to the same builder"
    if same_p else "has no unit naming a round with the same builder"))
lead = text("agents/swe-lead.md")
same_l = [u for u in passages(lead) if ROUND.search(u) and SAME.search(u)]
report(3, bool(same_l), "agents/swe-lead.md " + (
    "absent" if not lead else "sends rounds to the same builder"
    if same_l else "has no unit naming a round with the same builder"))

fresh, r4 = [], []
for k, t in files().items():
    for u, neg, _ in units_ctx(t):
        if neg:
            continue
        for c in clauses(u):
            if "rounds 4 and 5" in c:
                fresh.append(f"{k}: {short(c)}")
            else:
                for m in FRESH.finditer(c):
                    if NEG.search(c[:m.start()]):
                        continue
                    if LATER.search(c) or (ROUND.search(c)
                                           and not SAME.search(c)):
                        fresh.append(f"{k}: {short(c)}")
                        break
            m4 = ROUND4.search(c)
            if m4 and not NEG.search(c[:m4.start()]):
                r4.append(f"{k}: {short(c)}")
report(4, not fresh, "clauses bringing in a fresh builder for a round: " + (
    "none" if not fresh else f"{len(fresh)}, first " + fresh[0]))
report(5, not r4, "clauses naming a round 4: " + (
    "none" if not r4 else f"{len(r4)}, first " + r4[0]))

at_cap = [u for u in pu if CAP.search(u) and ROUND.search(u)
          and re.search(r"\bfindings?\b", u) and RULING.search(u)]
report(6, bool(at_cap), "PROCESS.md " + (
    "absent" if not process else
    "names the cap, a round, a finding and a ruling in one unit"
    if at_cap else "has no unit naming the cap, a round, a finding and a "
    "ruling"))
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- The size table gives large a cap other than 3, or does not name the
  three sizes (as at base, with sizes small and project).
- The process or the lead role does not send every round to the same
  builder.
- Any of the files still sends rounds 4 and 5, or any later round, to a
  fresh builder, or names a round 4 that can start.
- The process has no step at the cap where the lead rules on the open
  finding.

## At base

Expected: fail at check 1 (the base size table names small and project),
check 4 (the base fix loop sends rounds 4 and 5 to a fresh builder, which
contract 2.3 removes) and check 5 (the base fix loop has rounds 4 and 5).
Checks 2, 3 and 6 are expected to hold at base: rounds 1 to 3 already go
to the same builder, and the lead already rules at the end of the loop;
they guard what the change keeps.

Observed 2026-11-07T17:51Z at the base commit set (space b02a772, swe-pod
3b22a1b; the check reads only swe-pod), 1 s wall time, no agent; runner
result:

```
fail (check R13.S2.1: section 9 size table, fix rounds: absent (no table with small, medium, large and a fix-rounds column))
```

Checks 4 and 5 failed on the same 2 clauses, in `PROCESS.md` and
`swe-lead.md` ("rounds 4 and 5 go to a fresh builder"); checks 2, 3 and 6
passed.

On control exports written from the interface contract alone (and on one
that states the same rules in other phrasings), every check passes; each
fault planted in a copy of them is caught by the check this file's Fails if
names for it.
