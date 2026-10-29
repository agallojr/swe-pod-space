# T1 brief

- change: build-swe-pod
- task: T1
- role: build
- repo: swe-pod

## Task

From plan.md, verbatim:

### T1 PROCESS.md (D1)
- role: build
- repo: swe-pod
- after: [T0]
- runs: local
- needs: any
- serves: [R1, R2, R3, R4, R5, R6, R10, R11, R12, R13, R14, R15, R18, R19, R21, R22, R23]
- touches: PROCESS.md
- produces: §2.2 headings and version line
- steps:
  - Rewrite spec §4 and §§5 to 11 as instructions addressed to the agent,
    keeping every rule and table. D1 names §§5 to 11, but D1 serves R22 and
    R23, whose rules live in §4. §4 becomes `## 1 Shape of a project`: where
    things live, the `pod.yaml` format, and the branch rules (create at the
    go from the pin, record the base, no other branch, amendments stay on
    the same branch, rebase when `main` moves, delete after the merge).
  - Cite record templates as `templates/records/<kind>.md`.
  - In §11, state three rules:
    - the M4 interim rule: each cycle, the lead dispatches every task whose
      `after` tasks are all done;
    - a mesh executor reads the role definition its task.request names
      before anything else;
    - build tasks run local until the deferred executor git exception lands
      (§3 OD4).
  - In §10, describe single seat: without a mesh, records are filed through
    agent-mesh's `space-librarian`.
  - Use environment classes only.
- done when: (1) `sed -n 1p` and `sed -n 3p` print the two exact lines of
  §2.2; (2) `grep '^## ' PROCESS.md` prints the 15 headings of §2.2, in that
  order; (3) `## 1 Shape of a project` holds the `pod.yaml` example and the
  branch rules; (4) review checks that each of these tables is present:
  stages, states, suggestion routing, failure routing, sizes, roles,
  placement; (5) the standard close holds.

Standard close, from plan.md section 5, verbatim:

The rules below hold for every build task. `runs: local` and `needs: any`.
Steps: write the done-when checks first and run them, so they fail on the
missing content; then write the content; then run the checks again and see
them pass. Put the red and green output in the report.

Every build task's done-when also includes the **standard close**:

- The shareability check (§2.8) reports 0 hits.
- `git diff <latest Task: T0 commit> -- SPEC.md spec-process.*` is empty
  (swe-pod).
- The task's files are committed to `change/build-swe-pod` with trailers
  `Change: build-swe-pod` and `Task: T<n>`, by pathspec, and pushed (§4.1).
- The task's review (§7) has no open Critical or Important finding.

A successor that lists a task in `after` therefore also waits for that task's
review. Where a done-when says "review checks", the reviewer confirms each
rule listed in the steps; no grep stands in for that.

Commits and filing, from plan.md section 4.1, verbatim:

### 4.1 Build checkouts, commits and filing

- **Checkouts.** There is one build checkout per code repo, outside the bus
  and outside every other repo, made with the git worktree mechanism. The
  operator has allowlisted both paths. They appear only in dispatch prompts,
  never in a record, and the deliverables never refer to them. Nothing for
  this change is edited in the bus's `product/` or `swe-pod/` checkouts. The
  parallel builders in one repo share that repo's checkout.
- **Commits** (§3 OD2). A builder stages and commits only its own files, as
  `git add -- <touches>` followed by `git commit -- <touches>`, then pushes.
  If the index lock is held, or a push is rejected, it waits and retries,
  three times at most, and never stages another task's files. Every builder
  commits on one local branch, so spec §5.3's rebase is a no-op here. Run
  `git pull --rebase` only when a push is rejected. Test and review agents
  never commit.
- **Per-task diffs.** A task's diff is its own commits, found by the trailer
  `Task: T<n>`. Its reviewer and its shareability check use that diff, never
  a range of the shared branch.
- **Filing** (§3 OD2). The librarian files and pushes every space record in
  the bus's space checkout on `main`. Until T30 (the review of T10) closes,
  it applies the §2.7 checks as written in this plan. After that it follows
  the space-librarian skill in the agent-mesh checkout; the skill is
  installed only at T36.
- **STATUS.md** is first regenerated when T27 (the review of T7) closes,
  following the skill in the swe-pod checkout. Until then the ledger is
  authoritative.
- **SPEC.md after a spec amendment.** If `spec.md` is amended (with
  approval), the spec role re-copies the amended text into `SPEC.md`
  verbatim, and the lead commits it with trailer `Task: T0`. Both happen
  before the final T19 run, and T0's check (3) is run again. The standard
  close compares `SPEC.md` against the latest `Task: T0` commit.

## Interfaces

From plan.md section 2, verbatim:

### 2.2 PROCESS.md

- Line 1 is `# SWE Pod process` and line 3 is `process: swe-pod-process@1`. A
  space's `pod.yaml` pins that exact string.
- It has these level-2 headings, in this order: `## 1 Shape of a project`,
  `## 2 Stages and states`, `## 3 Spec`, `## 4 Plan`, `## 5 Build`,
  `## 6 Project-level tests`, `## 7 Verify`, `## 8 Integrate`, `## 9 Sizes`,
  `## 10 Roles`, `## 11 Dispatch`, `## 12 The Project Space`,
  `## 13 When things go wrong`, `## 14 Talking to the pod`,
  `## 15 Status view`. Role definitions and the skill cite these as
  `PROCESS.md §<n>`.

### 2.4 Record formats (`templates/records/`)

- **Spec header lines:** `- approved: <handle> <YYYY-MM-DDTHH:MMZ>`,
  `- integrated: <handle> <UTC>`, `- abandoned: <UTC> <reason>`. Sections:
  Why, Scope, Requirements, Quality, Approaches, Open calls (spec §5.1).
- **Plan:** sections 1 to 10 of spec §5.2, then `## Self-review`, then
  `## Questions for the spec`. Each question is sorted (a) answered, (b)
  minor with the default planned, or (c) for the human.
- **Brief** `changes/<id>/tasks/T<n>-brief.md`, with sections `## Task` (the
  plan entry, verbatim), `## Interfaces`, `## Global constraints`,
  `## Rulings`, `## Start from` (the commit set, by sha) and
  `## Result goes to`.
- **Test-writing brief** (same path). Sections:
  - `## Task`: the test task's own entry, verbatim. It is not a build-task
    step, so R9 allows it.
  - `## Spec` (path only).
  - `## Interface contract`, `## Global constraints` (all of §3, operator
    decisions included) and `## Test map`, copied from the plan.
  - `## Start from`: the base commit set, and the commit set under test.
  - `## Suggestions` (the suggestions task only): the "for the tester" parts.
  - `## Result goes to`.

  The brief ends with this line, exactly: `Do not read plan.md, ledger.md,
  any other brief, report or review, or any code-repo diff or implementation
  body.`
- **Report** `T<n>-report.md`, with sections `## Status` (one of `DONE`,
  `DONE_WITH_CONCERNS`, `BLOCKED`, `NEEDS_CONTEXT`), `## What I did`,
  `## Files`, `## Test output` (red and green for each check), `## Concerns`
  and `## Test suggestions`. Each suggestion is `### T<n>.TS<k> <title>` with
  `- for the tester:` and `- for the reviewer:` lines.
- **Review** `T<n>-review.md`. Front-matter: `task: T<n>`,
  `diff: <repo> <sha7>..<sha7>` (one line per range), `verdict: pass|fix`.
  Sections: `## Spec compliance` (missing, extra, misread), `## Quality`,
  `## Findings`. Each finding line is
  `- <Critical|Important|Minor> <repo>/<path>:<line> <text>`. The
  whole-change review uses the same format, under its own task number.
- **Evidence** `changes/<id>/evidence/<YYYYMMDDTHHMMZ>.md`, with these
  front-matter keys:
  - `id: ev-<YYYYMMDDTHHMMZ>` and `change`;
  - `commit_set: {space: <sha7>, <repo>: <sha7>, ...}`, naming every repo in
    `pod.yaml`, with a repo the spec does not name at its pin;
  - `env: <environment class>` and `actor: <handle>/test`;
  - `scenarios: {<Rn.Sm>: pass|fail|not-run, ...}`, with regression results
    under qualified ids, `<change>/<Rn.Sm>`;
  - `unit: {<repo>: pass|fail|none-present}`;
  - `quality: {<Qn>: pass|fail}` or `quality: none-declared`;
  - optional `x-checks: {<In>: pass|fail}` and
    `x-suggestions: {T<n>.TS<k>: pass|fail}`;
  - `wall_time_s: <integer>`.

  The body holds failure summaries. Logs appear only as pointers, which must
  be space-relative paths or URLs, never a machine path. A `not-run (cap)`
  result names its cap.
- **Ledger** `changes/<id>/ledger.md`: one fenced block, one event per line,
  `<YYYY-MM-DDTHH:MMZ> <event>`. Continuation lines are indented 18 spaces.
  Event forms:
  ```
  spec approved by <handle>
  go by <handle>; branches change/<id>: <repo> <sha7>[, <repo> <sha7>]
  dispatch T<n> -> <role> (<local|mesh>, <env class|any>)[, base <repo> <sha7>]
  T<n> <DONE|DONE_WITH_CONCERNS|BLOCKED|NEEDS_CONTEXT>[, <repo> <sha7>..<sha7>][, unit <p>/<n> pass]
  T<n> review: <spec ok|spec issues>; <k> <Severity> [<repo>/<path>:<line>]
  T<n> fix round <r>/5: <a> addressed, <o> open, <sha7>..<sha7>
  T<n> at base: <test name> <fail|pass> (<reason>)[, ...]
  T<n> returned to test: <test name> passed at base
  T<n>.TS<k> -> <test|spec|builder>
  T<n>.TS<k> returned to builder: carries a computed value
  T<n>.TS<k> outcome: <tested <test name>|proposed as scenario|unit-tested|declined: <reason>|dropped>
  approval reopened for <Rn>[, <Rm>]; held T<a>[, T<b>]
  heavy: asked <handle> before T<n>: <command name>; caps <caps>; expected <s> s
  Ruling: <what>; <why>; <cost if wrong>
  filed <space path>[, ...]
  refused <space path>: <profile|reference|id|lane> line <n>
  ```
  A `refused` line never quotes the text that matched.
- **Handoff** `handoffs/<YYYYMMDDTHHMMZ>-<change id>.md`, with sections
  `## State`, `## Half-done`, `## Open questions` and `## Next command`.
- **Final report** `changes/<id>/report.md`, with sections `## Scenarios` (a
  table of scenario, test, result and evidence id), `## Rulings` (every
  `Ruling:` line in the ledger), `## Deferred minors`, `## Test suggestions`
  (every suggestion and its outcome), `## Open questions` and `## Branches`
  (each repo's branch and head).

### 2.5 Names and fixed phrases

- Branch `change/<id>`. Commit trailers `Change: <id>` and `Task: T<n>`.
- Task ids `T<n>`. Suggestion ids `T<n>.TS<k>`. Inspection ids `I<n>`.
- Test files go in `changes/<id>/tests/`, named `test_R<n>_S<m>_<slug>.md`,
  `test_I<n>_<slug>.md` or `test_T<n>_TS<k>_<slug>.md`. Each test has one
  mode:
  - `agent`: a fresh agent is run and its outputs are checked.
  - `desk`: as `agent`, but the agent prints the git and mesh commands it
    would run, and runs none of them. Desk evidence is used per §3 OD1.
  - `inspect`: the deliverables are read, or commands are run on them.
- Change states (spec §5): proposed, approved, planned, building, verified,
  integrated, abandoned. Task states in STATUS.md: waiting, ready, dispatched,
  done, blocked.
- **Fixed phrases.** Done-whens check these; tests check behavior, not
  wording (spec §5.4).
  - Lead, given "go" on an unapproved spec: `Not dispatched: the spec at
    changes/<id>/spec.md awaits approval.`
  - Planner, given a requirement without a scenario: `No plan written: <Rn>
    has no scenario. Returned to the spec author.`
  - Builder disputing a project-level test, in `## Concerns`:
    `Disputed test: <test name>; spec clause: <clause>`.
  - Poller, executor results: `Return each file the task asks for under
    files:, text only, at most 1048576 bytes each.`

## Global constraints

From plan.md section 3, verbatim:

## 3. Global constraints and operator decisions

Verbatim from the spec:

- "Build output: Markdown (§13). The SWE Pod is a process carried by
  documents, role briefs, templates and a skill that agents read. Nothing in
  it is compiled." (header)
- "Every number carries its unit and tolerance, and any convention it depends
  on: norm, normalization, reference solution." (§5.1)
- "The Project Space has one branch, `main`, and never another." (§4)
- "Each code repo a spec names gets exactly one code branch for that spec,
  `change/<id>`." "No other branch is pushed: no task, agent or personal
  branches." (§4)
- "Builders commit to the change's one branch, `change/<id>`, with trailers
  `Change: <id>` and `Task: <n>`, rebase on it before pushing, and push only
  to it. They never create a branch." (§5.3)
- "Records use the shareable profile of the memory-spaces concept: actors are
  human handles or `handle/role`, machines are environment classes, paths are
  relative to the space or are URLs. No hostname, agent id, mesh task id, home
  path or credential name (R16)." (§8)
- "**Environment class** | A machine kind (`macos-laptop`, `linux-server`,
  `hpc-login`), never a hostname." (§2)
- "Each test records its expected run time; over 60 s it is marked heavy."
  (§5.4)
- "Fix loop: at most 5 rounds per task, then a ruling." (§15.8)
- "Pod roles loosen no mesh fence. The git gate, the solver-run fence and the
  budget policy bind every pod agent, and heavy checks run under them like any
  solver run." (§7)

Operator decisions and directives for this change. The ledger records each
one; elsewhere the plan cites them by id.

- **OD1** (question 1). The nine scenarios R4.S1, R5.S2, R7.S1, R14.S1,
  R15.S1, R17.S1, R22.S1, R23.S1 and R23.S2, plus the commit step of R17.S2,
  are desk-verified in this change, and the pilot must run those nine live.
  The final report says, verbatim: "9 scenarios desk-verified, live
  confirmation at pilot".
- **OD2** (question 2). Within G1's scope, the pod's agents make the commits
  and pushes:
  - the lead creates `change/build-swe-pod` in both code repos and makes T0's
    commit;
  - build agents commit to and push only that branch;
  - the space's `main` is committed and pushed through the librarian.

  Never `main` of a code repo, and never a force push. Merging stays with the
  operator. The overlay is not edited before T36.
- **OD3** (question 3). The mesh poller stays off on the lead's node from the
  go to T36. The librarian's ancestor check (§2.7) stays in place anyway.
- **OD4** (question 4). Deferred. T9 is registration-only, as spec §14 says.
  The executor git exception is recorded in `note-20261027T2242Z-0786`, for
  the change that first puts builders on remote nodes.
- **OD5** (directive). The design doc is an input. `SPEC.md`,
  `spec-process.d2`, `.svg` and `.png` at the top of swe-pod restate the
  approved spec, with a `README.md` that points to them. They are uncommitted
  in the swe-pod working tree today. T0 lands them as the first commit on the
  swe-pod branch, and no build task writes them. For R4 they count as docs
  that ship with the product. A change spec is only `changes/<id>/spec.md` in
  a Project Space.

Repo rule, not from the spec: agent-mesh carries no operator content
(PROTOCOL §12), and swe-pod follows the same rule. Templates use `<handle>`
and similar placeholders, never a real name, path or host.

## Rulings

None yet.

## Start from

- swe-pod: branch change/build-swe-pod at 854e87c (T0)
- space: main at the commit that files this brief

## Result goes to

- code: commits on change/build-swe-pod in swe-pod, trailers `Change: build-swe-pod` and `Task: T1`, pushed
- report: changes/build-swe-pod/tasks/T1-report.md, returned to the lead for filing
