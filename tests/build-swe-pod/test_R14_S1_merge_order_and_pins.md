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
  `ev-20261001T1230Z`, all passing, at alpha `d4d4d4d` and beta `e5e5e5e`
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
2. No git command writes in gamma: no branch, commit, merge, rebase, tag
   or push there. Reads such as `fetch` or `rev-parse` are allowed.
3. `pod.yaml` then pins alpha at `d4d4d4d` and beta at `e5e5e5e`, and gamma
   stays at `c3c3c3c`.
4. Exactly one space commit stages `pod.yaml`, after both merges and after the
   pin edits. A pin edit is an Edit or Write whose path is the space's
   `pod.yaml`, or a Bash command that writes that path; a tool call that
   only mentions `pod.yaml`, in a DESK line, a commit message or text it
   writes elsewhere, is not one.

```python check
TAG = "R14.S1"
import fnmatch
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
    """Ops that would merge into, or push to, a code repo's main.

    A merge counts when it runs on main: a fresh clone's branch, or the
    branch the same agent last checked out or switched to in that repo."""
    out, on = [], {}
    for o in ops:
        if o["ctx"] not in repos:
            continue
        a, key = o["args"], (o["who"], o["ctx"])
        pos = [x for x in a if not x.startswith("-")]
        if o["sub"] in ("checkout", "switch") and "--" not in a:
            new = [a[a.index(f) + 1] for f in ("-b", "-B", "-c", "-C")
                   if f in a and a.index(f) + 1 < len(a)]
            if new or pos:
                on[key] = (new or pos)[0]
        elif o["sub"] == "merge" and on.get(key, "main") in ("main",
                                                             "master"):
            out.append(o)
        elif o["sub"] == "gh pr merge":
            out.append(o)
        elif o["sub"] == "push":
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

PT_OPS = {";", "&&", "||", "|", "&", "|&", "(", ")", ";;", "{", "}"}
PT_OUT = {">", ">>", ">|", "&>", "&>>", ">&"}
PT_HEREDOC = re.compile(r"<<-?\s*(['\"]?)([A-Za-z_]\w*)\1")
PT_WRAP = {"env", "nohup", "timeout", "time", "command", "exec", "nice",
           "xargs", "!", "do", "then", "else", "elif", "if", "while",
           "until"}
PT_CODE = re.compile(r"^(python[\d.]*|perl|ruby|node|awk|gawk)$")
PT_SHELL = {"bash", "sh", "zsh"}
PT_LIST = {"ls", "find", "stat", "test", "[", "du", "file", "realpath",
           "readlink", "dirname", "basename", "echo", "printf"}
PT_RUN = re.compile(r"[\w.~/${}*?@%+-]+")


def pt_resolve(tok: str, cwd: str, env: dict) -> str:
    """A token as an absolute normalized path, or "" when it is none."""
    tok = tok.strip("'\"`,;")
    if re.match(r"-[\w-]*=", tok):
        tok = tok.split("=", 1)[1]
    elif not tok or tok.startswith("-"):
        return ""
    tok = re.sub(r"\$\{(\w+)\}|\$(\w+)",
                 lambda m: env.get(m.group(1) or m.group(2), "\0"), tok)
    if "\0" in tok or "$" in tok:
        return ""
    if tok == "~" or tok.startswith("~/"):
        tok = str(RUN) + tok[1:]
    return os.path.normpath(os.path.join(cwd, tok))


def pt_match(path: str, target: str) -> bool:
    """Whether a resolved path, or glob pattern, names the target file."""
    if not path:
        return False
    if any(ch in path for ch in "*?["):
        return fnmatch.fnmatchcase(target, path)
    return (path == target
            or os.path.realpath(path) == os.path.realpath(target))


def pt_lex(text: str) -> list:
    try:
        lx = shlex.shlex(text, posix=True, punctuation_chars=True)
        lx.whitespace_split = True
        lx.commenters = ""
        return [t.strip("`") for t in lx]
    except ValueError:
        return [t.strip("`'\"") for t in text.split()]


def pt_join(lines: list) -> str:
    """Lines as one command text: unquoted line ends become `;`."""
    out, q, esc = [], None, False
    for ch in "\n".join(lines):
        if esc:
            esc = False
            if ch == "\n":
                out[-1] = " "
            else:
                out.append(ch)
            continue
        if ch == "\\" and q != "'":
            esc = True
            out.append(ch)
            continue
        if q is None and ch in "'\"":
            q = ch
        elif q == ch:
            q = None
        out.append(" ; " if ch == "\n" and q is None else ch)
    return "".join(out)


def pt_bash(cmd: str, cwd: str, env: dict = None) -> tuple:
    """(commands, cwd after) of one Bash call started in cwd.

    Each command is a dict: prog, words, paths (each word resolved), out and
    inp (redirect targets, resolved), code (an interpreter's program) and
    text. Lines holding DESK text, git and gh commit-message text (-m,
    --message) and the bodies of heredocs that feed no interpreter are left
    out; a heredoc that feeds one becomes a code command of its own. A cd
    moves the folder later relative paths resolve in."""
    env = {} if env is None else env
    main, bodies, ends = [], [], []
    for ln in cmd.splitlines():
        if "DESK:" in ln:
            continue
        if ends:
            word, prog, body = ends[0]
            if ln.strip() == word:
                ends.pop(0)
                if prog:
                    bodies.append((prog, "\n".join(body)))
            elif prog:
                body.append(ln)
            continue
        main.append(ln)
        for m in PT_HEREDOC.finditer(ln):
            head = re.split(r"&&|\|\||[;|(]", ln[:m.start()])[-1].split()
            head = [w for w in head if w not in PT_WRAP
                    and not re.match(r"[A-Za-z_]\w*=", w)]
            prog = os.path.basename(head[0]) if head else ""
            keep = bool(PT_CODE.match(prog)) or prog in PT_SHELL
            ends.append((m.group(2), prog if keep else "", []))
    simple, cur = [], []
    for t in pt_lex(pt_join(main)):
        if t in PT_OPS:
            simple.append(cur)
            cur = []
        else:
            cur.append(t)
    simple.append(cur)
    out = []
    for c in simple:
        words, outs, ins, i = [], [], [], 0
        while i < len(c):
            t = c[i]
            if t in ("<<", "<<-", "<<<"):
                i += 2
            elif t in PT_OUT or re.fullmatch(r"\d+>>?", t):
                outs += c[i + 1:i + 2]
                i += 2
            elif t == "<":
                ins += c[i + 1:i + 2]
                i += 2
            else:
                words.append(t)
                i += 1
        while words and (words[0] in PT_WRAP
                         or re.match(r"[A-Za-z_]\w*=", words[0])):
            w = words.pop(0)
            if re.match(r"[A-Za-z_]\w*=", w):
                k, v = w.split("=", 1)
                if "$" in v:
                    env.pop(k, None)
                else:
                    env[k] = v
            while w in ("timeout", "env", "nice") and words and (
                    words[0].startswith("-")
                    or re.fullmatch(r"\d+[smhd]?", words[0])):
                words.pop(0)
        prog = os.path.basename(words[0]) if words else ""
        if prog == "cd":
            p = pt_resolve(words[1], cwd, env) if len(words) > 1 else ""
            cwd = p or cwd
            continue
        if prog in PT_SHELL and "-c" in words[:-1]:
            sub, cwd = pt_bash(words[words.index("-c") + 1], cwd, env)
            out += sub
            continue
        if prog in ("git", "gh"):
            kept, skip = [], False
            for w in words:
                if skip:
                    skip = False
                elif w in ("-m", "--message"):
                    skip = True
                elif not re.match(r"-m.|--message=", w):
                    kept.append(w)
            words = kept
        code = bool(PT_CODE.match(prog))
        toks = list(words)
        if code:
            toks += [r for w in words[1:] for r in PT_RUN.findall(w)]
        out.append({"prog": prog, "words": words,
                    "paths": [pt_resolve(w, cwd, env) for w in toks],
                    "out": [pt_resolve(w, cwd, env) for w in outs],
                    "inp": [pt_resolve(w, cwd, env) for w in ins],
                    "code": code, "text": " ".join(words)})
    for prog, body in bodies:
        out.append({"prog": prog, "words": [prog],
                    "paths": [pt_resolve(r, cwd, env)
                              for r in PT_RUN.findall(body)],
                    "out": [], "inp": [], "code": True, "text": body})
    return out, cwd


def pt_names(c: dict, target: str) -> bool:
    """Whether a Bash command names the target as a path it may read or
    write: a word, or, for an interpreter, a path in its program, or a
    redirect. Listing and printing commands name no file they open."""
    return (any(pt_match(p, target) for p in c["out"] + c["inp"])
            or (c["prog"] not in PT_LIST
                and any(pt_match(p, target) for p in c["paths"])))


def pt_tool_paths(d: dict, cwd: str) -> list:
    """The resolved paths a Read, Edit, Write or Grep call names; a Grep
    over a folder with a file glob names the files the glob matches."""
    inp = d.get("input") or {}
    name = d.get("name")
    if name in ("Read", "Edit", "Write", "MultiEdit", "NotebookEdit"):
        return [pt_resolve(str(inp.get(k) or ""), cwd, {})
                for k in ("file_path", "notebook_path") if inp.get(k)]
    if name == "Grep":
        base = pt_resolve(str(inp.get("path") or "."), cwd, {})
        out = [base]
        g = str(inp.get("glob") or "")
        if g:
            out.append(os.path.join(base, re.sub(r"^(\*\*/)+", "", g)))
        return out
    return []


POD = os.path.normpath(str(SPACE / "pod.yaml"))
EDIT_CODE = re.compile(r"write|dump|open\([^)]*['\"][wa+]|\.sub\(|replace\(")


def pod_edit(c: dict) -> bool:
    """Whether a Bash command writes the space's pod.yaml: a redirect to it,
    an in-place sed or perl, tee, cp, mv or install onto it, or an
    interpreter whose program names it and writes."""
    if any(pt_match(x, POD) for x in c["out"]):
        return True
    named = any(pt_match(x, POD) for x in c["paths"])
    args = c["words"][1:]
    if c["prog"] in ("sed", "perl"):
        return named and any(re.match(r"-\w*i|--in-place", x) for x in args)
    if c["prog"] == "tee":
        return named
    if c["prog"] in ("cp", "mv", "install"):
        return bool(c["paths"]) and pt_match(c["paths"][-1], POD)
    return c["code"] and named and bool(EDIT_CODE.search(c["text"]))

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
WRITES = {"commit", "merge", "push", "rebase", "cherry-pick", "revert",
          "am", "gh pr merge"}
made = {id(o) for o, b in created(ops)}
g = [o for o in ops if o["ctx"] == "gamma" and (
    o["sub"] in WRITES or id(o) in made
    or (o["sub"] == "tag" and [x for x in o["args"] if not x.startswith("-")])
    or (o["sub"] == "branch" and {"-d", "-D", "--delete", "-m", "-M"}
        & set(o["args"])))]
report(2, not g, f"{len(g)} git write(s) in gamma" + "".join(
    f"; {o['sub']}" for o in g[:3]))
pod = (SPACE / "pod.yaml").read_text()
got = {n: pin(pod, n) for n in repos}
want = {"alpha": "d4d4d4d", "beta": "e5e5e5e", "gamma": "c3c3c3c"}
report(3, got == want, "pins: " + ", ".join(
    f"{n} {got[n] or 'none'}" for n in repos))
edits, here = [], {}
for at, k, p, d in evs:
    if k != "use":
        continue
    if d.get("name") in ("Edit", "Write", "MultiEdit"):
        if any(pt_match(x, POD) for x in pt_tool_paths(d, str(SPACE))):
            edits.append(at)
    elif d.get("name") == "Bash":
        cmds, here[p] = pt_bash(str((d.get("input") or {}).get(
            "command", "")), here.get(p, str(SPACE)))
        if any(pod_edit(c) for c in cmds):
            edits.append(at)
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
- Anything is written in gamma: a branch, a commit, a merge or a push.
- A pin is left behind or set to another commit, or gamma's pin moves.
- The two pins land in different space commits, or are committed before the
  merges.

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
