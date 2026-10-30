# SWE Pod process

process: swe-pod-process@2

This is the SWE Pod process, written as instructions to the agent doing the
work. Each rule names the role it binds; where a section says "you", it means
the role that section addresses. The human needs no command (§14).

- A Project Space keeps a copy of this file at its root, and its `pod.yaml`
  pins the version on line 3. Follow the version your space pins.
- Role definitions and the `swe-pod` skill cite this file as
  `PROCESS.md §<n>`.
- Record formats are templates in the swe-pod product, cited here as
  `templates/records/<kind>.md`. Write every record from its template.
- Machines are named only by environment class, a machine kind such as
  `macos-laptop`, `linux-server` or `hpc-login`, never by hostname.

## 1 Shape of a project

A project is one Project Space plus the code repos it names. The Project
Space is a git repo holding specs, plans, records and project-level tests. A
code repo holds the project's deliverables: code, its unit tests and the docs
that ship with it. A project whose deliverable is not code (documents, a
paper) has a deliverable repo in the same place, under the same rules.

Put each thing where this table says:

| Thing | Lives in |
|---|---|
| Specs, plans, ledgers, briefs, reports, reviews, evidence, decisions, handoffs, `STATUS.md` | Project Space |
| Project-level tests (acceptance tests for each spec, cross-repo tests, the regression suite of integrated specs) | Project Space |
| Code, unit tests, docs that ship with the code (README, API docs) | Code repo, on branch `change/<id>` until merged |
| Mesh task messages, workflow records, agent and task ids | Mesh bus, never the Project Space |

Never commit a spec, plan, ledger, brief, report, review, evidence record or
project-level test to a code repo. A change's branches hold only code, unit
tests and docs that ship with the code. Commit every process record and every
project-level test to the Project Space.

### pod.yaml

`pod.yaml` at the root of the space names the code repos and their pins:

```yaml
pod: 1
project: fvm-vqls
process: swe-pod-process@2         # pinned PROCESS.md version
repos:
  qutil: {remote: "<url>", pin: "<sha>"}
  fvm:   {remote: "<url>", pin: "<sha>"}
depends: {fvm: [qutil]}            # merge order: qutil before fvm
gates: {spec: human, plan: human-skim, merge: human}
```

(Values illustrative.)

- `process:` is the version of this file the space follows.
- `repos:` gives each code repo's remote and its pin, the commit the project
  stands on. Pins advance only at integrate (§8).
- `depends:` is the merge order (§8).
- `gates:` says who passes each gate (§2).

### Branches

A branch here always means a git branch in a code repo. For a spec
`add-vqls-backend` that names code repos `qutil` and `fvm`, each of those two
repos gets one branch, `change/add-vqls-backend`, and the Project Space stays
on `main`.

- The Project Space has one branch, `main`, and never another. Keep work in
  flight apart by folder (`changes/<id>/`), not by branch. That is why a
  change's project-level tests wait in its folder until integrate.
- Lead: at the go, for each code repo the spec names, and only those, make
  exactly one code branch, `change/<id>`, from that repo's pin in
  `pod.yaml`, and push it to the repo's remote.
  - Make and push it yourself only when the operator's guidance lets the
    pod commit in its code repos, that is, lets the lead create and push
    each `change/<id>` at the go and builders commit to it and push it (the
    pod commit scope rule in swe-pod's `INSTALL.md`, "Rules for your
    guidance overlay").
  - Otherwise give the human, for each such repo, the exact commands, with
    `<checkout>` a checkout of that repo whose `origin` is its remote in
    `pod.yaml`, and `<pin>` its full pin, and wait until they have run:

    ```
    git -C <checkout> branch change/<id> <pin>
    git -C <checkout> push origin change/<id>
    ```

  Either way, write the go line only once those branches exist on their
  remotes (`git ls-remote <remote> refs/heads/change/<id>` lists each),
  recording each base commit:
  `go by <handle>; branches change/<id>: <repo> <sha7>[, <repo> <sha7>]`.
  Create each branch once, before any agent needs it. Every agent working
  the change commits to it.
- Give a repo the spec does not name no branch and no branch command.
  Verify uses its pin.
- No other branch is pushed: no task, agent or personal branches. You may
  work in your own clone or worktree, but your commits reach the remote only
  on `change/<id>`. Never create a branch unless you are the lead at the go.
- An amendment to the spec stays on the same branch. A new spec gets a new
  branch.
- If another change integrates first and moves `main` under a change branch,
  a build task rebases the branch onto the new `main`, and verify runs again
  (§8).
- The branch is deleted after its merge, as part of the human's merge.
  Merge or delete a branch only on the human's word (§8). Never force-push.

## 2 Stages and states

The process runs five stages, in order:

| Stage | Role | Reads | Writes | Done when | Gate |
|---|---|---|---|---|---|
| **spec** | spec, with the human | the request, the code, earlier specs it touches | `spec.md` | every requirement has a scenario; the human approved | human approves |
| **plan** | plan | the approved spec, the code | `plan.md` | every requirement traces to a build task and every scenario to a test that names the risk it covers; self-review passes | human skims (project size) |
| **build** | build; review per wave | its brief | code and unit tests on `change/<id>` | each task passes its done-when and the review that covers it | none |
| **verify** | test; review | spec, project-level tests, the commit set | evidence, whole-change review | the latest evidence is green by the green rule (§7) at the commit set; no open Critical or Important finding | none |
| **integrate** | human, lead | everything above | merges, pins, docs, plans, final report, archive | merged in dependency order; kept tests promoted; report filed | human merges |

A commit set is one commit per affected code repo plus the Project Space
commit. It is what verify runs against.

- Lead: dispatch no plan, build or test task for a change whose spec has no
  `approved:` line. Given "go" on such a change, dispatch nothing and say,
  exactly:
  `Not dispatched: the spec at changes/<id>/spec.md awaits approval.`
- Writing the blind project-level tests of the requirements the plan marks
  at risk is a test task that starts at the go, in parallel with build, from
  the spec alone (§4, §6). Builders add to those tests only by suggesting
  tests, which the lead routes to the test agent only when they cover a risk
  no planned test covers (§6).
- Read a change's state from its records. Never set it by hand.

| State | Read from |
|---|---|
| proposed | `spec.md` exists without `approved:` |
| approved | `spec.md` has `approved:` |
| planned | `plan.md` exists with its self-review filled in |
| building | the ledger has a dispatch |
| verified | the latest evidence is green by the green rule (§7) at the current commit set, or for a sharded verify its shards' latest records are green together (§7), and the whole-change review has no open Critical or Important finding |
| integrated | `spec.md` has `integrated:`; the folder is under `changes/archive/` |
| abandoned | `spec.md` has `abandoned:` with a reason |

## 3 Spec

You are the spec author, and you work with the human. Describe the work to be
done and nothing else. A spec covers its own change only. No spec of existing
behavior is a precondition: a project starts with its first change, and its
first spec covers only that change. Only you edit a spec, and only the human
approves one.

### Draw out intent

- Look before asking. Read the code and any earlier spec the request touches
  until you can say how things work today. Never ask what the project already
  answers.
- Play the request back in your own words, with anything you found that
  bears on it: a constraint, a conflict, a cheaper path.
- Ask one question per message, the one whose answer most changes what gets
  built. Use plain words, not process jargon.
- Before writing up, give the two or three real ways to do it, what each
  trades off, and a recommendation. The human picks.
- List any default you fill in under Open calls. Never present it as agreed.
  "Just draft it" means draft now, with the defaults listed.

### Write the spec

Write `changes/<id>/spec.md` from `templates/records/spec.md`. The id is
verb-led kebab-case, such as `add-vqls-backend`.

- Title line: `# <id>: <the intent, in one sentence>`.
- Header lines: `- size:` (§9), `- owner: <handle>`, `- repos: [...]` (the
  code repos the change touches), and `- supersedes: []` (earlier
  requirement ids this work changes). Later lines record the change's
  life: `- approved: <handle> <YYYY-MM-DDTHH:MMZ>`,
  `- integrated: <handle> <UTC>` and `- abandoned: <UTC> <reason>`.
- Sections, in this order: Why; Scope, with In and Out; Requirements;
  Quality; Approaches (the two or three considered, the one picked, and
  why); Open calls (the defaults you chose, which the human checks).

A requirement and its scenarios, and a quality check, look like this (values
illustrative):

```markdown
### R1 VQLS linear solver option
The solver SHALL accept VQLS as its linear-solver backend.

#### R1.S1 Converges on the subsonic reference case
- GIVEN the quasi-1D nozzle reference case at nelem 5
- WHEN it is solved with the VQLS backend for 20 iterations
- THEN the L2 density error against the exact isentropic solution is below
  1e-3 (dimensionless, normalized by inlet density)

#### R1.S2 Rejects an unknown ansatz name
- GIVEN an ansatz name the backend does not define
- WHEN the solver starts
- THEN it exits non-zero before building any circuit and names the bad value

### Q1 Linter clean
The changed code SHALL pass the repo's linter with the repo's configuration.
- check: the linter's command in each affected repo; passing is exit status 0
```

### Requirements and scenarios

- One behavior per requirement, with one SHALL or MUST.
- Observable: someone who has never seen the code can tell whether it holds.
- No internals: no class names, library choices or steps.
- At least one scenario per requirement, exercising it, not restating it.
- Cover error and edge cases, not only the happy path.
- Every number carries its unit and tolerance, and any convention it depends
  on: norm, normalization, reference solution.
- Ids are local to the spec (`R1`, `R1.S1`) and qualified outside it
  (`add-vqls-backend/R1.S1`). When later work changes behavior an integrated
  spec requires, list those qualified ids under `supersedes`; the plan then
  has a test task that writes their replacements in `changes/<id>/tests/`,
  verify gives the old tests `superseded by <key>`, and integrate moves them
  out of `tests/` (§7, §8).
- A fix that restores behavior an integrated spec already requires may cite
  that requirement in place of new ones: a five-line spec.
- **Quality checks** go in the Quality section, one per tool or review: what
  is run, on what, and what passing means. They are requirements like any
  other, so verify runs them and evidence records them. Reuse a check an
  earlier spec declared by citing its qualified id. A spec with no Quality
  section asks for none.

### Human review and approval

Ask the human to read `Why` and `Scope` (is this the problem I meant?), then
`Requirements` (is "done" defined right, and does the case I care about most
have a scenario?), then `Open calls`. The test is whether the human would be
content if the pod built exactly this and nothing more.

- The human approves in any words. Record
  `- approved: <handle> <YYYY-MM-DDTHH:MMZ>` with the human's handle and the
  UTC time.
- An edit to `Requirements` after approval reopens approval for that edit
  only. Lead: hold the tasks that serve the edited requirements, let the
  work that does not depend on them carry on, and record
  `approval reopened for <Rn>[, <Rm>]; held T<a>[, T<b>]`.

## 4 Plan

You are the planner. Write `changes/<id>/plan.md` from
`templates/records/plan.md`. The plan covers all downstream work of the
change: build tasks, test tasks, reviews, verify and integrate, as a
dependency graph. Write it for an engineer who has never seen the code or the
spec. It holds the decisions they cannot make alone. A plan longer than the
code it describes has written the code instead.

- At project size you are a fresh agent that never saw the spec
  conversation. Your questions about the spec are the builder check: each is
  answered in the spec, decided and listed under Open calls, or sent to the
  human in one message, most important first.
- First check that every requirement has at least one scenario. If one has
  none, write no plan and return the spec to its author, saying exactly:
  `No plan written: <Rn> has no scenario. Returned to the spec author.`

### Plan sections

1. **Goal and approach** in two or three sentences.
2. **Interface contract:** the public surface the project-level tests drive:
   signatures with types, CLI flags, file formats, output fields, exact
   names. Builders build to it and testers test to it.
3. **Global constraints**, copied verbatim from the spec: units, tolerances,
   version floors, naming rules.
4. **File map:** per repo, the files to create or change, one responsibility
   each, following the repo's patterns.
5. **Tasks**, each in this form:

   ```markdown
   ### T3 VQLS backend
   - role: build
   - repo: qutil
   - after: [T1]
   - runs: local             # local | mesh
   - needs: any              # environment class, or any
   - serves: [R1]
   - risk: at risk: a wrong solve shows only in the converged solution
   - touches: qutil/linsolve/vqls.py, qutil/tests/test_vqls.py
   - consumes: LinearSolver protocol from T1
   - produces: VQLSSolver(ansatz: str, layers: int)
   - steps: failing test, watch it fail, minimal code, watch it pass, commit
   - done when: the unit tests in qutil/tests/test_vqls.py pass at the branch
     head (command and expected output given) and the review that covers it
     has no Critical or Important finding
   ```

   A build task is the smallest unit with its own test cycle that a
   reviewer could reject while approving its neighbor. Steps pin exact
   values and assertions. They give a function body only for an algorithm
   the signature and tests leave open. Each build task entry has
   `- risk: <at risk|small>: <reason>`. Build tasks run `local` for now
   (§11).
6. **Test tasks:** first the risk table and the expensive runs ("Risk and
   the tests it calls for", below); then the test-writing task, which
   writes the blind project-level tests of the requirements marked at risk
   (role test, `after: []`, so it starts at the go); a suggestions task
   (role test, after every build task), which runs only when the lead
   routes a builder's suggestion to the test agent (§6); and the verify run
   (role test, after every build and test task, with `needs:` naming the
   environment class the tests require), whole or in shards, each shard
   with its own `needs:`. A spec with entries under `supersedes` also gets a
   test task that writes their replacements in `changes/<id>/tests/`;
   verify gives the old tests `superseded by <key>`, and integrate moves
   them out of `tests/` (§7, §8).
7. **Review tasks:** the plan has one review per wave of build tasks, a
   review of one build task only where its entry has `- risk: at risk`, and
   the whole-change review. A wave is a group of build tasks the dependency
   summary runs together, and its review covers those of them not reviewed
   alone. A plan whose build tasks form one wave has one review, the
   whole-change review. It covers every build task, those marked at risk
   included; its `after:` list names them, and it comes before verify. A
   wave whose build tasks are all marked at risk has no wave review: their
   own reviews cover it.
8. **Integrate task:** role lead, after verify and the whole-change review;
   it lists the docs and open plans this change touches.
9. **Test map:** one row per scenario, with these columns, in this order:
   `| Scenario | Test | Class | Risk it covers | Expected (s) | Keep | Written by | Unit tests that also cover it |`.
   Keep is `keep` or `not kept: <reason>`. A scenario checked in a build
   task's done-when has Test `T<n> done-when`, Written by `T<n>`, and needs
   no test file. A regression test the plan names for a risk has a row
   whose Scenario cell is its key (`<change>/<value>`, §7) and whose Test
   cell is its test name.
10. **Dependency summary:** which tasks run in parallel, and the longest
    chain. Two tasks that touch a common file never run at the same time:
    make one `after` the other.

### Risk and the tests it calls for

Every test the plan lists names the risk it covers, and the plan lists no
test without one.

- **Risk table.** Section 6 opens with a risk table, one row per
  requirement. The plan marks each requirement `at risk` or `small`, with
  its reason, where the human sees it: at the skim at project size, and in
  the plan itself at small size. A requirement is at risk when a fault in
  it would be costly or would show only late, such as a fix for a reported
  defect seen only in a live session, or a rule that decides whether a
  change is verified; otherwise it is small.

  ```
  | Requirement | Risk | Reason |
  |---|---|---|
  | R<n> | <at risk|small> | <the reason> |
  ```

- **Independent tests.** Risk, not size, decides independent tests: a
  requirement the plan marks at risk gets blind project-level tests,
  written by a test agent that never saw the build, at any size; a
  requirement not at risk gets none beyond its builder's tests, which the
  review checks against its scenarios. A part of the change with small risk
  gets no test beyond its builder's own and the repo's unit suite, unless
  the plan names a further risk that test covers. A test planned for a
  requirement at risk names the part of that risk it covers. A builder's
  test is a unit test or, in a repo with no unit suite, a check in the
  build task's done-when. A plan that marks no requirement at risk has no
  test-writing task. A small, less risky change has few requirements at
  risk, and so few independent tests.
- **Expensive runs.** The plan gives each agent-class or live-class run it
  lists its wall time in s, its spend in USD and the caps the budget policy
  asks for, with the totals of those estimates; a script-class check gives
  its expected run time only. Cost classes are those of §7. An estimate is
  not a quota. The lead asks the operator only about an agent-class or
  live-class run the plan does not list, or one past twice the estimate
  (§11). Section 6 gives every agent-class
  or live-class run the plan lists in this table, with a Total row:

  ```
  | Run | Class | Task | Runs | Wall time (s) | Spend (USD) | Caps |
  |---|---|---|---|---|---|---|
  | <run> | <agent|live> | T<n> | <k> | <s> | <USD> | <caps> |
  | Total | | | <k> | <s> | <USD> | |
  ```

- **Live and heavy tests.** The plan lists a live-class test, or a test
  that is heavy by the 60 s fence (§11), only to reproduce a reported
  defect and confirm its fix: one run at base and one at the branch head,
  each with its reason; or where it gives the reason no cheaper check can
  show the behavior. Where a script-class check can show the behavior, its
  test is script class, and the plan lists no agent-class or live-class run
  for it.
- **Which tests are kept.** A scenario test of a lasting requirement is
  kept; a suggestion test only when it guards a boundary no kept test
  covers; a test of a one-time event, such as a migration, is not, and nor
  is a builder's done-when check, which verify reruns but integrate does
  not promote (§8).

### Parallel tasks and shards

- Plan for parallel work. Two tasks with no dependency between them run in
  parallel by default. Put in a task's `after` list only the tasks whose
  output it needs or that touch a file it touches.
- A task whose work divides may be sharded: split into shards that several
  holders of its role run in parallel, local and remote together. Builders
  take independent files; testers each run part of the suite.
- Name the shards. Each shard is a task entry of its own, `### T<n>a
  <title>`, `### T<n>b <title>`, with its own `runs:`, `needs:` and
  `touches:`. Fields the shards share go once, under a heading that opens
  with all their ids, such as `### T<n>a and T<n>b <title>`.
- Say how the work divides: the files each build shard touches, never a
  file another shard touches; or the tests, unit suites and quality checks
  each test shard runs, or the rule the lead follows to split them at
  dispatch. Between them, the shards of a verify run everything verify must
  give a result for (§7).
- Build shards run `local`, like every build task, for now (§11).

Then come the plan's last two sections, `Self-review` and `Questions for the
spec`. Sort each question as (a) answered, (b) minor, with the default
planned, or (c) for the human.

### Self-review

Before handing over, check: every requirement maps to a build task; every
scenario maps to a test; no step says "TBD", "handle edge cases" or "add
tests"; names and types agree across tasks; every task has role, after, runs
and done-when; every planned test names the risk it covers; every agent- and
live-class run has its wall time, spend and caps, with the totals; a live or
heavy test is listed only to reproduce a reported defect and confirm its
fix, or with the reason no cheaper check can show the behavior; the reviews
follow item 7. The self-review fails on any planned test that names no risk.
Fill in the self-review section with the result.

### The go

At project size the human skims the plan before any dispatch: every task
traces to a requirement, nothing reaches outside the approved scope, no
task hides the real decisions, and each risk mark and estimate gives its
reason. Then the human says go. At small size, approving the spec is the go.

## 5 Build

**Lead.** For each build task, write a brief from
`templates/records/brief.md` at `changes/<id>/tasks/T<n>-brief.md`, dispatch
a fresh builder (§11), and record the base commit in the dispatch line. The
brief holds the plan entry verbatim, the interfaces it touches, the global
constraints, any ruling that bears on it, the commit set to start from, by
sha, and where the result goes.

**Builder.** You work from your brief.

- Ask first if anything in your brief is unclear. If the answer would change
  the result, return NEEDS_CONTEXT with the question rather than guess.
- Work each step test first: write the failing test, watch it fail, write
  the minimal code, watch it pass. Run the repo's full unit suite once
  before reporting.
- A builder's test is a unit test or, in a repo with no unit suite, a check
  in the build task's done-when. Such a check is one command with its
  expected output, red at base and green at the head, and verify reruns it.
- White-box tests are unit tests. Anything that depends on internals, such
  as an internal routine's convergence order or a branch the public surface
  cannot reach, you test in the code repo, in the same task.
- Commit to the change's one branch, `change/<id>`, with trailers
  `Change: <id>` and `Task: T<n>`. Stage and commit only your task's files,
  by path, since other builders may share the branch. Rebase on the branch
  before pushing, and push only to it. Never create a branch. A rebase
  conflict means the plan's independence claim was wrong: stop and report
  BLOCKED.
- Never write or edit a project-level test or the spec. If you believe a
  project-level test is wrong, leave it unchanged, report
  DONE_WITH_CONCERNS, and put this line in `## Concerns`:
  `Disputed test: <test name>; spec clause: <clause>`. The lead routes it
  (§7).
- Return a report from `templates/records/report.md`, at
  `changes/<id>/tasks/T<n>-report.md`: what you did, the files, red and
  green output for each test, your concerns, any test suggestions (§6), and
  a status of DONE, DONE_WITH_CONCERNS, BLOCKED or NEEDS_CONTEXT.

**Lead.** Check that the commits exist and the report holds the test output.
A report is a claim; output and diffs are evidence. Record the result as:

```
T<n> <DONE|DONE_WITH_CONCERNS|BLOCKED|NEEDS_CONTEXT>[, <repo> <sha7>..<sha7>][, unit <p>/<n> pass]
```

**Reviews.** The plan has one review per wave of build tasks, a review of one
build task only where its entry has `- risk: at risk`, and the whole-change
review (§4). Dispatch a wave's review once every build task it covers has
reported, and an at-risk task's own review once that task reports. A plan
whose build tasks form one wave has one review, the whole-change review. It
covers every build task, those marked at risk included, and is then their
review (§7). A wave whose build tasks are all marked at risk has no wave
review: their own reviews cover it. Record the review
that covers a build task under that task's number, one line per build task
it covers, as
`T<n> review: <spec ok|spec issues>; <k> <Severity> [<repo>/<path>:<line>]`.

**Reviewer.** You are a fresh agent. You get the briefs, the reports and
the diffs from base to head of the build tasks your review covers, never a
builder's session. Where other builders commit to the same branch, a task's
diff is its own commits, found by its `Task: T<n>` trailer. Write
`changes/<id>/tasks/T<n>-review.md` from `templates/records/review.md`,
under your review's own task number.

- Return spec compliance (missing, extra, misread) and quality (structure,
  error handling, whether the tests check real behavior).
- For each scenario of a requirement not at risk, the review checks that its
  builder's test exercises it, and records an Important finding where one
  does not.
- Mark each finding Critical, Important or Minor, with file and line:
  `- <Critical|Important|Minor> <repo>/<path>:<line> <text>`.
- Trust the diff over the report. Change nothing you review.

**Fix loop.** Only Critical and Important findings start a fix round, and a
fix round carries only those. At most 5 rounds per task:

- Rounds 1 to 3 go to the same builder; rounds 4 and 5 go to a fresh builder
  on the same model. Each round ends with a review of the fix diff only.
- Lead: record each round as
  `T<n> fix round <r>/5: <a> addressed, <o> open, <sha7>..<sha7>`. Past
  round 5, rule on each open finding (§13).
- A review whose open findings are all Minor starts no fix round: its Minor
  findings are fixed in the whole-change fix wave or parked by a ruling.
  The same holds for a fix round's re-review.

**Models.** Every role runs on the most capable model available. Each role
definition says `model: inherit`, so every role, task and fix round runs on
the session's model, the most capable available; the lead never picks a
lesser model to save cost.

## 6 Project-level tests

You are the test agent writing the change's blind project-level tests: those
of the requirements the plan marks at risk (§4). Write them from the spec,
the interface contract, the global constraints and the test map. Do not read
implementation bodies, diffs, builder reports or build-task steps. Once code
exists you may use its public surface, such as `--help` output or
signatures.

**Lead.** Write the test-writing brief from `templates/records/test-brief.md`.
It carries only what this section allows: the test task's own entry, the
spec's path, and the interface contract, global constraints and test map
copied from the plan, with the commit sets to start from, and under its
global constraints the plan's rows for the expensive runs the task makes.
Its task entry covers the scenarios of the requirements the plan marks at
risk, and no others. It never holds an implementation body, a diff, a
builder report or a build-task step.

**Test agent:**

- Write at least one test per scenario of each requirement the plan marks at
  risk, as the test map gives them, named with the scenario id, such as
  `test_R1_S1_converges_subsonic`. Each names the part of the risk it
  covers.
- Take expected values from outside the code under test: literals,
  hand-checked fixtures, analytical or manufactured solutions, published
  references.
- Test through the public surface against the real system. Mock only what
  is slow or external.
- Before writing a test, name the change in behavior that would make it
  fail. A test only an intentional decision could fail, such as a message's
  wording, is a change detector; test the behavior instead.
- Give numbers units and tolerances. Each test declares its cost class, its
  `expected_s:` (its expected run time in s) and its
  `deliverables: [<repo>:<path>[ as <name>], ...]` (what it reads). Cost
  classes are those of §7; a test over 60 s is marked heavy (§11).
- Put tests in `changes/<id>/tests/`. They stay there until integrate moves
  the kept ones into `tests/`. Never put them in a code repo.

**Watch them fail.** Run the new tests at the base commit set first. A test
for added or changed behavior must fail there, for the stated reason. Record
each result as `T<n> at base: <test name> <fail|pass> (<reason>)[, ...]`.
Lead: if such a test passes at base, return it to the test agent and record
`T<n> returned to test: <test name> passed at base`. A run that ends as a
harness error is no result at base; it follows the harness-error rule (§7).

### Test suggestions from builders

A builder sees where the code is fragile: a near-singular input, a boundary,
a branch only some inputs reach. A test written from the spec alone cannot
see that, so a builder's report may carry suggestions. The test agent learns
where to look from the builder, never what the answer is.

**Builder.** Give each suggestion an id `T<n>.TS<k>` and two parts:

```markdown
### T3.TS1 High CFL near the stability limit
- for the tester: R1 is at risk on the reference case at nelem 5 with the CFL
  number raised to 0.9; the solve may stall above the 1e-3 error bound
  without reporting an error
- for the reviewer: qutil/linsolve/vqls.py:120-148, where the cost function
  flattens as the condition number grows
```

- Write the "for the tester" part in spec terms: the requirement or scenario
  at risk, the input, and the failure you expect. It holds no code, no diff,
  and no expected value the code computed.
- Write the "for the reviewer" part as a code location.

**Lead.** Triage each suggestion by risk. The lead routes a suggestion to
the test agent only when it covers a risk no planned test covers, naming
that risk; a suggestion whose input and failure a planned test already
exercises is declined, naming the test that covers it, and nothing of it
reaches the test agent. Route each suggestion and record where it went, as
`T<n>.TS<k> -> test: covers <risk>` or `T<n>.TS<k> -> <spec|builder>`:

| Suggestion | Goes to | Outcome |
|---|---|---|
| Behavior the spec covers, with a risk no planned test covers | the test agent, with the "for the tester" part only, which names the risk it covers | a project-level test whose expected value comes from the spec; or declined, with a reason |
| Behavior the spec covers, with a risk a planned test already covers | nowhere: the lead declines it | `declined: covered by <test name>` |
| Behavior the spec does not state | the spec author, as a proposed scenario | approved by the human and then tested; or dropped |
| Internal only, nothing observable | back to the builder | a unit test in the code repo |

- If a "for the tester" part gives an expected value the code computed,
  return it to the builder to restate, send nothing to the test agent, and
  record `T<n>.TS<k> returned to builder: carries a computed value`.
- Send the "for the reviewer" part to the review that covers the task and to
  the whole-change review, which check that the builder's unit tests cover
  it. The test agent never sees it.
- Record each outcome as:

  ```
  T<n>.TS<k> outcome: <tested <test name>|proposed as scenario|unit-tested|declined: <reason>|dropped>
  ```

  A suggestion the lead declines because a planned test covers it is
  `T<n>.TS<k> outcome: declined: covered by <test name>`. The final report
  lists every suggestion and its outcome (§8).

## 7 Verify

You are the test agent running verify. When the build tasks are done, or at
a checkpoint the lead picks, run at the commit set and in the environment
class the task names:

- the change's own project-level tests, and the build tasks' done-when
  checks that the test map names as `T<n> done-when`;
- the regression tests its selection picks (Selection, below);
- each affected repo's unit tests;
- every quality check in the spec's Quality section.

Verify runs, besides the change's own tests, unit suites and declared
quality checks, only the regression tests its selection picks. A repo in
`pod.yaml` that the spec does not name is used at its pin.

Return an evidence record, `changes/<id>/evidence/<YYYYMMDDTHHMMZ>.md`, from
`templates/records/evidence.md`:

```yaml
---
id: ev-20261102T1412Z
change: add-vqls-backend
commit_set: {space: 5c02e1a, qutil: 77b01d4, fvm: 3f9c2ab}
env: linux-server
actor: <handle>/test
selection: targeted
touched: [qutil:linsolve/vqls.py, qutil:tests/test_vqls.py]
scenarios: {R1.S1: pass, R1.S2: fail, add-solver-api/R2.S1: pass, add-solver-api/R3.S1: not-selected}
unit: {qutil: pass, fvm: pass}
quality: {Q1: pass}
wall_time_s: 212
---
Failure output for R1.S2; pointers to logs, never the logs themselves.
```

- `commit_set` names every repo in `pod.yaml`. `env` is an environment
  class. `wall_time_s` is the run's wall time in s.
- `selection:` and `touched:` state the selection rule (Selection, below),
  and `harness:` the harness a rerun used (Harness errors, below).
- Give a result for every scenario, every unit suite and every declared
  quality check, and for every regression test. A regression test is a
  `test_*.md` directly in `tests/`, or directly in a folder
  `tests/<change>/` for which `changes/archive/<yyyy-mm-dd>-<change>/`
  exists. Nothing deeper is one: fixture data such as
  `tests/<change>/fixtures/` holds none. Give its result under its key,
  `<change>/<value>`, the key the `swe-pod` skill reads:
  - `<change>`: for a test in `tests/<change>/`, that folder's name. For a
    test directly in `tests/`, the archived change whose plan test map has
    a row with its test name (its file name without `.md`), else the one
    whose final report's `## Scenarios` table has such a row; where several
    do, the one whose archive folder name sorts last. With neither, the
    change of a `scenario:` value that is one id written `<change>/<value>`.
  - `<value>`: the scenario id in that change's row, from its archived plan
    test map, else from its archived final report. With no such row, the
    test's `scenario:` front-matter value, less any `<change>/` part, when
    that value is exactly one id. When it is not (it lists several ids, or
    the test has none), the id its file name carries:
    `test_R<n>_S<m>_<slug>` gives `R<n>.S<m>`, `test_I<n>_<slug>` gives
    `I<n>` and `test_T<n>_TS<k>_<slug>` gives `T<n>.TS<k>`. So each test
    has at most one key.
  - Put `<change>/R<n>.S<m>` under `scenarios:`, `<change>/I<n>` under
    `x-checks:` and `<change>/T<n>.TS<k>` under `x-suggestions:`. A test
    with no key still counts: name it in the body as having none.
- A repo with no unit tests is `none-present`. A spec with no Quality
  section gets `quality: none-declared`, and you run no quality check. A
  `not-run (cap <n> s)` result names its cap.
- Put failure summaries in the body. Logs appear only as pointers:
  space-relative paths or URLs, never a machine path.
- A change is not verified while its latest evidence is not green by the
  green rule (below).

### Selection

The evidence states verify's selection rule in two front-matter keys:

- `selection: targeted`, the default, or `selection: full`. A full
  regression, `selection: full`, runs only on the operator's word. A record
  with no `selection:` key is read as `full`.
- `touched: [<repo>:<path>, ...]` lists every file the change's diff from
  base to head changes, in each repo of the spec's `repos:`.

Under `selection: targeted`, a regression test is picked when either holds:

- it is script class and one of its deliverable paths (less any
  ` as <name>`) is a `touched` path of the same repo, or a folder that holds
  one;
- it is agent or live class and the plan's test map has a row whose Test
  cell is its test name (the plan names it for a risk).

Under `selection: full`, every regression test is picked. Tests in another
project's space are never picked. Where a code repo can be read, the picks
follow its diff from the go line's base to the branch head, and a record
whose `touched` leaves out a file of that diff is not green; where it cannot
(a fixture's placeholder remote), they follow `touched`. Verify runs every
picked test and gives every other regression test `not-selected`; it starts
no session for a test it does not pick.

### Cost classes

Every test has one of three cost classes: `script` (starts no agent session:
inspection checks, scripts, unit suites), `agent` (starts an agent session),
`live` (drives an interactive session or a running node). A test's cost
class is its front-matter `class:` value when it has one. Else it comes from
`mode:`: `inspect` or `script` is script class; a mode that begins `agent`
or `desk` is agent class; a mode that begins `live` is live class. A test
with neither is live class, and the evidence names it under
`## Undeclared cost class`. A test needs no edit to have a class: one with a
`mode:` has it already.

### Results and the green rule

A result is one of `pass`, `fail`, `not-run (cap <n> s)`, `harness-error`,
`not-selected` or `superseded by <key>`, where `<key>` is a result key of
this change in the same record (`R1.S1`, `I1`).

The latest evidence is green when every result verify must give is a pass,
with two results that are no bar:

- `not-selected`, when the record's `selection:` is `targeted` and the test
  is not picked (Selection, above);
- `superseded by <key>`, when `<key>` holds `pass` in the same record and
  the spec's `supersedes` lists the superseded test's requirement:
  `<change>/R<n>` for a test keyed `<change>/R<n>.S<m>`, and for a test
  keyed `<change>/I<n>` or `<change>/T<n>.TS<k>`, any requirement
  `<change>/R<n>`.

Every other result is a bar: `fail`, `not-run`, `harness-error`, a missing
result, a `not-selected` test that the selection picks, and a
`superseded by` result that lacks either condition. The two results that can
be no bar are regression-test results: on a scenario of the spec, a unit
suite, a quality check or a test in `changes/<id>/tests/`, either one is a
bar. A sharded verify applies the same rule over its shards' latest records
together (Sharded verify, below).

### Harness errors

A run that starts an agent session is aborted 120 s after launch when its
session has not reached the test's first step, and ends as `harness-error`,
naming where it stopped, with no pass or fail for its tests. The abort is a
mechanism that stops a stuck run, not a time limit on the test. A rerun
after a harness fix that changes no expected value needs no ask; the
evidence gives `harness: <space sha7>`, the space commit holding the harness
the run used. After a third harness error in one task, the task stops and
reports BLOCKED to the lead. Lead: record each one as
`T<n> harness error: <test name>, attempt <k>/3, stopped at <where>`.

### Failures and the whole-change review

**Lead.** Route each failure:

| Failure | Goes to | Carrying |
|---|---|---|
| Test agrees with the spec, code does not | a builder, as a fix task | scenario id, failing output |
| A builder says the test is wrong | the test agent, who re-derives the expectation from the spec and fixes the test or keeps it with a reason | the spec clause |
| Spec ambiguous, intent settles it | the lead, as a ruling | the clause and the reading chosen |
| Spec ambiguous or wrong, only the human can say | the human, through the spec author | a proposed edit to the spec |
| Flaky or environmental | the test agent, debugging per §13 | the runs that disagree |
| A harness error | the test agent, who fixes the harness and reruns, at most three attempts in the task | where the session stopped |

**Whole-change review.** Dispatch a fresh reviewer. In a plan whose build
tasks form one wave, it is the one review: dispatch it once those build
tasks report, before verify, and it is their review too (§5). Otherwise
dispatch it after the first green run (for a sharded verify, the first time
its shards' records are green together, below). It reviews the whole
change: the spec, the plan, every repo's diff, the latest evidence when
there is one, and the ledger's deferred minors and rulings. It checks
completeness (every requirement has code and a test that covers it),
correctness (the code does what the spec means, edge cases included) and
coherence (the plan's decisions show in the code), and that each builder's
test exercises its scenario (§5). It uses the review format of §5, under
its own task number. The whole-change fix wave runs only when the
whole-change review has a Critical or Important finding, and then also
takes the batched Minor findings; with none, they are parked by one ruling
and listed in the final report. The fix wave goes to one builder, then one
re-review. The lead rules on what remains. In a plan whose build tasks form
one wave, a fix that lands after the whole-change review, such as one routed
from a verify failure, gets a review of its fix diff only.

### Sharded verify

When the plan shards verify (§4), each shard is a verify run of its own. A
test agent runs only the tests, unit suites and quality checks its shard's
brief lists, and returns one evidence record for the shard:

- named for the shard,
  `changes/<id>/evidence/<YYYYMMDDTHHMMZ>-<shard id>.md`, with
  `id: ev-<YYYYMMDDTHHMMZ>-<shard id>`;
- with two more keys: `shard: <shard id>`, and `tests: [<test name>, ...]`,
  the tests that record ran;
- with results only for what the shard ran.

The lead starts every shard at one commit set (§11). The current commit set
is each code branch's head now (a repo the spec does not name, at its pin),
with the shards' space commit: the commit that filed the last of the latest
shard briefs. A shard's latest record is at the current commit set when each
code repo's sha in it is that repo's current one, its space commit is the
shards' space commit, and neither `changes/<id>/tests/` nor `tests/` has
changed since that commit. Otherwise it is out of date: a repo moved, it ran
at another space commit, or `changes/<id>/tests/` or `tests/` changed after
that commit. Take each shard's latest record. The records are green
together only when all three hold:

- every one of them is at the current commit set;
- none of them gives a result that is a bar by the green rule (above), with
  each `superseded by <key>` result's `<key>` looked for in all of them;
- together they give a pass for every scenario, unit suite, declared
  quality check and test of the change, and for every regression test a
  pass or a result that is no bar.

The change is verified only when they are green together and the
whole-change review has no open Critical or Important finding. A shard with
no record yet leaves the change unverified.

While a shard is out of date, the change is not verified; the shard runs
again at the current commit set. Lead:

- If the commit set has moved since the shards' space commit, through a
  branch head or the tests, write every shard's brief again. Its
  `## Start from` names the new commit set under test, so its text changes.
  Dispatch every shard again as §11 says, at the new shards' space commit.
- If the commit set has not moved, dispatch a shard again from its brief,
  at the same shards' space commit. That covers a shard whose record names
  another commit set, and a shard whose run failed for a flaky or
  environmental reason.
- A shard that failed on the code or on a test runs again only once the
  fix lands, routed as the table above says. The fix moves the commit set,
  so every shard runs again.

## 8 Integrate

You are the lead, with the human. Never integrate on evidence older than the
space's current pins and `tests/`.

1. **Fresh evidence.** If `tests/` or any pin in `pod.yaml` moved since the
   latest evidence, a build task rebases each affected change branch onto
   the new `main`, and verify runs again, before any merge.
2. **Reconcile.** The spec must describe what the code does. If the code
   drifted, fix the code. If the spec was wrong and the human agrees, amend
   it; the amendment needs approval.
3. **Final report**, in chat and as `changes/<id>/report.md`, from
   `templates/records/final-report.md`: a table of scenario, test, result
   and evidence id; then every ruling made on the human's behalf with its
   cost if wrong (the list is exhaustive: every `Ruling:` line in the
   ledger); then deferred minors, each fixed in the whole-change fix wave
   or parked by a ruling; every test suggestion and its outcome; open
   questions; each repo's branch and head; then the test cost, the tests
   kept, and the costly regression tests not run.
   - The final report's `## Test cost` gives the plan's estimate beside the
     actual wall time in s and spend in USD of the expensive runs, with the
     ratio of actual to estimate, rounded to 0.1, the total test wall time
     in s, and the counts of test agents, review agents, fix rounds and
     asks to the operator about tests. Spend that no one estimated or no one
     knows is unknown, never 0 USD: the cell gives the known sum and
     `unknown for <k> of <n> runs`, or `unknown` with none known.
   - `## Tests kept` lists each test kept, not kept or moved out, with its
     reason.
   - `## Costly regression tests not run` lists each agent-class or
     live-class regression test not run since its last pass, so the human
     can call a full regression (§7).
4. **Merge**, only on the human's word: merge each `change/<id>` and delete
   it, open a pull request, or keep the branch. Repos merge in `depends`
   order. Discard work only when the human asks in so many words, after you
   confirm.
5. **Update**, after the merge, in one space commit, so the space's
   `tests/` holds only tests of lasting behavior that is still required:
   - Promote only the change's tests the plan's test map marks `keep`: they
     move, with the fixtures they use, from `changes/<id>/tests/` into
     `tests/<id>/`, and the others stay in the change's folder, which moves
     to its archive folder below. Each kept test gives its cost class, its
     expected run time in s and the deliverables it reads (§7); one that
     does not goes back to the test agent before the move.
   - Move out of `tests/`, into the archive folder of the change that wrote
     them, under `superseded-tests/`, the tests and fixtures of each
     requirement the spec supersedes, and each test the change made stale
     that no test task updated (one that fails only because the change
     removed what it relies on), so no test left in `tests/` is known to
     fail.
   - Advance every affected pin, mark `integrated:` on the spec, and move
     the folder to `changes/archive/<yyyy-mm-dd>-<id>/`.

   The librarian makes that commit in its integrate mode (agent-mesh
   `skills/space-librarian/SKILL.md`, section 3): the moves are its
   renames, the tests' moves first and the folder's last, and each edited or
   new file is a record, named by its path after the moves. Docs that ship
   with the code are
   updated by a build task before the merge; project docs in the space
   (README, decisions) are updated by you here. Give each open plan that
   depended on this change a ledger line naming what moved.
6. **Prune** what can be regenerated, such as diff files made for review.

## 9 Sizes

Every size starts with a spec. Pick the size when the spec is written:

| Size | When | Spec | Plan | Human gates |
|---|---|---|---|---|
| small | one intent, a few requirements, one repo, low risk | short | short; the planner may be the spec author | spec (also the go), merge |
| project | several requirements or repos, interface or data-format changes, anything costly to get wrong | full | full; fresh planner | spec, plan skim, merge |
| spike | building something throwaway is the fastest way to learn | the question and what would answer it | none | none |

- A spike has one build agent, no review, and never merges. Its output is a
  write-up in `notes/`. Keeping anything it produced is a new change with
  its own spec.
- If a change grows mid-flight, whoever notices says so, and it steps up a
  size.
- A change that needs "and also" is two changes.
- Size sets the gates and the plan's length, not the tests: risk, not size,
  decides independent tests (§4).

## 10 Roles

Each pod role is held by an agent, local or on the mesh, where the role is
`swe.<role>`. Stay in your lane:

| Role | Writes | Never |
|---|---|---|
| **human** | approvals, merges | needs a command |
| **spec** | `spec.md` | writes code or tests |
| **plan** | `plan.md` | edits the spec, code or tests |
| **lead** | ledger, briefs, rulings, final report; creates each `change/<id>` branch at the go; files every record of the change through the space's librarian | writes code, tests or the spec |
| **build** | code, unit tests (white-box included), shipped docs, on `change/<id>`; test suggestions in its report | writes project-level tests or the spec; reviews its own work; creates a branch |
| **test** | project-level tests, evidence | writes code or the spec; reads implementation bodies, diffs or builder reports while writing tests |
| **review** | review records | changes what it reviews; trusts a report over the diff |

**Independence.** These must be different agents: test and build, test and
spec, review and build, and spec and plan at project size. A different agent
means at least a fresh context started from a brief, never another agent's
session. Independence between agents comes from a fresh session or another
node, never from a lesser model. Every role runs on the most capable model
available. One node may hold several roles if each task runs as its own
agent.

**Placement.**

| Role | Usually |
|---|---|
| spec, lead | local, with the human |
| plan | local, or remote at project size |
| build | local or remote; several at once when the plan allows |
| test | remote, on a node of the environment class the checks need; agent-class and live-class tests are costly |
| review | anywhere |

Remote build waits on the executor git exception (§11); until then, build
runs local.

**Single seat.** Without a mesh, one interactive session is spec author,
planner, lead and the space's librarian, and dispatches fresh local subagents
for build, test and review. At project size it plans through a fresh local
subagent too, since spec and plan must be different agents. Without a mesh,
file every record through agent-mesh's `space-librarian` skill. It applies
the same profile, reference and id checks a mesh librarian applies (§12) and
makes the commit. That needs the Agent Mesh product's code, but no bus,
core, lore or remote agent. The records are the same either way, so a
project can move between single-seat and mesh use at any stage boundary.

## 11 Dispatch

You are the lead. Dispatch every task from the same brief,
`changes/<id>/tasks/T<n>-brief.md`, whatever runs it (§5, §6). The brief
holds the task text, the interfaces it touches, the global constraints, any
ruling that bears on it, the commit set to start from, and where the result
goes. Machine paths never go in a brief. Each role's definition is
`agents/swe-<role>.md` in the swe-pod product.

- **`runs: local`.** Start a fresh subagent on your own node, of type
  `swe-<role>`. Its prompt holds the brief's space-relative path and, on its
  own line, the checkout paths on this node. Before the role definitions are
  installed, start a general-purpose subagent and put the definition's text
  above the same prompt. The agent writes its outputs at their final
  space-relative paths.
- **`runs: mesh`.** Post a `task.request` to the role queue `swe.<role>`
  (PROTOCOL §5). Any holder of that role claims it, accept-as-claim, on any
  node. `needs:` narrows it to nodes of one environment class: post to an
  agent of that class directly, or to a role only such nodes hold. Set
  `project: proj:<name>` so the claiming node loads the space for its
  executor. The Context names the role definition, relative to the bus root,
  and the brief, relative to the space; the Goal tells the executor to read
  the role definition first. For a node that may predate the change, the
  Context also gives the repo URLs, the space commit that holds the brief,
  and the commit set under test, as separate lines.

  ```markdown
  ---
  schema_version: 1
  id: 20261102T1405-0003
  from: <lead agent id>
  to: role:swe.test
  type: task.request
  project: proj:fvm-vqls        # loads the space for the executor
  depends_on: []
  timeout_min: 120
  ---
  ## Goal
  Read the role definition named in Context before anything else. Then run
  verify for change add-vqls-backend at commit set space 5c02e1a,
  qutil 77b01d4, fvm 3f9c2ab.
  ## Context
  Project Space proj:fvm-vqls.
  Role definition: swe-pod/agents/swe-test.md
  Brief: changes/add-vqls-backend/tasks/T7-brief.md
  ## Done when
  An evidence record is in the result, with a result for every scenario, unit
  suite and declared quality check.
  ## On failure
  Return the failing output. Do not edit tests or code.
  ```

- **Mesh executor.** If you execute a pod task from the mesh, read the role
  definition your `task.request` names before anything else, then the brief.
- **Build tasks run local.** Dispatch build tasks with `runs: local` until
  the mesh executor's git exception lands. A mesh executor is told not to
  touch git, so a remote builder cannot commit to `change/<id>`. The
  exception, deferred to the change that first puts builders on remote
  nodes, will let a `swe.build` executor commit to and push only
  `change/<id>`, in the repo its brief names.
- **Shards.** Dispatch a sharded task's shards together, one brief per
  shard.
  - Each shard's brief holds its own plan entry and lists, in `## Task`,
    the tests or files that shard runs or touches. Write the split there
    when the plan leaves it to you. Its `## Start from` names the commit
    set under test as far as it is known when you write it: each branch
    head by sha, and the newest space commit that changed
    `changes/<id>/tests/` or `tests/`, by sha.
  - Record one dispatch line per shard, such as
    `dispatch T7a -> test (local, macos-laptop)` and
    `dispatch T7b -> test (mesh, linux-server)`. File the ledger with those
    lines first, then the briefs.
  - The librarian commits each record alone, so the commit that files the
    last brief is the last of the shard briefs and dispatch lines. It is
    the shards' space commit; with the branch heads, it is the shards'
    commit set. Start no shard before it exists, and give it to every
    shard at dispatch, on its own line in the local prompt or in the mesh
    task's Context.
  - Test shards run local and mesh together, each as its entry's `runs:`
    and `needs:` say. Build shards run local, like every build task, until
    the mesh executor's git exception lands.
- **Results.** A mesh agent returns its files (report, tests, review,
  evidence) in its task result, listed under `files:` with each file's
  space-relative path and sha256: text only, at most 1048576 bytes each.
  Check every result, local or mesh, and file it, with your own records,
  through the Project Space's librarian, which commits. Usually your node is
  that librarian and commits directly. Builders' code reaches the others
  through the pushed `change/<id>` branches.
- **Lanes.** File only what the task's role writes (§10). Every file a test
  task changed, its report included (§12), must be under
  `changes/<id>/tests/` or `changes/<id>/evidence/`. Refuse to file anything
  else, and record `refused <space path>: lane line <n>`.
- **Ordering.** Dispatch a task once every task in its `after` list is done,
  its review included, so independent tasks run in parallel. In a review
  task, `after: [T<k>]` means T<k> has reported and its commit exists; T<k>
  is done only when that review closes. A wave's review lists each build
  task it covers, and each of them is done only when that review closes.
  On the mesh this is a workflow you drive (PROTOCOL §8.1), and its record
  lives in the bus. Mesh workflows do not yet take steps with `after` lists
  (PROTOCOL §8.1 advances one cursor), so until they do, follow the interim
  rule: each cycle, the lead dispatches every task whose `after` tasks are
  all done.
- **What the space records.** Record each dispatch as
  `dispatch T<n> -> <role> (<local|mesh>, <env class|any>)[, base <repo> <sha7>]`.
  The line names the role, `local` or `mesh`, and the environment class, and
  no machine. Mesh task ids and agent ids stay in the bus, so the
  space can be handed to someone with no access to the mesh.
- **Fences.** Pod roles loosen no mesh fence. The git gate, the solver-run
  fence and the budget policy bind every pod agent, and heavy checks run
  under them like any solver run. Judge heaviness per check, from that
  check's own recorded expected run time alone: over 60 s is heavy, 60 s or
  less is not, whatever its cap, its label or the task's total time. A
  check that records no expected run time, such as a unit suite or a
  declared quality check, takes it from its brief or from the record of its
  last run when either gives one, and is heavy only when that time is over
  60 s. With no known time, the running agent's own fence still binds the
  run.
- **Asks about test runs.** The lead asks the operator about a test run
  only when it is an agent-class or live-class run the plan does not list,
  or when it would take the expensive runs past twice the plan's estimate
  in wall time or in spend, counting their actuals so far plus the estimate
  of the run to dispatch. Every other run the plan lists goes ahead with no
  ask. With no operator present, a run past that point is not dispatched.
  The budget policy's own ask points still hold.
  - An ask gives the operator the run, why it is asked about, and the
    expensive runs' actuals so far and what remains of twice the estimate.
    Record it as
    `ask: <handle> before T<n>: <run>; <unlisted|past twice the estimate>; spent <s> s, <USD> USD of <s> s, <USD> USD estimated`,
    and a run held for want of an operator as
    `T<n> not dispatched: <run>; past twice the estimate, no operator present`.
  - The brief of a test task quotes the plan's rows for the expensive runs
    it makes, with their caps and estimates: under `## Global constraints`
    in a test-writing brief, and in `## Task` in a verify brief. The rows
    hold nothing of the build.
  - After each test task, the lead records the actual wall time in s and
    spend in USD of its runs beside the plan's estimate, as
    `T<n> cost: actual <s> s, <USD|unknown> USD; estimate <s> s, <USD> USD`.
  - A rerun after a harness fix that changes no expected value needs no
    ask (§7).

## 12 The Project Space

The space has one branch, `main`; work in flight is kept apart by folder
(§1). A new space starts from `templates/space/` in the swe-pod product.

```
<project>-space/
  space.yaml              memory-space manifest (kind: project, shareable)
  pod.yaml                repos, pins, merge order, gates
  PROCESS.md              this process, pinned by version
  AGENTS.md               read order for an agent or human arriving cold
  STATUS.md               generated, never edited (§15)
  tests/                  regression suite: the kept tests of integrated specs
  changes/<id>/
    spec.md
    plan.md
    ledger.md
    tasks/T<n>-brief.md  T<n>-report.md  T<n>-review.md
    tests/                project-level tests for this change
    evidence/<utc>.md  <utc>-<shard id>.md  <utc>-<task id>-report.md
    report.md
  changes/archive/<yyyy-mm-dd>-<id>/
  decisions/<utc>-<slug>.md
  handoffs/<utc>-<id>.md
  notes/  lore/
```

A test task's report goes in the test lane (§11), under `evidence/`, as
`<YYYYMMDDTHHMMZ>-<task id>-report.md`. Every other task's report goes under
`tasks/`, as `T<n>-report.md`.

**Arriving cold.** Read `AGENTS.md`, then `STATUS.md`, then the ledgers. From
the space and the code repos alone you can tell each open change's state and
its next task. Answer "where are we?" from those records, naming each open
change's state and next task.

**Writers.** Every commit to the space goes through its librarian.

- The space's librarian is its only mesh writer (memory-spaces §6.3, in
  agent-mesh's `spec/memory-spaces.md`), and one librarian may manage
  several spaces. Without a mesh, the session runs agent-mesh's
  `space-librarian` itself (§10).
- What goes into a change folder comes from that change's lead; the
  librarian commits it.
- Space-wide files (`tests/`, `pod.yaml`, `changes/archive/`) change only at
  integrate, one integrate at a time. `STATUS.md` is regenerated, so it
  never conflicts.
- Decisions, handoffs and evidence are one file per event, named by UTC
  time. Any other new record id is collision-free (memory-spaces §3.4):
  `<category>-<YYYYMMDDTHHMMZ>-<4 hex>`, since more than one mesh may write
  the space.
- The librarian checks each record's header profile, references and id
  before filing it, and refuses one that fails. Record a refusal as
  `refused <space path>: <profile|reference|id|lane> line <n>`, and never
  quote the text that matched.

**Header profile.** Records use the shareable profile of the memory-spaces
concept: actors are human handles or `<handle>/<role>`, machines are
environment classes, and paths are relative to the space or are URLs. Write
no hostname, agent id, mesh task id, home path or credential name into any
record.

**The ledger**, `changes/<id>/ledger.md`, from
`templates/records/ledger.md`, is the change's log. It is what lets anyone
pick the change up after a context loss or a handoff. Trust it, and the git
logs, over memory. It is one fenced block, one event per line, as
`<YYYY-MM-DDTHH:MMZ> <event>`, with continuation lines indented 18 spaces.
The template lists every event form:

```
2026-11-02T14:05Z dispatch T3 -> build (local, any), base qutil 77b01d4
2026-11-02T14:06Z dispatch T5 -> test (mesh, linux-server)
2026-11-02T14:41Z T3 DONE, qutil 77b01d4..8e1d0c4, unit 14/14 pass
2026-11-02T14:50Z T3 review: spec ok; 1 Important qutil/linsolve/vqls.py:88
2026-11-02T15:02Z T3 fix round 1/5: 1 addressed, 0 open, 8e1d0c4..a91f2e0
2026-11-02T15:20Z T5 at base: R1.S1 fail (no VQLS backend), R1.S2 fail (flag unknown)
2026-11-02T15:31Z Ruling: flag named --vqls-ansatz, not --ansatz; existing
                  backend flags carry a prefix; rename costs one task
```

## 13 When things go wrong

- **Debugging.** Reproduce, read the whole error, check what changed. State
  one hypothesis and test it with the smallest change. Write a failing test
  before the fix. After three failed fixes, stop: the design is the likelier
  problem, and the lead takes it to the human with what was tried.
- **Disagreeing with a review.** Check the finding against the code. Push
  back with reasons when it would break something, is unneeded, or misses
  context. Never agree just to be agreeable.
- **Changing course.** Same intent, refined: edit the spec, and approval
  reopens for the edit. Narrower scope: integrate what is done and open a
  new change for the rest. Intent changed: a new change, and the old one
  marked abandoned. Code edited by hand: reconcile before integrate.
- **Rulings.** Lead: when the spec supports an answer, decide and keep
  going. A ruling is one ledger line:
  `Ruling: <what>; <why>; <cost if wrong>`. Every ruling reaches the human
  in the final report. Never drop a finding silently: fix it, or park it
  with a ruling.
- **Stop and ask** only for: an irreversible or destructive action; a
  security-sensitive one; an effect outside the change's branches and
  folder (merging, pushing a shared branch, publishing, spending money or a
  shared allocation, a run past the mesh fence); a test run that needs an
  ask (§11); a question only the human can answer that changes what gets
  built; or a plan so broken that every way forward is a guess.
- **Handoff.** At any stage boundary, the giver marks done only what has
  evidence and writes `handoffs/<utc>-<id>.md` from
  `templates/records/handoff.md`: state, half-done work, open questions,
  and the next command. The receiver re-runs the latest verify before
  building on what it inherited.

## 14 Talking to the pod

There are no commands. These are examples, not syntax.

| The human says | What happens |
|---|---|
| "I want the nozzle solver to take a VQLS backend" | The spec author reads the code, plays the request back, asks the one question that matters most |
| "Just draft it" / "Approved" | Draft with defaults listed / approval recorded |
| "Go" | The lead dispatches every task with nothing left in its `after` list; on an unapproved spec it dispatches nothing and says the spec awaits approval (§2) |
| "Where are we?" | Status, read from the records |
| "Run the tests on the Linux server" | The verify task goes to the mesh with `needs: linux-server` |
| "Merge it" / "Hand this to `<handle>`" / "Throw it away" | Integrate / a handoff record / confirm, then mark abandoned |

Answer the same way: plain words, one question at a time, full paths to
anything worth opening, and every load-bearing fact in the final message.

## 15 Status view

`STATUS.md` is generated, never edited by hand. Regenerate it from the specs,
plans, ledgers, evidence and handoffs whenever the lead files a record, with
the `swe-pod` skill. Regenerated from unchanged records, it gives the same
text.

- Per open change: state, owner, gate approvals with handle and time, each
  repo's branch head, each task with role, `local` or `mesh`, state and
  latest result, the latest evidence's results (for a sharded verify, each
  shard's latest record), and open review findings by severity.
- Task states are waiting, ready, dispatched, done and blocked.
- A project header lists the pins and the open changes by state.

It is Markdown, so it reads the same in a terminal, a previewer or on
GitHub, and `mesh-check` can summarize it.
