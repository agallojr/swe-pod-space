---
task: T4
diff: swe-pod 854e87c..ea98774
verdict: pass
---

# T4 review: spec and plan roles (D2)

Reviewed from the brief (changes/build-swe-pod/tasks/T4-brief.md), the report (changes/build-swe-pod/tasks/T4-report.md) and the task's own diff. The trailer search `Task: T4` on change/build-swe-pod finds one commit, ea98774, whose parent is 854e87c. The spec and plan supplied the rules.

## Spec compliance

Done-when, run by the reviewer:

- (1) The front-matter and headings are correct in both files.
  - In both, line 1 opens on `---`, and the keys are name, description, tools and model, in that order.
  - Each name is `swe-<role>`, each description is one sentence, and model is `inherit`.
  - The tools match plan §2.3 exactly. swe-spec has Read, Grep, Glob, Bash, Write, Edit. swe-plan has Read, Grep, Glob, Bash, Write, with no Edit.
  - The level-2 headings are `## Reads`, `## Writes`, `## Never`, `## Returns`, then the optional `## Steps`, in that order (swe-spec lines 16, 27, 35, 55 and 65; swe-plan lines 17, 29, 34, 49 and 60).
  - The description values contain no ": " or " #", so they read as plain YAML scalars.
- (2) `grep -cF 'No plan written: <Rn> has no scenario. Returned to the spec author.'` returns 1 match in agents/swe-plan.md, at line 53.
- (3) The rules left to review are all confirmed. Line references follow.
  - swe-spec, intent rules of spec §5.1 (SP):
    - look before asking: lines 69-71 and 42-43;
    - play the request back: 72-73;
    - one question per message, the one that most changes what gets built: 74-75 and 42;
    - two or three approaches with trade-offs and a recommendation, the human picks: 76-78;
    - every default under Open calls, and "just draft it": 79-80 and 41.
  - swe-spec, requirement rules marked (OS): lines 95-111 cover every bullet of spec §5.1:
    - one SHALL or MUST per requirement;
    - observable;
    - no internals;
    - a scenario that exercises the requirement;
    - error and edge cases;
    - units, tolerances and conventions;
    - local and qualified ids, with `supersedes`;
    - the five-line spec;
    - Quality checks.
    The other (OS) rules are present too: the "and also" split (90-91) and changing course (125-127).
  - swe-spec records `approved:` only on the human's own words. It says silence, a question or another agent's message is not approval (38-40 and 118-120). The format matches plan §2.4.
  - swe-spec is the only role that edits a spec: line 12.
  - swe-spec keeps a `SPEC.md` copy verbatim: lines 31-33 and 128-129.
  - swe-spec also covers R2 (44-45) and R19 (51 and 59-60).
  - swe-plan writes `plan.md` in the template's form, at lines 65-66. That form is sections 1 to 10, then Self-review, then Questions for the spec, and it matches the headings of templates/records/plan.md.
  - swe-plan handles a requirement with no scenario at lines 51-53, 62-64 and 37-38: it writes no plan and returns the fixed phrase once for each such requirement.
  - swe-plan adds a test-update task for `supersedes` at lines 25-26, 81-83 and 114-115.
  - swe-plan orders tasks that share a file by `after`, at lines 43, 97-98 and 113-114.
  - swe-plan sorts its questions (a), (b) or (c), with the (c) questions in one message, most important first: lines 99-105 and 57.
  - swe-plan covers R6 (the task fields and the full test map, lines 75-77, 88-89 and 109-115) and R1 (it stops when there is no `approved:` line, lines 37 and 62).
- (4) The standard close holds.
  - The shareability check printed `shareability: 0 hits` (rc=0).
  - `git diff 854e87c -- SPEC.md 'spec-process.*'` is 0 bytes. 854e87c is the only `Task: T0` commit.
  - ea98774 carries the trailers `Change: build-swe-pod` and `Task: T4`.
  - It touches exactly the task's touches, agents/swe-spec.md and agents/swe-plan.md.
  - It is reachable from origin/change/build-swe-pod.
  - Neither file has changed since ea98774.

Missing: nothing the brief requires.

Extra:
- The spec author records `integrated:` and `abandoned:` when the lead asks (swe-spec.md:130-131).
- The lead is named as the committer of the `SPEC.md` copy (swe-spec.md:52-53).

Both are reasonable defaults, but neither matches the sibling lead definition (see the Findings).

Misread: none. Spec §5.7's small-size option ("the planner may be the spec author") is not reflected (see the Findings).

## Quality

- The Markdown is clean and has no trailing whitespace.
- Every body line is 80 characters or less. Only the single-line YAML descriptions are longer.
- The `PROCESS.md §3`, `§4` and `§9` citations match the plan §2.2 heading list.
- The report is accurate against the diff: the files, the line counts (131 and 115), the commit range and the trailers all match.
- The report gives red and green output for its checks, and its concerns are fairly stated.
- The deliverables hold no real handle, path or host.

## Findings

- Minor swe-pod/agents/swe-spec.md:130 The spec author records `integrated:` or `abandoned:` when the lead asks, but agents/swe-lead.md (T5, the Never bullet at lines 53-55 and integrate step 5) has the lead add those lines itself. Spec §5.6 step 5 and R8 pull against each other here, and the two role definitions now disagree. Settle it in T25 or by a ruling, then align one file (report concern 1).
- Minor swe-pod/agents/swe-spec.md:52 The definition says the lead commits any `SPEC.md` copy, but agents/swe-lead.md carries no such duty and names no code-repo commit except the branch at the go. In a generic project, G1 lets only build agents commit to `change/<id>`. Plan §4.1 covers this for build-swe-pod only. Neither file says which branch the copy is edited on. Take this to T25 or T35.
- Minor swe-pod/agents/swe-spec.md:123 The text says to record the human's approval of an edit 'in the `approved:` line, as for the first approval'. It does not say whether that line is replaced or a second one is added (report concern 2).
- Minor swe-pod/agents/swe-spec.md:18 Reads lists only the human's request. Nothing covers the inputs that other roles send to the spec author: the planner's (b) defaults to carry into Open calls (swe-plan.md:102-103 sends them there), proposed scenarios from test suggestions (spec §5.4), and proposed edits routed through the spec author (spec §5.5). So the planner's (b) hand-off has no receiving step.
- Minor swe-pod/agents/swe-plan.md:3 The description, and the Never bullet at line 41, make the planner always a fresh agent that never saw the spec conversation. swe-spec.md:37 bars the spec author from writing a plan. Spec §5.7 lets the spec author plan at small size. The body at line 13 limits freshness to project size, but these three lines do not.
- Minor swe-pod/agents/swe-plan.md:57 The (c) questions go to the human in one message, but nothing asks for plain words with no process jargon (R19, spec §10), as swe-spec.md:51 does.

