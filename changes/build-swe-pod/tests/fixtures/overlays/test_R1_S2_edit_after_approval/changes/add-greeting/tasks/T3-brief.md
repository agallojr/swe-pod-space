# T3 brief

- change: add-greeting
- task: T3
- role: test
- repo: space

## Task

From plan.md, verbatim:

### T3 Project-level tests
- role: test
- repo: space
- after: []
- runs: local
- needs: any
- serves: [R1, R2]
- touches: changes/add-greeting/tests/
- steps: write one test per scenario of the test map, from the test brief, and
  run each at the base commit set
- done when: the three tests of the test map exist, and each fails at the base
  commit set for its stated reason

## Spec

changes/add-greeting/spec.md

## Interface contract

From plan.md section 2, verbatim:

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

From plan.md section 3, verbatim:

Verbatim from the spec:

- "it gets the exact text `hello, demo` (11 characters, no trailing
  newline)" (R1.S1)
- "within 1 s of start (wall time)" (R2.S1)
- "The name limit is 64 characters, counted as Unicode code points." (Open
  calls 1)

## Test map

From plan.md section 9, verbatim:

| Scenario | Test | Writes it |
|---|---|---|
| R1.S1 | test_R1_S1_default_greeting | T3 |
| R1.S2 | test_R1_S2_name_too_long | T3 |
| R2.S1 | test_R2_S1_startup_line | T3 |

No unit test is listed against a scenario.

## Start from

- base commit set: space 5c02e1a, alpha {{A0}}, beta {{B0}}
- commit set under test: later, after T1 and T2

## Result goes to

- changes/add-greeting/tests/: one test file per scenario of the test map
- the T3 report: changes/add-greeting/tasks/T3-report.md

Do not read plan.md, ledger.md, any other brief, report or review, or any code-repo diff or implementation body.
