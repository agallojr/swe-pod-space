# add-greeting: ledger

```
2026-11-01T09:00Z spec approved by demo-owner
2026-11-01T09:40Z filed changes/add-greeting/plan.md
2026-11-01T10:30Z go by demo-owner; branches change/add-greeting: alpha a1a1a1a, beta b2b2b2b
2026-11-01T10:31Z dispatch T1 -> build (local, any), base alpha a1a1a1a
2026-11-01T10:31Z dispatch T3 -> test (local, any)
2026-11-01T11:02Z T1 DONE, alpha a1a1a1a..d4d4d4d, unit 3/3 pass
2026-11-01T11:03Z dispatch T4 -> review (local, any)
2026-11-01T11:03Z dispatch T2 -> build (local, any), base beta b2b2b2b
2026-11-01T11:20Z T3 DONE
2026-11-01T11:24Z T3 at base: test_R1_S1_default_greeting fail (no greeting in alpha),
                  test_R1_S2_name_too_long fail (no greeting in alpha),
                  test_R2_S1_startup_line fail (beta prints nothing)
2026-11-01T11:25Z filed changes/add-greeting/tests/test_R1_S1_default_greeting.md,
                  changes/add-greeting/tests/test_R1_S2_name_too_long.md,
                  changes/add-greeting/tests/test_R2_S1_startup_line.md
2026-11-01T11:31Z T4 review: spec ok; 1 Minor alpha/greeting.py:9
2026-11-01T11:58Z T2 DONE, beta b2b2b2b..e5e5e5e, unit 4/4 pass
2026-11-01T11:59Z dispatch T5 -> review (local, any)
2026-11-01T11:59Z dispatch T6 -> test (local, any)
2026-11-01T12:20Z T5 review: spec issues; 1 Important beta/main.py:14
2026-11-01T12:21Z T6 DONE
2026-11-01T12:40Z T2 fix round 1/5: 1 addressed, 0 open, e5e5e5e..f6f6f6f
2026-11-01T13:29Z filed changes/add-greeting/tasks/T7a-brief.md,
                  changes/add-greeting/tasks/T7b-brief.md
2026-11-01T13:30Z dispatch T7a -> test (local, macos-laptop)
2026-11-01T13:30Z dispatch T7b -> test (mesh, linux-server)
2026-11-01T14:12Z T7a DONE
2026-11-01T14:13Z filed changes/add-greeting/evidence/20261101T1412Z-T7a.md
2026-11-01T14:20Z T7b BLOCKED
2026-11-01T14:30Z Ruling: T7b runs beta's unit suite with alpha on PYTHONPATH; the first
                  run lacked it; cost if wrong: one more T7b run
2026-11-01T14:35Z filed changes/add-greeting/tasks/T7b-brief.md
2026-11-01T14:36Z dispatch T7b -> test (mesh, linux-server)
2026-11-01T15:00Z T7b DONE
2026-11-01T15:02Z filed changes/add-greeting/evidence/20261101T1500Z-T7b.md
2026-11-01T15:05Z dispatch T8 -> review (local, any)
2026-11-01T15:40Z T8 review: spec ok; 1 Minor alpha/greeting.py:9
2026-11-01T15:41Z filed changes/add-greeting/tasks/T8-review.md
```
