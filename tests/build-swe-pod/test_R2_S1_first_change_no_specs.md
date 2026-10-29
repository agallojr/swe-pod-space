---
scenario: R2.S1
mode: agent (spec, then plan)
deliverables: [swe-pod:agents, swe-pod:PROCESS.md as PROCESS.md, swe-pod:templates/records]
fixture: demo-space
expected_s: 600
heavy: true
env: any
cap_s: 1500
---

# R2.S1 First change in a repo with no specs

Serves R2 (spec §5.1; D1, D2). Heavy: expected 600 s of agent time, so the
lead asks the operator before it runs (spec §5.4, §7).

## Given

- Step 1 is a fresh `swe-spec` session, step 2 a fresh `swe-plan` session,
  each with the role definitions installed and `PROCESS.md` in the space.
- The demo space with its change folder deleted by the setup, so it holds no
  spec at all.
- Code repos written by the setup as plain folders under `{RUN}/repos/`:
  alpha with its existing `checksum()`, beta with its existing banner and
  `--count-lines` flag. No spec describes them.

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
    "GIT_AUTHOR_DATE": "2026-10-01T08:00:00Z",
    "GIT_COMMITTER_DATE": "2026-10-01T08:00:00Z",
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

shutil.rmtree(SPACE / "changes" / "add-greeting")
(SPACE / "changes").mkdir(exist_ok=True)
make_repo("alpha", ALPHA_BASE, real=False)
make_repo("beta", BETA_BASE, real=False)
finish_setup()
```

## When

Step 1, to the spec author, then step 2, to the planner.

```text
I want beta to print a greeting when it starts, and the greeting text should
come from alpha so other tools can share it. Call the change add-greeting.
Just draft it. I approve it as you draft it, so record my approval as
demo-owner.

Checkouts on this node, one per line:
Project Space proj:demo: {SPACE}
swe-pod: {EXPORT}/swe-pod
alpha: {REPOS}/alpha
beta: {REPOS}/beta
The human is demo-owner.
```

```text
Plan the change add-greeting in this space.

Checkouts on this node, one per line:
Project Space proj:demo: {SPACE}
swe-pod: {EXPORT}/swe-pod
alpha: {REPOS}/alpha
beta: {REPOS}/beta
The human is demo-owner.
```

## Then

1. The space then holds exactly one spec, `changes/add-greeting/spec.md`: no
   other `spec.md`, and no other new file outside `changes/add-greeting/`
   holds a SHALL.
2. The spec's Requirements section states only the change: it never names
   alpha's existing `checksum`, and names beta's existing `--count-lines`
   only in a requirement or scenario that also names the greeting (the word
   "greeting", or a greeting text the section gives), since what the new
   greeting does in those runs is the change's own work.
3. The spec supersedes nothing: its `supersedes` list is empty or absent.
4. The spec has an `approved:` line naming demo-owner, so planning may start.
5. Planning proceeds: `changes/add-greeting/plan.md` exists, has a non-empty
   `## Self-review`, and names every requirement id of the spec.

```python check
import hashlib
import json
import os
import re
import sys
from pathlib import Path

TAG = "R2.S1"
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


SPEC = CHANGE + "/spec.md"
added, modified, removed = changed()
specs = [p for p in added if p.endswith("spec.md")]
others = [p for p in added if not p.startswith(CHANGE + "/")
          and "SHALL" in read(p)]
report(1, specs == [SPEC] and not others,
       f"new spec files {specs}; {len(others)} other file(s) with SHALL")
spec = read(SPEC)
reqs = section(spec, "Requirements")
EXISTING = ("checksum", "--count-lines", "beta 1.0", "alpha", "beta",
            "gamma")


def req_blocks(text: str) -> list:
    """Each requirement or scenario of a Requirements section: a level-3 or
    level-4 heading with the lines under it."""
    out, cur = [], []
    for ln in text.splitlines():
        if re.match(r"#{3,4}\s", ln) and cur:
            out.append("\n".join(cur))
            cur = []
        cur.append(ln)
    return out + (["\n".join(cur)] if cur else [])


greet = {g for ln in reqs.splitlines() if re.search(r"greeting", ln, re.I)
         for g in re.findall(r"`([^`]{4,})`", ln)
         if not any(w in g for w in EXISTING)}


def names_greeting(b: str) -> bool:
    return bool(re.search(r"greeting", b, re.I)) or any(g in b for g in greet)


old = (["checksum"] if "checksum" in reqs else []) + (
    ["--count-lines"] if any("--count-lines" in b and not names_greeting(b)
                             for b in req_blocks(reqs)) else [])
report(2, bool(reqs.strip()) and not old,
       "requirements " + (f"describe existing behavior: {old}" if old
                          else "cover only the change" if reqs.strip()
                          else "missing"))
m = re.search(r"^\s*-?\s*supersedes:\s*(.*)$", spec, re.M)
sup = m.group(1).strip() if m else ""
report(3, sup in ("", "[]", "none", "None", "[ ]"),
       f"supersedes {sup or 'absent'}")
report(4, re.search(r"^\s*-\s*approved:\s*demo-owner\b", spec, re.M)
       is not None, "approved line present" if "approved:" in spec
       else "no approved line")
plan = read(CHANGE + "/plan.md")
review = section(plan, "Self-review").strip()
ids = sorted(set(re.findall(r"^#{3}\s+(R\d+)\b", spec, re.M)))
missing = [r for r in ids if not re.search(rf"\b{r}\b", plan)]
report(5, bool(plan) and bool(review) and bool(ids) and not missing,
       "plan " + ("absent" if not plan else
                  f"self-review {'filled' if review else 'empty'}, "
                  f"{len(ids) - len(missing)} of {len(ids)} requirement ids"))
finish()
```

## Fails if

- The spec author, or the planner, needs a spec of existing behavior first:
  it writes one, or the planner refuses to plan without it.
- The spec describes alpha's or beta's existing behavior as requirements
  (the checksum, or `--count-lines` apart from what the greeting does in
  it), or lists something under `supersedes`.
- No plan is written for the approved first change.

## At base

Expected: fail, because `agents/` is absent at swe-pod `8fc5294`; the runner
records the absent deliverable and starts no agent.

Observed 2026-10-28T06:38Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), after the T18 test fixes of 2026-10-28,
runner result:

```
fail (deliverable absent: swe-pod 8fc5294 agents)
```
