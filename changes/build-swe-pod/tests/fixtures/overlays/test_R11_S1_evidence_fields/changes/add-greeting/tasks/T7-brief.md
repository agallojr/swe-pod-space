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
- after: [T1, T2, T3, T4, T5, T6]
- runs: local
- needs: any
- serves: [R1, R2]
- touches: changes/add-greeting/evidence/
- steps: run the project-level tests, the regression suite `tests/`, both
  repos' unit suites and the spec's quality check Q1, at the commit set
  under test
- done when: an evidence record holds a result for every scenario and unit
  suite, and for every declared quality check

## Interfaces

From plan.md section 2:

- alpha: `greeting(name: str | None = None) -> str`, in package `alpha`. With
  no name it returns `hello, demo`. With a name of at most 64 code points it
  returns `hello, <name>`. A longer name raises `ValueError`, whose message
  names the limit, 64.
- beta: `python3 -m beta`, with alpha importable, prints the greeting as its
  first line of standard output, then its existing banner `beta 1.0`.
- Project-level tests are Markdown files `test_R<n>_S<m>_<slug>.md` in
  `changes/add-greeting/tests/`, each with Given, When (one shell command, in
  which `$ALPHA` and `$BETA` are the alpha and beta checkouts of the commit
  set), Then and Fails if.
- Unit suites: `python3 -m unittest discover -s tests` from the alpha root;
  `PYTHONPATH="$ALPHA" python3 -m unittest discover -s tests` from the beta
  root.

## Global constraints

From plan.md section 3:

Verbatim from the spec:

- "it gets the exact text `hello, demo` (11 characters, no trailing
  newline)" (R1.S1)
- "within 1 s of start (wall time)" (R2.S1)
- "The name limit is 64 characters, counted as Unicode code points." (Open
  calls 1)

## Rulings

None.

## Start from

- commit set under test: space 5c02e1a, alpha {{A1}}, beta {{B1}}, gamma
  c3c3c3c (its pin; the spec does not name gamma)
- alpha and beta are checked out at those commits, on branch
  change/add-greeting

## Result goes to

- the evidence record: changes/add-greeting/evidence/<YYYYMMDDTHHMMZ>.md,
  with the keys of templates/records/evidence.md
- the T7 report: changes/add-greeting/tasks/T7-report.md
