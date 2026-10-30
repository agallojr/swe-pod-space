# T3 brief

- change: right-size-testing
- task: T3
- role: test

## Task
### T3 Replace the version-line checks I1 and I3
- role: test
- after: []
- runs: local
- needs: any
- serves: [R12, R13]
- done when: `changes/right-size-testing/tests/test_I1_process_md.md` and
  `test_I3_d3_templates.md`, each the build-swe-pod test of that name with
  its checks unchanged but the process version line `swe-pod-process@2`
  (its `mode: inspect` makes it script class); each run at the base commit
  set and failing there only on that check (I1.2, I3.14)

## Spec
changes/right-size-testing/spec.md

## Interface contract
The exact forms below are what the builder writes into swe-pod and what the
tests and checks read. "The files" means every swe-pod file that states the
rule: `PROCESS.md`, `agents/`, `skills/swe-pod/`, `templates/`, `README.md`
and `INSTALL.md`.

### 2.1 Cost classes (R13)

- Classes: `script` (starts no agent session: inspection checks, scripts,
  unit suites), `agent` (starts an agent session), `live` (drives an
  interactive session or a running node).
- A test's class is its front-matter `class:` value when it has one. Else it
  comes from `mode:`: `inspect` or `script` is script class; a mode that
  begins `agent` or `desk` is agent class; a mode that begins `live` is live
  class. A test with neither is live class, and the evidence names it under
  `## Undeclared cost class`.
- Each test declares `expected_s:` (its expected run time in s) and
  `deliverables: [<repo>:<path>[ as <name>], ...]` (what it reads).

### 2.2 Verify's selection (R4)

- Evidence front matter gains two keys:
  - `selection: targeted`, the default, or `selection: full`, only on the
    operator's word. A record with no `selection:` key is read as `full`.
  - `touched: [<repo>:<path>, ...]`: every file the change's diff from base
    to head changes, in each repo of the spec's `repos:`.
- Under `targeted`, a regression test is **picked** when either holds:
  - it is script class and one of its deliverable paths (less any
    ` as <name>`) is a `touched` path of the same repo, or a folder that
    holds one;
  - it is agent or live class and the plan's test map has a row whose Test
    cell is its test name (the plan names it for a risk).
- Where a code repo can be read, the picks follow its diff from the go
  line's base to the branch head, and a record whose `touched` leaves out a
  file of that diff is not green; where it cannot (a fixture's placeholder
  remote), they follow `touched`.
- Verify runs every picked test and gives every other regression test
  `not-selected`. Tests in another project's space are never picked.

### 2.3 Results

A result is one of `pass`, `fail`, `not-run (cap <n> s)`, `harness-error`,
`not-selected` or `superseded by <key>`, where `<key>` is a result key of
this change in the same record (`R1.S1`, `I1`).

### 2.4 The green rule (R5)

The latest evidence is green when every result verify must give is a pass,
as today, with two results that are no bar:

- `not-selected`, when the record's `selection:` is `targeted` and the test
  is not picked (2.2);
- `superseded by <key>`, when `<key>` holds `pass` in the same record and
  the spec's `supersedes` lists the superseded test's requirement:
  `<change>/R<n>` for a test keyed `<change>/R<n>.S<m>`, and for a test keyed
  `<change>/I<n>` or `<change>/T<n>.TS<k>`, any requirement `<change>/R<n>`.

Every other result is a bar: `fail`, `not-run`, `harness-error`, a missing
result, a `not-selected` test that 2.2 picks, and a `superseded by` result
that lacks either condition. A sharded verify applies the same rule over its
shards' latest records together.

### 2.5 The status line (R5.S1)

`status-format.md`'s regression part of the latest-evidence line becomes

```
regression <p>/<n> pass[, <k> not-selected][, <j> superseded]
```

`<n>` counts the regression tests that need a pass, `<p>` their passes, and
`<k>` and `<j>` the regression tests whose `not-selected` or `superseded`
result is no bar; each bracketed part only when its count is not 0. So
R5.S1's record shows `regression 6/6 pass, 84 not-selected`.

### 2.6 The plan's forms (R1, R2, R6, R8, R10, R12)

- Section 6 of the plan template opens with a risk table, one row per
  requirement:

  ```
  | Requirement | Risk | Reason |
  |---|---|---|
  | R<n> | <at risk|small> | <the reason> |
  ```

- Each build task entry has `- risk: <at risk|small>: <reason>`.
- Section 6 then gives the expensive runs, every agent-class or live-class
  run the plan lists, with a Total row:

  ```
  | Run | Class | Task | Runs | Wall time (s) | Spend (USD) | Caps |
  |---|---|---|---|---|---|---|
  | <run> | <agent|live> | T<n> | <k> | <s> | <USD> | <caps> |
  | Total | | | <k> | <s> | <USD> | |
  ```

- The test map, section 9, has these columns, in this order:

  ```
  | Scenario | Test | Class | Risk it covers | Expected (s) | Keep | Written by | Unit tests that also cover it |
  ```

  Keep is `keep` or `not kept: <reason>`. A scenario checked in a build
  task's done-when has Test `T<n> done-when`, Written by `T<n>`, and needs
  no test file. A regression test the plan names for a risk has a row whose
  Scenario cell is its key (`<change>/<value>`) and whose Test cell is its
  test name.
- Review tasks: one per wave of build tasks (a wave is a group the
  dependency summary runs together), a review of one build task only where
  its entry has `- risk: at risk`, and the whole-change review. A plan whose
  build tasks form one wave has one review, the whole-change review.
- Self-review adds four items: every planned test names the risk it covers;
  every agent- and live-class run has its wall time, spend and caps, with
  the totals; a live or heavy test is listed only to reproduce a reported
  defect and confirm its fix, or with the reason no cheaper check can show
  the behavior; the reviews follow the rule above.

### 2.7 Ledger forms (R3, R7, R9, R11)

New forms in `templates/records/ledger.md`. The `heavy:` form is retired;
`ask:` takes its place.

```
T<n> cost: actual <s> s, <USD|unknown> USD; estimate <s> s, <USD> USD
ask: <handle> before T<n>: <run>; <unlisted|past twice the estimate>; spent <s> s, <USD> USD of <s> s, <USD> USD estimated
T<n> not dispatched: <run>; past twice the estimate, no operator present
T<n> harness error: <test name>, attempt <k>/3, stopped at <where>
T<n>.TS<k> -> test: covers <risk>
T<n>.TS<k> outcome: declined: covered by <test name>
```

The ask point is past twice the estimate in wall time or in spend, counting
the expensive runs' actuals so far plus the run to dispatch (open call 4).

### 2.8 Harness errors (R9)

A run that starts an agent session is aborted 120 s after launch when its
session has not reached the test's first step, and ends as `harness-error`
naming where it stopped, with no pass or fail for its tests. A rerun after a
harness fix that changes no expected value needs no ask; the evidence gives
`harness: <space sha7>`, the space commit holding the harness the run used.
After a third harness error in one task, the task stops and reports BLOCKED.

### 2.9 The final report (R12, R14, open call 8)

`templates/records/final-report.md` gains three sections:

```
## Test cost
| Expensive runs | Estimate | Actual | Actual / estimate |
|---|---|---|---|
| wall time (s) | <s> | <s> | <ratio, to 0.1> |
| spend (USD) | <USD> | <USD, or unknown> | <ratio, to 0.1, or unknown> |

- total test wall time: <s> s
- test agents: <n>
- review agents: <n>
- fix rounds: <n>
- asks to the operator about tests: <n>

## Tests kept
- kept: <test name>: <reason>
- not kept: <test name>: <reason>

## Costly regression tests not run
- <test name>: last pass <ev id>
```

When some expensive runs have no known spend, the Actual spend cell gives
the known sum and `unknown for <k> of <n> runs`; with none known, `unknown`.
Never 0 USD for a run whose spend no one knows.

### 2.10 Models (R15)

Each role file says `model: inherit`. `PROCESS.md`, `agents/swe-lead.md` and
`README.md` each hold the sentence `Every role runs on the most capable model
available.` No text lets a role, task, fix round or independence check run on
a lesser or cheaper model, or says a later round needs a stronger model:
rounds 4 and 5 go to a fresh builder on the same model, and independence
comes from a fresh session or another node.

### 2.11 Process version (open call 16)

`PROCESS.md` line 3 and `templates/space/pod.yaml` say
`process: swe-pod-process@2`, as does the illustrative `pod.yaml` in
`PROCESS.md` §1.

## Global constraints
From the spec, verbatim where it states them:

- "No pod role ever runs on a lesser model to save cost. Every role runs on
  the most capable model available, and the lead never picks a cheaper one."
- "an estimate is not a quota" (R2); "by default, past twice it in wall time
  or spend" (R3); "an abort 120 s after launch (a mechanism that stops a
  stuck run, not a time limit on the test)" (R9).
- "The budget policy's own ask points still hold." (R3)
- Out of scope: the per-role model map, archiving branches, one-time
  permissions, the note's three test-check fixes, build-swe-pod's deferred
  Minors, the skill reading only the first id of a Reviews cell, a reusable
  live-session harness, other spaces' `PROCESS.md` copies and pins, the
  operator's guidance overlay and budget policy, any full regression run,
  agent-mesh.
- Units on every number; UTC, ISO 8601, for every time.
- Records carry no hostname, agent id, mesh task id, home path or credential
  name.

Operator decisions (the spec's open calls, and the plan's risk and run
estimates):

- Open call 16: the process version becomes swe-pod-process@2; the space's
  PROCESS.md copy, pod.yaml's process: line and I1's version-line check move
  with it at integrate.
- Section 2.11 of the interface contract above: PROCESS.md line 3 and
  templates/space/pod.yaml say process: swe-pod-process@2.
- The replacements are script-class checks of about 1 s each. Start no agent
  session.

## Test map
| Scenario | Test | Class | Risk it covers | Expected (s) | Keep | Written by | Unit tests that also cover it |
|---|---|---|---|---|---|---|---|
| R1.S1 | T1 done-when | script | small: the plan template and planner state risk-named tests | 1 | not kept: a builder's check (open call 10) | T1 | none |
| R1.S2 | T1 done-when | script | small: the planner's self-review fails a test with no risk | 1 | not kept: a builder's check | T1 | none |
| R2.S1 | T1 done-when | script | small: the expensive-runs table and its totals | 1 | not kept: a builder's check | T1 | none |
| R3.S1 | T1 done-when | script | small: no ask for listed runs; the cost line | 1 | not kept: a builder's check | T1 | none |
| R3.S2 | T1 done-when | script | small: the ask at twice the estimate | 1 | not kept: a builder's check | T1 | none |
| R4.S1 | T1 done-when | script | small: script-class tests of touched files are picked | 1 | not kept: a builder's check | T1 | none |
| R4.S2 | T1 done-when | script | small: unnamed live tests are not picked | 1 | not kept: a builder's check | T1 | none |
| R5.S1 | test_R5_S1_not_selected_green | script, or agent where needed | at risk: a targeted verify read as not green | 5 | keep | T2 | none |
| R5.S2 | test_R5_S2_superseded_with_replacement | script, or agent where needed | at risk: a superseded test with a passing replacement read as not green | 5 | keep | T2 | none |
| R5.S3 | test_R5_S3_superseded_without_replacement | script, or agent where needed | at risk: a false green from a superseded test with no passing replacement or no supersedes entry | 5 | keep | T2 | none |
| R5.S4 | test_R5_S4_picked_test_not_passed | script, or agent where needed | at risk: a false green from a picked test given not-selected or not-run | 5 | keep | T2 | none |
| R6.S1 | T1 done-when | script | small: blind tests for at-risk requirements only | 1 | not kept: a builder's check | T1 | none |
| R6.S2 | T1 done-when | script | small: no test-writing task when nothing is at risk | 1 | not kept: a builder's check | T1 | none |
| R7.S1 | T1 done-when | script | small: a covered suggestion is declined | 1 | not kept: a builder's check | T1 | none |
| R7.S2 | T1 done-when | script | small: an uncovered suggestion reaches the test agent | 1 | not kept: a builder's check | T1 | none |
| R8.S1 | T1 done-when | script | small: live runs only to reproduce and confirm | 1 | not kept: a builder's check | T1 | none |
| R8.S2 | T1 done-when | script | small: the cheaper check is chosen | 1 | not kept: a builder's check | T1 | none |
| R9.S1 | T1 done-when | script | small: the 120 s abort and harness-error | 1 | not kept: a builder's check | T1 | none |
| R9.S2 | T1 done-when | script | small: reruns need no ask; BLOCKED after the third | 1 | not kept: a builder's check | T1 | none |
| R10.S1 | T1 done-when | script | small: one review per wave and one per at-risk task | 1 | not kept: a builder's check | T1 | none |
| R10.S2 | T1 done-when | script | small: a small change's one review | 1 | not kept: a builder's check | T1 | none |
| R11.S1 | T1 done-when | script | small: Minor findings start no fix round | 1 | not kept: a builder's check | T1 | none |
| R11.S2 | T1 done-when | script | small: a fix round carries Important findings only | 1 | not kept: a builder's check | T1 | none |
| R12.S1 | T1 done-when | script | small: only kept tests are promoted | 1 | not kept: a builder's check | T1 | none |
| R12.S2 | T1 done-when | script | small: superseded and stale tests leave the suite | 1 | not kept: a builder's check | T1 | none |
| R13.S1 | T1 done-when | script | small: promoted tests carry their class | 1 | not kept: a builder's check | T1 | none |
| R13.S2 | T1 done-when | script | small: classes from mode with no edit | 1 | not kept: a builder's check | T1 | none |
| R14.S1 | T1 done-when | script | small: the cost table | 1 | not kept: a builder's check | T1 | none |
| R14.S2 | T1 done-when | script | small: unknown spend is not 0 USD | 1 | not kept: a builder's check | T1 | none |
| R15.S1 | T1 done-when | script | small: no text allows a lesser model | 1 | not kept: a builder's check | T1 | none |
| I1 | test_I1_process_md | script | the version line moves to @2 (open call 16) | 1 | keep: replaces build-swe-pod's I1 | T3 | none |
| I3 | test_I3_d3_templates | script | the template pod.yaml's version line moves to @2 | 1 | keep: replaces build-swe-pod's I3 | T3 | none |
| build-swe-pod/R12.S1 | test_R12_S1_missing_quality_check | agent | at risk, R5: the loosened rule must still keep a change with a missing quality check unverified | 120 | already in tests/ | build-swe-pod | none |
| Q1 | the whole-change review | review | one rule, one wording | none | not a test | T4 | none |

T2 may rename its tests; the names above are the slugs planned. Each R5 test
records its own class once written.

## Start from
- base commit set: {space: 6f1e4e0, swe-pod: b7fc257, agent-mesh: f27c611}
- commit set under test: {space: 6f1e4e0, swe-pod: change/right-size-testing,
  agent-mesh: f27c611}; the branch is at b7fc257 while T1 builds, so this
  task runs its tests at the base commit set only

## Result goes to
- tests: changes/right-size-testing/tests/test_I1_process_md.md and
  changes/right-size-testing/tests/test_I3_d3_templates.md
- at base: each test's result at the base commit set, with its reason, for
  the ledger
- report: changes/right-size-testing/evidence/<YYYYMMDDTHHMMZ>-T3-report.md

Do not read plan.md, ledger.md, any other brief, report or review, or any code-repo diff or implementation body.
