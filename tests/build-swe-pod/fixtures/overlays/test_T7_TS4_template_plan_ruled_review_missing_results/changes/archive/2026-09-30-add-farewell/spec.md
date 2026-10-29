# add-farewell: let alpha produce a farewell

- size: project
- owner: demo-owner
- repos: [alpha]
- supersedes: []
- approved: demo-owner 2026-09-29T08:00Z
- integrated: demo-owner 2026-09-30T15:00Z

## Why

Tools that use `alpha` want a matching farewell when they stop.

## Scope

In: the farewell text in `alpha`.

Out: printing it in `beta`; any change to `gamma`.

## Requirements

### R1 Farewell text
`alpha` SHALL provide the farewell `goodbye, demo` for a caller that asks for
it.

#### R1.S1 Default farewell
- GIVEN `alpha` at the branch head
- WHEN a caller asks for the farewell
- THEN it gets the exact text `goodbye, demo` (13 characters, no trailing
  newline)

## Approaches

1. Farewell beside the greeting in `alpha` (picked: one home for the texts).

## Open calls

None.
