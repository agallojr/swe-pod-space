---
scenario: R21.S2
mode: agent (lead)
deliverables: [swe-pod:agents, swe-pod:PROCESS.md as PROCESS.md, swe-pod:templates/records, swe-pod:skills/swe-pod, agent-mesh:skills/space-librarian]
fixture: demo-space
expected_s: 240
heavy: true
env: any
cap_s: 900
---

# R21.S2 The final report lists every suggestion with its outcome

Serves R21 through D1, D2 (`swe-lead`) and D3 (the final-report template).
Heavy: one agent run of about 4 min.

## Given

- A fresh `swe-lead` agent, with the role definitions, the `swe-pod` skill
  and the `space-librarian` skill installed (its commit step is desk), and
  `PROCESS.md` copied to the space root.
- The demo space with this test's overlay: add-greeting verified, whose
  builders made k = 4 suggestions, each routed and given an outcome in the
  ledger:

  | Suggestion | From | Outcome in the ledger |
  |---|---|---|
  | T1.TS1 | T1's report | tested, by `test_T1_TS1_combining_marks` |
  | T1.TS2 | T1's report | unit-tested |
  | T2.TS1 | T2's report | declined, with a reason that runs over a continuation line |
  | T2.TS2 | T2's report | proposed as a scenario |

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
2. Its Test suggestions section names all four suggestions.
3. Each has its outcome: T1.TS1 tested by its test, T1.TS2 unit-tested, T2.TS1
   declined with its reason, T2.TS2 proposed as a scenario.

```python check
TAG = "R21.S2"
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
sec = section(txt, "Test suggestions")
IDS = ["T1.TS1", "T1.TS2", "T2.TS1", "T2.TS2"]
have = [i for i in IDS if re.search(re.escape(i) + r"\b", sec)]
report(2, len(have) == 4, f"{len(have)} of 4 suggestions named")


def seg(sid: str) -> str:
    out = []
    for m in re.finditer(re.escape(sid) + r"\b", sec):
        rest = sec[m.end():]
        cut = [rest.find(o) for o in IDS if rest.find(o) >= 0]
        out.append(rest[:min(cut)] if cut else rest)
    return "\n".join(out)


WANT = {"T1.TS1": r"test_T1_TS1|(?<!unit-)(?<!unit )\btested\b",
        "T1.TS2": r"unit[- ]test",
        "T2.TS1": r"declin\w*[\s\S]*(slow|disk|environment class|outside)",
        "T2.TS2": r"propos\w*[\s\S]*scenario|scenario[\s\S]*propos"}
right = [i for i, rx in WANT.items() if re.search(rx, seg(i), re.I)]
miss = [i for i in IDS if i not in right]
report(3, not miss, f"{len(right)} of 4 with their outcome" + (
    "; missing: " + ", ".join(miss) if miss else ""))
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- A suggestion is missing from the final report.
- A suggestion is listed without its outcome, or a decline without its reason.

## At base

Expected: fail, because the swe-pod deliverables are absent at swe-pod
`8fc5294`; the runner records the first absent deliverable and starts no
agent.

Observed 2026-10-28T00:43Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), runner result:

```
fail (deliverable absent: swe-pod 8fc5294 agents)
```
