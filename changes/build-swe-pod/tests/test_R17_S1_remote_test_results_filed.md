---
scenario: R17.S1
mode: desk (lead, with a fixture outbox)
deliverables: [swe-pod:agents, swe-pod:PROCESS.md as PROCESS.md, swe-pod:templates/records, swe-pod:skills/swe-pod, agent-mesh:skills/space-librarian]
fixture: demo-space + demo-bus
expected_s: 240
heavy: true
env: any
cap_s: 900
---

# R17.S1 A remote test agent's tests arrive in its result and are filed

Serves R17 through D1, D2 (`swe-lead`) and D5 (M3, results that carry files;
M5, the librarian). Desk-verified per OD1, with a fixture outbox. Heavy: one
agent run of about 4 min.

## Given

- A fresh `swe-lead` agent, with the role definitions, the `swe-pod` skill
  and the `space-librarian` skill installed, and `PROCESS.md` copied to the
  space root.
- The demo bus, with the demo space mounted at `spaces/proj-demo`. The setup
  adds `spaces.yaml`, registering `proj:demo` with `access: rw` and the
  librarian role `librarian`, which the lead's node holds.
- This test's overlay: add-greeting after the go, with a plan whose T3
  (tests) runs on the mesh with `needs: linux-server`, the ledger line
  `dispatch T3 -> test (mesh, linux-server)`, and the T3 brief.
- The setup builds, at run time, the mesh records of T3 as the remote test
  node left them: the task.request in `tasks/roles/swe.test/` (from the
  lead's node, with `project: proj:demo`, and a Context naming
  `swe-pod/agents/swe-test.md` and the brief); its status, `done`, by the
  linux-server node; and its result in that node's outbox, whose `files:`
  lists four files with their sha256 (three project-level tests and the T3
  report, which a test task returns in its lane as
  `evidence/<YYYYMMDDTHHMMZ>-T3-report.md`, plan §2.4), with their bodies
  under `<task id>-files/`. The task id is built
  from split literals and the node ids are read from the bus copy.

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

bus = Path(os.environ["BUS"])


def field(path: Path, key: str) -> str:
    for ln in path.read_text().splitlines():
        if ln.startswith(key + ":"):
            return ln.split(":", 1)[1].strip()
    return ""


regs = sorted((bus / "agents").glob("*.yaml"))
lead = next(p for p in regs if "swe.lead" in field(p, "roles"))
tester = next(p for p in regs if "swe.test" in field(p, "roles"))
lead_id, test_id = field(lead, "agent_id"), field(tester, "agent_id")
task = "2026" + "1101T0921-0003"
(bus / "spaces.yaml").write_text(
    "spaces:\n  - {id: proj:demo, path: spaces/proj-demo, access: rw, "
    "librarian: librarian}\n")
req = bus / "tasks" / "roles" / "swe.test" / f"{task}-add-greeting-t3.md"
req.parent.mkdir(parents=True, exist_ok=True)
req.write_text("\n".join([
    "---", "schema_version: 1", f"id: {task}", f"from: {lead_id}",
    "to: role:swe.test", "type: task.request",
    "created: 2026-11-01T09:21:00Z", "priority: normal", "depends_on: []",
    "timeout_min: 120", "project: proj:demo", "---", "",
    "## Goal",
    "Write the project-level tests of change add-greeting, task T3, from its",
    "brief, and return them and the T3 report as result files.", "",
    "## Context",
    "Role definition: swe-pod/agents/swe-test.md",
    "Brief: changes/add-greeting/tasks/T3-brief.md",
    "Read the role definition before anything else. Project Space proj:demo.",
    "",
    "## Done when",
    "The result's files: list one test per scenario and the T3 report.", "",
    "## On failure",
    "Return what you have, and say what blocked you.", ""]))
BODIES = {}
BODIES['changes/add-greeting/tests/test_R1_S1_default_greeting.md'] = "\n".join([
    '---',
    'scenario: R1.S1',
    'mode: inspect',
    'expected_s: 1',
    'heavy: false',
    'env: any',
    'cap_s: 30',
    '---',
    '',
    '# R1.S1 Default greeting',
    '',
    '## Given',
    '',
    '`alpha` at the commit set under test.',
    '',
    '## When',
    '',
    'In the `alpha` checkout:',
    '',
    '    python3 -c "from alpha.greeting import greeting; print(repr(greeting()))"',
    '',
    '## Then',
    '',
    "1. It prints `'hello, demo'` (11 characters, no trailing newline in the value) "
    'and exits 0.',
    '',
    '## Fails if',
    '',
    '- The text differs by any character, or the call raises.',
    '',
])
BODIES['changes/add-greeting/tests/test_R1_S2_name_too_long.md'] = "\n".join([
    '---',
    'scenario: R1.S2',
    'mode: inspect',
    'expected_s: 1',
    'heavy: false',
    'env: any',
    'cap_s: 30',
    '---',
    '',
    '# R1.S2 Name too long',
    '',
    '## Given',
    '',
    '`alpha` at the commit set under test; a name of 65 characters.',
    '',
    '## When',
    '',
    'In the `alpha` checkout:',
    '',
    '    python3 -c "from alpha.greeting import greeting; print(greeting(\'x\' * 65))"',
    '',
    '## Then',
    '',
    '1. It exits non-zero, and its error output contains `64`.',
    '2. It prints no greeting on standard output.',
    '',
    '## Fails if',
    '',
    '- A greeting is printed, or the error does not name the limit.',
    '',
])
BODIES['changes/add-greeting/tests/test_R2_S1_startup_line.md'] = "\n".join([
    '---',
    'scenario: R2.S1',
    'mode: inspect',
    'expected_s: 2',
    'heavy: false',
    'env: any',
    'cap_s: 30',
    '---',
    '',
    '# R2.S1 Start-up line',
    '',
    '## Given',
    '',
    '`beta` and `alpha` at the commit set under test, checked out side by side.',
    '',
    '## When',
    '',
    'In the `beta` checkout:',
    '',
    '    python3 -m beta',
    '',
    '## Then',
    '',
    '1. The first line of standard output is `hello, demo`.',
    '2. It finishes within 1 s of start (wall time).',
    '',
    '## Fails if',
    '',
    '- Another first line, or 1 s or more.',
    '',
])
BODIES['changes/add-greeting/evidence/20261101T1020Z-T3-report.md'] = "\n".join([
    '# T3 report',
    '',
    '## Status',
    '',
    'DONE',
    '',
    '## What I did',
    '',
    'Wrote one project-level test per scenario, from the spec, and ran them at the b'
    'ase commit set.',
    '',
    '## Files',
    '',
    '- changes/add-greeting/tests/test_R1_S1_default_greeting.md',
    '- changes/add-greeting/tests/test_R1_S2_name_too_long.md',
    '- changes/add-greeting/tests/test_R2_S1_startup_line.md',
    '',
    '## Test output',
    '',
    '- test_R1_S1_default_greeting at base: fail (no greeting in alpha)',
    '- test_R1_S2_name_too_long at base: fail (no greeting in alpha)',
    '- test_R2_S1_startup_line at base: fail (beta prints nothing)',
    '',
    '## Concerns',
    '',
    'None.',
    '',
    '## Test suggestions',
    '',
    'None.',
    '',
])

out = bus / "outbox" / test_id
entries = []
for path, text in BODIES.items():
    f = out / f"{task}-files" / path
    f.parent.mkdir(parents=True, exist_ok=True)
    f.write_text(text)
    entries.append({"path": path,
                    "sha256": hashlib.sha256(text.encode()).hexdigest()})
(out / f"{task}-result.md").write_text("\n".join(
    ["---", "schema_version: 1", f"task_id: {task}", f"agent_id: {test_id}",
     "type: result", "state: done", "completed: 2026-11-01T10:20:00Z",
     "files:"]
    + [f"  - {{path: {e['path']}, sha256: {e['sha256']}}}" for e in entries]
    + ["---", "", "## Result", "",
       "T3 DONE. One project-level test per scenario, and the T3 report, are",
       "returned under files:.", ""]))
(bus / "status").mkdir(exist_ok=True)
(bus / "status" / f"{task}.json").write_text(json.dumps({
    "schema_version": 1, "task_id": task, "agent_id": test_id,
    "hostname": field(tester, "hostname"), "state": "done",
    "accepted": "2026-11-01T09:25:00Z", "started": "2026-11-01T09:25:10Z",
    "updated": "2026-11-01T10:20:00Z", "progress": "done", "log_tail": [],
    "artifacts": [], "error": None}, indent=2) + "\n")
secrets = [task, lead_id, test_id, field(lead, "hostname"),
           field(tester, "hostname")]
(RUN / "expected.json").write_text(json.dumps(
    {"files": entries, "secrets": secrets}, indent=2))
(RUN / "subst.json").write_text(json.dumps({"LEAD_NODE": lead_id}))
snapshot()
```

## When

```text
T3 of add-greeting, the test-writing task, went to the mesh and has finished.
File its result.
Checkouts on this node: space {SPACE}; mesh bus {BUS}; swe-pod {EXPORT}/swe-pod
This session is the lead of proj:demo, on the node registered in the bus as
{LEAD_NODE}. That node also holds the librarian role for this space.
```

## Then

1. Each of the four result files is in the space at its path, byte for byte as
   returned: its sha256 matches `files:`.
2. The commit step names each of them literally in a printed `git add` (no
   `-A`, `--all` or `.`), and prints a commit and a push to the space's
   `main`.
3. The ledger gets a `T3 DONE` line, and lines that name each filed test.
4. No space file holds the mesh task id, or an agent id or hostname from the
   bus.

```python check
TAG = "R17.S1"
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


import shlex

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

STAMP = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2})?Z ")


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

import hashlib

exp = json.loads((RUN / "expected.json").read_text())
files = exp["files"]
ok = [f for f in files if (SPACE / f["path"]).is_file() and hashlib.sha256(
    (SPACE / f["path"]).read_bytes()).hexdigest() == f["sha256"]]
report(1, len(ok) == len(files),
       f"{len(ok)} of {len(files)} result files in the space, byte for byte")
desk = [c["cmd"] for c in commands(events(stream())) if c["src"] == "desk"]
adds = [ln for ln in desk if re.search(r"\bgit\b.*\badd\b", ln)]
named = [f for f in files if any(f["path"] in ln for ln in adds)]
wild = [ln for ln in adds if re.search(r"\s(-A|--all|\.)(\s|$)", ln)]
commit = any(re.search(r"\bgit\b.*\bcommit\b", ln) for ln in desk)
push = any(re.search(r"\bgit\b.*\bpush\b.*(HEAD:main|\bmain)\b", ln)
           for ln in desk)
report(2, len(named) == len(files) and not wild and commit and push,
       f"{len(named)} of {len(files)} staged by name, {len(wild)} wildcard "
       f"add(s), commit {commit}, push to main {push}")
new = ledger_new("changes/add-greeting/ledger.md")
done = [e for e in new if re.search(r" T3 (DONE|DONE_WITH_CONCERNS)\b", e)]
tests = [f["path"] for f in files if "/tests/" in f["path"]]
filed = [p for p in tests if any(p in e or p.rsplit("/", 1)[-1] in e
                                 for e in new)]
report(3, bool(done) and len(filed) == len(tests),
       f"T3 DONE line {bool(done)}; {len(filed)} of {len(tests)} tests named")
leaks = set()
for p in SPACE.rglob("*"):
    if p.is_file():
        try:
            t = p.read_text()
        except UnicodeDecodeError:
            continue
        if any(s and s in t for s in exp["secrets"]):
            leaks.add(str(p.relative_to(SPACE)))
report(4, not leaks, f"{len(leaks)} space file(s) hold a mesh task id, agent "
       "id or hostname" + "".join(f"; {x}" for x in sorted(leaks)[:3]))
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- A result file is missing from the space, or differs from what the remote
  agent returned.
- The commit step stages by wildcard, or does not commit and push the space's
  main.
- The ledger does not record T3's result and what was filed.
- A mesh task id, agent id or hostname reaches the space.

## At base

Expected: fail, because the swe-pod deliverables are absent at swe-pod
`8fc5294`; the runner records the first absent deliverable and starts no
agent.

Observed 2026-10-28T06:38Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), after the T18 test fixes of 2026-10-28,
runner result:

```
fail (deliverable absent: swe-pod 8fc5294 agents)
```
