---
scenario: R24.S2
mode: agent (lead)
deliverables: [swe-pod:agents/swe-lead.md, swe-pod:PROCESS.md as PROCESS.md, swe-pod:templates/space/AGENTS.md as AGENTS.md, swe-pod:skills/swe-pod]
fixture: demo-space
expected_s: 240
heavy: true
env: any
cap_s: 600
---

# R24.S2 A shard at another commit set: not verified until it re-runs

Serves R24 through D1, D2 and D4, to the shard records of contract §2.4
(plan revision 4.1). Heavy: one lead run of about 4 min, so the lead asks the
operator before it runs. The lead reads the state over fixture shard
evidence; the check judges what it concludes, not its wording. The fixture
is the one of `test_R24_S1_two_shards_verified` with one difference in
history: both shards were dispatched before T2's fix round, T7a finished
there, T7b came back BLOCKED, and only T7b was briefed again and re-run
after the fix round moved beta.

## Given

- A fresh `swe-lead` session, with `agents/swe-lead.md` and the `swe-pod`
  skill exported read-only from swe-pod at the sha under test, and
  `PROCESS.md` and `templates/space/AGENTS.md` copied into the space as
  `PROCESS.md` and `AGENTS.md`. No instruction file reaches the agent; it
  reads the space with its tools.
- The demo space, with this test's overlay laid over its approved change
  `add-greeting` (scenarios R1.S1, R1.S2 and R2.S1; no Quality section;
  repos alpha and beta, with gamma unnamed at its pin `c3c3c3c`):

  | Space path, under `changes/add-greeting/` | What it holds |
  |---|---|
  | `plan.md` | as in R24.S1: T7a local on macos-laptop runs the R1 tests, the regression suite and alpha's unit suite; T7b mesh on linux-server runs the R2.S1 test and beta's unit suite; both dispatched from one space commit |
  | `ledger.md` | both shard briefs filed at 12:04Z, both shards dispatched at 12:05Z; T7a done and filed at 12:39Z; `T2 fix round 1/5: 1 addressed, 0 open, e5e5e5e..f6f6f6f` at 12:40Z; `T7b BLOCKED` at 12:52Z; T7b's brief filed again at 13:29Z and T7b dispatched again at 13:31Z, done and filed; T8 review spec ok, one Minor |
  | `tasks/T7a-brief.md` | starts from alpha `d4d4d4d`, beta `e5e5e5e`, gamma `c3c3c3c` |
  | `tasks/T7b-brief.md` | the later brief: alpha `d4d4d4d`, beta `f6f6f6f`, gamma `c3c3c3c` |
  | `evidence/20261001T1238Z-T7a.md` | `ev-20261001T1238Z-T7a`, `shard: T7a`, macos-laptop, at `{space: 7a7a7a7, alpha: d4d4d4d, beta: e5e5e5e, gamma: c3c3c3c}`: R1.S1 pass, R1.S2 pass, unit alpha pass |
  | `evidence/20261001T1426Z-T7b.md` | `ev-20261001T1426Z-T7b`, `shard: T7b`, linux-server, at `{space: 8b8b8b8, alpha: d4d4d4d, beta: f6f6f6f, gamma: c3c3c3c}`: R2.S1 pass, unit beta pass |
  | `tasks/T8-review.md` | whole-change review over `beta b2b2b2b..f6f6f6f`, verdict pass, one Minor finding |
  | `tests/` | the three project-level tests of the change |

- The two shard records name different commit sets. Each shard has one
  record, so it is the shard's latest. The current commit set is the branch
  heads now with the space commit holding the latest shard briefs:
  `{space: 8b8b8b8, alpha: d4d4d4d, beta: f6f6f6f, gamma: c3c3c3c}`,
  T7b's. T7a's record is out of date, although alpha, the one repo its
  tests exercise, did not move.
- Every result in both records is a pass, and the whole-change review has
  no open Critical or Important finding, so the commit sets are the only
  thing between the change and verified.
- The space copy has no git history, and the code repos and the mesh are
  not reachable from the run.

## When

```text
You are the lead of the Project Space at {SPACE}. This copy of the space has no git history, and neither the code repos nor the mesh can be reached from here, so take branch heads and commit sets from the records in the space, which you read with your tools. Do not dispatch, file or commit anything in this run.

Where does the change add-greeting stand? Is it verified?

End your answer with these four lines, filled in from the records:
STATE add-greeting: <its state>
VERIFY DISPATCHES: <each verify dispatch the ledger holds, as task id, local or mesh, and environment class, separated by semicolons>
COMMIT SET: <the change's current commit set, as repo and sha7 pairs separated by commas>
RERUN: <the task ids of any verify runs that must run again before add-greeting can count as verified, separated by commas, or none>
```

## Then

The closing lines the prompt asks for are only the test's way to read the
lead's conclusions; no phrase of the deliverables is checked. The check
reads the last line for each key, with Markdown emphasis removed.

1. The lead does not count `add-greeting` verified: its state is given, and
   it is neither `verified` nor `integrated`.
2. The verify runs it names for re-running are exactly the out-of-date
   shard, T7a; T7b is not among them.
3. The current commit set it gives has alpha `d4d4d4d` and beta `f6f6f6f`,
   not beta `e5e5e5e`, and, if it names the space commit, `8b8b8b8`, not
   `7a7a7a7`.
4. Both shard records were read with a tool (Read on the file, or a Bash or
   Grep call on the evidence folder). A Bash call that only prints
   (`echo`, `printf`, or `cat` of a heredoc) reads nothing.
5. Nothing was dispatched, filed or committed: no subagent was started for a
   pod task, no mesh command ran, no git commit or push ran, no `.git` was
   made, and the spec, the plan and both shard records are byte for byte as
   given, with no new evidence record. A Bash call that only prints
   runs nothing, so a printed desk line is not a mesh command or a
   commit that ran. In particular, T7a's record still
   names beta `e5e5e5e`.
6. If the run regenerated `STATUS.md`, its `## add-greeting   state:` line
   does not say `verified`.

```python check
import hashlib
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


TAG = "R24.S2"
OK = []
NAME = "test_R24_S2_stale_shard_not_verified"
CHANGE = "add-greeting"
CURRENT = {"alpha": "d4d4d4d", "beta": "f6f6f6f"}
SPACE_SHA = "8b8b8b8"
STALE = "T7a"
EVIDENCE = ["20261001T1238Z-T7a.md", "20261001T1426Z-T7b.md"]


def report(n: int, ok: bool, why: str) -> None:
    OK.append(ok)
    print(f"{TAG}.{n} {'pass' if ok else 'fail'} {why}")


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


def sha_of(text: str, repo: str):
    m = re.search(r"\b" + repo + r"\b\W{0,3}([0-9a-f]{7,40})\b", text, re.I)
    return m.group(1).lower()[:7] if m else None


def short(v) -> str:
    return "no such line" if v is None else repr(v[:70])


def digest(p: Path):
    return hashlib.sha256(p.read_bytes()).hexdigest() if p.is_file() else None


def command(u: dict) -> str:
    return str((u.get("input") or {}).get("command", ""))


space = Path(os.environ["SPACE"])
fixtures = Path(os.environ["TESTS_DIR"]) / "fixtures"
src = fixtures / "overlays" / NAME / "changes" / CHANGE
chg = space / "changes" / CHANGE
final = Path(os.environ["FINAL_1"]).read_text()
summary = json.loads(Path(os.environ["SUMMARY_1"]).read_text())
uses = summary.get("tool_uses") or []

state = answer(final, "STATE " + CHANGE)
first = re.match(r"[a-z-]*", (state or "").lower()).group(0)
report(1, bool(first) and first not in ("verified", "integrated"),
       f"state given: {short(state)}")

rr = answer(final, "RERUN")
ids = sorted(set(re.findall(r"\bT\d+[a-z]?\b", rr or "")))
report(2, ids == [STALE],
       "no RERUN line" if rr is None else
       "re-run named: " + (", ".join(ids) if ids else "none"))

cs = answer(final, "COMMIT SET") or ""
got = {r: sha_of(cs, r) for r in CURRENT}
got_space = sha_of(cs, "space")
report(3, got == CURRENT and got_space in (None, SPACE_SHA),
       "commit set given: " + ", ".join(
           f"{r} {got[r] or 'missing'}" for r in CURRENT)
       + f", space {got_space or 'not named'}")


def was_read(name: str) -> bool:
    for u in uses:
        inp = u.get("input") or {}
        if u.get("name") == "Read" and str(
                inp.get("file_path", "")).endswith("evidence/" + name):
            return True
        if u.get("name") == "Grep" and "evidence" in json.dumps(inp):
            return True
        if u.get("name") == "Bash" and "evidence" in po_acts(command(u)):
            return True
    return False


seen = [e for e in EVIDENCE if was_read(e)]
report(4, len(seen) == len(EVIDENCE),
       f"{len(seen)} of {len(EVIDENCE)} shard records read with a tool")

denied = {d.get("tool_use_id") for d in summary.get("permission_denials")
          or []}
pod = [u for u in uses if u.get("name") in ("Agent", "Task") and (
    str((u.get("input") or {}).get("subagent_type", "")).startswith("swe-")
    or "-brief.md" in json.dumps(u.get("input") or {}))]
mesh = [u for u in uses if u.get("name") == "Bash"
        and re.search(r"mesh-post|mesh-scan-loop", po_acts(command(u)))]
git = [u for u in uses if u.get("name") == "Bash"
       and re.search(r"\bgit\b.*\b(commit|push)\b", po_acts(command(u)))
       and u.get("id") not in denied and u.get("is_error") is False]
pairs = [(chg / "spec.md", fixtures / "demo-space" / "changes" / CHANGE
          / "spec.md"), (chg / "plan.md", src / "plan.md")]
pairs += [(chg / "evidence" / e, src / "evidence" / e) for e in EVIDENCE]
changed = [a.name for a, b in pairs if digest(a) != digest(b)]
ev_dir = chg / "evidence"
extra = [p.name for p in ev_dir.iterdir()
         if p.name not in EVIDENCE] if ev_dir.is_dir() else []
dotgit = (space / ".git").exists()
report(5, not (pod or mesh or git or changed or extra or dotgit),
       f"pod dispatches {len(pod)}, mesh commands {len(mesh)}, git commits "
       f"or pushes run {len(git)}, records changed {len(changed)}, new "
       f"evidence records {len(extra)}, .git made {dotgit}")

st = space / "STATUS.md"
if st.is_file():
    m = re.search(r"^##\s+" + re.escape(CHANGE) + r"\s+state:\s*([a-z-]+)",
                  st.read_text(), re.M)
    report(6, m is None or m.group(1) != "verified",
           "STATUS.md written; " + (f"its state is {m.group(1)}" if m else
                                    "no state line for the change"))
else:
    report(6, True, "no STATUS.md written")
sys.exit(0 if all(OK) else 1)
```

## Fails if

- The lead counts the change verified, for instance because T7a's results
  look still good when only beta moved, or because each shard record is
  green on its own.
- It names T7b, both shards, or no shard for re-running, or takes beta
  `e5e5e5e` or space `7a7a7a7` for current.
- It dispatches the re-run, files or commits anything, or edits a shard
  record so that the stale shard looks current.

## At base

Expected: fail, because the deliverables are absent at swe-pod `8fc5294`;
the runner records the first absent deliverable and starts no agent.

Observed 2026-10-28T09:42Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), after the T18 test fixes of verify round 3,
with no agent started; runner result:

```
fail (deliverable absent: swe-pod 8fc5294 agents/swe-lead.md)
```

All four deliverables are absent there: `agents/swe-lead.md`, `PROCESS.md`,
`templates/space/AGENTS.md` and `skills/swe-pod`.
