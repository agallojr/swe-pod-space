# T7 report: swe-pod skill (D4)

- change: build-swe-pod
- task: T7
- actor: agallojr/build

## Status

DONE_WITH_CONCERNS

## What I did

**Fix round 1/5, on the three Important findings of T7-review.md.** I wrote
one check per finding first and watched all three fail, then made the
three fixes in one commit, `5aacf3f`:

- **Review task to the task it reviews** (SKILL.md 1.3). The whole-change
  review is the one whose heading title is `Whole-change review`, and it
  reviews no single task. Any other review task reviews the task in the
  first of these it has: its review-table Reviews cell, the `T<m>` of a
  `### T<n> Review of T<m>` heading, or its single `after:` entry. The
  heading rule now counts only the ids a heading opens with, so
  `### T21 Review of T1` is the task T21 and not a two-id heading.
  status-format.md's done and latest rules say "reviews no single task" to
  match.
- **A ruling closes findings at any round** (status-format.md, "Open
  findings", and a new ledger bullet in SKILL.md 1.4). A `Ruling:` line
  newer than the task's newest review or fix-round line, and beginning
  `Ruling: T<n> open findings`, closes T<n>'s Critical and Important
  findings, whole-change review included. That is the ledger's `Ruling:`
  form with its `<what>` starting with the task id. A ruling in any other
  form closes nothing. The old "after the fifth fix round" limit is gone.
- **Green needs every result** (SKILL.md 1.6). It now needs a pass for
  every `test_*.md` in `changes/<id>/tests/`, under the key trace step 4
  maps it to. It also needs a pass for every regression test, meaning each
  test-map row of an archived change whose file is under `tests/`, under
  `<change>/<Rn.Sm>`. I removed "at least one" and "when present". The
  latest-evidence bullet in status-format.md now counts `x-checks` and
  `x-suggestions` over those files and adds `regression <p>/<n> pass`, so
  the record's results show why it is not green.

Round 0's account, below, still holds apart from these three rules.

Wrote the `swe-pod` skill as two files in swe-pod, `skills/swe-pod/SKILL.md`
and `skills/swe-pod/status-format.md`, to plan §2.6 and the T7 steps. I
wrote the done-when checks first and watched them fail.

- **SKILL.md.** Front-matter `name: swe-pod`. The description says when to
  invoke the skill (status, go or the next thing, regenerating STATUS.md, a
  traceability check) and sets no standing rule. Section 1 reads the records
  in the T7 order (`AGENTS.md`, `STATUS.md`, `pod.yaml`, then each change's
  spec, plan and ledger), as committed at the space's HEAD, with code repos
  read-only. It covers:
  - the change state from the spec §5 table, where verified needs the latest
    evidence to pass every scenario, unit suite and declared check;
  - plan tasks, ledger events, the current commit set and green evidence.

  Section 2 says where things stand. Section 3 regenerates STATUS.md and
  files it through the librarian, adding no ledger line. Section 4 handles
  go: the fixed approval phrase, then acting as swe-lead from the first
  ready task. Section 5 is the trace, from `serves` and the test map,
  through the `Change:`/`Task:` trailers on `change/<id>` (fetch and log,
  read-only), to the latest evidence. It holds the TRACE line and all five
  BREAK forms, exactly.
- **status-format.md.** The exact §2.6 layout and the rule for every field:
  - the header, the gates, the branches and the task table
    (`| task | role | runs | state | latest |`);
  - the five task states (waiting, ready, dispatched, done, blocked);
  - the latest cell, open findings, `next:` and the latest evidence;
  - the ordering and empty-case rules, so the same records give the same
    bytes.

  It ends with a fictional example.
- **Regeneration (done-when 4).** I regenerated this space's STATUS.md
  twice by following the skill, at space commit `03d8c12` and with the same
  branch heads, and did not file either output:
  - run 1 by hand, reading the records with the skill's commands;
  - run 2 with a scratch procedure outside every repo that applies the
    skill's rules as written, line by line. It is not shipped.

  The first attempt at run 2 found a gap in the text: the spec quotes an
  example spec, inside a fence, with its own `approved:` line. The rules
  then did not say to read header fields from the header only, so that
  example leaked into "As of" and the gates. I fixed SKILL.md §1.2 and
  status-format.md, and ran both runs again. The two outputs are identical.

## Files

- swe-pod/skills/swe-pod/SKILL.md: created. The skill: reading the records,
  where things stand, regenerating STATUS.md, go, and the trace. Changed
  in fix round 1: sections 1.3, 1.4 and 1.6.
- swe-pod/skills/swe-pod/status-format.md: created. The STATUS.md format,
  field rules, task states, findings and determinism rules. Changed in fix
  round 1: the latest-evidence bullet, task states item 1, "Latest" and
  "Open findings".
- Commit range: swe-pod 74d23f1..32db546 (one commit, `32db546`, trailers
  `Change: build-swe-pod` and `Task: T7`), pushed to `change/build-swe-pod`.
- Fix round 1 range: swe-pod 32db546..5aacf3f (one commit, `5aacf3f`, the
  same two files, 44 insertions and 21 deletions, trailers
  `Change: build-swe-pod` and `Task: T7`), pushed to `change/build-swe-pod`.

## Test output

### Fix round 1: one check per finding (run on the swe-pod build checkout)

- command: `check_t7_fix1.py <swe-pod checkout>`, a scratch check outside
  every repo. Each check reads only its own section:
  - F1 (SKILL.md 1.3): the "names one task id" heading rule is gone; the
    heading rule says `### T21 Review of T1` is T21; the rule names the
    `### T<n> Review of T<m>` form, a single `after:` entry and the
    `Whole-change review` heading.
  - F2 ("Open findings", SKILL.md 1.4): "fifth fix round" is gone; the
    `Ruling: T<n> open findings` form and "at any round" are present, and
    1.4 reads that line.
  - F3 (SKILL.md 1.6): "at least one" and "when present" are gone; 1.6
    covers `changes/<id>/tests/` by step 4, regression tests through
    `changes/archive/` test maps as `<change>/<Rn.Sm>`, and gives a
    `test_I1` example.
- red, at swe-pod 32db546:

  ```
  F1 review task linked by heading or after fail: 1.3 still says a heading 'names one task id'; 1.3 heading rule does not count ids in the title; 1.3 names the template form `### T<n> Review of T<m>`; 1.3 takes a single `after:` entry; 1.3 names the whole-change review by its heading
  F2 a ruling closes findings at any round fail: status-format still limits rulings to after round 5; status-format gives the ruling form; status-format says at any round; SKILL.md 1.4 reads the ruling line
  F3 green needs a pass for every test file fail: 1.6 still accepts 'at least one' regression result; 1.6 still checks x- keys only when present; 1.6 covers every test file in changes/<id>/tests/ by step 4; 1.6 covers regression tests through archived test maps; 1.6 example: no x-checks while test_I1 files exist
  exit 1
  ```

- first green attempt: F2 and F3 passed. F1 failed only on "1.3 takes a
  single `after:` entry": the check wanted the literal words "`after:`
  list names one task", and the text reads "its `after:` list, when that
  list names one task". I widened the check to allow words in between. The
  text did not change.
- green, on the working tree that became 5aacf3f:

  ```
  F1 review task linked by heading or after pass
  F2 a ruling closes findings at any round pass
  F3 green needs a pass for every test file pass
  exit 0
  ```

### Fix round 1: behavior on two fixture spaces

- `make_fx1.py` writes two fictional spaces outside every repo. Both have
  one change, `demo`, with a plan in the template's form: T1 build, T2
  tests, T3 verify, `### T4 Review of T1` with `after: [T1]`,
  `### T5 Whole-change review`, and T6 integrate after `[T3, T5]`. There is
  no review table. The ledger closes T1's review. T5's re-review leaves 1
  Important, then comes
  `Ruling: T5 open findings parked: ...; ...; cost if wrong: ...`.
  `changes/demo/tests/` holds `test_R1_S1_hello.md` and
  `test_I1_layout.md`. An archived change's test map names two tests that
  are in `tests/`.
  - fx1a's evidence passes R1.S1 and one of the two regression results,
    and has no `x-checks:`.
  - fx1b's evidence passes everything.
- `run2_fix1.py` is the round-0 run-2 procedure with the three fixed rules
  and the 1.6 green rule added. `--old` switches the fixed rules back to
  the old ones. It reads fixtures from disk, so it does not judge
  staleness.
- red, the old rules (`--old`):

  ```
  == fx1a --old
  | T4 | review | local | ready | - |
  | T5 | review | local | dispatched | 2026-11-02T17:00Z review r1: spec ok; 1 Important |
  | T6 | lead | local | waiting | - |
  - latest evidence: ev-20261102T1545Z, macos-laptop, green: scenarios 1/1 pass, unit greeter pass, quality none-declared
  - open findings: Critical 0, Important 1, Minor 0
  - next: T4 -> review (local, any)
  == fx1b --old
  ## demo   state: building   owner: ana
  | T5 | review | local | dispatched | 2026-11-02T17:00Z review r1: spec ok; 1 Important |
  - open findings: Critical 0, Important 1, Minor 0
  - next: T4 -> review (local, any)
  ```

  These are the three failures the findings describe. T4's review is
  already filed, yet T4 is `next:`. The ruled finding stays open, so T6
  never becomes ready. fx1a's evidence reads green with an inspection
  result and a regression result missing.
- green, the fixed rules:

  ```
  == fx1a new
  ## demo   state: building   owner: ana
  | T4 | review | local | done | 2026-11-02T15:10Z review r1: spec ok; none |
  | T5 | review | local | done | 2026-11-02T17:00Z review r1: spec ok; 1 Important |
  | T6 | lead | local | ready | - |
  - latest evidence: ev-20261102T1545Z, macos-laptop, not green: scenarios 1/1 pass, regression 1/2 pass, unit greeter pass, quality none-declared, x-checks 0/1 pass
  - open findings: Critical 0, Important 0, Minor 0
  - next: T6 -> lead (local, any)
  == fx1b new
  ## demo   state: verified   owner: ana
  - latest evidence: ev-20261102T1545Z, macos-laptop, green: scenarios 1/1 pass, regression 2/2 pass, unit greeter pass, quality none-declared, x-checks 1/1 pass
  - open findings: Critical 0, Important 0, Minor 0
  - next: T6 -> lead (local, any)
  ```

### Fix round 1: done-when 1 to 3, and I4, run again

- `check_t7.py`, on the working tree that became 5aacf3f:

  ```
  check 1 pass: name swe-pod, description says when and sets no standing rule
  check 2 pass: exact 2.6 lines in status-format.md, 5/5 present
  check 3 pass: TRACE and five BREAK forms in SKILL.md, 6/6 present
  exit 0
  ```

- I4's embedded check, byte-identical to the block in
  `changes/build-swe-pod/tests/test_I4_swe_pod_skill.md` at space
  `489729b`, run unchanged on the same tree:

  ```
  I4.1 pass swe-pod ?: SKILL.md and status-format.md present
  I4.2 pass front-matter name, and a description that says when and sets no standing rule
  I4.3 pass exact STATUS.md lines: all present
  I4.4 pass per-change bullets and task table
  I4.5 pass task states named
  I4.6 pass trace forms: all present
  exit 0
  ```

### Fix round 1: done-when 4, this space's STATUS.md

- The three fixed rules do not change this space's text:
  - its plan has no `Review of` heading;
  - its only review task outside the review table is T35, the
    whole-change review;
  - its ledger has no `Ruling: T<n> open findings` line;
  - it has no `ev-` evidence record.
- At space `03d8c12`, the inputs of round 0, the old and the fixed
  procedure give byte-identical output: `diff` prints nothing. Against
  round 0's committed pair, only the branches line differs, because both
  heads have moved since:

  ```
  < - branches: change/build-swe-pod: swe-pod 74d23f1, agent-mesh 859679a
  > - branches: change/build-swe-pod: swe-pod 32db546, agent-mesh c6aa593
  ```

- At space `489729b`, today's `main`, I ran the fixed procedure twice. The
  outputs are identical:

  ```
  74c17689cda4fffef369044cffa978496c5537d9996548b24a40449fad6d5471  run 1
  74c17689cda4fffef369044cffa978496c5537d9996548b24a40449fad6d5471  run 2
  ```

  Against the old procedure, only the evidence line differs. The old
  procedure printed a placeholder whenever `evidence/` held any file. The
  fixed one reads only `ev-` records, and the one file there,
  `evidence/20261028T0053Z-T39-report.md`, is a test-task report, so it
  gives `latest evidence: none`.
- Not filed: the committed STATUS.md is unchanged.

### Fix round 1: standard close

- shareability, after staging and again after committing (last line of
  each):

  ```
  shareability: 0 hits
  shareability: 0 hits
  ```

- `git diff 74d23f1 -- SPEC.md spec-process.*`: empty, 0 lines. 74d23f1 is
  still the latest `Task: T0` commit.
- commit, by pathspec: `[change/build-swe-pod 5aacf3f] Fix review links
  rulings and green rule in the swe-pod skill`, 2 files changed, 44
  insertions(+), 21 deletions(-).
- step 7: `git merge-base --is-ancestor origin/change/build-swe-pod HEAD`
  exited 0, since the remote head `32db546` is already in the branch, so I
  did not rebase. Push:
  `32db546..5aacf3f  change/build-swe-pod -> change/build-swe-pod`.
  `git ls-remote` shows the remote head at `5aacf3f`.
- unit suite: swe-pod has no unit suite, so none was run (unit 0/0).
- review: the T27 review of this fix diff is pending.

### Round 0: done-when 1 to 3 (check script, run on the swe-pod build checkout)

- command: `check_t7.py <swe-pod checkout>`. It checks (1) the front-matter
  name and a description that says when, with no `always`, `must`, `never`,
  `whenever`, `every session`, `every turn` or `from now on`; (2) the five
  exact §2.6 lines as whole lines of status-format.md; (3) the TRACE line
  and five BREAK forms as whole lines of SKILL.md.
- red:

  ```
  check 1 fail: name swe-pod, description says when and sets no standing rule (SKILL.md absent)
  check 2 fail: exact 2.6 lines in status-format.md, 0/5 present (status-format.md absent)
  check 3 fail: TRACE and five BREAK forms in SKILL.md, 0/6 present
  exit 1
  ```

- green (after the last edit, before staging):

  ```
  check 1 pass: name swe-pod, description says when and sets no standing rule
  check 2 pass: exact 2.6 lines in status-format.md, 5/5 present
  check 3 pass: TRACE and five BREAK forms in SKILL.md, 6/6 present
  exit 0
  ```

### Round 0: I4, as an extra check (its embedded check, run unchanged on the checkout)

- red, at swe-pod 74d23f1:

  ```
  I4.1 fail swe-pod 74d23f1: absent: skills/swe-pod/SKILL.md, skills/swe-pod/status-format.md
  I4.2 fail front-matter name, and a description that says when and sets no standing rule
  I4.3 fail exact STATUS.md lines: missing line(s) 1, 2, 3, 4, 5
  I4.4 fail per-change bullets and task table
  I4.5 fail task states named
  I4.6 fail trace forms: 6 missing
  exit 1
  ```

- green, on the working tree that became 32db546:

  ```
  I4.1 pass swe-pod working-tree: SKILL.md and status-format.md present
  I4.2 pass front-matter name, and a description that says when and sets no standing rule
  I4.3 pass exact STATUS.md lines: all present
  I4.4 pass per-change bullets and task table
  I4.5 pass task states named
  I4.6 pass trace forms: all present
  exit 0
  ```

### Round 0: done-when 4, STATUS.md regenerated twice, identical, not filed

- inputs: space `main` at `03d8c12` (records read with `git show
  03d8c12:<path>`); branch heads read with `git ls-remote` at
  2026-10-28T00:45Z, swe-pod `74d23f1`, agent-mesh `859679a`.
- red: before the skill existed, there was nothing to follow; the committed
  STATUS.md (from 2026-10-27T21:42Z) is in the old form, not §2.6. The
  first attempt at the pair differed in two lines:
  - the "As of" time and the gates took a spec `approved:` line from the
    example inside a fence. That was a gap in the rules, now fixed.
  - agent-mesh's head moved from `97b35a2` to `859679a` between the runs.
    That was a real input change.
- green: `diff run1 run2` prints nothing, so the outputs are identical.

  ```
  528ce464eb1218d060f011172e4979e1162d5a918d7b302a464711500cd5d6bb  run1-STATUS.md
  528ce464eb1218d060f011172e4979e1162d5a918d7b302a464711500cd5d6bb  run2-STATUS.md
  ```

- a format check of the output against the §2.6 line forms printed
  `format check pass (59 lines, 40 task rows)`.
- not filed: the committed STATUS.md is unchanged. Per plan §4.1, it is
  first regenerated when T27 closes.

The output, both runs:

```markdown
# Status: proj:swe-pod

Generated from the records; never edited by hand. As of 2026-10-28T00:31Z.

- pins: swe-pod 8fc5294, agent-mesh 8ee5364
- open changes: 1 (building: 1)

## build-swe-pod   state: building   owner: agallojr

- gates: spec agallojr 2026-10-27T21:36Z, spec agallojr 2026-10-28T00:31Z, go 2026-10-27T22:58Z
- branches: change/build-swe-pod: swe-pod 74d23f1, agent-mesh 859679a
- tasks: waiting 15, ready 1, dispatched 10, done 14, blocked 0

| task | role | runs | state | latest |
|---|---|---|---|---|
| T0 | lead | local | done | 2026-10-27T22:58Z DONE |
| T1 | build | local | done | 2026-10-27T23:52Z fix round 1/5: 1 addressed, 0 open |
| T2 | build | local | dispatched | 2026-10-28T00:20Z dispatch -> build (local, any) |
| T3 | build | local | dispatched | 2026-10-28T00:20Z dispatch -> build (local, any) |
| T4 | build | local | done | 2026-10-27T23:52Z DONE_WITH_CONCERNS, swe-pod 854e87c..ea98774 |
| T5 | build | local | done | 2026-10-27T23:52Z fix round 1/5: 1 addressed, 0 open |
| T6 | build | local | done | 2026-10-27T23:52Z fix round 1/5: 1 addressed, 0 open |
| T7 | build | local | dispatched | 2026-10-28T00:20Z dispatch -> build (local, any) |
| T8 | build | local | dispatched | 2026-10-28T00:20Z dispatch -> build (local, any) |
| T9 | build | local | dispatched | 2026-10-28T00:20Z dispatch -> build (local, any) |
| T10 | build | local | done | 2026-10-27T23:52Z fix round 1/5: 1 addressed, 0 open |
| T11 | build | local | done | 2026-10-27T23:52Z DONE, agent-mesh 8ee5364..e70dfc2 |
| T12 | build | local | dispatched | 2026-10-28T00:20Z dispatch -> build (local, any) |
| T13 | build | local | dispatched | 2026-10-28T00:20Z dispatch -> build (local, any) |
| T14 | build | local | dispatched | 2026-10-28T00:20Z dispatch -> build (local, any) |
| T15 | test | local | done | 2026-10-28T00:05Z at base: 8 fail, 0 pass |
| T16 | test | local | dispatched | 2026-10-28T00:05Z dispatch -> test (local, any) |
| T17 | test | local | dispatched | 2026-10-28T00:05Z dispatch -> test (local, any) |
| T18 | test | local | waiting | - |
| T19a | test | local | waiting | - |
| T19b | test | mesh | waiting | - |
| T21 | review | local | done | 2026-10-27T23:52Z review r1: spec ok; 1 Minor |
| T22 | review | local | waiting | - |
| T23 | review | local | waiting | - |
| T24 | review | local | done | 2026-10-27T23:52Z review: spec ok; 6 Minor |
| T25 | review | local | done | 2026-10-27T23:52Z review r1: spec ok; 1 Minor |
| T26 | review | local | done | 2026-10-27T23:52Z review r1: spec ok; 2 Minor |
| T27 | review | local | waiting | - |
| T28 | review | local | waiting | - |
| T29 | review | local | waiting | - |
| T30 | review | local | done | 2026-10-27T23:52Z review r1: spec ok; 1 Minor |
| T31 | review | local | done | 2026-10-27T23:52Z review: spec ok; 5 Minor |
| T32 | review | local | waiting | - |
| T33 | review | local | waiting | - |
| T34 | review | local | waiting | - |
| T35 | review | local | waiting | - |
| T36 | lead | local | waiting | - |
| T37 | build | local | waiting | - |
| T38 | review | local | waiting | - |
| T39 | test | local | ready | - |

- latest evidence: none
- open findings: Critical 0, Important 0, Minor 35
- next: T39 -> test (local, any)
```

### Round 0: trace, by the skill's section 5, at the same inputs (not a done-when)

```
TRACE build-swe-pod: 0 breaks
```

- Requirements: 24, each served by a build task (R24 by T37).
- Scenarios: 37, each with a test-map row. No task in a "Writes it" cell is
  done yet, so no test file is due.
- Reported build tasks T1, T4, T5, T6, T10 and T11: each has commits with
  both trailers on its branch.
- There is no evidence yet.

### Round 0: standard close

- shareability, after staging and again after committing (last line of
  each):

  ```
  shareability: 0 hits
  shareability: 0 hits
  ```

- `git diff 74d23f1 -- SPEC.md spec-process.*`, against the latest
  `Task: T0` commit: empty, 0 lines.
- commit, by pathspec: `[change/build-swe-pod 32db546] Add the swe-pod skill
  and its STATUS.md format`, 2 files changed, 484 insertions.
- step 7: `git merge-base --is-ancestor origin/change/build-swe-pod HEAD`
  exit 0 (remote head `74d23f1` already in the branch), so no rebase. Push:
  `74d23f1..32db546  change/build-swe-pod -> change/build-swe-pod`. The
  remote head is now `32db546`.
- unit suite: swe-pod has no unit suite, so none was run (unit 0/0).
- review: T27 is pending.

## Concerns

- **This space's ledger predates the event forms.** Several of its lines
  match no form in `templates/records/ledger.md`:
  - the go line, `go. T0 (lead, local): ...`, names no handle;
  - T0's completion is recorded in words, as "T0 complete";
  - some dispatch lines name several tasks
    (`dispatch T7, T12, T13, T14, T8 -> ...`, `dispatch T2, T3, T9 again
    -> ...`).

  SKILL.md §1.4 reads each of these by an explicit rule. That is why the
  gates show `go 2026-10-27T22:58Z` with no handle. T27 should check that
  these rules are wanted, not just tolerated.
- **The status says what the ledger says, and here that lags the work.** At
  `03d8c12`:
  - T39 is ready, and so it is `next:`, because its brief is filed and no
    dispatch line is.
  - T2, T3 and T9 show dispatched because the ledger has no status lines
    for their second runs. T3 and T9 reports and reviews are filed, and
    T2's commit exists.

  Lines the lead adds will move these. The skill takes task states and
  findings from the ledger alone (§1.4), not from the files in `tasks/`.
- **Review tasks have no dispatch line** in the lead's definition. The
  skill treats a review task as dispatched once the task it reviews has
  reported, so it is never ready and never `next:` (status-format.md, task
  states, item 3). This is my reading of swe-lead "Checking and filing"
  step 2; it settles a case the brief leaves open.
- **R24 is not in T7.** The verified rule reads one latest evidence record,
  as the T7 steps say. Plan revision 4 gives sharded evidence to T37, which
  touches SKILL.md after T7.
- **Branch heads come from the remotes**, so a push between two
  regenerations changes the text, as happened once here. R20.S1 holds only
  while the inputs hold still. The determinism rules in status-format.md
  say so.
- **Minor findings are summed over every review round** and never close
  before integrate, which gives 35 here. If the lead wants minors that a
  fix round closed dropped from the count, the rule in "Open findings" is
  the one to change.
- **Fix round 1: the lead's definition does not name the ruling form
  yet.** The skill closes findings only on a `Ruling:` line that begins
  `Ruling: T<n> open findings`. agents/swe-lead.md says "rule on each open
  finding" and "you rule on what remains", but gives no form for that
  ruling. A lead that words the ruling another way leaves the findings
  open in STATUS.md, so the whole-change review does not read done. Route
  this one sentence to the lead's definition: T5's file, or T37, which
  touches it after T7. It is the same route as the review's Minor on
  filing STATUS.md.
- **Fix round 1: the whole-change review's "at its first green run" is a
  comment.** In both the plan template and this plan, that condition comes
  after the `after:` list's closing bracket, and 1.3 reads such text as a
  comment. So the review can read ready as soon as verify reports, even
  when the evidence is not green. In fixture fx1a, T6 integrate reads
  ready with evidence not green, because T3 has reported and T5 is done by
  its ruling. The change state stays `building`, and the lead's definition
  holds integrate until verify is green. I left this as it is because no
  finding names it; T27 may want it in the task-state rules.
- **Fix round 1: test-task reports under `evidence/`.** Under the A39
  ruling, test-task reports now go in `evidence/` as
  `<UTC>-<task id>-report.md`. The As of rule counts the UTC in their
  names, which is harmless, since the ledger has a line at the same time.
  The latest-evidence rule reads only `ev-` records, so it skips them.
  This is consistent, but T37's shard rules should keep it that way.

## Test suggestions

### T7.TS1 Several events of one task in the same minute

- for the tester: R20.S1 is at risk on a space whose ledger records a
  task's report, its review and a fix round, all with the same UTC minute.
  Regenerating STATUS.md twice, or against the committed copy, may disagree
  on that task's latest result or its state.
- for the reviewer: swe-pod/skills/swe-pod/status-format.md:141-159, where
  the latest event is chosen by UTC and then by the order written. Also
  SKILL.md:104-110. There is no unit suite; the regeneration pair in this
  report is the only check of this rule.

### T7.TS2 A spec that quotes an example spec

- for the tester: R12.S1 and R20.S1 are at risk on a space whose spec.md
  quotes, inside a fenced block, an example spec with its own `approved:`
  line, requirement and scenario headings, and a Quality section. The status
  may count the example's approvals, scenarios or quality checks as the
  change's own, and so give the wrong "As of" time, the wrong gates, or a
  wrong verified state.
- for the reviewer: swe-pod/skills/swe-pod/SKILL.md:60-71, the header-only
  and fence rules. The first attempt at the regeneration pair failed on
  exactly this.

### T7.TS3 A ledger written in words

- for the tester: R18.S1 is at risk on a space whose ledger has these
  lines:
  - one dispatch line naming several tasks;
  - a lead task's completion recorded in words, with no status line;
  - a build task that has reported, while its review has not.

  A fresh agent asked "where are we?" may name, as the next task, one that
  is already dispatched, done, or under review.
- for the reviewer: swe-pod/skills/swe-pod/SKILL.md:112-117 (multi-task
  dispatch and "T<n> complete") and
  swe-pod/skills/swe-pod/status-format.md:121-137 (the task-state order and
  review tasks with no dispatch line).

### T7.TS4 A plan in the template's form, with a ruled whole-change review

- for the tester: R18.S1, R20.S1 and R12.S1 are at risk on a space set up
  as follows:
  - its plan writes each review task as a heading "Review of" another
    task, with that task as its only `after` entry, and has no review
    table;
  - the lead ruled on the finding the whole-change re-review left open;
  - its latest evidence passes every scenario but has no result for one
    inspection test in the change's tests folder, nor for one regression
    test in the space's tests folder.

  A fresh agent asked "where are we?" may do any of these:
  - name as the next task a review that is already filed;
  - count the ruled finding as open, and hold back integrate;
  - call the change verified while a test still has no result.
- for the reviewer: swe-pod/skills/swe-pod/SKILL.md:73-100 (heading ids
  and the order that links a review task to its task),
  SKILL.md:124-127 and status-format.md:169-173 (the ruling form), and
  SKILL.md:154-177 (the green rule). There is no unit suite. The fixture
  runs in this report (fx1a, fx1b) are the only behavior check.
