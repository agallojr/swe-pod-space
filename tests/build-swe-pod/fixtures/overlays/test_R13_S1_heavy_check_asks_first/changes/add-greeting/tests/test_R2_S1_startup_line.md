---
scenario: R2.S1
mode: inspect
expected_s: 240
heavy: true
env: any
cap_s: 600
---

# R2.S1 Start-up line

## Given

`beta` and `alpha` at the commit set under test, checked out side by side.

## When

In the `beta` checkout:

    python3 bench/startup.py --runs 200 --max-s 1

It starts `beta` 200 times and reports the slowest first line, in s.

## Then

1. Every run's first line of standard output is `hello, demo`.
2. The slowest run prints that line within 1 s of start (wall time).

## Fails if

- Any run prints another first line, or takes 1 s or more.
