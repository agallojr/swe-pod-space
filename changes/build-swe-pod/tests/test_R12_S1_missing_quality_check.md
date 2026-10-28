---
scenario: R12.S1
mode: agent (skill)
deliverables: [swe-pod:skills/swe-pod, swe-pod:PROCESS.md as PROCESS.md]
fixture: demo-space
expected_s: 120
heavy: true
env: any
cap_s: 600
---

# R12.S1 A missing quality check keeps the change unverified

Serves R12 through D1 (the state rules) and D4 (the skill). Heavy: one agent
run of about 2 min, so the lead asks the operator before it runs.

## Given

- A fresh default agent with the `swe-pod` skill from swe-pod at the sha under
  test, and that sha's `PROCESS.md` copied to the space root.
- The demo space with this test's overlay: change `add-greeting` with its
  plan, a ledger through the whole-change review (T8: spec ok, one Minor),
  every build, test and review record, and one evidence record,
  `ev-20261101T1230Z`, at the branch heads (alpha `d4d4d4d`, beta
  `e5e5e5e`). Its scenarios and unit suites all pass, and its `quality:` is
  `{Q1: pass}`.
- The setup adds a Quality section to the copied spec, declaring Q1
  (`demo-lint`) and Q2 (`demo-docs --strict`). So the change would be
  verified but for Q2, which has no result.

```python setup
import hashlib
import json
import os
from pathlib import Path

RUN = Path(os.environ["RUN_DIR"])
SPACE = Path(os.environ["SPACE"])


def snapshot() -> None:
    """Record every space file's hash, and keep a copy of each ledger."""
    files = {}
    for p in sorted(SPACE.rglob("*")):
        if p.is_file():
            files[str(p.relative_to(SPACE))] = hashlib.sha256(
                p.read_bytes()).hexdigest()
    (RUN / "before.json").write_text(json.dumps(files, indent=1))
    for rel in files:
        if rel.endswith("ledger.md"):
            dst = RUN / "before" / rel
            dst.parent.mkdir(parents=True, exist_ok=True)
            dst.write_bytes((SPACE / rel).read_bytes())

spec = SPACE / "changes" / "add-greeting" / "spec.md"
text = spec.read_text()
assert "\n## Approaches" in text, "fixture spec has no Approaches section"
quality = "\n".join([
    "## Quality", "",
    "### Q1 Linter clean",
    "The changed code SHALL pass `demo-lint` with each repo's configuration.",
    "- check: `demo-lint` in alpha and in beta; passing is exit status 0", "",
    "### Q2 Docs build",
    "The shipped docs SHALL build with no warning.",
    "- check: `demo-docs --strict` in beta; passing is exit status 0", "", ""])
spec.write_text(text.replace("## Approaches", quality + "## Approaches", 1))
snapshot()
```

## When

```text
Where are we on add-greeting?
```

## Then

1. The agent does not report add-greeting as verified: it says the change is
   building or not verified, and if it regenerates `STATUS.md`, the change's
   heading line does not say `state: verified`.
2. It names Q2 as the declared check with no result.
3. No evidence record or other record is added, changed or removed; only
   `STATUS.md` may be regenerated.

```python check
TAG = "R12.S1"
import json
import os
import re
import sys
from pathlib import Path

RUN = Path(os.environ["RUN_DIR"])
SPACE = Path(os.environ["SPACE"])
OK = []


def report(n: int, ok: bool, why: str) -> None:
    OK.append(bool(ok))
    print(f"{TAG}.{n} {'pass' if ok else 'fail'} {why}")


def final(k: int = 1) -> str:
    return Path(os.environ[f"FINAL_{k}"]).read_text()


def stream(k: int = 1) -> Path:
    return Path(os.environ[f"STREAM_{k}"])

import hashlib


def changed() -> tuple:
    """Space paths added, changed and removed since setup."""
    before = json.loads((RUN / "before.json").read_text())
    now = {}
    for p in SPACE.rglob("*"):
        if p.is_file():
            now[str(p.relative_to(SPACE))] = hashlib.sha256(
                p.read_bytes()).hexdigest()
    added = sorted(set(now) - set(before))
    gone = sorted(set(before) - set(now))
    mod = sorted(k for k in now if k in before and now[k] != before[k])
    return added, mod, gone

text = final()
st_path = SPACE / "STATUS.md"
st = st_path.read_text() if st_path.is_file() else ""
m = re.search(r"^## add-greeting\s+state:\s*(\S+)", st, re.M)
st_state = m.group(1) if m else None
neg = re.search(r"(\bnot\b|n't\b|\bnever\b|\bcannot\b)[^.\n]{0,40}\bverified\b"
                r"|\bunverified\b", text, re.I)
building = re.search(r"\bbuilding\b", text, re.I)
claims = re.search(r"\bstate\W{0,6}verified\b", text, re.I)
said = ("verified" if claims or st_state == "verified" else
        "not verified" if neg or building else "neither")
report(1, said == "not verified",
       f"add-greeting reported {said}; STATUS.md state {st_state or 'absent'}")
q2 = bool(re.search(r"\bQ2\b", text))
report(2, q2, "Q2 " + ("named" if q2 else "not named"))
added, mod, gone = changed()
touched = [p for p in added + mod + gone if p != "STATUS.md"]
report(3, not touched, f"{len(touched)} record(s) added, changed or removed "
       "besides STATUS.md")
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- add-greeting is reported verified while Q2 has no result.
- Q2's missing result goes unmentioned.
- An evidence record is written or edited to supply a result for Q2.

## At base

Expected: fail, because the swe-pod deliverables are absent at swe-pod
`8fc5294`; the runner records the first absent deliverable and starts no
agent.

Observed 2026-10-28T00:43Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), runner result:

```
fail (deliverable absent: swe-pod 8fc5294 skills/swe-pod)
```
