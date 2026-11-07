# Ledger: add-size-gauge

```
2026-11-07T17:23Z spec approved by agallojr
2026-11-07T17:29Z Ruling: every pod agent of this change is started by the lead
                  with model opus set on the dispatch; the role files still say
                  model: inherit until T1 changes them, and the session is not
                  on Opus; cost if wrong: a task would run on the session's
                  model, a lesser one
2026-11-07T17:29Z Ruling: build-swe-pod/R9 added to the spec's supersedes at
                  planning, a header edit with no requirement text changed;
                  verify can then give build-swe-pod/I2 superseded by I2; cost
                  if wrong: the old I2 fails at the head and blocks green
2026-11-07T17:29Z filed changes/add-size-gauge/spec.md, changes/add-size-gauge/plan.md, changes/add-size-gauge/tasks/T1-brief.md, changes/add-size-gauge/tasks/T2-brief.md, changes/add-size-gauge/tasks/T3-brief.md
2026-11-07T17:29Z go by agallojr; branches change/add-size-gauge: swe-pod 3b22a1b
2026-11-07T17:30Z dispatch T1 -> build (local, any), base swe-pod 3b22a1b
2026-11-07T17:30Z dispatch T2 -> test (local, any)
2026-11-07T17:30Z dispatch T3 -> test (local, any)
2026-11-07T17:54Z filed changes/add-size-gauge/tests/test_I1_process_md.md, changes/add-size-gauge/tests/test_I2_role_definitions.md, changes/add-size-gauge/tests/test_I3_d3_templates.md, changes/add-size-gauge/evidence/20261107T1735Z-T3-report.md
2026-11-07T17:54Z T3 DONE
2026-11-07T17:54Z T3 at base: test_I1_process_md fail (I1.2 version line is @2; I1.7 first column is small, project, spike), test_I2_role_definitions fail (I2.2 six role files say model: inherit), test_I3_d3_templates fail (I3.14 pod.yaml gives @2)
2026-11-07T17:54Z T1 DONE_WITH_CONCERNS, swe-pod 3b22a1b..61d67db
2026-11-07T17:54Z T1.TS2 -> spec
2026-11-07T17:54Z T1.TS2 outcome: dropped
2026-11-07T17:54Z Ruling: the ledger event plan skimmed by <handle> stays, though
                  plan 2.5 did not list it; R8.S1 needs the records to tell a
                  skimmed large plan from one nobody has skimmed; the skill
                  reads it only for its time; cost if wrong: one ledger form
                  to remove, no change to the skill
2026-11-07T17:54Z Ruling: T1.TS2 is dropped, an open spec sized under the old
                  names is not given a legacy reading; the only open spec in
                  this space is this one, and it integrates with the move to
                  @3, while other spaces move their own pins (spec Out); cost
                  if wrong: a spec approved as medium runs as small in
                  another space after its pin moves, until the operator
                  re-sizes it
2026-11-07T17:54Z Ruling: tests/build-swe-pod/test_T1_TS3_single_seat_fresh_planner.md
                  quotes wording the change removes ("project size"); it is
                  agent class and not run at verify; integrate moves it to
                  superseded-tests as made stale, with no replacement; cost if
                  wrong: no regression test of the single-seat fresh planner
                  until one is rewritten
2026-11-07T17:54Z dispatch T4 -> review (local, any), base swe-pod 3b22a1b
2026-11-07T17:55Z T2 DONE
2026-11-07T17:55Z T2 at base: test_R4_S1_terse_plan_sections fail (no small passage leaves out the plan sections), test_R4_S2_terse_plan_meets_skill_rules fail (no terse plan defined), test_R10_S1_role_files_model_opus fail (six role files say model: inherit), test_R10_S2_no_text_allows_lesser_model fail (model: inherit and "most capable model" in the text), test_R13_S1_small_cap_then_ruling fail (no size table rows; clauses allow 5 rounds), test_R13_S2_large_cap_same_builder fail (no cap of 3; rounds 4 and 5 to a fresh builder), test_R13_S3_spec_cause_goes_to_author fail (no passage sends a cap hit to the spec author), test_R13_S4_fix_round_line_carries_cap fail (forms are fix round <r>/5)
2026-11-07T17:55Z T1.TS1 -> test: covers a cap ruling the status view must read as closing the finding
2026-11-07T17:55Z filed changes/add-size-gauge/tasks/T1-report.md, changes/add-size-gauge/tasks/T4-brief.md, changes/add-size-gauge/tasks/T7-brief.md, changes/add-size-gauge/plan.md, the 8 tests of T2 and changes/add-size-gauge/evidence/20261107T1753Z-T2-report.md
2026-11-07T17:55Z dispatch T7 -> test (local, any)
2026-11-07T18:07Z T1 review: spec issues; 2 Important swe-pod/PROCESS.md:879, swe-pod/agents/swe-lead.md:424, 13 Minor
2026-11-07T18:07Z T4 review: spec issues; 2 Important, 15 Minor; Q1 fail
2026-11-07T18:07Z Ruling: T4's Minor findings in swe-pod are fixed in the whole-change fix
                  wave with its Important ones, not parked; why: under
                  swe-pod-process@2 the wave takes the batched Minors, and they
                  are wording disagreements that Q1 counts; cost if wrong: one
                  more round of doc edits
2026-11-07T18:07Z Ruling: for a size amendment, the operator's word that names the new size
                  is the approval of the amendment; no task is held and no
                  approval reopened line is written, as a size line is no
                  requirement; why: R3.S2 reopens approval for the amendment
                  only and the skill holds tasks only for a requirement; cost
                  if wrong: the text says one sentence more than the spec
2026-11-07T18:07Z Ruling: at small, the one review's fix round carries the Critical and
                  Important findings only, the Minor findings are parked by one
                  ruling and listed in the final report, and the cap ruling
                  begins Ruling: T<n> open findings; at medium and large the
                  whole-change fix wave takes the batched Minors as before;
                  why: R6.S1, R13.S1 and T1.TS1; cost if wrong: a small change
                  carries Minors to the final report instead of fixing them
2026-11-07T18:07Z Ruling: T4's Minor at plan.md:289 is fixed in the plan, not in swe-pod:
                  R4.S3 is T1's check C4, and T2 tests R4.S1 and R4.S2; why: it
                  is a lead behavior that does not carry R4's risk with the
                  skill; cost if wrong: one scenario of an at-risk requirement
                  has no blind test
2026-11-07T18:07Z Ruling: T4's Minor on the kept test fixtures (size: project and fix round
                  1/5 lines) is parked, nothing edited; why: they are inputs of
                  agent-class tests that verify does not pick, the skill reads
                  fix round lines by their prefix and reads no size name, and
                  only test_T1_TS3 asserts the removed wording (ruled
                  17:54Z); cost if wrong: an agent-class test fails when
                  someone runs it
2026-11-07T18:07Z filed changes/add-size-gauge/tasks/T4-review.md, changes/add-size-gauge/plan.md
2026-11-07T18:10Z T7 DONE
2026-11-07T18:10Z T7 at base: test_T1_TS1_cap_ruling_closes_finding fail (check T1.TS1.4: the base status view closes findings only on a Ruling: T<n> open findings line, and the base text gives only the general Ruling form)
2026-11-07T18:10Z T1.TS1 outcome: tested test_T1_TS1_cap_ruling_closes_finding
2026-11-07T18:10Z T7 at head: test_T1_TS1_cap_ruling_closes_finding fail at swe-pod 61d67db (check T1.TS1.4: PROCESS.md section 13 Rulings item and one unit of agents/swe-lead.md give the cap ruling only in the general form); routed to T1 fix round 1 as a further finding
2026-11-07T18:10Z filed changes/add-size-gauge/tests/test_T1_TS1_cap_ruling_closes_finding.md, changes/add-size-gauge/evidence/20261107T1809Z-T7-report.md
2026-11-07T18:18Z T1 fix round 1/5: 15 addressed, 0 open, 61d67db..7168579
2026-11-07T18:18Z Ruling: the plan's done-when "skills/swe-pod/ names no size" is read as
                  names no size name (small, medium, large, spike, project
                  size), not as banning the word size; why: R4.S2 check 4 needs
                  the skill's skim lines to say the skim depends on the size;
                  cost if wrong: a skill line says size where a stricter reading
                  wanted a pointer to the lead
2026-11-07T18:18Z dispatch T4 -> review (local, any), base swe-pod 61d67db
```
