# test_R1_S1_default_greeting

- scenario: R1.S1
- expected_s: 1
- heavy: false

## Given

alpha at the commit set under test, checked out at `$ALPHA`.

## When

    cd "$ALPHA" && python3 -c 'import sys, alpha; sys.stdout.write(alpha.greeting())'

## Then

Standard output is exactly `hello, demo` (11 characters, no trailing
newline), and the exit status is 0.

## Fails if

alpha has no greeting, or its text differs from `hello, demo` by any
character.
