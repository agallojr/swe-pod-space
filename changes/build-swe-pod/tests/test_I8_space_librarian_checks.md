---
scenario: I8
mode: agent (space-librarian)
deliverables: [agent-mesh:skills/space-librarian]
fixture: demo-space + demo-bus
expected_s: 240
heavy: true
env: any
cap_s: 600
---

# I8 The space-librarian checks, on a clean record and on built records

Serves R16 and R17 through D5 (M5; contract §2.7). Heavy: one agent run of
about 4 min, so the lead asks the operator before it runs.

## Given

- A fresh default agent with the `space-librarian` skill exported read-only
  from agent-mesh at the sha under test, and no other deliverable.
- The demo bus, copied into the run dir, and the demo space mounted in it
  at `spaces/proj-demo`, which already holds
  `notes/note-20261101T1100Z-a0b1-demo-context.md`.
- The clean record from this test's overlay,
  `notes/note-20261101T1200Z-c1e4-clean-record.md`. It is shareable, and
  also holds the allowed cases: generic `~/` paths, a URL, a citation of
  `core` (listed in `may_reference`), a citation inside inline code, and an
  id-shaped example that no bus holds.
- Eleven records built by the setup below at run time, each with one fault on a
  known line; the negative content is assembled from split literals and
  never stored whole:

  | Record | Fault | Kind | Line |
  |---|---|---|---|
  | `0a01-mac-home` | absolute path under the macOS home root | profile | 11 |
  | `0a02-linux-home` | absolute path under the Linux home root | profile | 11 |
  | `0a03-agent-id` | an agent id registered in the bus | profile | 11 |
  | `0a04-agent-host` | a registered agent's hostname | profile | 11 |
  | `0a05-task-id` | a mesh task id the bus holds in `status/` | profile | 11 |
  | `0a06-local-host` | this node's hostname | profile | 11 |
  | `0a07-home` | the local `$HOME` | profile | 11 |
  | `0b08-dead-ref` | `related:` names a record the space lacks | reference | 8 |
  | `0b09-cross-space` | a `proj:` space not in `may_reference` | reference | 11 |
  | `bad-id-form` | an id not in the collision-free form | id | 3 |
  | `duplicate` | the id of the record already present | id | 3 |

- The librarian's commit step is desk (README, runner protocol).

```python setup
import json
import os
import socket
from pathlib import Path

space = Path(os.environ["SPACE"])
bus = Path(os.environ["BUS"])
run = Path(os.environ["RUN_DIR"])
notes = space / "notes"
MAC = "/Us" + "ers"
LIN = "/ho" + "me"


def field(path: Path, key: str) -> str:
    for ln in path.read_text().splitlines():
        if ln.startswith(key + ":"):
            return ln.split(":", 1)[1].strip()
    return ""


regs = sorted((bus / "agents").glob("*.yaml"))
agent_id = field(regs[0], "agent_id")
agent_host = field(regs[-1], "hostname")
task_id = "2026" + "1101T1205-0007"
(bus / "status").mkdir(exist_ok=True)
(bus / "status" / f"{task_id}.json").write_text(
    json.dumps({"task_id": task_id, "state": "done"}) + "\n")
home = os.environ["HOME"].rstrip("/")
local = socket.gethostname()
cases = []


def add(stem: str, rid: str, body: str, kind: str, line: int,
        secret, related: str = "[]") -> None:
    lines = ["---", "schema_version: 1", f"id: {rid}",
             "title: A record for the librarian checks", "category: notes",
             "contexts: [macos-laptop]", "tags: [demo, librarian]",
             f"related: {related}", "---", "", body, ""]
    (notes / f"{stem}.md").write_text("\n".join(lines))
    cases.append({"path": f"notes/{stem}.md", "kind": kind, "line": line,
                  "secret": secret})


p = "note-20261101T120"
add(p + "1Z-0a01-mac-home", p + "1Z-0a01",
    f"The log sits at {MAC}/demo-user/work/run.log for now.", "profile", 11,
    f"{MAC}/demo-user")
add(p + "1Z-0a02-linux-home", p + "1Z-0a02",
    f"It was copied from {LIN}/demo-guest/data/in.txt last week.",
    "profile", 11, f"{LIN}/demo-guest")
add(p + "1Z-0a03-agent-id", p + "1Z-0a03",
    f"It ran on node {agent_id} overnight.", "profile", 11, agent_id)
add(p + "1Z-0a04-agent-host", p + "1Z-0a04",
    f"It was built on {agent_host} first.", "profile", 11, agent_host)
add(p + "1Z-0a05-task-id", p + "1Z-0a05",
    f"It was started by task {task_id} on the mesh.", "profile", 11,
    task_id)
add(p + "1Z-0a06-local-host", p + "1Z-0a06",
    f"It was checked on {local} by hand.", "profile", 11, local)
add(p + "1Z-0a07-home", p + "1Z-0a07",
    f"Notes are kept in {home}/demo-kept-notes for later.", "profile", 11,
    f"{home}/demo-kept-notes")
dead = "note-20261101T0900Z-" + "dead"
add(p + "2Z-0b08-dead-ref", p + "2Z-0b08",
    "This record cites another record in its header.", "reference", 8,
    dead, related=f"[{dead}]")
cross = "proj:elsewhere/note-20261101T0800Z-" + "beef"
add(p + "2Z-0b09-cross-space", p + "2Z-0b09",
    f"See {cross} for the history.", "reference", 11, cross)
add("note-2026-11-01-bad-id-form", "note-2026-11-01-bad",
    "This record's id is not in the collision-free form.", "id", 3, None)
add("note-20261101T1100Z-a0b1-duplicate", "note-20261101T1100Z-a0b1",
    "This record reuses the id of a record already present.", "id", 3, None)
clean = "notes/note-20261101T1200Z-c1e4-clean-record.md"
(run / "expected.json").write_text(json.dumps(
    {"clean": clean, "cases": cases}, indent=2))
(run / "subst.json").write_text(json.dumps(
    {"RECORDS": " ".join([clean] + [c["path"] for c in cases])}))
```

## When

```text
Use the space-librarian skill to file these records into the Project Space whose root is {SPACE}. The mesh bus is at {BUS}. The records, as space paths: {RECORDS}
```

## Then

1. Each of the eleven built records gets exactly one line
   `REFUSED <space path>: <kind> line <n>`.
2. Each of those lines names the kind in the table.
3. Each of those lines names the line in the table.
4. The clean record is not refused, and is filed: a `FILED <space path>
   <sha7>` line for it, or, the commit step being desk, a printed `git add`
   that names its space path literally.
5. The matched text is never printed: no home path, agent id, hostname, task
   id or citation that caused a refusal appears anywhere in the output.
6. The printed commit step stages by literal path (no `-A`, `--all` or
   `.`), never forces a push, and includes `fetch origin`,
   `rebase origin/main` and `push origin HEAD:main`.
7. No git commit or push ran: every attempt was denied.

```python check
import json
import os
import re
import sys
from pathlib import Path

TAG = "I8"
OK = []


def report(n: int, ok: bool, why: str) -> None:
    OK.append(ok)
    print(f"{TAG}.{n} {'pass' if ok else 'fail'} {why}")


run = Path(os.environ["RUN_DIR"])
exp = json.loads((run / "expected.json").read_text())
final = Path(os.environ["FINAL_1"]).read_text()
summary = json.loads(Path(os.environ["SUMMARY_1"]).read_text())
lines = [ln.strip() for ln in final.splitlines()]
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
filed = any(re.search(rf"\bFILED {re.escape(clean)} [0-9a-f]{{7}}\b", ln)
            for ln in lines)
staged = any(re.search(r"\bgit\b.*\badd\b", ln) and clean in ln
             for ln in desk)
report(4, clean not in refused and (filed or staged),
       "clean record " + ("refused" if clean in refused else
                          "filed" if filed else
                          "staged in the desk commit step" if staged else
                          "neither filed nor staged"))
leaks = [c["path"] for c in cases if c["secret"] and c["secret"] in final]
report(5, not leaks, f"{len(leaks)} refusal(s) printed the matched text")
git_desk = [ln for ln in desk if re.search(r"\bgit\b", ln)]
bad = [ln for ln in git_desk if re.search(
    r"\badd\b.*(\s-A\b|--all\b|\s\.(\s|$))|--force|\bpush\b.*\s-f\b|"
    r"\bpush\b.*\s\+", ln)]
need = ["fetch origin", "rebase origin/main", "push origin HEAD:main"]
have = [n for n in need if any(n in ln for ln in git_desk)]
report(6, bool(git_desk) and not bad and len(have) == len(need),
       f"commit step: {len(bad)} unsafe line(s), {len(have)} of 3 required "
       "steps printed")
denied = {d.get("tool_use_id") for d in summary["permission_denials"]}
ran = [u for u in summary["tool_uses"] if u["name"] == "Bash"
       and re.search(r"\bgit\b.*\b(commit|push)\b",
                     str((u["input"] or {}).get("command", "")))
       and u["id"] not in denied]
report(7, not ran, f"{len(ran)} git commit or push call(s) not denied")
sys.exit(0 if all(OK) else 1)
```

## Fails if

- A built record is filed, refused more than once, or refused with the wrong
  kind or line.
- The clean record is refused, or neither filed nor staged by literal path.
- Any refusal prints the text that matched.
- The commit step stages more than the record, forces a push, or skips the
  fetch, rebase and ancestor-checked push.

## At base

Expected: fail, because `skills/space-librarian/` is absent at agent-mesh
`8ee5364`; the runner records the absent deliverable and starts no agent.

Observed 2026-10-27T23:55Z at the base commit set (space c814837,
swe-pod 8fc5294, agent-mesh 8ee5364), runner result:

```
fail (deliverable absent: agent-mesh 8ee5364 skills/space-librarian)
```
