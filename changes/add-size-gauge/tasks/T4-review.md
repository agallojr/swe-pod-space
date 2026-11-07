---
task: T4
diff: swe-pod 3b22a1b..61d67db
verdict: fix
---

## Spec compliance
Reviewed: the spec, the plan, swe-pod's diff from base 3b22a1b to head
61d67db (one commit, 61d67db, trailers `Change: add-size-gauge` and
`Task: T1`, 16 files, all in the plan's file map), the ledger's rulings,
T1's brief and report. No evidence record yet (verify T5 follows this
review); no deferred minors in the ledger.

- missing: R6.S1 and R13.S1 at small. PROCESS.md §7 and the lead's
  "Whole-change review" paragraph still say the whole-change fix wave "also
  takes the batched Minor findings", goes to "one builder, then one
  re-review", and that the lead "rules on what remains". A small change's
  one review is the whole-change review (§5, §9), so this is the path every
  small change takes. It disagrees with R6.S1 (fix round 1 carries the
  Important finding only; the Minor ones are listed in the final report),
  with the cap of 2 (R13.S1 needs a round 2 at small), and its ruling has
  no `Ruling: T<n> open findings` form (T1.TS1). Everything else the 13
  requirements ask for is present.
- extra: the `plan skimmed by <handle>` event (ruled to stay, 17:54Z); the
  spec template's Open calls size line; the self-review rule that an item
  that does not apply is checked with its reason; the line for a terse
  plan's test-writing brief (`none in the plan; the spec is the source`);
  the skill's pointer to the lead's skim line. Each serves a requirement
  (R8.S1, R2.S1, R4.S1, R5.S1, R8.S1), and none reaches outside the scope.
- misread: none. The §9 table, the terse plan, the fix-loop forms, the
  model passages, the names and the version follow plan section 2 word for
  word.
- size: no sign that the change outgrows its size.

Rules the done-when leaves to review:
- C1 to C8: re-run at the head (clean checkout at 61d67db, tracked files
  only): all 8 print `C<n> pass` and exit 0. Re-run against the base file
  contents read from git at 3b22a1b: all 8 fail with the messages the
  report gives. This matches the report.
- `unit: none-present`: swe-pod tracks no unit suite. Holds.
- Q2 text search at the head: one match, PROCESS.md:1029, the legacy-names
  note Q2 allows. Holds.
- T1.TS1, the cap ruling form: PROCESS.md:584-586 and
  agents/swe-lead.md:393-395 give `Ruling: T<n> open findings`, which
  skills/swe-pod/SKILL.md:152-155 and status-format.md:217-225 read as
  closing the task's Critical and Important findings. §13 (PROCESS.md:1324)
  points to §5 and gives no other form. No place gives a different form,
  but PROCESS.md:882-883, agents/swe-lead.md:427-428 and SPEC.md:490-491
  tell the lead to rule "on what remains" after the whole-change fix wave
  with no form, and at small that is the cap ruling. A ruling there in the
  general form leaves the findings open and the change never reads as
  verified. The ledger template lists only the general Ruling form. Partly
  holds; see the findings.
- T1.TS2, legacy names: PROCESS.md:1028-1029 gives the legacy reading to
  archived specs only, agents/swe-lead.md:529-533 reads the size from the
  spec header as written, and SPEC.md:539-542 says the same. Nothing gives
  an open spec a legacy reading. This agrees with the 17:54Z ruling that
  drops T1.TS2. Holds.
- `plan skimmed by <handle>`: the same form in templates/records/ledger.md:20,
  agents/swe-lead.md:121, 125 and 633, and PROCESS.md:487-488. PROCESS §12
  says the template lists every event form, and it does. The skill reads
  the line only for its time, as the ruling says. Holds.
- Q1 (one rule, one wording): fail; see Quality.

## Quality
- structure: PROCESS.md was edited first, and its wording was carried into
  the other files nearly verbatim:
  - the size table: PROCESS §9 and SPEC §5.7 match plan 2.1;
  - the review sets: §4 item 7, §5, swe-plan, swe-lead, the plan template,
    README and the SPEC note;
  - blind tests: §2, §4, §6, swe-plan, swe-test, swe-lead's test brief, the
    plan template and README;
  - models: §5, §10, swe-lead, INSTALL, README, SPEC, and the six role
    files at `model: opus`;
  - the go and the skim gate: §2, §4, §14, swe-lead, the skill, README,
    INSTALL and pod.yaml;
  - the size rules: §3, §9, swe-spec, swe-lead, swe-build, swe-plan,
    swe-review and swe-test.
  Two lines were left unwrapped, PROCESS.md:334 and 1026.
- error handling: the fixed lines are exact and the same everywhere: the
  unchanged `Not dispatched: the spec at changes/<id>/spec.md awaits
  approval.`, and the new `Not dispatched: the plan at
  changes/<id>/plan.md awaits the operator's skim.` (PROCESS.md:490,
  agents/swe-lead.md:100 and 129).
- tests: swe-pod has no unit suite, so the builder's tests are C1 to C8.
  Each checks phrases or table cells in named sections. It shows that the
  rule's words are where the plan put them, not that the files agree, and
  an exact-phrase check fails on a rewording. For a docs-only repo, that is
  what a done-when check can do, and the plan accepts it.
  Under swe-pod-process@2, which this change runs under, each scenario of a
  requirement not at risk is exercised by the check the test map gives it:
  - C1: R1.S1 and R11.S1;
  - C2: R1.S2 and R2.S1 to R2.S3;
  - C3: R3.S1 to R3.S3;
  - C4: R4.S3;
  - C5: R5.S1 to R5.S3;
  - C6: R6.S1, R6.S2, R7.S1, R7.S2 and R8.S2;
  - C7: R8.S1 and R9.S2;
  - C8: R9.S1 and R11.S2.
  The gap: C6 reads only §5 and §9, so it never read the §7 passage that
  governs R6.S1 for a small change. The two Important findings are what it
  missed.
- test suggestions: T1.TS1, as above: the fix-loop text and the skill agree
  on the form, and the whole-change fix wave does not give it. T1.TS2 is
  dropped by ruling, and the wording agrees with the ruling.
- Q1: fail. Each rule this change alters reads the same in every file,
  except:
  - the fix loop at small: Important, at PROCESS.md:879 and
    agents/swe-lead.md:424; Minor, at SPEC.md:490 and
    agents/swe-build.md:174;
  - smaller disagreements, all Minor and listed below: "cost tables" against
    "expensive-runs tables"; four agents "at every size" against the spike;
    the §7 builder's-test check without the size qualifier §5 now has;
    SPEC.md's stage table; SPEC.md's Independence; the test-brief template;
    swe-plan's Reads; reopening approval for a size amendment.

## Findings
- Important swe-pod/PROCESS.md:879 The whole-change fix wave "also takes the batched Minor findings", goes to "one builder, then one re-review", and "the lead rules on what remains" with no form. For a small change, whose one review is the whole-change review, this contradicts §5 and §9 (a round carries only Critical and Important findings; cap 2), R6.S1 (fix round 1 carries the Important finding only) and R13.S1 (a round 2 at small), and its ruling lacks `Ruling: T<n> open findings`, so the status view never closes the findings (T1.TS1). State how a one-wave plan's whole-change review runs: the §5 fix loop with the size's cap, Minors parked and listed, and the cap ruling form. C6 does not read §7.
- Important swe-pod/agents/swe-lead.md:424 The same disagreement in the lead's "Whole-change review" paragraph (lines 424-430: batched Minors, one fix wave, "you rule on what remains" with no form), which the lead follows for every small change.
- Minor swe-pod/SPEC.md:490 "Its findings go to one builder in one fix wave, then one re-review; the lead rules on what remains" carries the same disagreement for small changes into the product spec.
- Minor swe-pod/agents/swe-build.md:174 "Minor findings wait for the whole-change fix wave, which takes them with its Critical or Important ones" disagrees with R6.S1 at small, where that review's round carries the Important finding only.
- Minor swe-pod/templates/records/ledger.md:39 The template lists only the general `Ruling: <what>; <why>; <cost if wrong>`, while the skill closes findings only on `Ruling: T<n> open findings` (§5, swe-lead) and reads the event forms from this template; list the cap form too.
- Minor swe-pod/agents/swe-lead.md:540 "Approval reopens for the amendment only" for a size amendment names no record, no held tasks and no re-approval event (the skill holds tasks only on `approval reopened for <Rn>; held ...`), and does not say whether the operator's word naming the size is that approval; PROCESS.md:1024, PROCESS.md:1346 and agents/swe-spec.md say the same.
- Minor swe-pod/PROCESS.md:1030 "Every size keeps ... four different fresh agents", and §10's "At every size" (PROCESS.md:1052, README.md:33), contradict the spike row and the bullet below it (one build agent, no review); say "every size of the gauge", or name small, medium and large.
- Minor swe-pod/PROCESS.md:877 The whole-change review checks "that each builder's test exercises its scenario (§5)" with no size qualifier, while §5, swe-review and swe-build now make that check for medium and large changes only.
- Minor swe-pod/PROCESS.md:1010 The large row says "the risk and cost tables" (also SPEC.md:528), while §4:280 and swe-plan say "the risk and expensive-runs tables": one table under two names.
- Minor swe-pod/PROCESS.md:369 The terse plan's section 6 names only the blind-test task and verify, and leaves unstated the suggestions task (§6) and the replacements task a spec with `supersedes` gets (§4 item 6) at small; the same holds in agents/swe-plan.md and templates/records/plan.md.
- Minor swe-pod/templates/records/test-brief.md:25 The Global constraints placeholder still says "the plan's global constraints, verbatim", while PROCESS §6 and swe-lead now say a terse plan's brief gives `none in the plan; the spec is the source`.
- Minor swe-pod/agents/swe-plan.md:26 Reads "nothing of the conversation that produced it", but the spec author may now write a small or medium plan "by this definition"; only the Never item (line 50) was limited to a large change's fresh planner.
- Minor swe-pod/SPEC.md:157 The stage table's build row still says "review per task" and "its review", against the reviews by size.
- Minor swe-pod/SPEC.md:558 Independence says a fresh context "started from a brief", where PROCESS §10:1057 says "from a brief or the operator's request".
- Minor swe-pod/PROCESS.md:334 A line was left unwrapped at about 96 chars (also line 1026, at 81 chars).
- Minor swe-pod-space/changes/add-size-gauge/plan.md:289 R4 is marked at risk, but R4.S3 is mapped to T1's done-when check C4, while T2's done-when says one test per scenario of R4; plan coherence, not T1's diff.
- Minor swe-pod-space/tests/build-swe-pod/fixtures/demo-space/changes/add-greeting/spec.md:3 Kept test fixtures still carry `size: project` on open changes (about 15 overlay plans and specs) and `fix round 1/5` lines (test_R24_S2, test_T7_TS1 and 3 overlay ledgers). The builder flagged them, and only test_T1_TS3 has a ruling; integrate should check them before claiming that no kept test is known to fail.
