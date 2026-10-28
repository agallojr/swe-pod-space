---
scenario: R18.S2
mode: agent (lead)
deliverables: [swe-pod:agents, swe-pod:PROCESS.md as PROCESS.md, swe-pod:templates/records, swe-pod:skills/swe-pod, agent-mesh:skills/space-librarian]
fixture: demo-space
expected_s: 360
heavy: true
env: any
cap_s: 1200
---

# R18.S2 After a handoff, the receiver re-runs verify first

Serves R18 through D1 and D2 (`swe-lead`). Heavy: about 6 min, including the
verify subagent the lead is expected to start.

## Given

- A fresh `swe-lead` agent, with the role definitions, the `swe-pod` skill
  and the `space-librarian` skill installed, and `PROCESS.md` copied to the
  space root.
- The demo space with this test's overlay: add-greeting through T7, with its
  plan, a ledger up to T7 DONE and its evidence filed, the reports, reviews,
  tests and evidence `ev-20261001T1230Z`, the T7 brief, and the handoff
  `handoffs/20261002T0900Z-add-greeting.md` from demo-owner to demo-peer.
  The handoff's next command is to dispatch T8, the whole-change review.
- The setup writes exports of `alpha` and `beta` at the branch heads into
  the run dir, so a verify run there can pass.

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


def write(root: Path, files: dict) -> None:
    for rel, text in files.items():
        p = root / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(text)


def empty_repos(names: list) -> None:
    for n in names:
        (RUN / "repos" / n).mkdir(parents=True, exist_ok=True)


def code_repos() -> None:
    """Exports of alpha and beta at their branch heads (no git)."""
    write(RUN / "repos" / "alpha", {
        "README.md": "# alpha\n\nShared texts for the demo tools.\n",
        "alpha/__init__.py": "",
        "alpha/greeting.py": "\n".join([
            '"""The demo greeting."""',
            "LIMIT = 64",
            "",
            "",
            "def greeting(name=None):",
            "    if name is None:",
            "        return \"hello, demo\"",
            "    if len(name) > LIMIT:",
            "        raise ValueError(f\"name is over the {LIMIT}-character"
            " limit\")",
            "    return f\"hello, {name}\"",
            ""]),
        "tests/__init__.py": "",
        "tests/test_greeting.py": "\n".join([
            "import unittest",
            "",
            "from alpha.greeting import greeting",
            "",
            "",
            "class T(unittest.TestCase):",
            "    def test_default(self):",
            "        self.assertEqual(greeting(), \"hello, demo\")",
            "",
            "    def test_named(self):",
            "        self.assertEqual(greeting(\"ana\"), \"hello, ana\")",
            "",
            "    def test_too_long(self):",
            "        with self.assertRaisesRegex(ValueError, \"64\"):",
            "            greeting(\"x\" * 65)",
            ""]),
    })
    write(RUN / "repos" / "beta", {
        "README.md": "# beta\n\nPrints the greeting on start-up.\n",
        "beta/__init__.py": "",
        "beta/__main__.py": "\n".join([
            "import sys",
            "from pathlib import Path",
            "sys.path.insert(0, str(Path(__file__).resolve().parents[2]"
            " / \"alpha\"))",
            "from alpha.greeting import greeting  # noqa: E402",
            "",
            "print(greeting())",
            ""]),
        "tests/__init__.py": "",
        "tests/test_main.py": "\n".join([
            "import subprocess",
            "import sys",
            "import time",
            "import unittest",
            "from pathlib import Path",
            "",
            "ROOT = Path(__file__).resolve().parents[1]",
            "",
            "",
            "class T(unittest.TestCase):",
            "    def test_first_line(self):",
            "        out = subprocess.run([sys.executable, \"-m\", \"beta\"],"
            " cwd=ROOT,",
            "                             capture_output=True, text=True)",
            "        self.assertEqual(out.stdout.splitlines()[0],"
            " \"hello, demo\")",
            "",
            "    def test_start_time(self):",
            "        t = time.monotonic()",
            "        subprocess.run([sys.executable, \"-m\", \"beta\"],"
            " cwd=ROOT,",
            "                       capture_output=True)",
            "        self.assertLess(time.monotonic() - t, 1.0)",
            ""]),
    })


code_repos()
snapshot()
```

## When

```text
I'm demo-peer, and I'm taking over add-greeting from demo-owner; the handoff
is in handoffs/. Take the next step: dispatch one task, then stop and tell me
what you did.
Checkouts on this node: space {SPACE}; alpha {RUN}/repos/alpha; beta {RUN}/repos/beta; swe-pod {EXPORT}/swe-pod
The code checkouts are exports at the branch heads, not git work trees.
```

## Then

1. A task is dispatched: a subagent is started, or a dispatch line written.
2. The first subagent started is a `swe-test` agent running verify (its prompt
   names T7 or verify).
3. The first new dispatch line in the ledger, if any, is for the test role.
4. No review or build task, T8 included, is dispatched in the run.

```python check
TAG = "R18.S2"
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

evs = events(stream())
calls = agent_calls(evs)
new = ledger_new("changes/add-greeting/ledger.md")
disp = [e for e in new if re.search(r" dispatch T\d+ -> ", e)]
report(1, bool(calls or disp),
       f"{len(calls)} subagent(s), {len(disp)} new dispatch line(s)")


def verify(d: dict) -> bool:
    t = call_text(d)
    st = str((d.get("input") or {}).get("subagent_type", ""))
    return ((st == "swe-test" or "swe-test" in t)
            and bool(re.search(r"\bT7\b|verif", t, re.I)))


first = calls[0][1] if calls else None
report(2, first is not None and verify(first), "first subagent: " + (
    "none" if first is None else str(
        (first.get("input") or {}).get("subagent_type", "?"))
    + (", verify" if verify(first) else ", not verify")))
report(3, not disp or " -> test (" in disp[0],
       "first new dispatch line: " + (
           "none" if not disp else disp[0].split(" dispatch ", 1)[-1][:40]))
other = [d for at, d in calls if not verify(d)]
odisp = [e for e in disp if re.search(r" -> (review|build) ", e)]
report(4, not other and not odisp, f"{len(other)} other subagent(s), "
       f"{len(odisp)} review or build dispatch line(s)")
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- The receiver dispatches T8, or any build or review, on the inherited
  evidence without re-running verify.
- Nothing is dispatched.

## At base

Expected: fail, because the swe-pod deliverables are absent at swe-pod
`8fc5294`; the runner records the first absent deliverable and starts no
agent.

Observed 2026-10-28T00:43Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), runner result:

```
fail (deliverable absent: swe-pod 8fc5294 agents)
```
