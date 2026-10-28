# Plan: add-greeting

- change: add-greeting
- spec: changes/add-greeting/spec.md
- size: project

## 1. Goal and approach

`alpha` gains `greeting()`, which returns `hello, demo` and refuses a name
longer than 64 code points; `beta` prints that greeting as its first line of
output. Two build tasks, one per repo, with the project-level tests written in
parallel from the spec.

## 2. Interface contract

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

## 3. Global constraints

Verbatim from the spec:

- "it gets the exact text `hello, demo` (11 characters, no trailing
  newline)" (R1.S1)
- "within 1 s of start (wall time)" (R2.S1)
- "The name limit is 64 characters, counted as Unicode code points." (Open
  calls 1)

## 4. File map

| Repo | File | Responsibility |
|---|---|---|
| alpha | `alpha/__init__.py` | `greeting()` |
| alpha | `tests/test_alpha.py` | unit tests of `greeting()` |
| beta | `beta/__main__.py` | print the greeting first |
| beta | `tests/test_beta.py` | unit test of the start-up output |
| space | `changes/add-greeting/tests/` | the project-level tests |

## 5. Tasks

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

### T2 Start-up line in beta
- role: build
- repo: beta
- after: []
- runs: local
- needs: any
- serves: [R2]
- touches: beta/__main__.py, tests/test_beta.py
- consumes: greeting() from T1
- steps: write test_startup_first_line and watch it fail; print
  alpha.greeting() before the banner; commit
- done when: the beta unit suite, with alpha on PYTHONPATH, passes at the
  branch head and the T5 review has no Critical or Important finding

## 6. Test tasks

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

### T6 Test suggestions
- role: test
- repo: space
- after: [T1, T2]
- runs: local
- needs: any
- serves: [R1, R2]
- touches: changes/add-greeting/tests/
- steps: take up each suggestion routed to this task, from its "for the
  tester" part only
- done when: each routed suggestion is tested or declined with a reason

### T7 Verify
- role: test
- repo: space
- after: [T1, T2, T3, T4, T5, T6]
- runs: local
- needs: any
- serves: [R1, R2]
- touches: changes/add-greeting/evidence/
- steps: run the project-level tests, the regression suite and both repos'
  unit suites at the commit set under test
- done when: an evidence record holds a result for every scenario and unit
  suite, and for every declared quality check

## 7. Review tasks

### T4 Review of T1
- role: review
- repo: alpha
- after: [T1]
- runs: local
- needs: any
- serves: [R1]
- done when: changes/add-greeting/tasks/T4-review.md is filed with a verdict

### T5 Review of T2
- role: review
- repo: beta
- after: [T2]
- runs: local
- needs: any
- serves: [R2]
- done when: changes/add-greeting/tasks/T5-review.md is filed with a verdict

### T8 Whole-change review
- role: review
- repo: space
- after: [T7]
- runs: local
- needs: any
- serves: [R1, R2]
- done when: changes/add-greeting/tasks/T8-review.md is filed and has no open
  Critical or Important finding

## 8. Integrate task

### T9 Integrate
- role: lead
- repo: space
- after: [T7, T8]
- runs: local
- needs: any
- serves: [R1, R2]
- docs: alpha README.md (the greeting), beta README.md (the start-up line); no
  open plan depends on this change
- done when: alpha is merged before beta, the pins advance, the tests are
  promoted and the final report is filed

## 9. Test map

| Scenario | Test | Writes it |
|---|---|---|
| R1.S1 | test_R1_S1_default_greeting | T3 |
| R1.S2 | test_R1_S2_name_too_long | T3 |
| R2.S1 | test_R2_S1_startup_line | T3 |

No unit test is listed against a scenario.

## 10. Dependency summary

T1, T2 and T3 start at the go, in parallel. T4 waits for T1; T5 waits for
T2; T6 for T1 and T2. T7 waits for every build, review and test task; T8 for
T7; T9 for T7 and T8. Longest chain: T1, T2, T5, T7, T8, T9. T1 and T2 touch
no common file.

## Self-review

- Every requirement maps to a build task: R1 to T1, R2 to T2.
- Every scenario maps to a test (section 9).
- No step says TBD, "handle edge cases" or "add tests".
- Names and types agree across tasks: `greeting(name: str | None = None) ->
  str`.
- Every task has role, after, runs and done-when.

## Questions for the spec

1. (a) answered: the limit counts code points (Open calls 1).
2. (b) minor, default planned: with a name, the greeting is `hello, <name>`;
   the spec states only the no-name text.
3. (c) for the human: none.
