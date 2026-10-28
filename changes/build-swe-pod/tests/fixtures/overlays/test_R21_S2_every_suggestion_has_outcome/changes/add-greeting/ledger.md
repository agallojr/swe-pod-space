# Ledger: add-greeting

```
2026-10-01T09:00Z spec approved by demo-owner
2026-10-01T09:20Z go by demo-owner; branches change/add-greeting: alpha a1a1a1a, beta b2b2b2b
2026-10-01T09:21Z dispatch T1 -> build (local, any), base alpha a1a1a1a
2026-10-01T09:21Z dispatch T3 -> test (local, any)
2026-10-01T09:55Z T1 DONE, alpha a1a1a1a..d4d4d4d, unit 3/3 pass
2026-10-01T09:56Z filed changes/add-greeting/tasks/T1-report.md
2026-10-01T09:57Z T1.TS1 -> test
2026-10-01T09:57Z T1.TS2 -> builder
2026-10-01T09:56Z dispatch T4 -> review (local, any)
2026-10-01T10:05Z T1 review: spec ok; 0 Important
2026-10-01T10:06Z filed changes/add-greeting/tasks/T1-review.md
2026-10-01T10:20Z T3 DONE
2026-10-01T10:21Z T3 at base: test_R1_S1_default_greeting fail (no greeting in alpha),
                  test_R1_S2_name_too_long fail (no greeting in alpha), test_R2_S1_startup_line
                  fail (beta prints nothing)
2026-10-01T10:22Z filed changes/add-greeting/tests/test_R1_S1_default_greeting.md,
                  changes/add-greeting/tests/test_R1_S2_name_too_long.md,
                  changes/add-greeting/tests/test_R2_S1_startup_line.md, changes/add-greeting/tasks/T3-report.md
2026-10-01T10:25Z T1.TS2 outcome: unit-tested
2026-10-01T10:30Z dispatch T2 -> build (local, any), base beta b2b2b2b
2026-10-01T11:05Z T2 DONE, beta b2b2b2b..e5e5e5e, unit 2/2 pass
2026-10-01T11:06Z filed changes/add-greeting/tasks/T2-report.md
2026-10-01T11:06Z T2.TS1 -> test
2026-10-01T11:06Z T2.TS2 -> spec
2026-10-01T11:06Z dispatch T5 -> review (local, any)
2026-10-01T11:15Z T2 review: spec ok; 1 Minor beta/beta/__main__.py:3
2026-10-01T11:16Z filed changes/add-greeting/tasks/T2-review.md
2026-10-01T11:16Z dispatch T6 -> test (local, any)
2026-10-01T11:25Z T6 DONE
2026-10-01T11:25Z T1.TS1 outcome: tested test_T1_TS1_combining_marks
2026-10-01T11:25Z T2.TS1 outcome: declined: R2.S1 bounds start-up on the evidence's environment class,
                  and a slow network disk is not one
2026-10-01T11:28Z T2.TS2 outcome: proposed as scenario
2026-10-01T11:26Z filed changes/add-greeting/tasks/T6-report.md
2026-10-01T11:30Z dispatch T7 -> test (local, any)
2026-10-01T12:30Z T7 DONE
2026-10-01T12:31Z filed changes/add-greeting/evidence/20261001T1230Z.md, changes/add-greeting/tasks/T7-report.md
2026-10-01T12:35Z dispatch T8 -> review (local, any)
2026-10-01T13:10Z T8 review: spec ok; 1 Minor beta/beta/__main__.py:3
2026-10-01T13:11Z filed changes/add-greeting/tasks/T8-review.md
```
