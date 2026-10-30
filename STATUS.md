# Status: proj:swe-pod

Generated from the records; never edited by hand. As of 2026-10-30T17:59Z.

- pins: swe-pod b7fc257, agent-mesh f27c611
- open changes: 1 (verified: 1)

## right-size-testing   state: verified   owner: agallojr

- gates: spec agallojr 2026-10-30T16:03Z, go agallojr 2026-10-30T16:15Z
- branches: change/right-size-testing: swe-pod 3b22a1b
- tasks: waiting 0, ready 1, dispatched 0, done 5, blocked 0

| task | role | runs | state | latest |
|---|---|---|---|---|
| T1 | build | local | done | 2026-10-30T17:33Z fix round 1/5: 21 addressed, 1 open |
| T2 | test | local | done | 2026-10-30T16:51Z at base: 4 fail, 0 pass |
| T3 | test | local | done | 2026-10-30T16:31Z at base: 2 fail, 0 pass |
| T4 | review | local | done | 2026-10-30T17:40Z review r1: spec ok; 1 Minor |
| T5 | test | local | done | 2026-10-30T17:59Z DONE_WITH_CONCERNS |
| T6 | lead | local | ready | - |

- latest evidence: ev-20261030T1742Z, macos-laptop, green: scenarios 30/30 pass, regression 5/5 pass, 83 not-selected, 2 superseded, unit swe-pod none-present, quality 1/1 pass, x-checks 2/2 pass
- open findings: Critical 0, Important 0, Minor 38
- next: T6 -> lead (local, any)
