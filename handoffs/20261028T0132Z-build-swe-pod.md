# Handoff: build-swe-pod, lead role, 2026-10-28T01:32Z

From the lead session that ran the go through wave 2, to a fresh lead
session. Nothing is half-built in a code repo. Machine paths for this node
are not in this record; the operator gives the new lead a private companion
with them.

## State

- The change is in state `building`. Plan revision 4.2 (`changes/build-swe-pod/plan.md`)
  governs; the spec carries the approved R24 amendment.
- Code branches `change/build-swe-pod`: swe-pod at 6f8ed78, agent-mesh at
  e0f6af0. Both checkouts are clean and pushed.
- Done and review-clean: T0, and build tasks T1 to T14, each with its review
  task (T21 to T34) filed under `tasks/`.
- Test work done and filed: T15 (runner, fixtures, I1 to I8), T16 and T17
  (35 scenario tests, R1.S1 to R23.S2), T39 (R24.S1, R24.S2), and T41 (runner
  follow-up: code repos as an extra directory, gateway sign-in kept across
  resets, path redaction). Every test fails at base for its stated reason.
- Every operator decision, directive and ruling so far is in `ledger.md`.
  Read it to the end before acting: OD1 to OD7, PC1 (a, serial remote shard),
  PC2 (i, the lead posts the remote shard with the operator's heavy approval
  quoted), no pull requests (merge and push), G3 already applied to the
  operator's overlay, with higher agent-run limits.
- `STATUS.md` is still the seed version and is stale. Until it is
  regenerated, the ledger is authoritative (plan section 4.1).

## Half-done

Nothing is half-built. These tasks are ready or waiting, in order:

1. Regenerate `STATUS.md` with the swe-pod skill from the swe-pod branch head
   (plan section 4.1: first regeneration once T27 closes, which it has).
2. T37 (role scaling, build, swe-pod) is ready: every task in its after list
   has closed. Write its brief from the plan entry, dispatch a fresh builder,
   then T38, its review.
3. Route the builders' test suggestions. Each build report has a
   `## Test suggestions` section, and the lead routes each one per spec
   section 5.4, recording one ledger line each (`T<n>.TS<k> -> ...`). Then
   dispatch T18 (test) with the "for the tester" parts. T18 runs after T37
   too.
4. Verify, sharded under R24, PC1 and PC2: T19a (local, macos-laptop) and
   T19b (mesh, linux-server, the remote `swe.test` holder). Both run after
   T0 to T18, T37, T39 and T41. T19b's first steps on the remote node are
   `runner.sh reset`, then `runner.sh smoke`; any failure, or a new managed
   policy, is BLOCKED for the operator.
5. T35, the whole-change review on the most capable model, after both shards
   are green at one commit set. It also triages every Minor finding logged in
   the reviews and the tester's own suggestions T39.TS1 to T39.TS3.
6. T36 integrate, on the operator's merge word (plan section 8).

## Open questions

- PC3: does the pilot still run R7.S1 and R17.S1 live? The default is yes;
  the operator has not answered.
- The verify heavy ask needs the operator's yes before either shard runs.
  Compute the expected time from each test's filed `expected_s` and the
  split. The filed tests sum to about 196 min serial, so each shard is about
  95 to 100 min. The cap is 150 min per shard. Quote the operator's approval
  line in T19b's Context.

## Next command

Read `AGENTS.md`, then `pod.yaml`, then `changes/build-swe-pod/ledger.md` to
the end, then this handoff. Re-run the latest check before building on
inherited work: confirm both branch heads match the State above. Then do
item 1 of Half-done.
