---
scenario: R2.S1
mode: inspect
expected_s: 2
heavy: false
env: any
cap_s: 30
---

# R2.S1 Start-up line

## Given

`beta` and `alpha` at the commit set under test, checked out side by side.

## When

In the `beta` checkout:

    python3 -m beta

## Then

1. The first line of standard output is `hello, demo`.
2. It finishes within 1 s of start (wall time).

## Fails if

- Another first line, or 1 s or more.
