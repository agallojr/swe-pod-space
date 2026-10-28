---
scenario: I4
mode: inspect
deliverables: [swe-pod:skills/swe-pod]
fixture: none
expected_s: 1
heavy: false
env: any
cap_s: 30
---

# I4 The swe-pod skill against contract §2.6

Serves R18 and R20 through D4.

## Given

`skills/swe-pod/` exported read-only from swe-pod at the sha under test.

## When

```text
The runner exports skills/swe-pod from swe-pod by sha and runs the check
below on it. No agent is run.
```

## Then

1. `skills/swe-pod/SKILL.md` and `skills/swe-pod/status-format.md` exist.
2. `SKILL.md` front-matter has `name: swe-pod` and a non-empty
   `description:` that says when to invoke it (it names the status, "go" and
   the traceability check) and gives no standing rule (no "always", "must",
   "every session" or "every turn").
3. `status-format.md` holds each of these lines exactly, as a whole line:
   - `# Status: <space id>`
   - `Generated from the records; never edited by hand. As of <UTC of the newest ledger line or record>.`
   - `- pins: <repo> <sha7>, ...`
   - `- open changes: <n> (<state>: <k>, ...)`
   - `## <id>   state: <state>   owner: <handle>`
4. `status-format.md` gives the per-change bullets: gates, branches, a task
   table whose header names task, role, runs, state and latest in that
   order, the latest evidence, open findings as
   `Critical <n>, Important <n>, Minor <n>`, and `next:`.
5. `status-format.md` names the task states waiting, ready, dispatched, done
   and blocked.
6. `SKILL.md` or `status-format.md` holds the trace output forms exactly:
   `TRACE <change id>: <n> breaks`, `BREAK requirement-without-task <Rn>`,
   `BREAK scenario-without-test <Rn.Sm>`, `BREAK task-without-commit T<n>`,
   `BREAK test-without-evidence <test name>` and
   `BREAK evidence-stale <ev id>`.

```python check
import os
import re
import sys
from pathlib import Path

TAG = "I4"
OK = []
EXACT = [
    "# Status: <space id>",
    "Generated from the records; never edited by hand. As of <UTC of the "
    "newest ledger line or record>.",
    "- pins: <repo> <sha7>, ...",
    "- open changes: <n> (<state>: <k>, ...)",
    "## <id>   state: <state>   owner: <handle>",
]
TRACE = [
    "TRACE <change id>: <n> breaks",
    "BREAK requirement-without-task <Rn>",
    "BREAK scenario-without-test <Rn.Sm>",
    "BREAK task-without-commit T<n>",
    "BREAK test-without-evidence <test name>",
    "BREAK evidence-stale <ev id>",
]


def report(n: int, ok: bool, why: str) -> None:
    OK.append(ok)
    print(f"{TAG}.{n} {'pass' if ok else 'fail'} {why}")


def strip_md(line: str) -> str:
    s = line.strip()
    if s.startswith("`") and s.endswith("`") and s.count("`") == 2:
        s = s[1:-1]
    return s.rstrip()


sha = os.environ.get("SHA_SWE_POD", "?")
root = Path(os.environ["EXPORT_SWE_POD"]) / "skills" / "swe-pod"
skill, fmt = root / "SKILL.md", root / "status-format.md"
miss = [p.name for p in (skill, fmt) if not p.is_file()]
report(1, not miss, f"swe-pod {sha}: " + (
    "SKILL.md and status-format.md present" if not miss else
    "absent: skills/swe-pod/" + ", skills/swe-pod/".join(miss)))
st = skill.read_text() if skill.is_file() else ""
ft = fmt.read_text() if fmt.is_file() else ""
m = re.match(r"---\n(.*?)\n---", st, re.S)
fm = m.group(1) if m else ""
name = re.search(r"^name:\s*(\S+)", fm, re.M)
desc = re.search(r"^description:\s*(.+)$", fm, re.M)
d = desc.group(1).lower() if desc else ""
when_ok = ("status" in d and re.search(r"\bgo\b", d) is not None
           and "trace" in d)
rule_free = not re.search(r"\b(always|must)\b|every session|every turn", d)
report(2, bool(name) and name.group(1) == "swe-pod" and bool(d)
       and when_ok and rule_free,
       "front-matter name, and a description that says when and sets no "
       "standing rule")
lines = {strip_md(ln) for ln in ft.splitlines()}
miss3 = [i + 1 for i, e in enumerate(EXACT) if e not in lines]
report(3, bool(ft) and not miss3, "exact STATUS.md lines: " + (
    "all present" if not miss3 else
    "missing line(s) " + ", ".join(map(str, miss3))))
low = ft.lower()
table = any(re.search(r"\|\s*task\s*\|\s*role\s*\|\s*runs\s*\|\s*state\s*"
                      r"\|\s*latest\s*\|", ln.lower())
            for ln in ft.splitlines())
ok4 = (bool(ft) and "gate" in low and "branch" in low and table
       and "evidence" in low
       and "Critical <n>, Important <n>, Minor <n>" in ft and "next:" in ft)
report(4, ok4, "per-change bullets and task table")
report(5, bool(ft) and all(re.search(rf"\b{s}\b", low) for s in (
    "waiting", "ready", "dispatched", "done", "blocked")),
    "task states named")
both = {strip_md(ln) for ln in (st + "\n" + ft).splitlines()}
miss6 = [t for t in TRACE if t not in both]
report(6, bool(st or ft) and not miss6, "trace forms: " + (
    "all present" if not miss6 else f"{len(miss6)} missing"))
sys.exit(0 if all(OK) else 1)
```

## Fails if

- The skill or its status format is missing, or misnamed.
- The description sets a standing rule, or does not say when to invoke the
  skill.
- An exact STATUS.md line or trace form differs by any character, or a
  per-change bullet, the task table or a task state is missing.

## At base

Expected: fail, because `skills/swe-pod/` is absent at swe-pod `8fc5294`.

Observed 2026-10-27T23:55Z at the base commit set (space c814837,
swe-pod 8fc5294, agent-mesh 8ee5364), runner result:

```
fail (check I4.1: swe-pod 8fc5294: absent: skills/swe-pod/SKILL.md, skills/swe-pod/status-format.md)
```
