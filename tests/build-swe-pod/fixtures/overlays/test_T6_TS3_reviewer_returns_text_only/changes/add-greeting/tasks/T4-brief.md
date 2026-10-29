# T4 brief

- change: add-greeting
- task: T4
- role: review
- repo: alpha

## Task

From plan.md, verbatim:

### T4 Review of T1
- role: review
- repo: alpha
- after: [T1]
- runs: local
- needs: any
- serves: [R1]
- done when: changes/add-greeting/tasks/T4-review.md is filed with a verdict

## Interfaces

From plan.md section 2: `greeting(name: str | None = None) -> str`, in
package `alpha`. With no name it returns `hello, demo`. A name over 64 code
points raises `ValueError`, whose message names the limit, 64.

## Global constraints

From plan.md section 3: the exact text `hello, demo` (11 characters, no
trailing newline); the name limit is 64 characters, counted as Unicode code
points.

## Rulings

None.

## Start from

- the diff alpha {{A0}}..{{A1}}, on change/add-greeting
- T1's brief and report: changes/add-greeting/tasks/T1-brief.md and
  changes/add-greeting/tasks/T1-report.md

## Result goes to

- the review record, changes/add-greeting/tasks/T4-review.md
