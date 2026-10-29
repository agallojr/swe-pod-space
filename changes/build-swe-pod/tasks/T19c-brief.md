# T19c brief

- change: build-swe-pod
- task: T19c
- role: test
- repo: space, swe-pod, agent-mesh

## Task

From plan.md, verbatim:

### T19c Verify, targeted (linux-server, mesh)
- role: test
- repo: space, swe-pod, agent-mesh
- after: [T0 to T18, T37, T39, T41, T42]
- runs: mesh
- needs: linux-server
- serves: [R1 to R24], through its 9 tests and the records it carries
  (§3 OD8)
- prerequisite: the operator has signed in the isolated runner config on
  the node (T15 Config); if it fails, T19c reports BLOCKED, for the
  operator.
- touches: changes/build-swe-pod/evidence/<YYYYMMDDTHHMMZ>-T19c.md, its
  `-runs/` folder and its `-report.md`
- steps:
  - **Commit set.** T19c's space commit is the one that files its brief and
    its dispatch line, and the lead gives it at dispatch with the branch
    heads, by sha. At this revision those are swe-pod `83eaef9` and
    agent-mesh `bbd19a2`, with the tests as changed at space `31e5e2d`.
  - **Tests.** Exactly these 9, serially, in this order, which the brief's
    `## Task` lists; expected 2193 s in all, from the filed `expected_s`:
    1. test_I1_process_md
    2. test_R13_S1_heavy_check_asks_first
    3. test_T1_TS4_heavy_from_recorded_run_time
    4. test_T8_TS3_heavy_verify_with_g3_overlay
    5. test_R23_S2_unnamed_repo_no_branch
    6. test_T10_TS6_commit_stage_order
    7. test_T13_TS1_result_files_by_rule
    8. test_T7_TS3_ledger_written_in_words
    9. test_R16_S1_dispatch_line_names_no_machine, last, over T19c's own
       ledgers

    They are the five that did not pass in round 4 and have not passed
    consistently since (R23.S2, T1.TS4, T10.TS6, T13.TS1 with T13.TS2, and
    T7.TS3); the three whose deliverable text changed after round 4, in
    the heavy-rule fix (I1, R13.S1 and T8.TS3); and test_R16_S1. The other
    81 tests are carried (§3 OD8).
  - **First step: `runner.sh smoke`** on the linux-server node, as for the
    shards: only a smoke failure, or a managed policy that is new or
    changed since the kinds the brief lists as ruled on, stops T19c as
    BLOCKED for a lead ruling before any test runs. The evidence body
    records the smoke result.
  - **Caps.** Each run is capped at its `cap_s`, at most 1800 s, and T19c
    at 120 min in all. The 9 caps sum to 6690 s.
  - **Heavy.** Before dispatch, the lead gives the operator one heavy ask
    (R13.S1), naming the runner commands, the caps above and the expected
    2193 s. The lead records it as a `heavy:` line, and the Context quotes
    it under PC2 (i).
  - **API errors and the spend limit** (the third 01:55Z ruling). A run
    stopped by an API error, such as the provider's safeguard or a gateway
    outage, and not by an agent's answer, is run again after the main pass,
    at most twice more, inside T19c's cap. test_R16_S1 then runs again,
    last. As in the 2026-10-28T12:04Z ruling, each test's result is its
    last run's, and one still stopped is `not-run (environment)`. A stop on
    the account's spend limit ends T19c at once as BLOCKED, with the
    results so far, and no run from that stop on is scored.
  - **Dispatch**, as T19b's. The brief and the dispatch line
    `dispatch T19c -> test (mesh, linux-server)` are in T19c's space
    commit. The lead posts a `task.request` to `role:swe.test` with
    `project: proj:swe-pod`, using the branch's mesh-post from the
    agent-mesh build checkout with an explicit bus `--repo`; the installed
    mesh-post has no `--project`. The Context holds:
    - the role-definition line and the brief line;
    - the three repo URLs;
    - the space commit;
    - the commit set;
    - the runner config path (§2.3);
    - under PC2 (i), the operator's approval quoted from the `heavy:` line,
      with its caps and expected time.
  - **Brief.** The tester reads `agents/swe-test.md` from the swe-pod branch
    commit first. The brief grants read-only git (clone, fetch, archive)
    into a scratch directory outside the bus, and running the runner. T19c
    runs no I6, so the brief grants no `git init`. These permissions live
    in the brief only. The tester cites the PC2 authority in its report.
  - **Return on a pre-M3 node**, as T19b's. The executor itself writes each
    file body under `outbox/<its agent id>/T19c-files/<space path>`, which
    the old poller's sync carries. It puts the `files:` list, with sha256,
    in the result body.
  - **Run.** Serially (PC1).
  - **Evidence.** One record, `ev-<YYYYMMDDTHHMMZ>-T19c`, with every §2.4
    key, among them `shard: T19c` and `tests:` listing the 9;
    `scenarios:` for R13.S1, R16.S1 and R23.S2; `x-checks:` for I1;
    `x-suggestions:` for T1.TS4, T7.TS3, T8.TS3, T10.TS6, T13.TS1 and
    T13.TS2; `unit: {swe-pod: none-present, agent-mesh: none-present}`;
    `quality: none-declared`; and `wall_time_s`. Its log pointers go only
    to its `-runs/` files, and its report goes under `evidence/` (§2.4).
  - **Not re-judged.** R7.S1 and R17.S1 live stand on T19b's rounds 3 to 5
    (§3 OD8). T19c's dispatch and filings are not checked against
    test_R7_S1 or test_R17_S1.
  - **Filing.** The lead pulls the bus by hand (§3 OD3), checks each sha256
    against the result body's `files:`, and files them through the
    librarian.
  - **Re-runs.** A re-run at a new commit set runs the 9 again, in this
    order, after a new heavy ask. A re-run for a deliverable that T35's
    fixes change is targeted, as T35's done-when says.
- done when: (1) the result body's `files:` matches the returned files by
  sha256; (2) the evidence record, with `env: linux-server`, is filed, each
  file `FILED` after the ancestor check; (3) no mesh task id or agent id
  enters the space.

T20 is merged into verify (§3 OD6), and its id is not reused.

T40 is dropped (PC1 (a)), and its id is not reused.

T19a and T19b are superseded by T19c (§3 OD8), and their ids are not
reused.

This task runs these 9 tests, serially, in this order (expected 2193 s in all):

- test_I1_process_md
- test_R13_S1_heavy_check_asks_first
- test_T1_TS4_heavy_from_recorded_run_time
- test_T8_TS3_heavy_verify_with_g3_overlay
- test_R23_S2_unnamed_repo_no_branch
- test_T10_TS6_commit_stage_order
- test_T13_TS1_result_files_by_rule
- test_T7_TS3_ledger_written_in_words
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
  - For this change, OD8 replaces this verify form and its verified rule.
- **OD8** (decision and directive, ledger 2026-10-29T01:55Z). Round 6
  stopped on the operator account's daily API spend limit. The operator
  rewrote verify "to focus on the important things": what has passed
  consistently is assumed, and only what remains is tested, as if it were a
  new change, because a full regression run is expensive. The mesh
  demonstration, local and remote pod agents joined by the mesh, is proven
  and is not redone. T35 is kept, with a cost estimate, and so is T36. The
  remaining tests run on the linux-server node through the mesh. The
  rulings under it:
  - Verify is one task, T19c, mesh on linux-server, which runs 9 tests
    (§6). For this change it supersedes T19a and T19b.
  - **Verified, for this change**, is T19c's 9 tests passing, with the
    other 81 tests carried from their filed evidence: 80 passed in round 4
    (`ev-20261028T0947Z-T19a` and `ev-20261028T0950Z-T19b`), and R19.S1
    passed in round 6 at T19c's branch heads and tests, as the ruling
    records, since round 6 filed no record. The runner's desk-step wording,
    changed after round 4, was proven by T41's live runs. This takes the
    place of §2.4's rule, every result passing at one commit set (R24), for
    this change only; §2.4 and R24 as built are unchanged. A targeted
    re-run (T35) replaces the results of the tests it runs.
  - R7.S1 and R17.S1 live stand on T19b's rounds 3 to 5 (OD1, OD6), and
    are not re-judged.
  - Cost if wrong: a regression in an established test is found later, by
    a full run.

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

- Use the runner and its protocol in `changes/build-swe-pod/tests/README.md`. First `runner.sh reset`, then `runner.sh smoke`. A smoke failure, or a managed policy of a kind not ruled on, stops the task as BLOCKED before any test runs. Kinds ruled on: the node's gateway login and provider environment (00:05Z); a gateway settings drop-in, and the gateway's remote managed settings (02:59Z). The evidence body records the smoke result.
- Time: each run is capped at its own `cap_s`, and the task at 120 min in all. A run that reaches its cap is `not-run`, with the cap. If the task reaches 120 min, stop, record every test not yet run as `not-run (task cap)`, and file what you have.
- heavy: approved by agallojr ("yes to heavy", 2026-10-28T03:10Z; "be permissive on time", 02:49Z; "fire at it the remaining 9 tests", 2026-10-29) for runner.sh run over these 9 tests; caps: each run its own cap_s, at most 1800 s, and the task 120 min; expected: 2193 s. Pass `--allow-heavy`.
- API errors (2026-10-29T01:55Z): a run stopped by an API error (provider safeguard, gateway outage), not an agent's answer, re-runs after the main pass, at most twice more, inside the task cap, then test_R16_S1 again last; each test's result is its last run's, and one still stopped is `not-run (environment)`. A spend-limit stop ends the task at once as BLOCKED, with the results so far, and scores no test after it.
- Use a scratch root new for this task, so that test_R16_S1 reads only this task's runs.
- Run only these 9 tests, serially, in the order listed, each once apart from the re-runs above. Write the record with every key of plan section 2.4, `shard: T19c` and `tests:` included, `unit: {swe-pod: none-present, agent-mesh: none-present}`, `quality: none-declared` and `wall_time_s`, and results only for the tests this task ran. Log pointers go only into its `-runs/` folder.
- This brief grants, and only this brief: read-only git (clone, fetch, archive) into a scratch directory outside the bus, and running the runner; no `git init`, as T19c runs no I6. Cite the PC2 authority in the report.
- Return on a pre-M3 node: write each file body under `outbox/<your agent id>/T19c-files/<space path>`, which the poller's sync carries, and put the `files:` list, with each file's sha256, in the result body.

## Start from

- base commit set: space c814837, swe-pod 8fc5294, agent-mesh 8ee5364
- commit set under test: swe-pod 83eaef9, agent-mesh bbd19a2
- tests changed at: 31e5e2d
- space commit: given at dispatch, on its own line

## Result goes to

- evidence: changes/build-swe-pod/evidence/<YYYYMMDDTHHMMZ>-T19c.md, id `ev-<YYYYMMDDTHHMMZ>-T19c`, `env: linux-server`
- runs: changes/build-swe-pod/evidence/<YYYYMMDDTHHMMZ>-T19c-runs/
- report: changes/build-swe-pod/evidence/<YYYYMMDDTHHMMZ>-T19c-report.md

Do not read plan.md, ledger.md, any other brief, report or review, or any code-repo diff or implementation body.
