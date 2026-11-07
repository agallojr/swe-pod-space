---
scenario: R10.S1
mode: inspect
class: script
deliverables: [swe-pod:agents]
fixture: none
expected_s: 1
heavy: false
env: any
cap_s: 30
risk: at risk: all six role files pin Opus; a role file that still says model inherit, names another model, or is missing lets that role run on whatever the session runs on
---

# R10.S1 The six role files say `model: opus`

Serves R10 through contract 2.4: "Each of the six role files has the
front-matter line `model: opus`." The part of the risk it covers: the model
a pod agent runs on is pinned by its role file, so one role file left at
`model: inherit` (or set to another model) lets that role, and every task
and fix round it runs, fall back to the session's model, which may be a
lesser one.

## Given

`agents/` exported read-only from swe-pod at the sha under test. The six
role files are `swe-spec.md`, `swe-plan.md`, `swe-lead.md`, `swe-build.md`,
`swe-test.md` and `swe-review.md` (build-swe-pod contract 2.3, as
`tests/build-swe-pod/test_I2_role_definitions.md` names them).

## When

```text
The runner exports agents/ from swe-pod by sha and runs the check below on
it. No agent is run.
```

## Then

1. All six role files exist.
2. Each has a front-matter block (between the first two `---` lines) with
   exactly one `model:` key, and its value is exactly `opus` (quotes
   around it allowed). The expected value is the spec's (R10, R10.S1) and
   contract 2.4's literal `model: opus`.

```python check
import os
import re
import sys
from pathlib import Path

TAG = "R10.S1"
OK = []
ROLES = ["spec", "plan", "lead", "build", "test", "review"]
WANT = "opus"
ROOT = Path(os.environ.get("EXPORT_SWE_POD") or "/nonexistent")
SHA = os.environ.get("SHA_SWE_POD", "?")


def report(n: int, ok: bool, why: str) -> None:
    OK.append(bool(ok))
    print(f"{TAG}.{n} {'pass' if ok else 'fail'} {why}")


def model_values(text: str) -> list:
    m = re.match(r"---\n(.*?)\n---\n", text, re.S)
    if not m:
        return None
    vals = []
    for line in m.group(1).splitlines():
        km = re.match(r"model:\s*(.*?)\s*$", line)
        if km:
            vals.append(km.group(1).strip().strip("'\""))
    return vals


root = ROOT / "agents"
missing = [r for r in ROLES if not (root / f"swe-{r}.md").is_file()]
report(1, not missing, f"swe-pod {SHA}: " + (
    "all six role files present" if not missing else
    "absent: " + ", ".join(f"agents/swe-{r}.md" for r in missing)))
bad = []
for r in ROLES:
    p = root / f"swe-{r}.md"
    if not p.is_file():
        bad.append(f"swe-{r} absent")
        continue
    vals = model_values(p.read_text())
    if vals is None:
        bad.append(f"swe-{r} has no front-matter")
    elif len(vals) != 1:
        bad.append(f"swe-{r} has {len(vals)} model: keys")
    elif vals[0] != WANT:
        bad.append(f"swe-{r} says model: {vals[0]}")
report(2, not bad, f"front-matter model against {WANT!r}: " + (
    "all six say model: opus" if not bad else "; ".join(bad)))
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- A role file is missing, or has no front matter.
- A role file's front matter has no `model:` key, more than one, or one
  whose value is not `opus`: `inherit`, a dated model id, `sonnet`,
  `haiku`, or a placeholder.

## At base

Expected: fail at check 2. At the base commit set the role files predate
this change, and build-swe-pod's kept test of them
(`tests/build-swe-pod/test_I2_role_definitions.md`, check 2) pins
`model: inherit`. Check 1 passes: the six files exist at base.

Observed 2026-11-07T17:51Z at the base commit set (space b02a772, swe-pod
3b22a1b; the check reads only swe-pod), 1 s wall time, no agent; runner
result:

```
fail (check R10.S1.2: front-matter model against 'opus': swe-spec says model: inherit; swe-plan says model: inherit; swe-lead says model: inherit; swe-build says model: inherit; swe-test says model: inherit; swe-review says model: inherit)
```

Check 1 passed, as expected.

On control exports written from the interface contract alone (and on one
that states the same rules in other phrasings), every check passes; each
fault planted in a copy of them is caught by the check this file's Fails if
names for it.
