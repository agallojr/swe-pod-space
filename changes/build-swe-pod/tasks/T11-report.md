# T11 report

- change: build-swe-pod
- task: T11 (M2a: spaces in the protocol, `project:` field)
- role: build
- repo: agent-mesh
- commit: e70dfc2 on `change/build-swe-pod`, trailers `Change: build-swe-pod`
  and `Task: T11`, pushed (base 8ee5364)

## Status

DONE

## What I did

- **spec/memory-spaces.md** (new). Restates the memory-spaces design note,
  revision 2, with the same section numbers (§1 to §11), so the plan's and
  PROTOCOL's citations resolve. A `## Status` table comes before §1:
  - implemented: §4 mounting for project spaces (with §8 mount and retire, and
    §9 step 1), clone on first need and tip following, §5 loading by "load" /
    "drop" and by a task's `project:` field, and §6.3 the librarian;
  - not yet: §9 step 2 (shared lore), §9 step 3 (split `memory/`), the
    `active:` default, auto-load at session start, and the session-start
    catalog.

  §5, §4.3 and §9 also say "not yet" where those parts come up. The changes
  from the note: the owner handle is now `<handle>`, the organization-named
  shared-lore example is now `lore:cfd-group`, and space-record paths and
  cross-repo pointers are gone. §4.3 also says what an absent registry means,
  from plan §2.7.
- **spec/PROTOCOL.md.**
  - §3 layout: rows for `/spaces.yaml` (optional, absent means nothing is
    mounted, no layout bump, the operator writes it) and `/spaces/<path>/`.
  - §3.1 writer table: `spaces.yaml` goes to the operator. For
    `spaces/<path>/`, the mount (`.gitmodules` entry and gitlink) goes to the
    operator, and the contents go to the space's librarian, which writes in
    the space's own repo.
  - §5: the example front-matter gets an optional `project:` line after
    `timeout_min:`. A new **Project:** paragraph covers:
    - the `^proj:[a-z0-9][a-z0-9-]*$` pattern;
    - the claiming node loading the space for the executor;
    - `blocked` when the space is not mounted;
    - the executor reading but never committing;
    - `mesh-post --project`.
  - §7: a closing **Memory spaces** paragraph. It explains that the §7
    categories govern `memory/` while a space declares its own, and points to
    `spec/memory-spaces.md`.
- **skills/mesh-post/mesh-post.sh.** Adds `--project`. The argument loop
  checks the value before any repo check, using `valid_project()`, which does
  case matching against explicit character lists. It does not use ranges, so
  the result does not depend on the locale, and it runs on bash 3.2. An
  invalid value (or a missing one) exits 1 with
  `mesh-post: invalid --project value: <value>`. A valid value is written as
  the line after `timeout_min:` in every target's message. Without the flag,
  no line is written. The usage header documents the flag.
- **skills/mesh-post/SKILL.md.** Adds the flag in the "you supply" list, the
  front-matter bullet and the flag list, plus a Notes entry: the pattern, what
  it loads, the error, and that posting does not check whether the space is
  mounted.
- **bus-skeleton/spaces.yaml** (new). `spaces: []`, with a comment saying the
  operator writes it, how to mount a space, and the entry shape with
  placeholders. The installer copies `bus-skeleton/.` wholesale, so new buses
  get the file.

## Files

- `spec/memory-spaces.md` (create)
- `spec/PROTOCOL.md` (change)
- `skills/mesh-post/mesh-post.sh` (change)
- `skills/mesh-post/SKILL.md` (change)
- `bus-skeleton/spaces.yaml` (create)

## Test output

The checks ran as one throwaway bash script under bash 3.2. Each run used a
fresh `git init` repo with no remote, in a scratch directory outside every
repo (verified with `rev-parse`), passed as an explicit `--repo` with
`--from op-test`. Checks 1 to 4 are the done-when checks. Checks c1 to c4 are
supporting content greps for the other touched files. The scratch directory
was removed afterwards.

Red, before the change:

```
PASS 1 bash -n exit=0
  rc=1 line-after-timeout_min=[]
FAIL 2 project line after timeout_min
  | mesh-post: unknown arg: --project
  rc=1 stderr=[mesh-post: unknown arg: --project] files-written=0
FAIL 3 invalid --project rejected
  rc=0 message-file=yes project-lines=0
PASS 4 no project line without flag
FAIL c1 spec/memory-spaces.md exists
FAIL c2 skeleton spaces: []
FAIL c3 PROTOCOL spaces rows, project field, pointer
FAIL c4 SKILL.md documents --project
checks: 2 pass, 6 fail
```

Checks 1 and 4 already passed before the change: they guard behavior the
script already had (it parses, and it writes no `project:` line). The checks
that test the new content (2, 3, c1 to c4) failed.

Green, after the change:

```
PASS 1 bash -n exit=0
  rc=0 line-after-timeout_min=[project: proj:demo]
PASS 2 project line after timeout_min
  rc=1 stderr=[mesh-post: invalid --project value: demo] files-written=0
PASS 3 invalid --project rejected
  rc=0 message-file=yes project-lines=0
PASS 4 no project line without flag
PASS c1 spec/memory-spaces.md exists
PASS c2 skeleton spaces: []
PASS c3 PROTOCOL spaces rows, project field, pointer
PASS c4 SKILL.md documents --project
checks: 8 pass, 0 fail
```

Extra edge runs (bash 3.2, two `--to` targets, `--dry-run`):

- accepted, with both messages carrying `project:` right after
  `timeout_min:`: `proj:abc-1`, `proj:0x`;
- refused, exit 1, the fixed message, no files written: empty, `proj:`,
  `proj:Demo`, `proj:-x`, `proj:a_b`, `proj:a/b`, `PROJ:a`, a value with an
  embedded line break, a value with a space, and `--project` with no value.

Standard close:

- shareability, before the commit (staged): `shareability: 0 hits`
- shareability, after the commit: `shareability: 0 hits`
- `git diff <latest Task: T0 commit> -- SPEC.md spec-process.*` in swe-pod:
  empty (0 lines)
- committed by pathspec, with both trailers, and pushed; the remote branch
  tip is e70dfc2
- review: pending (§7)

## Concerns

- The status table in `spec/memory-spaces.md` points forward. It names
  products that T10 and T12 deliver as implemented: `skills/mesh-load/`,
  `skills/space-librarian/`, `skills/mesh-on/poller-prompt.md`,
  `skills/mesh-on/mesh-scan-loop.sh`, the mounting section of
  `docs/operator-manual.md`, and `guidance/agent-operating.md`. At e70dfc2,
  only the `mesh-post` part is true. The rest becomes true once T10 and T12
  land. The paths are code spans, not links, so no link check breaks.
- PROTOCOL §5 states the poller behavior that T12 implements: `blocked` when
  the space is not mounted, and an executor that reads the space but never
  commits to it. I used the §6 state name `blocked` (lowercase). T12's poller
  text should match it.
- PROTOCOL §7's `workflows` record already has a `project:` header field
  (a folder handle, not in `proj:` form). It is a different field in a
  different file kind from the new task field, but the two share a name.
- `--project` works with any `--type`. Plan §2.7 does not limit it to
  `task.request`, so I did not either.
- The note's diagram (`assets/memory-spaces/spaces.*`) was not carried: it is
  outside this task's touches, and `spec/memory-spaces.md` has no image.
- During this run, another builder's staged files (the T9 pair) were in the
  shared index. I committed by pathspec only, so they stayed staged and out
  of e70dfc2. The shareability scans of staged changes included their lines,
  and there were still 0 hits.

## Test suggestions

### T11.TS1 Project value pattern edges
- for the tester: Post with `--project` set to each of these, and check that
  every one is refused with the fixed invalid-value error, leaves no message,
  and exits 1:
  - values that differ from `^proj:[a-z0-9][a-z0-9-]*$` only at an edge: an
    uppercase letter, a leading hyphen after the prefix, an underscore, a
    slash, an embedded space or line break;
  - the prefix alone, an empty value, and the flag with no value.

  Values that do match, including ones with a digit first or a hyphen later,
  must be accepted.
- for the reviewer: `skills/mesh-post/mesh-post.sh` `valid_project()` (line 47)
  and the `--project)` arm of the argument loop (line 72).

### T11.TS2 Invalid value is refused before the repo is checked
- for the tester: Post with an invalid project value and a `--repo` that is
  not a git repo. The error must be the invalid-project error, not the
  repo error (§2.7: "inside its argument loop, before any repo check").
- for the reviewer: the argument loop (line 72) runs before the repo check
  `[ -d "$REPO/.git" ]` (line 101) in `skills/mesh-post/mesh-post.sh`.

### T11.TS3 Fan-out keeps the field on every message
- for the tester: Post one task to two or more targets with a valid project.
  Every message written must carry the `project:` line directly after
  `timeout_min:`. The same post without the flag must carry no `project:`
  line in any message.
- for the reviewer: the per-target front-matter block in
  `skills/mesh-post/mesh-post.sh` (the `if [ -n "$PROJECT" ]` after the
  `timeout_min` echo).

### T11.TS4 Locale independence
- for the tester: Run the pattern-edge case with an uppercase letter under a
  non-C UTF-8 locale. It must still be refused.
- for the reviewer: `valid_project()` uses explicit character lists, not
  ranges.

### T11.TS5 New bus carries an empty registry
- for the tester: Scaffold a new bus from the product skeleton. It must
  contain `spaces.yaml` with an empty `spaces` list and a comment that the
  operator writes it. With no registry file at all, the protocol must still
  read as "no spaces mounted".
- for the reviewer: `bus-skeleton/spaces.yaml`; the wholesale copy in
  `install/install.sh` (the `cp -R .../bus-skeleton/.` line); PROTOCOL §3 row
  `/spaces.yaml` (line 90).

### T11.TS6 Status table matches the M2 scope
- for the tester: In `spec/memory-spaces.md`, the status table must mark these
  as implemented: §4 mounting for project spaces, §5 loading by "load" and by
  a task's `project`, and §6.3 the librarian. It must mark these as not yet:
  §9 steps 2 and 3, the `active:` default, auto-load at session start, and
  the session-start catalog. No other part may be marked implemented.
- for the reviewer: `spec/memory-spaces.md` `## Status` (line 24), and the
  "not yet" markers in §4.3 (line 215), §5 (line 242) and §9 (line 366).

### T11.TS7 PROTOCOL rows and pointer
- for the tester: PROTOCOL §3 has layout rows and writer-table rows for
  `spaces.yaml` and `spaces/<path>/`, with the operator writing the registry
  and the mount, and the space's librarian writing its contents in the
  space's own repo. §5 documents the optional `project:` field with its
  pattern. §7 has one paragraph pointing to `spec/memory-spaces.md`.
- for the reviewer: `spec/PROTOCOL.md` lines 90 to 98 (layout), 135 to 136
  (writer table), 381 and 416 (§5), 877 (§7).
