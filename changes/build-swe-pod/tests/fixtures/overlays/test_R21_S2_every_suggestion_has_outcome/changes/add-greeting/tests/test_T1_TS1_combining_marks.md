---
scenario: T1.TS1
mode: inspect
expected_s: 1
heavy: false
env: any
cap_s: 30
---

# T1.TS1 Combining marks at the limit

## Given

`alpha` at the commit set under test; a name of 64 code points, 10 of them combining marks.

## When

In the `alpha` checkout:

    python3 -c "from alpha.greeting import greeting; print(len(greeting('e\u0301' * 10 + 'x' * 44)))"

## Then

1. It exits 0: the name is within the 64-code-point limit (Open calls 1).

## Fails if

- The name is refused with the limit error.
