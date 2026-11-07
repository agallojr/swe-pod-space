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

This is add-size-gauge's replacement of right-size-testing's
`test_I1_process_md`: at integrate it replaces the kept test of the same
name, `tests/right-size-testing/test_I1_process_md.md`, which pins the old
version line and the old size names (R12). Its checks are right-size-testing's
I1 checks unchanged, except two:

- check 2 now expects line 3 of `PROCESS.md` to be
  `process: swe-pod-process@3` (R12.S1; this change's interface contract
  §2.5);
- check 7 now expects the first column of the §9 size table to name exactly
  small, medium, large and spike (R1, R12.S2; contract §2.1).

It serves R12.S1 (check 2) and, with this change's I2 and I3, R12.S2. Its
`mode: inspect` makes it script class.

Section, contract and requirement numbers below are build-swe-pod's, except
R1, R12 and contract §2.1 and §2.5, which are this change's. The other checks
serve build-swe-pod's R1 to R6, R10 to R15, R18, R19 and R21 to R23 through
D1 (build-swe-pod's contract §2.2).

## Given

`PROCESS.md` exported read-only from swe-pod at the sha under test.

## When

```text
The runner exports PROCESS.md from swe-pod by sha and runs the check below on
it. No agent is run.
```

## Then

1. `PROCESS.md` exists at the swe-pod sha.
2. Line 1 is `# SWE Pod process` and line 3 is `process: swe-pod-process@3`
   (R12.S1).
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
7. §9 has a table whose first column names exactly the sizes small, medium,
   large and spike, one row each and no other row (contract §2.1), so a size
   table that keeps a `project` row beside them fails.
8. §10 has a table whose first column names the roles human, spec, plan,
   lead, build, test and review.

First-column cells are compared after removing `*` and backticks, ignoring
case. For check 7 only, a trailing parenthetical is also dropped, so the
contract's `small (default)` names small.

```python check
import os
import re
import sys
from pathlib import Path

TAG = "I1"
OK = []
FENCE = "`" * 3
VERSION = "process: swe-pod-process@3"
SIZES = ["small", "medium", "large", "spike"]


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


def cell(c: str) -> str:
    return c.replace("*", "").replace("`", "").strip().lower()


def first_col(table: list) -> set:
    return {cell(r[0]) for r in table if r}


def has_table(sec: list, names: set) -> bool:
    return any(names <= first_col(t) for t in tables(sec))


def size_col(table: list) -> list:
    return [re.sub(r"\s*\(.*\)\s*$", "", cell(r[0])) for r in table if r]


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
       f"line 1 and line 3 against {VERSION!r} (R12.S1); "
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
cols9 = [size_col(t) for t in tables(sec.get("9", []))]
ok7 = any(sorted(c) == sorted(SIZES) for c in cols9)
seen = "; ".join(", ".join(c) for c in cols9) or "no table"
report(7, ok7, f"section 9 size table against {', '.join(SIZES)}; "
       f"first columns found: {seen}")
report(8, has_table(sec.get("10", []),
                    {"human", "spec", "plan", "lead", "build", "test",
                     "review"}),
       "section 10 role table")
sys.exit(0 if all(OK) else 1)
```

## Fails if

- `PROCESS.md` is missing, or its line 1 differs from build-swe-pod's
  contract §2.2, or its line 3 is not `process: swe-pod-process@3` (R12.S1),
  as when the process version has not moved from `swe-pod-process@2`.
- A heading is missing, renamed, renumbered, out of order, or an extra
  level-2 heading is present.
- One of the six tables is missing from its section, or lacks a row the
  contract or spec names.
- §9 has no table whose first column is exactly small, medium, large and
  spike: as when it still names small, project and spike, when medium or
  large is missing, or when a `project` row stays beside the four.

## At base

Expected: fail on checks I1.2 and I1.7 only. At the base commit set the
process version has not moved, so line 3 is not `process: swe-pod-process@3`,
and §9's size table still has the two sizes of `swe-pod-process@2` beside
spike, so its first column lacks medium and large. Checks I1.1 and I1.3 to
I1.6 and I1.8 are right-size-testing's unchanged, and T3's done-when expects
them to pass at base.

Observed 2026-11-07T17:34Z at the base commit set (space b02a772,
swe-pod 3b22a1b; the check reads only swe-pod's `PROCESS.md`), wall time
1.5 s for this run and I2's and I3's together, runner result:

```
fail (check I1.2: line 1 and line 3 against 'process: swe-pod-process@3' (R12.S1); line 3 is 'process: swe-pod-process@2')
```

Its check output: I1.1, I1.3 to I1.6 and I1.8 pass, I1.2 and I1.7 fail, as
expected.

```
I1.1 pass PROCESS.md present at swe-pod 3b22a1b
I1.2 fail line 1 and line 3 against 'process: swe-pod-process@3' (R12.S1); line 3 is 'process: swe-pod-process@2'
I1.3 pass the 15 level-2 headings, in order
I1.4 pass section 2 stage table
I1.5 pass section 2 change-state table
I1.6 pass routing tables: section 6 has 4 rows, section 7 has 6 rows
I1.7 fail section 9 size table against small, medium, large, spike; first columns found: small, project, spike
I1.8 pass section 10 role table
```
