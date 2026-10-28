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
  `notes/note-20261101T1100Z-a0b1-demo-context.md`.
- The clean record from this test's overlay,
  `notes/note-20261101T1300Z-d2f5-single-seat.md`, which also holds the
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
home = os.environ["HOME"].rstrip("/")
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


p = "note-20261101T130"
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
dead = "note-20261101T0900Z-" + "dead"
add(p + "2Z-0d05-dead-ref", p + "2Z-0d05",
    "This record cites another record in its header.", "reference", 8,
    dead, related=f"[{dead}]")
cross = "proj:elsewhere/note-20261101T0800Z-" + "beef"
add(p + "2Z-0d06-cross-space", p + "2Z-0d06",
    f"See {cross} for the history.", "reference", 11, cross)
add("note-2026-11-01-bad-id-form-two", "note-2026-11-01-bad2",
    "This record's id is not in the collision-free form.", "id", 3, None)
add("note-20261101T1100Z-a0b1-duplicate-two", "note-20261101T1100Z-a0b1",
    "This record reuses the id of a record already present.", "id", 3, None)
clean = "notes/note-20261101T1300Z-d2f5-single-seat.md"
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
   `push origin HEAD:main`.
7. No git commit or push ran: every attempt was denied.

```python check
TAG = "R17.S2"
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
need = ["fetch origin", "rebase origin/main", "push origin HEAD:main"]
have = [n for n in need if any(n in ln for ln in git_desk)]
report(6, bool(git_desk) and not bad and len(have) == len(need),
       f"commit step: {len(bad)} unsafe line(s), {len(have)} of 3 required "
       "steps printed")
denied = {d.get("tool_use_id") for d in summary["permission_denials"]}
ran = [u for u in summary["tool_uses"] if u["name"] == "Bash"
       and re.search(r"\bgit\b.*\b(commit|push)\b",
                     str((u["input"] or {}).get("command", "")))
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

Observed 2026-10-28T00:43Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), runner result:

```
fail (deliverable absent: agent-mesh 8ee5364 skills/space-librarian)
```
