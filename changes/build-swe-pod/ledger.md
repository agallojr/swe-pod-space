# Ledger: build-swe-pod

```
2026-10-27T21:36Z spec approved by agallojr
2026-10-27T21:42Z filed spec.md from the operator's draft; librarian profile edits
                  outside Requirements: private record ids and a bus path
                  replaced by descriptions, an agent id by a placeholder, a
                  node name by its environment class
2026-10-27T21:42Z filed note-20261027T2142Z-0a31: memory-spaces design, restated because
                  the spec relies on it
2026-10-27T22:27Z plan.md filed by a fresh planner (37 tasks)
2026-10-27T22:27Z plan-review.md: adversarial review, 21 findings (2 Critical,
                  11 Important, 8 Minor); negotiation opened
2026-10-27T22:27Z operator decision (plan question 1): desk-mode evidence for the 9
                  scenarios that need real git or mesh dispatch; the
                  pilot runs those 9 live, and the final report says so
2026-10-27T22:31Z operator decision (plan question 2): for this change only, the
                  pod's agents make the commits and pushes within G1's
                  scope (change/build-swe-pod in both code repos,
                  T0 included; the space's main through the librarian);
                  never main of a code repo, no force push, merging
                  stays with the operator; G1 itself goes into the
                  overlay at integrate
2026-10-27T22:42Z operator decision (plan question 4): T9's executor git exception
                  is deferred; M1 stays registration-only. Recorded
                  in note-20261027T2242Z-0786, for the change that first puts
                  builders on remote nodes
2026-10-27T22:44Z operator decision (plan question 3): the mesh poller stays off on
                  the lead's node from the go to T36
2026-10-27T22:47Z operator go, conditional: build starts once the round-2 re-review
                  raises no Critical or Important finding; the plan skim
                  gate is satisfied by that condition
2026-10-27T22:56Z plan-review round 2: no Critical or Important finding open
                  (A1 to A26 closed or conceded; A27 to A31 Minor, fixed
                  in passing); the operator's conditional go is in
                  effect; plan.md revision 3 filed
2026-10-27T22:58Z go. T0 (lead, local): change/build-swe-pod created in swe-pod
                  from base 8fc5294 and in agent-mesh from base 8ee5364,
                  both pushed. T0 commit 854e87c lands SPEC.md b216f955,
                  spec-process.d2 df7674eb, spec-process.svg c52d2a3f,
                  spec-process.png 0dc607df, README.md ba428d39 (sha256
                  prefixes, each matching its source). done-when 1 to 4
                  pass: parent 8fc5294, exactly five files; sha256 match;
                  Requirements section of SPEC.md identical to spec.md
                  (305 lines); agent-mesh branch on its remote at
                  8ee5364. T0 complete
2026-10-27T23:04Z dispatch T1 -> build (local, any), base swe-pod 854e87c
2026-10-27T23:04Z dispatch T2 -> build (local, any), base swe-pod 854e87c
2026-10-27T23:04Z dispatch T3 -> build (local, any), base swe-pod 854e87c
2026-10-27T23:04Z dispatch T4 -> build (local, any), base swe-pod 854e87c
2026-10-27T23:04Z dispatch T5 -> build (local, any), base swe-pod 854e87c
2026-10-27T23:04Z dispatch T6 -> build (local, any), base swe-pod 854e87c
2026-10-27T23:04Z dispatch T9 -> build (local, any), base agent-mesh 8ee5364
2026-10-27T23:04Z dispatch T10 -> build (local, any), base agent-mesh 8ee5364
2026-10-27T23:04Z dispatch T11 -> build (local, any), base agent-mesh 8ee5364
2026-10-27T23:04Z filed changes/build-swe-pod/tasks/T1-brief.md to T6-brief.md,
                  T9-brief.md to T11-brief.md
2026-10-27T23:25Z operator signed in the isolated runner config for T15
2026-10-27T23:25Z dispatch T15 -> test (local, any); filed changes/build-swe-pod/tasks/T15-brief.md
2026-10-27T23:27Z operator decision: no pull requests for swe-pod; at T36 the
                  operator's merge word means merge change/build-swe-pod
                  into main and push
2026-10-27T23:27Z operator decision: no pull requests for agent-mesh either; at T36
                  each repo's change/build-swe-pod merges into its main
                  and is pushed, agent-mesh first
2026-10-27T23:52Z T6 DONE_WITH_CONCERNS, swe-pod ea98774..101cebb
2026-10-27T23:52Z T6 review: spec issues; 1 Important, 5 Minor
2026-10-27T23:52Z T6 fix round 1/5: 1 addressed, 0 open, 45572b0..d752594
2026-10-27T23:52Z T6 review r1: spec ok; 2 Minor
2026-10-27T23:52Z T4 DONE_WITH_CONCERNS, swe-pod 854e87c..ea98774
2026-10-27T23:52Z T4 review: spec ok; 6 Minor
2026-10-27T23:52Z T1 DONE_WITH_CONCERNS, swe-pod 101cebb..ab800ec
2026-10-27T23:52Z T1 review: spec issues; 1 Important swe-pod/PROCESS.md:687
2026-10-27T23:52Z T1 fix round 1/5: 1 addressed, 0 open, 1237519..45572b0
2026-10-27T23:52Z T1 review r1: spec ok; 1 Minor
2026-10-27T23:52Z T5 DONE_WITH_CONCERNS, swe-pod ab800ec..1237519
2026-10-27T23:52Z T5 review: spec issues; 1 Important, 9 Minor
2026-10-27T23:52Z T5 fix round 1/5: 1 addressed, 0 open, d752594..8770c1a
2026-10-27T23:52Z T5 review r1: spec ok; 1 Minor
2026-10-27T23:52Z T11 DONE, agent-mesh 8ee5364..e70dfc2
2026-10-27T23:52Z T11 review: spec ok; 5 Minor
2026-10-27T23:52Z T10 DONE, agent-mesh e70dfc2..92f1dcf
2026-10-27T23:52Z T10 review: spec issues; 1 Important, 5 Minor
2026-10-27T23:52Z T10 fix round 1/5: 1 addressed, 0 open, 92f1dcf..7430aeb
2026-10-27T23:52Z T10 review r1: spec ok; 1 Minor
2026-10-27T23:52Z T2 BLOCKED: the commit was refused by the session's permission
                  classifier; files staged, nothing committed
2026-10-27T23:52Z T3 BLOCKED: the commit was refused by the session's permission
                  classifier; files staged, nothing committed
2026-10-27T23:52Z T9 BLOCKED: the commit was refused by the session's permission
                  classifier; files staged, nothing committed
2026-10-27T23:52Z filed T1, T4, T5, T6, T10, T11 reports and reviews; T2, T3, T9 reports
2026-10-28T00:05Z T15 DONE_WITH_CONCERNS: runner, fixtures, I1 to I8; smoke tests pass
                  (no instruction file reaches the agent under test, subagent at
                  depth 1, 30 s cap, desk prints only, ls allowed, git -C commit
                  denied)
2026-10-28T00:05Z T15 at base: test_I1 fail (PROCESS.md absent), test_I2 fail (role
                  definitions absent), test_I3 fail (templates absent), test_I4 fail
                  (skill absent), test_I5 fail (templates absent), test_I6 fail
                  (--project unknown argument), test_I7 fail (no project: field),
                  test_I8 fail (space-librarian absent)
2026-10-28T00:05Z Ruling: the node's managed settings (gateway login, provider
                  environment) are accepted under test isolation; they add no
                  instruction file and loosen no fence; cost if wrong: a scenario
                  result reflects node policy, caught at T20 on another node
2026-10-28T00:05Z Ruling: the test agent may read the space's memory-spaces note for
                  the 11 manifest keys (I3); it is a relied-on spec input, not a
                  plan, brief, report, review or diff; cost if wrong: none to
                  blindness, the keys are not implementation
2026-10-28T00:05Z Ruling: T16 and T17 briefs state that no instruction file reaches
                  an agent under test, so a scenario needing AGENTS.md has the agent
                  read it with a tool (R18.S1); cost if wrong: one test rewrite
2026-10-28T00:05Z heavy noted: test_I8 expected 240 s, cap 600 s; it joins the
                  operator ask before T19
2026-10-28T00:05Z filed changes/build-swe-pod/tests/ (T15), tasks/T15-report.md
2026-10-28T00:05Z dispatch T16 -> test (local, any)
2026-10-28T00:05Z dispatch T17 -> test (local, any)
2026-10-28T00:05Z filed changes/build-swe-pod/tasks/T16-brief.md, T17-brief.md
```
