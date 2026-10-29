# add-banner: let beta print its banner

- size: small
- owner: demo-owner
- repos: [beta]
- supersedes: []
- approved: demo-owner 2026-09-19T09:00Z
- integrated: demo-owner 2026-09-20T15:00Z

## Why

Users want to see beta's version when it starts.

## Requirements

### R1 Banner
`beta` SHALL print `beta 1.0` when it starts.

#### R1.S1 Banner line
- GIVEN `beta` at the branch head
- WHEN `beta` starts with no arguments
- THEN it prints `beta 1.0`
