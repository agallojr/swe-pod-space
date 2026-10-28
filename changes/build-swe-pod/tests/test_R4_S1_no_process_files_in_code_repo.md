---
scenario: R4.S1
mode: desk (build, then lead)
deliverables: [swe-pod:agents, swe-pod:PROCESS.md as PROCESS.md, swe-pod:templates/records, swe-pod:skills/swe-pod, agent-mesh:skills/space-librarian]
fixture: demo-space
expected_s: 600
heavy: true
env: any
cap_s: 1500
---

# R4.S1 No process files in a code repo

Serves R4 (spec §4; D1 to D3). Desk-verified per OD1; the pilot runs it live.
Heavy: expected 600 s of agent time, so the lead asks the operator before it
runs (spec §5.4, §7). The test map's mode `desk (build, lead)` is written with
`then`, the runner's step separator, so the builder and the lead each run as
their own step.

## Given

- Step 1: a fresh `swe-build` session given T2's brief. Step 2: a fresh
  `swe-lead` session. Both desk: they print every git command and run none,
  so the diff `<base>..<merge>` is the set of files the two steps create or
  change in the code-repo checkouts, plus the paths their printed `git add`
  lines name.
- The demo space with the overlay: add-greeting verified, with plan, ledger
  through the whole-change review, briefs, reports, reviews, a green
  evidence record and three project-level tests; and T2's brief.
- Code repos written by the setup as plain folders under `{RUN}/repos/`:
  alpha with T1's greeting, beta at its base.

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

make_repo("alpha", ALPHA_BASE, (("T1", ALPHA_T1),), real=False)
make_repo("beta", BETA_BASE, real=False)
fill(FAKE)
finish_setup(keep=("changes/add-greeting/ledger.md",))
```

## When

Step 1, the builder, then step 2, the lead.

```text
changes/add-greeting/tasks/T2-brief.md

Checkouts on this node, one per line:
Project Space proj:demo: {SPACE}
swe-pod: {EXPORT}/swe-pod
alpha: {REPOS}/alpha
beta: {REPOS}/beta
```

```text
T2's report is in, and the change is verified. Merge it.

Checkouts on this node, one per line:
Project Space proj:demo: {SPACE}
swe-pod: {EXPORT}/swe-pod
agent-mesh: {EXPORT}/agent-mesh
alpha: {REPOS}/alpha
beta: {REPOS}/beta
The human is demo-owner.
```

## Then

1. The builder changes at least one file in the beta checkout: it does T2's
   work there.
2. No file created or changed in the alpha or beta checkout during the run is a
   process record or project-level test: no spec, plan, ledger, brief, report,
   review, evidence record, handoff, `changes/` folder, or `test_R<n>_S<m>_`,
   `test_I<n>_` or `test_T<n>_TS<k>_` file.
3. No path a printed `git add` names, in either step, is one of those.
4. The builder's report is in the space, at
   `changes/add-greeting/tasks/T2-report.md`.
5. The lead writes nothing into a code-repo checkout: no Write or Edit call of
   step 2 targets one, and no command of step 2 copies, moves or redirects into
   one.
6. The lead's final report is in the space, at `changes/add-greeting/report.md`
   or `changes/archive/<date>-add-greeting/report.md`.

```python check
import hashlib
import json
import os
import re
import sys
from pathlib import Path

TAG = "R4.S1"
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


PROC = re.compile(r"(^|/)(spec|plan|ledger|report|STATUS)\.md$|"
                  r"(^|/)T\d+-(brief|report|review)\.md$|"
                  r"(^|/)(evidence|handoffs|changes)(/|$)|"
                  r"(^|/)test_(R\d+_S\d+|I\d+|T\d+_TS\d+)_[^/]*$|"
                  r"(^|/)\d{8}T\d{4}Z[^/]*\.md$")
added, modified, _ = changed("repos")
beta = [p for p in added + modified if p.startswith("beta/")]
report(1, bool(beta), f"{len(beta)} file(s) changed in the beta checkout")
bad = [p for p in added + modified
       if PROC.search(p.split("/", 1)[1] if "/" in p else p)]
report(2, not bad, f"{len(added) + len(modified)} file(s) changed in the "
       f"checkouts; process files: {bad[:4] or 'none'}")
paths = staged(desk(1))[0] + staged(desk(2))[0]
bad_add = [p for p in paths if PROC.search(p)]
report(3, not bad_add, f"{len(paths)} staged path(s); process files: "
       f"{bad_add[:4] or 'none'}")
sp_added, sp_mod, _ = changed()
rep = CHANGE + "/tasks/T2-report.md"
report(4, rep in sp_added + sp_mod, "T2 report " + (
    "in the space" if rep in sp_added + sp_mod else "not in the space"))
root = str(REPOS)
writes = [u for u in uses(2, ("Write", "Edit"))
          if arg(u, "file_path").startswith(root)]
moves = [u for u in uses(2, ("Bash",)) if root in arg(u, "command")
         and re.search(r"\b(cp|mv|rsync|install|tee)\b|>",
                       arg(u, "command"))]
report(5, not writes and not moves,
       f"lead: {len(writes)} write(s), {len(moves)} copy or redirect "
       "command(s) into a checkout")
finals = [p for p in sp_added + sp_mod if re.fullmatch(
    r"changes/(archive/[^/]+-)?add-greeting/report\.md", p)]
report(6, bool(finals), f"final report in the space: {finals or 'none'}")
finish()
```

## Fails if

- The builder writes its report, the brief, or a project-level test into the
  code repo, or stages one.
- The lead's integrate copies the change's tests, its final report or any
  other record into a code repo.
- The builder's report does not reach the space.

## At base

Expected: fail, because `agents/` is absent at swe-pod `8fc5294`; the runner
records the absent deliverable and starts no agent.

Observed 2026-10-28T00:40Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), with no --config, so no agent could start;
runner result:

```
fail (deliverable absent: swe-pod 8fc5294 agents)
```
