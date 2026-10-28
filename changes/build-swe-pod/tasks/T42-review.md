---
task: T42
diff: agent-mesh e0f6af0..1367f65
verdict: pass
---

Range: agent-mesh e0f6af0..1367f65. One commit has the trailer `Task: T42`: 1367f65, "Accept shard evidence ids in space-librarian id check". Its parent is e0f6af0, and it has the trailers `Change: build-swe-pod` and `Task: T42`. Its subject is one line of plain ASCII. It touches one file, `skills/space-librarian/SKILL.md`, which is the task's only touch: 9 lines added and 7 removed. `git show --check` is clean, the file has no non-ASCII bytes, and every changed line is at most 76 characters. `ls-remote` shows `change/build-swe-pod` at 1367f65.

## Spec compliance

- missing: none.
  - Prose (agent-mesh/skills/space-librarian/SKILL.md:101-103): the evidence form reads `ev-<UTC>`, or `ev-<UTC>-<shard id>` for a shard, such as `ev-<UTC>-T19a`, under `changes/<id>/evidence/`. This is what the step asks for.
  - Script (SKILL.md:291-292): the evidence alternative is exactly `ev-[0-9]{8}T[0-9]{4}Z(-T[0-9]+[a-z])?`, as the step gives it. Line 305 matches it anchored, as `^(<form>)$`.
- extra: three small additions, all acceptable.
  - The parenthetical "(a task id and one lowercase letter)" at line 102 makes the prose state the shard id form that the script enforces (plan §2.5, `T<n>a`).
  - The semicolon at line 103 keeps the decisions and handoffs form apart from the longer evidence clause.
  - The evidence case is split over two lines (291-292), the same way as the decisions and handoffs case at 293-294.

  None of these changes behavior beyond the step.
- misread: none. The shard id form matches plan §2.5, and the evidence id matches §2.4.
- Done-when, re-run by the reviewer. I extracted the section 1 script from SKILL.md at 1367f65 (lines 125 to 310) and ran it under sh. Every result was the same under dash and ksh. Each throwaway space was a `git init` repo with a `space.yaml` and no remote, in a scratch directory outside every repo. All records were built at run time. Each full T42 run took about 17 s of wall time per shell, and each T10 run about 8 s.
  1. Holds. `changes/demo/evidence/20261028T0100Z.md` (`id: ev-20261028T0100Z`) and `changes/demo/evidence/20261028T0100Z-T19a.md` (`id: ev-20261028T0100Z-T19a`, `shard: T19a`) were both in the space, and one run printed `CHECKED` for both. With the script at e0f6af0, the shard record is `REFUSED ...: id line 2` (red).
  2. Holds. Each record below was added on its own, with both good records present, and each printed `REFUSED <space path>: id line 2`:
     - `ev-20261028T0100Z-T19`;
     - `ev-20261028T0100Z-19a`;
     - `ev-20261028T0100Z-T19a-x`;
     - `ev-20261028T0100-T19a`;
     - a second evidence record, `20261028T0105Z-T19b.md`, holding `ev-20261028T0100Z-T19a`;
     - `notes/20261028T0200Z-T19a.md`, holding `ev-20261028T0200Z-T19a`.

     Controls show that each refusal has the right cause:
     - `ev-20261028T0200Z-T19a` under `evidence/` is `CHECKED`;
     - the second holder is `CHECKED` once the first record is gone.

     Extra probes:
     - `CHECKED`: `-T123b`, `-T0a`, and a shard id in an archived change's `evidence/`;
     - `REFUSED ...: id line 2`: `-T19A`, `-T19ab`, `-Ta` and `-t19a`, and the shard form under `decisions/` and under `changes/demo/tasks/`.
  3. Holds. I copied the space without `.git` outside every repo, and the bus registry came from the node.
     - The five records (`spec.md`, `plan.md`, `ledger.md` and the two notes) are `CHECKED`.
     - The five records built at run time are refused, each line naming only the check and the line:
       - local `$HOME`: profile line 10;
       - a registered agent's `cwd` root, not under a home root: profile line 10;
       - a registry agent id: profile line 10;
       - a citation of a space not in `may_reference`: reference line 10;
       - a duplicate of the 0a31 id: id line 2.
     - Only result lines were printed, and no probe value appears in the output.
     - With an empty registry, the cwd-root and agent-id records are `CHECKED` (2 of 2).
  4. Holds. `git show -U0` has two hunks:
     - `-101,6 +101,7`, inside the id bullet (SKILL.md:96-107);
     - `-290 +291,2`, the `changes/*/evidence/*)` case.

     `--word-diff` shows only three changes: the inserted shard clause, a comma after `ev-<UTC>`, and the semicolon. The rest of the bullet is rewrapped, with no word changed.
  5. Holds; checked by reading.
     - The prose and the script give the same form:
       - `<UTC>` is `[0-9]{8}T[0-9]{4}Z`;
       - "a task id" is `T[0-9]+`;
       - "one lowercase letter" is `[a-z]`;
       - the shard suffix is optional and joined by `-`;
       - the place, `changes/<id>/evidence/`, is the case `changes/*/evidence/*`.
     - Nothing else changed. The diff has no other hunk, so these parts are byte-identical to e0f6af0:
       - the base form (line 289);
       - the decisions and handoffs case (293-294);
       - the already-present and one-file-per-event rules (296-304);
       - the profile and reference checks;
       - section 2.
  6. Holds.
     - The shareability check prints `shareability: 0 hits`, exit 0.
     - In swe-pod, `git diff 74d23f1 -- SPEC.md spec-process.*` is 0 lines, and 74d23f1 is the latest `Task: T0` commit.
     - 1367f65 holds only the task's touch, has both trailers and is pushed.
     - This review has no open Critical or Important finding.
- Builder's concern: the id check does not tie a shard id to its file name or its `shard:` key. I rule this out of T42's scope, with no finding against T42.
  - The §2.7 id check is form, collision-free, and not already present.
  - §2.4 and R24 put the tie in the evidence format. The lead checks `shard:` and `tests:` when a shard reports (swe-pod/agents/swe-lead.md:240-242), and it finds shard records by file name.
  - T42's steps say nothing else changes.
  - The one effect of the missing tie that I found is the prefix case under T42.TS1 below (Minor).

## Quality

- structure: The change is one alternation added to the existing case, in the style of the case next to it. The prose stays in its one bullet.
- error handling: Unchanged. A malformed id is still refused at its `id:` line.
- tests: agent-mesh has no unit suite (none present). The builder's harness was in scratch and is deleted, but its red and green output is in the report. It ran the script on real records and checked the result lines, which is real behavior, not wording. My re-run agrees with its red and green results.

  One flaw in that harness: its `T19A` probe names `20261028T0100Z-T19A.md`. On a case-insensitive filesystem, that is the same file as the T19a record, so the probe overwrites and then removes the shard record. I hit the same aliasing myself. In the report's order, that probe runs after the required checks, and the probes after it do not depend on the shard record.
- test suggestions:
  - T42.TS1, for the reviewer:
    - The form match is anchored on the whole id. Confirmed at SKILL.md:305 (`^($form)$`, with the alternation inside the group), and `-T19a-x` and `-T19ab` are refused.
    - The `holders` lookup (207-211) matches `id:` lines exactly (line 210), but file names by prefix (line 208).
    - Yes, an evidence file name can make a shorter id read as already held. Example:
      - Put `changes/demo/evidence/ev-20261028T0300Z-T19a.md` in the space, with `id: ev-20261028T0300Z-T19a`. It is itself `CHECKED`, because nothing ties its file name to its id.
      - A new `changes/demo/evidence/20261028T0300Z.md` with `id: ev-20261028T0300Z` is then `REFUSED ...: id line 2`. It is `CHECKED` once that file is gone.
      - The same prefix lets a `related: [ev-20261028T0300Z]` citation resolve when no record holds that id.
    - A conforming space never hits this. The deliverables name evidence files `<UTC>.md`, `<UTC>-<shard id>.md` and `<UTC>-<task id>-report.md`, and none of these starts with `ev-`.
    - Line 208 predates T42. But T42 makes one valid evidence id (`ev-<UTC>`) a prefix of another (`ev-<UTC>-T19a`), so the `ev-`-prefixed file now passes the id check itself.
    - The builder's harness does not cover the prefix case.
  - T42.TS2, for the reviewer:
    - Only the evidence case widens the form. The diff leaves the base form (289) and the decisions and handoffs case (293-294) unchanged.
    - A `decisions/` record and a `handoffs/` record with file-name ids are `CHECKED` at both commits, and a base-form `note-` id under `evidence/` is `CHECKED`.
    - The prose at 100-104 states the same rule.
    - The builder's harness covers the evidence-side probes but not decisions or handoffs. My probes cover those.

## Findings
- Minor agent-mesh/skills/space-librarian/SKILL.md:208 `holders` matches file names by prefix. An evidence file named `ev-<UTC>-<shard id>.md` passes the id check, because the check ties no id to its file name. That file then makes the unsharded id `ev-<UTC>` read as already present, so a new record holding it is refused as `id`, and a citation of `ev-<UTC>` resolves to it. No deliverable names evidence files with an `ev-` prefix, so a conforming space is unaffected.
