---
task: T2
diff: swe-pod 0ee5f01..aa84b73
verdict: pass
---

# T2 review: record templates (D3)

Reviewed from the brief (changes/build-swe-pod/tasks/T2-brief.md), the report (changes/build-swe-pod/tasks/T2-report.md) and the task's own diff. The trailer search `Task: T2` on origin/change/build-swe-pod finds one commit, aa84b73. Its parent is 0ee5f01, which is T3's commit. It adds exactly the ten touches (498 lines) and nothing else. The rules came from plan sections 2.4, 2.5 and 4.1, spec sections 5, 5.1 to 5.6, 8 and 9, and R5, R9, R11, R12, R14, R16, R18 and R21. PROCESS.md and the sibling role definitions at the branch head were read to check consistency.

## Spec compliance

The reviewer re-ran the done-when against the working tree. For templates/records it is identical to aa84b73: `git diff aa84b73 -- templates/records` is empty and nothing is staged.

- The builder's check script, run read-only as the report gives it (its fetch line dropped after a separate fetch), printed `== total: 50 ok, 0 FAIL`, the same as the report's green run. For the red state, `git ls-tree` lists 0 files under templates/records at 854e87c and at 0ee5f01.
- (1) All ten files exist, and templates/records holds exactly those ten.
- (2) Headings and keys were confirmed by reading each file, not by the grep alone:
  - spec.md:
    - header lines `size`, `owner`, `repos` and `supersedes`;
    - the three state-line forms exactly as section 2.4 gives them, at lines 18-20, inside the template comment;
    - `## Why`, `## Scope` (In, Out), `## Requirements`, `## Quality`, `## Approaches` and `## Open calls`, in that order;
    - the requirement, GIVEN/WHEN/THEN scenario and `- check:` forms.
  - plan.md:
    - `## 1. Goal and approach` to `## 10. Dependency summary`, with the names spec section 5.2 uses;
    - then `## Self-review` (the five section 5.2 checks) and `## Questions for the spec`, with groups (a), (b) and (c);
    - the task form carries role, repo, after, runs, needs, serves, touches, consumes, produces, steps and done when, as in spec section 5.2;
    - the test, review and integrate task forms follow section 5.2 items 6 to 8.
  - brief.md: the six section 2.4 sections in order, with Start from by sha.
  - test-brief.md: the eight section 2.4 sections in order. `## Spec` is a path only, and `## Suggestions` is marked for the suggestions task only and carries only `- for the tester:`.
  - report.md: the six sections in order, the four statuses, the disputed-test phrase of section 2.5, and `### T<n>.TS<k> <title>` with both lines.
  - review.md: front-matter `task`, `diff` and `verdict`; the three sections; missing, extra and misread; the finding line form.
  - evidence.md: all eleven section 2.4 keys are in the front-matter. It loads as YAML in a second parser and gives exactly those keys.
  - ledger.md: one fenced block, with each of the 16 section 2.4 event forms as a whole line after `<YYYY-MM-DDTHH:MMZ> `, and one continuation line indented exactly 18 spaces.
  - handoff.md: the path `handoffs/<YYYYMMDDTHHMMZ>-<change id>.md` and the four sections in order.
  - final-report.md: the six sections in order, with the Scenario | Test | Result | Evidence id table and the Branches table.
- (3) The closing line of test-brief.md is present exactly. It is the last line, line 50, and ends with a newline.
- (4) Standard close:
  - The shareability check (plan section 2.8) on the T2 diff printed `shareability: 0 hits`.
  - `git diff 854e87c aa84b73 -- SPEC.md 'spec-process.*'` is 0 bytes, and it is also 0 bytes at the branch head. 854e87c is the only `Task: T0` commit.
  - aa84b73 has a one-line plain ASCII subject and the trailers `Change: build-swe-pod` and `Task: T2`. It touches only the ten paths and is reachable from origin/change/build-swe-pod, as that branch's current head.
  - The review part is this record.

The rules the steps leave to review, one by one:

- Placeholders only: holds. Every value is a `<placeholder>`. There is no real handle, host, path or repo, no example value from the spec (no qutil, fvm or VQLS), and no environment class literal.
- The test brief has the sections and the exact closing line: holds (above).
- The ledger lists every section 2.4 event form: holds, 16 of 16, verbatim.
- The evidence template shows everything the steps ask for: holds.
  - Both `quality` forms: the live `quality: {<Qn>: pass|fail}`, and `quality: none-declared` named as the replacement line at lines 15-16.
  - `none-present`, at line 14.
  - `x-checks` and `x-suggestions`, at lines 20-21, marked optional.
  - Qualified regression ids, at line 11.
  - The log-pointer rule, in the body comment at lines 26-27 and in the `- log:` pointers.
  - `not-run (cap)` naming its cap, at lines 36-37.

Missing: nothing that section 2.4 or the steps require. Against the sibling role definitions and PROCESS.md, some slots are missing (see the Findings):

- the report has no place for the commit range or the unit-suite line that agents/swe-build.md asks for;
- the review has no place for the done-when rules left to review;
- the brief has no review-task form of `## Result goes to`;
- the plan has no form for the supersedes test-update task that PROCESS.md section 4 names.

Extra: plan.md, report.md and handoff.md each have a header list, and every file has an HTML comment giving its space path and its rules, to be deleted when the record is written. These are reasonable and hold placeholders only.

Misread: none. Where section 2.4 is silent, the builder's readings (report, Concerns) are sound:

- the `## N.` plan headings match this change's own plan and the numbering of section 5.2;
- the evidence body is a `## Failures` section with `- log:` pointers;
- the test brief has result lines.

The spec template keeps its state lines in a comment so that a new spec reads as proposed. That is a correct reading of the spec section 5 state table. The hazard it leaves is a Minor finding below.

## Quality

- Structure: each template is short, follows its record's section 2.4 order exactly, and keeps the rules in a comment, apart from the placeholder body. There is no trailing whitespace. The only lines over 80 characters are the verbatim section 2.4 forms, the closing line, one table row and one state list.
- Error handling (empty and edge cases): the templates say what to write when a part is empty:
  - `None yet.` for a brief's rulings;
  - `quality: none-declared` and `none-present`;
  - the optional x-keys left out;
  - the Suggestions section dropped outside the suggestions task;
  - `None` for an empty Rulings list in the final report;
  - Self-review boxes left unchecked until the plan is planned.
- Tests: swe-pod has no unit suite (it is Markdown only), so the done-when script is the only test.
  - It checks real structure, not loose wording: whole-line matches, heading order, front-matter keys only inside the front-matter, block lines only inside the fence, the 18-space continuation, and the test brief's last line.
  - For a format deliverable whose contract is "exact", that is the right kind of check.
  - Its red run was shown before any content existed (1 ok, 45 FAIL). Check (3)'s red was shown against the T0 tree, and the reviewer confirmed it.
- Test suggestions, for-the-reviewer parts. No unit suite can cover them, so the reviewer read each location:
  - T2.TS1, spec.md:8-22: the fragility is confirmed (a Minor finding below).
  - T2.TS2, review.md:3: the template follows section 2.4 and agents/swe-review.md. The issue is in the plan (a Minor finding below, for a ruling).
  - T2.TS3, ledger.md:13-31: the fragility is confirmed (a Minor finding below).
  - T2.TS4, evidence.md:15-17: holds. The replacement line is named exactly, and PROCESS.md section 7 and agents/swe-test.md repeat the rule.
- Report accuracy: the files, the range 0ee5f01..aa84b73, the trailers, the 11 keys and the 16 forms all match the diff. Two details are loose, and the report discloses both:
  - one green line under Check (3) comes from a check that the command shown does not contain;
  - the push also carried T3's unpushed 0ee5f01. That follows from the shared local branch of plan section 4.1 and does not change T2's diff by trailer.

## Findings

- Minor swe-pod/templates/records/spec.md:18 The three state-line forms start at column 0 inside the template comment. A spec made from the template that keeps its comment therefore contains `- approved: ...`, and a reader that greps for that line (the lead's approval check, the T7 status skill) would read a proposed change as approved (R1). Indent the three forms inside the comment, or quote them inline, so no line of a fresh spec begins `- approved:`. T7 should take state only from the header list outside comments (report concern 3, T2.TS1).
- Minor swe-pod/templates/records/ledger.md:14 The 16 event forms are live lines in the fenced block, and only the comment says a new ledger's block starts empty. A ledger copied without emptying the block holds placeholder `dispatch` and `spec approved by` events, so a state reader sees the change as building and approved (spec section 5 state table, R18.S1, T2.TS3). Move the forms into the comment and leave the block empty, or mark them plainly as examples to delete.
- Minor swe-pod/templates/records/report.md:19 `## Files` has no slot for the commit range, and `## Test output` has none for the single full unit-suite run as `unit <p>/<n> pass`. agents/swe-build.md Returns asks for both, spec section 5.3 has the builder run the suite before reporting, and the lead takes both from the report for its `T<n> <status>, <repo> <sha7>..<sha7>, unit <p>/<n> pass` ledger line.
- Minor swe-pod/templates/records/review.md:13 `## Spec compliance` has slots only for missing, extra and misread. Under it, agents/swe-review.md also asks whether each rule the brief's done-when leaves to review holds, and in fix mode whether each finding under fix is closed or open. Plan section 7 makes the first of these part of every review task. Add a line for each.
- Minor swe-pod/templates/records/brief.md:31 The comment says the template serves build and review tasks, but `## Result goes to` lists only commits on change/<id> and a report. A review brief needs the review record's path and no commits. Add the review variant, as test-brief.md does with "keep the lines that apply".
- Minor swe-pod/templates/records/plan.md:55 `## 6. Test tasks` has forms for the project-level tests, suggestions and verify tasks. It has none for the test task that updates matching tests in `tests/` when the spec lists `supersedes` entries, which PROCESS.md section 4 item 6 and agents/swe-plan.md both require (spec section 5.1, R2.S2).
- Minor swe-pod/templates/records/review.md:3 One `diff:` line per range, as plan section 2.4 and agents/swe-review.md require, repeats a YAML key in a multi-repo review. Strict parsers reject a repeated key, and lenient ones keep only the last range (report concern 4, T2.TS2). The template matches the contract, so this is a plan-level issue: rule on it, or change section 2.4 (for example to `diff: [<repo> <sha7>..<sha7>, ...]`), at the whole-change review.

