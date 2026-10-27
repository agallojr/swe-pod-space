# T1 report: PROCESS.md (D1)

## Status

DONE_WITH_CONCERNS

## What I did

- Wrote `PROCESS.md` in swe-pod. It restates spec §4 and §§5 to 11 as
  instructions to the agent, with each rule naming the role it binds. Line 1
  is `# SWE Pod process`, line 3 is `process: swe-pod-process@1`, and the 15
  level-2 headings of plan §2.2 appear in order, with no other level-2 line.
  Fenced examples that hold `## ` lines are indented under a list item, so
  `grep '^## '` sees only the 15 headings.
- `## 1 Shape of a project` holds the "lives in" table, the `pod.yaml`
  example, and the branch rules: create `change/<id>` once at the go from the
  pin, record the base in the ledger's go line, no branch for a repo the spec
  does not name (verify uses its pin), no other branch pushed, amendments on
  the same branch, rebase onto a moved `main` and verify again, delete after
  the merge, on the human's word.
- All seven tables are kept: stages (§2), states (§2), suggestion routing
  (§6), failure routing (§7), sizes (§9), roles and placement (§10). So are
  the lives-in table (§1) and the talking table (§14).
- §11 states the three rules from the brief: the M4 interim rule ("each
  cycle, the lead dispatches every task whose `after` tasks are all done"); a
  mesh executor reads the role definition its `task.request` names before
  anything else; build tasks run `local` until the deferred executor git
  exception lands. §10 Single seat files records through agent-mesh's
  `space-librarian` skill.
- Every record template is cited as `templates/records/<kind>.md`, all ten
  kinds. Machines appear only as environment classes. Actors appear only as
  `<handle>` or `<handle>/<role>`.
- Committed by pathspec with trailers `Change: build-swe-pod` and `Task: T1`,
  and pushed: swe-pod `101cebb..ab800ec` (one commit, `ab800ec`, parent
  `101cebb`, the branch head when I committed).

Fix round 1/5:

- Addressed the Important finding at `PROCESS.md:687`. The §11 Ordering rule
  now defines a review task's `after` list, in plan §7's words: "In a review
  task, `after: [T<k>]` means T<k> has reported and its commit exists; T<k>
  is done only when that review closes." The definition sits before the M4
  interim rule in the same bullet, so the interim rule's "done" reads with
  it, and a per-task review can be dispatched. The rest of the bullet is
  reflowed to the new line breaks; no other wording changed.
- Committed by pathspec with the same trailers and pushed: swe-pod
  `1237519..45572b0` (one commit, `45572b0`, parent `1237519`, the branch
  head when I committed). T1's commits are now `ab800ec` and `45572b0`.

## Files

- swe-pod `PROCESS.md` (created, 844 lines; fix round 1 made it 845
  lines)

## Test output

The checks were run from the swe-pod checkout root.

**Check 1** (`sed -n 1p` and `sed -n 3p`). Red:

```
line1: sed: PROCESS.md: No such file or directory
line3: sed: PROCESS.md: No such file or directory
check 1 FAIL
```

Green:

```
line1: # SWE Pod process
line3: process: swe-pod-process@1
check 1 PASS
```

**Check 2** (`grep '^## ' PROCESS.md`, diffed against the 15 headings of
§2.2). Red:

```
1c1,15
< ugrep: warning: PROCESS.md: No such file or directory
---
> ## 1 Shape of a project
  ... (all 15 expected headings listed as missing)
check 2 FAIL
```

Green:

```
## 1 Shape of a project
## 2 Stages and states
## 3 Spec
## 4 Plan
## 5 Build
## 6 Project-level tests
## 7 Verify
## 8 Integrate
## 9 Sizes
## 10 Roles
## 11 Dispatch
## 12 The Project Space
## 13 When things go wrong
## 14 Talking to the pod
## 15 Status view
check 2 PASS
```

**Check 3** (section 1 extracted with awk between `## 1 ` and the next
level-2 heading. It is grepped for the `pod.yaml` example, with `pod: 1`,
`process: swe-pod-process@1`, `repos:`, `pin:`, `depends:` and `gates:`, and
for the branch rules: `change/<id>`, `base commit`, `No other branch`,
`amendment`, `rebase`, `after its merge`). Red:

```
missing: ```yaml
missing: pod: 1
missing: process: swe-pod-process@1
missing: repos:
missing: pin:
missing: depends:
missing: gates:
missing: change/<id>
missing: base commit
missing: No other branch
missing: amendment
missing: rebase
missing: after its merge
check 3 FAIL
```

Green:

```
check 3 PASS
```

**Check 4.** The review decides this one. I used a grep for each table's
header row as an aid only. Red:

```
missing table: | Stage | Role | Reads | Writes | Done when | Gate |
missing table: | State | Read from |
missing table: | Suggestion | Goes to | Outcome |
missing table: | Failure | Goes to | Carrying |
missing table: | Size | When | Spec | Plan | Human gates |
missing table: | Role | Writes | Never |
missing table: | Role | Usually |
check 4 FAIL
```

Green:

```
check 4 PASS
```

**Check 5, the standard close:**

- `git diff 854e87c -- SPEC.md 'spec-process.*'` is empty before the change
  and after the commit (0 bytes).
- Commit: before, there was no `Task: T1` commit
  (`close-commit FAIL (no Task: T1 commit)`). After,
  `git log -E --grep='^Task: T1$'` gives `ab800ec`, with the trailers
  `Change: build-swe-pod` and `Task: T1`. `ab800ec` is an ancestor of
  `origin/change/build-swe-pod` after a fresh fetch.
- Shareability check, after staging and again after the commit:
  `shareability: 0 hits`.
- The review has not run yet; that is T21's part of the close.

**Fix round 1/5.** The check takes the §11 Ordering bullet (from
`- **Ordering.**` to the next bullet), joins its lines, and looks for
`review task`, `has reported`, `commit exists`, `done only when` and
`interim rule`, and for the definition coming before the interim rule. Red,
on `PROCESS.md` as committed at `ab800ec` (unchanged at the branch head):

```
missing in Ordering: review task
missing in Ordering: has reported
missing in Ordering: commit exists
missing in Ordering: done only when
definition not before interim rule
fix check FAIL
```

Green, after the edit:

```
fix check PASS
```

The first version of the check did not collapse the indent at a line
break, so it reported `review task` missing after the edit too. I fixed the
check and ran it red again on the committed file, as above.

Checks 1 to 4 run again after the edit:

```
line1: # SWE Pod process
line3: process: swe-pod-process@1
check 2 PASS
check 3 PASS
check 4 PASS
```

Standard close, fix round 1: `git diff 854e87c -- SPEC.md 'spec-process.*'`
is empty (0 bytes). `git log -E --grep='^Task: T1$'` gives `45572b0` and
`ab800ec`; `45572b0` is an ancestor of `origin/change/build-swe-pod` after
a fresh fetch. Shareability check after staging and again after the commit:
`shareability: 0 hits`. As in concern 8, the run after staging also saw
other builders' staged files; the run after the commit covers T1's commits
only.

## Concerns

Fix round 1: no new concern; I agree with the finding. The concerns below
are from the first round and still stand.

1. **Single seat versus independence.** Spec §6 says the single seat is
   "spec author, planner, lead". The same section requires spec and plan to
   be different agents at project size. `PROCESS.md` §10 settles this by
   having the single seat plan through a fresh local subagent at project
   size. Please confirm that reading.
2. **Examples changed to agree with the build-local rule.** The spec's
   plan-task example (a build task) and its ledger example (`dispatch T3 ->
   build (mesh, any)`) both show a mesh build. Both now say `local`, so they
   do not contradict §11's rule.
3. **The task.request example gained lines from plan §2.3:** the
   `Role definition: swe-pod/agents/swe-test.md` and `Brief: ...` Context
   lines, and a Goal sentence telling the executor to read the role
   definition first.
4. **Names follow the interface contract where it differs from the spec.**
   Briefs, reports and reviews are `T<n>-brief.md` and so on, and the
   trailer is `Task: T<n>`, per plan §§2.4 and 2.5. The spec writes
   `<n>-brief.md` and `Task: <n>`.
5. **Content beyond spec §§4 to 11.** I added these from the interface
   contract, where they state a rule of a requirement D1 serves:
   - the three fixed phrases of §2.5 (lead, planner, disputed test);
   - ledger event forms of §2.4, at the rules that produce them;
   - the evidence values `none-present`, `none-declared` and
     `not-run (cap)`;
   - the test-writing brief's contents;
   - local and mesh dispatch details of §2.3, and result files of §2.7;
   - the task states of §2.5;
   - per-task diffs found by trailer, and staging by path for parallel
     builders.

   The lane refusal for test results (§11 "Lanes") serves R8.S1. That is
   D2's requirement, not D1's, so the reviewer may judge it extra.
6. **Dropped:**
   - the (OS) and (SP) provenance markers;
   - the embedded diagram, since `spec-process.png` is not in a space;
   - citations of swe-pod requirement and M ids (R15, M5 and so on). Those
     ids belong to the swe-pod spec and mean nothing in another project's
     space, so each rule is stated in full instead.

   "Hand this to Ana" became "Hand this to `<handle>`" (placeholder rule).
7. **Forward references.** `memory-spaces §6.3` and `§3.4` are cited as
   being in agent-mesh's `spec/memory-spaces.md`, which T11 creates. If T11
   renumbers the design, these cites break. The result-files rule cites no
   PROTOCOL section, because T13 adds that section and its number is not
   fixed yet.
8. **Shared checkout.** The pre-commit shareability run also scanned files
   other builders had staged at that moment (`templates/space/*`). It
   reported 0 hits, so nothing changed, but that count was not T1's alone.
   The post-commit run covers only T1's commit.

## Test suggestions

### T1.TS1 Approval text outside the header

- for the tester: R1 is at risk when a spec's header has no `approved:`
  line but its body has the text `approved:` somewhere else, for example
  quoted under Open calls. Given "go", the lead may read the change as
  approved and dispatch.
- for the reviewer: `PROCESS.md:106-109` and the states table at
  `PROCESS.md:117-118`, which say "`spec.md` has `approved:`" without
  saying it must be the header line.

### T1.TS2 Stale evidence when only the regression suite moved

- for the tester: R15 is at risk when another change integrates and adds
  tests to `tests/` but moves no pin of the waiting change's repos. Given
  "merge" for the waiting change, the lead may merge on its old evidence
  without running verify again.
- for the reviewer: `PROCESS.md:529-531` (integrate step 1) and the rebase
  rule at `PROCESS.md:85-87`, which names only `main` moving.

### T1.TS3 Single seat at project size

- for the tester: R17.S2 and the independence rule are at risk in a
  single-seat session with no mesh, on a project-size spec. The session may
  write `plan.md` in its own context instead of through a fresh agent, so
  spec and plan are one agent.
- for the reviewer: `PROCESS.md:606-614`, the single-seat paragraph and its
  project-size sentence.

### T1.TS4 Heavy check found only from the recorded run time

- for the tester: R13.S1 is at risk in a live session when a verify task's
  test records an expected run time just over 60 s but is not labelled
  heavy, and also when the time is exactly 60 s, which is not heavy. The
  lead may dispatch the first without giving the command, caps and expected
  wall time, or ask about the second.
- for the reviewer: `PROCESS.md:405` (the test agent marks a test heavy) and
  `PROCESS.md:700-706` (the lead's fence rule).

### T1.TS5 Suggestion with a computed value given as a tolerance

- for the tester: R21.S1 is at risk when a "for the tester" part gives the
  code's result as an approximate or bounded number, such as an error the
  solve "settles near", not as an exact expected value. The lead may not
  see it as a computed value and pass it to the test agent.
- for the reviewer: `PROCESS.md:447-449`.

### T1.TS6 Review task waiting on its own build task

- for the tester: R6's `after` lists are at risk in a session where a
  build task has reported and committed, and the next dispatch cycle comes.
  The lead may hold the build task's review because the build task is not
  yet done, so the build stalls. Or, the other way, it may dispatch a
  successor of the build task before that review closes.
- for the reviewer: `PROCESS.md:687-694`, the §11 Ordering bullet and its
  review-task definition.
