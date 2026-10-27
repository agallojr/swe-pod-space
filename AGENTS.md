# Agents: start here

This is the Project Space for `proj:swe-pod`. It holds the process, specs,
plans, records and project-level tests. Code and other deliverables live in
the code repos `pod.yaml` names.

Read in this order:

1. `STATUS.md`: where each change stands.
2. `pod.yaml`: the code repos, their pins and merge order.
3. For the change you work on: `changes/<id>/spec.md`, then `plan.md`, then
   `ledger.md`.
4. Your task's brief, if you have one: `changes/<id>/tasks/<n>-brief.md`.

Until `PROCESS.md` exists (deliverable D1 of `build-swe-pod`), sections 4 to 9
of `changes/build-swe-pod/spec.md` are the process.

Standing rules:

- Specs first. Nothing is planned, built or tested for a change whose spec has
  no `approved:` line.
- This space has one branch, `main`. Code work happens only on `change/<id>`
  in the code repos the change's spec names.
- Every write to this space goes through its librarian.
- Records here are shareable: no hostnames, agent ids, mesh task ids,
  home-directory paths, credential names, or citations of private records.
- New record ids are collision-free: the category, the UTC minute and four hex
  digits, as in `note-20261027T2148Z-3c9e`.
