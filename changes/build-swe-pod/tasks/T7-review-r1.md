---
task: T7
diff: swe-pod 32db546..5aacf3f
verdict: pass
---

## Spec compliance

Scope: fix round 1 of T7, one commit, 5aacf3f (parent 32db546). I found it with `git log -E --grep='^Task: T7$' origin/change/build-swe-pod`. It has trailers `Change: build-swe-pod` and `Task: T7` and touches only the two files in `touches:`:
- skills/swe-pod/SKILL.md: 42 lines changed;
- skills/swe-pod/status-format.md: 23 lines changed.

That is 44 lines added and 21 removed. I reviewed the diff against the three Important findings of T7-review.md, and read the surrounding sections of both files at 5aacf3f for context. I also read these to check the fixes:
- swe-pod templates/records/plan.md, ledger.md, agents/swe-lead.md and PROCESS.md sections 7 and 8, all at the branch head;
- the space's plan section 7 and ledger.

Findings under fix:

- **SKILL.md:90, review-task link: closed.** SKILL.md 1.3 (lines 91-100) now names the whole-change review by its heading title `Whole-change review`, which reviews no single task. Every other review task reviews, in this order of precedence:
  1. the task its Reviews cell begins with;
  2. T<m> from a heading `### T<n> Review of T<m>`;
  3. the single task in its `after:` list.

  Lines 82-83 make headings count only the ids before the title, so `### T21 Review of T1` is the task T21. Before the fix, "names one task id" would have dropped that heading. status-format.md task states (lines 128-130) and Latest (line 145) now point at that link.

  Checked against the template:
  - plan.md:83-85 gives `### T<n> Review of T<m>` with `after: [T<m>]`, which rules 2 and 3 match.
  - plan.md:90-92 gives `### T<n> Whole-change review` with a one-task `after:`. The title rule runs first, so the whole-change review is not mistaken for a review of the verify task.

  Checked against the space: the review table's cells all begin with the reviewed id (T1 to T14, T37), and T35's heading is `### T35 Whole-change review`.

- **status-format.md:166, rulings close only after round 5: closed.** A ledger line that begins `Ruling: T<n> open findings` now closes that task's open Critical and Important findings at any round, the whole-change review's included. It counts only when it is newer than the task's newest review or fix-round line (status-format.md:169-172, SKILL.md:124-127). The example `Ruling: T<n> open findings parked: <which>; <why>; <cost if wrong>` fits the ledger form `Ruling: <what>; <why>; <cost if wrong>`, so the lead's ledger lines can carry it.

  The new rule ties into the rest of the skill:
  - It feeds "review closed" (SKILL.md:133-135), so a build task turns done.
  - The whole-change review "counts its own review lines" (status-format.md:129-130), so `Ruling: T35 open findings ...` makes T35 done and lets the change read verified.
  - A later re-review line reopens the count, which is right.
  - Free-form rulings close nothing. In this space's ledger, `Ruling: T16 and T17 briefs ...` therefore no longer risks a false close.

  One gap remains, outside T7's touches: the lead's definition does not name this form (Minor below).

- **SKILL.md:149, green rule passes missing results: closed.** SKILL.md 1.6 (lines 161-177) now requires a pass for:
  - every `test_*.md` in `changes/<id>/tests/`, under the key from the trace's step 4 mapping;
  - every regression test, taken from each archived change's plan test map, for rows whose test file is under `tests/`, as `<change>/<Rn.Sm>`.

  The old "when present" clause for `x-checks:` and `x-suggestions:` is gone. Line 174 keeps a stray `fail` on an extra key from passing. The two counter-examples from the finding are now named as not green (lines 175-177): no `x-checks:` while test_I1 exists, and 1 regression result of 10.

  status-format.md:86-94 follows: it adds `regression <p>/<n> pass` and takes the `x-checks` and `x-suggestions` counts from the test files, not the record's keys. The fix follows the finding as worded. Its test-map basis leaves out promoted inspection and suggestion tests (Minor below).

Done-when, after the fix:
- (1) to (3) still hold. I re-ran the I4 embedded check, read-only, on the checkout at 5aacf3f: I4.1 to I4.6 pass, exit 0.
- (4) The fix does not change the regenerated output of the reported run pair. At space 03d8c12 there were:
  - no evidence records, no `tests/` and no `changes/archive/`;
  - no `Ruling: T<n> open findings` line;
  - one multi-id heading, `### T19a and T19b ...`, which is not a task under either the old or the new heading rule. The review table's links are unchanged.
- (5) Standard close:
  - The shareability check, re-run, prints `shareability: 0 hits`.
  - `git diff 74d23f1 5aacf3f -- SPEC.md spec-process.*` is 0 lines, and 74d23f1 is still the latest `Task: T0` commit.
  - The commit is by pathspec with both trailers. `git ls-remote` shows the remote `change/build-swe-pod` at 5aacf3f.
  - `git diff --check` is clean.

Missing: none for the findings under fix. Extra: none. Misread: none.

## Quality

The fixes are in the right places and stay deterministic:
- Each new rule has a fixed precedence: the link order, and "newer than that line" for rulings.
- Each rule has a fixed fallback: "reviews no single task", and "a Ruling: line in another form closes nothing".
- The two files say the same thing: SKILL.md 1.3 and 1.4 hold the rules, and status-format.md points back to them by section.
- The new prose names its examples, `### T21 Review of T1` and test_I1 with no `x-checks:`, which makes the edge cases concrete.

Error handling: the fix adds no new failure path.

Tests: there is no unit suite in swe-pod, and no check exercises the three new rules, because this space's records have no template-form review task, no prefix-form ruling and no evidence. The I4 checks stay wording checks. Coverage of the new behavior rests on the regeneration scenarios (R18.S1, R20.S1) at verify. That is acceptable for a fix diff whose output on this space is unchanged.

A note for the lead, outside this diff and not a T7 finding: the T39 report was filed as `changes/build-swe-pod/evidence/20261028T0053Z-T39-report.md`. It is not an `ev-` record, so the skill reads no evidence from it, but it adds a UTC to "As of".

## Findings

- Minor swe-pod/skills/swe-pod/status-format.md:170 Only a ruling that begins `Ruling: T<n> open findings` closes a task's open findings, and that form is written only here and in SKILL.md:124-127. agents/swe-lead.md:276 and :296 tell the lead to rule on each open finding or on what remains, and swe-lead.md:299 and templates/records/ledger.md:27 give only `Ruling: <what>; <why>; <cost if wrong>`. A lead that follows its own definition writes something like `Ruling: T35 Important PROCESS.md:12 parked; ...`, which closes nothing. After the ruling on the whole-change review's leftover finding, the change still reads building with open Important findings. The skill side is now sound and deterministic. Carry the form into swe-lead.md's fix-loop and whole-change paragraphs; T37 touches that file.
- Minor swe-pod/skills/swe-pod/SKILL.md:164 The regression rule requires a result only for archived test-map rows, and test maps hold scenario rows only (templates/records/plan.md:110-112). PROCESS.md section 8 step 5 moves the whole of `changes/<id>/tests/` into `tests/`, so promoted test_I<n> and test_T<n>_TS<k> files are regression tests. Under this rule they need no result, and a run that omits them reads green, against PROCESS.md section 7's not-verified rule. PROCESS.md section 7 defines qualified ids only as `<change>/<Rn.Sm>`, so these tests have no key. Define one in PROCESS.md and the evidence template, for example `<change>/I<n>` under `x-checks:`, then require it here. T37 touches all three files.

