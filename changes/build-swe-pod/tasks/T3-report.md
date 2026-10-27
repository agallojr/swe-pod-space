# T3 report: Space template (D3)

## Status

BLOCKED

The content is written, and every done-when check passes on the working tree.
The commit step of the standard close is not done: the build session's
permission layer denied `git commit` (with `git add` already done), and after
that it also denied read-only git commands. Nothing is committed or pushed for
T3. Question for the lead: who commits the T3 files to `change/build-swe-pod`
in swe-pod? The operator can allow the commit for this builder, or the lead can
commit them under the same trailers.

## What I did

- Created `templates/space/` in swe-pod with the §2.1 files: `space.yaml`,
  `pod.yaml`, `AGENTS.md` and `README.md`, plus `changes/`, `tests/`,
  `decisions/`, `handoffs/`, `notes/` and `lore/`, each holding an empty
  `.gitkeep`. There is no `STATUS.md`.
- `space.yaml` has the 11 manifest keys. These are fixed: `space: 1`,
  `kind: project`, `writer_model: multi-actor`, the seven categories,
  `header_profile: shareable` and `may_reference: []`. These are placeholders:
  `id: proj:<project>`, `title` and `owners: [<handle>]`. These are defaults,
  taken from memory-spaces §3.1 and this space's own manifest:
  `visibility: shared` and `retention: until-archived`.
- `pod.yaml` follows spec §4 key for key: `pod`, `project`,
  `process: swe-pod-process@1`, `repos` (two placeholder repos, each with
  `remote` and `pin`), `depends` and
  `gates: {spec: human, plan: human-skim, merge: human}`.
- `AGENTS.md` gives the read order: `STATUS.md` (the `swe-pod` skill makes it
  if it is missing), `pod.yaml`, `PROCESS.md`, the change's spec, plan and
  ledger, then the brief. It adds the exception that a test-writing agent reads
  only its brief and `spec.md`. Its standing rules are specs first; one branch;
  every write goes through the librarian; the shareable profile; collision-free
  ids; and code repos hold only code, unit tests and shipped docs.
- `README.md` names the space with placeholders, points to `AGENTS.md` and
  `STATUS.md`, and shows the space layout from spec §8.
- Staged the 10 files by pathspec (`templates/space`) and ran the shareability
  check: 0 hits.

## Files

All in swe-pod, staged and not committed:

- `templates/space/space.yaml`
- `templates/space/pod.yaml`
- `templates/space/AGENTS.md`
- `templates/space/README.md`
- `templates/space/changes/.gitkeep`
- `templates/space/tests/.gitkeep`
- `templates/space/decisions/.gitkeep`
- `templates/space/handoffs/.gitkeep`
- `templates/space/notes/.gitkeep`
- `templates/space/lore/.gitkeep`

Staged diff: 10 files, 87 insertions.

## Test output

I ran the checks as one inline shell block, with no file left behind. The YAML
check uses Ruby's Psych parser (`Psych.safe_load`, based on libyaml), because
the shared tooling venv has no PyYAML. Nothing was installed.

The checks:

1. Each §2.1 file and each folder's `.gitkeep` exists, and there is no
   `STATUS.md`.
2. Both files load in a YAML parser. `space.yaml` has exactly the 11 keys, with
   the fixed values above. `pod.yaml` has the spec §4 keys in order,
   `process: swe-pod-process@1`, the three gates, and `remote` and `pin` for
   each repo.
3. `AGENTS.md` holds the test-agent exception, plus one phrase for each
   standing rule.
4. Part of the standard close: `git diff 854e87c -- SPEC.md spec-process.*`
   is empty.

Red, before writing:

```
== check 1: section 2.1 files and folders exist
FAIL missing templates/space/space.yaml
FAIL missing templates/space/pod.yaml
FAIL missing templates/space/AGENTS.md
FAIL missing templates/space/README.md
FAIL missing templates/space/changes/.gitkeep
FAIL missing templates/space/tests/.gitkeep
FAIL missing templates/space/decisions/.gitkeep
FAIL missing templates/space/handoffs/.gitkeep
FAIL missing templates/space/notes/.gitkeep
FAIL missing templates/space/lore/.gitkeep
ok   no templates/space/STATUS.md
== check 2: YAML loads; space.yaml has the 11 keys; pod.yaml fields
FAIL space.yaml: Errno::ENOENT
FAIL pod.yaml: Errno::ENOENT
== check 3: AGENTS.md test-agent exception and standing rules
FAIL AGENTS.md lacks: test-writing agent reads only its brief and `spec.md`
FAIL AGENTS.md lacks: one branch, `main`
FAIL AGENTS.md lacks: through the librarian
FAIL AGENTS.md lacks: shareable profile
FAIL AGENTS.md lacks: collision-free
FAIL AGENTS.md lacks: code, unit tests and shipped docs
== check 4 (part): SPEC.md and spec-process.* unchanged since the T0 commit
ok   git diff 854e87c -- SPEC.md spec-process.* is empty
== result: FAIL
```

Green, after writing:

```
== check 1: section 2.1 files and folders exist
ok   templates/space/space.yaml
ok   templates/space/pod.yaml
ok   templates/space/AGENTS.md
ok   templates/space/README.md
ok   templates/space/changes/.gitkeep
ok   templates/space/tests/.gitkeep
ok   templates/space/decisions/.gitkeep
ok   templates/space/handoffs/.gitkeep
ok   templates/space/notes/.gitkeep
ok   templates/space/lore/.gitkeep
ok   no templates/space/STATUS.md
== check 2: YAML loads; space.yaml has the 11 keys; pod.yaml fields
ok   space.yaml has exactly the 11 keys
ok   space.yaml kind
ok   space.yaml writer_model
ok   space.yaml header_profile
ok   space.yaml may_reference
ok   space.yaml categories
ok   pod.yaml keys in spec 4 order
ok   pod.yaml process
ok   pod.yaml gates
ok   pod.yaml repos remote and pin
== check 3: AGENTS.md test-agent exception and standing rules
ok   AGENTS.md: test-writing agent reads only its brief and `spec.md`
ok   AGENTS.md: one branch, `main`
ok   AGENTS.md: through the librarian
ok   AGENTS.md: shareable profile
ok   AGENTS.md: collision-free
ok   AGENTS.md: code, unit tests and shipped docs
== check 4 (part): SPEC.md and spec-process.* unchanged since the T0 commit
ok   git diff 854e87c -- SPEC.md spec-process.* is empty
== result: PASS
```

Hygiene, on the same run: no trailing whitespace, and no line over 88
characters.

Shareability check, run on the staged files (the final line):

```
shareability: 0 hits
```

The post-commit run was not possible: there is no T3 commit.

Standard close:

- shareability 0 hits: pass, on the staged files.
- SPEC.md and spec-process.* unchanged since T0: pass.
- committed with the trailers and pushed: not done (see Status).
- review: not yet run.

## Concerns

- **Commit and push are not done.** The 10 files are staged in the shared
  swe-pod checkout. The other builders commit by pathspec, so the T3 files do
  not go into their commits. Their shareability checks do scan all staged
  lines, though, so until T3 is committed those checks also cover the T3
  files. T3 has 0 hits, so this does not change their results.
- **Content beyond the listed steps,** for the reviewer to judge. `AGENTS.md`
  has a "Specs first" rule, which restates spec decision 1 and R1 and matches
  this space's own `AGENTS.md`. `README.md` has a layout block from spec §8 and
  cites `PROCESS.md` §12, the heading plan §2.2 sets and T1 writes.
- **pod.yaml shows two placeholder repos and one `depends` entry.** A project
  with one repo, or with three, edits those lines by hand. The template does not
  say how.

## Test suggestions

### T3.TS1 Fresh space before any STATUS.md exists
- for the tester: Run R18.S1 against a space made from the template, holding
  one approved change and no `STATUS.md` yet. A fresh agent asked "where are
  we?" must still name that change's state and next task. This is fragile
  because the first item in the read order is the missing file.
- for the reviewer: swe-pod `templates/space/AGENTS.md:9`, read-order item 1
  (lines 9 to 11).

### T3.TS2 Test-writing agent with plan, ledger and reports present
- for the tester: Under R9, open a test-writing agent in a space made from the
  template, where the change folder also holds `plan.md`, `ledger.md` and
  builder reports. Check that it reads only its brief and `spec.md`. This is
  fragile because the read order just above the exception sends every other
  agent to `plan.md` and `ledger.md`.
- for the reviewer: swe-pod `templates/space/AGENTS.md:18`, the exception
  paragraph (lines 18 to 21).

### T3.TS3 A placeholder repo left in pod.yaml
- for the tester: Under R23.S2 and the go, make a space from the template whose
  `pod.yaml` still holds a placeholder repo, with no real remote or pin. At the
  go, the lead must not create a branch in that repo or run verify against it.
- for the reviewer: swe-pod `templates/space/pod.yaml:4`, the `repos` block
  and `depends` (lines 4 to 7).
