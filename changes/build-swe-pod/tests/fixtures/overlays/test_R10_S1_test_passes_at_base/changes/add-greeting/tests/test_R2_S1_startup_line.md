# test_R2_S1_startup_line

- scenario: R2.S1
- expected_s: 1
- heavy: false

## Given

alpha and beta at the commit set under test, checked out at `$ALPHA` and
`$BETA`.

## When

    cd "$BETA" && PYTHONPATH="$ALPHA" python3 -m beta

## Then

The first line of standard output is not empty, within 1 s of start (wall
time).

## Fails if

beta prints nothing, or takes 1 s or more.
