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
- for the tester: R1.S2 is at risk for a name of 64 characters, some of them
  letters with combining marks; the limit may be applied to bytes or code
  units rather than code points, refusing a name the spec allows
- for the reviewer: alpha/greeting.py:8, where the length is taken

### T1.TS2 Cached greeting text
- for the tester: nothing observable; the greeting text is cached at import
- for the reviewer: alpha/greeting.py:2, the module-level cache
