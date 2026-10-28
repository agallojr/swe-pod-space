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
3. No lint, format or type-check tool is run. A Bash call that only prints
   (`echo`, `printf`, or `cat` of a heredoc) runs nothing.
4. The record has a result for each of R1.S1, R1.S2 and R2.S1, so verify did
   run.

```python check
TAG = "R12.S2"
import json
import os
import re
import shlex
import sys
from pathlib import Path


# How a Bash call is read. A simple command that only prints (echo, printf,
# or cat of a heredoc) runs and reads nothing, and a heredoc body is text,
# unless an interpreter reads it; po_acts gives what is left to match on.
PO_PRINT = {"echo", "printf", ":", "true"}
PO_SKIP = {"do", "then", "else", "elif", "if", "while", "until", "!", "{",
           "}", "done", "fi", "esac", "time", "command", "builtin", "exec",
           "nohup", "env", "timeout", "nice"}
PO_CODE = re.compile(r"(ba|z|da|k)?sh|python[\d.]*|perl|ruby|node|osascript|"
                     r"source|\.|eval|xargs")
PO_OPS = re.compile(r"&&|\|\||;;|\|&|[;|()\n]|(?<![<>&])&(?![>&])")
PO_DOC = re.compile(r"(?<!<)<<(?!<)-?")
PO_REDIR = re.compile(r"^(\d|&)?(>>?|<<?-?|<<<)(.*)$")


def po_scan(s: str) -> tuple:
    """(s with quoted, escaped and comment characters blanked, s with only
    comments blanked, the quote left open at the end or None)."""
    mask, keep, q, esc, rem = [], [], None, False, False
    for i, ch in enumerate(s):
        if rem and ch != "\n":
            mask.append(" ")
            keep.append(" ")
            continue
        rem = False
        keep.append(ch)
        if esc:
            mask.append(" ")
            esc = False
        elif ch == "\\" and q != "'":
            mask.append(" ")
            esc = True
        elif q:
            mask.append(" ")
            q = None if ch == q else q
        elif ch in "'\"":
            mask.append(" ")
            q = ch
        elif ch == "#" and (i == 0 or s[i - 1] in " \t\n;|&()"):
            mask.append(" ")
            keep[-1] = " "
            rem = True
        else:
            mask.append(ch)
    return "".join(mask), "".join(keep), q


def po_parts(cmd: str) -> tuple:
    """A Bash command's logical lines, each as (text without comments, its
    mask), and its heredoc bodies, each as (body, line index, position)."""
    phys, lines, bodies, i = cmd.split("\n"), [], [], 0
    while i < len(phys):
        buf = phys[i]
        i += 1
        while i < len(phys):
            mask, keep, q = po_scan(buf)
            if q is None and not re.search(r"(?<!\\)(\\\\)*\\$", buf):
                break
            buf += "\n" + phys[i]
            i += 1
        mask, keep, q = po_scan(buf)
        lines.append((keep, mask))
        for m in PO_DOC.finditer(mask):
            w = re.match(r"\s*(['\"]?)([A-Za-z_][\w.-]*)\1", buf[m.end():])
            if not w:
                continue
            body = []
            while i < len(phys) and phys[i].strip() != w.group(2):
                body.append(phys[i])
                i += 1
            i += 1
            bodies.append(("\n".join(body), len(lines) - 1, m.start()))
    return lines, bodies


def po_words(seg: str) -> list:
    """A simple command's words, past keywords, assignments and wrappers."""
    try:
        a = shlex.split(seg)
    except ValueError:
        a = seg.split()
    while a and (a[0] in PO_SKIP or re.match(r"[A-Za-z_]\w*=", a[0])):
        w = a.pop(0)
        while w in ("timeout", "nice", "env") and a and re.match(
                r"-|\d|[A-Za-z_]\w*=", a[0]):
            a.pop(0)
    return a


def po_operands(a: list) -> tuple:
    """(operands, output targets) of a simple command's words."""
    ops, outs, skip = [], [], None
    for x in a[1:]:
        if skip:
            if skip == ">":
                outs.append(x)
            skip = None
            continue
        m = PO_REDIR.match(x)
        if m:
            if m.group(3):
                if m.group(2).startswith(">") and not m.group(3).startswith(
                        "&"):
                    outs.append(m.group(3))
            else:
                skip = ">" if m.group(2).startswith(">") else "<"
        elif not x.startswith("-"):
            ops.append(x)
    return ops, [t for t in outs if t != "/dev/null"]


def po_acts(cmd: str, writes: bool = False) -> str:
    """What a Bash command runs or reads, as text to match on.

    A simple command that only prints runs nothing and reads nothing, so it
    is left out: echo, printf, : and true, and cat with no file operand and
    no input redirect, as when it prints a heredoc. So are comments and
    heredoc bodies, which are text. A print that pipes into an interpreter
    (sh, python, xargs and the like), or holds a command substitution, is
    kept, and so is the body of a heredoc an interpreter reads, judged by the
    same rule when a shell reads it. With writes, a print redirected into a
    file other than /dev/null is kept too, as the write it is."""
    lines, bodies = po_parts(cmd)
    out, segs = [], []
    for n, (keep, mask) in enumerate(lines):
        cut = [(m.start(), m.end(), m.group(0)) for m in PO_OPS.finditer(mask)]
        starts = [0] + [e for s, e, o in cut]
        ends = [s for s, e, o in cut] + [len(keep)]
        opsafter = [o for s, e, o in cut] + [""]
        row = []
        for s, e, op in zip(starts, ends, opsafter):
            a = po_words(keep[s:e])
            name = os.path.basename(a[0]) if a else ""
            row.append({"s": s, "e": e, "op": op, "a": a, "name": name,
                        "text": keep[s:e].strip(), "mask": mask[s:e]})
        for k, g in enumerate(row):
            feeds = False
            for h in row[k:]:
                if h is not g and PO_CODE.fullmatch(h["name"] or "-"):
                    feeds = True
                if h["op"] not in ("|", "|&"):
                    break
            g["code"] = bool(PO_CODE.fullmatch(g["name"] or "-")) or feeds
        segs.append(row)
        for g in row:
            if not g["a"]:
                continue
            opers, outs = po_operands(g["a"])
            prints = g["name"] in PO_PRINT or (
                g["name"] == "cat" and not opers
                and not re.search(r"(?<![<>])<(?![<(])", g["mask"]))
            if (prints and not g["code"] and "$(" not in g["text"]
                    and "`" not in g["text"]):
                if writes and outs:
                    out.append(g["text"])
                continue
            out.append(g["text"])
    for body, n, pos in bodies:
        g = next((x for x in segs[n] if x["s"] <= pos <= x["e"]), None)
        if not g or not g["code"]:
            continue
        shell = re.fullmatch(r"(ba|z|da|k)?sh|source|\.", g["name"] or "-")
        out.append(po_acts(body, writes) if shell else body)
    return "\n".join(x for x in out if x)


def po_blob(d: dict, writes: bool = False) -> str:
    """A tool call's paths and text, its Bash command read by po_acts."""
    inp = dict(d.get("input") or {})
    if d.get("name") == "Bash":
        inp["command"] = po_acts(str(inp.get("command", "")), writes)
    return " ".join(str(inp.get(k, "")) for k in (
        "file_path", "path", "command", "pattern", "glob", "content",
        "new_string"))


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
       and LINT.search(po_acts(str((d.get("input") or {}).get(
           "command", ""))))]
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

Observed 2026-10-28T09:42Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), after the T18 test fixes of verify round 3,
with no agent started; runner result:

```
fail (deliverable absent: swe-pod 8fc5294 agents/swe-test.md)
```
