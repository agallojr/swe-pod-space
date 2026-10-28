---
task: T1, T2, T5, T7
diff: swe-pod 2a01192..3280728
verdict: fix
---

This is the fix-mode review of fix round 3 of the verify fixes to T1, T2, T5 and T7. The diff is four commits on `change/build-swe-pod`, each found by its `Task:` trailer, with parent `2a01192`:

- `f1cf99c` (T1): PROCESS.md;
- `f833f72` (T5): agents/swe-lead.md;
- `7572de9` (T7): skills/swe-pod/SKILL.md;
- `3280728` (T2): templates/records/evidence.md.

I checked it against the findings the previous fix-mode review (`V1-review.md`) left open: c, its three Important findings and its three Minor ones. I also checked it against spec §5.6, R5.S2 and R12, plan §2.2 to §2.6, and PROCESS.md. Line numbers are at `3280728`.

## Spec compliance

Findings under fix:

- **c (T7, T1): closed in SKILL.md, PROCESS.md and the evidence template. One writer was not updated.** SKILL.md:193-215 gives every regression test the key `<change>/<value>`:
  - `<change>` is the folder `tests/<change>/` the test sits in. For a test directly in `tests/`, it is the archived change whose plan test map names the test, else the one whose final report does, with the folder that sorts last winning a tie. With neither, it is the change of a qualified `scenario:` value.
  - `<value>` is the scenario id in that change's archived row. With no row, it is the `scenario:` value without any `<change>/` part. With no `scenario:` value either, it is the id the file name carries (section 5, step 4).
  - `<change>/R<n>.S<m>` is looked for under `scenarios:`, `<change>/I<n>` under `x-checks:` and `<change>/T<n>.TS<k>` under `x-suggestions:`.

  I walked it on this change. Once it integrates, `tests/build-swe-pod/` holds 90 test files directly:
  - the 37 scenario tests take their ids from plan §9's rows;
  - the 8 inspection tests, whose `scenario:` is `I<n>`, key `build-swe-pod/I<n>` under `x-checks:`;
  - the 45 suggestion tests key `build-swe-pod/T<n>.TS<k>` under `x-suggestions:`.

  Each has a key an evidence record can give. The flat-layout overlays (T7.TS4, R15.S1, T1.TS2, T5.TS5) key `add-farewell/R1.S1` from the archived report row, which is how T5.TS5's evidence writes it.

  The writing side names the same three keys in PROCESS.md:531-544 and in the evidence template's comments (evidence.md:17-18 and 27-30). status-format.md:89-90 counts regression results through 1.6. Its x-checks and x-suggestions counts (95-97) take only the change's own tests, so nothing is counted twice. The common case, a test in `tests/<id>/` with a bare `scenario:` value, reads the same on both sides. PROCESS.md states three edge cases more loosely than 1.6 (Minor below).

  The test agent's own definition was not updated. swe-test.md:158-160 still puts regression results under `scenarios:` as `<change>/<Rn.Sm>`, and lines 166-167 give `x-checks:` and `x-suggestions:` bare keys only (Important below).
- **Important SKILL.md:193: closed**, as for c above.
- **Important SKILL.md:190, fixtures counted: closed.** SKILL.md:193-198 counts only:
  - a `test_*.md` directly in `tests/<change>/`, when that `<change>` has a folder under `changes/archive/`;
  - a `test_*.md` directly in `tests/`.

  Nothing deeper counts. The 107 fixture files that move to `tests/build-swe-pod/fixtures/` are not counted. Neither is a legacy `tests/fixtures/`, because no archived change has that name. The change's own tests (line 191) and the trace (step 4) still count only files in the folder itself. PROCESS.md:532-533 says "never fixture data below them", but leaves out the archive condition (Minor below).
- **Important SKILL.md:42, read-only rule against the lead's Go step: closed.**
  - SKILL.md:42-44 limits the rule to sections 2, 3 and 5, and leaves section 4 to the lead's definition.
  - Section 4 (312-316) says the lead's Go step applies as written. The lead makes and pushes each `change/<id>` when the pod commit scope allows it, and otherwise gives the human the commands. This matches swe-lead.md:110-132 and its Writes list (44-45).
  - "What it writes" (395-400) limits "nothing in a code repo" to the skill's own steps, and names the branches the lead makes at the go.
  - No sentence of the skill now forbids what section 4 does.
- **Minor SKILL.md:54, Branch head with several repos: closed.** SKILL.md:54-60 gives three cases:
  1. a range written `<repo> <sha7>..<sha7>` on any task's line counts for that repo;
  2. a bare fix-round range counts only when the plan entry names that repo alone;
  3. a bare range of a task whose entry names several repos counts for none.

  The only several-repo entries in this change's ledger, T0 and T35, have no range line there. Each repo's head reads from qualified or single-repo ranges in event order. The rule is deterministic.
- **Minor SKILL.md:312, ready rule: closed.** SKILL.md:325-329 now says the task is not held, has no dispatch line, and its `after` tasks are done. For the review of one task, it says that task has reported and every other task in its `after` list is done, as status-format.md:167-170 says.
- **Minor swe-lead.md:61: closed.** swe-lead.md:60-62 reads "push to a code repo's `main` other than the integrate merge the human asks for". It reads as one item and agrees with Merge step 4 (436-440).
- **Evidence template (T2):** only comments changed. The key lines are as plan §2.4 gives them, and the comments name the same three keys as PROCESS.md §7 and SKILL.md 1.6.

Promotion into `tests/<id>/`:

- PROCESS.md:640-641 (§8 step 5) and swe-lead.md:441-442 (integrate step 5) use the same words: move `changes/<id>/tests/` into `tests/`, as the folder `tests/<id>/`. This happens in the one space commit that also moves the change to `changes/archive/<yyyy-mm-dd>-<id>/`, so the folder and the archive that the 1.6 key needs always land together. SKILL.md 1.6 cites §8 for it.
- Spec §5.6 step 5 says "into `tests/`". R5.S2 says the tests are "in `tests/` and run as part of the regression suite". A subfolder meets both. This change's R5.S2 test accepts `tests/add-greeting/<name>` (test_R5_S2_tests_promoted_at_integrate.md:177).
- The R2.S2 test updates a superseded test in place in `tests/<old change>/`, so the test keeps its key.
- The trace in SKILL.md section 5, step 2 (354-355), still looks for an integrated change's test "in `tests/`" (Minor below).

Other checks:

- missing: the test agent's definition (Important below).
- extra: two additions go past what the plan and spec say:
  - The `<change>/I<n>` and `<change>/T<n>.TS<k>` keys go past plan §2.4's evidence keys ("regression results under qualified ids, `<change>/<Rn.Sm>`"). Finding c needed them.
  - The `tests/<id>/` folder goes past spec §5.6's "into `tests/`". The builder gives the reason for it.

  Plan §2.4 still reads R-only, which the lead may want to record.
- misread: none.
- Each commit stays inside its owning task's touches: T1 PROCESS.md; T2 templates/records/evidence.md; T5 agents/swe-lead.md; T7 skills/swe-pod/SKILL.md.
- PROCESS.md:
  - no added line carries a requirement, operator-decision, guidance or deliverable id;
  - the pod commit scope condition is still stated in words;
  - line 1, line 3 and its 15 level-2 headings are unchanged.
- The old wording is gone: "any folder below it", "except the integrate merge", "from this skill", "Regression results go under".
- Shareability check, once per owning task: 0 hits each for T1, T2, T5 and T7.
- Repo state:
  - `git diff 74d23f1 3280728 -- SPEC.md spec-process.d2 spec-process.svg spec-process.png` is empty;
  - the working tree is clean;
  - no added line is over 80 chars or ends in a space.

## Quality

- structure: Each fix sits where its finding pointed. The key rule is stated in full once (SKILL.md 1.6) and in short on the writing side (PROCESS.md §7 and the template comments). The integrate move is one phrase, the same in PROCESS.md and swe-lead.md. The insert leaves PROCESS.md:642 and swe-lead.md:443 as short lines. Markdown renders them the same, so this is not a finding.
- determinism: 1.6 reads committed records in fixed orders, with a fixed tie-break and a fixed fallback, and it says what a test with no key gives. The branch head and ready rules now leave no case to the reader's judgment. On the writing side, PROCESS.md leaves the tie-break and two fallbacks unstated (Minor below).
- error handling: each of these cases now gets fixed text:
  - a folder under `tests/` that is not a change;
  - fixture data;
  - a test with no archived row;
  - a test with no `scenario:` value;
  - a plan entry that names several repos.
- tests: swe-pod has no unit suite. The builder's 14 done-when checks and 4 template checks are greps over the changed blocks, with red and green output. The script was deleted, so I re-ran the absence checks by grep. I also read each rule and walked by hand this change's 90 tests and 107 fixture files and the flat-layout overlays.
- test suggestions: T7.TS7 (updated) and T7.TS9 point to SKILL.md:193-215, 39-44, 312-316 and 394-399, and to PROCESS.md:531-544, and those match the lines. T7.TS7 would also catch the swe-test.md gap if a test agent working from its definition ran the verify. No unit suite exists to cover them.

## Findings
- Important swe-pod/agents/swe-test.md:158 the test agent's own definition still puts regression results under scenarios: as <change>/<Rn.Sm>, and lines 166-167 give x-checks: and x-suggestions: bare keys only; after this round, PROCESS.md §7 (531-544) and the evidence template put a regression inspection test under x-checks: as <change>/I<n> and a suggestion test under x-suggestions: as <change>/T<n>.TS<k>, and leave out fixture data, which step 2 (line 139) does not mention; a test agent that follows its definition can write the 53 inspection and suggestion results this change will promote where SKILL.md 1.6 does not look, and the next change then does not read verified; state the three keys and the fixture rule there, or point to PROCESS.md §7 for them (T6's file, outside this round's touches)
- Minor swe-pod/PROCESS.md:532 the writing-side key is looser than SKILL.md 1.6 in three edge cases, though lines 540-541 say the skill reads the same key: it counts any folder tests/<change>/, where 1.6 counts one only when changes/archive/<yyyy-mm-dd>-<change>/ exists; for a test directly in tests/ it gives no order between the archived test map and the final report, no tie-break when several archived changes name the test, and no fallback to the change of a qualified scenario: value; and <value> takes the scenario: value without dropping a <change>/ part, so a qualified value reads as <change>/<change>/R<n>.S<m>; the common case, a test in tests/<id>/ with a bare scenario: value, agrees; state 1.6's order and conditions, or give the key as SKILL.md 1.6 defines it
- Minor swe-pod/skills/swe-pod/SKILL.md:354 trace step 2 still looks for an integrated change's test file "in tests/", but integrate now puts it in tests/<id>/ (PROCESS.md:641, swe-lead.md:442), and 1.6 now separates "directly in tests/" from "tests/<change>/"; read as directly in tests/, the trace reports a false scenario-without-test break for every integrated test; say tests/<id>/ there
