---
scenario: R4.S2
mode: inspect
class: script
deliverables: [swe-pod:PROCESS.md, swe-pod:skills/swe-pod]
fixture: none
expected_s: 5
heavy: false
env: any
cap_s: 30
risk: at risk: a terse plan satisfies the skill's planned and trace rules; if the rules by which the skill reads a change as planned or building, or the trace finds its breaks, read a section the terse plan leaves out, a small change never reads as planned or its trace prints a break
---

# R4.S2 The skill reads a small change's terse plan by the rules every size shares

Serves R4 through contract 2.2: "The skill's planned state and trace read
it by the rules they already have." The part of the risk it covers: the
skill regenerates `STATUS.md` and runs the trace from the records alone.
Its rules for the planned and building states and for the trace's breaks
must read only what a terse plan has; a rule that needs the file map, the
dependency summary, the global constraints, the questions for the spec or
the risk or cost table (or a plan skim that a small change does not have)
leaves a small change stuck before building, or with a trace break.

This script-class test reads the rules as text. It builds the space of
R4.S1 (an approved small spec of 3 requirements in one repo and its terse
plan, written from contract 2.2 alone) and checks that every plan section
the skill's state and trace rules name is one that plan has.

## Given

- `PROCESS.md` and `skills/swe-pod/` exported read-only from swe-pod at the
  sha under test.
- The fixture the check writes into the run's space copy,
  `changes/add-greeting-option/`: `spec.md`, approved, `size: small`, repo
  `alpha`, requirements R1 to R3 with scenarios R1.S1, R1.S2, R2.S1, R2.S2
  and R3.S1; and `plan.md`, the terse plan of contract 2.2, whose level-2
  headings are `1 Goal and approach`, `2 Interface contract`, `5 Tasks`,
  `6 Test tasks`, `7 Review tasks`, `8 Integrate task`, `9 Test map` and
  `Self-review`, with one build task serving R1 to R3, a test map row per
  scenario, and a self-review with every item checked.

## When

```text
The runner exports the deliverables by sha and runs the check below on
them. No agent is run.
```

## Then

Text is read as in `test_R4_S1_terse_plan_sections`, whose small-passage
and left-out-span rules this test uses. A rule unit of the skill is a
paragraph or list item of `SKILL.md` or `status-format.md` that names
`planned`, `building`, `trace` or `break`. A rule unit is conditioned when
it names medium or large and not small, or says "where present", "if
present", "when present" or "if any". The plan sections read are the plan
template's level-2 headings but Tasks (its word names every kind of task,
and the terse plan keeps it), with Goal read as "goal and approach", and
the risk and cost tables.

1. `PROCESS.md` defines a terse plan: §4 or §9 has a small passage in which
   at least one of Global constraints, File map, Dependency summary and
   Questions for the spec is left out (at base, no such passage exists).
2. Every plan section or table that an unconditioned rule unit of the skill
   names is one the fixture's terse plan has (by its headings): none of
   Global constraints, File map, Dependency summary, Questions for the
   spec, the risk table or the cost table.
3. No unconditioned rule unit of the skill names a section or table that
   the small passage of check 1 leaves out.
4. Every unit of the skill that names the plan skim (a `skim` word) also
   names a size (small, medium, large, project) or the word size: the skim
   is a gate of some sizes, not a step every change waits on before it
   reads as building.

```python check
import os
import re
import sys
from pathlib import Path

TAG = "R4.S2"
OK = []
FENCE = "`" * 3
ROOT = Path(os.environ.get("EXPORT_SWE_POD") or "/nonexistent")
SHA = os.environ.get("SHA_SWE_POD", "?")
SPACE = Path(os.environ.get("SPACE") or os.environ.get("RUN_DIR") or ".")
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
ALL = dict(LEFT, **TABLES)
ALL.update({
    "goal": r"\bgoal and approach\b",
    "interface contract": r"\binterface contract\b",
    "test tasks": r"\btest tasks\b",
    "review tasks": r"\breview tasks\b",
    "integrate task": r"\bintegrate task\b",
    "test map": r"\btest map\b",
    "self-review": r"\bself-review\b",
})
STATE = re.compile(r"\bplanned\b|\bbuilding\b|\btrace\b|\bbreak\b")
PRESENT = re.compile(r"\b(?:where|if|when) present\b|\bif any\b")
SIZES = re.compile(r"\b(?:small|medium|large|project)\b|\bsizes?\b")
SPEC = """# add-greeting-option: hello takes a --greeting option

- size: small
- owner: demo
- repos: [alpha]
- supersedes: []
- approved: demo 2026-11-07T12:00Z

## Requirements

### R1 The option sets the greeting
#### R1.S1 Given text
#### R1.S2 Empty text

### R2 The default stays
#### R2.S1 No option
#### R2.S2 Option after the name

### R3 Help names the option
#### R3.S1 --help
"""
PLAN = """# Plan: add-greeting-option

- spec: changes/add-greeting-option/spec.md
- size: small

## 1 Goal and approach

Add a --greeting option to alpha's hello command, defaulting to Hello.

## 2 Interface contract

`hello [--greeting <text>] <name>` prints `<text>, <name>`.

## 5 Tasks

### T1 The --greeting option
- role: build
- after: []
- runs: local
- needs: any
- serves: [R1, R2, R3]
- done when: alpha's unit suite passes with a test per scenario

## 6 Test tasks

### T2 Blind tests of R1 to R3
- role: test
- after: []
- runs: local
- needs: any
- serves: [R1, R2, R3]
- done when: one test per scenario, each failing at base

### T3 Verify
- role: test
- after: [T1, T2]
- runs: local
- needs: any
- serves: [R1, R2, R3]
- done when: an evidence record at the branch head

## 7 Review tasks

### T4 Whole-change review
- role: review
- after: [T3]
- runs: local
- needs: any
- serves: [R1, R2, R3]
- done when: a review record with no open Critical or Important finding

## 8 Integrate task

### T5 Integrate
- role: lead
- after: [T4]
- runs: local
- needs: any
- serves: [R1, R2, R3]
- done when: merged on the operator's word

## 9 Test map

| Scenario | Test | Class | Written by |
|---|---|---|---|
| R1.S1 | test_R1_S1_given_text | script | T2 |
| R1.S2 | test_R1_S2_empty_text | script | T2 |
| R2.S1 | test_R2_S1_no_option | script | T2 |
| R2.S2 | test_R2_S2_option_after_name | script | T2 |
| R3.S1 | test_R3_S1_help | script | T2 |

## Self-review

- [x] Every requirement is served by a task.
- [x] Every scenario has a row in the test map.
- [x] Every task has a done-when.
"""


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


def units(s: str) -> list:
    out = []
    for block in re.split(r"\n[ \t]*\n", s):
        cur = []
        for line in block.splitlines():
            if re.match(r"\s*(?:[-+*]|\d+\.)\s", line) and cur:
                out.append(flat("\n".join(cur)))
                cur = []
            cur.append(line)
        if cur:
            out.append(flat("\n".join(cur)))
    return [u for u in out if u]


def names_in(u: str) -> set:
    return {n for n, rx in ALL.items() if re.search(rx, u)}


# The fixture: the space of R4.S1.
change = SPACE / "changes" / "add-greeting-option"
change.mkdir(parents=True, exist_ok=True)
(change / "spec.md").write_text(SPEC)
(change / "plan.md").write_text(PLAN)
heads = [flat(ln[3:]) for ln in PLAN.splitlines() if ln.startswith("## ")]
has = {n for n, rx in ALL.items() if any(re.search(rx, h) for h in heads)}
scen = re.findall(r"^#### (R\d+\.S\d+)", SPEC, re.M)
rows = re.findall(r"^\| (R\d+\.S\d+) \|", PLAN, re.M)
if sorted(scen) != sorted(rows) or len(scen) != 5:
    print(f"{TAG}.0 fail fixture: test map rows {rows} against {scen}")
    sys.exit(1)

process = text("PROCESS.md")
sec = h2_sections(outside(process))
pwins = windows(sec.get("4", []) + [""] + sec.get("9", []))
win = best(pwins, lambda w: (len(left_out(w, LEFT, OUT)),
                             len(left_out(w, TABLES, OUT))))
dropped = set()
if win:
    dropped = left_out(win, dict(LEFT, **TABLES), OUT) | left_out(
        win, {k: v for k, v in ALL.items() if k not in LEFT
              and k not in TABLES}, OUT_STRONG)
defined = bool(dropped & set(LEFT))
report(1, defined, "PROCESS.md " + (
    "absent" if not process else "defines a terse plan leaving out "
    + ", ".join(sorted(dropped)) if defined else
    "has no small passage in section 4 or 9 that leaves out a plan section"))

skill = text("skills/swe-pod/SKILL.md")
fmt = text("skills/swe-pod/status-format.md")
rule = []
for u in units(skill) + units(fmt):
    if not STATE.search(u):
        continue
    if PRESENT.search(u):
        continue
    if re.search(r"\b(?:medium|large)\b", u) and not SMALL.search(u):
        continue
    rule.append(u)
read = set()
for u in rule:
    read |= names_in(u)
lack = sorted(read - has)
report(2, bool(skill or fmt) and not lack, "skill " + (
    "absent" if not (skill or fmt) else
    f"{len(rule)} state and trace rule units name "
    + (", ".join(sorted(read)) or "no plan section")
    + ("; all in the terse plan" if not lack else
       "; not in the terse plan: " + ", ".join(lack))))

clash = sorted(read & dropped)
report(3, defined and not clash, "skill rule units against the terse "
       "plan of PROCESS.md: " + (
           "no terse plan defined" if not defined else
           "read none of its left-out sections" if not clash else
           "read left-out " + ", ".join(clash)))

skims = [u for u in units(skill) + units(fmt) if re.search(r"\bskim", u)]
unbound = [u for u in skims if not SIZES.search(u)]
report(4, not unbound, "skill units naming the plan skim: "
       f"{len(skims)}, " + ("each bound to a size" if not unbound else
                            f"{len(unbound)} with no size, first: "
                            + unbound[0][:80]))
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- `PROCESS.md` defines no terse plan for a small change (as at base).
- A rule by which the skill reads the planned or building state, or finds
  a trace break, names a section or table the terse plan leaves out, with
  no condition that keeps it to medium or large or to plans that have it.
- The skill makes the plan skim a step of every change, so a small change,
  which has no skim, cannot read as building.

## At base

Expected: fail at checks 1 and 3, because at the base commit set
`PROCESS.md` defines no terse plan: no small passage of §4 or §9 leaves a
section out (the base sizes are small and project, and both have the full
plan). Checks 2 and 4 read the skill's existing rules, which contract 2.2
keeps; they are expected to hold at base and guard that the change does
not make those rules read a left-out section or an unbound skim.

Observed 2026-11-07T17:51Z at the base commit set (space b02a772, swe-pod
3b22a1b; the check reads only swe-pod), 0 s wall time, no agent; runner
result:

```
fail (check R4.S2.1: PROCESS.md has no small passage in section 4 or 9 that leaves out a plan section)
```

Check 3 failed with it (no terse plan defined). Check 2 passed: the
skill's 14 state and trace rule units name only the self-review among plan
sections, which the terse plan keeps. Check 4 passed with no unit of the
skill naming a skim at base, so it holds there vacuously and binds only
once the change adds one.

On control exports written from the interface contract alone (and on one
that states the same rules in other phrasings), every check passes; each
fault planted in a copy of them is caught by the check this file's Fails if
names for it.
