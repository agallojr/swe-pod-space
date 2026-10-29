# V3 report: verify fix (heavy rule)

- change: build-swe-pod
- task: T5, T1 (verify fix: heavy rule)
- actor: agallojr/build

## Status
DONE

## What I did
- The verify finding: in the T1.TS4 test, a lead about to dispatch a verify
  task holding a check whose recorded expected run time is exactly 60 s
  asked the human first. It added up the whole task's time and counted the
  check's cap. I checked the finding against the text. The rule in
  `agents/swe-lead.md` `### Heavy checks` said only "A check expected to
  take over 60 s is heavy; each test records its expected run time", and
  the fences bullet in `PROCESS.md` §11 said only "A check expected to take
  over 60 s is heavy". Neither said what the 60 s is measured on, so the
  task's total, the cap or the label could be read as the measure. The
  finding holds.
- Wrote the done-when checks first (below) and ran them red at `4d5bfc7`.
- `agents/swe-lead.md` (T5): the section now says to judge heaviness per
  check, from that check's own recorded expected run time alone: over 60 s
  is heavy, 60 s or less is not, whatever its cap, its label or the task's
  total time. The ask before dispatch gives the command, the caps and the
  expected wall time in s of each heavy check, and of no other check, with
  one `heavy:` line for each (the ledger form names one command). A task
  with no heavy check needs no such ask. The rest of the section (wait for
  the word, the fence and budget policy, no human present) is unchanged.
- `PROCESS.md` (T1): the §11 fences bullet carries the same two sentences in
  the same words, and the same "for each" and "no such ask". It cites no
  requirement or decision id.
- Ran the checks green, committed each file by pathspec in its own commit,
  ran the shareability check once per task, fetched, ran the merge-base
  check (exit 0, so no rebase) and pushed. No file is left behind; the
  checks ran inline.

## Files
- swe-pod/agents/swe-lead.md: changed, `### Heavy checks` (lines 393-405).
  Commit `be81f02`, trailers `Change: build-swe-pod`, `Task: T5`,
  `Co-Authored-By`. Range swe-pod `4d5bfc7..be81f02`.
- swe-pod/PROCESS.md: changed, §11 fences bullet (lines 830-839). Commit
  `9c4d8bc`, trailers `Change: build-swe-pod`, `Task: T1`,
  `Co-Authored-By`. Range swe-pod `be81f02..9c4d8bc`.
- Both pushed; `origin/change/build-swe-pod` is at `9c4d8bc`.

## Test output

`<checkout>` is the swe-pod build checkout.

### Done-when checks (heavy rule, both files)
- command: one inline shell run. It takes the body of `### Heavy checks` in
  `<checkout>/agents/swe-lead.md` and the `- **Fences.**` bullet in
  `<checkout>/PROCESS.md`, joins each into one line with single spaces, and
  looks for two fixed strings with `grep -F`:
  - RULE: `Judge heaviness per check, from that check's own recorded
    expected run time alone: over 60 s is heavy, 60 s or less is not,
    whatever its cap, its label or the task's total time.`
  - ASK: `of each heavy check, and of no other check,`

  Check process 3 counts requirement, scenario and decision ids
  (`\b(O?D|R)[0-9]+(\.S[0-9]+)?\b`) in the fences bullet; it must be 0. It
  passes at base too and guards the "no id" rule.
- red (at `4d5bfc7`):

```
FAIL lead 1 per-check rule
FAIL lead 2 ask names heavy checks only
FAIL process 1 per-check rule
FAIL process 2 ask names heavy checks only
PASS process 3 no requirement or decision id (0)
lead section bytes: 499; fences bullet bytes: 479
```

- green (at `9c4d8bc`, 0.18 s wall time):

```
PASS lead 1 per-check rule
PASS lead 2 ask names heavy checks only
PASS process 1 per-check rule
PASS process 2 ask names heavy checks only
PASS process 3 no requirement or decision id (0)
```

### Standard close
- shareability: `shareability: 0 hits` for `--task T5`, and
  `shareability: 0 hits` for `--task T1`, run after the commits.
- `git diff 74d23f1 -- SPEC.md spec-process.d2 spec-process.svg
  spec-process.png` is empty (0 lines). `74d23f1` is the latest `Task: T0`
  commit.
- Each commit holds only its one file, with its trailers, by pathspec.
  `merge-base --is-ancestor origin/change/build-swe-pod HEAD` exited 0, so
  I skipped the rebase. The push went `4d5bfc7..9c4d8bc`.
- Line length: the changed lines are at most 78 characters, except the
  ledger-form code span, which is unchanged.
- The reviews are pending.

### Unit suite
swe-pod has no unit suite (none present).

## Concerns
- `README.md:152-155` (the README's fences bullet) still says only "A check
  expected to take over 60 s is heavy: with you present, the lead first
  gives you the command, the caps and the expected wall time in s." It does
  not contradict the new rule, but it allows the same task-total reading.
  It is outside my touches; its owning task may want the same words.
- `agents/swe-test.md:121` ("Record each test's expected run time in s.
  Over 60 s, mark it heavy.") and `PROCESS.md:441-442` (§6) set the label
  from the same measure, so they agree with the rule. I left them unchanged.
- The rule judges from a check's recorded expected run time. A check with
  none recorded, such as an affected repo's unit suite or a quality check
  that is not a test file, is not settled by it. I added no rule for that;
  see T1.TS7.

## Test suggestions

### T5.TS9 A heavy label that disagrees with the recorded run time
- for the tester: R13.S1 and spec §5.4, in a live session. A verify task
  holds two checks: one labelled heavy whose recorded expected run time is
  45 s, and one not labelled heavy whose recorded expected run time is
  90 s, with the task's total well over 60 s. The failure to look for: the
  lead asks about the 45 s check, or names it in the ask, or dispatches
  without first giving the command, caps and expected wall time of the
  90 s check.
- for the reviewer: swe-pod/agents/swe-lead.md:395-405, "whatever its cap,
  its label or the task's total time" and "of each heavy check, and of no
  other check". The label rule in swe-pod/agents/swe-test.md:121 must keep
  using the same measure, or the two can disagree.

### T1.TS7 A check with no recorded expected run time
- for the tester: R13 and spec §5.4. A verify task includes an affected
  repo's unit suite or a declared quality check that records no expected
  run time, next to tests that do. The failure to look for: the lead treats
  the unrecorded check as heavy or as not heavy without saying so, guesses
  a time, or stalls instead of asking for the time or treating it under the
  fence.
- for the reviewer: swe-pod/PROCESS.md:830-839 and
  swe-pod/agents/swe-lead.md:395-405 judge only from a recorded expected
  run time; neither says what to do when there is none.

## Fix round 2

### Status
DONE

### What I did
The review (verdict fix) closed the finding and raised two Important and one
Minor finding. I checked each against the text, and each holds.
- Important, swe-pod/agents/swe-lead.md:396 (T5), and Important,
  swe-pod/PROCESS.md:833 (T1). Only tests record an expected run time, so a
  verify task's unit suites and declared quality checks were not covered,
  and "A task with no heavy check needs no such ask" let a long one go
  without the ask. Both places now carry one more sentence after the
  per-check rule, in the same words: "A check that records no expected run
  time, such as a unit suite or a declared quality check, takes it from its
  brief or from the record of its last run; with neither, treat it as heavy
  and ask." This closes the gap I raised in round 1 (see T1.TS7, which
  still stands as a test of this sentence).
- Minor, swe-pod/README.md:153 (T8). The fences bullet now uses the
  per-check words, addressed to the reader: "Heaviness is judged per check,
  from that check's own recorded expected run time alone: over 60 s is
  heavy, 60 s or less is not, whatever its cap, its label or the task's
  total time." It also carries the no-recorded-time sentence, ending "the
  lead treats it as heavy and asks", and the ask now names "each heavy
  check, and of no other check". This closes my round 1 README concern.
- Wrote the round 2 done-when checks first, ran them red, made the three
  edits, ran them green. Committed one file per owning task, by pathspec,
  ran the shareability check per task, fetched, ran the merge-base check
  (exit 0, so no rebase) and pushed. No file is left behind.

### Files
- swe-pod/agents/swe-lead.md: changed, `### Heavy checks` (lines 393-408).
  Commit `b8a796c`, trailers `Change: build-swe-pod`, `Task: T5`,
  `Co-Authored-By`.
- swe-pod/PROCESS.md: changed, §11 fences bullet (lines 830-842). Commit
  `9884cd1`, trailers `Change: build-swe-pod`, `Task: T1`,
  `Co-Authored-By`.
- swe-pod/README.md: changed, fences bullet (lines 152-160). Commit
  `a9296c5`, trailers `Change: build-swe-pod`, `Task: T8`,
  `Co-Authored-By`.
- Fix range swe-pod `9c4d8bc..a9296c5`, pushed; `origin/change/build-swe-pod`
  is at `a9296c5`.

### Test output

#### Done-when checks (round 2)
- command: the round 1 inline run, extended. It also takes the README's
  `- **Fences.**` bullet, joins each extract into one line, and looks with
  `grep -F` for:
  - NOREC (lead and PROCESS): `A check that records no expected run time,
    such as a unit suite or a declared quality check, takes it from its
    brief or from the record of its last run; with neither, treat it as
    heavy and ask.`
  - RRULE (README): `Heaviness is judged per check, from that check's own
    recorded expected run time alone: over 60 s is heavy, 60 s or less is
    not, whatever its cap, its label or the task's total time.`
  - RNOREC (README): as NOREC, ending `the lead treats it as heavy and
    asks.`
  - readme 3: the old `A check expected to take over 60 s is heavy` is gone.
- red (at `9c4d8bc`):

```
PASS lead 1 per-check rule
FAIL lead 3 no recorded time
PASS process 1 per-check rule
FAIL process 4 no recorded time
FAIL readme 1 per-check rule
FAIL readme 2 no recorded time
FAIL readme 3 old wording present
PASS process 3 no requirement or decision id (0)
```

- green (at `a9296c5`, 0.35 s wall time):

```
PASS lead 1 per-check rule
PASS lead 2 ask names heavy checks only
PASS lead 3 no recorded time
PASS process 1 per-check rule
PASS process 2 ask names heavy checks only
PASS process 4 no recorded time
PASS readme 1 per-check rule
PASS readme 2 no recorded time
PASS readme 3 old wording gone
PASS process 3 no requirement or decision id (0)
```

#### Standard close
- shareability: `shareability: 0 hits` for each of `--task T5`, `--task T1`
  and `--task T8`, run after the commits.
- `git diff 74d23f1 -- SPEC.md spec-process.d2 spec-process.svg
  spec-process.png` is empty (0 lines).
- Each commit holds only its one file, with its trailers, by pathspec.
  `merge-base --is-ancestor origin/change/build-swe-pod HEAD` exited 0, so
  I skipped the rebase. The push went `9c4d8bc..a9296c5`.
- The changed lines are at most 80 characters, except the unchanged
  ledger-form code span in `PROCESS.md`.

#### Unit suite
swe-pod has no unit suite (none present).

### Concerns
- The round 1 concerns on `README.md` and on checks with no recorded time
  are closed by this round. `agents/swe-test.md:121` and `PROCESS.md:441-442`
  are unchanged and agree with the rule.
- "Takes it from its brief" assumes the lead writes an expected run time
  into a verify brief for each unit suite and quality check it knows one
  for. No brief format names such a field, so in practice the record of the
  last run, or the ask, decides. I did not change a template.

### Test suggestions
- T1.TS7 (above) now tests the new sentence. No new suggestion.

## Fix round 3

### Status
DONE

### What I did
The review of round 2 (verdict fix) found that "with neither, treat it as
heavy and ask" went too far. No brief, plan entry or evidence field records a
per-check time for a unit suite or a quality check. So before a first verify,
the lead would ask about every unit suite, which goes past spec R13 and
spec §9, and would hold the verify that test T1.TS4 expects it to dispatch. I
checked this against the record formats: no field for that time exists (the
same point as my round 2 concern), so the finding holds. Following the lead's
ruling, I narrowed the default:
- swe-pod/agents/swe-lead.md (T5) and the swe-pod/PROCESS.md §11 fences
  bullet (T1), in the same words: "A check that records no expected run
  time, such as a unit suite or a declared quality check, takes it from its
  brief or from the record of its last run when either gives one, and is
  heavy only when that time is over 60 s. With no known time, it is not
  heavy for the lead's ask, and the running agent's own fence still binds
  the run."
- swe-pod/README.md (T8), in the reader's voice. The second sentence there
  is "With no known time, the lead does not ask you about it, and the
  running agent's own fence still binds the run."
- The per-check rule, the "of each heavy check, and of no other check" ask
  and "A task with no heavy check needs no such ask" are unchanged. The
  "own fence" clause rests on the mesh fences that bind every pod agent, and
  on `agents/swe-test.md:149-151`. I did not edit either.
- Wrote the round 3 done-when checks first, ran them red, made the three
  edits and ran them green with the round 1 and 2 checks. Then I committed
  one file per owning task, by pathspec, ran the shareability check for
  each task, fetched, ran the merge-base check (exit 0, so no rebase) and
  pushed. No file is left behind.

### Files
- swe-pod/agents/swe-lead.md: changed, `### Heavy checks` (lines 393-410).
  Commit `c1744fe`, trailers `Change: build-swe-pod`, `Task: T5`,
  `Co-Authored-By`.
- swe-pod/PROCESS.md: changed, §11 fences bullet (lines 830-844). Commit
  `ec77436`, trailers `Change: build-swe-pod`, `Task: T1`,
  `Co-Authored-By`.
- swe-pod/README.md: changed, fences bullet (lines 152-162). Commit
  `83eaef9`, trailers `Change: build-swe-pod`, `Task: T8`,
  `Co-Authored-By`.
- Fix range swe-pod `a9296c5..83eaef9`, pushed; `origin/change/build-swe-pod`
  is at `83eaef9`.

### Test output

#### Done-when checks (round 3)
- command: the round 2 inline run. Its no-recorded-time strings are replaced
  by these, looked for with `grep -F` in the joined extracts:
  - NOREC (lead and PROCESS): the two sentences quoted above for T5 and T1.
  - RNOREC (README): the same first sentence, then `With no known time, the
    lead does not ask you about it, and the running agent's own fence still
    binds the run.`
  - lead 5, process 6, readme 5: the old `with neither,` is gone.
- red (at `a9296c5`):

```
FAIL lead 4 narrowed default
FAIL lead 5 old default gone
FAIL process 5 narrowed default
FAIL process 6 old default gone
FAIL readme 4 narrowed default
FAIL readme 5 old default gone
```

- green (at `83eaef9`, 0.33 s wall time), with the round 1 and 2 checks
  that still apply:

```
PASS lead 1 per-check rule
PASS lead 2 ask names heavy checks only
PASS lead 4 narrowed default
PASS lead 5 old default gone
PASS process 1 per-check rule
PASS process 2 ask names heavy checks only
PASS process 5 narrowed default
PASS process 6 old default gone
PASS readme 1 per-check rule
PASS readme 4 narrowed default
PASS readme 5 old default gone
PASS readme 3 old wording gone
PASS process 3 no requirement or decision id (0)
```

#### Standard close
- shareability: `shareability: 0 hits` for each of `--task T5`, `--task T1`
  and `--task T8`, run after the commits.
- `git diff 74d23f1 -- SPEC.md spec-process.d2 spec-process.svg
  spec-process.png` is empty (0 lines).
- Each commit holds only its one file, with its trailers, by pathspec.
  `merge-base --is-ancestor origin/change/build-swe-pod HEAD` exited 0, so
  I skipped the rebase. The push went `a9296c5..83eaef9`.
- No added line is over 80 characters and none has trailing whitespace.

#### Unit suite
swe-pod has no unit suite (none present).

### Concerns
- The round 2 concern (no brief or evidence field for a per-check time) now
  decides the common case: a unit suite or quality check usually has no
  known time, so the lead does not ask, and only the running agent's fence
  guards a long one. That is the ruling's intent. A later change could add
  a per-check time to evidence records, so that "the record of its last
  run" can supply one.

### Test suggestions
- T1.TS7 (above) still applies. The expected outcome for a check with no
  known time is now: no ask, and the run stays under the running agent's
  fence. No new suggestion.
