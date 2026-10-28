---
scenario: R18.S1
mode: agent (fresh, with the skill)
deliverables: [swe-pod:skills/swe-pod, swe-pod:templates/space/AGENTS.md as AGENTS.md, swe-pod:PROCESS.md as PROCESS.md]
fixture: demo-space
expected_s: 120
heavy: true
env: any
cap_s: 600
---

# R18.S1 A fresh agent tells where each open change stands

Serves R18 through D3 (`AGENTS.md`) and D4 (the skill). Heavy: one agent run
of about 2 min.

## Given

- A fresh default agent with no session history and the `swe-pod` skill
  installed. The space template's `AGENTS.md` is copied to the space root,
  with `PROCESS.md`. No instruction file reaches the agent: it sees
  `AGENTS.md` only if it reads it with a tool (runner protocol).
- The demo space with this test's overlay, holding two open changes:
  - add-greeting, building: T1 done and reviewed, T3 done, and T2 (after
    T1) not yet dispatched, so T2 is next;
  - add-farewell, approved at 2026-11-02T08:00Z, with no plan, so its plan is
    next.
- A `STATUS.md` that matches those records, in the format of contract §2.6.

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
Where are we?
```

## Then

1. The answer gives add-greeting's state as building and add-farewell's as
   approved.
2. It gives add-greeting's next task as T2, and add-farewell's next step as
   its plan.
3. The agent read `AGENTS.md`, `STATUS.md` and at least one ledger with a
   tool.

```python check
TAG = "R18.S1"
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

AGENT_TOOLS = ("Agent", "Task")


def events(path: Path) -> list:
    """Ordered (position, kind, parent, data) items of a stream-json file.

    kind is text, use (a tool call) or result (a tool result); parent is the
    Agent call id for a subagent's items, else None."""
    out = []
    for i, line in enumerate(path.read_text().splitlines()):
        try:
            ev = json.loads(line)
        except json.JSONDecodeError:
            continue
        t = ev.get("type")
        if t not in ("assistant", "user"):
            continue
        parent = ev.get("parent_tool_use_id")
        content = (ev.get("message") or {}).get("content") or []
        if not isinstance(content, list):
            continue
        for j, c in enumerate(content):
            if not isinstance(c, dict):
                continue
            ct, at = c.get("type"), (i, j)
            if ct == "text" and t == "assistant":
                out.append((at, "text", parent, c.get("text") or ""))
            elif ct == "tool_use":
                out.append((at, "use", parent, c))
            elif ct == "tool_result":
                body = c.get("content")
                if isinstance(body, list):
                    body = "\n".join(x.get("text", "") for x in body
                                     if isinstance(x, dict))
                out.append((at, "result", parent,
                            {"id": c.get("tool_use_id"),
                             "text": str(body or ""),
                             "is_error": bool(c.get("is_error"))}))
    return out


def agent_calls(evs: list, top: bool = True) -> list:
    """(position, call) for each Agent call; the session's own by default."""
    return [(at, d) for at, k, p, d in evs if k == "use"
            and d.get("name") in AGENT_TOOLS and (p is None or not top)]


def call_text(d: dict) -> str:
    inp = d.get("input") or {}
    return " ".join(str(inp.get(k, "")) for k in
                    ("subagent_type", "description", "prompt"))


def tool_blob(d: dict) -> str:
    inp = d.get("input") or {}
    return " ".join(str(inp.get(k, "")) for k in (
        "file_path", "path", "command", "pattern", "glob", "content",
        "new_string"))

text = final()
IDS = ["add-greeting", "add-farewell"]


def segs(cid: str) -> str:
    """The text after each mention of cid, up to the next change id."""
    out = []
    for m in re.finditer(re.escape(cid), text):
        rest = text[m.end():]
        cut = [rest.find(o) for o in IDS if rest.find(o) >= 0]
        out.append(rest[:min(cut)] if cut else rest)
    return "\n".join(out)


g, f = segs("add-greeting"), segs("add-farewell")
s1 = (bool(re.search(r"\bbuilding\b", g, re.I)),
      bool(re.search(r"\bapproved\b", f, re.I)))
report(1, all(s1), f"state building for add-greeting {s1[0]}, approved for "
       f"add-farewell {s1[1]}")
s2 = (bool(re.search(r"\bT2\b", g)), bool(re.search(r"\bplan", f, re.I)))
report(2, all(s2), f"next T2 for add-greeting {s2[0]}, plan for add-farewell "
       f"{s2[1]}")
evs = events(stream())
blobs = [tool_blob(d) for at, k, p, d in evs if k == "use"
         and d.get("name") in ("Read", "Bash", "Grep")]
read = {n: any(n in b for b in blobs)
        for n in ("AGENTS.md", "STATUS.md", "ledger.md")}
report(3, all(read.values()), "read: " + ", ".join(
    f"{n} {v}" for n, v in read.items()))
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- Either change's state or next task is missing or wrong.
- The answer is not drawn from `AGENTS.md`, `STATUS.md` and the ledgers.

## At base

Expected: fail, because the swe-pod deliverables are absent at swe-pod
`8fc5294`; the runner records the first absent deliverable and starts no
agent.

Observed 2026-10-28T00:43Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), runner result:

```
fail (deliverable absent: swe-pod 8fc5294 skills/swe-pod)
```
