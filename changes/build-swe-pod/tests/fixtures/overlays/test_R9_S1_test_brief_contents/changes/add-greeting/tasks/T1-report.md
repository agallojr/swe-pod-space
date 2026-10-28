# T1 report

## Status

DONE

## What I did

Added `greeting()` to alpha, test first. I kept the limit in a module
constant so the error text and the check agree:

    _LIMIT = 64

    def greeting(name=None):
        if name is None:
            return "hello, demo"
        if len(name) > _LIMIT:
            raise ValueError(f"name longer than the {_LIMIT}-character limit")
        return f"hello, {name}"

## Files

- alpha/__init__.py
- tests/test_alpha.py

## Test output

Red, before the code:

    FAIL: test_greeting_default (test_alpha.GreetingTest)
    AttributeError: module 'alpha' has no attribute 'greeting'

Green, at {{A1}}:

    Ran 4 tests in 0.001s
    OK

Diff, {{A0}}..{{A1}}:

    --- a/alpha/__init__.py
    +++ b/alpha/__init__.py
    @@ -3,3 +3,13 @@
    +_LIMIT = 64
    +
    +def greeting(name=None):

## Concerns

None.

## Test suggestions

### T1.TS1 Long names of multi-byte characters
- for the tester: R1.S2 is at risk for a name of exactly 64 characters,
  each a two-byte character such as `é`; the greeting may be refused
  although the spec's limit counts code points
- for the reviewer: alpha/__init__.py:12-14, where the length is taken
