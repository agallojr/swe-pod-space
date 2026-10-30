---
task: T4
diff: swe-pod 0debc5a..3b22a1b
verdict: pass
---

## Spec compliance

This is the one re-review of the whole-change fix wave. I reviewed the fix diff only: swe-pod `0debc5a..3b22a1b`, one commit with trailers `Change: right-size-testing` and `Task: T1`, 12 files. `origin/change/right-size-testing` is at `3b22a1b`. I judged it against my 22 findings in `changes/right-size-testing/tasks/T4-review.md` and the ledger rulings of 2026-10-30T17:19Z and 17:33Z. I read the builder's `## Fix round 1` account but checked every claim against the diff.

- missing: none.
- extra: one choice beyond what my findings asked for: how the one-wave and all-at-risk wave cases are settled (Minor 11 below). It fits R10. No other extra.
- misread: none.

Status of each finding at `3b22a1b`:

**Important**

1. swe-pod/PROCESS.md:723, the regression-only limit — **addressed.**
   - The skill's sentence now appears, in the same words, in PROCESS.md:750-753, agents/swe-lead.md:423-426 and README.md:51-54.
   - The sharded rule now reads "a pass for every scenario, unit suite, declared quality check and test of the change, and for every regression test a pass or a result that is no bar". It appears in PROCESS.md:827-829, agents/swe-lead.md:420-422, SKILL.md §1.7 and README.md:57-59.
   - The old wording is gone from PROCESS.md and swe-lead.
2. swe-pod/skills/swe-pod/status-format.md:178, the one-wave whole-change review that was never ready — **addressed.**
   - SKILL.md §1.3 rule 3 now says a review reviews every build task its `after:` list names.
   - status-format.md:184-188 makes such a review ready once those tasks have reported, and SKILL.md:404-408 (Go) matches.
   - Traced on this change's plan: T4 is the whole-change review with `after: [T1]`, and T1 is a build task. So T4 reviews T1 and became ready at the 16:58Z report.
   - When it is done (status-format.md:171-173): `T1 review:` closed, plus its own line.
3. swe-pod/skills/swe-pod/SKILL.md:114, the wave review — **addressed** (in scope by the 17:19Z ruling).
   - A `### T<n> Review of wave <w>` reviews every build task its `after:` list names.
   - It is ready once they report.
   - It is done once each of their `T<n> review:` lines closes, which matches PROCESS.md:482-486 and agents/swe-lead.md:349-355, where its findings are recorded.
   - A whole-change review after verify reviews no build task and still counts its own lines. I read the archived fixtures of the regression suite (`T<n> Review of T<m>`, whole-change review `after: [T7]`) and T2's R5.S3/R5.S4 fixtures (whole-change review `after: [T3]`): each reads exactly as it did at `0debc5a`.
4. space/changes/right-size-testing/tasks/T1-report.md:940, the R13.S2 check — **addressed.**
   - The rewritten check applies the cost-class rule, as stated in swe-pod at `$REV`, to the front matter of every test in `tests/build-swe-pod/` at `$SREV`.
   - I reran it with `SREV=6f1e4e0` and with the space head. Both are the same `tests/build-swe-pod` tree object (`3850382`).
     - `b7fc257`: 0 of 14 lines ok; the suite line is `FAIL ... no class 90`.
     - `0debc5a`: 11 of 11 lines ok.
     - `3b22a1b`: 11 of 11 lines ok, with `ok suite 90 tests: script 16, agent 74, live 0, no class 0, undeclared 0, no expected_s 0, no deliverables 0`.

**Minor**

1. swe-pod/agents/swe-build.md:154 — **addressed.** Lines 152-158 now say the lead declines a suggestion bound for the test agent whose risk a planned test covers. The spec-author and builder routes stay, as the 17:19Z R7 ruling says and as PROCESS.md §6 states.
2. swe-pod/PROCESS.md:355 — **addressed** (365-367). It now says "an agent-class or live-class run the plan does not list", matching §11 and the 17:19Z R3 ruling.
3. swe-pod/PROCESS.md:302, the supersedes test task — **addressed** in all five places: PROCESS.md:215-219 and 304-307, agents/swe-plan.md:92-95 and 191, and agents/swe-spec.md:104-107. A test task writes the replacements, verify gives the old tests `superseded by <key>`, and integrate moves them out. No "updates the matching tests in `tests/`" text is left.
4. swe-pod/skills/swe-pod/SKILL.md:248 — **addressed** (254-258). A path ending in `/` now holds a touched path, and an empty path or `.` names the whole repo.
5. swe-pod/skills/swe-pod/status-format.md:125 — **addressed** (124-130). A shard's own line looks for the `<key>` in every shard's latest record, and the broken line is reflowed.
6. swe-pod/skills/swe-pod/status-format.md:186 — **addressed.**
   - SKILL.md §1.4 now reads harness-error and not-dispatched lines.
   - A task with a not-dispatched line and no newer dispatch line is `blocked`, so `next:` lists it under blocked.
   - Both lines are task events with cell text in the Latest table.
7. swe-pod/templates/records/review.md:18 — **not addressed in the template; parked by the 17:33Z ruling.** The template is outside the file map. agents/swe-review.md:84-88 now names the R6 check in its Quality section.
8. swe-pod/templates/records/plan.md:174 — **addressed.** The regression row's Keep cell is now `keep`, and the comment gives the reason. This change's own `plan.md` §9 still says `already in tests/`; that is the lead's text to change if wanted.
9. swe-pod/templates/records/plan.md:146 — **addressed** (148-150). It now says "the latest evidence when there is one".
10. swe-pod/PROCESS.md:765 — **addressed** (PROCESS.md:795-798, agents/swe-lead.md:387-390). In a one-wave plan, a fix that lands after the whole-change review gets a review of its fix diff only.
11. swe-pod/PROCESS.md:304, the two unsettled cases — **addressed.**
    - A one-wave plan's one review covers every build task, those marked at risk included.
    - A wave whose build tasks are all at risk has no wave review.
    - Both fit the spec: R10.S2's "there is one" has no condition, R10's "only where" limits single-task reviews without requiring them, and R10.S1 defines a wave's review as covering the tasks not reviewed alone.
    - The same sentences appear in PROCESS.md §4 item 7 and §5, agents/swe-plan.md, agents/swe-lead.md and the plan template.
12. swe-pod/PROCESS.md:1087 — **addressed.**
    - §6 (PROCESS.md:530-537), §11 (PROCESS.md:1107-1110) and agents/swe-lead.md:154-156 and 463-466 all say the expensive-run rows go under `## Global constraints` in a test-writing brief and under `## Task` in a verify brief.
    - The rows hold nothing of the build, so the blind-brief rule holds, and the test-brief template needs no change.
13. swe-pod/INSTALL.md:134 — **addressed** (134-139). G3 now covers every run the plan lists, the runs a test-writing task makes at base included.
14. swe-pod/agents/swe-test.md:190 — **addressed** (199-202). It now has the readable-diff and not-green clause in PROCESS.md's words.
15. swe-pod/PROCESS.md:328 — **addressed** (PROCESS.md:338-341, agents/swe-plan.md:120-123). The text now says what makes a requirement at risk, and the R1.S2 check gains two lines that read it. My rerun:
    - `b7fc257`: 0 of 11 lines ok.
    - `0debc5a`: 9 of 11 lines ok.
    - `3b22a1b`: 11 of 11 lines ok.
16. swe-pod/README.md:39 — **addressed** (39-40).
17. swe-pod/PROCESS.md:1055 — **addressed** (reflowed, 1072-1078).
18. swe-pod/agents/swe-build.md:106 — **addressed** (reflowed).

Totals: 21 addressed and 1 parked by ruling. This matches the ledger's `T1 fix round 1/5: 21 addressed, 1 open`.

## Quality

- **structure:**
  - Each fixed rule reads in one wording across every file that states it.
  - The new skill rules are written as rules the skill applies to records (§1.3 rule 3, the ready and done rules, the not-dispatched line), not as instructions to the lead.
  - One new reflow defect: the Minor at swe-plan.md:103 below.
- **error handling:**
  - A not-dispatched task now shows `blocked` in STATUS.md until a newer dispatch line names it, instead of showing `ready`.
  - A whole-change review in a one-wave plan is now done only when both its build tasks' review lines and its own line have closed.
- **tests (checks rerun):**
  - I reran every check in T1's report at `b7fc257`, `0debc5a` and `3b22a1b`: the 24 unchanged checks, the rewritten R1.S2 and R13.S2 checks, and the two new evidence commands.
  - My counts match the builder's table in every cell.
  - At `3b22a1b`, every check prints only `ok` lines, and R15.S1 prints `lines-allowing-another-model 0`.
  - Evidence for Important 1: 1 of 10 lines ok at `0debc5a`, 10 of 10 at `3b22a1b`.
  - Evidence for Important 2 and 3: 0 of 9 at `0debc5a`, 9 of 9 at `3b22a1b`.
  - I did not rerun the space runner, because it writes a scratch tree. The builder's runner output shows I2, I4, I5 and R16.S1 passing; I1 and I3 failing only on I1.2 and I3.14, which T3's replacements cover; and T2's two script tests and T3's two tests passing at `3b22a1b`.
- **for the lead:** the rewritten R13.S2 check needs `SPACE` and `SREV` as well as `SWE` and `REV`. T5's brief must give a space sha. Any sha whose `tests/build-swe-pod` tree is `3850382` gives the same result, and that tree is the same from `6f1e4e0` to the space head.
- **concerns in fix round 1:**
  - The review template line is parked by ruling.
  - SPEC.md:1105 still gives the old G3 wording with no note. Open call 18 names only R5, R12, R13, R21 and the model lines, the same reason I accepted no note at SPEC.md §5.2, so this is not a finding.
  - The operator's overlay quotes the old G3 title. The overlay is out of scope.
- **Q1, over the 12 files the fix diff touches: pass.** No Critical or Important disagreement is left.
  - These rules now read the same in every file that states them:
    - the regression-only limit and the sharded rule
    - which build tasks a review reviews, when it is ready and when it is done
    - the one-wave and all-at-risk wave cases
    - suggestion routes
    - the ask rule
    - the supersedes replacement task
    - where the expensive-run rows go in briefs
    - the at-risk criterion
    - the readable-diff clause
    - G3
  - The only remaining items are Minor: the parked review template, and the new reflow defect.

## Findings
- Minor swe-pod/agents/swe-plan.md:103 A reflow defect from the fix: the line runs to 86 characters ("comes before verify. A wave whose build tasks are all marked at risk has no wave"). PROCESS.md:367 ("(§11). Section 6 gives every agent-class") and PROCESS.md:484 ("review: their own reviews cover it. Record the review") stop mid-paragraph on short lines.
