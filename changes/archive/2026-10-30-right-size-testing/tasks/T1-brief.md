# T1 brief

- change: right-size-testing
- task: T1
- role: build
- repo: swe-pod

## Task
### T1 Right-size testing in swe-pod
- role: build
- repo: swe-pod
- after: []
- runs: local
- needs: any
- risk: small: doc rules an agent reads; R5's part is at risk and is
  tested blind by T2
- serves: [R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15, Q1]
- touches: the files of section 4
- consumes: the spec; the forms of section 2
- produces: the forms of section 2 at the head of change/right-size-testing
- steps:
  1. For each scenario except R5's, write its check first: one shell
     command run against a swe-pod checkout `$SWE` at sha `$REV`, with its
     expected output, that fails at `b7fc257` for the stated reason and
     exercises the scenario's THEN through the text an agent reads (the
     forms of section 2 and the rule's sentences in the files that state
     it). Name it by scenario id.
  2. Watch every check fail at `b7fc257`.
  3. Edit the files of section 4 until every check passes. Each rule this
     change alters reads the same in every file that states it (Q1); where
     a file states a rule of section 2, it uses that section's form.
  4. Bump the process version (2.11) and add the SPEC.md notes (open call
     18).
  5. Run the six script-class regression tests that read the files you
     touch, with the space's runner, at the head (command below).
  6. Commit by path with trailers `Change: right-size-testing` and
     `Task: T1`, and push `change/right-size-testing`.
- done when:
  - every check of step 1 (26: R1.S1 to R15.S1, R5 excepted) is in the
    report under `## Test output` as `### <scenario id> done-when check`,
    with its command, its red output at `b7fc257` and its green output at
    the head;
  - this prints nothing at the head:
    `git -C $SWE grep -n -i -E 'cheaper (one|model)|stronger model|different model' $REV -- PROCESS.md agents skills templates README.md INSTALL.md`;
  - `runner.sh run` of `tests/build-swe-pod/test_I1_process_md.md`,
    `test_I2_role_definitions.md`, `test_I3_d3_templates.md`,
    `test_I4_swe_pod_skill.md`, `test_I5_templates_placeholders_only.md`
    and `test_R16_S1_dispatch_line_names_no_machine.md`, with
    `--repo swe-pod=$SWE@$REV`, `--repo agent-mesh=<checkout>@f27c611`,
    `--bus` and `--space`, prints `pass` for I2, I4, I5 and R16.S1, and
    for I1 and I3 fails only checks I1.2 and I3.14, the version line that
    T3's replacements check at @2;
  - the commits are on the remote's `change/right-size-testing`;
  - and the whole-change review, T4, has no open Critical or Important
    finding.

## Interfaces
Section 2 of the plan, the interface contract, verbatim. T1 builds all of it.

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

The file map, section 4 of the plan, verbatim:

| Repo | File | Create or change | One responsibility | Task |
|---|---|---|---|---|
| swe-pod | `PROCESS.md` | change | the process: §2, §4 to §11 for every rule of R1 to R15; line 3 @2 | T1 |
| swe-pod | `agents/swe-plan.md` | change | risk marks, estimates, reviews per wave, live tests (R1, R2, R6, R8, R10) | T1 |
| swe-pod | `agents/swe-lead.md` | change | asks, triage, reviews, fix loop, integrate promotion, cost report, models (R3, R7, R10 to R12, R14, R15) | T1 |
| swe-pod | `agents/swe-test.md` | change | targeted verify, results, harness errors, cost classes (R4, R9, R13) | T1 |
| swe-pod | `agents/swe-build.md`, `agents/swe-review.md`, `agents/swe-spec.md` | change where they state an altered rule | suggestions, review of builders' tests, fix rounds, models (R6, R7, R11, R15) | T1 |
| swe-pod | `skills/swe-pod/SKILL.md` | change | green rule, selection, trace of done-when rows (R4, R5, R6) | T1 |
| swe-pod | `skills/swe-pod/status-format.md` | change | the regression part of the latest-evidence line (R5.S1) | T1 |
| swe-pod | `templates/records/plan.md` | change | 2.6 forms | T1 |
| swe-pod | `templates/records/evidence.md` | change | `selection:`, `touched:`, `harness:`, results (R4, R5, R9, R13) | T1 |
| swe-pod | `templates/records/ledger.md` | change | 2.7 forms | T1 |
| swe-pod | `templates/records/final-report.md` | change | 2.9 sections | T1 |
| swe-pod | `templates/space/pod.yaml` | change | process @2 | T1 |
| swe-pod | `README.md`, `INSTALL.md` | change | the rules and the model sentence as they ship | T1 |
| swe-pod | `SPEC.md` | change | a note beside R5, R12, R13, R21 and the model lines of §5.3 and §6 naming this change (open call 18) | T1 |

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

## Rulings
```
2026-10-30T16:19Z Ruling: this change runs under its own rules from the go, though
                  the space still pins swe-pod-process@1: risk-named tests, the plan's
                  estimates and asks, targeted verify, the green rule with not-selected
                  and superseded, one review, and every role on the most capable model;
                  why: open call 2 of the approved spec, and the operator's go at small
                  size; cost if wrong: one change verified under rules the space has not
                  yet pinned, which integrate pins as swe-pod-process@2
2026-10-30T16:22Z Ruling: the one review, T4, runs after T1 and its fix wave and before
                  verify, which then runs once at the final commit set and takes Q1 from
                  the review; why: open call 2 orders build, test, review, verify, and a
                  review after verify would need a second verify after its fix wave;
                  cost if wrong: a code fault verify finds needs a fix and a review of
                  that fix diff alone
2026-10-30T16:22Z Ruling: build-swe-pod's checks I1.2 and I3.14 go stale when swe-pod
                  moves to swe-pod-process@2 (open call 16); T3 writes replacements at
                  @2, verify gives build-swe-pod/I1 and build-swe-pod/I3 superseded by I1
                  and superseded by I3 under plan 2.4, and integrate moves the two old
                  tests to build-swe-pod's superseded-tests; why: both are picked
                  script-class tests, and neither may hold the evidence red nor be ruled
                  green by hand; cost if wrong: the green rule's superseded case also
                  takes I-check keys, which R5's tests and the review must accept
2026-10-30T16:22Z Ruling: STATUS.md is regenerated with the swe-pod skill at the branch
                  head once T1 lands, and with the installed skill until then; why: this
                  change runs under its own rules from the go; cost if wrong: STATUS.md
                  reads this change's evidence by the old rule until T1 lands
```

## Start from
- swe-pod: branch change/right-size-testing at b7fc257
- space: main at 6f1e4e0

## Result goes to
- code: commits on change/right-size-testing in swe-pod, trailers
  Change: right-size-testing and Task: T1, pushed
- report: changes/right-size-testing/tasks/T1-report.md
