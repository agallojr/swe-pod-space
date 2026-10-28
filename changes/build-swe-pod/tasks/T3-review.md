---
task: T3
diff: swe-pod 8770c1a..0ee5f01
verdict: pass
---

# T3 review: space template (D3)

Sources: the brief (changes/build-swe-pod/tasks/T3-brief.md), the report (changes/build-swe-pod/tasks/T3-report.md) and the task's own diff.

The trailer search `Task: T3` on origin/change/build-swe-pod finds one commit, 0ee5f01, whose parent is 8770c1a. It adds 10 files and 87 lines, all under templates/space/.

Rules came from these sources:
- the spec: R4, R5, R16, R17, R18, R22, R23, section 4 and section 8;
- the plan: sections 2.1, 2.4 and 4.1, and the T3 entry;
- the memory-spaces note: sections 3.1 and 3.4;
- PROCESS.md at the branch head: line 3 and section 12.

## Spec compliance

Done-when checks, re-run by the reviewer without changing any file:

- (1) The section 2.1 files and folders exist.
  - git ls-tree lists space.yaml, pod.yaml, AGENTS.md and README.md, plus changes/, tests/, decisions/, handoffs/, notes/ and lore/. Each folder holds an empty .gitkeep (blob e69de29).
  - The result is the same at 0ee5f01 and at the branch head. No later commit touches templates/space/.
  - There is no STATUS.md.
- (2) Both YAML files load in Ruby Psych safe_load (based on libyaml).
  - space.yaml loads to exactly 11 keys, in the plan's order: space, id, kind, title, visibility, owners, writer_model, categories, header_profile, may_reference, retention.
  - Its fixed values match the step: kind project, writer_model multi-actor, the seven categories in the listed order, header_profile shareable and may_reference [].
  - pod.yaml loads to the 6 keys of spec section 4, in order: pod, project, process, repos, depends, gates.
- (3) AGENTS.md:18 holds the test-agent exception. Lines 19 to 21 list what that agent skips. This matches the closing line of the test-writing brief in plan section 2.4.
- (4) The standard close holds.
  - The shareability check for T3 reports `shareability: 0 hits`.
  - `git diff 854e87c -- SPEC.md spec-process.*` is empty, at 0ee5f01 and at the branch head. 854e87c is the only `Task: T0` commit.
  - The commit carries the trailers `Change: build-swe-pod` and `Task: T3`. It touches only templates/space/ (committed by pathspec), and the remote branch contains it.
  - Hygiene: no line is longer than 88 characters, and no line has trailing whitespace.

Rules the steps leave to review, each confirmed by reading the file:

- space.yaml, placeholders and defaults:
  - `id: proj:<project>`, `title` and `owners: [<handle>]` are placeholders.
  - `visibility: shared` and `retention: until-archived` match the example in memory-spaces section 3.1.
  - `space: 1` is the schema version.
  - Holds.
- pod.yaml follows spec section 4 key for key, with the same shapes. Each repo is a flow map with remote and pin, and depends is a map of lists. `process: swe-pod-process@1` matches line 3 of PROCESS.md. The gates are exact. Holds.
- AGENTS.md read order, lines 9 to 16: STATUS.md, then pod.yaml, then PROCESS.md, then the change's spec, plan and ledger, then the brief at the plan section 2.4 path, `T<n>-brief.md`. This agrees with "Arriving cold" in PROCESS.md section 12 and with R18.S1. Holds.
- AGENTS.md standing rules:
  - One branch (lines 27 to 29): only `main`, work in flight kept apart by folder, and `change/<id>` only in the repos the spec names. Serves R22 and R23. Holds.
  - Every write goes through the librarian (lines 30 to 32): only the space's librarian commits, records arrive through the change's lead, and space-wide files change only at integrate. Serves R17 and spec section 8. Holds.
  - Shareable profile (lines 33 to 36): the same substance as spec section 8. Serves R16. Holds.
  - Collision-free ids (lines 37 to 39): the category, the UTC minute and four hex digits, and one file per event for evidence, decisions and handoffs. Holds, with a Minor finding on the missing word "random".
  - Code repos hold only code, unit tests and shipped docs (lines 40 to 42): serves R4 and R5. Holds.
- Test-agent exception: present, with a Minor finding on the public-surface allowance.
- No STATUS.md: holds. README.md and AGENTS.md both name the swe-pod skill as the file's generator.

- missing: none.
- extra:
  - AGENTS.md:25-26 adds a "Specs first" rule. It restates spec decision 1 and R1, matches the space's own AGENTS.md, and does no harm.
  - README.md adds a layout block from spec section 8 and a pointer to PROCESS.md section 12. That heading exists on the branch.
  - Both YAML files carry comments on their fields. One comment adds an unsourced rule (Minor, space.yaml:2).
- misread: nothing material. Two small gaps, both logged as Minor:
  - the id rule leaves out "random";
  - the exception leaves out the public-surface allowance of spec section 5.4.

## Quality

- structure: The files are small, hold placeholders only and read cleanly.
  - The placeholders are consistent: `<project>` in all four files, `proj:<project>` in space.yaml and AGENTS.md, and the README title `<project>-space` from spec section 8.
  - The README layout matches spec section 8 and PROCESS.md section 12.
  - The report raised a concern about projects with one repo or three. The comment "one line per code repo of the project" covers the repos block. A project with one repo would set depends to {}, which the template does not say but is clear enough. No finding.
- error handling: Templates have little to handle. The one fallback is a missing STATUS.md (AGENTS.md:10). It is handled, but the instruction goes to every agent, not just the lead (Minor).
- tests: swe-pod has no unit suite; it holds only Markdown and YAML.
  - The builder's done-when checks for the YAML parse the files and compare key sets and values, so they test structure, not wording.
  - Check 3 matches phrases in AGENTS.md, which tests wording only. I read each rule myself instead.
  - The red and green output in the report agrees with what I re-ran.
- test suggestions:
  - T3.TS1: the for-the-reviewer pointer, AGENTS.md lines 9 to 11, is correct. There is no unit suite to cover it. The behavior belongs to the tester under R18.S1. It relates to the Minor finding at AGENTS.md:10.
  - T3.TS2: the pointer, AGENTS.md lines 18 to 21, is correct. Done-when check (3) covers the text. The behavior belongs to the tester under R9.
  - T3.TS3: the pointer, pod.yaml lines 4 to 7, is correct. The placeholder repos parse as the literal keys `<repo-a>` and `<repo-b>`, so a parser does not stop on them. The behavior belongs to the tester under R23.S2.
- push: The report says T2's aa84b73 carried 0ee5f01 to the remote. git agrees: aa84b73 is the child of 0ee5f01, carries `Task: T2`, and touches only templates/records/.

## Findings

- Minor swe-pod/templates/space/AGENTS.md:10 Read-order item 1 tells every agent that arrives to run the swe-pod skill when STATUS.md is missing. That includes review, build and test agents, whose roles write no space record. Scope it to the lead or the human, or tell the other roles to read the ledgers instead.
- Minor swe-pod/templates/space/AGENTS.md:18 The test-agent exception ("reads only its brief and `spec.md`") leaves out the allowance in spec section 5.4 to use the public surface once code exists (--help output, signatures). agents/swe-test.md Reads grants that allowance. One added clause would align the two before T36 copies this paragraph into the space.
- Minor swe-pod/templates/space/AGENTS.md:38 The id rule says "four hex digits", but memory-spaces section 3.4 says four random hex digits. The randomness is what keeps ids from colliding across meshes. PROCESS.md section 12 has the same omission.
- Minor swe-pod/templates/space/README.md:14 This layout line and AGENTS.md:13 name a PROCESS.md at the space root. The template does not ship one (plan section 2.1), and nothing in it says to copy one in. Carry to T8 so that INSTALL's step for starting a space copies PROCESS.md.
- Minor swe-pod/templates/space/space.yaml:2 The id comment adds a character rule ("lowercase letters, digits and hyphens") that memory-spaces section 3.1 does not state. Drop it or cite a source.

