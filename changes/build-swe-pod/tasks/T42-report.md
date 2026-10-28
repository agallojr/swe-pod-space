# T42 report

- change: build-swe-pod
- task: T42
- actor: agallojr/build

## Status
DONE

## What I did
- Wrote the done-when checks first, as a harness in a scratch directory
  outside every repo. It pulls the section 1 script out of the skill, builds
  a throwaway space (`git init`, a `space.yaml`, no remote) with records made
  at run time under `changes/demo/evidence/` and `notes/`, and runs the script
  on them. It also repeats T10's done-when checks 1 and 2 on a copy of this
  space taken without `.git`. A second small check reads the `Task: T42`
  commits and confirms every hunk falls inside the id bullet or the evidence
  case. Both ran red against the skill at `e0f6af0`.
- **Prose.** In section 1's id bullet, the evidence form now reads
  `ev-<UTC>`, or `ev-<UTC>-<shard id>` for a shard (a task id and one
  lowercase letter), such as `ev-<UTC>-T19a`, under `changes/<id>/evidence/`.
  A semicolon now separates this from the `decisions/` and `handoffs/` form.
  The bullet's last four lines are rewrapped and no word in them changed;
  `git diff --word-diff` shows only the insertion and the two punctuation
  changes.
- **Script.** In the `changes/*/evidence/*)` case, the evidence alternative
  is now `ev-[0-9]{8}T[0-9]{4}Z(-T[0-9]+[a-z])?`. The case is split over two
  lines, the same way the `decisions/*|handoffs/*)` case below it is.
- Nothing else changed: the other id forms, the already-present and
  one-file-per-event rules, the profile and reference checks, and section 2.
- Ran the same harness green under `/bin/sh`, `/bin/dash` and `/bin/ksh`.
  Then I committed by pathspec, ran the shareability check, fetched, and ran
  the merge-base check (exit 0, so no rebase). Then I pushed. The scratch
  harness and spaces are deleted.

## Files
- agent-mesh/skills/space-librarian/SKILL.md: changed. The section 1 id
  bullet (lines 96 to 107) and the evidence case of the check script (lines
  291 to 292). The diff is 9 lines added and 7 removed.
- Commit range: agent-mesh `e0f6af0..1367f65`. That is one commit, `1367f65`,
  on `change/build-swe-pod`, with trailers `Change: build-swe-pod` and
  `Task: T42`. It is pushed, and `origin/change/build-swe-pod` is at
  `1367f65`.

## Test output

### Done-when 1 to 3 (harness)
- command: `sh harness.sh <SKILL.md> <shell>`, run in a scratch directory
  outside every repo. It extracts the section 1 script and runs it as
  `SPACE=<space root> <shell> <script file> <space path> ...`. For the
  T42 checks, `BUS` is left to the skill's default. For T10 check 2 it is
  the bus, and for the T10 controls it is a directory with no registry. Each
  negative record is added on its own, with the two good records present,
  and is removed after its run.
- red (skill at `e0f6af0`, `/bin/sh`, 19.3 s wall time). Check 1 fails, as
  the old form refuses the shard id. Check 2 passes, because the old form
  refuses every id there; the two controls show it refuses them for the
  wrong reason:

```
PASS scratch outside every repo
PASS check script extracted
PASS space has no remote
  | CHECKED changes/demo/evidence/20261028T0100Z.md
  | REFUSED changes/demo/evidence/20261028T0100Z-T19a.md: id line 2
FAIL 1 CHECKED ev-20261028T0100Z and ev-20261028T0100Z-T19a together
  | REFUSED changes/demo/evidence/20261028T0100Z-T19.md: id line 2
PASS 2 refuses ev-20261028T0100Z-T19 (no letter)
  | REFUSED changes/demo/evidence/20261028T0100Z-19a.md: id line 2
PASS 2 refuses ev-20261028T0100Z-19a (no T)
  | REFUSED changes/demo/evidence/20261028T0100Z-T19a-x.md: id line 2
PASS 2 refuses ev-20261028T0100Z-T19a-x (trailing text)
  | REFUSED changes/demo/evidence/20261028T0100-T19a.md: id line 2
PASS 2 refuses ev-20261028T0100-T19a (no Z)
  | REFUSED changes/demo/evidence/20261028T0101Z-T19a.md: id line 2
PASS 2 refuses a second evidence record holding ev-20261028T0100Z-T19a
  | REFUSED notes/20261028T0200Z-T19a.md: id line 2
PASS 2 refuses ev-20261028T0200Z-T19a under notes/
  | REFUSED changes/demo/evidence/20261028T0101Z-T19a.md: id line 2
FAIL control: that second record passes once the first is gone
  | REFUSED changes/demo/evidence/20261028T0200Z-T19a.md: id line 2
FAIL control: ev-20261028T0200Z-T19a passes under evidence/
  | REFUSED changes/demo/evidence/20261028T0100Z-T123b.md: id line 2
FAIL extra: ev-20261028T0100Z-T123b passes
  | REFUSED changes/demo/evidence/20261028T0100Z-T19A.md: id line 2
PASS extra: ev-20261028T0100Z-T19A (upper case) refused
  | REFUSED changes/demo/evidence/20261028T0100Z-T19ab.md: id line 2
PASS extra: ev-20261028T0100Z-T19ab (two letters) refused
  | REFUSED changes/demo/evidence/20261028T0100Z-Ta.md: id line 2
PASS extra: ev-20261028T0100Z-Ta (no task number) refused
  | CHECKED changes/demo/evidence/note-20261028T0100Z-1a2b.md
PASS extra: note-20261028T0100Z-1a2b under evidence/ passes
PASS T10 copy is outside every repo
  | CHECKED changes/build-swe-pod/spec.md
PASS T10.1 accepts changes/build-swe-pod/spec.md
  | CHECKED changes/build-swe-pod/plan.md
PASS T10.1 accepts changes/build-swe-pod/plan.md
  | CHECKED changes/build-swe-pod/ledger.md
PASS T10.1 accepts changes/build-swe-pod/ledger.md
  | CHECKED notes/note-20261027T2142Z-0a31-memory-spaces-design.md
PASS T10.1 accepts notes/note-20261027T2142Z-0a31-memory-spaces-design.md
  | CHECKED notes/note-20261027T2242Z-0786-deferred-executor-git-exception.md
PASS T10.1 accepts notes/note-20261027T2242Z-0786-deferred-executor-git-exception.md
PASS registry values found
  | REFUSED notes/note-20261028T0313Z-fa27-neg-home.md: profile line 10
  | REFUSED notes/note-20261028T0313Z-3d88-neg-root.md: profile line 10
  | REFUSED notes/note-20261028T0313Z-9d3e-neg-agent.md: profile line 10
  | REFUSED notes/note-20261028T0313Z-df14-neg-ref.md: reference line 10
  | REFUSED notes/note-20261027T2142Z-0a31-neg-dup.md: id line 2
PASS T10.2 refuses $HOME
PASS T10.2 refuses cwd root
PASS T10.2 refuses agent id
PASS T10.2 refuses space not in may_reference
PASS T10.2 refuses duplicate id
PASS T10.2 only result lines printed
PASS T10.2 no matched text printed
  | CHECKED notes/note-20261028T0313Z-3d88-neg-root.md
PASS T10 control: neg-root passes with no registry
  | CHECKED notes/note-20261028T0313Z-9d3e-neg-agent.md
PASS T10 control: neg-agent passes with no registry
harness (/bin/sh): 29 pass, 4 fail
```

- green (edited skill, `/bin/sh`, 20.0 s wall time):

```
PASS scratch outside every repo
PASS check script extracted
PASS space has no remote
  | CHECKED changes/demo/evidence/20261028T0100Z.md
  | CHECKED changes/demo/evidence/20261028T0100Z-T19a.md
PASS 1 CHECKED ev-20261028T0100Z and ev-20261028T0100Z-T19a together
  | REFUSED changes/demo/evidence/20261028T0100Z-T19.md: id line 2
PASS 2 refuses ev-20261028T0100Z-T19 (no letter)
  | REFUSED changes/demo/evidence/20261028T0100Z-19a.md: id line 2
PASS 2 refuses ev-20261028T0100Z-19a (no T)
  | REFUSED changes/demo/evidence/20261028T0100Z-T19a-x.md: id line 2
PASS 2 refuses ev-20261028T0100Z-T19a-x (trailing text)
  | REFUSED changes/demo/evidence/20261028T0100-T19a.md: id line 2
PASS 2 refuses ev-20261028T0100-T19a (no Z)
  | REFUSED changes/demo/evidence/20261028T0101Z-T19a.md: id line 2
PASS 2 refuses a second evidence record holding ev-20261028T0100Z-T19a
  | REFUSED notes/20261028T0200Z-T19a.md: id line 2
PASS 2 refuses ev-20261028T0200Z-T19a under notes/
  | CHECKED changes/demo/evidence/20261028T0101Z-T19a.md
PASS control: that second record passes once the first is gone
  | CHECKED changes/demo/evidence/20261028T0200Z-T19a.md
PASS control: ev-20261028T0200Z-T19a passes under evidence/
  | CHECKED changes/demo/evidence/20261028T0100Z-T123b.md
PASS extra: ev-20261028T0100Z-T123b passes
  | REFUSED changes/demo/evidence/20261028T0100Z-T19A.md: id line 2
PASS extra: ev-20261028T0100Z-T19A (upper case) refused
  | REFUSED changes/demo/evidence/20261028T0100Z-T19ab.md: id line 2
PASS extra: ev-20261028T0100Z-T19ab (two letters) refused
  | REFUSED changes/demo/evidence/20261028T0100Z-Ta.md: id line 2
PASS extra: ev-20261028T0100Z-Ta (no task number) refused
  | CHECKED changes/demo/evidence/note-20261028T0100Z-1a2b.md
PASS extra: note-20261028T0100Z-1a2b under evidence/ passes
PASS T10 copy is outside every repo
  | CHECKED changes/build-swe-pod/spec.md
PASS T10.1 accepts changes/build-swe-pod/spec.md
  | CHECKED changes/build-swe-pod/plan.md
PASS T10.1 accepts changes/build-swe-pod/plan.md
  | CHECKED changes/build-swe-pod/ledger.md
PASS T10.1 accepts changes/build-swe-pod/ledger.md
  | CHECKED notes/note-20261027T2142Z-0a31-memory-spaces-design.md
PASS T10.1 accepts notes/note-20261027T2142Z-0a31-memory-spaces-design.md
  | CHECKED notes/note-20261027T2242Z-0786-deferred-executor-git-exception.md
PASS T10.1 accepts notes/note-20261027T2242Z-0786-deferred-executor-git-exception.md
PASS registry values found
  | REFUSED notes/note-20261028T0315Z-6417-neg-home.md: profile line 10
  | REFUSED notes/note-20261028T0315Z-340c-neg-root.md: profile line 10
  | REFUSED notes/note-20261028T0315Z-5b45-neg-agent.md: profile line 10
  | REFUSED notes/note-20261028T0315Z-8468-neg-ref.md: reference line 10
  | REFUSED notes/note-20261027T2142Z-0a31-neg-dup.md: id line 2
PASS T10.2 refuses $HOME
PASS T10.2 refuses cwd root
PASS T10.2 refuses agent id
PASS T10.2 refuses space not in may_reference
PASS T10.2 refuses duplicate id
PASS T10.2 only result lines printed
PASS T10.2 no matched text printed
  | CHECKED notes/note-20261028T0315Z-340c-neg-root.md
PASS T10 control: neg-root passes with no registry
  | CHECKED notes/note-20261028T0315Z-5b45-neg-agent.md
PASS T10 control: neg-agent passes with no registry
harness (/bin/sh): 33 pass, 0 fail
```

- green under the other two shells: `harness (/bin/dash): 33 pass, 0 fail`
  and `harness (/bin/ksh): 33 pass, 0 fail`.

### Done-when 4 (the T42 commits change only the id bullet and the case)
- command: `sh check4.sh`. It finds the `Task: T42` commits on
  `change/build-swe-pod`, then lists the files they touch. It works out the
  id bullet's lines and the evidence case's lines in the file before and
  after the commits. Then it checks that every `git diff -U0` hunk lies
  inside one of them, on both sides.
- red (before the commit):

```
FAIL 4 no Task: T42 commit
```

- green:

```
T42 commits: 1367f65
PASS 4 commits touch only skills/space-librarian/SKILL.md
old: bullet 96-106, case 290-290; new: bullet 96-107, case 291-292
  hunk -101,6 +101,7 inside
  hunk -290,1 +291,2 inside
PASS 4 every hunk is in the id bullet or the evidence case line
```

### Done-when 5
For review: the prose and the script give the same form, and nothing else
changed.

### Done-when 6, standard close
- shareability: 0 hits (`shareability: 0 hits`, after the commit and before
  the push).
- swe-pod `git diff 74d23f1 -- SPEC.md spec-process.*` is empty (0 lines).
  `74d23f1` is the latest `Task: T0` commit.
- `1367f65` holds only `skills/space-librarian/SKILL.md`, has both trailers,
  and was committed by pathspec. `merge-base --is-ancestor
  origin/change/build-swe-pod HEAD` exited 0, so I skipped the rebase. The
  push went `e0f6af0..1367f65`.
- The review is pending.

### Unit suite
agent-mesh has no unit suite (none present). Its only `package.json`, under
`services/librarian-ingress/`, has no test script.

## Concerns
- The id check reads only the id's form, whether it is already present, and
  where the record sits. It does not check that a shard id in the id matches
  the file name (`<UTC>-<shard id>.md`) or the record's `shard:` key. It also
  does not check that the shard is a task in the plan. Plan section 2.4 ties
  these together, and today only the lead's filing check on `shard:` and
  `tests:` stands behind them. This is outside T42's steps ("Nothing else
  changes"), so I did not add it.
- GNU userland is untested here: this node has only BSD tools. The new
  pattern is plain ERE (a grouped optional suffix), which both support.

## Test suggestions

### T42.TS1 Shard evidence records are filed alongside an unsharded one
- for the tester: R24.S1. Give the librarian a space whose change already
  holds an unsharded evidence record at one UTC minute. Then hand it two
  shard evidence records for two shards of that change at the same minute,
  each named and identified by the shard form. The failure to look for: the
  librarian refuses either shard record as `id`, or refuses the earlier
  unsharded record when it is re-checked after the shard records land.
- for the reviewer: agent-mesh/skills/space-librarian/SKILL.md:291-292 and
  305-307. The form match is anchored on the whole id. Check the `holders`
  lookup at 207-211 too: it matches `id:` lines exactly, but file names by
  prefix. So an evidence file named with the `ev-` prefix would count as
  holding a shorter id that is a prefix of its name.

### T42.TS2 Malformed shard ids and misplaced shard ids are refused
- for the tester: R24 and the evidence record format. Hand the librarian new
  evidence records whose ids depart from the shard form in one way each: no
  task letter, a capital letter, two letters, no task number, a missing `Z`
  in the time, or extra text after the shard id. Also hand it a shard-form id
  in a record outside the change's evidence folder, and a second evidence
  record that reuses an existing shard record's id. The failure to look for:
  any of these is filed rather than refused as `id`, or refused under another
  check, or refused at a line other than its `id:` line.
- for the reviewer: agent-mesh/skills/space-librarian/SKILL.md:289-294. Only
  the evidence case widens the form; the base form and the decisions and
  handoffs case are unchanged. Also check the prose at 100-104 for the same
  rule.
