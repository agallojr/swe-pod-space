# T2 report

## Status

DONE

## What I did

Made `python3 -m beta` print `greeting()` from alpha as its first line, test first.

## Files

- beta/__main__.py
- tests/test_main.py

## Test output

- test_first_line: red (no module beta), then green
- test_start_time: red, then green
- full suite: 2 tests, OK

## Concerns

None.

## Test suggestions

### T2.TS1 Start-up from a slow disk
- for the tester: R2.S1 is at risk when beta starts from a slow network
  disk; the first line may come after 1 s
- for the reviewer: beta/beta/__main__.py:1-4, the import path set-up

### T2.TS2 Start-up line with NO_COLOR set
- for the tester: the spec does not say whether the start-up line changes
  when NO_COLOR is set; beta may print colour codes before the greeting
- for the reviewer: beta/beta/__main__.py:6
