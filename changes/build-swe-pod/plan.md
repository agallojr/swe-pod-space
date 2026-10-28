# build-swe-pod: plan

- change: `build-swe-pod`; spec `swe-pod` revision 3, approved 2026-10-27T21:36Z
- size: project. Planner: a fresh agent in the plan role, which never saw the
  spec conversation (spec §5.2)
- revision: 3.1, after review rounds 1 to 3 (`plan-review.md`) and the
  operator decisions in §3
- base commit set (what the tests run against at base): the space's `main` at
  the commit that files this plan; swe-pod `8fc5294`; agent-mesh `8ee5364`
  (the pins in `pod.yaml`)
- build base: agent-mesh tasks start from `8ee5364`, and swe-pod tasks from
  T0's commit (§3 OD5)
- code branches: `change/build-swe-pod` in swe-pod and in agent-mesh,
  created by T0 from the pins
- state: planned once filed. The operator skims it before the go

## 1. Goal and approach

Build the SWE Pod as Markdown in `swe-pod` (D1 to D4), and add what the pod
needs from the Agent Mesh to `agent-mesh` (D5). D5 covers M1, M2, M3 and M5,
plus the text of G1 to G3. Each build task writes one deliverable, checks it
with the commands in its done-when, and gets a review. In parallel, a test
agent writes one scenario test for each scenario of R1 to R23, plus
inspection checks, from the spec alone. Verify then runs them, each agent
under test as an isolated headless process briefed only with the
deliverables, against a fixture Project Space.

Every task runs `local` except T19, the verify, which a remote pod agent in
the test role runs on a linux-server node, dispatched through the mesh
(§3 OD6). M4 is not built: spec §14 says "later",
so PROCESS.md and the lead's definition carry its interim rule. T8 writes
the G1 to G3 text, and the operator applies it to the private overlay in
T36. Models: T1, T5 and T35 run on the most capable model available; the
others may run on a cheaper one.

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
  change (T19), the Context also gives the repo URLs, the space commit that
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
  - the latest evidence;
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
  and R17.S1 are verified live by T19's own dispatch (OD6). The final report
  says, verbatim: "7 scenarios desk-verified, live confirmation at pilot;
  R7.S1 and R17.S1 verified live at T19".
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
- **OD6** (directive). Verify is one task, T19, and the former T20 is merged
  into it. It is run by a remote pod agent that holds `swe.test` on a
  linux-server node, dispatched through the mesh. The operator keeps that
  agent standing by, with read access to the three private repos and its own
  signed-in isolated runner config. Its dispatch is the live evidence for
  R7.S1, and the filing of its returned files is the live evidence for
  R17.S1.

Repo rule, not from the spec: agent-mesh carries no operator content
(PROTOCOL §12), and swe-pod follows the same rule. Templates use `<handle>`
and similar placeholders, never a real name, path or host.

## 4. File map

| Repo | File | Create or change | One responsibility | Task |
|---|---|---|---|---|
| swe-pod | `SPEC.md`, `spec-process.*` | land | the design doc (§3 OD5) | T0 only |
| swe-pod | `PROCESS.md` | create | the process as instructions (D1) | T1 |
| swe-pod | `templates/records/*.md` (10 files) | create | one record format each (D3) | T2 |
| swe-pod | `templates/space/*` | create | a new Project Space's skeleton (D3) | T3 |
| swe-pod | `agents/swe-spec.md`, `agents/swe-plan.md` | create | spec and plan roles (D2) | T4 |
| swe-pod | `agents/swe-lead.md` | create | lead role (D2) | T5 |
| swe-pod | `agents/swe-build.md`, `swe-test.md`, `swe-review.md` | create | build, test, review roles (D2) | T6 |
| swe-pod | `skills/swe-pod/SKILL.md`, `status-format.md` | create | status, next step, trace (D4) | T7 |
| swe-pod | `README.md` | land, then extend | the pointer to `SPEC.md` (T0); layout and use (T8) | T0, T8 |
| swe-pod | `INSTALL.md` | create | global install; the G1 to G3 overlay text (D5) | T8 |
| agent-mesh | `templates/agent-identity.env.template` | change | lists the six `swe.*` roles (M1) | T9 |
| agent-mesh | `docs/operator-manual.md` | change | roles (T9); mounting a space and access (T12) | T9, T12 |
| agent-mesh | `guidance/agent-operating.md` | change | loading and the librarian for spaces (T12); result files (T13) | T12, T13 |
| agent-mesh | `skills/mesh-on/poller-prompt.md` | change | task loads its space (T12); returned files (T13) | T12, T13 |
| agent-mesh | `skills/mesh-on/mesh-scan-loop.sh` | change | clone spaces on first need only (M2) | T12 |
| agent-mesh | `skills/space-librarian/SKILL.md` | create | file records into a space, with or without a bus (M5) | T10 |
| agent-mesh | `spec/memory-spaces.md` | create | the design, moved from the space note, with implemented scope marked (M2) | T11 |
| agent-mesh | `spec/PROTOCOL.md` | change | §3 spaces layout and writers, §5 `project:`, §7 pointer (T11); result files, §9 sweep unit (T13) | T11, T13 |
| agent-mesh | `skills/mesh-post/mesh-post.sh`, `SKILL.md` | change | `--project` flag (M2) | T11 |
| agent-mesh | `bus-skeleton/spaces.yaml` | create | empty registry for new buses | T11 |
| agent-mesh | `skills/mesh-load/SKILL.md` | create | load and drop a space (M2) | T12 |
| agent-mesh | `README.md` | change | new skills, spaces, `swe.*` roles | T14 |
| space | `changes/build-swe-pod/tests/**` | create | project-level tests, runner and fixtures | T15 to T18 |
| space | `changes/build-swe-pod/evidence/*` | create | verify evidence and test outputs | T19 |

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

## 5. Build tasks

### T0 Branches and the design doc (at the go)
- role: lead
- repo: swe-pod, agent-mesh
- after: []
- runs: local
- needs: any
- serves: [] (it lands an input, §3 OD5)
- touches: SPEC.md, spec-process.d2, spec-process.svg, spec-process.png,
  README.md
- steps:
  1. Create `change/build-swe-pod` in each code repo from its pin, in its
     build checkout (§4.1), and push it.
  2. Copy the five files from the bus's swe-pod checkout into the swe-pod
     build checkout and compare their sha256. Commit them with trailers
     `Change: build-swe-pod` and `Task: T0`, and push.
  3. Return the bus checkout to a clean `main`.
  4. Record the go, both bases, T0's commit and the sha256 values in the
     ledger.
- done when:
  1. T0's commit is the swe-pod branch's first commit on top of `8fc5294`,
     and holds exactly those five files.
  2. Each file's sha256 matches its source.
  3. The `## 12. Requirements` section of `SPEC.md` is identical to that
     section of `changes/build-swe-pod/spec.md`.
  4. The agent-mesh branch exists on its remote at `8ee5364`.

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

### T2 Record templates (D3)
- role: build
- repo: swe-pod
- after: [T0]
- runs: local
- needs: any
- serves: [R5, R9, R11, R12, R14, R16, R18, R21]
- touches: templates/records/{spec,plan,brief,test-brief,report,review,evidence,ledger,handoff,final-report}.md
- produces: §2.4 formats
- steps: Write one file per record kind, with placeholders only. The
  test-brief template has the sections and exact closing line of §2.4. The
  ledger template lists every §2.4 event form. The evidence template shows
  both `quality` forms, `none-present`, `x-checks`, `x-suggestions`, and the
  log-pointer rule.
- done when: (1) all 10 files exist; (2) each has the exact headings and
  front-matter keys §2.4 gives it, one grep per key; (3) `test-brief.md`
  contains the closing line exactly; (4) the standard close holds.

### T3 Space template (D3)
- role: build
- repo: swe-pod
- after: [T0]
- runs: local
- needs: any
- serves: [R4, R5, R16, R18, R22]
- touches: templates/space/**
- steps:
  - `space.yaml` has all 11 manifest keys, as placeholders or defaults:
    `space`, `id`, `kind: project`, `title`, `visibility`, `owners`,
    `writer_model: multi-actor`, `categories: [notes, lore, decisions,
    evidence, handoffs, changes, tests]`, `header_profile: shareable`,
    `may_reference: []`, `retention`.
  - `pod.yaml` follows spec §4, with `process: swe-pod-process@1` and
    `gates: {spec: human, plan: human-skim, merge: human}`.
  - `AGENTS.md` gives the read order and the standing rules: one branch;
    every write goes through the librarian; the shareable profile;
    collision-free ids; code repos hold only code, unit tests and shipped
    docs. It adds the exception that a test-writing agent reads only its
    brief and `spec.md`.
  - Each folder holds a `.gitkeep`. There is no `STATUS.md`; the skill makes
    it.
- done when: (1) the §2.1 files and folders exist; (2) both YAML files load
  in a YAML parser, and `space.yaml` has the 11 keys; (3) `AGENTS.md` has
  the test-agent exception; (4) the standard close holds.

### T4 Spec and plan roles (D2)
- role: build
- repo: swe-pod
- after: [T0]
- runs: local
- needs: any
- serves: [R2, R3, R6, R8, R19]
- touches: agents/swe-spec.md, agents/swe-plan.md
- steps:
  - **swe-spec** follows the intent rules of §5.1 and the requirement rules
    marked (OS). It asks one question per message, the one that most changes
    what gets built. It lists every default under Open calls and records
    `approved:` only on the human's words. It is the only role that edits a
    spec, and it keeps a product's `SPEC.md` a verbatim copy.
  - **swe-plan** writes `plan.md` in the template's form. If a requirement has
    no scenario, it writes no plan and returns the fixed phrase (§2.5). For a
    spec with `supersedes`, the plan gets a test task that updates the
    matching tests in `tests/`. Tasks that share a file are ordered by
    `after`. Its questions are sorted (a), (b) or (c).
- done when: (1) both files have the §2.3 front-matter and four headings;
  (2) swe-plan contains the planner's fixed phrase exactly; (3) review checks
  the other rules; (4) the standard close holds.

### T5 Lead role (D2)
- role: build
- repo: swe-pod
- after: [T0]
- runs: local
- needs: any
- serves: [R1, R7, R8, R9, R10, R13, R14, R15, R17, R18, R21, R22, R23]
- touches: agents/swe-lead.md
- steps:
  - **Go.** On "go" for a spec without `approved:`, dispatch nothing and
    return the fixed phrase. At the go, create one branch per named repo from
    its pin, and record the base.
  - **Briefs and dispatch.** Write briefs, using the test-writing brief for
    test tasks. Dispatch per §2.3, with machine paths only in prompts and no
    machine names in ledger lines. A mesh task.request's Goal tells the
    executor to read its role definition first. Build tasks stay local until
    the deferred exception lands (§3 OD4). Dispatch ready tasks each cycle
    (the M4 interim).
  - **Checking and filing.** Check that commits exist and that reports hold
    test output. File through the librarian only what is in the role's lane
    (test: `changes/<id>/tests/` and `changes/<id>/evidence/`; build: reports;
    review: reviews), and refuse anything else with a `refused ... lane` line.
  - **Suggestions and failures.** Route suggestions, sending back to its
    builder one that carries a computed value. Return a test that passes at
    base. Route failures (spec §5.5). Count fix rounds and write rulings.
  - **Heavy checks.** Before dispatching one, give the human the command,
    the caps and the expected wall time.
  - **Requirement edits.** When Requirements are edited, reopen approval for
    the edited requirements only, and hold just the tasks that serve them.
  - **Merge and integrate.** Before a merge, re-verify if the pins or
    `tests/` moved since the last evidence. Integrate in `depends` order.
  - **Handoff and status.** On receiving a handoff, re-run the latest verify
    first. Regenerate `STATUS.md` with the skill after each filing.
- done when: (1) the §2.3 front-matter and headings are present; (2) the file
  contains the lead's fixed phrase and every §2.4 ledger event form exactly;
  (3) the lane table names all six roles; (4) review checks the other rules;
  (5) the standard close holds.

### T6 Build, test and review roles (D2)
- role: build
- repo: swe-pod
- after: [T0]
- runs: local
- needs: any
- serves: [R4, R8, R9, R10, R11, R12, R21, R23]
- touches: agents/swe-build.md, agents/swe-test.md, agents/swe-review.md
- steps:
  - **swe-build.** Ask first when anything is unclear. Work test first, and
    run the full unit suite once. Write only code, unit tests and shipped
    docs, on `change/<id>`. Rebase before pushing, and never create a
    branch; a rebase conflict means BLOCKED. If a project-level test looks
    wrong, report `DONE_WITH_CONCERNS` with the `Disputed test:` phrase, and
    leave the test unchanged. Suggestions come in two parts and never carry a
    value the code computed.
  - **swe-test.** Writing mode is blind: read only the brief and `spec.md`,
    and end with the test-brief line. Name each test after its scenario, and
    take expected values from outside the code. Run each new test at the
    base commit set and expect it to fail. Mark tests over 60 s heavy.
    Verify mode: run at the given commit set in the named environment class,
    and write evidence with every §2.4 key. Write only under
    `changes/<id>/tests/` and `changes/<id>/evidence/`.
  - **swe-review.** Review from the brief, the report and the diff, never
    from the builder's session. Write the review in the §2.4 format. The
    whole-change mode checks completeness, correctness and coherence.
- done when: (1) the §2.3 front-matter, tools and headings are present, with
  no Write or Edit in swe-review's `tools`; (2) swe-test contains the
  test-brief closing line exactly, and swe-build the `Disputed test:` phrase;
  (3) review checks the other rules; (4) the standard close holds.

### T7 swe-pod skill (D4)
- role: build
- repo: swe-pod
- after: [T0, T2]
- runs: local
- needs: any
- serves: [R12, R18, R20]
- touches: skills/swe-pod/SKILL.md, skills/swe-pod/status-format.md
- consumes: the T2 templates (ledger, evidence, plan)
- steps:
  - Read `AGENTS.md`, `STATUS.md`, `pod.yaml`, then each change's spec, plan
    and ledger.
  - Derive each change's state from the spec §5 table. A change is verified
    only if its latest evidence covers every declared check and every
    scenario.
  - The next task is the first task whose `after` tasks are done and which
    has no dispatch line yet. "Do the next thing" means acting as swe-lead.
  - STATUS.md follows §2.6.
  - The trace runs from the plan's `serves` and test map, through the
    `git log` trailers on the branch (read-only), to the latest evidence.
  - The skill writes no record except `STATUS.md`, which it files through the
    librarian.
- done when: (1) the description says when to invoke and gives no standing
  rule; (2) the exact §2.6 lines appear in `status-format.md`; (3) all five
  BREAK forms appear in `SKILL.md`; (4) the report shows this space's
  `STATUS.md` regenerated twice by following the skill, in the §2.6 format,
  with the two outputs identical, and not filed; (5) the standard close
  holds.

### T8 swe-pod shipped docs and the G1 to G3 text
- role: build
- repo: swe-pod
- after: [T1, T2, T3, T4, T5, T6, T7]
- runs: local
- needs: any
- serves: [R7, R13, R17]
- touches: README.md (extend), INSTALL.md
- steps:
  - **README.** Extend T0's README. Keep every line except its one status
    line, which may be rewritten to the post-merge state, and keep the
    `SPEC.md` pointer. Add the §2.1 layout, single-seat use and mesh use.
    Say that the pod depends on agent-mesh's `space-librarian` when no mesh
    is present.
  - **INSTALL.** Cover linking `agents/swe-*.md` and `skills/swe-pod/` into
    the user's global Claude config (never into a project), and starting a
    space from `templates/space/`.
  - **"Rules for your guidance overlay."** An INSTALL section that states G1,
    G2 and G3 of spec §14 as rules a deployment adds to its own overlay, in
    generic terms.
  - Leave `SPEC.md` and `spec-process.*` alone.
- done when: (1) every repo-relative path in README or INSTALL exists on the
  branch; (2) T8's diff of `README.md` deletes no line except the status
  line, and the README still names `SPEC.md`; (3) INSTALL has the overlay
  section with three rules, labeled G1 to G3; (4) the standard close holds.

### T9 M1: `swe.*` roles (registration only)
- role: build
- repo: agent-mesh
- after: [T0]
- runs: local
- needs: any
- serves: [R7]
- touches: templates/agent-identity.env.template, docs/operator-manual.md
- steps: Name the six roles in both files. Say they are per-task-output
  roles, and that registering one means adding it to `AGENT_ROLES`. Make no
  change to the protocol, the guidance or the poller (§3 OD4).
- done when: (1) a grep finds all six role names in both files; (2) the
  task's diff touches no other file; (3) the standard close holds.

### T10 M5: space-librarian
- role: build
- repo: agent-mesh
- after: [T0]
- runs: local
- needs: any
- serves: [R16, R17]
- touches: skills/space-librarian/SKILL.md
- steps: Follow §2.7 exactly. Write each check as a command an agent runs,
  portable between BSD and GNU (`grep -E` only, no `-P`). The skill states
  that a mesh librarian uses it for every rw space `spaces.yaml` assigns to
  its role, and that without a bus the session uses it directly.
- done when:
  1. Run in a scratch directory outside every repo, the commands accept as
     clean copies of five records: this space's `spec.md`, `plan.md` and
     `ledger.md`, and its two notes (memory-spaces and the deferral note).
  2. They refuse five records built at run time, each with its §2.7 line
     naming only the check and the line number:
     - one carrying the local `$HOME`;
     - one carrying a registered agent's `cwd` root;
     - one carrying an agent id from the registry;
     - one citing a space not in `may_reference`;
     - one with a duplicate id.
  3. The commit, push and ancestor-check sequence appears in the report as
     desk output, not run.
  4. The standard close holds.

### T11 M2a: spaces in the protocol, `project:` field
- role: build
- repo: agent-mesh
- after: [T0]
- runs: local
- needs: any
- serves: [R7, R17]
- touches: spec/memory-spaces.md, spec/PROTOCOL.md,
  skills/mesh-post/mesh-post.sh, skills/mesh-post/SKILL.md,
  bus-skeleton/spaces.yaml
- steps:
  - **spec/memory-spaces.md** restates the space's memory-spaces note, with a
    status table. Implemented now: §4 mounting for project spaces, §5 loading
    by "load" and by a task's `project`, and §6.3 the librarian. Not yet: §9
    steps 2 and 3, the `active:` default, auto-load at session start, and the
    session-start catalog.
  - **PROTOCOL.** §3 gets the `spaces.yaml` and `spaces/<path>/` rows in the
    layout and the writer table, §5 the optional `project:` field, and §7 one
    paragraph pointing to memory-spaces.
  - **mesh-post** gets `--project`, as §2.7 describes.
  - **bus-skeleton/spaces.yaml** is `spaces: []`, with a comment that the
    operator writes it.
- done when: every run uses a throwaway `git init` repo with no remote, in a
  scratch directory outside every repo, passed as an explicit `--repo`
  (omitting it would reach the live bus), with `--from op-test`. Then:
  1. `bash -n` exits 0.
  2. `--dry-run --project proj:demo` writes `project: proj:demo` right after
     `timeout_min:`.
  3. `--project demo` exits 1 with `mesh-post: invalid --project value:
     demo`, and writes no message.
  4. Without `--project`, there is no `project:` line.
  5. The standard close holds.

### T12 M2b: loading spaces
- role: build
- repo: agent-mesh
- after: [T9]
- runs: local
- needs: any
- serves: [R7, R17]
- touches: skills/mesh-load/SKILL.md, skills/mesh-on/poller-prompt.md,
  skills/mesh-on/mesh-scan-loop.sh, guidance/agent-operating.md,
  docs/operator-manual.md
- steps:
  - **mesh-load** follows §2.7. It initializes with `git submodule update
    --init -- <path>`, then updates with `--remote --merge`; both are
    read-only on the bus.
  - **Scan loop.** Change it per §2.7, keeping it portable to bash 3.2.
  - **Poller.** On a claimed task with `project:`, resolve the path from
    `spaces.yaml`; if the space is not mounted, the task is BLOCKED and names
    the project. Otherwise initialize and pull the space, and tell the
    executor where it is, that it may read but never commit there, and that
    it returns files (§2.7).
  - **agent-operating.** The librarian duty extends to every rw space the
    registry assigns to it, filing through `space-librarian`.
  - **Operator manual.** Mounting by hand (the commands and the registry
    line), and access: read for every pod node, push credentials only on the
    librarian's node.
- done when:
  1. `bash -n` on the scan loop exits 0.
  2. With `MESH_SCAN_LIST=1`, run against a scratch directory whose
     `.gitmodules` lists `product`, `swe-pod`, `spaces/a` and `spaces/b`,
     where only `spaces/a/.git` exists, it prints exactly `product`,
     `swe-pod` and `spaces/a`.
  3. mesh-load contains `NOT MOUNTED` exactly.
  4. Review checks the BLOCKED rule, the read-only instruction and the mount
     commands.
  5. The standard close holds.

### T13 M3: results that carry files
- role: build
- repo: agent-mesh
- after: [T11, T12]
- runs: local
- needs: any
- serves: [R8, R17]
- touches: spec/PROTOCOL.md, skills/mesh-on/poller-prompt.md,
  guidance/agent-operating.md
- steps:
  - **PROTOCOL** gets a result-files subsection per §2.7, and the §9 sweep
    unit gains the `-files/` folder.
  - **Poller.** In the executor instruction, the fixed results phrase (§2.5)
    replaces "never payloads" for requested files only. At the terminal step,
    the poller writes the files and the `files:` list.
  - **agent-operating.** Step 6 says the same, and the archiver sweeps the
    folder with its task. The status file's `artifacts` rule is unchanged.
- done when: (1) PROTOCOL contains `files:`, `-files/` and `1048576`; (2) the
  poller prompt contains the fixed results phrase exactly; (3) review checks
  the sweep-unit sentences and the terminal write step; (4) the standard
  close holds.

### T14 agent-mesh README
- role: build
- repo: agent-mesh
- after: [T10, T13]
- runs: local
- needs: any
- serves: [R7, R17]
- touches: README.md
- steps: List `mesh-load` and `space-librarian` with the other skills, add a
  paragraph on project spaces linking `spec/memory-spaces.md`, and name the
  `swe.*` roles.
- done when: (1) every repo-relative path the README links exists on the
  branch; (2) the standard close holds.

## 6. Test tasks

These are written blind, from the test-writing brief only (§2.4), whose
`## Task` carries the task's own entry from this section. Nothing here
depends on §4.1 or §5, which the test agent never reads.

### T15 Runner, fixtures and inspection checks
- role: test
- repo: space
- after: []
- runs: local
- needs: any
- serves: [R1 to R23]
- touches: changes/build-swe-pod/tests/README.md, tests/runner.sh,
  tests/fixtures/**, tests/test_I1 to test_I8
- steps:
  - **Isolated runner** (`runner.sh`; the protocol is in `README.md`). Each
    agent under test is a separate headless Claude Code process.
    - **Config.** On each node that runs the runner, the operator signs in
      one isolated config at a fixed path. That is this node for T15's smoke
      test, and the linux-server node for T19. The path is given only in the
      dispatch prompt and Context. Before each run, the runner resets that
      config in place:
      it replaces the agents, skills and settings, and clears per-project
      memory and session state. The agents and skills are the test's
      `deliverables:`. There is no CLAUDE.md or other guidance. The provider
      environment is inherited from the session that starts the runner, and
      none of it is written into the space.
    - **Settings.** Install the product's `hooks/git-gate.py` with no
      allowlist, so it denies every git add, commit and push wherever it
      points. Also deny `git -C`, `git branch`, `git checkout`,
      `git reset`, sudo and web tools.
    - **Permission mode.** The mode never prompts, and is never a bypass
      mode. It allows exactly the union of the §2.3 role tools plus Skill
      (Read, Grep, Glob, Bash, Write, Edit, Agent, Skill), minus the denies
      above, and denies everything else.
    - **Where it runs.** The cwd is a scratch copy of the fixture. The
      runner refuses to start unless `git rev-parse` fails in both the cwd
      and the config directory. Fixtures have no `.git`.
    - **Desk steps.** In desk mode, and for every librarian commit step, the
      agent prints commands and runs none.
    - **Caps and output.** A run is stopped at its cap and recorded as
      `not-run (cap)`. Each run writes one output file, in which the scratch
      root is rewritten to `<scratch>`, so no machine path reaches it.
    - **Deliverables.** They are exported read-only by sha (`git archive`)
      from the brief's `## Start from`, never read from a working copy. The
      runner takes machine paths as arguments and holds none.
  - **Test front-matter:** `scenario`, `mode`, `deliverables`, `fixture`,
    `expected_s`, `heavy`, `env`, `cap_s`. Sections: Given, When (the literal
    words), Then (numbered checks), Fails if, At base.
  - **Fixture** `fixtures/demo-space/`: project `proj:demo` with repos
    `alpha`, `beta` (`depends: {beta: [alpha]}`) and `gamma`, which the
    change does not name. Each scenario's overlays go in
    `fixtures/overlays/<test name>/`.
  - **Fixture bus** `fixtures/demo-bus/agents/`: invented placeholder ids,
    one macos-laptop node and one linux-server node, with `swe.test` on the
    linux-server node.
  - **Negative content** (home paths, mesh task ids, agent ids) is built at
    run time from split literals and never stored whole.
  - **Inspection checks**, each defined here only:
    - I1 PROCESS.md: version line, the 15 headings of §2.2, the tables.
    - I2 the six role definitions: the §2.3 front-matter, tools and
      headings.
    - I3 the D3 files: the §2.4 sections and keys, and the 11 `space.yaml`
      keys.
    - I4 the skill against §2.6.
    - I5 the D3 templates hold placeholders only, with no real hostname,
      agent id, home path, credential name or handle (R16).
    - I6 mesh-post `--project`: the three cases of §2.7, each against a
      throwaway `git init` repo with no remote, passed as an explicit
      `--repo`.
    - I7 the agent-mesh documents: `project:`, `files:`, the spaces rows,
      the six roles, both new skills, the scan-loop list mode.
    - I8 the space-librarian checks, on a clean record and on records built
      at run time.
- done when:
  1. The files exist and are returned for filing.
  2. A runner smoke test shows that the agent under test answers `NONE` when
     asked to quote the first line of every instruction file in its context.
     A managed policy file, if any exists, is reported to the lead for a
     ruling.
  3. The smoke test shows that the agent under test can start a subagent,
     which is the depth R7.S2 needs.
  4. The smoke test shows that a long run is stopped at a 30 s cap, that a
     desk run prints a git command without running it, that a permitted
     Bash command (`ls`) succeeds, and that a `git -C <scratch> commit`
     attempt is denied.
  5. If sign-in or isolation fails, T15 reports BLOCKED, for the operator.
  6. Every I-test has been run at the base commit set, and each fails
     because its deliverable is absent (for I6, because `--project` is an
     unknown argument). The lead records these as `T15 at base:`.

### T16 Scenario tests R1 to R11
- role: test
- repo: space
- after: [T15]
- runs: local
- needs: any
- serves: [R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11]
- touches: changes/build-swe-pod/tests/test_R1_* to test_R11_*, their overlays
- steps: Follow `changes/build-swe-pod/tests/README.md`. Write one test per
  scenario, with the names and modes in the test map (§9). Each Fails if
  names the behavior change that would fail the test. Expected values are
  literals from the spec.
- done when: (1) 17 test files exist, one for each scenario from R1.S1 to
  R11.S1; (2) each has been run at the base commit set and fails on the
  runner's precondition (a listed deliverable is absent), with no agent
  started; the lead records `T16 at base:`, and a test that passes at base
  goes back to the test agent.

### T17 Scenario tests R12 to R23
- role: test
- repo: space
- after: [T15]
- runs: local
- needs: any
- serves: [R12, R13, R14, R15, R16, R17, R18, R19, R20, R21, R22, R23]
- touches: changes/build-swe-pod/tests/test_R12_* to test_R23_*, their overlays
- steps: as T16.
- done when: (1) 18 test files exist, one for each scenario from R12.S1 to
  R23.S2; (2) as T16 at base.

### T18 Builder test suggestions
- role: test
- repo: space
- after: [T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12, T13, T14]
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

### T19 Verify, by a remote pod agent (linux-server, mesh)
- role: test
- repo: space, swe-pod, agent-mesh
- after: [T0 to T18]
- runs: mesh
- needs: linux-server
- serves: [R1 to R23]
- touches: changes/build-swe-pod/evidence/<YYYYMMDDTHHMMZ>.md,
  changes/build-swe-pod/evidence/<YYYYMMDDTHHMMZ>-runs/<test name>.txt,
  changes/build-swe-pod/tasks/T19-report.md
- prerequisite: the operator has signed in the node's isolated runner config
  (T15 Config). If that config or sign-in fails, T19 reports BLOCKED, for the
  operator.
- steps:
  - **Dispatch** (§3 OD6). The lead files the T19 brief and the ledger line
    `dispatch T19 -> test (mesh, linux-server)` in one space commit. It then
    posts a `task.request` to `role:swe.test` with `project: proj:swe-pod`.
    The Context holds the role-definition line, the brief line, the three
    repo URLs, that space commit, the commit set under test (the space plus
    both branch heads, by sha), and the runner config path (§2.3).
  - **Brief.** The tester reads `agents/swe-test.md` from the swe-pod branch
    commit first. The brief grants read-only git (clone, fetch, archive) into
    a scratch directory outside the bus; for I6, `git init` of throwaway
    repos there and staging into them, and nothing else; and running the
    runner. These permissions live in the brief only. The node's product
    predates M3, so the brief carries the §2.7 result-files format.
  - **Run.** Run every test in `changes/build-swe-pod/tests/` (I1 to I8 and
    every scenario and suggestion test) with the isolated runner, at the
    commit set. The node is not a laptop, so up to 4 runs go in parallel,
    and never more than half the node's cores. Caps are each test's `cap_s`
    (at most 600 s) and 240 min in total. `test_R16_S1` runs last, over the
    ledgers of all earlier runs.
  - **R7.S1, live.** The tester checks test_R7_S1's Then items against its
    own task.request and the dispatch line in the space commit it was given,
    and records that result for R7.S1. The desk run is also kept, in the
    report.
  - Neither repo has a unit suite, and the spec has no Quality section.
  - **Heavy.** Before dispatch, the lead gives the operator the runner
    command, the caps and an expected 45 to 90 min (R13.S1).
  - **Return.** The evidence record, every test's output file and the report
    come back as result files (`files:`, with sha256). The lead pulls the bus
    by hand (§3 OD3), checks each sha256, and files them through the
    librarian.
- done when:
  1. The result's `files:` matches the returned files by sha256.
  2. The evidence has every §2.4 key:
     - results for all 35 scenarios, with R7.S1 judged live;
     - I1 to I8 under `x-checks`;
     - every suggestion test under `x-suggestions`;
     - `unit: {swe-pod: none-present, agent-mesh: none-present}`;
     - `quality: none-declared`;
     - `env: linux-server` and `wall_time_s`;
     - log pointers to the `-runs/` files only.
  3. The librarian has filed every file, each `FILED` after the ancestor
     check. Those filings, checked by T35 against test_R17_S1's Then items,
     are R17.S1's live evidence.
  4. No mesh task id or agent id enters the space.

  Green means every result passes.

T20 is merged into T19 (§3 OD6), and its id is not reused.

## 7. Review tasks

Every review task has role review, repo as the task reviewed, `runs: local`
and `needs: any`. Each touches only `changes/build-swe-pod/tasks/T<n>-review.md`,
which it returns to the lead for filing. It reviews the task's own commits,
found by `Task: T<n>` (§4.1), and also checks the rules its build task's
done-when leaves to review.

In a review task, `after: [T<k>]` means T<k> has reported and its commit
exists; T<k> is done only when the review closes. A review is done when its
record is filed with a verdict, and every Critical or Important finding is
closed by the fix loop (at most 5 rounds) or ruled on. Minor findings go to
the ledger.

| Task | Reviews | after | serves |
|---|---|---|---|
| T21 | T1 PROCESS.md | [T1] | as T1 |
| T22 | T2 record templates | [T2] | as T2 |
| T23 | T3 space template | [T3] | as T3 |
| T24 | T4 spec and plan roles | [T4] | as T4 |
| T25 | T5 lead role | [T5] | as T5 |
| T26 | T6 build, test, review roles | [T6] | as T6 |
| T27 | T7 skill | [T7] | as T7 |
| T28 | T8 swe-pod docs and G1 to G3 text | [T8] | as T8 |
| T29 | T9 M1 | [T9] | as T9 |
| T30 | T10 M5 | [T10] | as T10 |
| T31 | T11 M2a | [T11] | as T11 |
| T32 | T12 M2b | [T12] | as T12 |
| T33 | T13 M3 | [T13] | as T13 |
| T34 | T14 agent-mesh README | [T14] | as T14 |

### T35 Whole-change review
- role: review
- repo: swe-pod, agent-mesh
- after: [T19] (its first green run)
- runs: local
- needs: any
- serves: [R1 to R23]
- touches: changes/build-swe-pod/tasks/T35-review.md
- steps: Run on the most capable model. The inputs are the spec, this plan,
  both branches' diffs from their bases, the latest evidence, and the
  ledger's deferred minors and rulings. Check:
  - completeness: every requirement has a deliverable and a passing test;
  - correctness: each deliverable says what the spec means;
  - coherence: the decisions in §2 and §3 show up in the deliverables;
  - that each "for the reviewer" part is covered;
  - that T19's filings meet test_R17_S1's Then items, which is R17.S1's
    live evidence (§3 OD6).
- done when: the record is filed; one builder fixes its findings in one
  wave; one re-review follows; the lead rules on what remains; verify is
  re-run if a deliverable changed.

## 8. Integrate task

### T36 Integrate
- role: lead, with the operator
- repo: space, swe-pod, agent-mesh
- after: [T19, T35]
- runs: local
- needs: any
- serves: [R5, R14, R15]
- touches: STATUS.md, pod.yaml, AGENTS.md, PROCESS.md (copied in), tests/,
  changes/build-swe-pod/ -> changes/archive/<yyyy-mm-dd>-build-swe-pod/,
  notes/note-20261027T2142Z-0a31-memory-spaces-design.md (header only),
  changes/build-swe-pod/report.md
- steps:
  1. **Fresh evidence.** If `tests/` or a pin moved since T19, rebase
     and run verify again.
  2. **Reconcile** the spec with the deliverables, and confirm that T0's
     check (3) still holds.
  3. **Final report**, in the §2.4 format. It gives OD1's sentence verbatim
     and lists the seven desk-verified scenarios, citing T19's dispatch and
     filings for R7.S1 and R17.S1.
     Under open questions it records that R7 holds only for local builds
     until the deferred exception lands (§3 OD4).
  4. **Overlay.** The operator applies T8's G1 to G3 text to the private
     best-practices overlay, before the merges.
  5. **Merge**, on the operator's word only: agent-mesh, then swe-pod; then
     the branches are deleted.
  6. **Operator steps, outside the space:**
     - remove the two checkout paths from the git-gate allowlist;
     - link the swe-pod agents and skill, and agent-mesh's two new skills,
       into the shared Claude config;
     - advance the bus's `product/` and `swe-pod/` gitlinks in dedicated
       commits;
     - turn the poller back on (§3 OD3).
  7. **One space commit:**
     - copy `PROCESS.md` into the space root;
     - set `process: swe-pod-process@1` in `pod.yaml`;
     - advance both pins to the merge commits;
     - in `AGENTS.md`, delete the paragraph that begins "Until `PROCESS.md`
       exists", and add the T3 test-agent exception;
     - move `changes/build-swe-pod/tests/` into `tests/`;
     - add `superseded_by` to the memory-spaces note, as the URL of
       agent-mesh `spec/memory-spaces.md`;
     - mark `integrated:`, and archive the folder.
  8. **Regenerate** `STATUS.md` with the skill. Prune the scratch.
- docs and open plans touched: the space's `AGENTS.md`, `README.md` and
  `pod.yaml`. No other open plan exists in this space.
- done when:
  - the overlay holds G1 to G3 before the first merge;
  - both merges are on `main` in `depends` order;
  - the space commit holds every edit in step 7;
  - `report.md` lists every ruling and suggestion, and has OD1's sentence;
  - the regenerated `STATUS.md` shows no open change.

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
| R7.S1 | test_R7_S1_mesh_dispatch | live, at T19's own dispatch; desk run kept | T16 |
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
| R17.S1 | test_R17_S1_remote_test_results_filed | live, T19's filings checked by T35; desk run kept | T17 |
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

Inspection checks and the requirements they serve (§13): I1 (R1 to R6,
R10 to R15, R18, R19, R21 to R23); I2 (R7 to R9, R17, R21, R23); I3 (R4,
R5, R11, R12, R16, R18, R21, R22); I4 (R18, R20); I5 (R16, through the D3
templates); I6 (R7); I7 (R7, R13, R17); I8 (R16, R17). T15 writes all eight. Repo-wide hygiene is not a check of this change,
because the spec declares no Quality section; the standard close covers it.

## 10. Dependency summary

- **At the go:** T0 (both branches and the design doc) and T15, in parallel.
- **After T0:** T1 to T6 in parallel in the swe-pod checkout; T9, T10 and
  T11 in parallel in the agent-mesh checkout. None of them share a file.
- **Then:**
  - T7 after T0 and T2. T8 after T1 to T7.
  - T12 after T9. T13 after T11 and T12. T14 after T10 and T13.
  - T16 and T17 after T15, in parallel.
  - T19 (mesh), then T35, then T36.
- **Ordering of shared files:**
  - `guidance/agent-operating.md` and `skills/mesh-on/poller-prompt.md`: T12,
    then T13.
  - `docs/operator-manual.md`: T9, then T12.
  - `spec/PROTOCOL.md`: T11, then T13.
  - swe-pod `README.md`: T0, then T8.
  - `SPEC.md` and `spec-process.*`: T0 only, plus T0-style re-copies (§4.1).
  - No other file is touched by two tasks. Test tasks write only new files.
- **Longest chain** (13 tasks): T0 > T9 > T29 > T12 > T32 > T13 > T33 > T14
  > T34 > T18 > T19 > T35 > T36.

## Self-review

- **Every requirement maps to a build task.** R1 to T1, T5. R2 to T1, T4. R3
  to T1, T4. R4 to T1, T3, T6. R5 to T1, T3, T5, T6. R6 to T1, T2, T4. R7 to
  T5, T8, T9, T11, T12, T13. R8 to T4, T5, T6, T13. R9 to T2, T5, T6. R10 to
  T1, T5, T6. R11 to T1, T2, T6. R12 to T1, T2, T6, T7. R13 to T1, T5, T8.
  R14 to T1, T2, T5. R15 to T1, T5. R16 to T2, T3, T10. R17 to T5, T8, T10,
  T11, T12, T13. R18 to T1, T2, T3, T5, T7. R19 to T1, T4. R20 to T7. R21 to
  T1, T2, T5, T6. R22 to T1, T3, T5. R23 to T1, T5, T6. Pass.
- **Every scenario maps to a test.** The test map lists 35 of 35 scenarios,
  each with a test name and the task that writes it. Pass.
- **No placeholder steps.** Every done-when names a file, an exact string, a
  command, or rules left to its review. Nothing says TBD, "handle edge cases"
  or "add tests". Pass.
- **Names agree.** These match between §2 and every task that uses them:
  `swe-pod-process@1`, `swe-<role>`, `swe.<role>`, `project:`, `--project`,
  `files:`, `-files/`, `MESH_SCAN_LIST`, `space-librarian`, `mesh-load`,
  `none-present`, `none-declared`, `x-checks`, `x-suggestions`, `T<n>.TS<k>`,
  `test_R<n>_S<m>_<slug>`. Pass.
- **Every task has its fields.** Each has role, repo, after, runs, needs,
  serves and done-when; the review tasks get them through the rule above
  their table. T0 serves none, because it lands an input (§3 OD5). Pass.
- **Shared files are ordered** (§10). No build task touches `SPEC.md`, and
  the standard close checks that. Pass.
- **Blindness, scope, shareable.** §6 cites only §2, §3, §9 and its own
  files. Nothing outside spec §§13 and 14 is built; M4 and the executor git
  exception are deferred (§3 OD4). There is no hostname, agent id, home path
  or private record id. Pass.

## Questions for the spec

The questions that needed the operator are settled (§3, OD1 to OD6). Several
earlier defaults are now fixed in §2 or in their tasks, and are no longer
open: result files (§2.7); M4 deferred (§1); mesh builds deferred (§3 OD4,
T36 step 3); results with no scenario (§2.4); no layout bump (§2.7);
templates kept in the product (§2.1); negative fixtures built at run time
(T15). The rest are ranked by the cost of a wrong guess.

1. **(b) Can the agents under test be isolated?** T15's runner isolates them
   from the operator's guidance and git gate, and the operator signs in its
   config at the go. If sign-in or isolation fails, T15 is BLOCKED and the
   question goes to the operator.
2. **(b) How does the test agent stay blind?** `AGENTS.md` sends arriving
   agents to `plan.md` and `ledger.md`. The test-brief line, swe-test and
   the template's `AGENTS.md` keep a test-writing agent to its brief and
   `spec.md`, and T36 adds the same exception to this space's `AGENTS.md`.
3. **(b) How do builders share one checkout?** They commit by pathspec and
   find their diffs by trailer (§4.1).
4. **(b) Is STATUS.md regeneration deterministic (R20.S1)?** It is a fixed
   format, with an "As of" time taken from the newest record, and T7 checks
   that two regenerations are identical. A generator script would be a new
   change.
5. **(b) Are the role definitions exercised as subagent types before
   install?** Yes: the runner installs them into its isolated config. The
   operator's config gets them at T36.
6. **(b) What does space-librarian check against?** Real registry and node
   values, plus the patterns and reference fields of §2.7. It is a Markdown
   skill, with no script.
7. **(b) Where are G1 to G3 written and reviewed?** In INSTALL.md (T8,
   reviewed by T28), applied by the operator in T36.
8. **(a) Does this change run quality checks?** No. The spec has no Quality
   section, so verify runs none and the evidence says `none-declared`
   (§5.1, R12.S2).
9. **(a) Does T19 need the human's word first?** Yes. It is heavy, so the
   lead gives the human the command, the caps and the expected wall time
   before dispatching it (R13.S1, §5.4).
