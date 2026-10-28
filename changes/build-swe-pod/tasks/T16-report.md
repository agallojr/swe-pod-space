# T16 report

## Status

DONE_WITH_CONCERNS

## What I did

- Wrote 17 scenario tests, R1.S1 to R11.S1, one per row of the test map that
  T16 writes. Each has the front-matter, sections and mode the README and the
  test map give, a `python setup` block that builds its world, and a
  `python check` block that prints one line per numbered Then check. Each
  check names the behavior change that fails it under `## Fails if`, and
  takes its expected values from the spec, the contract, or a hand-checked
  fixture.
- Fixtures: 13 overlays under `fixtures/overlays/<test name>/` (records of
  the demo change `add-greeting` in the states each scenario needs: plan,
  ledgers, briefs, reports, reviews, evidence and demo project-level tests,
  plus a second change, `add-farewell`, for R5.S2). The setups write the
  code repos alpha and beta at run time under `{RUN}/repos/`. Most are plain
  folders. Where a build, test or verify agent needs commits, they are git
  repos the setup commits itself, and it writes their sha7s into the records
  and the pins. Negative content (agent ids, hostnames, home paths) is read
  from the bus fixture copy or built from split literals at run time.
- Before writing the files into the space, I ran every setup and check in a
  scratch folder against simulated agent outcomes. 18 good outcomes pass.
  17 empty outcomes and 22 targeted bad outcomes (a dispatch on an
  unapproved spec, an unordered shared file, `git add -A`, a diff in the
  brief, a pasted log, and so on) fail with the expected check, and no
  script crashes. I confirmed the hand-checked values by running the demo
  tests on the repos the setups build: R1.S1 pass, R1.S2 pass, R2.S1 fail
  (banner first), both unit suites and Q1 pass for R11.S1; the flawed R2.S1
  test passes at base for R10.S1; a 40-character name is greeted for R8.S2.
- Ran all 17 at the base commit set with the runner, without `--config` or
  `--gate`, so no agent could start. Each failed on the runner's
  precondition, and no run dir holds a prompt or stream file.

## Files

- changes/build-swe-pod/tests/test_R1_S1_go_without_approval.md
- changes/build-swe-pod/tests/test_R1_S2_edit_after_approval.md
- changes/build-swe-pod/tests/test_R2_S1_first_change_no_specs.md
- changes/build-swe-pod/tests/test_R2_S2_supersedes_and_test_update.md
- changes/build-swe-pod/tests/test_R3_S1_requirement_without_scenario.md
- changes/build-swe-pod/tests/test_R4_S1_no_process_files_in_code_repo.md
- changes/build-swe-pod/tests/test_R5_S1_tests_in_change_folder.md
- changes/build-swe-pod/tests/test_R5_S2_tests_promoted_at_integrate.md
- changes/build-swe-pod/tests/test_R6_S1_complete_test_map.md
- changes/build-swe-pod/tests/test_R6_S2_shared_files_ordered.md
- changes/build-swe-pod/tests/test_R7_S1_mesh_dispatch.md
- changes/build-swe-pod/tests/test_R7_S2_local_dispatch.md
- changes/build-swe-pod/tests/test_R8_S1_test_result_in_lane.md
- changes/build-swe-pod/tests/test_R8_S2_builder_disputes_test.md
- changes/build-swe-pod/tests/test_R9_S1_test_brief_contents.md
- changes/build-swe-pod/tests/test_R10_S1_test_passes_at_base.md
- changes/build-swe-pod/tests/test_R11_S1_evidence_fields.md
- changes/build-swe-pod/tests/fixtures/overlays/ (88 files), one folder per
  test above except R2.S1, R3.S1, R6.S1 and R6.S2, whose setups edit the
  demo space in place
- changes/build-swe-pod/tasks/T16-report.md

## Test output

Base commit set space c814837, swe-pod 8fc5294, agent-mesh 8ee5364, run
2026-10-28T00:40Z, 7 s wall time in all. For `T16 at base:`, one per test:

```
test_R1_S1_go_without_approval fail (deliverable absent: swe-pod 8fc5294 agents)
test_R1_S2_edit_after_approval fail (deliverable absent: swe-pod 8fc5294 agents)
test_R2_S1_first_change_no_specs fail (deliverable absent: swe-pod 8fc5294 agents)
test_R2_S2_supersedes_and_test_update fail (deliverable absent: swe-pod 8fc5294 agents)
test_R3_S1_requirement_without_scenario fail (deliverable absent: swe-pod 8fc5294 agents)
test_R4_S1_no_process_files_in_code_repo fail (deliverable absent: swe-pod 8fc5294 agents)
test_R5_S1_tests_in_change_folder fail (deliverable absent: swe-pod 8fc5294 agents)
test_R5_S2_tests_promoted_at_integrate fail (deliverable absent: swe-pod 8fc5294 agents)
test_R6_S1_complete_test_map fail (deliverable absent: swe-pod 8fc5294 agents)
test_R6_S2_shared_files_ordered fail (deliverable absent: swe-pod 8fc5294 agents)
test_R7_S1_mesh_dispatch fail (deliverable absent: swe-pod 8fc5294 agents)
test_R7_S2_local_dispatch fail (deliverable absent: swe-pod 8fc5294 agents)
test_R8_S1_test_result_in_lane fail (deliverable absent: swe-pod 8fc5294 agents)
test_R8_S2_builder_disputes_test fail (deliverable absent: swe-pod 8fc5294 agents)
test_R9_S1_test_brief_contents fail (deliverable absent: swe-pod 8fc5294 agents)
test_R10_S1_test_passes_at_base fail (deliverable absent: swe-pod 8fc5294 agents)
test_R11_S1_evidence_fields fail (deliverable absent: swe-pod 8fc5294 agents)
```

Every other deliverable a test lists is absent at base too (`PROCESS.md`,
`templates/records`, `skills/swe-pod`, `skills/space-librarian`), except
`agent-mesh:skills/mesh-post` for R7.S1. No test passed at base. Not run
past the precondition: all 17, because each is heavy (below).

## Concerns

1. **R4.S1's mode string.** The test map gives `desk (build, lead)`. In the
   runner's grammar that is one step, run as `swe-build`, which cannot
   exercise the lead's merge. I wrote `desk (build, then lead)`, two steps,
   so both halves of `<base>..<merge>` are covered. The lead may rule on the
   wording.
2. **All 17 are heavy.** Expected times are estimates, not measurements:
   120 s to 600 s each, 7080 s (about 118 min) in all. The caps total
   19500 s (about 5 h 25 min). Running them needs the operator's go and
   `--allow-heavy`, under the budget policy.
3. **Code-repo checkouts sit outside the working directories.** The runner
   adds only the export and the bus with `--add-dir`, so `{RUN}/repos/` is
   outside them. The tests rely on the bare `Read`, `Edit`, `Write` and
   `Bash` allow rules covering such paths. The permissions docs say a bare
   `Read` matches all reads, but they also say `cd` into another directory
   followed by `git` prompts, and dontAsk denies a prompt. The smoke test
   does not cover this. Runner change request for T15: add `<run>/repos` as
   an `--add-dir` when it exists after setup, and a smoke case that reads,
   writes and runs `cd <dir> && git log` there. The README's "Fixtures have
   no .git" still holds: the stored fixtures have none. The setups make git
   repos only at run time, inside the run dir, and the runner's four
   `rev-parse` checks still fail where it makes them.
4. **What the checks read.** Ledger lines and the dispatch Context are
   checked loosely against the contract's record forms (§2.3, §2.4), for
   example `dispatch T3 -> test (mesh, linux-server)` or a `refused` line.
   No §2.5 fixed phrase is checked word for word.
5. **Scenario shortcuts, each named in its Given:**
   - R2.S1 and R2.S2: the runner has no hook between steps, so step 1's
     human words both draft and approve the spec. A spec author that
     refuses to record a sight-unseen approval fails for a reason outside
     R2.
   - R5.S2 and R9.S1: the lead is told to write a brief and not dispatch
     it, so that no test agent starts.
   - R4.S1 (desk): the fixture ledger already records T2 as done and the
     change as verified, while step 1 has the builder do T2.
   - R7.S1: posting to `role:swe.test` counts as reaching the linux-server
     class only because the demo bus has no other holder of that role.
6. **R6.S2's GIVEN depends on the planner.** If it puts R1 and R3 in one
   build task, no two tasks share a file, and the check fails with "GIVEN
   not reached". The lead judges whether that run is a real failure.
7. **The lead-test `deliverables:` front-matter lines are longer than 88
   characters**, because the runner reads that key as one line.
8. **Isolation note.** When I read the runner, a read hook added the
   space's `AGENTS.md` to my context. I did not follow its read order, and
   I did not read plan.md, ledger.md or any other excluded file.

## Test suggestions

None.
