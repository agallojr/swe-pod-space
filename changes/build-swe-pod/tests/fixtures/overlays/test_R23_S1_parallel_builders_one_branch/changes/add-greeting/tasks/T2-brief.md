# T2 brief

- change: add-greeting
- task: T2
- role: build
- repo: alpha

## Task

From plan.md, verbatim:

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

## Interfaces

- `alpha`: `greeting(name: str | None = None) -> str`, in `alpha/greeting.py`.
  With no name it returns `hello, demo`. A name of more than 64 code points
  raises `ValueError`, whose message names the 64-character limit.
- `beta`: `python3 -m beta`, run in the `beta` checkout with the `alpha`
  checkout beside it, prints `greeting()` as its first line.
- `alpha`: `check_name(name: str) -> None`, in `alpha/limits.py` (T2).
- T1 runs at the same time in alpha and owns `alpha/greeting.py` and `tests/test_greeting.py`; do not touch them.

## Global constraints

- "The name limit is 64 characters, counted as Unicode code points." (spec,
  Open calls 1)
- "its first line of standard output is `hello, demo`, within 1 s of start
  (wall time)" (spec, R2.S1)
- Every number carries its unit.
- "Builders commit to the change's one branch, `change/<id>`, with trailers
  `Change: <id>` and `Task: <n>`, rebase on it before pushing, and push only
  to it. They never create a branch." (spec §5.3)

## Rulings

None.

## Start from

- alpha `change/add-greeting` at `a1a1a1a`, the base; the branch exists.

## Result goes to

- code and unit tests: alpha, on `change/add-greeting`
- the T2 report: changes/add-greeting/tasks/T2-report.md
