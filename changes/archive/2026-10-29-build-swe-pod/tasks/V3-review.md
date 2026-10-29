---
task: T5, T1
diff: swe-pod 4d5bfc7..9c4d8bc
verdict: fix
---

# V3 review: verify fix (heavy rule), fix mode

## Spec compliance

Finding under fix: in T1.TS4, a lead about to dispatch a verify task holding
a check whose recorded expected run time is exactly 60 s asked the human
first, because it counted the task's total time (about 65 s) and the check's
300 s cap. The diff is two commits. be81f02 (Task: T5) touches only
agents/swe-lead.md. 9c4d8bc (Task: T1) touches only PROCESS.md. Each carries
the Change, Task and Co-Authored-By trailers.

- Closed, in both files. swe-pod/agents/swe-lead.md:395-397 and
  swe-pod/PROCESS.md:832-834 now judge heaviness per check, from that
  check's own recorded expected run time alone: over 60 s is heavy, 60 s or
  less is not, "whatever its cap, its label or the task's total time". This
  rules out the cap reading and the task-total reading that the round 4 lead
  gave. It also rules out the label reading that T1.TS4 step 1 exercises (61 s
  labelled `heavy: false`). Under this text, exactly 60 s is not heavy.
- The ask names the heavy checks only: "of each heavy check, and of no other
  check", one `heavy:` line "for each" (swe-lead.md:398-402,
  PROCESS.md:835-839). A task with no heavy check needs no ask. The one-line
  ledger form at swe-lead.md:486 still fits.
- The two texts agree. The rule sentence and the ask clause are word for
  word the same in both. Two differences predate the fix and are not about
  heaviness: only the lead's section says "wait for the human's word", and
  only the lead's section has the no-human-present sentence.
- Agreement with the spec: R13 ("A check expected to take over 60 s") and
  §5.4 ("Each test records its expected run time; over 60 s it is marked
  heavy") are per check and strictly over 60 s, and both texts match that.
  R13.S1's ask (command, caps, expected wall time before dispatch, human
  present) is kept and is now limited to the heavy checks.
- Rule left to review, "cite no requirement or decision id": holds. Both
  changed sections contain 0 ids matching `\b(O?D|R)[0-9]+(\.S[0-9]+)?\b`.
  I re-ran the report's two fixed-string checks at 9c4d8bc, and both texts
  pass both.
- Missing: the measure is now a check's recorded expected run time "alone",
  but only tests record one (PROCESS.md:441, agents/swe-test.md:121). A
  verify task always also runs each affected repo's unit suite and each
  declared quality check (PROCESS.md:118 and 531, agents/swe-test.md:140-142),
  and these record no expected run time. R13 covers every check expected to
  take over 60 s. The old wording, "expected to take over 60 s", let the lead
  judge such a check from any estimate. The new wording does not cover it,
  and with "A task with no heavy check needs no such ask" a lead can read a
  long unit suite as not heavy. It would then dispatch without the R13.S1
  ask in a live session. The builder's report raises this as a concern and
  as T1.TS7 but adds no rule. Both files need one sentence on a check with
  no recorded expected run time: for example, the lead takes its expected
  run time from the brief or the record of its last run, and asks when there
  is none. Important, one finding per file.
- Extra: none. Misread: none.

Other places that state heaviness:
- Same measure: swe-pod/PROCESS.md:441-442 (§6) and
  swe-pod/agents/swe-test.md:121 set the label from the same per-test
  expected run time.
- No measure stated: swe-pod/agents/swe-lead.md:70,
  swe-pod/agents/swe-test.md:149 and swe-pod/skills/swe-pod/SKILL.md:337-338
  say "heavy check" and add nothing that conflicts.
- Tester's own fence: swe-pod/agents/swe-test.md:80 forbids running "a check
  expected to take over 60 s" outside the fence. This is broader than the
  lead's rule, and safe.
- Not in the review scope: agents/swe-build.md:60, agents/swe-review.md:57
  and INSTALL.md:135-136 use the same threshold to bind runs to the fences.
  They describe no ask, so they invite no task-total reading.
- Another way: swe-pod/README.md:152-155 (T8's file) still says only "A
  check expected to take over 60 s is heavy" before the ask, which allows the
  old reading. Minor, as briefed.

## Quality

- The change is small and contained. Each file is in its own commit by
  pathspec. `git diff --check` is clean. Added lines are at most 78
  characters, apart from the unchanged ledger-form code span (80 and
  82 characters with indent).
- The report's done-when checks only test the wording: they look for fixed
  strings. The behavior they stand for is tested by the project-level test
  test_T1_TS4_heavy_from_recorded_run_time (step 2 must dispatch the 60 s
  check), which runs again at verify. swe-pod has no unit suite.
- The builder's suggestions T5.TS9 (the label disagrees with the run time,
  and the task total is over 60 s) and T1.TS7 (a check with no recorded run
  time) cover the new clause and the gap above. T1.TS7 has no rule to test
  against until the Important findings are fixed.
- Shareability check: `shareability: 0 hits` for T5 and for T1.

## Findings

- Important swe-pod/agents/swe-lead.md:396 Heaviness is judged "from that check's own recorded expected run time alone", but only tests record one; a verify task's unit suites and declared quality checks have none, so the rule does not cover them and, with "A task with no heavy check needs no such ask", a long one can be dispatched in a live session without the R13.S1 ask; say how such a check is judged (for example, from its brief's or last run's time, and ask when none is known)
- Important swe-pod/PROCESS.md:833 Same gap in the fences bullet: "recorded expected run time alone" leaves each unit suite and declared quality check in a verify task, which records no expected run time, with no heaviness rule, though R13 covers every check expected to take over 60 s; add the same sentence as in the lead's section
- Minor swe-pod/README.md:153 The fences bullet still says only "A check expected to take over 60 s is heavy" before the ask, which allows the task-total and cap readings that PROCESS.md §11 and the lead's role now exclude; use the per-check words
