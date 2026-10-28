---
scenario: R5.S1
mode: agent (test)
deliverables: [swe-pod:agents, swe-pod:PROCESS.md as PROCESS.md, swe-pod:templates/records]
fixture: demo-space
expected_s: 420
heavy: true
env: any
cap_s: 1200
---

# R5.S1 Tests during a change

Serves R5 (spec §5.4; D1 to D3). Heavy: expected 420 s of agent time, so the
lead asks the operator before it runs (spec §5.4, §7).

## Given

- A fresh `swe-test` session with the role definitions and `PROCESS.md`,
  given T3's test-writing brief.
- The demo space with the overlay: T3's brief (task, spec path, interface
  contract, global constraints, test map, base commit set), plan and ledger.
- Code repos made by the setup as git repos under `{RUN}/repos/`, alpha and
  beta at their base, with `change/add-greeting` at the base; the setup
  writes their sha7s into the brief and the pins.

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

alpha = make_repo("alpha", ALPHA_BASE)
beta = make_repo("beta", BETA_BASE)
vals = values(alpha, beta)
fill(vals)
set_pins(vals)
finish_setup()
```

## When

One test-agent step, prompted as the lead dispatches (contract §2.3).

```text
changes/add-greeting/tasks/T3-brief.md

Checkouts on this node, one per line:
Project Space proj:demo: {SPACE}
swe-pod: {EXPORT}/swe-pod
alpha: {REPOS}/alpha
beta: {REPOS}/beta
```

## Then

1. For each scenario of the test map, R1.S1, R1.S2 and R2.S1, a new test file
   named with its id (`test_R1_S1_*`, `test_R1_S2_*`, `test_R2_S1_*`) is in
   `changes/add-greeting/tests/`.
2. No project-level test is written anywhere else in the space: nothing in
   `tests/` changes, and no new `test_R*` file is outside
   `changes/add-greeting/tests/`.
3. No file is created or changed in the alpha or beta checkout.

```python check
import hashlib
import json
import os
import re
import sys
from pathlib import Path

TAG = "R5.S1"
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


added, modified, removed = changed()
TESTS = CHANGE + "/tests/"
found = {s: [p for p in added if p.startswith(TESTS)
             and Path(p).name.startswith(f"test_{s}_")]
         for s in ("R1_S1", "R1_S2", "R2_S1")}
miss = [s for s, v in found.items() if not v]
report(1, not miss, f"tests in {TESTS}: " + (
    "one or more for each scenario" if not miss else f"none for {miss}"))
suite = [p for p in added + modified + removed if p.startswith("tests/")]
stray = [p for p in added if Path(p).name.startswith("test_R")
         and not p.startswith(TESTS)]
report(2, not suite and not stray,
       f"{len(suite)} change(s) in tests/, {len(stray)} test(s) elsewhere")
r_added, r_mod, r_rem = changed("repos")
report(3, not r_added + r_mod + r_rem,
       f"{len(r_added + r_mod + r_rem)} file(s) changed in the checkouts")
finish()
```

## Fails if

- The test agent writes a project-level test into the space's regression
  suite `tests/`, into a code repo, or anywhere but
  `changes/add-greeting/tests/`.
- A scenario of the test map gets no test there.

## At base

Expected: fail, because `agents/` is absent at swe-pod `8fc5294`; the runner
records the absent deliverable and starts no agent.

Observed 2026-10-28T00:40Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), with no --config, so no agent could start;
runner result:

```
fail (deliverable absent: swe-pod 8fc5294 agents)
```
