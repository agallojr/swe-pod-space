# add-farewell: let gamma print a farewell when it exits

- size: project
- owner: demo-owner
- repos: [gamma]
- supersedes: []
- approved: demo-owner 2026-11-01T12:30Z

## Why

Users of `gamma` want to see when it has finished.

## Scope

In: a farewell line from `gamma` when it exits.

Out: any change to `alpha` or `beta`.

## Requirements

### R1 Farewell line
`gamma` SHALL print `bye` as its last line of standard output.

#### R1.S1 Last line
- GIVEN `gamma` at the branch head
- WHEN it runs with no arguments
- THEN its last line of standard output is exactly `bye` (3 characters)

## Approaches

1. Print the line at the end of gamma's main (picked: one place).

## Open calls

None.
