---
scenario: R13.S1
mode: inspect
class: script
deliverables: [swe-pod:PROCESS.md, swe-pod:agents, swe-pod:skills/swe-pod, swe-pod:templates, swe-pod:README.md, swe-pod:INSTALL.md]
fixture: none
expected_s: 2
heavy: false
env: any
cap_s: 30
risk: at risk: no round past 2 at small, a ruling instead; a size table or fix-loop text that still allows a third (or a fifth) round at small, or gives the lead no ruling step at the cap, lets a small change loop on fixes instead of going back to the spec
---

# R13.S1 Small: no round 3 after round 2, a `Ruling:` line instead

Serves R13 through contract 2.1 (the Fix rounds column of the size table)
and 2.3 (the fix loop). The part of the risk it covers: at a small change
the lead, reading the process and its role, must find that the cap is 2,
that at the cap no further round starts, and that it rules on each open
finding in a `Ruling:` ledger line that the final report carries. A size
table that gives small another cap, a fix-loop passage with no ruling step
at the cap, or any surviving statement of 4 or 5 rounds lets round 3 (or
later) start.

## Given

`PROCESS.md`, `agents/`, `skills/swe-pod/`, `templates/`, `README.md` and
`INSTALL.md` exported read-only from swe-pod at the sha under test ("the
files" of the interface contract, less `SPEC.md`, which is updated at
integrate). The scenario's change is small, and its Important finding is
still open after fix round 2.

## When

```text
The runner exports the deliverables by sha and runs the check below on
them. No agent is run.
```

## Then

Text is read with backticks and Markdown emphasis removed, in lower case,
with white-space runs as one space. A unit is a paragraph (a run of
non-blank lines) or a list item; checks 2, 3 and 5 read a list item
together with its lead-in (the paragraph before the list, when it ends in a
colon); a clause is a part of a unit between sentence ends and semicolons.
A clause is negated where `no`, `not`, `never`, `nor`, `none` or `without`
comes before the matched words in it, and every clause under a heading
holding one of them (as `## Never`), or of a list item after a lead-in
that holds one, is negated.
Table cells are compared after removing `*` and backticks; a cap is the
cell's first whole number (or number word).

1. `PROCESS.md` §9 has a table whose first column names small, medium and
   large and which has a column whose header names fix rounds; small's cell
   in that column gives 2 (spec R13, contract 2.1).
2. `PROCESS.md` has a unit that names the cap (`cap`, `capped` or `at
   most`), a fix round (`round` or `rounds`), a finding and a ruling
   (`ruling`, `rules on` or `Ruling:`): at the cap the lead rules on the
   open finding (contract 2.3).
3. `agents/swe-lead.md` has a unit that names the cap, a round and a
   ruling, as in check 2.
4. No clause of the files allows a round past 3 or states a cap above 3:
   none names 4 to 9 (or four to nine) rounds, a round 4 to 9, a fourth to
   ninth round, `rounds 4 and 5`, a fix-round form with a literal cap of 4
   to 9 (as `fix round <r>/5`), or "up to" 4 to 9 with a round, unless the
   clause is negated (as "no round 4 starts").
5. The ruling reaches the final report: `templates/records/final-report.md`
   has a `## Rulings` section, and `PROCESS.md` has a unit that names a
   ruling (or rulings) and the final report.

```python check
import os
import re
import sys
from pathlib import Path

TAG = "R13.S1"
OK = []
FENCE = "`" * 3
ROOT = Path(os.environ.get("EXPORT_SWE_POD") or "/nonexistent")
SHA = os.environ.get("SHA_SWE_POD", "?")
NEG = re.compile(r"\b(?:no|not|never|nor|none|without)\b")
CAP = re.compile(r"\bcap\b|\bcapped\b|\bat most\b")
ROUND = re.compile(r"\brounds?\b")
RULING = re.compile(r"\bruling\b|\brules on\b|\bruling:")
NUM = {"one": 1, "two": 2, "three": 3, "four": 4, "five": 5, "six": 6}
BIG = r"(?:[4-9]|four|five|six|seven|eight|nine)"
STALE = [
    rf"\b{BIG}\s+(?:fix\s+)?rounds?\b",
    r"\brounds?\s+[4-9]\b",
    r"\b(?:fourth|fifth|sixth|seventh|eighth|ninth)\s+(?:fix\s+)?rounds?\b",
    r"\brounds 4 and 5\b",
    r"\bfix rounds?\s+\S*/[4-9]\b",
    rf"\bup to {BIG}\b.*\brounds?\b",
]


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


def units(s: str) -> list:
    return [u for u, _, _ in units_ctx(s)]


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
report(1, caps.get("small") == 2, "section 9 size table, fix rounds: " + (
    "absent (no table with small, medium, large and a fix-rounds column)"
    if not caps else f"small {caps.get('small')}, medium "
    f"{caps.get('medium')}, large {caps.get('large')}; small expected 2"))

pu = passages(process)
at_cap = [u for u in pu if CAP.search(u) and ROUND.search(u)
          and re.search(r"\bfindings?\b", u) and RULING.search(u)]
report(2, bool(at_cap), "PROCESS.md " + (
    "absent" if not process else
    "names the cap, a round, a finding and a ruling in one unit"
    if at_cap else "has no unit naming the cap, a round, a finding and a "
    "ruling"))

lead = text("agents/swe-lead.md")
lu = [u for u in passages(lead) if CAP.search(u) and ROUND.search(u)
      and RULING.search(u)]
report(3, bool(lu), "agents/swe-lead.md " + (
    "absent" if not lead else "names the cap, a round and a ruling in one "
    "unit" if lu else "has no unit naming the cap, a round and a ruling"))

stale = []
for k, t in files().items():
    for u, neg, _ in units_ctx(t):
        if neg:
            continue
        for c in clauses(u):
            for pat in STALE:
                m = re.search(pat, c)
                if m and not NEG.search(c[:m.start()]):
                    stale.append(f"{k}: {short(c)}")
                    break
            else:
                continue
            break
report(4, not stale, "clauses allowing a round past 3: " + (
    "none" if not stale else f"{len(stale)}, first " + stale[0]))

fr = text("templates/records/final-report.md")
rul = any(ln.strip().lower() == "## rulings" for ln in fr.splitlines())
to_fr = [u for u in pu if re.search(r"\brulings?\b", u)
         and "final report" in u]
report(5, rul and bool(to_fr), "final-report template Rulings section "
       f"{'present' if rul else 'absent'}; PROCESS.md unit naming rulings "
       f"and the final report {'present' if to_fr else 'absent'}")
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- The size table gives small a cap other than 2, has no Fix rounds column,
  or does not name the three sizes (as at base, with sizes small and
  project).
- The process or the lead role has no step at the cap where the lead rules
  on the open finding.
- Any of the files still states 5 rounds, rounds 4 and 5, or a fix-round
  form with a literal cap of 5, so a third or later round can start.
- The final report has no Rulings section, or the process does not carry
  rulings into it.

## At base

Expected: fail at check 1, because the base size table names small and
project, not small, medium and large, and gives no small cap of 2; and at
check 4, because the base fix loop allows 5 rounds (the contract removes
"the fresh builder of rounds 4 and 5", and Q2 lists `fix round <r>/5` and
`5 rounds` as stale). Checks 2, 3 and 5 are expected to hold at base: the
lead already rules at the end of the loop and rulings reach the final
report; they guard the ruling step, which the change keeps.

Observed 2026-11-07T17:51Z at the base commit set (space b02a772, swe-pod
3b22a1b; the check reads only swe-pod), 1 s wall time, no agent; runner
result:

```
fail (check R13.S1.1: section 9 size table, fix rounds: absent (no table with small, medium, large and a fix-rounds column))
```

Check 4 failed with 7 clauses (the base "at most 5 rounds per task", its
"rounds 4 and 5 go to a fresh builder", and the `fix round <r>/5` forms
and a `1/5` example in `PROCESS.md`, `swe-lead.md` and the ledger
template); checks 2, 3 and 5 passed.

On control exports written from the interface contract alone (and on one
that states the same rules in other phrasings), every check passes; each
fault planted in a copy of them is caught by the check this file's Fails if
names for it.
