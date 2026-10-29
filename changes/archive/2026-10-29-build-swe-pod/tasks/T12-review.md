---
task: T12
diff: agent-mesh 97b35a2..859679a
verdict: pass
---

## Spec compliance
- missing: none. Each step in the brief is present in the one `Task: T12` commit, 859679a, which changes exactly the five touches.
  - mesh-load (new) has both verbs, "load <project>" and "drop <project>". It initializes with `submodule update --init -- <path>` only when `<path>/.git` is absent, then always runs `submodule update --remote --merge -- <path>`. It prints `NOT MOUNTED proj:<name>` and the mount commands, then stops. It prints the catalog (the STATUS.md header plus the ids and titles in notes/ and decisions/) and keeps the loaded set in a per-session flag file keyed the way mm-on keys its flag.
  - The scan loop reads paths from .gitmodules. Non-space submodules keep the old flags (`--init --recursive`, plus `--remote` under `MESH_PRODUCT_TRACK=tip`). It updates only those `spaces/*` paths where `<path>/.git` exists, with `--remote --merge` and no `--init`. `MESH_SCAN_LIST=1` prints the set and exits 0 before any pull, seen-file touch or stop check. The script stays within bash 3.2.
  - The poller has step 4b2 and the executor lines. agent-operating has the loading rule and the librarian duty for rw spaces through space-librarian. The operator manual has the new section 8.
- extra:
  - A Retire paragraph in the operator manual. It is justified: the Status table in `spec/memory-spaces.md` cites the operator manual for "§8 (mount, retire)".
  - Poller step 4b2 also blocks the task, naming the project, when the first-need clone or the tip pull fails. This is the conservative choice, consistent with the credential branch, and it keeps git stderr (which could carry a URL credential) out of the status.
  - A single-writer bullet in the poller and a single-writer table row in agent-operating that give `spaces.yaml`, .gitmodules and the space gitlinks to the operator. This matches PROTOCOL §3.
  - Renumbering of the phone and glossary sections. The only cross-reference to them was updated, and no other file in the repo cites those section numbers.

  All of these are accepted.
- misread: none.
- Done-when rules left to review (4), each confirmed by reading the deliverable:
  - **BLOCKED rule: holds.**
    - `skills/mesh-on/poller-prompt.md:197-225`, step 4b2, runs after the credential check and before `running`. It resolves the path from `spaces.yaml`, and treats a space as mounted only when an entry exists and .gitmodules has a submodule at that path. If either is missing, it writes status `blocked` with `error` `NOT MOUNTED proj:<name>`, so the status names the project. It then syncs, moves on, and is told never to mount the space itself.
    - An invalid `project:` value counts as not mounted.
    - `guidance/agent-operating.md:103-114` states the same rule. Two branches are missing there; see the Minor finding.
  - **Read-only instruction: holds.**
    - `poller-prompt.md:305-312` tells the executor the space id and absolute path, that it may read and search the space, and that it must never write, stage, commit or push there. Anything it produces for the space comes back as files, with paths relative to the space root and their full text, for the result's `files:` list and the librarian.
    - mesh-load lines 22-28 and 137-140 make the space read-only to the session.
    - Both `submodule update` commands are described, correctly, as changing only the space checkout and the bus's local .git.
  - **Mount commands: hold.** They are at `skills/mesh-load/SKILL.md:78-87` and in operator manual section 8, and they match each other:
    - `submodule add -b main`, which writes `branch = main`;
    - `config -f .gitmodules submodule.spaces/proj-<name>.ignore all`, where `-f` resolves against the `-C` directory and the subsection has no dots;
    - the one-line registry entry;
    - a pathspec add of .gitmodules, the gitlink and spaces.yaml, then commit and push, each as a literal `git -C` line.

    This matches memory-spaces §4.2 and §8, and the shape of the bus's own existing mount. Access is covered too: read for every pod node, push credentials only on the node that holds the space's librarian role.
- Re-run checks (read-only, from the committed blobs, under /bin/bash 3.2.57):
  - (1) `bash -n` exits 0.
  - (2) `MESH_SCAN_LIST=1` against the live bus prints `product`, `swe-pod` and `spaces/proj-swe-pod`, with rc 0. That is the initialized-space case, with a gitfile `.git`, and the result is the same with only the repo argument or with all arguments. The filter body run on a list that adds an uncloned `spaces/b` drops `spaces/b`. I built no scratch fixture, because review writes nothing; the builder's fixture output agrees.
  - (3) `grep -c 'NOT MOUNTED'` on mesh-load gives 3, with the printed line form at line 70.
- Standard close:
  - The shareability check reports `shareability: 0 hits`.
  - The swe-pod `SPEC.md` and `spec-process.*` diff against the latest Task: T0 commit is 0 bytes.
  - The commit has both trailers and touches exactly the five pathspec files. `git show --check` is clean, and the remote branch head is 859679a.

## Quality
- structure:
  - The scanner change is small and well placed. `update_paths` is the one source for both list mode and the update loop. List mode runs before the role and id arguments are checked and before any write. Each git call reads stdin from /dev/null, so it cannot consume the here-document path list, and the `[ -n "$p" ]` guard stops an empty pathspec from matching every submodule.
  - mesh-load is a clear contract with literal-path git commands and read-only snippets.
  - The poller and agent-operating texts describe the scanner as it now behaves.
- error handling:
  - Scanner failures are swallowed per path and retried on the next cycle, which keeps the existing posture. One bad space no longer stops the other updates.
  - mesh-load and the poller stop or block when the clone or the pull fails, without echoing git output.
  - The registry resolver reads one-line flow entries only. The skill, the operator manual and the bus registry all use that form, and a block-style entry fails safe as NOT MOUNTED.
  - The scanner merging into the librarian's working checkout is a design consequence of plan §2.7; see the Minor finding.
- tests:
  - agent-mesh has no unit suite. The builder's checks exercise real behavior:
    - list mode against a fixture, including the gitfile and no-.gitmodules edges;
    - a functional two-pass run on a local bus clone. Red: the old scanner cloned the unloaded space and left it at the gitlink. Green: the new scanner leaves it alone until first need, then follows the tip, and the bus index and tree stay clean;
    - the mesh-load snippets run read-only.
  - Check 1 was already green at base. That is inherent to a syntax check.
- test suggestions: agent-mesh has no unit tests, so no unit test covers any "for the reviewer" part. I checked each part by reading instead:
  - T12.TS1 (poller-prompt.md:197-225, agent-operating.md:103-114): both halves of the mounted test and the invalid-value rule are present in the poller, and agent-operating lacks the invalid-value rule and the clone-failure branch.
  - T12.TS2 (mesh-scan-loop.sh:41-56, :84-106): the `-e` test accepts the gitfile form, the empty-path guard and the stdin redirect are present, and the filter was confirmed by running it.
  - T12.TS3 (SKILL.md:22-28, :92-113, :142-175): there are two `submodule update` commands and no add, commit or push, and Drop rewrites the flag file with `mv`.
  - T12.TS4 (SKILL.md:49-64): the resolver reads one-line flow entries only, as stated, and fails safe on other forms.

## Findings
- Minor agent-mesh/skills/mesh-on/mesh-scan-loop.sh:93 On the librarian's node the scanner runs `submodule update --remote --merge` every cycle in the same space checkout that space-librarian commits, rebases and pushes in, with no coordination and errors swallowed: it can contend for the index lock, make a local merge commit when local main holds an unpushed record and origin has advanced, or leave a conflicted merge behind (STATUS.md is a mutable file) that blocks later filings. This follows plan §2.7 as written and cannot happen in this change (OD3). Record it for the pilot and the whole-change review.
- Minor agent-mesh/INSTALL.md:66 The `pullmesh` alias and the install and troubleshooting steps (lines 51, 66, 83, 202, 220) run `submodule update --init --recursive` over every submodule. On a bus with mounts that clones every mounted space, which goes against clone on first need (memory-spaces §4.3), and the command fails on a node with no read access to some space. Line 207 still describes the developer-mode sync as one `--init --remote --recursive` call. INSTALL.md is in no task's touches, so this is a plan gap outside T12.
- Minor agent-mesh/docs/operator-manual.md:285 Retire says "commit and push as for a mount", but the mount's add line names `spaces/proj-<name>`. After `git rm` that path is in neither the index nor the tree, so reusing the line fails with a pathspec error. Retire should give its own add (`git add -- spaces.yaml`), because `git rm` has already staged .gitmodules and the removal.
- Minor agent-mesh/guidance/agent-operating.md:107 Step 4's project-space summary leaves out two branches that poller step 4b2 has: an invalid `project:` value counts as not mounted, and a failed first-need clone or tip pull also ends the task `blocked`. The two descriptions of one rule therefore differ.

