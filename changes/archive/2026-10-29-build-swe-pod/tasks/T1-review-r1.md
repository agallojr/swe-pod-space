---
task: T1
diff: swe-pod 1237519..45572b0
verdict: pass
---

## Spec compliance

This is the re-review after fix round 1/5. It covers only the fix commit `45572b0`, the newest commit with trailer `Task: T1` on `change/build-swe-pod`. Its parent is `1237519` (the T5 commit, which was the branch head when T1 committed). T1's commits are now `ab800ec` and `45572b0`.

- The fix commit changes only `PROCESS.md`, which is the task's `touches`. Its trailers are `Change: build-swe-pod` and `Task: T1`. The subject is one line of plain ASCII.
- `45572b0` is the head of `origin/change/build-swe-pod` after a fresh fetch, so it is pushed.
- The working-tree `PROCESS.md` matches `45572b0`.
- A word-diff of `ab800ec` against `45572b0` shows one insertion and nothing else. The rest of the bullet is reflowed with its wording unchanged.

Previously open finding:
- Important swe-pod/PROCESS.md:687 (a review task can never be dispatched under the Ordering and interim rules). CLOSED. The §11 Ordering bullet now reads, at L688-690: "In a review task, `after: [T<k>]` means T<k> has reported and its commit exists; T<k> is done only when that review closes." This is plan §7 L1053-1054 nearly word for word ("the review" became "that review"). It comes before the interim rule in the same bullet. The deadlock is gone: a review task can be dispatched once its build task has reported and committed. A successor that lists the build task still waits for the review to close, as the standard close requires.

Done-when checks, rerun by the reviewer on the file at `45572b0`:
- (1) PASS. Line 1 is `# SWE Pod process` and line 3 is `process: swe-pod-process@1`.
- (2) PASS. `grep '^## '` prints the 15 headings of plan §2.2 in order, with no other level-2 line.
- (3) PASS. The fix does not touch `## 1 Shape of a project`. The `pod.yaml` example keys are still present, and the previous review confirmed the branch rules at L73-89.
- (4) PASS. All seven tables are present, at the same lines as before:
  - stages, L95;
  - states, L115;
  - suggestion routing, L441;
  - failure routing, L506;
  - sizes, L558;
  - roles, L576;
  - placement, L595.
- (5) Standard close:
  - The shareability check (`share-check.py --task T1`) reports `shareability: 0 hits`.
  - `git diff 854e87c -- SPEC.md 'spec-process.*'` is empty (0 bytes). `854e87c` is the only `Task: T0` commit.
  - The commit is made by pathspec with the right trailers, and it is pushed.
  - This review leaves no open Critical or Important finding.

Missing: none. Extra: none. Misread: none.

## Quality

The fix does what was asked, in the plan's own words, and in one of the two places the finding suggested (§11 Ordering). It adds no other change. The builder's report records red output on the committed file and green output after the edit, plus reruns of checks 1 to 4 and the standard close. The reviewer's own runs above agree. Test suggestion T1.TS6 points at this bullet, which suits a test of the review-dispatch path. One small wording point remains in the interim rule (below). It does not bring back the stall, because the definition in the same bullet says what a review task's `after` entry means.

## Findings

- Minor swe-pod/PROCESS.md:693 The M4 interim rule still says "every task whose `after` tasks are all done". Read with the new definition at L688-690 it works, but on its own it still uses "done" where a review task's `after` entry means reported with its commit present. "whose `after` entries are all met" would remove the remaining ambiguity.

