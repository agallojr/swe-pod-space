---
scenario: R24.S1
mode: agent (lead)
deliverables: [swe-pod:agents/swe-lead.md, swe-pod:PROCESS.md as PROCESS.md, swe-pod:templates/space/AGENTS.md as AGENTS.md, swe-pod:skills/swe-pod]
fixture: demo-space
expected_s: 240
heavy: true
env: any
cap_s: 600
---

# R24.S1 Two verify shards on two nodes, both green at one commit set

Serves R24 through D1, D2 and D4, to the shard records of contract §2.4
(plan revision 4.1). Heavy: one lead run of about 4 min, so the lead asks the
operator before it runs. The lead reads the state over fixture shard
evidence; the check judges what it concludes, not its wording. The change's
own verify, run as T19a (local, on macos-laptop) and T19b (mesh, on
linux-server), is also a live instance of this scenario.

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
  | `plan.md` | T1 to T9; T7 is verify in two shards, dispatched from one space commit: T7a local on macos-laptop runs the R1 tests, the regression suite and alpha's unit suite; T7b mesh on linux-server runs the R2.S1 test and beta's unit suite |
  | `ledger.md` | the go; T1 to T6 done, with T2's fix round moving beta `e5e5e5e..f6f6f6f`; both shard briefs filed in one entry; then two dispatch lines, `dispatch T7a -> test (local, macos-laptop)` and `dispatch T7b -> test (mesh, linux-server)`, both done and their records filed; T8 review spec ok, one Minor |
  | `tasks/T7a-brief.md`, `tasks/T7b-brief.md` | the shard briefs, each starting from alpha `d4d4d4d`, beta `f6f6f6f`, gamma `c3c3c3c` and the space commit that holds them |
  | `evidence/20261101T1412Z-T7a.md` | `ev-20261101T1412Z-T7a`, `shard: T7a`, `env: macos-laptop`; tests the two R1 tests; R1.S1 pass, R1.S2 pass, unit alpha pass |
  | `evidence/20261101T1426Z-T7b.md` | `ev-20261101T1426Z-T7b`, `shard: T7b`, `env: linux-server`; tests the R2.S1 test; R2.S1 pass, unit beta pass |
  | `tasks/T8-review.md` | whole-change review, verdict pass, one Minor finding |
  | `tests/` | the three project-level tests of the change |

- Both shard records name the same commit set,
  `{space: 8b8b8b8, alpha: d4d4d4d, beta: f6f6f6f, gamma: c3c3c3c}`: the
  space commit the two shards were dispatched from, and the alpha and beta
  branch heads the ledger shows now. That is the current commit set. Every
  result in them is a pass, and both say `quality: none-declared`. Neither
  record alone covers every scenario and unit suite; together they do.
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

1. The lead counts `add-greeting` verified: its state is `verified`.
2. The ledger holds exactly two verify dispatch lines, and the answer names
   both: T7a as local on macos-laptop and T7b as mesh on linux-server.
3. The current commit set it gives has alpha `d4d4d4d` and beta `f6f6f6f`,
   and, if it names the space commit, `8b8b8b8`.
4. It names no verify run for re-running.
5. Both shard records were read with a tool (Read on the file, or a Bash or
   Grep call on the evidence folder).
6. Nothing was dispatched, filed or committed: no subagent was started for a
   pod task, no mesh command ran, no git commit or push ran, no `.git` was
   made, and the spec, the plan and both shard records are byte for byte as
   given, with no new evidence record.
7. If the run regenerated `STATUS.md`, its `## add-greeting   state:` line
   says `verified`.

```python check
import hashlib
import json
import os
import re
import sys
from pathlib import Path

TAG = "R24.S1"
OK = []
NAME = "test_R24_S1_two_shards_verified"
CHANGE = "add-greeting"
CURRENT = {"alpha": "d4d4d4d", "beta": "f6f6f6f"}
SPACE_SHA = "8b8b8b8"
SHARDS = {"T7a": ("local", "macos-laptop"), "T7b": ("mesh", "linux-server")}
EVIDENCE = ["20261101T1412Z-T7a.md", "20261101T1426Z-T7b.md"]


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


def segments(text: str) -> dict:
    """The text after each task id, up to the next task id."""
    marks = list(re.finditer(r"\bT\d+[a-z]?\b", text))
    out = {}
    for i, m in enumerate(marks):
        end = marks[i + 1].start() if i + 1 < len(marks) else len(text)
        out.setdefault(m.group(0), text[m.end():end].lower())
    return out


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
report(1, first == "verified", f"state given: {short(state)}")

ledger_p = chg / "ledger.md"
ledger = ledger_p.read_text() if ledger_p.is_file() else ""
verify_lines = re.findall(r"^\S+ dispatch T7[a-z]? -> ", ledger, re.M)
in_ledger = [s for s, (mode, env) in SHARDS.items() if re.search(
    r"^\S+ dispatch " + s + r" -> test \(" + mode + ", " + env + r"\)",
    ledger, re.M)]
seg = segments(answer(final, "VERIFY DISPATCHES") or "")
named = []
for s, (mode, env) in SHARDS.items():
    t = seg.get(s, "")
    other = "mesh" if mode == "local" else "local"
    if (re.search(r"\b" + mode + r"\b", t) and env in t
            and not re.search(r"\b" + other + r"\b", t)):
        named.append(s)
report(2, len(verify_lines) == 2 and len(in_ledger) == 2 and len(named) == 2,
       f"ledger holds {len(verify_lines)} verify dispatch lines, "
       f"{len(in_ledger)} of 2 as given; the answer names {len(named)} of 2 "
       "with the right mode and class")

cs = answer(final, "COMMIT SET") or ""
got = {r: sha_of(cs, r) for r in CURRENT}
got_space = sha_of(cs, "space")
report(3, got == CURRENT and got_space in (None, SPACE_SHA),
       "commit set given: " + ", ".join(
           f"{r} {got[r] or 'missing'}" for r in CURRENT)
       + f", space {got_space or 'not named'}")

rr = answer(final, "RERUN")
ids = sorted(set(re.findall(r"\bT\d+[a-z]?\b", rr or "")))
report(4, rr is not None and not ids,
       "no RERUN line" if rr is None else
       "re-run named: " + (", ".join(ids) if ids else "none"))


def was_read(name: str) -> bool:
    for u in uses:
        inp = u.get("input") or {}
        if u.get("name") == "Read" and str(
                inp.get("file_path", "")).endswith("evidence/" + name):
            return True
        if u.get("name") in ("Bash", "Grep") and "evidence" in json.dumps(inp):
            return True
    return False


seen = [e for e in EVIDENCE if was_read(e)]
report(5, len(seen) == len(EVIDENCE),
       f"{len(seen)} of {len(EVIDENCE)} shard records read with a tool")

denied = {d.get("tool_use_id") for d in summary.get("permission_denials")
          or []}
pod = [u for u in uses if u.get("name") in ("Agent", "Task") and (
    str((u.get("input") or {}).get("subagent_type", "")).startswith("swe-")
    or "-brief.md" in json.dumps(u.get("input") or {}))]
mesh = [u for u in uses if u.get("name") == "Bash"
        and re.search(r"mesh-post|mesh-scan-loop", command(u))]
git = [u for u in uses if u.get("name") == "Bash"
       and re.search(r"\bgit\b.*\b(commit|push)\b", command(u))
       and u.get("id") not in denied and u.get("is_error") is False]
pairs = [(chg / "spec.md", fixtures / "demo-space" / "changes" / CHANGE
          / "spec.md"), (chg / "plan.md", src / "plan.md")]
pairs += [(chg / "evidence" / e, src / "evidence" / e) for e in EVIDENCE]
changed = [a.name for a, b in pairs if digest(a) != digest(b)]
ev_dir = chg / "evidence"
extra = [p.name for p in ev_dir.iterdir()
         if p.name not in EVIDENCE] if ev_dir.is_dir() else []
dotgit = (space / ".git").exists()
report(6, not (pod or mesh or git or changed or extra or dotgit),
       f"pod dispatches {len(pod)}, mesh commands {len(mesh)}, git commits "
       f"or pushes run {len(git)}, records changed {len(changed)}, new "
       f"evidence records {len(extra)}, .git made {dotgit}")

st = space / "STATUS.md"
if st.is_file():
    m = re.search(r"^##\s+" + re.escape(CHANGE) + r"\s+state:\s*([a-z-]+)",
                  st.read_text(), re.M)
    report(7, m is None or m.group(1) == "verified",
           "STATUS.md written; " + (f"its state is {m.group(1)}" if m else
                                    "no state line for the change"))
else:
    report(7, True, "no STATUS.md written")
sys.exit(0 if all(OK) else 1)
```

## Fails if

- The lead does not count the change verified, for instance because it
  reads only the newest shard record, which alone lacks R1's results, or
  wants one record to hold every result.
- It calls the change verified without reading both shard records, or gives
  a current commit set other than the one both records name.
- Its list of verify dispatches misses a shard, or gives a shard the wrong
  mode or environment class.
- It dispatches, files or commits anything, or changes a record it read.

## At base

Expected: fail, because the deliverables are absent at swe-pod `8fc5294`;
the runner records the first absent deliverable and starts no agent.

Observed 2026-10-28T00:52Z at the base commit set (space c814837,
swe-pod 8fc5294, agent-mesh 8ee5364), runner result, with no agent started:

```
fail (deliverable absent: swe-pod 8fc5294 agents/swe-lead.md)
```

All four deliverables are absent there: `agents/swe-lead.md`, `PROCESS.md`,
`templates/space/AGENTS.md` and `skills/swe-pod`.
