# T4 brief, re-review of fix round 1

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

This is the re-review after fix round 1 (T1 fix round 1/5, 61d67db..7168579):
review the fix diff only for the findings, then state Q1 over every file the
whole change alters. Your first review is changes/add-size-gauge/tasks/T4-review.md;
read its Findings. For each of its swe-pod findings (2 Important, 13 Minor)
and the T1.TS1 item (every unit that tells the lead to rule at the fix-round
cap gives the form `Ruling: T<n> open findings <what>; <why>; <cost if wrong>`
or points to PROCESS.md section 5 for it), say whether the fix diff closes it.
Mark any new disagreement your own reading finds in the fix diff, Critical,
Important or Minor, with file and line. The builder's account is the
"Fix round 1" section of changes/add-size-gauge/tasks/T1-report.md; trust the
diff over it. The two findings that name the space (plan.md:289 and the kept
test fixtures) are the lead's, ruled below; do not repeat them. Your tools
have no Write: return the full text of the review record in your final
message, from templates/records/review.md, under task number T4 with
`diff: swe-pod 61d67db..7168579`, and the lead will file it as
changes/add-size-gauge/tasks/T4-review-r1.md.

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


## Start from
- swe-pod: branch change/add-size-gauge, the fix diff from 61d67db to 7168579
  (the whole change is 3b22a1b to 7168579, for Q1)
- space: main at the commit that files this brief
- read: changes/add-size-gauge/spec.md, plan.md, tasks/T4-review.md,
  tasks/T1-report.md, ledger.md

## Result goes to
- review: changes/add-size-gauge/tasks/T4-review-r1.md (filed by the lead)
