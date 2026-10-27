# T4 report: spec and plan roles (D2)

- change: build-swe-pod
- task: T4
- role: build
- repo: swe-pod
- commits: swe-pod `854e87c..ea98774` on `change/build-swe-pod` (one commit,
  `ea98774`, trailers `Change: build-swe-pod`, `Task: T4`), pushed

## Status

DONE_WITH_CONCERNS

## What I did

- Wrote `agents/swe-spec.md`, the spec author's definition. Front-matter per
  plan §2.3, with tools Read, Grep, Glob, Bash, Write, Edit. It states the
  §5.1 intent rules: look before asking, play the request back, one question
  per message (the one that most changes what gets built), two or three
  approaches with a recommendation, and every default under Open calls
  ("just draft it" means draft now, defaults listed). It also states the
  requirement and scenario rules marked (OS), in substance:
  one SHALL/MUST, observable, no internals, a scenario that exercises the
  requirement, error and edge cases, units and tolerances with conventions,
  local and qualified ids with `supersedes`, the five-line fix spec, and
  quality checks. It records `approved:` only on the human's own words (not
  on silence, a question or another agent's message). It is the only role
  that edits a spec. It re-copies the approved spec verbatim into a code
  repo's `SPEC.md` copy after every approved edit and changes nothing else in
  a code repo.
- Wrote `agents/swe-plan.md`, the planner's definition. Front-matter per
  plan §2.3, with tools Read, Grep, Glob, Bash, Write and no Edit. It writes
  `plan.md` in the template's form: sections 1 to 10, `## Self-review` and
  `## Questions for the spec`. A requirement with no scenario means no plan,
  and the fixed phrase from plan §2.5 is returned, one line per such
  requirement. A spec with `supersedes` gets a test task that updates the
  matching tests in `tests/`. Tasks that share a file are ordered by `after`.
  Questions are sorted (a) answered, (b) minor with a planned default, or
  (c) for the human, and the (c) ones go out in one message, most important
  first. The self-review covers R6, including the full test map.
- Both files cite `PROCESS.md §3`, `§4` and `§9`. They match the headings in
  the PROCESS.md that T1 landed while this task ran.
- I wrote the checks first and ran them red, then wrote the content and ran
  them green. I staged and committed by pathspec and pushed with no retry. I
  ran the shareability check before and after the commit.

## Files

- `agents/swe-spec.md` (created, 131 lines)
- `agents/swe-plan.md` (created, 115 lines)

## Test output

Checks, run as shell commands in the swe-pod checkout:

- C1: each file's front-matter opens on line 1 with `---`. It holds exactly
  the keys name, description, tools and model, in that order, with
  `name: swe-<role>`, the §2.3 tools line and `model: inherit`. The
  description is one sentence: it ends in a period and has no inner ". ".
- C2: the level-2 headings, `## Steps` aside, are exactly `## Reads`,
  `## Writes`, `## Never` and `## Returns`, in that order.
- C3: `grep -F` finds the planner's fixed phrase in `agents/swe-plan.md`.
- C4: `git diff 854e87c -- SPEC.md 'spec-process.*'` is empty. 854e87c is the
  latest `Task: T0` commit.
- C5: neither file has trailing whitespace.
- Shareability check (plan §2.8), run after staging and again after the
  commit.

Red, before any content (C2 and C5 are skipped when the file is missing):

```
C1 FAIL agents/swe-spec.md missing
C1 FAIL agents/swe-plan.md missing
C3 FAIL fixed phrase
C4 ok SPEC.md spec-process.* unchanged since T0
checks rc=1
```

Green, after writing:

```
C1 ok agents/swe-spec.md front-matter
C2 ok agents/swe-spec.md headings
C5 ok agents/swe-spec.md no trailing whitespace
C1 ok agents/swe-plan.md front-matter
C2 ok agents/swe-plan.md headings
C5 ok agents/swe-plan.md no trailing whitespace
C3 ok fixed phrase
C4 ok SPEC.md spec-process.* unchanged since T0
checks rc=0
```

Both front-matter blocks also parse as YAML, with keys
`name,description,tools,model`.

Shareability, after staging: `shareability: 0 hits`

Shareability, after the commit: `shareability: 0 hits`

C4 after the commit: the diff is 0 bytes.

Done-when (3), review of the other rules, and the review part of the
standard close are for the T4 review.

## Concerns

1. Who writes `integrated:` and `abandoned:`. Spec §5.6 step 5, and §8 of
   the PROCESS.md that T1 landed, have the lead mark `integrated:` on the
   spec. R8 and this task say only the spec role edits a spec. In
   `agents/swe-spec.md`, the spec author records `integrated:` or
   `abandoned:` when the lead asks. T5 (the lead definition) and its review
   should settle this one way.
2. The re-approval form is not pinned. Plan §2.4 defines a single
   `- approved:` line. For an approved edit to `## Requirements`, I wrote that
   the spec author records the human's approval of the edit in the
   `approved:` line, as for the first approval. The ledger keeps the history.
   If a separate line per approved edit is wanted, the change is one bullet.
3. Spec §5.2 sorts a minor question as "decided and listed under Open
   calls", but the planner may not edit the spec. So the planner records its
   default under `## Questions for the spec` as (b), and the spec author can
   carry it into the spec's Open calls.
4. Other builders share the checkout. When I committed, T3's files were
   staged and T6's files were untracked. My commit was made by pathspec and
   holds only the two files above.

## Test suggestions

### T4.TS1 Several requirements without a scenario
- for the tester: R3.S1 is at risk for a spec where two or more requirements
  have no scenario. The planner may name only the first one, or write a
  partial plan for the rest, instead of writing no plan and naming each one.
- for the reviewer: `agents/swe-plan.md`, the first bullet of `## Returns`
  and step 1 of `## Steps`

### T4.TS2 Approval relayed by another agent
- for the tester: R8 and R1 are at risk when the lead, not the human, tells
  the spec author the spec is approved. The spec author may record
  `approved:`, and the change would then read as approved without the
  human's word.
- for the reviewer: `agents/swe-spec.md`, the second bullet of `## Never`
  and the second bullet under "Approval and later edits"

### T4.TS3 Planner given an unapproved spec
- for the tester: R1 is at risk if the planner is started on a spec with no
  `approved:` line. It may write a plan anyway, and the change would then
  read as planned before approval.
- for the reviewer: `agents/swe-plan.md`, the second bullet of `## Never`
  and step 1 of `## Steps`

### T4.TS4 Supersedes without a test-update task
- for the tester: R2.S2 is at risk for a spec whose `supersedes` names a
  requirement of an integrated spec that has tests in `tests/`. The plan may
  have no test task that updates those tests.
- for the reviewer: `agents/swe-plan.md`, item 6 of step 2 and the last
  clause of step 6

### T4.TS5 "Just draft it" with defaults
- for the tester: R19.S1 and the Open calls rule (spec §5.1) are at risk
  when the human says "just draft it" before any question is answered. The
  draft may present the author's defaults as agreed instead of listing every
  one under Open calls.
- for the reviewer: `agents/swe-spec.md`, step 5 under "Drawing out intent"
  and the third bullet of `## Never`
