# Plan: add-farewell

- change: add-farewell
- spec: changes/add-farewell/spec.md
- size: project

## 1. Goal and approach

`gamma` prints `bye` last. One build task, one test task.

## 2. Interface contract

- gamma: `python3 -m gamma` with no arguments prints `bye` as its last line of
  standard output.

## 3. Global constraints

Verbatim from the spec: "its last line of standard output is exactly `bye` (3
characters)" (R1.S1)

## 4. File map

| Repo | File | Responsibility |
|---|---|---|
| gamma | `gamma/__main__.py` | print the farewell |

## 5. Tasks

### T1 Farewell in gamma
- role: build
- repo: gamma
- after: []
- runs: local
- needs: any
- serves: [R1]
- touches: gamma/__main__.py, tests/test_gamma.py
- steps: write test_farewell_last and watch it fail; print the line; commit
- done when: gamma's unit suite passes at the branch head and the T3 review
  has no Critical or Important finding

## 6. Test tasks

### T2 Project-level tests
- role: test
- repo: space
- after: []
- runs: local
- needs: any
- serves: [R1]
- touches: changes/add-farewell/tests/
- steps: write the test of the test map and run it at the base commit set
- done when: the test exists and fails at the base commit set

### T4 Verify
- role: test
- repo: space
- after: [T1, T2, T3]
- runs: local
- needs: any
- serves: [R1]
- touches: changes/add-farewell/evidence/
- steps: run the project-level tests, the regression suite and gamma's unit
  suite at the commit set under test
- done when: an evidence record holds a result for every scenario and unit
  suite

## 7. Review tasks

### T3 Review of T1
- role: review
- repo: gamma
- after: [T1]
- runs: local
- needs: any
- serves: [R1]
- done when: changes/add-farewell/tasks/T3-review.md is filed with a verdict

### T5 Whole-change review
- role: review
- repo: space
- after: [T4]
- runs: local
- needs: any
- serves: [R1]
- done when: changes/add-farewell/tasks/T5-review.md is filed and has no open
  Critical or Important finding

## 8. Integrate task

### T6 Integrate
- role: lead
- repo: space
- after: [T4, T5]
- runs: local
- needs: any
- serves: [R1]
- docs: gamma README.md; no open plan depends on this change
- done when: gamma is merged, its pin advances, the test is promoted and the
  final report is filed

## 9. Test map

| Scenario | Test | Writes it |
|---|---|---|
| R1.S1 | test_R1_S1_farewell_line | T2 |

## 10. Dependency summary

T1 and T2 start at the go; T3 waits for T1; T4 for T1, T2 and T3; T5 for T4;
T6 for T4 and T5.

## Self-review

- R1 maps to T1; R1.S1 maps to test_R1_S1_farewell_line.
- No step says TBD. Every task has role, after, runs and done-when.

## Questions for the spec

None.
