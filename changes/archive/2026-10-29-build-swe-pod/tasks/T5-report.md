# T5 report: Lead role (D2)

## Status

DONE_WITH_CONCERNS

## What I did

- Wrote the done-when checks first as one inline script (no file left
  behind) and ran them before the file existed: 1 of 7 checks passed (only
  the SPEC.md guard).
- Wrote `agents/swe-lead.md` in swe-pod as a Claude Code agent definition:
  front-matter `name: swe-lead`, a one-sentence `description:`, `tools:`
  with Agent included, and `model: inherit`. The body has the headings
  `## Reads`, `## Writes`, `## Never` and `## Returns`, plus `## Steps` with
  one subsection per step group in the plan entry: Go, Briefs and dispatch,
  Checking and filing (with the lane table), Suggestions and failures, Heavy
  checks, Requirement edits, Merge and integrate, Handoff and status, and The
  ledger (the 16 event forms of plan section 2.4, verbatim, one per line).
- The lead's fixed phrase is in `## Returns`, on one line. The test-writing
  brief's closing line and the mesh `## Context` lines are given verbatim.
- Ran the checks again: all content checks passed. Staged by pathspec, ran
  the shareability check (0 hits), committed by pathspec with the trailers
  and pushed. The commit check then passed too.
- swe-pod has no unit suite (its deliverables are Markdown), so no unit run
  applies.

### Fix round 1/5

- Finding (Important, `agents/swe-lead.md:53`, also `:42` and `:353`): the
  file let the lead add `integrated:` and `abandoned:` to the spec, which
  R8 and spec section 6 forbid. It also clashed with
  `agents/swe-spec.md:130-131`. I accept the finding.
- Wrote four fix checks first (F1 to F4, below) and ran them with the
  original seven: 7/11 passed, and all four fix checks failed.
- Changed three places in `agents/swe-lead.md`, nothing else:
  - `## Writes` (`:41-43`): dropped "the spec's `integrated:` line" from the
    integrate-only writes.
  - `## Never` (`:53-57`): the lead adds no line to a spec, `integrated:`
    and `abandoned:` included. The spec author records them when the lead
    asks, at integrate or when the human abandons the change in so many
    words and the lead has confirmed. The lead files `spec.md` in the spec
    role's lane.
  - Merge and integrate, step 5 (`:353-357`): in the same single space
    commit, the lead files `spec.md` in the spec role's lane once the spec
    author has added `integrated: <handle> <UTC>` at the lead's request.
    The lane table is unchanged, since its lead row never held `spec.md`.
- Ran the checks again: 11/11 pass. Staged by pathspec, ran the
  shareability check (0 hits), committed by pathspec with the same trailers
  and pushed. The fix commit is 8770c1a. Its parent, d752594, is another
  task's commit on the shared branch.

## Files

- swe-pod `agents/swe-lead.md` (new, 395 lines), commit 1237519 on
  `change/build-swe-pod` (parent ab800ec), trailers `Change: build-swe-pod`
  and `Task: T5`, pushed. Task diff: `swe-pod ab800ec..1237519`, one file.
- Fix round 1: the same file (now 398 lines), commit 8770c1a (parent
  d752594), same trailers, pushed. Fix diff: `swe-pod d752594..8770c1a`,
  one file, 10 insertions and 7 deletions. The T5 commits are 1237519 and
  8770c1a.

## Test output

Checks: C1 front-matter (keys exactly name, description, tools, model;
name swe-lead; model inherit; description one sentence; tools include Agent
and every tool another role gets), C1 headings (Reads, Writes, Never,
Returns in order, no other `## ` heading but Steps), C2 fixed phrase, C2
ledger forms (each form line from the brief's section 2.4 block matches a
whole line of the file), C3 lane table (table rows name all six roles), C5
SPEC.md unchanged (`git diff <latest Task: T0 commit> -- SPEC.md
spec-process.*` empty), C5 committed and pushed (a `Task: T5` commit on
`origin/change/build-swe-pod`, with `Change: build-swe-pod`, touching only
`agents/swe-lead.md`).

Red, before the file existed:

```
C1 front-matter FAIL (no agents/swe-lead.md)
C1 headings FAIL (no agents/swe-lead.md)
C2 fixed phrase FAIL (no agents/swe-lead.md)
C2 ledger forms FAIL (no agents/swe-lead.md)
C3 lane table FAIL (no agents/swe-lead.md)
C5 SPEC.md unchanged PASS vs T0 854e87c
C5 committed and pushed FAIL T5 commits on origin: []
summary: 1/7 pass
```

Green, after writing, before the commit:

```
C1 front-matter PASS
C1 headings PASS h2=['Reads', 'Writes', 'Never', 'Returns', 'Steps']
C2 fixed phrase PASS
C2 ledger forms PASS 16/16 exact lines
C3 lane table PASS roles ['build', 'lead', 'plan', 'review', 'spec', 'test']
C5 SPEC.md unchanged PASS vs T0 854e87c
C5 committed and pushed FAIL T5 commits on origin: []
summary: 6/7 pass
```

Green, after commit and push:

```
C5 SPEC.md unchanged PASS vs T0 854e87c
C5 committed and pushed PASS T5 commits on origin: ['1237519']
branches on origin: ['refs/heads/change/build-swe-pod', 'refs/heads/main']
```

Shareability check, after staging and again after the commit:

```
shareability: 0 hits
```

### Fix round 1/5

Fix checks: F1 the `## Writes` section names no `integrated:`,
`abandoned:` or `spec.md`. F2 no text grants the lead a spec line: the old
phrases "lines you add to a spec", "the spec's `integrated:` line" and "add
`integrated: <handle> <UTC>` to the spec" are gone. F3 `## Never` says the
spec author records `integrated:` and `abandoned:` when the lead asks,
filed in the spec role's lane. F4 integrate step 5 has the spec author add
`integrated: <handle> <UTC>`, filed in the spec role's lane, in the one
space commit. C1 to C5 were run again with the same checks as above.

Red, before the fix:

```
C1 front-matter PASS
C1 headings PASS h2=['Reads', 'Writes', 'Never', 'Returns', 'Steps']
C2 fixed phrase PASS
C2 ledger forms PASS 16/16 exact lines
C3 lane table PASS roles ['build', 'lead', 'plan', 'review', 'spec', 'test']
C5 SPEC.md unchanged PASS vs T0 854e87c
C5 committed and pushed PASS T5 commits on origin: ['1237519']
F1 Writes gives the lead no spec line FAIL
F2 no grant of spec lines to the lead FAIL
F3 Never: spec author records both lines when the lead asks FAIL
F4 integrate step 5: spec author adds integrated:, in the spec lane FAIL
summary: 7/11 pass
```

Green, after the fix, before the commit:

```
C1 front-matter PASS
C1 headings PASS h2=['Reads', 'Writes', 'Never', 'Returns', 'Steps']
C2 fixed phrase PASS
C2 ledger forms PASS 16/16 exact lines
C3 lane table PASS roles ['build', 'lead', 'plan', 'review', 'spec', 'test']
C5 SPEC.md unchanged PASS vs T0 854e87c
C5 committed and pushed PASS T5 commits on origin: ['1237519']
F1 Writes gives the lead no spec line PASS
F2 no grant of spec lines to the lead PASS
F3 Never: spec author records both lines when the lead asks PASS
F4 integrate step 5: spec author adds integrated:, in the spec lane PASS
summary: 11/11 pass
```

Green, after commit and push. Each T5 commit touches only
`agents/swe-lead.md` and carries `Change: build-swe-pod`:

```
C5 SPEC.md unchanged PASS vs T0 854e87c
C5 committed and pushed PASS T5 commits on origin: ['8770c1a', '1237519']
summary: 11/11 pass
```

Shareability check, after staging and again after the commit:

```
shareability: 0 hits
```

Also checked: no trailing whitespace, ASCII only, front-matter parses as
YAML. Lines over 88 characters are only the front-matter values, table rows
and lines that must stay exact on one line (ledger forms, the test-writing
brief's last line).

## Concerns

1. **`tools:` is an explicit list, so "all tools" is approximate.** Plan
   section 2.3 requires a `tools:` key and says swe-lead gets all tools,
   Agent included. In Claude Code, a subagent inherits every tool only when
   `tools` is left out. A list gives exactly the listed tools. I listed 16
   built-in tools: Agent, Bash, Read, Write, Edit, Glob, Grep, NotebookEdit,
   WebFetch, WebSearch, TodoWrite, Skill, ToolSearch, Monitor, TaskStop and
   SendMessage. That list leaves out MCP tools and any built-in tool it does
   not name. If "all" has to be literal, the fix is to drop the key, which
   contradicts section 2.3. That needs a ruling.
2. **Line number in a lane refusal.** The form
   `refused <space path>: <profile|reference|id|lane> line <n>` needs a line
   number, but a lane refusal is about the whole file. I chose `lane line 1`
   and said why in the file. It is a minor default.
3. Resolved in fix round 1. The review found that the lead could add
   `integrated:` and `abandoned:` to a spec, which R8 forbids. Now the spec
   author records both lines when the lead asks, as
   `agents/swe-spec.md:130-131` says, and the lead files `spec.md` in the
   spec role's lane.
4. **The deferred executor git exception is described in product terms.**
   "Build tasks run local until mesh executors may commit and push to
   `change/<id>`". If the plan says `runs: mesh` for a build task, the lead
   runs it local and writes a `Ruling:` line. The file does not cite the
   operator decision or its note, since a shipped doc should not cite this
   change's records. The line needs an edit once the exception lands.
5. **Additions from the spec beyond the plan entry's steps.** These are
   lead duties in spec sections 5.3, 5.5, 5.6 and 9, kept short: the
   stop-and-ask list, the stop after three failed fixes, the whole-change
   review dispatch, the sha256 and size check on mesh result files, model
   choice, and the integrate update and prune steps. The reviewer may judge
   any of them as extra.
6. Other builders share this checkout and had files staged when the
   shareability check ran. The check scans the whole index, and it still
   reported 0 hits. My commit holds only `agents/swe-lead.md`.

## Test suggestions

### T5.TS1 Plan request on an unapproved spec

- for the tester: R1 is at risk when the human asks to plan, build or test
  a change whose spec has no `approved:` line in words other than "go".
  The failure I expect is that the lead dispatches a planner or a test
  task anyway, where it should dispatch nothing and say the spec awaits
  approval, giving its path.
- for the reviewer: swe-pod `agents/swe-lead.md:106-108` (Go, step 2) and
  `:51-52` (Never).

### T5.TS2 Test result that also touches a file outside its lane

- for the tester: R8.S1 is at risk when a finished test task's output also
  changes a file outside `changes/<id>/tests/` and `changes/<id>/evidence/`,
  such as the spec or a task report. The failure I expect is that the lead
  files that file along with the tests.
- for the reviewer: swe-pod `agents/swe-lead.md:200-209` (lane table) and
  `:223-227` (Checking and filing, step 4).

### T5.TS3 Requirement edit while a serving task is already running

- for the tester: R1.S2 is at risk when the Requirements section is edited
  while a task that serves the edited requirement has already been
  dispatched. The failure I expect is that the lead marks that task done
  and dispatches its successors before the human approves the edit, or that
  it holds tasks that do not serve the edited requirement.
- for the reviewer: swe-pod `agents/swe-lead.md:318-327` (Requirement
  edits).

### T5.TS4 Build task the plan marks for the mesh

- for the tester: R7 and R23 are at risk when a plan entry has role build
  and `runs: mesh`. The failure I expect is that the lead posts a mesh
  `task.request` for it, where it should run the task locally and leave a
  ruling line in the ledger.
- for the reviewer: swe-pod `agents/swe-lead.md:188-190` (Briefs and
  dispatch, step 4, last bullet).

### T5.TS5 Pin moved, `tests/` unchanged, before a merge

- for the tester: R15.S1 is at risk when only a `pod.yaml` pin has moved
  since the latest evidence and `tests/` has not. The failure I expect is
  that the lead merges on the older evidence without running verify again.
- for the reviewer: swe-pod `agents/swe-lead.md:334-338` (Merge and
  integrate, step 1).

### T5.TS6 Suggestion whose tester part carries a value the code computed

- for the tester: R21.S1 is at risk when a builder's suggestion gives, in
  its "for the tester" part, an expected value the code computed, mixed in
  with spec-terms text. The failure I expect is that some of that part
  still reaches the test agent, for instance in the suggestions task's
  brief.
- for the reviewer: swe-pod `agents/swe-lead.md:243-245` (Suggestions,
  first bullet).
