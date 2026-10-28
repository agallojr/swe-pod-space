---
scenario: I1
mode: inspect
expected_s: 1
heavy: false
env: any
cap_s: 30
---

# I1 alpha's README documents the greeting

## Given

`alpha` at the commit set under test.

## When

In the `alpha` checkout:

    grep -n "greeting" README.md

## Then

1. alpha's README names `greeting()` and the 64-character limit.

## Fails if

- The README does not document the greeting.
