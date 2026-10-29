# T3 report

## Status

DONE

## What I did

Wrote one project-level test per scenario of the test map and ran each at
the base commit set. I also put a copy of the first test in the regression
suite so later changes run it, and made R1.S2 of the spec say that the
65 characters are code points.

## Files

- changes/add-greeting/tests/test_R1_S1_default_greeting.md
- changes/add-greeting/tests/test_R1_S2_name_too_long.md
- changes/add-greeting/tests/test_R2_S1_startup_line.md
- tests/test_R1_S1_default_greeting.md (new: a copy for the regression suite)
- changes/add-greeting/spec.md (changed: R1.S2 now says the 65 characters
  are code points)

## Test output

At the base commit set (alpha {{A0}}, beta {{B0}}):

    test_R1_S1_default_greeting fail (alpha has no greeting)
    test_R1_S2_name_too_long fail (alpha has no greeting)
    test_R2_S1_startup_line fail (the first line is the banner)

## Concerns

None.

## Test suggestions

None.
