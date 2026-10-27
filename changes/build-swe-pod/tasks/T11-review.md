---
task: T11
diff: agent-mesh e70dfc2..e70dfc2 (one commit, e70dfc2, on base 8ee5364)
verdict: pass
---

Range: agent-mesh 8ee5364..e70dfc2. One commit carries the trailer `Task: T11`: e70dfc255d09 "Add memory spaces spec, spaces in PROTOCOL, mesh-post project flag". It has the trailers `Change: build-swe-pod` and `Task: T11`, and its subject is one line of plain ASCII. Its parent is 8ee5364, which matches the brief's start pin.

## Spec compliance

- **Touches.** The commit touches exactly the five files the brief lists: `spec/memory-spaces.md` (new), `spec/PROTOCOL.md`, `skills/mesh-post/mesh-post.sh`, `skills/mesh-post/SKILL.md` and `bus-skeleton/spaces.yaml` (new). T9's two files were staged in the shared index during the build, but they are not in e70dfc2.
- **Missing.** Nothing.
  - `spec/memory-spaces.md` restates note-20261027T2142Z-0a31. I diffed it line by line against the note's body. Apart from the declared changes it is verbatim, with sections §1 to §11 kept:
    - the new Status table;
    - the owner handle replaced by `<handle>`;
    - the organization-named lore example replaced by `lore:cfd-group`;
    - the space-path companion and diagram lines dropped;
    - "not yet" markers added;
    - the sentence on an absent registry added, from plan §2.7.
  - The Status table marks as implemented: §4 mounting for project spaces, §5 loading by "load" and by a task's `project:`, and §6.3 the librarian. It marks as not yet: §9 step 2, §9 step 3, the `active:` default, auto-load at session start, and the session-start catalog. This matches the brief.
  - PROTOCOL §3 has the `/spaces.yaml` and `/spaces/<path>/` rows in both the layout and the writer table.
  - PROTOCOL §5 has the optional `project:` line after `timeout_min:` in the example front-matter, plus a Project paragraph that gives the pattern.
  - PROTOCOL §7 has one closing paragraph that points to `spec/memory-spaces.md`.
  - mesh-post has `--project`, as plan §2.7 describes.
  - `bus-skeleton/spaces.yaml` is `spaces: []`, with a comment saying the operator writes it.
- **Extra (minor).**
  - The implemented row also names §8 retire and §9 step 1.
  - §10 gains a lead-in sentence that claims more coverage than the table gives.
- **Misread.** None.
  - PROTOCOL §5 uses the §6 state name `blocked`. This matches T12's BLOCKED rule.
  - The `spaces/<path>/` writer row gives the mount to the operator and the contents to the space's librarian, writing in the space's own repo. This matches memory-spaces §10.1 and plan §2.7.

## Done-when, run by the reviewer

Each run used a fresh `git init` repo with no remote, under a scratch directory in /tmp. `rev-parse` confirmed the scratch directory is outside every repo. Each run passed an explicit `--repo` and `--from op-test`, under /bin/bash 3.2.57. The script ran was the committed blob, identical to the worktree copy.

1. `bash -n` exits 0.
2. `--dry-run --project proj:demo`: rc 0. The line right after `timeout_min: 120` is `project: proj:demo`.
3. `--project demo`: rc 1. stderr is exactly `mesh-post: invalid --project value: demo`. 0 files were written.
4. Without `--project`: 0 `project:` lines.
5. Standard close:
   - `share-check.py --task T11` prints `shareability: 0 hits` (exit 0). The scan included the staged T9 lines.
   - In swe-pod, `git diff 854e87c -- SPEC.md spec-process.*` (the latest `Task: T0` commit) is 0 lines.
   - The commit was made by pathspec, has both trailers, and is pushed: `ls-remote` shows `change/build-swe-pod` at e70dfc2.
   - This review has no open Critical or Important finding.

Extra checks:

- An invalid value is refused before the repo check. With `--repo` set to a nonexistent path, placed either before or after `--project`, the error is the invalid-project error, not the repo error.
- `--project` with no value, and `--project --repo`, are both refused with rc 1.
- Under LC_ALL=en_US.UTF-8, these are refused: empty, `proj:`, `proj:Demo`, `proj:-x`, `proj:a_b`, `proj:a/b`, `PROJ:a`, a value with an embedded space, a value with an embedded line break, `proj:é`, `proj:a.`, a leading space, a trailing space, and `xproj:a`.
- These are accepted: `proj:abc-1`, `proj:0x`, `proj:a-`, `proj:a--b`, `proj:9`. All of these match `^proj:[a-z0-9][a-z0-9-]*$`.
- Fan-out to three targets: every message has the `project:` line directly after `timeout_min:`.

## Quality

- The script change is small and portable to bash 3.2. `valid_project()` uses explicit character lists, so the match does not depend on the locale.
- The value is checked in the argument loop, before the repo check. The line is emitted only when the flag is set.
- SKILL.md documents the flag in the "you supply" list, the front-matter bullet, the flag list and Notes.
- `git show --check` is clean.
- The PROTOCOL citations the new text relies on all resolve: §1.7, the §12 rule that nothing references upward, §3.3 layout bump, and §6 `blocked`.
- The report's line references are accurate.

## Findings

- Minor agent-mesh/spec/memory-spaces.md:386 The added §10 lead-in says the Status table shows which parts this version has, but §10 items 3 (PROTOCOL §12 restated as the visibility rule), 5 (header profiles documented), 7 (git gate) and 8 (operator-guidance exception for nested repos) have no Status row, either implemented or not yet.
- Minor agent-mesh/spec/memory-spaces.md:31 The implemented row adds §8 retire (unmount) and §9 step 1 to the brief's list and cites docs/operator-manual.md for them. T12's operator-manual step covers mounting and access only, so nothing is planned to document retire there.
- Minor agent-mesh/spec/memory-spaces.md:32 The Status rows cite skills/mesh-load/, skills/space-librarian/, skills/mesh-on/poller-prompt.md, skills/mesh-on/mesh-scan-loop.sh, guidance/agent-operating.md and docs/operator-manual.md as implemented. None of that content exists at e70dfc2. The brief directs these forward references to T10 and T12; T30, T32 or T19 should confirm each becomes true.
- Minor agent-mesh/spec/PROTOCOL.md:470 The §6 state machine still notes blocked as (missing credential or dependency), and §8 step 4 (line 957) checks only credentials. Neither mentions the new §5 reason for blocked, a space that is not mounted.
- Minor agent-mesh/spec/PROTOCOL.md:416 The new task field project: proj:<name> has the same name as the existing §7 workflows-record project: header (line 691, a folder handle, not in proj: form). No sentence tells the two apart. The builder flagged this.

