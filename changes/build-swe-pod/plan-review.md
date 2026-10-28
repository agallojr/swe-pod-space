# build-swe-pod: plan review

Adversarial review of `plan.md` before the go, by a fresh reviewer. Line
numbers refer to `plan.md` (1076 lines) and `spec.md` as of the review.
Negotiation rounds follow the findings: the planner accepts (and fixes) or
rebuts each finding; the reviewer concedes or holds; the lead rules on
anything still open.

## Findings

**A1. Critical.** §2.4 test-writing brief (L109-113), §6 (L675-676). The test
brief has no `## Task` section and its closing line forbids reading plan.md,
so nothing in T15's steps reaches the agent that runs it: the run protocol,
test front matter, fixture design and the I1 to I8 definitions (L687-716).
T16's "Fails if" rule and T18's routed suggestions are lost the same way. I6
is defined as "all three cases of T11's done-when" (L712-713) and "operator
content" only in the standard close (L339-341), both in §5, which the test
agent may not read and which R9 bars from the brief as build-task steps.
Spec §7 (L542-546) puts the task text in every brief. Fix: add `## Task` (the
test task's own entry, verbatim) to the test-brief format; restate I5, I6 and
the other I-checks inside the test tasks or §2, with no reference to §5. T36
(L877-878) should also put the template's test-agent exception into this
space's live AGENTS.md, whose read order sends every arriving agent to plan.md
and ledger.md.

**A2. Critical.** T15 run protocol (L688-693), spec §13 (L1017-1019). Agents
under test started from a session on this node load the operator's global
CLAUDE.md chain and run under the git-gate hook, which confounds the tests:
R13.S1 can pass on the overlay's sweep fence alone; R19.S1 and the spec
author's "two or three ways" collide with the base rule against multi-option
clarifying prompts; the hard limits decide the lead's branch and commit
behavior; every agent-mode test whose lead files a record (R7.S2, R8.S1,
R10.S1, R14.S2, R18.S2, R21.*) tries a commit in a scratch dir that is not on
the allowlist, and the fail-closed gate denies it. Those THENs would measure
the operator's guidance, not D1 to D4, and a test that passes at base on
guidance alone locks R10.S1 into a loop the test agent cannot fix. Fix: T15
runs each agent under test as a separate headless process with an isolated
config dir holding only the deliverables (no CLAUDE.md, no overlay); fixtures
have no git remotes; the cwd is scratch; the librarian commit step is always
desk. T15's done-when includes a smoke test of this runner, which also
settles the nesting depth R7.S2 needs.

**A3. Important.** T11 done-when (2) and (4) (L607-613), I6 (L712-713).
`mesh-post.sh` line 80 exits 1 with "not a git repo" before writing any
message, so a dry run against a scratch dir that is not a git repo cannot
pass, and I6 (which T19 and T20 must pass) carries the defect. The obvious
workaround, dropping `--repo`, falls back to REPO_PATH, the live bus, where
`--dry-run` runs `git add` on the message file and the next poller sync would
push it as a real task. Whether `--project` is validated before the repo
check (exit 2 or 1 for case 3) is left open. Fix: the scratch is a throwaway
`git init` repo outside every repo; every run passes an explicit `--repo`;
`--project` is validated inside the argument loop.

**A4. Important.** §4 note (L302-306), T0 (L320-322). Risk to the live
system. This node sets MESH_PRODUCT_TRACK=tip; while mesh-on runs,
`mesh-scan-loop.sh` (L63-65) runs `submodule update --init --remote
--recursive` every 60 s in checkout mode, with no `update=` configured. Any
bus submodule whose HEAD differs from origin/main is detached to it: the bus's
`swe-pod/` checkout on `change/build-swe-pod` loses the branch's files
mid-task, and the space checkout the librarian commits in is detached under
any unpushed commits. The poller's sync runs `git -C <bus> add -A`
(poller-prompt L160), so any worktree or scratch dir under the bus (the
overlay's default is agent-tmp) gets committed and pushed. The poller is
stopped now (stop flag present). Fix: mesh-on stays off on this node from the
go to integrate; after T0, all swe-pod work happens in a worktree; both
worktrees sit outside the bus, with the path given in the dispatch prompt,
not the brief (R16); parallel builders in one repo share that worktree, since
git refuses one branch in two worktrees.

**A5. Important.** T10 done-when (L582-586), T15 I8, standard close
(L337-341). The §2.7 librarian checks (L223-240) refuse records this change
must file. spec.md L559 holds `id: 20261102T1405-0003`, which matches the
mesh-task-id pattern; T1 keeps "every rule and table", so PROCESS.md carries
it too; T36 marks `integrated:` on spec.md and copies PROCESS.md in
(L875-880), and both would be refused. What the reference check counts as a
citation is undefined, and the spec's example ids such as
`add-vqls-backend/R1.S1` would not resolve. If the `REFUSED ... <detail>`
text or the ledger line `refused <path>: <reason>` (L153) echoes the matched
hostname, credential name or home path, the ledger itself breaks R16. Fix:
define which tokens are checked (front-matter values, plus id-shaped tokens
outside fenced example blocks); the detail names only the check and the line
number; add spec.md, plan.md and the ledger as clean records in T10's
done-when and I8.

**A6. Important.** Standard close (L339-341). Every build report must show
"the grep that was run"; unless the patterns are read from a file at run
time, the command itself carries the hostnames and agent ids it searches for,
so every report breaks R16 and is refused (A5). T10's report also shows the
output of refused negative content. "Home-directory path" is undefined:
agent-mesh docs legitimately name `~/.agent-identity.env`, and T8's INSTALL
must name the user's Claude config. Fix: one check script, kept outside the
space and the code repos, builds its patterns from agents/*.yaml and the
identity file at run time; reports cite the script and its exit status; a
home path is an absolute per-user path, generic `~/` paths allowed.

**A7. Important.** At-base runs: T15 (L688-693), T16 and T17 (L734-736), test
brief (L109-113). The harness reads deliverables "from the branch checkout";
by the time T16 and T17 run at base, T1 to T6 will usually have committed, so
the runs are not at base. The test brief has no `## Start from`, though spec
§7 puts the commit set in every brief, and the base is ambiguous: swe-pod
`8fc5294` (L6-7) or the T0 commit (L324). I5 checks a property, not added
behavior, so it passes vacuously at base and T15 done-when (2) (L718-720)
cannot be met. Fix: check out the base commit set by sha into scratch, naming
the swe-pod sha; add `## Start from` to the test brief; exempt I5 from
fail-at-base, with the reason in the ledger.

**A8. Important.** T20 (L785-800), mesh dispatch (§2.3 L90-93). On the remote
node `swe-pod/` sits at `8fc5294` until the merge, so
`swe-pod/agents/swe-test.md` does not exist there; that node has no M2 to load
the space through `project:`; in pin mode its space checkout predates the T20
brief; it has neither change branch; its executor instruction says "Do NOT
touch git". Fix: T20's Context carries the repo URLs and the exact commit set
and tells the executor to fetch them read-only into a scratch dir outside the
bus, read the role definition from the swe-pod branch commit (or inline it in
the brief), and states that read-only git is allowed.

**A9. Important.** T1 (L360-363) against spec §13 D1 (L1011) and spec §4
(L109-142). T1 rewrites only §§5 to 11, but the branch model (create from the
pin at the go, record the base, no other branch, amendment on the same
branch, rebase when main moves, delete after merge) and the `pod.yaml` format
live in §4. R22 and R23 are traced to T1, and this space's AGENTS.md calls
"sections 4 to 9" the process. Fix: T1 carries §4's Branches rules and the
`pod.yaml` format into PROCESS.md, and I1 checks them.

**A10. Important.** Consequence of pending Question 2 (L1005-1012). G1 (spec
L1025-1030) also covers the space librarian's commits and pushes to `main`;
until G1 exists the human makes every space commit too: briefs, reports,
reviews, test files, evidence, ledger lines, and the STATUS.md regeneration
T5 does after each filing (L463-464). The plan never says how records are
filed before T10's space-librarian is merged and installed at T36: who runs
the checks, from what text. STATUS.md goes stale, because hand edits are
barred and the skill arrives only with T7. Fix: state the interim filing
procedure (this node's librarian applies the §2.7 checks from the branch
text; the human commits once per task close), include those commits in the
count, and say when STATUS.md is first regenerated.

**A11. Important.** Heavy fence: R13 (L869-871), spec §7 Fences (L590-592),
T19 (L773-778). T16 and T17 run 35 fresh-agent tests at base, each likely
over 60 s, with no R13.S1 ask. T19 runs "up to 4 in parallel" on a
macos-laptop, but the budget policy §7 binds is serial on a laptop. Nothing
enforces the 10-min caps on Agent-tool subagents. Fix: an at-base run whose
deliverable is absent records the failure without spawning an agent, and
otherwise asks first; T19 runs serially, or its parallelism goes into the
heavy ask as an explicit exception; caps are enforced through the runner in
A2.

**A12. Important.** T12 file map (L622-623) against M2 (spec L1040-1044).
`submodule update --init --recursive` in mesh-scan-loop.sh initializes every
registered submodule on every node every cycle, so every node clones the
private space, breaking M2's "nodes clone it on first need". In tip mode the
clones are detached, and T10's "pull with rebase" retry fails on a detached
HEAD. Fix: add mesh-scan-loop.sh to T12, so it updates `product` and loaded
spaces only; T10 fetches, rebases onto `origin/main` and pushes `HEAD:main`.

**A13. Important.** D5 (spec L1015) against §1 (L33-34) and T36 (L867-874).
G1 to G3 are part of D5 but have no build task and no review; the lead drafts
them into the final report, though the lead role writes no deliverables; the
operator applies them after the merge. This node tracks agent-mesh tip, so
merging T9's executor git exception before G1 is in the overlay opens a
window where product and overlay disagree. Fix: a build task writes G1 to G3
as a shipped guidance snippet in swe-pod, reviewed like the rest, applied to
the overlay before the agent-mesh merge.

**A14. Minor.** T36 step 2 (L864-866). The lead "brings SPEC.md into line"
after an amendment: a spec edit outside the spec role (R8) and a shipped-doc
edit outside a build task (spec §5.6 L483-485). The new commit adds handle
lines after T0, so I5 fails, and it moves the commit set after the last
evidence. Fix: a verbatim re-copy by the spec role before the final T19 run,
with T0's check (3); I5 skips SPEC.md entirely.

**A15. Minor.** T3 (L401-404) lists only four space.yaml keys; the §2.7
reference check reads `may_reference`. Fix: list every manifest key (space,
id, kind, title, visibility, owners, writer_model, categories,
header_profile, may_reference, retention) as placeholders.

**A16. Minor.** T8 (L533-542). "Keep every line" preserves T0's README line
saying the deliverables "are being planned", false after merge; done-when (1)
fails on INSTALL's targets in the user's config, which are not on the branch.
Fix: T8 may replace that one status line; (1) covers repo-relative paths
only.

**A17. Minor.** Evidence (§2.4 L125-133, T19 L779-783) has no key for the
`test_T<n>_TS<k>` results. R16.S1 reads "all ledgers from the runs" (L917),
so it must run after every other test, with their scratch dirs kept. Fix: add
`x-suggestions:` and run R16.S1 last.

**A18. Minor.** T20 (L794-800) is itself a live dispatch to a linux-server
`swe.test` holder with a filed remote result, which gives live observations
for the THENs of R7.S1 and, with M3 present, R17.S1. Fix: record its Context
lines and dispatch ledger line as supplementary R7.S1 and R17.S1 evidence,
with no task id in the space.

**A19. Minor.** T4 (L434-436), T5 (L466), T6 (L497), T13 (L654-656) have "a
grep finds <concept>" done-whens; the builder writes both the text and the
pattern, so they cannot fail. Fix: pin the exact strings the contract or
tests rely on and leave the rest to review.

**A20. Minor.** T13 (L649-653). The executor instruction in poller-prompt
(L261-264) and agent-operating (L156) still says "artifact pointers ... never
payloads", so executors will not return files. Fix: amend it in T13's steps
and done-when.

**A21. Minor.** §9 (L932) maps I5 to R16, but R16 governs Project Space
records; I5 checks the code-repo branches, the PROTOCOL §12 repo rule, so it
is an undeclared quality check under R12.S2. Fix: point I5 at the D3
templates only; leave repo-wide hygiene to the standard close.

**Verdict.** Once A1 to A13 are fixed, the plan is fit to build from. Its
structure (traceability, test map, shared-file ordering and the critical
path) is sound.

## Round 1: planner

Plan revision 2 answers this round. Section and task ids below refer to it.
The operator settled question 1 (desk mode) and question 2 (the pod's agents
commit within G1's scope) during this round; question 4 (T9) is still open.

**A1. ACCEPT.** The test-writing brief (§2.4) now has `## Task` (the test
task's own entry, which R9 allows because it is not a build-task step),
`## Start from` and `## Suggestions`. I1 to I8 are defined inside T15 and
cite only §2. I6 no longer points at T11, and I5 no longer points at the
standard close. The §6 preamble says the test tasks depend on neither §4.1
nor §5, and the self-review checks that. T36 step 7 adds the test-agent
exception to this space's live `AGENTS.md`.

**A2. ACCEPT.** T15 now builds an isolated runner. Each agent under test is
a headless process whose fresh config holds only the deliverables: no
CLAUDE.md, git writes, sudo and web tools denied, a scratch cwd, fixtures
without `.git`, and every librarian commit step desk. T15's done-when adds a
smoke test: an empty instruction context, a subagent started (the R7.S2
depth), a cap kill at 30 s, and a desk command printed but not run. If
isolation or sign-in cannot be made to work, T15 is BLOCKED and goes to the
operator (question 6).

**A3. ACCEPT.** The claim is confirmed: `skills/mesh-post/mesh-post.sh:80`
dies with "not a git repo" before writing anything, and `die` exits 1
(`:37`). Unknown arguments also exit 1 (`:55`), so my "exit 2" was
inconsistent with the script, and §2.7 now pins exit 1 with
`mesh-post: invalid --project value: <value>`, checked inside the argument
loop. At base, I6 therefore fails with a different message (`unknown arg`).
T11's done-when and I6 run against a throwaway `git init` repo with no
remote and an explicit `--repo`, and must never omit `--repo`.

**A4. ACCEPT.** Every factual claim is confirmed:
- this node's identity file sets tip tracking and a 60 s poll;
- `skills/mesh-on/mesh-scan-loop.sh:63-65` runs `submodule update --init
  --remote --recursive` with no path;
- the bus `.gitmodules` sets no `update=`;
- `skills/mesh-on/poller-prompt.md:160` is `git -C «REPO» add -A`;
- the bus `.gitignore` does not exclude `agent-tmp/`;
- the stop flag is present.

New §4.1: mesh-on stays off on this node from the go to T36 (question 3, for
the operator); one worktree per code repo, outside the bus and every repo,
shared by that repo's parallel builders; paths only in dispatch prompts; the
operator allowlists the two worktrees at the go and removes them at T36. T0
now works in the swe-pod worktree and returns the bus checkout to a clean
`main`.

**A5. ACCEPT.** Confirmed: `spec.md:559` is `id: 20261102T1405-0003`. §2.7
now checks only real values (ids, hostnames and task ids that exist in the
bus registry, `tasks/`, `status/` and `_archive/`, the local hostname,
credential key names), so the spec's example ids pass. It defines a citation
as the front-matter reference fields plus qualified cross-space ids.
`REFUSED` and the ledger's `refused` line name only the check and the line
number. T10's done-when now uses this space's `spec.md`, `plan.md` and
`ledger.md` as clean records.

**A6. ACCEPT** with a different mechanism. New §2.8 is a recipe that builds
its patterns at run time from the registry, the node and `space.yaml`, rather
than a separate script. It scans only the added lines, prints `<file>:<line>
<kind>`, and allows generic `~/` paths. Reports record only
`shareability: <n> hits`. The standard close cites §2.8.

**A7. PARTIAL.** Accepted: the header now defines the base commit set (the
pins) separately from the swe-pod build base (T0's commit). The runner
exports deliverables by sha with `git archive`, never from a working copy,
and the test brief has `## Start from`. Not taken: the I5 fail-at-base
exemption. Under A21, I5 now checks the D3 templates, which are absent at
base, so it fails there for the stated reason.

**A8. ACCEPT.** T20's Context carries the three remote URLs and the commit
set of the latest green T19, allows read-only clone, fetch and archive into
a scratch directory outside the bus, and has the executor read the role
definition from the swe-pod commit. §2.3 now says the mesh Context holds "at
least" the two lines, and adds this case.

**A9. ACCEPT.** T1 now carries spec §4 (where things live, the `pod.yaml`
format, and the branch rules) as `## 1 Shape of a project`. §2.2 lists 15
headings, and I1 checks them. T1 now also serves R4 and R5. D1's text names
§§5 to 11, but §13 has D1 serve R22 and R23, whose rules live in §4. The
Requirements are untouched.

**A10. ACCEPT**, written for the settled question 2. §4.1 now covers:
- who commits: the lead makes the branches and T0, builders commit to the
  branch only, and the librarian commits space records;
- filing before M5: the §2.7 checks as written in the plan until T30 closes,
  then the skill text in the agent-mesh worktree;
- STATUS.md: first regenerated when T27 closes, with the ledger
  authoritative until then.

The human-commit path is gone from T0 and the standard close.

**A11. ACCEPT.**
- At base, T16 and T17 fail on the runner's precondition (deliverable
  absent) without starting an agent, so the at-base runs are not heavy.
- T19 is serial, per the budget policy on a laptop.
- The runner enforces each `cap_s`, at most 600 s.
- The heavy ask states 600 s per run, 240 min in total, and an expected 90
  to 150 min.

**A12. ACCEPT.** Confirmed: `mesh-scan-loop.sh:64` and `:67` both run
`submodule update --init ... --recursive` with no path, so every node
initializes `spaces/proj-swe-pod` from `.gitmodules`. T12 now changes the
scan loop (§2.7). Spaces are updated only once initialized, with `--remote
--merge`, and never initialized by the loop; `MESH_SCAN_LIST=1` lists the
paths for a done-when on a scratch `.gitmodules`. The librarian's push is now
`fetch`, `rebase origin/main`, `push origin HEAD:main`, which works when
detached.

**A13. PARTIAL.** Accepted: G1 to G3 are part of D5 and need an author and a
review, and with tip tracking the overlay must hold G1 before the agent-mesh
merge. T8 now writes them as a section of INSTALL.md, reviewed by T28, and
T36 step 4 applies them before any merge. Rebutted: "a build task applies
them to the overlay". The overlay is the operator's file (PROTOCOL §3.1 and
§4.4), and the brief's directive keeps that edit at integrate. Question 4 now
states the difference between keeping and dropping T9's exception.

**A14. ACCEPT.** In §4.1, a spec amendment is re-copied verbatim into
`SPEC.md` by the spec role and committed by the lead as a T0-style commit,
before the final T19 run, with T0's check (3) re-run. T36 step 2 only
confirms it. The I5 concern is moot under A21.

**A15. ACCEPT.** T3 lists all 11 manifest keys, and T3's done-when and I3
check them.

**A16. ACCEPT.** T8 may rewrite the README's one status line, and its
done-when checks only repo-relative paths.

**A17. ACCEPT.** The evidence gains `x-suggestions`. T19 runs
`test_R16_S1` last and keeps every run's scratch until it finishes, and the
test map row says so.

**A18. ACCEPT.** T20 done-when (3) records its dispatch ledger line and
Context lines as supplementary live observations for R7.S1, and for R17.S1
if the result came as a file, with no mesh task id in the space. The final
report names them, and the test map's R7.S1 row notes them.

**A19. ACCEPT.** §2.5 adds fixed phrases (the lead's refusal, the planner's
refusal, `Disputed test:`, the two poller phrases). The done-whens of T4,
T5, T6, T9, T12 and T13 now check exact strings, and leave every other rule
to "review checks", which §7 assigns to each reviewer.

**A20. PARTIAL.** Accepted for `skills/mesh-on/poller-prompt.md:263-264`:
T13 replaces "never payloads" with the fixed results phrase, for requested
files only. Rebutted for `guidance/agent-operating.md:155-156`: that line
sits under "Credentials: names only, ever" and governs the status file's
`artifacts` field, which still holds pointers under M3. T13 now says it is
unchanged.

**A21. ACCEPT.** I5 now checks only the D3 templates (placeholders only,
R16). Repo-wide hygiene stays in the builders' standard close, and §9 says
why it is not a check of this change.

Tally: 18 accepted, 3 partial (A7, A13, A20), 0 rebutted.

## Round 1: reviewer

Plan revision 2 (1320 lines), checked against each answer. Line numbers
refer to revision 2.

**A1. CLOSED.** The test brief has `## Task`, `## Start from` and
`## Suggestions` (L120-134). I1 to I8 are defined in T15 against §2 only
(L897-913). T36 step 7 adds the test-agent exception to the live `AGENTS.md`
(L1114-1115).

**A2. CLOSED** as a design: separate headless processes with a fresh config,
no guidance, desk librarian steps, and a smoke test with a BLOCKED exit
(L869-883, L914-920). The mechanism raises A22 and A24.

**A3. CLOSED.** Exit 1 with a fixed message, validated in the argument loop
(L252-256). T11 and I6 run against a throwaway `git init` repo passed as an
explicit `--repo` (L768-777, L906-909).

**A4. CLOSED** (L392-404, T0 L437-445). One consequence of pending question
3: if the operator keeps mesh-on, the deployed scan loop still moves the
space checkout to origin tip in checkout mode. A librarian commit made but
not yet pushed between two cycles then drops out of HEAD, and
`push origin HEAD:main` (L299-300) pushes nothing while `FILED` is printed.
Fix, needed either way: before printing `FILED`, the librarian confirms its
commit is an ancestor of `origin/main`.

**A5. OPEN.** The profile half is fixed (real values only, L281-288), and
spec.md, plan.md and the ledger are T10's clean records (L736-738). The
reference rule (L289-293) still refuses records this change files at T36:
- T36 step 7 sets `superseded_by` to a URL (L1117-1118). A URL neither
  resolves in the space nor names a space in `may_reference`, yet spec §8
  allows URLs.
- The memory-spaces note's body carries example qualified ids,
  `proj:fvm-vqls/note-...` (note L150 and L153), and T36 re-files the note.
- `discovered_in: build-swe-pod` names a change, not a record, and the
  change folder moves to `changes/archive/` at T36. "Resolve" is undefined
  for change and task ids.

Fix: accept URLs in reference fields; do not treat text inside inline code
or fenced blocks as a citation; define resolution for change ids, archived
ones included; add the memory-spaces note to T10's clean records.

**A6. CLOSED.** §2.8 builds its patterns at run time and prints only
`<file>:<line> <kind>`; the report records only the hit count (L303-317).
Its narrowed home-path rule is A23, and its scope on a shared branch is part
of A25.

**A7. CONCEDE** the I5 exemption. With I5 retargeted to the D3 templates
(A21), it fails at base because they are absent. The accepted parts close
the rest: the build base is separate from the base commit set (L8-12),
deliverables are exported by sha with `git archive` (L880-882), and the
brief has `## Start from` (L126-127).

**A8. OPEN**, one gap. The Context carries the URLs and "the commit set of
the latest green T19" (L1014-1018). The T20 brief is filed after T19 and
T35, so it is not in that space commit, and an executor that checks out the
space at the commit set finds no brief. Fix: the Context names the space
commit that holds the brief separately from the commit set under test.

**A9. CLOSED.** `## 1 Shape of a project` carries the `pod.yaml` format and
the branch rules (L74-80, L481-485, L494), and I1 checks the 15 headings.

**A10. CLOSED** for the settled question 2 (L405-417).

**A11. CLOSED.** At-base runs stop on the precondition without starting an
agent (L938-941). T19 is serial, with per-run caps and a heavy ask covering
more than 2 h (L984-991).

**A12. CLOSED.** The scan loop never initializes a space and can list its
paths for a testable done-when (L265-270, L806-810). The push sequence works
on a detached HEAD (L298-301).

**A13. CONCEDE.** There is nothing to hold. My fix meant a build task that
writes G1 to G3 as a shipped snippet, which the operator applies before the
merge. It did not ask a build task to edit the overlay. T8 (L684-687), T28
and T36 step 4 (L1097-1100) now do exactly that.

**A14. CLOSED** for R8 and §5.6 (L418-422, L1092-1093). The re-copy commit
breaks the standard close for any task still open; see A25.

**A15. CLOSED** (L526-530, L540-541).

**A16. CLOSED** (L676-680, L689-691).

**A17. CLOSED** (L156-157, L986-987, L1162).

**A18. CLOSED** (L1024-1027, L1149).

**A19. CLOSED.** The fixed phrases (L210-222) are checked exactly, and the
rest is named as review work (L467-469, L1038).

**A20. CONCEDE** for `guidance/agent-operating.md`. Its "never payloads"
sentence sits under "Credentials: names only, ever" and governs the status
file's `artifacts` field, which M3 leaves as pointers. The poller-prompt
change (L826-830) was the one that mattered.

**A21. CLOSED** (L904-905, L1175-1180).

### New findings

**A22. Important.** T15 runner (L869-883). The agents under test run
without the operator's guidance and without the git gate. The two fences
meant to replace them are weak:
- Settings deny rules match command prefixes. `git -C <dir> commit` or
  `push` gets past a `git commit` or `git push` deny, and that literal `-C`
  form is the one the mesh trains agents to use. `git checkout -b`, `branch`
  and `reset` are not denied at all.
- The run protocol no longer requires the scratch to be outside every repo.
  The old T15 did, and T10 and T11 still do (L737, L769). The operator's
  default place for scratch work is inside the bus. In a fixture copy with
  no `.git` under the bus, any git command acts on the live bus.

The permission mode of the headless runs is also unstated. Fix:
- The runner refuses to start unless `git rev-parse` fails in its cwd and in
  its config dir.
- The isolated settings install the product's git-gate hook with no
  allowlist, in place of the prefix denies. The hook is path-aware and fails
  closed, so it denies every gated op wherever it points.
- State the permission mode.
- Add to the smoke test a `git -C` commit attempt that must be denied.

**A23. Important.** §2.7 profile (L286-288) and §2.8 (L312). The home-path
check now covers only the macOS and Linux home roots. A registered node may
have its home and working directory under a site data root instead, and the
registered linux-server node is one. T20's evidence carries log pointers
(§2.4 L160), so a home path from that node would pass the space librarian:
an R16 breach in a shareable space. Spec §8 allows only space-relative paths
and URLs. Fix: add the local `$HOME` and every registered agent's
working-directory root from `agents/*.yaml` to the patterns, and have T20's
brief require log pointers to be space-relative or omitted.

**A24. Minor.** T15 (L871-874) and question 6 (L1271-1274). A fresh config
dir per run is likely unauthenticated on this node. Sign-in goes through
managed gateway settings plus provider entries in the operator's settings
`env`, and the isolated config omits those entries. T15 would then BLOCK at
the go and hold the whole test chain. Fix: the operator signs in one
isolated base config at the go. The runner copies it for each run, replacing
only agents, skills and settings, and passes the provider entries at run
time without storing them in the space.

**A25. Minor.** Shared worktree and shared branch (§4.1 L397-408, standard
close L460-462, §2.8 L314-315, §4.1 L418-422):
- Parallel builders committing from one worktree can sweep another
  builder's staged files into the wrong `Task:` trailer, and they contend
  on the index lock.
- "Rebasing before each push" fails on the shared dirty tree, and with one
  local branch there is nothing to rebase onto.
- The scan's `git diff <base>` and the review's "diff from base to head"
  both include other tasks' commits.
- After a SPEC.md re-copy (A14), `git diff <T0 commit> -- SPEC.md` is
  non-empty for every task still open.

Fix: builders commit with a pathspec (`git commit -- <touches>`); the lead
serializes commits and pushes; drop the rebase inside the shared worktree;
take each task's diff from its own trailer-marked commits; compare SPEC.md
against the latest `Task: T0` commit.

**A26. Minor.** Proportion. At 1320 lines the plan is still shorter than the
deliverables it describes. PROCESS.md alone restates about 600 spec lines,
before the six role definitions, ten templates, the skill and the
agent-mesh edits, so spec §5.2's test is not failed. Most of the growth is
contract the tests need (§2.5, §2.7, §2.8 and the T15 runner). About 60 to
80 lines are repetition:
- The question 1 decision is restated in §2.5, §3, §9, question 1 and T36
  step 3.
- The question 2 decision appears in §3, §4.1, question 2 and question 19.
- The note that SPEC.md is an input appears in the header, §1, §2.1, the
  file map, T0, question 5 and the self-review.

The plan has already drifted once (exit 2 against exit 1), and copies are
how that recurs. Fix: state each decision once, in §3, and cite it
elsewhere.

**Round 1 verdict.** Closed 16, open 2 (A5, A8), conceded 3 (A7, A13, A20),
held 0, new 5 (A22 to A26, of which A22 and A23 are Important). The plan is
fit to build from once A5, A8, A22 and A23 are fixed. A24 to A26 can be
fixed in passing.

## Round 2: planner

Plan revision 3 (1285 lines, down from 1320) answers this round. The operator
decisions taken since round 1 (questions 3 and 4) are now §3 OD3 and OD4,
alongside OD1, OD2 and the SPEC.md directive OD5.

**A4 consequence (reviewer note). ACCEPT**, kept by operator order even with
the poller off (OD3). §2.7: after the push, the librarian fetches and prints
`FILED` only once `merge-base --is-ancestor` confirms the commit is in
`origin/main`. T10 done-when (3) shows the sequence as desk output.

**A5. ACCEPT.** §2.7's reference check is now defined as follows:
- a citation is a value in a front-matter reference field, or a qualified
  cross-space id in body text outside inline code and fenced blocks;
- URLs are accepted, so T36's `superseded_by` URL passes;
- a change id resolves to `changes/<id>/` or
  `changes/archive/<date>-<id>/`, so `discovered_in: build-swe-pod` still
  resolves after archiving;
- `<change>/T<n>` resolves to a task in that change's plan.

The note's example ids at its lines 150 and 153 sit in inline code, so they
are not citations. T10's clean records now include both space notes
(memory-spaces, and the deferral note `note-20261027T2242Z-0786`).

**A8. ACCEPT.** §2.3 and T20 now give, as separate lines, the space commit
that holds the T20 brief and the commit set under test (the latest green
T19's). Read-only git stays in T20's brief and Context, not in the product,
as the operator directed.

**A22. ACCEPT.** Both factual claims hold:
- PROTOCOL §4.5 says permission rules "match the literal command string",
  so a `git commit` deny misses `git -C <dir> commit`;
- `hooks/git-gate.py:403-407` denies every gated op when no allowlist is
  configured, and `:75-80` resolves the allowlist from the active config
  directory.

T15's runner now:
- installs the product's git gate with no allowlist, in place of the
  prefix denies;
- adds denies for `git -C`, `git branch`, `git checkout` and `git reset`,
  which the gate does not cover;
- states the permission mode: it never prompts, denies any tool not allowed,
  and never bypasses;
- refuses to start unless `git rev-parse` fails in both its cwd and its
  config directory;
- adds a denied `git -C <scratch> commit` attempt to the smoke test.

**A23. ACCEPT.** Confirmed from the registry: the linux-server node's `cwd`
sits under a site data root, not a standard home root. The §2.7 profile
patterns, which §2.8 now reuses rather than repeats, add the local `$HOME`,
each registered agent's `cwd`, and the first two path components of each
`cwd`. §2.4 now says that evidence log pointers must be space-relative or
URLs, and T20's brief requires them to be space-relative or left out. T10's
refusal cases add a `$HOME` record and a registered-`cwd` record.

**A24. ACCEPT.** Confirmed: sign-in on this node relies on managed settings
and provider entries in the operator's settings `env`, which a fresh config
directory would lack. T15: the operator signs in one isolated base config at
the go, and each run gets a copy with only agents, skills and settings
replaced. The provider environment is inherited from the session that starts
the runner and is never written into the space. Question 1 notes the sign-in
step.

**A25. PARTIAL.** Accepted: §4.1 now covers:
- staging and committing by pathspec (`git add -- <touches>`, then
  `git commit -- <touches>`);
- retries on the index lock or a rejected push, three at most, never
  staging another task's files;
- the spec §5.3 rebase as a no-op on one local branch, with
  `git pull --rebase` only on a rejected push;
- per-task diffs found by the `Task: T<n>` trailer, for both the reviewer
  (§7) and the shareability check (§2.8, `git diff <task base> -- <task
  touches>`).

The standard close now compares `SPEC.md` against the latest `Task: T0`
commit. Rebutted in part, with the reason: "the lead serializes commits and
pushes". OD2 says build agents commit and push. Pathspec commits plus
bounded retries remove the cross-attribution and lock risks without moving
the commit to the lead.

**A26. ACCEPT.** OD1 to OD5 are each stated once, in §3. §1, §2.1, §2.5,
§4.1, T0, T9, T36, §9, the self-review and the questions now cite them by
id. The questions list dropped the five settled items and the duplicate
branch question (20 to 15). §2.8 cites §2.7's patterns instead of repeating
them. OD4 removed T9's exception, its fixed phrase, its file-map entries and
its question, and cites `note-20261027T2242Z-0786`. T9 now touches only the
identity template and the operator manual, and serves R7 only; R13 is still
served by T1, T5 and T8. The plan is 35 lines shorter.

Tally for this round: 6 accepted (A5, A8, A22, A23, A24, A26), 1 partial
(A25: the defects are fixed, and the lead-serialized commit is rebutted
under OD2), 0 rebutted.

## Round 2: reviewer

Plan revision 3 (1285 lines), checked against each answer. Line numbers
refer to revision 3.

**A4 note. CLOSED.** `FILED` is printed only after a fresh fetch shows the
commit is an ancestor of `origin/main` (L286-290), and T10 shows the
sequence as desk output (L726-727).

**A5. CLOSED.** The rule now reads (L273-281):
- a citation is a front-matter reference value, or a qualified id outside
  inline code and fenced blocks;
- URLs pass;
- a change id resolves live or archived;
- `<change>/T<n>` resolves to a task in that change's plan.

This covers T36's `superseded_by` URL (L1116-1117), the note's example ids,
and `discovered_in: build-swe-pod`. Both notes are among T10's clean records
(L716-718).

**A8. CLOSED.** The space commit that holds the brief and the commit set
under test are separate Context lines (L85-87, L1005-1012).

**A22. CLOSED.** T15 now has all five parts of the fix (L859-867, L911-913):
- the product's git gate, installed with no allowlist (confirmed at
  `hooks/git-gate.py:402-407`: no allowlist means deny);
- added denies for `git -C`, `branch`, `checkout` and `reset`;
- a stated permission mode, with no bypass;
- a `git rev-parse` precondition on both the cwd and the config dir;
- a denied `git -C` commit in the smoke test.

The allow list is still unstated; see A28.

**A23. CLOSED.** The home-path patterns now take in the local `$HOME`, each
registered agent's `cwd`, and that `cwd`'s first two components (L261-272).
§2.4 limits log pointers to space-relative paths or URLs (L142-144), T20
requires the same (L1015-1016), and T10 has refusal cases for both
(L721-722).

**A24. CLOSED** as a fix: one signed-in base config, copied per run, with
the provider environment inherited (L853-858, question 1). Whether a copy
keeps the sign-in is A27.

**A25. CONCEDE** the serialization. The defect was cross-attribution and
lock contention, and serialization was only my means of fixing it.
Pathspec staging and commit, bounded retries, and per-task diffs found by
trailer remove both defects under OD2 (L400-409, L460-463).

**A26. CLOSED.** Each operator decision is stated once, in §3 (L329-357),
and cited by id elsewhere. The questions dropped from 20 to 15.

### OD consolidation and OD4

The rules from revision 2 all survive. The old §4.1 git-gate step became
"has allowlisted" (L395-396), and its removal is still in T36 step 6. The
desk rule is §3 OD1, and the SPEC.md-under-R4 rule is §3 OD5. The rest of
old §4.1 is unchanged, and the old questions 3, 4, 5, 16, 19 and 20 are
covered by §3 or the new questions. The one wording gap is A31(b).

Nothing in this change depends on the removed executor exception:
- every build task runs local;
- T20 only reads, apart from A29;
- R7.S1, R23.S1 and R23.S2 are desk tests;
- I7 checks registration only;
- R13 is still served, through T1, T5 and T8.

The consequences that remain are A30.

### New findings

**A27. Minor.** T15 config (L853-858). The stored sign-in may be keyed to
the config directory's path. If so, each copy at a new path starts signed
out, and the smoke test BLOCKs at the go. Fix: keep one base config at a
fixed path and reset it in place between runs. Replace the agents, skills
and settings, and clear the per-project memory and session state. T19's
serial order makes this safe.

**A28. Minor.** T15 permission mode (L863-864). "Denies any tool not
allowed" names no allow list. If Bash or Agent is left out, agent-mode
tests fail only at T19, after the heavy ask. With Bash denied outright, the
smoke test's "`git -C` commit is denied" check (L911-913) also passes
vacuously. Fix: allow the union of the §2.3 role tools plus Skill, and add
a permitted Bash command that must succeed to the smoke test.

**A29. Minor**; it dates from revision 2. T20's brief grants only read-only
git (clone, fetch, archive) (L1010-1011). I6, which T20 must pass
(L1015, L1022), needs `git init` of a throwaway repo and mesh-post's
dry-run staging into it (L896-898). A careful executor will decline I6, or
run it outside its stated permission. Fix: the brief also permits `git init`
and staging inside that throwaway repo, and nothing else.

**A30. Minor.** Consequences of OD4:
- T9 no longer adds the agent-operating sentence telling a `swe.*`
  executor to read the role definition named in its Context. The
  `Role definition:` line (L82-84) is now only a label. Fix: PROCESS.md §11
  (T1) and swe-lead (T5) make it an instruction in the task.request.
- The deliverables describe build tasks as local or remote, while a mesh
  executor still may not commit. Fix: PROCESS.md §11 and swe-lead say build
  tasks run local until the deferred exception lands, and T36's final
  report lists R7 for mesh builds as an open item. That way T35's
  completeness check (L1070) meets a known, recorded gap instead of a new
  finding.

**A31. Minor.** Wording:
- (a) §2.8 defines the scan as `git diff <task base> -- <task touches>`
  (L296-297), a path-limited range of the shared branch. §4.1 says the
  shareability check uses the task's own trailer commits, "never a range of
  the shared branch" (L407-409). Fix: keep the trailer form in both places.
- (b) The test brief copies "Global constraints" (L108-109), yet §6 relies
  on §3's OD1 (L837-839, L1233). Fix: say the brief copies all of §3,
  operator decisions included.

**Round 2 verdict.** Closed 6 (A5, A8, A22, A23, A24, A26; the A4 note is
also closed), open 0, conceded 1 (A25), held 0, new 5 (A27 to A31, all
Minor). No Critical or Important finding remains open.

## Round 3: planner

Plan revision 3.1 (1283 lines, down from 1285). T0 and the §4.1 checkout and
commit rules are untouched, since the go is in effect.

**A27. ACCEPT.** T15 Config: one signed-in isolated config at a fixed path,
given only in the dispatch prompt. Before each serial run the runner resets
it in place: it replaces the agents, skills and settings, and clears
per-project memory and session state. Per-run copies are dropped.

**A28. ACCEPT.** T15 Permission mode now allows exactly the union of the
§2.3 role tools plus Skill (Read, Grep, Glob, Bash, Write, Edit, Agent,
Skill), minus the stated denies, and denies the rest. Smoke-test item 4 adds
a permitted Bash command (`ls`) that must succeed, so the `git -C` denial
cannot pass vacuously.

**A29. ACCEPT.** T20's brief also permits, for I6 only, `git init` of one
throwaway repo in its scratch directory and staging into it, and nothing
else. These permissions stay in the brief, not the product.

**A30. ACCEPT.**
- T1's §11 now states that a mesh executor reads the role definition its
  task.request names before anything else.
- T1's §11 also states that build tasks run local until the deferred
  exception lands (§3 OD4). T5 says the same, and has the Goal of every
  mesh task.request tell the executor to read its role definition first.
  §2.3 states the Goal rule as well.
- T36 step 3 has the final report record, under open questions, that R7
  holds only for local builds until then, so T35 meets a recorded gap.

**A31. ACCEPT.**
- (a) §2.8 now uses §4.1's definition: the task's diff is its own commits,
  found by the `Task: T<n>` trailer, plus its staged changes before the first
  commit. The path-limited range of the shared branch is gone.
- (b) §2.4's test-writing brief copies all of §3, operator decisions
  included, as `## Global constraints`.

Length kept down: the §9 inspection table became one paragraph; the
questions list dropped six items now fixed in §2 or in their tasks, naming
them in one sentence; two self-review items were merged.

Tally: 5 accepted (A27 to A31), 0 partial, 0 rebutted.

## Planner note: OD6 (T19 and T20 merged)

This follows the operator directive in the ledger: verify is one mesh task,
T19, run by a remote `swe.test` agent on a linux-server node, and T20 is
merged into it. Plan changes:
- §1 and §2.3;
- §3, where OD1 now has 7 desk-verified scenarios, plus new OD6;
- the file map;
- T15 Config, with one signed-in config per runner node, and outputs with
  `<scratch>` paths;
- T19, rewritten: dispatch, brief permissions, full suite with up to 4
  parallel runs and at most half the node's cores, the heavy ask, return as
  result files, `env: linux-server`;
- T20, removed;
- T35, T36, §9, §10 and the questions intro.

The longest chain is now 13 tasks, and the plan has 36.

One judgment call. The remote tester can judge R7.S1 live from its own
task.request and the dispatch line in the space commit it was given. It
cannot see the filing of its own returned files, which is the THEN of
R17.S1. That live check therefore goes to T35, which confirms the filings
against test_R17_S1's Then items. The final report cites both.
