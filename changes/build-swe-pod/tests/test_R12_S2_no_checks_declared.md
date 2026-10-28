---
scenario: R12.S2
mode: agent (test, verify)
deliverables: [swe-pod:agents/swe-test.md, swe-pod:PROCESS.md as PROCESS.md, swe-pod:templates/records]
fixture: demo-space
expected_s: 240
heavy: true
env: any
cap_s: 900
---

# R12.S2 No checks declared: verify runs none and says so

Serves R12 through D1, D2 (`swe-test`) and D3 (the evidence template).
Heavy: one agent run of about 4 min.

## Given

- A fresh `swe-test` agent: the session runs as that role definition from
  swe-pod at the sha under test. `PROCESS.md` is copied to the space root,
  and the record templates are readable at the swe-pod path in the prompt.
- The demo space with this test's overlay: add-greeting's plan, a ledger
  through T6 and the dispatch of T7 (verify), the change's three
  project-level tests (each runs in under 2 s), and the T7 brief. The spec
  has no Quality section.
- The setup writes exports of `alpha` and `beta` at their branch heads into
  the run dir, outside the space: code that meets the spec, with each repo's
  unit tests. They are plain folders, not git work trees.
- The prompt is the one the lead gives a local subagent (contract §2.3): the
  brief's space path, then the checkout paths on their own line.

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
Brief: changes/add-greeting/tasks/T7-brief.md
Checkouts on this node: space {SPACE}; alpha {RUN}/repos/alpha; beta {RUN}/repos/beta; swe-pod {EXPORT}/swe-pod
The code checkouts are exports at the commit set of the brief, not git work
trees.
```

## Then

1. Exactly one evidence record is written under
   `changes/add-greeting/evidence/`, counted by record name
   (`<YYYYMMDDTHHMMZ>.md`, or `<YYYYMMDDTHHMMZ>-<shard id>.md`); the task's
   report, `<YYYYMMDDTHHMMZ>-T7-report.md` (plan §2.4), is not a record.
2. Its front-matter says `quality: none-declared`.
3. No lint, format or type-check tool is run.
4. The record has a result for each of R1.S1, R1.S2 and R2.S1, so verify did
   run.

```python check
TAG = "R12.S2"
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

CHG = "changes/add-greeting/"
added, mod, gone = changed()
ev = [p for p in added if p.startswith(CHG + "evidence/") and re.fullmatch(
    r"\d{8}T\d{4}Z(-T\d+[a-z]?)?\.md", p.rsplit("/", 1)[-1])]
report(1, len(ev) == 1, f"{len(ev)} evidence record(s) written")
fm = front_text((SPACE / ev[0]).read_text()) if ev else ""
q = re.search(r"^quality:\s*(.*)$", fm, re.M)
qv = q.group(1).strip() if q else ""
report(2, qv == "none-declared", "quality: " + (
    "none-declared" if qv == "none-declared" else
    "absent" if not q else "another value"))
LINT = re.compile(r"\b(ruff|flake8|pylint|pycodestyle|pyflakes|black|isort|"
                  r"mypy|pyright|pytype|eslint|prettier|shellcheck|"
                  r"markdownlint|mdl|yamllint|bandit|vulture|radon)\b")
evs = events(stream())
ran = [d for at, k, p, d in evs if k == "use" and d.get("name") == "Bash"
       and LINT.search(str((d.get("input") or {}).get("command", "")))]
report(3, not ran, f"{len(ran)} call(s) of a lint, format or type-check tool")
have = [s for s in ("R1.S1", "R1.S2", "R2.S1") if re.search(
    re.escape(s) + r"\s*:\s*(pass|fail|not-run)", fm)]
report(4, len(have) == 3, f"{len(have)} of 3 scenarios have a result")
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- No evidence record, or more than one.
- `quality:` is missing or holds a result, though the spec declares no check.
- A quality tool is run though none is declared.

## At base

Expected: fail, because the swe-pod deliverables are absent at swe-pod
`8fc5294`; the runner records the first absent deliverable and starts no
agent.

Observed 2026-10-28T06:38Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), after the T18 test fixes of 2026-10-28,
runner result:

```
fail (deliverable absent: swe-pod 8fc5294 agents/swe-test.md)
```
