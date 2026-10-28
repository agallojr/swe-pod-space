---
scenario: R11.S1
mode: agent (test, verify)
deliverables: [swe-pod:agents, swe-pod:PROCESS.md as PROCESS.md, swe-pod:templates/records]
fixture: demo-space
expected_s: 420
heavy: true
env: any
cap_s: 1200
---

# R11.S1 Evidence fields

Serves R11 (spec §5.5; D2, D3). Heavy: expected 420 s of agent time, so the
lead asks the operator before it runs (spec §5.4, §7).

## Given

- A fresh `swe-test` session with the role definitions and `PROCESS.md`,
  given T7's verify brief, and told this node's environment class (derived
  by the setup from the platform: macos-laptop or linux-server).
- The setup adds a Quality section to the spec with one check, Q1
  (`python3 -m compileall -q .` in each affected repo exits 0).
- The overlay: T7's brief with the commit set under test (space, alpha and
  beta heads, gamma at its pin `c3c3c3c`), and the three project-level
  tests. The regression suite `tests/` is empty.
- Code repos made by the setup as git repos under `{RUN}/repos/`: alpha with
  T1's greeting; beta whose change prints its banner before the greeting,
  so R2.S1 fails while both unit suites pass (hand-checked: R1.S1 pass,
  R1.S2 pass, R2.S1 fail, alpha pass, beta pass, Q1 pass).

```python setup
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

RUN = Path(os.environ["RUN_DIR"])
SPACE = Path(os.environ["SPACE"])
REPOS = RUN / "repos"
SKIP = {".git", "__pycache__", ".pytest_cache"}
FAKE = {"A0": "a1a1a1a", "A1": "d4d4d4d", "B0": "b2b2b2b", "B1": "e5e5e5e"}
GIT_ENV = {
    "PATH": os.environ.get("PATH", "/usr/bin:/bin"),
    "HOME": os.environ["CHECK_HOME"],
    "GIT_CONFIG_NOSYSTEM": "1",
    "GIT_CONFIG_GLOBAL": os.devnull,
    "GIT_AUTHOR_NAME": "demo-owner",
    "GIT_AUTHOR_EMAIL": "demo-owner@example.invalid",
    "GIT_COMMITTER_NAME": "demo-owner",
    "GIT_COMMITTER_EMAIL": "demo-owner@example.invalid",
    "GIT_AUTHOR_DATE": "2026-11-01T08:00:00Z",
    "GIT_COMMITTER_DATE": "2026-11-01T08:00:00Z",
}


def tree(root: Path) -> dict:
    out = {}
    if root.is_dir():
        for p in sorted(root.rglob("*")):
            rel = p.relative_to(root)
            if (p.is_file() and not SKIP & set(rel.parts)
                    and p.suffix != ".pyc"):
                out[str(rel)] = hashlib.sha256(p.read_bytes()).hexdigest()
    return out


def git(cwd: Path, *args: str) -> str:
    r = subprocess.run(["git", *args], cwd=cwd, env=GIT_ENV,
                       capture_output=True, text=True, check=True)
    return r.stdout.strip()


def write_files(root: Path, files: dict) -> None:
    for rel, text in files.items():
        p = root / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(text)


def make_repo(name: str, base: dict, commits: tuple = (),
              real: bool = True) -> list:
    """REPOS/<name>: base on main, then each (task, files) commit on the
    change branch. Returns the sha7s, base first; a plain folder gets []."""
    root = REPOS / name
    write_files(root, base)
    if not real:
        for _, files in commits:
            write_files(root, files)
        return []
    git(root, "init", "-q")
    git(root, "symbolic-ref", "HEAD", "refs/heads/main")
    git(root, "add", "-A")
    git(root, "commit", "-q", "-m", f"{name} 1.0")
    shas = [git(root, "rev-parse", "--short=7", "HEAD")]
    git(root, "checkout", "-q", "-b", "change/add-greeting")
    for task, files in commits:
        write_files(root, files)
        git(root, "add", "-A")
        git(root, "commit", "-q", "-m", f"{task} in {name}", "-m",
            f"Change: add-greeting\nTask: {task}")
        shas.append(git(root, "rev-parse", "--short=7", "HEAD"))
    return shas


def values(alpha: list, beta: list) -> dict:
    out = dict(FAKE)
    for key, shas in (("A", alpha), ("B", beta)):
        for k, sha in enumerate(shas[:2]):
            out[f"{key}{k}"] = sha
    return out


def fill(vals: dict) -> None:
    """Replace the {{KEY}} placeholders in every text file of the space."""
    for p in SPACE.rglob("*"):
        if not p.is_file():
            continue
        try:
            text = p.read_text()
        except UnicodeDecodeError:
            continue
        new = re.sub(r"\{\{([A-Z][A-Z0-9]*)\}\}",
                     lambda m: vals.get(m.group(1), m.group(0)), text)
        if new != text:
            p.write_text(new)


def set_pins(vals: dict) -> None:
    pod = SPACE / "pod.yaml"
    text = pod.read_text()
    for old, key in (("a1a1a1a", "A0"), ("b2b2b2b", "B0")):
        text = text.replace(f'pin: "{old}"', f'pin: "{vals[key]}"')
    pod.write_text(text)


def edit(rel: str, old: str, new: str) -> None:
    p = SPACE / rel
    text = p.read_text()
    if old not in text:
        raise SystemExit(f"setup: text to edit not found in {rel}")
    p.write_text(text.replace(old, new, 1))


def finish_setup(extra: dict = None, keep: tuple = ()) -> None:
    data = {"REPOS": str(REPOS)}
    data.update(extra or {})
    (RUN / "subst.json").write_text(json.dumps(data))
    files = {r: (SPACE / r).read_text() for r in keep
             if (SPACE / r).is_file()}
    (RUN / "before.json").write_text(json.dumps(
        {"space": tree(SPACE), "repos": tree(REPOS), "files": files},
        indent=1))


ALPHA_BASE = {
    "README.md": (
        "# alpha\n"
        "\n"
        "The shared text library of the demo project.\n"
        "\n"
        "- `checksum(text)`: a short hex checksum of a text.\n"
        "\n"
        "Unit tests: run `python3 -m unittest discover -s tests` from the\n"
        "repo root.\n"
    ),
    "CHANGELOG.md": (
        "# Changelog\n"
        "\n"
        "## Unreleased\n"
        "\n"
        "## 1.0\n"
        "\n"
        "- checksum(text)\n"
    ),
    "CONTRIBUTING.md": (
        "# Contributing\n"
        "\n"
        "All public functions live in `alpha/__init__.py`, with their unit\n"
        "tests in `tests/test_alpha.py`. Every change adds one line per\n"
        "user-visible behavior to `CHANGELOG.md`, under Unreleased.\n"
    ),
    "alpha/__init__.py": (
        "\"\"\"alpha: the shared text library of the demo project.\"\"\"\n"
        "\n"
        "__version__ = \"1.0\"\n"
        "\n"
        "\n"
        "def checksum(text: str) -> str:\n"
        "    \"\"\"The sum of the code points, modulo 65536, in 4 hex digits.\"\"\"\n"
        "    return format(sum(map(ord, text)) % 65536, \"04x\")\n"
    ),
    "tests/test_alpha.py": (
        "import unittest\n"
        "\n"
        "import alpha\n"
        "\n"
        "\n"
        "class ChecksumTest(unittest.TestCase):\n"
        "    def test_checksum_empty(self):\n"
        "        self.assertEqual(alpha.checksum(\"\"), \"0000\")\n"
        "\n"
        "    def test_checksum_ab(self):\n"
        "        self.assertEqual(alpha.checksum(\"ab\"), \"00c3\")\n"
    ),
}
ALPHA_T1 = {
    "alpha/__init__.py": (
        "\"\"\"alpha: the shared text library of the demo project.\"\"\"\n"
        "\n"
        "__version__ = \"1.0\"\n"
        "\n"
        "\n"
        "def checksum(text: str) -> str:\n"
        "    \"\"\"The sum of the code points, modulo 65536, in 4 hex digits.\"\"\"\n"
        "    return format(sum(map(ord, text)) % 65536, \"04x\")\n"
        "\n"
        "\n"
        "_LIMIT = 64\n"
        "\n"
        "\n"
        "def greeting(name=None):\n"
        "    \"\"\"The greeting; a name longer than 64 code points is refused.\"\"\"\n"
        "    if name is None:\n"
        "        return \"hello, demo\"\n"
        "    if len(name) > _LIMIT:\n"
        "        raise ValueError(f\"name longer than the {_LIMIT}-character limit\")\n"
        "    return f\"hello, {name}\"\n"
    ),
    "tests/test_alpha.py": (
        "import unittest\n"
        "\n"
        "import alpha\n"
        "\n"
        "\n"
        "class ChecksumTest(unittest.TestCase):\n"
        "    def test_checksum_empty(self):\n"
        "        self.assertEqual(alpha.checksum(\"\"), \"0000\")\n"
        "\n"
        "    def test_checksum_ab(self):\n"
        "        self.assertEqual(alpha.checksum(\"ab\"), \"00c3\")\n"
        "\n"
        "\n"
        "class GreetingTest(unittest.TestCase):\n"
        "    def test_greeting_default(self):\n"
        "        self.assertEqual(alpha.greeting(), \"hello, demo\")\n"
        "\n"
        "    def test_greeting_long_name(self):\n"
        "        with self.assertRaises(ValueError):\n"
        "            alpha.greeting(\"x\" * 65)\n"
    ),
    "CHANGELOG.md": (
        "# Changelog\n"
        "\n"
        "## Unreleased\n"
        "\n"
        "- greeting(name=None)\n"
        "\n"
        "## 1.0\n"
        "\n"
        "- checksum(text)\n"
    ),
}
BETA_BASE = {
    "README.md": (
        "# beta\n"
        "\n"
        "The demo command-line tool. `python3 -m beta` prints its banner;\n"
        "`--count-lines` counts the lines of standard input.\n"
        "\n"
        "Unit tests: run `python3 -m unittest discover -s tests` from the\n"
        "repo root.\n"
    ),
    "beta/__init__.py": (
        "\"\"\"beta: the demo command-line tool.\"\"\"\n"
    ),
    "beta/__main__.py": (
        "\"\"\"beta: the demo command-line tool.\"\"\"\n"
        "import sys\n"
        "\n"
        "\n"
        "def main(argv: list) -> int:\n"
        "    print(\"beta 1.0\")\n"
        "    if \"--count-lines\" in argv:\n"
        "        print(sum(1 for _ in sys.stdin))\n"
        "    return 0\n"
        "\n"
        "\n"
        "if __name__ == \"__main__\":\n"
        "    sys.exit(main(sys.argv[1:]))\n"
    ),
    "tests/test_beta.py": (
        "import contextlib\n"
        "import io\n"
        "import unittest\n"
        "\n"
        "from beta.__main__ import main\n"
        "\n"
        "\n"
        "class MainTest(unittest.TestCase):\n"
        "    def test_banner(self):\n"
        "        out = io.StringIO()\n"
        "        with contextlib.redirect_stdout(out):\n"
        "            self.assertEqual(main([]), 0)\n"
        "        self.assertIn(\"beta 1.0\", out.getvalue())\n"
    ),
}
BETA_T2 = {
    "beta/__main__.py": (
        "\"\"\"beta: the demo command-line tool.\"\"\"\n"
        "import sys\n"
        "\n"
        "import alpha\n"
        "\n"
        "\n"
        "def main(argv: list) -> int:\n"
        "    print(\"beta 1.0\")\n"
        "    print(alpha.greeting())\n"
        "    if \"--count-lines\" in argv:\n"
        "        print(sum(1 for _ in sys.stdin))\n"
        "    return 0\n"
        "\n"
        "\n"
        "if __name__ == \"__main__\":\n"
        "    sys.exit(main(sys.argv[1:]))\n"
    ),
    "tests/test_beta.py": (
        "import contextlib\n"
        "import io\n"
        "import unittest\n"
        "\n"
        "from beta.__main__ import main\n"
        "\n"
        "\n"
        "class MainTest(unittest.TestCase):\n"
        "    def test_banner(self):\n"
        "        out = io.StringIO()\n"
        "        with contextlib.redirect_stdout(out):\n"
        "            self.assertEqual(main([]), 0)\n"
        "        self.assertIn(\"beta 1.0\", out.getvalue())\n"
        "\n"
        "    def test_greeting_printed(self):\n"
        "        import alpha\n"
        "        out = io.StringIO()\n"
        "        with contextlib.redirect_stdout(out):\n"
        "            main([])\n"
        "        self.assertIn(alpha.greeting(), out.getvalue())\n"
    ),
    "README.md": (
        "# beta\n"
        "\n"
        "The demo command-line tool. `python3 -m beta` prints its banner;\n"
        "`--count-lines` counts the lines of standard input.\n"
        "\n"
        "Unit tests: with the alpha checkout on PYTHONPATH, run\n"
        "`python3 -m unittest discover -s tests` from the repo root.\n"
    ),
}
Q1_TEXT = (
    "## Quality\n"
    "\n"
    "### Q1 Byte-compiles\n"
    "The changed code SHALL byte-compile with the node's Python 3.\n"
    "- check: `python3 -m compileall -q .` in each affected repo; passing is exit\n"
    "  status 0\n"
    "\n"
)

edit("changes/add-greeting/spec.md", "#" * 2 + " Approaches",
     Q1_TEXT + "#" * 2 + " Approaches")
alpha = make_repo("alpha", ALPHA_BASE, (("T1", ALPHA_T1),))
beta = make_repo("beta", BETA_BASE, (("T2", BETA_T2),))
vals = values(alpha, beta)
fill(vals)
set_pins(vals)
env = "macos-laptop" if sys.platform == "darwin" else "linux-server"
(RUN / "expected.json").write_text(json.dumps(
    {"alpha": vals["A1"], "beta": vals["B1"], "env": env}))
finish_setup({"ENVCLASS": env})
```

## When

One test-agent step, prompted as the lead dispatches.

```text
changes/add-greeting/tasks/T7-brief.md

Checkouts on this node, one per line:
Project Space proj:demo: {SPACE}
swe-pod: {EXPORT}/swe-pod
alpha: {REPOS}/alpha
beta: {REPOS}/beta
Environment class of this node: {ENVCLASS}
```

## Then

1. Exactly one new evidence record is in `changes/add-greeting/evidence/`, named
   `<YYYYMMDDTHHMMZ>.md`, with `id: ev-<that stamp>` and `change: add-greeting`.
2. `commit_set` names the space and every repo of `pod.yaml`, each with a sha7:
   alpha and beta at the commit set under test, gamma at its pin `c3c3c3c`.
3. `env` is this node's environment class.
4. `scenarios` holds R1.S1 pass, R1.S2 pass and R2.S1 fail.
5. `unit` holds alpha pass and beta pass.
6. `quality` holds Q1 pass.
7. `wall_time_s` is an integer number of seconds.
8. `actor` is `<handle>/test`.
9. Logs appear only as pointers: the body has no raw test log (no `Ran <n> test`
   line, no `Traceback (most recent call last)`), and no machine path (none
   of this run's paths, no home path).

```python check
import hashlib
import json
import os
import re
import sys
from pathlib import Path

TAG = "R11.S1"
OK = []
RUN = Path(os.environ["RUN_DIR"])
SPACE = Path(os.environ["SPACE"])
REPOS = RUN / "repos"
SKIP = {".git", "__pycache__", ".pytest_cache"}
BEFORE = json.loads((RUN / "before.json").read_text())
CHANGE = "changes/add-greeting"


def report(n: int, ok: bool, why: str) -> None:
    OK.append(bool(ok))
    print(f"{TAG}.{n} {'pass' if ok else 'fail'} {why}")


def finish() -> None:
    sys.exit(0 if OK and all(OK) else 1)


def tree(root: Path) -> dict:
    out = {}
    if root.is_dir():
        for p in sorted(root.rglob("*")):
            rel = p.relative_to(root)
            if (p.is_file() and not SKIP & set(rel.parts)
                    and p.suffix != ".pyc"):
                out[str(rel)] = hashlib.sha256(p.read_bytes()).hexdigest()
    return out


def changed(kind: str = "space") -> tuple:
    """(added, modified, removed) paths since setup, in the space or repos."""
    before = BEFORE[kind]
    after = tree(SPACE if kind == "space" else REPOS)
    added = sorted(set(after) - set(before))
    modified = sorted(k for k in before
                      if k in after and before[k] != after[k])
    removed = sorted(set(before) - set(after))
    return added, modified, removed


def summary(k: int) -> dict:
    p = os.environ.get(f"SUMMARY_{k}", "")
    if p and Path(p).is_file():
        return json.loads(Path(p).read_text())
    return {"tool_uses": [], "permission_denials": [], "result": ""}


def uses(k: int, names: tuple = (), sub: bool = False) -> list:
    """Tool calls of step k by the session agent (sub=False) or subagents."""
    return [u for u in summary(k).get("tool_uses") or []
            if (not names or u.get("name") in names)
            and bool(u.get("subagent")) == sub]


def arg(u: dict, key: str) -> str:
    return str((u.get("input") or {}).get(key, "") or "")


def final(k: int) -> str:
    return summary(k).get("result") or ""


def texts(k: int) -> list:
    """The session agent's text blocks of step k, the final one included."""
    out = []
    p = os.environ.get(f"STREAM_{k}", "")
    if p and Path(p).is_file():
        for line in Path(p).read_text().splitlines():
            try:
                ev = json.loads(line)
            except ValueError:
                continue
            if ev.get("type") != "assistant" or ev.get("parent_tool_use_id"):
                continue
            for c in (ev.get("message") or {}).get("content") or []:
                if isinstance(c, dict) and c.get("type") == "text":
                    out.append(c.get("text") or "")
    out.append(final(k))
    return out


def printed(k: int) -> list:
    """Lines the session agent printed: its text, Bash commands, outputs."""
    lines = []
    for t in texts(k):
        lines += t.splitlines()
    for u in uses(k, ("Bash",)):
        lines += arg(u, "command").splitlines()
        lines += str(u.get("output") or "").splitlines()
    return lines


def desk(k: int) -> list:
    """The commands a desk step printed instead of running."""
    return [ln.split("DESK:", 1)[1].strip().strip("`")
            for ln in printed(k) if "DESK:" in ln]


def events(text: str) -> list:
    """Ledger events, continuation lines joined to their event."""
    out = []
    for ln in text.splitlines():
        if re.match(r"\d{4}-\d\d-\d\dT\d\d:\d\dZ ", ln):
            out.append(ln.strip())
        elif out and ln.startswith(" " * 18) and ln.strip():
            out[-1] += " " + ln.strip()
    return out


def new_events(rel: str = CHANGE + "/ledger.md") -> list:
    old = set(events(BEFORE["files"].get(rel, "")))
    p = SPACE / rel
    now = events(p.read_text()) if p.is_file() else []
    return [e for e in now if e not in old]


def rel_token(tok: str) -> str:
    """A command token as a space-relative path where it is one."""
    tok = tok.strip("'\"`,;()")
    base = str(SPACE).rstrip("/") + "/"
    return tok[len(base):] if tok.startswith(base) else tok


def staged(lines: list) -> tuple:
    """Paths a list of git command lines stages, and whether any stages
    everything (-A, --all or .)."""
    paths, wholesale = [], False
    for ln in lines:
        m = re.search(r"\bgit\b(?:\s+-[Cc]\s+\S+)*\s+add\b([^;&|]*)", ln)
        if not m:
            continue
        for tok in m.group(1).split():
            tok = rel_token(tok)
            if tok in ("-A", "--all", ".", "./", "*", ":/"):
                wholesale = True
            elif tok and not tok.startswith("-"):
                paths.append(tok)
    return paths, wholesale


def covers(tok: str, path: str) -> bool:
    """A staged token covers a path: the same path, or a folder holding it."""
    tok = tok.rstrip("/")
    return bool(tok) and (path == tok or path.startswith(tok + "/"))


def section(text: str, name: str) -> str:
    """The body of the level-2 section whose title contains name."""
    out, on = [], False
    for ln in text.splitlines():
        if ln.startswith("## "):
            title = re.sub(r"^\d+\.?\s*", "", ln[3:]).strip().lower()
            on = name.lower() in title
            continue
        if on:
            out.append(ln)
    return "\n".join(out)


def read(rel: str) -> str:
    p = SPACE / rel
    return p.read_text() if p.is_file() else ""


EXP = json.loads((RUN / "expected.json").read_text())
added, _, _ = changed()
recs = [p for p in added if p.startswith(CHANGE + "/evidence/")]
named = [p for p in recs if re.fullmatch(r"\d{8}T\d{4}Z\.md", Path(p).name)]
text = read(named[0]) if len(named) == 1 else ""
m = re.match(r"---\n(.*?)\n---\n?(.*)", text, re.S)
head, body = (m.group(1), m.group(2)) if m else ("", text)


def field(key: str):
    """A front-matter value: a flow map as a dict, else the stripped text."""
    lines = head.splitlines()
    for i, ln in enumerate(lines):
        km = re.match(rf"{key}:\s*(.*)$", ln)
        if not km:
            continue
        val = km.group(1).strip()
        if not val:
            sub = {}
            for nxt in lines[i + 1:]:
                sm = re.match(r"\s+([\w.\-/]+):\s*(.*)$", nxt)
                if not sm:
                    break
                sub[sm.group(1)] = sm.group(2).strip().strip("'\"")
            return sub
        if val.startswith("{") and val.endswith("}"):
            out = {}
            for part in val[1:-1].split(","):
                if ":" in part:
                    k, v = part.split(":", 1)
                    out[k.strip().strip("'\"")] = v.strip().strip("'\"")
            return out
        return val.strip("'\"")
    return None


stamp = Path(named[0]).stem if named else ""
report(1, len(recs) == 1 and len(named) == 1
       and field("id") == f"ev-{stamp}" and field("change") == "add-greeting",
       f"{len(recs)} new record(s); id {field('id')}, change "
       f"{field('change')}")
cs = field("commit_set") or {}
sha = re.compile(r"[0-9a-f]{7}")
ok2 = (isinstance(cs, dict) and set(cs) >= {"space", "alpha", "beta", "gamma"}
       and all(sha.fullmatch(str(v)) for v in cs.values())
       and cs.get("alpha") == EXP["alpha"] and cs.get("beta") == EXP["beta"]
       and cs.get("gamma") == "c3c3c3c")
report(2, ok2, f"commit_set {cs}")
report(3, field("env") == EXP["env"], f"env {field('env')}")
sc = field("scenarios") or {}
want = {"R1.S1": "pass", "R1.S2": "pass", "R2.S1": "fail"}
report(4, isinstance(sc, dict) and all(sc.get(k) == v
                                       for k, v in want.items()),
       f"scenarios {sc}")
un = field("unit") or {}
report(5, isinstance(un, dict) and un.get("alpha") == "pass"
       and un.get("beta") == "pass", f"unit {un}")
q = field("quality") or {}
report(6, isinstance(q, dict) and q.get("Q1") == "pass", f"quality {q}")
w = field("wall_time_s")
report(7, isinstance(w, str) and w.isdigit(), f"wall_time_s {w}")
a = field("actor")
report(8, isinstance(a, str) and re.fullmatch(r"[a-z0-9][a-z0-9-]*/test", a)
       is not None, f"actor {a}")
logs = re.search(r"Ran \d+ tests? in|Traceback \(most recent call last\)",
                 body)
paths = [n for n in (str(RUN), str(SPACE), "/Us" + "ers/", "/ho" + "me/",
                     "/tmp/", "/private/") if n in text]
report(9, bool(text) and not logs and not paths,
       "body " + ("absent" if not text else "holds a raw log" if logs
                  else "holds a machine path" if paths
                  else "has pointers only"))
finish()
```

## Fails if

- The evidence record lacks the commit set (or names a repo of `pod.yaml`
  wrongly), the environment class, a scenario, a unit suite, the declared
  quality check, or the wall time in s.
- It records results the run did not get (R2.S1 fails at this commit set).
- It pastes logs, or points at them by a machine path.

## At base

Expected: fail, because `agents/` is absent at swe-pod `8fc5294`; the runner
records the absent deliverable and starts no agent.

Observed 2026-10-28T00:40Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), with no --config, so no agent could start;
runner result:

```
fail (deliverable absent: swe-pod 8fc5294 agents)
```
