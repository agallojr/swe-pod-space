---
scenario: R5.S1
mode: inspect
class: script
deliverables: [swe-pod:skills/swe-pod, swe-pod:PROCESS.md, swe-pod:templates/records/evidence.md]
fixture: none
expected_s: 2
heavy: false
env: any
cap_s: 30
risk: at risk: a targeted verify read as not green; the rule an agent applies must make a not-selected test the selection does not pick no bar to green, and the status line must count it apart from the passes
---

# R5.S1 Not-selected tests leave the evidence green: the rule as written

Serves R5 through contract 2.2, 2.4 and 2.5. Script class: it reads the
text an agent applies when it regenerates `STATUS.md`, and the forms the
verify that writes the record uses. How an agent reads that text, on this
scenario's record in small (2 selected passes and 3 `not-selected`), is
checked by `test_R5_S4_picked_test_not_passed`, whose control record it is.

## Given

- `skills/swe-pod/`, `PROCESS.md` and `templates/records/evidence.md`,
  exported read-only from swe-pod at the sha under test.
- The scenario's record passes every scenario, unit suite and declared
  quality check and the 6 regression tests its targeted selection picks,
  and gives the other 84 `not-selected`. By contract 2.5 its
  latest-evidence line shows `regression 6/6 pass, 84 not-selected`.

## When

```text
The runner exports the deliverables by sha and runs the check below on
them. No agent is run.
```

## Then

Matching ignores backticks, Markdown emphasis, case and line breaks. A
paragraph is a run of non-blank lines, a list without blank lines included.
No other wording is checked.

1. `skills/swe-pod/status-format.md` gives the regression part of the
   latest-evidence line with its not-selected count, as contract 2.5's
   form `regression <p>/<n> pass[, <k> not-selected][, <j> superseded]`
   does: it holds `regression <p>/<n> pass` and `<k> not-selected`.
2. The skill (`SKILL.md` or `status-format.md`) states the green rule's
   not-selected case: one paragraph names `not-selected`, the `targeted`
   selection and what the selection picks (`pick`, as in picked or picks).
3. `PROCESS.md` states the same case: one paragraph names `not-selected`,
   `targeted` and `pick`.
4. `templates/records/evidence.md` gives the forms the rule reads: a
   `selection:` key and a `touched:` key, each at the start of a line, and
   the `not-selected` result.

```python check
import os
import re
import sys
from pathlib import Path

TAG = "R5.S1"
OK = []
ROOT = Path(os.environ.get("EXPORT_SWE_POD") or "/nonexistent")


def report(n: int, ok: bool, why: str) -> None:
    OK.append(bool(ok))
    print(f"{TAG}.{n} {'pass' if ok else 'fail'} {why}")


def text(rel: str) -> str:
    p = ROOT / rel
    return p.read_text() if p.is_file() else ""


def flat(s: str) -> str:
    """Lower case, no backticks or emphasis, white space runs as one space."""
    s = s.replace("`", "").replace("*", "")
    return re.sub(r"\s+", " ", s).strip().lower()


def paragraphs(s: str) -> list:
    return [flat(b) for b in re.split(r"\n[ \t]*\n", s) if b.strip()]


def holds(s: str, words: list) -> bool:
    return any(all(w in p for w in words) for p in paragraphs(s))


fmt = text("skills/swe-pod/status-format.md")
skill = text("skills/swe-pod/SKILL.md") + "\n\n" + fmt
process = text("PROCESS.md")
tmpl = text("templates/records/evidence.md")

f = flat(fmt)
reg = "regression <p>/<n> pass" in f
k = "<k> not-selected" in f
report(1, bool(fmt) and reg and k,
       "status-format.md " + ("absent" if not fmt else
                              f"regression part {'found' if reg else 'absent'}"
                              f", not-selected count "
                              f"{'found' if k else 'absent'}"))

words = ["not-selected", "targeted", "pick"]
report(2, holds(skill, words),
       "the skill " + ("states" if holds(skill, words) else
                       "has no paragraph naming") +
       " not-selected with the targeted selection and its picks")
report(3, bool(process) and holds(process, words),
       "PROCESS.md " + ("absent" if not process else
                        "states" if holds(process, words) else
                        "has no paragraph naming") +
       ("" if not process else
        " not-selected with the targeted selection and its picks"))

sel = bool(re.search(r"^[ \t>-]*`?selection:", tmpl, re.M))
tch = bool(re.search(r"^[ \t>-]*`?touched:", tmpl, re.M))
ns = "not-selected" in tmpl
report(4, bool(tmpl) and sel and tch and ns,
       "evidence template " + ("absent" if not tmpl else
                               f"selection: {sel}, touched: {tch}, "
                               f"not-selected: {ns}"))
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- The skill or `PROCESS.md` still asks a pass of every regression test,
  with no `not-selected` case bound to the targeted selection and its
  picks, so a rightly targeted verify stays not green (the case of
  heartbeat-every-15-min, whose lead had to rule it verified).
- `status-format.md` has no place for the not-selected count, so the line
  cannot show the 84 apart from the 6 passes.
- The evidence template gives a verify no `selection:` or `touched:` key or
  no `not-selected` result to write.

## At base

Expected: fail at check 1, because swe-pod `b7fc257`'s `status-format.md`
gives the regression part as `regression <p>/<n> pass` only, and no
deliverable names `not-selected` (checks 2 to 4 fail too).

Observed 2026-10-30T16:42Z at the base commit set (space 6f1e4e0, swe-pod
b7fc257, agent-mesh f27c611), 1 s wall time, no agent; runner result:

```
fail (check R5.S1.1: status-format.md regression part found, not-selected count absent)
```

Checks 2 to 4 failed as well: no paragraph of the skill or `PROCESS.md`
names `not-selected`, and the evidence template has no `selection:` or
`touched:` key and no `not-selected` result. On a control export written
from contract 2.2 to 2.5 alone, all four checks pass.
