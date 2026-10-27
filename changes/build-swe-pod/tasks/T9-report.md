# T9 report

- change: build-swe-pod
- task: T9
- role: build
- repo: agent-mesh

## Status

BLOCKED

The content is written and staged, and every content check passes. The commit
step was refused by the build node's permission layer (auto-mode classifier,
reason "Git Destructive") on the first `git commit` attempt. No commit was made
and nothing was pushed. The two files sit staged, by pathspec, in the shared
agent-mesh build checkout on `change/build-swe-pod` at 8ee5364. The standard
close's commit and push items are therefore open, and so is done-when (2),
which is checked against the `Task: T9` commits.

To close: someone with commit authority on that checkout (the lead, or a
re-dispatched builder once the permission is granted) runs the three commands
under "Concerns". No content change is needed.

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

## Files

- `templates/agent-identity.env.template` (agent-mesh), +4 lines, staged, not
  committed
- `docs/operator-manual.md` (agent-mesh), +7 lines, staged, not committed
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

Check 3a, standard close. swe-pod `SPEC.md` and `spec-process.*` are unchanged
since the latest `Task: T0` commit:

```sh
cd <swe-pod checkout>
t0=$(git log -1 --format=%h --grep='^Task: T0$')
git diff "$t0" -- SPEC.md 'spec-process.*'
```

Before: `T0=854e87c diff-bytes=0`. After: `T0=854e87c diff-bytes=0`. Passes
both times, since T9 does not touch swe-pod.

Check 3b, standard close. A `Task: T9` commit carrying both trailers is on
`origin/change/build-swe-pod`:

Red, before the content: `T9 commits on origin=0 with both trailers=0`.
After the content: `T9 commits on origin=0 with both trailers=0`. Still fails,
because the commit was refused.

Shareability check (§2.8), final line, staged before the commit attempt:
`shareability: 0 hits`. Run again after the refusal: `shareability: 0 hits`.

## Concerns

- **The commit and push were refused, so T9 is not closed.** The refusal came
  from the node's permission layer, not from the git gate, and I did not try
  to get around it. These commands, run from the agent-mesh build checkout
  with its absolute path in place of `<checkout>`, close it unchanged:

  ```
  git -C <checkout> commit -m "Register the six swe roles in the identity template and operator manual" --trailer "Change: build-swe-pod" --trailer "Task: T9" --trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -- templates/agent-identity.env.template docs/operator-manual.md
  git -C <checkout> push origin change/build-swe-pod
  ```

  Then run checks 2 and 3b again. The files are already staged, but the
  commit uses pathspecs, so it commits only these two files whatever else is
  staged.
- **Staged state in a shared index.** My two files stay staged in the shared
  checkout until someone commits them. A parallel builder's `git commit --
  <its touches>` leaves them out, so they cannot leak into another task's
  commit. Another task's shareability check does scan staged lines, though,
  so it will scan these 11 lines too. They gave 0 hits.
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
- for the reviewer: the diff of the `Task: T9` commits, once made. Check that
  the template's added lines all start with `#`, and that `mesh-post.sh`
  reads the identity file with start-anchored patterns.
