---
scenario: R13.S3
mode: inspect
class: script
deliverables: [swe-pod:PROCESS.md, swe-pod:agents/swe-lead.md, swe-pod:templates/records/ledger.md]
fixture: none
expected_s: 2
heavy: false
env: any
cap_s: 30
risk: at risk: a cap hit caused by the spec reopens approval for it; without a rule that sends the spec author a proposed edit when the open finding is a requirement read two ways, the lead can only rule against one reading, and the misread requirement ships or is fixed again
---

# R13.S3 A cap hit from a requirement read two ways goes to the spec author

Serves R13 through contract 2.3: "At the cap the lead ... where a finding
comes from a requirement read two ways, sends the spec author a proposed
edit: approval reopens for that edit only, and the tasks that serve it are
held (`approval reopened for <Rn>; held T<a>`)." The part of the risk it
covers: a task at its cap whose open finding is a requirement that the
builder and the reviewer read two ways. The operator's reason for the cap
is that a task needing more rounds "means the spec is not understood", so
the lead must route that case back to the spec author, reopen approval for
the one edit, and hold the tasks that serve it until the operator
approves, rather than rule on one reading or start another round.

## Given

`PROCESS.md`, `agents/swe-lead.md` and `templates/records/ledger.md`
exported read-only from swe-pod at the sha under test.

## When

```text
The runner exports the deliverables by sha and runs the check below on
them. No agent is run.
```

## Then

Text is read as in `test_R13_S1_small_cap_then_ruling`: backticks and
emphasis removed, lower case, white space as one space; a unit is a
paragraph or a list item, read together with its lead-in (the paragraph
before the list, when it ends in a colon). A passage is one unit, or two
units next to each other in the same file.

A cap word is `cap`, `capped` or `at most`. A spec-author word is "spec
author", `swe-spec`, "spec agent" or "spec role". A two-ways word is "two
ways", "two readings", an `ambigu-` word, "more than one way" (or reading,
or meaning), or "read differently". An edit word is `edit`, `edits` or an
`amend-` word.

1. `PROCESS.md` has a passage that names a cap word, a round (`round` or
   `rounds`, so the cap is the fix-round cap and not another, such as the
   three harness reruns of §7), a spec-author word, a two-ways word and an
   edit word.
2. A passage of check 1 also names reopening (a `reopen-` word), and
   `PROCESS.md` or the ledger template holds the ledger form
   `approval reopened for <Rn>; held T<a>` of contract 2.3.
3. `PROCESS.md` has a unit that names held (`held` or `hold`) tasks (a
   `task` word or `T<`) and approval (an `approv-` word): the held tasks
   wait for the operator's approval.
4. `agents/swe-lead.md` has a passage that names a cap word, a round, a
   spec-author word and a two-ways word.

```python check
import os
import re
import sys
from pathlib import Path

TAG = "R13.S3"
OK = []
ROOT = Path(os.environ.get("EXPORT_SWE_POD") or "/nonexistent")
SHA = os.environ.get("SHA_SWE_POD", "?")
NEG = re.compile(r"\b(?:no|not|never|nor|none|without)\b")
CAP = re.compile(r"\bcap\b|\bcapped\b|\bat most\b")
ROUND = re.compile(r"\brounds?\b")
AUTHOR = re.compile(r"\bspec author\b|\bswe-spec\b|\bspec agent\b|"
                    r"\bspec role\b")
TWO = re.compile(r"\btwo ways\b|\btwo readings\b|\bambigu\w*|"
                 r"\bmore than one (?:way|reading|meaning)\b|"
                 r"\bread differently\b")
EDIT = re.compile(r"\bedits?\b|\bamend\w*")
REOPEN = re.compile(r"\breopen\w*")
FORM = "approval reopened for <rn>; held t<a>"


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


process = text("PROCESS.md")
lead = text("agents/swe-lead.md")
ledger = text("templates/records/ledger.md")


def windows(t: str) -> list:
    ps = passages(t)
    return ps + [ps[i] + " " + ps[i + 1] for i in range(len(ps) - 1)]


def spec_route(w: str) -> bool:
    return bool(CAP.search(w) and ROUND.search(w) and AUTHOR.search(w)
                and TWO.search(w) and EDIT.search(w))


pw = [w for w in windows(process) if spec_route(w)]
report(1, bool(pw), "PROCESS.md " + (
    "absent" if not process else "routes a cap hit from a requirement read "
    "two ways to the spec author with an edit" if pw else
    "has no passage naming the fix-round cap, the spec author, a "
    "requirement read two ways and an edit"))

reo = [w for w in pw if REOPEN.search(w)]
form = FORM in flat(process) or FORM in flat(ledger)
report(2, bool(reo) and form, "the routing passage "
       + ("names reopening" if reo else "absent or names no reopening")
       + "; the form approval reopened for <Rn>; held T<a> "
       + ("present" if form else "absent from PROCESS.md and the ledger "
          "template"))

held = [u for u in passages(process) if re.search(r"\bheld\b|\bhold", u)
        and re.search(r"\btasks?\b|\bt<", u)
        and re.search(r"\bapprov\w*", u)]
report(3, bool(held), "PROCESS.md " + (
    "absent" if not process else "holds the tasks until approval"
    if held else "has no unit naming held tasks and approval"))

lw = [w for w in windows(lead) if CAP.search(w) and ROUND.search(w)
      and AUTHOR.search(w) and TWO.search(w)]
report(4, bool(lw), "agents/swe-lead.md " + (
    "absent" if not lead else "routes a cap hit from a requirement read "
    "two ways to the spec author" if lw else "has no passage naming the "
    "fix-round cap, the spec author and a requirement read two ways"))
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- The process has no rule for the case where the open finding at the cap
  comes from a requirement read two ways, or the rule does not send the
  spec author a proposed edit.
- The rule does not reopen approval for the edit, or the ledger form
  `approval reopened for <Rn>; held T<a>` is gone.
- The held tasks do not wait for the operator's approval.
- The lead role does not carry the rule.

## At base

Expected: fail at checks 1, 2 and 4, because the base fix loop ends with
the lead's ruling after round 5 and sends nothing back to the spec author
(the spec's open call 5: "At the cap the lead rules as today and, where
the spec is the cause, sends the author an edit"), and the ledger form
`approval reopened for <Rn>; held T<a>` of contract 2.3 is new. Check 3 is
expected to hold at base: the process already holds tasks for approval.

Observed 2026-11-07T17:51Z at the base commit set (space b02a772, swe-pod
3b22a1b; the check reads only swe-pod), 1 s wall time, no agent; runner
result:

```
fail (check R13.S3.1: PROCESS.md has no passage naming the fix-round cap, the spec author, a requirement read two ways and an edit)
```

Check 2 failed on both its parts (no routing passage; the ledger form is
in neither `PROCESS.md` nor the ledger template), check 4 failed, and
check 3 passed. A first draft of check 1 without the round word matched
the base §7 verify-failure table ("spec ambiguous or wrong ... a proposed
edit to the spec" beside "at most three" harness reruns); the round word
keeps check 1 to the fix-round cap.

On control exports written from the interface contract alone (and on one
that states the same rules in other phrasings), every check passes; each
fault planted in a copy of them is caught by the check this file's Fails if
names for it.
