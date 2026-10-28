# T19a brief

- change: build-swe-pod
- task: T19a
- role: test
- repo: space, swe-pod, agent-mesh

## Task

From plan.md, verbatim:

### T19a and T19b Verify, sharded (§3 OD6, OD7)

Both shards share these fields:
- role: test
- repo: space, swe-pod, agent-mesh
- after: [T0 to T18, T37, T39, T41, T42]
- serves: [R1 to R24]
- prerequisite: the operator has signed in the isolated runner config on
  the node (T15 Config); if it fails, the shard reports BLOCKED, for the
  operator.

- **Commit set.** The shards' space commit is the space commit that files
  the last of the shard briefs and dispatch lines, and the lead gives that
  commit to every shard at dispatch. Both shards run at that space commit
  and at the same branch heads, by sha.
- **Split** (the lead, at dispatch). Each test goes to one shard by its
  `expected_s`, so that both shards finish at about the same time. Both are
  serial (PC1), so the split is about half and half.
  - A test whose `env` names a class goes to the shard of that class.
  - `test_R16_S1` runs last in both shards, over that shard's ledgers.
  - Each brief's `## Task` lists its shard's tests.
- **First step: `runner.sh smoke`** on the shard's own node, with T41's
  three cases. The brief lists the managed-policy kinds already ruled on.
  Only a smoke failure, or a managed policy that is new or changed since
  then, stops the shard as BLOCKED for a lead ruling before any test runs.
  The evidence body records the smoke result. For T19b, this replaces the
  mitigation named in the 00:05Z ruling, which the lead re-records.
- **Caps.** Each run is capped at its `cap_s`, at most 600 s, and each shard
  at 150 min in total.
- **Heavy.** Before dispatch, the lead gives the operator one heavy ask
  (R13.S1). It names the runner commands and the caps, and each shard's
  expected time, computed at dispatch from the filed `expected_s` and the
  actual split. A shard expected to exceed its cap is re-split before the
  ask. The approval is used as PC2 says, and the quoted figure is that
  computed time.
- **Suites.** Neither repo has a unit suite, and the spec has no Quality
  section.
- **Evidence.** Each shard files one record named for its shard, with every
  §2.4 key including `shard:` and `tests:`. It also carries
  `unit: {swe-pod: none-present, agent-mesh: none-present}`,
  `quality: none-declared` and `wall_time_s`, and its log pointers go only to
  its `-runs/` files. Its report goes under `evidence/` (§2.4).
- **Verified.** By the §2.4 rule, over all 37 scenarios, I1 to I8 and every
  suggestion test.
- **Re-runs.** A re-run at a new commit set re-runs both shards.

### T19a and T19b Verify, sharded (§3 OD6, OD7)

Both shards share these fields:
- role: test
- repo: space, swe-pod, agent-mesh
- after: [T0 to T18, T37, T39, T41, T42]
- serves: [R1 to R24]
- prerequisite: the operator has signed in the isolated runner config on
  the node (T15 Config); if it fails, the shard reports BLOCKED, for the
  operator.

- **Commit set.** The shards' space commit is the space commit that files
  the last of the shard briefs and dispatch lines, and the lead gives that
  commit to every shard at dispatch. Both shards run at that space commit
  and at the same branch heads, by sha.
- **Split** (the lead, at dispatch). Each test goes to one shard by its
  `expected_s`, so that both shards finish at about the same time. Both are
  serial (PC1), so the split is about half and half.
  - A test whose `env` names a class goes to the shard of that class.
  - `test_R16_S1` runs last in both shards, over that shard's ledgers.
  - Each brief's `## Task` lists its shard's tests.
- **First step: `runner.sh smoke`** on the shard's own node, with T41's
  three cases. The brief lists the managed-policy kinds already ruled on.
  Only a smoke failure, or a managed policy that is new or changed since
  then, stops the shard as BLOCKED for a lead ruling before any test runs.
  The evidence body records the smoke result. For T19b, this replaces the
  mitigation named in the 00:05Z ruling, which the lead re-records.
- **Caps.** Each run is capped at its `cap_s`, at most 600 s, and each shard
  at 150 min in total.
- **Heavy.** Before dispatch, the lead gives the operator one heavy ask
  (R13.S1). It names the runner commands and the caps, and each shard's
  expected time, computed at dispatch from the filed `expected_s` and the
  actual split. A shard expected to exceed its cap is re-split before the
  ask. The approval is used as PC2 says, and the quoted figure is that
  computed time.
- **Suites.** Neither repo has a unit suite, and the spec has no Quality
  section.
- **Evidence.** Each shard files one record named for its shard, with every
  §2.4 key including `shard:` and `tests:`. It also carries
  `unit: {swe-pod: none-present, agent-mesh: none-present}`,
  `quality: none-declared` and `wall_time_s`, and its log pointers go only to
  its `-runs/` files. Its report goes under `evidence/` (§2.4).
- **Verified.** By the §2.4 rule, over all 37 scenarios, I1 to I8 and every
  suggestion test.
- **Re-runs.** A re-run at a new commit set re-runs both shards.

This shard runs these 44 tests, serially, in this order (expected 11473 s in all):

- test_I2_role_definitions
- test_I4_swe_pod_skill
- test_I6_mesh_post_project_flag
- test_I8_space_librarian_checks
- test_R11_S1_evidence_fields
- test_R14_S1_merge_order_and_pins
- test_R15_S1_reverify_after_other_change
- test_R17_S1_remote_test_results_filed
- test_R18_S1_fresh_agent_where_are_we
- test_R19_S1_one_question_per_message
- test_R20_S1_status_rebuild_matches
- test_R22_S1_space_never_branches
- test_R23_S2_unnamed_repo_no_branch
- test_R24_S2_stale_shard_not_verified
- test_R2_S2_supersedes_and_test_update
- test_R3_S1_requirement_without_scenario
- test_R5_S1_tests_in_change_folder
- test_R6_S1_complete_test_map
- test_R7_S1_mesh_dispatch
- test_R7_S2_local_dispatch
- test_R9_S1_test_brief_contents
- test_T10_TS8_joined_and_registry_values
- test_T11_TS5_new_bus_mounts_no_space
- test_T11_TS7_protocol_spaces_writers
- test_T12_TS3_load_never_changes_bus
- test_T13_TS1_result_files_by_rule
- test_T1_TS1_approval_text_outside_header
- test_T1_TS3_single_seat_fresh_planner
- test_T1_TS6_review_dispatched_before_successor
- test_T2_TS2_review_over_two_repos
- test_T2_TS3_ledger_from_template_not_emptied
- test_T37_TS1_shard_stale_by_space_commit
- test_T3_TS1_fresh_space_without_status
- test_T3_TS3_placeholder_repo_in_pod_yaml
- test_T4_TS1_several_requirements_without_scenario
- test_T5_TS1_plan_request_on_unapproved_spec
- test_T6_TS1_no_change_branch_on_remote
- test_T6_TS3_reviewer_returns_text_only
- test_T7_TS2_spec_quoting_example_spec
- test_T7_TS4_template_plan_ruled_review_missing_results
- test_T8_TS1_install_user_level_then_local_dispatch
- test_T8_TS3_heavy_verify_with_g3_overlay
- test_T9_TS2_agent_roles_registration
- test_R16_S1_dispatch_line_names_no_machine

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

- Use the runner and its protocol in `changes/build-swe-pod/tests/README.md`. First `runner.sh reset`, then `runner.sh smoke`. A smoke failure, or a managed policy of a kind not ruled on, stops the shard as BLOCKED before any test runs. Kinds ruled on: the node's gateway login and provider environment (00:05Z); a gateway settings drop-in, and the gateway's remote managed settings (02:59Z). The evidence body records the smoke result.
- Time (02:49Z, and the shard cap ruling at dispatch): each run is capped at its own `cap_s`, and the shard at 240 min in all. A run that reaches its cap is `not-run`, with the cap. If the shard reaches 240 min, stop, record every test not yet run as `not-run (shard cap)`, and file what you have.
- heavy: approved by agallojr ("yes to heavy", 2026-10-28T03:10Z; "be permissive on time", 02:49Z) for runner.sh run over this shard's tests, round 5 after the verify fixes; caps: each run its own cap_s, at most 1800 s, and the shard 240 min; expected: T19a 11473 s, T19b 11472 s. Pass `--allow-heavy`.
- Run only this shard's tests, serially, in the order listed, each once. Write the shard record with every key of plan section 2.4, `shard:` and `tests:` included, `unit: {swe-pod: none-present, agent-mesh: none-present}`, `quality: none-declared` and `wall_time_s`, and results only for the tests this shard ran. Log pointers go only into its `-runs/` folder.

## Start from

- base commit set: space c814837, swe-pod 8fc5294, agent-mesh 8ee5364
- commit set under test: swe-pod 83eaef9, agent-mesh bbd19a2
- tests changed at: 73c7543
- shards' space commit: given at dispatch, on its own line

## Result goes to

- evidence: changes/build-swe-pod/evidence/<YYYYMMDDTHHMMZ>-T19a.md, id `ev-<YYYYMMDDTHHMMZ>-T19a`, `env: macos-laptop`
- runs: changes/build-swe-pod/evidence/<YYYYMMDDTHHMMZ>-T19a-runs/
- report: changes/build-swe-pod/evidence/<YYYYMMDDTHHMMZ>-T19a-report.md

Do not read plan.md, ledger.md, any other brief, report or review, or any code-repo diff or implementation body.
