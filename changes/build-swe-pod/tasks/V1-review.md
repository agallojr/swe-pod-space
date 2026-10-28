---
task: T1, T2, T5, T7
diff: swe-pod 1cecea0..2a01192
verdict: fix
---

This is the fix-mode review of the verify fixes to T1, T2, T5 and T7. The diff is four commits on `change/build-swe-pod`, each found by its `Task:` trailer, with parent `1cecea0`:

- `b830ab2` (T1): PROCESS.md;
- `ec10cf6` (T2): templates/records/test-brief.md;
- `f174cf8` (T5): agents/swe-lead.md;
- `2a01192` (T7): skills/swe-pod/SKILL.md and skills/swe-pod/status-format.md.

I checked it against the seven verify findings under fix (a to g), spec §4, §5.5, §7, R5.S2, R12, R20 and R23, plan §2.2 to §2.6, and PROCESS.md.

## Spec compliance

Findings under fix:

- **a (T7): closed.** SKILL.md:44-61 adds a Branch head rule with three cases, in order:
  1. the remote can be read and lists the branch: the sha it lists;
  2. the remote can be read and has no such branch: `<repo> missing`;
  3. the remote cannot be read (`git ls-remote` exits non-zero): the end sha of the newest ledger range for that repo, in 1.4 event order. With no range, the go line's sha. With neither, `missing`.

  It reads only committed records, so two rebuilds that cannot read a remote give the same head. Three places now take the head from this rule, so the stale mark and the branches bullet cannot disagree:
  - 1.5 (SKILL.md:163-164);
  - the branches bullet (status-format.md:76-80);
  - "Same records, same text" (status-format.md:219-222).

  I re-ran `git ls-remote` against a local repo. It exits 0 with no output for a missing branch, and 128 for a path that cannot be read, as the three cases assume. One edge is left open: a plan entry that names several repos (Minor below).
- **b (T7): closed.** status-format.md:187 leaves out each count of 0. It writes `none` when no count is left or the line gives none, and adds the example `spec ok; 0 Important` gives `review: spec ok; none`. The rule is deterministic and agrees with the Example table (status-format.md:247).
- **c (T7): open.** No `test_*.md` under `tests/` is dropped now (SKILL.md:190-205). The key comes from the first of three sources: the archived test map, then the archived report's Scenarios table, then a qualified `scenario:` value, with a fixed folder-sort tie-break. But the rule cannot be met for the files c was about, and it now counts files that are not tests:
  - **No key for inspection and suggestion tests.** Promoted `test_I<n>_*` and `test_T<n>_TS<k>_*` files have no `<Rn.Sm>`. The plan's test-map template and the final report's Scenarios template have `R<n>.S<m>` rows only, and these tests' `scenario:` values are a bare `I<n>` or `T<n>.TS<k>`. So each one counts, but its result is always missing, and no evidence record can supply it.
    - This change's `changes/build-swe-pod/tests/` holds 8 such inspection tests and 45 suggestion tests. Once it integrates, no later change in the space can read verified.
    - PROCESS.md §7 (line 532) tells the test agent only `<change>/<Rn.Sm>`, so the writing side needs the matching rule as well.
  - **Fixture files counted.** "In that folder or any folder below it" also takes in fixture data. This change's `tests/fixtures/` holds 107 files named `test_*.md`: the fixture spaces' own tests. Before integrate they are not counted, because the change's own tests (SKILL.md:188) and the trace (step 4) count only test files in the folder itself. After integrate, no archived record names them, so each reads missing.
- **Ruling on the builder's concern (a bare `scenario:` value reads missing).**
  - For scenario tests the builder is right not to qualify the bare value. R6.S1 makes a plan's test map complete, so steps 1 and 2 key every promoted R-scenario test of a change integrated through this process, and qualifying a bare value would be a guess.
  - The concern is not a corner case, though. Where no archived record names a test at all, "it still counts, and its result is missing" is what happens to every inspection and suggestion test the process produces, and to every fixture file. That is finding c above.
  - So the narrower reading stands for R-scenario tests, but the key rule needs a source for the other tests.
- **d (T7, T5): closed.**
  - Words: SKILL.md:133-137 reads plain words saying `T<n>` is finished, done or complete as a DONE line, and "not" or "not yet" as no DONE line. status-format.md:186 points to it.
  - Review states: in status-format.md:165-170, a review task is dispatched only by its own dispatch line. It is ready once the task it reviews has reported and the rest of its `after` list is done.
  - Latest: a review task's events now include its own dispatch lines (status-format.md:176-178).
  - SKILL.md section 4 step 2 (312-315) defers to that state.
  - Lead: swe-lead.md:259-268 has the lead record `dispatch T<m> -> review (<local|mesh>, <env class|any>)` for every review, re-reviews and the whole-change review included. This agrees with PROCESS.md §11 ("Record each dispatch", and its Ordering rule for review tasks) and with spec §7: role, local or mesh, and environment class, no machine.
  - T7.TS3 fixture ledger, walked by hand: T0 is done (words), T1 has reported but is not done, T3 is dispatched, T4 is ready and T2 is waiting. So the next task is T4, as the test expects.
  - This change's own ledger has no review dispatch lines. Done is still decided first, and a review task is done once the review of its task is closed, with no dispatch line needed. So its reviews with closed review lines still read done. A review whose task has reported, and whose review is still open, reads ready until the lead writes its dispatch line, as the report says.
- **e (T5, T1): closed in PROCESS.md and swe-lead.md.** PROCESS.md:73-97 and swe-lead.md:110-132 agree on each point:
  - branches only for the repos in the spec's `repos:` list, made from the pin and pushed;
  - the lead runs the two commands itself only when the guidance's pod commit scope lets it; otherwise it gives the human the commands, filled in, and waits;
  - the go line is written only after `git ls-remote` lists each branch;
  - a repo the spec does not name gets no branch and no branch command.

  PROCESS.md states the guidance condition in words and cites INSTALL.md's "Rules for your guidance overlay". The fix adds no bare requirement, decision or guidance id: across PROCESS.md, R ids appear only inside its example spec and records. SKILL.md still disagrees with the lead's go step (Important below).
- **f (T5): closed.** swe-lead.md:60-62 now forbids pushing a code repo's `main` except the integrate merge, on the human's word. This matches its Writes list (44-45), Merge step 4 (436-440), PROCESS.md §1 (line 107) and §8 step 4, and INSTALL.md G1's "merging only on the human's word". A wording point is left (Minor below).
- **g (T2): closed.** templates/records/test-brief.md "Result goes to" now has `- report: changes/<id>/evidence/<YYYYMMDDTHHMMZ>-T<n>-report.md`, and its comment says every test task keeps that line. This matches plan §2.4 (Report) and swe-lead's lane for the test role. The exact closing line is still the last line.

Other checks:

- missing: nothing beyond c.
- extra: none. Each commit touches only its owning task's files: T1 PROCESS.md; T2 templates/records/test-brief.md; T5 agents/swe-lead.md; T7 skills/swe-pod/SKILL.md and status-format.md.
- misread: SKILL.md 1.1 and its "What it writes" section, against swe-lead's Go step 3 (Important below).
- Shareability check, once per owning task: 0 hits each for T1, T2, T5 and T7.
- `git diff 74d23f1 2a01192 -- SPEC.md spec-process.d2 spec-process.svg spec-process.png` is empty.
- PROCESS.md line 1, line 3 and its 15 level-2 headings are unchanged. The working tree is clean.

## Quality

- structure: Each fix sits in the section its finding names, and the old wording is gone: no "writes no dispatch line", no "`T<n> complete` in words", no head read only from the remote. The Branch head rule is stated once and cited from 1.5 and status-format.md.
- determinism: The new rules read committed records in fixed orders. The words rule in 1.4 needs some judgment, but it is bounded by its finished, done or complete versus not or not yet wording, and it applies only to ledgers written before the event forms existed. That is acceptable.
- error handling: An unreadable remote, a missing branch, no go line, zero counts and no counts each get fixed text. Two cases have none: a plan entry naming several repos in Branch head case 3, and a key for regression tests that are not scenarios (c).
- tests: swe-pod has no unit suite. The builder's 23 done-when checks are greps over the changed blocks: they show the wording landed, not that the rules work. So I read each rule and walked the T7.TS3 fixture ledger and this change's ledger by hand. The report has red and green output for each check.
- test suggestions: The for-the-reviewer pointers of T7.TS5 to T7.TS8 and T5.TS7 and T5.TS8 match the lines: SKILL.md:44-61, 163-164, 190-205 and 133-137; status-format.md:187 and 163-170; swe-lead.md:110-132 and 259-268; PROCESS.md:73-96. There is no unit suite to cover them. T7.TS7 would show c's remaining gap if it also put an inspection test, a suggestion test and a fixture file under `tests/`.

## Findings
- Important swe-pod/skills/swe-pod/SKILL.md:193 promoted inspection and suggestion tests (test_I<n>_*, test_T<n>_TS<k>_*) get no key: the archived test map and the final report's Scenarios table hold R<n>.S<m> rows only (templates/records/plan.md:112, templates/records/final-report.md:14), and these tests' scenario: values are a bare I<n> or T<n>.TS<k>, so each counts with its result missing and no evidence record can supply it; once a change with such tests integrates (this one has 53), no later change in the space can read verified; give these tests a key, and state the same key on the writing side (PROCESS.md:532) so the test agent writes results under it
- Important swe-pod/skills/swe-pod/SKILL.md:190 "in that folder or any folder below it" counts fixture data as regression tests: this change's tests/fixtures/ holds 107 files named test_*.md that move under tests/ at integrate, none of them named by any archived record, so each reads missing; the change's own tests (line 188) and the trace (step 4) count only test files in the folder itself
- Important swe-pod/skills/swe-pod/SKILL.md:42 the skill says never to push or create a branch in a code repo, and "What it writes" (line 383) says it writes nothing in a code repo, yet section 4 has it act as the lead, whose Go step 3 (agents/swe-lead.md:120-122) now runs git branch and git push itself when the pod commit scope allows it; a go given through the skill meets two contrary rules on the very step finding e fixes; limit the read-only rule to the skill's own steps, or have section 4 say that the lead's go step applies
- Minor swe-pod/skills/swe-pod/SKILL.md:54 Branch head case 3 ties a fix-round range to a repo through a plan entry with repo: <repo>, but does not say what an entry naming several repos gives (this change's T0 and T35 have repo: swe-pod, agent-mesh), so two readers can differ there
- Minor swe-pod/skills/swe-pod/SKILL.md:312 section 4 step 2's restatement of the ready rule leaves out "not held" and, for a review, "every other task in its after list is done", which status-format.md:167-170 has
- Minor swe-pod/agents/swe-lead.md:61 in this comma-separated Never list, "except the integrate merge, on the human's word," reads as two items; reword it, e.g. "push to a code repo's main other than the integrate merge the human asks for"
