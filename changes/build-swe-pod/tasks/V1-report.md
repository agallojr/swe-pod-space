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
