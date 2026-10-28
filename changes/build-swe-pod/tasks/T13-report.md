# T13 report

- change: build-swe-pod
- task: T13 (M3: results that carry files)
- role: build
- repo: agent-mesh
- commit: c6aa593 on `change/build-swe-pod`, trailers `Change: build-swe-pod`
  and `Task: T13`, pushed (base 859679a)

## Status

DONE

Done-when checks 1 and 2 pass, and so do the checkable items of the standard
close. Done-when 3 (the sweep-unit sentences and the terminal write step) and
the review item of the standard close are left to the review (§7).

## What I did

- Wrote the done-when checks first as a shell script in a scratch directory
  outside the code repo, and ran it at base: 11 of 12 checks failed on the
  missing content. Check s7 passed at base, as expected, because it checks
  that the status file's `artifacts` rule stays unchanged. I also wrote a
  functional check. It takes the file-check commands from the poller prompt
  itself and runs them on fixtures, and it failed at base because the
  commands were absent.
- `spec/PROTOCOL.md`:
  - New §5.1 "Result files", following §2.7.
    - `files:` is a front-matter key of one-line flow entries
      `{path, sha256}`.
    - `path` is relative to the space root for a task with `project:`, and
      is otherwise the path the task gives. It has no empty, `.`, `..` or
      `.git` segment and appears once.
    - `sha256` is 64 lowercase hex digits, over the file's bytes.
    - Each body sits at `outbox/<agent-id>/<task-id>-files/<path>` and is
      committed with the result.
    - Files are text only (UTF-8 with no NUL byte), at most 1048576 bytes
      each. A file that breaks a rule is neither written nor listed, and the
      result body names it.
    - With no files, there is no `files:` key and no folder.
    - The folder is swept with its task.
    - The requester checks each body against its `sha256`, and for a project
      task the space's librarian files the bodies.
    - It states that the status file's `artifacts` is unchanged.
  - §9: the sweep unit adds the `<id>-files/` folder. The folder keeps its
    name and goes into the same `_archive/YYYY-MM/` as its result. Orphan
    collection takes in a `-files/` folder whose result is already archived
    or gone. The retention table row and the read-only boundary check name
    the folder too.
  - Consistency lines (see Concerns): the per-task-output roles line in §2,
    the `outbox/` line in the §3 layout, a §5.1 pointer in §5's `project:`
    paragraph, and the terminal step of the §8 loop.
- `skills/mesh-on/poller-prompt.md`:
  - Executor instruction. "never payloads" is now "never payloads except the
    files the task asks for", followed by the fixed results phrase on its own
    line, exactly. The executor writes each requested file to
    `«STAGING»/<rel>` and lists each `<rel>` under `files:`.
  - New "Staging directory" paragraph. Before it spawns the executor, the
    poller makes a fresh `mktemp -d` directory outside the bus and outside
    every space checkout.
  - The project-space executor lines from T12 now point to the staging
    directory instead of "its full text".
  - Step 4e, at the terminal step: the poller publishes the files before
    the sync.
    - First, `find «STAGING» -type l` must print nothing.
    - For each file, the path rules are checked, the file must be a regular
      file, and `wc -c`, `iconv` and `LC_ALL=C tr`/`cmp` check size, UTF-8
      and NUL bytes.
    - A file that passes is copied to `«REPO»/outbox/«AGENT_ID»/<id>-files/<rel>`,
      and `shasum -a 256` (or `sha256sum`) runs on the copy.
    - A file that fails is named in the result body.
    - The poller writes `files:` into the result front-matter, one line per
      file, or no key when there are no files. It deletes the staging
      directory. One sync carries the status, the result and the files.
  - Archiver duty: the unit and the orphan collection take in the `-files/`
    folder.
- `guidance/agent-operating.md`:
  - Step 6 says the same in digest form: pointers, except the requested
    files; the checks, symlinks included; the `-files/` path; the `files:`
    entries; one sync.
  - The archiver bullet sweeps the folder with its task, collects orphan
    folders, and its self-check names the folder.
  - The "Credentials" section's `artifacts` rule is unchanged.
- Ran the checks again (all green), and also project-level test I7, which
  reads only the deliverables, against base and the worktree. Staged by
  pathspec, ran the shareability check, committed by pathspec with the
  trailers, and ran the shareability check again. The fetch showed the remote
  head already in my branch (merge-base exit 0), so I pushed without a rebase.

## Files

- `spec/PROTOCOL.md` (agent-mesh): changed. New §5.1; the §9 sweep unit,
  orphans, retention row and boundary check; consistency lines in §2, §3,
  §5 and §8.
- `skills/mesh-on/poller-prompt.md` (agent-mesh): changed. Executor
  instruction with the fixed phrase, the staging directory, the project
  executor lines, the step 4e publish step, the archiver duty.
- `guidance/agent-operating.md` (agent-mesh): changed. Step 6 and the
  archiver bullet.
- Commit range: `agent-mesh 859679a..c6aa593`, one commit, c6aa593, 3 files,
  +135/-34 lines, pushed to `change/build-swe-pod`.
- `changes/build-swe-pod/tasks/T13-report.md` (space): this report, for the
  librarian to file.

## Test output

Checkout and scratch paths are replaced with placeholders. Every run used
`/bin/bash` 3.2.57 (the macOS default), on macos-laptop.

### Done-when checks and supporting checks (`checks.sh`)

dw1 and dw2 are done-when (1) and (2). s1 to s6 grep inside the section that
review item (3) names: §9 of PROTOCOL, poller step 4e to 4e2, the poller
archiver duty, agent-operating step 6 to 6a, and the agent-operating archiver
bullet. s7 checks that no removed line of the diff from 859679a names
`artifacts`. s8 checks that the old executor wording is gone: "never
payloads)" with no exception, and "its full text".

- command: `/bin/bash checks.sh <checkout>`
- red (base 859679a):

  ```
  FAIL dw1 PROTOCOL has files:
  FAIL dw1 PROTOCOL has -files/
  FAIL dw1 PROTOCOL has 1048576
  FAIL dw2 poller phrase
  FAIL s1 PROTOCOL 9 sweep names -files/
  FAIL s2 poller terminal step writes -files/
  FAIL s3 poller terminal step writes files:
  FAIL s4 poller archiver sweeps -files/
  FAIL s5 operating step 6 has -files/
  FAIL s6 operating archiver sweeps -files/
  PASS s7 artifacts rule lines unchanged
  FAIL s8 old executor wording replaced
  checks: 11 fail
  exit=11
  ```

- green (worktree, then the blobs of `origin/change/build-swe-pod` at c6aa593):

  ```
  PASS dw1 PROTOCOL has files:
  PASS dw1 PROTOCOL has -files/
  PASS dw1 PROTOCOL has 1048576
  PASS dw2 poller phrase (1 line)
  PASS s1 PROTOCOL 9 sweep names -files/
  PASS s2 poller terminal step writes -files/
  PASS s3 poller terminal step writes files:
  PASS s4 poller archiver sweeps -files/
  PASS s5 operating step 6 has -files/
  PASS s6 operating archiver sweeps -files/
  PASS s7 artifacts rule lines unchanged
  PASS s8 old executor wording replaced
  checks: 0 fail
  exit=0
  ```

  On the pushed blobs: `checks: 0 fail`. s7 was rerun on the commit itself
  as `git diff 859679a c6aa593 -- <the three files> | grep -cE
  '^-[^-].*artifacts'`, which gave `removed artifacts lines: 0`.

### Functional check of the step 4e commands (`fixtures.sh`)

The script reads the `wc -c`, `iconv`, `LC_ALL=C tr` and `shasum` lines, and
the `find «STAGING» -type l` line, from the poller prompt itself. It runs them
on these fixtures:

- `good.md`: UTF-8 text with a non-ASCII character;
- `max.md`: exactly 1048576 bytes;
- `over.md`: 1048577 bytes;
- `badutf.md`: invalid UTF-8 bytes;
- `nul.md`: a NUL byte;
- two staging trees, one clean and one with a symlink.

Each file's verdict must match its fixture, and the hash must be 64 lowercase
hex digits equal to Python's `hashlib.sha256`. While building it I found that
macOS `tr` fails with "Illegal byte sequence" on invalid UTF-8 under a UTF-8
locale, so the prompt line uses `LC_ALL=C tr`.

- command: `/bin/bash fixtures.sh <checkout> <fixtures>`
- red (the poller prompt blob at 859679a):

  ```
  FAIL command missing from prompt
  FAIL command missing from prompt
  FAIL command missing from prompt
  FAIL command missing from prompt
  fixtures: 4 fail
  exit=4
  ```

- green (worktree; the pushed blobs gave `fixtures: 0 fail` too):

  ```
  size: wc -c < <file>
  utf8: iconv -f UTF-8 -t UTF-8 <file> > /dev/null
  nul:  LC_ALL=C tr -d '\000' < <file> | cmp -s - <file>
  sha:  shasum -a 256 <file>
  PASS good.md -> ok
  PASS max.md -> ok
  PASS over.md -> size
  PASS badutf.md -> text
  PASS nul.md -> text
  PASS sha256 is 64 lowercase hex and matches hashlib
  PASS symlink guard: clean tree 0 links, linked tree 1 link
  fixtures: 0 fail
  exit=0
  ```

  Only macOS was run. GNU `iconv`, `tr`, `cmp` and `sha256sum` behave the
  same on these inputs, but no linux-server run was made.

### Project-level test I7, check only (read-only, no agent)

- command: the `python check` block of `test_I7_agent_mesh_documents.md`,
  with `EXPORT_AGENT_MESH` set to a `git archive` of 859679a, then to the
  worktree; tooling venv Python run with `-I`; about 1 s each
- red (859679a): `I7.2 fail result files: missing files: list, -files/
  folder, 1048576-byte limit, sweep in section 9`, exit 1. I7.1 and I7.3 to
  I7.7 passed.
- green (worktree): `I7.2 pass result files: documented, and swept in
  section 9`, and I7.1 to I7.7 all pass, exit 0.

### Standard close

- Shareability check (§2.8), after staging: `shareability: 0 hits`. After
  committing: `shareability: 0 hits`.
- `git diff 74d23f1 -- SPEC.md spec-process.*` in swe-pod: 0 lines. 74d23f1
  is the latest `Task: T0` commit.
- Commit and push: `git fetch origin change/build-swe-pod`, then
  `merge-base --is-ancestor origin/change/build-swe-pod HEAD` exited 0, so no
  rebase. Push output: `859679a..c6aa593  change/build-swe-pod ->
  change/build-swe-pod`. `ls-remote` shows `c6aa593`.
- Review (§7): pending.

Unit suite: agent-mesh has no unit suite. It has no test files and no test
runner, and its one `package.json`, under `services/librarian-ingress/`, has
no test script. So there is no `unit <p>/<n>` line.

## Concerns

- **Staging directory instead of "full text".** T12's executor lines had
  the executor return each file's full text to the poller. At up to
  1048576 bytes a file, that would pass megabytes through the poller's
  context, which the prompt says to keep bounded. It would also make the
  poller retype every byte before hashing. Instead, the executor now writes
  the files into a per-task `mktemp -d` directory, and the poller checks and
  copies them byte for byte. The reviewer should confirm this reading of "At
  the terminal step, the poller writes the files".
- **Rules beyond §2.7.** These are additions that §2.7 does not state:
  - a `.git` path segment is refused, because git would reject the path at
    the sync;
  - a symlink anywhere in the staging tree blocks all of that task's files,
    because `cp` would follow it, for instance to the node's credentials
    file;
  - a file that breaks a rule is left out and named in the result body;
  - an empty file list gives no `files:` key.

  The reviewer may ask for any of them to be dropped.
- **Consistency edits outside the two named PROTOCOL sections.** These are
  in §2 (the per-task-output roles line said such roles write "only" the
  result file), §3 (the `outbox/` layout line), §5 (a pointer to §5.1) and
  §8 (the loop's terminal step). The poller's archiver duty and the
  agent-operating archiver self-check name the folder too, so that the
  sweep the archiver actually runs matches §9.
- **Files on `failed`.** Step 4e publishes the requested files at either
  terminal state, `done` or `failed`. The brief does not say otherwise.
- **Outside my touches.** These are not updated, and are plan gaps if the
  lead wants them:
  - `skills/mesh-check/SKILL.md` (its task-results summary) and
    `docs/operator-manual.md` ("Find a result") do not mention `files:`;
  - the `spec/memory-spaces.md` Status table has no row for result files.

  T12's review finding at `guidance/agent-operating.md:107` (step 4's
  summary omits two branches of poller step 4b2) is still open in that
  file. It is not in T13's steps, so I left it.
- **Pre-M3 nodes.** A node whose product predates c6aa593 ignores `files:`.
  The plan's T19b already has its executor write the bodies itself.

## Test suggestions

### T13.TS1 Result files that break a rule are not published

- for the tester: R17 and spec §14 M3 (contract §2.7: text only, at most
  1048576 bytes each, space-relative paths). Use a project task that asks
  for several files: one small text file; one just over the size limit;
  one holding a NUL byte or invalid UTF-8; one whose path climbs out of the
  space with `..`. A second task asks for no files. Expected failure: the
  result's `files:` lists, or the outbox's `-files/` folder holds, a file
  that breaks a rule. Other failures: a listed `sha256` does not match the
  body in the outbox; the result of the second task has an empty `files:`
  key or an empty folder.
- for the reviewer: agent-mesh/skills/mesh-on/poller-prompt.md:238-269. The
  order of the checks and the copy, and that the hash is taken from the
  copy. The size bound is inclusive. Quoting `<file>` matters for paths with
  spaces.

### T13.TS2 A link in the staged files cannot publish a node file

- for the tester: R16 and PROTOCOL §1 invariant 4 (no credential value in
  the bus), with M3. Use a project task whose executor, among the files it
  returns, stages a symbolic link to a file outside its staging directory
  (a stand-in for the node's credentials file), under a requested path.
  Expected failure: the linked file's content appears anywhere under the
  outbox, or the result lists that path under `files:`.
- for the reviewer: agent-mesh/skills/mesh-on/poller-prompt.md:239-244 and
  :342-346. The guard is one `find -type l` over the whole staging tree
  before any copy. Check that the staging directory is outside the bus and
  every space, and is deleted on every terminal path.

### T13.TS3 The archiver sweeps the files folder with its task

- for the tester: R17 and PROTOCOL §9 (contract §2.7: "swept with their
  task"). Use a bus holding an aged terminal task whose result has a
  `-files/` folder, plus an orphan `-files/` folder whose result is already
  in `_archive/`. Run one archiver sweep. Expected failure: the folder stays
  in `outbox/`; or it is moved in a different commit from its message,
  status and result; or it lands somewhere other than its result's
  `_archive/YYYY-MM/`.
- for the reviewer: agent-mesh/spec/PROTOCOL.md:1098-1118,
  agent-mesh/skills/mesh-on/poller-prompt.md:376-383 and
  agent-mesh/guidance/agent-operating.md:223-233. The three statements of
  the sweep unit must agree.
