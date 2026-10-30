# T5 brief

- change: right-size-testing
- task: T5
- role: test
- repo: swe-pod

## Task
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

What to run, at the commit set under test (Start from):

1. The selection (plan 2.2, `selection: targeted`). `touched:` is
   `git diff --name-only b7fc257..3b22a1b` in swe-pod, each path as
   `swe-pod:<path>`. Read the front matter of every `test_*.md` directly in
   the space's `tests/build-swe-pod/` (90 tests), take each one's class by
   plan 2.1, and pick by plan 2.2. The plan's test map names one agent-class
   regression test, `test_R12_S1_missing_quality_check`. The expected picks
   are I1 to I5, R16.S1 and `test_R12_S1_missing_quality_check`; if your
   picks differ, stop and report NEEDS_CONTEXT with the difference.
2. This change's own tests, in `changes/right-size-testing/tests/`: T2's four
   R5 tests (two script-class, two agent-class) and T3's `test_I1_process_md`
   and `test_I3_d3_templates`.
3. T1's done-when checks, from `changes/right-size-testing/tasks/T1-report.md`:
   each `### <scenario id> done-when check` command, as last updated in its
   `## Fix round` sections, with `SWE` the swe-pod checkout and `REV`
   3b22a1b, and for the rewritten R13.S2 check also `SPACE` the space
   checkout and `SREV` the space sha you run at; and the model grep of T1's
   done-when. Each gives its scenario's
   result: pass when its output matches the expected output in the report.
4. The picked regression tests, with the space's runner. Then
   `test_R16_S1_dispatch_line_names_no_machine` last, with `--space`, as it
   asks.
5. Q1 from T4's review: pass when the latest review of T4 has no open
   Critical or Important finding; take it from
   `changes/right-size-testing/tasks/T4-review.md` and the ledger's latest
   `T4 review` line.

The evidence record (from `templates/records/evidence.md` at swe-pod
3b22a1b):

- `commit_set: {space: <the space sha you ran at: the HEAD that holds this brief>, swe-pod: <sha7>,
  agent-mesh: f27c611}`, `env: macos-laptop`, `actor: agallojr/test`,
  `selection: targeted`, `touched: [...]`, `wall_time_s`.
- `scenarios:` every scenario of the spec (R1.S1 to R15.S1, 30 in all), then
  each build-swe-pod scenario test under `build-swe-pod/R<n>.S<m>`, the key
  the skill's section 1.6 at 3b22a1b gives it.
- `x-checks:` this change's `I1` and `I3`; build-swe-pod's checks under
  `build-swe-pod/I<n>`, with `build-swe-pod/I1: superseded by I1` and
  `build-swe-pod/I3: superseded by I3` (ledger ruling of 16:22Z).
- `x-suggestions:` build-swe-pod's suggestion tests under
  `build-swe-pod/T<n>.TS<k>`.
- every regression test not picked: `not-selected`.
- `unit: {swe-pod: none-present}`; `quality: {Q1: <pass|fail>}`.
- The body: the selection's touched files and picks, a `## Undeclared cost
  class` section only if a test has neither `class:` nor `mode:`, each
  failure's summary, and pointers to logs by test name only.

## Interfaces
Section 2 of the plan, the interface contract, verbatim:

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

T5's rows are the smoke, the two R5 agent-class tests at the head and
`test_R12_S1_missing_quality_check`: 4 runs, 720 s and 3.20 USD estimated.
These runs need no ask. A run past twice the change's estimate in all
(2520 s or 11.30 USD, counting T2's 266 s and 1.34 USD), or a run this list
does not hold, needs the lead's ask first: stop and report NEEDS_CONTEXT. A
run whose session never reaches the test's first step is a harness error:
stop it 120 s after launch, record `harness-error` and no pass or fail,
rerun after a harness fix that changes no expected value, and report
BLOCKED after a third.

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
2026-10-30T16:51Z Ruling: the managed policy T2's smoke reports, the gateway settings drop-in
                  and the remote managed settings, is accepted under test isolation, as
                  build-swe-pod ruled at 2026-10-28T02:59Z; why: it pins the model, adds
                  denials and gateway variables, adds no instruction file and loosens no
                  fence; cost if wrong: an agent-class result reflects node policy
2026-10-30T16:51Z Ruling: T2's two script-class tests read the rule's words together in one
                  paragraph and contract 2.5's status form, and stand as written; a correct
                  rule they fail goes back to the test agent with the spec clause; why: 2.5
                  is the contract, and T4 reads them for a change detector; cost if wrong: a
                  false fail at verify and one test fix
2026-10-30T17:19Z Ruling: R7's declined covers a suggestion bound for the test agent that a
                  planned test covers; the routes to the spec author (behavior the spec does
                  not state) and back to the builder (internal only) stay; why: both R7
                  scenarios are about suggestions bound for the test agent, and
                  build-swe-pod/R21.S2, which stays in the suite, needs the proposed-as-
                  scenario and unit-tested outcomes; cost if wrong: a suggestion R7 meant to
                  decline reaches the spec author or the builder
2026-10-30T17:19Z Ruling: an unlisted script-class run needs no ask (R3); why: R3's only when
                  limits the ask, and the spec puts the cost in agent-class and live-class
                  runs, as T4 confirmed; cost if wrong: an unlisted script check runs with no
                  word from the operator
2026-10-30T17:19Z Ruling: T4's wave-review finding at swe-pod/skills/swe-pod/SKILL.md:114 is in
                  scope and fixed in this wave, not parked; why: R10 brings wave reviews in,
                  and the skill must read their state; the out-of-scope item is only the
                  first id of a Reviews cell; cost if wrong: one more skill rule in this wave
2026-10-30T17:19Z Ruling: the whole-change fix wave carries T4's 4 Important findings and,
                  batched with them, its 18 Minor ones; why: open call 12 and R11, a fix wave
                  that runs for an Important finding also takes the batched Minors; cost if
                  wrong: a longer fix wave
2026-10-30T17:33Z Ruling: T4's Minor at swe-pod/templates/records/review.md:18 is parked; why:
                  the review template is outside the plan's file map, and swe-review's Quality
                  section now names the R6 check; cost if wrong: a reviewer working from the
                  template alone may skip that check
2026-10-30T17:40Z Ruling: T4's re-review Minor, the reflow defect at swe-pod/agents/swe-plan.md:103
                  and two short lines at swe-pod/PROCESS.md:367 and :484, is parked; why: a
                  Minor finding starts no fix round (R11) and the one whole-change fix wave
                  has run; cost if wrong: three unevenly wrapped lines ship in
                  swe-pod-process@2
```

## Start from
- swe-pod: branch change/right-size-testing at 3b22a1b (base b7fc257)
- agent-mesh: its pin, f27c611
- space: main at fbf3e3e

## Result goes to
- evidence: changes/right-size-testing/evidence/<YYYYMMDDTHHMMZ>.md, id
  ev-<YYYYMMDDTHHMMZ>
- report: changes/right-size-testing/evidence/<YYYYMMDDTHHMMZ>-T5-report.md,
  with each agent-class run's wall time in s and spend in USD (or unknown),
  and the task's total
