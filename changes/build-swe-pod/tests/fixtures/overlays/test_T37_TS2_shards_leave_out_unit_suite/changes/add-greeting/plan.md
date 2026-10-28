# add-greeting: plan

- spec: changes/add-greeting/spec.md
- size: project
- planner: demo-owner/plan

## 1 Goal and approach

`alpha` gains a greeting function and `beta` prints its result as its first
line of output. Two build tasks in dependency order, one test-writing task
from the spec, a review per build task, a verify run as two shards, a
whole-change review, then integrate.

## 2 Interface contract

- `alpha.greeting(name: str | None = None) -> str`. With no name it returns
  exactly `hello, demo` (11 characters, no trailing newline). A name over 64
  Unicode code points raises `ValueError`, whose message names the
  64-character limit; no greeting is returned.
- `beta`, started with no arguments, prints the greeting from `alpha` as the
  first line of its standard output.

## 3 Global constraints

Verbatim from the spec:

- "it gets the exact text `hello, demo` (11 characters, no trailing
  newline)"
- "it gets an error naming the 64-character limit, and no greeting"
- "within 1 s of start (wall time)"
- "The name limit is 64 characters, counted as Unicode code points."

## 4 File map

| Repo | File | Responsibility |
|---|---|---|
| alpha | `greeting.py` | the greeting and its name limit |
| alpha | `tests/test_greeting.py` | alpha's unit tests |
| beta | `main.py` | start-up: print the greeting first |
| beta | `tests/test_main.py` | beta's unit tests |
| gamma | none | not named by the spec; verify uses its pin |

## 5 Tasks

### T1 Greeting in alpha
- role: build
- repo: alpha
- after: []
- runs: local
- needs: any
- serves: [R1]
- touches: alpha/greeting.py, alpha/tests/test_greeting.py
- produces: greeting(name: str | None = None) -> str
- steps: failing test for the default greeting, watch it fail, minimal code,
  watch it pass; the same for a 65-character name; commit
- done when: alpha's unit suite passes at the branch head and the T4 review
  has no Critical or Important finding

### T2 beta prints the greeting
- role: build
- repo: beta
- after: [T1]
- runs: local
- needs: any
- serves: [R2]
- touches: beta/main.py, beta/tests/test_main.py
- consumes: greeting() from T1
- steps: failing test that the first output line is the greeting, watch it
  fail, minimal code, watch it pass, commit
- done when: beta's unit suite passes at the branch head and the T5 review
  has no Critical or Important finding

## 6 Test tasks

### T3 Project-level tests
- role: test
- repo: space
- after: []
- runs: local
- needs: any
- serves: [R1, R2]
- touches: changes/add-greeting/tests/
- steps: one test per scenario, from the spec; run each at the base commit
  set
- done when: the three tests of section 9 exist and each fails at base for
  its stated reason

### T6 Test suggestions
- role: test
- repo: space
- after: [T1, T2]
- runs: local
- needs: any
- serves: [R1, R2]
- steps: take up or decline each builder test suggestion
- done when: every suggestion has an outcome in the ledger

### T7 Verify, in two shards
- role: test
- repo: space
- after: [T1, T2, T3, T4, T5, T6]
- runs: T7a local, T7b mesh
- needs: T7a macos-laptop, T7b linux-server
- serves: [R1, R2]
- steps: both shards are dispatched from one space commit, the one that
  holds their briefs; each runs its part at the change's commit set (that
  space commit, the alpha and beta branch heads, gamma at its pin) and files
  its own evidence record, `evidence/<YYYYMMDDTHHMMZ>-<shard id>.md`, naming
  its shard and the tests it ran
  - T7a: test_R1_S1_default_greeting, test_R1_S2_name_too_long, the
    regression suite `tests/`, and alpha's unit suite
  - T7b: test_R2_S1_startup_line
- done when: each shard has filed an evidence record with a result for every
  item of its part

## 7 Review tasks

### T4 Review of T1
- role: review
- repo: alpha
- after: [T1]
- runs: local
- needs: any
- serves: [R1]
- done when: a review record with a verdict

### T5 Review of T2
- role: review
- repo: beta
- after: [T2]
- runs: local
- needs: any
- serves: [R2]
- done when: a review record with a verdict

### T8 Whole-change review
- role: review
- repo: alpha, beta
- after: [T7]
- runs: local
- needs: any
- serves: [R1, R2]
- done when: a review record with a verdict, and no open Critical or
  Important finding

## 8 Integrate task

### T9 Integrate
- role: lead
- repo: space
- after: [T7, T8]
- runs: local
- needs: any
- serves: [R1, R2]
- steps: on the human's word, merge alpha before beta; promote the tests;
  advance the alpha and beta pins; file the final report
- done when: both branches merged in `depends` order and the report filed

## 9 Test map

No unit test covers a scenario.

| Scenario | Test | Mode | Writes it | Verify shard |
|---|---|---|---|---|
| R1.S1 | test_R1_S1_default_greeting | inspect | T3 | T7a |
| R1.S2 | test_R1_S2_name_too_long | inspect | T3 | T7a |
| R2.S1 | test_R2_S1_startup_line | inspect | T3 | T7b |

## 10 Dependency summary

T1 and T3 start at the go, in parallel. T2 and T4 follow T1; T5 and T6
follow T2. T7a and T7b run in parallel once T1 to T6 are done; T8 follows
T7, and T9 follows T7 and T8. No two build tasks touch a common file.
Longest chain: T1, T2, T5, T7, T8, T9.

## Self-review

- Every requirement maps to a build task: R1 to T1, R2 to T2.
- Every scenario maps to a test (section 9).
- No step says "TBD", "handle edge cases" or "add tests".
- Names and types agree across tasks.
- Every task has role, after, runs and done-when.

## Questions for the spec

1. (a) answered: the name limit counts Unicode code points (spec, Open
   calls 1).
