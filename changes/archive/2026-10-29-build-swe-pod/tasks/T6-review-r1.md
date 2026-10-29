---
task: T6
diff: swe-pod 45572b0..d752594
verdict: pass
---

## Spec compliance

Scope: re-review after fix round 1/5. It covers only the fix commit d752594 (parent 45572b0), with trailers `Change: build-swe-pod` and `Task: T6`. It is checked against the one open finding from the previous review, Important swe-pod/agents/swe-build.md:119. The trailer search returns two commits, 101cebb (round 0, already reviewed) and d752594. d752594 changes only agents/swe-build.md (24 lines added, 8 removed), which is in `touches:`. The later commit 8770c1a changes only agents/swe-lead.md, so it is not T6's. `git ls-remote` shows the remote `change/build-swe-pod` at 8770c1a, and d752594 is an ancestor of it, so the fix is pushed.

The previous Important finding is resolved:
- Step 7 (lines 117-142) runs no unconditional `git pull --rebase`. The commands are fetch, `merge-base --is-ancestor`, `status --porcelain --untracked-files=no`, `rebase --no-autostash` and push.
- When the merge-base check exits 0, the builder skips the status check and the rebase, so the up-to-date case pushes even while other tasks' files are staged or edited.
- A rebase runs only when the remote head is not in the local branch. A rejected push sends the builder back to the fetch.
- Other tasks' files are never stashed, reset, restored, checked out, staged or committed. This is in lines 129-131, and in `## Never` at lines 51-53. `--no-autostash` stops `rebase.autoStash` from stashing them.
- A tree that is not clean means wait and start again from the fetch. After three tries the builder reports BLOCKED, naming the files or the rejection. That matches plan 4.1's three-tries rule.

I checked the git behavior myself in a scratch clone of the branch, deleted afterwards, with global and system git config off:
- Up to date, with a tracked file edited: `git pull --rebase origin change/build-swe-pod` exits 128 with "cannot pull with rebase: You have unstaged changes". The new fetch exits 0, and the merge-base check exits 0.
- Local branch behind the remote, with the same edit: the merge-base check exits 1 and the status check lists ` M README.md`. `git -c rebase.autoStash=true rebase --no-autostash origin/change/build-swe-pod` exits 1 ("cannot rebase: You have unstaged changes"), leaves 0 stash entries, and leaves the edit in place.
- Missing remote branch: `git fetch origin change/nosuch` exits 128 with "couldn't find remote ref", which matches line 138's "the fetch finds no such ref".

These match the report's F4 to F7 output and the text's reason at lines 134-136.

The T6 step rules touched by the fix still hold:
- rebase before pushing: line 117, conditional only when the rebase would be a no-op
- never create a branch: lines 49 and 138-140
- a rebase conflict means BLOCKED: lines 140-142

Done-when, re-run at the branch head:
- (1) pass. Front-matter and tools match plan 2.3 for all three roles, and swe-review's `tools` has no Write or Edit. Headings in order: Reads, Writes, Never, Returns, Steps.
- (2) pass. swe-test line 38 is the test-brief closing line, as a whole-line match. swe-build line 84 has the `Disputed test:` phrase.
- (4) Standard close:
  - The shareability check (`--task T6`) prints `shareability: 0 hits` and exits 0.
  - `git diff 854e87c -- SPEC.md spec-process.*` prints 0 lines, in the working tree and at HEAD.
  - The commit was made by pathspec, with both trailers, and is pushed.

Missing: none. Extra: none.

Misread: none. Report concern 6 (plan 4.1 says to run `git pull --rebase` only when a push is rejected): the definition never runs it. It still rebases, by fetch and rebase, exactly when a push would be rejected. That keeps to the plan's restriction and to spec 5.3. Builders from T7 on get both texts. If the lead wants no apparent tension, a `Ruling:` line can note that the definition's fetch-and-rebase meets plan 4.1.

## Quality

The step 7 text is clear and ordered, and gives its reason for avoiding `git pull --rebase`. Every body line is at most 80 characters (only the front-matter description, line 3, is longer), and there is no trailing whitespace. The file is now 160 lines.

The previous Minor at swe-build.md:116 is partly addressed: the rejected-push retry, three tries at most, is now at lines 132-133. A held index lock is still not covered, as the builder notes in its concerns. That Minor was out of this round's scope, and it stays with the previous review's deferred Minors.

Two new Minors are below. The first was introduced by this fix: the tracking-ref dependency. The second was already in the old text: the commit range after a rebase. Neither damages another task's work. Each fails loudly or only leaves a report range stale.

## Findings

- Minor swe-pod/agents/swe-build.md:121 The merge-base check reads `origin/change/<id>`. `git fetch origin change/<id>` updates that ref only when the fetch refspec covers it. In a single-branch or shallow clone (refspec `+refs/heads/main:refs/remotes/origin/main`), the fetch exits 0 but creates no tracking ref, so the check exits 128, not 1. "Otherwise rebase first" then sends the builder to a rebase with an invalid upstream, a case step 7 does not name. I reproduced this in a scratch clone: fetch exit 0, no tracking ref, merge-base exit 128. The old `git pull ... origin change/<id>` did not depend on the refspec, so the fix introduced this. Fix: fetch with an explicit refspec, `git fetch origin +refs/heads/change/<id>:refs/remotes/origin/change/<id>`, or say that any exit other than 0 or 1 means stop and report BLOCKED.
- Minor swe-pod/agents/swe-build.md:123 A rebase rewrites every local commit not yet on the remote: the builder's own step 6 commit, and in the shared checkout other builders' unpushed commits too. Step 7 and `## Files` do not say to take the report's commit range after the push. So a builder can report a `<sha7>..<sha7>` that is no longer on `change/<id>`, and the ledger's `T<n> DONE` line copies that range. The reviewer finds commits by trailer, so reviews are unaffected. The old pull text had the same gap. Fix: say to read the range after the push, for example `git log --format=%h -E --grep='^Task: T<n>$' change/<id>`.

