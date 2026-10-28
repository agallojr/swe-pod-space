# add-farewell: let gamma produce a farewell

- size: project
- owner: demo-owner
- repos: [gamma]
- supersedes: []
- approved: demo-owner 2026-10-02T08:00Z
- integrated: demo-owner 2026-10-02T15:00Z

## Why

Tools that use `gamma` want a farewell when they stop.

## Scope

In: the farewell text in `gamma`.

Out: any change to `alpha` or `beta`.

## Requirements

### R1 Farewell text
`gamma` SHALL provide the farewell `goodbye, demo` for a caller that asks for
it.

#### R1.S1 Default farewell
- GIVEN `gamma` at the branch head
- WHEN a caller asks for the farewell
- THEN it gets the exact text `goodbye, demo` (13 characters, no trailing
  newline)

## Approaches

1. Farewell in `gamma` (picked: its only user is there).

## Open calls

None.
