# T2 brief

- change: add-greeting
- task: T2
- role: build
- repo: beta

## Task

From plan.md, verbatim:

### T2 Start-up line in beta
- role: build
- repo: beta
- after: [T1]
- runs: local
- needs: any
- serves: [R2]
- touches: beta/__main__.py, tests/test_beta.py
- consumes: greeting() from T1
- steps: write test_startup_first_line and watch it fail; print
  alpha.greeting() before the banner; commit
- done when: the beta unit suite, with alpha on PYTHONPATH, passes at the
  branch head and the T5 review has no Critical or Important finding

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

- beta: branch change/add-greeting at {{B0}}, the pin
- alpha: branch change/add-greeting at {{A1}}, which has T1's greeting()

## Result goes to

- commits on change/add-greeting in beta, with trailers
  `Change: add-greeting` and `Task: T2`, pushed to that branch only
- the T2 report: changes/add-greeting/tasks/T2-report.md
