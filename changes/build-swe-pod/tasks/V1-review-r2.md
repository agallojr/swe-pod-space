---
task: T6, T1, T7
diff: swe-pod 3280728..079cd89
verdict: fix
---

This is the fix-mode review of fix round 4 of the verify fixes to T6, T1 and T7. The diff is three commits on `change/build-swe-pod`, each found by its `Task:` trailer, in one line from parent `3280728`:

- `7296598` (T1): PROCESS.md;
- `49f0a93` (T6): agents/swe-test.md;
- `079cd89` (T7): skills/swe-pod/SKILL.md.

I checked it against the three findings `V1-review-r1.md` left open. I also checked it against SKILL.md 1.6 and section 5, status-format.md, the evidence and final report templates, and PROCESS.md. Line numbers are at `079cd89`.

## Spec compliance

Findings under fix:

- **Important swe-test.md:158: closed.**
  - Verify step 2 (141-143) defines the regression suite the way 1.6 counts it: each `test_*.md` directly in `tests/`, or directly in `tests/<change>/` for an archived change. Fixture data and anything else below those folders never count.
  - Step 4 (163-169) gives the three keys where 1.6 looks for them, by the rule of PROCESS.md §7: `<change>/R<n>.S<m>` under `scenarios:`, `<change>/I<n>` under `x-checks:` and `<change>/T<n>.TS<k>` under `x-suggestions:`.
  - The `scenarios:` bullet (161-162) no longer carries the R-only key. The `x-checks:` and `x-suggestions:` bullet (175-177) keeps bare keys for this change's tests and puts the regression keys beside them.
  - The short form at 166-169 states the common case and leaves the rest to §7. It leaves out two parts of the `<value>` rule (Minor below). The verify Reads paragraph (40-45) does not name the archived records that steps 2 and 4 now read (Minor below).
- **Minor PROCESS.md:532: closed.** §7 (531-552) now gives the key the way 1.6 does, clause by clause:
  - A `tests/<change>/` folder counts only when `changes/archive/<yyyy-mm-dd>-<change>/` exists, and nothing deeper counts (533-536; 1.6 at 193-198).
  - For a test directly in `tests/`, the change is found in this order: the archived plan test map, else the final report's `## Scenarios` table, with the archive folder name that sorts last winning a tie, then the change of a qualified `scenario:` value (538-543; 1.6 at 200-205).
  - `<value>` is found in this order: the row, from the test map, else from the final report; then the `scenario:` value, less any `<change>/` part; then the id the file name carries (544-549; 1.6 at 206-210). The three name forms at 548-549 are the ones section 5, step 4 maps (367-369).
  - A test with no key still counts (551-552). 1.6 (214-215) treats its result as missing, and 558-559 say the same.
- **Minor SKILL.md:354: closed.** Trace step 2 (351-355) looks for the file in `tests/<id>/` after integrate, which is where PROCESS.md:652 and swe-lead.md:442 put it.

One key rule:

- These files now name the same suite, the same `<change>/<value>` key and the same three places for it:
  - SKILL.md 1.6;
  - PROCESS.md §7;
  - swe-test.md steps 2 and 4;
  - the evidence template's comments (17-18 and 27-30);
  - status-format.md (89-90 and 95-97).

  PROCESS.md and 1.6 agree clause by clause. swe-test.md points to §7 for everything except the common case. Neither the template nor status-format gives a rule of its own that differs.
- I walked the rule on this change. Once it integrates, `tests/build-swe-pod/` holds 90 test files and 107 fixture files:
  - the 37 scenario tests get their keys from plan §9's rows;
  - the 8 inspection tests get `build-swe-pod/I<n>` from their `scenario:` value;
  - 37 of the 45 suggestion tests have a one-id `scenario:` value and get `build-swe-pod/T<n>.TS<k>`;
  - the other 8 suggestion tests have a list as their `scenario:` value, for example `scenario: T1.TS5, T5.TS6`.

  Plan §9 and the final report's `## Scenarios` table have rows for scenarios only. So for those 8, the rule takes the whole list as `<value>`, which matches none of the three key forms. They have no key, every later change's latest evidence lacks their results, and no later change is verified (Important below). The rule had this gap before this round, and `V1-review-r1.md` counted all 45 suggestion tests as keyed. This round restates the rule at PROCESS.md:546 and swe-test.md:168.

Other checks:

- missing: a key for a test whose `scenario:` value lists several ids (Important below).
- extra: none.
- misread: none.
- Each commit stays inside its owning task's touches:
  - T1: PROCESS.md;
  - T6: agents/swe-test.md, within swe-build.md, swe-test.md and swe-review.md;
  - T7: skills/swe-pod/SKILL.md, within SKILL.md and status-format.md.
- PROCESS.md cites no bare requirement or operator-decision id. The only ids in it are in the worked examples (the spec, plan, evidence and ledger samples) and in the id-format note at 212-213. No added line carries one. Line 1, line 3 and the 15 level-2 headings are unchanged.
- The old wording is gone:
  - "with regression results under qualified ids" in swe-test.md;
  - "or in `tests/` after integrate" in the trace;
  - "whose test map or final report names it" in PROCESS.md.

  No test in `changes/build-swe-pod/tests/` greps for the removed wording.
- Shareability check, once per owning task: 0 hits each for T1, T6 and T7.
- Repo state:
  - `git diff 74d23f1 079cd89 -- SPEC.md spec-process.d2 spec-process.svg spec-process.png` is empty;
  - the working tree is clean at `079cd89`;
  - no added line is over 80 chars or ends in a space.

## Quality

- structure: Each fix sits where its finding pointed. 1.6 and §7 now both state the key in full, in the same clause order, so the two can be compared line by line. swe-test.md carries a short form and a pointer. The new top-level bullet at PROCESS.md:553 splits the old long bullet, and it renders the same.
- determinism:
  - 1.6 and §7 fix the order, the tie-break and the fallbacks, and they say what a test with no key gives. They do not say what a `scenario:` value that is not a single id gives (Important below).
  - swe-test.md:175 still calls `x-checks:` and `x-suggestions:` optional. Read with the template's "leave either key out when there are none", that means "present when there are results", so it is not a finding.
- error handling: both sides now give fixed text for each of these cases:
  - fixture data;
  - a folder under `tests/` that is not a change;
  - a qualified `scenario:` value;
  - a missing row;
  - a missing `scenario:` value.
- tests: swe-pod has no unit suite. The builder's 9 done-when checks are greps, with red and green output. The script was deleted, so I read each rule and walked this change's 90 tests and 107 fixture files by hand.
- test suggestions: T6.TS6 points to swe-test.md:141-143 and 163-169 and to PROCESS.md:531-552, and those match the lines. As written it uses scenario, inspection and suggestion tests with one id each, so it would not catch the list case. No unit suite exists to cover it.

## Findings
- Important swe-pod/PROCESS.md:546 a test whose scenario: value lists several ids gets no key: 8 of this change's 45 suggestion tests have such a value (test_T1_TS5_computed_values_in_other_forms.md has scenario: T1.TS5, T5.TS6; also the tests for T3.TS2, T9.TS1, T10.TS1, T10.TS8, T11.TS1, T11.TS6 and T13.TS1); once they move to tests/build-swe-pod/, neither the archived plan test map nor the final report's ## Scenarios table has a row for them, so <value> is the whole list, which matches none of the three key forms; their results are then missing from every later change's latest evidence, and no later change is verified; SKILL.md:208-210 reads the same and swe-test.md:168 restates it; in all three places, take the id the file name carries when the scenario: value is not one id (or ahead of the scenario: value for a test in tests/<change>/), or make each such test's scenario: value a single id; the gap predates this round, which restates it
- Minor swe-pod/agents/swe-test.md:167 the short form of <value> for a test in tests/<change>/ ("its row's scenario id in that change's archived test map or final report, else its scenario: value") leaves out two parts of PROCESS.md:544-546 and SKILL.md 1.6: the test map comes before the final report, and the scenario: value drops any <change>/ part; so a qualified value with no row reads as <change>/<change>/R<n>.S<m>, the edge case this round closed in PROCESS.md, and "§7 gives the rest" can be read as covering only the other cases; state those two parts, or give only the pointer
- Minor swe-pod/agents/swe-test.md:40 the verify Reads paragraph (40-45) lists the brief, the spec, pod.yaml, the change's tests, tests/ and the code repos, but not the archived records that steps 2 and 4 now read: changes/archive/<yyyy-mm-dd>-<change>/, to tell whether a folder belongs to an archived change, and that change's plan test map and final report, for a regression test's key; add them
