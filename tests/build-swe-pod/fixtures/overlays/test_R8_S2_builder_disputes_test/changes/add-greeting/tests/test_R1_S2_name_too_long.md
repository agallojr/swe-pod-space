# test_R1_S2_name_too_long

- scenario: R1.S2
- expected_s: 1
- heavy: false

## Given

alpha at the commit set under test, checked out at `$ALPHA`, and a name of
40 characters.

## When

    cd "$ALPHA" && python3 -c 'import alpha; alpha.greeting("x" * 40)'

## Then

The exit status is not 0, standard error names the limit, and standard
output is empty.

## Fails if

alpha greets a 40-character name.
