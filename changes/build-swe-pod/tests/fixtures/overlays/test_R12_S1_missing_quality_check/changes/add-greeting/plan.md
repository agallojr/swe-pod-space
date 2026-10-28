# add-greeting plan

- change: add-greeting
- spec: changes/add-greeting/spec.md

## 1 Goal and approach

Put the greeting text in `alpha` behind one function, and have `beta` print
it on start-up. Two build tasks, one per repo, with `beta`'s after `alpha`'s.

## 2 Interface contract

- `alpha`: `greeting(name: str | None = None) -> str`, in `alpha/greeting.py`.
  With no name it returns `hello, demo`. A name of more than 64 code points
  raises `ValueError`, whose message names the 64-character limit.
- `beta`: `python3 -m beta`, run in the `beta` checkout with the `alpha`
  checkout beside it, prints `greeting()` as its first line.

## 3 Global constraints

- "The name limit is 64 characters, counted as Unicode code points." (spec,
  Open calls 1)
- "its first line of standard output is `hello, demo`, within 1 s of start
  (wall time)" (spec, R2.S1)
- Every number carries its unit.

## 4 File map

- alpha: `alpha/greeting.py` (the greeting and the name limit),
  `tests/test_greeting.py`.
- beta: `beta/__main__.py` (the start-up line), `tests/test_main.py`.

## 5 Tasks

### T1 Greeting text in alpha
- role: build
- repo: alpha
- after: []
- runs: local
- needs: any
- serves: [R1]
- touches: alpha/greeting.py, tests/test_greeting.py
- produces: greeting(name: str | None = None) -> str
- steps: failing test, watch it fail, minimal code, watch it pass, commit
- done when: `python3 -m unittest discover -s tests -t .` passes in
  alpha at the branch head, and the T4 review has no Critical or
  Important finding

### T2 beta prints the greeting
- role: build
- repo: beta
- after: [T1]
- runs: local
- needs: any
- serves: [R2]
- touches: beta/__main__.py, tests/test_main.py
- consumes: greeting() from T1
- steps: failing test, watch it fail, minimal code, watch it pass, commit
- done when: `python3 -m unittest discover -s tests -t .` passes in
  beta at the branch head, and the T5 review has no Critical or
  Important finding

## 6 Test tasks

### T3 Scenario tests R1.S1 to R2.S1
- role: test
- repo: space
- after: []
- runs: local
- needs: any
- serves: [R1, R2]
- touches: changes/add-greeting/tests/
- done when: three test files exist, one per scenario, and each
  fails at the base commit set for its stated reason

### T6 Test suggestions
- role: test
- repo: space
- after: [T1, T2]
- runs: local
- needs: any
- serves: [R1, R2]
- done when: every suggestion routed to the test agent is tested or
  declined with a reason

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
  scenario, unit suite and declared quality check (Q1 and Q2)

## 7 Review tasks

### T4 Review of T1
- role: review
- repo: alpha
- after: [T1]
- runs: local
- needs: any
- serves: [R1]
- done when: changes/add-greeting/tasks/T1-review.md holds a verdict

### T5 Review of T2
- role: review
- repo: beta
- after: [T2]
- runs: local
- needs: any
- serves: [R2]
- done when: changes/add-greeting/tasks/T2-review.md holds a verdict

### T8 Whole-change review
- role: review
- repo: space
- after: [T7]
- runs: local
- needs: any
- serves: [R1, R2]
- done when: changes/add-greeting/tasks/T8-review.md holds a verdict

## 8 Integrate task

### T9 Integrate
- role: lead
- repo: space
- after: [T7, T8]
- runs: local
- needs: any
- serves: [R1, R2]
- docs: the README of alpha and of beta; no open plan depends on this
  change
- done when: merged in depends order, tests promoted, pins advanced,
  final report filed

## 9 Test map

| Scenario | Test | Mode | Writes it |
|---|---|---|---|
| R1.S1 | test_R1_S1_default_greeting | inspect | T3 |
| R1.S2 | test_R1_S2_name_too_long | inspect | T3 |
| R2.S1 | test_R2_S1_startup_line | inspect | T3 |

## 10 Dependency summary

T1 and T3 start at the go. T2 waits for T1. The longest chain is T1, T2, T6,
T7, T8, T9. No two tasks touch a common file.

## Self-review

Every requirement maps to a build task (R1 to T1, R2 to T2). Every scenario
maps to a test. No step says TBD. Names and types agree across tasks. Every
task has role, after, runs and done-when.

## Questions for the spec

None.
