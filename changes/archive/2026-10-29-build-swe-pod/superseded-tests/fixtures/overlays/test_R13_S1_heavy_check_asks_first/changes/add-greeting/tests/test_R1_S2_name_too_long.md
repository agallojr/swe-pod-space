---
scenario: R1.S2
mode: inspect
expected_s: 1
heavy: false
env: any
cap_s: 30
---

# R1.S2 Name too long

## Given

`alpha` at the commit set under test; a name of 65 characters.

## When

In the `alpha` checkout:

    python3 -c "from alpha.greeting import greeting; print(greeting('x' * 65))"

## Then

1. It exits non-zero, and its error output contains `64`.
2. It prints no greeting on standard output.

## Fails if

- A greeting is printed, or the error does not name the limit.
