---
task: T5, T1, T8
diff: swe-pod a9296c5..83eaef9
verdict: pass
---

# V3 review, round 3: verify fix (heavy rule), fix mode

## Spec compliance

This round fixes the two Important findings and the one Minor finding in V3-review-r1.md. I found the fix diff's three commits on `change/build-swe-pod` by their trailers. The branch head is 83eaef9.

- c1744fe (Task: T5) touches only agents/swe-lead.md.
- ec77436 (Task: T1) touches only PROCESS.md.
- a9296c5..83eaef9's last commit, 83eaef9 (Task: T8), touches only README.md.

In the plan, each of these files is in the `touches:` list of the task that owns it: T5 agents/swe-lead.md, T1 PROCESS.md, T8 README.md. Each commit carries the Change, Task and Co-Authored-By trailers.

The lead's ruling of 2026-10-28T11:26Z says three things:
- a check that records no expected run time takes one from its brief or from its last run's record when either gives one;
- it is heavy only when that time is over 60 s;
- with no known time it is not heavy for the lead's ask, and the running agent's own fence still binds the run.

- Important swe-pod/agents/swe-lead.md:400: closed. "With neither, treat it as heavy and ask" is gone. Lines 397-402 now read: "A check that records no expected run time, such as a unit suite or a declared quality check, takes it from its brief or from the record of its last run when either gives one, and is heavy only when that time is over 60 s. With no known time, it is not heavy for the lead's ask, and the running agent's own fence still binds the run." This is the ruling, clause by clause.
  - The parts of the old finding are settled. A check with no known time is not heavy, so there is no ask, no `heavy:` line and no unknown `expected <s> s` to give.
  - Line 70 ("Dispatch a heavy check before the human has its command, caps and expected wall time") no longer applies to such a check.
  - The rule no longer asks where R13 and spec §9 do not: a check with no known time is not expected to take over 60 s or to run past the mesh fence.
- Important swe-pod/PROCESS.md:837: closed. Lines 835-839 of the fences bullet carry the same two sentences word for word, after the same per-check rule. The old default is gone.
- Minor swe-pod/README.md:158: closed. Lines 156-160 carry the same first sentence word for word. The second is in the reader's voice: "With no known time, the lead does not ask you about it, and the running agent's own fence still binds the run." The old default is gone.
- The three texts agree. I compared them with whitespace collapsed, at 83eaef9:
  - the no-recorded-time sentence is in all three;
  - the not-heavy sentence is in the lead's section and in PROCESS.md;
  - README has its reader's-voice form of that sentence;
  - "of each heavy check, and of no other check" is in all three;
  - "A task with no heavy check needs no such ask" is in the lead's section and in PROCESS.md;
  - "with neither" is in none of them.
- The "own fence" clause has something to rest on. The fences bullet's first sentences bind every pod agent to the mesh fences. Each agent that runs checks has its own fence:
  - swe-pod/agents/swe-test.md:80-81;
  - swe-pod/agents/swe-build.md:59-60;
  - swe-pod/agents/swe-review.md:57-58.

  The ruling accepts a long, unmeasured check running without the ask as its cost if wrong, so that is not a finding.
- PROCESS.md cites no requirement or decision id. The fences bullet, lines 830-844, has 0 matches of `\b(O?D|R)[0-9]+(\.S[0-9]+)?\b`, and the fix diff's added lines have 0. The file has 10 matches in all, the same 10 as at a9296c5. All of them are the worked example's own ids (R1, R1.S1, R1.S2 of the example spec, in the example plan, the evidence and the ledger lines), not this change's ids.
- test_T1_TS4_heavy_from_recorded_run_time agrees with the rule as now written:
  - Step 1: add-greeting's verify holds `test_R2_S1_startup_line`, which records `expected_s: 61`. That check is heavy, so the lead asks first and names its command, its cap of 300 s and its expected time of 61 s (Then 1-4). Under "of no other check", the unit suites are left out of the ask, and the Then needs nothing about them.
  - Step 2: add-farewell's verify holds the same test at `expected_s: 60`, which is not heavy. Its unit suites either have no known time or a time of 60 s or less, so they are not heavy either way. The verify is dispatched (Then 5), and it is not "held for the human's go as if it were heavy" (Fails if).
  - The round 2 text failed this test, and this text passes it.
- Extra: none. Missing: none of the findings under fix is left. Misread: none.

## Quality

- The change is small. It adds 7 lines and removes 5 in swe-lead.md, adds 3 and removes 1 in PROCESS.md, and adds 5 and removes 3 in README.md. Each commit holds one file. `git diff --check a9296c5 83eaef9` is clean. The longest added line is 75 characters.
- I re-ran the report's fixed-string done-when checks at 83eaef9: the narrowed default is in all three files, the old default is gone, the ask names heavy checks only, and PROCESS.md has 0 ids. All pass, which matches the report's green output. These checks test wording only. The behavior is tested by project-level test T1.TS4 at verify, and the rule now agrees with it (see above). T1.TS7 would also test it, but it is still a builder suggestion.
- swe-pod has no unit suite.
- Shareability check: `shareability: 0 hits` for T5, for T1 and for T8.

## Findings

none
