---
scenario: R17.S2
mode: agent (space-librarian)
deliverables: [agent-mesh:skills/space-librarian]
fixture: demo-space
expected_s: 240
heavy: true
env: any
cap_s: 600
---

# R17.S2 No mesh: the session files through the Agent Mesh librarian

Serves R17 through D5 (M5: a librarian usable without a bus). The commit
step is desk, per the runner protocol. Heavy: one agent run of about 4 min.

## Given

- A fresh default agent with only the `space-librarian` skill, exported
  read-only from agent-mesh at the sha under test.
- The demo space alone: no bus, no core and no lore space. It holds
  `notes/note-20261001T1100Z-a0b1-demo-context.md`.
- The clean record from this test's overlay,
  `notes/note-20261001T1300Z-d2f5-single-seat.md`, which also holds the
  allowed cases: generic `~/` paths, a URL, a citation of `core` (listed in
  `may_reference`), a citation inside inline code, and an id-shaped example
  that no bus holds.
- Eight records built by the setup at run time, each with one fault on a
  known line. With no bus, the profile values are the node's own and the
  home-root patterns. The negative content is built from split literals or
  read from the node, and never stored whole:

  | Record | Fault | Kind | Line |
  |---|---|---|---|
  | `0c01-mac-home` | absolute path under the macOS home root | profile | 11 |
  | `0c02-linux-home` | absolute path under the Linux home root | profile | 11 |
  | `0c03-local-host` | this node's hostname | profile | 11 |
  | `0c04-home` | the local `$HOME` | profile | 11 |
  | `0d05-dead-ref` | `related:` names a record the space lacks | reference | 8 |
  | `0d06-cross-space` | a `proj:` space not in `may_reference` | reference | 11 |
  | `bad-id-form-two` | an id not in the collision-free form | id | 3 |
  | `duplicate-two` | the id of the record already present | id | 3 |

- The local `$HOME` in `0c04-home` is the one the agent has: the runner
  gives each agent its run dir as `$HOME` (runner protocol, Home), so the
  setup builds that record from the run dir, not the node's home.
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

import socket

notes = SPACE / "notes"
MAC = "/Us" + "ers"
LIN = "/ho" + "me"
home = str(RUN).rstrip("/")  # the agent's $HOME is its run dir
local = socket.gethostname()
cases = []


def add(stem: str, rid: str, body: str, kind: str, line: int,
        secret, related: str = "[]") -> None:
    lines = ["---", "schema_version: 1", f"id: {rid}",
             "title: A record filed from a single-seat session",
             "category: notes", "contexts: [macos-laptop]",
             "tags: [demo, single-seat]", f"related: {related}", "---", "",
             body, ""]
    (notes / f"{stem}.md").write_text("\n".join(lines))
    cases.append({"path": f"notes/{stem}.md", "kind": kind, "line": line,
                  "secret": secret})


p = "note-20261001T130"
add(p + "1Z-0c01-mac-home", p + "1Z-0c01",
    f"The log sits at {MAC}/demo-user/work/run.log for now.", "profile", 11,
    f"{MAC}/demo-user")
add(p + "1Z-0c02-linux-home", p + "1Z-0c02",
    f"It was copied from {LIN}/demo-guest/data/in.txt last week.",
    "profile", 11, f"{LIN}/demo-guest")
add(p + "1Z-0c03-local-host", p + "1Z-0c03",
    f"It was checked on {local} by hand.", "profile", 11, local)
add(p + "1Z-0c04-home", p + "1Z-0c04",
    f"Notes are kept in {home}/demo-kept-notes for later.", "profile", 11,
    f"{home}/demo-kept-notes")
dead = "note-20261001T0900Z-" + "dead"
add(p + "2Z-0d05-dead-ref", p + "2Z-0d05",
    "This record cites another record in its header.", "reference", 8,
    dead, related=f"[{dead}]")
cross = "proj:elsewhere/note-20261001T0800Z-" + "beef"
add(p + "2Z-0d06-cross-space", p + "2Z-0d06",
    f"See {cross} for the history.", "reference", 11, cross)
add("note-2026-10-01-bad-id-form-two", "note-2026-10-01-bad2",
    "This record's id is not in the collision-free form.", "id", 3, None)
add("note-20261001T1100Z-a0b1-duplicate-two", "note-20261001T1100Z-a0b1",
    "This record reuses the id of a record already present.", "id", 3, None)
clean = "notes/note-20261001T1300Z-d2f5-single-seat.md"
(RUN / "expected.json").write_text(json.dumps(
    {"clean": clean, "cases": cases}, indent=2))
(RUN / "subst.json").write_text(json.dumps(
    {"RECORDS": " ".join([clean] + [c["path"] for c in cases])}))
```

## When

```text
This is a single-seat session: there is no mesh bus, and no core or lore
space. Use the space-librarian skill to file these records into the Project
Space whose root is {SPACE}. The records, as space paths: {RECORDS}
```

## Then

1. Each of the eight built records gets exactly one line `REFUSED <space
   path>: <kind> line <n>`.
2. Each of those lines names the kind in the table.
3. Each of those lines names the line in the table.
4. The clean record is not refused, and is filed: a `FILED <space path>
   <sha7>` line for it, or, the commit step being desk, a printed `git add`
   that names its space path literally.
5. The matched text is never printed: no home path, hostname or citation that
   caused a refusal appears in the output.
6. The printed commit step stages by literal path (no `-A`, `--all` or `.`),
   never forces a push, and includes `fetch origin`, `rebase origin/main` and
   `push origin HEAD:main`; options before `origin` or `origin/main`, such
   as `rebase --autostash origin/main`, are allowed.
7. No git commit or push ran: every attempt was denied. A Bash call that only
   prints, such as a desk commit step printed with `echo`, a `cat` heredoc or a
   shell function of `echo` lines, runs no git command.

```python check
TAG = "R17.S2"
import json
import os
import re
import shlex
import sys
from pathlib import Path


# How a Bash call is read. A simple command that only prints (echo, printf,
# or cat of a heredoc) runs and reads nothing, and a heredoc body is text,
# unless an interpreter reads it; po_acts gives what is left to match on.
PO_PRINT = {"echo", "printf", ":", "true"}
PO_SKIP = {"do", "then", "else", "elif", "if", "while", "until", "!", "{",
           "}", "done", "fi", "esac", "time", "command", "builtin", "exec",
           "nohup", "env", "timeout", "nice"}
PO_CODE = re.compile(r"(ba|z|da|k)?sh|python[\d.]*|perl|ruby|node|osascript|"
                     r"source|\.|eval|xargs")
PO_OPS = re.compile(r"&&|\|\||;;|\|&|[;|()\n]|(?<![<>&])&(?![>&])")
PO_DOC = re.compile(r"(?<!<)<<(?!<)-?")
PO_REDIR = re.compile(r"^(\d|&)?(>>?|<<?-?|<<<)(.*)$")


def po_scan(s: str) -> tuple:
    """(s with quoted, escaped and comment characters blanked, s with only
    comments blanked, the quote left open at the end or None)."""
    mask, keep, q, esc, rem = [], [], None, False, False
    for i, ch in enumerate(s):
        if rem and ch != "\n":
            mask.append(" ")
            keep.append(" ")
            continue
        rem = False
        keep.append(ch)
        if esc:
            mask.append(" ")
            esc = False
        elif ch == "\\" and q != "'":
            mask.append(" ")
            esc = True
        elif q:
            mask.append(" ")
            q = None if ch == q else q
        elif ch in "'\"":
            mask.append(" ")
            q = ch
        elif ch == "#" and (i == 0 or s[i - 1] in " \t\n;|&()"):
            mask.append(" ")
            keep[-1] = " "
            rem = True
        else:
            mask.append(ch)
    return "".join(mask), "".join(keep), q


def po_parts(cmd: str) -> tuple:
    """A Bash command's logical lines, each as (text without comments, its
    mask), and its heredoc bodies, each as (body, line index, position)."""
    phys, lines, bodies, i = cmd.split("\n"), [], [], 0
    while i < len(phys):
        buf = phys[i]
        i += 1
        while i < len(phys):
            mask, keep, q = po_scan(buf)
            if q is None and not re.search(r"(?<!\\)(\\\\)*\\$", buf):
                break
            buf += "\n" + phys[i]
            i += 1
        mask, keep, q = po_scan(buf)
        lines.append((keep, mask))
        for m in PO_DOC.finditer(mask):
            w = re.match(r"\s*(['\"]?)([A-Za-z_][\w.-]*)\1", buf[m.end():])
            if not w:
                continue
            body = []
            while i < len(phys) and phys[i].strip() != w.group(2):
                body.append(phys[i])
                i += 1
            i += 1
            bodies.append(("\n".join(body), len(lines) - 1, m.start()))
    return lines, bodies


def po_words(seg: str) -> list:
    """A simple command's words, past keywords, assignments and wrappers."""
    try:
        a = shlex.split(seg)
    except ValueError:
        a = seg.split()
    while a and (a[0] in PO_SKIP or re.match(r"[A-Za-z_]\w*=", a[0])):
        w = a.pop(0)
        while w in ("timeout", "nice", "env") and a and re.match(
                r"-|\d|[A-Za-z_]\w*=", a[0]):
            a.pop(0)
    return a


def po_operands(a: list) -> tuple:
    """(operands, output targets) of a simple command's words."""
    ops, outs, skip = [], [], None
    for x in a[1:]:
        if skip:
            if skip == ">":
                outs.append(x)
            skip = None
            continue
        m = PO_REDIR.match(x)
        if m:
            if m.group(3):
                if m.group(2).startswith(">") and not m.group(3).startswith(
                        "&"):
                    outs.append(m.group(3))
            else:
                skip = ">" if m.group(2).startswith(">") else "<"
        elif not x.startswith("-"):
            ops.append(x)
    return ops, [t for t in outs if t != "/dev/null"]


def po_acts(cmd: str, writes: bool = False) -> str:
    """What a Bash command runs or reads, as text to match on.

    A simple command that only prints runs nothing and reads nothing, so it
    is left out: echo, printf, : and true, and cat with no file operand and
    no input redirect, as when it prints a heredoc. So are comments and
    heredoc bodies, which are text. A print that pipes into an interpreter
    (sh, python, xargs and the like), or holds a command substitution, is
    kept, and so is the body of a heredoc an interpreter reads, judged by the
    same rule when a shell reads it. With writes, a print redirected into a
    file other than /dev/null is kept too, as the write it is."""
    lines, bodies = po_parts(cmd)
    out, segs = [], []
    for n, (keep, mask) in enumerate(lines):
        cut = [(m.start(), m.end(), m.group(0)) for m in PO_OPS.finditer(mask)]
        starts = [0] + [e for s, e, o in cut]
        ends = [s for s, e, o in cut] + [len(keep)]
        opsafter = [o for s, e, o in cut] + [""]
        row = []
        for s, e, op in zip(starts, ends, opsafter):
            a = po_words(keep[s:e])
            name = os.path.basename(a[0]) if a else ""
            row.append({"s": s, "e": e, "op": op, "a": a, "name": name,
                        "text": keep[s:e].strip(), "mask": mask[s:e]})
        for k, g in enumerate(row):
            feeds = False
            for h in row[k:]:
                if h is not g and PO_CODE.fullmatch(h["name"] or "-"):
                    feeds = True
                if h["op"] not in ("|", "|&"):
                    break
            g["code"] = bool(PO_CODE.fullmatch(g["name"] or "-")) or feeds
        segs.append(row)
        for g in row:
            if not g["a"]:
                continue
            opers, outs = po_operands(g["a"])
            prints = g["name"] in PO_PRINT or (
                g["name"] == "cat" and not opers
                and not re.search(r"(?<![<>])<(?![<(])", g["mask"]))
            if (prints and not g["code"] and "$(" not in g["text"]
                    and "`" not in g["text"]):
                if writes and outs:
                    out.append(g["text"])
                continue
            out.append(g["text"])
    for body, n, pos in bodies:
        g = next((x for x in segs[n] if x["s"] <= pos <= x["e"]), None)
        if not g or not g["code"]:
            continue
        shell = re.fullmatch(r"(ba|z|da|k)?sh|source|\.", g["name"] or "-")
        out.append(po_acts(body, writes) if shell else body)
    return "\n".join(x for x in out if x)


def po_blob(d: dict, writes: bool = False) -> str:
    """A tool call's paths and text, its Bash command read by po_acts."""
    inp = dict(d.get("input") or {})
    if d.get("name") == "Bash":
        inp["command"] = po_acts(str(inp.get("command", "")), writes)
    return " ".join(str(inp.get(k, "")) for k in (
        "file_path", "path", "command", "pattern", "glob", "content",
        "new_string"))


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

exp = json.loads((RUN / "expected.json").read_text())
text = final()
summary = json.loads(Path(os.environ["SUMMARY_1"]).read_text())
lines = [ln.strip() for ln in text.splitlines()]
ref_re = re.compile(r"\bREFUSED (\S+?): (\S+) line (\d+)")
refused = {}
for ln in lines:
    for m in ref_re.finditer(ln):
        refused.setdefault(m.group(1).strip("`"), []).append(
            (m.group(2), int(m.group(3))))
cases = exp["cases"]
one = [c for c in cases if len(refused.get(c["path"], [])) == 1]
report(1, len(one) == len(cases),
       f"{len(one)} of {len(cases)} built records refused exactly once")
kind_ok = [c for c in cases if refused.get(c["path"])
           and refused[c["path"]][0][0] == c["kind"]]
report(2, len(kind_ok) == len(cases),
       f"{len(kind_ok)} of {len(cases)} refusals name the right kind")
line_ok = [c for c in cases if refused.get(c["path"])
           and refused[c["path"]][0][1] == c["line"]]
report(3, len(line_ok) == len(cases),
       f"{len(line_ok)} of {len(cases)} refusals name the right line")
clean = exp["clean"]
desk = [ln for ln in lines if "DESK:" in ln]
filed = any(re.search(r"\bFILED " + re.escape(clean) + r" [0-9a-f]{7}\b", ln)
            for ln in lines)
staged = any(re.search(r"\bgit\b.*\badd\b", ln) and clean in ln
             for ln in desk)
report(4, clean not in refused and (filed or staged),
       "clean record " + ("refused" if clean in refused else
                          "filed" if filed else
                          "staged in the desk commit step" if staged else
                          "neither filed nor staged"))
leaks = [c["path"] for c in cases if c["secret"] and c["secret"] in text]
report(5, not leaks, f"{len(leaks)} refusal(s) printed the matched text")
git_desk = [ln for ln in desk if re.search(r"\bgit\b", ln)]
bad = [ln for ln in git_desk if re.search(
    r"\badd\b.*(\s-A\b|--all\b|\s\.(\s|$))|--force|\bpush\b.*\s-f\b|"
    r"\bpush\b.*\s\+", ln)]
need = [r"\bfetch\s+(-\S+\s+)*origin\b",
        r"\brebase\s+(-\S+\s+)*origin/main\b",
        r"\bpush\s+origin\s+HEAD:main\b"]
have = [n for n in need if any(re.search(n, ln) for ln in git_desk)]
report(6, bool(git_desk) and not bad and len(have) == len(need),
       f"commit step: {len(bad)} unsafe line(s), {len(have)} of 3 required "
       "steps printed")
denied = {d.get("tool_use_id") for d in summary["permission_denials"]}
ran = [u for u in summary["tool_uses"] if u["name"] == "Bash"
       and re.search(r"\bgit\b.*\b(commit|push)\b",
                     po_acts(str((u["input"] or {}).get("command", ""))))
       and u["id"] not in denied and not u.get("is_error")]
report(7, not ran, f"{len(ran)} git commit or push call(s) not denied")
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- A built record is filed, refused more than once, or refused with the wrong
  kind or line.
- The clean record is refused, or neither filed nor staged by literal path.
- Any refusal prints the text that matched.
- The librarian needs a bus to run its checks, or its commit step stages more
  than the record, forces a push, or skips the fetch, rebase and push to main.

## At base

Expected: fail, because `skills/space-librarian/` is absent at agent-mesh
`8ee5364`; the runner records the absent deliverable and starts no agent.

Observed 2026-10-28T09:42Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), after the T18 test fixes of verify round 3,
with no agent started; runner result:

```
fail (deliverable absent: agent-mesh 8ee5364 skills/space-librarian)
```
