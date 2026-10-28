# T15 report: runner, fixtures and inspection checks

## Status

DONE_WITH_CONCERNS

## What I did

- Wrote the isolated runner, `runner.sh`, with its protocol in `README.md`.
  Each agent under test is a separate headless Claude Code process. Before
  every run the runner resets the one signed-in config in place: it rewrites
  the agents, skills, settings and hooks, and clears per-project memory and
  session state. It installs the product's `hooks/git-gate.py` (exported from
  agent-mesh `8ee5364`) with no allowlist. It denies `git -C`, `git branch`,
  `git checkout`, `git reset`, sudo, WebFetch and WebSearch. It runs in
  `dontAsk` mode with bypass disabled, allowing exactly Read, Grep, Glob,
  Bash, Write, Edit, Agent and Skill. It excludes every `CLAUDE.md`,
  `CLAUDE.local.md`, `AGENTS.md` and rules file, loads no MCP server, and
  refuses to start where `git rev-parse` succeeds. It applies desk preambles
  and desk denies, stops runs at their caps, and exports deliverables
  read-only by sha. It holds no machine path; every path is an argument.
- Wrote the fixtures: `demo-space/` (`proj:demo`: repos alpha, beta and
  gamma, `depends: {beta: [alpha]}`, one approved change `add-greeting`
  naming alpha and beta only, and one note), `demo-bus/agents/` (two
  invented nodes, a macos-laptop and a linux-server, with `swe.test` on the
  linux-server), and the overlay of I8 (one clean record).
- Wrote the eight inspection checks, I1 to I8. Each test carries its own
  executable check, and I8 also has a setup. Negative content is built at run
  time from split literals or read from the run's fixture copy.
- Ran the smoke test (six serial runs, each capped at 30 s). Ran every
  I-test at the base commit set. Dry-checked the I8 scripts red and green on
  synthetic agent output, with no agent run. Ran a shareability scan of every
  file I wrote, using real values read at run time: 0 hits.

## Files

- `changes/build-swe-pod/tests/README.md`
- `changes/build-swe-pod/tests/runner.sh`
- `changes/build-swe-pod/tests/fixtures/demo-space/space.yaml`
- `changes/build-swe-pod/tests/fixtures/demo-space/pod.yaml`
- `changes/build-swe-pod/tests/fixtures/demo-space/README.md`
- `changes/build-swe-pod/tests/fixtures/demo-space/changes/add-greeting/spec.md`
- `changes/build-swe-pod/tests/fixtures/demo-space/notes/note-20261101T1100Z-a0b1-demo-context.md`
- `changes/build-swe-pod/tests/fixtures/demo-space/{tests,decisions,handoffs,lore}/.gitkeep`
- `changes/build-swe-pod/tests/fixtures/demo-bus/agents/demo-mac-01.yaml`
- `changes/build-swe-pod/tests/fixtures/demo-bus/agents/demo-linux-01.yaml`
- `changes/build-swe-pod/tests/fixtures/overlays/test_I8_space_librarian_checks/notes/note-20261101T1200Z-c1e4-clean-record.md`
- `changes/build-swe-pod/tests/test_I1_process_md.md`
- `changes/build-swe-pod/tests/test_I2_role_definitions.md`
- `changes/build-swe-pod/tests/test_I3_d3_templates.md`
- `changes/build-swe-pod/tests/test_I4_swe_pod_skill.md`
- `changes/build-swe-pod/tests/test_I5_templates_placeholders_only.md`
- `changes/build-swe-pod/tests/test_I6_mesh_post_project_flag.md`
- `changes/build-swe-pod/tests/test_I7_agent_mesh_documents.md`
- `changes/build-swe-pod/tests/test_I8_space_librarian_checks.md`
- this report, `changes/build-swe-pod/tasks/T15-report.md`

All are in the space working tree and unfiled, for the lead to file.

## Test output

**Smoke test**, 2026-10-27T23:58Z, Claude Code 2.1.312, git gate from
agent-mesh `8ee5364`. The output is copied verbatim, except that the config
path is shown as `<config>` and the managed drop-in by its kind:

```
SMOKE S1-instruction-files pass (answer 'NONE'; elapsed 2.8 s, cap 30 s)
SMOKE S1 context: tools=Task,Bash,Edit,Glob,Grep,Read,Skill,Write mcp_servers=0 agents=claude,Explore,general-purpose,Plan,statusline-setup plugins=cc-plugin-sec-default,cc-plugin-agents-md,cc-plugin-plugin-authoring permissionMode=dontAsk
SMOKE S1 bundled skills present: 16
MANAGED POLICY present, for the lead's ruling: <macOS system managed-settings.d drop-in, gateway login policy> (settings drop-in)
MANAGED POLICY present, for the lead's ruling: <config>/remote-settings.json (remote managed settings)
SMOKE S2-subagent pass (spawned 1, completed 1, max_depth 1, nonce returned True; elapsed 4.7 s, cap 30 s)
SMOKE S3-cap pass (recorded not-run (cap 30 s); elapsed 30.4 s, cap 30 s)
SMOKE S4-desk pass (retried once after API retries with no turn; git command printed True, git attempts 0 (all denied True), .git created False; elapsed 7.8 s, cap 30 s)
SMOKE S5-ls pass (ls calls 1, succeeded True; elapsed 5.5 s, cap 30 s)
SMOKE S6-git-C-commit pass (denials 1; tool result 'PreToolUse:Bash hook error: git commit is gated: no mesh-git allowlist configured (<config>/...)'; elapsed 7.7 s, cap 30 s)
```

- Done-when 2: S1 pass. Probe `CLAUDE.md`, `CLAUDE.local.md` and
  `AGENTS.md` files were in the cwd, and an instruction file sits in a folder
  above the scratch root. The agent answered `NONE`. No managed instruction
  file exists. Two managed settings sources exist and go to the lead for a
  ruling (Concerns, item 1).
- Done-when 3: S2 pass. The agent under test started a general-purpose
  subagent at depth 1, which returned the word made at run time.
- Done-when 4: S3 pass (stopped at the 30 s cap, recorded
  `not-run (cap 30 s)`, no stray process left). S4 pass (the desk run printed
  `DESK: git init`, `git add pod.yaml` and `git commit`, ran no git command,
  and made no `.git`). S5 pass (`ls` ran and listed the fixture). S6 pass
  (`git -C <scratch> commit` was denied by the git gate and appears in the
  permission denials).
- Earlier smoke runs, 2026-10-27T23:44Z and 23:56Z: the first passed all six.
  In the second, S4 got only provider API retries until the cap. That is why
  the runner now retries once on that stall (Concerns, item 6).

**At base**, 2026-10-27T23:55Z, at the base commit set (space `c814837`,
swe-pod `8fc5294`, agent-mesh `8ee5364`). Each test fails because its
deliverable is absent. For I6 the cause is that `--project` is an unknown
argument.

```
RESULT test_I1_process_md fail (check I1.1: PROCESS.md absent at swe-pod 8fc5294)
RESULT test_I2_role_definitions fail (check I2.1: swe-pod 8fc5294: absent: agents/swe-spec.md, agents/swe-plan.md, agents/swe-lead.md, agents/swe-build.md, agents/swe-test.md, agents/swe-review.md)
RESULT test_I3_d3_templates fail (check I3.1: swe-pod 8fc5294 templates/space: absent: templates/space/space.yaml, templates/space/pod.yaml, templates/space/AGENTS.md, templates/space/README.md)
RESULT test_I4_swe_pod_skill fail (check I4.1: swe-pod 8fc5294: absent: skills/swe-pod/SKILL.md, skills/swe-pod/status-format.md)
RESULT test_I5_templates_placeholders_only fail (check I5.1: swe-pod 8fc5294: templates/space or templates/records absent)
RESULT test_I6_mesh_post_project_flag fail (check I6.1: proj:demo: exit 1, mesh-post: unknown arg: --project)
RESULT test_I7_agent_mesh_documents fail (check I7.1: agent-mesh 8ee5364: PROTOCOL section 5 does not document the project field)
RESULT test_I8_space_librarian_checks fail (deliverable absent: agent-mesh 8ee5364 skills/space-librarian)
```

At base, I7's other checks also fail: `files:` list, `-files/` folder,
1048576-byte limit and the §9 sweep missing; no spaces rows; 0 of 6 roles;
neither skill; list mode not documented. I6.5 (no flag, no line) passes at
base, as it should. Proposed ledger line:

```
T15 at base: test_I1_process_md fail (PROCESS.md absent), test_I2_role_definitions fail (agents/ absent), test_I3_d3_templates fail (templates/ absent), test_I4_swe_pod_skill fail (skills/swe-pod/ absent), test_I5_templates_placeholders_only fail (templates/ absent), test_I6_mesh_post_project_flag fail (--project is an unknown argument), test_I7_agent_mesh_documents fail (project field, files list, spaces rows, roles, both skills and list mode absent), test_I8_space_librarian_checks fail (skills/space-librarian/ absent)
```

**I8 scripts, red and green**, with synthetic agent output and no agent
run. The setup built 11 records, each with its fault on the expected line.
Correct output gave 7 of 7 pass. Output with a wrong line, a wrong kind, a
leaked value, a forced push and a missing fetch, rebase and push failed
I8.2, I8.3, I8.5 and I8.6.

**For information only, not evidence:** an inspect run at the change heads
then current (swe-pod `8770c1a`, agent-mesh `7430aeb`). I1, I2 and I6 passed,
which shows those checks can pass on a conforming deliverable. I3, I4 and I5
failed with their deliverables absent. I7 was run there before its last
edit, so that result does not count.

## Concerns

1. **Managed policy: accepted by the lead's ruling.** The managed settings
   add no instruction file, loosen no fence, and apply alike to every agent
   on this node, so they do not confound the tests. Two managed settings
   sources apply to the isolated config, and the runner cannot remove them. One is a system
   managed-settings drop-in, which forces gateway login and sets the
   provider environment. The other is remote managed settings in the
   config, delivered by the gateway: they set the default model, deny
   WebSearch, allow only managed MCP servers, disable side-load flags and
   carry an announcement. S1 shows that neither adds an instruction file, and
   `--strict-mcp-config` leaves 0 MCP servers.
2. **The 11 `space.yaml` keys: resolved by the lead's ruling.** On the
   lead's ruling I read the space manifest in
   `notes/note-20261027T2142Z-0a31-memory-spaces-design.md` §3.1. I3.13 now
   checks its 11 keys by name: `space`, `id`, `kind`, `title`, `visibility`,
   `owners`, `writer_model`, `categories`, `header_profile`, `may_reference`
   and `retention`. It also checks `kind: project` and
   `header_profile: shareable`, and that no other top-level key is present.
   The fixture's `space.yaml` now carries all 11, with invented placeholder
   values. Re-run at base, 2026-10-28T00:04Z: I3 still fails
   `(check I3.1: swe-pod 8fc5294 templates/space: absent: ...)`, and I3.13
   reports `space.yaml: absent`.
3. **Fixture conventions inferred.** The demo registrations carry their
   environment class in `context:`, which base PROTOCOL §7 calls the coarse
   environment class. If the change adds a separate field, the fixture needs
   it too.
4. **No instruction file reaches the agent, not even `AGENTS.md`.** The
   exclusions cover every `CLAUDE.md`, `CLAUDE.local.md`, `AGENTS.md` and
   rules file. An agent sees a space's `AGENTS.md` only when it reads the
   file with a tool. Authors of scenario tests (T16, T17) should know this,
   for example for R18.S1. The product's 16 bundled skills, its built-in
   agent types and its three built-in plugins remain loaded. They are part of
   Claude Code, not guidance.
5. **I8 is heavy, and lacks one case.** I8 runs one agent, expected 240 s
   with a 600 s cap, so the lead must ask the operator before its run at the
   commit set under test. The command is `runner.sh run
   test_I8_space_librarian_checks.md ... --allow-heavy`. I8 has no negative
   case for a credential key name: those come from the node's credentials
   file, and the test does not write to the node's home. I5 covers credential
   names for the templates, using the bus registrations.
6. **Provider stalls.** In two of three smoke runs, the run right after a
   capped run got only provider API retries, with no agent turn. The runner
   now retries such a run once and records the retry, and S4 then passed. If
   it keeps happening, a short pause after each capped run may help.
7. **Inputs the runner needs.** The runner needs Python 3.9 or later
   (`--python`), and `/usr/bin/python3` for the git gate. I5 needs `--bus`
   and `--space`, from which it reads real values at run time; it fails
   rather than pass when they are missing.

## Test suggestions

None.
