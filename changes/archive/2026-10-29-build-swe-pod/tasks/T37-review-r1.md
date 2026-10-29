---
task: T37
diff: swe-pod 882cd09..1cecea0
verdict: fix
---

## Spec compliance

Scope: this is fix round 1 of T37. It is one commit, 1cecea0 (parent 882cd09), which I found with `git log -E --grep='^Task: T37$' origin/change/build-swe-pod`. It is the remote head of `change/build-swe-pod` and has the trailers `Change: build-swe-pod` and `Task: T37`. It touches 4 of T37's 8 touches: PROCESS.md, agents/swe-lead.md, agents/swe-test.md and skills/swe-pod/SKILL.md (106 lines added, 46 removed). I read it against:
- the three Important findings under fix from the first review;
- the lead's ruling for the first finding: the shards' space commit is the space commit that files the last of the shard briefs and dispatch lines, and the lead gives that commit to every shard at dispatch;
- R24 (R24.S1, R24.S2);
- the text around each change at 1cecea0.

The builder's "Fix round 1" section is a claim. Everything below comes from the diff.

Findings under fix:

- A, swe-pod/PROCESS.md:733 (one space commit for every shard brief): closed.
  - "One space commit" is gone from every shard rule. At 1cecea0 the phrase is left only in integrate (PROCESS.md:613, agents/swe-lead.md:420), which is not a shard rule (see below).
  - The lead files the ledger's dispatch lines first, then the briefs (PROCESS.md:752-755, agents/swe-lead.md:209-213). The librarian files records in the order given, one per commit (agent-mesh skills/space-librarian/SKILL.md:37-38, 330-335). So the commit that files the last brief is also the last of the shard briefs and dispatch lines. That is the ruling's commit, and the text names it the shards' space commit (PROCESS.md:756-759).
  - The lead starts no shard before that commit exists. It gives the commit to every shard at dispatch, on its own line in the prompt or in the mesh Context (PROCESS.md:759-761, agents/swe-lead.md:214-216). A verify shard checks out the space at that commit and records it as `space:` (agents/swe-test.md:132-137). So every shard record of one round names the same space commit.
  - The skill finds the same commit: the newest commit on `HEAD` that changed a shard's brief (SKILL.md:196-207). A later re-dispatch line changes no brief, so it does not move that commit. PROCESS.md §7 (557-560) and swe-lead (340-342) use the same definition.
  - So the shards filed before the last one no longer read out of date, and the never-verified loop the finding described is gone.
- B, swe-pod/skills/swe-pod/SKILL.md:205 (the tests condition was only in the skill): closed.
  - PROCESS.md §7 (560-565) and agents/swe-lead.md:345-349 now state all three conditions:
    - each repo's sha is the current one;
    - the space sha is the shards' space commit;
    - neither `changes/<id>/tests/` nor `tests/` has changed since that commit.
  - SKILL.md:208-214 gives the same three conditions and the same three reasons a record is out of date.
  - "Green together" now requires "is at the current commit set" in all three places (PROCESS.md:568, agents/swe-lead.md:350-351, SKILL.md:217-218). So the claim at SKILL.md:187-188 that the skill and the lead apply the same rule now holds.
  - A test edit filed after the briefs now puts the shards out of date for the lead, for the skill and in STATUS.md alike.
- C, swe-pod/PROCESS.md:573 (no re-run case after a test fix): closed.
  - The re-run rule now asks whether the commit set has moved since the shards' space commit, "through a branch head or the tests" (PROCESS.md:580-583, agents/swe-lead.md:359-363, SKILL.md:225-228). A test fix filed after the briefs is such a move. Every shard is then briefed again and runs at a new shards' space commit, which holds the fixed test.
  - Each new brief's `## Start from` names each branch head, and the newest space commit that changed `changes/<id>/tests/` or `tests/`, by sha (PROCESS.md:748-751, agents/swe-lead.md:202-204). After either kind of move one of those shas differs. So the brief's text changes, and the librarian makes a new commit instead of skipping a byte-identical file (agent-mesh skills/space-librarian/SKILL.md:318-329).
  - The skill's `go` re-runs an out-of-date shard "as 1.7 says" (SKILL.md:283-285), and 1.7 now writes new briefs after a tests move. So `go` and `next: re-run ...` (status-format.md:132-134) no longer loop.
  - A shard that failed, rather than went out of date, is now covered (PROCESS.md:584-590, agents/swe-lead.md:364-370, SKILL.md:229-234):
    - after a flaky or environmental failure, it runs again from its brief at the same shards' space commit;
    - after a failure on the code or on a test, it runs again once the fix lands, and the fix moves the commit set.
  - One case is left open: a move through a pin alone (Minor).

R24:
- R24.S1 still holds by the text. The shards run at one commit set, every result is a pass, the change is verified, and the ledger holds one dispatch line per shard (PROCESS.md:752-754).
- R24.S2 holds. Suppose a shard's record names another commit set while the commit set has not moved. That shard is dispatched again from its brief at the current commit set (PROCESS.md:584-587). The change stays unverified until then (577-578).

Not under fix: the space-librarian id check (Important, agent-mesh/skills/space-librarian/SKILL.md:290). It is unchanged on `change/build-swe-pod` and stays open. The ledger routes it outside T37, to an agent-mesh build task and its review, before T19a and T19b. The first review's five Minors are in the ledger, and this diff leaves their text as it was.

Builder's note on integrate: it holds.
- PROCESS.md §8 step 5 (613) says the update is made "in one space commit". agents/swe-lead.md:420 says "in one space commit through the librarian".
- The librarian never commits more than one record in a commit (agent-mesh skills/space-librarian/SKILL.md:12, 386). It files only a path that names a file (55-56, 270).
- So it can neither make the update in one commit nor file the removal half of the update's two moves.
- The text predates T37 (it came in with T1 and T5) and follows the change spec's own integrate step 5. It is outside T37's scope: Important, routed outside T37.
- R14.S1's "both pins advance in one space commit" is still met, because both pins are in `pod.yaml`, which is one record.

Done-when, re-run at 1cecea0:
- (1) Holds.
  - PROCESS.md §4, §7 and §11 contain `shard` 11, 25 and 11 times.
  - `shard:` and `tests:` appear 1 and 1 times in templates/records/evidence.md, and 4 and 2 times in skills/swe-pod/SKILL.md.
  - PROCESS.md has no `R24`.
  - At 882cd09 the counts were `11 18 8 1 1 4 2 0`. At 1cecea0 they are `11 25 11 1 1 4 2 0`, which matches the report.
  - PROCESS.md's 15 level-2 headings are unchanged.
- (3) Standard close, not yet held:
  - The shareability check, re-run, prints `shareability: 0 hits`.
  - `git diff 74d23f1 1cecea0 -- SPEC.md spec-process.d2 spec-process.svg spec-process.png` is empty (0 lines). 74d23f1 is the latest `Task: T0` commit.
  - The commit has both trailers and is pushed.
  - The close does not hold yet, because this review has open Important findings.

- missing: nothing the three findings asked for.
- extra: none outside the findings. The swe-test verify step 1 change is a needed part of A and is within T37's touches.
- misread: none. The fix applies the lead's ruling as written.

## Quality

- structure:
  - PROCESS.md §7, swe-lead "Sharded verify" and SKILL.md 1.7 state the current commit set, the out-of-date rule and the three re-run cases in matching words. Each points back to PROCESS.md §7.
  - The `## Start from` rule is the same in PROCESS.md §11 and in swe-lead "Shards" step 1.
  - The added lines have no trailing whitespace and are at most 76 characters.
  - Two wording gaps are Minor findings: SKILL.md:198-199, and the `## Start from` line form.
- error handling:
  - Each of these now has a path back to green: a shard with no record, a shard at another space commit, a tests change, a flaky failure, and a failure on the code or on a test.
  - The path that still fails is a move through a pin alone (Minor).
  - Outside T37, integrate's update and the librarian id check still fail (Important).
- tests:
  - swe-pod has no unit suite (none present).
  - Done-when (1) is a wording check, which fits a wording-level done-when. Its counts match my re-run.
  - The builder's 30 phrase checks were a scratch script, since removed, so I could not re-run them. They also check wording only.
  - Behavior is left to review and to T39's R24 tests at verify.
- test suggestions:
  - This diff does not change them.
  - T37.TS1's reviewer part now holds on firmer ground: every record is matched against the shards' space commit, and every shard is given that commit.
  - TS2 and TS3 are untouched.
  - No unit test covers any of them.

## Findings

- Important agent-mesh/skills/space-librarian/SKILL.md:290 Still open, and unchanged on `change/build-swe-pod`. The id check accepts only `ev-<YYYYMMDDTHHMMZ>` under `changes/<id>/evidence/` (prose at 101-103). So it refuses the id of every shard record, `ev-<YYYYMMDDTHHMMZ>-<shard id>` (swe-pod PROCESS.md:552, agents/swe-test.md:151), and no sharded verify can be green (R24.S1). It is outside T37's touches. By operator decision it is routed outside T37, to an agent-mesh build task and its review, before T19a and T19b.
- Important swe-pod/PROCESS.md:613 Integrate's update is made "in one space commit" (also agents/swe-lead.md:420, "in one space commit through the librarian"). The librarian never commits more than one record in a commit (agent-mesh skills/space-librarian/SKILL.md:12, 386), and it files only paths that name a file (55-56, 270). So the update cannot be one commit. The removal half of its two moves cannot be filed at all, and the old paths stay on the space's `main`: `changes/<id>/tests/` into `tests/`, and the change folder into `changes/archive/`. This confirms the builder's note. The text predates T37 (T1 and T5) and follows the change spec's own integrate step 5, so T37 cannot fix it. R14.S1 is still met, because both pins are in `pod.yaml`, which is one record. Routed outside T37, before the first integrate: a ruling or a plan task for the integrate rule in swe-pod, or a librarian change in agent-mesh.
- Minor swe-pod/PROCESS.md:580 The re-brief case covers a move "through a branch head or the tests" (also agents/swe-lead.md:359 and skills/swe-pod/SKILL.md:225). But the current commit set also includes the pin of each repo the spec does not name (PROCESS.md:557-558), and a shard brief's `## Start from` names no pin (748-751). If only such a pin moves, the rule takes the not-moved case. It dispatches again at the old shards' space commit, whose `pod.yaml` still holds the old pin, so the shard stays out of date. A re-brief would not help either, because its text would not change. This should be rare, since integrate's pin advance comes with a `tests/` change (613-615), which the tests case catches. Name a pin in the moved case and in `## Start from`.
- Minor swe-pod/PROCESS.md:748 A shard brief's `## Start from` now names the newest space commit that changed `changes/<id>/tests/` or `tests/` (also agents/swe-lead.md:202-204), but no line form is given for it. The verify brief's only space sha is `space:` in the commit set under test (templates/records/test-brief.md:32). swe-test's step 1 reads that sha as the space to check out, and only its shard sentence overrides that (agents/swe-test.md:132-137). A lead who writes the tests commit there gives the shard two space shas. Give the line its own form, such as `- tests changed at: <sha7>`, and say that a shard brief leaves out `space:`. The template is outside T37's touches, so that part goes to the ledger with the existing test-brief Minor.
- Minor swe-pod/skills/swe-pod/SKILL.md:198 "So it is also the last of the shard briefs and dispatch lines" holds only until a not-moved re-dispatch files a new dispatch line after that commit (SKILL.md:229-230, agents/swe-lead.md:364-365). The git command at 203-205 and "the same shards' space commit" settle which commit counts. But a reader who takes the ruling's words as the definition would move the space commit on every re-dispatch, and so put every other shard out of date. Limit the sentence to the first dispatch, or drop it.
