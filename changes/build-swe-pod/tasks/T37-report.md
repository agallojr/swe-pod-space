# T37 report

- change: build-swe-pod
- task: T37
- actor: agallojr/build

## Status
DONE

## What I did
Test first: I wrote done-when check (1) and the standard-close checks, ran
them red at swe-pod 6f8ed78, wrote the content, then ran them green.

- PROCESS.md
  - §4 gets a new subsection, "Parallel tasks and shards". Tasks with no
    dependency run in parallel by default. A task whose work divides may
    be sharded, with each shard as its own task entry (`### T<n>a`). The
    plan says how the work divides, and build shards run local.
  - §7 gets "Sharded verify". It covers the shard record (file name, id,
    `shard:`, `tests:`, only what the shard ran) and the current commit
    set. It states the three-part rule for when the shards are "green
    together", in plain words. A shard that is out of date is re-run.
  - §11 gets a "Shards" bullet. It asks for one brief per shard, with the
    shard's tests or files in `## Task`. All shard briefs and dispatch
    lines are filed in one space commit before any shard starts. Test
    shards run local and mesh together, build shards stay local, and each
    shard gets its own dispatch line.
  - §12's layout now lists `<utc>-<shard id>.md` and
    `<utc>-<task id>-report.md` under `evidence/`. A new sentence says a
    test task's report goes under `evidence/`.
  - §2 (verified row), §6 (verify whole or in shards), the §11 Lanes
    bullet and §15 now agree with the new rules. PROCESS.md has no `R24`.
- agents/swe-plan.md: new step 5, plan parallel by default, name the
  shards and say how the work divides. Self-review checks this.
- agents/swe-lead.md: a "Shards" dispatch procedure, with one dispatch
  line per shard and one space commit. A filing step checks a shard
  record's `shard:` and `tests:`. The test lane names its report under
  `evidence/`. A new "Sharded verify" section holds the verified rule and
  the re-run rule. The whole-change review, integrate start and merge
  step 1 now read shard records.
- agents/swe-test.md: in a verify shard, run only what the brief lists. A
  shard record has `shard:` and `tests:`. Every test task writes its
  report as `evidence/<UTC>-T<n>-report.md`.
- skills/swe-pod/SKILL.md
  - New definitions in 1.6: an evidence record, and a shard record. A
    report under `evidence/` is not evidence.
  - New 1.7 Sharded verify. It defines the shards, each shard's latest
    record, the current commit set (with a git command for the
    brief-holding commit), "at the current commit set" and "green
    together".
  - The 1.2 verified row uses 1.7.
  - §2 names any shard that is out of date or missing.
  - §4 makes a shard that is out of date the next task.
  - Trace steps 4 and 5 handle shards.
- skills/swe-pod/status-format.md: a sharded form of the
  `latest evidence` bullet, with one line per shard showing its latest
  record. New `next: re-run T<a>[, T<b>] at the current commit set` rule.
  The "As of" rule now reads the UTC that begins a record's name.
- templates/records/evidence.md: `shard:` and `tests:`, the shard file
  name and id, and "only what the shard ran" notes.
- templates/records/report.md: the path line says where a test task's
  report goes (`evidence/<UTC>-T<n>-report.md`). The actor is now
  `<handle>/<build|test>`.

## Files
- swe-pod/PROCESS.md: changed
- swe-pod/agents/swe-plan.md: changed
- swe-pod/agents/swe-lead.md: changed
- swe-pod/agents/swe-test.md: changed
- swe-pod/skills/swe-pod/SKILL.md: changed
- swe-pod/skills/swe-pod/status-format.md: changed
- swe-pod/templates/records/evidence.md: changed
- swe-pod/templates/records/report.md: changed

Commit range: swe-pod 6f8ed78..882cd09 (one commit, 882cd09, trailers
`Change: build-swe-pod`, `Task: T37`), pushed to `change/build-swe-pod`.

## Test output

### Done-when (1)
- command: a scratch check script (removed afterwards). It looked for
  `shard` in the PROCESS.md §4, §7 and §11 sections, `shard:` and
  `tests:` in the evidence template and SKILL.md, and a bare `R24` in
  PROCESS.md. It also checked PROCESS.md lines 1 and 3 and its 15
  level-2 headings in order (plan §2.2), the body headings of the three
  touched role definitions (§2.3), and trailing whitespace in all eight
  touches.
- red (at 6f8ed78):

  ```
  PROCESS.md '## 4 Plan': shard MISSING
  PROCESS.md '## 7 Verify': shard MISSING
  PROCESS.md '## 11 Dispatch': shard MISSING
  templates/records/evidence.md: shard: MISSING
  templates/records/evidence.md: tests: MISSING
  skills/swe-pod/SKILL.md: shard: MISSING
  skills/swe-pod/SKILL.md: tests: MISSING
  PROCESS.md bare R24: 0
  PROCESS.md lines 1, 3 and headings: ok
  agents/swe-plan.md body headings: ok
  agents/swe-lead.md body headings: ok
  agents/swe-test.md body headings: ok
  RESULT: FAIL (7)
  ```

- green (working tree, then committed as 882cd09):

  ```
  PROCESS.md '## 4 Plan': shard found
  PROCESS.md '## 7 Verify': shard found
  PROCESS.md '## 11 Dispatch': shard found
  templates/records/evidence.md: shard: found
  templates/records/evidence.md: tests: found
  skills/swe-pod/SKILL.md: shard: found
  skills/swe-pod/SKILL.md: tests: found
  PROCESS.md bare R24: 0
  PROCESS.md lines 1, 3 and headings: ok
  agents/swe-plan.md body headings: ok
  agents/swe-lead.md body headings: ok
  agents/swe-test.md body headings: ok
  RESULT: PASS
  ```

- equivalent you can re-run, from the swe-pod checkout, for each `<rev>`:
  `git show <rev>:PROCESS.md | awk '/^## 4 Plan/,/^## 5 Build/' | grep -c shard`.
  Use the same command for `/^## 7 Verify/,/^## 8 Integrate/` and
  `/^## 11 Dispatch/,/^## 12 The Project Space/`. Then run
  `grep -c 'shard:'` and `grep -c 'tests:'` on the evidence template and
  SKILL.md, and `grep -cw R24` on PROCESS.md. The counts are in this
  order: §4, §7, §11, evidence `shard:`, evidence `tests:`, skill
  `shard:`, skill `tests:`, PROCESS.md `R24`.
  - red, 6f8ed78: `0 0 0 0 0 0 0 0`
  - green, 882cd09: `11 18 8 1 1 4 2 0`

### Standard close
- `git diff 74d23f1 -- SPEC.md spec-process.d2 spec-process.svg
  spec-process.png` (74d23f1 is the latest `Task: T0` commit): empty, 0
  lines, before and after the commit.
- shareability: 0 hits
- commit by pathspec with both trailers. Then
  `git merge-base --is-ancestor origin/change/build-swe-pod HEAD` exited 0
  (remote head 6f8ed78), so there was no rebase. The push went
  `6f8ed78..882cd09`, and `git ls-remote` shows the remote head at
  882cd09.

### Unit suite
swe-pod has no unit suite: none present.

## Concerns
- These are decisions for the reviewer to confirm. None blocks the task.
  - SKILL.md 1.7 is stricter than plan §2.4 in one way. A shard record is
    at the current commit set only if three things hold: its repo shas
    match, its space sha is the commit that holds the latest shard
    briefs, and the change's tests and `tests/` have not changed from
    that commit to `HEAD`. The last part is the existing 1.5 check. I
    kept it so that a test edited after the briefs were filed cannot
    count as verified.
  - Re-run rule (PROCESS.md §7, swe-lead "Sharded verify", SKILL.md 1.7).
    The current space commit is the one holding the latest shard briefs.
    So re-filing one shard's brief would put every other shard out of
    date. The rule therefore has two cases. If no branch head has moved,
    the shard that is out of date is dispatched again from its existing
    brief, which matches R24.S2. If a head has moved, every shard is
    briefed again in one space commit and every shard runs again, which
    matches the plan's re-run rule for T19a and T19b.
  - Report template: beyond the path line the step names, I changed the
    actor line to `<handle>/<build|test>`. Otherwise a test task's report
    written from the template would say `/build`.
  - Not in my touches, so not changed. `templates/records/brief.md` and
    `test-brief.md` do not say that a shard's `## Task` lists its tests
    (plan §2.4). `templates/records/plan.md` does not show shard
    entries. PROCESS.md §11, swe-lead and swe-plan do carry these rules.
  - status-format.md adds new exact STATUS.md text: the sharded
    `latest evidence` lines and the `next: re-run ...` rule. STATUS.md for
    a change with no shard record is unchanged.

## Test suggestions

### T37.TS1 Shard out of date by its space commit only
- for the tester: R24.S2 is at risk. The input is a verify in two
  shards. Both records name the same code branch heads, but different
  space commits, and only one of those commits is the one that filed the
  latest shard briefs. Expected failure: the lead reads the change as
  verified, or it does not name the shard whose record is at the older
  space commit as the one to re-run.
- for the reviewer: swe-pod/skills/swe-pod/SKILL.md:185-221 (1.7, current
  commit set and "at the current commit set"), and
  swe-pod/agents/swe-lead.md:329-351. The space part is matched against
  the brief-holding commit, not against `HEAD`. That line is easy to
  misread as the 1.5 rule.

### T37.TS2 Shards that pass but do not cover everything together
- for the tester: R24.S1 and R12.S1 are at risk. The input is two shard
  records at one commit set, where every result in each is a pass, but
  together they leave out one unit suite or one scenario of the spec.
  Expected failure: the change is read as verified.
- for the reviewer: swe-pod/skills/swe-pod/SKILL.md:210-216 ("green
  together") and swe-pod/skills/swe-pod/status-format.md:98-118. The
  combined results and the per-shard counts use different `<n>`s, and the
  top line must be `not green` when coverage is missing.

### T37.TS3 A test task's report among the evidence
- for the tester: R11.S1 and R8.S1 are at risk. The input is a change
  whose `evidence/` folder holds a test task's report, filed after the
  latest evidence record. Expected failure: the report is read as the
  latest evidence, so the change's verified state or the status view's
  latest evidence is wrong.
- for the reviewer: swe-pod/skills/swe-pod/SKILL.md:156-160. Evidence
  records are told apart by their `id: ev-` front matter, not by file
  name, and status-format "As of" takes the UTC at the start of every
  record's name in `evidence/`.
