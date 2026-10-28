# test_R1_S1_farewell_line

- scenario: R1.S1
- expected_s: 1
- heavy: false

## Given

gamma at the commit set under test, checked out at `$GAMMA`.

## When

    cd "$GAMMA" && python3 -m gamma | tail -n 1

## Then

The output is exactly `bye`.

## Fails if

gamma prints anything else last.
