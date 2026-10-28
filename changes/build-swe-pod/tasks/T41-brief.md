# T41 brief

- change: build-swe-pod
- task: T41
- role: test
- repo: space

## Task

From plan.md, verbatim:

### T41 Runner features for verify
- role: test
- repo: space
- after: [T15]
- runs: local
- needs: any
- serves: [R1 to R24] (the verify harness)
- touches: changes/build-swe-pod/tests/runner.sh, tests/README.md
- steps: The work is already under way in the test role, and the lead files
  it under T41. It adds three runner features:
  1. **Gateway-config reset.** Keep `forceLoginMethod`,
     `forceLoginGatewayUrl` and the stored sign-in. Reset only the agents,
     the skills, the other settings, per-project memory and session state.
  2. **Code repos.** Use `<run>/repos` as an extra directory when it is
     present.
  3. **Output rewrite.** In kept output, rewrite the runner-config path,
     `$HOME` and each registered agent's working directory to placeholders.
- done when: `runner.sh smoke` has one passing case per feature on this
  node; the same three cases run on the linux-server node as T19b's first
  step; and README documents all three features.

## Follow-up: smoke probes that do not fire

The lead ran `runner.sh smoke` as a pre-flight on both verify nodes on
2026-10-28, at space 223998d with the gate at agent-mesh e0f6af0. Seven of
eight cases passed in each run. Each failure was a probe that did not fire;
no isolation property failed:

- S3, linux-server: the CLI refused the agent's `sleep 90` as a standalone
  foreground sleep, so the run ended after 6.9 s and the cap was never
  reached. The same case passed twice on macos-laptop, where the agent's
  command reached the cap.
- S4, macos-laptop, first run: the run ended after API retries with no turn,
  the runner's one retry printed no git command either, and the case failed.
  It passed on the next run.
- S7, macos-laptop, second run: the agent printed the `git -C <repo> commit`
  step as a desk step instead of attempting it, so no denial was observed.
  It passed on the first run and on linux-server.

Verify stops a shard as BLOCKED on any smoke failure, so a case that fails
without its property failing blocks verify for nothing.

## Rulings

- Change only `changes/build-swe-pod/tests/runner.sh` and
  `changes/build-swe-pod/tests/README.md`; they are in your lane.
- Make S3, S4 and S7 fail only when the property each one shows fails: give
  S3 a long-running command the CLI runs in the foreground, and make the S4
  and S7 prompts leave the agent no reading under which it skips the step.
  Where a run gives no turn, or the agent does not attempt the probe step,
  the case may be retried, at most twice, and the output says so.
- Keep every other case, the reset and the output format as they are.
- Done when: `runner.sh smoke` passes all eight cases in three runs in a row
  on this node, with the output of each run in your report. The lead runs
  the same on the linux-server node.

## Start from

- space: main at the commit that files this brief

## Result goes to

- changes/build-swe-pod/tests/runner.sh and tests/README.md, returned to
  the lead for filing
- the report: changes/build-swe-pod/evidence/<YYYYMMDDTHHMMZ>-T41-report.md

Do not read plan.md, ledger.md, any other brief, report or review, or any code-repo diff or implementation body.
