# add-greeting plan

- change: add-greeting
- spec: changes/add-greeting/spec.md

## 1 Goal and approach

Build the greeting text and the name limit in `alpha` as two parallel
tasks, join them, then have `beta` print the greeting.

## 2 Interface contract

- `alpha`: `greeting(name: str | None = None) -> str`, in `alpha/greeting.py`.
  With no name it returns `hello, demo`. A name of more than 64 code points
  raises `ValueError`, whose message names the 64-character limit.
- `beta`: `python3 -m beta`, run in the `beta` checkout with the `alpha`
  checkout beside it, prints `greeting()` as its first line.
- `alpha`: `check_name(name: str) -> None`, in `alpha/limits.py`.

## 3 Global constraints

- "The name limit is 64 characters, counted as Unicode code points." (spec,
  Open calls 1)
- "its first line of standard output is `hello, demo`, within 1 s of start
  (wall time)" (spec, R2.S1)
- Every number carries its unit.

## 4 File map

- alpha: `alpha/greeting.py`, `tests/test_greeting.py` (T1, then T3);
  `alpha/limits.py`, `tests/test_limits.py` (T2).
- beta: `beta/__main__.py`, `tests/test_main.py` (T4).

## 5 Tasks

### T1 Greeting text in alpha
- role: build
- repo: alpha
- after: []
- runs: local
- needs: any
- serves: [R1]
- touches: alpha/greeting.py, tests/test_greeting.py
- produces: greeting(name: str | None = None) -> str; no name gives
  `hello, demo`, a name gives `hello, <name>`
- steps: failing test, watch it fail, minimal code, watch it pass, commit
- done when: `python3 -m unittest discover -s tests -t .` passes in
  alpha at the branch head, and the T6 review has no Critical or
  Important finding

### T2 Name limit in alpha
- role: build
- repo: alpha
- after: []
- runs: local
- needs: any
- serves: [R1]
- touches: alpha/limits.py, tests/test_limits.py
- produces: check_name(name: str) -> None, raising ValueError that
  names the 64-character limit for more than 64 code points
- steps: failing test, watch it fail, minimal code, watch it pass, commit
- done when: `python3 -m unittest discover -s tests -t .` passes in
  alpha at the branch head, and the T7 review has no Critical or
  Important finding

### T3 Greeting checks the name
- role: build
- repo: alpha
- after: [T1, T2]
- runs: local
- needs: any
- serves: [R1]
- touches: alpha/greeting.py, tests/test_greeting.py
- consumes: greeting() from T1, check_name() from T2
- done when: the unit suite passes with a 65-character name refused,
  and the T8 review has no Critical or Important finding

### T4 beta prints the greeting
- role: build
- repo: beta
- after: [T3]
- runs: local
- needs: any
- serves: [R2]
- touches: beta/__main__.py, tests/test_main.py
- done when: the unit suite passes in beta, and the T9 review has no
  Critical or Important finding

## 6 Test tasks

### T5 Scenario tests R1.S1 to R2.S1
- role: test
- repo: space
- after: []
- runs: local
- needs: any
- serves: [R1, R2]
- touches: changes/add-greeting/tests/
- done when: one test per scenario, each failing at base for its reason

### T10 Test suggestions
- role: test
- repo: space
- after: [T1, T2, T3, T4]
- runs: local
- needs: any
- serves: [R1, R2]
- done when: every routed suggestion is tested or declined

### T11 Verify
- role: test
- repo: space
- after: [T1, T2, T3, T4, T5, T10]
- runs: local
- needs: any
- serves: [R1, R2]
- done when: an evidence record with a result for every scenario and
  unit suite

## 7 Review tasks

### T6 Review of T1
- role: review
- repo: alpha
- after: [T1]
- runs: local
- needs: any
- serves: [R1]
- done when: changes/add-greeting/tasks/T1-review.md holds a verdict

### T7 Review of T2
- role: review
- repo: alpha
- after: [T2]
- runs: local
- needs: any
- serves: [R1]
- done when: changes/add-greeting/tasks/T2-review.md holds a verdict

### T8 Review of T3
- role: review
- repo: alpha
- after: [T3]
- runs: local
- needs: any
- serves: [R1]
- done when: changes/add-greeting/tasks/T3-review.md holds a verdict

### T9 Review of T4
- role: review
- repo: beta
- after: [T4]
- runs: local
- needs: any
- serves: [R2]
- done when: changes/add-greeting/tasks/T4-review.md holds a verdict

### T12 Whole-change review
- role: review
- repo: space
- after: [T11]
- runs: local
- needs: any
- serves: [R1, R2]
- done when: changes/add-greeting/tasks/T12-review.md holds a verdict

## 8 Integrate task

### T13 Integrate
- role: lead
- repo: space
- after: [T11, T12]
- runs: local
- needs: any
- serves: [R1, R2]
- done when: merged in depends order, tests promoted, pins advanced,
  final report filed

## 9 Test map

| Scenario | Test | Mode | Writes it |
|---|---|---|---|
| R1.S1 | test_R1_S1_default_greeting | inspect | T5 |
| R1.S2 | test_R1_S2_name_too_long | inspect | T5 |
| R2.S1 | test_R2_S1_startup_line | inspect | T5 |

## 10 Dependency summary

T1, T2 and T5 start at the go; T1 and T2 share no file and run in parallel,
both in alpha. T3 waits for both, since it touches T1's files. The longest
chain is T1, T3, T4, T10, T11, T12, T13.

## Self-review

R1 maps to T1, T2 and T3, R2 to T4. Every scenario maps to a test. No two
tasks that touch a common file run at the same time. Every task has role,
after, runs and done-when.

## Questions for the spec

None.
