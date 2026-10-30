# right-size-testing: final report

- change: right-size-testing
- spec: changes/right-size-testing/spec.md
- latest evidence: ev-20261030T1742Z

Verified: the latest evidence, ev-20261030T1742Z, is green at the current
commit set (space 3a2a91b for the tests, swe-pod 3b22a1b, agent-mesh
f27c611), and the whole-change review, T4, has no open Critical or Important
finding. Not merged: merge is the operator's word.

## Scenarios
Selection `targeted`: `touched:` is the 17 files of swe-pod's diff
b7fc257..3b22a1b. Picked and passed: build-swe-pod I2, I4, I5, R16.S1 and
`test_R12_S1_missing_quality_check` (named by the plan for R5's risk);
build-swe-pod I1 and I3 `superseded by I1` and `superseded by I3`; the other
83 regression tests `not-selected` (73 agent class the plan does not name, 10
script class that read only agent-mesh files). Unit: swe-pod none-present.

| Scenario | Test | Result | Evidence id |
|---|---|---|---|
| R1.S1 | T1 done-when check | pass | ev-20261030T1742Z |
| R1.S2 | T1 done-when check | pass | ev-20261030T1742Z |
| R2.S1 | T1 done-when check | pass | ev-20261030T1742Z |
| R3.S1 | T1 done-when check | pass | ev-20261030T1742Z |
| R3.S2 | T1 done-when check | pass | ev-20261030T1742Z |
| R4.S1 | T1 done-when check | pass | ev-20261030T1742Z |
| R4.S2 | T1 done-when check | pass | ev-20261030T1742Z |
| R5.S1 | test_R5_S1_not_selected_green | pass | ev-20261030T1742Z |
| R5.S2 | test_R5_S2_superseded_with_replacement | pass | ev-20261030T1742Z |
| R5.S3 | test_R5_S3_superseded_without_replacement | pass | ev-20261030T1742Z |
| R5.S4 | test_R5_S4_picked_test_not_passed | pass | ev-20261030T1742Z |
| R6.S1 | T1 done-when check | pass | ev-20261030T1742Z |
| R6.S2 | T1 done-when check | pass | ev-20261030T1742Z |
| R7.S1 | T1 done-when check | pass | ev-20261030T1742Z |
| R7.S2 | T1 done-when check | pass | ev-20261030T1742Z |
| R8.S1 | T1 done-when check | pass | ev-20261030T1742Z |
| R8.S2 | T1 done-when check | pass | ev-20261030T1742Z |
| R9.S1 | T1 done-when check | pass | ev-20261030T1742Z |
| R9.S2 | T1 done-when check | pass | ev-20261030T1742Z |
| R10.S1 | T1 done-when check | pass | ev-20261030T1742Z |
| R10.S2 | T1 done-when check | pass | ev-20261030T1742Z |
| R11.S1 | T1 done-when check | pass | ev-20261030T1742Z |
| R11.S2 | T1 done-when check | pass | ev-20261030T1742Z |
| R12.S1 | T1 done-when check | pass | ev-20261030T1742Z |
| R12.S2 | T1 done-when check | pass | ev-20261030T1742Z |
| R13.S1 | T1 done-when check | pass | ev-20261030T1742Z |
| R13.S2 | T1 done-when check | pass | ev-20261030T1742Z |
| R14.S1 | T1 done-when check | pass | ev-20261030T1742Z |
| R14.S2 | T1 done-when check | pass | ev-20261030T1742Z |
| R15.S1 | T1 done-when check | pass | ev-20261030T1742Z |
| I1 | test_I1_process_md | pass | ev-20261030T1742Z |
| I3 | test_I3_d3_templates | pass | ev-20261030T1742Z |
| Q1 | the whole-change review, T4-review-r1.md | pass | ev-20261030T1742Z |

## Rulings
- 2026-10-30T16:19Z Ruling: this change runs under its own rules from the go, though the space still pins swe-pod-process@1: risk-named tests, the plan's estimates and asks, targeted verify, the green rule with not-selected and superseded, one review, and every role on the most capable model; why: open call 2 of the approved spec, and the operator's go at small size; cost if wrong: one change verified under rules the space has not yet pinned, which integrate pins as swe-pod-process@2
- 2026-10-30T16:22Z Ruling: the one review, T4, runs after T1 and its fix wave and before verify, which then runs once at the final commit set and takes Q1 from the review; why: open call 2 orders build, test, review, verify, and a review after verify would need a second verify after its fix wave; cost if wrong: a code fault verify finds needs a fix and a review of that fix diff alone
- 2026-10-30T16:22Z Ruling: build-swe-pod's checks I1.2 and I3.14 go stale when swe-pod moves to swe-pod-process@2 (open call 16); T3 writes replacements at @2, verify gives build-swe-pod/I1 and build-swe-pod/I3 superseded by I1 and superseded by I3 under plan 2.4, and integrate moves the two old tests to build-swe-pod's superseded-tests; why: both are picked script-class tests, and neither may hold the evidence red nor be ruled green by hand; cost if wrong: the green rule's superseded case also takes I-check keys, which R5's tests and the review must accept
- 2026-10-30T16:22Z Ruling: STATUS.md is regenerated with the swe-pod skill at the branch head once T1 lands, and with the installed skill until then; why: this change runs under its own rules from the go; cost if wrong: STATUS.md reads this change's evidence by the old rule until T1 lands
- 2026-10-30T16:51Z Ruling: the managed policy T2's smoke reports, the gateway settings drop-in and the remote managed settings, is accepted under test isolation, as build-swe-pod ruled at 2026-10-28T02:59Z; why: it pins the model, adds denials and gateway variables, adds no instruction file and loosens no fence; cost if wrong: an agent-class result reflects node policy
- 2026-10-30T16:51Z Ruling: T2's two script-class tests read the rule's words together in one paragraph and contract 2.5's status form, and stand as written; a correct rule they fail goes back to the test agent with the spec clause; why: 2.5 is the contract, and T4 reads them for a change detector; cost if wrong: a false fail at verify and one test fix
- 2026-10-30T17:19Z Ruling: R7's declined covers a suggestion bound for the test agent that a planned test covers; the routes to the spec author (behavior the spec does not state) and back to the builder (internal only) stay; why: both R7 scenarios are about suggestions bound for the test agent, and build-swe-pod/R21.S2, which stays in the suite, needs the proposed-as-scenario and unit-tested outcomes; cost if wrong: a suggestion R7 meant to decline reaches the spec author or the builder
- 2026-10-30T17:19Z Ruling: an unlisted script-class run needs no ask (R3); why: R3's only when limits the ask, and the spec puts the cost in agent-class and live-class runs, as T4 confirmed; cost if wrong: an unlisted script check runs with no word from the operator
- 2026-10-30T17:19Z Ruling: T4's wave-review finding at swe-pod/skills/swe-pod/SKILL.md:114 is in scope and fixed in this wave, not parked; why: R10 brings wave reviews in, and the skill must read their state; the out-of-scope item is only the first id of a Reviews cell; cost if wrong: one more skill rule in this wave
- 2026-10-30T17:19Z Ruling: the whole-change fix wave carries T4's 4 Important findings and, batched with them, its 18 Minor ones; why: open call 12 and R11, a fix wave that runs for an Important finding also takes the batched Minors; cost if wrong: a longer fix wave
- 2026-10-30T17:33Z Ruling: T4's Minor at swe-pod/templates/records/review.md:18 is parked; why: the review template is outside the plan's file map, and swe-review's Quality section now names the R6 check; cost if wrong: a reviewer working from the template alone may skip that check
- 2026-10-30T17:40Z Ruling: T4's re-review Minor, the reflow defect at swe-pod/agents/swe-plan.md:103 and two short lines at swe-pod/PROCESS.md:367 and :484, is parked; why: a Minor finding starts no fix round (R11) and the one whole-change fix wave has run; cost if wrong: three unevenly wrapped lines ship in swe-pod-process@2
- 2026-10-30T17:59Z Ruling: T5's third smoke, a rerun after a false fail in the runner's smoke judge S4, counts as a rerun of a listed run and needed no ask; why: the change's expensive runs stood at 682 s and 3.34 USD, within twice the 1260 s and 5.65 USD estimate (R3); cost if wrong: one unlisted 96 s, 0.41 USD run went ahead with no word from the operator
- 2026-10-30T17:59Z Ruling: Q1 is read from the re-review, T4-review-r1.md, as T5 did, though its brief named T4-review.md; why: the latest review of T4 decides Q1; cost if wrong: none, the first review's Q1 fail was closed by the fix wave

## Deferred minors
- T4 Minor swe-pod/agents/swe-build.md:154 Says the lead "declines the rest" of the suggestions, while PROCESS.md:577-590 and agents/swe-lead.md:305-317 also route them to the spec author or the builder. The R7 reading behind those routes needs a lead ruling.: fixed in the whole-change fix wave, swe-pod 0debc5a..3b22a1b
- T4 Minor swe-pod/PROCESS.md:355 "asks the operator only about runs the plan does not list" drops the "agent-class or live-class" of PROCESS.md:1074-1075. So §4 asks about an unlisted script check and §11 does not.: fixed in the whole-change fix wave, swe-pod 0debc5a..3b22a1b
- T4 Minor swe-pod/PROCESS.md:302 For a spec with `supersedes`, the test task "updates the matching tests in `tests/`" (also PROCESS.md:216-217, agents/swe-plan.md:92-93 and 182-183, agents/swe-spec.md:104-106). But integrate moves those tests out (PROCESS.md:874-879) and verify gives them `superseded by <key>`. Say the task writes their replacements in `changes/<id>/tests/`, as T3 did.: fixed in the whole-change fix wave, swe-pod 0debc5a..3b22a1b
- T4 Minor swe-pod/skills/swe-pod/SKILL.md:248 By the prefix rule, a deliverable path ending in `/`, or a whole repo, never holds a touched path, though plan 2.2's "or a folder that holds one" covers it. Such a test's `not-selected` would read as no bar. No test declares one today.: fixed in the whole-change fix wave, swe-pod 0debc5a..3b22a1b
- T4 Minor swe-pod/skills/swe-pod/status-format.md:125 A shard's own line counts `superseded by <key>` as a bar when `<key>` passes only in another shard. It then shows `not green` while the combined line shows `green` (SKILL.md:328-329 looks in every record). Also a broken line at 127.: fixed in the whole-change fix wave, swe-pod 0debc5a..3b22a1b
- T4 Minor swe-pod/skills/swe-pod/status-format.md:186 The new ledger forms are not task events. A task recorded as `T<n> not dispatched` still shows `ready` and `next:` names it, and a `T<n> harness error` line never shows.: fixed in the whole-change fix wave, swe-pod 0debc5a..3b22a1b
- T4 Minor swe-pod/templates/records/review.md:18 The Quality section has no line for the R6 check that PROCESS.md:485-487 and agents/swe-review.md:110-113 now require: that each builder's test for a requirement not at risk exercises its scenario, with an Important finding where it does not.: parked by the ruling at 2026-10-30T17:33Z
- T4 Minor swe-pod/templates/records/plan.md:174 The regression row's Keep cell, `already in tests/`, is neither `keep` nor `not kept: <reason>`, the only two values PROCESS.md:314 and agents/swe-plan.md:104 allow.: fixed in the whole-change fix wave, swe-pod 0debc5a..3b22a1b
- T4 Minor swe-pod/templates/records/plan.md:146 The whole-change review's done-when names "the latest evidence", which a one-wave plan's review, run before verify, does not have. PROCESS.md:771 says "when there is one".: fixed in the whole-change fix wave, swe-pod 0debc5a..3b22a1b
- T4 Minor swe-pod/PROCESS.md:765 In a one-wave plan the only review runs before verify, so a fix routed from a verify failure lands after it, and no rule says it gets a review. The 16:22Z ruling gives this change a review of that fix diff; the process could say the same.: fixed in the whole-change fix wave, swe-pod 0debc5a..3b22a1b
- T4 Minor swe-pod/PROCESS.md:304 Two cases are unsettled. A one-wave plan with a build task marked at risk meets both "one review, the whole-change review" and "a review of one build task only where its entry has `- risk: at risk`". A wave whose tasks are all at risk gets a wave review that covers none. Say which rule holds.: fixed in the whole-change fix wave, swe-pod 0debc5a..3b22a1b
- T4 Minor swe-pod/PROCESS.md:1087 A test task's brief "quotes the plan's rows for the expensive runs", but PROCESS.md:518-524 lets a test-writing brief carry only its entry, the spec path, the contract, the constraints and the test map. templates/records/test-brief.md has no place for the rows; T2's brief put them under Global constraints.: fixed in the whole-change fix wave, swe-pod 0debc5a..3b22a1b
- T4 Minor swe-pod/INSTALL.md:134 G3 covers only a verify task. A deployment that copies it will still stop to ask before the listed agent-class runs a test-writing task makes at base, which PROCESS.md:1078-1079 lets go ahead with no ask.: fixed in the whole-change fix wave, swe-pod 0debc5a..3b22a1b
- T4 Minor swe-pod/agents/swe-test.md:190 Verify step 3 defines `touched:` but does not say that a readable repo's diff decides the picks, or that a record whose `touched:` leaves out a file of that diff is not green (PROCESS.md:698-701, SKILL.md:250-262).: fixed in the whole-change fix wave, swe-pod 0debc5a..3b22a1b
- T4 Minor swe-pod/PROCESS.md:328 No text says what makes a requirement at risk, so whether R1.S2's reported live-only defect is marked at risk rests on the planner's judgment alone (open call 3). One sentence naming such cases (a reported defect seen only live, a rule that decides verified) would let its check show the THEN.: fixed in the whole-change fix wave, swe-pod 0debc5a..3b22a1b
- T4 Minor swe-pod/README.md:39 "and a build task of its own only when the plan marks it at risk" is missing its noun: it should be "a review of a build task of its own".: fixed in the whole-change fix wave, swe-pod 0debc5a..3b22a1b
- T4 Minor swe-pod/PROCESS.md:1055 One line of 111 characters in the Ordering bullet, left by a reflow.: fixed in the whole-change fix wave, swe-pod 0debc5a..3b22a1b
- T4 Minor swe-pod/agents/swe-build.md:106 A reflow left "reruns it. For a" on a short line of its own.: fixed in the whole-change fix wave, swe-pod 0debc5a..3b22a1b
- T4 (re-review) Minor swe-pod/agents/swe-plan.md:103 A reflow defect from the fix: the line runs to 86 characters ("comes before verify. A wave whose build tasks are all marked at risk has no wave"). PROCESS.md:367 ("(§11). Section 6 gives every agent-class") and PROCESS.md:484 ("review: their own reviews cover it. Record the review") stop mid-paragraph on short lines.: parked by the ruling at 2026-10-30T17:40Z

## Test suggestions
- T1.TS1 A superseded inspection check: declined: covered by test_R5_S3_superseded_without_replacement, whose supersedes check is the one an I-check key takes, and by T5's own record (build-swe-pod/I1 and I3 superseded by I1 and I3, green)
- T1.TS2 A touched list that leaves out a file of the diff: declined: no fixture has a readable code repo; the lead checked T5's touched list against swe-pod's diff b7fc257..3b22a1b (17 of 17 files), and T4 read the skill's diff check
- T1.TS3 A deliverable that is a folder, or carries an alias: declined: covered by test_R5_S4_picked_test_not_passed and by T5's own picks, whose deliverables are folders and aliases
- T1.TS4 Sharded verify with not-selected and superseded results: declined: this change's verify is not sharded and the spec gives R5's sharded clause no scenario; T4 read the combined-records rule
- T1.TS5 not-selected on a scenario of the change itself: declined: a change's own scenarios, unit suites and quality checks still need a pass, which test_R12_S1_missing_quality_check guards; T4's Important finding put the limiting sentence in PROCESS.md, swe-lead and README too

## Open questions
- Follow-up, not fixed here: `tests/build-swe-pod/runner.sh` smoke case S4's judge matches the word git anywhere in a Bash command, so an echo of a DESK line fails it; T5 needed a third smoke (96 s, 0.41 USD). A later change to the runner: the operator.
- Follow-up, not fixed here: the runner has no built-in 120 s abort for a session that never reaches the test's first step (R9); T2 and T5 ran a watcher beside it. The reusable live-session harness the spec leaves out is the place for it: the operator.
- The operator's guidance overlay still cites the retired `heavy:` approval line and the old G3 title; swe-pod's INSTALL.md G3 now covers every run the plan lists. Rewording the overlay is the operator's.
- swe-pod's SPEC.md keeps the old G3 wording with no note (open call 18 names only R5, R12, R13, R21 and the model lines): the operator.
- Three agent-class regression tests may be stale under the new rules and were not run: `test_R2_S2_supersedes_and_test_update` (expects the supersedes test task to name a path in `tests/`), `test_R6_S1_complete_test_map` (expects every scenario mapped to a test-role task) and `test_T1_TS6_review_dispatched_before_successor` (a review per build task). About 1500 s expected, about 3 USD. Run them, or move them out at integrate: the operator.

## Branches
| Repo | Branch | Head |
|---|---|---|
| swe-pod | change/right-size-testing | 3b22a1b |
| agent-mesh | none (not in the spec's repos) | pin f27c611 |

## Test cost
| Expensive runs | Estimate | Actual | Actual / estimate |
|---|---|---|---|
| wall time (s) | 1260 | 682 | 0.5 |
| spend (USD) | 5.65 | 3.34, unknown for 3 of 29 agent sessions | 0.6, over the known spend |

The expensive runs: T2's smoke and two R5 agent-class tests at base (266 s,
1.34 USD) and T5's three smokes, two R5 agent-class tests and
`test_R12_S1_missing_quality_check` at the head (416 s, 2.00 USD). The
unknown spend is the smoke case S3 in each of the three smokes, stopped at its
30 s cap.

- total test wall time: 1023 s (T2 268 s, T3 1 s, T5 754 s), besides about 10 s of the builder's done-when checks
- test agents: 3
- review agents: 1 (two reviews: the whole-change review and its one re-review)
- fix rounds: 1
- asks to the operator about tests: 0

## Tests kept
- kept: test_R5_S1_not_selected_green: R5 is at risk; a lasting rule
- kept: test_R5_S2_superseded_with_replacement: R5 is at risk; a lasting rule
- kept: test_R5_S3_superseded_without_replacement: R5 is at risk; guards a false green
- kept: test_R5_S4_picked_test_not_passed: R5 is at risk; guards a false green
- kept: test_I1_process_md: replaces build-swe-pod's I1 with the version line at swe-pod-process@2
- kept: test_I3_d3_templates: replaces build-swe-pod's I3 with the template's version line at swe-pod-process@2
- not kept: T1's 26 done-when checks: a builder's checks in a repo with no unit suite (open call 10); they live in the T1 report
- moved out: build-swe-pod test_I1_process_md: stale at swe-pod-process@2; superseded by this change's I1
- moved out: build-swe-pod test_I3_d3_templates: stale at swe-pod-process@2; superseded by this change's I3
- moved out: build-swe-pod test_R13_S1_heavy_check_asks_first: the ask before each heavy check is removed (R3 supersedes build-swe-pod/R13)
- moved out: build-swe-pod test_T1_TS4_heavy_from_recorded_run_time: the same removed ask
- moved out: build-swe-pod test_T8_TS3_heavy_verify_with_g3_overlay: the same removed ask
- moved out: build-swe-pod test_R5_S2_tests_promoted_at_integrate: only kept tests are promoted now (R12 supersedes build-swe-pod/R5)

The other tests of the superseded build-swe-pod/R5, R12, R13 and R21 stay,
since their behavior still holds: test_R5_S1_tests_in_change_folder,
test_R12_S1_missing_quality_check, test_R12_S2_no_checks_declared,
test_R21_S1_suggestion_with_computed_value and
test_R21_S2_every_suggestion_has_outcome.

## Costly regression tests not run
69 agent-class tests, about 21540 s expected in all, none run since its last
pass in build-swe-pod's verify:

- test_I8_space_librarian_checks: last pass ev-20261029T0356Z-T19c (agent class, expected 240 s)
- test_R10_S1_test_passes_at_base: last pass ev-20261028T0950Z-T19b (agent class, expected 600 s)
- test_R11_S1_evidence_fields: last pass ev-20261028T0947Z-T19a (agent class, expected 420 s)
- test_R12_S2_no_checks_declared: last pass ev-20261028T0950Z-T19b (agent class, expected 240 s)
- test_R14_S1_merge_order_and_pins: last pass ev-20261028T0947Z-T19a (agent class, expected 240 s)
- test_R14_S2_rulings_in_final_report: last pass ev-20261028T1137Z-T19b (agent class, expected 240 s)
- test_R15_S1_reverify_after_other_change: last pass ev-20261028T0947Z-T19a (agent class, expected 180 s)
- test_R17_S1_remote_test_results_filed: last pass ev-20261028T0947Z-T19a (agent class, expected 240 s)
- test_R17_S2_single_seat_librarian: last pass ev-20261028T1137Z-T19b (agent class, expected 240 s)
- test_R18_S1_fresh_agent_where_are_we: last pass ev-20261028T0947Z-T19a (agent class, expected 120 s)
- test_R18_S2_handoff_reverify_first: last pass ev-20261028T0950Z-T19b (agent class, expected 360 s)
- test_R19_S1_one_question_per_message: last pass ev-20261028T0751Z-T19a (agent class, expected 90 s)
- test_R1_S1_go_without_approval: last pass ev-20261028T1137Z-T19b (agent class, expected 120 s)
- test_R1_S2_edit_after_approval: last pass ev-20261028T0950Z-T19b (agent class, expected 420 s)
- test_R20_S1_status_rebuild_matches: last pass ev-20261028T0947Z-T19a (agent class, expected 240 s)
- test_R21_S1_suggestion_with_computed_value: last pass ev-20261028T0950Z-T19b (agent class, expected 180 s)
- test_R21_S2_every_suggestion_has_outcome: last pass ev-20261028T0950Z-T19b (agent class, expected 240 s)
- test_R22_S1_space_never_branches: last pass ev-20261028T0947Z-T19a (agent class, expected 240 s)
- test_R23_S1_parallel_builders_one_branch: last pass ev-20261028T1137Z-T19b (agent class, expected 480 s)
- test_R23_S2_unnamed_repo_no_branch: last pass ev-20261029T0211Z-T19c (agent class, expected 360 s)
- test_R24_S1_two_shards_verified: last pass ev-20261028T0950Z-T19b (agent class, expected 240 s)
- test_R24_S2_stale_shard_not_verified: last pass ev-20261028T0947Z-T19a (agent class, expected 240 s)
- test_R2_S1_first_change_no_specs: last pass ev-20261028T0950Z-T19b (agent class, expected 600 s)
- test_R2_S2_supersedes_and_test_update: last pass ev-20261028T0947Z-T19a (agent class, expected 600 s)
- test_R3_S1_requirement_without_scenario: last pass ev-20261028T0947Z-T19a (agent class, expected 180 s)
- test_R4_S1_no_process_files_in_code_repo: last pass ev-20261028T1137Z-T19b (agent class, expected 600 s)
- test_R5_S1_tests_in_change_folder: last pass ev-20261028T0947Z-T19a (agent class, expected 420 s)
- test_R6_S1_complete_test_map: last pass ev-20261028T0947Z-T19a (agent class, expected 420 s)
- test_R6_S2_shared_files_ordered: last pass ev-20261028T0950Z-T19b (agent class, expected 420 s)
- test_R7_S1_mesh_dispatch: last pass ev-20261028T0947Z-T19a (agent class, expected 300 s)
- test_R7_S2_local_dispatch: last pass ev-20261028T0947Z-T19a (agent class, expected 600 s)
- test_R8_S1_test_result_in_lane: last pass ev-20261028T0950Z-T19b (agent class, expected 360 s)
- test_R8_S2_builder_disputes_test: last pass ev-20261028T0950Z-T19b (agent class, expected 300 s)
- test_R9_S1_test_brief_contents: last pass ev-20261028T0947Z-T19a (agent class, expected 300 s)
- test_T10_TS1_reference_rule: last pass ev-20261029T0356Z-T19c (agent class, expected 300 s)
- test_T10_TS6_commit_stage_order: last pass ev-20261029T0211Z-T19c (agent class, expected 240 s)
- test_T10_TS8_joined_and_registry_values: last pass ev-20261029T0356Z-T19c (agent class, expected 480 s)
- test_T12_TS1_unmounted_project_blocked: last pass ev-20261029T0356Z-T19c (agent class, expected 600 s)
- test_T12_TS3_load_never_changes_bus: last pass ev-20261029T0356Z-T19c (agent class, expected 240 s)
- test_T13_TS1_result_files_by_rule: last pass ev-20261029T0211Z-T19c (agent class, expected 600 s)
- test_T1_TS1_approval_text_outside_header: last pass ev-20261028T0947Z-T19a (agent class, expected 150 s)
- test_T1_TS2_only_regression_suite_moved: last pass ev-20261028T1137Z-T19b (agent class, expected 180 s)
- test_T1_TS3_single_seat_fresh_planner: last pass ev-20261028T0947Z-T19a (agent class, expected 900 s)
- test_T1_TS5_computed_values_in_other_forms: last pass ev-20261028T0950Z-T19b (agent class, expected 240 s)
- test_T1_TS6_review_dispatched_before_successor: last pass ev-20261028T0947Z-T19a (agent class, expected 480 s)
- test_T2_TS1_spec_from_template_with_comments: last pass ev-20261028T1137Z-T19b (agent class, expected 150 s)
- test_T2_TS2_review_over_two_repos: last pass ev-20261028T0947Z-T19a (agent class, expected 180 s)
- test_T2_TS3_ledger_from_template_not_emptied: last pass ev-20261028T0947Z-T19a (agent class, expected 150 s)
- test_T37_TS1_shard_stale_by_space_commit: last pass ev-20261028T0947Z-T19a (agent class, expected 240 s)
- test_T37_TS2_shards_leave_out_unit_suite: last pass ev-20261028T0950Z-T19b (agent class, expected 240 s)
- test_T37_TS3_report_among_evidence: last pass ev-20261028T0950Z-T19b (agent class, expected 180 s)
- test_T3_TS1_fresh_space_without_status: last pass ev-20261028T0947Z-T19a (agent class, expected 120 s)
- test_T3_TS2_blind_writer_amid_records_and_code: last pass ev-20261028T0950Z-T19b (agent class, expected 600 s)
- test_T3_TS3_placeholder_repo_in_pod_yaml: last pass ev-20261028T0947Z-T19a (agent class, expected 240 s)
- test_T4_TS1_several_requirements_without_scenario: last pass ev-20261028T0947Z-T19a (agent class, expected 180 s)
- test_T4_TS2_approval_relayed_by_lead: last pass ev-20261028T1137Z-T19b (agent class, expected 120 s)
- test_T4_TS3_planner_on_unapproved_spec: last pass ev-20261028T1137Z-T19b (agent class, expected 150 s)
- test_T4_TS5_just_draft_it_lists_defaults: last pass ev-20261028T0950Z-T19b (agent class, expected 240 s)
- test_T5_TS1_plan_request_on_unapproved_spec: last pass ev-20261028T0947Z-T19a (agent class, expected 150 s)
- test_T5_TS3_edit_while_serving_task_runs: last pass ev-20261028T0950Z-T19b (agent class, expected 480 s)
- test_T5_TS5_only_pin_moved: last pass ev-20261028T0950Z-T19b (agent class, expected 180 s)
- test_T6_TS1_no_change_branch_on_remote: last pass ev-20261028T0947Z-T19a (agent class, expected 420 s)
- test_T6_TS3_reviewer_returns_text_only: last pass ev-20261028T0947Z-T19a (agent class, expected 300 s)
- test_T7_TS1_same_minute_events: last pass ev-20261028T0950Z-T19b (agent class, expected 300 s)
- test_T7_TS2_spec_quoting_example_spec: last pass ev-20261028T0947Z-T19a (agent class, expected 180 s)
- test_T7_TS3_ledger_written_in_words: last pass ev-20261029T0211Z-T19c (agent class, expected 180 s)
- test_T7_TS4_template_plan_ruled_review_missing_results: last pass ev-20261028T0947Z-T19a (agent class, expected 240 s)
- test_T8_TS1_install_user_level_then_local_dispatch: last pass ev-20261028T0947Z-T19a (agent class, expected 600 s)
- test_T8_TS2_single_seat_files_through_librarian: last pass ev-20261028T1137Z-T19b (agent class, expected 240 s)
