# V1 report: verify fix round

- change: build-swe-pod
- task: T1, T2, T5, T7 (verify fixes)
- actor: agallojr/build

## Status

DONE_WITH_CONCERNS

## What I did

Fix round on the seven findings from verify at swe-pod 1cecea0 (shards
T19a and T19b). I checked each finding against the deliverable text and
found each one holds. I wrote one done-when check per finding (23 checks in
all) and watched them fail. Then I made the fixes and watched all 23 pass.
I committed one fix per owning task, by pathspec, ran the shareability check
for each task, and pushed `change/build-swe-pod`. No project-level test was
edited or run.

- **a (T7) Unreadable remote, R20.S1.** SKILL.md 1.1 has a new
  **Branch head** rule, applied in order:
  1. a readable remote that lists the branch gives the sha it lists;
  2. a readable remote with no such branch gives `<repo> missing`;
  3. a remote that cannot be read (`git ls-remote` exits non-zero) gives
     the end of the newest ledger range for that repo, in 1.4 event order.
     A range is a status line's `<repo> <sha7>..<sha7>`, or a fix-round
     line's `<sha7>..<sha7>` for a task whose plan entry has
     `repo: <repo>`. With no range it gives the repo's sha on the go line,
     and with neither, `<repo> missing`.

  status-format.md's branches bullet and its "Same records, same text"
  bullet use this rule. So does SKILL.md 1.5, so a stale check and the
  branches bullet always give the same head.
- **b (T7) Zero counts, T7.TS1.** In the review cell, every count of 0 is
  left out. When no count is left, or the line gives none, the cell is
  `none`, with the example `spec ok; 0 Important` giving
  `review: spec ok; none`.
- **c (T7) Regression suite, T7.TS4.** SKILL.md 1.6 counts every
  `test_*.md` under the space's `tests/`, in that folder or any folder below
  it. Each test's `<change>/<Rn.Sm>` key comes from the first of these that
  names it, by test name:
  1. a row of an archived plan's test map;
  2. else a row of the `## Scenarios` table in an archived `report.md`;
  3. else the test's own `scenario:` value, when it is written
     `<change>/<Rn.Sm>`.

  When several archived changes name the test at one step, the folder name
  that sorts last wins. A test that none of these keys still counts, and
  its result is missing. See Concerns for the bare `scenario:` case.
- **d (T7, T5) Words and review dispatch, T7.TS3.**
  - SKILL.md 1.4 takes an event that says in plain words that `T<n>` is
    finished, done or complete as a DONE line, and one that says it is not,
    or not yet, as no DONE line. status-format.md's Latest row for words
    matches.
  - In status-format.md's "Task states", a review task is now dispatched
    only by its own dispatch line. A review of one task is ready once that
    task has reported and the rest of its `after` list is done. Done still
    comes first, so a closed review reads done.
  - A review task's Latest events now include its own dispatch lines.
  - SKILL.md section 4 step 2 states the same ready rule.
  - swe-lead.md "Checking and filing" step 3 records
    `dispatch T<m> -> review (<local|mesh>, <env class|any>)` when it
    dispatches a review. Every review it dispatches gets a dispatch line,
    fix-round re-reviews and the whole-change review included.
- **e (T5, T1) Branches at the go, R23.S2 and T3.TS3.**
  - swe-lead.md Go step 3 now covers only the repos the spec names. It
    shows the two commands, `git -C <checkout> branch change/<id> <pin>`
    and `git -C <checkout> push origin change/<id>`. The lead runs them
    itself when the deployment's guidance (G1, the pod commit scope in
    swe-pod's `INSTALL.md`) lets the pod commit. Otherwise it gives them to
    the human, filled in, for each repo, and waits.
  - Either way, the lead writes the go line only once `git ls-remote`
    shows each branch. A repo the spec does not name gets no branch and no
    branch command.
  - PROCESS.md §1 Branches says the same. It states the guidance condition
    in words: the guidance lets the lead create and push each `change/<id>`
    at the go, and lets builders commit to it and push it. It cites
    `INSTALL.md`, "Rules for your guidance overlay", and uses no bare
    requirement or decision id.
- **f (T5) Code repo `main`.** swe-lead.md Never now reads: push to a code
  repo's `main` except the integrate merge, on the human's word. This
  matches its Writes line and "Merge and integrate" step 4.
- **g (T2) Test brief report line.** templates/records/test-brief.md
  "Result goes to" has the exact line
  `- report: changes/<id>/evidence/<YYYYMMDDTHHMMZ>-T<n>-report.md`, and its
  comment says that every test task keeps it. This matches plan §2.4
  (Report) and PROCESS.md §12.

Nothing is pushed back. Finding c is taken in a narrower form; the reason is
under Concerns.

## Files

- swe-pod/PROCESS.md: changed, §1 Branches (T1). Range
  `swe-pod 1cecea0..b830ab2`.
- swe-pod/templates/records/test-brief.md: changed, "Result goes to" (T2).
  Range `swe-pod b830ab2..ec10cf6`.
- swe-pod/agents/swe-lead.md: changed, Never, Go step 3, and "Checking and
  filing" step 3 (T5). Range `swe-pod ec10cf6..f174cf8`.
- swe-pod/skills/swe-pod/SKILL.md and swe-pod/skills/swe-pod/status-format.md:
  changed (T7). Range `swe-pod f174cf8..2a01192`.

| Task | Commit | Subject |
|---|---|---|
| T1 | b830ab2 | Make the go create named branches or give the human the commands before the go line |
| T2 | ec10cf6 | Add the report line to the test brief result section |
| T5 | f174cf8 | Fix the lead go step branches main rule and review dispatch lines |
| T7 | 2a01192 | Fix branch heads zero counts regression tests and review task states in the swe-pod skill |

Each commit has the trailers `Change: build-swe-pod` and `Task: T<n>`. The
whole fix range is `swe-pod 1cecea0..2a01192`, pushed to
`origin/change/build-swe-pod`. Before the push, the merge-base check showed
that the remote head 1cecea0 was already in the branch, so I did not rebase.

## Test output

### Done-when checks (one script, 23 checks, finding letter first)

The script ran from a scratch folder outside the space and the code repo,
with the checkout as its target. It has since been deleted. Each check is a
grep over the changed rule's block. e5 is a guard: no line added to
PROCESS.md may carry a bare requirement or decision id. It holds trivially
before any edit.

- red, before any edit:

```
FAIL a1 SKILL 1.1 has a Branch head rule for a remote that cannot be read
FAIL a2 rule takes the newest ledger range end, else the go line base
FAIL a3 status-format branches bullet cites the Branch head rule
FAIL a4 SKILL 1.5 takes heads from the Branch head rule
FAIL b1 review cell says how a count of 0 is written
FAIL b2 old ambiguous wording gone
FAIL c1 SKILL 1.6 counts every test file under tests/ at any depth
FAIL c2 falls back to the archived report, then the scenario: value
FAIL c3 old map-only rule gone
FAIL d1 SKILL 1.4 accepts finished, done or complete in words
FAIL d2 status-format: no implicit review dispatch
FAIL d3 status-format: review ready once the task it reviews has reported
FAIL d4 status-format: in-words row matches 1.4
FAIL d5 SKILL section 4 ready rule matches the review rule
FAIL d6 swe-lead writes a dispatch line for a review
FAIL e1 swe-lead Go gives per-repo branch and push commands
FAIL e2 swe-lead Go writes the go line only once the branches exist
FAIL e3 PROCESS 1 Branches gives the commands and the guidance condition
FAIL e4 PROCESS 1 Branches writes the go line only once the branches exist
PASS e5 guard: lines added to PROCESS carry no bare requirement or decision id
FAIL f1 swe-lead Never: old blanket rule gone
FAIL f2 swe-lead Never: only the integrate merge, on the human's word
FAIL g1 test-brief Result goes to has the report line
checks: 1/23 pass
```

- first green run: 22 of 23 passed. d3 failed only because "has reported"
  wraps across two lines in the new rule. I changed that check to ignore
  line breaks and left the prose as it was.
- green, after the edits and before the commits:

```
PASS a1 SKILL 1.1 has a Branch head rule for a remote that cannot be read
PASS a2 rule takes the newest ledger range end, else the go line base
PASS a3 status-format branches bullet cites the Branch head rule
PASS a4 SKILL 1.5 takes heads from the Branch head rule
PASS b1 review cell says how a count of 0 is written
PASS b2 old ambiguous wording gone
PASS c1 SKILL 1.6 counts every test file under tests/ at any depth
PASS c2 falls back to the archived report, then the scenario: value
PASS c3 old map-only rule gone
PASS d1 SKILL 1.4 accepts finished, done or complete in words
PASS d2 status-format: no implicit review dispatch
PASS d3 status-format: review ready once the task it reviews has reported
PASS d4 status-format: in-words row matches 1.4
PASS d5 SKILL section 4 ready rule matches the review rule
PASS d6 swe-lead writes a dispatch line for a review
PASS e1 swe-lead Go gives per-repo branch and push commands
PASS e2 swe-lead Go writes the go line only once the branches exist
PASS e3 PROCESS 1 Branches gives the commands and the guidance condition
PASS e4 PROCESS 1 Branches writes the go line only once the branches exist
PASS e5 guard: lines added to PROCESS carry no bare requirement or decision id
PASS f1 swe-lead Never: old blanket rule gone
PASS f2 swe-lead Never: only the integrate merge, on the human's word
PASS g1 test-brief Result goes to has the report line
checks: 23/23 pass
```

### Owning tasks' own done-whens, re-checked

- T1 (1) and (2): `sed -n 1p` gives `# SWE Pod process`, and `sed -n 3p`
  gives `process: swe-pod-process@1`. `grep -c '^## ' PROCESS.md` gives
  15.
- T2 (3): the last line of `test-brief.md` is still the exact closing line.
- T5 and T7: the fixed phrase, the ledger event forms and the five BREAK
  forms are unchanged.
- No added line has trailing spaces. The only added lines over 80 chars
  are table rows, which follow the file's style.

### Standard close

- shareability, once per owning task, after committing and before pushing:

```
--task T1: shareability: 0 hits
--task T2: shareability: 0 hits
--task T5: shareability: 0 hits
--task T7: shareability: 0 hits
```

- `git diff --stat 74d23f1 -- SPEC.md spec-process.d2 spec-process.svg
  spec-process.png` gives no output: the design doc is unchanged since the
  latest `Task: T0` commit.
- push: `1cecea0..2a01192  change/build-swe-pod -> change/build-swe-pod`.
  The tree is clean and equal to `origin/change/build-swe-pod`.

### Unit suite

unit: none-present. swe-pod has no unit suite.

## Concerns

- **c, bare `scenario:` values.** The finding's last fallback is "the
  test's own `scenario:` front-matter value". I take it only when the value
  is written `<change>/<Rn.Sm>`. A bare value such as `R1.S1`, which is
  what the demo fixture's promoted test has, names no change. Qualifying
  it would mean guessing which archived change it came from, and leaving
  it bare would clash with the current change's own `R1.S1`. So a test
  with a bare value that no archived plan or report names still counts,
  and its result is missing: the change cannot read verified, and no
  result is dropped. In T7.TS4 the archived report names the test, so step
  2 keys it as `add-farewell/R1.S1`.
- **c, the test agent's side.** PROCESS.md §7, swe-test.md and the
  evidence template say regression results go under `<change>/<Rn.Sm>`.
  None of them says how the test agent finds `<change>` for a file in
  `tests/`. The skill now has a rule for reading the key. The writing side
  should state the same rule, but that is T1 and T6 scope and outside this
  round's findings, so the lead may want a follow-up.
- **d, ledgers without review dispatch lines.** This change's own ledger
  has none. Under the new rule, a closed review still reads done. A review
  whose task has reported and whose review is not closed now reads ready,
  where before it read dispatched, until the lead writes its dispatch line.
- **T7.TS1, check .2.** That check failed because step 2 touched the
  space's `STATUS.md` after the human asked it not to. Finding b does not
  cover this. The skill's read order (SKILL.md 1.1) and section 3 step 3
  (compare with the committed file) both have the agent read `STATUS.md`.
  The skill says nothing about yielding to a human request not to read it.
  I left this unchanged because it was not among the findings.
- **R20.S1, empty task table.** Both runs had a change with no plan and
  wrote its task table as the header rows only. They agreed, but
  status-format.md has no fixed text for that case. Not changed, since it
  was not among the findings.
- **T7.TS4, ruling form.** That run also saw a parked-finding ruling not
  written in the `Ruling: T<n> open findings ...` form, so it closed
  nothing. That is a fixture matter, and the check that failed (.2) was
  about missing results only.

## Test suggestions

### T7.TS5 One remote readable, one not, with a fix round
- for the tester: R20.S1 and R18.S1 are at risk. Use a change in two repos.
  One repo's remote can be read and lists `change/<id>`. The other's URL
  does not resolve, and its ledger has a fix-round range newer than its
  task's DONE range. Rebuild STATUS.md twice. The expected failure is that
  the unreadable repo's head is taken from the older DONE range, or from
  the go line, or is written `missing`. Another is that the two rebuilds
  differ, or that the latest evidence's stale mark disagrees with the
  branches bullet.
- for the reviewer: swe-pod/skills/swe-pod/SKILL.md:44-61 (the Branch head
  rule, where a fix-round range is tied to a repo through the plan's
  `repo:` field) and swe-pod/skills/swe-pod/SKILL.md:162-165 (1.5 uses it).

### T7.TS6 Review lines with mixed and all-zero counts
- for the tester: R20.S1 is at risk. Use a ledger where one review line
  gives `spec issues; 0 Critical, 0 Important, 2 Minor`, another gives
  `spec ok; 0 Critical, 0 Important, 0 Minor`, and a re-review line
  `review r2:` gives no counts at all. Rebuild STATUS.md twice. The
  expected failure is that the rebuilds differ in the latest cell of those
  review tasks, or that a zero count is kept.
- for the reviewer: swe-pod/skills/swe-pod/status-format.md:187 (the review
  row of the Latest table).

### T7.TS7 Regression test in a subfolder, named twice or not at all
- for the tester: R12 and R5.S2 are at risk. Use a space whose `tests/`
  holds a regression test in a subfolder. Two archived changes' reports
  name it, and a second regression test is named by no archived plan or
  report and has a bare `scenario:` value. The latest evidence passes
  every scenario, unit suite and the first test. The expected failure is
  that the change reads verified, or that the first test's result is
  looked for under the older archived change.
- for the reviewer: swe-pod/skills/swe-pod/SKILL.md:190-205 (the
  regression bullet of 1.6: its three key sources and the folder-sort
  tie-break).

### T7.TS8 A task said in words not to be finished
- for the tester: R18.S1 is at risk. Use a ledger with an event in words
  that says a lead task is not finished yet, and a later one that says it
  is done. Ask where things stand between the two events (ledger cut after
  the first) and after both. The expected failure is that the task reads
  done after the first event alone, or not done after the second.
- for the reviewer: swe-pod/skills/swe-pod/SKILL.md:133-137 (status line
  in words).

### T5.TS7 Go when the guidance does not let the pod commit
- for the tester: R23.S1 and R23.S2 are at risk. Use a lead whose
  deployment's guidance has no pod commit scope rule, a spec naming two of
  the three repos in `pod.yaml`, and the human's "go". The expected
  failure is any of these: the lead runs a branch or push command itself;
  it gives commands for the third repo; it gives no commands for one of
  the two named repos; or it writes the go line before the human says the
  commands ran.
- for the reviewer: swe-pod/agents/swe-lead.md:110-132 and
  swe-pod/PROCESS.md:73-96 (the two cases, and when the go line is
  written).

### T5.TS8 Review dispatch recorded
- for the tester: R16.S1 and R18.S1 are at risk. Have a build task report
  DONE with its commits on the branch, and have the lead dispatch its
  review. The expected failure is that the ledger gains no dispatch line
  for the review task, or that the line names a machine instead of a role,
  `local` or `mesh`, and an environment class. A later status rebuild
  then shows the review as ready while it runs.
- for the reviewer: swe-pod/agents/swe-lead.md:258-268 (Checking and
  filing step 3) and swe-pod/skills/swe-pod/status-format.md:163-170 (task
  states 3 and 4).

## Fix round 3

Status: DONE. This round fixes the findings of the
fix-mode review, `changes/build-swe-pod/tasks/V1-review.md`: c, three
Important findings and three Minor ones. Nothing is pushed back.

### What I did

- **Important SKILL.md:193, no key for promoted inspection and suggestion
  tests (c).** SKILL.md 1.6 now gives each regression test the key
  `<change>/<value>`:
  - `<change>` is the name of the folder `tests/<change>/` the test sits
    in. For a test directly in `tests/`, it is the archived change whose
    plan test map, or else whose final report, names the test, with the
    folder that sorts last winning, else the change of a qualified
    `scenario:` value.
  - `<value>` is the scenario id in that change's archived test map or
    report row, else the test's `scenario:` value without any `<change>/`
    part, else the id its file name carries (section 5, step 4).
  - `<change>/R<n>.S<m>` goes under `scenarios:`, `<change>/I<n>` under
    `x-checks:` and `<change>/T<n>.TS<k>` under `x-suggestions:`.
  - The writing side, PROCESS.md §7 (T1), states the same key for the test
    agent.
  - For the folder to exist, PROCESS.md §8 step 5 (T1) and swe-lead.md
    "Merge and integrate" step 5 (T5) now move `changes/<id>/tests/` into
    `tests/` as the folder `tests/<id>/`. This goes past "one line in T1":
    without it the key rule's folder would not reliably exist, and a flat
    promotion leaves inspection and suggestion tests with no key. A flat
    `tests/` layout, as in the demo fixtures, is still read through the
    archived records. R5.S2 accepts both layouts.
- **Important SKILL.md:190, fixture files counted.** Only a `test_*.md`
  directly in `tests/<change>/`, or directly in `tests/`, counts. A
  `<change>` folder counts only when `changes/archive/<yyyy-mm-dd>-<change>/`
  exists, so a folder such as `tests/fixtures/` is never taken for a
  change. Nothing deeper counts: `tests/<change>/fixtures/` holds no test
  of the suite. PROCESS.md §7 says the same: never fixture data below
  them.
- **Important SKILL.md:42 and "What it writes", the read-only rule against
  the lead's Go step.**
  - In SKILL.md 1.1, the never-commit, push or branch rule now holds in
    sections 2, 3 and 5. In section 4 the lead's definition decides.
  - Section 4 says the lead's Go step applies as written: the lead makes
    and pushes each `change/<id>` when the pod commit scope allows it, and
    otherwise gives the human the commands.
  - "What it writes" scopes "nothing in a code repo" to the skill's own
    steps, and says the lead's writes include the branches it makes at
    the go.
- **Minor SKILL.md:54, Branch head with a plan entry naming several
  repos.**
  - A range for a repo is one written `<repo> <sha7>..<sha7>` on any
    task's line.
  - A fix-round line's bare `<sha7>..<sha7>` counts only when the task's
    plan entry names that repo alone in `repo:`.
  - The bare range of a task whose entry names several repos counts for
    none of them.
- **Minor SKILL.md:312, ready rule.** Section 4 step 2 now says: not held,
  no dispatch line yet, and the `after` tasks done. For the review of one
  task, it says that task has reported and every other task in its `after`
  list is done, as status-format.md says.
- **Minor swe-lead.md:61.** It now reads: push to a code repo's `main`
  other than the integrate merge the human asks for.
- **Evidence template (T2), at the coordinator's request.** Only its
  comments changed. The scenarios comment now names regression scenario
  tests under `<change>/R<n>.S<m>`. The x-checks and x-suggestions comment
  names `<change>/I<n>` under `x-checks:` and `<change>/T<n>.TS<k>` under
  `x-suggestions:`. No key or other line changed.

### Files

| Task | Commit | Files |
|---|---|---|
| T1 | f1cf99c | swe-pod/PROCESS.md: §7, the regression key; §8 step 5, `tests/<id>/` |
| T5 | f833f72 | swe-pod/agents/swe-lead.md: Never, `main`; integrate step 5, `tests/<id>/` |
| T7 | 7572de9 | swe-pod/skills/swe-pod/SKILL.md: 1.1, 1.6, section 4 and "What it writes" |
| T2 | 3280728 | swe-pod/templates/records/evidence.md: the regression key comments |

The round's range is `swe-pod 2a01192..3280728`, pushed to
`origin/change/build-swe-pod` in two pushes, the T2 commit last. Before
each push, the merge-base check showed that the remote head (2a01192, then
7572de9) was already in the branch, so I did not rebase.

### Test output

One script of 14 done-when checks, each a grep over the changed block with
line breaks ignored. It ran from a scratch folder outside the space and the
code repo, and has since been deleted. The last check is a guard: lines
added to PROCESS.md since 2a01192 carry no bare requirement or decision id.

- red, before the edits:

```
FAIL 1a SKILL 1.6: inspection and suggestion regression keys have a home
FAIL 1b SKILL 1.6: change from the tests/<change>/ folder, value from scenario: or the file name
FAIL 1c PROCESS 7: writing side states the same keys
FAIL 1d PROCESS 7: old R-only rule gone
FAIL 1e PROCESS 8 and swe-lead integrate move the tests to tests/<id>/
FAIL 2a SKILL 1.6: only files directly in tests/ or tests/<change>/
FAIL 2b SKILL 1.6: fixture data is not a test of the suite
FAIL 3a SKILL 1.1: read-only rule limited to the skill's own sections
FAIL 3b SKILL 4: the lead's Go step applies, branches included
FAIL 3c What it writes: no blanket nothing-in-a-code-repo rule
FAIL m1 Branch head case 3 says what a several-repo plan entry gives
FAIL m2 SKILL 4 step 2 ready rule: not held, every other after task done
FAIL m3 swe-lead Never reads as one item
PASS guard: lines added to PROCESS since 2a01192 carry no bare requirement or decision id
checks: 1/14 pass
```

- green, after the edits and before the commits:

```
PASS 1a SKILL 1.6: inspection and suggestion regression keys have a home
PASS 1b SKILL 1.6: change from the tests/<change>/ folder, value from scenario: or the file name
PASS 1c PROCESS 7: writing side states the same keys
PASS 1d PROCESS 7: old R-only rule gone
PASS 1e PROCESS 8 and swe-lead integrate move the tests to tests/<id>/
PASS 2a SKILL 1.6: only files directly in tests/ or tests/<change>/
PASS 2b SKILL 1.6: fixture data is not a test of the suite
PASS 3a SKILL 1.1: read-only rule limited to the skill's own sections
PASS 3b SKILL 4: the lead's Go step applies, branches included
PASS 3c What it writes: no blanket nothing-in-a-code-repo rule
PASS m1 Branch head case 3 says what a several-repo plan entry gives
PASS m2 SKILL 4 step 2 ready rule: not held, every other after task done
PASS m3 swe-lead Never reads as one item
PASS guard: lines added to PROCESS since 2a01192 carry no bare requirement or decision id
checks: 14/14 pass
```

- evidence template (T2), one grep per key, red and then green:

```
red:
FAIL key <change>/R<n>.S<m> named
FAIL key <change>/I<n> named
FAIL key <change>/T<n>.TS<k> named
FAIL old R-only wording gone
green:
PASS key <change>/R<n>.S<m> named
PASS key <change>/I<n> named
PASS key <change>/T<n>.TS<k> named
PASS old R-only wording gone
```

  Every changed line of the template begins with `#`, and none is over 80
  chars.
- Round-1 checks c1 ("any folder below it") and f2 ("except the integrate
  merge") would now fail. That is expected: this round replaces that
  wording on purpose.
- PROCESS.md line 1 and line 3 are unchanged, and it still has 15
  level-2 headings. No added line has trailing spaces. No added prose line
  is over 80 chars.
- shareability, after committing and before pushing:

```
--task T1: shareability: 0 hits
--task T5: shareability: 0 hits
--task T7: shareability: 0 hits
--task T2: shareability: 0 hits
```

- `git diff --stat 74d23f1 -- SPEC.md spec-process.d2 spec-process.svg
  spec-process.png` gives no output.
- push: `2a01192..7572de9  change/build-swe-pod -> change/build-swe-pod`,
  then `7572de9..3280728  change/build-swe-pod -> change/build-swe-pod`.
- unit: none-present. swe-pod has no unit suite.

### Concerns

- The evidence template concern raised earlier in this round is closed
  by 3280728 (T2).
- swe-test.md (T6) says only "regression results under qualified ids",
  which does not contradict the new key. It points to PROCESS.md §7.
- This change's own tests are the first to be promoted under the new rule.
  At its integrate, they move to `tests/build-swe-pod/` with `fixtures/`
  below. The 53 inspection and suggestion tests get keys from their
  `scenario:` values, and the 107 fixture files are not counted.

### Test suggestions

#### T7.TS7, updated: regression tests in a folder, flat, and in fixtures
- for the tester: R12 and R5.S2 are at risk. Integrate a change whose tests
  include a scenario test, an inspection test, a suggestion test and a
  fixture folder holding files named `test_*.md`. Then run verify for a
  later change, with evidence that passes every result except the promoted
  inspection test. The expected failure is that the later change reads
  verified, that fixture files are asked for as results, or that the
  inspection or suggestion result is looked for under `scenarios:`.
- for the reviewer: swe-pod/skills/swe-pod/SKILL.md:193-215 (1.6, the
  regression bullet) and swe-pod/PROCESS.md:531-544 (§7, the writing-side
  key).

#### T7.TS9 Go through the skill under the pod commit scope
- for the tester: R23.S1 is at risk. Run the `swe-pod` skill on "go" in a
  deployment whose guidance has the pod commit scope rule. The expected
  failure is that it refuses to make the branches, or only prints them,
  because of a read-only rule.
- for the reviewer: swe-pod/skills/swe-pod/SKILL.md:39-44, 312-316 and
  394-399 (the read-only rule's scope, and section 4's pointer to the
  lead's Go step).

## Fix round 4

Status: DONE. This round fixes the three findings left by the review of
round 3, all in the regression key rule. Nothing is pushed back.

### What I did

- **Important swe-pod/agents/swe-test.md:158 (T6).** I made two changes so
  that an agent following swe-test.md writes regression results where
  SKILL.md 1.6 looks for them.
  - Verify step 2 now says what the regression suite is: each `test_*.md`
    directly in `tests/`, or directly in `tests/<change>/` for an archived
    change. It never counts fixture data or anything else below them.
  - Step 4 now has a regression bullet. It gives the key
    `<change>/<value>` by the rule of `PROCESS.md §7`, with
    `<change>/R<n>.S<m>` under `scenarios:`, `<change>/I<n>` under
    `x-checks:` and `<change>/T<n>.TS<k>` under `x-suggestions:`.
    - It also gives the common case. For a test in `tests/<change>/`, the
      change is the folder's name, and the value is its row's scenario id
      in the archived test map or report, else its `scenario:` value.
    - For the other cases it points to §7.
  - The `scenarios:` bullet no longer carries the old `<change>/<Rn.Sm>`
    rule. The optional `x-checks:` and `x-suggestions:` bullet now says
    that its bare keys are for this change's tests, and the regression
    keys sit beside them.
- **Minor swe-pod/PROCESS.md:532 (T1).** §7 now states the key the way
  SKILL.md 1.6 does, for the three edge cases the review named:
  - A `tests/<change>/` folder counts only when
    `changes/archive/<yyyy-mm-dd>-<change>/` exists. Nothing deeper counts.
  - For a test directly in `tests/`: first the archived plan test map,
    else the archived final report, with the archive folder name that sorts
    last winning. Failing both, the change of a `scenario:` value written
    `<change>/<value>`.
  - `<value>` drops any `<change>/` part. The id a file name carries is
    spelled out for all three name forms.
  - A test with no key still counts, and the agent names it in the body.
- **Minor swe-pod/skills/swe-pod/SKILL.md:354 (T7).** Trace step 2 now
  looks for an integrated change's test in `tests/<id>/`.

### Files

| Task | Commit | Files |
|---|---|---|
| T1 | 7296598 | swe-pod/PROCESS.md: §7, the regression key in full |
| T6 | 49f0a93 | swe-pod/agents/swe-test.md: verify steps 2 and 4 |
| T7 | 079cd89 | swe-pod/skills/swe-pod/SKILL.md: trace step 2 |

The round's range is `swe-pod 3280728..079cd89`, pushed to
`origin/change/build-swe-pod`. Before the push, the merge-base check showed
that the remote head 3280728 was already in the branch, so I did not
rebase.

### Test output

One script of 9 done-when checks, each a grep over the changed block with
line breaks ignored. It ran from a scratch folder outside the space and the
code repo, and has since been deleted. The last check is a guard: lines
added to PROCESS.md since 3280728 carry no bare requirement or decision id.

- red, before the edits:

```
FAIL 1a swe-test step 2: only files directly in tests/<change>/ or tests/, never fixture data
FAIL 1b swe-test step 4: the three regression keys
FAIL 1c swe-test: old R-only key gone
FAIL 1d swe-test points to PROCESS.md section 7 for the key rule
FAIL 2a PROCESS 7: a tests/<change>/ folder counts only when the change is archived
FAIL 2b PROCESS 7: tie-break and qualified-scenario fallback for a test directly in tests/
FAIL 2c PROCESS 7: drops a <change>/ part from a scenario: value
FAIL 3a SKILL trace step 2: integrated test in tests/<id>/
PASS guard: lines added to PROCESS since 3280728 carry no bare requirement or decision id
checks: 1/9 pass
```

- green, after the edits and before the commits:

```
PASS 1a swe-test step 2: only files directly in tests/<change>/ or tests/, never fixture data
PASS 1b swe-test step 4: the three regression keys
PASS 1c swe-test: old R-only key gone
PASS 1d swe-test points to PROCESS.md section 7 for the key rule
PASS 2a PROCESS 7: a tests/<change>/ folder counts only when the change is archived
PASS 2b PROCESS 7: tie-break and qualified-scenario fallback for a test directly in tests/
PASS 2c PROCESS 7: drops a <change>/ part from a scenario: value
PASS 3a SKILL trace step 2: integrated test in tests/<id>/
PASS guard: lines added to PROCESS since 3280728 carry no bare requirement or decision id
checks: 9/9 pass
```

- PROCESS.md still has 15 level-2 headings. No added line has trailing
  spaces or is over 80 chars.
- shareability, after committing and before pushing:

```
--task T1: shareability: 0 hits
--task T6: shareability: 0 hits
--task T7: shareability: 0 hits
```

- `git diff --stat 74d23f1 -- SPEC.md spec-process.d2 spec-process.svg
  spec-process.png` gives no output.
- push: `3280728..079cd89  change/build-swe-pod -> change/build-swe-pod`.
- unit: none-present. swe-pod has no unit suite.

### Concerns

None.

### Test suggestions

#### T6.TS6 Test agent writes the keys the skill reads
- for the tester: R12 and R5.S2 are at risk. Use a space where an
  integrated change left a scenario test, an inspection test and a
  suggestion test in `tests/<change>/`, and fixture files named
  `test_*.md` below that folder. Then run verify for a later change. The
  expected failure is any of these:
  - the evidence record gives a regression result under a bare id;
  - it puts the inspection or suggestion result under `scenarios:`;
  - it gives results for fixture files;
  - the skill then reports a regression result as missing although the
    test passed.
- for the reviewer: swe-pod/agents/swe-test.md:141-143 and 163-169, and
  swe-pod/PROCESS.md:531-552.

## Fix round 5

Status: DONE. This round fixes the findings of the review of round 4.
Nothing is pushed back.

### What I did

- **Important: a test whose `scenario:` value lists several ids got no
  key.** This was at PROCESS.md:546 (T1), SKILL.md:208-210 (T7) and
  swe-test.md:168 (T6). Now, in all three places:
  - With no archived row, `<value>` is the `scenario:` value, less any
    `<change>/` part, only when that value is exactly one id.
  - When it is not (it lists several ids, or the test has none), `<value>`
    is the id the file name carries. That is the section 5, step 4
    mapping in SKILL.md, spelled out in PROCESS.md §7.
  - The `<change>` fallback for a test directly in `tests/` takes a
    `scenario:` value only when it is one id written `<change>/<value>`.
  - So each test has at most one key. For example,
    `test_T1_TS5_<slug>` with `scenario: T1.TS5, T5.TS6` gets the value
    `T1.TS5`.
- **Minor swe-test.md:167 (T6).** The short form now gives the full order
  for a test in `tests/<change>/`:
  1. the archived plan test map;
  2. else the archived final report;
  3. else the `scenario:` value, less any `<change>/` part, when it is
     exactly one id;
  4. else the id the file name carries.

  It points to §7 only for a test directly in `tests/`.
- **Minor swe-test.md:40 (T6).** The verify-mode Reads paragraph now also
  lists, for the regression keys, each archived change's folder,
  `changes/archive/<yyyy-mm-dd>-<change>/`, and in it that change's plan
  test map and final report.

### Files

| Task | Commit | Files |
|---|---|---|
| T1 | f7545b1 | swe-pod/PROCESS.md: §7, the value rule |
| T6 | f3dabea | swe-pod/agents/swe-test.md: Reads (verify mode) and verify step 4 |
| T7 | 4d5bfc7 | swe-pod/skills/swe-pod/SKILL.md: 1.6, the value rule |

The round's range is `swe-pod 079cd89..4d5bfc7`, pushed to
`origin/change/build-swe-pod`. Before the push, the merge-base check showed
that the remote head 079cd89 was already in the branch, so I did not
rebase.

### Test output

One script of 6 done-when checks, each a grep over the changed block with
line breaks ignored. It ran from a scratch folder outside the space and the
code repo, and has since been deleted. The last check is a guard: lines
added to PROCESS.md since 079cd89 carry no bare requirement or decision id.

- red, before the edits:

```
FAIL 1a PROCESS 7: a scenario: value that is not exactly one id falls back to the file name
FAIL 1b SKILL 1.6: same rule
FAIL 1c swe-test step 4: same rule
FAIL 2 swe-test: test map before final report, and the <change>/ part dropped
FAIL 3 swe-test Reads: verify mode lists the archived records
PASS guard: lines added to PROCESS since 079cd89 carry no bare requirement or decision id
checks: 1/6 pass
```

- green, after the edits and before the commits:

```
PASS 1a PROCESS 7: a scenario: value that is not exactly one id falls back to the file name
PASS 1b SKILL 1.6: same rule
PASS 1c swe-test step 4: same rule
PASS 2 swe-test: test map before final report, and the <change>/ part dropped
PASS 3 swe-test Reads: verify mode lists the archived records
PASS guard: lines added to PROCESS since 079cd89 carry no bare requirement or decision id
checks: 6/6 pass
```

- PROCESS.md still has 15 level-2 headings. No added line has trailing
  spaces or is over 80 chars.
- shareability, after committing and before pushing:

```
--task T1: shareability: 0 hits
--task T6: shareability: 0 hits
--task T7: shareability: 0 hits
```

- `git diff --stat 74d23f1 -- SPEC.md spec-process.d2 spec-process.svg
  spec-process.png` gives no output.
- push: `079cd89..4d5bfc7  change/build-swe-pod -> change/build-swe-pod`.
- unit: none-present. swe-pod has no unit suite.

### Concerns

None.

### Test suggestions

#### T7.TS10 A promoted suggestion test that serves several suggestions
- for the tester: R12 is at risk. Promote a suggestion test whose
  `scenario:` value lists two suggestion ids into `tests/<change>/` of an
  archived change whose records give it no row. Run verify for a later
  change, and give that test a passing result under the key its file name
  carries. The expected failure is that the later change does not read
  verified, or that the evidence gives the test two results or a result
  under the whole list.
- for the reviewer: swe-pod/PROCESS.md:543-550,
  swe-pod/skills/swe-pod/SKILL.md:205-212 and
  swe-pod/agents/swe-test.md:166-174.
