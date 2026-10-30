# right-size-testing: plan

- change: right-size-testing; spec approved 2026-10-30T16:03Z
- size: small
- planner: agallojr/lead (small size: the lead writes the plan, open call 1)
- base commit set: {space: 6982fb5, swe-pod: b7fc257, agent-mesh: f27c611}
- code branches: change/right-size-testing in swe-pod

## 1. Goal and approach

Make testing for risk the SWE Pod's default (approach 1 of the spec, with
selection rule b). One builder rewrites every swe-pod file that states an
altered rule, in one wording (Q1), and bumps the process to
swe-pod-process@2 (open call 16). R5, the green rule, is the one requirement
at risk: a blind test task writes its tests. Every other scenario is a check
in the build task's done-when, rerun at verify (open calls 2, 3 and 10).

## 2. Interface contract

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

## 3. Global constraints

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

## 4. File map

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

## 5. Tasks

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

## 6. Test tasks

Risk (R1, R6):

| Requirement | Risk | Reason |
|---|---|---|
| R1 to R4, R6 to R15 | small | rules an agent reads in docs; a wrong word shows at the next change's plan or verify, costs one doc fix, and the whole-change review reads every one (Q1) |
| R5 | at risk | it loosens the rule that decides verified: a wrong reading calls a change verified while a test the selection picks has no pass (a false green), or keeps a rightly targeted verify not green (heartbeat-every-15-min's case); an agent applies it from the skill's text |

Expensive runs (R2). No live run.

| Run | Class | Task | Runs | Wall time (s) | Spend (USD) | Caps |
|---|---|---|---|---|---|---|
| runner.sh smoke, before a task's first agent-class run | agent | T2, T5 | 2 | 180 | 0.90 | 300 s each |
| R5 agent-class tests at base, at most 2, only if T2 writes any | agent | T2 | 2 | 480 | 2.00 | each test's cap_s, at most 600 s |
| the same at the head | agent | T5 | 2 | 480 | 2.00 | each test's cap_s, at most 600 s |
| `test_R12_S1_missing_quality_check` | agent | T5 | 1 | 120 | 0.75 | 600 s |
| Total | | | 7 | 1260 | 5.65 | |

Twice the estimate, the ask point (R3, open call 4): 2520 s or 11.30 USD.
The script checks (T1's 26 checks, I1 to I5 and R16.S1, T3's two checks,
T2's script-class tests) expect 1 s to 5 s each and about 60 s in all.

### T2 Project-level tests of R5
- role: test
- after: []
- runs: local
- needs: macos-laptop
- serves: [R5]
- done when: one test per R5 scenario (R5.S1 to R5.S4) in
  `changes/right-size-testing/tests/`, script-class fixture checks, with an
  agent-class run of the swe-pod skill only where a fixture check cannot
  show how an agent reads the rule (at most 2 such tests); each with its
  class, `expected_s`, deliverables and the risk it covers; each run at the
  base commit set and failing there for the stated reason, with its result
  in the ledger

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

### T5 Verify (macos-laptop)
- role: test
- after: [T1, T2, T3, T4]
- runs: local
- needs: macos-laptop
- done when: an evidence record at the current commit set with
  `selection: targeted` and `touched:`, giving: a result for every
  scenario (R5's from T2's tests, the rest by rerunning T1's done-when
  checks from its report); `I1` and `I3` from T3's tests; a pass or
  `not-selected` for every regression test in `tests/build-swe-pod/`, by
  2.2, picking I1 to I5, R16.S1 and `test_R12_S1_missing_quality_check`,
  with `build-swe-pod/I1` and `build-swe-pod/I3` given `superseded by I1`
  and `superseded by I3`; `unit: {swe-pod: none-present}`; and Q1 from T4's
  review

## 7. Review tasks

The build task forms one wave, so the one review is the whole-change review
(R10.S2, open call 11).

### T4 Whole-change review
- role: review
- after: [T1]
- runs: local
- needs: any
- done when: a review record over the spec, this plan, swe-pod's diff from
  `b7fc257` to the head, T1's report, T2's and T3's tests and the ledger's
  rulings; it checks that each of T1's done-when checks exercises its
  scenario (an Important finding where one does not, R6.S1), and runs Q1:
  every file that states a rule this change alters, compared; passing is no
  Critical or Important finding on a disagreement. Fix rounds carry only
  Critical and Important findings; Minor ones are fixed in one batch with
  them, or parked by a ruling (R11).

## 8. Integrate task

### T6 Integrate
- role: lead
- after: [T5, T4]
- runs: local
- needs: any
- docs: the space's `PROCESS.md` copy (to swe-pod's at the merged head) and
  `pod.yaml` (`process: swe-pod-process@2`, swe-pod pin to the merged head)
- tests: move `changes/right-size-testing/tests/` to
  `tests/right-size-testing/` with T2's and T3's tests (all kept); move
  `tests/build-swe-pod/test_I1_process_md.md` and
  `test_I3_d3_templates.md` to
  `changes/archive/2026-10-29-build-swe-pod/superseded-tests/`, and with
  them the tests of a behavior this change removes: the ask before each
  heavy check (`test_R13_S1_heavy_check_asks_first`,
  `test_T1_TS4_heavy_from_recorded_run_time`,
  `test_T8_TS3_heavy_verify_with_g3_overlay`) and the promotion of every
  test (`test_R5_S2_tests_promoted_at_integrate`); read each other test of
  build-swe-pod/R5, R12, R13 and R21 and keep those whose behavior still
  holds, such as `test_R12_S1_missing_quality_check`,
  `test_R21_S1_suggestion_with_computed_value` and
  `test_R21_S2_every_suggestion_has_outcome`; the final report lists each
  test moved or kept, with its reason (R12.S2)
- open plans: none
- done when: merged on the human's word; tests moved; pin and process line
  advanced; final report filed with its `## Test cost` section

## 9. Test map

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

## 10. Dependency summary

- parallel: T1, T2 and T3 start at the go, together.
- then: T4 once T1 reports; T5 once T1 to T4 are done; T6 on the human's
  word.
- longest chain: T1 -> T4 (and its fix wave) -> T5 -> T6.
- shared files: none between tasks. T1 alone writes swe-pod; T2 and T3 write
  different files in `changes/right-size-testing/tests/`.

## Self-review
- [x] every requirement maps to a build task (T1 serves R1 to R15 and Q1)
- [x] every scenario maps to a test (section 9; R5's to T2, the rest to T1's
  done-when)
- [x] no step says "TBD", "handle edge cases" or "add tests"
- [x] names and types agree across tasks (section 2 forms)
- [x] every task has role, after, runs and done-when
- [x] every planned test names the risk it covers (section 9)
- [x] every agent-class run has its wall time, spend and caps, with the
  totals (section 6); no live run
- [x] no live or heavy test beyond the one agent-class test the spec's open
  call 2 names for R5's risk, and R5's agent-class tests only where no
  fixture check can show the behavior
- [x] one wave, one review, the whole-change review

## Questions for the spec

### (a) Answered
1. When does the one review run? Before verify, so verify runs once at the
   final commit set and records Q1 from it (open call 2 lists build, test,
   review, then verify; R10.S2 makes it the whole-change review).
2. Which agent-class regression test does verify run? Only
   `test_R12_S1_missing_quality_check` (open call 2).

### (b) Minor, with the default planned
1. The version bump makes build-swe-pod's checks I1.2 and I3.14 stale. T3
   writes replacements at @2 in this change's folder; verify gives the old
   ones `superseded by I1` and `superseded by I3`, which 2.4 lets an I-check
   key take for a change whose requirements the spec supersedes; integrate
   moves the old ones out (R12.S2, open call 16).
2. The forms of section 2 (column names, keys, ledger lines) are the
   planner's choice where the spec gives none.

### (c) For the human
None.
