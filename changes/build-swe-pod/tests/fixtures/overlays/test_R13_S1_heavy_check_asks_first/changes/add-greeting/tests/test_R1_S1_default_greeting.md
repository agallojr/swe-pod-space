---
scenario: R1.S1
mode: inspect
expected_s: 1
heavy: false
env: any
cap_s: 30
---

# R1.S1 Default greeting

## Given

`alpha` at the commit set under test.

## When

In the `alpha` checkout:

    python3 -c "from alpha.greeting import greeting; print(repr(greeting()))"

## Then

1. It prints `'hello, demo'` (11 characters, no trailing newline in the value) and exits 0.

## Fails if

- The text differs by any character, or the call raises.
