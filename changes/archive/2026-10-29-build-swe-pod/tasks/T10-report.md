# T10 report: M5 space-librarian

## Status

DONE

## What I did

- Wrote `skills/space-librarian/SKILL.md` in agent-mesh to plan §2.7. It is
  given a space root and record files, and prints one line per record:
  `FILED <space path> <sha7>` or `REFUSED <space path>:
  <profile|reference|id> line <n>`. It never prints the matched text.
- **Who runs it.** A mesh librarian uses it for every rw space that
  `spaces.yaml` assigns to its role (`access: rw`, its role in
  `librarian:`), and never writes an `ro` space. Without a bus, the session
  uses it directly as its own librarian.
- **Section 1, the checks.** One POSIX `sh` script that the agent saves in a
  scratch directory outside the space and runs with `sh`. Its patterns are
  `grep -E`, `sed -E` and POSIX `awk` only: no `-P`, and no interval
  expressions in `awk`. It runs profile, then reference, then id, and reports
  the first check that fails, at its first failing line.
  - **profile.** The values are built at run time, in a temporary directory
    the script deletes on exit. From the bus: `agents/*.yaml`, the inbox
    names under `tasks/`, and the task ids in the file names under `tasks/`,
    `status/` and `_archive/`. From the node: the hostname and the credential
    key names. Home paths use the four §2.7 patterns.
  - **reference.** Covers the front-matter reference fields, and qualified
    cross-space ids in the body outside inline code and fences. It resolves
    URLs, records in the space, spaces in `may_reference`, change folders
    (live or archived), and `<change>/T<n>` against plan headings and table
    rows.
  - **id.** Covers the collision-free form and the UTC-named forms for
    evidence, decisions and handoffs. The id must not be held by another
    file. An id already filed at the same path is not new.
- **Section 2, commit, push, confirm.** The git commands use literal paths:
  - one commit per record, by pathspec, with a plain-text message;
  - `fetch origin`, `rebase --autostash origin/main`, then the check runs
    again;
  - `push origin HEAD:main`, retried at most 3 times;
  - a fresh fetch, then `merge-base --is-ancestor`, before `FILED`.

  It never force-pushes. A desk run prints the section 2 commands and runs
  none of them.
- Wrote the done-when checks as a harness in a scratch directory outside
  every repo. The harness copies the space there without `.git`, extracts
  the script from the skill, and runs it. It ran red before the skill
  existed and green after.

### Fix round 1

- **Finding.** The profile word patterns counted `-` and `_` as word
  characters on both sides of every value, so a real task id or agent id
  joined by a hyphen passed: `_archive/<yyyy-mm>/<task id>-result.md`,
  `task-<task id>` and `node-<agent id>`. I reproduced it before the fix (red
  below).
- **Change.** The script now builds three value lists, each with its own
  boundary:
  - `words`, the hostnames, their first labels and the credential key names.
    These keep `-` and `_` as word characters on both sides, so a label
    inside a longer name passes.
  - `agents`, the `agent_id` and `agent_name` values and the inbox names
    under `tasks/`. These end at any character that is not a letter or a
    digit, so `-` and `_` joins match.
  - `tids`, the mesh task ids from the file names. These start after any
    character that is not a letter or a digit, and end at any non-digit.
  One `pat` function builds the patterns for all three lists. The home-path
  patterns are unchanged. The section 1 text for the profile check now says
  which joins pass and which do not.
- **Harness.** It gained four probes: the `<task id>-result.md` file name
  under `_archive/`, `task-<task id>`, `node-<agent id>`, and a task id and
  an agent id each followed by `_x`. It also gained two false-refusal
  controls, which must pass: a record id with the same digits as a real task
  id (the record form has `Z` after the time), and a sha256 that holds an
  agent id inside a longer run of hex digits. Each new probe also reruns
  against an empty registry, where it must pass.

## Files

- agent-mesh `skills/space-librarian/SKILL.md` (new, 376 lines), commit
  `92f1dcf` on `change/build-swe-pod`, trailers `Change: build-swe-pod` and
  `Task: T10`, pushed.
- Fix round 1: the same file (now 390 lines), commit `7430aeb` on
  `change/build-swe-pod`, with the same trailers, pushed. Task diff:
  agent-mesh `e70dfc2..7430aeb`, which holds the two `Task: T10` commits
  `92f1dcf` and `7430aeb`.

## Test output

Done-when 1 and 2, red (before the skill existed):

```
scratch outside every repo: yes
FAIL check script extracted
FAIL 1 accepts changes/build-swe-pod/spec.md
FAIL 1 accepts changes/build-swe-pod/plan.md
FAIL 1 accepts changes/build-swe-pod/ledger.md
FAIL 1 accepts notes/note-20261027T2142Z-0a31-memory-spaces-design.md
FAIL 1 accepts notes/note-20261027T2242Z-0786-deferred-executor-git-exception.md
FAIL 2 refuses $HOME
FAIL 2 refuses cwd root
FAIL 2 refuses agent id
FAIL 2 refuses space not in may_reference
FAIL 2 refuses duplicate id
FAIL 2 only result lines printed (1 other)
FAIL 2 no matched text printed
FAIL control: cwd root passes with no registry
FAIL control: agent id passes with no registry
harness: 0 pass, 15 fail
```

Done-when 1 and 2, green (`/bin/sh`). The five negative records are built at
run time with fresh ids. The two controls rerun the registry cases against an
empty registry, to show it is the registry patterns that refuse them:

```
scratch outside every repo: yes
PASS check script extracted
  | CHECKED changes/build-swe-pod/spec.md
  | CHECKED changes/build-swe-pod/plan.md
  | CHECKED changes/build-swe-pod/ledger.md
  | CHECKED notes/note-20261027T2142Z-0a31-memory-spaces-design.md
  | CHECKED notes/note-20261027T2242Z-0786-deferred-executor-git-exception.md
PASS 1 accepts changes/build-swe-pod/spec.md
PASS 1 accepts changes/build-swe-pod/plan.md
PASS 1 accepts changes/build-swe-pod/ledger.md
PASS 1 accepts notes/note-20261027T2142Z-0a31-memory-spaces-design.md
PASS 1 accepts notes/note-20261027T2242Z-0786-deferred-executor-git-exception.md
  | REFUSED notes/note-20261027T2323Z-bb1c-neg-home.md: profile line 10
  | REFUSED notes/note-20261027T2323Z-a5ff-neg-root.md: profile line 10
  | REFUSED notes/note-20261027T2323Z-5360-neg-agent.md: profile line 10
  | REFUSED notes/note-20261027T2323Z-f41f-neg-ref.md: reference line 10
  | REFUSED notes/note-20261027T2142Z-0a31-neg-dup.md: id line 2
PASS 2 refuses $HOME
PASS 2 refuses cwd root
PASS 2 refuses agent id
PASS 2 refuses space not in may_reference
PASS 2 refuses duplicate id
PASS 2 only result lines printed
PASS 2 no matched text printed
  | CHECKED notes/note-20261027T2323Z-a5ff-neg-root.md
  | CHECKED notes/note-20261027T2323Z-5360-neg-agent.md
PASS control: cwd root passes with no registry
PASS control: agent id passes with no registry
harness: 15 pass, 0 fail
```

Each run of the same harness under `/bin/dash` and under `/bin/ksh` ended
with `harness: 15 pass, 0 fail`. The check took 1.13 s wall time for the five
clean records.

Extra checks, beyond the done-when:

- 21 of 21 probes passed in scratch, under `/bin/sh` and under `/bin/dash`.
  Accepted:
  - a change id in `discovered_in`;
  - task ids `T10` (a plan heading) and `T30` (a plan table row);
  - a block-list `related`, with a URL in it;
  - an own-space qualified id with a commit pin;
  - qualified ids inside inline code, a fence, and a span that crosses a
    line;
  - prose such as `core/lore` and `spaces/core/notes`;
  - `~/`, `/home/<user>` and `$HOME` written literally;
  - an id-shaped example that no bus holds.

  Refused:
  - an unknown change;
  - a missing plan task;
  - an unresolved own-space id;
  - a `core/` citation;
  - a per-user home path;
  - a bus task id;
  - the node's hostname;
  - a node credential name;
  - a bad id form;
  - a decision whose name is not in the UTC form.
- A read-only run on the space checkout itself (submodule of the bus, base
  `origin/main`) found the bus through the superproject. It accepted all 38
  files in the space, tracked and untracked, images included, with no false
  refusal.

Done-when 3, desk output. This follows the skill's Desk run for this report,
`changes/build-swe-pod/tasks/T10-report.md`. The check script ran for real,
since it only reads, and printed `CHECKED changes/build-swe-pod/tasks/T10-report.md`.
The section 2 commands below were printed and none was run. The space root
is written as `<space root>`, because a record holds no machine path:

```
git -C <space root> fetch origin
git -C <space root> cat-file -e origin/main:changes/build-swe-pod/tasks/T10-report.md
git -C <space root> diff --quiet origin/main -- changes/build-swe-pod/tasks/T10-report.md
git -C <space root> add -- changes/build-swe-pod/tasks/T10-report.md
git -C <space root> commit -m "File changes/build-swe-pod/tasks/T10-report.md" -- changes/build-swe-pod/tasks/T10-report.md
git -C <space root> fetch origin
git -C <space root> rebase --autostash origin/main
git -C <space root> log -1 --format=%H -- changes/build-swe-pod/tasks/T10-report.md
SPACE=<space root> sh <script file> changes/build-swe-pod/tasks/T10-report.md
git -C <space root> push origin HEAD:main
git -C <space root> fetch origin
git -C <space root> merge-base --is-ancestor <commit> origin/main
```

No `FILED` line, as a desk run prints none.

Standard close:

- The shareability check printed `shareability: 0 hits` after staging, and
  again after the commit.
- `git diff 854e87c -- SPEC.md spec-process.*` in swe-pod printed nothing.
  `854e87c` is the latest `Task: T0` commit.
- `92f1dcf` holds only `skills/space-librarian/SKILL.md`, has both trailers,
  and is on `origin/change/build-swe-pod`.
- The review (T30) is pending.

### Fix round 1

Red, with the harness run against the skill as committed in `92f1dcf`. All
done-when checks still pass. The four new probes fail, because each
hyphen-joined or underscore-joined value is `CHECKED`:

```
PASS scratch outside every repo
PASS check script extracted
  | CHECKED changes/build-swe-pod/spec.md
PASS 1 accepts changes/build-swe-pod/spec.md
  | CHECKED changes/build-swe-pod/plan.md
PASS 1 accepts changes/build-swe-pod/plan.md
  | CHECKED changes/build-swe-pod/ledger.md
PASS 1 accepts changes/build-swe-pod/ledger.md
  | CHECKED notes/note-20261027T2142Z-0a31-memory-spaces-design.md
PASS 1 accepts notes/note-20261027T2142Z-0a31-memory-spaces-design.md
  | CHECKED notes/note-20261027T2242Z-0786-deferred-executor-git-exception.md
PASS 1 accepts notes/note-20261027T2242Z-0786-deferred-executor-git-exception.md
  | REFUSED notes/note-20261027T2341Z-4829-neg-home.md: profile line 10
PASS 2 refuses $HOME
  | REFUSED notes/note-20261027T2341Z-9db1-neg-root.md: profile line 10
PASS 2 refuses cwd root
  | REFUSED notes/note-20261027T2341Z-0644-neg-agent.md: profile line 10
PASS 2 refuses agent id
  | REFUSED notes/note-20261027T2341Z-22e1-neg-ref.md: reference line 10
PASS 2 refuses space not in may_reference
  | REFUSED notes/note-20261027T2142Z-0a31-neg-dup.md: id line 2
PASS 2 refuses duplicate id
  | CHECKED notes/note-20261027T2341Z-99d5-neg-arch.md
FAIL fix refuses task id in <task id>-result.md
  | CHECKED notes/note-20261027T2341Z-1509-neg-task.md
FAIL fix refuses task-<task id>
  | CHECKED notes/note-20261027T2341Z-91aa-neg-node.md
FAIL fix refuses node-<agent id>
  | CHECKED notes/note-20261027T2341Z-3887-neg-us.md
FAIL fix refuses <id>_x
  | CHECKED notes/note-20261027T2341Z-c7ab-pos-utc.md
PASS control: UTC record id sharing a task id's digits passes
  | CHECKED notes/note-20261027T2341Z-40d8-pos-sha.md
PASS control: sha256 holding an agent id inside an alphanumeric run passes
PASS 2 only result lines printed (0 other)
PASS 2 no matched text printed
  | CHECKED notes/note-20261027T2341Z-9db1-neg-root.md
PASS control: neg-root passes with no registry
  | CHECKED notes/note-20261027T2341Z-0644-neg-agent.md
PASS control: neg-agent passes with no registry
  | CHECKED notes/note-20261027T2341Z-99d5-neg-arch.md
PASS control: neg-arch passes with no registry
  | CHECKED notes/note-20261027T2341Z-1509-neg-task.md
PASS control: neg-task passes with no registry
  | CHECKED notes/note-20261027T2341Z-91aa-neg-node.md
PASS control: neg-node passes with no registry
  | CHECKED notes/note-20261027T2341Z-3887-neg-us.md
PASS control: neg-us passes with no registry
harness: 22 pass, 4 fail
```

Green, against the fixed skill (`/bin/sh`):

```
PASS scratch outside every repo
PASS check script extracted
  | CHECKED changes/build-swe-pod/spec.md
PASS 1 accepts changes/build-swe-pod/spec.md
  | CHECKED changes/build-swe-pod/plan.md
PASS 1 accepts changes/build-swe-pod/plan.md
  | CHECKED changes/build-swe-pod/ledger.md
PASS 1 accepts changes/build-swe-pod/ledger.md
  | CHECKED notes/note-20261027T2142Z-0a31-memory-spaces-design.md
PASS 1 accepts notes/note-20261027T2142Z-0a31-memory-spaces-design.md
  | CHECKED notes/note-20261027T2242Z-0786-deferred-executor-git-exception.md
PASS 1 accepts notes/note-20261027T2242Z-0786-deferred-executor-git-exception.md
  | REFUSED notes/note-20261027T2341Z-c343-neg-home.md: profile line 10
PASS 2 refuses $HOME
  | REFUSED notes/note-20261027T2341Z-a44b-neg-root.md: profile line 10
PASS 2 refuses cwd root
  | REFUSED notes/note-20261027T2341Z-7a22-neg-agent.md: profile line 10
PASS 2 refuses agent id
  | REFUSED notes/note-20261027T2341Z-b44e-neg-ref.md: reference line 10
PASS 2 refuses space not in may_reference
  | REFUSED notes/note-20261027T2142Z-0a31-neg-dup.md: id line 2
PASS 2 refuses duplicate id
  | REFUSED notes/note-20261027T2341Z-c1d7-neg-arch.md: profile line 10
PASS fix refuses task id in <task id>-result.md
  | REFUSED notes/note-20261027T2341Z-52fc-neg-task.md: profile line 10
PASS fix refuses task-<task id>
  | REFUSED notes/note-20261027T2341Z-91ac-neg-node.md: profile line 10
PASS fix refuses node-<agent id>
  | REFUSED notes/note-20261027T2341Z-8aad-neg-us.md: profile line 10
PASS fix refuses <id>_x
  | CHECKED notes/note-20261027T2341Z-1afb-pos-utc.md
PASS control: UTC record id sharing a task id's digits passes
  | CHECKED notes/note-20261027T2341Z-4837-pos-sha.md
PASS control: sha256 holding an agent id inside an alphanumeric run passes
PASS 2 only result lines printed (0 other)
PASS 2 no matched text printed
  | CHECKED notes/note-20261027T2341Z-a44b-neg-root.md
PASS control: neg-root passes with no registry
  | CHECKED notes/note-20261027T2341Z-7a22-neg-agent.md
PASS control: neg-agent passes with no registry
  | CHECKED notes/note-20261027T2341Z-c1d7-neg-arch.md
PASS control: neg-arch passes with no registry
  | CHECKED notes/note-20261027T2341Z-52fc-neg-task.md
PASS control: neg-task passes with no registry
  | CHECKED notes/note-20261027T2341Z-91ac-neg-node.md
PASS control: neg-node passes with no registry
  | CHECKED notes/note-20261027T2341Z-8aad-neg-us.md
PASS control: neg-us passes with no registry
harness: 26 pass, 0 fail
```

The same harness under `/bin/dash` and under `/bin/ksh` also ended with
`harness: 26 pass, 0 fail`.

False-refusal sweep: the fixed script, run read-only on the space checkout
itself, with the bus found through the superproject. It accepted all 45
files in the space, tracked and untracked, with no refusal. The run took
5.78 s wall time.

Done-when 3 is unchanged: the fix touches only section 1, and the section 2
command sequence above is still what a desk run prints.

Standard close, fix round 1:

- The shareability check printed `shareability: 0 hits` after staging, and
  again after the commit.
- `git diff 854e87c -- SPEC.md spec-process.*` in swe-pod printed nothing.
  `854e87c` is still the latest `Task: T0` commit.
- `7430aeb` holds only `skills/space-librarian/SKILL.md`, has both
  trailers, and is on `origin/change/build-swe-pod`.

## Concerns

- **GNU userland untested.** This node has only BSD `grep`, `sed` and `awk`,
  so the script ran under three shells (sh, dash, ksh) with BSD tools. It
  avoids `-P`, GNU-only flags and `awk` interval expressions. `grep -o`,
  `-a` and `-l` are not POSIX, but both BSD and GNU grep have them. A run on
  a `linux-server` node (T20, or test I8) would settle it.
- **Commit stage and git-backed id rules not run.** The git fence allows no
  commit outside the task checkout, so I never ran section 2, the
  event-file overwrite rule, or the post-rebase recheck. The `origin/main`
  rule ("not new at the same path") was exercised only read-only, on the
  live space.
- **Choices beyond the literal §2.7 text**, for the reviewer:
  - `agent_name` and the inbox directory names under `tasks/` count as agent
    ids.
  - Values shorter than 3 characters are skipped.
  - The reference and id checks read Markdown records only. Other files,
    such as images and YAML, get the profile check alone.
  - Only YAML front-matter counts as front-matter. A spec's bullet header
    (`- supersedes: []`) is not read as a reference field.
  - `rebase --autostash`, so unfiled edits in the checkout do not block the
    rebase.
  - The check runs again after the rebase.
  - A record already on `origin/main` as it is gets `FILED` with its
    existing commit, and no new commit.
  - Under evidence, decisions and handoffs, a changed file at an
    already-filed path is refused as `id`.
  - `CHECKED` is a working line, and there is a desk-run section.
  - "First two path components" of a `cwd` is taken as `/<a>/<b>`.
- **Approximations in the body scan.**
  - An unmatched backtick hides the rest of its paragraph from the
    qualified-id scan, so it fails open.
  - An unfenced 4-space code block is scanned as body text, so it fails
    closed.
  - The home-root pattern needs a non-path character before `/Users/` or
    `/home/`, so URL paths do not trip it. As a result, a per-user path under
    another root on an unregistered node is not caught. Registered nodes are
    still caught through the `cwd` patterns.
- **Shared index.** The checkout's index also held T9's two staged files. I
  left them alone and committed by pathspec. The staged-change scan of the
  shareability check covered them too, with 0 hits. In fix round 1 the same
  two files were still staged, and I left them alone again.
- **Fix round 1, boundary choices.**
  - `agent_name` takes the agent-id boundary, since this skill counts it as
    an agent id. A cost: if an operator gives an agent a generic word as its
    name, a compound such as an environment class name that holds that word
    is then refused. That is a false refusal, so it fails closed.
  - Hostnames, their labels and credential key names keep `-` and `_` as
    word characters, as the review asked. So `<hostname label>-x` and
    `X_<credential key>` still pass.
  - A task id now ends at any non-digit. Record ids are not affected,
    because their UTC form has `Z` between the time and the suffix. The
    `pos-utc` control shows this.
- **Outside my touches.** The builders' shareability tool (§2.8) has its own
  copy of the old word boundary, with `-` and `_` as word characters on both
  sides. So it has the same gap for hyphen-joined task ids and agent ids. It
  is not in this task's touches, and I did not change it. I am raising it
  for the lead.

## Test suggestions

### T10.TS1 Shareable records are accepted
- for the tester: Give the librarian a Project Space and records that follow
  the shareable profile. Their citations name records, changes and tasks in
  the same space, URLs, and qualified ids inside inline code or fenced
  blocks. Check that every record passes all three checks.
- for the reviewer: `skills/space-librarian/SKILL.md` lines 216 to 262
  (`resolve`, `refs`) and lines 264 to 308 (the record loop).

### T10.TS2 Each profile leak is refused without echoing it
- for the tester: Build records at run time, one leak each: the local home
  path, a registered node's working-directory root, a registered agent id, a
  mesh task id the bus holds, and a credential key name the node holds. Each
  must be refused as `profile`, at the line of the record that holds the
  leak. The output must contain none of the leaked values.
- for the reviewer: `SKILL.md` lines 142 to 185 (building the values) and
  line 272.

### T10.TS3 Citations and the visibility rule
- for the tester: Cite, in body text, a space that is not in `may_reference`;
  the record must be refused as `reference`. Cite the same space after
  listing it in `may_reference`; it must be accepted. Cite a private space
  (`core/` or `lore/`) from a shared space; it must be refused.
- for the reviewer: `SKILL.md` lines 187 to 198 and lines 216 to 226.

### T10.TS4 Duplicate ids, and re-filing
- for the tester: A new record that reuses an existing record's id is
  refused as `id`. Re-filing a record that is already on `main`, unchanged,
  makes no second commit and still reports it as filed.
- for the reviewer: `SKILL.md` lines 280 to 306, and section 2 step 1.

### T10.TS5 Single seat uses the same checks (R17.S2)
- for the tester: In a session with no bus, filing a record runs the same
  three checks, with values from the node only. A value known only to a
  registry then passes. A home path still fails.
- for the reviewer: `SKILL.md` lines 26 to 28 and lines 131 to 140.

### T10.TS6 Commit stage in desk mode
- for the tester: A desk run prints the commands in order, one commit per
  record. The only push is to `HEAD:main`, and the ancestor check against
  `origin/main` comes after a fresh fetch. No force push, branch, or
  `FILED` line appears.
- for the reviewer: `SKILL.md` lines 311 to 380.

### T10.TS7 Portability
- for the tester: Run the check script on a `linux-server` node with GNU
  tools, against the same five clean records and five built records. The
  results must match a `macos-laptop` run line for line.
- for the reviewer: `SKILL.md` lines 123 to 309.

### T10.TS8 Joined bus values are refused (fix round 1)
- for the tester: Build records at run time that join a real bus value to
  other text with `-` or `_`: a bus task id in its own file-name form
  (`<task id>-<slug>`, under `_archive/<yyyy-mm>/`), `task-<task id>`,
  `node-<agent id>`, and a task id or agent id followed by `_` and more
  text. Each must be refused as `profile`, at the line that holds it, and
  the output must hold none of the values. Also check two id-shaped texts
  that are not bus values: a record id whose digits match a real task id
  but in the record's UTC form, and a sha256 that holds an agent id inside a
  longer run of hex digits. Both must be accepted. The joined records must
  be accepted when there is no registry.
- for the reviewer: `SKILL.md` lines 142 to 163 (the three value lists) and
  lines 172 to 182 (`pat` and its three boundaries).
