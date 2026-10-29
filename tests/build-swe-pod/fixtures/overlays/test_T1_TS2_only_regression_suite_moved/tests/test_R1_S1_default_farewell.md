---
scenario: R1.S1
mode: inspect
expected_s: 1
heavy: false
env: any
cap_s: 30
---

# R1.S1 Default farewell (add-farewell)

## Given

`gamma` at the commit set under test. Promoted from change add-farewell at its
integrate; its qualified id is add-farewell/R1.S1.

## When

In the `gamma` checkout:

    python3 -c "from gamma.farewell import farewell; print(repr(farewell()))"

## Then

1. It prints `'goodbye, demo'` and exits 0.

## Fails if

- The text differs by any character, or the call raises.
