# T3 brief

- change: add-greeting
- task: T3
- role: test
- repo: space

## Task

From plan.md, verbatim:

### T3 Scenario tests R1.S1 to R2.S1
- role: test
- repo: space
- after: []
- runs: mesh
- needs: linux-server
- serves: [R1, R2]
- touches: changes/add-greeting/tests/
- done when: three test files exist, one per scenario, and each
  fails at the base commit set for its stated reason

## Spec

changes/add-greeting/spec.md

## Interface contract

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

## Test map

| Scenario | Test | Mode | Writes it |
|---|---|---|---|
| R1.S1 | test_R1_S1_default_greeting | inspect | T3 |
| R1.S2 | test_R1_S2_name_too_long | inspect | T3 |
| R2.S1 | test_R2_S1_startup_line | inspect | T3 |

## Start from

- base commit set: space 5d5d5d5, alpha a1a1a1a, beta b2b2b2b, gamma c3c3c3c
- commit set under test: later, at T7

## Result goes to

- changes/add-greeting/tests/: one test file per scenario
- the T3 report: changes/add-greeting/tasks/T3-report.md

Do not read plan.md, ledger.md, any other brief, report or review, or any code-repo diff or implementation body.
