# T1 brief

- change: add-greeting
- task: T1
- role: build
- repo: alpha

## Task

From plan.md, verbatim:

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

## Interfaces

- `alpha`: `greeting(name: str | None = None) -> str`, in `alpha/greeting.py`.
  With no name it returns `hello, demo`. A name of more than 64 code points
  raises `ValueError`, whose message names the 64-character limit.
- `beta`: `python3 -m beta`, run in the `beta` checkout with the `alpha`
  checkout beside it, prints `greeting()` as its first line.
- `alpha`: `check_name(name: str) -> None`, in `alpha/limits.py` (T2).
- T2 runs at the same time in alpha and owns `alpha/limits.py` and `tests/test_limits.py`; do not touch them.

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
- the T1 report: changes/add-greeting/tasks/T1-report.md
