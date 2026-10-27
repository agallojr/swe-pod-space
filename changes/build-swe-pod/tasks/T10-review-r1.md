---
task: T10
diff: agent-mesh 92f1dcf..7430aeb
verdict: pass
---

Re-review after fix round 1 of 5. Scope: the one new commit with trailer `Task: T10`, `7430aeb` ("Bound task and agent ids in space-librarian profile so hyphen joins match"), checked against the one finding left open by the previous review (Important, SKILL.md:168, the hyphen-join gap for task ids and agent ids).

## Spec compliance

- Missing: none. The previous finding is fixed as asked. The values are now in three lists:
  - `words` (hostnames, first labels, credential key names) keeps the old boundary, `(^|[^A-Za-z0-9_-])v([^A-Za-z0-9_-]|$)`.
  - `agents` (agent_id, agent_name, inbox names) uses an alphanumeric boundary on both sides.
  - `tids` (mesh task ids) uses an alphanumeric left boundary and `[^0-9]` on the right.
  This matches the boundaries the finding suggested. The new probes include `<task id>-result.md` under `_archive/<yyyy-mm>/`.
- Extra: none. The diff touches only `skills/space-librarian/SKILL.md`, which is the task's single touch (+23 / -9 lines). The two T9 files staged in the shared index were left out, so the commit was made by pathspec.
- Misread: none. The prose (lines 76-80) and the code comment (lines 172-175) agree with the code. The one small gap is the Minor finding below.

## Quality

I ran a separate harness. The scratch directory was a fresh `mktemp -d` under /tmp, outside every repo, and I deleted it afterwards. The harness copied the space without `.git` and took the script out of `7430aeb`'s SKILL.md. All values were built at run time from the live registry and none was printed.

- Done-when 1: all five clean records came back `CHECKED`: spec.md, plan.md, ledger.md and the two notes.
- Done-when 2: the five built records came back with the right check and line, and nothing else:
  - `$HOME`: `REFUSED ...: profile line 8`
  - cwd root: `REFUSED ...: profile line 8`
  - agent id: `REFUSED ...: profile line 8`
  - space not in may_reference: `REFUSED ...: reference line 8`
  - duplicate id: `REFUSED ...: id line 2`
- Fix probes, all `REFUSED ...: profile line 8` with the fix:
  - `_archive/<yyyy-mm>/<task id>-result.md`
  - `task-<task id>`
  - `node-<agent id>`
  - `outbox/<agent id>/<task id>-files/`
  - `<agent id>_x`
  - `<task id>_x`
  - `<task id>` followed by a letter
  - `<inbox name>-x`
- False-refusal controls, all `CHECKED`:
  - a UTC record id that shares a task id's digits;
  - a sha256 holding an agent id inside a longer hex run;
  - the environment classes macos-laptop, linux-server and hpc-login;
  - a hostname label in a hyphen compound (passes by design);
  - a task id followed by one more digit.
- The output held only result lines and none of the leaked values. With an empty registry (BUS pointing to a missing directory), all ten registry-dependent probes came back `CHECKED`.
- Totals: `harness: 37 pass, 0 fail` under `sh`, and the same under `dash`, in 16.6 s wall time.
- The same harness against `92f1dcf` gave `30 pass, 7 fail`. All seven failures are hyphen or underscore joins of a bus value, so the red/green split is real.
- I also ran the fixed script read-only on all 60 files of the live space checkout, in 6.5 s wall time. 59 came back `CHECKED`. The one refusal is a reference refusal on an untracked T15 test fixture under `tests/fixtures/overlays/test_I8.../`. It cites `core/...` and is meant for an overlay space whose `may_reference` lists core. `92f1dcf` refuses it the same way, so this commit did not cause it, and it is not a T10 defect.
- Standard close:
  - `share-check.py --task T10` printed `shareability: 0 hits`.
  - In swe-pod, `git diff 854e87c -- SPEC.md spec-process.*` printed 0 bytes (`854e87c` is the latest `Task: T0` commit).
  - `7430aeb` has the trailers `Change: build-swe-pod` and `Task: T10`, has a one-line plain-ASCII subject, and is on `origin/change/build-swe-pod`.
  - `git diff --check` is clean, with no trailing whitespace and no non-ASCII.
- Done-when 3: the section 2 desk output is still in the report. The fix changes only section 1.
- GNU userland is still untested; this node has only BSD tools. The new code uses only POSIX `sed` and `grep -E` bracket classes, so the portability risk the report already lists is unchanged.
- Outside this diff: the report says `tools/share-check.py` (§2.8) has the same old hyphen boundary. That file is not one of T10's touches, so the lead should track it separately. It is not a finding against T10.

## Findings

- Minor agent-mesh/skills/space-librarian/SKILL.md:79 The prose for the joined-value rule names "an agent id, agent name or task id", but the code (lines 143-144, 160) gives the direct-inbox names under `tasks/` the same alphanumeric boundary. A reader of section 1 alone cannot tell that `<inbox name>-x` is refused. Add the inbox names to that sentence.

