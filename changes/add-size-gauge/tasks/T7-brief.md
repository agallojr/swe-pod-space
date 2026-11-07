# T7 brief

- change: add-size-gauge
- task: T7
- role: test

## Task
### T7 Builder test suggestions
- role: test
- after: [T1]
- runs: local
- needs: any
- serves: [R13]
- done when: T1.TS1, routed by the lead for a risk no planned test covers
  (a cap ruling the status view must read as closing the finding), is tested
  in `changes/add-size-gauge/tests/` as a script-class test, run at the base
  commit set with its result in the ledger, or declined with a reason

## Spec
changes/add-size-gauge/spec.md

## Interface contract
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

## Global constraints
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

## Test map
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

## Start from
- base commit set: {space: b02a772, swe-pod: 3b22a1b}
- commit set under test: {space: b02a772, swe-pod: 61d67db}

## Suggestions
### T1.TS1 A cap ruling the status view must read as closing the finding
- for the tester: R13.S1 and R13.S2 are at risk at the point after the cap:
  a small change whose task has an Important finding still open after fix
  round 2, and the lead's ruling on it in the ledger. When `STATUS.md` is
  regenerated, the finding may still count as open, so the change can never
  read as verified even though the ruling reached the ledger and will reach
  the final report. The risk: a ruling at the cap that the status view does
  not read as closing the finding.

## Result goes to
- tests: changes/add-size-gauge/tests/
- at base: each new test's result at the base commit set, with its reason,
  for the ledger
- report: changes/add-size-gauge/evidence/<YYYYMMDDTHHMMZ>-T7-report.md

Do not read plan.md, ledger.md, any other brief, report or review, or any code-repo diff or implementation body.
