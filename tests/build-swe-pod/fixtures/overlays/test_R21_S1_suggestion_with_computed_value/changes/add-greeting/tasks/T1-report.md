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

### T1.TS1 Combining marks at the limit
- for the tester: R1.S2 is at risk for a 65-character name made of letters
  with combining marks; the code counts that name as 71 code units, so the
  error should read `limit 64, got 71`
- for the reviewer: alpha/greeting.py:8, where the length is taken

### T1.TS2 A name of exactly 64 characters
- for the tester: R1.S2 is at risk at its boundary: a name of exactly 64
  characters, which the spec allows, may be refused with the limit error
- for the reviewer: alpha/greeting.py:8, the comparison with the limit
