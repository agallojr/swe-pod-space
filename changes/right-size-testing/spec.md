# right-size-testing: each change runs the right tests for its risk, and no test without a stated risk

- size: project
- owner: agallojr
- repos: [swe-pod]
- supersedes: [build-swe-pod/R5, build-swe-pod/R12, build-swe-pod/R13, build-swe-pod/R21]

## Why

In short, after this change:

- Every test in a plan names the risk it covers. A part of the change with
  small risk gets few tests or none beyond its builder's own. No test runs
  without a stated risk.
- The plan estimates the time and spend of its expensive runs, those that
  start an agent or a live session. The operator is asked only before a run
  the plan does not list, or when those runs head well past the estimate.
- Verify runs the change's own tests and the regression tests the change
  could break, not the whole suite. A test it rightly skipped does not hold
  up green.
- Blind tests only for requirements at risk; one review per wave; Minor
  findings never start a fix round; a builder's test suggestion is taken up
  only when it covers a risk no planned test covers.
- Live tests only to reproduce and confirm a reported defect, or where
  nothing cheaper can show the behavior.
- At integrate, only tests worth keeping join the regression suite.
- No model is lowered. Every role keeps its current model (`model:
  inherit`, the operator's own). The savings come from running fewer,
  better-targeted tests, never from weaker agents.

The operator, 2026-10-30: "I want us to do a better job right sizing the
testing effort - its costing a lot to do purist testing. I need something
more practical and cost effective - not test for test sake, but the
targetted tests." On a draft that set test counts: "i don't like this '10
tests' thing - i dont want to say a number, like 'do it in 10 tests', i
want to say do the RIGHT tests for the risk". And: "i hope there's no
dumbing down of claude agents to haiku or something." On 2026-10-29: "we
need to get to right size on our quality assurance processes", and of one
small change: "i think this is way too heavy a test for this small poller
change."

Today every change is tested the same way, whatever its size or risk: a
blind test for every scenario, a review of every build task, every builder
suggestion routed toward a test, every regression test at every verify, and
an ask to the operator before each heavy check. The last day of work shows
the cost (records of the proj:agent-mesh space by URL, this space's by
path):

- **keep-poller-parked**, small, one build task: about 6.3 h from go to
  merge. The first ask covered 11 live and unit runs; the operator cut it to
  4. The R1 reproduction needed 3 live attempts of about 675 s each, the
  first two lost to the test harness, not the code; verify's live run lost
  one more attempt (148 s) to it, then passed (717 s, about 4.77 USD). About
  5 asks to the operator to approve test runs.
  https://github.com/agallojr/agent-mesh-space/blob/main/changes/archive/2026-10-29-keep-poller-parked/ledger.md
- **heartbeat-every-15-min**, small, a two-number change: about 1 h. Its
  evidence was not green by the swe-pod skill's rule (SKILL.md §1.6, a pass
  for every regression test) only because six live regression tests were
  not run and three superseded ones were given `superseded`, a result the
  rule does not know; the lead had to rule it verified.
  https://github.com/agallojr/agent-mesh-space/blob/main/changes/archive/2026-10-29-heartbeat-every-15-min/evidence/20261029T2148Z.md
- **move-memory-into-spaces**, project size: about 10 h from approval to
  integrate. The first plan had 14 reviews for about 20 tasks; the operator
  cut it to one per wave. 45 builder suggestions were routed and 40
  suggestion tests written; 71 test files moved into the regression suite.
  A regression live run lost an attempt (147 s) to a dialog the harness did
  not recognize. The whole-change fix wave closed 28 Minor findings with no
  Important one open.
  https://github.com/agallojr/agent-mesh-space/blob/main/changes/archive/2026-10-30-move-memory-into-spaces/ledger.md
- **build-swe-pod**, this space: one review per build task, 34 fix-round
  entries, and six verify rounds of up to 90 tests; round 6 stopped at the
  account's daily API spend limit, and a targeted verify of 9 tests
  replaced it. `changes/archive/2026-10-29-build-swe-pod/ledger.md`
- The follow-up note proposes sizing review and verify to risk:
  `notes/note-20261029T1233Z-167e-swe-pod-follow-up.md`.

Each change got lean only by directives and rulings made mid-change. This
change makes testing for risk the process's default.

## Scope

In:

- The plan's test plan, its risk marks and its estimates of expensive runs;
  when the lead asks the operator (`PROCESS.md` §4, §11; the plan template;
  the planner and lead roles; the ledger forms).
- Verify's selection of regression tests, the evidence that records it, and
  the green rule (`PROCESS.md` §2, §7; the test role; the evidence template;
  the swe-pod skill and its status format).
- Blind tests, suggestion triage, live tests and harness errors, reviews and
  the fix loop (`PROCESS.md` §5, §6; the build, test, review and lead roles).
- Integrate's promotion of tests, each test's cost class, and the final
  report's cost section (`PROCESS.md` §8; the final-report template).
- The docs that ship with swe-pod and state these rules.

Out:

- **Model choice.** This change lowers no model and gives no reason to pick
  a cheaper one; every role keeps `model: inherit`. The per-role model map
  in the follow-up note is its own change.
- Archiving branches at delivery and one-time permissions, from the same
  note: a separate change. So are the note's three test-check fixes and
  build-swe-pod's deferred Minors.
- The swe-pod skill reading only the first id in a review table's Reviews
  cell.
- **A reusable live-session harness**, a possible later change: one
  isolated-session driver for every project's live tests would carry
  forward the fixes that four lost live attempts paid for in two changes.
- Other Project Spaces' `PROCESS.md` copies and pins; the operator's own
  guidance overlay and budget policy, whose ask points still bind; running
  any full regression suite; agent-mesh (Open calls 17).

## Requirements

### R1 Every test in the plan covers a named risk
A change's plan SHALL name, for every test it plans, the risk that test
covers, and plan no test without one; a part of the change with small risk
gets no test beyond its builder's own unless the plan names a further risk
that test covers.

#### R1.S1 A change of small risk
- GIVEN an approved spec whose requirements the plan judges of small risk,
  served by one build task in a repo with a unit suite
- WHEN its plan is written
- THEN its test plan holds the builder's tests and the repo's unit suite,
  each naming the risk it covers, and no other test

#### R1.S2 A requirement at risk
- GIVEN a spec whose R1 fixes a defect the operator reported, seen only in a
  live session
- WHEN its plan is written
- THEN R1 is marked at risk with that reason, each test planned for it names
  the part of that risk it covers, and the planner's self-review fails on
  any planned test that names no risk

### R2 The plan estimates its expensive runs
The plan SHALL give each agent-class or live-class run it lists an estimate
of its wall time in s and its spend in USD, with the caps the budget policy
asks for, and the total of those estimates; an estimate is not a quota.

#### R2.S1 Estimates for the costly runs only
- GIVEN a plan listing one live run, two agent-class runs and five script
  checks
- WHEN it is read
- THEN the live and agent-class runs each give an estimated wall time in s,
  spend in USD and caps, the plan gives their totals, and the script checks
  give an expected run time only

### R3 The operator is asked only about unplanned or overrunning runs
The lead SHALL ask the operator about a test run only when the plan does
not list it, or when it would take the expensive runs' actual cost well
past the plan's estimate (by default, past twice it in wall time or spend);
every other run the plan lists goes ahead with no ask, and with no operator
present an overrunning run is not dispatched. The budget policy's own ask
points still hold.

#### R3.S1 Listed runs need no ask
- GIVEN an approved change whose plan lists a unit suite expected at 150 s
  and a live run estimated at 700 s and 5 USD
- WHEN the lead dispatches the tasks that run them, with the operator
  present
- THEN it asks the operator nothing, and after each test task the ledger
  gives that task's actual wall time in s and spend in USD beside the
  plan's estimate

#### R3.S2 An unlisted or overrunning run is asked about
- GIVEN expensive runs estimated at 1500 s in all, with 2500 s spent
- WHEN the lead would dispatch a listed run estimated at 700 s, or a live
  run the plan does not list
- THEN it asks the operator first, with the actuals and what remains; a
  rerun of a listed run estimated at 400 s it dispatches with no ask, as
  2900 s is within twice the estimate

### R4 Verify runs a targeted selection of regression tests
Verify SHALL run, besides the change's own tests, unit suites and declared
quality checks, only the regression tests its selection picks: every
script-class regression test that reads a deliverable the change touches,
and every agent-class or live-class one the plan names for a risk; a full
regression runs only on the operator's word. A test reads a touched
deliverable when a path it declares is, or holds, a file the change's diff
from base to head changes. The evidence states the selection rule and lists
every regression test as selected, with its result, or `not-selected`.

#### R4.S1 Cheap tests that read a touched file are selected
- GIVEN a change whose diff touches only swe-pod's `PROCESS.md`, and a
  suite with 2 script-class tests that read it, 3 that do not, and 4
  agent-class tests that read it, none named by the plan
- WHEN verify runs
- THEN it runs the 2 and none of the other 7, and the evidence states the
  rule and lists the 2 with their results and the 7 as `not-selected`

#### R4.S2 Live tests of an earlier change are not run by default
- GIVEN a change that edits the poller's scan loop and prompt, and six
  live-class regression tests of keep-poller-parked that read those files,
  none named by the plan
- WHEN verify runs
- THEN no live session starts, and the evidence lists the six as
  `not-selected`

### R5 Tests verify rightly did not run leave the evidence green
The green rule SHALL count a regression test given `not-selected` under the
evidence's selection rule, or `superseded` by a passing test of this change
for a requirement the spec supersedes, as no bar to green, while every test
the selection picks still needs a pass; the same holds for a sharded
verify's records taken together.

#### R5.S1 Not-selected tests leave the evidence green
- GIVEN an evidence record that passes every scenario, unit suite, declared
  quality check and the 6 selected regression tests, and gives the other 84
  regression tests `not-selected`
- WHEN `STATUS.md` is regenerated
- THEN the evidence is green, and the latest-evidence line shows the 84 not
  selected apart from the 6 passes

#### R5.S2 A superseded test with a passing replacement
- GIVEN a spec that supersedes `keep-poller-parked/R2`, and an evidence
  record that gives keep-poller-parked's R2.S1 test `superseded`, naming
  this change's test of the new behavior, which passes in the same record
- WHEN `STATUS.md` is regenerated
- THEN the evidence is green

#### R5.S3 A superseded test without a passing replacement
- GIVEN the record of R5.S2, but with the named test failing, or with a spec
  whose `supersedes` does not list `keep-poller-parked/R2`
- WHEN `STATUS.md` is regenerated
- THEN the evidence is not green

#### R5.S4 A test the selection picks is not passed
- GIVEN an evidence record that gives `not-selected` to a script-class
  regression test reading a file the change's diff touches, or to an
  agent-class test the plan names, or gives a selected test
  `not-run (cap 600 s)`
- WHEN `STATUS.md` is regenerated
- THEN the evidence is not green

### R6 Blind tests are written only for requirements at risk
Blind project-level tests SHALL be written only at project size and only for
the scenarios of requirements the plan marks at risk; every other scenario
maps to a test its builder writes, which the review checks against it.

#### R6.S1 A small change has no blind test task
- GIVEN an approved small spec
- WHEN its plan is written and its review done
- THEN the plan has no test-writing task, its test map maps every scenario
  to a builder's test (a unit test or, in a repo with no unit suite, a check
  in the build task's done-when), and the review records an Important
  finding for any scenario that test does not exercise

#### R6.S2 Blind tests for the requirement at risk only
- GIVEN an approved project-size spec with R1 to R4, of which the plan marks
  only R2 at risk
- WHEN the test-writing task is dispatched
- THEN its brief covers R2's scenarios and no others, and the scenarios of
  R1, R3 and R4 map to builders' tests

### R7 Builder test suggestions are triaged by risk
The lead SHALL route a builder's test suggestion to the test agent only when
it covers a risk no planned test covers, naming that risk, and record every
other suggestion as declined with its reason.

#### R7.S1 A risk already covered
- GIVEN a suggestion whose input and failure a planned test already
  exercises
- WHEN the lead routes it
- THEN it is declined, naming the test that covers it, and nothing reaches
  the test agent

#### R7.S2 A risk not yet covered
- GIVEN a suggestion of a boundary no planned test exercises
- WHEN the lead routes it
- THEN it reaches the test agent with the risk it covers named, and the
  final report lists it with its outcome

### R8 Live and heavy tests are the exception
A plan SHALL list a live-class test, or a test that is heavy by the
operator's 60 s fence, only to reproduce a reported defect and confirm its
fix, or where it names why no cheaper check can show the behavior.

#### R8.S1 Reproduce and confirm a reported defect
- GIVEN a spec fixing a reported defect that only a live session shows
- WHEN its plan is written
- THEN its live runs are one reproduction at base and one confirming run at
  the branch head, each with its reason

#### R8.S2 A cheaper check exists
- GIVEN a requirement on what a script prints, which a script-class test can
  show
- WHEN the plan is written
- THEN its test is script class, and the plan lists no live or agent-class
  run for it

### R9 A failed harness stops early and is not a test result
A run that starts an agent session SHALL end as a harness error when its
session never reaches the test's first step, by an abort 120 s after launch
(a mechanism that stops a stuck run, not a time limit on the test), and
record no pass or fail for its tests.

#### R9.S1 The session never starts
- GIVEN a live run whose session stops at a startup dialog and never reaches
  the test's first step
- WHEN the run goes on
- THEN it ends no later than 130 s after launch, as a harness error naming
  where it stopped, and none of its tests is recorded as pass or fail

#### R9.S2 Reruns after harness errors
- GIVEN a harness error, then a harness fix that changes no expected value
- WHEN the test task reruns the run
- THEN no ask goes to the operator and the evidence names the space commit
  holding the harness the run used; after a third harness error in one task,
  the task stops and reports BLOCKED to the lead

### R10 Reviews are sized to risk
A plan SHALL have one review per wave of build tasks, a review of a single
build task only where it marks that task at risk, and the whole-change
review. A wave is a group of build tasks the plan's dependency summary runs
together.

#### R10.S1 Three waves, one task at risk
- GIVEN a project-size plan with 9 build tasks in 3 waves, and T4, in the
  second wave with 2 others, marked at risk
- WHEN its review tasks are listed
- THEN there are 5: one for each wave, covering its tasks other than T4,
  one of T4 alone, and the whole-change review

#### R10.S2 A small change gets one review
- GIVEN a small plan whose build tasks form one wave
- WHEN its review tasks are listed
- THEN there is one, on the most capable model, and it is the whole-change
  review

### R11 Minor findings never start a fix round
A review whose open findings are all Minor SHALL start no fix round; its
Minor findings are fixed in the whole-change fix wave or parked by a ruling.

#### R11.S1 Minor findings only
- GIVEN a wave review, or a fix round's re-review, whose open findings are
  all Minor
- WHEN the lead records it
- THEN no fix round is dispatched, and the final report shows each Minor
  finding fixed in the whole-change fix wave or parked by a ruling

#### R11.S2 An Important finding among Minor ones
- GIVEN a wave review, not the whole-change review, with 1 Important and 4
  Minor findings
- WHEN its fix round starts
- THEN the round carries the Important finding only, and the Minor ones
  wait as in R11.S1

### R12 The regression suite keeps only durable, current tests
At integrate, the lead SHALL leave the space's `tests/` holding only tests
of lasting behavior that is still required: it promotes only the change's
tests the plan marks to keep, and moves out the tests the change supersedes
or makes stale.

#### R12.S1 Only the kept tests are promoted
- GIVEN a change with 66 tests in its folder, of which the plan marks 20 to
  keep
- WHEN it integrates
- THEN the change's folder under `tests/` holds those 20, the other 46 stay
  in the change's archive folder, and the final report lists both groups,
  each test with its reason

#### R12.S2 Superseded and stale tests leave the suite
- GIVEN a change whose spec supersedes `keep-poller-parked/R2`, and a
  regression test that failed at verify only because the change removed
  what its fixture relies on
- WHEN the change integrates
- THEN keep-poller-parked's R2 tests and fixtures are in its archive folder,
  not under `tests/`; the stale test has been updated or superseded; and no
  test left in `tests/` is known to fail

### R13 Every regression test has a cost class
Every regression test SHALL declare its cost class, its expected run time
in s and the deliverables it reads, for verify's selection. The classes:
script, which starts no agent session (inspection checks, scripts, unit
suites); agent, which starts an agent session; live, which drives an
interactive session or a running node. A test that declares none is treated
as live class and named in the evidence.

#### R13.S1 Promoted tests carry their class
- GIVEN a change's kept tests at integrate
- WHEN its folder under `tests/` is read
- THEN each test gives its cost class, its expected run time in s and the
  deliverables it reads

#### R13.S2 The suite as it stands
- GIVEN this space's `tests/build-swe-pod/` at this change's base
- WHEN verify's selection reads it
- THEN every test has a cost class with no edit to the test: its inspect
  tests are script class, its agent and desk tests agent class

### R14 The final report gives test cost, estimate against actual
The final report SHALL give the change's test cost: the plan's estimate and
the actual wall time in s and spend in USD of its expensive runs, the total
test wall time in s, and the number of test agents, review agents, fix
rounds and asks to the operator about tests.

#### R14.S1 The cost table
- GIVEN an integrated change whose plan estimated its expensive runs at
  1500 s and 10 USD
- WHEN its final report is read
- THEN it gives those estimates beside the actuals, with the ratio of
  actual to estimate (rounded to 0.1), the total test wall time in s, and
  the counts of test agents, review agents, fix rounds and asks

#### R14.S2 Spend that was not estimated
- GIVEN an agent-class run whose spend no one estimated
- WHEN the final report is written
- THEN its spend shows as unknown, not as 0 USD, and the total says how many
  runs it leaves out

## Quality

### Q1 One rule, one wording
The changed files SHALL state each rule this change alters the same way
wherever they state it.
- check: the whole-change review reads every file in swe-pod that states a
  rule this change alters (risk-named tests, estimates and asks, verify's
  selection, the green rule, blind tests, suggestion triage, live tests,
  harness errors, reviews and the fix loop, integrate's promotion, cost
  classes, the cost report) and compares them; passing is no Critical or
  Important finding on a disagreement

## Approaches

1. **Make testing for risk the process's default (picked).** `PROCESS.md`,
   the role files, the templates and the swe-pod skill change together, so
   every later change gets it with no directive. It costs one doc change
   now and loosens the green rule, which R5.S3 and R5.S4 and the plan's
   recorded selection guard.
2. **A per-change switch** between today's full rules and lean ones. The
   purist path stays, but every rule is stated twice and must agree in both
   modes, and the default stays heavy unless someone picks lean.
3. **No process change**: keep cutting cost per change by directive and
   ruling, as on 2026-10-29. It costs nothing now, but each change argues it
   again, the operator is still asked run by run, and the status view calls
   a verified change not green.

For verify's selection, within approach 1:

- **a. Every regression test that reads a touched deliverable.** Mechanical,
  but a process-doc edit touches files nearly every test reads: for this
  change it would pick 66 of this space's 74 agent-class tests, about
  19950 s (5.5 h) expected, and for heartbeat-every-15-min the six live
  tests the operator ruled out.
- **b. Rule a for script-class tests; agent-class and live-class tests only
  when the plan names them for a risk (picked, R4).** Cheap tests always run
  when they read a touched file; costly ones when a risk calls for them.
- **c. The plan names every selected test by hand.** The most control, but
  the green rule could not catch a test left out by mistake.

## Open calls

1. **Size: project**, by `PROCESS.md` §9: the evidence, plan and test record
   formats change, and every later change relies on the green rule. The
   alternative is small: no fresh planner and no plan skim, but the
   operator would not see the plan's risk marks before work starts.
2. **This change runs under its own rules from the go**, by one lead ruling,
   though the space still pins the old process. Its test plan: R5, the
   green rule, is the one requirement marked at risk, so one blind test
   task writes R5's scenario tests as script-class fixture checks, with an
   agent-class run of the swe-pod skill only where a fixture check cannot
   show how an agent reads the rule. Every other scenario is a check in its
   build task's done-when, rerun at verify. One review, the whole-change
   review, which also runs Q1. Verify selects the 6 script-class regression
   tests that read files this change touches (I1 to I5 and R16.S1 in
   `tests/build-swe-pod/`) and one agent-class test,
   `test_R12_S1_missing_quality_check`, named for the risk that R5 breaks
   the rule it tests; the rest are not selected, about 22815 s (6.3 h) of
   expected run time not spent. No live run.
3. **Small risk** (R1): the builder's own tests and the repo's unit suite,
   and nothing more unless the plan names a further risk. The planner
   judges risk and gives its reasons in the plan, where the operator sees
   them at the skim.
4. **"Well past the estimate" is twice it**, in wall time or spend (R3).
   With no operator present, the lead dispatches no run past that point and
   records why. The budget policy's ask points (about 6 h of agent test
   runs in all, about 3 h for one run, money or a shared allocation) hold
   on top. Alternative: ask as soon as the estimate is passed.
5. **Spend estimates cover agent-class runs, not only live ones** (R2):
   build-swe-pod's verify stopped at the daily API spend limit on agent
   runs.
6. **Verify's selection is approach b** (R4). Tests in other projects'
   spaces are never selected; a cross-project run is the operator's call.
7. **Cost classes come from the `mode:` value tests already carry** (R13):
   inspect and script are script class, agent and desk agent class, live
   live class, so no existing test needs an edit.
8. **"Before a release"**: the pod has no release event, so a full
   regression runs only when the operator asks. The final report lists the
   costly regression tests not run since their last pass, so the operator
   can call one.
9. **A `superseded` result** is added beside `not-selected` (R5.S2), beyond
   the brief, since heartbeat-every-15-min's evidence already needed it.
10. **No blind test at small size, even for a requirement at risk** (R6.S1);
    the review checks the builder's test for it with that mark in view. In
    a repo with no unit suite, such as swe-pod, a builder's test is a
    done-when check, rerun by verify and not promoted. Blind script-class
    tests were cheap (heartbeat-every-15-min's took one test agent about
    12 min); the costs came from live and agent runs, reviews, fix rounds
    and suggestion passes. Alternative: keep a blind task at small size for
    script-class tests.
11. **A small change's one review is the whole-change review** (R10.S2), as
    keep-poller-parked's and heartbeat-every-15-min's leads ruled.
12. **Fix rounds carry only Critical and Important findings** (R11). The
    whole-change fix wave runs only when the whole-change review has one,
    and then also takes the batched Minor ones; with none, they are parked
    by one ruling and listed in the final report.
13. **Two reruns after harness errors** (R9.S2), three attempts in all;
    keep-poller-parked's R1 reproduction needed its third.
14. **Which tests are kept** (R12): the plan's test map marks each. A
    scenario test of a lasting requirement is kept; a suggestion test only
    when it guards a boundary no kept test covers; tests of one-time events,
    such as a migration, are not.
15. **Q1 is declared** because restating one rule across files cost
    build-swe-pod many fix commits; it rides on the whole-change review.
16. **Process version swe-pod-process@2.** This space's `PROCESS.md` copy
    and `pod.yaml` `process:` line move at integrate, and I1's version-line
    check with them.
17. **`supersedes`** lists build-swe-pod/R5 (only kept tests are promoted),
    R12 (not every regression test runs), R13 (heavy checks in the plan are
    not asked about one by one) and R21 (not every suggestion reaches the
    test agent). agent-mesh is not in `repos`: its librarian's integrate
    mode already takes any list of renames.
18. **swe-pod's SPEC.md** gets a short note beside R5, R12, R13 and R21
    naming this change, from a build task.
19. **The existing model line stays as it is.** `PROCESS.md` §5 and the
    lead's role already let the lead pick "a cheaper one for a mechanical
    task with a complete brief". This change leaves that text alone, as
    model choice is out of scope. If the operator wants it gone, the
    per-role model map change can remove it.
