# T4 brief

- change: add-size-gauge
- task: T4
- role: review
- repo: swe-pod

## Task
### T4 Whole-change review
- role: review
- after: [T1]
- runs: local
- needs: any
- done when: a review record over the spec, the plan, swe-pod's diff from
  base to head and the ledger's rulings, with Q1 stated as pass or fail

The build task you review is T1. Its plan entry:

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

For the reviewer, from T1's report (check that the builder's checks C1 to C8
and the text cover these, and say so in your review):

- T1.TS1: `PROCESS.md` (the Fix loop passage, about lines 573-590),
  `agents/swe-lead.md` (about lines 385-398), `skills/swe-pod/status-format.md`
  (the Open findings passage, about lines 212-228) and `skills/swe-pod/SKILL.md`
  (about lines 151-154). The skill closes a task's Critical and Important
  findings only on a ruling that begins `Ruling: T<n> open findings`. Check
  that every place the process tells the lead to rule at the fix-round cap
  gives that form, and that none gives another.
- T1.TS2: `PROCESS.md` (the legacy-names note, about lines 1028-1029) and
  `agents/swe-lead.md` (the Size subsection, about lines 529-533). The lead
  ruled this suggestion dropped (see Rulings); check the wording does not
  contradict that ruling.
- The builder added a ledger event `plan skimmed by <handle>` that the plan
  does not list (see Rulings). Check the ledger template, the lead's event
  forms and `PROCESS.md` agree on its form.

Also run quality check Q1 of the spec (one rule, one wording) over every
file this change alters, and state it as pass or fail.

## Interfaces
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

## Rulings
- 2026-11-07T17:29Z Ruling: every pod agent of this change is started by the lead
  with model opus set on the dispatch; the role files still say model: inherit
  until T1 changes them, and the session is not on Opus; cost if wrong: a task
  would run on the session's model, a lesser one
- 2026-11-07T17:29Z Ruling: build-swe-pod/R9 added to the spec's supersedes at
  planning, a header edit with no requirement text changed; verify can then
  give build-swe-pod/I2 superseded by I2; cost if wrong: the old I2 fails at the
  head and blocks green
- 2026-11-07T17:54Z Ruling: the ledger event plan skimmed by <handle> stays,
  though plan 2.5 did not list it; R8.S1 needs the records to tell a skimmed
  large plan from one nobody has skimmed; the skill reads it only for its time;
  cost if wrong: one ledger form to remove, no change to the skill
- 2026-11-07T17:54Z Ruling: T1.TS2 is dropped, an open spec sized under the old
  names is not given a legacy reading; the only open spec in this space is this
  one, and it integrates with the move to @3, while other spaces move their own
  pins (spec Out); cost if wrong: a spec approved as medium runs as small in
  another space after its pin moves, until the operator re-sizes it

## Start from
- swe-pod: branch change/add-size-gauge, the diff from 3b22a1b to 61d67db
- space: main at the commit that files this brief
- read: changes/add-size-gauge/spec.md, plan.md, tasks/T1-brief.md,
  tasks/T1-report.md, ledger.md

## Result goes to
- review: changes/add-size-gauge/tasks/T4-review.md, from
  templates/records/review.md in the swe-pod checkout, under task number T4
