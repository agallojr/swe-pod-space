# Status: proj:demo

Generated from the records; never edited by hand. As of 2026-10-02T08:00Z.

- pins: alpha a1a1a1a, beta b2b2b2b, gamma c3c3c3c
- open changes: 2 (building: 1, approved: 1)

## add-greeting   state: building   owner: demo-owner

- gates: spec approved by demo-owner 2026-10-01T09:00Z; go by demo-owner
  2026-10-01T09:20Z
- branches: alpha change/add-greeting d4d4d4d; beta change/add-greeting
  b2b2b2b
- tasks:

  | task | role | runs | state | latest |
  |---|---|---|---|---|
  | T1 | build | local | done | DONE, alpha a1a1a1a..d4d4d4d, unit 3/3 pass |
  | T2 | build | local | ready | |
  | T3 | test | local | done | DONE; at base 3 fail, as expected |
  | T4 | review | local | done | spec ok; 0 Important |
  | T5 | review | local | waiting | |
  | T6 | test | local | waiting | |
  | T7 | test | local | waiting | |
  | T8 | review | local | waiting | |
  | T9 | lead | local | waiting | |

- latest evidence: none
- open findings: Critical 0, Important 0, Minor 0
- next: dispatch T2

## add-farewell   state: approved   owner: demo-owner

- gates: spec approved by demo-owner 2026-10-02T08:00Z
- branches: none
- tasks: none; no plan yet
- latest evidence: none
- open findings: Critical 0, Important 0, Minor 0
- next: write the plan
