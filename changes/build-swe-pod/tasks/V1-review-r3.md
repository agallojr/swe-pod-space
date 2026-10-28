---
task: T1, T6, T7
diff: swe-pod 079cd89..4d5bfc7
verdict: pass
---

This is the fix-mode review of fix round 5 of the verify fixes to T1, T6 and T7. The diff is three commits on `change/build-swe-pod`, each found by its `Task:` trailer, in one line from parent `079cd89`:

- `f7545b1` (T1): PROCESS.md;
- `f3dabea` (T6): agents/swe-test.md;
- `4d5bfc7` (T7): skills/swe-pod/SKILL.md.

I checked the diff against the three findings `V1-review-r2.md` left open. I also checked it against SKILL.md section 5, step 4, the evidence and final report templates, status-format.md and plan §9. Line numbers are at `4d5bfc7`.

## Spec compliance

Findings under fix:

- **Important PROCESS.md:546: closed.**
  - §7 (544-551) now takes the `scenario:` value, less any `<change>/` part, only when that value is exactly one id. When the value lists several ids, or the test has none, `<value>` is the id the file name carries. That id comes in the three forms that SKILL.md section 5, step 4 gives (369-371). The bullet ends "So each test has at most one key."
  - SKILL.md 1.6 (206-212) says the same, clause by clause, and points to section 5, step 4 for the file-name forms. swe-test.md step 4 (168-174) says the same for a test in `tests/<change>/`.
  - For a test directly in `tests/`, the `<change>` fallback now takes a `scenario:` value only when it is one id written `<change>/<value>`. PROCESS.md:543 and SKILL.md:204-205 say this alike.
- **Minor swe-test.md:167: closed.** The short form (168-174) now gives the same order as §7 and 1.6:
  1. the archived plan test map;
  2. else the archived final report;
  3. with no row, the `scenario:` value less any `<change>/` part, when it is one id;
  4. else the file-name id.

  A qualified value with no row now gives `<change>/R<n>.S<m>`. The closing pointer names the one case it leaves to §7, a test directly in `tests/`. The bullet still opens "by the rule of `PROCESS.md §7`".
- **Minor swe-test.md:40: closed.** The verify Reads paragraph (40-47) now names each archived change's folder, `changes/archive/<yyyy-mm-dd>-<change>/`, and that change's plan test map and final report. Verify mode is not blind. The "Do not read plan.md" line (38) and the Never rule (72-73) bind writing mode only, so the added read conflicts with nothing.

The key rule, walked over this change's tests:

- Once integrate moves them, `tests/build-swe-pod/` holds 90 test files directly. README.md, runner.sh and `fixtures/` are not tests of the suite. For all 90, `<change>` is `build-swe-pod`, the folder's name.
- 37 scenario tests: each has a row in plan §9 with its test name, and all 37 rows name a file that exists. `<value>` is the row's id, so the key is `build-swe-pod/R<n>.S<m>` under `scenarios:`.
- 8 inspection tests: none has a row, because plan §9 and the final report's `## Scenarios` table have rows for scenarios only. Each `scenario:` value is one id, so the key is `build-swe-pod/I<n>` under `x-checks:`.
- 37 suggestion tests have a one-id `scenario:` value. Each gets `build-swe-pod/T<n>.TS<k>` under `x-suggestions:`.
- 8 suggestion tests have a list as their `scenario:` value: the tests for T1.TS5, T3.TS2, T9.TS1, T10.TS1, T10.TS8, T11.TS1, T11.TS6 and T13.TS1. The value is not one id, so the key is the file-name id, under `x-suggestions:`. For example, `test_T1_TS5_computed_values_in_other_forms` (`scenario: T1.TS5, T5.TS6`) gets `build-swe-pod/T1.TS5`. In all 8, that id is the first in the list.
- Result: 90 keys, one per test, none shared and none missing:
  - 37 under `scenarios:`;
  - 8 under `x-checks:`;
  - 45 under `x-suggestions:`.

  PROCESS.md §7, SKILL.md 1.6 and swe-test.md step 4 give the same key for each test. Each key is also `build-swe-pod/` plus the key that section 5, step 4 gives the same file in `changes/build-swe-pod/tests/`. So this change's own evidence and a later change's evidence agree.
- The lists also name other ids: T5.TS6, T6.TS2, T14.TS3, T10.TS3, T10.TS2, T10.TS5, T11.TS4, T14.TS2 and T13.TS2. None of them has a test file of its own, so no key is claimed twice.

Other checks:

- missing: none.
- extra: none.
- misread: none.
- Each commit stays inside its owning task's touches:
  - T1: PROCESS.md;
  - T6: agents/swe-test.md;
  - T7: skills/swe-pod/SKILL.md.
- The evidence template's comments (17-18 and 27-30) and status-format.md (89-90 and 95-97) give no `<value>` rule of their own, so nothing else needed to change.
- No line added to PROCESS.md carries a bare requirement or operator-decision id. PROCESS.md still has 15 level-2 headings.
- Shareability check, once per owning task: 0 hits each for T1, T6 and T7.
- Repo state:
  - `git diff 74d23f1 4d5bfc7 -- SPEC.md spec-process.d2 spec-process.svg spec-process.png` is empty;
  - the working tree is clean at `4d5bfc7`, which is the head of `origin/change/build-swe-pod`;
  - no added line is over 80 chars or ends in a space.

## Quality

- structure: Each fix sits where its finding pointed. §7 and 1.6 use the same words, so the two can still be compared line by line. swe-test.md keeps a short form, and now states it in full for the case it covers.
- determinism: "exactly one id" settles the list case in `<change>` and `<value>` alike. One edge is left: a test directly in `tests/`, with no row, whose `scenario:` value is a list of qualified ids, has no `<change>` and so no key. This is not a finding:
  - integrate never puts a test directly in `tests/` (PROCESS.md:654);
  - §7 and 1.6 already say what a test with no key gives;
  - no test of this change is in that case.
- Reads: the verify Reads addition gives its purpose as "for the regression keys". Step 2 also reads the archive folder, to tell whether `tests/<change>/` counts. Verify mode is not blind, so the narrow label forbids nothing.
- tests: swe-pod has no unit suite. The builder's 6 done-when checks are greps, with red and green output. The script was deleted, so I read each rule. I then walked the 90 tests with a read-only script over their file names, their `scenario:` values and plan §9.
- test suggestions: T7.TS10 covers the list case that T6.TS6 missed. Its "for the reviewer" pointers hold the rule, give or take a line at each end: PROCESS.md:543-550, SKILL.md:205-212 and swe-test.md:166-174.

## Findings
none
