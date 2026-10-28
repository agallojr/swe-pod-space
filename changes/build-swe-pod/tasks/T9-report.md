# T9 report

- change: build-swe-pod
- task: T9
- role: build
- repo: agent-mesh

## Status

DONE

The first builder wrote and staged the content, and the node refused its
commit. On re-dispatch, with the commit permitted, the staged files were
checked against the brief unchanged, committed by pathspec with both
trailers, and pushed. Every done-when check and the standard close's
checkable items now pass. The review (§7) is still to come.

## What I did

- Wrote the done-when checks as shell commands and ran them. Checks 1, 2 and
  3b failed on the missing content and the missing commit.
- `templates/agent-identity.env.template`: added a four-line comment block just
  above the `AGENT_ROLES=` line, next to the existing roles comment. It names
  `swe.spec`, `swe.plan`, `swe.lead`, `swe.build`, `swe.test` and `swe.review`,
  says they are per-task-output roles that any number of nodes may hold, says
  that registering one means adding it to `AGENT_ROLES`, and gives an example.
  It also says no protocol, guidance or poller change is involved. The
  default `AGENT_ROLES=` value is unchanged, so no node picks up a pod role
  unless its operator adds one.
- `docs/operator-manual.md`, section 1 (Mental model): added one bullet,
  "SWE Pod roles". It names the six roles, calls them per-task-output roles
  (PROTOCOL §2), says each holder writes only its own
  `outbox/<agent-id>/<task-id>-result.md` so any number of nodes may hold each,
  says registering means adding the role to `AGENT_ROLES` in the node's
  `~/.agent-identity.env`, and says the protocol, guidance and poller treat
  them like any other role.
- Made no change to PROTOCOL, guidance, poller or skills (§3 OD4). Checked
  that adding comment lines is safe for the template's consumers: install
  copies the file, and `mesh-post.sh` reads `AGENT_ID=` and `REPO_PATH=` with
  start-anchored `sed`, so the example line `# AGENT_ROLES=...` is never
  parsed. Dotted role names already work as queue names (`slurm.submit`).
- Ran the checks again. Checks 1 and 3a pass. Checks 2 and 3b still fail
  because the commit was refused.
- Staged both files with `git add -- <touches>`. Ran the shareability check
  before the commit attempt and again afterwards. Both runs report 0 hits.
- Re-dispatch: checked the staged diff against the brief (both files, +11
  lines, nothing else staged or modified) and confirmed that every identity
  file parser in the repo skips `#` lines. The branch had moved to 7430aeb
  (T10 and T11 commits, none touching these files). Re-ran the checks, ran
  the shareability check, committed with `git commit -- <touches>`, found the
  remote head already an ancestor (merge-base exit 0, no rebase needed),
  pushed, and ran the checks and the shareability check again.

## Files

- `templates/agent-identity.env.template` (agent-mesh), +4 lines
- `docs/operator-manual.md` (agent-mesh), +7 lines
- Commit range: `agent-mesh 7430aeb..97b35a2` (one commit, 97b35a2, trailers
  `Change: build-swe-pod` and `Task: T9`), pushed to `change/build-swe-pod`
- `changes/build-swe-pod/tasks/T9-report.md` (space), this report, for the
  librarian to file

## Test output

Checkout paths are replaced with placeholders.

Check 1, done-when (1). All six role names in both files:

```sh
cd <agent-mesh checkout>
for f in templates/agent-identity.env.template docs/operator-manual.md; do
  for r in swe.spec swe.plan swe.lead swe.build swe.test swe.review; do
    grep -qF "$r" "$f" && echo "ok   $r $f" || echo "MISS $r $f"
  done
done
```

Red, before the content:

```
MISS swe.spec templates/agent-identity.env.template
MISS swe.plan templates/agent-identity.env.template
MISS swe.lead templates/agent-identity.env.template
MISS swe.build templates/agent-identity.env.template
MISS swe.test templates/agent-identity.env.template
MISS swe.review templates/agent-identity.env.template
MISS swe.spec docs/operator-manual.md
MISS swe.plan docs/operator-manual.md
MISS swe.lead docs/operator-manual.md
MISS swe.build docs/operator-manual.md
MISS swe.test docs/operator-manual.md
MISS swe.review docs/operator-manual.md
check1 exit=1
```

Green, after the content:

```
ok   swe.spec templates/agent-identity.env.template
ok   swe.plan templates/agent-identity.env.template
ok   swe.lead templates/agent-identity.env.template
ok   swe.build templates/agent-identity.env.template
ok   swe.test templates/agent-identity.env.template
ok   swe.review templates/agent-identity.env.template
ok   swe.spec docs/operator-manual.md
ok   swe.plan docs/operator-manual.md
ok   swe.lead docs/operator-manual.md
ok   swe.build docs/operator-manual.md
ok   swe.test docs/operator-manual.md
ok   swe.review docs/operator-manual.md
check1 exit=0
```

Re-dispatch: the same 12 `ok` lines and `check1 exit=0` on the staged tree,
and again read from `origin/change/build-swe-pod` after the push.

Check 1b, from the steps; an aid only, since the reviewer confirms the wording.
This counts the lines with `swe.` and with "per-task-output" in each file.

Red: `template swe-lines=0 per-task-output-lines=1` (that one is the existing
PROTOCOL-style wording) and `manual swe-lines=0 per-task-output-lines=0`.
Green: `template swe-lines=3 per-task-output-lines=2` and
`manual swe-lines=2 per-task-output-lines=1`.

Check 2, done-when (2). Files in the `Task: T9` commits are exactly the
touches:

```sh
shas=$(git log --format=%H --grep='^Task: T9$' change/build-swe-pod)
# empty -> fail; else list files and fail on any outside the two touches
```

Red, before the content: `no Task: T9 commit`, `check2 exit=1`.
After the content: still `no Task: T9 commit`, `check2 exit=1`, because the
commit was refused. Pre-commit proxy: `git status --short` lists only
`M  docs/operator-manual.md` and `M  templates/agent-identity.env.template`,
both staged, nothing else modified.

Re-dispatch, before the commit: `no Task: T9 commit`, `check2 exit=1`.
Green, after the commit:

```
commits: 97b35a2
docs/operator-manual.md
templates/agent-identity.env.template
check2 exit=0
```

Check 3a, standard close. swe-pod `SPEC.md` and `spec-process.*` are unchanged
since the latest `Task: T0` commit:

```sh
cd <swe-pod checkout>
t0=$(git log -1 --format=%h --grep='^Task: T0$')
git diff "$t0" -- SPEC.md 'spec-process.*'
```

Before: `T0=854e87c diff-bytes=0`. After: `T0=854e87c diff-bytes=0`. Passes
both times, since T9 does not touch swe-pod. Re-dispatch, before and after
the commit: `T0=854e87c diff-bytes=0`.

Check 3b, standard close. A `Task: T9` commit carrying both trailers is on
`origin/change/build-swe-pod`:

Red, before the content: `T9 commits on origin=0 with both trailers=0`.
After the content: `T9 commits on origin=0 with both trailers=0`. Still fails,
because the commit was refused. Re-dispatch, before the commit: the same.
Green, after the push: `T9 commits on origin=1 with both trailers=1`.

Push: `7430aeb..97b35a2  change/build-swe-pod -> change/build-swe-pod`.

Shareability check (§2.8), final line, staged before the commit attempt:
`shareability: 0 hits`. Run again after the refusal: `shareability: 0 hits`.
Re-dispatch, after staging: `shareability: 0 hits`. After the commit and
push: `shareability: 0 hits`.

Unit suite: agent-mesh has no unit suite (no test files or test runner in
the repo), so there is no `unit <p>/<n>` line.

## Concerns

- **Wording choice.** The brief says "registration only". I read that as
  documenting how a node opts in, so the template's default `AGENT_ROLES=`
  value is unchanged and no node holds a pod role by default. If the plan
  meant the template example to list the swe roles, the reviewer should flag
  it.

## Test suggestions

### T9.TS1 Six pod roles named as per-task-output roles

- for the tester: R7 and spec §14 M1. In the shipped node identity template
  and in the operator manual, confirm that each of `swe.spec`, `swe.plan`,
  `swe.lead`, `swe.build`, `swe.test` and `swe.review` is named, and that the
  text calls them per-task-output roles that any number of nodes may hold
  (PROTOCOL §2).
- for the reviewer: `templates/agent-identity.env.template`, the comment block
  just above the `AGENT_ROLES=` line. `docs/operator-manual.md` section 1,
  "Mental model", the "SWE Pod roles" bullet.

### T9.TS2 Registering a pod role means adding it to AGENT_ROLES

- for the tester: R7.S1. A node registers for a `swe.<role>` queue only by
  listing that role in `AGENT_ROLES` in its identity file. Confirm both files
  say so, and that a node whose identity file follows the template's default,
  unedited, holds no pod role.
- for the reviewer: the same two locations. The default `AGENT_ROLES=` value
  in the template is unchanged.

### T9.TS3 No protocol, guidance or poller change

- for the tester: spec §14 M1 and plan §3 OD4. Confirm that T9's commits
  change no file in PROTOCOL, guidance, the poller or any skill, and that
  the only change to the identity template is comments, so the template's
  consumers parse the file as before.
- for the reviewer: the diff of the `Task: T9` commit, 97b35a2. Check that
  the template's added lines all start with `#`, and that `mesh-post.sh`
  reads the identity file with start-anchored patterns.
