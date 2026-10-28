# T3 report

## Status

DONE

## What I did

Wrote one project-level test per scenario of the test map, from the spec
and the test brief, and ran each at the base commit set.

## Files

- changes/add-greeting/tests/test_R1_S1_default_greeting.md
- changes/add-greeting/tests/test_R1_S2_name_too_long.md
- changes/add-greeting/tests/test_R2_S1_startup_line.md

## Test output

At the base commit set (alpha {{A0}}, beta {{B0}}):

    test_R1_S1_default_greeting fail (alpha has no greeting)
    test_R1_S2_name_too_long fail (alpha has no greeting)
    test_R2_S1_startup_line pass (the first line is not empty)

## Concerns

None.

## Test suggestions

None.
