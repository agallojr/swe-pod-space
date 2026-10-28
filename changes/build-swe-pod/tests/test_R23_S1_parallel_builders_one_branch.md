---
scenario: R23.S1
mode: desk (lead, build)
deliverables: [swe-pod:agents, swe-pod:PROCESS.md as PROCESS.md, swe-pod:templates/records, swe-pod:skills/swe-pod, agent-mesh:skills/space-librarian]
fixture: demo-space
expected_s: 480
heavy: true
env: any
cap_s: 1800
---

# R23.S1 Two parallel builders in one repo share the one branch

Serves R23 through D1 and D2 (`swe-lead`, `swe-build`). Desk-verified per
OD1: the lead and both builders print the git commands they would run. Heavy:
about 8 min, with two builder subagents.

## Given

- A fresh `swe-lead` agent, with the role definitions, the `swe-pod` skill
  and the `space-librarian` skill installed, and `PROCESS.md` copied to the
  space root. The lead starts the builders as `swe-build` subagents.
- The demo space with this test's overlay: an add-greeting plan in which T1
  (greeting text, `alpha/greeting.py`) and T2 (name limit,
  `alpha/limits.py`) both work in alpha, with no file in common and no
  `after` between them; the go already recorded (branches
  `change/add-greeting`: alpha `a1a1a1a`, beta `b2b2b2b`); and the briefs of
  T1 and T2.
- The setup writes a minimal export of alpha into the run dir (a package
  and an empty test folder), not a git work tree.

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

write(RUN / "repos" / "alpha", {
    "README.md": "# alpha\n\nShared texts for the demo tools.\n",
    "alpha/__init__.py": "", "tests/__init__.py": ""})
snapshot()
```

## When

```text
Dispatch T1 and T2 of add-greeting now, in parallel; both work in alpha.
Dispatch nothing else. Pass this run's desk rule on to each builder, word for
word, at the top of its prompt.
Checkouts on this node: space {SPACE}; alpha {RUN}/repos/alpha; swe-pod {EXPORT}/swe-pod
```

## Then

1. Two `swe-build` subagents are started, one for T1 and one for T2.
2. They run in parallel: each starts before the other finishes.
3. Each builder prints a commit with the trailers `Change: add-greeting` and
   `Task: T1` (or `Task: T2`), and a push that names `change/add-greeting`.
4. No one creates a branch, pushes any other branch, or forces a push.

```python check
TAG = "R23.S1"
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

repos = {"alpha": str(RUN / "repos" / "alpha")}
evs = events(stream())
builders = {}
for at, d in agent_calls(evs):
    st = str((d.get("input") or {}).get("subagent_type", ""))
    t = call_text(d)
    if st != "swe-build" and "swe-build" not in t:
        continue
    m = re.search(r"\bT([12])-brief", t) or re.search(r"\bT([12])\b", t)
    if m and "T" + m.group(1) not in builders:
        builders["T" + m.group(1)] = (at, d.get("id"))
report(1, set(builders) == {"T1", "T2"}, "builders started for: " + (
    ", ".join(sorted(builders)) or "none"))
span = {}
for tk, (at, cid) in builders.items():
    ends = [a for a, k, p, d in evs if p == cid
            or (k == "result" and d["id"] == cid)]
    span[tk] = (at, max(ends) if ends else at)
par = (len(span) == 2 and (span["T1"][0][0] == span["T2"][0][0] or (
    span["T1"][0] < span["T2"][1] and span["T2"][0] < span["T1"][1])))
report(2, par, "builders ran " + ("in parallel" if par else "one after the "
                                  "other" if len(span) == 2 else "short"))
cmds = commands(evs)
ops = git_ops(cmds, repos)
good = []
for tk, (at, cid) in builders.items():
    mine = [c["cmd"] for c in cmds if c["who"] == cid]
    text = "\n".join(mine + [d if isinstance(d, str) else d.get("text", "")
                             for a, k, p, d in evs if (p == cid and k == "text")
                             or (k == "result" and d["id"] == cid)])
    commit = any(o["who"] == cid and o["sub"] == "commit" for o in ops)
    push = [o for o in ops if o["who"] == cid and o["sub"] == "push"
            and "change/add-greeting" in o["cmd"]]
    if (commit and push and re.search(r"Task:\s*" + tk + r"\b", text)
            and re.search(r"Change:\s*add-greeting\b", text)):
        good.append(tk)
report(3, sorted(good) == ["T1", "T2"], "builders with a trailered commit "
       "and a push to change/add-greeting: " + (", ".join(good) or "none"))
cr = created(ops)
bad = [o for o, d, f in pushed(ops) if f or any(
    x not in ("change/add-greeting", "HEAD")
    and not (x == "main" and o["ctx"] == "space" and o["who"] is None)
    for x in d)]
report(4, not cr and not bad, f"{len(cr)} branch(es) created, {len(bad)} "
       "push(es) to another branch or forced")
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- A builder creates a branch, or pushes to any branch but
  `change/add-greeting`.
- A builder's commit lacks its `Change:` or `Task:` trailer.
- The two tasks run one after the other, or only one is started.

## At base

Expected: fail, because the swe-pod deliverables are absent at swe-pod
`8fc5294`; the runner records the first absent deliverable and starts no
agent.

Observed 2026-10-28T00:43Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), runner result:

```
fail (deliverable absent: swe-pod 8fc5294 agents)
```
