---
scenario: R4.S1
mode: inspect
class: script
deliverables: [swe-pod:PROCESS.md, swe-pod:templates/records/plan.md]
fixture: none
expected_s: 2
heavy: false
env: any
cap_s: 30
risk: at risk: sections of the terse plan, kept and left out; a process or plan template that keeps a section a small plan should drop (the global constraints, file map, dependency summary, questions, risk or cost table) weighs a small change down, and one that drops a kept section (the test map, the self-review, the test or review tasks) breaks the trace
---

# R4.S1 The terse plan of a small change: what it keeps, what it leaves out

Serves R4 through contract 2.2: "Kept, with the section numbers of the plan
template: 1 Goal; 2 Interface contract, only where the tests drive a public
surface; 5 Tasks (the one build task); 6 Test tasks (the blind-test task,
verify; no risk table, no expensive-runs table); 7 Review tasks (the
whole-change review); 8 Integrate; 9 Test map; Self-review, filled in. Left
out: 3 Global constraints, 4 File map, 10 Dependency summary, Questions for
the spec." The part of the risk it covers: the planner (or the spec author)
of a small change writes the plan that `PROCESS.md` §4 and the plan
template describe. Both must say which sections a small plan leaves out,
and neither may drop a section the trace and the verify read.

## Given

`PROCESS.md` and `templates/records/plan.md` exported read-only from
swe-pod at the sha under test. The section names are the plan template's
level-2 headings, as `tests/right-size-testing/test_I3_d3_templates.md`
check 4 lists them: Goal and approach, Interface contract, Global
constraints, File map, Tasks, Test tasks, Review tasks, Integrate task,
Test map, Dependency summary, then Self-review and Questions for the spec.
The two tables are the risk table and the expensive-runs (cost) table of
Test tasks.

## When

```text
The runner exports PROCESS.md and the plan template from swe-pod by sha and
runs the check below on them. No agent is run.
```

## Then

Text is read with backticks and Markdown emphasis removed, in lower case,
with white-space runs as one space. A paragraph is a run of non-blank
lines. A small passage is a run of 1 to 6 paragraphs between two headings
of which one paragraph, or the heading above them, names `small`.

A section or table is left out in a passage when its name falls in a
left-out span: the text after a leave-out word (leave out, leaves out, left
out, leaving out, omit, omits, omitted, drop, drops, dropped, skip, skips,
none of, without, no) up to the end of its sentence (a full stop before a
space or the end), a semicolon, a keep word (keep, keeps, kept, retain),
or, where the word stands inside brackets, the closing bracket. Check 3
reads only the spans of the strong leave-out words (all but `without` and
`no`). A section is named by its template name; its number may go with
it. The risk table is named "risk table" (or "risk and cost tables", "risk
or expensive-runs table"); the cost table "cost table", "expensive-runs
table" or "expensive runs".

1. `PROCESS.md` §4 or §9 has a small passage in which Global constraints,
   File map, Dependency summary and Questions for the spec are each left
   out (contract 2.2's "Left out").
2. `PROCESS.md` §4 or §9 has a small passage in which the risk table and
   the cost table are each left out (spec R4: "with no risk table,
   dependency summary or cost table"; contract 2.2: "no risk table, no
   expensive-runs table").
3. In the passage of check 1, none of Goal, Test tasks, Review tasks,
   Integrate, Test map and Self-review is left out by a strong leave-out
   word (contract 2.2's "Kept"; the Interface contract is kept only where
   the tests drive a public surface, so it is not read here).
4. The plan template says the same of a small plan: each of the four
   sections and the two tables is left out in a small passage of the
   template, or, for a section, its own section text names `small` with a
   leave-out word or `not`, or says it is for medium and large only.
5. `PROCESS.md` asks every plan for a test-map row for each scenario (a
   paragraph names the test map, `every`, `each` or `all`, and a scenario)
   and for a self-review with no unchecked item (a paragraph names the
   self-review and an unchecked, filled-in, ticked or checked item): spec
   R4.S1's "a row in its test map for every scenario" and "its self-review
   is filled in with no unchecked item".

```python check
import os
import re
import sys
from pathlib import Path

TAG = "R4.S1"
OK = []
FENCE = "`" * 3
ROOT = Path(os.environ.get("EXPORT_SWE_POD") or "/nonexistent")
SHA = os.environ.get("SHA_SWE_POD", "?")
SMALL = re.compile(r"\bsmall\b")
STRONG = (r"leaves? out|left out|leaving out|omits?|omitted|omitting|"
          r"drops?|dropped|dropping|skips?|skipped|none of")
OUT = re.compile(rf"\b(?:{STRONG}|without|no)\b")
OUT_STRONG = re.compile(rf"\b(?:{STRONG})\b")
KEEP = re.compile(r"\b(?:keeps?|kept|keeping|retains?|retained)\b")
LEFT = {
    "global constraints": r"\bglobal constraints\b",
    "file map": r"\bfile map\b",
    "dependency summary": r"\bdependency summary\b",
    "questions for the spec": r"\bquestions for the spec\b",
}
TABLES = {
    "risk table": r"\brisk (?:(?:and|or|,) (?:the )?(?:cost|expensive[- ]"
                  r"runs?) )?tables?\b",
    "cost table": r"\bcost tables?\b|\bexpensive[- ]runs?\b",
}
KEPT = {
    "goal": r"\bgoal\b",
    "test tasks": r"\btest tasks\b",
    "review tasks": r"\breview tasks\b",
    "integrate": r"\bintegrate\b",
    "test map": r"\btest map\b",
    "self-review": r"\bself-review\b",
}
MEDLARGE = re.compile(
    r"\b(?:medium and large|medium or large|large and medium)"
    r"(?: (?:changes?|plans?|sizes?))? only\b|\bonly (?:at|for|in|on) "
    r"(?:a )?(?:medium|large)\b|\b(?:medium|large) (?:changes?|plans?) "
    r"only\b")


def report(n: int, ok: bool, why: str) -> None:
    OK.append(bool(ok))
    print(f"{TAG}.{n} {'pass' if ok else 'fail'} {why}")


def text(rel: str) -> str:
    p = ROOT / rel
    return p.read_text(errors="replace") if p.is_file() else ""


def flat(s: str) -> str:
    s = s.replace("`", "").replace("*", "")
    return re.sub(r"\s+", " ", s).strip().lower()


def outside(t: str) -> list:
    out, fenced = [], False
    for line in t.splitlines():
        if line.lstrip().startswith(FENCE):
            fenced = not fenced
            continue
        if not fenced:
            out.append(line)
    return out


def h2_sections(lines: list) -> dict:
    out, cur = {"0": []}, "0"
    for line in lines:
        if line.startswith("## "):
            cur = line[3:].split(" ", 1)[0]
            out[cur] = [line]
        else:
            out[cur].append(line)
    return out


def blocks(lines: list) -> list:
    """(heading, paragraphs) for each run of lines between headings."""
    out, head, paras, cur = [], "", [], []
    for line in lines + ["# end"]:
        if line.startswith("#") or not line.strip():
            if cur:
                paras.append(flat("\n".join(cur)))
                cur = []
            if line.startswith("#"):
                if paras:
                    out.append((head, paras))
                head, paras = flat(line), []
            continue
        cur.append(line)
    return out


def windows(lines: list, most: int = 6) -> list:
    out = []
    for head, paras in blocks(lines):
        for i in range(len(paras)):
            for w in range(1, most + 1):
                if i + w > len(paras):
                    break
                win = " ".join(paras[i:i + w])
                if SMALL.search(win) or SMALL.search(head):
                    out.append(win)
    return out


def spans(s: str, marker) -> list:
    out = []
    for m in marker.finditer(s):
        depth = s.count("(", 0, m.start()) - s.count(")", 0, m.start())
        i, d = m.end(), 0
        while i < len(s):
            c = s[i]
            if c == "(":
                d += 1
            elif c == ")":
                if d == 0 and depth > 0:
                    break
                d = max(0, d - 1)
            elif c == ";" or (c == "." and (i + 1 == len(s)
                                            or s[i + 1] == " ")):
                break
            i += 1
        span = s[m.end():i]
        k = KEEP.search(span)
        out.append(span[:k.start()] if k else span)
    return out


def left_out(win: str, names: dict, marker) -> set:
    sp = spans(win, marker)
    return {n for n, rx in names.items() if any(re.search(rx, x)
                                                 for x in sp)}


def best(wins: list, key) -> str:
    return max(wins, key=key) if wins else ""


process = text("PROCESS.md")
sec = h2_sections(outside(process))
plines = sec.get("4", []) + [""] + sec.get("9", [])
pwins = windows(plines)


def score1(w: str) -> tuple:
    return (len(left_out(w, LEFT, OUT)), len(left_out(w, TABLES, OUT)),
            -len(left_out(w, KEPT, OUT_STRONG)))


w1 = best(pwins, score1)
got1 = left_out(w1, LEFT, OUT) if w1 else set()
report(1, got1 == set(LEFT), "PROCESS.md " + (
    "absent" if not process else
    f"sections 4 and 9: {len(pwins)} small passages; best leaves out "
    + (", ".join(sorted(got1)) or "none") + "; missing "
    + (", ".join(sorted(set(LEFT) - got1)) or "none")))

w2 = best(pwins, lambda w: len(left_out(w, TABLES, OUT)))
got2 = left_out(w2, TABLES, OUT) if w2 else set()
report(2, got2 == set(TABLES), "PROCESS.md small passage leaves out "
       + (", ".join(sorted(got2)) or "no table") + "; missing "
       + (", ".join(sorted(set(TABLES) - got2)) or "none"))

bad3 = left_out(w1, KEPT, OUT_STRONG) if w1 else set()
report(3, bool(got1) and not bad3, "PROCESS.md " + (
    "has no small passage that leaves a section out" if not got1 else
    "small passage keeps goal, test and review tasks, integrate, test map "
    "and self-review" if not bad3 else "small passage leaves out kept "
    "section(s): " + ", ".join(sorted(bad3))))

tmpl = text("templates/records/plan.md")
tl = outside(tmpl)
twins = windows(tl)
items = dict(LEFT, **TABLES)
by_note = set()
for w in twins:
    by_note |= left_out(w, items, OUT)
by_sec = set()
for k, lines in h2_sections(tl).items():
    if not lines or not lines[0].startswith("## "):
        continue
    head = flat(lines[0])
    body = flat("\n".join(lines))
    for n, rx in LEFT.items():
        if re.search(rx, head) and (
                (SMALL.search(body) and (OUT.search(body)
                                         or re.search(r"\bnot\b", body)))
                or MEDLARGE.search(body)):
            by_sec.add(n)
marked = by_note | by_sec
report(4, bool(tmpl) and marked == set(items), "plan template " + (
    "absent" if not tmpl else "marks for a small plan: "
    + (", ".join(sorted(marked)) or "nothing") + "; missing "
    + (", ".join(sorted(set(items) - marked)) or "none")))

paras = [p for _, ps in blocks(outside(process)) for p in ps]
tm = any("test map" in p and re.search(r"\b(?:every|each|all)\b", p)
         and re.search(r"\bscenarios?\b", p) for p in paras)
sr = any("self-review" in p and re.search(
    r"\bunchecked\b|\bfilled\b|\bticked\b|\bchecked\b|\[ \]", p)
    for p in paras)
report(5, tm and sr, f"PROCESS.md test map row per scenario "
       f"{'asked' if tm else 'not asked'}; self-review with no unchecked "
       f"item {'asked' if sr else 'not asked'}")
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- `PROCESS.md` defines no plan for a small change that leaves sections
  out, or its small plan keeps one of Global constraints, File map,
  Dependency summary, Questions for the spec, the risk table or the cost
  table.
- Its small plan leaves out the goal, the test or review tasks, the
  integrate task, the test map or the self-review.
- The plan template does not mark the four sections and the two tables as
  left out of a small plan, so a planner copying the template writes a
  full plan.
- `PROCESS.md` stops asking every plan for a test-map row per scenario or a
  self-review with no unchecked item.

## At base

Expected: fail at checks 1 to 4, because at the base commit set there is
no small size in the new sense and no terse plan: the base sizes are small
and project (`tests/right-size-testing/test_I1_process_md.md` check 7), and
nothing in `PROCESS.md` §4 or §9 or in the plan template leaves a section
out of a small plan. Check 5 is expected to hold at base: the test-map and
self-review rules bind every plan already.

Observed 2026-11-07T17:51Z at the base commit set (space b02a772, swe-pod
3b22a1b; the check reads only swe-pod), 1 s wall time, no agent; runner
result:

```
fail (check R4.S1.1: PROCESS.md sections 4 and 9: 15 small passages; best leaves out none; missing dependency summary, file map, global constraints, questions for the spec)
```

Checks 2 to 4 failed as well (no small passage leaves out a table; the
plan template marks nothing for a small plan) and check 5 passed, as
expected.

On control exports written from the interface contract alone (and on one
that states the same rules in other phrasings), every check passes; each
fault planted in a copy of them is caught by the check this file's Fails if
names for it.
