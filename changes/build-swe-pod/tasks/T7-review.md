---
task: T7
diff: swe-pod 74d23f1..32db546
verdict: fix
---

## Spec compliance

Scope: one commit, 32db546 (parent 74d23f1). I found it with `git log -E --grep='^Task: T7$' origin/change/build-swe-pod`. It has trailers `Change: build-swe-pod` and `Task: T7` and touches exactly the two files in `touches:`: skills/swe-pod/SKILL.md (268 lines) and skills/swe-pod/status-format.md (216 lines), 484 lines added in all. It serves R12, R18 and R20 through D4. I read it against the brief (plan T7, sections 2.4 to 2.6, 3 and 4.1), spec sections 5, 11 and 13, R12, R18 and R20, PROCESS.md sections 2, 4, 5, 7, 8 and 15, agents/swe-lead.md, and the T2 templates T7 consumes (templates/records/ledger.md, evidence.md, plan.md).

Done-when, one by one:
- (1) Holds. The description says when to invoke the skill: where things stand or the status, go or the next thing, regenerating STATUS.md, a traceability check. It sets no standing rule.
- (2) Holds. All five exact section 2.6 lines are whole lines of status-format.md (lines 14, 16, 18, 19, 21). The heading uses three spaces on each side, which I checked byte by byte. `Critical <n>, Important <n>, Minor <n>` is on line 32.
- (3) Holds. The TRACE line and the five BREAK forms are exact, on SKILL.md:251-256.
- (4) Holds as reported: two runs, identical sha256, not filed. In the space, STATUS.md has not changed since the seed commit. I could not rebuild byte for byte, because the swe-pod head has moved since the runs, to 32db546. Instead I checked the output against the ledger and plan at space 03d8c12 by the skill's rules, and it agrees:
  - 40 rows: waiting 15, ready 1, dispatched 10, done 14, blocked 0. There is no T20 or T40 at that commit.
  - As of 2026-10-28T00:31Z, the gates and the pins all match.
  - Minor 35 = 7 + 6 + 1 + 10 + 5 + 6.
  - The latest cells of T0, T6, T15, T21 and T39 match, with T39 as `next:`.
- (5) Standard close:
  - The shareability check, re-run, prints `shareability: 0 hits`.
  - `git diff 74d23f1 32db546 -- SPEC.md spec-process.*` is 0 lines; 74d23f1 is the latest `Task: T0` commit.
  - The commit is by pathspec with both trailers. `git ls-remote` shows the remote `change/build-swe-pod` at 32db546.
  - This review has open Important findings, so the close does not hold yet.

Steps:
- Read order (SKILL.md:28-30): holds, with space.yaml, evidence, handoffs and decisions added.
- State from the spec section 5 table (SKILL.md:47-58): holds. The predicates are the spec's, taken "first that holds" in a safe order. Verified also needs the whole-change review to be done, a sound reading of section 5.5. Verified covers every scenario and every declared quality check (R12.S1 example at lines 157-159). It is misread for the regression suite and for project-level tests outside the scenarios (Important, SKILL.md:149).
- Next task (SKILL.md:202-205, status-format.md:131-136): holds for build, test and lead tasks. Treating a review task as dispatched once its task reports matches agents/swe-lead.md:216-220, so I accept the builder's reading. Review tasks written in the plan template's heading form are not covered (Important, SKILL.md:90). "Do the next thing" means acting as swe-lead (SKILL.md:192-193): holds.
- STATUS.md follows section 2.6: holds. The bullets come in order: gates, branches, task table, latest evidence, open findings, `next:`. Extra: a `- tasks:` count bullet above the table. It is harmless and deterministic, so it is not a finding.
- Trace (SKILL.md:221-260): holds. It runs from `serves:` and the test map, through the trailers on `change/<id>` read-only, to the latest evidence. I ran the trailer `--format` on the branch and it prints the Change and Task values as intended.
- Writes only STATUS.md, through the librarian (SKILL.md:174-188, 262-268): holds. The no-ledger-line rule conflicts with the lead's definition (Minor).

Missing:
- A link from the template-form review task (`### T<n> Review of T<m>`) to the task it reviews.
- A ruling that closes findings before round 5.
- Results for every regression and project-level test in the verified rule.

Misread: none beyond the regression gap above.

Builder's concerns:
- The multi-task dispatch rule is a sound general rule. The `T<n> complete` and handle-less go rules are shims (Minor).
- R24 is rightly left to T37.
- Branch heads read from the remotes are inherent in spec section 11.
- Summing Minor counts over rounds is right here: fix-mode reviews list only new findings. For example, T6-review-r1 lists two new Minors.

## Quality

Structure:
- The skill is clear and well ordered. SKILL.md holds reading, where things stand, regenerate, go and trace. status-format.md holds layout, field rules, task states, latest, findings and determinism.
- Every list has a fixed order and every empty case a fixed text. Header fields are read from the spec header only, and fenced examples are skipped. That fix came from a real failure in the first run pair and is correct for this space's spec, which quotes an example spec with its own `approved:` line.
- The status-format example agrees with its own rules: counts, As of, `next:` and the dispatched review task.
- The weak points are rules written to this space's shape rather than to the templates: the review table, and the legacy ledger wording.

Error handling: a missing remote branch gives `<repo> missing`, there are rules for no evidence and no records, and code repos are read-only. Two gaps:
- The fetch is fragile in a clone whose refspec does not cover the branch (Minor).
- Section 2 trusts the committed STATUS.md on As of alone (Minor).

Tests: swe-pod has no unit suite, as plan section 9 says.
- The done-when 1 to 3 checks are wording checks, which fits wording-level done-whens. Red and green output are both shown.
- I re-ran I4's embedded check, read-only, on the build checkout at 32db546: I4.1 to I4.6 pass, exit 0.
- Behavior is checked only by the one regeneration pair. The "for the reviewer" parts are each covered by that pair on this space's records:
  - TS1: same-minute ordering, exercised by the 2026-10-27T23:52Z block. The rule is at status-format.md:143 and SKILL.md:97-98.
  - TS2: header-only and fence rules (SKILL.md:60-71), exercised by the spec's fenced example.
  - TS3: multi-task dispatch and `T0 complete` (SKILL.md:103-108).
- No check covers a plan in the template's form, a ruling-closed finding, or evidence with missing regression or inspection results. Those are the Important findings below.

## Findings

- Important swe-pod/skills/swe-pod/SKILL.md:90 A review task is linked to the task it reviews only through a review table's Reviews column. swe-pod's own plan template writes review tasks as `### T<n> Review of T<m>` with `after: [T<m>]` (templates/records/plan.md:83-88), and no rule covers that form. Read as written, such a task never gets an event or a dispatched state (status-format.md items 1 and 3, and "Latest" at line 141). It turns ready once T<m> is done, and is named in `next:` for a review already filed. Two agents may also read it differently (R18.S1, R20.S1). Fix: take the reviewed task from the heading's `Review of T<m>`, or from the review task's single `after:` entry, as well as from a table.
- Important swe-pod/skills/swe-pod/status-format.md:166 Only a `Ruling:` line after a task's fifth fix round closes its open findings. PROCESS.md section 7 and agents/swe-lead.md:292-296 have the lead rule on what remains of the whole-change review after one fix wave and one re-review, and swe-lead.md:75 parks any finding with a ruling. So a whole-change review whose leftover Important finding is ruled on stays open: that review is never done, the change never reads verified, the integrate task never becomes ready, and open findings stay above 0, while the lead goes on to integrate. Fix: let a ruling on a named task's open findings close them at any round, in a form the lead's ledger lines can carry.
- Important swe-pod/skills/swe-pod/SKILL.md:149 The green rule counts evidence as green when results are missing. It asks for at least one regression result when `tests/` holds tests (line 150), and it checks `x-checks:` and `x-suggestions:` only when the record has them (line 155). R12 and PROCESS.md section 7 say a change is not verified while any project-level test, regression test, unit suite or declared check lacks a passing result. A record with 1 of 10 regression results, or with no `x-checks:` while `changes/<id>/tests/` holds test_I1 to test_I8, reads as green, and the change as verified. The trace's step 4 would flag the missing results; the state does not. Fix: require a pass for every test file in `changes/<id>/tests/`, using the step 4 mapping, and for every test in `tests/`, whose qualified id each archived change's test map gives.
- Minor swe-pod/skills/swe-pod/SKILL.md:108 The rule that an event saying `T<n> complete` in words is a DONE line, and the handle-less `go <UTC>` gate (status-format.md:71), are shims for this one space's ledger, which predates the event forms. They are extra in the shipped skill. The first matches anywhere in any event, so a line such as `Ruling: ... until T5 complete` would mark T5 done. Restrict it to legacy lines, or have the lead record a ruling or a corrective status line in place of the rule.
- Minor swe-pod/skills/swe-pod/status-format.md:123 Rule 1 (done) comes before any held check, so a held task can show done, and its successors can show ready. agents/swe-lead.md:322-323 says to mark no held task done.
- Minor swe-pod/skills/swe-pod/SKILL.md:185 Filing STATUS.md adds no ledger line, but agents/swe-lead.md:231-232 has the lead record `filed <space path>` for each FILED line. A lead following its own definition moves As of with each STATUS.md filing, so a rebuild never matches the committed copy (R20.S1). Route the exception to the lead's definition (T5's file, after it T37).
- Minor swe-pod/skills/swe-pod/SKILL.md:164 Where things stand uses the committed STATUS.md whenever its As of equals the newest UTC in the records. As of does not move when a branch head moves or when a record without a UTC changes, so the answer can carry stale branches or a stale verified state.
- Minor swe-pod/skills/swe-pod/status-format.md:99 `next: the go, by the human` for a planned change is wrong at small size, where approving the spec is the go (PROCESS.md section 4, agents/swe-lead.md:102-103). `next: the plan, by the plan role` (line 98) is wrong for a spike, which has no plan (PROCESS.md section 9).
- Minor swe-pod/skills/swe-pod/SKILL.md:234 `git fetch origin change/<id>` creates no `origin/change/<id>` in a clone whose fetch refspec does not cover it, such as a single-branch clone, so the log on line 235 fails. Fetch with `+refs/heads/change/<id>:refs/remotes/origin/change/<id>`, or log FETCH_HEAD. This is the same gap the T6 re-review raised for swe-build.

