# T6 brief

- change: build-swe-pod
- task: T6
- role: build
- repo: swe-pod

## Task

From plan.md, verbatim:

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
  change (T20), the Context also gives the repo URLs, the space commit that
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

- code: commits on change/build-swe-pod in swe-pod, trailers `Change: build-swe-pod` and `Task: T6`, pushed
- report: changes/build-swe-pod/tasks/T6-report.md, returned to the lead for filing
