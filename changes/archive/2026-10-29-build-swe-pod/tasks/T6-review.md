---
task: T6
diff: swe-pod ea98774..101cebb
verdict: fix
---

## Spec compliance

Diff: one commit, 101cebb, with trailers `Change: build-swe-pod` and `Task: T6`. Its parent is ea98774. It creates exactly the three files in `touches:`: agents/swe-build.md (144 lines), agents/swe-test.md (151 lines) and agents/swe-review.md (113 lines). No other file changed. No later commit changes these three files.

Done-when, re-run by the reviewer against `git show 101cebb:<file>`:

- (1) pass. Each file's front-matter has exactly four keys: `name: swe-<role>`, a one-sentence `description` with no ": ", `tools` and `model: inherit`. The tools match plan section 2.3 exactly:
  - build: Read, Grep, Glob, Bash, Write, Edit
  - test: Read, Grep, Glob, Bash, Write, Agent
  - review: Read, Grep, Glob, Bash, with no Write and no Edit

  The body headings in all three files are, in order: `## Reads`, `## Writes`, `## Never`, `## Returns`, `## Steps`.
- (2) pass. swe-test.md line 38 is the closing line, exactly and as a whole line. swe-build.md line 83 holds `Disputed test: <test name>; spec clause: <clause>`, and line 129 cites the phrase again.
- (3) Rules left to review, checked one by one by reading the files:
  - swe-build:
    - ask first, with NEEDS_CONTEXT: line 97
    - test first: lines 100-103
    - full unit suite run once: line 108
    - writes only code, unit tests and shipped docs, only on `change/<id>`: lines 32-34
    - rebase before pushing: line 116
    - never create a branch: lines 49 and 122
    - a rebase conflict means BLOCKED: lines 123-126
    - a disputed test gives DONE_WITH_CONCERNS and stays unchanged: lines 44-45 and 127-129
    - suggestions have two parts and carry no computed value: lines 54-55 and 84-93

    All present. Step 7's rebase command is defective in the shared-checkout layout: see the Important finding.
  - swe-test:
    - blind writing mode that ends with the closing line: lines 28-38
    - tests named after their scenario: lines 93-96
    - expected values from outside the code: lines 64-65 and 100-102
    - each new test run at base and expected to fail: lines 109-112
    - heavy over 60 s: line 108
    - verify at the commit set in the named environment class: lines 121-125
    - evidence carries every section 2.4 key: `id`, `change`, `commit_set` (with unnamed repos at their pins), `env`, `actor`, `scenarios` (with qualified regression ids), `unit`, `quality` or `none-declared`, the optional `x-` keys, and `wall_time_s`: lines 133-145
    - log pointers only, and `not-run (cap)` names its cap: lines 127-129 and 147-148
    - writes only under `tests/` and `evidence/`: lines 47-61
    - never commits: line 67

    All present.
  - swe-review:
    - works from the brief, the report and the diff, never the builder's session: lines 27-31 and 53
    - review in the section 2.4 format: front-matter `task`, `diff` (one per range), `verdict`; sections Spec compliance (missing, extra, misread), Quality, Findings; the exact finding-line form; `fix` if and only if a Critical or Important finding is open: lines 64-89
    - whole-change mode checks completeness, correctness and coherence: lines 106-111

    All present.
- (4) Standard close:
  - The shareability check (tools/share-check.py with `--task T6`) reports `shareability: 0 hits`.
  - `git diff 854e87c -- SPEC.md spec-process.*` prints 0 lines, both in the working tree and at the branch head.
  - The commit was made by pathspec with both trailers, and 101cebb is an ancestor of origin/change/build-swe-pod. The remote has only `main` and `change/build-swe-pod`.
  - Not yet met: this review has one open Important finding.

Missing: no rule from the T6 steps is absent.

Extra:
- swe-review's fix mode
- swe-test's status set and final-message contents
- the public-surface allowance in swe-test

All three come from spec sections 5.3 and 5.4, so none goes beyond the spec.

Misread: none. Report concern 1: the public-surface allowance follows spec section 5.4 ("Once code exists it may use the public surface"). It does not loosen R9, which governs a brief's contents. The closing line is kept exact, and line 62 forbids asking another agent for excluded material. The plan step's literal wording ("read only the brief and spec.md") is narrower, but the spec governs here.

Report concerns 2 to 5 are acceptable:
- Concern 2: a test task returns no report file. That matches R8.S1, and the swe-lead definition records `T<n> at base:` lines from the test agent's result.
- Concern 3: test names given as stems, with the extension taken from the test map.
- Concern 4: on the mesh, the review text returns as a result file, which depends on T13.
- Concern 5: the staged scan covers other tasks' files. Re-run, it still reports 0 hits.

## Quality

Structure matches the sibling definitions from T4: an H1 title, an intro, then the same heading order. The PROCESS.md citations (sections 5, 6, 7, 10, 11 and 13) match the headings T1 wrote. There is no trailing whitespace. Every line is at most 80 characters, except the front-matter description lines and the exact closing line, which must stay whole.

swe-pod is Markdown only and has no unit suite, so unit-test coverage of the "for the reviewer" parts does not apply. The four suggestions' line ranges point at the right passages: swe-build.md:116-126, swe-test.md:27-38, swe-review.md:39-45 and swe-test.md:121-136. The "for the tester" parts are in spec terms and carry no computed value.

The main defect is operational. swe-build step 7 tells every builder to run an unconditional `git pull --rebase` before pushing. Git refuses that whenever the shared checkout holds another task's staged or modified tracked files, as it does now. Step 7 handles only a missing branch and a rebase conflict, so builders dispatched with this text (T7 to T14) can stall, or can touch other tasks' work. The remaining Minors are gaps in where and how the test and review agents obtain commits and the files they may read.

## Findings

- Important swe-pod/agents/swe-build.md:119 Step 7 runs `git pull --rebase origin change/<id>` before every push. Git refuses a rebase pull while the index or tracked files hold uncommitted changes, and it checks this before fetching, so the refusal comes even when the branch is up to date. Parallel builders in one repo share one checkout: git will not check out the same branch in a second worktree, and plan section 4.1 sets up a shared checkout. So whenever another task's files are staged (the shared checkout has T2 and T3 files staged right now), the command exits with "cannot pull with rebase: Your index contains uncommitted changes". Step 7 covers only a missing branch and a rebase conflict, so the builder is left to stash or reset other tasks' work, push without rebasing, or report a false BLOCKED. Fix: fetch, and rebase only when the remote head is not already in the local branch or the push is rejected. Never stash, reset or otherwise touch another task's files. When the tree is not clean, wait and retry, or report BLOCKED.
- Minor swe-pod/agents/swe-build.md:116 There is no wait-and-retry rule for a held index lock or a rejected push. Plan section 4.1 says wait and retry, three times at most. Parallel builders in one checkout hit both races (R23.S1). Without the rule, a builder may delete `.git/index.lock` or give up.
- Minor swe-pod/agents/swe-test.md:28 The writing-mode "Read only" list (the brief, the spec, the public surface) leaves out files that a test task's own entry can name. Examples: `changes/<id>/tests/README.md`, the runner and the fixtures, which T16 and T17 are told to follow, and `PROCESS.md`, which line 12 cites. The closing line does not exclude them, so list them as allowed reads.
- Minor swe-pod/agents/swe-test.md:35 The public-surface allowance does not say how to read signatures without opening a source file, which shows implementation bodies. Name the allowed means: `--help` output, shipped API docs, or a grep for signature lines only. The allowance follows spec section 5.4 and does not loosen R9.
- Minor swe-pod/agents/swe-test.md:121 Verify step 1, and writing step 8 at line 109, say to check out the commit set without saying where. A `git checkout <sha>` in the shared build checkout or in the space checkout from the prompt would move HEAD under parallel builders or the librarian. Say to use a scratch checkout or export of its own (for example `git archive`) and never to move a branch.
- Minor swe-pod/agents/swe-review.md:94 Step 2 reads `origin/change/<id>`, but the Bash list at lines 41-42 allows no `git fetch`, so a reviewer with a stale remote-tracking ref misses newer commits. In fix mode, the trailer search also returns every commit of the task, not just the fix round's, and the only stated source for the fix range is the builder's report. Say the fix range comes from the brief or from the lead's fix-round ledger line, and allow a fetch that changes no working file.

