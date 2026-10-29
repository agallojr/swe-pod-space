---
scenario: R20.S1
mode: agent (skill, then skill)
deliverables: [swe-pod:skills/swe-pod, swe-pod:PROCESS.md as PROCESS.md]
fixture: demo-space
expected_s: 240
heavy: true
env: any
cap_s: 1200
---

# R20.S1 Regenerating STATUS.md from the records gives the same text

Serves R20 through D4 (the skill and `status-format.md`). Heavy: two agent
runs of about 2 min each.

## Given

- Two steps, each a fresh default agent in its own process with a reset
  config, each with the `swe-pod` skill installed and `PROCESS.md` copied to
  the space root.
- The demo space with this test's overlay: the two open changes of R18.S1,
  and no `STATUS.md`. The newest ledger line or record is
  2026-10-02T08:00Z.
- Step 1's `STATUS.md` stands for the committed one; step 2 rebuilds it from
  the same records without reading it.

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

snapshot()
```

## When

```text
Regenerate STATUS.md.
```

```text
Regenerate STATUS.md from the records, but write it to x-rebuild/STATUS.md in
the space, not to the space root, and do not open the space's own STATUS.md: I
want to compare the two.
```

## Then

1. Step 1 writes `STATUS.md`, whose first non-empty line is `# Status:
   proj:demo`, with the line `Generated from the records; never edited by
   hand. As of <UTC>.`
2. The As-of time is 2026-10-02T08:00Z, the newest ledger line, not the wall
   clock.
3. The pins line names alpha `a1a1a1a`, beta `b2b2b2b` and gamma `c3c3c3c`.
4. Step 2 neither reads nor writes the space's root `STATUS.md`: no Read,
   Edit, Write or Grep call names it as its path, and no Bash command names
   it as a path. DESK lines, commit-message text and printed text do not
   count.
5. Step 2's `x-rebuild/STATUS.md` matches `STATUS.md` line for line, trailing
   spaces and blank lines at the end aside.

```python check
TAG = "R20.S1"
import fnmatch
import json
import os
import re
import shlex
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

st_p = SPACE / "STATUS.md"
st = st_p.read_text() if st_p.is_file() else ""
lines = [ln.rstrip() for ln in st.splitlines() if ln.strip()]
GEN = "Generated from the records; never edited by hand. As of "
gen = next((ln for ln in lines if ln.startswith(GEN)), "")
head_ok = bool(lines) and lines[0] == "# Status: proj:demo" and bool(gen)
report(1, head_ok, "STATUS.md " + (
    "absent" if not st else "header and Generated line " + (
        "present" if head_ok else "wrong")))
asof = gen[len(GEN):] if gen else ""
report(2, bool(re.match(r"2026-10-02[T ]08:00", asof)),
       "As of " + ("the newest ledger line" if re.match(
           r"2026-10-02[T ]08:00", asof) else "another time"))
pins = next((ln for ln in lines if ln.startswith("- pins: ")), "")
report(3, all(x in pins for x in ("alpha a1a1a1a", "beta b2b2b2b",
                                  "gamma c3c3c3c")), "pins line " + (
    "complete" if pins else "absent"))
TARGET = os.path.normpath(str(SPACE / "STATUS.md"))
peek, here = [], {}
for at, k, p, d in events(stream(2)):
    if k != "use":
        continue
    if d.get("name") == "Bash":
        cmds, here[p] = pt_bash(str((d.get("input") or {}).get(
            "command", "")), here.get(p, str(SPACE)))
        hit = any(pt_names(c, TARGET) for c in cmds)
    else:
        hit = any(pt_match(x, TARGET) for x in pt_tool_paths(d, str(SPACE)))
    if hit:
        peek.append(d.get("name"))
report(4, not peek, f"step 2 touched the space's STATUS.md {len(peek)} "
       "time(s)")
rb = SPACE / "x-rebuild" / "STATUS.md"


def norm(t: str) -> list:
    out = [ln.rstrip() for ln in t.splitlines()]
    while out and not out[-1]:
        out.pop()
    return out


a, b = norm(st), norm(rb.read_text()) if rb.is_file() else []
diff = next((i + 1 for i, (x, y) in enumerate(zip(a, b)) if x != y), None)
if diff is None and len(a) != len(b):
    diff = min(len(a), len(b)) + 1
report(5, bool(a) and rb.is_file() and diff is None, "rebuild " + (
    "absent" if not rb.is_file() else "matches" if diff is None and a else
    f"differs from line {diff}"))
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- The rebuild differs from `STATUS.md` in any line.
- The As-of time comes from the wall clock or a file time.
- Step 2 copies the committed `STATUS.md` rather than rebuilding it.

## At base

Expected: fail, because the swe-pod deliverables are absent at swe-pod
`8fc5294`; the runner records the first absent deliverable and starts no
agent.

Observed 2026-10-28T07:42Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), after the T18 fixes of verify round 2,
runner result:

```
fail (deliverable absent: swe-pod 8fc5294 skills/swe-pod)
```
