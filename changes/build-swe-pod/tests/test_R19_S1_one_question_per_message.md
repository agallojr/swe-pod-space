---
scenario: R19.S1
mode: agent (spec)
deliverables: [swe-pod:agents/swe-spec.md, swe-pod:PROCESS.md as PROCESS.md, swe-pod:templates/records/spec.md]
fixture: demo-space
expected_s: 90
heavy: true
env: any
cap_s: 600
---

# R19.S1 The spec author asks one question at a time

Serves R19 through D1 and D2 (`swe-spec`). Heavy: one agent run of about
90 s.

## Given

- A fresh `swe-spec` agent: the session runs as that role definition from
  swe-pod at the sha under test, with `PROCESS.md` copied to the space root
  and the spec template exported.
- The demo space as it is: the approved add-greeting, whose spec already
  fixes the 64-character name limit and puts the greeting text in alpha. No
  code checkout is on the node.

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
I'd like beta to greet people by name when they start it.
```

## Then

1. The agent's message holds exactly one question: one `?` outside code,
   quotes and fenced blocks.
2. It writes no spec, plan or other file under `changes/`.
3. The question does not ask what the space already answers: it is not about
   the name limit.

```python check
TAG = "R19.S1"
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

text = prose(final())
n = text.count("?")
report(1, n == 1, f"{n} question mark(s) in the message")
added, mod, gone = changed()
wrote = [p for p in added + mod + gone if p.startswith("changes/")]
report(2, not wrote, f"{len(wrote)} file(s) written under changes/")
qs = [s for s in re.split(r"(?<=[.?!])\s+", text) if "?" in s]
bad = [s for s in qs if re.search(r"\b64\b|\blimit\b|too long|how long|"
                                  r"max(imum)?\s+length|\blength\b", s, re.I)]
report(3, not bad, "the question " + (
    "asks about the name limit add-greeting settles" if bad else
    "does not ask what the space answers"))
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- More than one question in the message, or none.
- A spec is written before the human has answered.
- The question asks for the name limit, which add-greeting already settles.

## At base

Expected: fail, because the swe-pod deliverables are absent at swe-pod
`8fc5294`; the runner records the first absent deliverable and starts no
agent.

Observed 2026-10-28T00:43Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), runner result:

```
fail (deliverable absent: swe-pod 8fc5294 agents/swe-spec.md)
```
