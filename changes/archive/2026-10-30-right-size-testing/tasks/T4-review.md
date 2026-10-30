---
task: T4
diff: swe-pod b7fc257..0debc5a
verdict: fix
---

## Spec compliance

What I read: the spec (approved 2026-10-30T16:03Z), the plan, every ledger ruling and suggestion outcome, T1's report, T2's four tests and T3's two with their reports, and swe-pod's diff `b7fc257..0debc5a`. The diff is one commit with trailers `Change: right-size-testing` and `Task: T1`; it changes 16 files, and I read each one whole at `0debc5a`. The remote `change/right-size-testing` is at `0debc5a`. There is no evidence record yet: by the 16:22Z ruling, verify (T5) runs after this review. So completeness is checked against the text and T1's checks, not against evidence.

- missing:
  - **Green rule (R5, the requirement at risk).** R5 makes `not-selected` and `superseded by` no bar only on regression tests. Only `skills/swe-pod/SKILL.md` §1.6 says so. `PROCESS.md` §7 does not. Its sharded rule, `agents/swe-lead.md` and `README.md` go further and allow "a pass or a result that is no bar" for every scenario, unit suite and quality check. The ledger declined T1.TS5 on the strength of that one skill sentence.
  - **Review tasks in the skill (R10).** The skill's task-state rules were not updated for the new review layout:
    - In a one-wave plan, the whole-change review is never ready by the skill's rules.
    - A wave review is never ready and never done.
    - So the skill's Go would never dispatch either one. This change's own T4 is such a review, and the lead dispatched it by hand from `swe-lead`.
- extra (each serves a spec clause or replaces a retired form; all accepted):
  - §11: a test task's brief quotes the plan's expensive-run rows (one Minor on this, below).
  - Final report: the `moved out:` line, and `unknown` allowed in the Estimate cell.
  - `status-format.md` shows the regression part whenever the space has a regression test.
- misread: none that changes what an agent does. The R7 reading needs a ruling (concern 5 below).

**Rules the done-when leaves to review**

Each of T1's 26 checks against its scenario (R6.S1):
- I reran all 26 checks from the report at both shas.
  - At `b7fc257`: 7 of 208 lines ok, and `lines-allowing-another-model 4`.
  - At `0debc5a`: 208 of 208 lines ok, and `lines-allowing-another-model 0`.
  - The done-when's model grep prints 4 lines at `b7fc257` and nothing at `0debc5a` (exit 1).
- Each check looks for fixed sentences in every file that states the rule, and checks that retired text is gone.
- These checks exercise their THEN through the text an agent reads, which is what a builder's test can do in a doc repo (plan step 1): R1.S1, R2.S1, R3.S1, R3.S2, R4.S1, R4.S2, R6.S1, R6.S2, R7.S1, R7.S2, R8.S1, R8.S2, R9.S1, R9.S2, R10.S1, R10.S2, R11.S1, R11.S2, R12.S1, R12.S2, R13.S1, R14.S1, R14.S2 and R15.S1.
  - R9.S1 checks the rule only. No harness in scope has the 120 s abort (T2 used a watcher on its own node), and the reusable harness is out of scope.
- **R1.S2 (Minor):** the check covers the marks, the reason, naming the part of the risk, and the self-review failure. It does not show that a planner would mark a reported live-only defect at risk, because no text gives a criterion. Open call 3 leaves that to the planner's judgment, so this is Minor.
- **R13.S2 (Important):** its GIVEN is this space's `tests/build-swe-pod/` at base, but the check reads only swe-pod's rule text and never the suite. It would still pass if a test's `mode:` mapped to no class.
  - The THEN does hold today. I read the front matter of all 90 tests: 16 have `mode: inspect` (script class), 74 have a `mode:` starting `agent` or `desk` (agent class), none lacks a mode, and all 90 declare `expected_s:` and `deliverables:`.

Q1 is reported under Quality.

T1's other done-when items:
- The commits are on the remote.
- I did not rerun the six regression tests, because the runner writes a scratch tree. The report's per-check output shows only I1.2 and I3.14 failing, as planned.
- "T4 has no open Critical or Important finding" does not hold (Findings).

**T1's concerns, confirmed or rejected**

1. The brief was cut off in 2.9. Closed by the 16:31Z refile; what was built matches plan §2.
2. Whole-change review timing in a one-wave plan: **confirmed** as the general rule. If the review ran after verify, a one-wave plan would deadlock: a build task is done only when its review closes, and verify waits for the build tasks. R10.S2 and open call 2 support the change. It was not carried into the skill (Findings).
3. One `T<n> review:` line per covered build task, plus one under the whole-change review's own number: **confirmed** for build tasks and the whole-change review. **Rejected** where the report says it "keeps the skill's task states working with wave reviews unchanged": wave reviews never get a line of their own, so the skill never marks them done, and readiness also fails (Findings).
4. R3: **confirmed** that an unlisted script-class run needs no ask:
   - R3's "only when" limits when the lead asks; it does not force an ask.
   - R3.S2 asks about an unlisted live run.
   - The Why and open call 5 put the cost in agent-class and live-class runs.
   - The one-line summary at PROCESS.md:355 drops the qualifier (Minor).
5. R7: the reading is defensible but should be a ruling.
   - For it: both R7 scenarios are about suggestions headed for the test agent, and build-swe-pod/R21.S2, which plan T6 keeps, needs the "proposed as scenario" and "unit-tested" outcomes.
   - Against it: R7's words are broader ("record every other suggestion as declined"), and the ledger has no ruling on this reading. The lead should record one.
   - `agents/swe-build.md` says the lead "declines the rest" (Minor).
6. The two additions beyond 2.9: both **confirmed**. `moved out:` serves R12.S2 and plan T6; an unknown Estimate cell serves R14.S2's "spend that no one estimated".
7. No-bar results only on regression tests: **confirmed** as what R5 means. It is missing from PROCESS.md (Important).
8. Regression part shown whenever the space has a regression test: **confirmed**. Without it, a record with every test `not-selected` would show no regression part.
9. `heavy:` retired: **confirmed**. The operator's overlay is out of scope; INSTALL.md G3 gets a Minor.
10. Files outside T1's touches: `test-brief.md` and the space README agree. `templates/records/review.md` has no place for the R6 check (Minor).
11. No SPEC.md note at §5.2: **confirmed**. Open call 18 names only R5, R12, R13, R21 and the model lines.
12. I1.2 and I3.14: **confirmed**. I diffed T3's two tests against build-swe-pod's; they differ only in the version line and the prose about it.

## Quality

- **Structure:**
  - Each altered rule is written once and the same sentence is repeated in PROCESS.md, the role files, the skill and the templates. The forms of plan §2 appear verbatim.
  - PROCESS.md keeps its 15 level-2 headings and the plan template its 12 (counted outside code fences).
  - The process version is `@2` on PROCESS.md line 3, in its §1 `pod.yaml` example and in `templates/space/pod.yaml`.
  - There are two reflow defects (Minor).
- **Error handling:**
  - The green rule lists every bar.
  - Selection falls back to `touched` when a remote cannot be read, and a record whose `touched` leaves out a file of a readable diff is not green.
  - A task stops after the third harness error.
  - Gaps (all Minor): a deliverable path ending in `/` is never picked; a shard's own status line disagrees with the combined line; the new ledger forms are invisible in STATUS.md.
- **Tests:**
  - T1's 26 checks fail at base for the reasons they give and pass at the head; I reproduced both.
  - Because they only check that sentences are present, they cannot see a contradicting sentence elsewhere. For example, R7.S2's check passes while `swe-build.md` says "declines the rest". So Q1 rests on this review's reading, not on the checks.
  - T2's R5.S1 and R5.S2 script tests (I read them for a change detector, as the 16:51Z ruling asks):
    - They are not change detectors of the harmful kind. Checks 1 and 4 read the forms fixed by contract 2.3 and 2.5. Checks 2 and 3 need three words in one paragraph, not a fixed sentence.
    - But checks 2 and 3 would also pass a wrong rule that uses the same words. So the "green" outcome of R5.S1 and R5.S2 is really shown by the agent-class control cases: `pad-banner` in R5.S4 and `banner-late` in R5.S3.
    - They stand as written.
  - T3's two tests are build-swe-pod's checks with only the version line changed (diffed).
- **Test suggestions:** swe-pod has no unit suite, and none of T1's 26 checks reads any of the five "for the reviewer" locations, so I read each at `0debc5a`:
  - T1.TS1 (SKILL.md:266-283, PROCESS.md:717-737): the `I<n>` and `T<n>.TS<k>` condition reads the same in both files. Holds.
  - T1.TS2 (SKILL.md:250-262, PROCESS.md:679-705): in both files the picks follow the readable diff, and a `touched:` that leaves out a file of it makes the record not green. Holds. `agents/swe-test.md` does not state the not-green clause (Minor).
  - T1.TS3 (SKILL.md:246-249): the folder-prefix rule and the alias strip hold for every deliverable the suite declares today. A path ending in `/`, or a whole repo, would never match (Minor).
  - T1.TS4 (SKILL.md:326-333, status-format.md:110-125): the combined results hold. Each `not-selected` is judged by its own record, and each `superseded by` key is looked for in every shard's record. The per-shard status line disagrees with the combined line (Minor).
  - T1.TS5 (SKILL.md:277-283): the limiting sentence is there, but PROCESS.md lacks it (Important).
- **Q1: fail.**
  - Important disagreements:
    - The green rule's regression-only limit: SKILL.md says it; PROCESS.md, swe-lead and README do not.
    - Review readiness: PROCESS.md, swe-lead and the plan template on one side; SKILL.md and status-format.md on the other.
  - Minor disagreements:
    - Suggestion routes: swe-build against PROCESS.md and swe-lead.
    - Who gets asked: PROCESS.md §4 against §11.
    - The supersedes test-update task against integrate's move-out and `superseded by`.
    - Deliverable folders: SKILL.md against plan 2.2's wording.
    - Shard line against combined green.
    - The Keep cell's values.
    - A test task's brief against the blind-brief rule.
    - INSTALL.md G3 against the no-ask rule.
    - The review template against the R6 check.
  - These topics read the same in every file that states them:
    - risk-named tests
    - estimates
    - cost classes
    - harness errors
    - live tests
    - the fix loop
    - integrate's promotion
    - the cost report
    - models: no file allows a lesser model; every role file says `model: inherit`; the sentence is in PROCESS.md, swe-lead, README and INSTALL.

## Findings
- Important swe-pod/PROCESS.md:723 The green rule does not say that `not-selected` and `superseded by` are no bar only on regression-test results; SKILL.md:279-282 does. PROCESS.md:809-810, agents/swe-lead.md:412-417 and README.md:51-55 allow "a result that is no bar" for every scenario, unit suite and quality check, and the T1.TS5 decline rests on the skill's sentence alone. State the limit in PROCESS.md §7 and its sharded rule, in swe-lead and in README.
- Important swe-pod/skills/swe-pod/status-format.md:178 In a one-wave plan the whole-change review is never ready. It reviews no single task (SKILL.md:112-113), so it waits for its `after` build tasks to be done, and they are done only once it closes. The skill's Go (SKILL.md:394-398) never dispatches it and `next:` never names it, against PROCESS.md:765-767, agents/swe-lead.md:270-272 and templates/records/plan.md:142-143. This change's T4 is such a review.
- Important swe-pod/skills/swe-pod/SKILL.md:114 A wave review in the template's form (`### T<n> Review of wave <w>`, `after:` several build tasks) reviews no single task by §1.3. So it is never ready, for the same reason, and never done, because PROCESS.md:471-474 and agents/swe-lead.md:349-352 record its findings only under the build tasks' numbers. This overlaps the out-of-scope Reviews-cell item only in part; a ruling should say whether it is parked.
- Important space/changes/right-size-testing/tasks/T1-report.md:940 The R13.S2 check does not exercise its scenario (R6.S1). Its GIVEN is this space's tests/build-swe-pod/ at base, but it reads only swe-pod's rule text, so it would pass with a test whose `mode:` maps to no class. It should map each test's `class:` or `mode:` by the rule. The THEN holds today: of 90 tests, 16 are inspect and 74 are agent or desk.
- Minor swe-pod/agents/swe-build.md:154 Says the lead "declines the rest" of the suggestions, while PROCESS.md:577-590 and agents/swe-lead.md:305-317 also route them to the spec author or the builder. The R7 reading behind those routes needs a lead ruling.
- Minor swe-pod/PROCESS.md:355 "asks the operator only about runs the plan does not list" drops the "agent-class or live-class" of PROCESS.md:1074-1075. So §4 asks about an unlisted script check and §11 does not.
- Minor swe-pod/PROCESS.md:302 For a spec with `supersedes`, the test task "updates the matching tests in `tests/`" (also PROCESS.md:216-217, agents/swe-plan.md:92-93 and 182-183, agents/swe-spec.md:104-106). But integrate moves those tests out (PROCESS.md:874-879) and verify gives them `superseded by <key>`. Say the task writes their replacements in `changes/<id>/tests/`, as T3 did.
- Minor swe-pod/skills/swe-pod/SKILL.md:248 By the prefix rule, a deliverable path ending in `/`, or a whole repo, never holds a touched path, though plan 2.2's "or a folder that holds one" covers it. Such a test's `not-selected` would read as no bar. No test declares one today.
- Minor swe-pod/skills/swe-pod/status-format.md:125 A shard's own line counts `superseded by <key>` as a bar when `<key>` passes only in another shard. It then shows `not green` while the combined line shows `green` (SKILL.md:328-329 looks in every record). Also a broken line at 127.
- Minor swe-pod/skills/swe-pod/status-format.md:186 The new ledger forms are not task events. A task recorded as `T<n> not dispatched` still shows `ready` and `next:` names it, and a `T<n> harness error` line never shows.
- Minor swe-pod/templates/records/review.md:18 The Quality section has no line for the R6 check that PROCESS.md:485-487 and agents/swe-review.md:110-113 now require: that each builder's test for a requirement not at risk exercises its scenario, with an Important finding where it does not.
- Minor swe-pod/templates/records/plan.md:174 The regression row's Keep cell, `already in tests/`, is neither `keep` nor `not kept: <reason>`, the only two values PROCESS.md:314 and agents/swe-plan.md:104 allow.
- Minor swe-pod/templates/records/plan.md:146 The whole-change review's done-when names "the latest evidence", which a one-wave plan's review, run before verify, does not have. PROCESS.md:771 says "when there is one".
- Minor swe-pod/PROCESS.md:765 In a one-wave plan the only review runs before verify, so a fix routed from a verify failure lands after it, and no rule says it gets a review. The 16:22Z ruling gives this change a review of that fix diff; the process could say the same.
- Minor swe-pod/PROCESS.md:304 Two cases are unsettled. A one-wave plan with a build task marked at risk meets both "one review, the whole-change review" and "a review of one build task only where its entry has `- risk: at risk`". A wave whose tasks are all at risk gets a wave review that covers none. Say which rule holds.
- Minor swe-pod/PROCESS.md:1087 A test task's brief "quotes the plan's rows for the expensive runs", but PROCESS.md:518-524 lets a test-writing brief carry only its entry, the spec path, the contract, the constraints and the test map. templates/records/test-brief.md has no place for the rows; T2's brief put them under Global constraints.
- Minor swe-pod/INSTALL.md:134 G3 covers only a verify task. A deployment that copies it will still stop to ask before the listed agent-class runs a test-writing task makes at base, which PROCESS.md:1078-1079 lets go ahead with no ask.
- Minor swe-pod/agents/swe-test.md:190 Verify step 3 defines `touched:` but does not say that a readable repo's diff decides the picks, or that a record whose `touched:` leaves out a file of that diff is not green (PROCESS.md:698-701, SKILL.md:250-262).
- Minor swe-pod/PROCESS.md:328 No text says what makes a requirement at risk, so whether R1.S2's reported live-only defect is marked at risk rests on the planner's judgment alone (open call 3). One sentence naming such cases (a reported defect seen only live, a rule that decides verified) would let its check show the THEN.
- Minor swe-pod/README.md:39 "and a build task of its own only when the plan marks it at risk" is missing its noun: it should be "a review of a build task of its own".
- Minor swe-pod/PROCESS.md:1055 One line of 111 characters in the Ordering bullet, left by a reflow.
- Minor swe-pod/agents/swe-build.md:106 A reflow left "reruns it. For a" on a short line of its own.
