---
task: T9
diff: agent-mesh 7430aeb..97b35a2
verdict: pass
---

Range: agent-mesh 7430aeb..97b35a2. One commit carries the trailer `Task: T9`: 97b35a2 "Register the six swe roles in the identity template and operator manual". Its trailers are `Change: build-swe-pod` and `Task: T9`, and its subject is one line of plain ASCII. Its parent is 7430aeb, the tip of T10 and T11. The brief's start pin, 8ee5364, is an ancestor of 7430aeb, and neither T10 nor T11 touches T9's files.

## Spec compliance

The task serves spec R7 and spec section 14 M1 ("Registration only; no protocol change"), plus plan section 2.7 Roles and section 3 OD4.

- **Missing.** Nothing. I read each rule in the plan step against the deliverable:
  - Six roles named in both files.
    - Template lines 16-17 name `swe.spec`, `swe.plan`, `swe.lead`, `swe.build`, `swe.test` and `swe.review`.
    - The manual's section 1 bullet "SWE Pod roles" (lines 43-44) names the same six.
  - Called per-task-output roles.
    - Template line 17 says "per-task-output roles too", which ties back to the existing per-task-output sentence at line 10.
    - Manual line 44 says "per-task-output roles (PROTOCOL §2)".
    - Both add "any number of nodes may hold each", as plan section 2.7 says.
  - Registering means adding the role to `AGENT_ROLES`. Template line 18 and manual lines 47-48 both say so.
  - No change to the protocol, the guidance or the poller (OD4). The commit touches only the two listed files. PROTOCOL, guidance/, skills/ and hooks/ are untouched.
- **Extra.** Nothing beyond the brief.
  - The template's added sentence "No protocol, guidance or poller change." is the one piece of out-of-place wording (Minor, below).
- **Misread.** None.
  - The builder's concern: the default `AGENT_ROLES=build,install,slurm.submit,results.groom` is unchanged. That is the right reading of "registration only". Adding swe roles to the default would make every new node claim pod tasks without the operator choosing it. M1 makes the roles registrable; it does not assign them.
  - The template's example has one node holding both `swe.build` and `swe.test`. Spec section 6 allows this ("One node may hold several roles if each task runs as its own agent").

Done-when, re-run by the reviewer (read-only):

1. Grep on `origin/change/build-swe-pod`: all 12 role/file pairs found. At the parent 7430aeb, both files have 0 `swe.` lines (red).
2. Files in the `Task: T9` commits: exactly `docs/operator-manual.md` and `templates/agent-identity.env.template`.
3. Standard close:
   - The shareability check with `--task T9` prints `shareability: 0 hits`.
   - In swe-pod, `git diff 854e87c -- SPEC.md spec-process.*` is 0 bytes (854e87c is the latest `Task: T0` commit).
   - The commit is by pathspec, has both trailers, and is pushed: `ls-remote` shows `change/build-swe-pod` at 97b35a2.
   - This review has no open Critical or Important finding.

## Quality

- The change adds 11 lines and no code. `git show --check` is clean, and the longest added line is 79 chars.
- Every added template line starts with `#`. I checked every reader of the identity file:
  - `mesh-post.sh` uses start-anchored `sed -n 's/^AGENT_ID=//p'` and `s/^REPO_PATH=//p`.
  - `hooks/lore-recall.py` skips `#` lines.
  - `hooks/mm-qa-gate.py` matches `startswith("REPO_PATH=")`.
  - PROTOCOL section 8 boot `source`s the file.
  - None parses the new comments. The one soft spot is that mesh-on reads the file through `cat` and an agent (Minor, below).
- Dotted role names already work as queue names: `slurm.submit` exists, and the scan loop splits on commas only.
- The manual bullet fits section 1 and cites PROTOCOL section 2 correctly. Its "Nothing else changes" is accurate: the `project:` and `files:` work of T11 to T13 applies to every role, not only to swe roles.
- Tests: agent-mesh has no unit suite and this is a docs-only task, so no unit tests are expected. I checked the "for the reviewer" parts of T9.TS1 to T9.TS3 directly:
  - TS1: both locations, as above.
  - TS2: the default `AGENT_ROLES=` is unchanged.
  - TS3: all added template lines are comments, and the readers use start-anchored patterns.
- Report accuracy:
  - The red and green outputs for checks 1, 2, 3a and 3b match my re-runs.
  - Check 1b, labeled an aid, counts "per-task-output" lines as 1 to 2 in the template. A fixed-string grep gives 0 to 1, so the builder's pattern also matched the existing "per-task output" at line 10. This is not a defect in the deliverable.

## Findings

- Minor agent-mesh/templates/agent-identity.env.template:19 The example `# AGENT_ROLES=build,swe.build,swe.test.` ends in the sentence's period, right against the value, and sits directly above the live `AGENT_ROLES=` line. Copied as written, it gives a role named `swe.test.`. mesh-on Step 1 also has an agent pull AGENT_ROLES out of `cat` output, and an assignment-shaped comment next to the live line invites a misread. Put the example in prose or backticks, with no trailing period.
- Minor agent-mesh/templates/agent-identity.env.template:19 "No protocol, guidance or poller change." reads as a note about this change. A node operator reading the template later has no change to compare it against. The manual's wording says the lasting fact: the protocol, the guidance and the poller treat these roles like any other.
- Minor agent-mesh/docs/operator-manual.md:46 "each holder writes only its own `outbox/<agent-id>/<task-id>-result.md`" will be inexact once T13 lands plan section 2.7 result files: the swe roles are the main users of `files:`, whose bodies go to `outbox/<agent-id>/<task-id>-files/<path>`. T13 does not touch the manual and T12 covers only mounting, so no planned task fixes this. "writes only under its own `outbox/<agent-id>/`" stays true. The text mirrors PROTOCOL section 2's wording, which T13 may also leave as it is.
- Minor agent-mesh/docs/operator-manual.md:47 Neither file says when a new role takes effect. Registration (PROTOCOL section 4.3) and the queues the scan loop watches are read from the identity file at boot (mesh-on Step 1), so a role added to AGENT_ROLES applies only from the node's next /mesh-on. The plan step did not ask for this.

