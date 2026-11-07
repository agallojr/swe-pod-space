---
scenario: R10.S2
mode: inspect
class: script
deliverables: [swe-pod:PROCESS.md, swe-pod:agents, swe-pod:skills/swe-pod, swe-pod:templates, swe-pod:README.md, swe-pod:INSTALL.md]
fixture: none
expected_s: 3
heavy: false
env: any
cap_s: 30
risk: at risk: no passage allows a lesser model or ties one to a size; a sentence that lets a role, task, fix round or independence check run on a cheaper model, or picks the model by size, undoes R10 even where every role file says opus
---

# R10.S2 No passage allows a lesser model or ties a model to a size

Serves R10 through contract 2.4. The part of the risk it covers: the role
files pin Opus (R10.S1), but an agent also follows the prose of
`PROCESS.md`, its role body, the skill, the templates, README and INSTALL.
One passage there that lets a fix round, an independence check or a light
size run on a cheaper model, or that still says `model: inherit` or "the
most capable model available", hands the choice of model back to the
session or to the size, which R10 forbids. Checks 6 and 7 keep the
negative checks from passing on a `PROCESS.md` that says nothing of models
at all: R10 asks the process text to say every role runs on Opus at every
size, and that independence comes from a fresh session or another node.

## Given

`PROCESS.md`, `agents/`, `skills/swe-pod/`, `templates/`, `README.md` and
`INSTALL.md` exported read-only from swe-pod at the sha under test: the
files R10.S2's Given names.

## When

```text
The runner exports the deliverables by sha and runs the check below on
them. No agent is run.
```

## Then

Text is read with backticks and Markdown emphasis removed, in lower case,
with white-space runs as one space. A unit is a paragraph (a run of
non-blank lines) or a list item; a clause is a part of a unit between
sentence ends (a full stop before a space or the end) and semicolons. A
clause is negated where `no`, `not`, `never`, `nor`, `none`, `without` or a
word ending `n't` comes before the matched words in it, and so is every
clause of a unit under a heading that holds one of those words (as a role
file's `## Never`) or of a list item after a lead-in that holds one and
ends in a colon.

1. No file says `model: inherit`.
2. No file says "most capable model".
3. Every `model:` key or mention in the files gives the value `opus`
   (`writer_model` and `--model` are other names and are not read).
4. No clause allows a lesser model: a clause that names a lesser, cheaper,
   cheap, smaller, weaker, lighter, faster, less capable or lower-tier
   model, or Sonnet or Haiku, is negated.
5. No clause ties a model to a size: a clause that names a model (Opus,
   Sonnet, Haiku, or the word model or models, other than `writer_model`,
   `--model` and "language", "data", "risk", "threat", "mental" or
   "process" model) and a size (small, medium, large or spike) also holds
   `every`, `each`, `all`, `any`, `same`, `whatever`, `regardless`,
   `whichever` or `alike`, or is negated.
6. `PROCESS.md` has a unit that names Opus, a role and a size together
   with `every`, `each` or `all` (R10: every role on Opus at every size).
7. `PROCESS.md` has a unit that names independence (independent or
   independence), a fresh, new or separate session or agent, and another,
   other, different or second node (R10: independence comes from a fresh
   session or another node).

```python check
import os
import re
import sys
from pathlib import Path

TAG = "R10.S2"
OK = []
ROOT = Path(os.environ.get("EXPORT_SWE_POD") or "/nonexistent")
SHA = os.environ.get("SHA_SWE_POD", "?")
NEG = re.compile(r"\b(?:no|not|never|nor|none|without)\b|n't\b")
LESSER = re.compile(
    r"\b(?:lesser|cheaper|cheap|smaller|weaker|lighter|faster|"
    r"less capable|lower[- ]tier)\s+models?\b|\bsonnet\b|\bhaiku\b")
OTHER_MODEL = r"(?:language|data|risk|threat|mental|process)"
MODEL = re.compile(r"\bopus\b|\bsonnet\b|\bhaiku\b|(?<![\w-])models?\b")
SIZE = re.compile(r"\b(?:small|medium|large|spike)\b(?! language)")
UNIVERSAL = re.compile(
    r"\b(?:every|each|all|any|same|whatever|regardless|whichever|alike)\b")


def report(n: int, ok: bool, why: str) -> None:
    OK.append(bool(ok))
    print(f"{TAG}.{n} {'pass' if ok else 'fail'} {why}")


def flat(s: str) -> str:
    s = s.replace("`", "").replace("*", "")
    return re.sub(r"\s+", " ", s).strip().lower()


def units_ctx(s: str) -> list:
    """(unit, negated) pairs. A unit under a heading that holds a negation
    (as a role file's ## Never), or a list item after a lead-in unit that
    holds one and ends in a colon, is in a negated context."""
    out = []
    state = {"head": False, "lead": False}

    def emit(lines: list, item: bool) -> None:
        u = flat("\n".join(lines))
        if not u:
            return
        out.append((u, state["head"] or (item and state["lead"])))
        if not item:
            state["lead"] = u.endswith(":") and NEG.search(u) is not None

    for block in re.split(r"\n[ \t]*\n", s):
        cur, item = [], False
        for line in block.splitlines():
            if line.startswith("#"):
                if cur:
                    emit(cur, item)
                cur = []
                state["head"] = NEG.search(flat(line)) is not None
                state["lead"] = False
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
    return [u for u, _ in units_ctx(s)]


def clauses(u: str) -> list:
    return [c.strip() for c in re.split(r"\.(?=\s|$)|;", u) if c.strip()]


def negated(c: str, start: int) -> bool:
    return NEG.search(c[:start]) is not None


def model_hits(c: str) -> list:
    hits = []
    for m in MODEL.finditer(c):
        before = c[max(0, m.start() - 12):m.start()]
        if re.search(rf"\b{OTHER_MODEL}\s+$", before):
            continue
        hits.append(m)
    return hits


def files() -> dict:
    out = {}
    for rel in ("PROCESS.md", "README.md", "INSTALL.md"):
        p = ROOT / rel
        if p.is_file():
            out[rel] = p.read_text(errors="replace")
    for d in ("agents", "skills/swe-pod", "templates"):
        base = ROOT / d
        if not base.is_dir():
            continue
        for p in sorted(base.rglob("*")):
            if p.is_file():
                try:
                    out[str(p.relative_to(ROOT))] = p.read_text()
                except UnicodeDecodeError:
                    continue
    return out


def short(s: str, n: int = 90) -> str:
    return s if len(s) <= n else s[:n - 3] + "..."


F = files()
want = ["PROCESS.md", "README.md", "INSTALL.md", "agents", "skills/swe-pod",
        "templates"]
absent = [w for w in want if not any(k == w or k.startswith(w + "/")
                                     for k in F)]
if absent:
    print(f"{TAG}.0 note absent at swe-pod {SHA}: {', '.join(absent)}")

inherit = [k for k, t in F.items()
           if re.search(r"(?<![\w-])model:\s*inherit\b", flat(t))]
report(1, not inherit, "model: inherit " + (
    "in no file" if not inherit else "in " + ", ".join(inherit)))

capable = [k for k, t in F.items() if "most capable model" in flat(t)]
report(2, not capable, "most capable model " + (
    "in no file" if not capable else "in " + ", ".join(capable)))

other = []
for k, t in F.items():
    for m in re.finditer(r"(?<![\w-])model:\s*([^\s,;)]+)", flat(t)):
        v = m.group(1).strip("'\".")
        if v != "opus":
            other.append(f"{k} model: {v}")
report(3, not other, "model: values " + (
    "all opus" if not other else "not opus: " + "; ".join(other[:6])))

lesser, tied = [], []
for k, t in F.items():
    for u, neg in units_ctx(t):
        if neg:
            continue
        for c in clauses(u):
            for m in LESSER.finditer(c):
                if not negated(c, m.start()):
                    lesser.append(f"{k}: {short(c)}")
                    break
            mh = model_hits(c)
            if mh and SIZE.search(c):
                if not UNIVERSAL.search(c) and not NEG.search(c):
                    tied.append(f"{k}: {short(c)}")
report(4, not lesser, "clauses allowing a lesser model: " + (
    "none" if not lesser else f"{len(lesser)}, first " + lesser[0]))
report(5, not tied, "clauses tying a model to a size: " + (
    "none" if not tied else f"{len(tied)}, first " + tied[0]))

pu = units(F.get("PROCESS.md", ""))
opus = [u for u in pu if re.search(r"\bopus\b", u)
        and re.search(r"\broles?\b", u) and re.search(r"\bsizes?\b", u)
        and re.search(r"\b(?:every|each|all)\b", u)]
report(6, bool(opus), "PROCESS.md " + (
    "absent" if "PROCESS.md" not in F else
    "states every role on Opus at every size" if opus else
    "has no unit naming Opus, a role and a size with every, each or all"))
indep = [u for u in pu if re.search(r"\bindependen(?:ce|t)\b", u)
         and re.search(r"\b(?:fresh|new|separate) (?:session|agent)s?\b", u)
         and re.search(r"\b(?:another|other|different|second) nodes?\b", u)]
report(7, bool(indep), "PROCESS.md " + (
    "absent" if "PROCESS.md" not in F else
    "states independence by a fresh session or another node" if indep else
    "has no unit naming independence with a fresh session and another "
    "node"))
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- Any of the files still says `model: inherit` or "the most capable
  model available" (the rule R10 replaces, `right-size-testing/R15`).
- A `model:` value other than `opus` appears anywhere in them.
- A sentence lets a role, task, fix round, review or independence check run
  on Sonnet, Haiku or a cheaper, lighter or lesser model.
- A sentence picks or changes the model by size, such as a small change's
  review on a lighter model.
- `PROCESS.md` does not say that every role runs on Opus at every size, or
  does not say that independence comes from a fresh session or another
  node.

## At base

Expected: fail at checks 1 and 3, because at the base commit set the six
role files say `model: inherit` (build-swe-pod's kept test I2 pins it);
at check 2, because the base text keeps `right-size-testing/R15`'s "most
capable model" wording, which this change supersedes; and at check 6,
because the base process names no Opus rule. Checks 4, 5 and 7 are
expected to hold at base and guard what the change must not add or lose.

Observed 2026-11-07T17:51Z at the base commit set (space b02a772, swe-pod
3b22a1b; the check reads only swe-pod), 1 s wall time, no agent; runner
result:

```
fail (check R10.S2.1: model: inherit in PROCESS.md, INSTALL.md, agents/swe-build.md, agents/swe-lead.md, agents/swe-plan.md, agents/swe-review.md, agents/swe-spec.md, agents/swe-test.md)
```

Checks 2 ("most capable model" in `PROCESS.md`, README, INSTALL,
`swe-lead.md` and `swe-review.md`), 3 and 6 failed as well; checks 4, 5
and 7 passed. Check 4 passes at base only because the lead role's line on
a lesser model stands under its `## Never` heading, which the negated
context of the Then list covers.

On control exports written from the interface contract alone (and on one
that states the same rules in other phrasings), every check passes; each
fault planted in a copy of them is caught by the check this file's Fails if
names for it.
