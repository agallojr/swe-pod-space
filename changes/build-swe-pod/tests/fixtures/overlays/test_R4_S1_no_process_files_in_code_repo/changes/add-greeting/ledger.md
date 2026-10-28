# Ledger: add-greeting

```
2026-11-01T09:00Z spec approved by demo-owner
2026-11-01T09:30Z go by demo-owner; branches change/add-greeting: alpha {{A0}}, beta {{B0}}
2026-11-01T09:31Z dispatch T1 -> build (local, any), base alpha {{A0}}
2026-11-01T09:31Z dispatch T3 -> test (local, any)
2026-11-01T10:20Z T1 DONE, alpha {{A0}}..{{A1}}, unit 4/4 pass
2026-11-01T10:25Z dispatch T4 -> review (local, any)
2026-11-01T10:40Z T3 DONE
2026-11-01T10:41Z T3 at base: test_R1_S1_default_greeting fail (no greeting),
                  test_R1_S2_name_too_long fail (no greeting),
                  test_R2_S1_startup_line fail (no greeting line)
2026-11-01T10:50Z T4 review: spec ok; 1 Minor alpha/alpha/__init__.py:5
2026-11-01T10:51Z dispatch T2 -> build (local, any), base beta {{B0}}
2026-11-01T11:40Z T2 DONE, beta {{B0}}..{{B1}}, unit 2/2 pass
2026-11-01T11:45Z dispatch T5 -> review (local, any)
2026-11-01T12:00Z T5 review: spec ok; 0 Minor
2026-11-01T12:01Z dispatch T6 -> test (local, any)
2026-11-01T12:20Z T6 DONE
2026-11-02T14:05Z dispatch T7 -> test (local, any)
2026-11-02T14:12Z T7 DONE
2026-11-02T14:30Z dispatch T8 -> review (local, any)
2026-11-02T15:10Z T8 review: spec ok; 0 Minor
```
