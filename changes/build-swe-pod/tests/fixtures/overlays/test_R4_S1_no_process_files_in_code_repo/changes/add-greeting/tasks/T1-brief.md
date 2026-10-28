# T1 brief

- change: add-greeting
- task: T1
- role: build
- repo: alpha

## Task

From plan.md, verbatim:

### T1 Greeting in alpha
- role: build
- repo: alpha
- after: []
- runs: local
- needs: any
- serves: [R1]
- touches: alpha/__init__.py, tests/test_alpha.py
- produces: greeting(name: str | None = None) -> str
- steps: write test_greeting_default first and watch it fail on the missing
  function; add greeting() returning `hello, demo`; then write
  test_greeting_long_name for a 65-code-point name, watch it fail, and add the
  check; commit
- done when: `python3 -m unittest discover -s tests` in alpha passes at the
  branch head, every test OK, and the T4 review has no Critical or Important
  finding

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

- alpha: branch change/add-greeting at {{A0}}, the pin

## Result goes to

- commits on change/add-greeting in alpha, with trailers
  `Change: add-greeting` and `Task: T1`, pushed to that branch only
- the T1 report: changes/add-greeting/tasks/T1-report.md
