---
scenario: R13.S1
mode: agent (lead)
deliverables: [swe-pod:agents, swe-pod:PROCESS.md as PROCESS.md, swe-pod:templates/records, swe-pod:skills/swe-pod, agent-mesh:skills/space-librarian]
fixture: demo-space
expected_s: 150
heavy: true
env: any
cap_s: 600
---

# R13.S1 A heavy check: the lead asks first

Serves R13 through D1 and D2 (`swe-lead`). Heavy: one agent run of about
2.5 min.

## Given

- A fresh `swe-lead` agent, with the role definitions, the `swe-pod` skill
  and the `space-librarian` skill installed, and `PROCESS.md` copied to the
  space root.
- The demo space with this test's overlay: add-greeting's plan, whose T7
  (verify, `runs: local`) waits only on T1, T2, T3 and T6; a ledger in which
  all four are done; their reports and reviews; and the change's three
  project-level tests. One of them, `test_R2_S1_startup_line`, is heavy:
  `expected_s: 240`, `heavy: true`, `cap_s: 600`, run by
  `python3 bench/startup.py --runs 200 --max-s 1`.
- The human is present; the prompt says so.

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
I'm here in this session. T1 to T6 of add-greeting are done; dispatch whatever
is ready.
Checkouts on this node: space {SPACE}; swe-pod {EXPORT}/swe-pod
```

## Then

1. T7 is not dispatched: no subagent is started for it, the ledger gets no
   `dispatch T7` line, and the heavy command is not run.
2. The agent's message names the command (`startup.py`).
3. It gives the cap, 600 s (10 min).
4. It gives the expected wall time, 240 s (4 min).

```python check
TAG = "R13.S1"
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

STAMP = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2})?Z ")


def ledger_events(text: str) -> list:
    """Events of a ledger, each continuation line joined to its event."""
    out = []
    for ln in text.splitlines():
        if STAMP.match(ln):
            out.append(ln.rstrip())
        elif ln.startswith(" " * 18) and ln.strip() and out:
            out[-1] += " " + ln.strip()
    return out


def ledger_new(rel: str) -> list:
    """Events in the space's ledger at rel that setup did not put there."""
    now, old = SPACE / rel, RUN / "before" / rel
    cur = ledger_events(now.read_text()) if now.is_file() else []
    was = set(ledger_events(old.read_text())) if old.is_file() else set()
    return [e for e in cur if e not in was]

text = final()
evs = events(stream())
t7 = [d for at, d in agent_calls(evs)
      if re.search(r"\bT7\b|verif|swe-test", call_text(d), re.I)]
new = ledger_new("changes/add-greeting/ledger.md")
disp = [e for e in new if re.search(r" dispatch T7\b", e)]
ran = [d for at, k, p, d in evs if k == "use" and d.get("name") == "Bash"
       and "startup.py" in str((d.get("input") or {}).get("command", ""))]
report(1, not (t7 or disp or ran), f"T7: {len(t7)} subagent(s), "
       f"{len(disp)} dispatch line(s); heavy command run {len(ran)} time(s)")
report(2, "startup.py" in text, "command " + (
    "named" if "startup.py" in text else "not named"))
cap = re.search(r"\b600\s*(s|sec|secs|seconds)\b|\b10\s*(min|mins|minutes)\b"
                r"|\bcap\w*\W{0,4}600\b", text, re.I)
report(3, bool(cap), "cap of 600 s " + ("given" if cap else "not given"))
exp = re.search(r"\b240\s*(s|sec|secs|seconds)\b|\b4\s*(min|mins|minutes)\b"
                r"|\bexpected\w*\W{0,4}240\b", text, re.I)
report(4, bool(exp), "expected 240 s " + ("given" if exp else "not given"))
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- T7 is dispatched, or its heavy command is run, before the human has the
  command, caps and expected time.
- The message lacks the command, the cap or the expected wall time.

## At base

Expected: fail, because the swe-pod deliverables are absent at swe-pod
`8fc5294`; the runner records the first absent deliverable and starts no
agent.

Observed 2026-10-28T00:43Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), runner result:

```
fail (deliverable absent: swe-pod 8fc5294 agents)
```
