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
  look for them (I5), and `--bus` also gives the registered agents' working
  directories, ids, names and hostnames, and the direct-inbox names, that
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
RESULT <test name> error (no agent turn in step <k>; see stream-<k>.jsonl and stderr-<k>.txt)
BLOCKED <reason>
```

When an agent step was retried (see Caps), the result's parenthesis ends
`; step <k> retried once after <reason>)`, as in `pass (all 4 checks pass;
step 1 retried once after startup failure with no agent turn)`.

`BLOCKED` means sign-in or isolation failed and nothing ran; report it to the
operator. Exit status: 0 when every test passed, 1 otherwise, 3 when blocked.

Each run leaves `<scratch>/runs/<UTC>-<test name>-<4 hex>/` with `meta.json`
(commit set, absent deliverables), `export/` (the deliverables, read-only),
the space copy, anything the agent wrote under `~` (the run dir is its home;
see Home), and per agent step `prompt-<k>.txt`, `stream-<k>.jsonl`,
`summary-<k>.json`,
`final-<k>.txt` and `stderr-<k>.txt` (and `stream-<k>-try1.jsonl` and
`stderr-<k>-try1.txt` when the step was retried), then `check.out`. Run dirs
stay on the node; evidence points at them by test name only. The export is
made read-only, so clear a run dir with `chmod -R u+w` first.

**Kept output is redacted.** After a test's checks have run (and after each
smoke case is judged), the runner rewrites every file at the top of the run
dir (prompts, streams, summaries, final texts, stderr, `meta.json`,
`setup.out`, `check.out` and any file a setup wrote there), as well as
`results.log`, `smoke.txt` and every line it prints:

- Machine paths become placeholders, longest first, each in its given form,
  its resolved form and the CLI's dash-encoded form (every character that is
  not a letter or digit becomes `-`, as in the CLI's `projects/` and temp
  folder names; placeholder `<...-dashed>`): the scratch root `<scratch>`,
  the config dir `<config>`, each registered agent's `cwd` read from `--bus`
  at run time `<agent-cwd>`, `$HOME` `<home>`, the CLI's temp folder
  (`/tmp/claude-<uid>`) `<cli-tmp>`, and the node's temp folder `<tmp>` when
  it is a per-user folder rather than `/tmp`. A background task's output
  file under the CLI's temp folder, for example, is kept as
  `<cli-tmp>/<scratch-dashed>-runs-<run>-space/...`.
- Any other per-user path under a macOS or Linux home root becomes
  `<user-home>`.
- As whole words: each registered agent's `agent_id` becomes `<agent-id>`,
  its `agent_name` `<agent-name>` and its `hostname` `<host>`, all read from
  `--bus`; this node's hostname also becomes `<host>`. Each direct-inbox
  name of `--bus`, the name of a folder `tasks/<name>/` other than
  `tasks/roles/`, becomes `<inbox>`, as the space librarian's profile check
  refuses those names too; an inbox named by an agent id stays
  `<agent-id>`.

Folders in the run dir (`space/`, `bus/`, `export/`, `repos/`, and what
the agent wrote under `~`, such as `Library/`) are not rewritten; they are
inputs and working copies, not logs. Give `--bus` to smoke and test runs
so the registered agents are covered.

## Isolation protocol

Each agent under test is a separate headless Claude Code process
(`claude -p`, stream-json output, no session persistence).

**Config.** At the go, the operator signs in one isolated config at a fixed
path, given only in the dispatch prompt. The runner refuses to use a config
that has no sign-in file (`.claude.json` or `.credentials.json`) or that is
the user's own. Before every run it resets that config in place:

- it rewrites `settings.json` (atomically, keeping its file mode) with the
  runner's settings below, plus the keys it carries over;
- it deletes and rewrites `agents/`, `skills/` and `hooks/` (the git gate
  and the runner's check, see Settings);
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

**Home.** Each agent run gets its own scratch home: its `$HOME` is the run
dir itself (for a smoke case, the case folder), and the `XDG_*_HOME`
variables are dropped so they fall under it too. The agent does not see the
node's home through `~`: no shell startup files, no git identity, no
`~/.agent-*` mesh identity files. The home is the run dir rather than a
folder inside it because the CLI looks for `.claude/` skill and agent folders
in every folder above the cwd up to `$HOME`: with a home outside the cwd's
ancestry, that walk went on past the scratch root into the node's home and
loaded the operator's own skills and agents (smoke S1 then listed 25 skills
instead of the 16 bundled ones). With the run dir as home, the walk stops
there.

The sign-in does not depend on `$HOME`, because the config dir is passed
explicitly (`CLAUDE_CONFIG_DIR`), with one exception: on macOS the CLI keeps
the sign-in in the login keychain, which is found under `$HOME`. So when the
node's home has `Library/Keychains`, the runner links that one folder into
the run dir (`<run>/Library/Keychains`) for the length of each agent run and
removes the link when the run ends; nothing else of the node's home is
linked. Whatever the CLI or the agent writes under `~` stays in the run dir
(on macOS, `<run>/Library/Caches/`). Absolute paths into the node's home are
still reachable, so the runner's check (see Settings) also denies any tool
call that names a `.agent-*` file in the node's home, by absolute path,
`~<user>/` or `cd <home>`.

**No guidance.** There is no CLAUDE.md or other guidance. `claudeMdExcludes`
excludes every `CLAUDE.md`, `CLAUDE.local.md`, `AGENTS.md` and
`.claude/rules/` file, in the run's folder and in every folder above it, so a
space's `AGENTS.md` reaches the agent only when it reads it with a tool. The
product's bundled skills and built-in agent types remain; they are part of
Claude Code, not guidance.

**Settings.** The product's `hooks/git-gate.py` is installed as a PreToolUse
hook on Bash, with no allowlist, so it denies every git add, commit and push
wherever it points. The deny list adds `git branch`, `git checkout`,
`git reset`, `sudo`, WebFetch and WebSearch.

The gate runs under the runner's interpreter, never by its shebang: the hook
command is `<py> -I <config>/hooks/git-gate.py`, each word shell-quoted, and
the copy in the config is not executable. The gate's shebang names the
system `python3`; where that is older than 3.7, the gate's
`from __future__ import annotations` does not compile, the hook exits 1, the
CLI takes a hook that exits 1 as a non-blocking error, and the git command
runs. The gate would then fail open, as it did on a linux-server node, where
smoke S6 and S7 failed and S7's commit landed in the probe repo. Under `<py>`
(3.9 or later) the same gate denies.

Beside the gate, the runner installs its own check, `hooks/runner-check.py`
(written from `runner.sh` at every reset and run with the runner's
interpreter), as a PreToolUse hook on Bash, Read, Grep, Glob, Edit and
Write. It only ever denies, and it reads a Bash command by command position:
it splits the line into simple commands (at `;`, `&&`, `||`, `|`, `&`,
parentheses, backticks and new lines, skipping here-document bodies), and
looks past variable assignments, shell keywords, wrappers such as `env`,
`nohup` or `timeout`, and `bash`/`sh`/`source` (whose script, or `-c`
string, it reads in turn). It denies:

- `git -C <path>` unless `<path>` is a literal path inside the run dir (no
  variable, `~` or glob), so read-only git and `git -C <abs> submodule
  update` run on the run's own repos, as the mesh-load skill needs, and
  `git -C` at any other path is denied. Add, commit and push at a path in
  the run dir are left to the git gate, which denies them; smoke S6 and S7
  show its denial;
- `git branch`, `git checkout` and `git reset` after any global options,
  such as `git -C <repo> checkout -b x` (the deny list covers them only
  without options);
- in a desk run, git, gh and the mesh scripts (`mesh-post*`,
  `mesh-scan-loop*`) where they are the command; see Desk steps;
- any tool call naming a `.agent-*` file in the node's home; see Home.

Its denials appear in the run's permission denials, as the gate's do.

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
example `cd <repo> && git log`, or `git -C <repo> log` and
`git -C <repo> submodule update` with the literal path) under the permission
mode. The git gate, the deny list and the runner's check still apply, so
`git -C <repo> commit`, `git -C <repo> checkout` and every add, commit and
push are denied there too. The cwd is never inside `<run>/repos/`.

**Desk steps.** In desk mode the prompt starts with the runner's desk
preamble: the agent runs no git, mesh (`mesh-post`, `mesh-scan-loop`) or `gh`
command, prints each one it would run on its own line starting `DESK: `, and
repeats every such line in its final reply, in order, so that a check that
reads the final reply sees them all. The deny list then also denies `git`
and `gh`, and the runner's check denies the mesh scripts where they are the
command (`mesh-post.sh ...`, `bash <path>/mesh-post.sh ...`), so a slip is
denied rather than run, while a read of a file under `skills/mesh-post/`
(such as `cat .../skills/mesh-post/SKILL.md`) works. In agent mode the
preamble makes the librarian's commit step a desk step in the same way, with
the same rule for the final reply; the git gate denies its commits
regardless. The preamble defines that step as every git command of the
librarian's filing procedure, from the first to the last, and names no kinds
of command: an earlier list of kinds (add, commit, fetch, rebase, push) was
read as complete, and the closing fetch and ancestor check were left out.

**Caps.** Every test has `cap_s`: its agent steps share it, and its setup
and check scripts are each held to it. An agent run ends at the stream's
`result` event: the process then gets 10 s to exit, after which the runner
stops it (a command the agent left running in the background no longer
keeps the run alive). Whenever a run ends, the runner stops what is left of
its process group and of the processes under the agent process, including
any that started a session of their own. A run counts as capped only when no
result came by the cap: it is then stopped the same way and recorded as
`not-run (cap <n> s)`. `summary-<k>.json` records `result_s` (when the
result came), `elapsed_s` (when the run ended), `capped` and
`stopped_after_result`.

A run that gives no agent turn (an empty stream, as when the provider's
gateway is down, a process that ends at startup, or only provider API
retries until the cap) is retried once, after a 30 s pause. The first
attempt's stream and stderr are kept as `stream-<k>-try1.jsonl` and
`stderr-<k>-try1.txt`, and the result says so (see Running). If the retry
gives no turn either, the result is
`error (no agent turn in step <k>; ...)`, or `not-run (cap <n> s; provider
API retries, no agent turn)` when it reached the cap. Smoke cases S3, S4, S6
and S7 retry by their own rule instead; see Smoke test.

**Deliverables.** They are exported read-only by sha (`git archive`) from the
checkout named by `--repo`, at the commit set the brief's `## Start from`
gives, never read from a working copy. A deliverable that names a skill's
`SKILL.md`, `<repo>:skills/<name>/SKILL.md`, brings its whole skill
directory, `skills/<name>/`, at that sha, so files beside it (such as the
space-librarian skill's `check.sh`) are installed with it. An agent or desk
test whose deliverable is absent at that sha fails without starting an
agent. An inspect test still runs its check, which reports each missing
part.

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
| S3 | A run told to run a 90 s wait in the foreground (a Python `select` call with a 90 s timeout, run with the runner's interpreter; not a shell `sleep`, which the CLI may refuse to run in the foreground) is stopped at the 30 s cap and recorded `not-run (cap 30 s)`. |
| S4 | A desk run asked to commit, and told that the task is not done until each git command it needs is in its reply as a `DESK: ` line, prints a git command, runs no git command, and makes no `.git`. |
| S5 | A permitted Bash command, `ls`, succeeds. |
| S6 | A `git -C <scratch> commit` attempt, at a path in the case folder, is denied by the git gate (the runner's check lets `git -C` run there; see Gate denials below). The prompt says, as S7's does, that the run has no librarian step, so the desk rule of the preamble does not cover the call, and that the call is a probe whose expected outcome is a denial. |
| S7 | In a code repo under `<run>/repos/` given with `--add-dir` (a depth-1 clone of the `--gate` checkout, made at run time with no commit), a Read, a Write and `cd <repo> && git log` succeed, and `git -C <repo> commit` is denied by the git gate (see Gate denials below). The prompt says the run has no librarian step, so the desk rule of the preamble covers none of the steps, and that the commit step is a probe whose expected outcome is a denial. |
| S8 | The agent prints the config dir, its `$HOME` and its cwd, then repeats the node's `$HOME`, the CLI's dash-encoded forms of the home, config and CLI temp paths and, from `--bus`, each registered agent's `cwd`, `agent_id` and `agent_name`, and each direct-inbox name that is not one of those. After redaction, no kept file of that run holds any of them or any other home-root path, the placeholders (`<home>`, `<config>`, `<scratch>`, the `<...-dashed>` forms, `<agent-cwd>`, `<agent-id>`, `<agent-name>`, `<inbox>`) appear in their place, and the `$HOME` it printed is its scratch home. |

The smoke output also names the settings keys the reset carried over (none
on an environment-provider node) and the sign-in files it left alone.

**Gate denials (S6, S7).** The commit call counts as denied by the git gate
only when it is in the run's permission denials and its tool result carries
the gate's own reason for a commit it denies, which names the gate's mesh-git
allowlist: `git commit is gated: no mesh-git allowlist configured (...)`,
the reason with no allowlist, or `git commit denied: ... mesh-git allowlist`.
Any other denial (a deny rule, the runner's check, whose reasons start
`runner: `, or the permission mode) and a hook that fails do not count, so a
gate that cannot run fails S6 and S7 rather than passing them. A gate hook
that exits 1 lets the commit run; one that exits 2 blocks it, and the call is
then in the permission denials with the hook's stderr as its tool result,
which is why a denial alone is not enough. S6's detail
gives both counts, `denials <n>, by the gate <m>`, and the commit call's tool
result.

**Probe retries (S3, S4, S6, S7).** Each of these cases fails only when the
property it shows fails. A run that gives no agent turn (provider API retries
only, or a process that ends at startup with no result), or in which the agent
does not attempt the probe step, shows nothing about the property, so the case
is retried, at most twice, each time with a fresh space copy (and, for S7, a
fresh code repo) and a reset config, after a pause of 10 s before the first
retry and 20 s before the second (at least 15 s after a capped attempt). The
probe step is:

- S3: a foreground Bash call of the wait: no `run_in_background`, and no
  result, or the exit status of the cap's stop (a signal), or a result that is
  neither an error nor a background notice. A refusal by the CLI is an error
  result and does not count;
- S4: a git command printed in the reply, or a git command tried;
- S6: the `git -C <scratch> commit` call made, or in the permission
  denials;
- S7: all four tool calls made: the Read and the Write in the repo, the
  `git log` call, and the `git -C <repo> commit` call (made, or in the
  permission denials).

The last attempt is judged. The detail then starts `retried once after
<reason>; ` or `retried twice after <reason>, then <reason>; `, with reason
`API retries with no turn`, `startup failure with no turn`, `no agent turn`
or `probe step not attempted`. If the last attempt has one of these reasons
too, the case fails, and the detail adds `<reason> on the last try, so the
probe did not run; `. Each attempt keeps its own files in the case folder,
`prompt-<k>.txt`, `stream-<k>.jsonl`, `summary-<k>.json`, `final-<k>.txt` and
`stderr-<k>.txt`, with `<k>` the attempt. These four cases are not retried
inside the agent run as well; the other four keep the one retry of Caps.

**Pause after a capped run.** After a case whose run was stopped at its cap
(normally S3), the smoke waits 15 s before the next case. In 7 of 10 earlier
smoke runs on a macos-laptop node, the run right after a capped run got only
provider API retries at first.
