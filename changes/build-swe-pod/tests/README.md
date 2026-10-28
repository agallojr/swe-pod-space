# Project-level tests of build-swe-pod

The tests of this change, the runner that runs them, and the fixtures they run
on. They stay in this folder until integrate moves them into `tests/`.

| Path | What it is |
|---|---|
| `runner.sh` | The isolated runner. One file; it holds no machine path. |
| `fixtures/demo-space/` | The demo Project Space, `proj:demo`. |
| `fixtures/demo-bus/` | A demo mesh bus: two registered nodes. |
| `fixtures/overlays/<test name>/` | Files a test lays over the demo space. |
| `test_I<n>_<slug>.md` | Inspection checks I1 to I8. |
| `test_R<n>_S<m>_<slug>.md` | Scenario tests (written by other test tasks). |

## Running

Every machine path is an argument. In the commands below, `<config>` is the
isolated Claude Code config the operator signed in, `<scratch>` a scratch
root outside every repo, `<py>` a Python 3.9 or later interpreter, and the
checkouts are local clones used only for `git archive` exports by sha.

```
runner.sh smoke --python <py> --config <config> --scratch <scratch> \
  --gate <agent-mesh checkout>@<sha> [--bus <bus checkout>]

runner.sh reset --python <py> --config <config> --scratch <scratch> \
  --gate <agent-mesh checkout>@<sha>

runner.sh run <test file>... --python <py> --scratch <scratch> \
  --config <config> --gate <agent-mesh checkout>@<sha> \
  --repo swe-pod=<swe-pod checkout>@<rev> \
  --repo agent-mesh=<agent-mesh checkout>@<rev> \
  [--bus <bus checkout>] [--space <Project Space checkout>] \
  [--env <environment class>] [--model <model>] [--allow-heavy]
```

- `--repo <name>=<checkout>@<rev>` names where a test's deliverables come
  from. `<rev>` may be a branch; the runner resolves it to a sha and records
  the sha7 in the run's `meta.json`, so the commit set of every run is known.
- `--gate` names the agent-mesh sha whose `hooks/git-gate.py` is installed.
- `--bus` and `--space` are read-only sources of real values for checks that
  look for them (I5), and `--bus` also gives the agent working directories
  the redaction rewrites. Nothing read from them is printed or written.
- `--env` is this node's environment class. A test whose `env` is not `any`
  runs only where `--env` matches it.
- `--allow-heavy` lets tests marked `heavy: true` run. Give it only after the
  operator has said yes to the command, its caps and its expected time.
- `--keep-setting <key>` (repeatable) names a further settings key the reset
  must carry over; see Config below. The runner's own keys (`permissions`,
  `hooks`, `claudeMdExcludes`) cannot be kept.
- `reset` only resets the config, the same way as before a run, and prints
  the settings keys it kept and the sign-in files it left alone.

Runs are serial. Each prints one line, and appends it to
`<scratch>/results.log` with its UTC time:

```
RESULT <test name> pass (all <k> checks pass)
RESULT <test name> fail (check <In.k>: <reason>)
RESULT <test name> fail (deliverable absent: <repo> <sha7> <path>)
RESULT <test name> not-run (cap <n> s)
RESULT <test name> not-run (heavy: needs the operator's go and --allow-heavy)
BLOCKED <reason>
```

`BLOCKED` means sign-in or isolation failed and nothing ran; report it to the
operator. Exit status: 0 when every test passed, 1 otherwise, 3 when blocked.

Each run leaves `<scratch>/runs/<UTC>-<test name>-<4 hex>/` with `meta.json`
(commit set, absent deliverables), `export/` (the deliverables, read-only),
the space copy, and per agent step `prompt-<k>.txt`, `stream-<k>.jsonl`,
`summary-<k>.json`, `final-<k>.txt` and `stderr-<k>.txt`, then `check.out`.
Run dirs stay on the node; evidence points at them by test name only. The
export is made read-only, so clear a run dir with `chmod -R u+w` first.

**Kept output is redacted.** After a test's checks have run (and after each
smoke case is judged), the runner rewrites every file at the top of the run
dir (prompts, streams, summaries, final texts, stderr, `meta.json`,
`setup.out`, `check.out` and any file a setup wrote there), as well as
`results.log`, `smoke.txt` and every line it prints. Machine paths become
placeholders, longest first: the scratch root becomes `<scratch>`, the
config dir `<config>`, each registered agent's `cwd` read from `--bus` at
run time `<agent-cwd>`, and `$HOME` `<home>`. Any other per-user path under
a macOS or Linux home root becomes `<user-home>`, and this node's hostname
`<host>`. The working copies in the run dir (`space/`, `bus/`, `export/`,
`repos/`) are not rewritten; they are inputs, not logs. Give `--bus` to
smoke and test runs so agent working directories are covered.

## Isolation protocol

Each agent under test is a separate headless Claude Code process
(`claude -p`, stream-json output, no session persistence).

**Config.** At the go, the operator signs in one isolated config at a fixed
path, given only in the dispatch prompt. The runner refuses to use a config
that has no sign-in file (`.claude.json` or `.credentials.json`) or that is
the user's own. Before every run it resets that config in place:

- it rewrites `settings.json` (atomically, keeping its file mode) with the
  runner's settings below, plus the keys it carries over;
- it deletes and rewrites `agents/`, `skills/` and `hooks/`;
- it deletes any `CLAUDE.md`, `CLAUDE.local.md`, `rules/`, `commands/`,
  `output-styles/`, `settings.local.json` and `mesh-git-allowlist.txt`;
- it clears per-project memory and session state: `projects/`, `todos/`,
  `shell-snapshots/`, `session-env/`, `file-history/`, `plans/`,
  `paste-cache/`, `debug/` and `history.jsonl`.

It deletes only the names listed. Everything else in the config is kept,
in particular the stored sign-in (`.claude.json`, `.credentials.json`,
`sessions/`), the plugin marketplace cache, and any managed settings the
provider delivers. Per-project entries in `.claude.json` are keyed by working
directory, and every run has a new one, so none carries over. The agents and
skills installed are the test's `deliverables:` and nothing else.

The provider reaches the agent in one of two ways, and the runner handles
both without an option:

- **From the environment** (as on a macOS node with a system managed
  gateway policy): the provider environment is inherited from the session
  that starts the runner. The config's `settings.json` holds no sign-in key,
  so nothing is carried over.
- **From a gateway sign-in stored in the config** (as on a linux-server node):
  the config's `settings.json` holds `forceLoginMethod` and
  `forceLoginGatewayUrl`, and the sign-in is stored in the config dir. The
  reset detects the two keys and carries them, unchanged, into every new
  `settings.json`; it never reads out or prints their values. The stored
  sign-in files are not touched. `--keep-setting` adds keys if a node needs
  more.

Either way the runner drops only the variables that tie a child to the
starting session or to a mesh identity (`CLAUDECODE`,
`CLAUDE_CODE_SESSION_ID`, the messaging socket and token, `REPO_PATH`,
`AGENT_ID`, `MESH_*` and the like), and writes no provider setting of its
own.

**No guidance.** There is no CLAUDE.md or other guidance. `claudeMdExcludes`
excludes every `CLAUDE.md`, `CLAUDE.local.md`, `AGENTS.md` and
`.claude/rules/` file, in the run's folder and in every folder above it, so a
space's `AGENTS.md` reaches the agent only when it reads it with a tool. The
product's bundled skills and built-in agent types remain; they are part of
Claude Code, not guidance.

**Settings.** The product's `hooks/git-gate.py` is installed as the only
PreToolUse hook on Bash, with no allowlist, so it denies every git add,
commit and push wherever it points. The deny list adds `git -C`,
`git branch`, `git checkout`, `git reset`, `sudo`, WebFetch and WebSearch.

**Permission mode.** `dontAsk`, set in the settings and on the command line,
with bypass mode disabled. It never prompts and is not a bypass mode. It
allows exactly the union of the role tools of contract §2.3 plus Skill
(Read, Grep, Glob, Bash, Write, Edit, Agent, Skill), minus the denies above,
and denies everything else. `--tools` limits the built-in tools to those
eight and `--strict-mcp-config` loads no MCP server.

**Where it runs.** The cwd is a scratch copy of the fixture, in a new run dir.
The runner refuses to start unless `git rev-parse` fails in the scratch root,
the run dir, the cwd and the config dir. Fixtures have no `.git`.

**Code repos.** A scenario test that needs code repos builds them at run
time, in its setup script, under `<run>/repos/` (the `REPOS` variable). When
that directory exists after setup, the runner adds it with `--add-dir`, so
the agent under test can read and write there and run read-only git (for
example `cd <repo> && git log`) under the permission mode. The git gate and
the deny list still apply, so `git -C <repo> commit` and every add, commit
and push are denied there too. The cwd is never inside `<run>/repos/`.

**Desk steps.** In desk mode the prompt starts with the runner's desk
preamble: the agent runs no git, mesh (`mesh-post`, `mesh-scan-loop`) or `gh`
command, and prints each one it would run on its own line starting
`DESK: `. The deny list then also denies `git`, `gh` and the mesh scripts, so
a slip is denied rather than run. In agent mode the preamble makes the
librarian's commit step a desk step in the same way; the git gate denies its
commits regardless.

**Caps.** Every test has `cap_s`: its agent steps share it, and its setup
and check scripts are each held to it. A run still going at its cap is
stopped, with its whole process group, and recorded as `not-run (cap <n> s)`. A process that dies at startup with no
result, or that gets only provider API retries and no agent turn, is retried
once; the retry is recorded, and a second stall is reported as such.

**Deliverables.** They are exported read-only by sha (`git archive`) from the
checkout named by `--repo`, at the commit set the brief's `## Start from`
gives, never read from a working copy. An agent or desk test whose
deliverable is absent at that sha fails without starting an agent. An
inspect test still runs its check, which reports each missing part.

**Managed policy.** The smoke test lists any managed policy file present
(system managed settings, a managed `CLAUDE.md`, or remote managed settings
in the config). Each is reported to the lead for a ruling; the runner does
not remove them.

## Test files

Front-matter keys, all required:

| Key | Value |
|---|---|
| `scenario` | the scenario id (`R1.S1`) or inspection id (`I1`) |
| `mode` | `inspect`, `agent (<roles>)` or `desk (<roles>)` |
| `deliverables` | `[<repo>:<path>, ...]`; `<repo>:<path> as <space path>` also copies it into the space |
| `fixture` | `none`, `demo-space`, or `demo-space + demo-bus` |
| `expected_s` | expected wall time in s |
| `heavy` | `true` when `expected_s` is over 60 s |
| `env` | an environment class, or `any` |
| `cap_s` | the cap in s |

Sections: `## Given`, `## When` (the literal words, one fenced `text` block
per agent step), `## Then` (numbered checks), `## Fails if`, `## At base`.

**Modes.** In `agent (<roles>)` and `desk (<roles>)`, steps are separated by
`then`, as in `agent (spec, then plan)`, and each step uses the next `text`
block of `## When`. A step's first role picks the session agent: a pod role
(spec, plan, lead, build, test, review) runs the session as `swe-<role>`;
any other word (`fresh`, `skill`, a skill's name) runs the default agent with
the deliverable skills installed. Every exported `agents/*.md` and
`skills/<name>/` is installed in each step. `inspect` starts no agent.

**Tokens.** In `## When` text, `{SPACE}`, `{BUS}`, `{RUN}`, `{EXPORT}` and
`{REPOS}` are replaced at run time by the paths of this run, and a setup
script may add more by writing `subst.json` in the run dir.

**Scripts.** A fenced `python setup` block runs before the agent; a fenced
`python check` block runs after it. Both run with `<py> -I` in the run dir,
with these variables:

| Variable | Meaning |
|---|---|
| `RUN_DIR`, `SPACE`, `BUS` | the run dir, the space copy (the cwd), the bus copy or empty |
| `EXPORT`, `EXPORT_<REPO>`, `SHA_<REPO>` | the read-only export root, each repo's export, its sha7 |
| `ABSENT` | absent deliverables, one `<repo> <sha7> <path>` per line |
| `STEPS`, `SUMMARY_<k>`, `FINAL_<k>`, `STREAM_<k>` | agent steps and their outputs |
| `CHECK_HOME` | an empty folder to use as `HOME` for commands under test |
| `REPOS` | `<run>/repos/`, where a setup builds code repos; added with `--add-dir` if it exists |
| `REAL_BUS`, `REAL_SPACE` | `--bus` and `--space`, or empty |
| `TESTS_DIR`, `PYTHON` | this folder, the interpreter |

`summary-<k>.json` holds the agent's final text, every tool call with its
input, output and error flag, the permission denials, the subagent counts and
the session's tools, agents and skills. A check prints one line per numbered
check, `<id> pass <reason>` or `<id> fail <reason>`, and exits 0 only when
all pass. The runner's result names the first failing check. A test with no
check script is recorded for judging against its `## Then` list.

## Fixtures

- `demo-space/` is `proj:demo`: `space.yaml`, `pod.yaml` with repos `alpha`,
  `beta` and `gamma`, `depends: {beta: [alpha]}`, the approved change
  `add-greeting`, which names `alpha` and `beta` and not `gamma`, one note,
  and the empty folders of a space. It holds no `PROCESS.md`, `AGENTS.md` or
  `STATUS.md`; a test that needs them takes them from its deliverables or its
  overlay.
- `demo-bus/agents/` registers two invented nodes: `demo-mac-01`, a
  macos-laptop holding the librarian and every pod role but test, and
  `demo-linux-01`, a linux-server holding `swe.build` and `swe.test`. When a
  test uses the bus, the space is mounted in it at `spaces/proj-demo`.
- `overlays/<test name>/` is copied over the space copy for that test only.
- Home paths in the bus fixture are written as `{{MAC_HOME}}` and
  `{{LINUX_HOME}}` and expanded only in the run's copy.

**Negative content** (home paths, hostnames, agent ids, mesh task ids,
citations that must be refused) is built at run time from split literals or
read from the run's fixture copy, and never stored whole in any file here.

## Smoke test

`runner.sh smoke` makes eight serial runs in a copy of the demo space, each
capped at 30 s, and prints `SMOKE <case> pass|fail (<detail>)`:

| Case | Shows |
|---|---|
| S1 | The agent answers `NONE` when asked to quote the first line of every instruction file in its context, with probe `CLAUDE.md`, `CLAUDE.local.md` and `AGENTS.md` files in its cwd. Also lists the session's tools, MCP servers, agents and plugins, and any managed policy file. |
| S2 | The agent starts a general-purpose subagent, which returns a word made at run time: the depth R7.S2 needs. |
| S3 | A run told to `sleep 90` is stopped at the 30 s cap and recorded `not-run (cap 30 s)`. |
| S4 | A desk run asked to commit prints a git command, runs no git command, and makes no `.git`. |
| S5 | A permitted Bash command, `ls`, succeeds. |
| S6 | A `git -C <scratch> commit` attempt is denied. |
| S7 | In a code repo under `<run>/repos/` given with `--add-dir` (a depth-1 clone of the `--gate` checkout, made at run time with no commit), a Read, a Write and `cd <repo> && git log` succeed, and `git -C <repo> commit` is denied. |
| S8 | The agent prints the config dir, `$HOME` and its cwd, and repeats each registered agent's `cwd` from `--bus`. After redaction, no kept file of that run holds any of them or any other home-root path, and the placeholders appear in their place. |

The smoke output also names the settings keys the reset carried over (none
on an environment-provider node) and the sign-in files it left alone.
