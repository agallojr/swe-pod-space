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
```
