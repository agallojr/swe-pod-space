# T37 brief

- change: build-swe-pod
- task: T37
- role: build
- repo: swe-pod

## Task

From plan.md, verbatim:

### T37 Role scaling and sharded verify (D1, D2, D4)
- role: build
- repo: swe-pod
- after: [T1, T2, T4, T5, T6, T7]
- runs: local
- needs: any
- serves: [R24]
- touches: PROCESS.md, agents/swe-plan.md, agents/swe-lead.md,
  agents/swe-test.md, skills/swe-pod/SKILL.md,
  skills/swe-pod/status-format.md, templates/records/evidence.md,
  templates/records/report.md
- steps:
  - **PROCESS.md.**
    - §4 Plan: tasks with no dependency run in parallel by default, and a
      task whose work divides may be sharded across a role's holders, with
      the plan naming the shards and how the work divides.
    - §7 Verify: sharded verify, with the §2.4 rule for when a sharded verify
      counts as verified, written in plain words. PROCESS.md is copied into
      every space, so it never cites a bare requirement id.
    - §11 Dispatch: test shards run local and mesh together, from one brief
      per shard, all filed in one space commit. Build shards stay local
      until the deferred exception lands (§3 OD4).
  - **swe-plan.** Plan parallel by default. Name the shards, and say how the
    work divides.
  - **swe-lead.** Dispatch the shards, and log a dispatch line for each.
    Apply the §2.4 verified rule. A test task's report is filed in its lane
    (§2.4).
  - **swe-test.** Run only the shard your brief lists. Write the shard
    record with `shard:` and `tests:`, and put the report under
    `evidence/`.
  - **Skill.** The verified rule is the §2.4 one, and STATUS.md shows each
    shard's latest record (§2.6). The skill reads state for the lead
    (R24.S2).
  - **Evidence template.** Add `shard:` and `tests:`, and the shard file
    name.
  - **Report location.** In PROCESS.md §12's space layout and in the report
    template's path line, a test task's report goes under `evidence/`
    (§2.4).
- done when: (1) a grep finds `shard` in PROCESS.md §4, §7 and §11, finds
  `shard:` and `tests:` in the evidence template and the skill, and finds no
  bare `R24` in PROCESS.md; (2) review checks every rule in the steps; (3)
  the standard close holds.

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
  before the final verify run, and T0's check (3) is run again. The standard
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

### 2.3 Role definitions (Claude Code agent definitions)

- Front-matter keys: `name: swe-<role>`, `description:` (one sentence on when
  to use it), `tools:`, `model: inherit`.
- `tools` per role. swe-spec: Read, Grep, Glob, Bash, Write, Edit. swe-plan:
  Read, Grep, Glob, Bash, Write. swe-lead: all tools, Agent included.
  swe-build: Read, Grep, Glob, Bash, Write, Edit. swe-test: Read, Grep, Glob,
  Bash, Write, Agent. swe-review: Read, Grep, Glob, Bash, with no Write and no
  Edit.
- Body headings, exactly: `## Reads`, `## Writes`, `## Never`, `## Returns`.
  `## Steps` is optional.
- **Local dispatch.** The lead starts a subagent of type `swe-<role>` whose
  prompt holds the brief's space-relative path, and on its own line the
  checkout paths on this node. Before the definitions are installed, the lead
  starts a general-purpose subagent and puts the definition's text above the
  same prompt. Machine paths go in the prompt, never in the brief.
- **Mesh dispatch.** The `## Context` of the task.request holds at least two
  lines: `Role definition: swe-pod/agents/swe-<role>.md` (relative to the bus
  root) and `Brief: changes/<id>/tasks/T<n>-brief.md` (relative to the space).
  The Goal tells the executor to read the role definition before anything
  else. Front-matter has `project: proj:<name>`. For a node that may predate the
  change (T19b), the Context also gives the repo URLs, the space commit that
  holds the brief, and the commit set under test, as separate lines.
- **Where outputs go.** A local agent writes its outputs at their final
  space-relative path. A mesh agent returns them as result files (§2.7). The
  lead files both kinds through the space's librarian.

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
  `## Result goes to`. A shard's `## Task` also lists the tests or files that
  shard runs.
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
  `- for the tester:` and `- for the reviewer:` lines. A test task's report
  goes in its lane (R8.S1), as `evidence/<YYYYMMDDTHHMMZ>-<task id>-report.md`.
- **Review** `T<n>-review.md`. Front-matter: `task: T<n>`,
  `diff: <repo> <sha7>..<sha7>` (one line per range), `verdict: pass|fix`.
  Sections: `## Spec compliance` (missing, extra, misread), `## Quality`,
  `## Findings`. Each finding line is
  `- <Critical|Important|Minor> <repo>/<path>:<line> <text>`. The
  whole-change review uses the same format, under its own task number.
- **Evidence** `changes/<id>/evidence/<YYYYMMDDTHHMMZ>.md`, or
  `<YYYYMMDDTHHMMZ>-<shard id>.md` for a shard, with these front-matter keys:
  - `id: ev-<YYYYMMDDTHHMMZ>` (`ev-<YYYYMMDDTHHMMZ>-<shard id>` for a shard)
    and `change`;
  - for a shard, `shard: <task id>` and `tests: [<test name>, ...]`, the tests
    that record ran;
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
- **Verified, for a sharded verify (R24).** The current commit set is the
  branch heads now, together with the space commit that holds the latest
  shard briefs. Take each named shard's latest record. The change is
  verified only if:
  - every one of those records names the current commit set;
  - every result in every one of them passes;
  - together they cover every scenario, unit suite and declared quality
    check.

  A shard whose latest record names another commit set is out of date, and
  is re-run at the current commit set.
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
- Task ids `T<n>`, and shard ids `T<n>a`, `T<n>b`. Suggestion ids `T<n>.TS<k>`.
  Inspection ids `I<n>`.
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

### 2.6 swe-pod skill (`skills/swe-pod/SKILL.md`, name `swe-pod`)

- **When it is invoked:** in a Project Space, when the human asks where
  things stand, says go, asks for the status to be regenerated, or asks for a
  traceability check. The description says when to invoke it and gives no
  standing rule.
- **STATUS.md** is built to `status-format.md`. These lines are exact:
  `# Status: <space id>`, then `Generated from the records; never edited by
  hand. As of <UTC of the newest ledger line or record>.`, then
  `- pins: <repo> <sha7>, ...` and `- open changes: <n> (<state>: <k>, ...)`.
  Each open change gets `## <id>   state: <state>   owner: <handle>`,
  followed by bullets for:
  - gates passed, with handle and UTC;
  - branches, with their heads;
  - a task table (task, role, runs, state, latest);
  - the latest evidence, or for a sharded verify each shard's latest record;
  - open findings, as `Critical <n>, Important <n>, Minor <n>`;
  - `next:`.

  Nothing in it depends on the wall clock, so regenerating it from unchanged
  records gives the same text.
- **Trace output:** a first line `TRACE <change id>: <n> breaks`, then one line
  per break: `BREAK requirement-without-task <Rn>`,
  `BREAK scenario-without-test <Rn.Sm>`, `BREAK task-without-commit T<n>`,
  `BREAK test-without-evidence <test name>` or `BREAK evidence-stale <ev id>`.

### 2.8 Shareability check (builders' standard close)

The check uses the §2.7 profile patterns, plus the owner handles in the
space's `space.yaml`, all built at run time, so the command text holds no
real values. It scans only the lines the task's diff adds, where the task's
diff is its own commits, found by the trailer `Task: T<n>` (§4.1), plus its
staged changes before the first commit. It prints `<file>:<line> <pattern
kind>` per hit, never the matched text. A report records only
`shareability: <n> hits`.

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

- **OD1** (question 1, amended by OD6). Seven scenarios are desk-verified
  in this change, and the pilot must run them live: R4.S1, R5.S2, R14.S1,
  R15.S1, R22.S1, R23.S1 and R23.S2, plus the commit step of R17.S2. R7.S1
  and R17.S1 are desk-verified against the deliverables, and are also
  observed live at T19b's own dispatch, on the pre-change remote product
  (OD6). The final report
  says, verbatim: "7 scenarios desk-verified, live confirmation at pilot;
  R7.S1 and R17.S1 verified live at T19b".
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
- **OD6** (directive). The former T20 is merged into verify. The remote
  shard, T19b (OD7), is run by a pod agent that holds `swe.test` on a
  linux-server node, dispatched through the mesh. The operator keeps that
  agent standing by, with read access to the three private repos and its own
  signed-in isolated runner config. Its dispatch is the live evidence for
  R7.S1, and the filing of its returned files is the live evidence for
  R17.S1.
- **OD7** (spec amendment and standing rule). R24, Scaled roles, and the
  Scaling bullet of spec §7 are approved (space `2d8d8f7`; `SPEC.md`
  re-copied at swe-pod `74d23f1`).
  - Every pair of tasks with no dependency between them runs in parallel by
    default.
  - Verify is two shards at one commit set: T19a, local on macos-laptop, and
    T19b, mesh on linux-server.
  - Each shard files its own evidence record, and the change is verified
    only as R24 says (§2.4).

Operator choices on verify, PC1 to PC3. The plan proceeds with each
default until the operator picks:

- **PC1** (A32): **decided (a)** by the operator (ledger, 00:48Z). T19b runs
  serially, like T19a, on one signed-in config, and each config serves one
  runner process at a time. The parallel-slot option, and its task T40, are
  dropped.
- **PC2** (A34): who authorizes T19b's long runs on the remote node.
  - (i), the default: the operator approves the heavy ask, the lead records
    it as a `heavy:` ledger line, and T19b's Context quotes that approval,
    with its caps and expected time, as the operator's express permission.
    The lead posts the task, and the remote tester cites the approval. Risk:
    an executor may still decline a quoted permission that it cannot verify.
  - (ii): the operator posts T19b, so the remote node's overlay counts it as
    operator-posted.
- **PC3** (A41): whether the pilot also runs R7.S1 and R17.S1 live against
  the deliverables. The default is yes; the operator may rule them closed by
  T19b.

Repo rule, not from the spec: agent-mesh carries no operator content
(PROTOCOL §12), and swe-pod follows the same rule. Templates use `<handle>`
and similar placeholders, never a real name, path or host.

## Rulings

None yet.

## Start from

- swe-pod: branch change/build-swe-pod at its head when this task is dispatched, after every task in its after list has closed
- space: main at the commit that files this brief

## Result goes to

- code: commits on change/build-swe-pod in swe-pod, trailers `Change: build-swe-pod` and `Task: T37`, pushed
- report: changes/build-swe-pod/tasks/T37-report.md, returned to the lead for filing
