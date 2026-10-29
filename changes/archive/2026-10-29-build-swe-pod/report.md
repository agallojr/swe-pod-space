# build-swe-pod: final report

- change: build-swe-pod
- spec: changes/build-swe-pod/spec.md
- latest evidence: ev-20261029T0356Z-T19c (T19c round 2, 11 tests); ev-20261029T0211Z-T19c (T19c, 9 tests)

## Scenarios

37 scenarios (R1.S1 to R24.S1 and R24.S2) and 8 inspection checks (I1 to I8). Each result comes from the latest record that ran the test: T19c round 2 (ev-20261029T0356Z-T19c) for its 11 tests, then T19c (ev-20261029T0211Z-T19c) for its 9, then round 4 (ev-20261028T0947Z-T19a, ev-20261028T0950Z-T19b) for the rest, carried under plan section 3 OD8. R19.S1 passed in round 6 at the T19c branch heads and tests; round 6 filed no record, and the 2026-10-29T01:55Z ruling records the pass (its round 4 result was fail, a test-side wording that T18 then fixed).

| Scenario | Test | Result | Evidence id |
|---|---|---|---|
| R1.S1 | test_R1_S1_go_without_approval | pass | ev-20261028T0950Z-T19b |
| R1.S2 | test_R1_S2_edit_after_approval | pass | ev-20261028T0950Z-T19b |
| R2.S1 | test_R2_S1_first_change_no_specs | pass | ev-20261028T0950Z-T19b |
| R2.S2 | test_R2_S2_supersedes_and_test_update | pass | ev-20261028T0947Z-T19a |
| R3.S1 | test_R3_S1_requirement_without_scenario | pass | ev-20261028T0947Z-T19a |
| R4.S1 | test_R4_S1_no_process_files_in_code_repo | pass | ev-20261028T0950Z-T19b |
| R5.S1 | test_R5_S1_tests_in_change_folder | pass | ev-20261028T0947Z-T19a |
| R5.S2 | test_R5_S2_tests_promoted_at_integrate | pass | ev-20261029T0356Z-T19c |
| R6.S1 | test_R6_S1_complete_test_map | pass | ev-20261028T0947Z-T19a |
| R6.S2 | test_R6_S2_shared_files_ordered | pass | ev-20261028T0950Z-T19b |
| R7.S1 | test_R7_S1_mesh_dispatch | pass | ev-20261028T0947Z-T19a |
| R7.S2 | test_R7_S2_local_dispatch | pass | ev-20261028T0947Z-T19a |
| R8.S1 | test_R8_S1_test_result_in_lane | pass | ev-20261028T0950Z-T19b |
| R8.S2 | test_R8_S2_builder_disputes_test | pass | ev-20261028T0950Z-T19b |
| R9.S1 | test_R9_S1_test_brief_contents | pass | ev-20261028T0947Z-T19a |
| R10.S1 | test_R10_S1_test_passes_at_base | pass | ev-20261028T0950Z-T19b |
| R11.S1 | test_R11_S1_evidence_fields | pass | ev-20261028T0947Z-T19a |
| R12.S1 | test_R12_S1_missing_quality_check | pass | ev-20261028T0950Z-T19b |
| R12.S2 | test_R12_S2_no_checks_declared | pass | ev-20261028T0950Z-T19b |
| R13.S1 | test_R13_S1_heavy_check_asks_first | pass | ev-20261029T0211Z-T19c |
| R14.S1 | test_R14_S1_merge_order_and_pins | fail on the check, counts as pass by the 2026-10-29T11:13Z ruling | ev-20261029T0356Z-T19c |
| R14.S2 | test_R14_S2_rulings_in_final_report | pass | ev-20261028T0950Z-T19b |
| R15.S1 | test_R15_S1_reverify_after_other_change | pass | ev-20261028T0947Z-T19a |
| R16.S1 | test_R16_S1_dispatch_line_names_no_machine | pass | ev-20261029T0356Z-T19c |
| R17.S1 | test_R17_S1_remote_test_results_filed | pass | ev-20261028T0947Z-T19a |
| R17.S2 | test_R17_S2_single_seat_librarian | fail on the check, counts as pass by the 2026-10-29T11:13Z ruling | ev-20261029T0356Z-T19c |
| R18.S1 | test_R18_S1_fresh_agent_where_are_we | pass | ev-20261028T0947Z-T19a |
| R18.S2 | test_R18_S2_handoff_reverify_first | pass | ev-20261028T0950Z-T19b |
| R19.S1 | test_R19_S1_one_question_per_message | pass (round 6, carried by ruling) | 2026-10-29T01:55Z ruling |
| R20.S1 | test_R20_S1_status_rebuild_matches | pass | ev-20261028T0947Z-T19a |
| R21.S1 | test_R21_S1_suggestion_with_computed_value | pass | ev-20261028T0950Z-T19b |
| R21.S2 | test_R21_S2_every_suggestion_has_outcome | pass | ev-20261028T0950Z-T19b |
| R22.S1 | test_R22_S1_space_never_branches | pass | ev-20261028T0947Z-T19a |
| R23.S1 | test_R23_S1_parallel_builders_one_branch | pass | ev-20261028T0950Z-T19b |
| R23.S2 | test_R23_S2_unnamed_repo_no_branch | pass | ev-20261029T0211Z-T19c |
| R24.S1 | test_R24_S1_two_shards_verified | pass | ev-20261028T0950Z-T19b |
| R24.S2 | test_R24_S2_stale_shard_not_verified | pass | ev-20261028T0947Z-T19a |
| I1 | test_I1_process_md | pass | ev-20261029T0211Z-T19c |
| I2 | test_I2_role_definitions | pass | ev-20261028T0947Z-T19a |
| I3 | test_I3_d3_templates | pass | ev-20261028T0950Z-T19b |
| I4 | test_I4_swe_pod_skill | pass | ev-20261028T0947Z-T19a |
| I5 | test_I5_templates_placeholders_only | pass | ev-20261028T0950Z-T19b |
| I6 | test_I6_mesh_post_project_flag | pass | ev-20261028T0947Z-T19a |
| I7 | test_I7_agent_mesh_documents | pass | ev-20261029T0356Z-T19c |
| I8 | test_I8_space_librarian_checks | pass | ev-20261029T0356Z-T19c |

Round 2 ran these 11 tests: test_R14_S1_merge_order_and_pins, test_R5_S2_tests_promoted_at_integrate, test_I8_space_librarian_checks, test_R17_S2_single_seat_librarian, test_T10_TS1_reference_rule, test_T10_TS6_commit_stage_order, test_T10_TS8_joined_and_registry_values, test_T12_TS1_unmounted_project_blocked, test_T12_TS3_load_never_changes_bus, test_I7_agent_mesh_documents and test_R16_S1_dispatch_line_names_no_machine. 8 pass and 3 fail on the check (R14.S1, R17.S2 and T10.TS6), which count as passing by the 2026-10-29T11:13Z ruling; all in ev-20261029T0356Z-T19c.

### Desk-verified scenarios and live observations

7 scenarios desk-verified, live confirmation at pilot; R7.S1 and R17.S1 verified live at T19b

The seven desk-verified scenarios, which the pilot must run live, are:

- R4.S1 (test_R4_S1_no_process_files_in_code_repo): pass in ev-20261028T0950Z-T19b.
- R5.S2 (test_R5_S2_tests_promoted_at_integrate): pass in ev-20261029T0356Z-T19c.
- R14.S1 (test_R14_S1_merge_order_and_pins): fail on the check, counts as pass by the 2026-10-29T11:13Z ruling in ev-20261029T0356Z-T19c.
- R15.S1 (test_R15_S1_reverify_after_other_change): pass in ev-20261028T0947Z-T19a.
- R22.S1 (test_R22_S1_space_never_branches): pass in ev-20261028T0947Z-T19a.
- R23.S1 (test_R23_S1_parallel_builders_one_branch): pass in ev-20261028T0950Z-T19b.
- R23.S2 (test_R23_S2_unnamed_repo_no_branch): pass in ev-20261029T0211Z-T19c.

The commit step of R17.S2 (test_R17_S2_single_seat_librarian) is also desk-verified and left to the pilot; its result is fail on the check, counts as pass by the 2026-10-29T11:13Z ruling in ev-20261029T0356Z-T19c.

R7.S1 and R17.S1 are desk-verified against the deliverables, and were also observed live at T19b's own dispatch and filings, on the pre-change remote product (OD1, OD6). Both stand on T19b's rounds 3 to 5 and are not re-judged (OD8):

- R7.S1, the mesh dispatch: the lead's dispatch line and task request for each round met the scenario's Then items (ledger 2026-10-28T09:08Z, round 3: items 1 to 7 pass; 2026-10-28T10:55Z, round 4: items 1 to 7 pass; 2026-10-28T12:26Z, round 5: 7 of 7). Round 1's item 4 failure was a lead error, fixed at the re-post (2026-10-28T05:49Z). Test result: pass in ev-20261028T0947Z-T19a.
- R17.S1, remote results filed: T19b's returned files were filed byte for byte, with sha256 matching the result's `files:` list, in round 3 (ev-20261028T0755Z-T19b, 66 of 66), round 4 (ev-20261028T0950Z-T19b, 64 of 64) and round 5 (ev-20261028T1137Z-T19b, 85 of 85); the whole-change review checked these against the scenario's Then items (tasks/T35-review.md, "R17.S1 live"). Test result: pass in ev-20261028T0947Z-T19a.

## Rulings

57 Ruling: lines in the ledger, listed here in ledger order, each verbatim with its continuation lines joined.

- 2026-10-28T00:05Z Ruling: the node's managed settings (gateway login, provider environment) are accepted under test isolation; they add no instruction file and loosen no fence; cost if wrong: a scenario result reflects node policy, caught at T20 on another node
- 2026-10-28T00:05Z Ruling: the test agent may read the space's memory-spaces note for the 11 manifest keys (I3); it is a relied-on spec input, not a plan, brief, report, review or diff; cost if wrong: none to blindness, the keys are not implementation
- 2026-10-28T00:05Z Ruling: T16 and T17 briefs state that no instruction file reaches an agent under test, so a scenario needing AGENTS.md has the agent read it with a tool (R18.S1); cost if wrong: one test rewrite
- 2026-10-28T00:20Z Ruling: wave 2 agents read the reviewed role definitions agents/swe-build.md and agents/swe-review.md at swe-pod 8770c1a first, as plan section 2.3 directs before install; cost if wrong: a definition gap shows up as a review finding
- 2026-10-28T00:43Z Ruling: test_R4_S1 runs desk as two steps, build then lead, so the lead's merge is exercised; cost if wrong: one test rewrite
- 2026-10-28T00:43Z Ruling: the scenario shortcuts T16 names in each test's Given are accepted (approval in the step prompt; brief without dispatch; a pre-recorded done task; a single swe.test holder in the demo bus); cost if wrong: a scenario is exercised less directly
- 2026-10-28T00:43Z Ruling: test_R6_S2 reporting GIVEN not reached is judged by the lead against the plan the agent wrote; cost if wrong: a false fail
- 2026-10-28T00:43Z Ruling: T15's runner adds the per-run code repos as an extra directory, with a smoke case; returned to the test role as a T15 follow-up; cost if wrong: repo steps prompt and are denied
- 2026-10-28T00:46Z Ruling: test_R20_S1 (skill, then skill) and test_R23_S2 (lead, then lead) run as two steps; roles unchanged; cost if wrong: none
- 2026-10-28T00:46Z Ruling: the test-scaffolding words T17 lists in its prompts are accepted; none states the expected behavior; cost if wrong: a scenario is exercised less directly
- 2026-10-28T00:46Z Ruling: the strict checks of test_R18_S1, test_R19_S1 and test_R20_S1 stand, as those scenarios read; cost if wrong: false fails to judge
- 2026-10-28T00:46Z Ruling: shared overlays and passing the desk rule to subagents are deferred; cost if wrong: duplicated fixtures only
- 2026-10-28T00:48Z Ruling: the T15, T16 and T17 reports stay under tasks/ where they were filed; test-task reports from now on go under evidence/ as <UTC>-<task id>-report.md (A39); cost if wrong: three records sit outside the test lane by one folder
- 2026-10-28T00:53Z Ruling: the runner follow-up already in progress under the test role is filed as T41; cost if wrong: none
- 2026-10-28T00:54Z Ruling: the R24.S2 fixture's deliberate rule breaks stand, and the space commit is checked only when the lead names one; cost if wrong: a weaker space-commit check
- 2026-10-28T01:46Z Ruling: the 01:32Z lines for T2, T3, T8, T9, T12, T13 and T14 are restated below as review lines, counts copied from the filed reviews; each joined a status and its review in one event, and the swe-pod skill reads a review only from a line that begins T<n> review:; cost if wrong: none, no count changes
- 2026-10-28T02:27Z Ruling: a suggestion whose behavior the spec states, in a requirement or an M item of spec section 14, with the plan's interface contract giving the detail, is routed to test; T5.TS4 (the interim local-only build rule), T12.TS4 (block-style registry entries) and T13.TS3 (the archiver sweep of result files) state behavior the spec does not and go to spec; no suggestion carries a computed value, and none is internal only; cost if wrong: a few suggestions reach the tester that a stricter reading would send to the spec author
- 2026-10-28T02:49Z Ruling: on that directive, T18 declines no suggestion for its run time and gives each new test the cap_s it needs, at most 1500 s as the filed tests have; at verify, each run is capped at its own cap_s rather than 600 s, and each shard at 180 min rather than 150 min, inside the overlay's limits for agent test and verify runs (about 3 h per run, about 6 h in all); the heavy ask still comes before either shard; cost if wrong: longer shards
- 2026-10-28T02:51Z Ruling: T37 fix round 1 takes the three Important findings in swe-pod; the fourth, the space-librarian id check refusing shard evidence ids, is in agent-mesh, outside T37's touches, and goes to the operator before T19a and T19b; cost if wrong: verify waits on one more task
- 2026-10-28T02:59Z Ruling: the managed policy the smoke reports on both nodes, a gateway settings drop-in (macos-laptop) and the gateway's remote managed settings (both), is accepted under test isolation as the 00:05Z ruling accepted the node's managed settings: it pins the model, adds denials, sets gateway variables and limits MCP servers, adds no instruction file, and loosens no fence (S1: no instruction file, no MCP server); cost if wrong: a scenario result reflects node policy
- 2026-10-28T02:59Z Ruling: smoke cases that fail without their property failing would stop both shards as BLOCKED, so S3, S4 and S7 go back to the test role as a T41 follow-up; cost if wrong: one more short test task before verify
- 2026-10-28T03:07Z Ruling: T18 keeps its after list; T42's test suggestions, if any, go to T35 as T39's did, so that T18 does not wait on T42; cost if wrong: those suggestions get a review instead of a test
- 2026-10-28T03:09Z Ruling: T37 open findings parked: the space-librarian id check (agent-mesh/skills/space-librarian/SKILL.md:290), moved to T42 by the 03:01Z operator decision, and integrate's one space commit (swe-pod/PROCESS.md:613, agents/swe-lead.md:420), text from T1 and T5 that T37 did not touch, held for T35 and T36 before the first integrate; both are outside T37's touches, and the three findings in them are closed; cost if wrong: the integrate rule is settled at T36 instead of now
- 2026-10-28T03:23Z Ruling: the T41 agent read 30 lines of the T39 report, outside its brief; a test task's report holds no implementation body, diff, builder report or build-task step; cost if wrong: none to blindness
- 2026-10-28T04:09Z Ruling: nine fixture files under tests/fixtures/overlays/ copy the demo change's evidence records, so one fixture id sits in several overlays and the librarian refuses them on id; they are test data in the test lane, not space records, and pass the profile and reference checks; filed as T16's and T17's overlays were; the librarian applying record ids to test fixtures is logged for T35; cost if wrong: none, no space record holds those ids
- 2026-10-28T04:11Z Ruling: the shards' expected times, computed now from the filed expected_s and the split, are 11473 s and 11472 s, about 191 min each and 382 min in all; that is over the 02:49Z ruling's 180 min shard cap and a little over the overlay's about 3 h per run and about 6 h in all, so the shard cap is 240 min, under the operator's yes to heavy (03:10Z) and permissive time (02:49Z), both given before these figures were known; cost if wrong: about 6.4 h of node time the operator did not see as a figure
- 2026-10-28T04:48Z Ruling: in T19a, a gateway outage (about 04:45Z to 04:47Z) gave five tests no agent turn; the shard re-runs those five once after its main pass, then test_R16_S1 again so it stays last, at the same commit set and inside the 240 min cap, and records both passes, each test's result being its last run's; the runner's startup retry missing that case is logged for T35; cost if wrong: about 25 min more shard time
- 2026-10-28T05:42Z Ruling: one run log copy named a bus inbox name that the shipped mesh-post skill uses as its default sender; the lead redacted it to <agent> in that copy before filing, as the shard agent redacted others; logged for T35 with the runner's redaction gaps; cost if wrong: none, logs only
- 2026-10-28T06:00Z Ruling: the lead's triage of the 25 failures and 1 not-run across both shards: deliverable, back to builders: swe-pod status for an unreadable remote and zero finding counts (R20.S1, T7.TS1), the skill's regression tests (T7.TS4) and words of completion and review dispatch (T7.TS3), owner T7; the go's branch step under G1 (R23.S2, T3.TS3), owners T5 and T1; the push-main contradiction, owner T5; the test brief's report line (R7.S2), owner T2; agent-mesh space-librarian's script text broken by skill arguments, owner T10. Test and fixture, back to the test role: the desk-command reader (R14.S1, R17.S1, R22.S1, R23.S1, R23.S2, T3.TS3), rebase options (I8, R17.S2), report paths (R7.S2, R11.S1, R12.S2, R17.S1), and R2.S1, R4.S1, R16.S1, T9.TS2, T10.TS6, T11.TS6 with T14.TS2, T13.TS1, T7.TS1. Harness, back to the test role as T41: the mesh-post deny on paths and the git -C deny (R7.S1, T12.TS3), the wait loop (T2.TS2), the gateway startup retry, and HOME isolation with redaction; cost if wrong: a fix lands on the wrong side and the re-run shows it
- 2026-10-28T06:00Z Ruling: the test role fixes its tests from the shards' run evidence and the triage's test-side findings; run evidence is not an implementation body, diff, builder report or build-task step; cost if wrong: none to blindness
- 2026-10-28T06:11Z Ruling: T10's touches extend to skills/space-librarian/check.sh by the verify fix; cost if wrong: none, the file is the old script byte for byte
- 2026-10-28T06:43Z Ruling: plan section 2.4's regression keys (qualified R ids only) are widened by the verify fixes to <change>/I<n> under x-checks: and <change>/T<n>.TS<k> under x-suggestions:, and promoted tests go to tests/<id>/; both meet spec section 5.6 and R5.S2; logged for T35; cost if wrong: a plan text that lags its deliverables
- 2026-10-28T06:59Z Ruling: the commit set has moved since the shards' space commit 33c829f, through both branch heads (swe-pod 4d5bfc7, agent-mesh bbd19a2) and the tests (at 7bbe9af), so both shards are briefed again and run again, with the same split and caps; cost if wrong: none, a full re-run
- 2026-10-28T07:23Z Ruling: round 1's S6 and S7 passes on linux-server came from the runner's old blanket deny, not the gate; the runner is to run the gate under its own --python and pass S6 and S7 only on the gate's own denial; that changes the tests folder, so T19a, running, is stopped and both shards run again after the fix; the gate failing open on a node with an old Python is logged for T35 and the operator; cost if wrong: one more verify round
- 2026-10-28T07:27Z Ruling: the four T19a round 2 failures are on the test side: R11.S1 counts a log as a record; R14.S1 meets a fixture world dated after the run, so the spec agent rightly refused an integration before the approval; R20.S1 matches STATUS.md in a printed commit message; R22.S1 states no G1, so the lead rightly handed the human the commands; the fixtures shift back one month and the three checks are fixed; cost if wrong: one more round
- 2026-10-28T07:40Z Ruling: S6 taking S7's probe wording and its bounded retry is the 03:23Z probe hardening applied to one more case; cost if wrong: none
- 2026-10-28T07:49Z Ruling: 21 fixture files refused on id and 2 on reference (fixture notes citing core/, which the demo space's may_reference lists) are test data, filed as at 04:09Z; cost if wrong: none, no space record holds or cites them
- 2026-10-28T07:50Z Ruling: the commit set has moved since the shards' space commit f128c46, through the tests (now at b1feac6: the runner's gate fix and the round 2 test fixes), so both shards are briefed again and run again, round 3, with the same split and caps; cost if wrong: none, a full re-run
- 2026-10-28T09:09Z Ruling: of the 14 round 3 failures, 11 are on the test side and go back to the test role: printed heredocs and echo blocks read as git calls or reads (I8, T10.TS8, T10.TS1, T3.TS2), the request Context in a body file (R7.S1), a builder's desk merge counted as a merge into main (R15.S1), dispatch lines judged against the template form instead of the spec's Then (R16.S1), prose read as a branch name (R23.S2), and bytecode left by a read-only check (T6.TS3); T13.TS1 stopped on a provider safeguard and is re-run; R17.S2, R4.S1 and T4.TS5 are triaged against the deliverables; the lead's own dispatch lines keep to the template form from here on; cost if wrong: one more round
- 2026-10-28T09:45Z Ruling: the commit set has moved through the tests (now at ef0ef5b), so both shards are briefed again and run again, round 4, with the same split and caps; cost if wrong: none, a full re-run
- 2026-10-28T11:06Z Ruling: of round 4's six failures, one is deliverable: swe-lead's heavy rule lets a lead judge a check heavy from a task's total or a test's cap; it goes back to T5 (swe-lead.md) and T1 (PROCESS.md Fences), each starting a new fix loop for this verify finding; five are test-side and go to the test role (T10.TS6's runner preamble, T7.TS3's wording, R19.S1's question count, R23.S2's gamma match, T13.TS1's link item and its safeguard-tripping name); cost if wrong: one more round
- 2026-10-28T11:07Z Ruling: the lead filed one T19a round 4 log copy that the librarian check had refused on profile, a bus inbox name that the shipped mesh-post skill's text uses as its default sender; it is public product text, now redacted to <agent> in that copy in a follow-up commit, and the lead files nothing past a refusal again; the runner's redaction of that name is logged for T35; cost if wrong: the name stays in the space's history
- 2026-10-28T11:26Z Ruling: a check that records no expected run time takes it from its brief or its last run's record when either gives one and is heavy only when that time is over 60 s; with no known time it is not heavy for the lead's ask, and the running agent's own fence still binds the run; this narrows round 2's 'with neither, treat it as heavy', which went past R13 and held the verify T1.TS4 expects dispatched; cost if wrong: a long unmeasured check runs without the ask, under the agent's fence
- 2026-10-28T11:31Z Ruling: the commit set has moved, through swe-pod's head (83eaef9, the heavy-rule fix) and the tests (now at 73c7543), so both shards are briefed again and run again, round 5, with the same split and caps; cost if wrong: none
- 2026-10-28T12:04Z Ruling: in round 5, runs stopped by the provider's safeguard (an API error, not an agent's answer) are environmental, as round 1's gateway outage was; a shard re-runs each such test after its main pass, at most twice more, at the same commit set and inside its cap, then test_R16_S1 again last; each test's result is its last run's, and one still stopped is not-run (environment); cost if wrong: up to about 40 min more shard time
- 2026-10-28T12:28Z Ruling: the round 5 safeguard stops come from the runner, not the provider alone: 27 of the 38 macos-laptop runs whose prompt carries the round 4 librarian desk-step wording (print every command of the filing procedure, none left out) were stopped, and 0 of the 24 runs without it; retries would not help, so the shard was stopped; the wording goes back to the test role as T41, proven by live runs before both shards run again, round 6; the 03:23Z and 12:04Z rulings stand; cost if wrong: one more round
- 2026-10-28T12:40Z Ruling: the commit set has moved through the tests (now at 31e5e2d), so both shards are briefed again and run again, round 6, with the same split and caps; cost if wrong: none, a full re-run
- 2026-10-29T01:55Z Ruling: under that decision, verify is one shard, T19c, on linux-server through the mesh, at swe-pod 83eaef9 and agent-mesh bbd19a2, tests changed at 31e5e2d; it runs 9 tests: the 5 that did not pass in round 4 and have not passed consistently since (R23.S2, T1.TS4, T10.TS6, T13.TS1 with T13.TS2, T7.TS3), the 3 others whose deliverable text changed after round 4 (I1, R13.S1, T8.TS3, the heavy-rule fix), and test_R16_S1 last; expected 2193 s
- 2026-10-29T01:55Z Ruling: the other 81 tests are established: 80 passed in round 4, R19.S1 passed in round 6 at this commit set, and the runner's desk-step wording that changed after round 4 was proven by T41's live runs; R7.S1 and R17.S1 live stand on rounds 3 to 5; verified, for this change, is T19c's 9 tests passing with the 81 carried from their filed evidence, in place of every result at one commit set (R24); cost if wrong: a regression in an established test is found later, by a full run
- 2026-10-29T01:55Z Ruling: a T19c run stopped by an API error (provider safeguard, gateway outage), not an agent's answer, re-runs after the main pass, at most twice more, inside the shard cap; a spend-limit stop ends the shard at once as BLOCKED, with the results so far, and scores no test after it; cost if wrong: up to about 40 min more shard time
- 2026-10-29T02:33Z Ruling: the change is verified by OD8: T19c's 9 tests pass at swe-pod 83eaef9 and agent-mesh bbd19a2, with the other 81 carried; the tester's read of the T19b round 5 record and report, past its brief's last line, is accepted, as it took only their layout and no result; next T35 on the most capable model; cost if wrong: none to the results
- 2026-10-29T02:35Z Ruling: 9de4f77 joins the change as an out-of-plan commit, with no Task trailer; T35 reviews it with the rest, agent-mesh 8ee5364..9de4f77 and swe-pod 8fc5294..83eaef9; after T35's fixes, one targeted re-run on linux-server runs the tests whose deliverables name a changed file, for 9de4f77 I7, T11.TS5, T11.TS7, T12.TS1, T12.TS2, T13.TS1, T9.TS1 and T9.TS2, then test_R16_S1; T19c's evidence stands at agent-mesh bbd19a2; cost if wrong: one more targeted run
- 2026-10-29T03:08Z Ruling: one fix wave, then one re-review (T35-review-r1.md), then a targeted re-run on macos-laptop of the tests the wave's fixes touch, test_R16_S1 last; the wave takes finding 1 by design (a), an integrate mode in space-librarian that makes one commit of renames and edits after the three checks, a moved record's id not counting as new, and finding 16 inside it (fixtures skip the id and reference checks, keep the profile check); finding 2 (mesh-load's $2); finding 13 (the identity template's example role); and finding 14 (the poller prompt names a real node); cost if wrong: one more wave
- 2026-10-29T03:08Z Ruling: findings 4 to 12 and 17 to 30 are deferred to a follow-up change, and the final report lists them; finding 15: T19c's record at agent-mesh bbd19a2 stands for 9de4f77 by the 02:36Z decision, and the final report lists 9de4f77 as an out-of-plan commit with no task; finding 20: T36 moves the tests to tests/build-swe-pod/, as PROCESS.md says; cost if wrong: none to the deliverables
- 2026-10-29T03:30Z Ruling: the wave, its re-review, the targeted re-run on macos-laptop and T36 run unattended to the merges, which the operator's words authorize; T36 step 4 (G1 and G2 into the operator's overlay) moves to after the merges and stays the operator's, since it widens what agents may do unasked and nothing in this change depends on it; the bus gitlink bumps and the settings steps of step 6 also wait for the operator; a Critical or Important finding in the re-review, or a failing test, stops the run before any merge; cost if wrong: until G1 is in the overlay, a future pod change needs temporary allow rules, as this one did
- 2026-10-29T03:53Z Ruling: on the re-review's Minors: agent-mesh guidance/agent-operating.md:219 ("one commit per record", no integrate exception) is deferred to the follow-up change with the other deferred Minors; integrate's filing is recorded in one ledger line, `filed by integrate: <n> paths, space <sha>`, in place of one line per path; skills/mesh-on/SKILL.md joins T12's touches for finding 14's edit; cost if wrong: none to the deliverables
- 2026-10-29T11:13Z Ruling: R14.S1.4, R17.S2.1 and T10.TS6.1 failed on the check, not the deliverable (03:59Z triage); R14.S1, R17.S2 and T10.TS6 count as passing at swe-pod b7fc257 and agent-mesh f27c611 for this change, and the three check fixes (the pin-edit heuristic, and counting output the agent repeats) go to the follow-up change; the change is verified by OD8 at those heads; cost if wrong: a fault in the merge, refusal or commit-order text ships, to be found by the follow-up change's run

## Deferred minors

Sources: tasks/T35-review.md (whole-change review, 27 Minor findings, numbered here as F4 to F30 in the review's order, and its Deferred minors section) and tasks/T35-review-r1.md (3 Minors). The fix wave (agent-mesh 9de4f77..f27c611, swe-pod 83eaef9..b7fc257) took findings 1, 2, 13, 14 and 16; the 2026-10-29T03:08Z ruling deferred findings 4 to 12 and 17 to 30 to a follow-up change and settled 15 and 20.

Fixed or settled by a ruling (5):

- T35 Minor agent-mesh/templates/agent-identity.env.template:19 (F13) The example AGENT_ROLES line ends in the sentence's period, so a copy registers the role `swe.test.`: fixed in the T35 fix wave (T9, 95fdbdb), carried as reviewed only (2026-10-29T03:53Z decision).
- T35 Minor agent-mesh/skills/mesh-on/poller-prompt.md:25 (F14) 9de4f77 names a real node and its idle cost in a product file: fixed in the T35 fix wave (T12, f27c611), carried as reviewed only (2026-10-29T03:53Z decision).
- T35 Minor agent-mesh/skills/space-librarian/check.sh:164 (F16) The id and reference checks apply to test fixtures: fixed in the T35 fix wave inside the integrate mode (T10); fixtures skip the id and reference checks and keep the profile check.
- T35 Minor space/changes/build-swe-pod/plan.md:1473 (F15) 9de4f77 has no Task trailer and T36 would re-run T19c: settled by the 2026-10-29T03:08Z ruling; T19c's record at agent-mesh bbd19a2 stands for 9de4f77 by the 2026-10-29T02:36Z decision, and 9de4f77 is listed under Out-of-plan commits below.
- T35 Minor space/changes/build-swe-pod/plan.md:1503 (F20) T36 step 7 moves the tests "into `tests/`" where PROCESS.md says `tests/<id>/`: settled by the 2026-10-29T03:08Z ruling; T36 moves them to `tests/build-swe-pod/`.

Deferred to the follow-up change (22 from T35, 3 from the re-review):

- T35 Minor swe-pod/agents/swe-lead.md:324 (F4) Only a ruling that begins `Ruling: T<n> open findings` closes a task's open findings, but swe-lead, PROCESS.md section 13 and the ledger template give the other form: deferred to the follow-up change.
- T35 Minor swe-pod/templates/records/spec.md:18 (F5) The template comment's `- approved:` line sits at column 0 and reads as an approval header (skills/swe-pod/SKILL.md:81): deferred to the follow-up change.
- T35 Minor swe-pod/agents/swe-lead.md:279 (F6) Step 6 records `filed <space path>` for STATUS.md too, which moves its "As of": deferred to the follow-up change.
- T35 Minor swe-pod/agents/swe-lead.md:429 (F7) Comparing a commit set with the pins in `pod.yaml` reads as every pin moved: deferred to the follow-up change.
- T35 Minor swe-pod/PROCESS.md:655 (F8) Section 8 step 5 has the lead mark `integrated:`, while swe-lead has the spec author add it: deferred to the follow-up change.
- T35 Minor swe-pod/PROCESS.md:609 (F9) "Every result in every one of them is a pass" fails records with `none-present` or `none-declared` (also agents/swe-lead.md:372): deferred to the follow-up change.
- T35 Minor agent-mesh/skills/mesh-on/mesh-scan-loop.sh:97 (F10) The per-cycle submodule update can collide with the librarian's unpushed commit or rebase in a cloned space: deferred to the follow-up change.
- T35 Minor agent-mesh/INSTALL.md:66 (F11) The `pullmesh` alias clones every mounted space on every node, against M2's clone on first need: deferred to the follow-up change.
- T35 Minor agent-mesh/docs/operator-manual.md:285 (F12) Retire says to commit "as for a mount", but that `git add` fails with a pathspec error after `git rm`: deferred to the follow-up change.
- T35 Minor agent-mesh/skills/space-librarian/SKILL.md:200 (F17) No rule for filing a record's log folder beside its record: deferred to the follow-up change.
- T35 Minor agent-mesh/hooks/git-gate.py:1 (F18) Under a Python older than 3.7 the gate exits on a syntax error and git add, commit and push pass ungated; outside this change's scope: deferred to the follow-up change (the operator should open a change that makes the hook fail closed, and check each node's own gate).
- T35 Minor space/changes/build-swe-pod/ledger.md:885 (F19) R19.S1's round 6 pass has no record or log in the space, so its evidence is the 2026-10-29T01:55Z ruling: deferred to the follow-up change (file the round 6 log under `evidence/` if it survives).
- T35 Minor swe-pod/PROCESS.md:471 (F21) No text says a value the code computed counts in every form (also agents/swe-lead.md:291, agents/swe-build.md:55 and 89): deferred to the follow-up change.
- T35 Minor swe-pod/agents/swe-lead.md:110 (F22) Nothing handles a `pod.yaml` repo whose remote or pin is still a placeholder: deferred to the follow-up change.
- T35 Minor agent-mesh/skills/space-librarian/check.sh:100 (F23) A shared space may cite `core` or `lore` when `may_reference` lists it, against memory-spaces sections 3.2 and 6.3: deferred to the follow-up change.
- T35 Minor swe-pod/agents/swe-test.md:134 (F24) Verify mode says "check out the commit set" but not where, so HEAD may move under other agents: deferred to the follow-up change.
- T35 Minor swe-pod/agents/swe-build.md:120 (F25) `git fetch origin change/<id>` does not update `origin/change/<id>` in a single-branch clone (also skills/swe-pod/SKILL.md:363): deferred to the follow-up change.
- T35 Minor swe-pod/agents/swe-review.md:41 (F26) The reviewer's Bash allows no `git fetch`, so it may read a stale branch: deferred to the follow-up change.
- T35 Minor swe-pod/agents/swe-spec.md:52 (F27) It says the lead commits any `SPEC.md` copy, but swe-lead's Writes has no such duty: deferred to the follow-up change.
- T35 Minor agent-mesh/skills/mesh-on/poller-prompt.md:251 (F28) The link guard finds symbolic links only, so a hard link to a node file passes: deferred to the follow-up change.
- T35 Minor agent-mesh/spec/PROTOCOL.md:452 (F29) `files:` entries are unquoted flow mappings, so a path holding `, ` or `: ` breaks its entry (also skills/mesh-on/poller-prompt.md:277): deferred to the follow-up change.
- T35 Minor agent-mesh/skills/mesh-on/poller-prompt.md:412 (F30) The archiver sweeps an orphan status or `-files/` folder only when its task or result is "already archived", not when it is gone: deferred to the follow-up change.
- T35 re-review Minor agent-mesh/guidance/agent-operating.md:219 Still says the space-librarian makes "one commit per record" with no integrate exception, and nothing says integrate runs where the space's librarian role is held (also SKILL.md:204 and agents/swe-lead.md:454): deferred to the follow-up change (2026-10-29T03:53Z ruling).
- T35 re-review Minor swe-pod/agents/swe-lead.md:279 Step 6 would record one `filed` line per `FILED` line, about 1727 paths for integrate: settled by the 2026-10-29T03:53Z ruling; integrate's filing is one ledger line, `filed by integrate: <n> paths, space <sha>`.
- T35 re-review Minor agent-mesh/skills/mesh-on/SKILL.md:130 f27c611 carries `Task: T12` but the file is outside T12's touches: settled by the 2026-10-29T03:53Z ruling; the file joins T12's touches.

Accepted as deferred from the task reviews (63, from tasks/T35-review.md "Deferred minors"): of 102 Minor lines in the task reviews (97 distinct), 17 are closed and 17 are raised again as T35 findings F4 to F13 and F24 to F30 (counted above); the other 63 are cosmetic or rare, deferred to the follow-up change, each as its source review (tasks/T<n>-review*.md) states it. By group:

- weak rule gaps accepted as low risk: swe-lead's `<id>` used for both the message and the change id, the review's "diff from base to head", the `decisions/` lane timing; swe-test's writing-mode read list; swe-build's commit range read before the rebase; swe-plan's always-fresh description; the skill's free-text DONE rule, done before held, committed STATUS.md trusted on a matching "As of", and `next:` at small size; the AGENTS.md template sending every arriving agent to the skill; INSTALL's placeholder replace and `ln -sfn` onto a real directory; check.sh's file-name prefix match; agent-operating step 4's missing branches; the `.gitignore` segment and the per-file link rule; PROCESS.md's verified-row wording.
- swe-pod, PROCESS.md: the bare `approved:` key, the single-seat order, the interim-rule wording, the shards subsection placement, the unnamed-repo pin move.
- swe-pod, templates: the ledger, report, review, brief and plan slots; the repeated `diff:` key; the test-brief shard lines; the plan's sharded form; the AGENTS.md exception and "four hex digits".
- swe-pod, roles and docs: swe-spec reads and re-approval; swe-plan (c) wording; swe-lead's fixed `tools:` and Never wording; swe-build's index-lock wait; swe-test's public surface; the README and INSTALL wording items of T8.
- agent-mesh: the T9 role wording; check.sh's fenced ids, `supersedes` and date-shaped body ids; the librarian's step 5, inbox prose and `allowed-tools`; the memory-spaces status rows; PROTOCOL's blocked-reason list and `project:` name clash; the orphan `-files/` archive month; the T14 README items; the manual's skill map.

## Test suggestions

82 suggestions in all. Routing and outcomes are from the ledger (routing at 2026-10-28T02:27Z, 02:36Z and 2026-10-29T03:08Z; outcomes at 2026-10-28T02:30Z and 04:09Z and 2026-10-29T03:08Z). Every suggestion test last ran pass; T10.TS6, T1.TS4, T7.TS3 and T13.TS1 with T13.TS2 failed or did not run in round 4 and pass in ev-20261029T0211Z-T19c. Round 2 results for the suggestion tests it ran (test_T10_TS1_reference_rule, test_T10_TS6_commit_stage_order, test_T10_TS8_joined_and_registry_values, test_T12_TS1_unmounted_project_blocked, test_T12_TS3_load_never_changes_bus) are pass in ev-20261029T0356Z-T19c, apart from T10.TS6, a fail on the check that counts as pass by the 2026-10-29T11:13Z ruling.

- T1.TS1 Approval text outside the header: tested test_T1_TS1_approval_text_outside_header
- T1.TS2 Stale evidence when only the regression suite moved: tested test_T1_TS2_only_regression_suite_moved
- T1.TS3 Single seat at project size: tested test_T1_TS3_single_seat_fresh_planner
- T1.TS4 Heavy check found only from the recorded run time: tested test_T1_TS4_heavy_from_recorded_run_time
- T1.TS5 Suggestion with a computed value given as a tolerance: tested test_T1_TS5_computed_values_in_other_forms
- T1.TS6 Review task waiting on its own build task: tested test_T1_TS6_review_dispatched_before_successor
- T1.TS7 A check with no recorded expected run time: declined: a builder's suggestion, skipped for now by the operator
- T2.TS1 Fresh spec from the template keeps its comment: tested test_T2_TS1_spec_from_template_with_comments
- T2.TS2 Review over two repos: tested test_T2_TS2_review_over_two_repos
- T2.TS3 Ledger made from the template still lists the example events: tested test_T2_TS3_ledger_from_template_not_emptied
- T2.TS4 Evidence for a spec with no Quality section: declined: test_R12_S2_no_checks_declared already exercises it
- T3.TS1 Fresh space before any STATUS.md exists: tested test_T3_TS1_fresh_space_without_status
- T3.TS2 Test-writing agent with plan, ledger and reports present: tested test_T3_TS2_blind_writer_amid_records_and_code
- T3.TS3 A placeholder repo left in pod.yaml: tested test_T3_TS3_placeholder_repo_in_pod_yaml
- T4.TS1 Several requirements without a scenario: tested test_T4_TS1_several_requirements_without_scenario
- T4.TS2 Approval relayed by another agent: tested test_T4_TS2_approval_relayed_by_lead
- T4.TS3 Planner given an unapproved spec: tested test_T4_TS3_planner_on_unapproved_spec
- T4.TS4 Supersedes without a test-update task: declined: test_R2_S2_supersedes_and_test_update already exercises it
- T4.TS5 "Just draft it" with defaults: tested test_T4_TS5_just_draft_it_lists_defaults
- T5.TS1 Plan request on an unapproved spec: tested test_T5_TS1_plan_request_on_unapproved_spec
- T5.TS2 Test result that also touches a file outside its lane: declined: test_R8_S1_test_result_in_lane already exercises it
- T5.TS3 Requirement edit while a serving task is already running: tested test_T5_TS3_edit_while_serving_task_runs
- T5.TS4 Build task the plan marks for the mesh: dropped
- T5.TS5 Pin moved, `tests/` unchanged, before a merge: tested test_T5_TS5_only_pin_moved
- T5.TS6 Suggestion whose tester part carries a value the code computed: tested test_T1_TS5_computed_values_in_other_forms
- T5.TS7 Go when the guidance does not let the pod commit: declined: a builder's suggestion, skipped for now by the operator
- T5.TS8 Review dispatch recorded: declined: a builder's suggestion, skipped for now by the operator
- T5.TS9 A heavy label that disagrees with the recorded run time: declined: a builder's suggestion, skipped for now by the operator
- T6.TS1 Builder with no change branch to push to: tested test_T6_TS1_no_change_branch_on_remote
- T6.TS2 Blind test writer when code already exists: tested test_T3_TS2_blind_writer_amid_records_and_code
- T6.TS3 Reviewer asked to file its own review: tested test_T6_TS3_reviewer_returns_text_only
- T6.TS4 Evidence when pod.yaml names a repo the spec does not: declined: test_R11_S1_evidence_fields already exercises it
- T6.TS5 Parallel builders while one has work in progress: declined: cannot be produced or observed under the runner's isolation protocol
- T7.TS1 Several events of one task in the same minute: tested test_T7_TS1_same_minute_events
- T7.TS2 A spec that quotes an example spec: tested test_T7_TS2_spec_quoting_example_spec
- T7.TS3 A ledger written in words: tested test_T7_TS3_ledger_written_in_words
- T7.TS4 A plan in the template's form, with a ruled whole-change review: tested test_T7_TS4_template_plan_ruled_review_missing_results
- T7.TS5 One remote readable, one not, with a fix round: declined: a builder's suggestion, skipped for now by the operator
- T7.TS6 Review lines with mixed and all-zero counts: declined: a builder's suggestion, skipped for now by the operator
- T7.TS7 Regression test in a subfolder, named twice or not at all: declined: a builder's suggestion, skipped for now by the operator
- T7.TS8 A task said in words not to be finished: declined: a builder's suggestion, skipped for now by the operator
- T8.TS1 Install from INSTALL alone, then a local dispatch: tested test_T8_TS1_install_user_level_then_local_dispatch
- T8.TS2 Single seat with only what INSTALL installs: tested test_T8_TS2_single_seat_files_through_librarian
- T8.TS3 Heavy verify after the go, with the human present: tested test_T8_TS3_heavy_verify_with_g3_overlay
- T9.TS1 Six pod roles named as per-task-output roles: tested test_T9_TS1_pod_roles_per_task_output
- T9.TS2 Registering a pod role means adding it to AGENT_ROLES: tested test_T9_TS2_agent_roles_registration
- T9.TS3 No protocol, guidance or poller change: declined: it can be checked only by reading the diff of T9's commits in agent-mesh (which files they change, and that the identity template's change is comments only), which the blind rule excludes
- T10.TS1 Shareable records are accepted: tested test_T10_TS1_reference_rule
- T10.TS2 Each profile leak is refused without echoing it: tested test_T10_TS8_joined_and_registry_values
- T10.TS3 Citations and the visibility rule: tested test_T10_TS1_reference_rule
- T10.TS4 Duplicate ids, and re-filing: declined: its duplicate-id half is exercised by test_I8_space_librarian_checks (record duplicate) and test_R17_S2_single_seat_librarian (record duplicate-two)
- T10.TS5 Single seat uses the same checks (R17.S2): tested test_T10_TS8_joined_and_registry_values
- T10.TS6 Commit stage in desk mode: tested test_T10_TS6_commit_stage_order
- T10.TS7 Portability: declined: a line-for-line comparison of runs on two nodes is outside what one runner test can observe (a run sees only its own node)
- T10.TS8 Joined bus values are refused (fix round 1): tested test_T10_TS8_joined_and_registry_values
- T10.TS9 The skill invoked with arguments files the same way: declined: a builder's suggestion, skipped for now by the operator
- T10.TS10 An installed node finds the check script: declined: a builder's suggestion, skipped for now by the operator
- T11.TS1 Project value pattern edges: tested test_T11_TS1_project_value_edges
- T11.TS2 Invalid value is refused before the repo is checked: declined: test_I6_mesh_post_project_flag already exercises it
- T11.TS3 Fan-out keeps the field on every message: tested test_T11_TS3_fan_out_project_line
- T11.TS4 Locale independence: tested test_T11_TS1_project_value_edges
- T11.TS5 New bus carries an empty registry: tested test_T11_TS5_new_bus_mounts_no_space
- T11.TS6 Status table matches the M2 scope: tested test_T11_TS6_memory_spaces_scope_in_docs
- T11.TS7 PROTOCOL rows and pointer: tested test_T11_TS7_protocol_spaces_writers
- T12.TS1 A task for an unmounted project is blocked, not run: tested test_T12_TS1_unmounted_project_blocked
- T12.TS2 Spaces are cloned on first need and then follow the tip: tested test_T12_TS2_scan_list_initialized_spaces
- T12.TS3 Loading never changes the bus: tested test_T12_TS3_load_never_changes_bus
- T12.TS4 Registry entries the resolver cannot read: dropped
- T13.TS1 Result files that break a rule are not published: tested test_T13_TS1_result_files_by_rule
- T13.TS2 A link in the staged files cannot publish a node file: tested test_T13_TS1_result_files_by_rule
- T13.TS3 The archiver sweeps the files folder with its task: dropped
- T14.TS1 README links resolve on the change branch: declined: the spec states no requirement on the agent-mesh README's links or on its linking the memory-spaces design, so the expected value would come from the builder (a proposed scenario for the spec author, if wanted)
- T14.TS2 README claims no more than the product implements: tested test_T11_TS6_memory_spaces_scope_in_docs
- T14.TS3 README names the six pod roles as per-task-output roles: tested test_T9_TS1_pod_roles_per_task_output
- T37.TS1 Shard out of date by its space commit only: tested test_T37_TS1_shard_stale_by_space_commit
- T37.TS2 Shards that pass but do not cover everything together: tested test_T37_TS2_shards_leave_out_unit_suite
- T37.TS3 A test task's report among the evidence: tested test_T37_TS3_report_among_evidence
- T39.TS1 Shards at one commit set that together miss a result: declined: the tester's own, covered by the deliverable text (T35), skipped for now by the operator
- T39.TS2 A shard re-run supersedes its own earlier record: declined: the tester's own, covered by the deliverable text (T35), skipped for now by the operator
- T39.TS3 Status and trace for a stale shard: declined: the tester's own, covered by the deliverable text (T35), skipped for now by the operator
- T42.TS1 Shard evidence records are filed alongside an unsharded one: declined: a builder's suggestion, skipped for now by the operator
- T42.TS2 Malformed shard ids and misplaced shard ids are refused: declined: a builder's suggestion, skipped for now by the operator

## Open questions

- R7 (remote builders) holds only for local builds until the deferred executor git exception lands (plan section 3 OD4; the exception is recorded in note-20261027T2242Z-0786, for the change that first puts builders on remote nodes): the operator, in that change.
- The seven desk-verified scenarios (R4.S1, R5.S2, R14.S1, R15.S1, R22.S1, R23.S1, R23.S2) and the commit step of R17.S2 need live confirmation at pilot (OD1): the operator, at pilot.
- R19.S1 has no evidence record, only the 2026-10-29T01:55Z ruling (F19): file the round 6 log under `evidence/` if it survives, else accept the ruling.
- The git gate fails open under a Python older than 3.7 (F18, outside this change's scope): the operator opens a change that makes the hook fail closed, and checks each node's own gate.
- The 22 deferred T35 Minors, the 2 deferred re-review Minors and the 63 accepted task-review Minors have no change yet: the operator, to open the follow-up change.
- The integrate mode of the space-librarian had not run on a real space when the fix wave was filed (ledger 2026-10-29T03:39Z): the first integrate, T36, is its live run.
- The poller cost change (9de4f77) is carried as tested, not re-run (see Out-of-plan commits).

### Out-of-plan commits

- agent-mesh 9de4f77, the poller cost change (the scanner's idle deadline cut under the prompt-cache TTL, and the poller given its own model). It was made by another agent at the operator's request after T19c had started, carries no Task trailer, and is outside spec section 3's scope. It joined the change by the 2026-10-29T02:35Z ruling and is carried as tested by the operator's 2026-10-29T02:36Z decision; T19c's evidence stands at agent-mesh bbd19a2, and the targeted re-run for it was dropped. T35 reviewed it with the rest (F14 and F28 touch its files).

## Branches

| Repo | Branch | Head |
|---|---|---|
| agent-mesh | change/build-swe-pod | f27c611, merged into main at f27c611 (fast-forward, 2026-10-29) |
| swe-pod | change/build-swe-pod | b7fc257, merged into main at b7fc257 (fast-forward, 2026-10-29) |

The swe-pod branch is deleted. The agent-mesh branch is left in place, equal to main, for the operator to delete.
