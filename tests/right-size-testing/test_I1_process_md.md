---
scenario: I1
mode: inspect
deliverables: [swe-pod:PROCESS.md]
fixture: none
expected_s: 1
heavy: false
env: any
cap_s: 30
---

# I1 PROCESS.md: version line, the 15 headings, the tables

This is right-size-testing's replacement of build-swe-pod's
`test_I1_process_md`: at integrate it replaces build-swe-pod's test of the
same name in `tests/build-swe-pod/` (open call 16). Its checks are
build-swe-pod's I1 checks unchanged, except the version line: check 2 now
expects line 3 of `PROCESS.md` to be `process: swe-pod-process@2`, the
process version open call 16 sets (this change's interface contract §2.11).
Its `mode: inspect` makes it script class (R13).

Section, contract and requirement numbers below are build-swe-pod's, except
open call 16. The checks serve build-swe-pod's R1 to R6, R10 to R15, R18,
R19 and R21 to R23 through D1 (build-swe-pod's contract §2.2).

## Given

`PROCESS.md` exported read-only from swe-pod at the sha under test.

## When

```text
The runner exports PROCESS.md from swe-pod by sha and runs the check below on
it. No agent is run.
```

## Then

1. `PROCESS.md` exists at the swe-pod sha.
2. Line 1 is `# SWE Pod process` and line 3 is `process: swe-pod-process@2`
   (open call 16).
3. Outside fenced blocks, its level-2 headings are exactly these 15, in this
   order: `## 1 Shape of a project`, `## 2 Stages and states`, `## 3 Spec`,
   `## 4 Plan`, `## 5 Build`, `## 6 Project-level tests`, `## 7 Verify`,
   `## 8 Integrate`, `## 9 Sizes`, `## 10 Roles`, `## 11 Dispatch`,
   `## 12 The Project Space`, `## 13 When things go wrong`,
   `## 14 Talking to the pod`, `## 15 Status view`.
4. §2 has a table whose first column names the five stages: spec, plan,
   build, verify, integrate.
5. §2 has a table whose first column names the seven change states:
   proposed, approved, planned, building, verified, integrated, abandoned.
6. §6 has a table with at least 3 data rows (where each kind of test
   suggestion goes), and §7 a table with at least 5 data rows (where each kind
   of verify failure goes).
7. §9 has a table whose first column names the sizes small, project and
   spike.
8. §10 has a table whose first column names the roles human, spec, plan,
   lead, build, test and review.

First-column cells are compared after removing `*` and backticks, ignoring
case.

```python check
import os
import sys
from pathlib import Path

TAG = "I1"
OK = []
FENCE = "`" * 3
VERSION = "process: swe-pod-process@2"


def report(n: int, ok: bool, why: str) -> None:
    OK.append(ok)
    print(f"{TAG}.{n} {'pass' if ok else 'fail'} {why}")


def body_lines(text: str) -> list:
    out, fenced = [], False
    for line in text.splitlines():
        if line.lstrip().startswith(FENCE):
            fenced = not fenced
            continue
        if not fenced:
            out.append(line)
    return out


def sections(lines: list) -> dict:
    out, cur = {}, None
    for line in lines:
        if line.startswith("## "):
            cur = line[3:].split(" ", 1)[0]
            out[cur] = []
        elif cur is not None:
            out[cur].append(line)
    return out


def tables(lines: list) -> list:
    found, cur = [], []
    for line in lines + [""]:
        if line.strip().startswith("|"):
            cur.append(line.strip())
        else:
            if len(cur) >= 2:
                rows = [r for r in cur[2:] if r.strip("|-: ")]
                found.append([[c.strip() for c in r.strip("|").split("|")]
                              for r in rows])
            cur = []
    return found


def first_col(table: list) -> set:
    return {r[0].replace("*", "").replace("`", "").strip().lower()
            for r in table if r}


def has_table(sec: list, names: set) -> bool:
    return any(names <= first_col(t) for t in tables(sec))


sha = os.environ.get("SHA_SWE_POD", "?")
p = Path(os.environ["EXPORT_SWE_POD"]) / "PROCESS.md"
if not p.is_file():
    report(1, False, f"PROCESS.md absent at swe-pod {sha}")
    sys.exit(1)
report(1, True, f"PROCESS.md present at swe-pod {sha}")
raw = p.read_text().splitlines()
line3 = raw[2] if len(raw) >= 3 else "<none>"
report(2, len(raw) >= 3 and raw[0] == "# SWE Pod process"
       and raw[2] == VERSION,
       f"line 1 and line 3 against {VERSION!r} (open call 16); "
       f"line 3 is {line3!r}")
want = ["## 1 Shape of a project", "## 2 Stages and states", "## 3 Spec",
        "## 4 Plan", "## 5 Build", "## 6 Project-level tests",
        "## 7 Verify", "## 8 Integrate", "## 9 Sizes", "## 10 Roles",
        "## 11 Dispatch", "## 12 The Project Space",
        "## 13 When things go wrong", "## 14 Talking to the pod",
        "## 15 Status view"]
lines = body_lines(p.read_text())
got = [ln.rstrip() for ln in lines if ln.startswith("## ")]
if got == want:
    report(3, True, "the 15 level-2 headings, in order")
else:
    bad = next((i for i, (a, b) in enumerate(zip(got, want)) if a != b),
               min(len(got), len(want)))
    exp = want[bad] if bad < len(want) else "no more headings"
    report(3, False, f"{len(got)} level-2 headings; first mismatch at "
           f"position {bad + 1}, expected {exp!r}")
sec = sections(lines)
report(4, has_table(sec.get("2", []),
                    {"spec", "plan", "build", "verify", "integrate"}),
       "section 2 stage table")
report(5, has_table(sec.get("2", []),
                    {"proposed", "approved", "planned", "building",
                     "verified", "integrated", "abandoned"}),
       "section 2 change-state table")
t6 = max((len(t) for t in tables(sec.get("6", []))), default=0)
t7 = max((len(t) for t in tables(sec.get("7", []))), default=0)
report(6, t6 >= 3 and t7 >= 5,
       f"routing tables: section 6 has {t6} rows, section 7 has {t7} rows")
report(7, has_table(sec.get("9", []), {"small", "project", "spike"}),
       "section 9 size table")
report(8, has_table(sec.get("10", []),
                    {"human", "spec", "plan", "lead", "build", "test",
                     "review"}),
       "section 10 role table")
sys.exit(0 if all(OK) else 1)
```

## Fails if

- `PROCESS.md` is missing, or its line 1 differs from build-swe-pod's
  contract §2.2, or its line 3 is not `process: swe-pod-process@2` (open call
  16), as when the process version has not moved from
  `swe-pod-process@1`.
- A heading is missing, renamed, renumbered, out of order, or an extra
  level-2 heading is present.
- One of the six tables is missing from its section, or lacks a row the
  contract or spec names.

## At base

Expected: fail on check I1.2 only. At the base commit set the process
version has not moved: the space's `pod.yaml` names `swe-pod-process@1`, and
open call 16 moves it to `@2` in this change. Checks I1.1 and I1.3 to I1.8
are build-swe-pod's unchanged, and T3's done-when expects them to pass at
base, where swe-pod is at its pin.

Observed 2026-10-30T16:28Z at the base commit set (space 6f1e4e0,
swe-pod b7fc257, agent-mesh f27c611; the check reads only swe-pod's
`PROCESS.md`), wall time 1 s for this run and I3's together, runner result:

```
fail (check I1.2: line 1 and line 3 against 'process: swe-pod-process@2' (open call 16); line 3 is 'process: swe-pod-process@1')
```

Its check output: I1.1 and I1.3 to I1.8 pass, I1.2 fails, as expected.

```
I1.1 pass PROCESS.md present at swe-pod b7fc257
I1.2 fail line 1 and line 3 against 'process: swe-pod-process@2' (open call 16); line 3 is 'process: swe-pod-process@1'
I1.3 pass the 15 level-2 headings, in order
I1.4 pass section 2 stage table
I1.5 pass section 2 change-state table
I1.6 pass routing tables: section 6 has 3 rows, section 7 has 5 rows
I1.7 pass section 9 size table
I1.8 pass section 10 role table
```
