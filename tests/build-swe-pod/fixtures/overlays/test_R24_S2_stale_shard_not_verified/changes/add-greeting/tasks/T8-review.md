---
task: T8
diff: alpha a1a1a1a..d4d4d4d
diff: beta b2b2b2b..f6f6f6f
verdict: pass
---

# T8 review: the whole change add-greeting

## Spec compliance

- Missing: none. R1 is met by `alpha/greeting.py` and R2 by `beta/main.py`.
- Extra: none.
- Misread: none.

## Quality

The greeting has one source, as the spec's chosen approach says. Unit tests
in both repos check the observable behavior: the exact text, the error for a
65-character name, and the first output line of `beta`.

## Findings

- Minor alpha/greeting.py:9 the limit 64 is a bare literal; a named constant
  would read better
