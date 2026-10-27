---
task: T5
diff: swe-pod d752594..8770c1a
verdict: pass
---

# T5 re-review, fix round 1/5: Lead role (D2)

This re-review covers only the fix commit made since the first review. The fix commit is 8770c1a, and its parent is d752594, another task's commit on the shared branch. It was found with `git log -E --grep='^Task: T5$' change/build-swe-pod`, which returns two commits: 8770c1a and 1237519. 1237519 was covered by the first review.

The fix commit changes one file, `agents/swe-lead.md`, with 10 insertions and 7 deletions in three hunks. That matches the task's touches. Other tasks' files (`templates/records/*`) are staged in the shared index, but the commit does not hold them, so it was made by pathspec.

## Done-when, re-run by the reviewer on the file at 8770c1a

- **(1) Front-matter and headings: pass.**
  - The front-matter keys are exactly name, description, tools and model.
  - `name: swe-lead` and `model: inherit` are set. The description is one sentence.
  - `tools` includes Agent plus Read, Grep, Glob, Bash, Write and Edit.
  - The level-2 headings are Reads, Writes, Never, Returns and Steps.
- **(2) Fixed phrase and ledger forms: pass.**
  - The fixed phrase is on its own line (:88).
  - All 16 section 2.4 event forms are exact whole lines.
- **(3) Lane table: pass.** The rows name spec, plan, lead, build, test and review (:204-209).
- **(4) Review: see below.**
- **(5) Standard close: pass.**
  - The shareability check (`share-check.py --task T5`) printed `shareability: 0 hits`, exit 0.
  - `git diff 854e87c -- SPEC.md spec-process.*` is 0 bytes.
  - Both T5 commits carry the trailers `Change: build-swe-pod` and `Task: T5`.
  - `origin/change/build-swe-pod` is at 8770c1a.
  - The remote heads are only `main` and `change/build-swe-pod`.
  - The working tree has no uncommitted change to `agents/swe-lead.md`.

## Spec compliance

The previously open finding was Important swe-pod/agents/swe-lead.md:53, which let the lead add `integrated:` and `abandoned:` to the spec (also :42 and :353). It is closed. All three places are fixed:

- **:41-43 (Writes).** "the spec's `integrated:` line" is gone from the integrate-only writes. The lead's writes now name no spec line.
- **:53-57 (Never).** The lead writes no spec and adds no line to one, `integrated:` and `abandoned:` included. The spec author records them when the lead asks, at integrate or on a confirmed abandon. The lead files `spec.md` in the spec role's lane.
- **:353-357 (Integrate step 5).** The lead files `spec.md` in the spec role's lane, in the same single space commit through the librarian, once the spec author has added `integrated: <handle> <UTC>` at the lead's request.

The fixed text agrees with the following:

- R8: "only the spec role SHALL edit a spec".
- Spec section 6.
- swe-spec.md:130-131: the spec author records both lines when the lead asks.
- The lane table. Its spec row is `changes/<id>/spec.md`, and its lead row (:206) never held spec.md.

A grep of the file finds no other grant of a spec line to the lead.

**Missing.** None. **Extra.** None: the fix touches only the three cited places. **Misread.** None.

## Quality

The new text is ASCII only, has no trailing whitespace, and keeps every line within 88 characters. The report's fix-round section is accurate:

- red output 7/11 and green output 11/11 for checks F1 to F4 plus the original checks;
- the right fix range, d752594..8770c1a;
- 398 lines after the fix.

The fix adds no abandon procedure to Steps, and none existed before the fix. The abandon path appears only in the Never bullet. That is acceptable, and the fix did not change it.

The nine Minor findings from the first review were not part of this fix. They stay as that review recorded them, for the lead to defer or rule on. Their line numbers past :57 have moved down by 2.

One cross-file inconsistency remains outside T5's touches (Minor below).

## Findings

- Minor swe-pod/PROCESS.md:547 This is outside T5's touches and is for the lead to route. PROCESS.md section 8 is addressed to the lead ("You are the lead", :526), and its Update step still says "mark `integrated:` on the spec". The text now disagrees with swe-pod/agents/swe-lead.md:353-357 and swe-pod/agents/swe-spec.md:130-131, where the spec author adds the line at the lead's request. It is the same R8 issue as T5's closed Important finding. The fix is to send it back to T1's builder ("ask the spec author to record `integrated:`"), or to record a Ruling that reads the passive "mark" as delegated.

