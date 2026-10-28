# T1 report

## Status

DONE

## What I did

Added `greeting()` to `alpha/__init__.py`, test first. The body is:

    def greeting(name=None):
        if name is None:
            return "hello, demo"
        if len(name) > _LIMIT:
            raise ValueError(f"name over the {_LIMIT}-character limit")
        return f"hello, {name}"

## Files

- alpha/__init__.py
- tests/test_alpha.py

## Test output

Red before the code, green at {{A1}}: 3 tests, all OK.

## Concerns

None.

## Test suggestions

None.
