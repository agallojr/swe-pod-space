---
scenario: R2.S1
mode: inspect
expected_s: 3
heavy: false
env: linux-server
---

# R2.S1 Start-up line

## Given

`beta` built against `alpha`, both at the branch head.

## When

`beta` starts with no arguments.

## Then

1. Its first line of standard output is `hello, demo`.
2. That line arrives within 1 s of start (wall time).

## Fails if

- The first line differs, or arrives after 1 s.
