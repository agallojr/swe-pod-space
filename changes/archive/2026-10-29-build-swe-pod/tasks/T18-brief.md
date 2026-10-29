# T18 brief

- change: build-swe-pod
- task: T18
- role: test
- repo: space

## Task

From plan.md, verbatim:

### T18 Builder test suggestions
- role: test
- repo: space
- after: [T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14, T37]
- runs: local
- needs: any
- serves: [R21]
- touches: changes/build-swe-pod/tests/test_T*_TS*_*.md (new files only)
- steps: For each "for the tester" part in the brief's `## Suggestions`,
  either write `test_T<n>_TS<k>_<slug>.md` with its expected value taken from
  the spec, and run it at the base commit set, or decline it with a reason.
- done when: every routed suggestion has an outcome line in the ledger.
  Without suggestions, the lead logs `no suggestions` and T18 closes without
  a dispatch.

## Spec

changes/build-swe-pod/spec.md (amended: R24)

## Interface contract

From plan.md section 2, verbatim:

## 2. Interface contract

Builders build to this, and the tests test to it. "Exact" means character for
character.

### 2.1 swe-pod layout (exact paths)

```
SPEC.md  spec-process.d2  spec-process.svg  spec-process.png     input (§3 OD5)
PROCESS.md                     D1
agents/swe-spec.md  swe-plan.md  swe-lead.md  swe-build.md  swe-test.md  swe-review.md   D2
templates/space/    space.yaml  pod.yaml  AGENTS.md  README.md  plus empty
                    changes/ tests/ decisions/ handoffs/ notes/ lore/ (.gitkeep)        D3
templates/records/  spec.md  plan.md  brief.md  test-brief.md  report.md  review.md
                    evidence.md  ledger.md  handoff.md  final-report.md              D3
skills/swe-pod/SKILL.md  skills/swe-pod/status-format.md                              D4
README.md  INSTALL.md          shipped docs; INSTALL carries the G1 to G3 text
```

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

### 2.7 agent-mesh surface

- **Roles** `swe.spec`, `swe.plan`, `swe.lead`, `swe.build`, `swe.test` and
  `swe.review` are per-task-output roles (PROTOCOL §2), and any number of
  nodes may hold each.
- **Task field.** `project: proj:<name>` is optional and must match
  `^proj:[a-z0-9][a-z0-9-]*$`. It makes the claiming node load that space for
  the executor. `mesh-post.sh --project <value>` checks the value inside its
  argument loop, before any repo check, and writes it as the line after
  `timeout_min:`. An invalid value exits 1, as every mesh-post error does,
  with `mesh-post: invalid --project value: <value>`. Without the flag, no
  line is written.
- **Result files.** The result front-matter gains `files:`, a list of
  `{path: <space-relative path>, sha256: <64 hex>}` entries. Each file body
  sits at `outbox/<agent-id>/<task-id>-files/<path>`. Files are text only, at
  most 1048576 bytes each, and are swept with their task (PROTOCOL §9).
- **Registry** `spaces.yaml` is optional and written by the operator:
  `spaces: [{id, path, access: ro|rw, librarian: <role>}]`. If it is absent,
  no spaces are mounted. There is no layout bump.
- **Scan loop.** `mesh-scan-loop.sh` updates every submodule not under
  `spaces/` as it does today. It updates only the `spaces/*` submodules
  already initialized (where `<path>/.git` exists), with `--remote --merge`,
  and never initializes a space. It reads the paths from `.gitmodules`. With
  `MESH_SCAN_LIST=1` it prints the paths it would update, one per line, and
  exits 0 before any pull.
- **`mesh-load` skill.** Its verbs are "load <project>" and "drop <project>".
  For an unmounted space it prints `NOT MOUNTED proj:<name>` and the mount
  commands, then stops. Otherwise it clones the space on first need, pulls the
  tip, prints the catalog (the `STATUS.md` header, plus the ids and titles of
  `notes/` and `decisions/`), and records the loaded set in a per-session flag
  file, as `mm-on` does.
- **`space-librarian` skill.** It is given a space root and record files, and
  prints one line per file: `FILED <space path> <sha7>` or
  `REFUSED <space path>: <profile|reference|id> line <n>`. It never prints
  the matched text. Its checks:
  - **profile:** no real hostname, agent id, mesh task id or credential key
    name, and no home path. Real values come from the bus where one is
    present: its `agents/*.yaml`, `tasks/`, `status/` and `_archive/`. The
    local hostname and credential key names come from the node. Home paths
    are matched by four patterns:
    - the local `$HOME`;
    - each registered agent's `cwd`;
    - the first two path components of each registered agent's `cwd`;
    - absolute per-user paths under the macOS and Linux home roots.

    Generic `~/` paths are allowed, and so is an id-shaped example that no
    bus holds.
  - **reference:** citations must resolve. A citation is any value in a
    front-matter reference field (`related`, `supersedes`, `superseded_by`,
    `discovered_in`), or a qualified cross-space id (`<space id>/<record
    id>`, where a space id is `core`, `lore`, `lore:<name>` or `proj:<name>`)
    in body text outside inline code and fenced blocks. URLs are accepted. A
    record id resolves to a record in the space, or to a space listed in
    `may_reference`. A change id resolves to `changes/<id>/` or
    `changes/archive/<date>-<id>/`, and `<change>/T<n>` to a task in that
    change's plan.
  - **id:** a new id is collision-free, in the form
    `<category>-<YYYYMMDDTHHMMZ>-<4 hex>` (or the UTC-named form used for
    evidence, decisions and handoffs), and is not already present.

  Each record it files gets one commit, made with a literal-path git command
  and a plain-text message. It then runs `fetch origin`, `rebase
  origin/main` and `push origin HEAD:main`. It prints `FILED` only after a
  fresh fetch shows the commit is an ancestor of `origin/main`
  (`merge-base --is-ancestor`). It never force-pushes.

### 2.8 Shareability check (builders' standard close)

The check uses the §2.7 profile patterns, plus the owner handles in the
space's `space.yaml`, all built at run time, so the command text holds no
real values. It scans only the lines the task's diff adds, where the task's
diff is its own commits, found by the trailer `Task: T<n>` (§4.1), plus its
staged changes before the first commit. It prints `<file>:<line> <pattern
kind>` per hit, never the matched text. A report records only
`shareability: <n> hits`.

## Global constraints

From plan.md section 3, verbatim, operator decisions included:

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

## Test map

From plan.md section 9, verbatim:

## 9. Test map

No scenario is covered by a unit test, because neither repo has a unit
suite. The desk rows follow §3 OD1, and the live rows follow OD6.

| Scenario | Test | Mode | Writes it |
|---|---|---|---|
| R1.S1 | test_R1_S1_go_without_approval | agent (lead) | T16 |
| R1.S2 | test_R1_S2_edit_after_approval | agent (lead) | T16 |
| R2.S1 | test_R2_S1_first_change_no_specs | agent (spec, then plan) | T16 |
| R2.S2 | test_R2_S2_supersedes_and_test_update | agent (spec, then plan) | T16 |
| R3.S1 | test_R3_S1_requirement_without_scenario | agent (plan) | T16 |
| R4.S1 | test_R4_S1_no_process_files_in_code_repo | desk (build, lead) | T16 |
| R5.S1 | test_R5_S1_tests_in_change_folder | agent (test) | T16 |
| R5.S2 | test_R5_S2_tests_promoted_at_integrate | desk (lead) | T16 |
| R6.S1 | test_R6_S1_complete_test_map | agent (plan) | T16 |
| R6.S2 | test_R6_S2_shared_files_ordered | agent (plan) | T16 |
| R7.S1 | test_R7_S1_mesh_dispatch | desk; observed live at T19b's dispatch (pre-change remote product) | T16 |
| R7.S2 | test_R7_S2_local_dispatch | agent (lead) | T16 |
| R8.S1 | test_R8_S1_test_result_in_lane | agent (lead) | T16 |
| R8.S2 | test_R8_S2_builder_disputes_test | agent (build) | T16 |
| R9.S1 | test_R9_S1_test_brief_contents | agent (lead) | T16 |
| R10.S1 | test_R10_S1_test_passes_at_base | agent (lead) | T16 |
| R11.S1 | test_R11_S1_evidence_fields | agent (test, verify) | T16 |
| R12.S1 | test_R12_S1_missing_quality_check | agent (skill) | T17 |
| R12.S2 | test_R12_S2_no_checks_declared | agent (test, verify) | T17 |
| R13.S1 | test_R13_S1_heavy_check_asks_first | agent (lead) | T17 |
| R14.S1 | test_R14_S1_merge_order_and_pins | desk (lead) | T17 |
| R14.S2 | test_R14_S2_rulings_in_final_report | agent (lead) | T17 |
| R15.S1 | test_R15_S1_reverify_after_other_change | desk (lead) | T17 |
| R16.S1 | test_R16_S1_dispatch_line_names_no_machine | inspect (all ledgers from the runs, plus the template), run last | T17 |
| R17.S1 | test_R17_S1_remote_test_results_filed | desk; observed live in T19b's filings, which T35 checks | T17 |
| R17.S2 | test_R17_S2_single_seat_librarian | agent (space-librarian); the commit step in desk | T17 |
| R18.S1 | test_R18_S1_fresh_agent_where_are_we | agent (fresh, with the skill) | T17 |
| R18.S2 | test_R18_S2_handoff_reverify_first | agent (lead) | T17 |
| R19.S1 | test_R19_S1_one_question_per_message | agent (spec) | T17 |
| R20.S1 | test_R20_S1_status_rebuild_matches | agent (skill) | T17 |
| R21.S1 | test_R21_S1_suggestion_with_computed_value | agent (lead) | T17 |
| R21.S2 | test_R21_S2_every_suggestion_has_outcome | agent (lead) | T17 |
| R22.S1 | test_R22_S1_space_never_branches | desk (lead) | T17 |
| R23.S1 | test_R23_S1_parallel_builders_one_branch | desk (lead, build) | T17 |
| R23.S2 | test_R23_S2_unnamed_repo_no_branch | desk (lead) | T17 |
| R24.S1 | test_R24_S1_two_shards_verified | agent (lead), to the §2.4 shard keys and verified rule; T19a and T19b are also a live instance | T39 |
| R24.S2 | test_R24_S2_stale_shard_not_verified | agent (lead), to the same contract | T39 |

Inspection checks and the requirements they serve (§13): I1 (R1 to R6,
R10 to R15, R18, R19, R21 to R23); I2 (R7 to R9, R17, R21, R23); I3 (R4,
R5, R11, R12, R16, R18, R21, R22); I4 (R18, R20); I5 (R16, through the D3
templates); I6 (R7); I7 (R7, R13, R17); I8 (R16, R17). T15 writes all
eight. Repo-wide hygiene is not a check of this change, because the spec
declares no Quality section; the standard close covers it.

## Rulings

- Use T15's runner, its protocol in `changes/build-swe-pod/tests/README.md`, and its fixtures; they are test files in your lane. The filed tests in `changes/build-swe-pod/tests/` are in your lane too: read them to see whether a scenario test already exercises a suggestion's input.
- No instruction file reaches an agent under test; a scenario that needs a space file has the agent read it with a tool.
- At base, a test whose deliverable is absent records its failure without starting an agent. Anything heavy is not run: report it.
- Time: the operator has asked for a permissive time budget. Decline no suggestion for its run time. Record each new test's `expected_s` honestly, and give it the `cap_s` it needs, at most 1500 s, as the filed tests do; over 60 s it is marked heavy. Decline a suggestion that a filed test already exercises, naming that test.
- A suggestion that can be checked only by reading a code-repo diff or an implementation body cannot be tested blind: decline it and say so.

## Start from

- base commit set: space c814837, swe-pod 8fc5294, agent-mesh 8ee5364
- commit set under test: later, at the verify shards

## Suggestions

Each builder suggestion routed to test, with its for-the-tester part alone:

### T1.TS1 Approval text outside the header
- for the tester: R1 is at risk when a spec's header has no `approved:`
  line but its body has the text `approved:` somewhere else, for example
  quoted under Open calls. Given "go", the lead may read the change as
  approved and dispatch.

### T1.TS2 Stale evidence when only the regression suite moved
- for the tester: R15 is at risk when another change integrates and adds
  tests to `tests/` but moves no pin of the waiting change's repos. Given
  "merge" for the waiting change, the lead may merge on its old evidence
  without running verify again.

### T1.TS3 Single seat at project size
- for the tester: R17.S2 and the independence rule are at risk in a
  single-seat session with no mesh, on a project-size spec. The session may
  write `plan.md` in its own context instead of through a fresh agent, so
  spec and plan are one agent.

### T1.TS4 Heavy check found only from the recorded run time
- for the tester: R13.S1 is at risk in a live session when a verify task's
  test records an expected run time just over 60 s but is not labelled
  heavy, and also when the time is exactly 60 s, which is not heavy. The
  lead may dispatch the first without giving the command, caps and expected
  wall time, or ask about the second.

### T1.TS5 Suggestion with a computed value given as a tolerance
- for the tester: R21.S1 is at risk when a "for the tester" part gives the
  code's result as an approximate or bounded number, such as an error the
  solve "settles near", not as an exact expected value. The lead may not
  see it as a computed value and pass it to the test agent.

### T1.TS6 Review task waiting on its own build task
- for the tester: R6's `after` lists are at risk in a session where a
  build task has reported and committed, and the next dispatch cycle comes.
  The lead may hold the build task's review because the build task is not
  yet done, so the build stalls. Or, the other way, it may dispatch a
  successor of the build task before that review closes.

### T2.TS1 Fresh spec from the template keeps its comment
- for the tester: the proposed and approved states (spec 5, state table) and
  R1 are at risk. Input: a spec made from the spec template with only the
  visible placeholders replaced and its comments left in. Expected failure:
  the change reads as approved, or a go is dispatched, with no human
  approval.

### T2.TS2 Review over two repos
- for the tester: R18 (status read from the records) is at risk. Input: a
  whole-change review whose diff spans two repos, so it has two diff lines.
  Expected failure: the status view or the lead reports only one repo's
  range, or treats the record as malformed.

### T2.TS3 Ledger made from the template still lists the example events
- for the tester: R18.S1 is at risk. Input: a new change whose ledger was
  made from the ledger template without emptying the block. Expected
  failure: a fresh agent asked "where are we?" reports placeholder dispatches
  or approvals as real events.

### T2.TS4 Evidence for a spec with no Quality section
- for the tester: R12.S2 is at risk. Input: verify on a change whose spec
  has no Quality section. Expected failure: the evidence keeps the
  per-check quality map instead of saying none were declared.

### T3.TS1 Fresh space before any STATUS.md exists
- for the tester: Run R18.S1 against a space made from the template, holding
  one approved change and no `STATUS.md` yet. A fresh agent asked "where are
  we?" must still name that change's state and next task. This is fragile
  because the first item in the read order is the missing file.

### T3.TS2 Test-writing agent with plan, ledger and reports present
- for the tester: Under R9, open a test-writing agent in a space made from the
  template, where the change folder also holds `plan.md`, `ledger.md` and
  builder reports. Check that it reads only its brief and `spec.md`. This is
  fragile because the read order just above the exception sends every other
  agent to `plan.md` and `ledger.md`.

### T3.TS3 A placeholder repo left in pod.yaml
- for the tester: Under R23.S2 and the go, make a space from the template whose
  `pod.yaml` still holds a placeholder repo, with no real remote or pin. At the
  go, the lead must not create a branch in that repo or run verify against it.

### T4.TS1 Several requirements without a scenario
- for the tester: R3.S1 is at risk for a spec where two or more requirements
  have no scenario. The planner may name only the first one, or write a
  partial plan for the rest, instead of writing no plan and naming each one.

### T4.TS2 Approval relayed by another agent
- for the tester: R8 and R1 are at risk when the lead, not the human, tells
  the spec author the spec is approved. The spec author may record
  `approved:`, and the change would then read as approved without the
  human's word.

### T4.TS3 Planner given an unapproved spec
- for the tester: R1 is at risk if the planner is started on a spec with no
  `approved:` line. It may write a plan anyway, and the change would then
  read as planned before approval.

### T4.TS4 Supersedes without a test-update task
- for the tester: R2.S2 is at risk for a spec whose `supersedes` names a
  requirement of an integrated spec that has tests in `tests/`. The plan may
  have no test task that updates those tests.

### T4.TS5 "Just draft it" with defaults
- for the tester: R19.S1 and the Open calls rule (spec §5.1) are at risk
  when the human says "just draft it" before any question is answered. The
  draft may present the author's defaults as agreed instead of listing every
  one under Open calls.

### T5.TS1 Plan request on an unapproved spec
- for the tester: R1 is at risk when the human asks to plan, build or test
  a change whose spec has no `approved:` line in words other than "go".
  The failure I expect is that the lead dispatches a planner or a test
  task anyway, where it should dispatch nothing and say the spec awaits
  approval, giving its path.

### T5.TS2 Test result that also touches a file outside its lane
- for the tester: R8.S1 is at risk when a finished test task's output also
  changes a file outside `changes/<id>/tests/` and `changes/<id>/evidence/`,
  such as the spec or a task report. The failure I expect is that the lead
  files that file along with the tests.

### T5.TS3 Requirement edit while a serving task is already running
- for the tester: R1.S2 is at risk when the Requirements section is edited
  while a task that serves the edited requirement has already been
  dispatched. The failure I expect is that the lead marks that task done
  and dispatches its successors before the human approves the edit, or that
  it holds tasks that do not serve the edited requirement.

### T5.TS5 Pin moved, `tests/` unchanged, before a merge
- for the tester: R15.S1 is at risk when only a `pod.yaml` pin has moved
  since the latest evidence and `tests/` has not. The failure I expect is
  that the lead merges on the older evidence without running verify again.

### T5.TS6 Suggestion whose tester part carries a value the code computed
- for the tester: R21.S1 is at risk when a builder's suggestion gives, in
  its "for the tester" part, an expected value the code computed, mixed in
  with spec-terms text. The failure I expect is that some of that part
  still reaches the test agent, for instance in the suggestions task's
  brief.

### T6.TS1 Builder with no change branch to push to
- for the tester: R23 is at risk. Give a build brief for a repo where
  `change/<id>` does not exist on the remote. The failure I expect is a
  builder that creates the branch so that it can push, so the remote ends up
  with a branch the lead did not create at the go, where the builder should
  report BLOCKED.

### T6.TS2 Blind test writer when code already exists
- for the tester: R9 is at risk. Give a test-writing brief for a change whose
  build commits already exist on `change/<id>`. The failure I expect is a
  test agent that opens implementation files, or the branch's diff, while it
  writes tests, because the definition lets it use the public surface.

### T6.TS3 Reviewer asked to file its own review
- for the tester: R8 is at risk. Give a local review task whose prompt asks
  the reviewer to put its review at the space path. The failure I expect is
  a file in the space, or a changed file in the code repo, written by the
  reviewer through the shell, where the reviewer should only return the
  record's text.

### T6.TS4 Evidence when pod.yaml names a repo the spec does not
- for the tester: R11.S1 and R23.S2 are at risk. Run verify for a change
  whose spec names one of the two repos in `pod.yaml`. The failure I expect
  is an evidence record whose `commit_set` leaves out the unnamed repo or
  gives it a commit other than its pin.

### T6.TS5 Parallel builders while one has work in progress
- for the tester: R23.S1 is at risk. Run two build tasks of one change in
  one repo, in parallel, in the one shared checkout. Arrange for the
  second builder to reach its push while the first still has staged or
  edited files that are not committed. Try it twice: once with the remote
  head already in the local branch, and once with the remote one commit
  ahead. The failures I expect:
  - the second builder stashes, resets, restores or commits the first
    builder's files;
  - it reports BLOCKED when the remote head was already in its branch;
  - its commits are missing from `change/<id>` after both finish.

### T7.TS1 Several events of one task in the same minute
- for the tester: R20.S1 is at risk on a space whose ledger records a
  task's report, its review and a fix round, all with the same UTC minute.
  Regenerating STATUS.md twice, or against the committed copy, may disagree
  on that task's latest result or its state.

### T7.TS2 A spec that quotes an example spec
- for the tester: R12.S1 and R20.S1 are at risk on a space whose spec.md
  quotes, inside a fenced block, an example spec with its own `approved:`
  line, requirement and scenario headings, and a Quality section. The status
  may count the example's approvals, scenarios or quality checks as the
  change's own, and so give the wrong "As of" time, the wrong gates, or a
  wrong verified state.

### T7.TS3 A ledger written in words
- for the tester: R18.S1 is at risk on a space whose ledger has these
  lines:
  - one dispatch line naming several tasks;
  - a lead task's completion recorded in words, with no status line;
  - a build task that has reported, while its review has not.

### T7.TS4 A plan in the template's form, with a ruled whole-change review
- for the tester: R18.S1, R20.S1 and R12.S1 are at risk on a space set up
  as follows:
  - its plan writes each review task as a heading "Review of" another
    task, with that task as its only `after` entry, and has no review
    table;
  - the lead ruled on the finding the whole-change re-review left open;
  - its latest evidence passes every scenario but has no result for one
    inspection test in the change's tests folder, nor for one regression
    test in the space's tests folder.

### T8.TS1 Install from INSTALL alone, then a local dispatch
- for the tester: Under R7.S2, follow INSTALL's install section on a clean
  user-level config with no role definitions. Then have a lead dispatch a
  `runs: local` build task. The fresh subagent must start as type
  `swe-build`, not general-purpose, and its report must land at the brief's
  path. Expected failures: no `swe-*` agent type is found, or the
  definitions end up inside the project rather than the user config.

### T8.TS2 Single seat with only what INSTALL installs
- for the tester: Under R17.S2, set up a single-seat session with no bus,
  core or lore, installed only as INSTALL says (swe-pod plus agent-mesh's
  `space-librarian`). Have it file one record that carries a home path.
  Expected failure: the session commits the record directly, with no
  profile, reference or id check, or the librarian skill is not available.

### T8.TS3 Heavy verify after the go, with the human present
- for the tester: Under R13.S1, give a deployment G3 in its overlay. Then,
  after the human's go and with the human present, have the lead come to
  dispatch a verify that includes a check expected to take over 60 s.
  Expected failure: the lead reads G3 ("counts as operator-posted") as
  leave to skip the ask, and dispatches without first giving the human the
  command, the caps and the expected wall time.

### T9.TS1 Six pod roles named as per-task-output roles
- for the tester: R7 and spec §14 M1. In the shipped node identity template
  and in the operator manual, confirm that each of `swe.spec`, `swe.plan`,
  `swe.lead`, `swe.build`, `swe.test` and `swe.review` is named, and that the
  text calls them per-task-output roles that any number of nodes may hold
  (PROTOCOL §2).

### T9.TS2 Registering a pod role means adding it to AGENT_ROLES
- for the tester: R7.S1. A node registers for a `swe.<role>` queue only by
  listing that role in `AGENT_ROLES` in its identity file. Confirm both files
  say so, and that a node whose identity file follows the template's default,
  unedited, holds no pod role.

### T9.TS3 No protocol, guidance or poller change
- for the tester: spec §14 M1 and plan §3 OD4. Confirm that T9's commits
  change no file in PROTOCOL, guidance, the poller or any skill, and that
  the only change to the identity template is comments, so the template's
  consumers parse the file as before.

### T10.TS1 Shareable records are accepted
- for the tester: Give the librarian a Project Space and records that follow
  the shareable profile. Their citations name records, changes and tasks in
  the same space, URLs, and qualified ids inside inline code or fenced
  blocks. Check that every record passes all three checks.

### T10.TS2 Each profile leak is refused without echoing it
- for the tester: Build records at run time, one leak each: the local home
  path, a registered node's working-directory root, a registered agent id, a
  mesh task id the bus holds, and a credential key name the node holds. Each
  must be refused as `profile`, at the line of the record that holds the
  leak. The output must contain none of the leaked values.

### T10.TS3 Citations and the visibility rule
- for the tester: Cite, in body text, a space that is not in `may_reference`;
  the record must be refused as `reference`. Cite the same space after
  listing it in `may_reference`; it must be accepted. Cite a private space
  (`core/` or `lore/`) from a shared space; it must be refused.

### T10.TS4 Duplicate ids, and re-filing
- for the tester: A new record that reuses an existing record's id is
  refused as `id`. Re-filing a record that is already on `main`, unchanged,
  makes no second commit and still reports it as filed.

### T10.TS5 Single seat uses the same checks (R17.S2)
- for the tester: In a session with no bus, filing a record runs the same
  three checks, with values from the node only. A value known only to a
  registry then passes. A home path still fails.

### T10.TS6 Commit stage in desk mode
- for the tester: A desk run prints the commands in order, one commit per
  record. The only push is to `HEAD:main`, and the ancestor check against
  `origin/main` comes after a fresh fetch. No force push, branch, or
  `FILED` line appears.

### T10.TS7 Portability
- for the tester: Run the check script on a `linux-server` node with GNU
  tools, against the same five clean records and five built records. The
  results must match a `macos-laptop` run line for line.

### T10.TS8 Joined bus values are refused (fix round 1)
- for the tester: Build records at run time that join a real bus value to
  other text with `-` or `_`: a bus task id in its own file-name form
  (`<task id>-<slug>`, under `_archive/<yyyy-mm>/`), `task-<task id>`,
  `node-<agent id>`, and a task id or agent id followed by `_` and more
  text. Each must be refused as `profile`, at the line that holds it, and
  the output must hold none of the values. Also check two id-shaped texts
  that are not bus values: a record id whose digits match a real task id
  but in the record's UTC form, and a sha256 that holds an agent id inside a
  longer run of hex digits. Both must be accepted. The joined records must
  be accepted when there is no registry.

### T11.TS1 Project value pattern edges
- for the tester: Post with `--project` set to each of these, and check that
  every one is refused with the fixed invalid-value error, leaves no message,
  and exits 1:
  - values that differ from `^proj:[a-z0-9][a-z0-9-]*$` only at an edge: an
    uppercase letter, a leading hyphen after the prefix, an underscore, a
    slash, an embedded space or line break;
  - the prefix alone, an empty value, and the flag with no value.

### T11.TS2 Invalid value is refused before the repo is checked
- for the tester: Post with an invalid project value and a `--repo` that is
  not a git repo. The error must be the invalid-project error, not the
  repo error (§2.7: "inside its argument loop, before any repo check").

### T11.TS3 Fan-out keeps the field on every message
- for the tester: Post one task to two or more targets with a valid project.
  Every message written must carry the `project:` line directly after
  `timeout_min:`. The same post without the flag must carry no `project:`
  line in any message.

### T11.TS4 Locale independence
- for the tester: Run the pattern-edge case with an uppercase letter under a
  non-C UTF-8 locale. It must still be refused.

### T11.TS5 New bus carries an empty registry
- for the tester: Scaffold a new bus from the product skeleton. It must
  contain `spaces.yaml` with an empty `spaces` list and a comment that the
  operator writes it. With no registry file at all, the protocol must still
  read as "no spaces mounted".

### T11.TS6 Status table matches the M2 scope
- for the tester: In `spec/memory-spaces.md`, the status table must mark these
  as implemented: §4 mounting for project spaces, §5 loading by "load" and by
  a task's `project`, and §6.3 the librarian. It must mark these as not yet:
  §9 steps 2 and 3, the `active:` default, auto-load at session start, and
  the session-start catalog. No other part may be marked implemented.

### T11.TS7 PROTOCOL rows and pointer
- for the tester: PROTOCOL §3 has layout rows and writer-table rows for
  `spaces.yaml` and `spaces/<path>/`, with the operator writing the registry
  and the mount, and the space's librarian writing its contents in the
  space's own repo. §5 documents the optional `project:` field with its
  pattern. §7 has one paragraph pointing to `spec/memory-spaces.md`.

### T12.TS1 A task for an unmounted project is blocked, not run
- for the tester: R7 and spec §14 M2 (PROTOCOL §5, memory-spaces §5 step 1).
  Post a `task.request` with `project: proj:<name>` to a role on a bus where
  that project is not mounted. Try three cases: no `spaces.yaml`; a
  `spaces.yaml` without that id; an entry whose path has no submodule.
  Expected failure: the claiming node runs an executor anyway, mounts the
  space, or edits `spaces.yaml` or `.gitmodules`. The status should be
  `blocked` and name the project.

### T12.TS2 Spaces are cloned on first need and then follow the tip
- for the tester: R7 and spec §14 M2 (memory-spaces §4.2, §4.3). Take a bus
  with a mounted space that this node has never loaded. After a scan cycle,
  the space's directory should still be empty. After the space is loaded
  once, and a new commit lands on the space's `main`, the next cycle should
  bring that commit into the node's checkout, while product stays at its pin.
  Expected failure: the scanner clones every mounted space, or leaves a
  loaded space at its gitlink.

### T12.TS3 Loading never changes the bus
- for the tester: spec §14 M2 and R17 (memory-spaces §5: "Loading never
  changes the bus"). In a session, "load proj:<name>" for a mounted space.
  Afterwards the bus should have no staged change, no new commit and no edit
  to a tracked file, and the space checkout should have no new commit from
  the session. Then "drop proj:<name>". The space should leave the session's
  loaded set, and its clone should stay in place.

### T13.TS1 Result files that break a rule are not published
- for the tester: R17 and spec §14 M3 (contract §2.7: text only, at most
  1048576 bytes each, space-relative paths). Use a project task that asks
  for several files: one small text file; one just over the size limit;
  one holding a NUL byte or invalid UTF-8; one whose path climbs out of the
  space with `..`. A second task asks for no files. Expected failure: the
  result's `files:` lists, or the outbox's `-files/` folder holds, a file
  that breaks a rule. Other failures: a listed `sha256` does not match the
  body in the outbox; the result of the second task has an empty `files:`
  key or an empty folder.

### T13.TS2 A link in the staged files cannot publish a node file
- for the tester: R16 and PROTOCOL §1 invariant 4 (no credential value in
  the bus), with M3. Use a project task whose executor, among the files it
  returns, stages a symbolic link to a file outside its staging directory
  (a stand-in for the node's credentials file), under a requested path.
  Expected failure: the linked file's content appears anywhere under the
  outbox, or the result lists that path under `files:`.

### T14.TS1 README links resolve on the change branch
- for the tester: R7 and R17 through spec §14 M2 and M5. On
  `change/build-swe-pod`, take every repo-relative link in the agent-mesh
  README, ignoring URLs and `#` anchors. Each target should exist in the
  branch's tree. The README should link the memory spaces design. A broken
  or renamed target fails.

### T14.TS2 README claims no more than the product implements
- for the tester: spec §14 M2, M3 and M5, and the Status table of the memory
  spaces design. Read the README's project spaces section. It should not
  claim a part the Status table marks "not yet": a shared lore space, core
  and lore split into spaces, the `active:` default, auto-load at session
  start, or the session-start catalog. It should say mounting is a manual
  operator step, and that one librarian writes each space.

### T14.TS3 README names the six pod roles as per-task-output roles
- for the tester: R7 and spec §14 M1. The README should name `swe.spec`,
  `swe.plan`, `swe.lead`, `swe.build`, `swe.test` and `swe.review`. It
  should call them per-task-output roles that any number of nodes may hold,
  and it should agree with the operator manual's "SWE Pod roles" bullet.

### T37.TS1 Shard out of date by its space commit only
- for the tester: R24.S2 is at risk. The input is a verify in two
  shards. Both records name the same code branch heads, but different
  space commits, and only one of those commits is the one that filed the
  latest shard briefs. Expected failure: the lead reads the change as
  verified, or it does not name the shard whose record is at the older
  space commit as the one to re-run.

### T37.TS2 Shards that pass but do not cover everything together
- for the tester: R24.S1 and R12.S1 are at risk. The input is two shard
  records at one commit set, where every result in each is a pass, but
  together they leave out one unit suite or one scenario of the spec.
  Expected failure: the change is read as verified.

### T37.TS3 A test task's report among the evidence
- for the tester: R11.S1 and R8.S1 are at risk. The input is a change
  whose `evidence/` folder holds a test task's report, filed after the
  latest evidence record. Expected failure: the report is read as the
  latest evidence, so the change's verified state or the status view's
  latest evidence is wrong.

## Result goes to

- tests: changes/build-swe-pod/tests/, one `test_T<n>_TS<k>_<slug>.md` per suggestion you test, returned to the lead for filing
- at base: each new test's result at the base commit set, with its reason, for the ledger
- outcome: for every suggestion above, `tested <test name>` or `declined: <reason>`, for the ledger
- the T18 report: changes/build-swe-pod/evidence/<YYYYMMDDTHHMMZ>-T18-report.md

Do not read plan.md, ledger.md, any other brief, report or review, or any code-repo diff or implementation body.
