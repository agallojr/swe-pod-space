---
task: T10
diff: agent-mesh 1367f65..bbd19a2
verdict: pass
---

This is the fix-mode review of the verify fix to T10. It covers one new commit with trailer `Task: T10`: `bbd19a2` ("Ship the space-librarian check script as check.sh beside SKILL.md"), whose parent is `1367f65`. It is checked against the one verify finding under fix. That finding: the section 1 check script was inline in `skills/space-librarian/SKILL.md`, and its `$0` to `$3` text in shell and awk was replaced by the skill tool's arguments when the skill was invoked with arguments, so a copied-out script was corrupted.

## Spec compliance

- **Finding under fix: closed.** This is shown by the diff alone:
  - The 186-line `sh` block is gone from SKILL.md. At `bbd19a2`, `grep -nE '\$[0-9]'` on SKILL.md prints no line (exit 1).
  - No `$ARGUMENTS`, `${...}`, `$@` or `$*` text is left, so nothing in the file is open to the skill tool's substitution.
  - The script is now `skills/space-librarian/check.sh`. The skill tool does not read that file, so its positional parameters reach `sh` and `awk` as written.
- **check.sh is byte-identical to the old block.** I extracted the unindented sh block of SKILL.md at `1367f65` (lines 125-310) and compared it with `check.sh` at `bbd19a2`.
  - `cmp` exits 0. Both are 186 lines and 8117 bytes, with the same sha256 (prefix `bce6a070939bb47b`).
  - The T42 shard form `ev-<UTC>(-T<n><letter>)?` is in it.
  - The file is mode 100644 with no shebang, as the report says.
- **Section 1 pointer (SKILL.md:109-115), read in full:**
  - It says what the file is (`check.sh`), where it is (beside SKILL.md, in the skill's directory, `<skill dir>`), and how to run it (with `sh`, unmodified).
  - The call is `SPACE=<space root> sh <skill dir>/check.sh <space path> ...`. This matches the script's interface: `SPACE` is required (`${SPACE:?}`), record paths are relative to the space root, and a leading `./` is stripped.
  - The paragraph after it (lines 117-123) is unchanged and still right for the shipped file:
    - `BUS=<bus root>` is optional;
    - `REFUSED ...` and `CHECKED <space path>` are working lines;
    - the script is POSIX sh, using `grep -E`, `sed -E` and POSIX awk;
    - it uses its own temporary directory and removes it on exit.
  - "never copy it into the space or rebuild it by hand" replaces "copy the script into a file in a scratch directory outside the space". It keeps the old rule (no script file inside the space) and adds the rule the verify run needed (no hand-built check).
- **The rest of SKILL.md is unchanged in meaning.** The diff has two hunks: the pointer, and line 60's lead line. That line changed from "as the script below runs them" to "as the check script `check.sh` runs them". Everything else is byte-unchanged and still reads correctly against a shipped file:
  - the front-matter, Inputs and Output sections;
  - the prose of the three checks;
  - section 2, including step 3's re-run of "the check script" at line 162;
  - the desk run (line 190) and the Never list.
- **The installer ships check.sh.** `install/install.sh` step 6 (lines 212-226) links each whole skill directory with `ln -sfn`, product first, then the bus overlay. INSTALL.md §3 (lines 110-119) does the same by hand. So `check.sh` ships beside `SKILL.md`, as `mesh-on`'s `mesh-scan-loop.sh` already does. The script does not use its own path, so it runs the same through the symlink.
- **No other text tells an agent to copy the script out.**
  - At `bbd19a2`, `git grep` for these strings finds only SKILL.md's own lines: `check.sh`, "check script", "copy the script", "script block", "script below", "scratch directory".
  - README.md:139, guidance/agent-operating.md:218, docs/operator-manual.md:273 and spec/memory-spaces.md:35 name only the skill or its directory.
  - The swe-pod change branch has no such text either.
- **Extra:** `check.sh` is not in T10's `touches:` in plan.md, which lists SKILL.md only. The verify fix asked for this file, so it is not a finding here. The lead should add it to the plan's touches so the whole-change review sees it as planned.
- **Misread:** none.

## Quality

**Throwaway-space run.**
- Setup:
  - a scratch directory outside every repo;
  - `git init`, with a `space.yaml` and `changes/demo/plan.md`;
  - no remote and no commit, so `BASE` is `HEAD` and every record is new;
  - four evidence records under `changes/demo/evidence/`, written at run time.
- I ran the checkout's `skills/space-librarian/check.sh`, whose working tree equals `bbd19a2`. `SPACE` was set and `BUS` left to its default.
- It ran under `sh` (0.99 s wall time) and under `dash` (0.72 s wall time), with the same output from both:

```
CHECKED changes/demo/evidence/20261028T0100Z.md
CHECKED changes/demo/evidence/20261028T0100Z-T19a.md
REFUSED changes/demo/evidence/20261028T0100Z-T19.md: id line 2
REFUSED changes/demo/evidence/20261028T0200Z.md: profile line 8
```

- What the four lines show:
  - The records with ids `ev-20261028T0100Z` and `ev-20261028T0100Z-T19a` pass together.
  - `ev-20261028T0100Z-T19` is refused as `id`, at its `id:` line.
  - The fourth record holds the node's own `$HOME` path at line 8 and is refused as `profile`.
  - The output holds no matched text.
- The block extracted from `1367f65`'s SKILL.md gives the same four lines for the same records, so behavior did not change.
- Edge cases, both as SKILL.md:55-56 and the script describe:
  - A path that names no file printed `no such record: ...` to stderr, not a result line.
  - A run without `SPACE` stopped with exit 1 and the message `set SPACE to the space root`.
- The scratch directory is deleted.

**Standard close.**
- `share-check.py --task T10` printed `shareability: 0 hits`.
- `bbd19a2`:
  - has a one-line plain-ASCII subject;
  - has the trailers `Change: build-swe-pod`, `Task: T10` and `Co-Authored-By`;
  - touches only the two files;
  - is on `origin/change/build-swe-pod`.
- `git diff --check 1367f65 bbd19a2` is clean, and neither file has a non-ASCII byte.
- The checkout's working tree was clean before and after.

**Tests.** agent-mesh has no unit suite. The builder's harness checked the bytes, the `$<digit>` count and the throwaway-space runs. That tests real behavior, not wording. Its red run (4 fail) and green run (5 pass) agree with my runs.

**"For the reviewer" parts (report TS9 and TS10).**
- TS9 holds: SKILL.md:109-115 is the only place that names the script, and it inlines no shell or awk.
- TS10 holds: the installer links whole directories.
- Two cautions remain for later edits:
  - inlining any shell or awk with positional parameters into SKILL.md brings the corruption back;
  - `check.sh` works only when run with `sh`.

**Outside this diff.** The test runner keeps skills as regular-file copies: its `mesh-load` holds only a copy of SKILL.md. If it copies SKILL.md alone into its skills directory, `check.sh` will be missing on the verify re-run. The lead should copy or link the whole `skills/space-librarian/` directory there. This is the TS10 case and is not a T10 defect.

## Findings

- Minor agent-mesh/skills/space-librarian/SKILL.md:4 `allowed-tools` still grants `Write`. Its one use was writing the copied-out script to a scratch file. With `check.sh` shipped, and records "already written at that path" (line 37), the skill writes no file, and a pre-granted `Write` only makes the forbidden hand-built copy easier. Drop `Write` from the list.
