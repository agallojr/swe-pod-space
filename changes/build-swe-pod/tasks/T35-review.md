---
task: T35
diff: swe-pod 8fc5294..83eaef9
diff: agent-mesh 8ee5364..9de4f77
verdict: fix
---

Whole-change review of build-swe-pod, on the most capable model available.
Inputs: spec revision 3 with R24, plan revision 4.4, both branch diffs from
their bases, T19c's record (`ev-20261029T0211Z-T19c`), the round 4 records it
carries (`ev-20261028T0947Z-T19a`, `ev-20261028T0950Z-T19b`), R19.S1's round
6 pass as the 2026-10-29T01:55Z ruling records it, T19b's round 3 to 5
filings, every review record in `tasks/`, every report's test suggestions,
and the ledger to 2026-10-29T02:38Z. Read-only git and file reads only; no
test or agent was run. Per the 2026-10-29T02:38Z directive, every action
below is a proposal for the operator; none runs before the operator's word.

Proposed actions, in order:

1. The operator picks the integrate design for finding 1.
2. One builder wave on swe-pod and agent-mesh for findings 1 and 2, plus
   any Minors the operator takes up.
3. The lead writes the ledger lines for finding 3, and the rulings of
   findings 15 and 16; no run.
4. One re-review of the wave.
5. A targeted re-run on linux-server, after its own heavy ask. For
   findings 1 and 2 alone, the tests whose behavior those fixes touch are
   test_R14_S1, test_R5_S2, test_I8, test_R17_S2, test_T10_TS1,
   test_T10_TS6, test_T10_TS8, test_T12_TS1, test_T12_TS3 and test_I7,
   then test_R16_S1 last. Their filed `expected_s` sum to 3003 s and
   their caps to 8790 s; T19c took 23 % of its expected time. T35's
   done-when instead names every test whose `deliverables:` list a
   changed file, which for `agents/` and `PROCESS.md` is most of the
   suite. Choosing between the two is the operator's call, as under OD8.

## Spec compliance

- missing:
  - Integrate's update cannot be filed as the deliverables say: one space
    commit through a librarian that commits one record at a time and cannot
    record a move (finding 1). Parked for T35 and T36 at
    2026-10-28T03:09Z; still open at the heads.
  - "load <project>" can report a mounted space as `NOT MOUNTED` (finding
    2), the skill-argument hazard verify round 1 found in space-librarian.
  - In this change's records, 15 suggestions have no outcome line, which
    R21 requires and T36's final report needs (finding 3).
- extra: agent-mesh 9de4f77, the poller cost change, is outside spec §3
  ("Mesh core changes beyond those listed in §14" are out) and carries no
  `Task:` trailer (spec §5.3). The 2026-10-29T02:35Z ruling and the
  02:36Z operator decision fold it in as tested; accepted, with findings 14
  and 15. `skills/space-librarian/check.sh` is extra to T10's touches,
  accepted by the 2026-10-28T06:11Z ruling. Nothing else is extra.
- misread:
  - PROCESS.md §8 has the lead mark `integrated:`, which swe-lead gives to
    the spec author (finding 8).
  - swe-lead compares evidence shas with pins, which never match for a
    named repo (finding 7).
  - The skill's header rule counts a commented `- approved:` line in the
    spec template as a header line (finding 5).
  - "Every result is a pass" fails `none-present` and `none-declared`
    (finding 9).

### Completeness: requirement, deliverable, passing test

Carried results ran at swe-pod 4d5bfc7 and agent-mesh bbd19a2, round 4 at
space a2bbb6d. T19c ran at swe-pod 83eaef9, agent-mesh bbd19a2, space
082b1c3. Neither ran agent-mesh 9de4f77, carried as tested by the 02:36Z
decision. "a" is `ev-20261028T0947Z-T19a`, "b" is `ev-20261028T0950Z-T19b`,
"c" is `ev-20261029T0211Z-T19c`. "Desk" means OD1's desk evidence.

| Req | Deliverables (main) | Tests: result (record) |
|---|---|---|
| R1 | PROCESS.md §2, §3; swe-lead Go, Requirement edits | R1.S1, R1.S2 pass (b) |
| R2 | PROCESS.md §3, §4; swe-spec; swe-plan | R2.S1 pass (b), R2.S2 pass (a) |
| R3 | PROCESS.md §4; swe-plan fixed phrase | R3.S1 pass (a) |
| R4 | PROCESS.md §1; swe-build Never; space AGENTS.md | R4.S1 desk pass (b) |
| R5 | PROCESS.md §6, §8; swe-test; swe-lead step 5 | R5.S1 pass (a), R5.S2 desk pass (b) |
| R6 | PROCESS.md §4; swe-plan; plan template | R6.S1 pass (a), R6.S2 pass (b) |
| R7 | PROCESS.md §11; swe-lead dispatch; M1 roles; `--project`; mesh-load; poller b2 | R7.S1 desk pass (a) and live, rounds 3 to 5; R7.S2 pass (a); I6 pass (a) |
| R8 | PROCESS.md §10, §11 lanes; role Never lists; swe-lead lane table | R8.S1, R8.S2 pass (b) |
| R9 | test-brief template; swe-lead step 2; PROCESS.md §6 | R9.S1 pass (a) |
| R10 | PROCESS.md §6; swe-test step 8; swe-lead | R10.S1 pass (b) |
| R11 | PROCESS.md §7; evidence template; swe-test verify | R11.S1 pass (a) |
| R12 | PROCESS.md §7; skill 1.6 | R12.S1, R12.S2 pass (b) |
| R13 | PROCESS.md §11 Fences; swe-lead Heavy checks; INSTALL G3 | R13.S1 pass (c) |
| R14 | PROCESS.md §8; swe-lead integrate; final-report template | R14.S1 desk pass (a), R14.S2 pass (b) |
| R15 | PROCESS.md §8; swe-lead step 1 | R15.S1 desk pass (a) |
| R16 | templates; profile rules; space-librarian profile check | R16.S1 pass (c); I5 pass (b) |
| R17 | PROCESS.md §10 to §12; swe-lead filing; space-librarian; PROTOCOL §5.1; poller result files | R17.S1 desk pass (a) and live (below); R17.S2 pass (b); I8 pass (a) |
| R18 | space AGENTS.md; skill §2; handoff template; swe-lead handoff | R18.S1 pass (a), R18.S2 pass (b) |
| R19 | PROCESS.md §3, §14; swe-spec | R19.S1 fail in round 4 (a); pass in round 6 by the 01:55Z ruling, no record (finding 19) |
| R20 | skill §3; status-format.md | R20.S1 pass (a); I4 pass (a) |
| R21 | PROCESS.md §6; swe-build; swe-lead; report template | R21.S1, R21.S2 pass (b) |
| R22 | PROCESS.md §1, §12; space AGENTS.md | R22.S1 desk pass (a) |
| R23 | PROCESS.md §1; swe-lead Go; swe-build commit and push | R23.S1 desk pass (b), R23.S2 desk pass (c) |
| R24 | PROCESS.md §4, §7, §11; swe-plan; swe-lead; swe-test; skill 1.7; evidence template; librarian shard ids | R24.S1 pass (b), R24.S2 pass (a) |

Every requirement has a deliverable, and every one of the 90 test files has
a passing result in T19c's record or a carried round 4 record, except
test_R19_S1, whose pass stands on the 01:55Z ruling (OD8). I1 to I8 pass
(I1 in c, the rest in a or b). Unit suites are `none-present` and quality is
`none-declared` in every record, as the plan says. Live, R23 holds on both
remotes: each has only `main` and `change/build-swe-pod` from this change;
two older agent-mesh branches, from 2026-08, predate it.

### Correctness

- **Process and roles.** PROCESS.md has the 15 headings and the version
  line; T0's check (3) still holds at 83eaef9 (the Requirements section of
  `SPEC.md` matches `spec.md`, 324 lines), and `SPEC.md` and
  `spec-process.*` are unchanged since the latest `Task: T0` commit,
  74d23f1. The process says what the spec means, with the misreads above.
  The heavy rule (PROCESS.md §11 Fences, swe-lead Heavy checks, README)
  agrees in all three places after the 2026-10-28T11:26Z ruling. The
  gating, routing, fix-loop, sharded-verify and lane rules agree across
  PROCESS.md, the six role definitions and the skill, except as the
  findings say.
- **Skill.** The state, verified and trace rules are mechanical and
  testable. Their weak points are the ruling form (finding 4), the header
  rule (finding 5) and the regeneration loop (finding 6).
- **agent-mesh M1 to M5.** The scripts pass `bash -n` (scan loop,
  mesh-post) and `sh -n` (check.sh) at 9de4f77. `--project` is checked in
  the argument loop before the repo check and written after
  `timeout_min:`. The scan loop's list mode and its per-submodule update
  match plan §2.7. The poller loads a task's space, blocks an unmounted one,
  and publishes result files with the checks PROTOCOL §5.1 states.
  space-librarian follows plan §2.7, shard ids included (T42). The defects
  are findings 1, 2, 10 to 14, 16 to 18, 23 and 28 to 30.
- **9de4f77.** The idle deadline falls from 540 s to 240 s, under the
  5 min prompt-cache TTL. The last sleep is cut to the time left, so a
  call lasts about 240 s plus one pull and scan, with `POLL_SEC` at 300 s
  as in the identity template. PROTOCOL §8, agent-operating, the mesh-on
  skill, INSTALL and the template all state the new value. Executors get
  their own model, `MESH_EXECUTOR_MODEL`, defaulting to the session's. The
  quoted model prices (cache reads 0.20 USD per million tokens on both
  models) match today's list prices. The change fits the protocol. Its
  faults are operator content in a product file (finding 14) and
  bookkeeping (finding 15).

### Coherence with plan §2 and §3

- **OD1.** The seven desk scenarios and R17.S2's commit step are desk in
  their tests; the pilot owes them live. The final report's sentence is
  T36's.
- **OD2.** Every commit on both branches has `Change: build-swe-pod`, and
  every one but 9de4f77 has a `Task:` trailer. No `main` commit, no
  force-push, no other branch.
- **OD3** is node practice, outside the deliverables. The librarian's
  ancestor check is in the skill.
- **OD4.** PROCESS.md §10 and §11 and swe-lead keep build tasks local
  until the executor git exception lands.
- **OD5.** `SPEC.md` and `spec-process.*` landed by T0 and were re-copied
  once, at 74d23f1; no build task touched them.
- **OD6 and OD7.** Parallel by default and sharded verify are in PROCESS.md
  §4, §7 and §11, swe-plan, swe-lead, swe-test, the skill and the evidence
  template. Shard evidence ids are accepted by the librarian (T42).
- **OD8** applies to this change only, and the deliverables are unchanged
  by it, as it says. So the skill reads this change as not verified: T19c's
  `shard: T19c` makes T19a and T19b shards whose latest records are out of
  date. STATUS.md will show that until T36 archives the change. Accepted;
  the 02:33Z ruling holds the verified state.
- **PC1 (a)** and **PC2 (i)** show in the briefs and the `heavy:` lines.
  **PC3** (live R7.S1 and R17.S1 at the pilot) is T36's and the pilot's.
- **Plan §2.4 regression keys and `tests/<id>/`** (logged for T35,
  2026-10-28T06:43Z). PROCESS.md §7 and §8, swe-test, swe-lead, the skill
  and the evidence template agree on `<change>/I<n>`, `<change>/T<n>.TS<k>`
  and promotion into `tests/<id>/`. That meets spec §5.6 ("into `tests/`")
  and R5.S2. Accepted; the plan text lags, and T36's step needs the folder
  form (finding 20).

### R17.S1 live: T19b's filings in rounds 3 to 5

Checked against test_R17_S1's Then items. By OD6, T19b's returned files
(evidence record, run logs, report) stand in for the scenario's
"project-level tests"; the path is the same: result files, lead, librarian.

| Round | Record | Returned files equal to space copies (sha256) | Filing commits on `main` |
|---|---|---|---|
| 3 | `ev-20261028T0755Z-T19b` | 66 of 66, and all 66 match the result body's `files:` | e254431 (record), caea86c (64 logs), 4129295 (report) |
| 4 | `ev-20261028T0950Z-T19b` | 64 of 64, all match `files:` | eb18b6b (record), d9dcfc7 (report and 62 logs) |
| 5 | `ev-20261028T1137Z-T19b` | 85 of 85, all match `files:` | b225dac (record), e584a75 (report and 83 logs) |

1. Pass, each round: every returned file is in the space byte for byte,
   and its sha256 matches the result's `files:`. No file changed after its
   filing.
2. Pass in substance. Each filing commit holds only the returned files,
   by path, with nothing else, and each is an ancestor of `origin/main`.
   The add commands are not in the records. Each log folder went in one
   commit, and in rounds 4 and 5 the report went with it, which the
   librarian's one-record-per-commit rule does not provide for (finding
   17).
3. Pass. The ledger has a `T19b DONE_WITH_CONCERNS` line for each round
   (09:08Z, 10:55Z, 12:26Z) and a `filed` line naming the record and its
   report, with the logs as "its -runs/". The form is not the exact
   `filed <space path>[, ...]`.
4. Pass. No space file at HEAD holds a T19b task id, a registered agent id
   or name, a hostname or a direct-inbox name from the bus (18 values
   checked, 0 hits).

R17.S1 live is met by rounds 3 to 5, with finding 17.

### Items logged for T35

- **T39.TS1 to TS3, T42.TS1 and TS2** (00:54Z, 03:18Z): covered by the
  deliverable text (Test suggestions, below). No new test is needed. Each
  still needs an outcome line (finding 3).
- **T37's parked integrate finding** (03:09Z): still open; finding 1.
- **The librarian's record ids on test fixtures** (04:09Z, 07:49Z):
  finding 16.
- **The runner's startup retry for a gateway outage** (04:48Z): closed by
  T41 (06:51Z, one retry with no agent turn). Harness, not a deliverable.
  Accepted.
- **The run log naming the mesh-post default sender, and the runner's
  redaction gaps** (05:42Z, 11:07Z): closed by T41 (11:31Z, direct-inbox
  names redacted; T19c's smoke S8 passes). The redacted name is public
  product text and stays in the space's history, as the 11:07Z ruling
  says. Accepted.
- **Regression keys and `tests/<id>/`** (06:43Z): accepted under
  Coherence; finding 20.
- **The git gate failing open under an old Python** (07:23Z, for T35 and
  the operator): pre-existing, outside this change's diff and scope;
  finding 18, for the operator.

## Quality

- structure: Every deliverable has the §2 shape: the 15 PROCESS.md
  headings, the four role-definition headings with the §2.3 tools, the 10
  record templates, the 11 `space.yaml` keys, the exact STATUS.md and
  TRACE lines. Rules are stated once and cited elsewhere. Where they are
  restated (sharded verify in PROCESS.md, swe-lead and the skill; the heavy
  rule in three files), the copies agree, except findings 7 and 9.
- error handling: mesh-post exits 1 on a bad `--project`, before any
  write. The scan loop keeps going on a failed pull. The poller blocks a
  task on an unmounted or unreadable space and leaves a failing result
  file out, naming it. The librarian refuses without echoing the match,
  undoes a commit refused after a rebase, and stops on a conflict or a
  third rejected push. Gaps: lock contention with the scanner (finding
  10), fetch in a single-branch clone (finding 25), the gate's interpreter
  (finding 18).
- tests: Neither repo has a unit suite, so the 90 project-level tests
  carry everything: 37 scenario tests, 8 inspection checks and 45
  suggestion tests. Agent tests judge observed outputs (files, ledger
  lines, commands printed), not wording, and they fail at base for their
  stated reasons. Desk tests stand in for real git and mesh steps, and OD1
  sends those to the pilot. 81 results are carried from round 4 at swe-pod
  4d5bfc7, under OD8. Its cost if wrong is the plan's: a regression found
  later, by a full run.
- test suggestions: There are no unit tests, so I checked each "for the
  reviewer" part against the deliverable text at the heads. Of the 82
  suggestions (64 routed at 02:27Z, 3 of T37, 3 of T39, 2 of T42, and 10
  in the V1 to V3 reports), the deliverable handles the named fragility,
  with these exceptions:
  - T1.TS1: header-only approval (finding 5).
  - T1.TS5: computed values in other forms (finding 21).
  - T2.TS1: commented state lines (finding 5).
  - T3.TS3: verify half, a placeholder repo in `pod.yaml` (finding 22).
  - T10.TS3: visibility and `may_reference` (finding 23).
  - T10.TS9: the same argument hazard, in mesh-load (finding 2).
  Every routed test passes in its latest record (T1.TS4, T7.TS3, T8.TS3,
  T10.TS6, T13.TS1 and T13.TS2 in c; the rest in a or b). Proposed
  outcomes for the 15 with no outcome line (finding 3):
  - T39.TS1: declined, exercised by test_T37_TS2.
  - T39.TS2: declined, covered at PROCESS.md:605 and skill 1.7; low risk.
  - T39.TS3: declined, exercised by test_R24_S2.
  - T42.TS1 and T42.TS2: declined. The anchored form (check.sh:168, 181)
    was run on the malformed ids in T42's done-when.
  - T1.TS7: declined, exercised by test_T1_TS4.
  - T5.TS7: declined, exercised by test_R23_S2.
  - T5.TS8: declined, exercised by test_T7_TS3.
  - T5.TS9: declined, exercised by test_R13_S1 and test_T1_TS4.
  - T7.TS5 and T7.TS6: declined, exercised by test_R20_S1 and
    test_T7_TS1.
  - T7.TS7: declined, exercised by test_T7_TS4.
  - T7.TS8: declined, exercised by test_T7_TS3.
  - T10.TS9: routed to builder with finding 2.
  - T10.TS10: declined, the installer links the skill's directory.

### Deferred minors

The task reviews deferred 102 Minor lines, 97 distinct. At the heads:

- **Closed: 17.** Among them the T3 and T4 integrated and copy items, the
  T5 merge, citation and Never-list wording, the T7 and V1 regression keys
  and trace folder, T11's retire and forward references, and V3's heavy
  wording.
- **Raised again below: 17.** Findings 4 to 13 and 24 to 30 carry the
  deferred minors whose text an agent would follow wrongly.
- **Open and accepted as deferred: 63.** Cosmetic or rare, for the final
  report's `## Deferred minors`, each still as its source review states
  it:
  - weak rule gaps, accepted as low risk: swe-lead's `<id>` used for both
    the message and the change id, the review's "diff from base to head",
    the `decisions/` lane timing; swe-test's writing-mode read list;
    swe-build's commit range read before the rebase; swe-plan's
    always-fresh description; the skill's free-text DONE rule, done before
    held, committed STATUS.md trusted on a matching "As of", and `next:`
    at small size; the AGENTS.md template sending every arriving agent to
    the skill; INSTALL's placeholder replace and `ln -sfn` onto a real
    directory; check.sh's file-name prefix match; agent-operating step 4's
    missing branches; the `.gitignore` segment and the per-file link
    rule; PROCESS.md's verified-row wording;
  - swe-pod, PROCESS.md: the bare `approved:` key, the single-seat order,
    the interim-rule wording, the shards subsection placement, the
    unnamed-repo pin move.
  - swe-pod, templates: the ledger, report, review, brief and plan slots;
    the repeated `diff:` key; the test-brief shard lines; the plan's
    sharded form; the AGENTS.md exception and "four hex digits".
  - swe-pod, roles and docs: swe-spec reads and re-approval; swe-plan (c)
    wording; swe-lead's fixed `tools:` and Never wording; swe-build's
    index-lock wait; swe-test's public surface; the README and INSTALL
    wording items of T8.
  - agent-mesh: the T9 role wording; check.sh's fenced ids, `supersedes`
    and date-shaped body ids; the librarian's step 5, inbox prose and
    `allowed-tools`; the memory-spaces status rows; PROTOCOL's
    blocked-reason list and `project:` name clash; the orphan `-files/`
    archive month; the T14 README items; the manual's skill map.

## Findings

- Important swe-pod/PROCESS.md:653 Integrate's update is "in one space commit" (also agents/swe-lead.md:449, "in one space commit through the librarian"), but agent-mesh space-librarian commits one record per commit (skills/space-librarian/SKILL.md:200) and files only paths that name a file (SKILL.md:55-56). So it can neither make that one commit nor record the removal half of the two moves (`changes/<id>/tests/` into `tests/<id>/`, the change folder into `changes/archive/<date>-<id>/`). T37's review parked this for T35 and T36 at 2026-10-28T03:09Z, and T36 step 7 needs it. Proposed fix, a design pick for the operator: (a) add an integrate mode to space-librarian. It takes a list of renames plus edited records, runs the three checks on every new path (a moved record's id counts as not new), makes one commit with `git mv` and the edits, then runs the same fetch, rebase, push and ancestor check. Cite that mode in PROCESS.md §8 step 5 and swe-lead step 5. Or (b) state integrate as a short sequence of librarian commits, and give the librarian a move operation. Either way the librarian must learn to move files.
- Important agent-mesh/skills/mesh-load/SKILL.md:59 The mount test runs `awk '{print $2}'` in the skill's own text. When the skill is invoked with arguments, as "load <project>" is, the skill tool replaces `$2` with an argument. This is the mechanism that broke space-librarian's inline script in verify round 1 (tasks/V2-report.md). awk then prints the whole line, `grep -qxF` never matches, and a mounted space reads `NOT MOUNTED`. Fix: use `cut -d' ' -f2`, or ship the check as a script beside SKILL.md as check.sh is, and check every SKILL.md for `$<digit>`; the only other one is prose at skills/mesh-on/SKILL.md:131 (`$0.20`).
- Important space/changes/build-swe-pod/ledger.md:214 Fifteen suggestions have no outcome line, against R21 ("SHALL get a recorded outcome"), and T36's final report (R21.S2) needs them. T39.TS1 to TS3 and T42.TS1 and TS2 were "logged for T35" (ledger lines 214 and 404). T1.TS7, T5.TS7 to TS9, T7.TS5 to TS8, T10.TS9 and T10.TS10, from tasks/V1-report.md, V2-report.md and V3-report.md, were never routed. Fix, for the lead, with ledger lines only and no run: record a routing line and an outcome for each, as proposed under Quality, "test suggestions".
- Minor swe-pod/agents/swe-lead.md:324 The skill closes a task's open Critical or Important findings only on a ruling that begins `Ruling: T<n> open findings` (skills/swe-pod/status-format.md:203). But swe-lead (324, 345, 348), PROCESS.md §13 and templates/records/ledger.md:27 give only `Ruling: <what>; <why>; <cost if wrong>`. So a past-round-5 ruling, or the ruling after the whole-change re-review, in that form leaves STATUS.md showing open findings, and the change never reads verified. Name the form in swe-lead's fix-loop and whole-change paragraphs, and in the ledger template.
- Minor swe-pod/templates/records/spec.md:18 The template's comment has `- approved: <handle> <YYYY-MM-DDTHH:MMZ>` at column 0, before the first `##`. The skill's header rule (skills/swe-pod/SKILL.md:81) counts that as a header line, so a spec that keeps the comment reads as approved, which is the R1 gate. test_T2_TS1 passes, so agents compensate today. Indent the three state lines, and say at SKILL.md:81 that lines inside `<!-- -->` are not header lines. Add "in its header" at PROCESS.md:124 and agents/swe-plan.md:37 (T1.TS1).
- Minor swe-pod/agents/swe-lead.md:279 Step 6 records `filed <space path>` for every `FILED` line, and step 7 and line 469 file STATUS.md after each filing. So filing STATUS.md adds a ledger line, which moves its "As of" and calls for another regeneration. That goes against the skill's "Filing `STATUS.md` adds no ledger line" (skills/swe-pod/SKILL.md:307). Exempt STATUS.md in step 6.
- Minor swe-pod/agents/swe-lead.md:429 "Compare the latest evidence's `commit_set` ... with the current pins in `pod.yaml`": for a named repo the commit set holds the branch head, never the pin, so read literally, every pin has moved. Say instead: if `pod.yaml` or `tests/` changed after the evidence's space commit (`git diff --quiet <space sha> HEAD -- pod.yaml tests`).
- Minor swe-pod/PROCESS.md:655 §8 step 5 has the lead "mark `integrated:` on the spec", but agents/swe-lead.md:53-56 and 451-453 have the spec author add it at the lead's request. Make PROCESS.md say the same.
- Minor swe-pod/PROCESS.md:609 "Every result in every one of them is a pass" (also agents/swe-lead.md:372), read literally, fails a record with `unit: {<repo>: none-present}` or `quality: none-declared`, which every record of this change has. skills/swe-pod/SKILL.md:263 states it right: nothing is `fail` or `not-run`. Use that wording.
- Minor agent-mesh/skills/mesh-on/mesh-scan-loop.sh:97 Each cycle runs `submodule update --remote --merge` in every cloned space, the librarian's own checkout included, while space-librarian may have an unpushed commit or a rebase in progress there. The update can add a merge commit or collide on the index lock. Skip a space that has an operation in progress or commits not on `origin/main`, or skip the spaces whose librarian role this node holds.
- Minor agent-mesh/INSTALL.md:66 The `pullmesh` alias (also lines 51, 83 and 222) runs `submodule update --init --recursive`, which clones every mounted space on every node. That goes against M2's clone on first need, and it fails on a node without read access to a space. Limit it to the submodules not under `spaces/`, as the scanner does.
- Minor agent-mesh/docs/operator-manual.md:285 Retire says to "commit and push as for a mount", but that `git add -- ... spaces/proj-<name> ...` fails with a pathspec error after `git rm`. Give the retire commit its own add and commit lines.
- Minor agent-mesh/templates/agent-identity.env.template:19 The example `AGENT_ROLES=build,swe.build,swe.test.` ends in the sentence's period, so a copy registers the role `swe.test.`. Put the example on a line of its own.
- Minor agent-mesh/skills/mesh-on/poller-prompt.md:25 9de4f77 names a real node of the operator's mesh and its idle cost in a product file. The product carries no operator content (PROTOCOL §12, plan §3 repo rule). State the cost in general terms. The model prices at skills/mesh-on/SKILL.md:130-131 match today's list prices but will go stale; dropping them loses nothing.
- Minor space/changes/build-swe-pod/plan.md:1473 9de4f77 is on agent-mesh `change/build-swe-pod` with no `Task:` trailer, outside spec §3's scope, and is carried as tested by the 2026-10-29T02:36Z decision. As planned, T36 would still run T19c again (step 1: a branch head moved), and could not meet its done-when, "T19c's latest record is at the exact heads being merged" (line 1515). Before T36, record a Ruling that T19c's record at agent-mesh bbd19a2 stands for 9de4f77 under that decision. The final report lists 9de4f77 as an out-of-plan commit with no task.
- Minor agent-mesh/skills/space-librarian/check.sh:164 The id and reference checks apply to test fixtures. Record-shaped files under `changes/<id>/tests/fixtures/` were refused (2026-10-28T04:09Z; 07:49Z: 21 on id, 2 on reference) and filed past the refusals by ruling. T36's move of those files into `tests/` will meet the same refusals. Skip the id and reference checks, keeping the profile check, for paths under `changes/*/tests/fixtures/` and `tests/*/fixtures/`; PROCESS.md §7 already treats fixture data as no test. Or rule on it at T36.
- Minor agent-mesh/skills/space-librarian/SKILL.md:200 With one commit per record, there is no rule for filing a record's log folder. The lead filed each T19b `-runs/` folder (62 to 83 logs) in one commit, with the report in the same commit in rounds 4 and 5 (space commits caea86c, d9dcfc7 and e584a75), outside the skill's rules. Say how a folder of id-less logs beside its record is filed, for instance in one commit per folder after the profile check of each file.
- Minor agent-mesh/hooks/git-gate.py:1 Logged for T35 and the operator at 2026-10-28T07:23Z: the gate runs by its shebang, and under a Python older than 3.7 it exits on a syntax error. The CLI treats that exit as non-blocking, so git add, commit and push pass ungated, and PROCESS.md §11 Fences and INSTALL.md:134 rely on the gate. This is outside this change's diff and scope (spec §3). The operator should open a change that makes the hook fail closed (exit 2 when its interpreter is too old), and check the linux-server node's own gate now.
- Minor space/changes/build-swe-pod/ledger.md:885 R19.S1's round 6 pass, carried by OD8, has no record or log in the space, so the final report's evidence for it is a ruling. If the round 6 run log for test_R19_S1 survives, file it under `evidence/`.
- Minor space/changes/build-swe-pod/plan.md:1503 T36 step 7 moves the tests "into `tests/`", but PROCESS.md:654 and agents/swe-lead.md:450 put them in the folder `tests/<id>/` (the 06:43Z ruling). Move them to `tests/build-swe-pod/`.
- Minor swe-pod/PROCESS.md:471 No text says that a value the code computed counts in every form: an approximate value, a bound or a tolerance (T1.TS5's reviewer part; also agents/swe-lead.md:291 and agents/swe-build.md:55 and 89). Add "in any form".
- Minor swe-pod/agents/swe-lead.md:110 Nothing handles a `pod.yaml` repo whose remote or pin is still a placeholder, yet every evidence `commit_set` names each `pod.yaml` repo at its pin (PROCESS.md:529; T3.TS3, verify half). Have the lead refuse the go and name the entry.
- Minor agent-mesh/skills/space-librarian/check.sh:100 A citation of `core` or `lore` resolves whenever `may_reference` lists it, in a shared space too. But memory-spaces §3.2 and §6.3 say a shared space never cites core or personal lore, and that the librarian refuses such a citation (T10.TS3). Refuse them unless `space.yaml` has `visibility: private`, and say so at SKILL.md:90.
- Minor swe-pod/agents/swe-test.md:134 Verify mode says "check out the commit set" but not where. In the shared build checkout, or the librarian's space checkout, that moves HEAD under other agents. Say: in a scratch clone or a `git archive` export, outside every checkout another agent uses.
- Minor swe-pod/agents/swe-build.md:120 `git fetch origin change/<id>` updates `origin/change/<id>` only when the clone's refspec covers it. In a single-branch clone, the merge-base check then exits 128 (also skills/swe-pod/SKILL.md:363). Fetch with the explicit refspec `change/<id>:refs/remotes/origin/change/<id>`.
- Minor swe-pod/agents/swe-review.md:41 Bash is limited to `git log`, `git show` and `git diff`, so a reviewer cannot fetch and may read a stale `origin/change/<id>`. Allow `git fetch`, which changes no file under review.
- Minor swe-pod/agents/swe-spec.md:52 It says the lead "commits any `SPEC.md` copy", but swe-lead's Writes has no such duty, and this change's copies were committed under `Task: T0` by hand (plan §4.1). Add the duty to swe-lead's Writes, or give it to a build task.
- Minor agent-mesh/skills/mesh-on/poller-prompt.md:251 The link guard finds symbolic links only, so a hard link to a node file, such as the credentials file, passes as a regular file. Also refuse a staged file whose link count is over 1.
- Minor agent-mesh/spec/PROTOCOL.md:452 `files:` entries are unquoted flow mappings, and a path's characters are not restricted, so a path holding `, ` or `: ` breaks its entry (also skills/mesh-on/poller-prompt.md:277). Quote the path, or restrict paths to `[A-Za-z0-9._/-]`.
- Minor agent-mesh/skills/mesh-on/poller-prompt.md:412 The archiver duty sweeps an orphan status or `-files/` folder only when its task or result is "already archived". PROTOCOL §9 also sweeps one whose task or result is gone. Add "or gone".
