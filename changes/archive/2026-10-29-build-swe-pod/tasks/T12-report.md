# T12 report

- change: build-swe-pod
- task: T12 (M2b: loading spaces)
- role: build
- repo: agent-mesh
- commit: 859679a on `change/build-swe-pod`, trailers `Change: build-swe-pod`
  and `Task: T12`, pushed (base 97b35a2)

## Status

DONE

Done-when checks 1 to 3 pass, and so do the checkable items of the standard
close. Done-when 4 (the BLOCKED rule, the read-only instruction and the mount
commands) and the review item of the standard close are left to the review
(§7).

## What I did

- Wrote the done-when checks as shell commands against a scratch directory
  under /tmp, outside every repo, and ran them. Check 1 (`bash -n`) already
  passed at base. Checks 2 and 3 failed on the missing content. I also ran a
  functional check of the scan loop on a local clone of the bus, using local
  submodule URLs and a scratch `HOME`. It failed at base: the old scanner
  cloned the unloaded space and left it at the gitlink, not the tip.
- `skills/mesh-on/mesh-scan-loop.sh`: the scanner now reads submodule paths
  from `.gitmodules` (`git config -f`) and updates them one call per path.
  - A path not under `spaces/` is updated as before: `--init --recursive`,
    plus `--remote` only when `MESH_PRODUCT_TRACK=tip`.
  - A `spaces/*` path is updated only if `<path>/.git` exists, and always
    with `--remote --merge`, with no `--init`.
  - `MESH_SCAN_LIST=1` prints the update set and exits 0. It runs straight
    after the repo argument is read, before the role and id arguments are
    checked, the seen file is touched, the stop check or any pull.
  - Each git call takes stdin from /dev/null, so it cannot read the path list
    the loop is reading.
  - Empty arrays are never expanded, so the script is safe under `set -u` in
    bash 3.2, and it uses nothing newer than bash 3.2. The header comment
    describes the new behavior.
- `skills/mesh-load/SKILL.md` (new): the verbs "load <project>" and
  "drop <project>", following §2.7.
  1. Find the bus.
  2. Check that the space is mounted: a `spaces.yaml` entry plus a
     `.gitmodules` submodule at that entry's path. If not, print
     `NOT MOUNTED proj:<name>` and the operator's mount commands, then stop.
  3. Clone on first need with `submodule update --init -- <path>`.
  4. Pull the tip with `submodule update --remote --merge -- <path>`.
  5. Print the catalog: the `STATUS.md` header, then the ids and titles in
     `notes/` and `decisions/`.
  6. Record the loaded set in a per-session flag file, as `mm-on` does.

  Drop removes the id from the flag file, rewriting it with `mv`, not `rm`.
  The skill says it is read-only on the bus and that the space is read-only
  to the session.
- `skills/mesh-on/poller-prompt.md`:
  - New step 4b2, between the credential check and `running`. For a task with
    `project:`, the poller resolves the path from `spaces.yaml`. If the space
    is not mounted, the task gets status `blocked` with `error`
    `NOT MOUNTED proj:<name>`, and the poller never mounts it. Otherwise it
    clones the space on first need and pulls its tip, with no add, commit or
    push.
  - A paragraph in "Dispatching an executor" tells the executor the space's
    id and absolute path, that it may read the space but never write, stage,
    commit or push there, and that it returns files with space-relative
    paths. Those go in the result's `files:` list, which the librarian files.
  - A single-writer bullet: `spaces.yaml`, `.gitmodules` and the space
    gitlinks belong to the operator.
  - The step 0 scanner description now matches the script, including
    `MESH_SCAN_LIST=1`.
- `guidance/agent-operating.md`:
  - The scanner description in step 1 matches the script.
  - Step 4 gains the project-space load and the BLOCKED rule.
  - The single-writer table gains a row for spaces.
  - The librarian duty extends to every `access: rw` space that `spaces.yaml`
    assigns to a librarian role the node holds (`librarian`, or
    `librarian.<label>`). Filing goes through `space-librarian`, in the
    space's own repo and never through the bus, and never into an `ro` space.
    Push credentials live on that node only.
- `docs/operator-manual.md`: new section 8, "Mounting a memory space". It gives
  the mount commands by hand, the `spaces.yaml` registry line and what `ro`,
  `rw` and `librarian` mean. It says what nodes do with a mount (clone on
  first need; `MESH_SCAN_LIST=1` to inspect) and covers a task blocked on
  `NOT MOUNTED`. On access: read access for every pod node, and push
  credentials only on the node holding the space's librarian role. A short
  Retire paragraph follows (see Concerns). Section 1 now notes the exception
  for spaces. The phone and glossary sections are renumbered 9 and 10, and
  the one cross-reference to them is updated.
- Ran the checks again (all green), staged by pathspec, ran the shareability
  check, committed by pathspec with the trailers, and ran the shareability
  check again. The fetch showed the remote head was already an ancestor
  (merge-base exit 0), so I pushed without a rebase.

## Files

- `skills/mesh-load/SKILL.md` (agent-mesh): created, the mesh-load skill
- `skills/mesh-on/mesh-scan-loop.sh` (agent-mesh): changed, the update set
  and list mode
- `skills/mesh-on/poller-prompt.md` (agent-mesh): changed, step 4b2, the
  executor lines for a project space, the single-writer bullet, the scanner
  text
- `guidance/agent-operating.md` (agent-mesh): changed, loading in step 4, the
  single-writer row, the librarian duty for spaces, the scanner text
- `docs/operator-manual.md` (agent-mesh): changed, new section 8, section 1
  note, renumbering
- Commit range: `agent-mesh 97b35a2..859679a`, one commit, 859679a, 5 files,
  +388/-24 lines, pushed to `change/build-swe-pod`
- `changes/build-swe-pod/tasks/T12-report.md` (space): this report, for the
  librarian to file

## Test output

Checkout and scratch paths are replaced with placeholders. Every run used
`/bin/bash` 3.2.57 (the macOS default).

### Check 1, done-when (1): `bash -n` on the scan loop

- command: `/bin/bash -n skills/mesh-on/mesh-scan-loop.sh; echo "check1 exit=$?"`
- red: `check1 exit=0` (already passed at base; this is a syntax check)
- green: `check1 exit=0` on the worktree, and `committed check1 exit=0` on the
  blob read from `origin/change/build-swe-pod`

### Check 2, done-when (2): list mode

The fixture is `<scratch>/.gitmodules`, listing `product`, `swe-pod`,
`spaces/a` and `spaces/b`, where only `<scratch>/spaces/a/.git` exists. The
expected output is the three lines `product`, `swe-pod`, `spaces/a`. 2a runs
with all arguments, 2b with the repo argument only. `MESH_SEEN_FILE` points
into the scratch directory.

- command: `MESH_SCAN_LIST=1 /bin/bash skills/mesh-on/mesh-scan-loop.sh <scratch> r a 1 1`
  (2a), and the same with `<scratch>` only (2b); each output is compared
  exactly with the expected file
- red:

  ```
  == check 2a: MESH_SCAN_LIST=1 with all args
  STOP
  rc=2
  check2a FAIL
  == check 2b: MESH_SCAN_LIST=1 with repo arg only
  skills/mesh-on/mesh-scan-loop.sh: line 32: 2: roles csv
  rc=1
  check2b FAIL
  ```

- green:

  ```
  == check 2a: MESH_SCAN_LIST=1 with all args
  product
  swe-pod
  spaces/a
  rc=0
  check2a pass
  == check 2b: MESH_SCAN_LIST=1 with repo arg only
  product
  swe-pod
  spaces/a
  rc=0
  check2b pass
  no seen file written
  ```

  The committed blob gives the same output: `committed check2 pass`. Edge
  runs: a gitfile `spaces/b/.git` (the form a real submodule checkout has)
  lists `spaces/b`, with rc 0; a directory with no `.gitmodules` prints 0
  lines, with rc 0.

### Check 3, done-when (3): `NOT MOUNTED` in mesh-load

- command: `grep -c 'NOT MOUNTED' skills/mesh-load/SKILL.md; echo "check3 exit=$?"`
- red: `ugrep: warning: skills/mesh-load/SKILL.md: No such file or directory`,
  `check3 exit=2`
- green: `3`, `check3 exit=0`. `NOT MOUNTED proj:<name>` appears once as the
  printed line form. The committed blob has 3 matches.

### Functional check: the scan loop on a local bus clone

The fixture is a local `git clone` of the bus with LFS smudge skipped, taken
at the bus head of the time. Its submodule URLs point at local read-only
sources: the two code checkouts, and the space checkout for
`spaces/proj-swe-pod`. Each run is one pass with `POLL_SEC` 1 s and
`MAX_WAIT_SEC` 1 s, under a scratch `HOME`, with `protocol.file.allow=always`
set through the environment. Nothing was staged or committed anywhere. Commit
ids are abbreviated.

- red (old scanner, fresh clone): `IDLE`, rc 5, 31.6 s. Product and swe-pod
  were at their gitlinks. `spaces/proj-swe-pod` was cloned by the scanner and
  sat at the gitlink `fc61772`, while the source `main` was `2d8d8f7`.
- green (new scanner, fresh clone):
  - pass 1: `IDLE`, rc 5, 1.9 s. Product and swe-pod were at their gitlinks,
    `spaces/proj-swe-pod not initialized`, and list mode printed `product`
    and `swe-pod`.
  - first-need init, by mesh-load's step 3 command: the space checked out the
    gitlink `fc61772`, and list mode then also printed `spaces/proj-swe-pod`.
  - pass 2: `IDLE`, rc 5, 1.0 s. The space was at `03d8c12`, equal to the
    source `main` (`03d8c12`), and the tip was an ancestor of HEAD. Product
    and swe-pod were unchanged.
  - after each pass, the bus clone's HEAD was unchanged, with
    `index-clean=yes` and `tracked-clean=yes`.

### mesh-load snippets, run read-only

- Step 2 on the bus: `MOUNTED proj:swe-pod spaces/proj-swe-pod rw` and
  `NOT MOUNTED proj:nope`. On a scratch registry with an entry but no
  submodule: `NOT MOUNTED proj:ghost`. With a submodule but no entry:
  `NOT MOUNTED proj:swe-pod`.
- Step 5 on the space checkout: printed the `STATUS.md` header (title,
  generated line, pins, open changes) and two lines,
  `note-20261027T2142Z-0a31  Agent Mesh memory spaces, design concept revision 2 (2026-10-27)`
  and
  `note-20261027T2242Z-0786  Deferred: git exception for remote build executors`
  (quotes stripped). There is no `decisions/` folder yet, which the loop
  skips.
- Steps 6 and Drop, with a scratch config dir: loading twice gave one line;
  drop removed only the named id; dropping the last id left a 0-byte file.
- `git -C <dir> config -f .gitmodules ...` resolves the file against the
  `-C` directory, as the mount commands assume.

### Project-level inspection I7, items 5 and 7 (an aid only)

The I7 check block was run unchanged against `git archive` exports.

- red (export of 97b35a2): `I7.5 fail mesh-load skill absent or incomplete`,
  `I7.7 fail scan-loop list mode not documented`
- green (the worktree that became 859679a): `I7.5 pass mesh-load skill as
  contract`, `I7.7 pass scan-loop list mode documented`. I7.2 still fails as
  expected: that is T13's `files:` content. I7 as a whole exits 1 until T13
  lands.

### Standard close

- Shareability (§2.8), last line, after staging: `shareability: 0 hits`.
  After the commit: `shareability: 0 hits`.
- swe-pod `git diff <latest Task: T0 commit> -- SPEC.md spec-process.*`:
  `T0=74d23f1 diff-bytes=0`.
- Commit by pathspec with both trailers, pushed. The `Task: T12` commits on
  `origin/change/build-swe-pod` are `859679a` only. It changes exactly the
  five touches, and its message has both trailer lines (2 of 2).
  `git show --check` is clean. Push: `97b35a2..859679a  change/build-swe-pod
  -> change/build-swe-pod`. `ls-remote` shows `859679a`.
- Review (§7): pending.

Unit suite: agent-mesh has no unit suite (no test files or test runner; the
one `package.json`, under `services/librarian-ingress/`, has no test
script), so there is no `unit <p>/<n>` line.

## Concerns

- **Retire paragraph beyond the listed steps.** The brief's operator-manual
  step names mounting and access. `spec/memory-spaces.md` (T11) cites
  `docs/operator-manual.md` for "§8 (mount, retire)", and T11's review noted
  that nothing planned documents retire. I added a five-line Retire paragraph
  (`submodule deinit -f`, `git rm`, then remove the registry line), taken from
  memory-spaces §8, so that the citation holds. The reviewer may ask for it to
  be dropped.
- **Clone or pull failure also blocks.** Besides the BLOCKED rule for an
  unmounted space, poller step 4b2 also blocks the task, naming the project,
  if the first-need clone or the tip pull fails (for instance, no read access
  on that node). mesh-load stops in the same case. The status gets no git
  error text, because a remote URL could carry a credential. This goes past
  the brief's wording, so the reviewer should confirm it.
- **The scanner now merges into space checkouts.** Every cycle, on every node
  that has cloned a space (the librarian's node included), the scanner runs
  `--remote --merge` in that space's checkout. On the librarian's node this
  can collide with a filing in progress, or fail on an untracked file that
  an incoming commit adds. Such failures are swallowed and retried on the
  next cycle, so the space lags rather than breaks. While the poller is off
  on the lead's node (§3 OD3), this does not arise there.
- **Depends on T13.** The executor lines name the result's `files:` list.
  The poller's terminal step that writes those files comes in T13, so until
  T13 lands a project task's returned files have no publishing step.

## Test suggestions

### T12.TS1 A task for an unmounted project is blocked, not run

- for the tester: R7 and spec §14 M2 (PROTOCOL §5, memory-spaces §5 step 1).
  Post a `task.request` with `project: proj:<name>` to a role on a bus where
  that project is not mounted. Try three cases: no `spaces.yaml`; a
  `spaces.yaml` without that id; an entry whose path has no submodule.
  Expected failure: the claiming node runs an executor anyway, mounts the
  space, or edits `spaces.yaml` or `.gitmodules`. The status should be
  `blocked` and name the project.
- for the reviewer: agent-mesh/skills/mesh-on/poller-prompt.md:197-225 (step
  4b2), agent-mesh/guidance/agent-operating.md:103-114. The mounted test needs
  both halves, and an invalid `project:` value counts as not mounted.

### T12.TS2 Spaces are cloned on first need and then follow the tip

- for the tester: R7 and spec §14 M2 (memory-spaces §4.2, §4.3). Take a bus
  with a mounted space that this node has never loaded. After a scan cycle,
  the space's directory should still be empty. After the space is loaded
  once, and a new commit lands on the space's `main`, the next cycle should
  bring that commit into the node's checkout, while product stays at its pin.
  Expected failure: the scanner clones every mounted space, or leaves a
  loaded space at its gitlink.
- for the reviewer: agent-mesh/skills/mesh-on/mesh-scan-loop.sh:41-56 and
  :84-106. Check the `<path>/.git` existence test (it must accept the gitfile
  form), the `[ -n "$p" ]` guard (an empty path would be an empty pathspec,
  which matches every submodule), and the stdin redirect inside the
  here-document loop.

### T12.TS3 Loading never changes the bus

- for the tester: spec §14 M2 and R17 (memory-spaces §5: "Loading never
  changes the bus"). In a session, "load proj:<name>" for a mounted space.
  Afterwards the bus should have no staged change, no new commit and no edit
  to a tracked file, and the space checkout should have no new commit from
  the session. Then "drop proj:<name>". The space should leave the session's
  loaded set, and its clone should stay in place.
- for the reviewer: agent-mesh/skills/mesh-load/SKILL.md:22-28, :92-113 and
  :142-175. The two `submodule update` commands, and the flag-file rewrite in
  Drop.

### T12.TS4 Registry entries the resolver cannot read

- for the tester: spec §14 M2 (memory-spaces §4.3 registry). Use a
  `spaces.yaml` whose entry for a mounted space is written in block style
  (one key per line) instead of the one-line form the skeleton shows. Then
  "load" that project, and post a task naming it. Expected failure: the space
  is loaded from a wrong path. Reporting NOT MOUNTED is the conservative
  outcome.
- for the reviewer: agent-mesh/skills/mesh-load/SKILL.md:49-64. The `grep`
  and `sed` resolver reads one-line flow entries only, as space-librarian's
  registry grep does, so the two must stay in step if the registry format
  changes.
