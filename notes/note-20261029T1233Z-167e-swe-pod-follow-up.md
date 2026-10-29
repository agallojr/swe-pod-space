---
id: note-20261029T1233Z-167e
title: SWE Pod follow-up change, operator requests after build-swe-pod
category: notes
provenance: agent
contexts: []
tags: [swe-pod, follow-up, branches, archive, permissions, install]
discovered_by: agallojr/lead
discovered_on: 2026-10-29
discovered_in: build-swe-pod
retention: until-superseded
---
# SWE Pod follow-up change: operator requests after build-swe-pod

Two requests the operator made at build-swe-pod's integrate, for the next
swe-pod change, with the findings that change also takes.

## Archive branches at delivery, never delete them

The operator: "dont delete, but archive instead. this might be the default
behavior for swe-pod - it makes branches and on delivery archives them."

- Proposed default: after the merge, the lead tags each repo's merged head
  as an annotated tag `archive/<change id>` and pushes it. The tag cannot
  move and keeps the branch out of the branch list; `git checkout -b
  change/<id> archive/<id>` restores it.
- Texts to change: PROCESS.md §8 step 4 ("merge each `change/<id>` and
  delete it"), agents/swe-lead.md (Merge and integrate), the G1 rule in
  INSTALL.md ("deleting a merged branch"), and the README. Whether the
  `change/<id>` branch is then removed is the operator's call at each
  integrate.
- build-swe-pod already follows it: both repos carry
  `archive/build-swe-pod` (agent-mesh f27c611, swe-pod b7fc257).

## One-time permissions, not per project

The operator asked whether each project needs its own temporary permission
rules, and does not want that. build-swe-pod needed them only because it
built the pod before any standing rule existed.

- Proposed: INSTALL.md gives a one-time setup. One git-gate allowlist line
  for a pods root, with build checkouts at `<pods root>/<change id>/<repo>`
  (the gate allows a repo nested under a listed path). Project Spaces under
  the bus are covered by the bus's line. One standing harness rule, worded
  like G1, for `change/<id>` commits and pushes under the pods root and for
  a space librarian's commits to its space's main.
- With that in place, a new project's change needs no permission edit.

## A model for each role, set per project and recorded

The operator agreed (2026-10-29) to make the model each pod role runs on
explicit and auditable. Today PROCESS.md gives only guidance (a cheaper model
for mechanical work with a complete brief, the most capable for design
judgment and the whole-change review, a stronger model for fix rounds 4 and
5), every role file says `model: inherit`, and the lead picks per dispatch
with nothing recorded.

- Proposed: `pod.yaml` gains an optional `models:` map, one entry per role
  (and one for the whole-change review), which the lead follows. A role with
  no entry keeps `model: inherit`.
- Every dispatch line names the model:
  `dispatch T<n> -> <role> (<local|mesh>, <env class|any>, <model>)`.
- On a mesh, the dispatch carries the model to the executor; the node's
  poller model stays its own.

## Also for that change

- The three test-check fixes ruled at build-swe-pod's integrate:
  R14.S1.4 (a ledger append that names pod.yaml counted as a pin edit),
  R17.S2.1 and T10.TS6.1 (output the agent repeats counted twice).
- The deferred Minors and the accepted ones listed in
  build-swe-pod's final report, and agent-mesh
  guidance/agent-operating.md's "one commit per record", which predates the
  integrate mode.
