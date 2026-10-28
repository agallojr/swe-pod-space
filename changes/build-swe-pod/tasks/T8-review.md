---
task: T8
diff: swe-pod 5aacf3f..6f8ed78
verdict: pass
---

## Spec compliance

Scope: one commit, 6f8ed78 (parent 5aacf3f). I found it with `git log -E --grep='^Task: T8$' origin/change/build-swe-pod`. It has trailers `Change: build-swe-pod` and `Task: T8` and touches only the two files in `touches:`. README.md has 146 lines added and 2 deleted. INSTALL.md is new, at 136 lines. `origin/change/build-swe-pod` is at 6f8ed78. T8 serves R7, R13 and R17 (D5, and the shipped docs of §2.1). I read the commit against the brief, plan §2.1, §3 and §4.1, spec §13 to §16, R7, R13, R17 and R24, and PROCESS.md §1 to §11 and §14. I also checked its claims about agent-mesh against `change/build-swe-pod` in agent-mesh: `install/install.sh` step 6, `skills/space-librarian/SKILL.md`, `skills/mesh-load/SKILL.md`, and the operator manual's §8.

Done-when, one by one:
- (1) Holds. I checked each repo-relative path in both files against `git ls-tree` at 6f8ed78. These all exist: the 35 layout entries (the six empty template folders each hold a `.gitkeep`), plus `INSTALL.md`, `PROCESS.md`, `templates/space/`, `templates/records/`, `skills/swe-pod` and the `agents/swe-*.md` glob (6 matches). The path agent-mesh uses, `skills/space-librarian/SKILL.md`, exists on agent-mesh's change branch.
- (2) Holds. The README diff deletes exactly 2 lines. They are T0's status sentence, which T0 wrapped over two lines. Reading "the status line" as that sentence is the plain meaning, and I accept it. Lines 1 to 8 are byte-identical to T0's. `SPEC.md` is still named on lines 6 and 12.
- (3) Holds. `## Rules for your guidance overlay` (INSTALL.md:112) has three rules, labeled `G1.`, `G2.` and `G3.` in order.
- (4) Standard close:
  - The shareability check, re-run on the T8 commit, prints `shareability: 0 hits`.
  - `git diff 74d23f1 6f8ed78 -- SPEC.md spec-process.*` is empty. 74d23f1 is the latest `Task: T0` commit.
  - The commit is by pathspec, with both trailers, and pushed.
  - This review leaves no open Critical or Important finding.

Steps, read in the deliverable:
- README: holds.
  - Every T0 line except the status line is kept.
  - The status is rewritten to the post-merge state. `swe-pod-process@1` matches PROCESS.md line 3 and the pod.yaml template.
  - The §2.1 layout is complete. It lists each path at the start of its own line.
  - Single seat and mesh use are covered, and README.md:111-115 says the pod depends on agent-mesh's `space-librarian` when no mesh is present. That matches PROCESS.md §10 and R17.S2.
- INSTALL linking: holds.
  - Linking into `~/.claude/agents/` and `~/.claude/skills/` (INSTALL.md:24-28), with the explicit "Never install them into a project" (INSTALL.md:38-42).
  - Starting a space from `templates/space/` plus `PROCESS.md` (INSTALL.md:70-77).
  - The claim that the Agent Mesh installer links every product skill matches step 6 of install.sh, which loops over `product/skills/*/`.
  - The mesh mount at `<bus>/swe-pod/` with `-b main` and `ignore all` matches spec open call 11. It is needed because the bus-relative role definition path in PROCESS.md §11 depends on it.
- G1 to G3 in generic terms: holds.
  - G1 follows spec §14 clause by clause, including "Until this rule is in the overlay, the human makes these commits".
  - G2 is close to verbatim.
  - G3 generalizes "the solver-run budget policy" to "the budget policy on long runs, such as a solver-run budget policy". It adds that the policy's caps and ask points still hold, and the closing paragraph restates spec §7 ("loosen nothing else"). These clarify G3 and loosen nothing. They agree with R13.S1 and PROCESS.md §11 Fences.
- SPEC.md and spec-process.* untouched: holds.

Missing: nothing the steps ask for.

Extra, judged acceptable:
- README `## How it works`. T38 checks it against PROCESS.md after T37. I checked each claim in it against PROCESS.md §2 to §11 and §14, and found two deviations, both Minor (README.md:24, README.md:35).
- INSTALL's mesh mount, first-commit and remote steps. They agree with the agent-mesh operator manual §8 and with space-librarian's input rule that a space root has `origin`.

Misread: none that changes meaning. Four wording points are listed as Minor findings: README.md:24, README.md:122, INSTALL.md:79 and INSTALL.md:114.

## Quality

- **Structure.** The README goes from intro to status, How it works, Layout and Use (single seat, then mesh). INSTALL goes from needs to global install, mesh mount, starting a space, and the overlay rules. Both are clear and in an order a newcomer can follow. No trailing whitespace, and no line over 88 characters, in either file (checked).
- **Commands.**
  - The install commands work with both BSD and GNU `ln`, and a re-run leaves the links unchanged.
  - The `git -C <bus> config -f .gitmodules` form finds the file correctly, because `-C` runs first.
  - `cp -R .../templates/space/. <space>/` copies the `.gitkeep` files.
  - One fragile case is listed as Minor: `ln -sfn` onto a real directory left by an earlier copy (INSTALL.md:27).
- **Tests.** swe-pod is Markdown and YAML with no unit suite (0/0), as the plan expects. The builder's done-when checks were a throwaway script, since deleted. Its red output (47 failures, all missing content, with the deletion, `SPEC.md` and hygiene checks already passing) and its green output agree with what I re-derived by hand. So the checks tested real content, not wording alone.
- **"For the reviewer" parts.** No unit test covers them, because the repo has none. I read each part directly:
  - T8.TS1 (INSTALL.md:18-49): correct. INSTALL.md:11 requires `<swe-pod>` to be absolute, in prose only.
  - T8.TS2 (INSTALL.md:12-16 and 30-36, README.md:111-115): accurate against the space-librarian skill and install.sh.
  - T8.TS3 (INSTALL.md:129-136, README.md:152-155): the live-session ask appears in the README and in PROCESS.md §11. INSTALL defers to the fences, which is consistent.
- **Report accuracy.** It is accurate except for one line count (listed as Minor). The commit, range, shareability result, red/green claims and concerns all match the diff.

## Findings

- Minor swe-pod/README.md:24 "A fresh planner" is stated for every change, but PROCESS.md §9 lets the spec author plan at small size; README.md:107-109 has it right
- Minor swe-pod/README.md:35 the sharded-verify rule is given as a summary of PROCESS.md, which has no sharding text at 6f8ed78; T37 adds it, and T38 should confirm the two wordings agree
- Minor swe-pod/INSTALL.md:79 "replace every `<placeholder>`" would also rewrite notation that must stay in the space template (`changes/<id>/`, `<handle>/<role>`, `<category>-<YYYYMMDDTHHMMZ>-<4 hex>` in AGENTS.md and README.md); INSTALL.md:86-87 also asks for a one-sentence description in AGENTS.md, which has no slot for it
- Minor swe-pod/INSTALL.md:114 the overlay intro gives the reason for G1 and G2 (commits, spec and test files) but not for G3, so a deployment cannot tell when it needs G3, and "operator-posted" is never explained
- Minor swe-pod/README.md:122 the session walk-through goes from "approved" straight to "go" and leaves out the plan and the human's plan skim at project size
- Minor swe-pod/INSTALL.md:27 `ln -sfn` onto an existing real directory at `~/.claude/skills/swe-pod`, left by an earlier copy, makes a nested link inside it and leaves the stale copy in place; INSTALL does not say to remove a copy first
- Minor swe-pod-space/changes/build-swe-pod/tasks/T8-report.md:56 the report says 148 lines were added to README.md, but git numstat gives 146 added and 2 deleted (148 changed)

