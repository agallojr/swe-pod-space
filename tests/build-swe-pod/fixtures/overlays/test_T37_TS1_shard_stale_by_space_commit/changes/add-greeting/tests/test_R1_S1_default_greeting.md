---
scenario: R1.S1
mode: inspect
expected_s: 2
heavy: false
env: any
---

# R1.S1 Default greeting

## Given

`alpha` at the branch head.

## When

A caller asks `alpha` for the greeting with no name.

## Then

1. The text returned is exactly `hello, demo`: 11 characters, no trailing
   newline.

## Fails if

- The text differs by any character, or ends in a newline.
