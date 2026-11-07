---
id: note-20261107T1904Z-d8af
title: Direct edit outside the pod, a trivial size and a lighter small (swe-pod-process@4)
category: notes
provenance: agent
contexts: []
tags: [swe-pod, sizes, cost, direct-edit, process-4]
discovered_by: agallojr/operator
discovered_on: 2026-11-07
discovered_in: add-size-gauge
retention: until-superseded
---

# Direct edit: a trivial size and a lighter small (swe-pod-process@4)

On 2026-11-07 the operator asked for the changes below to be made straight
to swe-pod, **not through the pod**: no spec, plan, briefs, tests or reviews.
This note is the only record of it in the space. Where it is: swe-pod `main`
at `93426ee`, fast-forwarded on the operator's word from `7168579` (main
after `add-size-gauge`): `1dbc81f` (the lighter process), `e67ab5a` and its
revert `5da65a6` (a misread, trivial-only-when-asked), and `93426ee` (the
pod only when asked).

## Why

The operator spends too many credits on small changes to research-grade
software. A review of `add-size-gauge` found that a small change still cost
about the same as before, and its testing cost more: @3 had small write a
blind test for **every** scenario, where @2 wrote none when no requirement
was at risk. A small change still started 4 to 5 fresh Opus agents, each one
reading `PROCESS.md` (about 1,400 lines). `add-size-gauge` itself took 7
tasks, 3 test agents, and 2 reviews with 28 Minor findings between them, and
was merged early because the operator was short of tokens.

The operator's constraints still hold: a spec for every change; builder
separate from the spec author; tester separate from both; every role on Opus;
always a plan, even if it is terse.

## What changed (swe-pod, process @3 -> @4)

1. **Trivial size**, below small. The spec author may suggest it and the
   operator confirms it, or the operator names it ("a trivial pod"). It is for a
   typo, a rename, a one-line fix or a doc edit: one repo, one or two
   requirements, a fault that is cheap and shows at once. The spec has only
   Why, Requirements and Open calls. The plan is a stub written by the spec
   author: one build task whose done-when checks every scenario, one test
   task that runs verify only, integrate, test map, self-review. No risk
   table and no review. Fix cap 2; each fix round ends with verify run
   again.
2. **Small: blind tests only where at risk.** The terse plan gets its risk
   table back (a few rows). Only requirements marked at risk get blind
   tests; with none at risk there are none. Builder tests cover the rest,
   checked by the review and rerun by verify.
3. **Small: one test agent.** A new "One test task" (`PROCESS.md` §6) runs
   after the build task and the whole-change review. It writes any blind
   tests (still blind: it reads no implementation body, diff or report),
   any routed suggestions and any supersedes replacements, runs them at
   base, then runs verify. The separate suggestions task is gone for small.
   A fix routed from a verify failure gets no re-review; verify running
   again is its check.
4. **Small: no Minor findings.** The whole-change review reports Critical
   and Important findings only, so no Minor-parking rulings.
5. **All sizes: briefs are self-contained.** A build brief gets a
   `## Requirements` section that quotes the requirements and scenarios it
   serves. Builder, test and review role files no longer list `PROCESS.md`
   as something to read: they open it only for a section they cite, and
   never read it whole (`PROCESS.md` §11, "Self-contained briefs").
6. **The swe-pod skill:** a build task that no review covers (the trivial
   stub) is done once it has reported, and "verified" needs the whole-change
   review only where the plan has one.
7. **The pod runs only when asked** (`PROCESS.md` §2a, added after the
   rest). In ordinary conversation, a question, a fix or a bare "go" is
   done directly, with no spec or records. "Start a pod", "pod this" or "a
   trivial / small / medium / large pod for …" starts one, and a size named
   there is the change's size. The role and skill descriptions now say they
   apply only to a pod the operator asked for, so Claude does not pick them
   for ordinary requests. The space's `AGENTS.md` has the same standing
   rule.
8. **Medium and large did not change**, apart from item 5. The reviewer's
   check that builder tests exercise their scenarios now applies to small as
   well.

Files: `PROCESS.md`, `README.md`, a note in `SPEC.md` §5, the six
`agents/*.md`, `skills/swe-pod/SKILL.md` and `status-format.md`, and the
templates `brief.md`, `test-brief.md`, `plan.md`, `spec.md`, `ledger.md` and
`space/pod.yaml`.

## Open, for the operator

- **Pins moved by hand, not by integrate.** On the operator's word this
  space now pins `swe-pod-process@4` and swe-pod `93426ee`, and its
  `PROCESS.md` is the @4 copy. `add-size-gauge` was merged without its fix
  re-review, verify or integrate (ledger, 2026-11-07T18:41Z), so it is still
  open: not archived, tests not promoted, no final report.
- **Tests that @4 breaks.** In `changes/add-size-gauge/tests/`, `test_I1`
  and `test_I3` check for `@3`, and `test_R4_S1` checks the @3 terse-plan
  sections. They will fail against @4. Nothing was run here, and the
  regression suite under `tests/` was not run against @4.
- **Superseded in part:** add-size-gauge/R4 to R6 (terse plan, small's blind
  tests, small's one review) and R13.S1 (small's Minor findings), by the
  rules above.
