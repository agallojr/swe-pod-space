---
scenario: R14.S1
mode: desk (lead)
deliverables: [swe-pod:agents, swe-pod:PROCESS.md as PROCESS.md, swe-pod:templates/records, swe-pod:skills/swe-pod, agent-mesh:skills/space-librarian]
fixture: demo-space
expected_s: 240
heavy: true
env: any
cap_s: 900
---

# R14.S1 Merge in depends order; both pins in one space commit

Serves R14 through D1 and D2 (`swe-lead`). Desk-verified per OD1: the agent
prints each git command it would run and runs none. Heavy: one agent run of
about 4 min.

## Given

- A fresh `swe-lead` agent, with the role definitions, the `swe-pod` skill
  and the `space-librarian` skill installed, and `PROCESS.md` copied to the
  space root.
- The demo space, whose `pod.yaml` pins alpha `a1a1a1a`, beta `b2b2b2b` and
  gamma `c3c3c3c`, with `depends: {beta: [alpha]}`; and this test's overlay:
  add-greeting verified, with its plan, a ledger through T8 (spec ok, one
  Minor), every report and review, the project-level tests, and evidence
  `ev-20261101T1230Z`, all passing, at alpha `d4d4d4d` and beta `e5e5e5e`
  (gamma at its pin). Nothing has moved since.
- The setup makes empty folders for the alpha, beta and gamma checkouts in
  the run dir; in a desk run no command runs in them.

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

empty_repos(["alpha", "beta", "gamma"])
snapshot()
```

## When

```text
Merge add-greeting. In this desk run, take each merge's result to be the
branch head the ledger records.
Checkouts on this node: space {SPACE}; swe-pod {EXPORT}/swe-pod; alpha {RUN}/repos/alpha; beta {RUN}/repos/beta; gamma {RUN}/repos/gamma
```

## Then

1. The merge of `change/add-greeting` into alpha's main is printed before
   beta's.
2. No git command runs in gamma.
3. `pod.yaml` then pins alpha at `d4d4d4d` and beta at `e5e5e5e`, and gamma
   stays at `c3c3c3c`.
4. Exactly one space commit stages `pod.yaml`, after both merges and after the
   pin edits.

```python check
TAG = "R14.S1"
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

repos = {n: str(RUN / "repos" / n) for n in ("alpha", "beta", "gamma")}
evs = events(stream())
ops = git_ops(commands(evs), repos)
mg = merges(ops, repos)
first = {}
for o in mg:
    first.setdefault(o["ctx"], o["at"])
order = sorted(first, key=first.get)
report(1, "alpha" in first and "beta" in first
       and first["alpha"] < first["beta"],
       "merge order: " + (", ".join(order) or "no merge"))
g = [o for o in ops if o["ctx"] == "gamma"]
report(2, not g, f"{len(g)} git call(s) in gamma")
pod = (SPACE / "pod.yaml").read_text()
got = {n: pin(pod, n) for n in repos}
want = {"alpha": "d4d4d4d", "beta": "e5e5e5e", "gamma": "c3c3c3c"}
report(3, got == want, "pins: " + ", ".join(
    f"{n} {got[n] or 'none'}" for n in repos))
edits = [at for at, k, p, d in evs if k == "use" and "pod.yaml" in tool_blob(d)
         and (d.get("name") in ("Edit", "Write") or (
             d.get("name") == "Bash" and re.search(
                 r"\b(sed|perl|python3?|awk|tee)\b|>", str(
                     (d.get("input") or {}).get("command", "")))))]
VALUED = {"-m", "-F", "--message", "--file", "-c", "-C", "--author", "--date",
          "--trailer", "--reuse-message", "--reedit-message"}


def paths(args: list) -> list:
    out, skip = [], False
    for a in args:
        if skip:
            skip = False
        elif a in VALUED:
            skip = True
        elif not a.startswith("-"):
            out.append(a)
    return out


commits, staged = [], {}
for o in ops:
    if o["ctx"] != "space":
        continue
    s = staged.setdefault(o["who"], set())
    if o["sub"] in ("add", "mv", "rm"):
        ps = paths(o["args"])
        s.update(ps)
        if o["sub"] == "add" and (not ps or "." in ps or {
                "-A", "--all", "-u", "--update"} & set(o["args"])):
            s.add("*")
    elif o["sub"] == "commit":
        s.update(paths(o["args"]))
        if {"-a", "--all"} & set(o["args"]):
            s.add("*")
        commits.append((o["at"], set(s)))
        staged[o["who"]] = set()
podc = [c for c in commits if any(
    x == "pod.yaml" or x.endswith("/pod.yaml") for x in c[1])
    or ("*" in c[1] and edits and c[0] > edits[0])]
last_merge = max((o["at"] for o in mg), default=None)
last_edit = max(edits, default=None)
ok4 = (len(podc) == 1 and last_merge is not None and podc[0][0] > last_merge
       and (last_edit is None or podc[0][0] > last_edit))
report(4, ok4, f"{len(podc)} space commit(s) stage pod.yaml" + (
    "" if not podc or last_merge is None or podc[0][0] > last_merge
    else ", before the merges"))
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- beta merges before alpha, or either is not merged.
- Anything runs in gamma.
- A pin is left behind or set to another commit, or gamma's pin moves.
- The two pins land in different space commits, or are committed before the
  merges.

## At base

Expected: fail, because the swe-pod deliverables are absent at swe-pod
`8fc5294`; the runner records the first absent deliverable and starts no
agent.

Observed 2026-10-28T00:43Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), runner result:

```
fail (deliverable absent: swe-pod 8fc5294 agents)
```
