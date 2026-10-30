# right-size-testing: each change's tests, reviews and verify are sized to its risk and a stated budget, so the pod runs targeted tests rather than every test it could

- size: project
- owner: agallojr
- repos: [swe-pod]
- supersedes: [build-swe-pod/R5, build-swe-pod/R12, build-swe-pod/R13, build-swe-pod/R21]

## Why

The operator, 2026-10-30: "I want us to do a better job right sizing the
testing effort - its costing a lot to do purist testing. I need something
more practical and cost effective - not test for test sake, but the
targetted tests." And: "you had the idea of a reusable test harness - we can
add that to the spec, then decide if we want it." On 2026-10-29: "we need to
get to right size on our quality assurance processes", and of one small
change: "i think this is way too heavy a test for this small poller change."

Today the process tests every change the same way, whatever its size or
risk: a blind test task at the go with a test for every scenario, a review
of every build task, every builder suggestion routed toward a test, every
regression test at every verify, and an ask to the operator before each
heavy check. The last day of work shows the cost. Records of the
proj:agent-mesh space are cited by URL, this space's by path.

- **keep-poller-parked**, small, one build task: go at 2026-10-29T14:30Z,
  merged about 20:49Z, about 6.3 h. The first ask to the operator covered 11
  live and unit runs (about 1.9 h expected, 4.1 h and 95 USD at caps); the
  operator cut it to 4. The R1 reproduction needed 3 live attempts of about
  675 s each, and the first two failed in the test harness (the operator's
  own guidance reached the session and raised a startup dialog, then an
  allowlist sat at the wrong path), not in the code. Verify's live run ended
  once in a harness error (148 s), then passed (717 s, about 4.77 USD). 9
  blind tests, 2 fix rounds, and about 5 asks to the operator to approve
  test runs.
  https://github.com/agallojr/agent-mesh-space/blob/main/changes/archive/2026-10-29-keep-poller-parked/ledger.md
- **heartbeat-every-15-min**, small, a two-number change: about 1 h, 8
  blind script tests, one fix round for doc lines. Its evidence was not
  green by the swe-pod skill's rule (SKILL.md §1.6: a pass for every
  regression test), only because six live regression tests of
  keep-poller-parked were not run and three superseded ones were given
  `superseded`, a result the rule does not know. The lead had to rule it
  verified.
  https://github.com/agallojr/agent-mesh-space/blob/main/changes/archive/2026-10-29-heartbeat-every-15-min/ledger.md
  and
  https://github.com/agallojr/agent-mesh-space/blob/main/changes/archive/2026-10-29-heartbeat-every-15-min/evidence/20261029T2148Z.md
- **move-memory-into-spaces**, project size: about 10 h from approval to
  integrate. The plan's first draft had 14 reviews for about 20 tasks; the
  operator cut it to one per wave. 45 builder suggestions were routed, 40
  suggestion tests were written over three passes, and 71 test files moved
  into the regression suite at integrate. Verify ran 3 shards: 66 tests in
  about 1149 s, an R12 shard on a second node, and a regression shard whose
  live run ended once in a harness error (147 s; a folder-trust dialog drawn
  with cursor moves for spaces went unrecognized), then passed (669 s, 4.76
  USD). One regression test of another change failed on a fixture this
  change made stale, not on a defect. The whole-change fix wave closed 28
  Minor findings with no Important one open. The lead dispatched unit-suite
  runs before asking about them.
  https://github.com/agallojr/agent-mesh-space/blob/main/changes/archive/2026-10-30-move-memory-into-spaces/ledger.md
  and
  https://github.com/agallojr/agent-mesh-space/blob/main/changes/archive/2026-10-30-move-memory-into-spaces/report.md
- **build-swe-pod**, this space: one review per build task, 34 fix-round
  entries, and six verify rounds of up to 90 tests over two shards
  (recorded shard runs of about 2000 s to 4750 s each). Round 6 stopped at
  the account's daily API spend limit, and a targeted verify of 9 tests,
  with 81 earlier results carried, replaced it.
  `changes/archive/2026-10-29-build-swe-pod/ledger.md`
- The follow-up note proposes sizing review and verify to risk:
  `notes/note-20261029T1233Z-167e-swe-pod-follow-up.md`, "Right-size
  quality assurance".

Each of the three changes got lean only by operator directives and lead
rulings made mid-change. Agent test runs inside an approved change are
already pre-authorized under the operator's budget policy (swe-pod
`INSTALL.md`, G3), yet leads still asked run by run. This change makes
risk-sized, budgeted testing the process's default, so the operator approves
a budget once and is asked again only when it is overrun.

## Scope

In:

- The plan's test plan and test budget, and the size defaults for it
  (`PROCESS.md` §4 and §9, the plan template, the planner's role).
- When the lead asks the operator about test runs, and how it tracks their
  cost (`PROCESS.md` §11, the lead's role, the ledger forms).
- Verify's selection of regression tests, the evidence that records it, and
  the green rule that reads it (`PROCESS.md` §2 and §7, the test agent's
  role, the evidence template, the swe-pod skill and its status format).
- Blind test tasks, builder test suggestions, live and heavy tests, and
  harness errors (`PROCESS.md` §5 and §6, the test, build and lead roles,
  the test-writing brief).
- Reviews and the fix loop (`PROCESS.md` §5 and §7, the review and lead
  roles).
- Integrate's promotion and removal of regression tests, the cost class of
  each test, and the final report's cost section (`PROCESS.md` §8, the
  final-report template).
- The docs that ship with swe-pod and state these rules (README, INSTALL,
  SPEC.md's note on what this change supersedes).
- Optional, for the operator to take or drop at approval: R14, a reusable
  live-session harness.

Out:

- Archiving branches at delivery, one-time permissions, and the per-role
  model map, from the same follow-up note: a separate change.
- The swe-pod skill reading only the first id in a review table's Reviews
  cell.
- The note's other items for that change: the three test-check fixes ruled
  at build-swe-pod's integrate and its deferred Minors.
- Other Project Spaces' copies of `PROCESS.md` and their pins: each space,
  proj:agent-mesh's included, moves to the new rules on its own.
- The operator's own guidance overlay and its budget policy: nothing here
  loosens a mesh fence, the git gate or the budget policy's ask points.
- Running any full regression suite, and editing existing regression tests
  beyond what `supersedes` requires.
- agent-mesh: its librarian's integrate mode already takes any list of
  renames (Open calls 21).

## Requirements

### R1 Each plan states a test plan and a budget sized to risk
A change's plan SHALL state which tests run, for each task and for the whole
change, and why; mark the requirements at risk, each with its reason; and
give a test budget of the number of tests, the expected test wall time in s,
and the expected spend in USD of the runs that start an agent session, taken
from its size's default unless the plan states and justifies another.

| Size | Tests | Expected test wall time | Spend of agent and live runs |
|---|---|---|---|
| small | 10 | 1800 s | 10 USD |
| project | 40 | 7200 s | 30 USD |
| spike | none | none | none |

A test, unit suite or quality check counts once however often it runs. The
wall time and the spend count every run, runs at base and reruns included.

#### R1.S1 A small change with nothing at risk
- GIVEN an approved small spec with 3 requirements and 4 scenarios, none at
  risk, served by one build task in a repo with a unit suite
- WHEN its plan is written
- THEN the plan's test plan names, for the build task, each test it runs
  with its cost class (R12), its expected wall time in s and the scenario it
  serves; marks no requirement at risk; and gives a budget of at most 10
  tests, 1800 s and 10 USD

#### R1.S2 A reported defect puts its requirement at risk
- GIVEN a spec whose R1 fixes a defect the operator reported, seen only in a
  live session
- WHEN its plan is written
- THEN R1 is marked at risk with that reason, and the test plan lists the
  live runs R1 needs, each with its caps and its expected wall time in s

#### R1.S3 A budget above the size default says why
- GIVEN a small change whose planned tests take 2400 s of expected wall time
- WHEN its plan is written
- THEN its budget gives 2400 s, says it is above the small default of
  1800 s, and gives the reason for each test that takes it there

#### R1.S4 A heavy test with no cap is not planned
- GIVEN a plan draft whose test plan lists a test expected to take over 60 s
  with no cap
- WHEN the planner's self-review runs
- THEN it fails on that test, and the plan is not handed over until the test
  has its caps

### R2 The operator is asked about a budget, not about each run
The lead SHALL ask the operator about test runs only to approve a budget
above its size default, before a run the approved plan does not list, or
before a run that would take the actual cost past twice the approved budget
in any of its three numbers; every other test run, heavy ones included, goes
ahead under the approved budget with no ask. The mesh's fences and the
budget policy's own ask points still hold.

#### R2.S1 Heavy runs inside the budget need no ask
- GIVEN an approved small change whose plan lists two heavy checks, a unit
  suite expected at 150 s and a live run expected at 700 s that R7 allows,
  within the small default budget
- WHEN the lead dispatches the tasks that run them, with the operator present
- THEN it asks the operator nothing; the ledger records the budget's
  approval once, citing the spec's approval, and each heavy check's
  dispatch cites that line

#### R2.S2 A budget above the default is asked about once, at the go
- GIVEN an approved small change whose plan's budget is 2400 s, above the
  small default
- WHEN the change reaches its go
- THEN the lead asks the operator once, before any dispatch, giving the
  budget's three numbers and each heavy check's command, caps and expected
  wall time in s, and dispatches no test task until the operator answers

#### R2.S3 Actual cost is tracked against the budget
- GIVEN a change whose test tasks have reported
- WHEN its ledger is read
- THEN after each test task it gives that task's actual wall time in s and
  spend in USD, and the running totals beside the budget's

#### R2.S4 Past twice the budget, the lead asks first
- GIVEN an approved budget of 1800 s, with 3000 s spent
- WHEN the lead would dispatch a test task expected to take 900 s
- THEN it asks the operator first, with the actuals and the remaining
  planned tests and their expected cost; for a next task expected at 500 s
  it dispatches with no ask, since 3500 s is within 3600 s, and records the
  overrun

#### R2.S5 A run the plan does not list is asked about
- GIVEN a fix round that needs a live run the plan does not list, with half
  the budget unspent
- WHEN the lead would dispatch it
- THEN it asks the operator first; a rerun of a test the plan lists, after a
  fix, needs no ask

#### R2.S6 No operator present, past twice the budget
- GIVEN the case of R2.S4, with no operator present
- WHEN the lead would dispatch the 900 s task
- THEN it dispatches no further test task, records why, and leaves the rest
  for the operator

### R3 Verify runs a targeted selection of regression tests
Verify SHALL run, besides the change's own tests, unit suites and declared
quality checks, only the regression tests its selection picks: every
script-class regression test that reads a deliverable the change touches,
and every agent-class or live-class regression test the plan names with a
reason; a full regression run happens only on the operator's word. A test
reads a touched deliverable when a path it declares is, or holds, a file the
change's diff from base to head changes, in a repo the spec names. The
evidence states the selection rule and lists every regression test as
selected, with its result, or `not-selected`.

#### R3.S1 Script tests that read a touched file are selected
- GIVEN a change whose diff touches only swe-pod's `PROCESS.md`, and a
  regression suite with 2 script-class tests that read `PROCESS.md`, 3
  script-class tests that do not, and 4 agent-class tests that read it, none
  named by the plan
- WHEN verify runs
- THEN it runs the 2 and none of the other 7, and the evidence states the
  rule and lists all 9, the 2 with their results and the 7 as
  `not-selected`

#### R3.S2 Live tests of an earlier change are not run by default
- GIVEN a change that edits the poller's scan loop and prompt, and six
  live-class regression tests of keep-poller-parked that read those files,
  none named by the plan
- WHEN verify runs
- THEN none of the six runs, no live session starts, and the evidence lists
  each as `not-selected`

#### R3.S3 The plan names a costly regression test
- GIVEN a plan that names one agent-class regression test for verify,
  because the change alters the rule it tests
- WHEN verify runs
- THEN that test runs, and the evidence gives its result with the plan's
  reason

#### R3.S4 A full regression on the operator's word
- GIVEN the operator has asked for a full regression run
- WHEN verify runs
- THEN every regression test has a result, and the evidence names the run
  as full

#### R3.S5 Nothing to select
- GIVEN a change whose diff touches no deliverable any regression test
  reads, and a plan that names none
- WHEN verify runs
- THEN no regression test runs, and the evidence states the rule and lists
  every regression test as `not-selected`

### R4 Tests verify rightly did not run leave the evidence green
The green rule SHALL count a regression test given `not-selected` under the
evidence's selection rule, or given `superseded` by a passing test of this
change for a requirement the spec supersedes, as no bar to green, while a
test the selection picks still needs a pass; the same holds for a sharded
verify's records taken together.

#### R4.S1 Not-selected tests leave the evidence green
- GIVEN an evidence record that passes every scenario, unit suite, declared
  quality check and the 6 selected regression tests, and gives the other 84
  regression tests `not-selected`
- WHEN `STATUS.md` is regenerated
- THEN the evidence is green, and the latest-evidence line shows the 84 not
  selected apart from the 6 passes

#### R4.S2 A superseded test with a passing replacement
- GIVEN a spec that supersedes `keep-poller-parked/R2`, and an evidence
  record that gives keep-poller-parked's R2.S1 test `superseded`, naming
  this change's test of the new behavior, which passes in the same record
- WHEN `STATUS.md` is regenerated
- THEN the evidence is green

#### R4.S3 A superseded test without a passing replacement
- GIVEN the record of R4.S2, but with the named test failing, or with a spec
  whose `supersedes` does not list `keep-poller-parked/R2`
- WHEN `STATUS.md` is regenerated
- THEN the evidence is not green

#### R4.S4 A test the selection picks is marked not selected
- GIVEN an evidence record that gives `not-selected` to a script-class
  regression test reading a file the change's diff touches, or to an
  agent-class regression test the plan names for verify
- WHEN `STATUS.md` is regenerated
- THEN the evidence is not green

#### R4.S5 A selected test stopped by its cap
- GIVEN an evidence record that gives a selected regression test
  `not-run (cap 600 s)`
- WHEN `STATUS.md` is regenerated
- THEN the evidence is not green

### R5 Blind tests are written only where the plan marks risk
Blind project-level tests SHALL be written only at project size and only for
the scenarios of requirements the plan marks at risk; every other scenario
maps to a test its builder writes, which the review checks against the
scenario.

#### R5.S1 A small change has no blind test task
- GIVEN an approved small spec
- WHEN its plan is written and its review done
- THEN the plan has no test-writing task; its test map maps every scenario
  to a builder's test, a unit test or, in a repo with no unit suite, a check
  the build task's done-when gives; and the review record says, for each
  scenario, whether that test exercises it

#### R5.S2 Blind tests for the requirement at risk only
- GIVEN an approved project-size spec with R1 to R4, of which the plan marks
  only R2 at risk
- WHEN the plan is written and the test-writing task dispatched
- THEN its one test-writing brief covers R2's scenarios and no others, and
  the scenarios of R1, R3 and R4 map to builders' tests

#### R5.S3 Nothing at risk
- GIVEN a project-size plan that marks no requirement at risk
- WHEN it is written
- THEN it has no test-writing task

#### R5.S4 A scenario no builder test exercises
- GIVEN a build task whose tests leave one scenario it serves unexercised
- WHEN it is reviewed
- THEN the review records an Important finding naming that scenario, and the
  fix loop starts

### R6 Builder test suggestions are triaged
The lead SHALL route to the test agent only the builder suggestions that
cover a risk no existing test covers, at most 5 per change, and record every
other one as declined with its reason.

#### R6.S1 A risk already covered
- GIVEN a suggestion whose input and failure an existing test already
  exercises
- WHEN the lead routes it
- THEN it is declined, naming the test that covers it, and nothing reaches
  the test agent

#### R6.S2 The cap
- GIVEN 7 suggestions in one change, each covering a risk no test covers
- WHEN the lead routes them
- THEN 5 reach the test agent and 2 are declined as past the cap of 5 per
  change, and the final report lists all 7 with their outcomes

#### R6.S3 An internal-only suggestion
- GIVEN a suggestion about a behavior with nothing observable
- WHEN the lead routes it
- THEN it goes back to its builder as a unit test, and does not count toward
  the cap

### R7 Live and heavy tests are the exception
A plan SHALL list a live-class test, or any test expected to take over 60 s,
only to reproduce a reported defect and confirm its fix, or where it names
why no cheaper check can show the behavior.

#### R7.S1 Reproduce and confirm a reported defect
- GIVEN a spec fixing a reported defect that only a live session shows
- WHEN its plan is written
- THEN its live runs are one reproduction at base and one confirming run at
  the branch head, each with its reason, caps and expected wall time in s

#### R7.S2 A cheaper check exists
- GIVEN a requirement on what a script prints, which a script-class test can
  show
- WHEN the plan is written
- THEN its test is script class, and the plan lists no live-class or
  agent-class run for it

#### R7.S3 A heavy test with no reason
- GIVEN a plan draft that lists an agent-class test expected at 420 s with
  neither reason
- WHEN the planner's self-review runs
- THEN it fails on that test

### R8 A failed harness stops early and is not a test result
A run that starts an agent session SHALL end as a harness error no later
than 130 s after the session's launch (an abort at 120 s, plus up to 10 s to
stop it) when the session never reaches the test's first step, and record no
pass or fail for its tests.

#### R8.S1 The session never starts
- GIVEN a live run whose session stops at a startup dialog and never reaches
  the test's first step
- WHEN the run goes on
- THEN it ends no later than 130 s after the launch, as a harness error
  naming where it stopped, and none of its tests is recorded as pass or fail

#### R8.S2 A rerun after a harness fix
- GIVEN a harness error, then a harness fix that changes no expected value
- WHEN the test task reruns the run within the approved budget
- THEN no ask goes to the operator, and the evidence names the space commit
  holding the harness the passing run used

#### R8.S3 A third harness error stops the task
- GIVEN a test that has ended in a harness error twice in one task
- WHEN its third attempt ends in a harness error
- THEN the task stops and reports BLOCKED to the lead with the three errors,
  and no fourth attempt starts

### R9 Reviews are sized to risk
A plan SHALL have one review per wave of build tasks, a review of a single
build task only where it marks that task at risk, and the whole-change
review. A wave is a group of build tasks the plan's dependency summary runs
together.

#### R9.S1 Three waves, one task at risk
- GIVEN a project-size plan with 9 build tasks in 3 waves, and T4, in the
  second wave with 2 others, marked at risk
- WHEN its review tasks are listed
- THEN there are 5: one for each wave, covering its tasks other than T4, one
  of T4 alone, and the whole-change review

#### R9.S2 A small change gets one review
- GIVEN a small plan whose build tasks form one wave
- WHEN its review tasks are listed
- THEN there is one, on the most capable model, and it is the whole-change
  review

#### R9.S3 A wave review keeps its tasks apart
- GIVEN a wave of 3 build tasks
- WHEN its review is written
- THEN the review record names the diff of each of the 3 tasks, and each
  finding names its task, so a fix round goes to that task's builder

### R10 Minor findings never start a fix round
A review whose open findings are all Minor SHALL start no fix round; its
Minor findings are fixed in the whole-change fix wave or parked by a ruling.

#### R10.S1 Minor findings only
- GIVEN a wave review with 0 Critical, 0 Important and 6 Minor findings
- WHEN the lead records it
- THEN no fix round is dispatched, the 6 Minor findings are in the ledger,
  and the final report shows each one fixed in the whole-change fix wave or
  parked by a ruling

#### R10.S2 A re-review finds only new Minor findings
- GIVEN a fix round whose re-review closes every Important finding and finds
  5 new Minor ones
- WHEN the lead records it
- THEN no further fix round starts

#### R10.S3 An Important finding among Minor ones
- GIVEN a wave review, not the whole-change review, with 1 Important and 4
  Minor findings
- WHEN its fix round starts
- THEN the round carries the Important finding only, and the 4 Minor ones
  wait as in R10.S1

### R11 The regression suite keeps only durable, current tests
At integrate, the lead SHALL leave the space's `tests/` holding only tests
of lasting behavior that is still required: it promotes only the change's
tests the plan marks to keep, and moves out the tests of requirements the
change supersedes.

#### R11.S1 Only the kept tests are promoted
- GIVEN a change with 66 tests in its folder, of which the plan marks 20 to
  keep
- WHEN it integrates
- THEN the change's folder under `tests/` holds those 20, the other 46 stay
  in the change's archive folder, and the final report lists both groups,
  each test with its reason

#### R11.S2 Superseded tests leave the suite
- GIVEN a change whose spec supersedes `keep-poller-parked/R2`
- WHEN it integrates
- THEN keep-poller-parked's R2 tests and their fixtures are no longer under
  `tests/`, and are in keep-poller-parked's archive folder

#### R11.S3 A test the change made stale
- GIVEN a regression test that fails at verify because the change removed
  what its fixture relies on, not because of a defect
- WHEN the change integrates
- THEN this change has updated that test or superseded it, and no test left
  in `tests/` is known to fail

### R12 Every regression test has a cost class
Every regression test SHALL declare its cost class, its expected run time
in s and the deliverables it reads, for verify's selection. The classes:
script, which starts no agent session (inspection checks, scripts, unit
suites); agent, which starts an agent session; and live, which drives an
interactive session or a running node.

#### R12.S1 Promoted tests carry their class
- GIVEN a change's kept tests at integrate
- WHEN its folder under `tests/` is read
- THEN each test gives its cost class, its expected run time in s and the
  deliverables it reads

#### R12.S2 The suite as it stands
- GIVEN this space's `tests/build-swe-pod/` at this change's base, 90 tests
- WHEN verify's selection reads it
- THEN every test has a cost class with no edit to the test: its 16 inspect
  tests are script class and its 74 agent and desk tests agent class

#### R12.S3 A test with no class
- GIVEN a regression test that declares no cost class
- WHEN verify's selection reads it
- THEN it is treated as live class, so it runs only when the plan names it,
  and the evidence names it as lacking a class

### R13 The final report gives the test cost
The final report SHALL give the change's test cost against its budget: the
number of tests, the wall time in s and the spend in USD, budgeted and
actual, and the number of test agents and of review agents dispatched, of
fix rounds, and of asks to the operator about tests.

#### R13.S1 The cost table
- GIVEN an integrated change with an approved budget
- WHEN its final report is read
- THEN it gives the budgeted and actual number of tests, test wall time in s
  and spend in USD, the number of test agents and review agents dispatched,
  the number of fix rounds, and the number of asks to the operator about
  tests

#### R13.S2 Spend that was not estimated
- GIVEN an agent-class run whose spend was not estimated
- WHEN the final report is written
- THEN its spend shows as unknown, not as 0 USD, the total says how many runs
  it leaves out, and script-class runs show 0 USD

#### R13.S3 An overrun
- GIVEN an actual test wall time of 3200 s against a budget of 1800 s
- WHEN the final report is written
- THEN it gives the ratio of actual to budget, 1.8 (rounded to 0.1), and the
  reason for the overrun

### R14 (optional) A reusable live-session harness
The swe-pod product SHALL provide one harness that runs an isolated
interactive Claude Code session for any project's live tests.

Optional: the operator takes R14 or drops it at approval (Open calls 23).
Expected value: in two changes, four live attempts ended as harness errors,
about 1645 s of runs in all (keep-poller-parked: 675 s, 675 s and 148 s;
move-memory-into-spaces: 147 s), and each project built its own
isolated-session runner (this space's `tests/build-swe-pod/runner.sh`, and
https://github.com/agallojr/agent-mesh-space/blob/main/tests/keep-poller-parked/lib/live.py).
One harness would carry each fix forward. Cost: a code task in swe-pod,
which today holds only Markdown and skill files, with its own tests and at
least one live smoke run (about 700 s and about 5 USD, from the live runs
above), and upkeep as the CLI's screens change. With R7 making live tests
rare, its value falls with their number.

#### R14.S1 No walk-up to the operator's guidance
- GIVEN the operator's own guidance files in the operator's home folder
- WHEN the harness starts a session
- THEN the session's home and working folders lie outside the operator's
  home folder, and the session loads none of the operator's guidance

#### R14.S2 One sign-in, kept
- GIVEN the operator has signed in once to the harness's isolated config
- WHEN a second live run starts, in the same project or another
- THEN it needs no sign-in, and it leaves the config signed in

#### R14.S3 Known dialogs never take the test's input
- GIVEN a session that shows an external-imports dialog, a folder-trust
  dialog, an organization-settings notice or a permission-mode offer before
  its first prompt, with the words on screen separated by cursor moves
  rather than spaces
- WHEN the harness drives it
- THEN each is answered before the test's first input is typed: external
  imports declined, trust given to the run's scratch folder only, the notice
  dismissed and the offer declined

#### R14.S4 The config folder, found as the git gate finds it
- GIVEN a run whose isolated config folder is set the way the git gate looks
  for one
- WHEN the harness lays out the git allowlist and settings, and a skill
  under test reads the allowlist while the gate checks a git command
- THEN both find the same file in that folder

#### R14.S5 A session that never starts
- GIVEN a session driven by the harness that never reaches the test's first
  step
- WHEN 120 s pass from its launch
- THEN the harness ends it as in R8.S1, no later than 130 s after the launch

## Quality

### Q1 One rule, one wording
The changed files SHALL state each rule this change alters the same way
wherever they state it.
- check: the whole-change review reads every file in swe-pod that states
  the test budget, the operator ask, verify's selection, the green rule,
  blind tests, suggestion triage, the review and fix-loop rules or
  integrate's promotion, and compares them; passing is no Critical or
  Important finding on a disagreement

## Approaches

1. **Make risk-sized, budgeted testing the process's default (picked).**
   `PROCESS.md`, the role files, the plan, evidence and final-report
   templates and the swe-pod skill change together, so every later change
   gets the lean path with no directive. It costs one doc change now, and it
   loosens the green rule, which R4.S3 to R4.S5 and the plan's recorded
   selection guard.
2. **A per-change switch** between today's full rules and lean ones, named
   in the spec header. The purist path stays as it is, but every rule is
   stated twice and the files must agree in both modes (in build-swe-pod,
   one wording of the heavy-check rule took ten commits to align across
   files), and the default stays heavy unless someone picks lean.
3. **No process change**: keep cutting cost per change by operator
   directive and lead ruling, as the three changes of 2026-10-29 did. It
   costs nothing now, but each change argues it again, the operator is
   still asked run by run, and the status view calls a verified change not
   green.

For verify's selection, within approach 1:

- **a. Every regression test that reads a touched deliverable**, as first
  put. Mechanical, but a process-doc edit touches files nearly every test
  reads: for this change it would select 66 of this space's 74 agent-class
  tests, about 19950 s (5.5 h) expected, nearly three times the project
  default budget of 7200 s and close to the budget policy's ask point of
  about 6 h; and for heartbeat-every-15-min it would have selected
  keep-poller-parked's six live tests, the run the operator ruled out.
- **b. Rule a for script-class tests, and agent-class and live-class tests
  only when the plan names them with a reason (picked, R3).** Cheap tests
  always run when they read a touched file; costly ones run when someone
  has said why, where the operator can see it.
- **c. The plan names every selected test by hand.** The most control, but
  the green rule could not catch a test left out by mistake.

For the harness, R14: build it in this change, open it as its own change,
or drop it. Recommended: its own change, when a live test is next needed
(Open calls 23).

## Open calls

1. **Size: project**, by `PROCESS.md` §9: 13 requirements, the evidence,
   plan and test record formats change, and every later change relies on
   the green rule. Run lean, as in call 2. The alternative is small: no
   fresh planner and no plan skim, the spec's approval is the go; one agent
   and one operator touchpoint fewer, but the operator does not see the
   plan's budget and risk marks before work starts.
2. **This change runs under its own rules from the go**, by one lead ruling
   recorded at the go, though the space still pins the old process; the
   operator's approval of this spec approves that ruling. Its test plan:
   R4 is the one requirement marked at risk, so the one blind test task
   writes R4's 5 scenario tests as script-class fixture checks, plus at
   most 2 agent-class runs of the swe-pod skill (about 240 s each), since
   only an agent reading the skill shows how it computes green. Every other
   scenario is an inspection check in its build task's done-when, rerun at
   verify. Build tasks split by file, in one wave, with one review, the
   whole-change review on the most capable model, which also runs Q1.
   Verify is one local shard: those checks; the 6 script-class regression
   tests that read files this change touches (I1 to I5 and R16.S1 in
   `tests/build-swe-pod/`, about 8 s in all); and one agent-class guard,
   `test_R12_S1_missing_quality_check` (about 120 s), since R4 edits the
   rule it tests. The other 83 regression tests are not selected: about
   22815 s (6.3 h) of expected run time not spent, 19830 s (5.5 h) of it in
   agent-class tests that read files this change touches. Budget: 30 tests,
   1200 s expected, 10 USD (an estimate), no live run.
3. **Size default budgets** (R1): small 10 tests, 1800 s, 10 USD; project
   40 tests, 7200 s, 30 USD; spike none. For scale: heartbeat-every-15-min's
   verify took 252 s with no agent spend, keep-poller-parked's live runs
   alone about 2890 s, and move-memory-into-spaces's three verify shards
   about 2370 s.
4. **What approves the default budget**: the spec's approval at small size,
   the go after the plan skim at project size. A plan above its default
   needs one ask, at the go (R2.S2).
5. **The ask point is twice the approved budget** in any of its three
   numbers (R2). Between one and two times it, the lead carries on and
   records the overrun. The budget policy's own ask points (about 6 h in
   all, or about 3 h for one run, of agent test runs; money or a shared
   allocation) hold on top. With no operator present, past twice the
   budget nothing more is dispatched (R2.S6). Alternative: ask at the
   budget itself.
6. **Spend in USD covers agent-class runs too**, not only live ones:
   build-swe-pod's verify stopped at the daily API spend limit on agent
   runs.
7. **Verify's selection is approach b** (R3). Tests in other projects'
   spaces are never selected; a cross-project run is the operator's call,
   as move-memory-into-spaces's lead ruled at 2026-10-29T14:56Z.
8. **Cost classes come from the `mode:` value the tests already carry**
   (R12): inspect and script are script class; agent and desk are agent
   class; live is live class. So the 90 tests in this space, and those in
   proj:agent-mesh's, need no edit. A test with none counts as live class
   and is flagged (R12.S3).
9. **"Before a release"**: the pod has no release event, so a full
   regression runs only when the operator asks. The final report lists the
   costly-class regression tests that have not run since their last pass,
   with their expected run time, so the operator can call a full run when
   that list grows.
10. **A `superseded` result** is added beside `not-selected` (R4.S2), beyond
    the brief, since heartbeat-every-15-min's evidence already needed it.
11. **No blind test at small size, even for a requirement marked at risk**
    (R5.S1); the review checks the builder's test for it with that mark in
    view. In a repo with no unit suite, such as swe-pod, a scenario's
    builder test is a check command in the build task's done-when, rerun by
    verify and not promoted, so such a repo's regression suite grows only
    from blind tests of risky requirements. Note that blind script-class
    tests are cheap (heartbeat-every-15-min's 8 took one test agent about
    12 min); the costs in the evidence came from live and agent runs,
    per-task reviews, fix rounds and suggestion passes. Alternative: keep a
    blind test task at small size, for script-class tests only.
12. **Suggestion cap: 5 per change** (R6), counting only suggestions routed
    to the test agent. When more than 5 qualify, the lead takes the 5 at
    highest risk and lists the rest in the final report.
13. **A small change's one review is the whole-change review** (R9.S2), as
    keep-poller-parked's and heartbeat-every-15-min's leads ruled.
14. **Fix rounds carry only Critical and Important findings** (R10.S3). The
    whole-change fix wave runs only when the whole-change review has a
    Critical or Important finding, and then also takes the batched Minor
    ones; with none, they are parked by one ruling and listed in the final
    report. Alternative: the whole-change fix wave always runs for batched
    Minor findings, as move-memory-into-spaces's did for 28.
15. **At most two reruns after harness errors** (R8.S3), three attempts in
    all, within the budget; keep-poller-parked's R1 reproduction needed its
    third.
16. **Which tests are kept** (R11): the plan's test map marks each test to
    keep or not. A scenario test of a requirement meant to last is kept; a
    suggestion test only when it guards a boundary no kept test covers;
    tests of one-time events, such as a migration or a readiness gate, are
    not. Tests not kept stay in the change's archive folder.
17. **The cost report also gives fix rounds and operator asks** (R13.S1),
    beyond the brief's wall time, spend and agent counts.
18. **Q1 is declared** because restating one rule across files cost
    build-swe-pod many fix commits; it rides on the whole-change review and
    adds no agent.
19. **Process version swe-pod-process@2**, since the green rule and record
    formats change. This space's `PROCESS.md` copy and its `pod.yaml`
    `process:` line move at integrate, and I1's version-line check is
    updated with them.
20. **`supersedes`**: build-swe-pod/R5 (only kept tests are promoted), R12
    (not every regression test runs), R13 (heavy checks are asked about
    once, as a budget) and R21 (not every suggestion reaches the test
    agent). Their tests that still hold, such as R12.S1's, stay; R13.S1's is
    the one expected to be superseded outright.
21. **agent-mesh is not in `repos`**: its librarian's integrate mode already
    takes any ordered list of renames, so promoting only some tests needs no
    change there. Its one sentence summing up `PROCESS.md` §8 ("two
    renames") is left for the next agent-mesh change.
22. **swe-pod's SPEC.md**, the base spec, gets a short note beside R5, R12,
    R13 and R21 naming this change, from a build task, as a doc that ships
    with the code.
23. **R14, the harness: drop it from this change.** If wanted, open it as
    its own change when a live test is next needed, so this change stays a
    doc change. If it stays, this change gains a code task and a live smoke
    run (about 700 s, about 5 USD), and the harness ships in swe-pod. In
    R14.S3, "pre-declined" is read as: external imports declined, folder
    trust given to the run's scratch folder only, notices dismissed.
24. **Per-role model map**: out of scope (its own follow-up change), but the
    largest cost lever left for test agents: script-class verify runs and
    inspection checks could run on a cheaper model, with the whole-change
    review kept on the most capable one. Recommended for the follow-up
    change with the note's other items.
