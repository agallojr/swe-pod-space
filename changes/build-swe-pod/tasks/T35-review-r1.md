---
task: T35
diff: agent-mesh 9de4f77..f27c611
diff: swe-pod 83eaef9..b7fc257
verdict: pass
---

Fix-mode re-review of T35's fix wave. It checks the findings the
2026-10-29T03:08Z ruling took: 1 (integrate, design (a)), 2 (mesh-load's
`$2`), 13 (the identity template), 14 (the poller prompt) and 16 (fixtures,
inside 1). I read the fix diff from git: agent-mesh, six commits, `afb8016`,
`3cf692a`, `2d3f283`, `95fdbdb`, `e8506b0` and `f27c611`; swe-pod, two
commits, `70c46e5` and `b7fc257`. Both checkouts were clean at those heads,
and both are on `origin/change/build-swe-pod`. I ran no test runner and
nothing that calls a model. My only runs were `check.sh` in normal mode,
read-only, each call under 16 s.

## Spec compliance

- **Finding 1 (integrate in one space commit): closed**, clause by clause.
  - One commit, against one record per commit: SKILL.md section 3 (line 199
    on) makes the one commit (step 3: `git mv`, `git add`, then one
    `git commit` by pathspec). The intro (lines 12-14), the description and
    the Never rule (lines 321-323) all name integrate mode as the only
    exception.
  - Folders, against "paths that name a file": renames take a file or a
    folder (section 3 Inputs), and check.sh takes `--move <from> <to>`
    (lines 8-20).
  - The removal half of both moves: the commit names every `<from>` and
    `<to>`, so the old paths' deletions go in with the additions. I traced
    the `--only` pathspec commit: an old path in `HEAD` with no file is
    removed, a new index entry is added, and an untracked file is left out.
  - The three checks run on every path, under its name after the moves:
    check.sh lines 174-185 list the tracked files under each rename through
    `fwd`, plus the records, once each. Line 188 reads each one at its old
    path through `old`.
  - A moved record's id is not new: lines 219-232 compare it with the old
    path on `origin/main`, and a moved evidence record must be byte-equal
    to its old blob (`cmp`).
  - Fetch, rebase, re-check, push, ancestor check: steps 1, 4 and 5. A
    refusal after the rebase is undone by step 4's `reset --soft` and then
    step 6 (the renames moved back, last first). `--soft` is right here,
    since `git mv` needs the index entries.
  - Citations: PROCESS.md:657-660 and agents/swe-lead.md:454-459 cite the
    mode.
- **The three texts agree.** All three give the same facts:
  - two renames, the tests' move first, then the folder into
    `changes/archive/<yyyy-mm-dd>-<id>/`;
  - every edited or new file as a record, named by its path after the
    moves;
  - one commit.

  "The librarian makes that commit" (PROCESS.md) and "only the lead uses
  this mode" (SKILL.md:204) read together as the lead invoking the
  librarian's skill. That holds where the lead's session or node holds the
  space's librarian role. This change meets that, but the text never says it
  (Minor 1).
- **Finding 16 (fixtures): closed.** check.sh:193-198 gives a path under
  `changes/*/tests/fixtures/` or `tests/*/fixtures/` the profile check only,
  in every mode. SKILL.md:112-115 says the same. A case `*` matches `/`, so
  the patterns hold both before and after the moves.
- **Finding 2 (mesh-load `$2`): closed.** mesh-load/SKILL.md:59 now uses
  `cut -d' ' -f2-`. `git config --get-regexp` puts one space between key
  and value, so `-f2-` keeps a path that holds a space. I scanned every
  `SKILL.md` in both repos at the new heads for `$<digit>`, `${<digit>` and
  `$ARGUMENTS`: none found (grep exit 1).
- **Finding 13 (template): closed.** The example is now its own comment
  line, `#   AGENT_ROLES=build,swe.build,swe.test`, at
  templates/agent-identity.env.template:19, with no trailing period.
- **Finding 14 (poller prompt): closed.** poller-prompt.md:25-26 states the
  cost in general terms, with no node name and no figure. mesh-on/SKILL.md
  lines 130-132 drop the model names and prices.

  I ran the librarian's profile check, read-only, against the bus registry
  on all six changed agent-mesh files and on `agents/swe-lead.md`. Every
  file printed `CHECKED`.
- **Other text on how integrate is filed, or on one record per commit.** I
  grepped both repos at the new heads. Every hit except one agrees:
  - SPEC.md:485 and SPEC.md:897 ("one space commit") agree.
  - PROCESS.md:801 and swe-lead.md:226 ("commits each record alone") are
    about filing shard briefs in normal mode, which integrate mode leaves
    unchanged.
  - spec/memory-spaces.md:322 says "one commit per transition", and an
    integrate is one transition.

  The exception is `guidance/agent-operating.md:219`. It still says the
  librarian "makes one commit per record", with no exception. It does not
  state how integrate is filed, so it does not block T36, but it is now
  incomplete (Minor 1).
- **Extra:** `skills/mesh-on/SKILL.md` is outside T12's touches and plan
  §4. Finding 14 named that file, and the ruling took finding 14, so the
  edit itself is asked for. Only its `Task: T12` trailer lacks a ledger
  ruling (Minor 3).
- **Misread:** none.

## Quality

- **structure:** check.sh stays POSIX sh:
  - parameter expansions with quoted patterns, `case`, and
    `read -r ... <&3` with `done 3< file`;
  - `sed -n '1!G;h;$p'`, `cmp -s -` and `LC_ALL=C sort -u`.

  The functions `fwd` and `old` reuse the globals `p`, `a` and `b`, but no
  caller depends on them. The rename list's `a`/`b` loop and `fwd` run in
  separate pipeline subshells.
- **Normal mode unchanged:** With no `--move`, `old` returns the path as
  given, so lines 188, 221-222 and 225 reduce to the old code (`q=r`, the
  `git diff --quiet` branch). The only intended change is the fixture rule.
  I ran the old (9de4f77) and new scripts in normal mode on a 29-path
  sample of the space (records, logs and fixtures): the outputs are
  identical.
- **Error handling:** the integrate path covers each failure:
  - `bad rename` when both ends or neither end exist;
  - `no such record` goes to stderr, and SKILL.md step 2 makes it a stop;
  - a refusal before the commit changes nothing;
  - a refusal after the rebase is undone.

  A resumed run is safe at each point:
  - a rename already made is skipped (both ends pass the parse check);
  - a commit already made is caught as nothing to commit, or as a `<from>`
    that matches no file;
  - a pushed commit passes the re-check, since its paths are then on
    `origin/main` at their new names.

  A rebase that meets an upstream file under a renamed folder stops on a
  directory-rename conflict and is aborted, so it is safe.
- **This change's own integrate (plan T36 step 7).** The commit would make
  the two renames:
  - `changes/build-swe-pod/tests` to `tests/build-swe-pod`;
  - then `changes/build-swe-pod` to
    `changes/archive/<yyyy-mm-dd>-build-swe-pod`.

  The records would be `pod.yaml`, `AGENTS.md`, a new root `PROCESS.md`,
  the note's header, and the archived `spec.md` (and `report.md` if it is
  not yet filed). What I found:
  - Neither `tests/` nor `changes/archive/` exists yet. Both `<to>`s are
    absent, and step 3's `mkdir -p` makes their parents.
  - The change folder holds 1723 tracked files:
    - 567 under `tests/`, 475 of them fixtures, all under
      `tests/fixtures/`;
    - 1047 non-Markdown run logs and other non-Markdown files outside the
      fixtures;
    - 201 Markdown files outside the fixtures.
  - The space has no `.gitattributes`, so the evidence `cmp` compares like
    with like. No path would be quoted by `ls-files`, and the folder has no
    untracked or ignored file.
  - The runner names no `changes/` path, so the moved suite keeps working.
  - Normal-mode check of all 1723 files at their current paths, in nine
    calls: every file `CHECKED`, the run logs and fixtures included (about
    101 s wall time in total).

    Integrate mode differs only in the path names. The fixture and
    `changes/*/evidence/*` patterns match both before and after the moves.
    A moved record's id is read from its old path. Citations resolve by id,
    by `chg` (live or archived folder) or by `<change>/T<n>`, so they
    resolve both before and after the moves.

    So I expect step 2 and step 4 each to print no `REFUSED`, at about
    100 s per pass. That is under the Bash tool's 10 min limit, so a desk
    run first is cheap.
  - `PROCESS.md` from swe-pod passes the profile, reference and id checks.
    It has no front matter, and its body holds no qualified id and no home
    path.
  - The note's `superseded_by` URL resolves as a URL.
- **tests:** neither repo has a unit suite. The builder's harnesses were
  scratch scripts and are deleted. Their scenarios (refusal before and
  after the rebase, the undo, another writer pushing first, fixtures, moved
  ids) exercise behavior, not wording. Where my reading and runs overlap
  with them, they agree.
- **test suggestions:**
  - T10.TS11: its reviewer part holds. check.sh 8-35, 174-185 and 219-232
    and steps 3-6 are as described above.
    - Nested renames given outer first fail safe: the inner `git mv` fails
      and the renames are undone.
    - An existing `<to>` is `bad rename`.
    - A resumed pathspec commit is handled.
  - T10.TS12: its reviewer part holds. The `cmp` against the old blob is
    right for a moved record, where `git diff` against the new path could
    not see the old one.
  - T12.TS5: its reviewer part holds. No `SKILL.md` holds `$<digit>` or
    `$ARGUMENTS`.

## Findings

- Minor agent-mesh/guidance/agent-operating.md:219 still says the space-librarian skill "makes one commit per record", with no exception, so the mode this wave added (SKILL.md section 3) is missing from the librarian's duty text. Nothing says where integrate runs either. A lead whose session or node does not hold the space's librarian role has no way to hand renames over, since a mesh request and a `files:` result carry files only. This does not affect T36, because its lead holds that role. Add "except a change's integrate, one commit in the skill's integrate mode" here. At SKILL.md:204 and agents/swe-lead.md:454, say that integrate runs in the session or node that holds the space's librarian role.
- Minor swe-pod/agents/swe-lead.md:279 Step 6 records `filed <space path>` for each `FILED` line. Integrate mode prints one `FILED` line per path (SKILL.md:224 and 296), about 1727 for this change. So, read literally, the archived ledger gains about 1700 paths, and nothing gives a short form. Name one for an integrate filing, for instance `filed integrate <sha7>: <from> -> <to>, <from> -> <to>, <records>`. Or the lead can rule on it at T36.
- Minor agent-mesh/skills/mesh-on/SKILL.md:130 f27c611 carries `Task: T12`, but the file is in neither T12's touches nor plan §4. The edit itself is the price removal that finding 14 asked for. Record a ledger Ruling that extends T12's touches to this file, as the 2026-10-28T06:11Z ruling did for check.sh, so that the per-task diff and the final report account for it.
