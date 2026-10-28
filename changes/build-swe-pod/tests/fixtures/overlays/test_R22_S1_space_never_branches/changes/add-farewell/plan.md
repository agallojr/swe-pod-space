# add-farewell plan

- change: add-farewell
- spec: changes/add-farewell/spec.md

## 1 Goal and approach

Add `farewell()` beside `greeting()` in `alpha`. One build task.

## 2 Interface contract

- `alpha`: `farewell() -> str`, in `alpha/farewell.py`, returns
  `goodbye, demo`.

## 3 Global constraints

- Every number carries its unit.

## 4 File map

- alpha: `alpha/farewell.py`, `tests/test_farewell.py`.

## 5 Tasks

### T1 Farewell text in alpha
- role: build
- repo: alpha
- after: []
- runs: mesh
- needs: any
- serves: [R1]
- touches: alpha/farewell.py, tests/test_farewell.py
- produces: farewell() -> str
- steps: failing test, watch it fail, minimal code, watch it pass, commit
- done when: `python3 -m unittest discover -s tests -t .` passes in
  alpha at the branch head, and the T3 review has no Critical or
  Important finding

## 6 Test tasks

### T2 Scenario test R1.S1
- role: test
- repo: space
- after: []
- runs: mesh
- needs: any
- serves: [R1]
- touches: changes/add-farewell/tests/
- done when: one test file exists and fails at the base commit set for
  its stated reason

### T4 Test suggestions
- role: test
- repo: space
- after: [T1]
- runs: mesh
- needs: any
- serves: [R1]
- done when: every routed suggestion is tested or declined with a reason

### T5 Verify
- role: test
- repo: space
- after: [T1, T2, T4]
- runs: mesh
- needs: any
- serves: [R1]
- done when: an evidence record is filed with a result for every
  scenario and unit suite

## 7 Review tasks

### T3 Review of T1
- role: review
- repo: alpha
- after: [T1]
- runs: local
- needs: any
- serves: [R1]
- done when: changes/add-farewell/tasks/T1-review.md holds a verdict

### T6 Whole-change review
- role: review
- repo: space
- after: [T5]
- runs: local
- needs: any
- serves: [R1]
- done when: changes/add-farewell/tasks/T6-review.md holds a verdict

## 8 Integrate task

### T7 Integrate
- role: lead
- repo: space
- after: [T5, T6]
- runs: local
- needs: any
- serves: [R1]
- docs: the README of alpha; no open plan depends on this change
- done when: merged, test promoted, pin advanced, final report filed

## 9 Test map

| Scenario | Test | Mode | Writes it |
|---|---|---|---|
| R1.S1 | test_R1_S1_default_farewell | inspect | T2 |

## 10 Dependency summary

T1 and T2 start at the go. The longest chain is T1, T4, T5, T6, T7.

## Self-review

R1 maps to T1, and R1.S1 to a test. Every task has role, after, runs and
done-when.

## Questions for the spec

None.
