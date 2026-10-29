---
task: T37
diff: swe-pod 6f8ed78..882cd09
verdict: fix
---

## Spec compliance

Scope: one commit, 882cd09 (parent 6f8ed78). I found it with `git log -E --grep='^Task: T37$' origin/change/build-swe-pod`. It has trailers `Change: build-swe-pod` and `Task: T37`, touches exactly the eight files in `touches:` (324 lines added, 78 removed), and is the remote head of `change/build-swe-pod`. It serves R24 (R24.S1, R24.S2) and the Scaling bullet of spec section 7. I read it against the brief, plan sections 2.4 to 2.6, the T19a and T19b entries and the T38 row, and against PROCESS.md, swe-lead, swe-test, the skill and the record templates at the head. I also read the agent-mesh space-librarian skill on `change/build-swe-pod`, because the shard records are filed through it.

Done-when:
- (1) Holds. I re-ran it. At 882cd09, PROCESS.md §4, §7 and §11 contain `shard` 11, 18 and 8 times. `shard:` and `tests:` appear 1 and 1 times in templates/records/evidence.md, and 4 and 2 times in skills/swe-pod/SKILL.md. PROCESS.md has no `R24`. At 6f8ed78 every count is 0. This matches the report's `11 18 8 1 1 4 2 0`. No line the commit adds cites a requirement id or an operator decision.
- (2) Checked rule by rule, below.
- (3) Standard close:
  - The shareability check, re-run, prints `shareability: 0 hits`.
  - `git diff 74d23f1 882cd09 -- SPEC.md spec-process.d2 spec-process.svg spec-process.png` is empty. 74d23f1 is the latest `Task: T0` commit.
  - The commit was made by pathspec, has both trailers, and is pushed.
  - This review has open Important findings, so the close does not hold yet.

Steps, one by one:
- PROCESS.md §4: holds.
  - Tasks run in parallel by default, and `after` lists only needed output or a shared file (PROCESS.md:291-293).
  - A task may be sharded across a role's holders, local and remote together (294-296).
  - Shards are named as their own entries. The shared-fields heading form matches what SKILL.md 1.3 already parses (297-300).
  - The plan says how the work divides, for build and for test shards (301-305).
  - The subsection's placement is a Minor finding.
- PROCESS.md §7: holds, in plain words and with no bare requirement id (544-576). It covers the shard record, the current commit set, the three conditions, and out of date then re-run. The wording "every result ... is a pass" is a Minor finding. The re-run rule has a gap (Important).
- PROCESS.md §11: holds as written (730-740).
  - One brief per shard, listing in `## Task` the tests or files the shard covers.
  - Every brief and dispatch line in one space commit before any shard starts.
  - Test shards run local and mesh together; build shards run local until the executor's git exception lands. It does not cite the plan's operator decision, which is right for a process copied into every space.
  - One dispatch line per shard.
  - But "one space commit" cannot be made through the librarian (Important).
- swe-plan: holds. Step 5 (agents/swe-plan.md:100-113) plans parallel by default, names the shards and says how the work divides. The self-review checks both (129-131).
- swe-lead: holds.
  - "Shards" dispatch, with one dispatch line per shard (195-212).
  - A filing check on `shard:` and `tests:` (234-236).
  - "Sharded verify", with the verified rule (329-351).
  - The lane table puts a test task's report under `evidence/` (226).
  - The whole-change review, the start of integrate and merge step 1 also read shard records.
- swe-test: holds.
  - A shard runs only what its brief lists (137-139, and the Never at 75-76).
  - It writes `shard:` and `tests:` (147-150), and results only for what it ran (160-161).
  - It writes its report under `evidence/`, with `actor: <handle>/test` (55-59).
- Skill: holds, with one divergence.
  - The verified row (SKILL.md:55) and 1.7 (185-221) carry the plan §2.4 rule, plus an extra condition on test content (Important).
  - STATUS.md shows each shard's latest record (status-format.md:98-119).
  - The skill reads state for the lead. Section 2 names each stale or missing shard (233-236). `go` makes a stale shard the next task (270-272), with the matching `next: re-run ...` line (status-format.md:132-134).
- Evidence template: holds (templates/records/evidence.md:2-12). It has `shard:` and `tests:`, says to leave them out of an unsharded record, and gives the shard file name and id. It says "only what the shard ran" for scenarios, unit and quality.
- Report location: holds.
  - PROCESS.md §12 lists `<utc>-<shard id>.md` and `<utc>-<task id>-report.md` under `evidence/` (792), and says where each task's report goes (800-802).
  - The report template's path line says the same (templates/records/report.md:8-9).

T38's extra checks:
- The README's process summary still matches PROCESS.md §4 and §7.
  - README.md:24-27 covers parallel tasks.
  - README.md:32-38 covers verify in shards, which count only when the shards' evidence, at one commit set, together holds a pass for every scenario, unit suite and declared check.
  - "Build stays local for now" (147-148) agrees with build shards running local.
  - As a summary it leaves out the regression suite and the re-run rule, which is fine.
- These all put a test task's report at `changes/<id>/evidence/<YYYYMMDDTHHMMZ>-T<n>-report.md`, and they agree:
  - PROCESS.md §12 (792, 800-802) and §11 Lanes (748-751);
  - the report template (report.md:8-9);
  - swe-test (55-59);
  - swe-lead's lane table (226).
- The space's existing T15 to T17 reports were filed under `tasks/` before this rule. From now on a test task's report goes under `evidence/`.

Missing: nothing the steps ask for. Some plan-level gaps lie outside T37's touches:
- the librarian's id form (Important);
- the librarian's one commit per record (Important);
- the brief and plan templates (Minor).

Extra: all of it is within the touches and consistent with the steps.
- PROCESS.md: the verified row in §2, the test-task item in §4, the §11 Lanes bullet and §15.
- swe-lead: the shard filing check, and the wording at integrate.
- status-format: "As of" now reads "the UTC that begins the name", which gives the same UTC for unsharded names.
- The report template's actor line.

Misread: none against the text of plan §2.4. The design falls short in the out-of-date and re-run rules (see Findings).

Builder's concerns:
- SKILL.md 1.7 is stricter than plan §2.4. The extra condition is that tests are unchanged from the brief-filing commit to HEAD. It is sound, and allowed, because R24 and §2.4 state necessary conditions ("only when", "only if"). But PROCESS.md §7 and swe-lead do not carry it, while both say the skill applies their rule (Important).
- The two-case re-run rule. The reasoning is right: re-filing one shard's brief would put the other shards out of date. Both cases agree with R24.S2 and with the T19 entry's "a re-run at a new commit set re-runs both shards". But the rule keys on branch heads only, so no case works after a test fix (Important).
- The report template's actor line, `<handle>/<build|test>`: right. It is needed for the test-report step, and swe-test asks for `actor: <handle>/test`.
- brief.md, test-brief.md and plan.md say nothing about shards: correct. They are outside T37's touches, and no task has owned them since the R24 amendment. They go to the ledger (Minor). Until then, PROCESS.md §11 and the lead's definition carry the rules.
- New exact STATUS.md text: right. For a change with no shard record, STATUS.md is unchanged. The "As of" rule gives the same UTC for `<utc>.md` names, and the new first `next:` case needs a shard record.

## Quality

Structure:
- PROCESS.md §7 states the rule once, in plain words. swe-lead and the skill restate the same three conditions, and each points back to §7.
- Shard ids, file names, the id form and the two keys agree across PROCESS.md, swe-test, swe-lead, the evidence template and status-format.
- The skill finds the shards from the plan's lettered tasks and the records' `shard:` values. This fits its 1.3 parser and the plan's heading form.
- The sharded `latest evidence` bullet is deterministic. It keeps the combined counts, over every result verify needs, apart from each shard's own counts.
- Because the rule is restated in three places, the commit-set rule has already drifted between them (finding).

Error handling:
- A shard with no record shows `none` and keeps the change unverified.
- A stale shard is named in the answer, in STATUS.md and in the trace.
- The lead checks a shard record's `shard:` and `tests:` before filing.
- The paths that fail are the Important findings on commit sets and filing:
  - the librarian refuses shard records;
  - the shard briefs cannot all go in one commit;
  - no re-run case returns a shard to the current commit set after a test fix.

Tests: swe-pod has no unit suite (none present). Done-when (1) is a wording check, which fits a wording-level done-when. Its red and green output are in the report and match my re-run. Behavior is left to review, and to T39's R24 tests at verify.

Test suggestions:
- T37.TS1: sound. SKILL.md:196-209 and agents/swe-lead.md:334-336 match a record's space sha against the newest commit that changed a shard brief, not against HEAD. A record at another space commit is therefore out of date. It is re-run from its brief, and that converges.
  - No unit test covers this. At verify it is covered only by T39's R24.S2 test, if that test's fixture differs in the space commit alone, or by a test from T18.
  - When records are filed one per commit, this same exact match is what leaves the shard filed first out of date (Important, PROCESS.md:733).
- T37.TS2: sound. SKILL.md:210-216 requires the records together to hold a pass for every result 1.6 lists, and status-format.md:107-112 makes the top line `green` only then. The top line counts over all of verify's results, and each shard's line counts only its own. Nothing in swe-pod covers it. R24.S1 and R24.S2 do not exercise a coverage gap across shards, so it needs a test from the suggestions task.
- T37.TS3: sound. SKILL.md:156-160 tells evidence records apart by their `id: ev-` front matter. The report template has no front matter (report.md:1-5), so a test report under `evidence/` is never the latest evidence. Its leading UTC counts only toward "As of", which stays deterministic. Nothing in swe-pod covers it, so it needs a test from the suggestions task.

## Findings

- Important agent-mesh/skills/space-librarian/SKILL.md:290 The id check accepts only `ev-<YYYYMMDDTHHMMZ>` under `changes/<id>/evidence/` (also in the prose at lines 101-103). So it refuses as `id` every shard record, whose id is `ev-<YYYYMMDDTHHMMZ>-<shard id>` (plan §2.4; swe-pod templates/records/evidence.md:6, PROCESS.md:552, agents/swe-test.md:147). Reproduced: the form on that line rejects `ev-20261028T0100Z-T19a` and accepts `ev-20261028T0100Z`. A file that is not filed is not a record (swe-pod SKILL.md 1.1), so no sharded verify can be green, T19a and T19b included (R24.S1). No plan task updates the librarian for R24, and T37's touches cannot fix it. The lead routes it, as an agent-mesh task or a ruling, before T19a and T19b are dispatched.
- Important swe-pod/PROCESS.md:733 "File every shard's brief and dispatch line in one space commit" (also agents/swe-lead.md:206-209) cannot be done. The lead files only through the space's librarian, which commits each record alone (agent-mesh skills/space-librarian/SKILL.md:330-335). Each shard's brief then starts from "main at the commit that files the brief" (swe-lead.md:208-209), a different commit for each shard. SKILL.md:196-209 requires every shard record's space sha to equal the newest brief-filing commit, so every shard except the last one filed reads out of date. Re-dispatching it from its brief (PROCESS.md:573-574) records the same older commit again, so the change never reads verified. Fix within T37's files: make the shards' space commit the commit that files the last shard brief, give it to every shard at dispatch (in the prompt, or the mesh Context as at PROCESS.md:693), state that in the brief rule, and get a ruling on the plan's "one space commit". Or have the librarian file a set of records in one commit (agent-mesh).
- Important swe-pod/skills/swe-pod/SKILL.md:205 Here a shard record is at the current commit set only if, besides matching shas, `changes/<id>/tests` and `tests/` are unchanged from the brief-filing commit to HEAD (lines 205-209). PROCESS.md §7 (557-562, 571) and agents/swe-lead.md:334-339 and 346 define out of date by the commit set alone. Yet SKILL.md:187-188 and swe-lead.md:331-332 say the skill and the lead apply one rule. Suppose a test edit is filed after the briefs. The lead's rule then reads the shard records as current, and the change as verified if they pass. STATUS.md meanwhile shows every shard `stale`, with `next: re-run ...`. The extra condition is sound, and R24's "only when" allows it, so state it in PROCESS.md §7 and in swe-lead's "Sharded verify" as well.
- Important swe-pod/PROCESS.md:573 The re-run rule picks between re-dispatching from the old brief and re-briefing every shard by whether a branch head moved (the same rule is at agents/swe-lead.md:347-351 and skills/swe-pod/SKILL.md:217-221). It has no case for a change to `changes/<id>/tests/` or `tests/` after the briefs are filed. The §7 failure table causes exactly that whenever the test agent fixes a test (PROCESS.md:528). Re-dispatching from the old brief checks out the brief's space commit (agents/swe-test.md:132), so the fixed test never runs. Under SKILL.md 1.7, each shard stays out of date after every re-run, and `go` (SKILL.md:270-272) loops on `next: re-run ...` (status-format.md:132-134). Rewriting the briefs with unchanged heads can give byte-identical files, which the librarian skips, so no new brief-filing commit is made. Fix: re-brief every shard whenever the commit set moves, through a branch head or the tests, in a brief whose text changes (for instance, a `## Start from` that names the commit set under test). Also say how a shard that failed, rather than went out of date, is run again.
- Minor swe-pod/PROCESS.md:121 The verified row says "every shard's latest record is" green at the current commit set. That drops §7's condition that the records together cover every result, which matters because a shard record by design gives only part of them. Write "its shards' latest records are green together (§7)", as SKILL.md:55 does.
- Minor swe-pod/PROCESS.md:563 "Every result in every one of them is a pass" (also agents/swe-lead.md:340), read literally, fails a record with `unit: {<repo>: none-present}` or `quality: none-declared`. This change's own T19a and T19b records will carry both. SKILL.md:214 states it correctly: nothing is `fail` or `not-run`.
- Minor swe-pod/PROCESS.md:289 The new `### Parallel tasks and shards` subsection sits between the plan's ten-item section list and "Then come the plan's last two sections" (line 308). That sentence now reads as part of the subsection. Move the subsection after that paragraph.
- Minor swe-pod/templates/records/test-brief.md:48 This is outside T37's touches, and no task owns it. The verify brief's result lines give only the unsharded evidence name and no report line. Neither this template nor brief.md says that a shard's `## Task` lists the tests it runs (plan §2.4). PROCESS.md §11 and swe-lead carry these rules, so this goes to the ledger.
- Minor swe-pod/templates/records/plan.md:73 This is outside T37's touches. The plan template's verify entry has no sharded form (lettered shard entries under a shared-fields heading), although PROCESS.md §4 and swe-plan step 5 now describe one. It goes to the ledger.
