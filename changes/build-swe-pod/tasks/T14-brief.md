# T14 brief

- change: build-swe-pod
- task: T14
- role: build
- repo: agent-mesh

## Task

From plan.md, verbatim:

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

- agent-mesh: branch change/build-swe-pod at its head when this task is dispatched, after every task in its after list has closed
- space: main at the commit that files this brief

## Result goes to

- code: commits on change/build-swe-pod in agent-mesh, trailers `Change: build-swe-pod` and `Task: T14`, pushed
- report: changes/build-swe-pod/tasks/T14-report.md, returned to the lead for filing
