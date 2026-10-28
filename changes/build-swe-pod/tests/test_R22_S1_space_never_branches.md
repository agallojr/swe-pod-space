---
scenario: R22.S1
mode: desk (lead)
deliverables: [swe-pod:agents, swe-pod:PROCESS.md as PROCESS.md, swe-pod:templates/records, swe-pod:skills/swe-pod, agent-mesh:skills/space-librarian, agent-mesh:skills/mesh-post]
fixture: demo-space + demo-bus
expected_s: 240
heavy: true
env: any
cap_s: 900
---

# R22.S1 Two changes in flight: the space stays on main

Serves R22 through D1 and D2 (`swe-lead`). Desk-verified per OD1. Heavy: one
agent run of about 4 min.

## Given

- A fresh `swe-lead` agent, with the role definitions, the `swe-pod`,
  `space-librarian` and `mesh-post` skills installed, and `PROCESS.md`
  copied to the space root.
- The demo bus, with the demo space mounted at `spaces/proj-demo`.
- This test's overlay: two changes in flight in one space. add-greeting is
  building: its go is recorded and T1 and T3 are dispatched to the mesh.
  add-farewell is approved, with a plan whose build and test tasks run on
  the mesh; its ledger holds only the approval. add-farewell names alpha
  only.
- The setup makes empty folders for the code checkouts in the run dir.
- The go's words state this deployment's G1 guidance (spec §14), as plan §3
  OD2 does for this change: the lead may create and push `change/<id>` in
  the code repos the spec names, so the lead under test need not hand the
  branch commands to the human; if it does hand them over, that counts.

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

bus = Path(os.environ["BUS"])
lead = ""
for p in sorted((bus / "agents").glob("*.yaml")):
    text = p.read_text()
    if "swe.lead" in text:
        lead = next(ln.split(":", 1)[1].strip() for ln in text.splitlines()
                    if ln.startswith("agent_id:"))
assert lead, "no swe.lead holder in the bus fixture"
(RUN / "subst.json").write_text(json.dumps({"LEAD_NODE": lead}))

empty_repos(["alpha", "beta", "gamma"])
snapshot()
```

## When

```text
I've skimmed the plan for add-farewell. Go.
This deployment's guidance lets the lead create `change/add-farewell`
in each code repo the spec names, at the go, and push it; build agents
commit to and push only that branch.
Checkouts on this node: space {SPACE}; swe-pod {EXPORT}/swe-pod; alpha {RUN}/repos/alpha; beta {RUN}/repos/beta; gamma {RUN}/repos/gamma; mesh bus {BUS}
This session is the lead of proj:demo, on the node registered in the bus as
{LEAD_NODE}.
```

## Then

1. `change/add-farewell` is made in alpha: the lead prints the branch or
   push command, or hands it over in its reply.
2. No git command for the space creates a branch or pushes anything but
   `main`.
3. Every space file added, changed or removed in the run is under
   `changes/add-farewell/`, or is `STATUS.md`; add-greeting's folder is
   untouched.

```python check
TAG = "R22.S1"
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

DESK_RE = re.compile(r"DESK:\s*(.+?)\s*$")


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


def handed(text: str) -> list:
    """Git and cd commands a reply hands over for someone to run: lines that
    start with one, and inline code spans that hold one, outside DESK lines.
    Items are shaped as commands() items, for the session."""
    out = []
    for n, ln in enumerate(text.splitlines()):
        if "DESK:" in ln:
            continue
        s = re.sub(r"^\s*(?:[-*+>]\s+|\d+[.)]\s+|\$\s+)*`*", "", ln)
        found = re.findall(r"`((?:cd|git)\s[^`]+)`", ln)
        if not found and re.match(r"(cd|git)\s", s):
            found = [s.rstrip("`").strip()]
        for x in found:
            out.append({"at": (10 ** 6, n), "who": None, "cmd": x,
                        "src": "reply"})
    return out

import shlex


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
                here = next((r for r in repos if re.search(
                    r"\b" + re.escape(r) + r"\b", seg)), ctx)
                ops.append({"at": at, "who": c["who"], "ctx": here,
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
            elif len(pos) == 2 and "--detach" not in a:
                out.append((o, os.path.basename(pos[1].rstrip("/"))))
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

repos = {n: str(RUN / "repos" / n) for n in ("alpha", "beta", "gamma")}
ops = git_ops(commands(events(stream())), repos)
cr, pu = created(ops), pushed(ops)
hops = ops + git_ops(handed(final()), repos)
made = ([o for o, b in created(hops) if o["ctx"] == "alpha"
         and b == "change/add-farewell"]
        + [o for o, d, f in pushed(hops) if o["ctx"] == "alpha"
           and "change/add-farewell" in d])
report(1, bool(made), f"{len(made)} command(s) make change/add-farewell in "
       "alpha")
sb = [b for o, b in cr if o["ctx"] == "space"]
sp = [d for o, d, f in pu if o["ctx"] == "space"
      and (f or any(x not in ("main", "HEAD") for x in d))]
report(2, not sb and not sp, f"space: {len(sb)} branch(es) made, {len(sp)} "
       "push(es) to another branch or forced")
added, mod, gone = changed()
out = [p for p in added + mod + gone
       if not p.startswith("changes/add-farewell/") and p != "STATUS.md"]
report(3, not out, f"{len(out)} file(s) changed outside "
       "changes/add-farewell/, STATUS.md aside")
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- The space gets a branch, or a push to anything but `main`.
- add-farewell's records land outside its own folder, or add-greeting's folder
  changes.
- The go neither makes `change/add-farewell` in alpha nor hands over the
  commands that make it.

## At base

Expected: fail, because the swe-pod deliverables are absent at swe-pod
`8fc5294`; the runner records the first absent deliverable and starts no
agent.

Observed 2026-10-28T07:42Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), after the T18 fixes of verify round 2,
runner result:

```
fail (deliverable absent: swe-pod 8fc5294 agents)
```
