# T6 report: build, test and review roles (D2)

## Status

DONE_WITH_CONCERNS

## What I did

Wrote the three role definitions for build, test and review as Claude Code
agent definitions, to plan §2.3: front-matter `name`, a one-sentence
`description`, `tools` as listed for each role, and `model: inherit`; the
body headings `## Reads`, `## Writes`, `## Never`, `## Returns` and
`## Steps`, in that order, with an H1 title like the sibling definitions.

- `swe-build`: ask first (`NEEDS_CONTEXT`); work test first; run the full
  unit suite once; write only code, unit tests and shipped docs, only the
  files in `touches:`, on `change/<id>`; rebase before pushing; never create a
  branch (a missing branch or a rebase conflict means `BLOCKED`); a disputed
  project-level test gives `DONE_WITH_CONCERNS` with the exact phrase
  `Disputed test: <test name>; spec clause: <clause>` in `## Concerns`, and
  the test stays unchanged; suggestions in two parts, with no value the code
  computed in the "for the tester" part; the §2.4 report sections.
- `swe-test`: a blind writing mode that reads only the brief and the spec,
  ending with the exact test-brief closing line; tests named after their
  scenario; expected values from outside the code; each new test run at the
  base commit set, where it is expected to fail; expected run time recorded,
  heavy over 60 s; a verify mode run at the given commit set in the named
  environment class, writing evidence with every §2.4 key; writes only under
  `changes/<id>/tests/` and `changes/<id>/evidence/`; never commits.
- `swe-review`: tools Read, Grep, Glob, Bash only; reviews from the brief,
  the report and the diff (taken from git by the `Task: T<n>` trailer), never
  from the builder's session; returns the record text in the §2.4 review
  format for the lead to file; task, fix and whole-change modes, the last
  checking completeness, correctness and coherence.

All three cite `PROCESS.md §<n>` with the section numbers from plan §2.2.
They carry no machine path, hostname or handle; placeholders only.

### Fix round 1/5

One open finding, Important, swe-pod/agents/swe-build.md:119: step 7's
unconditional `git pull --rebase` fails in a shared checkout whenever
another task's files are staged or edited. I confirmed it before changing
anything (check F4, red). Changes, all in `agents/swe-build.md`:

- Step 7 now runs, each on its own line: `git fetch origin change/<id>`,
  `git merge-base --is-ancestor origin/change/<id> HEAD`,
  `git status --porcelain --untracked-files=no`,
  `git rebase --no-autostash origin/change/<id>` and
  `git push origin change/<id>`. If the merge-base check exits 0, the remote
  head is already in the branch, so the builder skips the status check and
  the rebase and pushes. Otherwise it rebases, which needs a clean tree. If
  the status check lists a file, that is another task's work in progress:
  never stash, reset, restore, check out, stage or commit it. The builder
  waits and starts again from the fetch. A rejected push also restarts from
  the fetch. After three tries it reports `BLOCKED` naming the files or the
  rejection. The text says not to use `git pull --rebase`, and why.
- `--no-autostash` is there because with `rebase.autoStash` set, both
  `git pull --rebase` and a plain `git rebase` stash other tasks' files
  (check F5, red).
- The missing-branch rule now says how the builder finds out: the fetch
  finds no such ref. The rebase-conflict rule is unchanged.
- `## Never`: "never stage their files" becomes "never stage, stash, reset
  or restore their files".

## Files

- swe-pod `agents/swe-build.md` (created)
- swe-pod `agents/swe-test.md` (created)
- swe-pod `agents/swe-review.md` (created)
- commit range: swe-pod `ea98774..101cebb` (one commit, `101cebb`, trailers
  `Change: build-swe-pod`, `Task: T6`), pushed to `change/build-swe-pod`
- fix round 1: swe-pod `agents/swe-build.md` (changed), range swe-pod
  `45572b0..d752594` (one commit, `d752594`, same trailers), pushed to
  `change/build-swe-pod`

## Test output

The done-when checks ran as one shell function. C1 covers done-when (1):
front-matter keys and values, the exact tools list per role, no other
front-matter keys, the body headings in order, and no Write or Edit in
swe-review's `tools`. C2 covers (2): the exact test-brief line in swe-test
(a whole-line match) and the `Disputed test:` phrase in swe-build. C4 is the
standard close's diff of `SPEC.md` and `spec-process.*` against T0's commit
`854e87c`. Done-when (3) is left to review, as the plan says.

Red, before writing:

```
C1 FAIL agents/swe-build.md missing
C1 FAIL agents/swe-test.md missing
C1 FAIL agents/swe-review.md missing
C2 FAIL swe-test test-brief line
C2 FAIL swe-build Disputed test phrase
C4 ok SPEC.md and spec-process.* unchanged since T0
CHECKS FAILED
```

Green, after writing:

```
C1 ok agents/swe-build.md front-matter and headings: ## Reads|## Writes|## Never|## Returns|## Steps|
C1 ok agents/swe-test.md front-matter and headings: ## Reads|## Writes|## Never|## Returns|## Steps|
C1 ok agents/swe-review.md front-matter and headings: ## Reads|## Writes|## Never|## Returns|## Steps|
C1 ok swe-review tools has no Write or Edit
C2 ok swe-test test-brief line
C2 ok swe-build Disputed test phrase
C4 ok SPEC.md and spec-process.* unchanged since T0
ALL CHECKS PASS
```

C4 was green both times, since T6 never touches those files. After the
commit, `git diff 854e87c -- SPEC.md spec-process.*` printed 0 lines.

Front-matter parse: all three front-matter blocks load as YAML maps with the
four keys (descriptions hold no `: `).

Unit suite: none present in swe-pod (Markdown only), so the full unit suite
run is `none-present`.

Shareability, staged before the commit and again after it:

```
shareability: 0 hits
```

Standard close: the commit exists on `origin/change/build-swe-pod`. The T6
review (T26) is still to come.

### Fix round 1/5

New checks F1 to F6, run as one shell function over step 7 of
`agents/swe-build.md`:

- F1: step 7 runs no `git pull`.
- F2: step 7's commands, in order, are fetch, merge-base ancestor check,
  status check, `--no-autostash` rebase and push.
- F3: the step 7 text has the rules: exits 0, clean tree, stash, reset,
  wait, three tries, BLOCKED, rejected push, another task, autoStash.
- F4 to F6 run step 7's own command lines in a throwaway clone of the
  branch. Each clone sits in a scratch directory outside every repo and is
  deleted after. Global and system git config are off, and `<id>` is set
  to `build-swe-pod`. They follow the skip rule the text states, and they
  never run a gated verb: reaching the push line counts as reaching the
  push.
  - F4: the remote head is already in the branch, and another task's edit
    to a tracked file is present.
  - F5: the remote is one commit ahead, the same edit is present, and
    `rebase.autoStash` is set.
  - F6: the remote is one commit ahead, and the tree is clean.

  Staged files could not be used in the clone, because staging there is a
  gated `git add` outside the allowlist. An unstaged tracked edit takes the
  same refusal path in git.

Red, before the fix:

```
F1 FAIL step 7 runs: git pull --rebase origin change/<id>
F2 FAIL step 7 commands are: @ pull --rebase origin change/<id>;@ push origin change/<id>;
F3 FAIL step 7 lacks 'exits 0'
F3 FAIL step 7 lacks 'clean'
F3 FAIL step 7 lacks 'stash'
F3 FAIL step 7 lacks 'reset'
F3 FAIL step 7 lacks 'wait'
F3 FAIL step 7 lacks 'three tries'
F3 FAIL step 7 lacks 'rejected'
F3 FAIL step 7 lacks 'another task'
F3 FAIL step 7 lacks 'autoStash'
F4 FAIL STOPS at 'git pull --rebase origin change/build-swe-pod': error: cannot pull with rebase: You have unstaged changes.; remote head in branch: yes; other file touched: no
F5 FAIL NOTE autostash used REACHES-PUSH; remote head in branch: yes; other file touched: yes
F6 ok REACHES-PUSH; remote head in branch: yes; other file touched: no
FIX CHECKS FAILED
```

Green, after the fix:

```
F1 ok step 7 has no git pull
F2 ok step 7 commands in order
F3 ok step 7 prose rules
F4 ok REACHES-PUSH; remote head in branch: yes; other file touched: no
F5 ok WAIT dirty: M README.md; remote head in branch: no; other file touched: no
F6 ok REACHES-PUSH; remote head in branch: yes; other file touched: no
FIX CHECKS PASS
```

F6 passed red too. It guards the clean-tree rebase path, which the old
text also handled. One extra check confirms that git refuses the new
rebase line without stashing, even with `rebase.autoStash` set and the
status check skipped:

```
F7 ok rebase --no-autostash refuses (exit 1: error: cannot rebase: You have unstaged changes.); other file untouched, 0 stash entries
```

The original checks C1, C2 and C4 passed before and after the fix. After
the fix, no line in `agents/swe-build.md` over 80 characters except the
description, and no trailing whitespace:

```
C1 ok agents/swe-build.md front-matter and headings: ## Reads|## Writes|## Never|## Returns|## Steps|
C1 ok agents/swe-test.md front-matter and headings: ## Reads|## Writes|## Never|## Returns|## Steps|
C1 ok agents/swe-review.md front-matter and headings: ## Reads|## Writes|## Never|## Returns|## Steps|
C1 ok swe-review tools has no Write or Edit
C2 ok swe-test test-brief line
C2 ok swe-build Disputed test phrase
C4 ok SPEC.md and spec-process.* unchanged since T0
REGRESSION CHECKS PASS
```

After the commit, `git diff 854e87c -- SPEC.md spec-process.*` printed 0
lines. The unit suite is still `none-present`.

Shareability, staged before the commit and again after it:

```
shareability: 0 hits
```

The push landed on the first try (`45572b0..d752594`). It did not need a
rebase: the remote head was already in the local branch.

## Concerns

- swe-test writing mode also allows the code's public surface once code
  exists (`--help` output or signatures, never a body), as spec §5.4 says.
  The plan step says "read only the brief and `spec.md`". I followed the spec
  and put the allowance before the closing line. The reviewer should confirm
  that it does not loosen R9.
- swe-test returns no report file. R8.S1 limits the files a test task
  produces to `changes/<id>/tests/` and `changes/<id>/evidence/`, so its
  status, at-base results (as `<test name> <fail|pass> (<reason>)`) and
  suggestion outcomes go in its final message, or in the result body on the
  mesh. The lead's definition (T5) has to take its ledger lines from there.
- Test file names are given as stems (`test_R<n>_S<m>_<slug>`,
  `test_I<n>_<slug>`, `test_T<n>_TS<k>_<slug>`), with "the file extension
  the test map gives". The definitions serve any project, so `.md` from plan
  §2.5 is not hard-coded.
- swe-review has no Write tool, so it returns the record's text and the lead
  files it. On the mesh, "the text goes back as a result file" relies on the
  executor writing result files (M3, T13).
- The shareability check's staged scan also took in another task's staged
  files in the shared checkout. The total was still 0 hits, and the scan
  after the commit covers T6's commit alone.
- Fix round 1, against plan §4.1. The plan says to run `git pull --rebase`
  only when a push is rejected. Step 7 does fetch and
  `git rebase --no-autostash` instead, on a rejection too. On a clean tree
  the effect is the same. On a tree that is not clean, the pull would also
  be refused, and with `rebase.autoStash` set it would touch other tasks'
  files. The plan's instruction to this change's own builders is not
  changed, and it is not the definition's text.
- Fix round 1, the Minor at swe-pod/agents/swe-build.md:116. The
  rejected-push retry, three tries at most, is now in step 7. The held
  index lock is not covered yet, since that finding is Minor and was not
  in this round.
- Fix round 1, shared checkout state. When I committed, the shared checkout
  held other tasks' files: staged T2 and T3 templates, and an unstaged edit
  to `agents/swe-lead.md`. I left all of them as they were. The pathspec
  commit took only `agents/swe-build.md`.

## Test suggestions

### T6.TS1 Builder with no change branch to push to

- for the tester: R23 is at risk. Give a build brief for a repo where
  `change/<id>` does not exist on the remote. The failure I expect is a
  builder that creates the branch so that it can push, so the remote ends up
  with a branch the lead did not create at the go, where the builder should
  report BLOCKED.
- for the reviewer: swe-pod/agents/swe-build.md:117-142, step 7. The
  missing-branch rule and the rebase-conflict rule both sit there.

### T6.TS5 Parallel builders while one has work in progress

- for the tester: R23.S1 is at risk. Run two build tasks of one change in
  one repo, in parallel, in the one shared checkout. Arrange for the
  second builder to reach its push while the first still has staged or
  edited files that are not committed. Try it twice: once with the remote
  head already in the local branch, and once with the remote one commit
  ahead. The failures I expect:
  - the second builder stashes, resets, restores or commits the first
    builder's files;
  - it reports BLOCKED when the remote head was already in its branch;
  - its commits are missing from `change/<id>` after both finish.
- for the reviewer: swe-pod/agents/swe-build.md:117-136, the step 7
  command order, the skip rule and the clean-tree rule.

### T6.TS2 Blind test writer when code already exists

- for the tester: R9 is at risk. Give a test-writing brief for a change whose
  build commits already exist on `change/<id>`. The failure I expect is a
  test agent that opens implementation files, or the branch's diff, while it
  writes tests, because the definition lets it use the public surface.
- for the reviewer: swe-pod/agents/swe-test.md:27-38, where the public-surface
  allowance comes just before the closing line.

### T6.TS3 Reviewer asked to file its own review

- for the tester: R8 is at risk. Give a local review task whose prompt asks
  the reviewer to put its review at the space path. The failure I expect is
  a file in the space, or a changed file in the code repo, written by the
  reviewer through the shell, where the reviewer should only return the
  record's text.
- for the reviewer: swe-pod/agents/swe-review.md:39-45, the Bash read-only
  rule.

### T6.TS4 Evidence when pod.yaml names a repo the spec does not

- for the tester: R11.S1 and R23.S2 are at risk. Run verify for a change
  whose spec names one of the two repos in `pod.yaml`. The failure I expect
  is an evidence record whose `commit_set` leaves out the unnamed repo or
  gives it a commit other than its pin.
- for the reviewer: swe-pod/agents/swe-test.md:121-136, verify steps 1 and 4.
