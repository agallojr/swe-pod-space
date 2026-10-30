# Ledger: right-size-testing

```
2026-10-30T16:03Z spec approved by agallojr
2026-10-30T16:15Z go by agallojr; branches change/right-size-testing: swe-pod b7fc257
2026-10-30T16:19Z Ruling: this change runs under its own rules from the go, though
                  the space still pins swe-pod-process@1: risk-named tests, the plan's
                  estimates and asks, targeted verify, the green rule with not-selected
                  and superseded, one review, and every role on the most capable model;
                  why: open call 2 of the approved spec, and the operator's go at small
                  size; cost if wrong: one change verified under rules the space has not
                  yet pinned, which integrate pins as swe-pod-process@2
2026-10-30T16:22Z filed changes/right-size-testing/ledger.md
2026-10-30T16:22Z filed changes/right-size-testing/plan.md
2026-10-30T16:22Z Ruling: the one review, T4, runs after T1 and its fix wave and before
                  verify, which then runs once at the final commit set and takes Q1 from
                  the review; why: open call 2 orders build, test, review, verify, and a
                  review after verify would need a second verify after its fix wave;
                  cost if wrong: a code fault verify finds needs a fix and a review of
                  that fix diff alone
2026-10-30T16:22Z Ruling: build-swe-pod's checks I1.2 and I3.14 go stale when swe-pod
                  moves to swe-pod-process@2 (open call 16); T3 writes replacements at
                  @2, verify gives build-swe-pod/I1 and build-swe-pod/I3 superseded by I1
                  and superseded by I3 under plan 2.4, and integrate moves the two old
                  tests to build-swe-pod's superseded-tests; why: both are picked
                  script-class tests, and neither may hold the evidence red nor be ruled
                  green by hand; cost if wrong: the green rule's superseded case also
                  takes I-check keys, which R5's tests and the review must accept
2026-10-30T16:22Z Ruling: STATUS.md is regenerated with the swe-pod skill at the branch
                  head once T1 lands, and with the installed skill until then; why: this
                  change runs under its own rules from the go; cost if wrong: STATUS.md
                  reads this change's evidence by the old rule until T1 lands
2026-10-30T16:24Z filed changes/right-size-testing/ledger.md
2026-10-30T16:24Z filed changes/right-size-testing/tasks/T1-brief.md, changes/right-size-testing/tasks/T2-brief.md,
                  changes/right-size-testing/tasks/T3-brief.md
2026-10-30T16:25Z dispatch T1 -> build (local, any), base swe-pod b7fc257
2026-10-30T16:25Z dispatch T2 -> test (local, macos-laptop)
2026-10-30T16:25Z dispatch T3 -> test (local, any)
2026-10-30T16:26Z filed STATUS.md
2026-10-30T16:31Z filed changes/right-size-testing/tasks/T1-brief.md, changes/right-size-testing/tasks/T2-brief.md,
                  changes/right-size-testing/tasks/T3-brief.md (plan section 2 whole; the first
                  copies stopped inside 2.9)
2026-10-30T16:31Z T3 DONE
2026-10-30T16:31Z T3 at base: test_I1_process_md fail (I1.2: PROCESS.md line 3 is
                  swe-pod-process@1), test_I3_d3_templates fail (I3.14: the template pod.yaml
                  pins swe-pod-process@1)
2026-10-30T16:31Z T3 cost: actual 1 s, 0 USD; estimate 2 s, 0 USD
2026-10-30T16:31Z filed changes/right-size-testing/tests/test_I1_process_md.md,
                  changes/right-size-testing/tests/test_I3_d3_templates.md,
                  changes/right-size-testing/evidence/20261030T1628Z-T3-report.md
2026-10-30T16:51Z T2 DONE_WITH_CONCERNS
2026-10-30T16:51Z T2 at base: test_R5_S1_not_selected_green fail (no not-selected count or
                  rule at base), test_R5_S2_superseded_with_replacement fail (no superseded
                  count or rule at base), test_R5_S3_superseded_without_replacement fail (the
                  control, R5.S2's record, is not green under the base rule),
                  test_R5_S4_picked_test_not_passed fail (the control, a targeted record, is
                  not green under the base rule)
2026-10-30T16:51Z T2 cost: actual 266 s, 1.34 USD; estimate 570 s, 2.45 USD
2026-10-30T16:51Z Ruling: the managed policy T2's smoke reports, the gateway settings drop-in
                  and the remote managed settings, is accepted under test isolation, as
                  build-swe-pod ruled at 2026-10-28T02:59Z; why: it pins the model, adds
                  denials and gateway variables, adds no instruction file and loosens no
                  fence; cost if wrong: an agent-class result reflects node policy
2026-10-30T16:51Z Ruling: T2's two script-class tests read the rule's words together in one
                  paragraph and contract 2.5's status form, and stand as written; a correct
                  rule they fail goes back to the test agent with the spec clause; why: 2.5
                  is the contract, and T4 reads them for a change detector; cost if wrong: a
                  false fail at verify and one test fix
2026-10-30T16:51Z filed changes/right-size-testing/tests/test_R5_S1_not_selected_green.md,
                  changes/right-size-testing/tests/test_R5_S2_superseded_with_replacement.md,
                  changes/right-size-testing/tests/test_R5_S3_superseded_without_replacement.md,
                  changes/right-size-testing/tests/test_R5_S4_picked_test_not_passed.md,
                  changes/right-size-testing/evidence/20261030T1649Z-T2-report.md
2026-10-30T16:58Z T1 DONE_WITH_CONCERNS, swe-pod b7fc257..0debc5a
2026-10-30T16:58Z filed changes/right-size-testing/tasks/T1-report.md
2026-10-30T16:59Z T1.TS1 outcome: declined: covered by test_R5_S3_superseded_without_replacement,
                  whose supersedes check is the one an I-check key takes, and by T5's own
                  record, which gives build-swe-pod/I1 and build-swe-pod/I3 superseded by I1
                  and superseded by I3
2026-10-30T16:59Z T1.TS2 outcome: declined: no fixture has a readable code repo; the lead
                  checks T5's touched list against swe-pod's diff from b7fc257 to the head
                  before the verified call, and T4 reads the skill's diff check
2026-10-30T16:59Z T1.TS3 outcome: declined: covered by test_R5_S4_picked_test_not_passed and by
                  T5's own picks, I2 to I5 and test_R12_S1_missing_quality_check, whose
                  deliverables are folders and aliases
2026-10-30T16:59Z T1.TS4 outcome: declined: this change's verify is not sharded and the spec
                  gives R5's sharded clause no scenario; T4 reads the combined-records rule
2026-10-30T16:59Z T1.TS5 outcome: declined: a change's own scenarios, unit suites and quality
                  checks still need a pass, a rule this change keeps and
                  test_R12_S1_missing_quality_check guards; T4 reads the sentence that limits
                  the no-bar results to regression tests
2026-10-30T16:59Z dispatch T4 -> review (local, any)
2026-10-30T17:18Z T1 review: spec issues; 4 Important swe-pod/PROCESS.md:723,
                  swe-pod/skills/swe-pod/status-format.md:178, swe-pod/skills/swe-pod/SKILL.md:114,
                  space/changes/right-size-testing/tasks/T1-report.md:940; 18 Minor
2026-10-30T17:18Z T4 review: spec issues; 4 Important, 18 Minor; Q1 fail
2026-10-30T17:18Z filed changes/right-size-testing/tasks/T4-review.md
2026-10-30T17:19Z Ruling: R7's declined covers a suggestion bound for the test agent that a
                  planned test covers; the routes to the spec author (behavior the spec does
                  not state) and back to the builder (internal only) stay; why: both R7
                  scenarios are about suggestions bound for the test agent, and
                  build-swe-pod/R21.S2, which stays in the suite, needs the proposed-as-
                  scenario and unit-tested outcomes; cost if wrong: a suggestion R7 meant to
                  decline reaches the spec author or the builder
2026-10-30T17:19Z Ruling: an unlisted script-class run needs no ask (R3); why: R3's only when
                  limits the ask, and the spec puts the cost in agent-class and live-class
                  runs, as T4 confirmed; cost if wrong: an unlisted script check runs with no
                  word from the operator
2026-10-30T17:19Z Ruling: T4's wave-review finding at swe-pod/skills/swe-pod/SKILL.md:114 is in
                  scope and fixed in this wave, not parked; why: R10 brings wave reviews in,
                  and the skill must read their state; the out-of-scope item is only the
                  first id of a Reviews cell; cost if wrong: one more skill rule in this wave
2026-10-30T17:19Z Ruling: the whole-change fix wave carries T4's 4 Important findings and,
                  batched with them, its 18 Minor ones; why: open call 12 and R11, a fix wave
                  that runs for an Important finding also takes the batched Minors; cost if
                  wrong: a longer fix wave
2026-10-30T17:19Z dispatch T1 -> build (local, any), base swe-pod 0debc5a
2026-10-30T17:33Z T1 DONE_WITH_CONCERNS, swe-pod 0debc5a..3b22a1b
2026-10-30T17:33Z T1 fix round 1/5: 21 addressed, 1 open, 0debc5a..3b22a1b
2026-10-30T17:33Z Ruling: T4's Minor at swe-pod/templates/records/review.md:18 is parked; why:
                  the review template is outside the plan's file map, and swe-review's Quality
                  section now names the R6 check; cost if wrong: a reviewer working from the
                  template alone may skip that check
2026-10-30T17:33Z filed changes/right-size-testing/tasks/T1-report.md
2026-10-30T17:33Z dispatch T4 -> review (local, any)
2026-10-30T17:40Z T1 review r1: spec ok; 1 Minor swe-pod/agents/swe-plan.md:103
2026-10-30T17:40Z T4 review r1: spec ok; 1 Minor; Q1 pass
2026-10-30T17:40Z Ruling: T4's re-review Minor, the reflow defect at swe-pod/agents/swe-plan.md:103
                  and two short lines at swe-pod/PROCESS.md:367 and :484, is parked; why: a
                  Minor finding starts no fix round (R11) and the one whole-change fix wave
                  has run; cost if wrong: three unevenly wrapped lines ship in
                  swe-pod-process@2
2026-10-30T17:40Z filed changes/right-size-testing/tasks/T4-review-r1.md
2026-10-30T17:41Z dispatch T5 -> test (local, macos-laptop)
2026-10-30T17:59Z T5 DONE_WITH_CONCERNS
2026-10-30T17:59Z T5 cost: actual 416 s, 2.00 USD; estimate 720 s, 3.20 USD
2026-10-30T17:59Z Ruling: T5's third smoke, a rerun after a false fail in the runner's smoke
                  judge S4, counts as a rerun of a listed run and needed no ask; why: the
                  change's expensive runs stood at 682 s and 3.34 USD, within twice the
                  1260 s and 5.65 USD estimate (R3); cost if wrong: one unlisted 96 s,
                  0.41 USD run went ahead with no word from the operator
2026-10-30T17:59Z Ruling: Q1 is read from the re-review, T4-review-r1.md, as T5 did, though
                  its brief named T4-review.md; why: the latest review of T4 decides Q1;
                  cost if wrong: none, the first review's Q1 fail was closed by the fix wave
2026-10-30T17:59Z filed changes/right-size-testing/evidence/20261030T1742Z.md,
                  changes/right-size-testing/evidence/20261030T1742Z-T5-report.md
```
