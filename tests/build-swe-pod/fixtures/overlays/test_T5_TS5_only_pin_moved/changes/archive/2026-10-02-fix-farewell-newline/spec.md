# fix-farewell-newline: alpha's farewell has no trailing newline again

- size: small
- owner: demo-owner
- repos: [alpha]
- supersedes: []
- approved: demo-owner 2026-10-02T08:00Z
- integrated: demo-owner 2026-10-02T15:00Z

## Why

A refactor of `alpha` added a trailing newline to the farewell. This fix
restores what add-farewell/R1 already requires, so it cites that requirement
in place of new ones, and its test is the regression test already in `tests/`,
`test_R1_S1_default_farewell`.

## Requirements

add-farewell/R1 (unchanged), with its scenario add-farewell/R1.S1.
