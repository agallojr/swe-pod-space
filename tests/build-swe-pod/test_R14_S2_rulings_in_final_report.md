---
scenario: R14.S2
mode: agent (lead)
deliverables: [swe-pod:agents, swe-pod:PROCESS.md as PROCESS.md, swe-pod:templates/records, swe-pod:skills/swe-pod, agent-mesh:skills/space-librarian]
fixture: demo-space
expected_s: 240
heavy: true
env: any
cap_s: 900
---

# R14.S2 Every ruling reaches the final report

Serves R14 through D1, D2 (`swe-lead`) and D3 (the final-report template).
Heavy: one agent run of about 4 min.

## Given

- A fresh `swe-lead` agent, with the role definitions, the `swe-pod` skill
  and the `space-librarian` skill installed (its commit step is desk, per the
  runner protocol), and `PROCESS.md` copied to the space root.
- The demo space with this test's overlay: add-greeting verified, as in
  R14.S1, with k = 3 `Ruling:` lines in its ledger: the name limit counts
  code points; beta reads the greeting at start-up; and T8's Minor is
  deferred. The third runs over two continuation lines, indented 18 spaces.

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

snapshot()
```

## When

```text
add-greeting is verified. Write its final report and file it. Do not merge
anything yet.
Checkouts on this node: space {SPACE}; swe-pod {EXPORT}/swe-pod
```

## Then

1. `changes/add-greeting/report.md` is written.
2. Its Rulings section lists all three rulings of the ledger.

```python check
TAG = "R14.S2"
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

FENCE = "`" * 3


def front_text(text: str) -> str:
    m = re.match(r"---\n(.*?)\n---", text, re.S)
    return m.group(1) if m else ""


def section(text: str, name: str) -> str:
    """Body of the level-2 section called name (a leading number allowed)."""
    out, on, fenced = [], False, False
    for ln in text.splitlines():
        if ln.lstrip().startswith(FENCE):
            fenced = not fenced
        if not fenced and ln.startswith("## "):
            head = re.sub(r"^\d+\.?\s*", "", ln[3:]).strip().lower()
            on = head == name.lower()
            continue
        if on:
            out.append(ln)
    return "\n".join(out)


def prose(text: str) -> str:
    """Text outside fenced blocks and quotes, with inline code removed."""
    out, fenced = [], False
    for ln in text.splitlines():
        if ln.lstrip().startswith(FENCE):
            fenced = not fenced
            continue
        if not fenced and not ln.lstrip().startswith(">"):
            out.append(re.sub(r"`[^`]*`", "", ln))
    return "\n".join(out)


def pin(pod: str, name: str):
    """A repo's pin in pod.yaml text, as sha7, or None."""
    m = re.search(r"^\s*" + name + r":\s*\{[^}]*\bpin:\s*\"?([0-9a-f]{7,40})",
                  pod, re.M)
    if not m:
        m = re.search(r"^\s*" + name + r":\s*\n(?:[ \t]+.*\n)*?[ \t]+pin:"
                      r"\s*\"?([0-9a-f]{7,40})", pod, re.M)
    return m.group(1)[:7] if m else None

rp = SPACE / "changes" / "add-greeting" / "report.md"
txt = rp.read_text() if rp.is_file() else ""
report(1, bool(txt), "report.md " + ("written" if txt else "absent"))
rul = section(txt, "Rulings")
WANT = [("code points", r"code[- ]points?"),
        ("start-up", r"start-?up|build[- ]time"),
        ("deferred Minor", r"__main__\.py:3|main\.py:3")]
hit = [n for n, rx in WANT if re.search(rx, rul, re.I)]
miss = [n for n, rx in WANT if n not in hit]
report(2, len(hit) == 3, f"{len(hit)} of 3 rulings under Rulings" + (
    "; missing: " + ", ".join(miss) if miss else ""))
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- No final report is written.
- Any ruling is missing from its Rulings section, the one written over
  continuation lines included.

## At base

Expected: fail, because the swe-pod deliverables are absent at swe-pod
`8fc5294`; the runner records the first absent deliverable and starts no
agent.

Observed 2026-10-28T00:43Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), runner result:

```
fail (deliverable absent: swe-pod 8fc5294 agents)
```
