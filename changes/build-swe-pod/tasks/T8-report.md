# T8 report: swe-pod shipped docs and the G1 to G3 text

- change: build-swe-pod
- task: T8
- actor: agallojr/build

## Status

DONE

## What I did

- Wrote the done-when checks first, as one Python script in a scratch
  directory outside every repo (deleted after the run). I ran it on the
  branch head before any edit and watched it fail on the missing content
  (red). Then I wrote the content, and it passed (green).
- **README.md (extended).** I kept every T0 line: the title, the intro, the
  three bullets with the `SPEC.md` pointer. I replaced only the status
  paragraph, rewritten to the post-merge state: version 1
  (`swe-pod-process@1`) and its deliverables, with first use at the pilot
  (`SPEC.md` §16). Then I added:
  - a pointer to `INSTALL.md`;
  - `## How it works`: a summary of the five stages as `PROCESS.md` has
    them, including sharded verify and its rule in plain words (spec R24),
    plus where things live, the roles and "no commands";
  - `## Layout`: every §2.1 path as a full repo-relative path, one per
    line, with a short description;
  - `## Use` with `### Single seat` and `### On a mesh`. Single seat says
    that when no mesh is present the pod depends on agent-mesh's
    `space-librarian` skill to file every record. On a mesh covers roles,
    mesh dispatch with `project:` and the bus-relative role definition path,
    results under `files:`, build staying local, shareable ledger lines, and
    the fences, including the 60 s heavy-check rule (R13).
- **INSTALL.md (new).** It covers:
  - what you need;
  - linking `agents/swe-*.md` and `skills/swe-pod/` into the global Claude
    config, `~/.claude/` by default, plus agent-mesh's `space-librarian` for
    single seat, with an explicit "never into a project";
  - a check of the links;
  - mounting swe-pod in a bus at `<bus>/swe-pod/` on a mesh;
  - starting a Project Space from `templates/space/` plus `PROCESS.md`,
    filling the placeholders, and the human's first commit;
  - `## Rules for your guidance overlay`, with G1, G2 and G3 of spec §14 in
    generic terms, labeled `G1.` to `G3.`.
- Left `SPEC.md` and `spec-process.*` alone. Staged both files by
  pathspec, ran the shareability check, committed by pathspec with both
  trailers, fetched, found the remote head already an ancestor (so no
  rebase), pushed, and ran the checks and the shareability check again.

## Files

All in swe-pod, on `change/build-swe-pod`, one commit (6f8ed78), range
`swe-pod 5aacf3f..6f8ed78`:

- swe-pod/README.md: changed. Status paragraph rewritten; How it works,
  Layout and Use added (148 lines added, 2 deleted).
- swe-pod/INSTALL.md: created. Install, starting a space, and the overlay
  rules G1 to G3 (136 lines).

## Test output

The checks, one script, run with the shared tooling venv's Python:

1. Every repo-relative path in README or INSTALL exists on the branch. A
   path is taken from inline code, from words in fenced blocks and from bare
   file names in prose. A `<swe-pod>/` prefix is stripped and the rest is
   checked. Paths under `~/`, `/`, `<bus>/`, `<space>/`, `<project>/` or
   `<agent-mesh>/`, tokens with a placeholder, and `<owner>/<repo>` slugs
   whose owner is in the space's `space.yaml` are listed as `skip`, not
   checked.
2. The README diff deletes no line except the status paragraph, and the
   README names `SPEC.md`. The diff base is HEAD before the commit, and the
   parent of the `Task: T8` commit after it. The README layout lists every
   §2.1 path at the start of a line. It has `### Single seat` and
   `### On a mesh`, its Use section names `space-librarian`, and it says
   what holds when no mesh is present.
3. INSTALL has `## Rules for your guidance overlay` whose rules are
   labeled exactly `G1`, `G2`, `G3`, in order. It links `agents/swe-*.md`
   and `skills/swe-pod` into `~/.claude/agents/` and `~/.claude/skills/`,
   says never into a project, and starts a space from `templates/space/`.
4. Part of the standard close: `git diff 74d23f1 -- SPEC.md spec-process.*`
   is empty (74d23f1 is the latest `Task: T0` commit). Hygiene: no trailing
   whitespace and no line over 88 characters.

Red, on swe-pod 5aacf3f before any edit. In the two `skip` lines for the
T0 repo slugs, the run printed the owner handle; the script now prints it
as `<owner>`, and this copy is shown that way.

```
== check 1: every repo-relative path in README or INSTALL exists
FAIL INSTALL.md exists
ok   README.md: SPEC.md
skip README.md: <owner>/agent-mesh (repo-slug, not swe-pod-relative)
skip README.md: proj:swe-pod (other, not swe-pod-relative)
skip README.md: <owner>/swe-pod-space (repo-slug, not swe-pod-relative)
== check 2: README diff deletes only the status line; names SPEC.md
ok   README diff vs HEAD deletes 0 lines, 0 outside the status line
ok   README names `SPEC.md`
FAIL README has a ## Layout section
FAIL README layout lists SPEC.md
FAIL README layout lists spec-process.d2
FAIL README layout lists spec-process.svg
FAIL README layout lists spec-process.png
FAIL README layout lists PROCESS.md
FAIL README layout lists agents/swe-spec.md
FAIL README layout lists agents/swe-plan.md
FAIL README layout lists agents/swe-lead.md
FAIL README layout lists agents/swe-build.md
FAIL README layout lists agents/swe-test.md
FAIL README layout lists agents/swe-review.md
FAIL README layout lists templates/space/space.yaml
FAIL README layout lists templates/space/pod.yaml
FAIL README layout lists templates/space/AGENTS.md
FAIL README layout lists templates/space/README.md
FAIL README layout lists templates/space/changes/
FAIL README layout lists templates/space/tests/
FAIL README layout lists templates/space/decisions/
FAIL README layout lists templates/space/handoffs/
FAIL README layout lists templates/space/notes/
FAIL README layout lists templates/space/lore/
FAIL README layout lists templates/records/spec.md
FAIL README layout lists templates/records/plan.md
FAIL README layout lists templates/records/brief.md
FAIL README layout lists templates/records/test-brief.md
FAIL README layout lists templates/records/report.md
FAIL README layout lists templates/records/review.md
FAIL README layout lists templates/records/evidence.md
FAIL README layout lists templates/records/ledger.md
FAIL README layout lists templates/records/handoff.md
FAIL README layout lists templates/records/final-report.md
FAIL README layout lists skills/swe-pod/SKILL.md
FAIL README layout lists skills/swe-pod/status-format.md
FAIL README layout lists README.md
FAIL README layout lists INSTALL.md
FAIL README has ### Single seat
FAIL README has ### On a mesh
FAIL README Use names agent-mesh's `space-librarian`
FAIL README says when no mesh is present
== check 3: INSTALL overlay section with G1 to G3
FAIL INSTALL has ## Rules for your guidance overlay
FAIL three rules labeled G1 to G3: []
FAIL INSTALL links agents/swe-*.md and skills/swe-pod/
FAIL INSTALL targets the global Claude config
FAIL INSTALL says never into a project
FAIL INSTALL starts a space from templates/space/
== check 4 (part): standard close and hygiene
ok   git diff 74d23f1 -- SPEC.md spec-process.* is empty
ok   README.md: no trailing whitespace
ok   README.md: no line over 88 characters
ok   INSTALL.md: no trailing whitespace
ok   INSTALL.md: no line over 88 characters
== result: FAIL (47 failed)
```

Two parts pass at red, as they should: with no edit there is no deletion,
and `SPEC.md` and the hygiene rules hold already. The 47 failures are all
missing content.

Green, on swe-pod 6f8ed78 after the commit and push. After the red run I
made two changes to the script. The layout check now matches each path at
the start of a line, not as a substring. The diff base label now prints the
resolved sha. The 45 `skip` lines are below the `ok` lines.

```
== check 1: every repo-relative path in README or INSTALL exists
ok   INSTALL.md exists
ok   README.md: SPEC.md
ok   README.md: INSTALL.md
ok   README.md: PROCESS.md
ok   README.md: spec-process.d2
ok   README.md: spec-process.svg
ok   README.md: spec-process.png
ok   README.md: agents/swe-spec.md
ok   README.md: agents/swe-plan.md
ok   README.md: agents/swe-lead.md
ok   README.md: agents/swe-build.md
ok   README.md: agents/swe-test.md
ok   README.md: agents/swe-review.md
ok   README.md: templates/space/space.yaml
ok   README.md: templates/space/pod.yaml
ok   README.md: templates/space/AGENTS.md
ok   README.md: templates/space/README.md
ok   README.md: templates/space/changes/
ok   README.md: templates/space/tests/
ok   README.md: templates/space/decisions/
ok   README.md: templates/space/handoffs/
ok   README.md: templates/space/notes/
ok   README.md: templates/space/lore/
ok   README.md: templates/records/spec.md
ok   README.md: templates/records/plan.md
ok   README.md: templates/records/brief.md
ok   README.md: templates/records/test-brief.md
ok   README.md: templates/records/report.md
ok   README.md: templates/records/review.md
ok   README.md: templates/records/evidence.md
ok   README.md: templates/records/ledger.md
ok   README.md: templates/records/handoff.md
ok   README.md: templates/records/final-report.md
ok   README.md: skills/swe-pod/SKILL.md
ok   README.md: skills/swe-pod/status-format.md
ok   README.md: README.md
ok   README.md: templates/space/
ok   INSTALL.md: agents/swe-*.md
ok   INSTALL.md: skills/swe-pod
ok   INSTALL.md: templates/space/
ok   INSTALL.md: templates/space/.
ok   INSTALL.md: PROCESS.md
ok   INSTALL.md: templates/records/
ok   INSTALL.md: README.md
== check 2: README diff deletes only the status line; names SPEC.md
ok   README diff vs 5aacf3f deletes 2 lines, 0 outside the status line
ok   README names `SPEC.md`
ok   README has a ## Layout section
ok   README layout lists SPEC.md
ok   README layout lists spec-process.d2
ok   README layout lists spec-process.svg
ok   README layout lists spec-process.png
ok   README layout lists PROCESS.md
ok   README layout lists agents/swe-spec.md
ok   README layout lists agents/swe-plan.md
ok   README layout lists agents/swe-lead.md
ok   README layout lists agents/swe-build.md
ok   README layout lists agents/swe-test.md
ok   README layout lists agents/swe-review.md
ok   README layout lists templates/space/space.yaml
ok   README layout lists templates/space/pod.yaml
ok   README layout lists templates/space/AGENTS.md
ok   README layout lists templates/space/README.md
ok   README layout lists templates/space/changes/
ok   README layout lists templates/space/tests/
ok   README layout lists templates/space/decisions/
ok   README layout lists templates/space/handoffs/
ok   README layout lists templates/space/notes/
ok   README layout lists templates/space/lore/
ok   README layout lists templates/records/spec.md
ok   README layout lists templates/records/plan.md
ok   README layout lists templates/records/brief.md
ok   README layout lists templates/records/test-brief.md
ok   README layout lists templates/records/report.md
ok   README layout lists templates/records/review.md
ok   README layout lists templates/records/evidence.md
ok   README layout lists templates/records/ledger.md
ok   README layout lists templates/records/handoff.md
ok   README layout lists templates/records/final-report.md
ok   README layout lists skills/swe-pod/SKILL.md
ok   README layout lists skills/swe-pod/status-format.md
ok   README layout lists README.md
ok   README layout lists INSTALL.md
ok   README has ### Single seat
ok   README has ### On a mesh
ok   README Use names agent-mesh's `space-librarian`
ok   README says when no mesh is present
== check 3: INSTALL overlay section with G1 to G3
ok   INSTALL has ## Rules for your guidance overlay
ok   three rules labeled G1 to G3: ['G1', 'G2', 'G3']
ok   INSTALL links agents/swe-*.md and skills/swe-pod/
ok   INSTALL targets the global Claude config
ok   INSTALL says never into a project
ok   INSTALL starts a space from templates/space/
== check 4 (part): standard close and hygiene
ok   git diff 74d23f1 -- SPEC.md spec-process.* is empty
ok   README.md: no trailing whitespace
ok   README.md: no line over 88 characters
ok   INSTALL.md: no trailing whitespace
ok   INSTALL.md: no line over 88 characters
== result: PASS (0 failed)
skip README.md: <owner>/agent-mesh (repo-slug, not swe-pod-relative)
skip README.md: proj:swe-pod (other, not swe-pod-relative)
skip README.md: <owner>/swe-pod-space (repo-slug, not swe-pod-relative)
skip README.md: change/<id> (other, not swe-pod-relative)
skip README.md: <space>/STATUS.md (other, not swe-pod-relative)
skip README.md: <bus>/spaces/ (other, not swe-pod-relative)
skip README.md: <bus>/spaces.yaml (other, not swe-pod-relative)
skip README.md: runs: mesh (other, not swe-pod-relative)
skip README.md: role:swe.<role> (other, not swe-pod-relative)
skip README.md: project: proj:<name> (other, not swe-pod-relative)
skip README.md: swe-pod/agents/swe-<role>.md (other, not swe-pod-relative)
skip INSTALL.md: <swe-pod> (other, not swe-pod-relative)
skip INSTALL.md: <agent-mesh> (other, not swe-pod-relative)
skip INSTALL.md: ~/.claude/ (other, not swe-pod-relative)
skip INSTALL.md: ~/.claude/agents (other, not swe-pod-relative)
skip INSTALL.md: ~/.claude/skills (other, not swe-pod-relative)
skip INSTALL.md: ~/.claude/agents/ (other, not swe-pod-relative)
skip INSTALL.md: ~/.claude/skills/swe-pod (other, not swe-pod-relative)
skip INSTALL.md: <agent-mesh>/skills/space-librarian (other, not swe-pod-relative)
skip INSTALL.md: ~/.claude/skills/space-librarian (other, not swe-pod-relative)
skip INSTALL.md: <project>/.claude/ (other, not swe-pod-relative)
skip INSTALL.md: <space>/pod.yaml (other, not swe-pod-relative)
skip INSTALL.md: /agents (other, not swe-pod-relative)
skip INSTALL.md: ~/.claude/agents/swe-*.md (other, not swe-pod-relative)
skip INSTALL.md: ~/.claude/skills/swe-pod/SKILL.md (other, not swe-pod-relative)
skip INSTALL.md: <bus>/swe-pod/ (other, not swe-pod-relative)
skip INSTALL.md: <bus>/swe-pod (other, not swe-pod-relative)
skip INSTALL.md: swe-pod/agents/swe-<role>.md (other, not swe-pod-relative)
skip INSTALL.md: <bus> (other, not swe-pod-relative)
skip INSTALL.md: <swe-pod (other, not swe-pod-relative)
skip INSTALL.md: url> (other, not swe-pod-relative)
skip INSTALL.md: swe.<role> (other, not swe-pod-relative)
skip INSTALL.md: <space> (other, not swe-pod-relative)
skip INSTALL.md: <space>/ (other, not swe-pod-relative)
skip INSTALL.md: <placeholder> (other, not swe-pod-relative)
skip INSTALL.md: <space>/space.yaml (other, not swe-pod-relative)
skip INSTALL.md: proj:<name> (other, not swe-pod-relative)
skip INSTALL.md: <space>/README.md (other, not swe-pod-relative)
skip INSTALL.md: <space>/AGENTS.md (other, not swe-pod-relative)
skip INSTALL.md: <space>/STATUS.md (other, not swe-pod-relative)
skip INSTALL.md: <space (other, not swe-pod-relative)
skip INSTALL.md: <bus>/spaces/ (other, not swe-pod-relative)
skip INSTALL.md: <bus>/spaces.yaml (other, not swe-pod-relative)
skip INSTALL.md: access: rw (other, not swe-pod-relative)
skip INSTALL.md: change/<id> (other, not swe-pod-relative)
```

The two deleted README lines are the old status paragraph, which T0 wrapped
over two lines:

```
-Status: specified and approved; the deliverables (process document, role
-briefs, Project Space template, skill) are being planned.
```

Shareability check, on the staged files before the commit (last line):

```
shareability: 0 hits
```

Shareability check, after the commit and push, on the `Task: T8` commit
(last line):

```
shareability: 0 hits
```

Install commands: I ran the `ln -sf <files> <dir>/` and `ln -sfn <dir>
<link>` forms twice each in a throwaway directory under `/tmp` (BSD `ln` on
macos-laptop). Both make the expected links, and a re-run leaves them
unchanged. I did not run them against the real global config; the operator
installs at T36.

Unit suite: swe-pod has no unit suite. It holds Markdown and YAML only, and
nothing in it is compiled or run (unit 0/0).

Standard close:

- shareability 0 hits: pass, before and after the commit.
- `SPEC.md` and `spec-process.*` unchanged since 74d23f1: pass.
- committed by pathspec with `Change: build-swe-pod` and `Task: T8`, and
  pushed: pass. `origin/change/build-swe-pod` is at 6f8ed78. The merge-base
  check exited 0, so no rebase was run.
- review (T28): not yet run.

## Concerns

- **Status line spans two physical lines.** T0's status is one sentence
  wrapped over two lines. T8 deletes both and writes a three-line status
  paragraph. Done-when (2) is met only if "the status line" means that
  paragraph, which is how I read it. No other line is deleted.
- **Content beyond the listed steps,** for the review to judge:
  - README `## How it works`. A process summary, since T38 checks that "the
    swe-pod README's process summary still matches" after T37.
  - The sharded-verify sentence in it. This states spec R24 in plain words
    before T37 writes R24 into `PROCESS.md`. If T37's wording differs, T38
    should catch it.
  - INSTALL `### On a mesh`. The swe-pod submodule mount at `<bus>/swe-pod/`
    (spec open call 11). It is needed because a mesh task names its role
    definition relative to the bus root, as `swe-pod/agents/swe-<role>.md`.
  - INSTALL's first-commit and mount-a-space steps.
- **G2 and G3 wording.** G2 is close to verbatim; the two base rules it
  names are quoted. G3 swaps "the solver-run budget policy" for "the budget
  policy on long runs, such as a solver-run budget policy", so it reads in
  generic terms. G3 adds "The policy's caps, and the points where it stops
  to ask, still hold", and the section ends with "These rules loosen nothing
  else" (spec §7). These are clarifications, not new rules.
- **`/agents` claim not exercised.** INSTALL says a new session's `/agents`
  lists the six `swe-*` agents once the links exist. I did not open a
  session with the links in place, because that needs the real global
  config, which is installed at T36.
- **T0 lines kept as they are.** The README's T0 bullets name the product
  and space repos by their owner-qualified slugs. The step says keep every
  line, so they stay. They are not part of T8's added lines.

## Test suggestions

### T8.TS1 Install from INSTALL alone, then a local dispatch
- for the tester: Under R7.S2, follow INSTALL's install section on a clean
  user-level config with no role definitions. Then have a lead dispatch a
  `runs: local` build task. The fresh subagent must start as type
  `swe-build`, not general-purpose, and its report must land at the brief's
  path. Expected failures: no `swe-*` agent type is found, or the
  definitions end up inside the project rather than the user config.
- for the reviewer: swe-pod/INSTALL.md:18-49. Fragile: `ln -sf` with a glob
  into a directory that may itself be a symlink, and `-n` on the skill link.
  Nothing checks that `<swe-pod>` is absolute, and a relative path makes
  dangling links.

### T8.TS2 Single seat with only what INSTALL installs
- for the tester: Under R17.S2, set up a single-seat session with no bus,
  core or lore, installed only as INSTALL says (swe-pod plus agent-mesh's
  `space-librarian`). Have it file one record that carries a home path.
  Expected failure: the session commits the record directly, with no
  profile, reference or id check, or the librarian skill is not available.
- for the reviewer: swe-pod/INSTALL.md:12-16 and 30-36 (the librarian
  dependency and its link), and swe-pod/README.md:111-115 (single seat says
  every record goes through it). Fragile: on a mesh node, the claim that
  the installer already linked the skill holds only for nodes installed
  after the skill existed.

### T8.TS3 Heavy verify after the go, with the human present
- for the tester: Under R13.S1, give a deployment G3 in its overlay. Then,
  after the human's go and with the human present, have the lead come to
  dispatch a verify that includes a check expected to take over 60 s.
  Expected failure: the lead reads G3 ("counts as operator-posted") as
  leave to skip the ask, and dispatches without first giving the human the
  command, the caps and the expected wall time.
- for the reviewer: swe-pod/INSTALL.md:129-136 (G3 and the closing
  paragraph) and swe-pod/README.md:152-155 (the fences bullet). Fragile:
  G3 classifies the task under the budget policy, while the live-session
  ask comes from `PROCESS.md` §11. The text says the two stack, but only
  the closing paragraph says so.
