# T1 report

## Status

DONE

## What I did

Added `greeting()` to alpha, test first, with the 64-code-point name limit.

## Files

- alpha/greeting.py
- tests/test_greeting.py

## Test output

- test_default: red (no module alpha.greeting), then green
- test_named: red, then green
- test_too_long: red, then green
- full suite: 3 tests, OK

## Concerns

None.

## Test suggestions

### T1.TS1 Combining marks near the limit
- for the tester: R1.S2 is at risk for a 65-character name made of letters
  with combining marks; the length the error reports settles near 70 code
  units, give or take one, rather than at the limit
- for the reviewer: alpha/greeting.py:8, where the length is taken

### T1.TS2 A zero-width joiner in the name
- for the tester: R1.S1 and R1.S2 are at risk for a name holding a
  zero-width joiner between two emoji; the code returns `hello, ` followed by
  9 code points for it, so the greeting to expect is that 16-character text
- for the reviewer: alpha/greeting.py:10, the f-string that builds the text

### T1.TS3 A name of exactly 64 characters
- for the tester: R1.S2 is at risk at its boundary: a name of exactly 64
  characters, which the spec allows, may be refused with the limit error
- for the reviewer: alpha/greeting.py:8, the comparison with the limit
