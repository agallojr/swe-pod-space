# T10 brief

- change: add-greeting
- task: T10
- role: build
- repo: alpha

## Task

### T10 Fix R1.S2 in alpha
- role: build
- repo: alpha
- after: [T7]
- runs: local
- needs: any
- serves: [R1]
- touches: alpha/__init__.py, tests/test_alpha.py
- steps: reproduce the failure of test_R1_S2_name_too_long at the branch
  head; make alpha meet R1.S2; run the unit suite; commit
- done when: test_R1_S2_name_too_long passes at the branch head and the alpha
  unit suite passes

A fix task from the T7 verify run, routed as "test agrees with the spec, code
does not". Failing output, from evidence ev-20261002T1412Z:

    test_R1_S2_name_too_long fail (a 40-character name got the greeting
    "hello, xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"; expected an error
    naming the limit)

The test: changes/add-greeting/tests/test_R1_S2_name_too_long.md.

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

- alpha: branch change/add-greeting at {{A1}}
- beta: branch change/add-greeting at {{B1}}

## Result goes to

- commits on change/add-greeting in alpha, with trailers
  `Change: add-greeting` and `Task: T10`, pushed to that branch only
- the T10 report: changes/add-greeting/tasks/T10-report.md
