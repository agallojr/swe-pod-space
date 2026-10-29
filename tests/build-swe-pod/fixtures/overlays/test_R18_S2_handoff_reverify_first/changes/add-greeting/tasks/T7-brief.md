# T7 brief

- change: add-greeting
- task: T7
- role: test
- repo: space

## Task

From plan.md, verbatim:

### T7 Verify
- role: test
- repo: space
- after: [T1, T2, T3, T6]
- runs: local
- needs: any
- serves: [R1, R2]
- steps: run every project-level test in changes/add-greeting/tests/
  and tests/, each affected repo's unit tests, and every quality
  check the spec declares, at the commit set of the brief
- done when: an evidence record is filed with a result for every
  scenario, unit suite and declared quality check

## Interfaces

From plan.md section 2:

- `alpha`: `greeting(name: str | None = None) -> str`, in `alpha/greeting.py`.
  With no name it returns `hello, demo`. A name of more than 64 code points
  raises `ValueError`, whose message names the 64-character limit.
- `beta`: `python3 -m beta`, run in the `beta` checkout with the `alpha`
  checkout beside it, prints `greeting()` as its first line.

## Global constraints

- "The name limit is 64 characters, counted as Unicode code points." (spec,
  Open calls 1)
- "its first line of standard output is `hello, demo`, within 1 s of start
  (wall time)" (spec, R2.S1)
- Every number carries its unit.

## Rulings

None.

## Start from

- commit set under test: space 5d5d5d5, alpha d4d4d4d, beta e5e5e5e,
  gamma c3c3c3c (gamma is not named by the spec and stays at its pin)

## Result goes to

- the evidence record: changes/add-greeting/evidence/<YYYYMMDDTHHMMZ>.md
- the T7 report: changes/add-greeting/tasks/T7-report.md
