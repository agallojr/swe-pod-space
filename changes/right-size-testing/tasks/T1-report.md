# T1 report

- change: right-size-testing
- task: T1
- actor: agallojr/build

## Status
DONE_WITH_CONCERNS (first build at 0debc5a; fix round 1 at 3b22a1b, see `## Fix round 1`)

## What I did
1. Wrote the 26 done-when checks (R1.S1 to R15.S1, R5 excepted) first, each
   one shell command over `$SWE` and `$REV` that reads the text an agent
   reads with `git show "$REV:<path>"` and looks for the section 2 forms and
   the rule's sentences in every file that states the rule, or for an old
   rule's text that must be gone. Ran all 26 at b7fc257 and watched each
   fail for its stated reason.
2. Rewrote the files of plan section 4 until all 26 passed, stating each
   altered rule in one wording across the files (Q1): the same sentences
   appear in `PROCESS.md`, the role files, the skill, the templates and
   `README.md`/`INSTALL.md` where each states the rule, and each check
   looks for that wording in each of those files.
3. Moved the process to `swe-pod-process@2` (plan 2.11): `PROCESS.md` line
   3, its illustrative `pod.yaml`, and `templates/space/pod.yaml`. Added a
   note to `SPEC.md` beside R5, R12, R13, R21 and the model lines of §5.3
   and §6 (open call 18).
4. Kept the shapes the regression tests check: `PROCESS.md` keeps exactly
   its 15 level-2 headings (new rules are `###` subsections), the plan
   template its 12, and the ledger template its one fenced block, with the
   dispatch line in form.
5. Ran the six script-class regression tests at the head with the space's
   runner: I2, I4, I5 and R16.S1 pass, and I1 and I3 fail only on I1.2 and
   I3.14, the `@2` version line that T3's replacements check.
6. Committed the 16 files by path with trailers `Change: right-size-testing`
   and `Task: T1`, and pushed `change/right-size-testing` (b7fc257..0debc5a,
   a fast-forward: the remote head was already in the branch).

## Files
All in swe-pod, commit range `swe-pod b7fc257..0debc5a` (fix round 1:
`swe-pod 0debc5a..3b22a1b`, listed under `## Fix round 1`):

- `PROCESS.md`: changed. Line 3 and §1's `pod.yaml` at `@2`; §2 stage and
  state tables, blind tests at risk; §4 risk table, `- risk:` line, review
  rule per wave, the test map's columns, new `### Risk and the tests it
  calls for`, self-review items; §5 builder's tests, reviews per wave and
  their ledger lines, the reviewer's check of builders' tests, the fix loop
  (Critical and Important only, rounds 4 and 5 on the same model), models;
  §6 blind tests of requirements at risk, cost class keys, suggestion
  triage; §7 run list, evidence keys, new `### Selection`,
  `### Cost classes`, `### Results and the green rule`,
  `### Harness errors`, `### Failures and the whole-change review`, sharded
  green together; §8 final report sections, promotion of kept tests and
  moving out superseded or stale ones; §9 risk not size; §10 independence
  and models; §11 fences and `**Asks about test runs.**`; §12 tree line;
  §13 stop and ask.
- `agents/swe-plan.md`: changed. Steps 2.5 to 2.9, a new step 3 (plan the
  tests for risk), self-review items, a Reads line and a Never line.
- `agents/swe-lead.md`: changed. Never, test-writing brief, models, review
  dispatch, suggestion triage, harness errors, reviews and fix loop,
  failure table, whole-change review, rulings, sharded green together,
  `### Heavy checks` replaced by `### Test runs and asks`, final report and
  promotion at integrate, the ledger forms.
- `agents/swe-test.md`: changed. Modes, Reads, Never, Returns, a "Both
  modes" block (cost classes, harness errors), writing steps 2, 7, 8, 9,
  verify steps 2 to 5 (selection, results, evidence keys).
- `agents/swe-build.md`: changed. Builder's tests as done-when checks,
  suggestion triage, fix rounds.
- `agents/swe-review.md`: changed. Modes (wave and at-risk task reviews,
  whole-change timing), Reads, the fix-round rule, the Important finding
  for a builder's test that misses its scenario, completeness.
- `agents/swe-spec.md`: unchanged; it states no rule this change alters.
- `skills/swe-pod/SKILL.md`: changed. §1.6 results, selection and the
  green rule; §1.7 sharded green together; §4 Go step 3; §5 trace step 2
  (`T<n> done-when` rows and kept tests).
- `skills/swe-pod/status-format.md`: changed. The regression part of the
  latest-evidence line (plan 2.5) and the sharded combined results.
- `templates/records/plan.md`: changed. 2.6 forms: `- risk:` line, risk
  table, expensive-runs table with Total, per-wave review entries, the
  test map's columns, four self-review items.
- `templates/records/evidence.md`: changed. `selection:`, `touched:`,
  `harness:`, the result values, a `harness-error` failure block and
  `## Undeclared cost class`.
- `templates/records/ledger.md`: changed. The 2.7 forms; `heavy:` retired.
- `templates/records/final-report.md`: changed. `## Test cost`,
  `## Tests kept`, `## Costly regression tests not run`, deferred minors'
  outcome.
- `templates/space/pod.yaml`: changed. `process: swe-pod-process@2`.
- `README.md`: changed. Version 2, the five stages as they now run, the
  model sentence, fences and asks.
- `INSTALL.md`: changed. The model sentence and `model: inherit`.
- `SPEC.md`: changed. Eight notes naming this change.

## Test output

swe-pod has no unit suite: `unit: none-present` (no `unit <p>/<n> pass` line
to give). The builder's tests are the done-when checks below.

### Done-when: no text allows another model
- command:
  `git -C $SWE grep -n -i -E 'cheaper (one|model)|stronger model|different model' $REV -- PROCESS.md agents skills templates README.md INSTALL.md`
- red at b7fc257: 4 lines (`PROCESS.md` §5 fix loop and Models, §10
  Independence; `agents/swe-lead.md` step 3 and the fix loop), as the
  R15.S1 check's `lines-allowing-another-model 4` shows.
- green at 0debc5a: prints nothing, exit status 1 (no match).

### Done-when: the six script-class regression tests
- command (machine paths as placeholders):

  ```sh
  runner.sh run test_I1_process_md.md test_I2_role_definitions.md \
    test_I3_d3_templates.md test_I4_swe_pod_skill.md \
    test_I5_templates_placeholders_only.md \
    test_R16_S1_dispatch_line_names_no_machine.md \
    --python <py> --scratch <scratch> \
    --repo swe-pod=<swe-pod checkout>@$REV \
    --repo agent-mesh=<agent-mesh checkout>@f27c611 \
    --gate <agent-mesh checkout>@f27c611 --bus <bus> --space <space>
  ```

- at b7fc257 (baseline), 3.4 s wall time:

  ```text
  RESULT test_I1_process_md pass (all 8 checks pass)
  RESULT test_I2_role_definitions pass (all 4 checks pass)
  RESULT test_I3_d3_templates pass (all 14 checks pass)
  RESULT test_I4_swe_pod_skill pass (all 6 checks pass)
  RESULT test_I5_templates_placeholders_only pass (all 9 checks pass)
  RESULT test_R16_S1_dispatch_line_names_no_machine pass (all 4 checks pass)
  ```

- at 0debc5a, 2.9 s wall time; as the done-when expects, I2, I4, I5 and
  R16.S1 pass and I1 and I3 fail only on I1.2 and I3.14:

  ```text
  RESULT test_I1_process_md fail (check I1.2: line 1 and line 3 as contract 2.2 gives them)
  RESULT test_I2_role_definitions pass (all 4 checks pass)
  RESULT test_I3_d3_templates fail (check I3.14: pod.yaml keys and pinned process)
  RESULT test_I4_swe_pod_skill pass (all 6 checks pass)
  RESULT test_I5_templates_placeholders_only pass (all 9 checks pass)
  RESULT test_R16_S1_dispatch_line_names_no_machine pass (all 4 checks pass)
  ```

  I1 and I3 per check at 0debc5a (every other check passes):

  ```text
  I1.1 pass PROCESS.md present at swe-pod 0debc5a
  I1.2 fail line 1 and line 3 as contract 2.2 gives them
  I1.3 pass the 15 level-2 headings, in order
  I1.4 pass section 2 stage table
  I1.5 pass section 2 change-state table
  I1.6 pass routing tables: section 6 has 4 rows, section 7 has 6 rows
  I1.7 pass section 9 size table
  I1.8 pass section 10 role table
  I3.1 pass swe-pod 0debc5a templates/space: complete
  I3.2 pass swe-pod 0debc5a templates/records: complete
  I3.3 pass spec template header lines and sections
  I3.4 pass plan template: 12 level-2 sections against the 12 of contract 2.4, and the question sorting
  I3.5 pass brief template sections
  I3.6 pass test-brief template sections and exact last line
  I3.7 pass report template sections, statuses and suggestion form
  I3.8 pass review template front-matter, sections and finding line form
  I3.9 pass evidence template front-matter keys: missing none
  I3.10 pass ledger template has one fenced block
  I3.11 pass handoff template sections
  I3.12 pass final-report template sections and scenario table
  I3.13 pass space.yaml: missing none; extra none; kind and header_profile as spec
  I3.14 fail pod.yaml keys and pinned process
  ```

### Done-when: the commits are on the remote
- command: `git -C $SWE ls-remote origin refs/heads/change/right-size-testing`
- output after the push:
  `0debc5a671ab3ad18c858a70c3705ed80da8ff04	refs/heads/change/right-size-testing`
  (push output `b7fc257..0debc5a  change/right-size-testing -> change/right-size-testing`).

### The 26 scenario checks

Each check below is one shell command. To rerun one, set `SWE` to a swe-pod
checkout and `REV` to a sha (`REV=b7fc257` red, `REV=0debc5a` green) and run
the command in bash. Each line prints `ok <file> <label>` when that file
holds the rule's sentence or form, `MISSING <file> <label>` when it does
not, `ok <file> no-<label>` when an old rule's text is gone, and
`STILL <file> <label>` when it is still there. Green: 208 of 208 `ok` lines
and `lines-allowing-another-model 0`. Red at b7fc257: 7 of 208 `ok` lines
(the six `model: inherit` lines and one final-report line that already
exist), so every check fails there. Each check runs in under 1 s.

### R1.S1 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md risk-named 'Every test the plan lists names the risk it covers, and the plan lists no test without one.'; h agents/swe-plan.md risk-named 'Every test the plan lists names the risk it covers, and the plan lists no test without one.'; h README.md risk-named 'Every test the plan lists names the risk it covers, and the plan lists no test without one.'; h PROCESS.md small-risk $'A part of the change with small risk gets no test beyond its builder\'s own and the repo\'s unit suite, unless the plan names a further risk that test covers.'; h agents/swe-plan.md small-risk $'A part of the change with small risk gets no test beyond its builder\'s own and the repo\'s unit suite, unless the plan names a further risk that test covers.'; h templates/records/plan.md risk-table '| Requirement | Risk | Reason |'; h templates/records/plan.md map-columns '| Scenario | Test | Class | Risk it covers | Expected (s) | Keep | Written by | Unit tests that also cover it |'
```

- expected output: every line begins `ok`. Red at b7fc257: the plan template and the planner hold no risk-named test rule, no risk table and no Risk column.
- red at b7fc257 (0 of 7 lines ok):

```text
MISSING PROCESS.md risk-named
MISSING agents/swe-plan.md risk-named
MISSING README.md risk-named
MISSING PROCESS.md small-risk
MISSING agents/swe-plan.md small-risk
MISSING templates/records/plan.md risk-table
MISSING templates/records/plan.md map-columns
```

- green at 0debc5a (7 of 7 lines ok):

```text
ok PROCESS.md risk-named
ok agents/swe-plan.md risk-named
ok README.md risk-named
ok PROCESS.md small-risk
ok agents/swe-plan.md small-risk
ok templates/records/plan.md risk-table
ok templates/records/plan.md map-columns
```

### R1.S2 done-when check

In fix round 1 two lines were added. The current command, with its red output at b7fc257 and its green output at 3b22a1b, is under `## Fix round 1`, `### R1.S2 done-when check`.

### R2.S1 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md estimates 'The plan gives each agent-class or live-class run it lists its wall time in s, its spend in USD and the caps the budget policy asks for, with the totals of those estimates; a script-class check gives its expected run time only.'; h agents/swe-plan.md estimates 'The plan gives each agent-class or live-class run it lists its wall time in s, its spend in USD and the caps the budget policy asks for, with the totals of those estimates; a script-class check gives its expected run time only.'; h PROCESS.md not-quota 'An estimate is not a quota.'; h agents/swe-plan.md not-quota 'An estimate is not a quota.'; h templates/records/plan.md runs-table '| Run | Class | Task | Runs | Wall time (s) | Spend (USD) | Caps |'; h templates/records/plan.md total-row '| Total | | | <k> | <s> | <USD> | |'; h templates/records/plan.md selfreview-runs '- [ ] every agent- and live-class run has its wall time, spend and caps, with the totals'
```

- expected output: every line begins `ok`. Red at b7fc257: no estimate rule and no expensive-runs table with a Total row.
- red at b7fc257 (0 of 7 lines ok):

```text
MISSING PROCESS.md estimates
MISSING agents/swe-plan.md estimates
MISSING PROCESS.md not-quota
MISSING agents/swe-plan.md not-quota
MISSING templates/records/plan.md runs-table
MISSING templates/records/plan.md total-row
MISSING templates/records/plan.md selfreview-runs
```

- green at 0debc5a (7 of 7 lines ok):

```text
ok PROCESS.md estimates
ok agents/swe-plan.md estimates
ok PROCESS.md not-quota
ok agents/swe-plan.md not-quota
ok templates/records/plan.md runs-table
ok templates/records/plan.md total-row
ok templates/records/plan.md selfreview-runs
```

### R3.S1 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md listed-no-ask 'Every other run the plan lists goes ahead with no ask.'; h agents/swe-lead.md listed-no-ask 'Every other run the plan lists goes ahead with no ask.'; h README.md listed-no-ask 'Every other run the plan lists goes ahead with no ask.'; h PROCESS.md cost-after-task $'After each test task, the lead records the actual wall time in s and spend in USD of its runs beside the plan\'s estimate'; h agents/swe-lead.md cost-after-task $'After each test task, the lead records the actual wall time in s and spend in USD of its runs beside the plan\'s estimate'; h templates/records/ledger.md cost-line 'T<n> cost: actual <s> s, <USD|unknown> USD; estimate <s> s, <USD> USD'; h agents/swe-lead.md cost-line 'T<n> cost: actual <s> s, <USD|unknown> USD; estimate <s> s, <USD> USD'; n PROCESS.md heavy-ask 'heavy: asked'; n agents/swe-lead.md heavy-ask 'heavy: asked'; n templates/records/ledger.md heavy-ask 'heavy: asked'
```

- expected output: every line begins `ok`. Red at b7fc257: no no-ask rule for listed runs and no cost line; the `heavy: asked` form is still there.
- red at b7fc257 (0 of 10 lines ok):

```text
MISSING PROCESS.md listed-no-ask
MISSING agents/swe-lead.md listed-no-ask
MISSING README.md listed-no-ask
MISSING PROCESS.md cost-after-task
MISSING agents/swe-lead.md cost-after-task
MISSING templates/records/ledger.md cost-line
MISSING agents/swe-lead.md cost-line
STILL PROCESS.md heavy-ask
STILL agents/swe-lead.md heavy-ask
STILL templates/records/ledger.md heavy-ask
```

- green at 0debc5a (10 of 10 lines ok):

```text
ok PROCESS.md listed-no-ask
ok agents/swe-lead.md listed-no-ask
ok README.md listed-no-ask
ok PROCESS.md cost-after-task
ok agents/swe-lead.md cost-after-task
ok templates/records/ledger.md cost-line
ok agents/swe-lead.md cost-line
ok PROCESS.md no-heavy-ask
ok agents/swe-lead.md no-heavy-ask
ok templates/records/ledger.md no-heavy-ask
```

### R3.S2 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md ask-rule $'The lead asks the operator about a test run only when it is an agent-class or live-class run the plan does not list, or when it would take the expensive runs past twice the plan\'s estimate in wall time or in spend, counting their actuals so far plus the estimate of the run to dispatch.'; h agents/swe-lead.md ask-rule $'The lead asks the operator about a test run only when it is an agent-class or live-class run the plan does not list, or when it would take the expensive runs past twice the plan\'s estimate in wall time or in spend, counting their actuals so far plus the estimate of the run to dispatch.'; h README.md ask-rule $'The lead asks the operator about a test run only when it is an agent-class or live-class run the plan does not list, or when it would take the expensive runs past twice the plan\'s estimate in wall time or in spend, counting their actuals so far plus the estimate of the run to dispatch.'; h PROCESS.md no-operator 'With no operator present, a run past that point is not dispatched.'; h agents/swe-lead.md no-operator 'With no operator present, a run past that point is not dispatched.'; h PROCESS.md policy-holds $'The budget policy\'s own ask points still hold.'; h agents/swe-lead.md policy-holds $'The budget policy\'s own ask points still hold.'; h templates/records/ledger.md ask-line 'ask: <handle> before T<n>: <run>; <unlisted|past twice the estimate>; spent <s> s, <USD> USD of <s> s, <USD> USD estimated'; h templates/records/ledger.md not-dispatched-line 'T<n> not dispatched: <run>; past twice the estimate, no operator present'; h skills/swe-pod/SKILL.md go-waits $'or one past twice the plan\'s estimate, waits for the operator\'s word'
```

- expected output: every line begins `ok`. Red at b7fc257: no twice-the-estimate ask rule, no `ask:` or `not dispatched` forms, and the skill still waits on each heavy check.
- red at b7fc257 (0 of 10 lines ok):

```text
MISSING PROCESS.md ask-rule
MISSING agents/swe-lead.md ask-rule
MISSING README.md ask-rule
MISSING PROCESS.md no-operator
MISSING agents/swe-lead.md no-operator
MISSING PROCESS.md policy-holds
MISSING agents/swe-lead.md policy-holds
MISSING templates/records/ledger.md ask-line
MISSING templates/records/ledger.md not-dispatched-line
MISSING skills/swe-pod/SKILL.md go-waits
```

- green at 0debc5a (10 of 10 lines ok):

```text
ok PROCESS.md ask-rule
ok agents/swe-lead.md ask-rule
ok README.md ask-rule
ok PROCESS.md no-operator
ok agents/swe-lead.md no-operator
ok PROCESS.md policy-holds
ok agents/swe-lead.md policy-holds
ok templates/records/ledger.md ask-line
ok templates/records/ledger.md not-dispatched-line
ok skills/swe-pod/SKILL.md go-waits
```

### R4.S1 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md selected-only 'only the regression tests its selection picks'; h agents/swe-test.md selected-only 'only the regression tests its selection picks'; h PROCESS.md pick-script 'it is script class and one of its deliverable paths (less any ` as <name>`) is a `touched` path of the same repo, or a folder that holds one'; h agents/swe-test.md pick-script 'it is script class and one of its deliverable paths (less any ` as <name>`) is a `touched` path of the same repo, or a folder that holds one'; h skills/swe-pod/SKILL.md pick-script 'it is script class and one of its deliverable paths (less any ` as <name>`) is a `touched` path of the same repo, or a folder that holds one'; h PROCESS.md touched-def $'lists every file the change\'s diff from base to head changes, in each repo of the spec\'s `repos:`'; h agents/swe-test.md touched-def $'lists every file the change\'s diff from base to head changes, in each repo of the spec\'s `repos:`'; h PROCESS.md not-selected 'gives every other regression test `not-selected`'; h agents/swe-test.md not-selected 'gives every other regression test `not-selected`'; h templates/records/evidence.md selection-key 'selection: targeted'; h templates/records/evidence.md touched-key 'touched: [<repo>:<path>, ...]'; h templates/records/evidence.md not-selected-result 'not-selected'
```

- expected output: every line begins `ok`. Red at b7fc257: verify runs the whole regression suite; no selection rule, no `selection:` or `touched:` keys, no `not-selected`.
- red at b7fc257 (0 of 12 lines ok):

```text
MISSING PROCESS.md selected-only
MISSING agents/swe-test.md selected-only
MISSING PROCESS.md pick-script
MISSING agents/swe-test.md pick-script
MISSING skills/swe-pod/SKILL.md pick-script
MISSING PROCESS.md touched-def
MISSING agents/swe-test.md touched-def
MISSING PROCESS.md not-selected
MISSING agents/swe-test.md not-selected
MISSING templates/records/evidence.md selection-key
MISSING templates/records/evidence.md touched-key
MISSING templates/records/evidence.md not-selected-result
```

- green at 0debc5a (12 of 12 lines ok):

```text
ok PROCESS.md selected-only
ok agents/swe-test.md selected-only
ok PROCESS.md pick-script
ok agents/swe-test.md pick-script
ok skills/swe-pod/SKILL.md pick-script
ok PROCESS.md touched-def
ok agents/swe-test.md touched-def
ok PROCESS.md not-selected
ok agents/swe-test.md not-selected
ok templates/records/evidence.md selection-key
ok templates/records/evidence.md touched-key
ok templates/records/evidence.md not-selected-result
```

### R4.S2 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md pick-named $'it is agent or live class and the plan\'s test map has a row whose Test cell is its test name'; h agents/swe-test.md pick-named $'it is agent or live class and the plan\'s test map has a row whose Test cell is its test name'; h skills/swe-pod/SKILL.md pick-named $'it is agent or live class and the plan\'s test map has a row whose Test cell is its test name'; h PROCESS.md no-session 'it starts no session for a test it does not pick'; h agents/swe-test.md no-session 'it starts no session for a test it does not pick'; h PROCESS.md full-on-word $'A full regression, `selection: full`, runs only on the operator\'s word.'; h agents/swe-test.md full-on-word $'A full regression, `selection: full`, runs only on the operator\'s word.'; h PROCESS.md other-space $'Tests in another project\'s space are never picked.'; h agents/swe-test.md other-space $'Tests in another project\'s space are never picked.'; h skills/swe-pod/SKILL.md other-space $'Tests in another project\'s space are never picked.'; n PROCESS.md run-whole-suite $'the change\'s project-level tests and the space\'s regression suite `tests/`;'
```

- expected output: every line begins `ok`. Red at b7fc257: no rule that leaves an unnamed agent or live test unpicked; PROCESS.md still runs all of `tests/`.
- red at b7fc257 (0 of 11 lines ok):

```text
MISSING PROCESS.md pick-named
MISSING agents/swe-test.md pick-named
MISSING skills/swe-pod/SKILL.md pick-named
MISSING PROCESS.md no-session
MISSING agents/swe-test.md no-session
MISSING PROCESS.md full-on-word
MISSING agents/swe-test.md full-on-word
MISSING PROCESS.md other-space
MISSING agents/swe-test.md other-space
MISSING skills/swe-pod/SKILL.md other-space
STILL PROCESS.md run-whole-suite
```

- green at 0debc5a (11 of 11 lines ok):

```text
ok PROCESS.md pick-named
ok agents/swe-test.md pick-named
ok skills/swe-pod/SKILL.md pick-named
ok PROCESS.md no-session
ok agents/swe-test.md no-session
ok PROCESS.md full-on-word
ok agents/swe-test.md full-on-word
ok PROCESS.md other-space
ok agents/swe-test.md other-space
ok skills/swe-pod/SKILL.md other-space
ok PROCESS.md no-run-whole-suite
```

### R6.S1 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md risk-decides $'Risk, not size, decides independent tests: a requirement the plan marks at risk gets blind project-level tests, written by a test agent that never saw the build, at any size; a requirement not at risk gets none beyond its builder\'s tests, which the review checks against its scenarios.'; h agents/swe-plan.md risk-decides $'Risk, not size, decides independent tests: a requirement the plan marks at risk gets blind project-level tests, written by a test agent that never saw the build, at any size; a requirement not at risk gets none beyond its builder\'s tests, which the review checks against its scenarios.'; h README.md risk-decides $'Risk, not size, decides independent tests: a requirement the plan marks at risk gets blind project-level tests, written by a test agent that never saw the build, at any size; a requirement not at risk gets none beyond its builder\'s tests, which the review checks against its scenarios.'; h PROCESS.md brief-at-risk 'covers the scenarios of the requirements the plan marks at risk, and no others'; h agents/swe-lead.md brief-at-risk 'covers the scenarios of the requirements the plan marks at risk, and no others'; h PROCESS.md tests-at-risk 'at least one test per scenario of each requirement the plan marks at risk'; h agents/swe-test.md tests-at-risk 'at least one test per scenario of each requirement the plan marks at risk'; h PROCESS.md review-important $'For each scenario of a requirement not at risk, the review checks that its builder\'s test exercises it, and records an Important finding where one does not.'; h agents/swe-review.md review-important $'For each scenario of a requirement not at risk, the review checks that its builder\'s test exercises it, and records an Important finding where one does not.'
```

- expected output: every line begins `ok`. Red at b7fc257: blind tests are written for every scenario; no risk-decides rule, no at-risk-only brief, no review check of builders' tests.
- red at b7fc257 (0 of 9 lines ok):

```text
MISSING PROCESS.md risk-decides
MISSING agents/swe-plan.md risk-decides
MISSING README.md risk-decides
MISSING PROCESS.md brief-at-risk
MISSING agents/swe-lead.md brief-at-risk
MISSING PROCESS.md tests-at-risk
MISSING agents/swe-test.md tests-at-risk
MISSING PROCESS.md review-important
MISSING agents/swe-review.md review-important
```

- green at 0debc5a (9 of 9 lines ok):

```text
ok PROCESS.md risk-decides
ok agents/swe-plan.md risk-decides
ok README.md risk-decides
ok PROCESS.md brief-at-risk
ok agents/swe-lead.md brief-at-risk
ok PROCESS.md tests-at-risk
ok agents/swe-test.md tests-at-risk
ok PROCESS.md review-important
ok agents/swe-review.md review-important
```

### R6.S2 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md no-test-task 'A plan that marks no requirement at risk has no test-writing task.'; h agents/swe-plan.md no-test-task 'A plan that marks no requirement at risk has no test-writing task.'; h PROCESS.md builder-test $'A builder\'s test is a unit test or, in a repo with no unit suite, a check in the build task\'s done-when.'; h agents/swe-plan.md builder-test $'A builder\'s test is a unit test or, in a repo with no unit suite, a check in the build task\'s done-when.'; h agents/swe-build.md builder-test $'A builder\'s test is a unit test or, in a repo with no unit suite, a check in the build task\'s done-when.'; h templates/records/plan.md donewhen-row '| R<n>.S<m> | T<n> done-when |'; h skills/swe-pod/SKILL.md trace-donewhen 'When that name is `T<n> done-when`, the row needs no test file'
```

- expected output: every line begins `ok`. Red at b7fc257: no rule that a plan with nothing at risk has no test-writing task; no done-when builder tests; the trace needs a file for every row.
- red at b7fc257 (0 of 7 lines ok):

```text
MISSING PROCESS.md no-test-task
MISSING agents/swe-plan.md no-test-task
MISSING PROCESS.md builder-test
MISSING agents/swe-plan.md builder-test
MISSING agents/swe-build.md builder-test
MISSING templates/records/plan.md donewhen-row
MISSING skills/swe-pod/SKILL.md trace-donewhen
```

- green at 0debc5a (7 of 7 lines ok):

```text
ok PROCESS.md no-test-task
ok agents/swe-plan.md no-test-task
ok PROCESS.md builder-test
ok agents/swe-plan.md builder-test
ok agents/swe-build.md builder-test
ok templates/records/plan.md donewhen-row
ok skills/swe-pod/SKILL.md trace-donewhen
```

### R7.S1 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md declined-covered 'is declined, naming the test that covers it, and nothing of it reaches the test agent'; h agents/swe-lead.md declined-covered 'is declined, naming the test that covers it, and nothing of it reaches the test agent'; h templates/records/ledger.md declined-line 'T<n>.TS<k> outcome: declined: covered by <test name>'; h agents/swe-lead.md declined-line 'T<n>.TS<k> outcome: declined: covered by <test name>'
```

- expected output: every line begins `ok`. Red at b7fc257: every suggestion on spec behavior is routed to the test agent; no declined-as-covered rule or form.
- red at b7fc257 (0 of 4 lines ok):

```text
MISSING PROCESS.md declined-covered
MISSING agents/swe-lead.md declined-covered
MISSING templates/records/ledger.md declined-line
MISSING agents/swe-lead.md declined-line
```

- green at 0debc5a (4 of 4 lines ok):

```text
ok PROCESS.md declined-covered
ok agents/swe-lead.md declined-covered
ok templates/records/ledger.md declined-line
ok agents/swe-lead.md declined-line
```

### R7.S2 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md route-risk 'to the test agent only when it covers a risk no planned test covers, naming that risk'; h agents/swe-lead.md route-risk 'to the test agent only when it covers a risk no planned test covers, naming that risk'; h agents/swe-build.md route-risk 'to the test agent only when it covers a risk no planned test covers, naming that risk'; h templates/records/ledger.md test-line 'T<n>.TS<k> -> test: covers <risk>'; h agents/swe-lead.md test-line 'T<n>.TS<k> -> test: covers <risk>'; h templates/records/final-report.md outcome-line '- T<n>.TS<k> <title>: <outcome>'
```

- expected output: every line begins `ok`. Red at b7fc257: routing is not by risk; no `-> test: covers <risk>` form.
- red at b7fc257 (1 of 6 lines ok):

```text
MISSING PROCESS.md route-risk
MISSING agents/swe-lead.md route-risk
MISSING agents/swe-build.md route-risk
MISSING templates/records/ledger.md test-line
MISSING agents/swe-lead.md test-line
ok templates/records/final-report.md outcome-line
```

- green at 0debc5a (6 of 6 lines ok):

```text
ok PROCESS.md route-risk
ok agents/swe-lead.md route-risk
ok agents/swe-build.md route-risk
ok templates/records/ledger.md test-line
ok agents/swe-lead.md test-line
ok templates/records/final-report.md outcome-line
```

### R8.S1 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md reproduce-confirm 'only to reproduce a reported defect and confirm its fix: one run at base and one at the branch head, each with its reason'; h agents/swe-plan.md reproduce-confirm 'only to reproduce a reported defect and confirm its fix: one run at base and one at the branch head, each with its reason'; h PROCESS.md selfreview-live 'a live or heavy test is listed only to reproduce a reported defect and confirm its fix, or with the reason no cheaper check can show the behavior'; h agents/swe-plan.md selfreview-live 'a live or heavy test is listed only to reproduce a reported defect and confirm its fix, or with the reason no cheaper check can show the behavior'; h templates/records/plan.md selfreview-live '- [ ] a live or heavy test is listed only to reproduce a reported defect and confirm its fix, or with the reason no cheaper check can show the behavior'
```

- expected output: every line begins `ok`. Red at b7fc257: no rule limiting live or heavy tests to reproduce and confirm.
- red at b7fc257 (0 of 5 lines ok):

```text
MISSING PROCESS.md reproduce-confirm
MISSING agents/swe-plan.md reproduce-confirm
MISSING PROCESS.md selfreview-live
MISSING agents/swe-plan.md selfreview-live
MISSING templates/records/plan.md selfreview-live
```

- green at 0debc5a (5 of 5 lines ok):

```text
ok PROCESS.md reproduce-confirm
ok agents/swe-plan.md reproduce-confirm
ok PROCESS.md selfreview-live
ok agents/swe-plan.md selfreview-live
ok templates/records/plan.md selfreview-live
```

### R8.S2 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md cheaper-check 'Where a script-class check can show the behavior, its test is script class, and the plan lists no agent-class or live-class run for it.'; h agents/swe-plan.md cheaper-check 'Where a script-class check can show the behavior, its test is script class, and the plan lists no agent-class or live-class run for it.'; h templates/records/plan.md class-column '| Class |'
```

- expected output: every line begins `ok`. Red at b7fc257: no rule choosing the script-class check; the test map has no Class column.
- red at b7fc257 (0 of 3 lines ok):

```text
MISSING PROCESS.md cheaper-check
MISSING agents/swe-plan.md cheaper-check
MISSING templates/records/plan.md class-column
```

- green at 0debc5a (3 of 3 lines ok):

```text
ok PROCESS.md cheaper-check
ok agents/swe-plan.md cheaper-check
ok templates/records/plan.md class-column
```

### R9.S1 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md abort-120 $'is aborted 120 s after launch when its session has not reached the test\'s first step, and ends as `harness-error`, naming where it stopped, with no pass or fail for its tests'; h agents/swe-test.md abort-120 $'is aborted 120 s after launch when its session has not reached the test\'s first step, and ends as `harness-error`, naming where it stopped, with no pass or fail for its tests'; h PROCESS.md not-a-limit 'a mechanism that stops a stuck run, not a time limit on the test'; h agents/swe-test.md not-a-limit 'a mechanism that stops a stuck run, not a time limit on the test'; h templates/records/evidence.md harness-error-result 'harness-error'; h templates/records/ledger.md harness-line 'T<n> harness error: <test name>, attempt <k>/3, stopped at <where>'
```

- expected output: every line begins `ok`. Red at b7fc257: no 120 s abort, no `harness-error` result and no harness-error ledger form.
- red at b7fc257 (0 of 6 lines ok):

```text
MISSING PROCESS.md abort-120
MISSING agents/swe-test.md abort-120
MISSING PROCESS.md not-a-limit
MISSING agents/swe-test.md not-a-limit
MISSING templates/records/evidence.md harness-error-result
MISSING templates/records/ledger.md harness-line
```

- green at 0debc5a (6 of 6 lines ok):

```text
ok PROCESS.md abort-120
ok agents/swe-test.md abort-120
ok PROCESS.md not-a-limit
ok agents/swe-test.md not-a-limit
ok templates/records/evidence.md harness-error-result
ok templates/records/ledger.md harness-line
```

### R9.S2 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md rerun-no-ask 'A rerun after a harness fix that changes no expected value needs no ask'; h agents/swe-test.md rerun-no-ask 'A rerun after a harness fix that changes no expected value needs no ask'; h agents/swe-lead.md rerun-no-ask 'A rerun after a harness fix that changes no expected value needs no ask'; h PROCESS.md harness-key '`harness: <space sha7>`, the space commit holding the harness the run used'; h agents/swe-test.md harness-key '`harness: <space sha7>`, the space commit holding the harness the run used'; h templates/records/evidence.md harness-key 'harness: <space sha7>'; h PROCESS.md third-blocked 'After a third harness error in one task, the task stops and reports BLOCKED'; h agents/swe-test.md third-blocked 'After a third harness error in one task, the task stops and reports BLOCKED'; h agents/swe-lead.md third-blocked 'After a third harness error in one task, the task stops and reports BLOCKED'
```

- expected output: every line begins `ok`. Red at b7fc257: no no-ask rerun rule, no `harness:` key, and no BLOCKED after a third harness error.
- red at b7fc257 (0 of 9 lines ok):

```text
MISSING PROCESS.md rerun-no-ask
MISSING agents/swe-test.md rerun-no-ask
MISSING agents/swe-lead.md rerun-no-ask
MISSING PROCESS.md harness-key
MISSING agents/swe-test.md harness-key
MISSING templates/records/evidence.md harness-key
MISSING PROCESS.md third-blocked
MISSING agents/swe-test.md third-blocked
MISSING agents/swe-lead.md third-blocked
```

- green at 0debc5a (9 of 9 lines ok):

```text
ok PROCESS.md rerun-no-ask
ok agents/swe-test.md rerun-no-ask
ok agents/swe-lead.md rerun-no-ask
ok PROCESS.md harness-key
ok agents/swe-test.md harness-key
ok templates/records/evidence.md harness-key
ok PROCESS.md third-blocked
ok agents/swe-test.md third-blocked
ok agents/swe-lead.md third-blocked
```

### R10.S1 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md per-wave 'one review per wave of build tasks, a review of one build task only where its entry has `- risk: at risk`, and the whole-change review'; h agents/swe-plan.md per-wave 'one review per wave of build tasks, a review of one build task only where its entry has `- risk: at risk`, and the whole-change review'; h templates/records/plan.md per-wave 'one review per wave of build tasks, a review of one build task only where its entry has `- risk: at risk`, and the whole-change review'; h PROCESS.md wave-def 'A wave is a group of build tasks the dependency summary runs together, and its review covers those of them not reviewed alone.'; h agents/swe-plan.md wave-def 'A wave is a group of build tasks the dependency summary runs together, and its review covers those of them not reviewed alone.'; h templates/records/plan.md wave-entry '### T<n> Review of wave <w>'; n PROCESS.md per-task-reviews 'Review tasks:** one per build task'; n agents/swe-plan.md per-task-reviews 'Review tasks: one per build task'
```

- expected output: every line begins `ok`. Red at b7fc257: reviews are one per build task; no wave rule.
- red at b7fc257 (0 of 8 lines ok):

```text
MISSING PROCESS.md per-wave
MISSING agents/swe-plan.md per-wave
MISSING templates/records/plan.md per-wave
MISSING PROCESS.md wave-def
MISSING agents/swe-plan.md wave-def
MISSING templates/records/plan.md wave-entry
STILL PROCESS.md per-task-reviews
STILL agents/swe-plan.md per-task-reviews
```

- green at 0debc5a (8 of 8 lines ok):

```text
ok PROCESS.md per-wave
ok agents/swe-plan.md per-wave
ok templates/records/plan.md per-wave
ok PROCESS.md wave-def
ok agents/swe-plan.md wave-def
ok templates/records/plan.md wave-entry
ok PROCESS.md no-per-task-reviews
ok agents/swe-plan.md no-per-task-reviews
```

### R10.S2 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md one-wave 'A plan whose build tasks form one wave has one review, the whole-change review.'; h agents/swe-plan.md one-wave 'A plan whose build tasks form one wave has one review, the whole-change review.'; h agents/swe-lead.md one-wave 'A plan whose build tasks form one wave has one review, the whole-change review.'; h templates/records/plan.md one-wave 'A plan whose build tasks form one wave has one review, the whole-change review.'; h PROCESS.md capable 'Every role runs on the most capable model available.'; h agents/swe-lead.md capable 'Every role runs on the most capable model available.'
```

- expected output: every line begins `ok`. Red at b7fc257: no one-wave, one-review rule; no every-role model sentence.
- red at b7fc257 (0 of 6 lines ok):

```text
MISSING PROCESS.md one-wave
MISSING agents/swe-plan.md one-wave
MISSING agents/swe-lead.md one-wave
MISSING templates/records/plan.md one-wave
MISSING PROCESS.md capable
MISSING agents/swe-lead.md capable
```

- green at 0debc5a (6 of 6 lines ok):

```text
ok PROCESS.md one-wave
ok agents/swe-plan.md one-wave
ok agents/swe-lead.md one-wave
ok templates/records/plan.md one-wave
ok PROCESS.md capable
ok agents/swe-lead.md capable
```

### R11.S1 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md all-minor 'A review whose open findings are all Minor starts no fix round: its Minor findings are fixed in the whole-change fix wave or parked by a ruling.'; h agents/swe-lead.md all-minor 'A review whose open findings are all Minor starts no fix round: its Minor findings are fixed in the whole-change fix wave or parked by a ruling.'; h agents/swe-review.md all-minor 'A review whose open findings are all Minor starts no fix round: its Minor findings are fixed in the whole-change fix wave or parked by a ruling.'; h templates/records/final-report.md minor-outcome '<fixed in the whole-change fix wave, or parked by the ruling at <UTC>>'; n PROCESS.md minors-to-ledger 'Minor findings go to the ledger for the whole-change review.'; n agents/swe-lead.md minors-to-ledger 'Minor findings stay in the ledger for the whole-change review.'; n agents/swe-review.md minors-to-ledger 'Minor ones go to the ledger for the whole-change review.'
```

- expected output: every line begins `ok`. Red at b7fc257: Minor findings go to the ledger for the whole-change review; no no-fix-round rule.
- red at b7fc257 (0 of 7 lines ok):

```text
MISSING PROCESS.md all-minor
MISSING agents/swe-lead.md all-minor
MISSING agents/swe-review.md all-minor
MISSING templates/records/final-report.md minor-outcome
STILL PROCESS.md minors-to-ledger
STILL agents/swe-lead.md minors-to-ledger
STILL agents/swe-review.md minors-to-ledger
```

- green at 0debc5a (7 of 7 lines ok):

```text
ok PROCESS.md all-minor
ok agents/swe-lead.md all-minor
ok agents/swe-review.md all-minor
ok templates/records/final-report.md minor-outcome
ok PROCESS.md no-minors-to-ledger
ok agents/swe-lead.md no-minors-to-ledger
ok agents/swe-review.md no-minors-to-ledger
```

### R11.S2 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md carries-only 'Only Critical and Important findings start a fix round, and a fix round carries only those.'; h agents/swe-lead.md carries-only 'Only Critical and Important findings start a fix round, and a fix round carries only those.'; h agents/swe-review.md carries-only 'Only Critical and Important findings start a fix round, and a fix round carries only those.'; h agents/swe-build.md carries-only 'Only Critical and Important findings start a fix round, and a fix round carries only those.'; h PROCESS.md fix-wave 'The whole-change fix wave runs only when the whole-change review has a Critical or Important finding, and then also takes the batched Minor findings; with none, they are parked by one ruling and listed in the final report.'; h agents/swe-lead.md fix-wave 'The whole-change fix wave runs only when the whole-change review has a Critical or Important finding, and then also takes the batched Minor findings; with none, they are parked by one ruling and listed in the final report.'
```

- expected output: every line begins `ok`. Red at b7fc257: a fix round is not limited to Critical and Important findings; no fix-wave rule.
- red at b7fc257 (0 of 6 lines ok):

```text
MISSING PROCESS.md carries-only
MISSING agents/swe-lead.md carries-only
MISSING agents/swe-review.md carries-only
MISSING agents/swe-build.md carries-only
MISSING PROCESS.md fix-wave
MISSING agents/swe-lead.md fix-wave
```

- green at 0debc5a (6 of 6 lines ok):

```text
ok PROCESS.md carries-only
ok agents/swe-lead.md carries-only
ok agents/swe-review.md carries-only
ok agents/swe-build.md carries-only
ok PROCESS.md fix-wave
ok agents/swe-lead.md fix-wave
```

### R12.S1 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md keep-only $'only the change\'s tests the plan\'s test map marks `keep`'; h agents/swe-lead.md keep-only $'only the change\'s tests the plan\'s test map marks `keep`'; h PROCESS.md others-stay $'the others stay in the change\'s folder'; h agents/swe-lead.md others-stay $'the others stay in the change\'s folder'; h templates/records/plan.md keep-form 'Keep is `keep` or `not kept: <reason>`'; h templates/records/final-report.md tests-kept '## Tests kept'; h templates/records/final-report.md kept-line '- kept: <test name>: <reason>'; h templates/records/final-report.md not-kept-line '- not kept: <test name>: <reason>'; h README.md keep 'only the tests the plan marks to keep join'; n PROCESS.md move-all $'move `changes/<id>/tests/` into `tests/`, as the folder `tests/<id>/`'; n agents/swe-lead.md move-all $'move `changes/<id>/tests/` into `tests/`, as the folder `tests/<id>/`'
```

- expected output: every line begins `ok`. Red at b7fc257: integrate moves every test into `tests/`; no Keep column and no Tests kept section.
- red at b7fc257 (0 of 11 lines ok):

```text
MISSING PROCESS.md keep-only
MISSING agents/swe-lead.md keep-only
MISSING PROCESS.md others-stay
MISSING agents/swe-lead.md others-stay
MISSING templates/records/plan.md keep-form
MISSING templates/records/final-report.md tests-kept
MISSING templates/records/final-report.md kept-line
MISSING templates/records/final-report.md not-kept-line
MISSING README.md keep
STILL PROCESS.md move-all
STILL agents/swe-lead.md move-all
```

- green at 0debc5a (11 of 11 lines ok):

```text
ok PROCESS.md keep-only
ok agents/swe-lead.md keep-only
ok PROCESS.md others-stay
ok agents/swe-lead.md others-stay
ok templates/records/plan.md keep-form
ok templates/records/final-report.md tests-kept
ok templates/records/final-report.md kept-line
ok templates/records/final-report.md not-kept-line
ok README.md keep
ok PROCESS.md no-move-all
ok agents/swe-lead.md no-move-all
```

### R12.S2 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md supersedes-out 'the tests and fixtures of each requirement the spec supersedes'; h agents/swe-lead.md supersedes-out 'the tests and fixtures of each requirement the spec supersedes'; h PROCESS.md superseded-folder 'under `superseded-tests/`'; h agents/swe-lead.md superseded-folder 'under `superseded-tests/`'; h PROCESS.md stale 'each test the change made stale that no test task updated'; h agents/swe-lead.md stale 'each test the change made stale that no test task updated'; h PROCESS.md none-failing 'so no test left in `tests/` is known to fail'; h agents/swe-lead.md none-failing 'so no test left in `tests/` is known to fail'; h templates/records/final-report.md moved-out-line '- moved out: <test name>: <reason>'
```

- expected output: every line begins `ok`. Red at b7fc257: no rule moving superseded or stale tests out of `tests/`.
- red at b7fc257 (0 of 9 lines ok):

```text
MISSING PROCESS.md supersedes-out
MISSING agents/swe-lead.md supersedes-out
MISSING PROCESS.md superseded-folder
MISSING agents/swe-lead.md superseded-folder
MISSING PROCESS.md stale
MISSING agents/swe-lead.md stale
MISSING PROCESS.md none-failing
MISSING agents/swe-lead.md none-failing
MISSING templates/records/final-report.md moved-out-line
```

- green at 0debc5a (9 of 9 lines ok):

```text
ok PROCESS.md supersedes-out
ok agents/swe-lead.md supersedes-out
ok PROCESS.md superseded-folder
ok agents/swe-lead.md superseded-folder
ok PROCESS.md stale
ok agents/swe-lead.md stale
ok PROCESS.md none-failing
ok agents/swe-lead.md none-failing
ok templates/records/final-report.md moved-out-line
```

### R13.S1 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md declares 'Each test declares its cost class, its `expected_s:` (its expected run time in s) and its `deliverables: [<repo>:<path>[ as <name>], ...]` (what it reads).'; h agents/swe-test.md declares 'Each test declares its cost class, its `expected_s:` (its expected run time in s) and its `deliverables: [<repo>:<path>[ as <name>], ...]` (what it reads).'; h PROCESS.md classes '`script` (starts no agent session: inspection checks, scripts, unit suites), `agent` (starts an agent session), `live` (drives an interactive session or a running node)'; h agents/swe-test.md classes '`script` (starts no agent session: inspection checks, scripts, unit suites), `agent` (starts an agent session), `live` (drives an interactive session or a running node)'; h PROCESS.md kept-carry 'Each kept test gives its cost class, its expected run time in s and the deliverables it reads'; h agents/swe-lead.md kept-carry 'Each kept test gives its cost class, its expected run time in s and the deliverables it reads'
```

- expected output: every line begins `ok`. Red at b7fc257: tests record only their run time; no cost classes and no kept-test rule.
- red at b7fc257 (0 of 6 lines ok):

```text
MISSING PROCESS.md declares
MISSING agents/swe-test.md declares
MISSING PROCESS.md classes
MISSING agents/swe-test.md classes
MISSING PROCESS.md kept-carry
MISSING agents/swe-lead.md kept-carry
```

- green at 0debc5a (6 of 6 lines ok):

```text
ok PROCESS.md declares
ok agents/swe-test.md declares
ok PROCESS.md classes
ok agents/swe-test.md classes
ok PROCESS.md kept-carry
ok agents/swe-lead.md kept-carry
```

### R13.S2 done-when check

In fix round 1 the check was rewritten. The current command, with its red output at b7fc257 and its green output at 3b22a1b, is under `## Fix round 1`, `### R13.S2 done-when check`.

### R14.S1 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md cost-report $'gives the plan\'s estimate beside the actual wall time in s and spend in USD of the expensive runs, with the ratio of actual to estimate, rounded to 0.1, the total test wall time in s, and the counts of test agents, review agents, fix rounds and asks to the operator about tests'; h agents/swe-lead.md cost-report $'gives the plan\'s estimate beside the actual wall time in s and spend in USD of the expensive runs, with the ratio of actual to estimate, rounded to 0.1, the total test wall time in s, and the counts of test agents, review agents, fix rounds and asks to the operator about tests'; h templates/records/final-report.md test-cost '## Test cost'; h templates/records/final-report.md cost-table '| Expensive runs | Estimate | Actual | Actual / estimate |'; h templates/records/final-report.md ratio '| wall time (s) | <s> | <s> | <ratio, to 0.1> |'; h templates/records/final-report.md total-time '- total test wall time: <s> s'; h templates/records/final-report.md test-agents '- test agents: <n>'; h templates/records/final-report.md review-agents '- review agents: <n>'; h templates/records/final-report.md fix-rounds '- fix rounds: <n>'; h templates/records/final-report.md asks '- asks to the operator about tests: <n>'
```

- expected output: every line begins `ok`. Red at b7fc257: the final report has no Test cost section.
- red at b7fc257 (0 of 10 lines ok):

```text
MISSING PROCESS.md cost-report
MISSING agents/swe-lead.md cost-report
MISSING templates/records/final-report.md test-cost
MISSING templates/records/final-report.md cost-table
MISSING templates/records/final-report.md ratio
MISSING templates/records/final-report.md total-time
MISSING templates/records/final-report.md test-agents
MISSING templates/records/final-report.md review-agents
MISSING templates/records/final-report.md fix-rounds
MISSING templates/records/final-report.md asks
```

- green at 0debc5a (10 of 10 lines ok):

```text
ok PROCESS.md cost-report
ok agents/swe-lead.md cost-report
ok templates/records/final-report.md test-cost
ok templates/records/final-report.md cost-table
ok templates/records/final-report.md ratio
ok templates/records/final-report.md total-time
ok templates/records/final-report.md test-agents
ok templates/records/final-report.md review-agents
ok templates/records/final-report.md fix-rounds
ok templates/records/final-report.md asks
```

### R14.S2 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md unknown 'is unknown, never 0 USD: the cell gives the known sum and `unknown for <k> of <n> runs`, or `unknown` with none known'; h agents/swe-lead.md unknown 'is unknown, never 0 USD: the cell gives the known sum and `unknown for <k> of <n> runs`, or `unknown` with none known'; h templates/records/final-report.md spend-row '| spend (USD) | <USD> | <USD, or unknown> | <ratio, to 0.1, or unknown> |'; h templates/records/final-report.md unknown-k 'unknown for <k> of <n> runs'; h templates/records/final-report.md never-zero 'Never 0 USD for a run whose spend no one knows.'
```

- expected output: every line begins `ok`. Red at b7fc257: no unknown-spend rule.
- red at b7fc257 (0 of 5 lines ok):

```text
MISSING PROCESS.md unknown
MISSING agents/swe-lead.md unknown
MISSING templates/records/final-report.md spend-row
MISSING templates/records/final-report.md unknown-k
MISSING templates/records/final-report.md never-zero
```

- green at 0debc5a (5 of 5 lines ok):

```text
ok PROCESS.md unknown
ok agents/swe-lead.md unknown
ok templates/records/final-report.md spend-row
ok templates/records/final-report.md unknown-k
ok templates/records/final-report.md never-zero
```

### R15.S1 done-when check

- command (run with `SWE` a swe-pod checkout and `REV` a sha):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; for r in spec plan lead build test review; do git -C "$SWE" show "$REV:agents/swe-$r.md" | sed -n '1,/^---$/{/^model: inherit$/p;}' | grep -q . && echo "ok agents/swe-$r.md model-inherit" || echo "MISSING agents/swe-$r.md model-inherit"; done; h PROCESS.md capable 'Every role runs on the most capable model available.'; h agents/swe-lead.md capable 'Every role runs on the most capable model available.'; h README.md capable 'Every role runs on the most capable model available.'; h INSTALL.md capable 'Every role runs on the most capable model available.'; h PROCESS.md same-model 'rounds 4 and 5 go to a fresh builder on the same model'; h agents/swe-lead.md same-model 'rounds 4 and 5 go to a fresh builder on the same model'; h PROCESS.md never-lesser 'never picks a lesser model to save cost'; h agents/swe-lead.md never-lesser 'never picks a lesser model to save cost'; h PROCESS.md independence 'Independence between agents comes from a fresh session or another node, never from a lesser model.'; h agents/swe-lead.md independence 'Independence between agents comes from a fresh session or another node, never from a lesser model.'; echo "lines-allowing-another-model $(git -C "$SWE" grep -i -E 'cheaper (one|model)|stronger model|different model|pick the model for the work' "$REV" -- PROCESS.md agents skills templates README.md INSTALL.md | wc -l | tr -d ' ')"
```

- expected output: every line begins `ok`, and the last line is `lines-allowing-another-model 0`. Red at b7fc257: no every-role model sentence; rounds 4 and 5 go to a stronger model; the lead picks a cheaper model for mechanical tasks; 4 lines allow another model.
- red at b7fc257 (6 of 17 lines ok):

```text
ok agents/swe-spec.md model-inherit
ok agents/swe-plan.md model-inherit
ok agents/swe-lead.md model-inherit
ok agents/swe-build.md model-inherit
ok agents/swe-test.md model-inherit
ok agents/swe-review.md model-inherit
MISSING PROCESS.md capable
MISSING agents/swe-lead.md capable
MISSING README.md capable
MISSING INSTALL.md capable
MISSING PROCESS.md same-model
MISSING agents/swe-lead.md same-model
MISSING PROCESS.md never-lesser
MISSING agents/swe-lead.md never-lesser
MISSING PROCESS.md independence
MISSING agents/swe-lead.md independence
lines-allowing-another-model 4
```

- green at 0debc5a (16 of 17 lines ok):

```text
ok agents/swe-spec.md model-inherit
ok agents/swe-plan.md model-inherit
ok agents/swe-lead.md model-inherit
ok agents/swe-build.md model-inherit
ok agents/swe-test.md model-inherit
ok agents/swe-review.md model-inherit
ok PROCESS.md capable
ok agents/swe-lead.md capable
ok README.md capable
ok INSTALL.md capable
ok PROCESS.md same-model
ok agents/swe-lead.md same-model
ok PROCESS.md never-lesser
ok agents/swe-lead.md never-lesser
ok PROCESS.md independence
ok agents/swe-lead.md independence
lines-allowing-another-model 0
```

## Concerns
- The brief's `## Interfaces` was cut off in 2.9. I built 2.9 to 2.11 from
  `plan.md` §2, and the lead's correction confirmed that text.
- Timing of the whole-change review. In a plan whose build tasks form one
  wave, I made the whole-change review the build tasks' review: it runs once
  they report and before verify (`PROCESS.md` §5 and §7, `swe-lead`,
  `swe-review`, the plan template). Otherwise it runs after verify's first
  green run, as before. Without this, a one-wave plan deadlocks: a build
  task is done only when its review closes, and verify waits for it. The
  16:22Z ruling made the same call for this change. The review should
  confirm it as the general rule.
- How reviews are recorded. The review that covers a build task is recorded
  under that task's number, one `T<n> review:` line per task it covers, and
  the whole-change review also gets a line under its own number (`PROCESS.md`
  §5, `swe-lead`). This keeps the skill's task states working with wave
  reviews unchanged; heartbeat-every-15-min recorded its one review the same
  way, as `T1 review:`. I left the skill's reading of review tasks as it is
  (out of scope).
- R3: I wrote the ask as applying to an agent-class or live-class run the
  plan does not list. An unlisted script-class run needs no ask. R3's "only
  when" allows that reading, and the spec's Why speaks only of expensive
  runs. The lead should confirm.
- R7: I kept the spec-author and builder routes for suggestions. I read
  "record every other suggestion as declined" as covering every other
  suggestion bound for the test agent: one a planned test covers is declined
  as `declined: covered by <test name>`. Plan T6 keeps
  `test_R21_S2_every_suggestion_has_outcome`, whose outcomes include
  "proposed as a scenario" and "unit-tested", which supports this reading.
- Two small additions beyond the 2.9 form. `## Tests kept` gets a third
  line, `- moved out: <test name>: <reason>`, because R12.S2 and plan T6 have
  the final report list the tests moved out. The unknown-spend rule also
  covers the Estimate cell, for R14.S2's "spend no one estimated".
- The skill (§1.6) says `not-selected` and `superseded by <key>` are no bar
  only on regression tests. On a scenario, unit suite, quality check or
  change test, either one is a bar. This follows from 2.2 and 2.4 (picks and
  `<change>/` keys exist only for regression tests). T2's R5 tests and the
  review should accept it.
- `status-format.md` now shows the regression part whenever the space has at
  least one regression test. It used to show it only when `<n>` was not 0.
  Without the change, a record that gives every regression test
  `not-selected` would show no regression part.
- The operator's guidance overlay, which is out of scope, cites the lead's
  `heavy:` approval line for test runs under G3. This change retires
  `heavy:` (plan 2.7). To give an executing node the caps and expected time
  that line used to carry, the brief of a test task now quotes the plan's
  rows for its expensive runs, with their caps and estimates (`PROCESS.md`
  §11, `swe-lead`). The operator may want to reword that overlay line.
- Files outside my touches that state nearby rules still agree with the new
  text. `templates/records/test-brief.md` sends the "for the tester" part
  alone, and that part already names the risk, as my wording requires.
  `templates/space/README.md` calls `tests/` the "regression suite: tests of
  integrated specs", which is still true. No edit needed; noted for Q1.
- `SPEC.md` keeps its old text with notes, as open call 18 asks. Its §5.2
  review line ("one per build task") gets no note, since open call 18 names
  only R5, R12, R13, R21 and the model lines.
- I1.2 and I3.14 fail at the head, as planned. T3's `@2` replacements cover
  them. No disputed test.

## Test suggestions

### T1.TS1 A superseded inspection check
- for the tester: R5 (the rule R5.S2 exercises) is at risk when the
  superseded regression test is keyed by an inspection-check id
  (`<change>/I<n>`), not a scenario id. Take a record that gives it
  `superseded by` a passing check of this change, with a spec whose
  `supersedes` lists one requirement of that earlier change. The record may
  be read as not green. The same record with a `supersedes` that lists no
  requirement of that change may be read as green.
- for the reviewer: swe-pod/skills/swe-pod/SKILL.md:266-283, the
  `superseded by <key>` condition for `I<n>` and `T<n>.TS<k>` keys; also
  swe-pod/PROCESS.md:717-737.

### T1.TS2 A touched list that leaves out a file of the diff
- for the tester: R5.S4 is at risk when the record's `touched:` leaves out
  a file the change's diff from base to head changes, and a script-class
  regression test that reads only that file is given `not-selected`. With a
  code repo whose remote can be read, the record may be read as green.
- for the reviewer: swe-pod/skills/swe-pod/SKILL.md:250-262, where the
  touched paths come from the readable diff and a `touched:` that leaves one
  out makes the record not green; swe-pod/PROCESS.md:679-705.

### T1.TS3 A deliverable that is a folder, or carries an alias
- for the tester: R4 and R5.S4 are at risk for a script-class regression
  test whose declared deliverable is a folder holding a touched file, or a
  path written with an ` as <name>` alias. Such a test is picked, and its
  `not-selected` may be read as no bar.
- for the reviewer: swe-pod/skills/swe-pod/SKILL.md:246-249, the folder
  prefix rule (touched path begins with the deliverable path and a `/`) and
  the alias strip.

### T1.TS4 Sharded verify with not-selected and superseded results
- for the tester: R5 for a sharded verify is at risk when one shard passes a
  regression test and another gives it `not-selected`, or when a
  `superseded by <key>` in one shard's record has its passing `<key>` only
  in another shard's record. The spec's "taken together" may be read
  shard by shard, giving a wrong green or not-green.
- for the reviewer: swe-pod/skills/swe-pod/SKILL.md:326-333 and
  swe-pod/skills/swe-pod/status-format.md:110-125, the combined results and
  the per-shard line.

### T1.TS5 not-selected on a scenario of the change itself
- for the tester: R5 is at risk when a record gives `not-selected` or
  `superseded by` to one of the change's own scenarios, unit suites or
  declared quality checks, not a regression test. The record may be read as
  green.
- for the reviewer: swe-pod/skills/swe-pod/SKILL.md:277-283, the sentence
  that limits the two no-bar results to regression tests.

## Fix round 1

The whole-change fix wave (T4's review, 4 Important and 18 Minor findings,
under the 17:19Z rulings).

- status: DONE_WITH_CONCERNS
- range: `swe-pod 0debc5a..3b22a1b`, one commit with trailers
  `Change: right-size-testing` and `Task: T1`, pushed. The remote head is
  `3b22a1b29aa4cae7fcaf6e317f25152ae0460981`.
- files changed (12, all in plan section 4): `PROCESS.md`, `README.md`,
  `INSTALL.md`, `agents/swe-build.md`, `agents/swe-lead.md`,
  `agents/swe-plan.md`, `agents/swe-review.md`, `agents/swe-spec.md`,
  `agents/swe-test.md`, `skills/swe-pod/SKILL.md`,
  `skills/swe-pod/status-format.md`, `templates/records/plan.md`.

### Findings

Line numbers are at 3b22a1b.

Important:

1. **Addressed.** swe-pod/PROCESS.md:723, the regression-only limit. The
   sentence from SKILL.md §1.6 now appears, in the same words, in:
   - PROCESS.md:750-753, §7 Results and the green rule;
   - agents/swe-lead.md:423-426, the Sharded verify bullet;
   - README.md:51-54, stage 4.

   The sharded "together" rule now reads, in the same words, "a pass for
   every scenario, unit suite, declared quality check and test of the
   change, and for every regression test a pass or a result that is no bar".
   It appears in PROCESS.md:827-829, agents/swe-lead.md:420-422,
   skills/swe-pod/SKILL.md §1.7 and README.md:57-59. Evidence: the
   `Evidence for Important 1` command below.
2. **Addressed.** swe-pod/skills/swe-pod/status-format.md:178, the one-wave
   whole-change review that was never ready.
   - skills/swe-pod/SKILL.md:112-127 (§1.3): a review task reviews the build
     tasks its `after:` list names. The whole-change review of a one-wave
     plan names them, so it reviews them.
   - status-format.md:184-188: a review task that reviews build tasks is
     ready once each of them has reported. status-format.md:171-175 says
     when it is done.
   - SKILL.md:404-408: Go's ready rule matches.
   - PROCESS.md:313-315 and agents/swe-plan.md:101-104 now say that review's
     `after:` list names the build tasks and that it comes before verify,
     as the plan template already did.

   Traced by hand on this change's plan: T4 is `Whole-change review`, with
   `after: [T1]` and T1 a build task. So T4 reviews T1, and it is ready
   once T1 has reported (the 16:58Z DONE_WITH_CONCERNS line), so Go
   dispatches it and `next:` names it. T4 is done once `T1 review:` and
   `T4 review:` both close.
3. **Addressed.** swe-pod/skills/swe-pod/SKILL.md:114, the wave review that
   was never ready or done (in scope by the 17:19Z ruling). The same §1.3
   rule 3 applies: a `### T<n> Review of wave <w>` reviews every build task
   its `after:` list names. It is ready once they report
   (status-format.md:184-188), and it is done when each of their
   `T<n> review:` lines is closed (status-format.md:171-173), which is
   where PROCESS.md and swe-lead record its findings. The Reviews-cell rule,
   rule 1, which reads the first id, is unchanged: that part is out of
   scope. A whole-change review whose `after:` list names only the verify
   task reviews no build task and still counts its own review lines
   (status-format.md:174-175). That is the shape of T2's R5.S3 and R5.S4
   fixtures, so their reading is unchanged. Evidence: the
   `Evidence for Important 2 and 3` command below.
4. **Addressed.** space/changes/right-size-testing/tasks/T1-report.md:940,
   the R13.S2 check. It is rewritten (below): it maps every test in the
   space's `tests/build-swe-pod/` by the rule as swe-pod states it at
   `$REV`. It is red at b7fc257 (90 of 90 tests have no class) and green at
   3b22a1b (16 script, 74 agent, 0 live; none lacks `expected_s:` or
   `deliverables:`).

Minor:

1. **Addressed.** agents/swe-build.md:154. It now says the lead declines a
   suggestion bound for the test agent whose risk a planned test covers, and
   that the spec-author and builder routes stay (agents/swe-build.md:152-158,
   per the 17:19Z R7 ruling).
2. **Addressed.** PROCESS.md:355. It now reads "only about an agent-class or
   live-class run the plan does not list, or one past twice the estimate"
   (PROCESS.md:365-367), matching §11 and the 17:19Z R3 ruling.
3. **Addressed.** PROCESS.md:302, the supersedes test task. In all five
   places it now writes the replacements in `changes/<id>/tests/`, verify
   gives the old tests `superseded by <key>`, and integrate moves them out:
   PROCESS.md:215-219 (§3), PROCESS.md:304-307 (§4 item 6),
   agents/swe-plan.md:92-95, agents/swe-plan.md:191 ("replacement-test
   task") and agents/swe-spec.md:104-107.
4. **Addressed.** SKILL.md:248. A deliverable path that ends in `/` holds a
   touched path that begins with it, and an empty path or `.` names the
   whole repo (SKILL.md:254-258).
5. **Addressed.** status-format.md:125. A shard's own line now looks for a
   `superseded by <key>` result's `<key>` in every shard's latest record,
   as the combined line does (status-format.md:124-130). The broken line at
   127 is reflowed.
6. **Addressed.** status-format.md:186, the new ledger forms. SKILL.md §1.4
   (lines 156-158) reads harness-error and not-dispatched lines. A task with
   a not-dispatched line and no newer dispatch line is `blocked`
   (status-format.md:177-179), so `next:` lists it under `blocked:`. Both
   lines are task events, with cell texts in the Latest table
   (status-format.md:191-194 and 207-208).
7. **Not addressed in the template.** templates/records/review.md:18. That
   template is outside T1's touches: plan section 4 lists no review
   template, and a builder may not stage a file outside its touches.
   Instead, the `## Quality` part of agents/swe-review.md (lines 84-88) now
   names the check, which is the text the reviewer reads: for each scenario
   of a requirement not at risk, whether its builder's test exercises it,
   with an Important finding where one does not. The template line needs
   the file map to grow, or a ruling. See Concerns, below.
8. **Addressed.** templates/records/plan.md:174. The regression row's Keep
   cell is now `keep`, and the comment says a regression test's row is keep
   because it stays in `tests/` (templates/records/plan.md:166-178). This
   change's own `plan.md` §9 still writes `already in tests/` for
   `build-swe-pod/R12.S1`. That is the plan's text, not mine to edit; the
   skill does not read the Keep cell of a regression row.
9. **Addressed.** templates/records/plan.md:146. It now reads "the latest
   evidence when there is one" (templates/records/plan.md:148-150).
10. **Addressed.** PROCESS.md:765. In a one-wave plan, a fix that lands
    after the whole-change review, such as one routed from a verify
    failure, gets a review of its fix diff only (PROCESS.md:795-798,
    agents/swe-lead.md:387-390).
11. **Addressed, with a choice.** PROCESS.md:304, the two unsettled cases.
    - A one-wave plan with a build task marked at risk: the one review, the
      whole-change review, covers every build task, those marked at risk
      included. Reason: R10.S2's THEN ("there is one") is unconditional for
      a plan whose build tasks form one wave, and R10's "a review of a
      single build task only where it marks that task at risk" permits a
      single-task review but does not require one.
    - A wave whose build tasks are all marked at risk has no wave review:
      their own reviews cover it. Reason: R10.S1 defines a wave's review as
      "covering its tasks other than" the one reviewed alone, so with none
      left it would cover nothing.

    Both sentences appear in the same words in PROCESS.md:310-317 (§4 item
    7), PROCESS.md:479-484 (§5), agents/swe-plan.md:97-106,
    agents/swe-lead.md:346-352 and templates/records/plan.md:118-126.
12. **Addressed.** PROCESS.md:1087. A test-writing brief carries the plan's
    expensive-run rows under its global constraints (PROCESS.md:530-537,
    agents/swe-lead.md:154-156). §11 and swe-lead say where they go: under
    `## Global constraints` in a test-writing brief, in `## Task` in a
    verify brief (PROCESS.md:1107-1110, agents/swe-lead.md:463-466). The
    rows hold nothing of the build, so the blind rule holds.
    `templates/records/test-brief.md` needs no change, since the rows go in
    its existing Global constraints section.
13. **Addressed.** INSTALL.md:134. G3 is now "A listed test run after the go
    counts as operator-posted": for every run the plan lists, the runs a
    test-writing task makes at base included (INSTALL.md:134-139). See
    Concerns, below.
14. **Addressed.** agents/swe-test.md:190. Verify step 3 now has the
    readable-diff and not-green clause in PROCESS.md's words
    (agents/swe-test.md:199-202).
15. **Addressed.** PROCESS.md:328. It now names the cases that are at risk:
    "A requirement is at risk when a fault in it would be costly or would
    show only late, such as a fix for a reported defect seen only in a live
    session, or a rule that decides whether a change is verified; otherwise
    it is small" (PROCESS.md:338-341, agents/swe-plan.md:120-123). The
    R1.S2 check gains two lines for it (below).
16. **Addressed.** README.md:39. It now reads "a review of a build task of
    its own" (README.md:39-40).
17. **Addressed.** PROCESS.md:1055. The Ordering bullet is reflowed
    (PROCESS.md:1072-1078).
18. **Addressed.** agents/swe-build.md:106. Reflowed.

### Checks whose text changed
- R13.S2: rewritten (Important 4).
- R1.S2: two lines added (Minor 15).
- No other check's expected sentence changed: all 26 pass at 3b22a1b with
  their first-round lines.

### Regression and change tests at 3b22a1b

The command is as in `### Done-when: the six script-class regression tests`
above, with `--repo swe-pod=<swe-pod checkout>@3b22a1b`. To it I added T2's
two script-class R5 tests and T3's two replacements, from
`changes/right-size-testing/tests/` (read-only runs; nothing edited). Wall
time was 5.9 s.

```text
RESULT test_I1_process_md fail (check I1.2: line 1 and line 3 as contract 2.2 gives them)
RESULT test_I2_role_definitions pass (all 4 checks pass)
RESULT test_I3_d3_templates fail (check I3.14: pod.yaml keys and pinned process)
RESULT test_I4_swe_pod_skill pass (all 6 checks pass)
RESULT test_I5_templates_placeholders_only pass (all 9 checks pass)
RESULT test_R16_S1_dispatch_line_names_no_machine pass (all 4 checks pass)
RESULT test_R5_S1_not_selected_green pass (all 4 checks pass)
RESULT test_R5_S2_superseded_with_replacement pass (all 4 checks pass)
RESULT test_I1_process_md pass (all 8 checks pass)
RESULT test_I3_d3_templates pass (all 14 checks pass)
```

The first six are build-swe-pod's tests: I2, I4, I5 and R16.S1 pass, and I1
and I3 fail only on I1.2 and I3.14 (in each run's `check.out` every other
check passes). The last four are this change's: T2's R5.S1 and R5.S2, and
T3's I1 and I3 at `@2`, all pass. I did not run T2's R5.S3 and R5.S4, which
are agent class. Their fixtures have a one-wave plan whose whole-change
review comes after verify (`after: [T3]`), which the new §1.3 reads exactly
as before, and their checks read only the latest-evidence lines and the
states. I see no fix here that would make either fail. There is no
disputed test.

### Concerns from fix round 1
- templates/records/review.md (Minor 7) is outside T1's touches, so I left
  it unchanged. The reviewer's role file now carries the R6 line. Adding it
  to the template needs the file map to grow, or a ruling to park it.
- G3 changed its title and scope in INSTALL.md (Minor 13). The operator's
  overlay, which is out of scope, still quotes the old title ("a verify
  after the go counts as operator-posted"). SPEC.md:1105 keeps the old G3
  wording, with no note, since open call 18 does not name it. The operator
  may want to align the overlay.
- This change's `plan.md` §9 uses `already in tests/` as a Keep value
  (Minor 8). That is for the lead to fix in the plan, if wanted.
- The R13.S2 check now needs two more variables, `SPACE` and `SREV`. The
  verify agent sets them to the space checkout and the space sha of the
  commit set. Any sha from 6982fb5 to the current space head gives the same
  `tests/build-swe-pod/` tree.

### R13.S2 done-when check (rewritten in fix round 1)

The check now applies the rule to the suite, as the review asked. It reads the cost-class rule from swe-pod's `PROCESS.md` at `$REV`: a `class:` value, the `inspect` or `script` mode, a mode that begins `agent` or `desk`, and one that begins `live`. It applies that rule to the front matter of every `test_*.md` directly in the space's `tests/build-swe-pod/` at `$SREV`. It fails on any test that maps to no class, declares neither `class:` nor `mode:`, or lacks `expected_s:` or `deliverables:`. A mapping the text at `$REV` does not state is not applied. The nine rule-text lines of the first version stay.

- command (run with `SWE` a swe-pod checkout, `REV` a swe-pod sha, `SPACE` a Project Space checkout and `SREV` a space sha; I used `SREV=6f1e4e0`, the brief's space commit, whose `tests/build-swe-pod/` tree is the same object at 6982fb5 and at the space head):

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md class-key $'A test\'s cost class is its front-matter `class:` value when it has one.'; h agents/swe-test.md class-key $'A test\'s cost class is its front-matter `class:` value when it has one.'; h skills/swe-pod/SKILL.md class-key $'A test\'s cost class is its front-matter `class:` value when it has one.'; h PROCESS.md from-mode '`inspect` or `script` is script class; a mode that begins `agent` or `desk` is agent class; a mode that begins `live` is live class'; h agents/swe-test.md from-mode '`inspect` or `script` is script class; a mode that begins `agent` or `desk` is agent class; a mode that begins `live` is live class'; h skills/swe-pod/SKILL.md from-mode '`inspect` or `script` is script class; a mode that begins `agent` or `desk` is agent class; a mode that begins `live` is live class'; h PROCESS.md undeclared 'A test with neither is live class, and the evidence names it under `## Undeclared cost class`.'; h agents/swe-test.md undeclared 'A test with neither is live class, and the evidence names it under `## Undeclared cost class`.'; h templates/records/evidence.md undeclared-section '## Undeclared cost class'; P=$(git -C "$SWE" show "$REV:PROCESS.md" 2>/dev/null | tr '\n' ' ' | tr -s ' '); ms=0; ma=0; ml=0; ck=0; case "$P" in *'`inspect` or `script` is script class'*) ms=1;; esac; case "$P" in *'a mode that begins `agent` or `desk` is agent class'*) ma=1;; esac; case "$P" in *'a mode that begins `live` is live class'*) ml=1;; esac; case "$P" in *'is its front-matter `class:` value when it has one'*) ck=1;; esac; [ "$ck$ms$ma$ml" = 1111 ] && echo "ok rule-at-REV maps class: and every mode prefix" || echo "MISSING rule-at-REV class-key $ck, inspect-or-script $ms, agent-or-desk $ma, live $ml"; for f in $(git -C "$SPACE" ls-tree --name-only "$SREV" tests/build-swe-pod/ | grep -E '^tests/build-swe-pod/test_[^/]*[.]md$'); do echo "@@FILE $f"; git -C "$SPACE" show "$SREV:$f" | awk 'NR==1 && /^---$/ {fm=1; next} fm && /^---$/ {exit} fm {print}'; done | awk -v ms=$ms -v ma=$ma -v ml=$ml -v ck=$ck 'function flush() { if (f == "") return; n++; c = "none"; if (cls != "" && ck) { if (cls ~ /^(script|agent|live)$/) c = cls } else if (mode != "") { if ((mode == "inspect" || mode == "script") && ms) c = "script"; else if (mode ~ /^(agent|desk)/ && ma) c = "agent"; else if (mode ~ /^live/ && ml) c = "live" } else if (cls == "") c = "undeclared"; k[c]++; if (!es) ne++; if (!dl) nd++; if (c == "none" || c == "undeclared" || !es || !dl) { bad++; if (bad <= 3) print "BAD " f " class " c (es ? "" : ", no expected_s") (dl ? "" : ", no deliverables") } } /^@@FILE / {flush(); f = $2; cls = ""; mode = ""; es = 0; dl = 0; next} /^class:/ {sub(/^class:[ ]*/, ""); cls = $0} /^mode:/ {sub(/^mode:[ ]*/, ""); mode = $0} /^expected_s:/ {es = 1} /^deliverables:/ {dl = 1} END {flush(); s = sprintf("suite %d tests: script %d, agent %d, live %d, no class %d, undeclared %d, no expected_s %d, no deliverables %d", n, k["script"], k["agent"], k["live"], k["none"], k["undeclared"], ne, nd); print ((n > 0 && bad == 0) ? "ok " : "FAIL ") s}'
```

- expected output: every line begins `ok`, and the last line is `ok suite 90 tests: script 16, agent 74, live 0, no class 0, undeclared 0, no expected_s 0, no deliverables 0`. At b7fc257 the rule text is absent, so no test maps to a class.
- red at b7fc257 (0 of 14 lines ok):

```text
MISSING PROCESS.md class-key
MISSING agents/swe-test.md class-key
MISSING skills/swe-pod/SKILL.md class-key
MISSING PROCESS.md from-mode
MISSING agents/swe-test.md from-mode
MISSING skills/swe-pod/SKILL.md from-mode
MISSING PROCESS.md undeclared
MISSING agents/swe-test.md undeclared
MISSING templates/records/evidence.md undeclared-section
MISSING rule-at-REV class-key 0, inspect-or-script 0, agent-or-desk 0, live 0
BAD tests/build-swe-pod/test_I1_process_md.md class none
BAD tests/build-swe-pod/test_I2_role_definitions.md class none
BAD tests/build-swe-pod/test_I3_d3_templates.md class none
FAIL suite 90 tests: script 0, agent 0, live 0, no class 90, undeclared 0, no expected_s 0, no deliverables 0
```

- at 0debc5a, the first head (11 of 11 lines ok):

```text
ok PROCESS.md class-key
ok agents/swe-test.md class-key
ok skills/swe-pod/SKILL.md class-key
ok PROCESS.md from-mode
ok agents/swe-test.md from-mode
ok skills/swe-pod/SKILL.md from-mode
ok PROCESS.md undeclared
ok agents/swe-test.md undeclared
ok templates/records/evidence.md undeclared-section
ok rule-at-REV maps class: and every mode prefix
ok suite 90 tests: script 16, agent 74, live 0, no class 0, undeclared 0, no expected_s 0, no deliverables 0
```

- green at 3b22a1b (11 of 11 lines ok):

```text
ok PROCESS.md class-key
ok agents/swe-test.md class-key
ok skills/swe-pod/SKILL.md class-key
ok PROCESS.md from-mode
ok agents/swe-test.md from-mode
ok skills/swe-pod/SKILL.md from-mode
ok PROCESS.md undeclared
ok agents/swe-test.md undeclared
ok templates/records/evidence.md undeclared-section
ok rule-at-REV maps class: and every mode prefix
ok suite 90 tests: script 16, agent 74, live 0, no class 0, undeclared 0, no expected_s 0, no deliverables 0
```

- the mapping on synthetic front matter (a sanity check of the awk program alone, all four mapping flags on). Input: a test with `mode: manual`, one with `class: weird`, one with neither, one with no `expected_s`, and one with no `deliverables`, beside clean tests. Output:

```text
BAD b.md class none
BAD c.md class none
BAD d.md class undeclared
FAIL suite 6 tests: script 1, agent 1, live 1, no class 2, undeclared 1, no expected_s 1, no deliverables 1
```

### R1.S2 done-when check (two lines added in fix round 1)

Two lines are added for the at-risk criterion the review asked for (PROCESS.md:328): the sentence naming cases that are at risk, in `PROCESS.md` and `agents/swe-plan.md`. The first nine lines are unchanged.

- command:

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md marks-reason 'marks each requirement `at risk` or `small`, with its reason'; h agents/swe-plan.md marks-reason 'marks each requirement `at risk` or `small`, with its reason'; h templates/records/plan.md risk-row '| R<n> | <at risk|small> | <the reason> |'; h templates/records/plan.md task-risk '- risk: <at risk|small>: <reason>'; h PROCESS.md part-of-risk 'A test planned for a requirement at risk names the part of that risk it covers.'; h agents/swe-plan.md part-of-risk 'A test planned for a requirement at risk names the part of that risk it covers.'; h PROCESS.md selfreview-fails 'The self-review fails on any planned test that names no risk.'; h agents/swe-plan.md selfreview-fails 'The self-review fails on any planned test that names no risk.'; h templates/records/plan.md selfreview-item '- [ ] every planned test names the risk it covers'; h PROCESS.md at-risk-cases 'such as a fix for a reported defect seen only in a live session, or a rule that decides whether a change is verified'; h agents/swe-plan.md at-risk-cases 'such as a fix for a reported defect seen only in a live session, or a rule that decides whether a change is verified'
```

- expected output: every line begins `ok`.
- red at b7fc257 (0 of 11 lines ok):

```text
MISSING PROCESS.md marks-reason
MISSING agents/swe-plan.md marks-reason
MISSING templates/records/plan.md risk-row
MISSING templates/records/plan.md task-risk
MISSING PROCESS.md part-of-risk
MISSING agents/swe-plan.md part-of-risk
MISSING PROCESS.md selfreview-fails
MISSING agents/swe-plan.md selfreview-fails
MISSING templates/records/plan.md selfreview-item
MISSING PROCESS.md at-risk-cases
MISSING agents/swe-plan.md at-risk-cases
```

- at 0debc5a (9 of 11 lines ok):

```text
ok PROCESS.md marks-reason
ok agents/swe-plan.md marks-reason
ok templates/records/plan.md risk-row
ok templates/records/plan.md task-risk
ok PROCESS.md part-of-risk
ok agents/swe-plan.md part-of-risk
ok PROCESS.md selfreview-fails
ok agents/swe-plan.md selfreview-fails
ok templates/records/plan.md selfreview-item
MISSING PROCESS.md at-risk-cases
MISSING agents/swe-plan.md at-risk-cases
```

- green at 3b22a1b (11 of 11 lines ok):

```text
ok PROCESS.md marks-reason
ok agents/swe-plan.md marks-reason
ok templates/records/plan.md risk-row
ok templates/records/plan.md task-risk
ok PROCESS.md part-of-risk
ok agents/swe-plan.md part-of-risk
ok PROCESS.md selfreview-fails
ok agents/swe-plan.md selfreview-fails
ok templates/records/plan.md selfreview-item
ok PROCESS.md at-risk-cases
ok agents/swe-plan.md at-risk-cases
```


### All 26 checks at the new head

The other 24 checks are unchanged. The counts below come from one run of every check at each sha. Every line at 3b22a1b is `ok`, and the R15.S1 check prints `lines-allowing-another-model 0` there (4 at b7fc257).

| Check | b7fc257 | 0debc5a | 3b22a1b |
|---|---|---|---|
| R1.S1 | 0 of 7 lines ok | 7 of 7 lines ok | 7 of 7 lines ok |
| R1.S2 | 0 of 11 lines ok | 9 of 11 lines ok | 11 of 11 lines ok |
| R2.S1 | 0 of 7 lines ok | 7 of 7 lines ok | 7 of 7 lines ok |
| R3.S1 | 0 of 10 lines ok | 10 of 10 lines ok | 10 of 10 lines ok |
| R3.S2 | 0 of 10 lines ok | 10 of 10 lines ok | 10 of 10 lines ok |
| R4.S1 | 0 of 12 lines ok | 12 of 12 lines ok | 12 of 12 lines ok |
| R4.S2 | 0 of 11 lines ok | 11 of 11 lines ok | 11 of 11 lines ok |
| R6.S1 | 0 of 9 lines ok | 9 of 9 lines ok | 9 of 9 lines ok |
| R6.S2 | 0 of 7 lines ok | 7 of 7 lines ok | 7 of 7 lines ok |
| R7.S1 | 0 of 4 lines ok | 4 of 4 lines ok | 4 of 4 lines ok |
| R7.S2 | 1 of 6 lines ok | 6 of 6 lines ok | 6 of 6 lines ok |
| R8.S1 | 0 of 5 lines ok | 5 of 5 lines ok | 5 of 5 lines ok |
| R8.S2 | 0 of 3 lines ok | 3 of 3 lines ok | 3 of 3 lines ok |
| R9.S1 | 0 of 6 lines ok | 6 of 6 lines ok | 6 of 6 lines ok |
| R9.S2 | 0 of 9 lines ok | 9 of 9 lines ok | 9 of 9 lines ok |
| R10.S1 | 0 of 8 lines ok | 8 of 8 lines ok | 8 of 8 lines ok |
| R10.S2 | 0 of 6 lines ok | 6 of 6 lines ok | 6 of 6 lines ok |
| R11.S1 | 0 of 7 lines ok | 7 of 7 lines ok | 7 of 7 lines ok |
| R11.S2 | 0 of 6 lines ok | 6 of 6 lines ok | 6 of 6 lines ok |
| R12.S1 | 0 of 11 lines ok | 11 of 11 lines ok | 11 of 11 lines ok |
| R12.S2 | 0 of 9 lines ok | 9 of 9 lines ok | 9 of 9 lines ok |
| R13.S1 | 0 of 6 lines ok | 6 of 6 lines ok | 6 of 6 lines ok |
| R13.S2 | 0 of 14 lines ok | 11 of 11 lines ok | 11 of 11 lines ok |
| R14.S1 | 0 of 10 lines ok | 10 of 10 lines ok | 10 of 10 lines ok |
| R14.S2 | 0 of 5 lines ok | 5 of 5 lines ok | 5 of 5 lines ok |
| R15.S1 | 6 of 17 lines ok | 16 of 17 lines ok | 16 of 17 lines ok |

### Evidence for Important 1 (PROCESS.md:723)

The regression-only sentence and the sharded rule, in the same words in every file that states them; the old sharded wording is gone.

- command:

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h PROCESS.md regression-only 'The two results that can be no bar are regression-test results: on a scenario of the spec, a unit suite, a quality check or a test in `changes/<id>/tests/`, either one is a bar.'; h agents/swe-lead.md regression-only 'The two results that can be no bar are regression-test results: on a scenario of the spec, a unit suite, a quality check or a test in `changes/<id>/tests/`, either one is a bar.'; h README.md regression-only 'The two results that can be no bar are regression-test results: on a scenario of the spec, a unit suite, a quality check or a test in `changes/<id>/tests/`, either one is a bar.'; h skills/swe-pod/SKILL.md regression-only 'The two results that can be no bar are regression-test results: on a scenario of the spec, a unit suite, a quality check or a test in `changes/<id>/tests/`, either one is a bar.'; h PROCESS.md sharded-together 'a pass for every scenario, unit suite, declared quality check and test of the change, and for every regression test a pass or a result that is no bar'; h agents/swe-lead.md sharded-together 'a pass for every scenario, unit suite, declared quality check and test of the change, and for every regression test a pass or a result that is no bar'; h README.md sharded-together 'a pass for every scenario, unit suite, declared quality check and test of the change, and for every regression test a pass or a result that is no bar'; h skills/swe-pod/SKILL.md sharded-together 'a pass for every scenario, unit suite, declared quality check and test of the change, and for every regression test a pass or a result that is no bar'; n PROCESS.md old-together 'together they give, for every scenario, regression test, unit suite and declared quality check, a pass or a result that is no bar'; n agents/swe-lead.md old-together 'together they give, for every scenario, regression test, unit suite and declared quality check, a pass or a result that is no bar'
```

- red at 0debc5a (1 of 10 lines ok):

```text
MISSING PROCESS.md regression-only
MISSING agents/swe-lead.md regression-only
MISSING README.md regression-only
ok skills/swe-pod/SKILL.md regression-only
MISSING PROCESS.md sharded-together
MISSING agents/swe-lead.md sharded-together
MISSING README.md sharded-together
MISSING skills/swe-pod/SKILL.md sharded-together
STILL PROCESS.md old-together
STILL agents/swe-lead.md old-together
```

- green at 3b22a1b (10 of 10 lines ok):

```text
ok PROCESS.md regression-only
ok agents/swe-lead.md regression-only
ok README.md regression-only
ok skills/swe-pod/SKILL.md regression-only
ok PROCESS.md sharded-together
ok agents/swe-lead.md sharded-together
ok README.md sharded-together
ok skills/swe-pod/SKILL.md sharded-together
ok PROCESS.md no-old-together
ok agents/swe-lead.md no-old-together
```


### Evidence for Important 2 and 3 (status-format.md:178, SKILL.md:114)

The skill's new reading of review tasks, readiness and done; the old wording is gone.

- command:

```sh
h(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "ok $1 $2" || echo "MISSING $1 $2"; }; n(){ git -C "$SWE" show "$REV:$1" 2>/dev/null | tr '\n' ' ' | tr -s ' ' | grep -q -F -- "$3" && echo "STILL $1 $2" || echo "ok $1 no-$2"; }; h skills/swe-pod/SKILL.md reviews-after '3. its `after:` list: every build task it names, one or more.'; h skills/swe-pod/SKILL.md wave-and-one-wave 'So a wave'"'"'s review, `### T<n> Review of wave <w>`, reviews every build task its `after:` list names, and so does the whole-change review, the one whose heading title is `Whole-change review`, in a plan whose build tasks form one wave'; h skills/swe-pod/SKILL.md go-ready 'for a review task that reviews build tasks (1.3), whose build tasks have all reported and every other task in its `after` list is done'; h skills/swe-pod/status-format.md ready 'A review task that reviews build tasks (`SKILL.md` section 1.3) is ready instead once each of them has reported and every other task in its `after` list is done'; h skills/swe-pod/status-format.md ready-cases 'So a wave'"'"'s review is ready once its build tasks report, and so is the whole-change review of a plan whose build tasks form one wave.'; h skills/swe-pod/status-format.md done 'A review task that reviews build tasks (`SKILL.md` section 1.3): the review of each of them is closed.'; h PROCESS.md after-names 'its `after:` list names them, and it comes before verify'; n skills/swe-pod/SKILL.md old-whole-change 'The whole-change review, the one whose heading title is `Whole-change review`, reviews no single task.'; n skills/swe-pod/status-format.md old-ready 'A review task that reviews one task is ready instead once that task has reported'
```

- red at 0debc5a (0 of 9 lines ok):

```text
MISSING skills/swe-pod/SKILL.md reviews-after
MISSING skills/swe-pod/SKILL.md wave-and-one-wave
MISSING skills/swe-pod/SKILL.md go-ready
MISSING skills/swe-pod/status-format.md ready
MISSING skills/swe-pod/status-format.md ready-cases
MISSING skills/swe-pod/status-format.md done
MISSING PROCESS.md after-names
STILL skills/swe-pod/SKILL.md old-whole-change
STILL skills/swe-pod/status-format.md old-ready
```

- green at 3b22a1b (9 of 9 lines ok):

```text
ok skills/swe-pod/SKILL.md reviews-after
ok skills/swe-pod/SKILL.md wave-and-one-wave
ok skills/swe-pod/SKILL.md go-ready
ok skills/swe-pod/status-format.md ready
ok skills/swe-pod/status-format.md ready-cases
ok skills/swe-pod/status-format.md done
ok PROCESS.md after-names
ok skills/swe-pod/SKILL.md no-old-whole-change
ok skills/swe-pod/status-format.md no-old-ready
```

