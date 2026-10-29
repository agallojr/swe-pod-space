# T10 report (verify fix)

- change: build-swe-pod
- task: T10 (verify fix)
- actor: agallojr/build

## Status
DONE

## What I did
- The verify finding: section 1 of `skills/space-librarian/SKILL.md` held the
  check script inline, and its shell and awk use positional parameters. When
  the skill is invoked with arguments, the skill tool substitutes those with
  the call's arguments, so a copied-out script was corrupted, and agents
  under test rebuilt it by hand. I checked the finding against the code: the
  script block (186 lines) held 27 lines with `$<digit>` text, and none was
  outside the block.
- Wrote the done-when checks first, as a harness in a scratch directory
  outside every repo, and ran it red: no `check.sh`, 27 matching lines in
  `SKILL.md`, and the throwaway-space runs failing on the missing file.
- Extracted the `sh` block of `SKILL.md` at `1367f65` and wrote it unchanged
  as `skills/space-librarian/check.sh` (T42's shard evidence form included).
  It has no shebang, since it must be byte-identical; it is run with `sh`.
- In `SKILL.md` section 1, replaced "Copy the script into a file in a
  scratch directory ..." and the inline block with a pointer to the shipped
  file, run as
  `SPACE=<space root> sh <skill dir>/check.sh <space path> ...`, where
  `<skill dir>` is the skill's directory, and "never copy it into the space
  or rebuild it by hand". The paragraph on `BUS=<bus root>`, `REFUSED`,
  `CHECKED`, portability and the temporary directory is unchanged, as is the
  prose of the three checks. The section's lead line now reads "as the check
  script `check.sh` runs them" (it said "the script below"). Section 2, the
  desk run and the never list are unchanged; their "check script" wording
  still holds.
- Checked how the skill ships. The installer (`install/install.sh` step 6)
  and the manual loop in `INSTALL.md` symlink each whole skill directory, so
  `check.sh` ships with the skill, as `mesh-post.sh` and `mesh-scan-loop.sh`
  already do. No text outside `SKILL.md` names the script or tells an agent
  to copy it out (grep over the repo), so nothing else changed.
- Ran the harness green, committed by pathspec, ran the shareability check,
  fetched, ran the merge-base check (exit 0, so no rebase) and pushed. The
  scratch directory is deleted.

## Files
- agent-mesh/skills/space-librarian/check.sh: created. The section 1 check
  script, byte-identical to the block in `SKILL.md` at `1367f65`.
- agent-mesh/skills/space-librarian/SKILL.md: changed. Section 1 points to
  `check.sh` instead of holding the script; 5 lines added, 193 removed.
- Commit range: agent-mesh `1367f65..bbd19a2`. One commit, `bbd19a2`, on
  `change/build-swe-pod`, with trailers `Change: build-swe-pod`, `Task: T10`
  and `Co-Authored-By`. It is pushed; `origin/change/build-swe-pod` is at
  `bbd19a2`.

## Test output

Machine paths in the output below are written as `<checkout>` (the
agent-mesh build checkout) and `<scratch>` (the scratch directory).

### Done-when 1 to 3 (harness)
- command: `sh harness.sh <checkout> <scratch>/SKILL-1367f65.md`, run in the
  scratch directory, which is outside every repo. The second argument is
  `git show 1367f65:skills/space-librarian/SKILL.md`. The harness extracts
  that file's unindented `sh` block, compares it with `check.sh` (`cmp`),
  counts `grep -nE '\$[0-9]'` lines in `SKILL.md`, then builds a throwaway
  space (`git init`, a `space.yaml`, no remote) with evidence records made at
  run time under `changes/demo/evidence/`, and runs
  `SPACE=<space root> sh <checkout>/skills/space-librarian/check.sh ...` on
  them. `BUS` is left to the script's default.
- red (before the change, 0.42 s wall time):

```
  | block: 186 lines, 8117 bytes
  | diff: <checkout>/skills/space-librarian/check.sh: No such file or directory
FAIL 1 check.sh is byte-identical to the base script block
  | grep -nE '$[0-9]' SKILL.md: 27 lines
FAIL 2 SKILL.md has no $<digit> text
PASS 3 space has no remote
  | sh: <checkout>/skills/space-librarian/check.sh: No such file or directory
FAIL 3 CHECKED ev-20261028T0100Z and ev-20261028T0100Z-T19a together
  | sh: <checkout>/skills/space-librarian/check.sh: No such file or directory
FAIL 3 REFUSED ev-20261028T0100Z-T19 as id
harness: 1 pass, 4 fail
```

- green (after the change, 2.03 s wall time):

```
  | block: 186 lines, 8117 bytes
PASS 1 check.sh is byte-identical to the base script block
  | grep -nE '$[0-9]' SKILL.md: 0 lines
PASS 2 SKILL.md has no $<digit> text
PASS 3 space has no remote
  | CHECKED changes/demo/evidence/20261028T0100Z.md
  | CHECKED changes/demo/evidence/20261028T0100Z-T19a.md
PASS 3 CHECKED ev-20261028T0100Z and ev-20261028T0100Z-T19a together
  | REFUSED changes/demo/evidence/20261028T0100Z-T19.md: id line 2
PASS 3 REFUSED ev-20261028T0100Z-T19 as id
harness: 5 pass, 0 fail
```

### Done-when 1 and 2, run directly in the checkout
- command: `diff <scratch>/block.sh skills/space-librarian/check.sh`, then
  `shasum -a 256` of both, then
  `grep -nE '\$[0-9]' skills/space-librarian/SKILL.md`.
- green:

```
diff exit 0
bce6a070939bb47b
bce6a070939bb47b
grep exit 1
```

  (`shasum` output cut to its first 16 hex digits; `grep` printed no line.)
  Also `grep -nE '\$\{?(ARGUMENTS|CLAUDE)'` on `SKILL.md` finds nothing.
- syntax: `dash -n` and `ksh -n` on `check.sh` both pass. `ksh -n` prints
  one "use braces" warning at line 109; that text is unchanged from the
  inline script.

### Done-when 4, standard close
- shareability: 0 hits (`shareability: 0 hits`, after the commit and before
  the push, over the `Task: T10` diff).
- swe-pod `git diff 74d23f1 -- SPEC.md spec-process.*` is empty (0 lines).
  `74d23f1` is the latest `Task: T0` commit.
- `bbd19a2` holds only the two files above, has both trailers, and was
  committed by pathspec. `merge-base --is-ancestor
  origin/change/build-swe-pod HEAD` exited 0, so I skipped the rebase. The
  push went `1367f65..bbd19a2`.
- The review is pending.

### Unit suite
agent-mesh has no unit suite (none present).

## Concerns
- `check.sh` is mode 100644 with no shebang, since done-when 1 requires it to
  be byte-identical to the block. `SKILL.md` says to run it with `sh`, and it
  must not be executed directly.
- An agent must know `<skill dir>`. The skill loader reports a skill's base
  directory when it loads it, and `mesh-on` already relies on the same
  pattern for `poller-prompt.md` and `mesh-scan-loop.sh`. The skill is
  installed only at T36, so before then a caller runs `check.sh` from the
  agent-mesh checkout.
- GNU userland is untested here: this node has only BSD tools. The script
  text is unchanged, so this is as before.

## Test suggestions

### T10.TS9 The skill invoked with arguments files the same way
- for the tester: R17.S2 and R16. A single-seat session with no bus invokes
  the librarian skill with arguments (the space root and record paths), and
  hands it one shareable record and one record carrying a home path. The
  failure to look for: the agent builds or edits a check of its own, writes a
  script file inside the space, or gives a result that differs from what the
  same records get when the skill is invoked with no arguments.
- for the reviewer: agent-mesh/skills/space-librarian/SKILL.md:109-123, the
  pointer to `<skill dir>/check.sh`. The skill tool substitutes `$<digit>`
  text in `SKILL.md`, so any later edit that inlines shell or awk with
  positional parameters into `SKILL.md` brings the corruption back. The
  script itself, agent-mesh/skills/space-librarian/check.sh, uses them
  throughout, which is safe only because the skill tool does not read it.

### T10.TS10 An installed node finds the check script
- for the tester: R17 and M5. On a node where the installer has linked the
  skills, a librarian files a record into a space through the installed
  skill. The failure to look for: the check script cannot be found at the
  installed skill's location, or the librarian falls back to a hand-built
  check.
- for the reviewer: agent-mesh/install/install.sh:211-226 links whole skill
  directories, so `check.sh` follows `SKILL.md`; a node that linked only
  `SKILL.md` would miss it. `check.sh` is mode 100644 and has no shebang, so
  it works only when run with `sh`, as the skill says.
