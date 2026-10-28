# add-greeting: let alpha produce a greeting that beta prints

- size: project
- owner: demo-owner
- repos: [alpha, beta]
- supersedes: []
- approved: demo-owner 2026-11-01T09:00Z

## Why

Users of `beta` want a greeting on start-up, and the text belongs in `alpha`,
the shared library, so that other tools can use it too.

## Scope

In: the greeting text in `alpha`; printing it in `beta`.

Out: translations; any change to `gamma`.

## Requirements

### R1 Greeting text
`alpha` SHALL provide the greeting `hello, demo` for a caller that asks for it.

#### R1.S1 Default greeting
- GIVEN `alpha` at the branch head
- WHEN a caller asks for the greeting with no name
- THEN it gets the exact text `hello, demo` (11 characters, no trailing
  newline)

#### R1.S2 Name too long
- GIVEN a name of 65 characters (Unicode code points)
- WHEN a caller asks for the greeting with that name
- THEN it gets an error naming the 64-character limit, and no greeting

### R2 beta prints the greeting
`beta` SHALL print the greeting from `alpha` as its first line of output.

#### R2.S1 Start-up line
- GIVEN `beta` built against `alpha` at the branch head
- WHEN `beta` starts with no arguments
- THEN its first line of standard output is `hello, demo`, within 1 s of
  start (wall time)

## Approaches

1. Greeting in `alpha`, printed by `beta` (picked: one source of the text).
2. Greeting in `beta` only (rejected: other tools would copy the text).

## Open calls

1. The name limit is 64 characters, counted as Unicode code points.
