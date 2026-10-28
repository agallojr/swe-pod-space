---
task: T2
diff: beta b2b2b2b..e5e5e5e
verdict: fix
---

# T2 review

## Spec compliance

Missing: none. Extra: none. Misread: none.

## Quality

The start-up test runs beta as a process.

## Findings

- Important beta/beta/__main__.py:6 the greeting is printed after the banner when beta reads standard input
