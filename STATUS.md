# Status: proj:swe-pod

Generated from the records; never edited by hand. As of 2026-10-30T16:59Z.

- pins: swe-pod b7fc257, agent-mesh f27c611
- open changes: 1 (building: 1)

## right-size-testing   state: building   owner: agallojr

- gates: spec agallojr 2026-10-30T16:03Z, go agallojr 2026-10-30T16:15Z
- branches: change/right-size-testing: swe-pod 0debc5a
- tasks: waiting 2, ready 0, dispatched 2, done 2, blocked 0

| task | role | runs | state | latest |
|---|---|---|---|---|
| T1 | build | local | dispatched | 2026-10-30T16:58Z DONE_WITH_CONCERNS, swe-pod b7fc257..0debc5a |
| T2 | test | local | done | 2026-10-30T16:51Z at base: 4 fail, 0 pass |
| T3 | test | local | done | 2026-10-30T16:31Z at base: 2 fail, 0 pass |
| T4 | review | local | dispatched | 2026-10-30T16:59Z dispatch -> review (local, any) |
| T5 | test | local | waiting | - |
| T6 | lead | local | waiting | - |

- latest evidence: none
- open findings: Critical 0, Important 0, Minor 0
- next: none ready; dispatched: T1, T4
