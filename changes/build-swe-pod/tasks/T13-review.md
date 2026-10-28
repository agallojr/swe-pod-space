---
task: T13
diff: agent-mesh 859679a..c6aa593
verdict: pass
---

# T13 review

One commit, c6aa593, found by the trailer `Task: T13` on
`origin/change/build-swe-pod`. It carries the trailers `Change: build-swe-pod`
and `Task: T13` and touches only the three files in the brief:
`spec/PROTOCOL.md`, `skills/mesh-on/poller-prompt.md` and
`guidance/agent-operating.md` (135 lines added, 34 removed). The remote
branch tip is c6aa593.

## Spec compliance

Serves R8 and R17, through spec §14 M3 and contract §2.7.

**Missing:** none. Each §2.7 result-files clause is in PROTOCOL §5.1
(spec/PROTOCOL.md:440-475):
- `files:` is a list of `{path, sha256}` entries; `path` is space-relative
  for a task with `project:`, and `sha256` is 64 lowercase hex digits.
- Each body is at `outbox/<agent-id>/<task-id>-files/<path>`.
- Files are text only, at most 1048576 bytes each.
- The folder is swept with its task, and §9 names it.

The poller and agent-operating steps are present too:
- **Poller.** The fixed results phrase stands on its own line at
  poller-prompt.md:337 and matches the whole line exactly. "never payloads"
  now carries an exception for requested files only (:335-336). Step 4e
  (:238-269) writes the files and the `files:` list.
- **agent-operating.** Step 6 (:126-137) says the same in digest form, and
  the archiver bullet (:223-233) sweeps the folder with its task.
- **`artifacts`.** The status-file rule is unchanged: PROTOCOL:518-519 and
  agent-operating:178-179. No removed line in the diff names `artifacts`
  (0 lines).

**Extra, all accepted:**
- **Staging directory.** A per-task `mktemp -d` directory outside the bus
  (poller-prompt.md:342-346), and T12's project-executor lines rewritten to
  point at it (:348-355). This is a sound reading of "the poller writes the
  files". Bodies of up to 1048576 bytes stay out of the poller's context,
  they are copied byte for byte, and the hash is taken from the copy.
- **Paths for tasks without `project:`.** The path is "the path the task
  gives". This agrees with the fixed phrase, which applies to every task.
- **Rules beyond §2.7.** A `.git` segment is refused, a link anywhere in the
  staging tree blocks the task's files, a failing file is left out and
  named in the body, and an empty list gives no key. None conflicts with
  §2.7.
- **Consistency lines in PROTOCOL §2, §3, §5 and §8.** They are needed:
  without them, §2 would still say per-task-output roles write only the
  result file.
- **Files on `failed`.** Publishing at `failed` is right: a builder's
  BLOCKED report must still arrive.

**Misread:** none.

**Rules the done-when leaves to review (item 3):**
- **Sweep-unit sentences: hold.** Read in PROTOCOL §9: the unit at
  :1098-1110, the retention row at :1085 and the read-only boundary check at
  :1114-1118. Also read: the poller's archiver duty (:377-384) and the
  agent-operating archiver bullet (:223-233). All three put the message, the
  terminal status, the result and the `-files/` folder into one commit, and
  all three collect orphan folders. Two wording gaps are Minor findings: the
  poller drops "or gone", and PROTOCOL gives no archive month for an orphan
  whose result is gone.
- **Terminal write step: holds.** Poller step 4e runs in this order:
  1. the link guard over the whole staging tree, before any copy;
  2. the path rules, then a regular-file check;
  3. size at most 1048576 bytes (the bound is inclusive), valid UTF-8 and no
     NUL byte;
  4. a copy into the outbox, with `sha256` taken from the copy;
  5. `files:` in the executor's order, with no key when there are none;
  6. the staging directory deleted, then one sync carrying status, result
     and files.

  The §8 loop line (PROTOCOL:1000-1002) and agent-operating step 6 match it.
  The staging directory is made only at dispatch (step 4d), so the `blocked`
  exits in 4b and 4b2 come before it. The poller has no timeout path, so 4e
  is the only terminal path after the directory exists.

**Re-run checks (none changes a file):**
- **Done-when 1.** PROTOCOL at c6aa593 has `files:` on 4 lines, `-files/` on
  9 lines and `1048576` on 1 line. At 859679a, 0 lines match any of the
  three.
- **Done-when 2.** The phrase matches the whole of poller line 337 at
  c6aa593 and is absent at 859679a. The old wording ("never payloads)" with
  no exception, and "its full text") is gone: 0 lines.
- **Step 4e commands.** Run on existing files with the macOS default bash:
  - a UTF-8 text file: `iconv` exit 0, `tr`/`cmp` exit 0, and a 64-hex
    hash;
  - a binary file: exit 1 from both checks;
  - an invalid byte on stdin: `iconv` exit 1.

  Plain `tr` under the UTF-8 locale fails on binary input, which confirms
  that `LC_ALL=C` is needed. `find -type l` on the macOS temp root prints
  nothing, because the symlinked `/var` is only an ancestor of the root.
- **I7 check block.** Run with the tooling Python in `-I` mode on the clean
  checkout at c6aa593: I7.1 to I7.7 pass, exit 0.
- **Standard close.**
  - The shareability check re-run gives `shareability: 0 hits`.
  - In swe-pod, `git diff 74d23f1 -- SPEC.md spec-process.*` gives 0 lines;
    74d23f1 is the latest `Task: T0` commit.
  - The commit, its trailers and the push are confirmed as above.

## Quality

**Structure.** The split is clear. PROTOCOL §5.1 is the normative contract,
poller step 4e is the operative procedure, and agent-operating step 6 is the
digest.

**Error handling.** A file that fails a check is refused on its own and named
in the body. A link anywhere in the tree blocks the task's files. The staging
directory is removed on the one terminal path that follows its creation.

**Gaps (all Minor):**
- The path rule allows characters that break the unquoted YAML flow entry.
- The `.git` refusal is exact, so `.gitignore`, `.gitattributes` and `.GIT`
  pass.
- The link guard does not catch hard links.
- The agent-operating digest states the link rule per file, which is weaker
  than the poller's whole-tree guard.
- Two orphan-sweep wording gaps (see the sweep-unit rule above).

**Tests.** agent-mesh has no unit suite, and the deliverables are Markdown,
so no unit tests apply. The builder kept its checks as scratch scripts,
following the base rule against leaving test files. Besides the greps, those
checks included a functional fixture run of the step 4e commands, which tests
the commands' behavior, not only their wording. My re-runs agree with the
reported red and green output.

**"For the reviewer" parts:**
- **TS1:** holds at poller-prompt.md:244-261. The checks come before the
  copy, the hash is taken from the copy, the size bound is inclusive, and
  `<file>` is quoted.
- **TS2:** holds at :239-244 and :342-346. There is one `find` over the
  whole tree before any copy; staging is outside the bus and every space;
  it is deleted on the only terminal path after it is made. The hard-link
  gap is noted below.
- **TS3:** the three statements agree on the unit and on one commit, and
  differ only in the orphan wording noted below.

## Findings

- Minor agent-mesh/skills/mesh-on/poller-prompt.md:266 `files:` entries are unquoted YAML flow mappings, and neither this step nor PROTOCOL §5.1 (spec/PROTOCOL.md:457) limits the characters a path may hold. A path with `,`, `{`, `}`, `[`, `]`, `: ` or ` #` gives an entry that a parser splits or truncates. Quote the path, or restrict it to a safe set.
- Minor agent-mesh/skills/mesh-on/poller-prompt.md:245 the segment rule refuses only an exact `.git`, so `.gitignore`, `.gitattributes` or `.GIT` under `<id>-files/` reach the bus. A `.gitignore` there can keep listed bodies out of the sync's `add -A` while `files:` still lists them. The same rule is at spec/PROTOCOL.md:460.
- Minor agent-mesh/skills/mesh-on/poller-prompt.md:240 the link guard is only `find -type l`. A hard link to a node file on the same volume is a regular file and passes it, which the purpose stated at :241-243 (keep a node file such as the credentials file out of the outbox) does not allow for. A link-count check would close it.
- Minor agent-mesh/guidance/agent-operating.md:129 step 6 gives the link rule per file ("a regular file, never a symlink"), which is weaker than the poller's whole-tree guard: a staged symlinked parent directory passes a per-file check.
- Minor agent-mesh/skills/mesh-on/poller-prompt.md:382 the archiver duty collects a `-files/` folder "whose result is" [already archived] and drops the "or gone" of PROTOCOL §9 (spec/PROTOCOL.md:1107). So the three sweep statements differ on orphans whose result was deleted.
- Minor agent-mesh/spec/PROTOCOL.md:1102 "goes into the same `_archive/YYYY-MM/` as its result" gives no month for an orphan folder whose result is gone, though the orphan rule at :1107 also sweeps that folder.
- Minor agent-mesh/docs/operator-manual.md:46 (outside T13's touches) still says each `swe.*` holder "writes only its own" result file, which PROTOCOL §2 (spec/PROTOCOL.md:49) now qualifies. The results summary in skills/mesh-check/SKILL.md and the Status table in spec/memory-spaces.md also lack result files. These are plan gaps for the lead, as the report's Concerns say.

