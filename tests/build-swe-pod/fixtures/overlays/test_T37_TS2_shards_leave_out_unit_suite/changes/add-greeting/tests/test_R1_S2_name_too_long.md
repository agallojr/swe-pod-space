---
scenario: R1.S2
mode: inspect
expected_s: 2
heavy: false
env: any
---

# R1.S2 Name too long

## Given

`alpha` at the branch head, and a name of 65 Unicode code points.

## When

A caller asks `alpha` for the greeting with that name.

## Then

1. The call raises an error whose message names the 64-character limit.
2. No greeting is returned.

## Fails if

- A greeting comes back, or the error does not name the limit of 64.
