---
task: T1
diff: swe-pod 101cebb..ab800ec
verdict: fix
---

## Spec compliance

Diff reviewed: commit `ab800ec`, the only commit with trailer `Task: T1` on `change/build-swe-pod`. It adds only `PROCESS.md` (844 lines), so it touches only the task's `touches`. The commit carries the trailers `Change: build-swe-pod` and `Task: T1`. It is an ancestor of the remote branch head `1237519`. The commit subject is one line of plain ASCII.

Done-when checks, run by the reviewer:
- (1) PASS. `sed -n 1p` prints `# SWE Pod process` and `sed -n 3p` prints `process: swe-pod-process@1`.
- (2) PASS. `grep '^## ' PROCESS.md` prints exactly the 15 headings of plan §2.2, in order, and no other level-2 line. The `## ` lines inside the task.request example are indented under a list item.
- (3) PASS. `## 1 Shape of a project` (L18-89) holds the `pod.yaml` example, identical to spec §4, and every branch rule:
  - create the branch at the go, from the pin (L73-78);
  - record the base in the ledger go line (L75-76);
  - no branch for a repo the spec does not name; verify uses its pin (L79);
  - no other branch pushed (L80-82);
  - amendments stay on the same branch (L83-84);
  - rebase when `main` moves (L85-87);
  - delete after the merge (L88-89).
- (4) Review confirms all seven tables are present. Their rows match spec §§5 to 7, apart from section renumbering, the extended "Go" row and "Ana" changed to `<handle>`:
  - stages, L95;
  - states, L115;
  - suggestion routing, L441;
  - failure routing, L506;
  - sizes, L558;
  - roles, L576;
  - placement, L595.

  The lives-in table (L28) and the talking table (L817) are also kept.
- (5) Standard close:
  - The shareability check reports `shareability: 0 hits` (exit 0).
  - `git diff 854e87c -- SPEC.md spec-process.*` is 0 bytes, both at the working tree and at `ab800ec`.
  - The commit was made by pathspec and pushed.
  - Review: this record.

Rules the steps leave to review:
- Spec §4 and §§5 to 11 are rewritten as instructions addressed to the agent. I compared them rule by rule and found no rule dropped.
- All ten record kinds are cited once each as `templates/records/<kind>.md`: spec, plan, brief, test-brief, report, review, evidence, ledger, handoff and final-report.
- §11 states the three required rules:
  - the M4 interim rule, verbatim (L691-693);
  - a mesh executor reads the role definition its task.request names before anything else (L668-669);
  - build tasks run local until the executor git exception lands (L670-675).
- §10 single seat files records through agent-mesh's `space-librarian` (L610-612).
- Machines appear only as environment classes, and actors only as `<handle>` or `<handle>/<role>`. There is no real name, path or host.
- The plan §2.5 fixed phrases appear exactly for the lead (L109), the planner (L236) and a disputed test (L335).
- The plan §2.4 ledger event forms appear exactly where the rules that produce them are.

Missing: none.

Extra, all consistent with the spec or the interface contract, and accepted:
- the fixed phrases, ledger forms and evidence values from plan §§2.4-2.5;
- the local and mesh dispatch details and the task.request Context lines from plan §2.3;
- the lanes refusal rule, which serves R8.S1;
- "Never force-push", from G1;
- the "Arriving cold" paragraph, which serves R18.S1;
- `T<n>-brief.md` and `Task: T<n>` naming, per plan §2.5.

The changes to the spec examples (the plan-task example and the ledger example now show `runs: local` and `(local, any)` for build) are consistent with the build-local rule and accepted. The dropped (OS)/(SP) markers, diagram and requirement-id citations are accepted: the diagram is not in a space, and the ids mean nothing outside this spec. The one extra that is a problem is the wording "its review included" in the Ordering rule (Important finding below).

Misread: none. The builder's reading of single seat (concern 1) is correct.

## Quality

Structure follows plan §2.2. Each rule names the role it binds. Fenced examples are correctly nested under list items.

All 25 internal `§<n>` cross-references resolve to the right section. The external citations `memory-spaces §6.3` (the librarian) and `memory-spaces §3.4` (identifiers) resolve in agent-mesh `spec/memory-spaces.md` on the change branch (T11's commit `e70dfc2`), so the builder's forward-reference concern 7 does not arise.

Formatting: no trailing whitespace; the only non-ASCII character is §; ledger continuation lines are indented 18 spaces.

The builder's test suggestions, checked against the text:
- T1.TS2 is covered: L526-531 rerun verify when `tests/` moved.
- T1.TS4 is covered: L701 keys heaviness on the expected time over 60 s, not on a label.
- T1.TS5 is adequate: a bounded value the code computed is still "an expected value the code computed".
- T1.TS1 and T1.TS3 are minor wording issues, listed below.

Note for the lead, outside this diff: `agents/swe-lead.md` L120-122 (T5) states the same ready-task rule without the review-task exception, so T25 should check it as well.

## Findings

- Important swe-pod/PROCESS.md:687 The Ordering rule says to dispatch a task "once every task in its `after` list is done, its review included", and the M4 interim rule at L691-693 repeats it with no exception. A review task's `after` list names the build task it reviews (plan form `after: [T<k>]`), and that build task's review is the review task itself. Read literally, no per-task review can ever be dispatched, so every build stalls. Plan §7 L1053-1054 handles this with a definition ("In a review task, `after: [T<k>]` means T<k> has reported and its commit exists; T<k> is done only when the review closes"), but PROCESS.md leaves it out while adding the wording that needs it. Fix: add that definition to §11 Ordering (or to §4 item 7, Review tasks), or drop "its review included".
- Minor swe-pod/PROCESS.md:106 The R1 gate and the states table (L117-118) key on "`approved:`" without saying it must be the spec header line `- approved: <handle> <YYYY-MM-DDTHH:MMZ>` (L156). A body that quotes `approved:`, for example under Open calls, could be read as approval (the builder's T1.TS1). The wording matches spec R1, so this is not a misread; naming the header line would make it tighter.
- Minor swe-pod/PROCESS.md:606 The single-seat paragraph first says the session "is spec author, planner, lead", and only the next sentence says that at project size it plans through a fresh subagent. The reading is correct, because independence requires spec and plan to be different agents at project size (the builder's concern 1 and T1.TS3). Writing "planner (at small size)" in the first sentence would remove the momentary contradiction.

