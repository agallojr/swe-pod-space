# T17 report

## Status

DONE_WITH_CONCERNS

## What I did

Wrote 18 scenario tests, one for each scenario from R12.S1 to R23.S2, from
the spec, the interface contract, the global constraints and the test map of
the brief. They follow T15's runner protocol (`tests/README.md`) and run on
its fixtures, with a per-test overlay where the scenario needs records. Each
test's check script was exercised outside the space on synthetic agent
output: a passing case (all 68 checks pass) and a failing case for each test
(each fails at the check it targets). The R16.S1 machine-value check was also
shown to catch a planted agent id and home path and to print only
`<source>:<line> <kind>`. All 18 then ran at the base commit set (space
c814837, swe-pod 8fc5294, agent-mesh 8ee5364) with no `--config` and no
`--gate`, so no agent could start; all 18 fail for the stated reason.

| Test | Mode | Expected | Cap | Heavy |
|---|---|---|---|---|
| test_R12_S1_missing_quality_check | agent (skill) | 120 s | 600 s | yes |
| test_R12_S2_no_checks_declared | agent (test, verify) | 240 s | 900 s | yes |
| test_R13_S1_heavy_check_asks_first | agent (lead) | 150 s | 600 s | yes |
| test_R14_S1_merge_order_and_pins | desk (lead) | 240 s | 900 s | yes |
| test_R14_S2_rulings_in_final_report | agent (lead) | 240 s | 900 s | yes |
| test_R15_S1_reverify_after_other_change | desk (lead) | 180 s | 900 s | yes |
| test_R16_S1_dispatch_line_names_no_machine | inspect | 2 s | 60 s | no |
| test_R17_S1_remote_test_results_filed | desk (lead, with a fixture outbox) | 240 s | 900 s | yes |
| test_R17_S2_single_seat_librarian | agent (space-librarian) | 240 s | 600 s | yes |
| test_R18_S1_fresh_agent_where_are_we | agent (fresh, with the skill) | 120 s | 600 s | yes |
| test_R18_S2_handoff_reverify_first | agent (lead) | 360 s | 1200 s | yes |
| test_R19_S1_one_question_per_message | agent (spec) | 90 s | 600 s | yes |
| test_R20_S1_status_rebuild_matches | agent (skill, then skill) | 240 s | 1200 s | yes |
| test_R21_S1_suggestion_with_computed_value | agent (lead) | 180 s | 600 s | yes |
| test_R21_S2_every_suggestion_has_outcome | agent (lead) | 240 s | 900 s | yes |
| test_R22_S1_space_never_branches | desk (lead) | 240 s | 900 s | yes |
| test_R23_S1_parallel_builders_one_branch | desk (lead, build) | 480 s | 1800 s | yes |
| test_R23_S2_unnamed_repo_no_branch | desk (lead, then lead) | 360 s | 1200 s | yes |

## Files

- changes/build-swe-pod/tests/test_R12_S1_missing_quality_check.md
- changes/build-swe-pod/tests/test_R12_S2_no_checks_declared.md
- changes/build-swe-pod/tests/test_R13_S1_heavy_check_asks_first.md
- changes/build-swe-pod/tests/test_R14_S1_merge_order_and_pins.md
- changes/build-swe-pod/tests/test_R14_S2_rulings_in_final_report.md
- changes/build-swe-pod/tests/test_R15_S1_reverify_after_other_change.md
- changes/build-swe-pod/tests/test_R16_S1_dispatch_line_names_no_machine.md
- changes/build-swe-pod/tests/test_R17_S1_remote_test_results_filed.md
- changes/build-swe-pod/tests/test_R17_S2_single_seat_librarian.md
- changes/build-swe-pod/tests/test_R18_S1_fresh_agent_where_are_we.md
- changes/build-swe-pod/tests/test_R18_S2_handoff_reverify_first.md
- changes/build-swe-pod/tests/test_R19_S1_one_question_per_message.md
- changes/build-swe-pod/tests/test_R20_S1_status_rebuild_matches.md
- changes/build-swe-pod/tests/test_R21_S1_suggestion_with_computed_value.md
- changes/build-swe-pod/tests/test_R21_S2_every_suggestion_has_outcome.md
- changes/build-swe-pod/tests/test_R22_S1_space_never_branches.md
- changes/build-swe-pod/tests/test_R23_S1_parallel_builders_one_branch.md
- changes/build-swe-pod/tests/test_R23_S2_unnamed_repo_no_branch.md
- changes/build-swe-pod/tests/fixtures/overlays/<test name>/ for 16 of
  them (all but R16.S1 and R19.S1), 158 files in all: demo records of
  add-greeting (plans, ledgers, briefs, reports, reviews, evidence,
  project-level tests), add-farewell (open, or archived for R15.S1), a
  `STATUS.md` (R18.S1), a handoff (R18.S2) and a clean note (R17.S2).
- changes/build-swe-pod/tasks/T17-report.md (this report)

## Test output

T17 at base, each line as the runner gave it (2026-10-28T00:43Z):

```
test_R12_S1_missing_quality_check fail (deliverable absent: swe-pod 8fc5294 skills/swe-pod)
test_R12_S2_no_checks_declared fail (deliverable absent: swe-pod 8fc5294 agents/swe-test.md)
test_R13_S1_heavy_check_asks_first fail (deliverable absent: swe-pod 8fc5294 agents)
test_R14_S1_merge_order_and_pins fail (deliverable absent: swe-pod 8fc5294 agents)
test_R14_S2_rulings_in_final_report fail (deliverable absent: swe-pod 8fc5294 agents)
test_R15_S1_reverify_after_other_change fail (deliverable absent: swe-pod 8fc5294 agents)
test_R16_S1_dispatch_line_names_no_machine fail (check R16.S1.1: swe-pod 8fc5294: templates/records/ledger.md absent)
test_R17_S1_remote_test_results_filed fail (deliverable absent: swe-pod 8fc5294 agents)
test_R17_S2_single_seat_librarian fail (deliverable absent: agent-mesh 8ee5364 skills/space-librarian)
test_R18_S1_fresh_agent_where_are_we fail (deliverable absent: swe-pod 8fc5294 skills/swe-pod)
test_R18_S2_handoff_reverify_first fail (deliverable absent: swe-pod 8fc5294 agents)
test_R19_S1_one_question_per_message fail (deliverable absent: swe-pod 8fc5294 agents/swe-spec.md)
test_R20_S1_status_rebuild_matches fail (deliverable absent: swe-pod 8fc5294 skills/swe-pod)
test_R21_S1_suggestion_with_computed_value fail (deliverable absent: swe-pod 8fc5294 agents)
test_R21_S2_every_suggestion_has_outcome fail (deliverable absent: swe-pod 8fc5294 agents)
test_R22_S1_space_never_branches fail (deliverable absent: swe-pod 8fc5294 agents)
test_R23_S1_parallel_builders_one_branch fail (deliverable absent: swe-pod 8fc5294 agents)
test_R23_S2_unnamed_repo_no_branch fail (deliverable absent: swe-pod 8fc5294 agents)
```

No test was left unrun at base, and none started an agent. The 17 agent and
desk tests failed on an absent deliverable before any agent step. R16.S1 is
an inspect test and ran its check. A repeat run gave the same 18 lines.

## Concerns

1. **Verify budget.** 17 of the 18 tests are heavy. Their expected times add
   up to 3962 s (about 66 min) of serial wall time. The caps add up to
   15360 s (about 4.3 h), which is over the 2 h point at which the budget
   policy says to ask. Each heavy test needs the operator's go and
   `--allow-heavy`. R18.S2 and R23.S1 start real subagents: a verify run,
   and two builders.
2. **R16.S1 runs last**, with the same `--scratch` as the other tests. It
   reads their run dirs' ledgers, and it fails check 2 if it finds no
   dispatch line that an agent wrote.
3. **Two modes differ from the test map's Mode column.** The roles are the
   same. R20.S1 runs `agent (skill, then skill)`: a second, independent
   regeneration is compared with the first, since the STATUS.md format
   beyond contract §2.6 belongs to the deliverable. R23.S2 runs `desk (lead,
   then lead)`: the go, then the verify brief.
4. **Scaffolding in prompts**, beyond the human's words. The lead may want
   to rule on each:
   - R14.S1: "take each merge's result to be the branch head", because desk
     runs have no merge shas.
   - R13.S1 and R18.S2: "I'm here in this session" and "dispatch one task,
     then stop".
   - R21.S1: "Start no agent".
   - R23.S1: "Pass this run's desk rule on to each builder", because the
     runner's desk preamble reaches only the session.
   - R20.S1 step 2: write to `x-rebuild/STATUS.md` and do not open the
     committed one.
   - R23.S2 step 2: the T7 brief "as it will stand once T1 to T6 are done".
5. **Strict checks** that the lead should know about:
   - R20.S1 needs two independent agents to produce STATUS.md files that
     match line for line. Contract §2.6 asks for this.
   - R18.S1 needs the agent to have read `AGENTS.md`, as R18.S1's THEN
     says.
   - R19.S1 counts `?` outside code and quotes, so a message offering two
     alternative questions fails.
   - The desk checks parse printed git commands. They place a command in a
     repo by the checkout path, by `-C`, or by a preceding `cd`.
6. **Runner suggestions for T15**, not edits:
   - A shared overlay, or an `overlay:` front-matter key. Twelve overlays
     repeat much of the same add-greeting record set.
   - A way to give the desk rule to subagents.
7. **Not mine:** `fixtures/overlays/test_R24_S1_two_shards_verified/`
   appeared in the tests folder during this task. It has no test file, and
   the spec has no R24. I listed its files and read none of them.
8. **Allowed case, kept on purpose:** the clean record of R17.S2 holds an
   example shaped like a mesh task id that no bus holds. It is one of the
   contract §2.7 allowed cases and mirrors T15's I8 overlay. My
   shareability scan of all 175 files found no other hit: no home path,
   handle, fixture node id, hostname or credential name. The negative
   content is built at run time.

## Test suggestions

None.
