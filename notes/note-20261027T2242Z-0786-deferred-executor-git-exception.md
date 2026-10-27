---
id: note-20261027T2242Z-0786
title: "Deferred: git exception for remote build executors"
category: notes
provenance: agent
contexts: []
tags: [deferred, git, executor, poller, remote-builders, G1, M1]
discovered_by: agallojr/lead
discovered_on: 2026-10-27
discovered_in: build-swe-pod
retention: until-superseded
---

# Deferred: git exception for remote build executors

**Decision** (operator, 2026-10-27T22:42Z): not in `build-swe-pod`.

The planner's first plan for `build-swe-pod` had T9 (M1, the `swe.*` roles)
add a narrow exception to the mesh poller's executor instruction, which
today says "do not touch git": a `swe.build` executor may commit to and push
only `change/<id>`, in the repo its brief names. That is G1 given a
mechanism for builders on remote nodes.

It is deferred because nothing in `build-swe-pod` uses it: every build task
runs locally, and the one remote task (T20, verify on `linux-server`) only
reads. In this change, M1 stays registration-only, as spec §14 says.

**When to pick it up:** in the change that first puts build tasks on remote
nodes (spec §16 step 6). Land it together with G1, and put G1 in the
operator's overlay before the `agent-mesh` merge, since a node that tracks
the product tip would otherwise run with the exception before the overlay
allows it (review finding A13).
