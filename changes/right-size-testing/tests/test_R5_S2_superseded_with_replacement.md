---
scenario: R5.S2
mode: inspect
class: script
deliverables: [swe-pod:skills/swe-pod, swe-pod:PROCESS.md, swe-pod:templates/records/evidence.md]
fixture: none
expected_s: 2
heavy: false
env: any
cap_s: 30
risk: at risk: a superseded test with a passing replacement read as not green; the rule an agent applies must make superseded by <key> no bar when <key> passes and the spec's supersedes lists the test's requirement, and the status line must count it apart
---

# R5.S2 A superseded test with a passing replacement: the rule as written

Serves R5 through contract 2.3, 2.4 and 2.5. Script class: it reads the
text an agent applies when it regenerates `STATUS.md`, and the result form
the verify that writes the record uses. How an agent reads that text, on
this scenario's record (a spec superseding the archived change's R2, its
R2.S1 test given `superseded by R1.S1`, R1.S1 passing), is checked by
`test_R5_S3_superseded_without_replacement`, whose control record it is.

## Given

- `skills/swe-pod/`, `PROCESS.md` and `templates/records/evidence.md`,
  exported read-only from swe-pod at the sha under test.
- The scenario's record: the spec supersedes `<change>/R2`; the record
  gives `<change>/R2.S1` the result `superseded by R1.S1`, and `R1.S1`,
  this change's test of the new behavior, passes in the same record.

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
   latest-evidence line with its superseded count, as contract 2.5's form
   `regression <p>/<n> pass[, <k> not-selected][, <j> superseded]` does: it
   holds `regression <p>/<n> pass` and `<j> superseded`.
2. The skill (`SKILL.md` or `status-format.md`) states the green rule's
   superseded case with both its conditions: one paragraph names
   `superseded by`, the spec's `supersedes` and a `pass`.
3. `PROCESS.md` states the same case: one paragraph names `superseded by`,
   `supersedes` and a `pass`.
4. `templates/records/evidence.md` gives the result form
   `superseded by <key>` (contract 2.3).

```python check
import os
import re
import sys
from pathlib import Path

TAG = "R5.S2"
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
j = "<j> superseded" in f
report(1, bool(fmt) and reg and j,
       "status-format.md " + ("absent" if not fmt else
                              f"regression part {'found' if reg else 'absent'}"
                              f", superseded count "
                              f"{'found' if j else 'absent'}"))

words = ["superseded by", "supersedes", "pass"]
report(2, holds(skill, words),
       "the skill " + ("states" if holds(skill, words) else
                       "has no paragraph naming") +
       " superseded by with the spec's supersedes and a pass")
report(3, bool(process) and holds(process, words),
       "PROCESS.md " + ("absent" if not process else
                        "states" if holds(process, words) else
                        "has no paragraph naming") +
       ("" if not process else
        " superseded by with the spec's supersedes and a pass"))

form = "superseded by <key>" in flat(tmpl)
report(4, bool(tmpl) and form,
       "evidence template " + ("absent" if not tmpl else
                               "gives superseded by <key>" if form else
                               "lacks superseded by <key>"))
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- The skill or `PROCESS.md` knows no `superseded by` result, or states it
  without the spec's `supersedes` or the replacement's pass, so a rightly
  superseded test keeps the evidence not green (heartbeat-every-15-min's
  three superseded tests), or an agent has no condition to check.
- `status-format.md` has no place for the superseded count.
- The evidence template gives a verify no `superseded by <key>` form.

## At base

Expected: fail at check 1, because swe-pod `b7fc257`'s `status-format.md`
gives the regression part as `regression <p>/<n> pass` only, and no
deliverable knows a `superseded by` result (checks 2 to 4 fail too).

Observed 2026-10-30T16:42Z at the base commit set (space 6f1e4e0, swe-pod
b7fc257, agent-mesh f27c611), 1 s wall time, no agent; runner result:

```
fail (check R5.S2.1: status-format.md regression part found, superseded count absent)
```

Checks 2 to 4 failed as well: no paragraph of the skill or `PROCESS.md`
names `superseded by`, and the evidence template lacks `superseded by
<key>`. On a control export written from contract 2.2 to 2.5 alone, all
four checks pass.
