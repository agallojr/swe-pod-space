# T1 report

- change: add-size-gauge
- task: T1
- actor: agallojr/build

## Status
DONE_WITH_CONCERNS

## What I did
- Wrote checks C1 to C8 (below) from the done-when, each one command with
  its expected output, and ran each at the base, an export of swe-pod
  3b22a1b: all eight fail, for the reasons the done-when names.
- Edited `PROCESS.md` first: line 3 to `swe-pod-process@3`; §1 pod.yaml
  example; §2 stage table and the blind-test bullet; §3 a new "Pick the
  size" subsection; §4 the plan by size, a new "The terse plan"
  subsection, the risk table, independent tests, expensive runs,
  self-review and the go with the large-size skim gate; §5 the reviews by
  size, the builder's one-line size flag, the fix loop with its cap of 2
  or 3 and the ruling at the cap, and the models passage (Opus); §6 and §7
  blind tests and verify at every size; §9 the size table of plan 2.1 and
  its four bullets (default and signs, no agent changes a size, legacy
  names, approved spec and four fresh agents); §10 independence, placement
  and single seat; §12 ledger example; §13 rulings at the cap; §14 the go
  and "make it medium" rows.
- Carried the same wording into `SPEC.md` (edited in place where it named
  the old sizes, the five-round loop or the old model rule, each place with
  an `add-size-gauge` note), the six role files (`model: opus` and the
  size, plan, review, fix-loop and go passages), the spec, plan, ledger and
  pod.yaml templates, the skill (fix-round row and the skim pointer, naming
  no size), README and INSTALL.
- Ran C1 to C8 at the commit, an export of swe-pod 61d67db: all eight
  pass. Ran the Q2 text search at the commit: the one match is the
  legacy-names note Q2 allows.
- Committed the 16 files by pathspec with both trailers, and pushed
  `change/add-size-gauge` (the remote head was already in the branch, so no
  rebase).

## Files
All in swe-pod, one commit, swe-pod 3b22a1b..61d67db:

- swe-pod/PROCESS.md: changed, the gauge, terse plan, reviews, fix cap,
  models and version @3
- swe-pod/SPEC.md: changed, the base spec's size, fix-loop and model
  statements, with notes
- swe-pod/README.md: changed, sizes, fix cap and Opus; version 3
- swe-pod/INSTALL.md: changed, Opus and the gates line
- swe-pod/agents/swe-spec.md: changed, `model: opus`; picking the size; may
  write a small or medium plan
- swe-pod/agents/swe-plan.md: changed, `model: opus`; plan length, terse
  plan, tests and reviews by size
- swe-pod/agents/swe-lead.md: changed, `model: opus`; the Go step, the skim
  line, reviews and fix loop by size, a Size subsection, ledger forms
- swe-pod/agents/swe-build.md: changed, `model: opus`; the size flag and the
  fix cap
- swe-pod/agents/swe-test.md: changed, `model: opus`; blind tests by size,
  verify at every size
- swe-pod/agents/swe-review.md: changed, `model: opus`; reviews by size
- swe-pod/templates/records/spec.md: changed, size line
  `<small|medium|large|spike>`, size comment and Open calls line
- swe-pod/templates/records/plan.md: changed, size line
  `<small|medium|large>`, the terse plan, tests and reviews by size,
  self-review items
- swe-pod/templates/records/ledger.md: changed, the `size` and
  `plan skimmed` events and the `<r>/<cap>` fix-round line
- swe-pod/templates/space/pod.yaml: changed, `swe-pod-process@3`, gates
  comment
- swe-pod/skills/swe-pod/status-format.md: changed, the fix-round row
  `fix round <r>/<cap>: <a> addressed, <o> open`
- swe-pod/skills/swe-pod/SKILL.md: changed, the fix-round line read by its
  prefix, the skim pointer in Go, naming no size

## Test output

swe-pod has no unit suite: `unit: none-present`, so the builder's tests are
the done-when checks C1 to C8.

How to run a check: in a directory `<dir>` that holds swe-pod's tracked files
at the sha under test, made with
`git -C <swe-pod> archive <sha> | tar -x -C <dir>`, run the command. Each
prints `C<n> pass` and exits 0, or `C<n> fail: <what is missing>` and exits
1. Expected at the branch head: `C<n> pass`, exit 0. Each runs in under 1 s.

### C1 to C8 at base (swe-pod 3b22a1b), red

```
C1 fail: header ['Size', 'When', 'Spec', 'Plan', 'Human gates']; first column ['small', 'project', 'spike']; spec template size line; plan template size line
exit 1
C2 fail: PROCESS.md s3 lacks ['a change is small unless its approved spec says another size', 'the size you suggest and the reason in one line under open calls', 'confirm it or name another', 'more than one repo', 'an interface or data-format change', 'well over about 3 requirements', 'a fault that would be costly or show late', 'a need for agent-class or live-class tests', 'about 3 requirements and one repo: a guide, not a cap', 'neither refuses the spec']; agents/swe-spec.md lacks ['a change is small unless its approved spec says another size', 'the size you suggest and the reason in one line under open calls', 'confirm it or name another', 'more than one repo', 'an interface or data-format change', 'well over about 3 requirements', 'a fault that would be costly or show late', 'a need for agent-class or live-class tests', 'about 3 requirements and one repo: a guide, not a cap', 'neither refuses the spec']
exit 1
C3 fail: PROCESS.md s9 lacks ['no agent changes a size', 'says so in one line to the lead', 'approval reopens for the amendment only', 'size <old> -> <new> by <handle>', 'stepping down drops the steps not yet made and keeps filed records']; agents/swe-lead.md lacks ['no agent changes a size', 'says so in one line to the lead', 'approval reopens for the amendment only', 'size <old> -> <new> by <handle>', 'stepping down drops the steps not yet made and keeps filed records']; ledger template lacks the size event
exit 1
C4 fail: Go step lacks ['for a small or medium change, that approval is the go, with no plan skim', 'for a large change, dispatch the plan task to a fresh planner', "wait for the operator's skim of plan.md"]
exit 1
C5 fail: PROCESS.md s4 lacks 3 of 3; PROCESS.md s6 lacks 3 of 3; agents/swe-plan.md lacks 3 of 3; agents/swe-test.md lacks 3 of 3
exit 1
C6 fail: section 9 Reviews column None; section 5 lacks ['a small change has one review, the whole-change review', 'a medium change has one review per wave of build tasks when it has more than one wave, and the whole-change review', 'a large change has one review per wave of build tasks, a review of each build task marked at risk, and the whole-change review', 'minor findings never start one', 'listed in the final report']
exit 1
C7 fail: no line "Not dispatched: the plan at changes/<id>/plan.md awaits the operator's skim."; Go step lacks 'for a large change whose ledger has no plan skimmed by <handle> line, dispatch nothing'; Go step lacks "not dispatched: the plan at changes/<id>/plan.md awaits the operator's skim."
exit 1
C8 fail: section 10 lacks the four different fresh agents at every size; section 9 lacks the legacy-names note
exit 1
```

In C7 the unchanged
`Not dispatched: the spec at changes/<id>/spec.md awaits approval.` line is
already present at base, so only the skim parts fail. In C8 the skill part
already holds at base (it names no size); the §10 and §9 parts fail.

### C1 to C8 at the branch head (swe-pod 61d67db), green

```
C1 pass
exit 0
C2 pass
exit 0
C3 pass
exit 0
C4 pass
exit 0
C5 pass
exit 0
C6 pass
exit 0
C7 pass
exit 0
C8 pass
exit 0
```

### Q2 text search at the branch head (a self-check, not a C check)

Command, in an export of 61d67db:
`grep -rn -i -E 'project size|small size|size: project|small\|project|fix round <r>/5|fix round [0-9]+/5|rounds 4 and 5|5 rounds|model: inherit|most capable model' --include='*.md' --include='*.yaml' --include='*.d2' .`

```
PROCESS.md:1029:  `size: project` as large; archived files are not edited.
```

The one match is the second line of the §9 legacy-names note, which Q2
allows.

### Kept script-class regression tests that read touched files, at 61d67db

Their `python check` blocks, run with `EXPORT_SWE_POD` at the export, as a
self-check. The failures are the planned ones T3 replaces:

```
right-size-testing/test_I1_process_md: I1.2 fail (expects @2; line 3 is @3), I1.7 fail (expects small, project, spike); I1.1, I1.3 to I1.6, I1.8 pass
right-size-testing/test_I3_d3_templates: I3.14 fail (expects @2 in pod.yaml); I3.1 to I3.13 pass
build-swe-pod/test_I2_role_definitions: I2.2 fail (expects model: inherit in all six); I2.1, I2.3, I2.4 pass
build-swe-pod/test_I4_swe_pod_skill: I4.1 to I4.6 pass
right-size-testing/test_R5_S1_not_selected_green: R5.S1.1 to R5.S1.4 pass
right-size-testing/test_R5_S2_superseded_with_replacement: R5.S2.1 to R5.S2.4 pass
```

### The check commands


#### C1

```
cd <dir> && python3 - <<'EOF'
# C1 (R1.S1, R11.S1): the section 9 size table, and the template size lines
import re, sys
from pathlib import Path
F = "`" * 3
def body(p):
    out, fen = [], False
    for ln in Path(p).read_text().splitlines():
        if ln.lstrip().startswith(F):
            fen = not fen
            continue
        if not fen:
            out.append(ln)
    return out
def sec(lines, n):
    out, on = [], False
    for ln in lines:
        if ln.startswith("## "):
            on = ln.split()[1] == str(n)
        elif on:
            out.append(ln)
    return out
def cells(ln):
    return [c.strip().replace("*", "").replace("`", "") for c in ln.strip().strip("|").split("|")]
rows = [cells(l) for l in sec(body("PROCESS.md"), 9) if l.strip().startswith("|")]
bad = []
head = ["Size", "When", "Spec", "Plan", "Blind tests", "Reviews", "Fix rounds", "Human gates"]
if not rows or rows[0] != head:
    bad.append(f"header {rows[0] if rows else None}")
data = [r for r in rows[2:]]
if [r[0] for r in data] != ["small (default)", "medium", "large", "spike"]:
    bad.append(f"first column {[r[0] for r in data]}")
elif [r[6] for r in data] != ["2", "3", "3", "none"]:
    bad.append(f"fix rounds column {[r[6] for r in data]}")
spec = Path("templates/records/spec.md").read_text().splitlines()
plan = Path("templates/records/plan.md").read_text().splitlines()
if "- size: <small|medium|large|spike>" not in spec:
    bad.append("spec template size line")
if "- size: <small|medium|large>" not in plan:
    bad.append("plan template size line")
print("C1 pass" if not bad else "C1 fail: " + "; ".join(bad))
sys.exit(1 if bad else 0)
EOF
```

#### C2

```
cd <dir> && python3 - <<'EOF'
# C2 (R1.S2, R2.S1 to R2.S3): the default size and the suggestion, in PROCESS.md section 3 and swe-spec
import re, sys
from pathlib import Path
F = "`" * 3
def body(p):
    out, fen = [], False
    for ln in Path(p).read_text().splitlines():
        if ln.lstrip().startswith(F):
            fen = not fen
            continue
        if not fen:
            out.append(ln)
    return out
def sec(lines, n):
    out, on = [], False
    for ln in lines:
        if ln.startswith("## "):
            on = ln.split()[1] == str(n)
        elif on:
            out.append(ln)
    return out
def norm(lines):
    return re.sub(r"\s+", " ", " ".join(lines).replace("`", "")).lower()
want = [
    "a change is small unless its approved spec says another size",
    "the size you suggest and the reason in one line under open calls",
    "confirm it or name another",
    "more than one repo",
    "an interface or data-format change",
    "well over about 3 requirements",
    "a fault that would be costly or show late",
    "a need for agent-class or live-class tests",
    "about 3 requirements and one repo: a guide, not a cap",
    "neither refuses the spec",
]
bad = []
for name, text in [("PROCESS.md s3", norm(sec(body("PROCESS.md"), 3))),
                   ("agents/swe-spec.md", norm(body("agents/swe-spec.md")))]:
    miss = [w for w in want if w not in text]
    if miss:
        bad.append(f"{name} lacks {miss}")
print("C2 pass" if not bad else "C2 fail: " + "; ".join(bad))
sys.exit(1 if bad else 0)
EOF
```

#### C3

```
cd <dir> && python3 - <<'EOF'
# C3 (R3.S1 to R3.S3): no agent changes a size, in PROCESS.md section 9, swe-lead and the ledger template
import re, sys
from pathlib import Path
F = "`" * 3
def body(p):
    out, fen = [], False
    for ln in Path(p).read_text().splitlines():
        if ln.lstrip().startswith(F):
            fen = not fen
            continue
        if not fen:
            out.append(ln)
    return out
def sec(lines, n):
    out, on = [], False
    for ln in lines:
        if ln.startswith("## "):
            on = ln.split()[1] == str(n)
        elif on:
            out.append(ln)
    return out
def norm(lines):
    return re.sub(r"\s+", " ", " ".join(lines).replace("`", "")).lower()
want = [
    "no agent changes a size",
    "says so in one line to the lead",
    "approval reopens for the amendment only",
    "size <old> -> <new> by <handle>",
    "stepping down drops the steps not yet made and keeps filed records",
]
bad = []
for name, text in [("PROCESS.md s9", norm(sec(body("PROCESS.md"), 9))),
                   ("agents/swe-lead.md", norm(body("agents/swe-lead.md")))]:
    miss = [w for w in want if w not in text]
    if miss:
        bad.append(f"{name} lacks {miss}")
led = Path("templates/records/ledger.md").read_text().splitlines()
if "<YYYY-MM-DDTHH:MMZ> size <old> -> <new> by <handle>" not in led:
    bad.append("ledger template lacks the size event")
print("C3 pass" if not bad else "C3 fail: " + "; ".join(bad))
sys.exit(1 if bad else 0)
EOF
```

#### C4

```
cd <dir> && python3 - <<'EOF'
# C4 (R4.S3): the Go step of swe-lead gives no plan skim at small and medium, and one at large
import re, sys
from pathlib import Path
F = "`" * 3
def body(p):
    out, fen = [], False
    for ln in Path(p).read_text().splitlines():
        if ln.lstrip().startswith(F):
            fen = not fen
            continue
        if not fen:
            out.append(ln)
    return out
def norm(lines):
    return re.sub(r"\s+", " ", " ".join(lines).replace("`", "")).lower()
go, on = [], False
for ln in body("agents/swe-lead.md"):
    if ln.startswith("### "):
        on = ln.strip() == "### Go"
    elif ln.startswith("## "):
        on = False
    elif on:
        go.append(ln)
text = norm(go)
want = [
    "for a small or medium change, that approval is the go, with no plan skim",
    "for a large change, dispatch the plan task to a fresh planner",
    "wait for the operator's skim of plan.md",
]
miss = [w for w in want if w not in text]
print("C4 pass" if go and not miss else f"C4 fail: Go step lacks {miss}")
sys.exit(1 if miss or not go else 0)
EOF
```

#### C5

```
cd <dir> && python3 - <<'EOF'
# C5 (R5.S1 to R5.S3): blind tests and verify by size, in PROCESS.md sections 4 and 6, swe-plan and swe-test
import re, sys
from pathlib import Path
F = "`" * 3
def body(p):
    out, fen = [], False
    for ln in Path(p).read_text().splitlines():
        if ln.lstrip().startswith(F):
            fen = not fen
            continue
        if not fen:
            out.append(ln)
    return out
def sec(lines, n):
    out, on = [], False
    for ln in lines:
        if ln.startswith("## "):
            on = ln.split()[1] == str(n)
        elif on:
            out.append(ln)
    return out
def norm(lines):
    return re.sub(r"\s+", " ", " ".join(lines).replace("`", "")).lower()
want = [
    "for a small change, a test agent writes a blind test for every scenario, from the spec alone",
    "for a medium or large change, the plan's risk table picks the requirements that get blind tests",
    "at every size, a test agent runs verify",
]
proc = body("PROCESS.md")
bad = []
for name, text in [("PROCESS.md s4", norm(sec(proc, 4))),
                   ("PROCESS.md s6", norm(sec(proc, 6))),
                   ("agents/swe-plan.md", norm(body("agents/swe-plan.md"))),
                   ("agents/swe-test.md", norm(body("agents/swe-test.md")))]:
    miss = [w for w in want if w not in text]
    if miss:
        bad.append(f"{name} lacks {len(miss)} of 3")
print("C5 pass" if not bad else "C5 fail: " + "; ".join(bad))
sys.exit(1 if bad else 0)
EOF
```

#### C6

```
cd <dir> && python3 - <<'EOF'
# C6 (R6.S1, R6.S2, R7.S1, R7.S2, R8.S2): review sets and findings, in PROCESS.md sections 5 and 9
import re, sys
from pathlib import Path
F = "`" * 3
def body(p):
    out, fen = [], False
    for ln in Path(p).read_text().splitlines():
        if ln.lstrip().startswith(F):
            fen = not fen
            continue
        if not fen:
            out.append(ln)
    return out
def sec(lines, n):
    out, on = [], False
    for ln in lines:
        if ln.startswith("## "):
            on = ln.split()[1] == str(n)
        elif on:
            out.append(ln)
    return out
def norm(lines):
    return re.sub(r"\s+", " ", " ".join(lines).replace("`", "")).lower()
def cells(ln):
    return [c.strip().replace("*", "").replace("`", "") for c in ln.strip().strip("|").split("|")]
proc = body("PROCESS.md")
bad = []
rows = [cells(l) for l in sec(proc, 9) if l.strip().startswith("|")]
col = rows[0].index("Reviews") if rows and "Reviews" in rows[0] else None
got = [r[col] for r in rows[2:5]] if col is not None else None
if got != ["the whole-change review",
           "one per wave when there is more than one wave, and the whole-change review",
           "one per wave, one per build task marked at risk, and the whole-change review"]:
    bad.append(f"section 9 Reviews column {got}")
want = [
    "a small change has one review, the whole-change review",
    "a medium change has one review per wave of build tasks when it has more than one wave, and the whole-change review",
    "a large change has one review per wave of build tasks, a review of each build task marked at risk, and the whole-change review",
    "only critical and important findings start a fix round",
    "minor findings never start one",
    "listed in the final report",
]
text = norm(sec(proc, 5))
miss = [w for w in want if w not in text]
if miss:
    bad.append(f"section 5 lacks {miss}")
print("C6 pass" if not bad else "C6 fail: " + "; ".join(bad))
sys.exit(1 if bad else 0)
EOF
```

#### C7

```
cd <dir> && python3 - <<'EOF'
# C7 (R8.S1, R9.S2): the two not-dispatched lines of swe-lead, and the large-size skim gate in its Go step
import re, sys
from pathlib import Path
raw = [l.strip() for l in Path("agents/swe-lead.md").read_text().splitlines()]
bad = []
for line in ["Not dispatched: the plan at changes/<id>/plan.md awaits the operator's skim.",
             "Not dispatched: the spec at changes/<id>/spec.md awaits approval."]:
    if line not in raw:
        bad.append(f"no line {line!r}")
go, on = [], False
for ln in Path("agents/swe-lead.md").read_text().splitlines():
    if ln.startswith("### "):
        on = ln.strip() == "### Go"
    elif ln.startswith("## "):
        on = False
    elif on:
        go.append(ln)
text = re.sub(r"\s+", " ", " ".join(go).replace("`", "")).lower()
for w in ["for a large change whose ledger has no plan skimmed by <handle> line, dispatch nothing",
          "not dispatched: the plan at changes/<id>/plan.md awaits the operator's skim."]:
    if w not in text:
        bad.append(f"Go step lacks {w!r}")
print("C7 pass" if not bad else "C7 fail: " + "; ".join(bad))
sys.exit(1 if bad else 0)
EOF
```

#### C8

```
cd <dir> && python3 - <<'EOF'
# C8 (R9.S1, R11.S2): four fresh agents in section 10, the legacy-names note in section 9, no size in the skill
import re, sys
from pathlib import Path
F = "`" * 3
def body(p):
    out, fen = [], False
    for ln in Path(p).read_text().splitlines():
        if ln.lstrip().startswith(F):
            fen = not fen
            continue
        if not fen:
            out.append(ln)
    return out
def sec(lines, n):
    out, on = [], False
    for ln in lines:
        if ln.startswith("## "):
            on = ln.split()[1] == str(n)
        elif on:
            out.append(ln)
    return out
def norm(lines):
    return re.sub(r"\s+", " ", " ".join(lines).replace("`", "")).lower()
proc = body("PROCESS.md")
bad = []
if ("at every size, the spec author, the builder, the test agent and the reviewer "
        "are four different fresh agents") not in norm(sec(proc, 10)):
    bad.append("section 10 lacks the four different fresh agents at every size")
if ("legacy names: an archived spec's size: small reads as medium and size: project "
        "as large; archived files are not edited") not in norm(sec(proc, 9)):
    bad.append("section 9 lacks the legacy-names note")
hits = []
for p in sorted(Path("skills/swe-pod").rglob("*")):
    if p.is_file():
        for i, ln in enumerate(p.read_text().splitlines(), 1):
            if re.search(r"\b(size|sizes|small|medium|large|spike)\b", ln, re.I):
                hits.append(f"{p}:{i}")
if hits:
    bad.append(f"skill names a size at {hits}")
print("C8 pass" if not bad else "C8 fail: " + "; ".join(bad))
sys.exit(1 if bad else 0)
EOF
```

## Concerns
- The §9 table's first cell reads `small (default)`, as plan 2.1 gives it.
  A check that compares first-column cells exactly, as the kept
  `right-size-testing/test_I1_process_md` check 7 does, fails on that cell
  unless it allows the `(default)` suffix. T3 writes the I1 replacement in
  parallel from the same contract, so the lead may want to check that it
  reads `small (default)` as small. I did not change the cell, since C1
  ("as in 2.1") and the contract both give it.
- Plan 2.1 names the column "Fix rounds per task" in its prose and
  "Fix rounds" in its table. I used the table's header, `Fix rounds`, and
  put one sentence under the table: the fix rounds are the cap per task (§5).
- A new ledger event, `plan skimmed by <handle>`, which plan 2.5 does not
  list. R8.S1 needs the records to tell a skimmed plan from one nobody has
  skimmed, so the lead records the operator's skim in that line, and "go" on
  a large change without the line gives
  `Not dispatched: the plan at changes/<id>/plan.md awaits the operator's skim.`
  The line is in the ledger template and in the lead's event forms. The
  skill reads it only for its time, as it reads any event it has no rule
  for. `STATUS.md` does not show it in `gates:`, and `next:` for a planned
  large change still reads "the go". Showing it there would be a later
  status-format change; this task leaves the status format alone except for
  the fix-round row. The lead may want to rule on the event's form.
- How I read "short, with the risk table" for a medium plan: every template
  section, kept short, with the risk table. The expensive-runs table is in
  every medium or large plan that lists an agent-class or live-class run, as
  before, and the large plan always has both tables. A small plan has
  neither, so the lead asks before any agent-class or live-class run a
  small change makes (§4, §11).
- Kept agent-class regression tests whose text this change makes stale:
  `tests/build-swe-pod/test_T1_TS3_single_seat_fresh_planner.md` quotes
  "spec and plan at project size" and "At project size the planner is a
  fresh agent", wording that is now gone from `SPEC.md` and `PROCESS.md`.
  Fixture specs in `test_R24_S1`, `test_R24_S2`, `test_T37_TS1`,
  `test_T7_TS1` and `test_T7_TS2` carry `size: project` on open (not
  archived) changes, which the legacy-names note does not cover. None of
  them is picked under `selection: targeted`, since they are agent class
  and the plan's test map does not name them. Integrate (§8, step 5) may
  need to move `test_T1_TS3` out as made stale, or have it updated.
- A spec approved under `swe-pod-process@2` with `size: small` that is still
  open when a space moves to @3 reads as the new small, not as medium: the
  legacy-names note covers archived specs only, as R11 states. This
  change's own spec is such a case until it integrates. See T1.TS2.
- No change was made to any project-level test.

## Test suggestions

### T1.TS1 A cap ruling the status view must read as closing the finding
- for the tester: R13.S1 and R13.S2 are at risk at the point after the cap:
  a small change whose task has an Important finding still open after fix
  round 2, and the lead's ruling on it in the ledger. When `STATUS.md` is
  regenerated, the finding may still count as open, so the change can never
  read as verified even though the ruling reached the ledger and will reach
  the final report. The risk: a ruling at the cap that the status view does
  not read as closing the finding.
- for the reviewer: swe-pod/PROCESS.md:584-586 and
  swe-pod/agents/swe-lead.md:393-395 name the form the cap ruling takes;
  swe-pod/skills/swe-pod/status-format.md:217-225 and
  swe-pod/skills/swe-pod/SKILL.md:151-154 close Critical and Important
  findings only on a ruling that begins with that prefix. A ruling at the
  cap in any other form leaves the count open.

### T1.TS2 An open change sized under the old names when the pin moves
- for the tester: R11 and R1 at the process-version boundary: a change
  that is still open, not archived, whose approved spec says `size: small`
  under the old process, read after the space's pin moves to the new
  process. It may run as the new small (terse plan, cap of 2 fix rounds, no
  risk table) although it was approved as the size now called medium. The
  spec states the legacy reading for archived specs only, so this is
  behavior the spec does not state.
- for the reviewer: swe-pod/PROCESS.md:1028-1029, the legacy-names note,
  and swe-pod/agents/swe-lead.md:529-533, the Size subsection, which reads
  the size from the spec's header with no rule for an open spec written
  under the old names.

## Fix round 1

Fix round 1 for the whole-change review T4 (2 Important, 13 Minor swe-pod
findings), the lead's four rulings that bear on it, and the coordinator's
T1.TS1 item. One commit, swe-pod 61d67db..7168579, "Fix round 1 of the
whole-change review for add-size-gauge", trailers `Change: add-size-gauge`
and `Task: T1`, pushed to `change/add-size-gauge` (the remote head was
already in the branch, so no rebase). The remote head is 7168579. Line
numbers below are at 7168579. The two findings that name the space
(plan.md:289 and the kept-test fixtures) are the lead's and were not
touched.

Status of this round: DONE. All 15 swe-pod findings are addressed and none
is left open. Two further fixes outside the findings are listed under
"Beyond the findings".

### Per finding

1. Important PROCESS.md:879 (the whole-change fix wave at small). §7 now
   has one paragraph by size (PROCESS.md:884-896), in the wording of ruling
   1. At small, the whole-change review is the one review and its findings
   run the §5 fix loop: Critical and Important only, same builder, cap 2.
   Minor findings are parked by one ruling and listed in the final report,
   and no fix wave batches them. At medium and large, the whole-change fix
   wave takes the batched Minor findings as before, and its rounds count
   toward the cap of 3. At either cap the lead rules in a line that begins
   `Ruling: T<n> open findings`. "The lead rules on what remains" is gone.
2. Important agents/swe-lead.md:424 (the same, in the lead's Whole-change
   review paragraph). The same text is at swe-lead.md:423-436, inside the
   paragraph, citing `PROCESS.md §5`.
3. Minor SPEC.md:490. The same text replaces "Its findings go to one
   builder in one fix wave ... the lead rules on what remains"
   (SPEC.md:490-500, citing §5.3).
4. Minor agents/swe-build.md:174. "Minor findings wait for the whole-change
   fix wave" is gone; the same text is a paragraph of its own
   (swe-build.md:178-188).
5. Minor templates/records/ledger.md:39. The template now lists
   `Ruling: T<n> open findings <what>; <why>; <cost if wrong>` beside the
   general form (ledger.md:43). Its comment says this is the form that
   closes the findings at a task's cap. The same line was added to the
   lead's event forms (swe-lead.md:661).
6. Minor agents/swe-lead.md:540 (the size amendment's approval). Following
   ruling 2, one sentence in the same words is at PROCESS.md §9
   (1035-1038), PROCESS.md §14's "Make it medium" row (1363),
   swe-lead.md:547-550 and swe-spec.md:117-120: "Approval reopens for the
   amendment only, and the operator's word that names the new size is its
   approval: no task is held, and no `approval reopened` line is written,
   since a size line is not a requirement." R3.S2's wording "approval
   reopens for the amendment only" is kept, so C3 still finds it.
7. Minor PROCESS.md:1030 (four agents "at every size" against the spike).
   Following ruling 3: "Every size of the gauge keeps ..." (PROCESS.md:1044),
   "At every size of the gauge, the spec author, ..." (PROCESS.md:1067) and
   README.md:33. SPEC.md:565 Independence gets the same phrase, for one
   wording. C8's phrase moves with it (see Checks).
8. Minor PROCESS.md:877 (the builder's-test check with no size). §7 now
   reads "and, in a medium or large change, that each builder's test of a
   requirement not at risk exercises its scenario (§5)" (PROCESS.md:879-881).
9. Minor PROCESS.md:1010 ("cost tables"). Following ruling 4, the large
   row reads "with the risk and expensive-runs tables" in PROCESS.md:1021
   and SPEC.md:537. No "cost table" is left in swe-pod.
10. Minor PROCESS.md:369 (the terse plan's section 6). It now keeps "the
    blind-test task and verify, and the suggestions task and the
    replacements task of a spec with `supersedes` when the change needs
    them, with no risk table and no expensive-runs table". This is in
    PROCESS.md:369-372, swe-plan.md:140-142 and the plan template's comment
    (plan.md:19-21).
11. Minor templates/records/test-brief.md:25. The Global constraints
    placeholder adds "for a terse plan, which has none: none in the plan;
    the spec is the source" (test-brief.md:25-26). The lead's prompt asked
    for this fix, so the file joins T1's files for this round.
12. Minor agents/swe-plan.md:26 (Reads). It now reads "the approved spec.
    As the fresh planner of a large change, read nothing of the
    conversation that produced it; the spec author who writes a small or
    medium plan by this definition already has that conversation"
    (swe-plan.md:26-29).
13. Minor SPEC.md:157. The stage table's build row now reads "build; the
    reviews of the change's size" and "each task passes its done-when and
    the review that covers it", as PROCESS §2 does.
14. Minor SPEC.md:558. Independence now says "started from a brief or the
    operator's request" (SPEC.md:565-569).
15. Minor PROCESS.md:334 and 1026 (unwrapped lines). §4 item 6 was
    rewrapped (PROCESS.md:325-337), and the old line 1026 went with
    ruling 2's rewrite. No line this change adds outside a table or a code
    block is over 81 chars.

The coordinator's T1.TS1 item: PROCESS.md §13's Rulings item named the cap
and gave only the general form. It now gives "At a task's fix-round cap,
rule on each open finding in a line of the form
`Ruling: T<n> open findings <what>; <why>; <cost if wrong>`, which closes it
in the status view (§5)" (PROCESS.md:1339-1341). The lead's unit was its
ledger event-forms block, which listed only the general form; item 5 adds
the cap form there. I also checked every other unit of PROCESS.md,
swe-lead.md, SPEC.md and the ledger template that tells the lead to rule at
the cap: §5 (PROCESS.md:586-588), §7 and swe-lead's fix-loop and
Whole-change review units all give the `Ruling: T<n> open findings` form,
and none gives a different one. The test itself was not edited.

### Beyond the findings

While self-checking I ran the change's own tests in
`changes/add-size-gauge/tests/` on the export. Two T2 tests of R4 failed at
61d67db on text my T1 commit wrote. Both are small fixes in T1's files, so
they are in this commit. I report them here so you can route or rule on
them.

- `test_R4_S1_terse_plan_sections` check 4: the plan template named the
  left-out sections by number only ("leave out 3, 4, 10 and Questions for
  the spec"). It now names them, "leave out 3 Global constraints, 4 File
  map, 10 Dependency summary and Questions for the spec" (plan.md:23-24),
  as PROCESS.md and swe-plan.md do.
- `test_R4_S2_terse_plan_meets_skill_rules` check 4: the two skill units I
  added that name the plan skim named no size word, so they read as if
  every change waits on the skim. Each now says the skim is where "the
  change's size calls for" it (SKILL.md:405-407 and 420-422). They still
  name no size: C8 reads size names, below.

### Checks

C6 is extended as the lead asked. It still reads §5 and §9, and now also
reads PROCESS.md §7, the lead's Whole-change review paragraph, SPEC.md and
swe-build.md, for the one wording of ruling 1. It also fails any of them
that still says the lead "rules on what remains". C8's §10 phrase follows
ruling 3, "at every size of the gauge". C8's skill test now looks for size
names only (small, medium, large, spike, "project size"), as the done-when
says ("names no size"), rather than for the word "size" too. That lets the
skill's skim units say "the change's size" for R4.S2. C1 to C5 and C7 are
unchanged from the first part. All checks run as the first part says, in an
export of the sha.

#### C6, extended, at 61d67db (red)

```
C6 fail: PROCESS.md s7 lacks 6 of 6; PROCESS.md s7 still rules on what remains with no form; agents/swe-lead.md Whole-change review lacks 6 of 6; agents/swe-lead.md Whole-change review still rules on what remains with no form; SPEC.md lacks 6 of 6; SPEC.md still rules on what remains with no form; agents/swe-build.md lacks 6 of 6
exit 1
```

#### C1 to C8 at 7168579 (green; C6 extended, C8 updated)

```
C1 pass
exit 0
C2 pass
exit 0
C3 pass
exit 0
C4 pass
exit 0
C5 pass
exit 0
C6 pass
exit 0
C7 pass
exit 0
C8 pass
exit 0
```

C8, updated, at 61d67db, for the record: it fails on its new phrase, as
it should.

```
C8 fail: section 10 lacks the four different fresh agents at every size of the gauge
exit 1
```

#### Q2 text search at 7168579

The same command as in the first part, in an export of 7168579:

```
PROCESS.md:1043:  `size: project` as large; archived files are not edited.
```

The one match is the legacy-names note Q2 allows.

#### T1.TS1 and the R4 tests with the runner

Run as `tests/build-swe-pod/README.md` says, from the space root:
`bash tests/build-swe-pod/runner.sh run changes/add-size-gauge/tests/<test>.md --python <tooling venv python> --scratch <pods scratch> --repo swe-pod=<swe-pod checkout>@<sha>`.

```
61d67db: RESULT test_T1_TS1_cap_ruling_closes_finding fail (check T1.TS1.4: status view closes on ruling: t<> open findings, ruling: t<> open findings parked: <>; <>; <>; lead's side gives it (PROCESS.md: ruling: t<> open findings); an at-cap unit gives another form, PROCESS.md: ruling: <>; <>; <> (in: - rulings. lead: when the spec supports an answer, decide and keep ...))
7168579: RESULT test_T1_TS1_cap_ruling_closes_finding pass (all 4 checks pass)
61d67db: RESULT test_R4_S1_terse_plan_sections fail (check R4.S1.4: plan template marks for a small plan: cost table, questions for the spec, risk table; missing dependency summary, file map, global constraints)
7168579: RESULT test_R4_S1_terse_plan_sections pass (all 5 checks pass)
61d67db: RESULT test_R4_S2_terse_plan_meets_skill_rules fail (check R4.S2.4: skill units naming the plan skim: 2, 2 with no size, first: where the lead's go step holds the go for the operator's skim of the plan, dispa)
7168579: RESULT test_R4_S2_terse_plan_meets_skill_rules pass (all 4 checks pass)
```

#### Other tests, as a self-check at 7168579

I ran each test's `python check` block with `EXPORT_SWE_POD` at the export:

- every test in `changes/add-size-gauge/tests/` passes: I1, I2, I3,
  R4.S1, R4.S2, R10.S1, R10.S2, R13.S1 to R13.S4 and T1.TS1;
- the kept `right-size-testing/test_I1_process_md` (checks 2 and 7),
  `right-size-testing/test_I3_d3_templates` (check 14) and
  `build-swe-pod/test_I2_role_definitions` (check 2) fail as planned,
  since T3's replacements supersede them;
- `build-swe-pod/test_I4_swe_pod_skill`,
  `right-size-testing/test_R5_S1_not_selected_green` and
  `right-size-testing/test_R5_S2_superseded_with_replacement` pass.

swe-pod has no unit suite: `unit: none-present`.

#### C6, extended

```
cd <dir> && python3 - <<'EOF'
# C6 (R6.S1, R6.S2, R7.S1, R7.S2, R8.S2, R13.S1): review sets and findings, in PROCESS.md sections 5, 7 and 9, the lead's Whole-change review paragraph, SPEC.md and swe-build
import re, sys
from pathlib import Path
F = "`" * 3
def body(p):
    out, fen = [], False
    for ln in Path(p).read_text().splitlines():
        if ln.lstrip().startswith(F):
            fen = not fen
            continue
        if not fen:
            out.append(ln)
    return out
def sec(lines, n):
    out, on = [], False
    for ln in lines:
        if ln.startswith("## "):
            on = ln.split()[1] == str(n)
        elif on:
            out.append(ln)
    return out
def para(lines, start):
    out, on = [], False
    for ln in lines:
        if ln.startswith(start):
            on = True
        elif on and not ln.strip():
            break
        if on:
            out.append(ln)
    return out
def norm(lines):
    return re.sub(r"\s+", " ", " ".join(lines).replace("`", "")).lower()
def cells(ln):
    return [c.strip().replace("*", "").replace("`", "") for c in ln.strip().strip("|").split("|")]
proc = body("PROCESS.md")
bad = []
rows = [cells(l) for l in sec(proc, 9) if l.strip().startswith("|")]
col = rows[0].index("Reviews") if rows and "Reviews" in rows[0] else None
got = [r[col] for r in rows[2:5]] if col is not None else None
if got != ["the whole-change review",
           "one per wave when there is more than one wave, and the whole-change review",
           "one per wave, one per build task marked at risk, and the whole-change review"]:
    bad.append(f"section 9 Reviews column {got}")
want5 = [
    "a small change has one review, the whole-change review",
    "a medium change has one review per wave of build tasks when it has more than one wave, and the whole-change review",
    "a large change has one review per wave of build tasks, a review of each build task marked at risk, and the whole-change review",
    "only critical and important findings start a fix round",
    "minor findings never start one",
    "listed in the final report",
]
text = norm(sec(proc, 5))
miss = [w for w in want5 if w not in text]
if miss:
    bad.append(f"section 5 lacks {miss}")
# the whole-change review's findings by size, in one wording in four places
want_wc = [
    "for a small change, the whole-change review is its one review, and its findings run the fix loop",
    "only critical and important findings start a fix round, every round goes to the same builder, and the cap is 2 rounds",
    "its minor findings are parked by one ruling and listed in the final report; no fix wave batches them",
    "for a medium or large change, the whole-change fix wave runs only when the whole-change review has a critical or important finding, and then also takes the batched minor findings",
    "its rounds count toward the cap of 3",
    "at either cap the lead rules on each open finding in a line that begins ruling: t<n> open findings",
]
places = [("PROCESS.md s7", norm(sec(proc, 7))),
          ("agents/swe-lead.md Whole-change review",
           norm(para(body("agents/swe-lead.md"), "**Whole-change review.**"))),
          ("SPEC.md", norm(body("SPEC.md"))),
          ("agents/swe-build.md", norm(body("agents/swe-build.md")))]
for name, t in places:
    miss = [w for w in want_wc if w not in t]
    if miss:
        bad.append(f"{name} lacks {len(miss)} of {len(want_wc)}")
    if "rules on what remains" in t or "rule on what remains" in t:
        bad.append(f"{name} still rules on what remains with no form")
print("C6 pass" if not bad else "C6 fail: " + "; ".join(bad))
sys.exit(1 if bad else 0)
EOF
```

#### C8, updated

```
cd <dir> && python3 - <<'EOF'
# C8 (R9.S1, R11.S2): four fresh agents in section 10, the legacy-names note in section 9, no size in the skill
import re, sys
from pathlib import Path
F = "`" * 3
def body(p):
    out, fen = [], False
    for ln in Path(p).read_text().splitlines():
        if ln.lstrip().startswith(F):
            fen = not fen
            continue
        if not fen:
            out.append(ln)
    return out
def sec(lines, n):
    out, on = [], False
    for ln in lines:
        if ln.startswith("## "):
            on = ln.split()[1] == str(n)
        elif on:
            out.append(ln)
    return out
def norm(lines):
    return re.sub(r"\s+", " ", " ".join(lines).replace("`", "")).lower()
proc = body("PROCESS.md")
bad = []
if ("at every size of the gauge, the spec author, the builder, the test agent and "
        "the reviewer are four different fresh agents") not in norm(sec(proc, 10)):
    bad.append("section 10 lacks the four different fresh agents at every size of the gauge")
if ("legacy names: an archived spec's size: small reads as medium and size: project "
        "as large; archived files are not edited") not in norm(sec(proc, 9)):
    bad.append("section 9 lacks the legacy-names note")
hits = []
for p in sorted(Path("skills/swe-pod").rglob("*")):
    if p.is_file():
        for i, ln in enumerate(p.read_text().splitlines(), 1):
            if re.search(r"\b(small|medium|large|spike)\b|project size", ln, re.I):
                hits.append(f"{p}:{i}")
if hits:
    bad.append(f"skill names a size at {hits}")
print("C8 pass" if not bad else "C8 fail: " + "; ".join(bad))
sys.exit(1 if bad else 0)
EOF
```

### Concerns for this round
- C8 now reads size names only, not the word "size". The plan's done-when
  says "names no size", and R4.S2's check 4 needs the skill's skim units to
  name a size or the word size. If you read "names no size" as also
  forbidding the word, R4.S2.4 and C8 cannot both pass, and that is a test
  to rule on.
- Ruling 1 scopes the fix-wave rule by size, so a medium change whose
  build tasks form one wave keeps the batched-Minor fix wave, though its
  whole-change review is also its one review. I wrote it as ruled.
- Ruling 3 covers the four agents only. "At every size, a test agent runs
  verify" (the C5 phrase, in PROCESS §4, §6, swe-plan, swe-test, README and
  the plan template) and "runs on Opus, at every size" are unchanged,
  though a spike has neither tests nor reviews.

### Test suggestions for this round
none
