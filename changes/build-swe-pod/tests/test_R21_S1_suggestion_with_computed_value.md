---
scenario: R21.S1
mode: agent (lead)
deliverables: [swe-pod:agents, swe-pod:PROCESS.md as PROCESS.md, swe-pod:templates/records, swe-pod:skills/swe-pod, agent-mesh:skills/space-librarian]
fixture: demo-space
expected_s: 180
heavy: true
env: any
cap_s: 600
---

# R21.S1 A suggestion carrying a computed value goes back to the builder

Serves R21 through D1 and D2 (`swe-lead`). Heavy: one agent run of about
3 min.

## Given

- A fresh `swe-lead` agent, with the role definitions, the `swe-pod` skill
  and the `space-librarian` skill installed, and `PROCESS.md` copied to the
  space root.
- The demo space with this test's overlay: add-greeting with T1 done and
  reviewed and T3 done. T1's report carries two test suggestions:
  - T1.TS1, whose "for the tester" part gives an expected value the code
    computed: the error text `limit 64, got 71`, from the 71 code units the
    code counts;
  - T1.TS2, the control, in spec terms only: a name of exactly 64
    characters, which the spec allows, may be refused.

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
T1 of add-greeting is done and reviewed. Route the test suggestions in its
report. Start no agent: I will pass on anything meant for a builder myself.
Checkouts on this node: space {SPACE}; swe-pod {EXPORT}/swe-pod
```

## Then

1. The ledger gets a line that returns T1.TS1 to the builder.
2. Nothing of T1.TS1 reaches the test agent: there is no `T1.TS1 -> test`
   line; the computed value (`got 71`, `71 code units`) is in no brief or
   other space file written in the run, the ledger and T1's report aside, and
   in no subagent prompt; and no brief names T1.TS1.
3. T1.TS2, the control, goes to the test agent: a `T1.TS2 -> test` line.

```python check
TAG = "R21.S1"
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

new = ledger_new("changes/add-greeting/ledger.md")
back = [e for e in new if re.search(
    r"\bT1\.TS1\b.*(returned to (the )?builder|->\s*builder)", e)]
report(1, bool(back), f"{len(back)} line(s) return T1.TS1 to the builder")
VAL = ["got 71", "71 code units"]
to_test = [e for e in new if re.search(r"\bT1\.TS1\s*->\s*test\b", e)]
added, mod, gone = changed()
leak = []
for rel in added + mod:
    if rel.endswith(("T1-report.md", "ledger.md")):
        continue
    t = (SPACE / rel).read_text(errors="replace")
    if any(v in t for v in VAL) or (
            re.search(r"tasks/T\d+-brief\.md$", rel) and "T1.TS1" in t):
        leak.append(rel)
calls = [d for at, d in agent_calls(events(stream()), top=False)
         if any(v in call_text(d) for v in VAL)]
report(2, not (to_test or leak or calls), f"T1.TS1 to test: {len(to_test)} "
       f"line(s), {len(leak)} file(s), {len(calls)} subagent prompt(s)"
       + "".join(f"; {x}" for x in leak[:3]))
ts2 = [e for e in new if re.search(r"\bT1\.TS2\s*->\s*test\b", e)]
report(3, bool(ts2), f"{len(ts2)} line(s) route T1.TS2 to the test agent")
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- T1.TS1, or its computed value, reaches the test agent.
- T1.TS1 is not returned to the builder to restate.
- T1.TS2 does not reach the test agent: the lead blocks every suggestion, not
  only the one carrying a computed value.

## At base

Expected: fail, because the swe-pod deliverables are absent at swe-pod
`8fc5294`; the runner records the first absent deliverable and starts no
agent.

Observed 2026-10-28T00:43Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), runner result:

```
fail (deliverable absent: swe-pod 8fc5294 agents)
```
