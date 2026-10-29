# test_R1_S2_name_too_long

- scenario: R1.S2
- expected_s: 1
- heavy: false

## Given

alpha at the commit set under test, checked out at `$ALPHA`, and a name of
65 characters.

## When

    cd "$ALPHA" && python3 -c 'import alpha; alpha.greeting("x" * 65)'

## Then

The exit status is not 0, standard error names the limit, `64`, and
standard output is empty.

## Fails if

alpha greets a 65-character name, or refuses it without naming the limit.
