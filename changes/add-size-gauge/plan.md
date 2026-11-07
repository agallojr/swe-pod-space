# add-size-gauge: plan

- change: add-size-gauge; spec approved 2026-11-07T17:23Z
- size: small
- planner: agallojr/lead (small size: the lead writes the plan, open call 1)
- base commit set: {space: 34cd0e2, swe-pod: 3b22a1b, agent-mesh: f27c611}
- code branches: change/add-size-gauge in swe-pod

## 1. Goal and approach

Approach 1 of the spec, with a terse plan at small (approach a). One builder
rewrites every swe-pod file that states an altered rule, in one wording (Q1),
and moves the process to `swe-pod-process@3`. R4, R10 and R13 are the
requirements at risk, so a blind test task writes their tests; every other
scenario is a check in the build task's done-when. This change runs under
`swe-pod-process@2`, as pinned (open call 1), so the pod's own risk rules
apply to it, not the new gauge.

## 2. Interface contract

"The files" means every swe-pod file that states a rule this change alters:
`PROCESS.md`, `SPEC.md`, `README.md`, `INSTALL.md`, `agents/`,
`skills/swe-pod/`, `templates/`.

### 2.1 The size table, `PROCESS.md` §9 (R1, R3, R4 to R9)

First column names `small`, `medium`, `large` and `spike`. Columns: Size,
When, Spec, Plan, Blind tests, Reviews, Fix rounds per task, Human gates.

| Size | When | Spec | Plan | Blind tests | Reviews | Fix rounds | Human gates |
|---|---|---|---|---|---|---|---|
| small (default) | one intent, about 3 requirements, one repo, low risk | short | terse; the spec author may write it | every scenario | the whole-change review | 2 | spec approval (also the go), merge |
| medium | several requirements, or one repo with moderate risk | full | short, with the risk table; the spec author may write it | requirements the plan marks at risk | one per wave when there is more than one wave, and the whole-change review | 3 | spec approval (also the go), merge |
| large | several repos, an interface or data-format change, anything costly to get wrong | full | full, by a fresh planner, with the risk and cost tables | requirements the plan marks at risk | one per wave, one per build task marked at risk, and the whole-change review | 3 | spec approval, plan skim, merge |
| spike | as today | as today | none | none | none | none | none |

The text around the table says, once each:

- A change is small unless its approved spec says another size. The spec
  author states the size it suggests and the reason in Open calls and asks
  the operator to confirm or name another (R2). The signs to suggest more
  than small: more than one repo, an interface or data-format change, well
  over about 3 requirements ("a guide, not a cap"), a fault that would be
  costly or show late, a need for agent-class or live-class tests.
- No agent changes a size. An agent that sees the change outgrow its size
  says so in one line to the lead, who tells the operator (R3). On the
  operator's word the spec's size line is amended, approval reopens for the
  amendment only, the steps the new size adds are made from there, and the
  ledger records `size <old> -> <new> by <handle>`. Stepping down drops the
  steps not yet made and keeps filed records.
- Legacy names: an archived spec's `size: small` reads as medium and
  `size: project` as large; archived files are not edited (R11).
- Every size keeps an approved spec before any build or test task, and four
  different fresh agents: spec author, builder, test agent, reviewer (R9).

### 2.2 The terse plan, small (R4)

Kept, with the section numbers of the plan template: 1 Goal; 2 Interface
contract, only where the tests drive a public surface; 5 Tasks (the one
build task); 6 Test tasks (the blind-test task, verify; no risk table, no
expensive-runs table); 7 Review tasks (the whole-change review); 8 Integrate;
9 Test map; Self-review, filled in. Left out: 3 Global constraints, 4 File
map, 10 Dependency summary, Questions for the spec. The skill's planned
state and trace read it by the rules they already have.

### 2.3 The fix loop (R6, R13)

- Cap per task: 2 at small, 3 at medium and large. Every round goes to the
  same builder; the fresh builder of rounds 4 and 5 is removed.
- Only Critical and Important findings start a round; Minor findings never
  do (`right-size-testing/R11` holds).
- At the cap the lead starts no further round, rules on each open finding in
  a `Ruling:` line (§13), and, where a finding comes from a requirement read
  two ways, sends the spec author a proposed edit: approval reopens for that
  edit only, and the tasks that serve it are held
  (`approval reopened for <Rn>; held T<a>`).
- Ledger line: `T<n> fix round <r>/<cap>: <a> addressed, <o> open,
  <sha7>..<sha7>`, with `<cap>` the cap of the change's size. The skill reads
  `T<n> fix round` by its prefix, so any cap reads the same.

### 2.4 Models (R10)

Each of the six role files has the front-matter line `model: opus`. The text
says every role, task and fix round runs on Opus at every size, never on a
lesser model to save cost, and that independence comes from a fresh session
or another node. No file says `model: inherit` or "the most capable model
available", and none ties a model to a size.

### 2.5 Names and version (R11, R12)

- `templates/records/spec.md` size line: `<small|medium|large|spike>`;
  `plan.md`: `<small|medium|large>`.
- `PROCESS.md` line 3: `process: swe-pod-process@3`;
  `templates/space/pod.yaml` gives the same.
- `templates/records/ledger.md` lists the new event
  `size <old> -> <new> by <handle>` and the fix-round line of 2.3.
- `skills/swe-pod/status-format.md` row: `fix round <r>/<cap>: <a> addressed,
  <o> open`.

## 3. Global constraints

Copied from the spec:

- Every role runs on Opus, at every size, and never on a lesser model to
  save cost (R10).
- Fix rounds cap at 2 for small and 3 for medium and large (R13).
- A small change has about 3 requirements and one repo: a guide, not a cap
  (R2).
- Names are `small`, `medium`, `large` and `spike`; `size: small` and
  `size: project` in archived specs read as medium and large (R11).
- The git gate, the sweep fence and the budget policy bind every size
  (Out).

## 4. File map

| Repo | File | Create or change | One responsibility | Task |
|---|---|---|---|---|
| swe-pod | PROCESS.md | change | §2, §3, §4, §5, §6, §9, §10, §13 and the examples state the gauge, fix loop and models; version @3 | T1 |
| swe-pod | SPEC.md | change | the base spec's size, fix-loop and model statements | T1 |
| swe-pod | README.md, INSTALL.md | change | sizes and models as above | T1 |
| swe-pod | agents/swe-*.md (6) | change | `model: opus`; the size, plan, review, fix-loop and go passages of spec, plan and lead | T1 |
| swe-pod | templates/records/spec.md, plan.md, ledger.md | change | size lines, the fix-round line, the size event | T1 |
| swe-pod | templates/space/pod.yaml | change | `swe-pod-process@3` | T1 |
| swe-pod | skills/swe-pod/status-format.md, SKILL.md | change | the fix-round row; any size name | T1 |

## 5. Tasks

### T1 The gauge, the fix cap and Opus in swe-pod
- role: build
- repo: swe-pod
- after: []
- runs: local
- needs: any
- serves: [R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13]
- risk: small: rules an agent reads in docs; a wrong word shows at the next
  change's plan or verify and costs one doc fix, and the whole-change review
  reads every file (Q1); R4, R10 and R13 are the exceptions, tested blind in
  T2
- touches: every file of the file map
- consumes: nothing
- produces: the forms of section 2
- steps: write checks C1 to C8 below, each one command with its expected
  output, and watch each fail at base; edit `PROCESS.md` first, since it is
  the source of the rules, then `SPEC.md`, `agents/`, `templates/`,
  `skills/swe-pod/`, `README.md` and `INSTALL.md` to the same wording; run
  the checks until they pass; commit with trailers `Change: add-size-gauge`
  and `Task: T1`
- done when: C1 to C8 pass at the branch head and swe-pod has no unit
  suite (`none-present`), and the review that covers it has no Critical or
  Important finding:
  - C1 (R1.S1, R11.S1): the §9 table's first column and header row are as
    in 2.1; the spec template's size line lists four names and the plan
    template's three
  - C2 (R1.S2, R2.S1 to R2.S3): `PROCESS.md` §3 and `agents/swe-spec.md`
    each say small is the default, the author states a suggested size and
    reason in Open calls, the signs of 2.1, and "about 3" with "not a cap"
  - C3 (R3.S1 to R3.S3): `PROCESS.md` §9 and `agents/swe-lead.md` each say
    no agent changes the size, the one line to the lead, amend and reopen
    approval for the amendment only, and the `size <old> -> <new>` event,
    which `templates/records/ledger.md` lists
  - C4 (R4.S3): `agents/swe-lead.md` Go step says no plan skim at small and
    medium, and a plan skim at large
  - C5 (R5.S1 to R5.S3): `PROCESS.md` §4 and §6, `agents/swe-plan.md` and
    `swe-test.md` give blind tests per scenario at small, the risk table at
    medium and large, and a test agent running verify at every size
  - C6 (R6.S1, R6.S2, R7.S1, R7.S2, R8.S2): `PROCESS.md` §5 and §9 give the
    review sets of 2.1; only Critical and Important findings start a round;
    Minor findings are listed in the final report
  - C7 (R8.S1, R9.S2): `agents/swe-lead.md` has the large-size plan-skim
    gate with a "plan awaits the operator's skim" line, and the unchanged
    `Not dispatched: the spec at changes/<id>/spec.md awaits approval.`
  - C8 (R9.S1, R11.S2): `PROCESS.md` §10 says four different fresh agents at
    every size, and §9 has the legacy-names note; `skills/swe-pod/` names no
    size

## 6. Test tasks

Risk:

| Requirement | Risk | Reason |
|---|---|---|
| R1 to R3, R5 to R9, R11, R12 | small | rules an agent reads in docs; a wrong word costs one doc fix, shows at the next change's plan or review, and the whole-change review reads every one (Q1) |
| R4 | at risk | the skill's planned state and the trace decide whether a change is verified; a terse plan that does not meet the rules they already have stalls a small change, and shows only at its first plan |
| R10 | at risk | a role file left on `inherit` runs a lesser model silently at every size, and shows only in the work's quality and cost |
| R13 | at risk | the cap and its ruling decide whether a task keeps fixing; a wrong ledger form or cap breaks the skill's reading of a round, and the cause is a spec misread |

Expensive runs (R2): none. Every test below is script class (`mode:
inspect`): no agent or live session starts, and no regression test is named
for a risk, so the selection picks script-class tests only. The script
checks expect 1 s to 5 s each, about 90 s in all.

### T2 Project-level tests of R4, R10 and R13
- role: test
- after: []
- runs: local
- needs: any
- serves: [R4, R10, R13]
- done when: one test per scenario of R4, R10 and R13 in
  `changes/add-size-gauge/tests/`, named in the test map, each script class
  with `expected_s`, `deliverables` and the risk it covers, each run at the
  base commit set and failing there for the stated reason, with its result in
  the ledger

### T3 Replace the checks that pin the old text: I1, I2, I3
- role: test
- after: []
- runs: local
- needs: any
- serves: [R12]
- done when: `changes/add-size-gauge/tests/test_I1_process_md.md`,
  `test_I2_role_definitions.md` and `test_I3_d3_templates.md`, each the
  existing test of that name with its checks unchanged but: I1, the version
  line `swe-pod-process@3` and the §9 first column small, medium, large and
  spike; I2, `model: opus`; I3, the version line in `templates/space/pod.yaml`
  and any size name the checks read; each `mode: inspect`; each run at the
  base commit set and failing there only on those checks

### T5 Verify (macos-laptop)
- role: test
- after: [T1, T2, T3, T4]
- runs: local
- needs: macos-laptop
- done when: an evidence record at the current commit set with
  `selection: targeted` and `touched:`, giving: a result for every scenario
  (R4, R10 and R13 from T2's tests, R12.S2 from T3's, the rest by rerunning
  T1's checks C1 to C8 from its report); `I1`, `I2` and `I3` from T3's tests,
  with `right-size-testing/I1`, `right-size-testing/I3` and
  `build-swe-pod/I2` given `superseded by I1`, `I3` and `I2`; a pass or
  `not-selected` for every regression test, by the selection, picking the
  script-class tests that read a touched file; `unit: {swe-pod:
  none-present}`; Q1 from T4's review; and Q2 by its text search

## 7. Review tasks

One wave of build tasks, so the whole-change review is the one review. It
covers T1, comes before verify, and runs Q1.

### T4 Whole-change review
- role: review
- after: [T1]
- runs: local
- needs: any
- done when: a review record over the spec, the plan, swe-pod's diff from
  base to head and the ledger's rulings, with Q1 stated as pass or fail

## 8. Integrate task

### T6 Integrate
- role: lead
- after: [T5, T4]
- runs: local
- needs: any
- docs: swe-pod `README.md`, `INSTALL.md`, `SPEC.md`; this space's
  `PROCESS.md` copy and `pod.yaml` (`process: swe-pod-process@3`, the swe-pod
  pin)
- open plans: none
- tests: keep the scenario tests of R4, R10 and R13 and the replacements I1,
  I2, I3; move out `tests/right-size-testing/test_I1_process_md.md`,
  `test_I3_d3_templates.md` and `tests/build-swe-pod/test_I2_role_definitions.md`
  as superseded
- done when: merged on the operator's word; kept tests promoted, superseded
  tests moved out; pins advanced; final report filed with its test cost

## 9. Test map

| Scenario | Test | Class | Risk it covers | Expected (s) | Keep | Written by | Unit tests that also cover it |
|---|---|---|---|---|---|---|---|
| R1.S1 | T1 done-when | script | small: size table in the docs (C1) | 2 | not kept: a builder's check | T1 | none |
| R1.S2 | T1 done-when | script | small: default size in the docs (C2) | 2 | not kept: a builder's check | T1 | none |
| R2.S1 | T1 done-when | script | small: suggestion with reason (C2) | 2 | not kept: a builder's check | T1 | none |
| R2.S2 | T1 done-when | script | small: signs to step up (C2) | 2 | not kept: a builder's check | T1 | none |
| R2.S3 | T1 done-when | script | small: "about 3" is a guide (C2) | 2 | not kept: a builder's check | T1 | none |
| R3.S1 | T1 done-when | script | small: agents flag, do not change (C3) | 2 | not kept: a builder's check | T1 | none |
| R3.S2 | T1 done-when | script | small: step up on the operator's word (C3) | 2 | not kept: a builder's check | T1 | none |
| R3.S3 | T1 done-when | script | small: step down on the operator's word (C3) | 2 | not kept: a builder's check | T1 | none |
| R4.S1 | test_R4_S1_terse_plan_sections | script | at risk: sections of the terse plan, kept and left out | 2 | keep | T2 | none |
| R4.S2 | test_R4_S2_terse_plan_meets_skill_rules | script | at risk: a terse plan satisfies the skill's planned and trace rules | 5 | keep | T2 | none |
| R4.S3 | T1 done-when | script | small: no skim at small and medium (C4) | 2 | not kept: a builder's check | T1 | none |
| R5.S1 | T1 done-when | script | small: blind test per scenario at small (C5) | 2 | not kept: a builder's check | T1 | none |
| R5.S2 | T1 done-when | script | small: risk table decides at medium (C5) | 2 | not kept: a builder's check | T1 | none |
| R5.S3 | T1 done-when | script | small: verify by a test agent when nothing is at risk (C5) | 2 | not kept: a builder's check | T1 | none |
| R6.S1 | T1 done-when | script | small: one review, one fix round (C6) | 2 | not kept: a builder's check | T1 | none |
| R6.S2 | T1 done-when | script | small: Minor findings start no round (C6) | 2 | not kept: a builder's check | T1 | none |
| R7.S1 | T1 done-when | script | small: reviews of two waves (C6) | 2 | not kept: a builder's check | T1 | none |
| R7.S2 | T1 done-when | script | small: reviews of one wave (C6) | 2 | not kept: a builder's check | T1 | none |
| R8.S1 | T1 done-when | script | small: plan skim gate at large (C7) | 2 | not kept: a builder's check | T1 | none |
| R8.S2 | T1 done-when | script | small: reviews of a large plan (C6) | 2 | not kept: a builder's check | T1 | none |
| R9.S1 | T1 done-when | script | small: four agents (C8) | 2 | not kept: a builder's check | T1 | none |
| R9.S2 | T1 done-when | script | small: go without approval (C7) | 2 | not kept: a builder's check | T1 | none |
| R10.S1 | test_R10_S1_role_files_model_opus | script | at risk: all six role files pin Opus | 1 | keep | T2 | none |
| R10.S2 | test_R10_S2_no_text_allows_lesser_model | script | at risk: no passage allows a lesser model or ties one to a size | 3 | keep | T2 | none |
| R11.S1 | T1 done-when | script | small: names in the templates (C1) | 2 | not kept: a builder's check | T1 | none |
| R11.S2 | T1 done-when | script | small: archived names read (C8) | 2 | not kept: a builder's check | T1 | none |
| R12.S1 | test_I1_process_md | script | small: the version line, in I1 of T3 (check 2) | 1 | keep | T3 | none |
| R12.S2 | test_I2_role_definitions | script | small: the suite expects @3, the new sizes and Opus, in I1, I2 and I3 of T3 | 3 | keep | T3 | none |
| R13.S1 | test_R13_S1_small_cap_then_ruling | script | at risk: no round past 2 at small, a ruling instead | 2 | keep | T2 | none |
| R13.S2 | test_R13_S2_large_cap_same_builder | script | at risk: no round 4 and no fresh builder | 2 | keep | T2 | none |
| R13.S3 | test_R13_S3_spec_cause_goes_to_author | script | at risk: a cap hit caused by the spec reopens approval for it | 2 | keep | T2 | none |
| R13.S4 | test_R13_S4_fix_round_line_carries_cap | script | at risk: the ledger and status forms carry the cap | 2 | keep | T2 | none |

## 10. Dependency summary

- parallel: T1, T2 and T3 start at the go
- longest chain: T1 -> T4 -> T5 -> T6
- shared files: none; T2 and T3 write only under `changes/add-size-gauge/tests/`

## Self-review
- [x] every requirement maps to a build task
- [x] every scenario maps to a test
- [x] no step says "TBD", "handle edge cases" or "add tests"
- [x] names and types agree across tasks
- [x] every task has role, after, runs and done-when
- [x] every planned test names the risk it covers
- [x] every agent- and live-class run has its wall time, spend and caps, with the totals: there is none
- [x] a live or heavy test is listed only to reproduce a reported defect and confirm its fix, or with the reason no cheaper check can show the behavior: there is none
- [x] the reviews follow section 7: one per wave, one per build task at risk, and the whole-change review: one wave, so the whole-change review only

## Questions for the spec

### (a) Answered
1. Does the terse plan keep the Global constraints and the File map? No:
   R4 lists the sections it keeps (2.2). This plan is a full-form plan only
   because it runs under `swe-pod-process@2`.
2. Which build-swe-pod test needs `superseded by`? `I2`, which pins
   `model: inherit`; spec open call 12 lists `build-swe-pod/R9` so verify
   can give it that result.

### (b) Minor, with the default planned
1. The ledger event for a size change: `size <old> -> <new> by <handle>`
   (2.1), a form this plan chose; the template and the skill's "As of" rule
   treat an unknown event as a line that counts only for its time.
2. `templates/space/pod.yaml`'s `gates:` line names the gates of large, as
   spec open call 7 says.

### (c) For the human
None.
