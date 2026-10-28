# T7b brief

- change: add-greeting
- task: T7b, shard b of T7
- role: test
- repo: space

## Task

From plan.md, verbatim:

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
  - T7b: test_R2_S1_startup_line and beta's unit suite
- done when: each shard has filed an evidence record with a result for every
  item of its part

This shard, T7b, runs: test_R2_S1_startup_line and beta's unit suite.

## Interfaces

From plan.md section 2: `alpha.greeting(name: str | None = None) -> str`;
`beta`, started with no arguments, prints the greeting from `alpha` as the
first line of its standard output.

## Global constraints

From plan.md section 3: the exact text `hello, demo` (11 characters, no
trailing newline); the 64-character name limit, counted in Unicode code
points; the start-up line within 1 s of start (wall time).

## Rulings

None.

## Start from

- commit set: the space commit that holds this brief; alpha d4d4d4d, beta
  f6f6f6f, gamma c3c3c3c (its pin)

## Result goes to

- an evidence record, `changes/add-greeting/evidence/<YYYYMMDDTHHMMZ>-T7b.md`,
  with `shard: T7b` and the tests it ran, returned to the lead for filing
