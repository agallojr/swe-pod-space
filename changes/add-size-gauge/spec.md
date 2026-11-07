# add-size-gauge: the pod runs light by default, and moves up in process weight only when the operator says

- size: small
- owner: agallojr
- repos: [swe-pod]
- supersedes: [right-size-testing/R6, right-size-testing/R10, right-size-testing/R15, build-swe-pod/R9]
- approved: agallojr 2026-11-07T17:23Z

## Why

In short, after this change:

- Every change has a size, small, medium or large, and the default is
  small: a low-risk change with a lightweight process and review.
- Size sets how much process runs: how long the plan is, how many reviews,
  and which gates the operator passes. It moves up (or down) only on the
  operator's word. The spec author may suggest a size, and no other agent
  changes it.
- Every size keeps a spec the operator approves, a plan (terse at small),
  and spec, build and test in three different agents. The testing agent is
  never the one that wrote the spec or the code.
- A task gets at most 3 fix rounds at any size, 2 at small. A task that
  needs more means the spec was not understood, so the lead goes back to the
  spec instead of fixing again.
- Every role runs on Opus, at every size. Weight comes off the process, never
  off the model.

The operator, 2026-11-07: "i want to make a change to swe-pod. i want to
make it lighter. in other words, i want its default to be a low risk model,
with lightweight process and review, and to move up to more complex / costly
only when directed. low -> medium -> high, small -> medium -> large. i want
specs, and i want build separate from spec, and test separate from spec and
build, and I don't want to use dumb models - i presently like opus for dev
work." On the first draft of the gauge: "'at most 3 requirements' - make
this softer 'about 3' - also add that the spec writer can suggest a sizing."
On the second: "i always want a plan even if its terse. 5 fix rounds is a
lot even for a project. it means the spec is not understood. cap at 3."

Today the process has two sizes, small and project, and the lightest one
still has a plan with a risk table, a review per wave and up to 5 fix rounds
per task (`PROCESS.md` §4, §5, §9). Earlier work already cut test and review
cost per change by directive and ruling, and then by the
`right-size-testing` change (its Why section holds the recorded costs, in
`changes/archive/2026-10-30-right-size-testing/spec.md`). That change
made risk, not size, decide independent tests. This one adds the missing
lower tier and makes size the dial for the rest of the process.

## Scope

In:

- A three-tier gauge, small, medium, large, with small the default, and
  what each tier runs: spec, plan, build, test, verify, review, human gates
  (`PROCESS.md` §2, §4, §5, §7, §9).
- The fix loop: a cap of 3 rounds per task at any size (2 at small), all
  rounds to the same builder, and what the lead does at the cap
  (`PROCESS.md` §5, §13; the lead role; the ledger template's fix-round line
  and the status format, which now give the cap of the change's size).
- Who suggests a size and who changes it (`PROCESS.md` §3, §9; the spec
  author and lead roles).
- A terse plan at small: which plan sections a small change leaves out
  (`PROCESS.md` §4; the plan template; the planner role).
- Every role on Opus: the model lines of the six role definitions and the
  model passages of `PROCESS.md` §5 and §10, README and INSTALL.
- The size names in the spec and plan templates, the role definitions that
  mention a size, README, INSTALL, and the product spec `SPEC.md` (updated at
  integrate).
- The process version, `PROCESS.md` line 3, and the kept tests that pin the
  old text: `tests/right-size-testing/test_I1_process_md.md` (the version line
  and the size names) and `tests/build-swe-pod/test_I2_role_definitions.md`
  (the model line). The plan also checks the other kept tests that name a
  size or the fix-round cap, such as `test_T1_TS3_single_seat_fresh_planner.md`,
  for text the change makes stale.

Out:

- Spike: it stays as it is, outside the gauge.
- A different model per role, or per tier. Opus is the one model of this
  change.
- The git gate, the sweep fence and the budget policy, which bind every size.
- Other Project Spaces' `PROCESS.md` copies and pins, and agent-mesh.
- Any rule that scores a change and picks its size by formula. The spec
  author uses judgment and says why.
- Re-sizing archived specs: their `size:` lines stay as written.

## Requirements

### R1 Three sizes on one gauge, small by default
`PROCESS.md` SHALL define the sizes small, medium and large, with spike
outside the gauge, and make a change small unless its approved spec says
another size.

#### R1.S1 The size table
- GIVEN `PROCESS.md` §9 at the branch head
- WHEN its size table is read
- THEN its first column names small, medium, large and spike, and for each of
  the first three it gives the spec, the plan, the reviews, the fix-round cap
  and the human gates

#### R1.S2 A request that names no size
- GIVEN an operator request that says nothing of size, and nothing in it
  that R2.S2 lists
- WHEN the spec author writes the spec
- THEN the spec's size line reads small

### R2 The spec author suggests a size, and the operator sets it
The spec author SHALL state in the spec the size it suggests and the reason,
and the size stands as the operator approves it or names another. A small
change has about 3 requirements and one repo; that is a guide, not a cap.

#### R2.S1 A suggestion with its reason
- GIVEN a request to add one option to one command in one repo, which
  changes no interface another tool reads
- WHEN the spec is drafted
- THEN the size line reads small, the Open calls give the reason in a line,
  and the spec asks the operator to confirm or name another size

#### R2.S2 A suggestion to step up
- GIVEN a request that changes a file format two repos read
- WHEN the spec is drafted
- THEN the size line reads medium or large with the reason in Open calls
  (more than one repo, an interface or data-format change, costly to get
  wrong, or needing agent-class or live-class tests), and the operator may
  name a smaller size, which then stands

#### R2.S3 About 3 is not a cap
- GIVEN a low-risk request in one repo that needs 5 requirements
- WHEN the spec is drafted
- THEN the spec author may keep it small and says in Open calls that it is
  over the guide of about 3, or may suggest medium; neither refuses the
  spec

### R3 Size changes only on the operator's word
No agent SHALL change a change's size. An agent that sees the change outgrow
its size says so in one line to the lead, who tells the operator; the size
and the process move when the operator names a new one.

#### R3.S1 A builder finds the change is bigger
- GIVEN an approved small change whose builder finds it must also change a
  second repo
- WHEN the builder reports
- THEN the report says so in one line, the lead tells the operator, and no
  plan section, review or gate is added until the operator names a larger
  size

#### R3.S2 Stepping up mid-flight
- GIVEN an approved small change with one build task done, and the operator
  says "make it medium"
- WHEN the lead acts
- THEN the spec's size line is amended and approval reopens for the amendment
  only; the plan sections and reviews medium adds are made from that point;
  the done build task and its commits stand; and the ledger records the new
  size

#### R3.S3 Stepping down
- GIVEN a large change before its go, and the operator says "make it small"
- WHEN the lead acts
- THEN the size line is amended on the operator's word, the steps small
  drops (the full plan, the plan skim) are not made, and records already
  filed stay

### R4 A small change has a terse plan
Every size SHALL have a `plan.md`, terse for a small change: the goal in a
sentence or two, the interface contract only where the tests drive a public
surface, its one build task with its done-when, its test and review tasks,
the test map, and a filled-in self-review, with no risk table, dependency
summary or cost table. The spec author may write it, and the operator does
not skim it.

#### R4.S1 The plan of an approved small spec
- GIVEN an approved small spec of 3 requirements in one repo
- WHEN its plan is written
- THEN `plan.md` holds the sections above and none of the three left out,
  has a row in its test map for every scenario, and its self-review is filled
  in with no unchecked item

#### R4.S2 The skill reads a small change
- GIVEN the space of R4.S1 before the dispatch, and again after the build
  task reports
- WHEN `STATUS.md` is regenerated
- THEN the change reads as planned, and then as building, by the rules every
  size shares, and the trace prints no break

#### R4.S3 No plan skim
- GIVEN the plan of R4.S1 and an approved spec
- WHEN the operator says go, or the approval is the go
- THEN the lead dispatches the build task without asking for a skim

### R5 Every size has a test agent separate from spec and build
Every size SHALL have its tests written, and verify run, by a test agent that
is neither the spec author nor a builder. At small it writes a blind test for
each scenario, from the spec alone; at medium and large the plan's risk
table picks the requirements that get blind tests, as
`right-size-testing/R6` has it, and the test agent still runs verify.

#### R5.S1 Small: a blind test per scenario
- GIVEN an approved small spec with 3 requirements and 5 scenarios
- WHEN the lead dispatches testing
- THEN the test brief covers all 5 scenarios and holds nothing of the build,
  each new-behavior test is run at base and fails there, and verify runs the
  tests with the repo's unit suite

#### R5.S2 Medium: the risk table decides
- GIVEN an approved medium spec with R1 to R4, of which the plan marks only
  R2 at risk
- WHEN the plan is written and testing dispatched
- THEN the test brief covers R2's scenarios only, and the other scenarios map
  to builders' tests that the review checks

#### R5.S3 Nothing at risk, medium
- GIVEN a medium plan that marks no requirement at risk
- WHEN verify is dispatched
- THEN a test agent runs it (the builders' tests, the unit suite and the
  declared quality checks), and no blind-test task is planned

### R6 A small change gets one review
A small change SHALL have one review, the whole-change review, by a fresh
reviewer, and its Critical and Important findings, not its Minor ones, start
a fix round.

#### R6.S1 An Important finding
- GIVEN a small change whose whole-change review has 1 Important and 3 Minor
  findings
- WHEN the lead records it
- THEN fix round 1 carries the Important finding only, a re-review of the fix
  diff follows, and the Minor findings are listed in the final report

#### R6.S2 Minor findings only
- GIVEN a small change whose whole-change review has 4 Minor findings and no
  other
- WHEN the lead records it
- THEN no fix round starts, and the final report lists the 4

### R7 A medium change runs the short process
A medium change SHALL have a short `plan.md` that the spec author may write,
with its risk table; one review per wave of build tasks when it has more than
one wave, and the whole-change review; and the operator's spec approval as
its go, with no plan skim.

#### R7.S1 Reviews of a two-wave medium plan
- GIVEN a medium plan with 5 build tasks in 2 waves
- WHEN its review tasks are listed
- THEN there are 3: one per wave and the whole-change review

#### R7.S2 One wave
- GIVEN a medium plan whose build tasks form one wave
- WHEN its review tasks are listed
- THEN there is one, the whole-change review

### R8 A large change runs the full process
A large change SHALL have a full plan written by a fresh planner that never
saw the spec conversation, which the operator skims before the go; a review
per wave, a review of a single build task marked at risk, and the
whole-change review; and shards and mesh nodes where the plan calls for them.

#### R8.S1 The plan skim is a gate
- GIVEN an approved large spec and a plan nobody has skimmed
- WHEN the operator says go
- THEN the lead dispatches nothing, and says the plan awaits the operator's
  skim

#### R8.S2 Reviews as today
- GIVEN a large plan with 9 build tasks in 3 waves, one of them marked at
  risk
- WHEN its review tasks are listed
- THEN there are 5, as `right-size-testing/R10.S1` lists them

### R9 No size relaxes the spec or the separation of agents
At every size the pod SHALL dispatch no build or test task before the spec
is approved, and keep the spec author, builder, test agent and reviewer four
different fresh agents.

#### R9.S1 Four agents at small
- GIVEN a small change run from approval to review
- WHEN the agents that wrote the spec, the code, the tests and the review are
  listed
- THEN they are four different agents, each started from a brief or the
  operator's request, none the session of another

#### R9.S2 Go without approval
- GIVEN a small spec with no `approved:` line
- WHEN the operator says go
- THEN the lead dispatches nothing and says
  `Not dispatched: the spec at changes/<id>/spec.md awaits approval.`

### R10 Every role runs on Opus
The pod SHALL run every role, task and fix round on Opus at every size, and
never on a lesser model to save cost: each role definition says
`model: opus`, the process text says the same, and independence between
agents comes from a fresh session or another node.

#### R10.S1 The role files
- GIVEN the six role definitions at the branch head
- WHEN their front matter is read
- THEN each says `model: opus`

#### R10.S2 No text allows a lesser model
- GIVEN `PROCESS.md`, the role definitions, the skill, the templates, README
  and INSTALL at the branch head
- WHEN every passage about models is read
- THEN none lets a role, a task, a fix round or an independence check run on
  a lesser or cheaper model, none ties a model to a size, and none says
  `model: inherit` or "the most capable model available"

### R11 The templates, roles, skill and docs use the new size names
The templates, role definitions, skill, README, INSTALL and `SPEC.md` SHALL
name sizes only as small, medium, large and spike (the spec template lists
all four, the plan template medium and large), while an archived spec's
`size: small` or `size: project` reads as medium or large and is not
edited.

#### R11.S1 The templates
- GIVEN `templates/records/spec.md` and `plan.md`
- WHEN their size lines are read
- THEN the spec's lists small, medium, large and spike, and the plan's lists
  small, medium and large

#### R11.S2 An archived spec
- GIVEN an archived spec with `size: project`
- WHEN `STATUS.md` is regenerated and the trace is run
- THEN neither errors on the old name, and nothing edits the archived file

### R12 The process version moves, and the kept tests that pin the old text move with it
The process SHALL move to version 3, `PROCESS.md` line 3 reading
`process: swe-pod-process@3`, with the kept tests that pin the old version
line, size names or model line replaced in the same change, so no test left
in `tests/` is known to fail.

#### R12.S1 The version line
- GIVEN `PROCESS.md` at the branch head
- WHEN line 3 is read
- THEN it reads `process: swe-pod-process@3`

#### R12.S2 The suite after integrate
- GIVEN this space's `tests/` after this change integrates
- WHEN the tests that read `PROCESS.md` and the role definitions are run
- THEN they expect `swe-pod-process@3`, the sizes small, medium, large and
  spike, and `model: opus`, and pass

### R13 A task gets at most 3 fix rounds, and a cap hit points back at the spec
The pod SHALL cap a task's fix rounds at 2 for a small change and 3 for a
medium or large one, send every round to the same builder, and at the cap
start no further round: the lead rules on each open finding and, where one
comes from a requirement the builder could read two ways, sends the spec
author the proposed edit, which reopens approval for that edit.

#### R13.S1 Small: open after round 2
- GIVEN a small change whose Important finding is open after fix round 2
- WHEN the lead records the round
- THEN no round 3 starts, and the lead rules on the finding in a `Ruling:`
  ledger line that reaches the final report

#### R13.S2 Large: open after round 3
- GIVEN a large change whose Critical finding is open after fix round 3
- WHEN the lead records the round
- THEN no round 4 starts, no fresh builder is brought in, and the lead rules
  on the finding as in R13.S1

#### R13.S3 The finding comes from the spec
- GIVEN a task at its cap whose open finding is a requirement that the
  builder and the reviewer read two ways
- WHEN the lead rules
- THEN the spec author gets a proposed edit to the requirement, approval
  reopens for that edit only, and the tasks that serve it are held until the
  operator approves

#### R13.S4 The ledger line carries the cap
- GIVEN a medium change in its second fix round of a task
- WHEN the lead records the round, and `STATUS.md` is regenerated
- THEN the ledger line reads `T<n> fix round 2/3: ...`, and the skill reads
  it as it reads a line with any cap

## Quality

### Q1 One rule, one wording
The changed files SHALL state each rule this change alters the same way
wherever they state it.
- check: the whole-change review reads every file in swe-pod that states a
  rule this change alters (sizes, plan, tests and blind tests, reviews, fix
  rounds and their cap, gates, models) and compares them; passing is no
  Critical or Important finding on a disagreement

### Q2 No stale size, fix-round or model wording
The changed files SHALL not name the old sizes, the old fix-round cap or the
old model rule.
- check: a text search of swe-pod for `project size`, `small size`,
  `size: project`, `small|project`, `fix round <r>/5`, `rounds 4 and 5`,
  `5 rounds`, `model: inherit` and `most capable model`, outside the
  legacy-names note R11 allows; passing is no match

## Approaches

1. **One gauge of three sizes, small below today's small (picked).** Small is
   new and lighter than anything today; medium keeps roughly today's small
   process; large is today's project. One `size:` line sets the plan, the
   reviews and the gates, one cap sets the fix loop, and `PROCESS.md`, the
   roles, the templates and the skill change together. It costs one doc
   change and a rename of two size words.
2. **Keep two sizes and add per-knob switches** (a terse plan, one review,
   fewer rounds). It needs no rename, but every combination of switches must
   be stated and checked, and the default stays heavy unless someone sets
   them.
3. **No process change**, keep cutting cost per change by directive and
   ruling. It costs nothing now, but each change argues it again.

Within approach 1, for a small change's plan:

- **a. A terse `plan.md` (picked, R4; the operator's call of 2026-11-07).**
  The plan keeps the sections a small change needs, so the skill's planned
  state and the trace read it as they do any plan.
- **b. No `plan.md`, the spec's build note standing in.** Lighter still, but
  the skill's planned state and trace read `plan.md`, and the operator wants a
  plan at every size.

## Open calls

1. **Size: small** by the pinned process's name, which this change renames
   medium: the spec's approval is also the go, the plan is short and the spec
   author may write it, and there is no plan skim. It runs under
   `swe-pod-process@2`, as pinned, until it integrates and moves the pin to
   @3.
2. **The mapping of old to new names**: today's small is medium, today's
   project is large, and archived specs read that way without an edit (R11).
3. **A terse plan at small, a plan at every size** (R4), the operator's
   decision of 2026-11-07.
4. **Small gets a blind test for every scenario**, since a small spec is
   about 3 requirements and has no risk table; medium and large keep the
   risk table (R5). The alternative is blind tests for every scenario at every
   size, which weighs more on medium and large.
5. **Fix rounds cap at 3, and at 2 for small** (R13), the operator's decision
   of 2026-11-07 ("cap at 3"; today 5 at every size). The 2 for small is my
   default. All rounds go to the same builder, so the fresh builder of rounds
   4 and 5 goes. At the cap the lead rules as today and, where the spec is
   the cause, sends the author an edit.
6. **Reviews**: small, one whole-change review; medium, one per wave when it
   has more than one wave, plus the whole-change review; large, the full set of
   `right-size-testing/R10`. Only Critical and Important findings start a fix
   round at every size (`right-size-testing/R11` holds).
7. **Gates**: small and medium, the spec approval (also the go) and the merge;
   large, also the plan skim. `pod.yaml`'s `gates:` line names the gates of
   large.
8. **Opus is pinned, not inherited** (R10): `model: opus` in the six role
   files replaces `model: inherit`, so the pod runs on Opus whatever the
   session runs on. The lead is the operator's own session and is not pinned
   by a file; the operator starts it on Opus. If a stronger model is later
   preferred, it is a one-line change per role file.
9. **What makes an agent suggest more than small** (R2.S2): more than one
   repo, an interface or data-format change, well over about 3 requirements,
   a fault that would be costly or show late, or a need for agent-class or
   live-class tests. These are signs for judgment, not a formula.
10. **"About 3" and the cap of 2 for small are starting values**, to be set
    from the first changes run on the gauge; the final report's test-cost
    section (`right-size-testing/R14`) shows what each size costs.
11. **The superseded requirements**: `right-size-testing/R6` (risk, not size,
    decides independent tests; R5 here keeps it for medium and large),
    `right-size-testing/R10` (reviews sized to risk, now by size; R7 and R8
    keep its lists) and `right-size-testing/R15` (the most capable model, now
    Opus). The kept tests of those three requirements: none is in `tests/`
    today, so nothing is moved out for them. The fix loop is not a numbered
    requirement of an earlier spec, so R13 supersedes none.
12. **`build-swe-pod/R9` (blind tests) is also listed in `supersedes`**, added
    by the spec author at planning, a header edit that changes no requirement
    text. Its kept test `tests/build-swe-pod/test_I2_role_definitions.md`
    pins `model: inherit`, so R10 makes it stale; this change writes its
    replacement `I2` (R12), and verify can then give the old one
    `superseded by I2` only if the spec lists a requirement that test serves.
    R5 changes who gets blind tests, which is what R9 requires.
