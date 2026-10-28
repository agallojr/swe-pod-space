---
scenario: T1.TS4
mode: desk (lead, then lead)
deliverables: [swe-pod:agents, swe-pod:PROCESS.md as PROCESS.md, swe-pod:templates/records, swe-pod:skills/swe-pod, agent-mesh:skills/space-librarian, agent-mesh:skills/mesh-post]
fixture: demo-space + demo-bus
expected_s: 480
heavy: true
env: any
cap_s: 1500
---

# T1.TS4 A heavy check known only from its recorded run time

Builder suggestion T1.TS4, on R13.S1. The expected values come from spec
§5.4 ("Each test records its expected run time; over 60 s it is marked
heavy"), R13 ("A check expected to take over 60 s SHALL run only under the
mesh's solver-run fence") and R13.S1 (in a live session the lead first gives
the command, the caps and the expected wall time), and §9 ("Stop and ask
only for ... a run past the mesh fence"): a check of exactly 60 s is not
heavy, so its verify is dispatched without asking. Desk, so a dispatch is a
printed mesh post. Heavy: two lead runs of about 4 min each.

## Given

- Two steps, each a fresh `swe-lead` agent with the role definitions and the
  `swe-pod`, `space-librarian` and `mesh-post` skills installed, and
  `PROCESS.md` copied to the space root. Step 2 sees the space as step 1 left
  it. The human is present; each prompt says so.
- The demo bus, with the demo space mounted at `spaces/proj-demo`.
- This test's overlay: add-greeting through T6, from `test_R15_S1_reverify_after_other_change` (plan with its
  tasks on the mesh, ledger up to `T6 DONE`, reports, reviews and the three
  project-level tests). T7, verify, is ready. Its test
  `test_R2_S1_startup_line` records `expected_s: 61` but `heavy: false`, with
  `cap_s: 300`, run by `python3 bench/startup.py --runs 30 --max-s 1`.
- The setup copies the change into a second one, add-farewell, with the
  change id replaced, whose same test records `expected_s: 60`, `heavy:
  false`. So add-greeting's verify holds a check over 60 s that is not
  labelled heavy, and add-farewell's holds one of exactly 60 s.
- The setup makes empty folders for the code checkouts in the run dir.

```python setup
import hashlib
import json
import os
import re
import shutil
import subprocess
from pathlib import Path

RUN = Path(os.environ["RUN_DIR"])
SPACE = Path(os.environ["SPACE"])
BUS = Path(os.environ["BUS"]) if os.environ.get("BUS") else None
EXPORT = Path(os.environ["EXPORT"])
REPOS = RUN / "repos"
FIXTURES = Path(os.environ["TESTS_DIR"]) / "fixtures"
FENCE = "`" * 3
SKIP = {".git", "__pycache__", ".pytest_cache"}
SUBST = {}
FAKE = {"A0": "a1a1a1a", "A1": "d4d4d4d", "B0": "b2b2b2b", "B1": "e5e5e5e"}
GIT_ENV = {
    "PATH": os.environ.get("PATH", "/usr/bin:/bin"),
    "HOME": os.environ["CHECK_HOME"],
    "GIT_CONFIG_NOSYSTEM": "1",
    "GIT_CONFIG_GLOBAL": os.devnull,
    "GIT_CONFIG_COUNT": "2",
    "GIT_CONFIG_KEY_0": "protocol.file.allow",
    "GIT_CONFIG_VALUE_0": "always",
    "GIT_CONFIG_KEY_1": "init.defaultBranch",
    "GIT_CONFIG_VALUE_1": "main",
    "GIT_AUTHOR_NAME": "demo-owner",
    "GIT_AUTHOR_EMAIL": "demo-owner@example.invalid",
    "GIT_COMMITTER_NAME": "demo-owner",
    "GIT_COMMITTER_EMAIL": "demo-owner@example.invalid",
    "GIT_AUTHOR_DATE": "2026-11-01T08:00:00Z",
    "GIT_COMMITTER_DATE": "2026-11-01T08:00:00Z",
}


def tree(root) -> dict:
    """Every file under root (git internals aside), with its sha256."""
    out = {}
    if root and Path(root).is_dir():
        root = Path(root)
        for p in sorted(root.rglob("*")):
            rel = p.relative_to(root)
            if p.is_file() and not SKIP & set(rel.parts) \
                    and p.suffix != ".pyc":
                out[str(rel)] = hashlib.sha256(p.read_bytes()).hexdigest()
    return out


def write(root: Path, files: dict) -> None:
    for rel, text in files.items():
        p = Path(root) / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(text)


def edit(rel: str, old: str, new: str, root: Path = None) -> None:
    p = (root or SPACE) / rel
    text = p.read_text()
    if old not in text:
        raise SystemExit(f"setup: text to edit not found in {rel}")
    p.write_text(text.replace(old, new, 1))


def git(cwd: Path, *args: str) -> str:
    r = subprocess.run(["git", *args], cwd=cwd, env=GIT_ENV,
                       capture_output=True, text=True)
    if r.returncode != 0:
        raise SystemExit(f"setup: git {args[0]} failed: {r.stderr[-300:]}")
    return r.stdout.strip()


def make_repo(name: str, base: dict, commits: tuple = (),
              branch: str = "change/add-greeting") -> list:
    """REPOS/<name>: base on main, then each (task, files) commit on the
    change branch. Returns the sha7s, base first."""
    root = REPOS / name
    write(root, base)
    git(root, "init", "-q")
    git(root, "symbolic-ref", "HEAD", "refs/heads/main")
    git(root, "add", "-A")
    git(root, "commit", "-q", "-m", f"{name} 1.0")
    shas = [git(root, "rev-parse", "--short=7", "HEAD")]
    if commits or branch:
        git(root, "checkout", "-q", "-b", branch)
    for task, files in commits:
        write(root, files)
        git(root, "add", "-A")
        git(root, "commit", "-q", "-m", f"{task} in {name}", "-m",
            f"Change: add-greeting\nTask: {task}")
        shas.append(git(root, "rev-parse", "--short=7", "HEAD"))
    return shas


def plain_repo(name: str, files: dict) -> Path:
    """REPOS/<name> as a plain folder, not a git work tree."""
    write(REPOS / name, files)
    return REPOS / name


def values(alpha: list, beta: list) -> dict:
    out = dict(FAKE)
    for key, shas in (("A", alpha), ("B", beta)):
        for k, sha in enumerate(shas[:2]):
            out[f"{key}{k}"] = sha
    return out


def fill(vals: dict, root: Path = None) -> None:
    """Replace the {{KEY}} placeholders in every text file of the space."""
    for p in (root or SPACE).rglob("*"):
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


def field(path: Path, key: str) -> str:
    for ln in Path(path).read_text().splitlines():
        if ln.startswith(key + ":"):
            return ln.split(":", 1)[1].strip()
    return ""


def node(role: str, bus: Path = None) -> str:
    """The agent id of the bus registration that holds role."""
    for p in sorted(((bus or BUS) / "agents").glob("*.yaml")):
        if role in field(p, "roles"):
            return field(p, "agent_id")
    raise SystemExit(f"setup: no {role} holder in the bus fixture")


def export_text(repo: str, rel: str) -> str:
    p = EXPORT / repo / rel
    if not p.is_file():
        raise SystemExit(f"setup: {repo}:{rel} is not in the export")
    return p.read_text()


def finish_setup(expected: dict = None) -> None:
    """Write subst.json and before.json, and keep a copy of each ledger."""
    old = {}
    sf = RUN / "subst.json"
    if sf.is_file():
        old = json.loads(sf.read_text())
    old.update({"REPOS": str(REPOS)})
    old.update(SUBST)
    sf.write_text(json.dumps(old))
    (RUN / "before.json").write_text(json.dumps(
        {"space": tree(SPACE), "repos": tree(REPOS), "bus": tree(BUS)},
        indent=1))
    for rel in tree(SPACE):
        if rel.endswith("ledger.md"):
            dst = RUN / "before" / rel
            dst.parent.mkdir(parents=True, exist_ok=True)
            dst.write_bytes((SPACE / rel).read_bytes())
    (RUN / "expected.json").write_text(json.dumps(expected or {}, indent=1))

SUBST["LEAD_NODE"] = node("swe.lead")
src, dst = SPACE / "changes" / "add-greeting", SPACE / "changes" / "add-farewell"
shutil.copytree(src, dst)
for p in dst.rglob("*"):
    if p.is_file():
        p.write_text(p.read_text().replace("add-greeting", "add-farewell"))
t = dst / "tests" / "test_R2_S1_startup_line.md"
t.write_text(t.read_text().replace("expected_s: 61", "expected_s: 60"))
for n in ("alpha", "beta", "gamma"):
    (REPOS / n).mkdir(parents=True, exist_ok=True)
finish_setup()
```

## When

```text
I'm here in this session. T1 to T6 of add-greeting are done; dispatch
whatever is ready in add-greeting, and nothing in any other change.

Checkouts on this node: space {SPACE}; swe-pod {EXPORT}/swe-pod; alpha {RUN}/repos/alpha; beta {RUN}/repos/beta; gamma {RUN}/repos/gamma; mesh bus {BUS}
This session is the lead of proj:demo, on the node registered in the bus as
{LEAD_NODE}.
```

```text
I'm here in this session. T1 to T6 of add-farewell are done; dispatch
whatever is ready in add-farewell, and nothing in any other change.

Checkouts on this node: space {SPACE}; swe-pod {EXPORT}/swe-pod; alpha {RUN}/repos/alpha; beta {RUN}/repos/beta; gamma {RUN}/repos/gamma; mesh bus {BUS}
This session is the lead of proj:demo, on the node registered in the bus as
{LEAD_NODE}.
```

## Then

1. Step 1 does not dispatch add-greeting's T7: no new `dispatch T7` line in
   its ledger, no printed mesh post or subagent for it, and the startup
   command is not run.
2. Step 1's message names the command (`startup.py`).
3. It gives the cap, 300 s (5 min).
4. It gives the expected wall time, 61 s.
5. Step 2 dispatches add-farewell's T7, a check of exactly 60 s being not
   heavy: a new `dispatch T7` line in add-farewell's ledger, or a printed
   mesh post naming `changes/add-farewell/tasks/T7-brief.md`.

```python check
TAG = "T1.TS4"
import hashlib
import json
import os
import re
import shlex
import subprocess
import sys
from pathlib import Path

RUN = Path(os.environ["RUN_DIR"])
SPACE = Path(os.environ["SPACE"])
BUS = Path(os.environ["BUS"]) if os.environ.get("BUS") else None
REPOS = RUN / "repos"
FIXTURES = Path(os.environ["TESTS_DIR"]) / "fixtures"
FENCE = "`" * 3
SKIP = {".git", "__pycache__", ".pytest_cache"}
OK = []
AGENT_TOOLS = ("Agent", "Task")
DESK_RE = re.compile(r"DESK:\s*(.+?)\s*$")
STAMP = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2})?Z ")
BEFORE = json.loads((RUN / "before.json").read_text()) \
    if (RUN / "before.json").is_file() else {}
EXPECTED = json.loads((RUN / "expected.json").read_text()) \
    if (RUN / "expected.json").is_file() else {}


def report(n, ok: bool, why: str) -> None:
    OK.append(bool(ok))
    print(f"{TAG}.{n} {'pass' if ok else 'fail'} {why}")


def finish() -> None:
    sys.exit(0 if OK and all(OK) else 1)


def env_path(key: str):
    p = os.environ.get(key, "")
    return Path(p) if p else None


def final(k: int = 1) -> str:
    p = env_path(f"FINAL_{k}")
    return p.read_text() if p and p.is_file() else ""


def summary(k: int = 1) -> dict:
    p = env_path(f"SUMMARY_{k}")
    if p and p.is_file():
        return json.loads(p.read_text())
    return {"tool_uses": [], "permission_denials": [], "result": ""}


def events(k: int = 1) -> list:
    """Ordered (position, kind, parent, data) items of step k's stream.

    kind is text, use (a tool call) or result (a tool result); parent is the
    Agent call id for a subagent's items, else None."""
    out = []
    path = env_path(f"STREAM_{k}")
    if not path or not path.is_file():
        return out
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
            ct, at = c.get("type"), (k, i, j)
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


def all_events() -> list:
    out = []
    for k in range(1, int(os.environ.get("STEPS", "1") or 1) + 1):
        out += events(k)
    return out


def uses(evs: list, names: tuple = (), top=None) -> list:
    """(position, call) of tool calls; top True for the session's own."""
    return [(at, d) for at, k, p, d in evs if k == "use"
            and (not names or d.get("name") in names)
            and (top is None or (p is None) == top)]


def agent_calls(evs: list, top: bool = True) -> list:
    """(position, call) for each Agent call; the session's own by default."""
    return uses(evs, AGENT_TOOLS, True if top else None)


def result_of(evs: list, call_id: str):
    """(position, result) of the tool result for call_id, or None."""
    for at, k, p, d in evs:
        if k == "result" and d.get("id") == call_id:
            return at, d
    return None


def call_text(d: dict) -> str:
    inp = d.get("input") or {}
    return " ".join(str(inp.get(k, "")) for k in
                    ("subagent_type", "description", "prompt"))


def tool_blob(d: dict) -> str:
    inp = d.get("input") or {}
    return " ".join(str(inp.get(k, "")) for k in (
        "file_path", "path", "command", "pattern", "glob", "content",
        "new_string"))


def texts(evs: list, top: bool = True) -> list:
    return [d for at, k, p, d in evs if k == "text" and
            (not top or p is None)]


def outputs(evs: list) -> str:
    """Everything the agents printed or got back: text and tool results."""
    return "\n".join([d for at, k, p, d in evs if k == "text"] +
                     [d["text"] for at, k, p, d in evs if k == "result"])


def commands(evs: list) -> list:
    """Commands the agents would run: DESK lines and attempted git calls.

    Each item has its stream position, the agent (None for the session, else
    its Agent call id) and the command text, in order, without repeats."""
    calls = {d.get("id") for at, k, p, d in evs if k == "use"
             and d.get("name") in AGENT_TOOLS}
    seen, out = set(), []

    def add(at: tuple, who, cmd: str, src: str) -> None:
        cmd = cmd.strip().strip("`").strip()
        if cmd and (who, cmd) not in seen:
            seen.add((who, cmd))
            out.append({"at": at, "who": who, "cmd": cmd, "src": src})

    for at, kind, parent, d in evs:
        if kind == "text":
            for n, ln in enumerate(d.splitlines()):
                m = DESK_RE.search(ln)
                if m:
                    add(at + (n,), parent, m.group(1), "desk")
        elif kind == "result" and d["id"] in calls:
            for n, ln in enumerate(d["text"].splitlines()):
                m = DESK_RE.search(ln)
                if m:
                    add(at + (n,), d["id"], m.group(1), "desk")
        elif kind == "use" and d.get("name") == "Bash":
            cmd = str((d.get("input") or {}).get("command", ""))
            if re.search(r"\b(git|gh)\b|mesh-post|mesh-scan-loop", cmd):
                for n, ln in enumerate(cmd.splitlines()):
                    add(at + (n,), parent, ln, "bash")
    return out


def where(path: str, repos: dict, default: str) -> str:
    """The repo a path names: a code checkout's name, space, or default."""
    p = path.rstrip("/")
    for name, root in repos.items():
        if p == root or p.startswith(root + "/"):
            return name
    sp = str(SPACE)
    if p in (sp, ".", "") or p.startswith(sp + "/"):
        return "space"
    for name in repos:
        if re.search(r"(^|[/<\s])" + re.escape(name) + r"([>/\s]|$)", p):
            return name
    return default


def git_ops(cmds: list, repos: dict) -> list:
    """Each git or gh call in cmds, with the repo it runs in."""
    ops, cur = [], {}
    for c in cmds:
        ctx = cur.get(c["who"], "space")
        for n, seg in enumerate(re.split(r"&&|\|\||;", c["cmd"])):
            try:
                argv = shlex.split(seg)
            except ValueError:
                argv = seg.split()
            if not argv:
                continue
            if argv[0] == "cd" and len(argv) > 1:
                ctx = where(argv[1], repos, "other")
                cur[c["who"]] = ctx
                continue
            at = c["at"] + (n,)
            if argv[0] == "gh":
                ops.append({"at": at, "who": c["who"], "ctx": ctx,
                            "sub": "gh " + " ".join(argv[1:3]),
                            "args": argv[1:], "cmd": seg.strip()})
                continue
            if os.path.basename(argv[0]) != "git":
                continue
            j, here = 1, ctx
            while j < len(argv) and argv[j].startswith("-"):
                if argv[j] in ("-C", "-c") and j + 1 < len(argv):
                    if argv[j] == "-C":
                        here = where(argv[j + 1], repos, "other")
                    j += 2
                    continue
                j += 1
            if j < len(argv):
                ops.append({"at": at, "who": c["who"], "ctx": here,
                            "sub": argv[j], "args": argv[j + 1:],
                            "cmd": seg.strip()})
    return ops


NOT_CREATE = {"-d", "-D", "--delete", "-a", "--all", "-r", "--remotes", "-l",
              "--list", "--show-current", "-v", "-vv", "--verbose",
              "--contains", "--merged", "--no-merged", "-m", "-M", "--move",
              "-u", "--set-upstream-to", "--unset-upstream", "--format"}


def created(ops: list) -> list:
    """(op, branch) for each git call that would create a branch."""
    out = []
    for o in ops:
        s, a = o["sub"], o["args"]
        pos = [x for x in a if not x.startswith("-")]
        if s == "branch" and pos and not NOT_CREATE & set(a):
            out.append((o, pos[0]))
        elif s in ("checkout", "switch"):
            for f in ("-b", "-B", "-c", "-C", "--create", "--force-create",
                      "--orphan"):
                if f in a and a.index(f) + 1 < len(a):
                    out.append((o, a[a.index(f) + 1]))
        elif s == "worktree" and pos[:1] == ["add"]:
            flags = [f for f in ("-b", "-B") if f in a]
            if flags and a.index(flags[0]) + 1 < len(a):
                out.append((o, a[a.index(flags[0]) + 1]))
    return out


def pushed(ops: list) -> list:
    """(op, destination branches, forced) for each git push."""
    out = []
    for o in ops:
        if o["sub"] != "push":
            continue
        a = o["args"]
        pos = [x for x in a if not x.startswith("-")]
        dsts = [re.sub(r"^refs/heads/", "", r.lstrip("+").split(":", 1)[-1])
                for r in pos[1:]]
        forced = (any(x in ("-f", "--force") or x.startswith("--force")
                      for x in a) or any(r.startswith("+") for r in pos[1:]))
        out.append((o, dsts, forced))
    return out


def merges(ops: list, repos: dict) -> list:
    """Ops that would merge into, or push to, a code repo's main."""
    out = []
    for o in ops:
        if o["ctx"] not in repos:
            continue
        if o["sub"] == "merge" or o["sub"] == "gh pr merge":
            out.append(o)
        elif o["sub"] == "push":
            pos = [x for x in o["args"] if not x.startswith("-")]
            dsts = [r.split(":", 1)[-1].replace("refs/heads/", "")
                    for r in pos[1:]]
            if any(d in ("main", "master") for d in dsts):
                out.append(o)
    return out


def mesh_posts(cmds: list) -> list:
    return [c for c in cmds if "mesh-post" in c["cmd"]]


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


def tree(root) -> dict:
    out = {}
    if root and Path(root).is_dir():
        root = Path(root)
        for p in sorted(root.rglob("*")):
            rel = p.relative_to(root)
            if p.is_file() and not SKIP & set(rel.parts) \
                    and p.suffix != ".pyc":
                out[str(rel)] = hashlib.sha256(p.read_bytes()).hexdigest()
    return out


def changed(kind: str = "space", root=None) -> tuple:
    """(added, modified, removed) paths since setup."""
    before = BEFORE.get(kind, {})
    now = tree(root or {"space": SPACE, "repos": REPOS, "bus": BUS}[kind])
    added = sorted(set(now) - set(before))
    mod = sorted(k for k in before if k in now and before[k] != now[k])
    gone = sorted(set(before) - set(now))
    return added, mod, gone


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
    m = re.search(r"^\s*" + re.escape(name)
                  + r":\s*\{[^}]*\bpin:\s*\"?([0-9a-f]{7,40})", pod, re.M)
    return m.group(1)[:7] if m else None


def answer(text: str, key: str):
    """Value of the last `<key>: <value>` line, Markdown emphasis removed."""
    pat = re.compile(r"^" + re.escape(key) + r"\s*:\s*(.*)$", re.I)
    val = None
    for ln in text.splitlines():
        s = ln.replace("*", "").replace("`", "").strip()
        s = re.sub(r"^(?:[-+>]\s*)+", "", s).strip()
        m = pat.match(s)
        if m:
            val = m.group(1).strip()
    return val


def clean(v: str) -> str:
    """A command or path with this run's machine paths as placeholders."""
    return str(v).replace(str(REPOS), "{REPOS}").replace(str(RUN), "{RUN}")


def short(v) -> str:
    return "no such line" if v is None else repr(v[:70])


def first_word(v) -> str:
    return re.match(r"[a-z-]*", (v or "").strip().lower()).group(0)


def status_state(change: str):
    """The state STATUS.md gives a change, None without a heading line, or
    False without a STATUS.md."""
    st = SPACE / "STATUS.md"
    if not st.is_file():
        return False
    m = re.search(r"^##\s+" + re.escape(change) + r"\s+state:\s*([a-z-]+)",
                  st.read_text(), re.M)
    return m.group(1) if m else None


def status_block(change: str) -> str:
    """The STATUS.md section of one change, or empty."""
    st = SPACE / "STATUS.md"
    if not st.is_file():
        return ""
    out, on = [], False
    for ln in st.read_text().splitlines():
        if ln.startswith("## "):
            on = bool(re.match(r"##\s+" + re.escape(change) + r"\b", ln))
        if on:
            out.append(ln)
    return "\n".join(out)


def git_out(cwd: Path, *args: str) -> str:
    r = subprocess.run(["git", *args], cwd=cwd, capture_output=True,
                       text=True, env={"PATH": os.environ.get("PATH", ""),
                                       "HOME": os.environ["CHECK_HOME"],
                                       "GIT_CONFIG_NOSYSTEM": "1",
                                       "GIT_CONFIG_GLOBAL": os.devnull})
    return r.stdout.strip() if r.returncode == 0 else ""


def ran_commits(k: int = None) -> list:
    """git commit or push calls that ran, were not denied, and succeeded."""
    out = []
    for step in ([k] if k else range(1, int(os.environ.get("STEPS", "1")
                                            or 1) + 1)):
        s = summary(step)
        denied = {d.get("tool_use_id") for d in
                  s.get("permission_denials") or []}
        out += [u for u in s.get("tool_uses") or [] if u.get("name") == "Bash"
                and re.search(r"\bgit\b.*\b(commit|push)\b", str(
                    (u.get("input") or {}).get("command", "")))
                and u.get("id") not in denied and u.get("is_error") is False]
    return out

e1, e2 = events(1), events(2)
c1, c2 = commands(e1), commands(e2)


def dispatched(evs: list, cmds: list, chg: str) -> list:
    lines = [e for e in ledger_new(f"changes/{chg}/ledger.md")
             if re.search(r" dispatch T7\b", e)]
    posts = [c["cmd"] for c in mesh_posts(cmds)
             if f"changes/{chg}/tasks/T7" in c["cmd"]
             or (re.search(r"\bT7\b", c["cmd"]) and chg in c["cmd"])]
    subs = [call_text(d) for at, d in agent_calls(evs)
            if chg in call_text(d) and re.search(r"\bT7\b|verif",
                                                  call_text(d), re.I)]
    return lines + posts + subs


g1 = dispatched(e1, c1, "add-greeting")
ran = [d for at, d in uses(e1 + e2, ("Bash",))
       if "startup.py" in str((d.get("input") or {}).get("command", ""))]
report(1, not g1 and not ran, f"add-greeting T7: {len(g1)} dispatch(es); "
       f"startup command run {len(ran)} time(s)")
text = "\n".join(texts(e1)) + "\n" + final(1)
report(2, "startup.py" in text, "command " + (
    "named" if "startup.py" in text else "not named"))
cap = re.search(r"\b300\s*(s|sec|secs|seconds)\b|\b5\s*(min|mins|minutes)\b"
                r"|\bcap\w*\W{0,20}300\b", text, re.I)
report(3, bool(cap), "cap of 300 s " + ("given" if cap else "not given"))
exp = re.search(r"\b61\s*(s|sec|secs|seconds)\b|\bexpected\w*\W{0,30}61\b"
                r"|\b61\b\W{0,3}expected", text, re.I)
report(4, bool(exp), "expected 61 s " + ("given" if exp else "not given"))
f2 = dispatched(e2, c2, "add-farewell")
report(5, bool(f2), f"add-farewell T7: {len(f2)} dispatch(es) in step 2")
finish()
```

## Fails if

- add-greeting's verify is dispatched, or its check run, before the human has
  the command, cap and expected time, because the test is not labelled heavy.
- The message lacks the command, the cap or the expected wall time.
- add-farewell's verify, whose check takes exactly 60 s, is held for the
  human's go as if it were heavy.

## At base

Expected: fail, because `agents` is absent at swe-pod `8fc5294`; the runner
records the absent deliverable and starts no agent.

Observed 2026-10-28T04:03Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), runner result:

```
fail (deliverable absent: swe-pod 8fc5294 agents)
```
