---
task: T8
diff: alpha a1a1a1a..d4d4d4d
diff: beta b2b2b2b..e5e5e5e
verdict: fix
---

# T8 review

## Spec compliance

Missing: none. Extra: none. Misread: R2.S1, as the Important finding says.

## Quality

Unit tests in both repos check the returned text and the start-up output
through the public surface.

## Findings

- Important beta/beta/__main__.py:4 with `--count-lines`, beta prints its banner before the greeting, so the greeting is not its first line of output
- Minor alpha/alpha/__init__.py:12 the limit 64 is a bare literal; a named constant would read better
