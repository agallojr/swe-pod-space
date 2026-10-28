---
task: T5, T1, T8
diff: swe-pod 9c4d8bc..a9296c5
verdict: fix
---

# V3 review, round 2: verify fix (heavy rule), fix mode

## Spec compliance

This round fixes the two Important findings and the one Minor finding in V3-review.md. The fix diff has three commits, which I found on `change/build-swe-pod` by their trailers:

- b8a796c (Task: T5) touches only agents/swe-lead.md.
- 9884cd1 (Task: T1) touches only PROCESS.md.
- a9296c5 (Task: T8) touches only README.md.

In the plan, each file is in the `touches:` list of the task that owns it. Each commit carries the Change, Task and Co-Authored-By trailers.

- Important swe-pod/agents/swe-lead.md:396: closed. Lines 397-400 add this sentence: "A check that records no expected run time, such as a unit suite or a declared quality check, takes it from its brief or from the record of its last run; with neither, treat it as heavy and ask." Unit suites and declared quality checks now have a rule. Line 405, "A task with no heavy check needs no such ask", can no longer let a long one through without the ask.
- Important swe-pod/PROCESS.md:833: closed. Lines 834-837 carry the same sentence, word for word, after the same per-check rule.
- Minor swe-pod/README.md:153: closed. Lines 153-160 now hold:
  - the per-check rule, in the reader's voice ("Heaviness is judged per check, ...");
  - the same no-recorded-time sentence, ending "the lead treats it as heavy and asks";
  - the ask, "of each heavy check, and of no other check".

  The old wording, "A check expected to take over 60 s is heavy", is gone.
- The three texts agree. The rule, the no-recorded-time sentence and the ask clause are word for word the same in the lead's section and in PROCESS.md. README says the same things in the reader's voice. It leaves out the ledger form and "A task with no heavy check needs no such ask", which is right for an overview.
- Rule left to review, "cite no requirement or decision id": holds. These three places contain 0 ids matching `\b(O?D|R)[0-9]+(\.S[0-9]+)?\b`:
  - the PROCESS.md fences bullet, lines 830-842;
  - the lead's `### Heavy checks` section;
  - the README fences bullet.

  I re-ran the report's fixed-string checks at a9296c5: the rule, the no-recorded-time sentence, the ask, and the old README wording being gone. All four pass.
- Ruling on the builder's concern that no brief format has an expected-run-time field: the concern holds, and it goes further than the report says.
  - templates/records/brief.md and templates/records/test-brief.md have no such field.
  - The plan's verify entry (templates/records/plan.md §6) gives no time. Neither does a spec Quality entry.
  - An evidence record's `wall_time_s` covers the whole run. It bounds a single check only when the whole run took 60 s or less.
  - "From its brief" sends the lead to a brief it writes itself.

  Closing the findings under fix does not need a template field, and this round should not add one. But it follows that before a change's first verify, the "with neither" branch is the usual path for every unit suite and quality check. That leads to the new problem below.
- New, from this round: "with neither, treat it as heavy and ask" makes every check with no known time heavy by default. It causes four problems:
  - It asks where the spec does not. R13 fences a check "expected to take over 60 s". Spec §9 says to stop and ask only for, among other things, "a run past the mesh fence". A check with no known time is not expected to run past the fence.
  - It conflicts with the project-level test test_T1_TS4_heavy_from_recorded_run_time. In step 2, add-farewell's verify runs alpha's and beta's unit suites. The plan's T7 steps call for them, and the ledger shows 3 and 2 unit tests. No brief, report, ledger line or evidence record gives either suite a time. The test fails if that verify "is held for the human's go as if it were heavy". A lead that follows the new text holds it. A lead that followed the round 1 text, which judges from the recorded time alone, did not.
  - The branch cannot be carried out as written. The ask and the `heavy:` line (`expected <s> s`) need an expected wall time in s. swe-pod/agents/swe-lead.md:70-71 forbids dispatching a heavy check before the human has its expected wall time, and no one has it for such a check.
  - "And ask" is not limited to a session with the human present. The lead's section leaves a session with no human present to the budget policy (lines 407-408).

  Severity: Important in the lead's section and in PROCESS.md, Minor in README. Whatever the lead decides, the tester's own fence still binds (swe-pod/agents/swe-test.md:80, "a check expected to take over 60 s").

  R13 and §5.4 do not settle a check with no known time, so the lead rules. Two ways out:
  - narrow the default: judge from any known time or bound, and treat the check as heavy only when one puts it over 60 s;
  - or keep the default, and give T1.TS4's unit suites a recorded time.

  Either way, the texts must say what the ask gives when the expected time is unknown.
- Extra: only the default above. Missing: nothing left from the findings under fix. Misread: none.

## Quality

- The change is small and contained: 7 lines added and 4 removed in swe-lead.md, 7 added and 4 removed in PROCESS.md, 8 added and 3 removed in README.md. Each commit holds one file. `git diff --check` is clean. Added lines are at most 77 characters.
- The report's done-when checks test wording only: they look for fixed strings. The behavior is tested by the project-level test T1.TS4, which runs again at verify (see above). T1.TS7 would also test it, but it is still a builder suggestion, not a written test.
- swe-pod has no unit suite.
- Shareability check: `shareability: 0 hits` for T5, for T1 and for T8.

## Findings

- Important swe-pod/agents/swe-lead.md:400 "with neither, treat it as heavy and ask" makes every check with no known time heavy, but no brief, plan entry, Quality entry, report or evidence field holds a per-check time for a unit suite or quality check (an evidence record's wall_time_s covers the whole run), so before a change's first verify every unit suite is asked about in a live session; this goes past R13 ("expected to take over 60 s") and spec §9 (stop and ask only for a run past the mesh fence), and a lead following it holds add-farewell's verify in test_T1_TS4_heavy_from_recorded_run_time step 2 (alpha's and beta's unit suites, no time recorded anywhere), so that test fails; the ask and the heavy: line also need an expected wall time in s that no one has (and line 70 forbids dispatch without it), and "and ask" is not limited to a session with the human present; the lead should rule: narrow the default (judge from any known time or bound, heavy only when one puts it over 60 s), or keep it and give T1.TS4's unit suites a recorded time, and either way say what the ask gives when the time is unknown
- Important swe-pod/PROCESS.md:837 The fences bullet has the same default ("with neither, treat it as heavy and ask"), with the same overreach past R13 and §9, the same conflict with T1.TS4 step 2, and no value for "the expected wall time in s" or `expected <s> s`; it must change with the lead's section so the two texts agree
- Minor swe-pod/README.md:158 "with neither, the lead treats it as heavy and asks" carries the same default; bring it in line with whatever the lead rules for the lead's section and PROCESS.md
