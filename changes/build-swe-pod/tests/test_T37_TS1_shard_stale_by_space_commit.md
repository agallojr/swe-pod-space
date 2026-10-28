---
scenario: T37.TS1
mode: agent (lead)
deliverables: [swe-pod:agents/swe-lead.md, swe-pod:PROCESS.md as PROCESS.md, swe-pod:templates/space/AGENTS.md as AGENTS.md, swe-pod:skills/swe-pod]
fixture: demo-space
expected_s: 240
heavy: true
env: any
cap_s: 600
---

# T37.TS1 A shard out of date by its space commit alone

Builder suggestion T37.TS1, on R24.S2. The expected values come from contract
§2.4, Verified for a sharded verify (R24): "The current commit set is the
branch heads now, together with the space commit that holds the latest shard
briefs ... every one of those records names the current commit set ... A
shard whose latest record names another commit set is out of date, and is
re-run at the current commit set." Unlike
`test_R24_S2_stale_shard_not_verified`, both records name the same code
heads; only their space commits differ. The fixture is `test_R24_S1_two_shards_verified`'s, with
this history: both shards were dispatched from one space commit after T2's
fix round; T7b came back BLOCKED, its brief was filed again with a ruling,
and only T7b ran again. Heavy: one lead run of about 4 min.

## Given

- A fresh `swe-lead` session, with `agents/swe-lead.md` and the `swe-pod`
  skill, and `PROCESS.md` and the space template's `AGENTS.md` copied into
  the space. No instruction file reaches the agent.
- The demo space with this test's overlay (from `test_R24_S1_two_shards_verified`): the plan with T7
  in two shards; a ledger in which both shard briefs are filed at 13:29Z and
  both shards dispatched at 13:30Z, T7a done and filed, `T7b BLOCKED` at
  14:20Z, a ruling, T7b's brief filed again at 14:35Z and T7b dispatched
  again, done and filed; T8 review spec ok with one Minor.
- `evidence/20261001T1412Z-T7a.md`, at `{space: 7a7a7a7, alpha: d4d4d4d,
  beta: f6f6f6f, gamma: c3c3c3c}`, and `evidence/20261001T1500Z-T7b.md`, at
  `{space: 8b8b8b8, alpha: d4d4d4d, beta: f6f6f6f, gamma: c3c3c3c}`, both
  all pass. The space commit that holds the latest shard briefs is
  `8b8b8b8`, so T7a's record is out of date though no code moved.

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
    "GIT_AUTHOR_DATE": "2026-10-01T08:00:00Z",
    "GIT_COMMITTER_DATE": "2026-10-01T08:00:00Z",
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

finish_setup()
```

## When

```text
You are the lead of the Project Space at {SPACE}. This copy of the space has no git history, and neither the code repos nor the mesh can be reached from here, so take branch heads and commit sets from the records in the space, which you read with your tools. Do not dispatch, file or commit anything in this run.

Where does the change add-greeting stand? Is it verified?

End your answer with these lines, filled in from the records:
STATE add-greeting: <its state>
VERIFY DISPATCHES: <each verify dispatch the ledger holds, as task id, local or mesh, and environment class, separated by semicolons>
COMMIT SET: <the change's current commit set, as repo and sha7 pairs separated by commas>
RERUN: <the task ids of any verify runs that must run again before add-greeting can count as verified, separated by commas, or none>
```

## Then

The closing lines are only the test's way to read the lead's conclusions; no
phrase of the deliverables is checked.

1. The lead does not count add-greeting verified: its state is given, and it
   is neither `verified` nor `integrated`.
2. The verify runs it names for re-running are exactly T7a.
3. The current commit set it gives has alpha `d4d4d4d` and beta `f6f6f6f`,
   and, if it names the space commit, `8b8b8b8`, not `7a7a7a7`.
4. Both shard records were read with a tool.
5. Nothing was dispatched, filed or committed, and the spec, the plan and
   both shard records are byte for byte as given, with no new evidence
   record.
6. If the run regenerated `STATUS.md`, its `## add-greeting   state:` line
   does not say `verified`.

```python check
TAG = "T37.TS1"
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


DESK_LINE_RE = re.compile(
    r"^\s*(?:[-*+>]\s+|\d+[.)]\s+)?[`\"']?DESK:\s*(.+?)[`\"']?\s*$")
HEREDOC_RE = re.compile(r"(?<!<)<<(?!<)-?")
SHELL_OPS = re.compile(r"&&|\|\||;|\|&?|(?<![<>&])&(?![>&])")
SHELL_VAR = re.compile(r"\$\{([A-Za-z_]\w*)\}|\$([A-Za-z_]\w*)")
ASSIGN = re.compile(r"^[A-Za-z_]\w*=")
LEADERS = {"do", "then", "else", "elif", "if", "while", "until", "!", "{",
           "}", "(", ")", "time", "command"}
RUN_WORDS = {"git", "gh", "mesh-post", "mesh-scan-loop"}


def unquoted(s: str) -> str:
    """s with every quoted or escaped character blanked, lengths kept."""
    out, q, esc = [], None, False
    for ch in s:
        if esc:
            out.append(" ")
            esc = False
        elif ch == "\\" and q != "'":
            out.append(" ")
            esc = True
        elif q is None and ch in "'\"":
            out.append(" ")
            q = ch
        elif q is not None:
            out.append(" ")
            if ch == q:
                q = None
        else:
            out.append(ch)
    return "".join(out)


def to_file(seg: str) -> bool:
    """Whether a simple command sends its standard output to a file."""
    u = unquoted(seg)
    return bool(re.search(r"(^|[^0-9&<>])>>?\s*[^&\s]", u)
                or re.match(r"\s*tee\b", u))


def shell_parts(cmd: str) -> tuple:
    """A Bash command's logical lines, as (line number, text), and its heredoc
    body lines, as (line number, text, whether the body goes to a file)."""
    lines, bodies, ends, buf, start = [], [], [], "", None
    for n, ln in enumerate(cmd.splitlines()):
        if ends:
            if ln.strip() == ends[0][0]:
                ends.pop(0)
            else:
                bodies.append((n, ln, ends[0][1]))
            continue
        start = n if start is None else start
        if ln.endswith("\\"):
            buf += ln[:-1] + " "
            continue
        buf += ln
        lines.append((start, buf))
        u = unquoted(buf)
        for m in HEREDOC_RE.finditer(u):
            w = re.match(r"\s*(['\"]?)([A-Za-z_]\w*)\1", buf[m.end():])
            if w:
                cut = [s.start() for s in SHELL_OPS.finditer(u)]
                lo = max([c for c in cut if c < m.start()], default=0)
                hi = min([c for c in cut if c > m.start()], default=len(u))
                ends.append((w.group(2), to_file(buf[lo:hi])))
        buf, start = "", None
    if buf:
        lines.append((start, buf))
    return lines, bodies


def segments(line: str) -> list:
    """The simple commands of one logical line, split on unquoted operators."""
    out, last = [], 0
    for m in SHELL_OPS.finditer(unquoted(line)):
        out.append(line[last:m.start()])
        last = m.end()
    out.append(line[last:])
    return [s.strip() for s in out if s.strip()]


def expand(s: str, env: dict) -> str:
    """s with each $NAME or ${NAME} that env holds replaced, outside single
    quotes."""
    out, q, i = [], None, 0
    while i < len(s):
        ch = s[i]
        if ch in "'\"" and q in (None, ch):
            q = None if q else ch
        m = SHELL_VAR.match(s, i) if ch == "$" and q != "'" else None
        name = m and (m.group(1) or m.group(2))
        if name in env:
            out.append(env[name])
            i = m.end()
            continue
        out.append(ch)
        i += 1
    return "".join(out)


def words(seg: str) -> list:
    try:
        return shlex.split(seg, comments=True)
    except ValueError:
        return seg.split()


def argv_of(seg: str) -> list:
    """A simple command's words, without leading keywords or assignments."""
    a = words(seg)
    while a and (a[0] in LEADERS or ASSIGN.match(a[0])):
        a = a[1:]
    return a


def runs_word(a: list) -> bool:
    """Whether the words run git, gh or a mesh script."""
    if a and a[0] in ("sh", "bash", "zsh") and len(a) > 1:
        a = a[1:]
    name = re.sub(r"\.sh$", "", os.path.basename(a[0])) if a else ""
    return name in RUN_WORDS


def echoed(a: list) -> list:
    """The DESK command texts an echo or printf command prints."""
    if not a or a[0] not in ("echo", "printf"):
        return []
    keep, skip = [], False
    for x in a[1:]:
        if skip:
            skip = False
        elif re.match(r"^(\d*(>>?|<)|&>>?)$", x):
            skip = True
        elif not re.match(r"^(\d*(>>?|<)&?|&>)\S", x):
            keep.append(x)
    while a[0] == "echo" and keep and re.match(r"^-[neE]+$", keep[0]):
        keep = keep[1:]
    return [m.group(1) for piece in re.split(r"\\n|\n", " ".join(keep))
            for m in [re.match(r"\s*DESK:\s*(.+?)\s*$", piece)] if m]


def bash_commands(cmd: str, output: str, cwd: str) -> tuple:
    """(written, cd lines, printed, run lines, cwd after) of one Bash call
    started in cwd; the four lists hold (line number, text).

    Printed DESK texts are the DESK lines of its output when the command
    itself holds DESK text, or, when the output holds none, the ones its echo
    and printf commands and heredoc bodies print; written ones are those they
    write to files. DESK lines of files it only shows are not its own. Simple
    shell variables set in the same command are expanded. Every cd is kept,
    since it sets where the agent's later DESK lines run; DESK lines written
    to a file keep the place the agent had before the call. Run lines are
    its logical lines that run git, gh or a mesh script, with any cd; echo
    text and heredoc bodies are never taken as commands. A relative cd is
    resolved against cwd."""
    lines, bodies = shell_parts(cmd)
    env, said, wrote, cds, per_line = {}, [], [], [], []
    for n, ln in lines:
        kept = []
        for seg in segments(ln):
            seg = expand(seg, env)
            raw = words(seg)
            if raw and all(ASSIGN.match(x) for x in raw):
                for x in raw:
                    k, v = x.split("=", 1)
                    if "$" in v or "`" in v:
                        env.pop(k, None)
                    else:
                        env[k] = v
                continue
            a = argv_of(seg)
            if not a:
                continue
            texts = echoed(a)
            (wrote if to_file(seg) else said).extend((n, x) for x in texts)
            if a[0] == "cd" and len(a) > 1 and not re.match(r"[~$-]", a[1]):
                cwd = os.path.normpath(os.path.join(cwd, a[1]))
                a = ["cd", cwd]
            if a[0] == "cd":
                cds.append((n, shlex.join(a)))
            if runs_word(a) or a[0] == "cd":
                kept.append((runs_word(a), shlex.join(a)))
        per_line.append((n, kept))
    runs = []
    if any(r for _, kept in per_line for r, _ in kept):
        runs = [(n, " && ".join(x for _, x in kept))
                for n, kept in per_line if kept]
    for n, ln, filed in bodies:
        m = DESK_LINE_RE.match(ln)
        if m:
            (wrote if filed else said).append((n, expand(m.group(1), env)))
    shown = [(n, m.group(1)) for n, ln in enumerate(output.splitlines())
             for m in [re.match(r"\s*DESK:\s*(.+?)\s*$", ln)] if m
             ] if "DESK" in cmd else []
    return wrote, cds, shown or said, runs, cwd


def commands(evs: list) -> list:
    """Commands the agents would run: DESK lines and attempted git calls.

    DESK lines are read from reply text, subagent results, the contents of
    files written with Write or Edit, and each Bash call (bash_commands).
    Each item has its stream position, the agent (None for the session, else
    its Agent call id), the command text and its source, in order, without
    repeats; a cd is kept each time. The session's Bash calls keep their
    working folder from call to call, and a subagent's start in the space."""
    calls = {d.get("id") for at, k, p, d in evs if k == "use"
             and d.get("name") in AGENT_TOOLS}
    outputs = {d["id"]: d["text"] for at, k, p, d in evs if k == "result"}
    seen, out, here = set(), [], str(SPACE)

    def add(at: tuple, who, cmd: str, src: str) -> None:
        cmd = cmd.strip().strip("`").strip()
        if cmd and ((who, cmd) not in seen or cmd.startswith("cd ")):
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
        elif kind == "use" and d.get("name") in ("Write", "Edit"):
            inp = d.get("input") or {}
            body = str(inp.get("content") or inp.get("new_string") or "")
            for n, ln in enumerate(body.splitlines()):
                m = DESK_LINE_RE.match(ln)
                if m:
                    add(at + (n,), parent, m.group(1), "desk")
        elif kind == "use" and d.get("name") == "Bash":
            cmd = str((d.get("input") or {}).get("command", ""))
            wrote, cds, said, runs, cwd = bash_commands(
                cmd, outputs.get(d.get("id"), ""),
                here if parent is None else str(SPACE))
            here = cwd if parent is None else here
            for n, x in wrote:
                add(at + (0, -2, n), parent, x, "desk")
            for n, x in cds:
                add(at + (0, -1, n), parent, x, "bash")
            for n, x in said:
                add(at + (0, n), parent, x, "desk")
            for n, x in runs:
                add(at + (1, n), parent, x, "bash")
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

NAME = "test_T37_TS1_shard_stale_by_space_commit"
EVIDENCE = ["20261001T1412Z-T7a.md", "20261001T1500Z-T7b.md"]

def sha_of(text: str, repo: str):
    m = re.search(r"\b" + repo + r"\b\W{0,3}([0-9a-f]{7,40})\b", text, re.I)
    return m.group(1).lower()[:7] if m else None


def digest(p: Path):
    return hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else None


src = FIXTURES / "overlays" / NAME / "changes" / "add-greeting"
chg = SPACE / "changes" / "add-greeting"
text = final(1)
uses_ = summary(1).get("tool_uses") or []


def was_read(name: str) -> bool:
    for u in uses_:
        inp = u.get("input") or {}
        if u.get("name") == "Read" and str(
                inp.get("file_path", "")).endswith("evidence/" + name):
            return True
        if u.get("name") in ("Bash", "Grep") and "evidence" in json.dumps(inp):
            return True
    return False


def untouched() -> tuple:
    pod = [u for u in uses_ if u.get("name") in ("Agent", "Task") and (
        str((u.get("input") or {}).get("subagent_type", "")).startswith("swe-")
        or "-brief.md" in json.dumps(u.get("input") or {}))]
    mesh = [u for u in uses_ if u.get("name") == "Bash" and re.search(
        r"mesh-post|mesh-scan-loop", str((u.get("input") or {}).get(
            "command", "")))]
    pairs = [(chg / "spec.md", FIXTURES / "demo-space" / "changes" /
              "add-greeting" / "spec.md"), (chg / "plan.md", src / "plan.md")]
    pairs += [(chg / "evidence" / e, src / "evidence" / e) for e in EVIDENCE]
    chd = [a.name for a, b in pairs if digest(a) != digest(b)]
    ev = chg / "evidence"
    extra = [p.name for p in ev.iterdir() if p.name not in EVIDENCE] \
        if ev.is_dir() else []
    return pod, mesh, ran_commits(), chd, extra, (SPACE / ".git").exists()

st = answer(text, "STATE add-greeting")
report(1, bool(first_word(st)) and first_word(st) not in (
    "verified", "integrated"), f"state given: {short(st)}")
rr = answer(text, "RERUN")
ids = sorted(set(re.findall(r"\bT\d+[a-z]?\b", rr or "")))
report(2, ids == ["T7a"], "no RERUN line" if rr is None else
       "re-run named: " + (", ".join(ids) or "none"))
cs = answer(text, "COMMIT SET") or ""
got = {r: sha_of(cs, r) for r in ("alpha", "beta")}
sp = sha_of(cs, "space")
report(3, got == {"alpha": "d4d4d4d", "beta": "f6f6f6f"} and sp in (
    None, "8b8b8b8"), f"commit set given: alpha {got['alpha']}, beta "
       f"{got['beta']}, space {sp or 'not named'}")
seen = [e for e in EVIDENCE if was_read(e)]
report(4, len(seen) == 2, f"{len(seen)} of 2 shard records read")
pod, mesh, git, chd, extra, dotgit = untouched()
report(5, not (pod or mesh or git or chd or extra or dotgit),
       f"pod dispatches {len(pod)}, mesh commands {len(mesh)}, commits "
       f"{len(git)}, records changed {len(chd)}, new evidence {len(extra)}, "
       f".git {dotgit}")
sst = status_state("add-greeting")
report(6, sst != "verified", "STATUS.md " + (
    "not written" if sst is False else f"state {sst}"))
finish()
```

## Fails if

- The lead counts the change verified because both records name the same
  code heads, though T7a's names a space commit older than the latest shard
  briefs.
- It names T7b, both shards or no shard for re-running.
- It dispatches, files or commits anything, or edits a record.

## At base

Expected: fail, because `agents/swe-lead.md` is absent at swe-pod `8fc5294`;
the runner records the absent deliverable and starts no agent.

Observed 2026-10-28T06:38Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), after the T18 test fixes of 2026-10-28,
runner result:

```
fail (deliverable absent: swe-pod 8fc5294 agents/swe-lead.md)
```
