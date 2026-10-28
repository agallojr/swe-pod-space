#!/usr/bin/env bash
# runner.sh: isolated runner for the SWE Pod project-level tests.
# Each agent under test is a separate headless Claude Code process run in one
# signed-in config that is reset in place before every run. The protocol is in
# README.md next to this file. Machine paths are arguments only; this file
# holds none.
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
usage: runner.sh smoke --python <py> --config <dir> --scratch <dir>
                 --gate <agent-mesh checkout>@<sha> [options]
       runner.sh run <test file>... --python <py> --scratch <dir>
                 [--config <dir>] [--gate <checkout>@<sha>]
                 [--repo <name>=<checkout>@<rev>]... [options]
options: --env <class>  --bus <dir>  --space <dir>  --model <model>
         --allow-heavy  --claude <cli>
EOF
  exit 2
}

[[ $# -eq 0 ]] && usage
PY=""
prev=""
for a in "$@"; do
  if [[ "$prev" == "--python" ]]; then PY="$a"; fi
  prev="$a"
done
if [[ -z "$PY" ]]; then
  echo "runner: --python <interpreter> is required" >&2
  usage
fi
RUNNER_TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export RUNNER_TESTS_DIR
exec "$PY" -I - "$@" <<'PYEOF'
"""Runner core (embedded so the runner is one file). See README.md."""
from __future__ import annotations

import argparse
import io
import json
import os
import random
import re
import shlex
import shutil
import signal
import socket
import subprocess
import sys
import tarfile
import time
from datetime import datetime, timezone
from pathlib import Path

TESTS_DIR = Path(os.environ["RUNNER_TESTS_DIR"])
FIXTURES = TESTS_DIR / "fixtures"

# Union of the role tools of contract 2.3, plus Skill. Everything else is
# denied by the dontAsk mode, which never prompts and is not a bypass mode.
TOOLS = ["Read", "Grep", "Glob", "Bash", "Write", "Edit", "Agent", "Skill"]
DENY = [
    "Bash(git -C:*)", "Bash(git branch:*)", "Bash(git checkout:*)",
    "Bash(git reset:*)", "Bash(sudo:*)", "WebFetch", "WebSearch",
]
DESK_DENY = [
    "Bash(git:*)", "Bash(gh:*)", "Bash(*mesh-post*)", "Bash(*mesh-scan-loop*)",
]
MD_EXCLUDES = [
    "**/CLAUDE.md", "**/CLAUDE.local.md", "**/AGENTS.md", "**/.claude/rules/**",
]
# Variables that tie a child to the session that started the runner, or point
# it at a mesh identity. The provider environment is inherited untouched.
DROP_VARS = [
    "CLAUDECODE", "CLAUDE_CODE_SESSION_ID", "CLAUDE_CODE_CHILD_SESSION",
    "CLAUDE_CODE_MESSAGING_SOCKET", "CLAUDE_CODE_MESSAGING_TOKEN", "CLAUDE_PID",
    "CLAUDE_CODE_ENTRYPOINT", "CLAUDE_CODE_SESSION_ATTENDED",
    "CLAUDE_CODE_EXECPATH", "CLAUDE_EFFORT", "CLAUDE_CODE_CONFIG_DIR",
    "CLAUDE_CONFIG_DIR", "REPO_PATH", "AGENT_ID",
]
# Config state cleared before every run. Sign-in files are kept.
STATE_DIRS = [
    "agents", "skills", "commands", "rules", "output-styles", "hooks",
    "projects", "todos", "shell-snapshots", "session-env", "file-history",
    "plans", "paste-cache", "debug",
]
STATE_FILES = [
    "settings.json", "settings.local.json", "CLAUDE.md", "CLAUDE.local.md",
    "history.jsonl", "mesh-git-allowlist.txt",
]
SIGN_IN_MARKER = ".claude.json"
POD_ROLES = {"spec", "plan", "lead", "build", "test", "review"}

DESK_PREAMBLE = (
    "Desk run. Run no git command, no mesh command (mesh-post, "
    "mesh-scan-loop) and no gh command. Wherever you would run one, print "
    "it instead on its own line starting with `DESK: `, and carry on as if "
    "it had succeeded. Every other tool works as normal."
)
LIBRARIAN_PREAMBLE = (
    "In this run the librarian's commit step is a desk step: print each git "
    "command of it (add, commit, fetch, rebase, push) on its own line "
    "starting with `DESK: `, and run none of them."
)


def utc_stamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


def say(line: str) -> None:
    print(line, flush=True)


class Blocked(Exception):
    """Isolation or sign-in failure: the run must not start."""


def in_git(path: Path) -> bool:
    try:
        r = subprocess.run(["git", "rev-parse"], cwd=path,
                           stdout=subprocess.DEVNULL,
                           stderr=subprocess.DEVNULL)
    except FileNotFoundError:
        return False
    return r.returncode == 0


def child_env(config: Path | None) -> dict:
    env = {k: v for k, v in os.environ.items()
           if k not in DROP_VARS and not k.startswith("MESH_")}
    if config is not None:
        env["CLAUDE_CONFIG_DIR"] = str(config)
    return env


# ---------------------------------------------------------------- test files

def parse_list(value: str) -> list:
    value = value.strip()
    if value.startswith("[") and value.endswith("]"):
        value = value[1:-1]
    return [v.strip() for v in value.split(",") if v.strip()]


def parse_test(path: Path) -> dict:
    text = path.read_text()
    m = re.match(r"---\n(.*?)\n---\n", text, re.S)
    if not m:
        raise ValueError(f"{path.name}: no front-matter")
    front = {}
    for line in m.group(1).splitlines():
        if ":" in line and not line.startswith(" "):
            k, v = line.split(":", 1)
            front[k.strip()] = v.strip()
    need = ["scenario", "mode", "deliverables", "fixture", "expected_s",
            "heavy", "env", "cap_s"]
    missing = [k for k in need if k not in front]
    if missing:
        raise ValueError(f"{path.name}: front-matter lacks {missing}")
    body = text[m.end():]
    sections = {}
    for sm in re.finditer(r"^## (.+?)\n(.*?)(?=^## |\Z)", body, re.M | re.S):
        sections[sm.group(1).strip()] = sm.group(2)
    fence = re.compile(r"^```([a-z]+)(?: ([a-z]+))?\n(.*?)^```\s*$",
                       re.M | re.S)
    blocks = [(b.group(1), b.group(2) or "", b.group(3))
              for b in fence.finditer(body)]
    when = [code for lang, _, code in fence_blocks(sections.get("When", ""))
            if lang == "text"]
    mode_raw = front["mode"]
    mm = re.match(r"(\w+)\s*(?:\((.*)\))?", mode_raw)
    kind = mm.group(1)
    steps = []
    if mm.group(2):
        for step in re.split(r",?\s*then\s+", mm.group(2)):
            roles = [r.strip() for r in step.split(",") if r.strip()]
            steps.append(roles)
    deliverables = []
    for d in parse_list(front["deliverables"]):
        dest = None
        if " as " in d:
            d, dest = [x.strip() for x in d.split(" as ", 1)]
        repo, rel = d.split(":", 1)
        deliverables.append({"repo": repo, "path": rel, "dest": dest})
    fixture = front["fixture"].strip()
    fixtures = [] if fixture in ("none", "") else [
        f.strip() for f in fixture.split("+")]
    return {
        "name": path.stem, "path": path, "front": front, "kind": kind,
        "steps": steps, "deliverables": deliverables, "fixtures": fixtures,
        "when": when,
        "setup": next((c for lang, tag, c in blocks
                       if lang == "python" and tag == "setup"), None),
        "check": next((c for lang, tag, c in blocks
                       if lang == "python" and tag == "check"), None),
        "cap_s": int(front["cap_s"]),
        "heavy": front["heavy"].lower() == "true",
        "env": front["env"],
    }


def fence_blocks(text: str) -> list:
    fence = re.compile(r"^```([a-z]+)(?: ([a-z]+))?\n(.*?)^```\s*$",
                       re.M | re.S)
    return [(b.group(1), b.group(2) or "", b.group(3))
            for b in fence.finditer(text)]


# --------------------------------------------------------------- deliverables

def parse_repo_args(values: list) -> dict:
    repos = {}
    for v in values or []:
        name, rest = v.split("=", 1)
        checkout, rev = rest.rsplit("@", 1)
        repos[name] = {"checkout": Path(checkout), "rev": rev}
    return repos


def resolve(repo: dict) -> str:
    r = subprocess.run(
        ["git", "-C", str(repo["checkout"]), "rev-parse", "--verify",
         repo["rev"] + "^{commit}"],
        capture_output=True, text=True)
    if r.returncode != 0:
        raise Blocked(f"cannot resolve {repo['rev']} in a --repo checkout")
    return r.stdout.strip()


def git_has(repo: dict, sha: str, rel: str) -> bool:
    r = subprocess.run(
        ["git", "-C", str(repo["checkout"]), "cat-file", "-e",
         f"{sha}:{rel}"], capture_output=True)
    return r.returncode == 0


def export(repo: dict, sha: str, rel: str, dest: Path) -> None:
    r = subprocess.run(
        ["git", "-C", str(repo["checkout"]), "archive", "--format=tar", sha,
         "--", rel], capture_output=True)
    if r.returncode != 0:
        raise Blocked(f"git archive failed for {rel}")
    dest.mkdir(parents=True, exist_ok=True)
    with tarfile.open(fileobj=io.BytesIO(r.stdout)) as tar:
        for member in tar.getmembers():
            target = (dest / member.name).resolve()
            if not str(target).startswith(str(dest.resolve())):
                raise Blocked("archive member escapes the export dir")
        try:
            tar.extractall(dest, filter="data")
        except TypeError:
            tar.extractall(dest)


def make_read_only(root: Path) -> None:
    for p in sorted(root.rglob("*"), key=lambda q: len(q.parts),
                    reverse=True):
        if p.is_symlink():
            continue
        p.chmod(0o555 if p.is_dir() else 0o444)
    root.chmod(0o555)


# ------------------------------------------------------------------ fixtures

TOKENS = {"{{MAC_HOME}}": "/Us" + "ers", "{{LINUX_HOME}}": "/ho" + "me"}


def expand_tokens(root: Path) -> None:
    for p in root.rglob("*"):
        if p.is_file():
            try:
                text = p.read_text()
            except UnicodeDecodeError:
                continue
            new = text
            for k, v in TOKENS.items():
                new = new.replace(k, v)
            if new != text:
                p.write_text(new)


def lay_out(run: Path, test: dict) -> tuple:
    """Copy fixtures and overlays into the run dir; return (space, bus)."""
    bus = None
    space = run / "space"
    if "demo-bus" in test["fixtures"]:
        bus = run / "bus"
        shutil.copytree(FIXTURES / "demo-bus", bus)
        space = bus / "spaces" / "proj-demo"
    if "demo-space" in test["fixtures"]:
        shutil.copytree(FIXTURES / "demo-space", space)
    else:
        space.mkdir(parents=True)
    overlay = FIXTURES / "overlays" / test["name"]
    if overlay.is_dir():
        shutil.copytree(overlay, space, dirs_exist_ok=True)
    expand_tokens(space)
    if bus:
        expand_tokens(bus)
    for d in [space] + ([bus] if bus else []):
        if in_git(d):
            raise Blocked("a fixture copy is inside a git work tree")
    return space, bus


# -------------------------------------------------------------------- config

def reset_config(config: Path, gate_src: Path, agents: list, skills: list,
                 desk: bool) -> None:
    """Reset the isolated config in place: agents, skills, settings, state."""
    for name in STATE_DIRS:
        p = config / name
        if p.is_symlink() or p.is_file():
            p.unlink()
        elif p.is_dir():
            shutil.rmtree(p)
    for name in STATE_FILES:
        p = config / name
        if p.exists() or p.is_symlink():
            p.unlink()
    (config / "hooks").mkdir()
    gate = config / "hooks" / "git-gate.py"
    shutil.copyfile(gate_src, gate)
    gate.chmod(0o755)
    (config / "agents").mkdir()
    for a in agents:
        shutil.copyfile(a, config / "agents" / a.name)
    (config / "skills").mkdir()
    for s in skills:
        shutil.copytree(s, config / "skills" / s.name)
    for p in (config / "agents").rglob("*"):
        p.chmod(0o644 if p.is_file() else 0o755)
    for p in (config / "skills").rglob("*"):
        p.chmod(0o644 if p.is_file() else 0o755)
    settings = {
        "permissions": {
            "defaultMode": "dontAsk",
            "disableBypassPermissionsMode": "disable",
            "allow": TOOLS,
            "deny": DENY + (DESK_DENY if desk else []),
        },
        "hooks": {"PreToolUse": [{"matcher": "Bash", "hooks": [
            {"type": "command", "command": shlex.quote(str(gate))}]}]},
        "claudeMdExcludes": MD_EXCLUDES,
    }
    (config / "settings.json").write_text(json.dumps(settings, indent=2))


def check_config(config: Path) -> None:
    if not config.is_absolute() or not config.is_dir():
        raise Blocked("--config must be an existing absolute directory")
    home = Path(os.path.expanduser("~")).resolve()
    if config.resolve() in (home, home / ".claude"):
        raise Blocked("--config must be the isolated config, not a user one")
    if not (config / SIGN_IN_MARKER).is_file():
        raise Blocked("the isolated config is not signed in")
    if in_git(config):
        raise Blocked("git rev-parse succeeds in the config dir")


# ---------------------------------------------------------------- agent runs

def kill_group(proc: subprocess.Popen) -> None:
    for sig in (signal.SIGTERM, signal.SIGKILL):
        try:
            os.killpg(proc.pid, sig)
        except ProcessLookupError:
            return
        try:
            proc.wait(timeout=5)
            return
        except subprocess.TimeoutExpired:
            continue


def summarize(stream: Path) -> dict:
    out = {"result": None, "is_error": None, "tool_uses": [],
           "permission_denials": [], "subagent_stats": None, "init": None,
           "assistant_events": 0, "api_retries": 0}
    uses = {}
    for line in stream.read_text().splitlines():
        try:
            ev = json.loads(line)
        except json.JSONDecodeError:
            continue
        t = ev.get("type")
        if t == "assistant":
            out["assistant_events"] += 1
        if t == "system" and ev.get("subtype") == "api_retry":
            out["api_retries"] += 1
        if t == "system" and ev.get("subtype") == "init":
            out["init"] = {k: ev.get(k) for k in (
                "tools", "agents", "skills", "mcp_servers", "plugins",
                "permissionMode", "memory_paths", "model")}
        if t in ("assistant", "user"):
            for c in (ev.get("message") or {}).get("content") or []:
                if not isinstance(c, dict):
                    continue
                if c.get("type") == "tool_use":
                    u = {"id": c.get("id"), "name": c.get("name"),
                         "input": c.get("input"), "is_error": None,
                         "output": None,
                         "subagent": ev.get("parent_tool_use_id") is not None}
                    uses[c.get("id")] = u
                    out["tool_uses"].append(u)
                if c.get("type") == "tool_result":
                    u = uses.get(c.get("tool_use_id"))
                    if u is not None:
                        content = c.get("content")
                        if isinstance(content, list):
                            content = "\n".join(
                                x.get("text", "") for x in content
                                if isinstance(x, dict))
                        u["output"] = content
                        u["is_error"] = bool(c.get("is_error"))
        if t == "result":
            out["result"] = ev.get("result")
            out["is_error"] = ev.get("is_error")
            out["permission_denials"] = ev.get("permission_denials") or []
            out["subagent_stats"] = ev.get("subagent_stats")
            out["num_turns"] = ev.get("num_turns")
    return out


def run_agent(args, run: Path, k: int, cwd: Path, prompt: str, cap_s: int,
              add_dirs: list, session_agent: str | None = None) -> dict:
    """One headless Claude Code process, stopped at its cap."""
    cmd = [args.claude, "-p", "--output-format", "stream-json", "--verbose",
           "--no-session-persistence", "--permission-mode", "dontAsk",
           "--tools", ",".join(TOOLS), "--strict-mcp-config"]
    if session_agent:
        cmd += ["--agent", session_agent]
    if args.model:
        cmd += ["--model", args.model]
    for d in add_dirs:
        cmd += ["--add-dir", str(d)]
    (run / f"prompt-{k}.txt").write_text(prompt)
    stream = run / f"stream-{k}.jsonl"
    err = run / f"stderr-{k}.txt"
    record = {"step": k, "cap_s": cap_s, "retried": False}
    for attempt in (1, 2):
        start = time.monotonic()
        with open(stream, "w") as so, open(err, "w") as se:
            proc = subprocess.Popen(
                cmd, cwd=cwd, env=child_env(args.config),
                stdin=subprocess.PIPE, stdout=so, stderr=se,
                start_new_session=True, text=True)
            proc.stdin.write(prompt)
            proc.stdin.close()
            capped = False
            while True:
                try:
                    proc.wait(timeout=0.5)
                    break
                except subprocess.TimeoutExpired:
                    if time.monotonic() - start >= cap_s:
                        capped = True
                        kill_group(proc)
                        break
        elapsed = time.monotonic() - start
        summary = summarize(stream)
        record.update({"exit": proc.returncode, "capped": capped,
                       "elapsed_s": round(elapsed, 1)})
        startup_failure = (not capped and summary["result"] is None
                           and elapsed < 20)
        api_stall = (summary["assistant_events"] == 0
                     and summary["api_retries"] > 0
                     and summary["result"] is None)
        if (startup_failure or api_stall) and attempt == 1:
            record["retried"] = ("startup failure" if startup_failure
                                 else "API retries with no turn")
            continue
        record["api_stall"] = api_stall
        break
    stray = cwd / ".claude"
    if stray.is_dir():
        shutil.rmtree(stray)
        record["removed_stray_dot_claude"] = True
    summary["run"] = record
    (run / f"summary-{k}.json").write_text(json.dumps(summary, indent=2))
    (run / f"final-{k}.txt").write_text(summary["result"] or "")
    return summary


def substitute(text: str, subst: dict) -> str:
    return re.sub(r"\{([A-Z][A-Z0-9_]*)\}",
                  lambda m: subst.get(m.group(1), m.group(0)), text)


# --------------------------------------------------------------- test driver

def script_env(base: dict) -> dict:
    env = child_env(None)
    env.update({k: str(v) for k, v in base.items()})
    return env


def run_script(args, run: Path, code: str, name: str, env: dict,
               cap_s: int) -> tuple:
    path = run / f"{name}.py"
    path.write_text(code)
    start = time.monotonic()
    try:
        r = subprocess.run([args.python, "-I", str(path)], cwd=run, env=env,
                           capture_output=True, text=True, timeout=cap_s)
    except subprocess.TimeoutExpired:
        return None, "", f"cap {cap_s} s"
    (run / f"{name}.out").write_text(r.stdout + r.stderr)
    return r.returncode, r.stdout, r.stderr[-2000:]


def run_test(args, path: Path) -> str:
    test = parse_test(path)
    name = test["name"]
    if test["env"] != "any" and test["env"] != args.env:
        return f"not-run (needs env {test['env']})"
    run = args.scratch / "runs" / (
        f"{utc_stamp()}-{name}-{random.randrange(16 ** 4):04x}")
    run.mkdir(parents=True)
    if in_git(run):
        raise Blocked("git rev-parse succeeds in the run dir")
    repos = parse_repo_args(args.repo)
    meta = {"test": name, "commit_set": {}, "absent": []}
    shas = {}
    exp = run / "export"
    exp.mkdir()
    for d in test["deliverables"]:
        repo = repos.get(d["repo"])
        if repo is None:
            raise Blocked(f"no --repo given for {d['repo']}")
        sha = shas.setdefault(d["repo"], resolve(repo))
        meta["commit_set"][d["repo"]] = sha[:7]
        if git_has(repo, sha, d["path"]):
            export(repo, sha, d["path"], exp / d["repo"])
        else:
            meta["absent"].append(f"{d['repo']} {sha[:7]} {d['path']}")
    (run / "meta.json").write_text(json.dumps(meta, indent=2))
    agent_mode = test["kind"] in ("agent", "desk")
    if agent_mode and meta["absent"]:
        make_read_only(exp)
        return f"fail (deliverable absent: {meta['absent'][0]})"
    if test["heavy"] and not args.allow_heavy:
        make_read_only(exp)
        return "not-run (heavy: needs the operator's go and --allow-heavy)"
    space, bus = lay_out(run, test)
    for d in test["deliverables"]:
        src = exp / d["repo"] / d["path"]
        if d["dest"] and src.exists():
            target = space / d["dest"]
            target.parent.mkdir(parents=True, exist_ok=True)
            if src.is_dir():
                shutil.copytree(src, target, dirs_exist_ok=True)
            else:
                shutil.copyfile(src, target)
    make_read_only(exp)
    (run / "meta.json").write_text(json.dumps(meta, indent=2))
    env_vars = {
        "RUN_DIR": run, "SPACE": space, "BUS": bus or "", "EXPORT": exp,
        "ABSENT": "\n".join(meta["absent"]), "TESTS_DIR": TESTS_DIR,
        "PYTHON": args.python, "REAL_BUS": args.bus or "",
        "REAL_SPACE": args.space or "", "CHECK_HOME": run / "home",
    }
    (run / "home").mkdir()
    for repo, sha in shas.items():
        key = re.sub(r"[^A-Z0-9]", "_", repo.upper())
        env_vars[f"EXPORT_{key}"] = exp / repo
        env_vars[f"SHA_{key}"] = sha[:7]
    if test["setup"]:
        rc, out, err = run_script(args, run, test["setup"], "setup",
                                  script_env(env_vars), test["cap_s"])
        if rc != 0:
            return f"error (setup failed: {(err or out).strip()[-200:]})"
    if agent_mode:
        if args.config is None or args.gate is None:
            raise Blocked("agent and desk tests need --config and --gate")
        subst = {"SPACE": str(space), "BUS": str(bus or ""),
                 "RUN": str(run), "EXPORT": str(exp)}
        sfile = run / "subst.json"
        if sfile.is_file():
            subst.update(json.loads(sfile.read_text()))
        agents = sorted((exp).glob("*/agents/*.md"))
        skills = sorted(p for p in exp.glob("*/skills/*") if p.is_dir())
        desk = test["kind"] == "desk"
        preamble = DESK_PREAMBLE if desk else LIBRARIAN_PREAMBLE
        steps = test["steps"] or [["fresh"]]
        if len(test["when"]) < len(steps):
            return "error (fewer When blocks than steps)"
        deadline = time.monotonic() + test["cap_s"]
        add_dirs = [exp] + ([bus] if bus else [])
        for k, roles in enumerate(steps, 1):
            role = roles[0]
            session_agent = f"swe-{role}" if role in POD_ROLES else None
            reset_config(args.config, args.gate_file, agents, skills, desk)
            remaining = int(deadline - time.monotonic())
            if remaining <= 0:
                return f"not-run (cap {test['cap_s']} s)"
            prompt = preamble + "\n\n" + substitute(test["when"][k - 1],
                                                    subst)
            s = run_agent(args, run, k, space, prompt, remaining, add_dirs,
                          session_agent)
            env_vars[f"SUMMARY_{k}"] = run / f"summary-{k}.json"
            env_vars[f"FINAL_{k}"] = run / f"final-{k}.txt"
            env_vars[f"STREAM_{k}"] = run / f"stream-{k}.jsonl"
            if s["run"]["capped"]:
                stall = ("; provider API retries, no agent turn"
                         if s["run"].get("api_stall") else "")
                return f"not-run (cap {test['cap_s']} s{stall})"
            if s["result"] is None:
                return "error (no result from the agent process)"
        env_vars["STEPS"] = len(steps)
    if not test["check"]:
        return "recorded (no check script; judge the run dir by the Then list)"
    rc, out, err = run_script(args, run, test["check"], "check",
                              script_env(env_vars), test["cap_s"])
    if rc is None:
        return f"not-run (cap {test['cap_s']} s)"
    fails = [ln for ln in out.splitlines() if re.match(r"\S+ fail ", ln)]
    passes = [ln for ln in out.splitlines() if re.match(r"\S+ pass", ln)]
    if rc == 0 and not fails:
        return f"pass (all {len(passes)} checks pass)"
    if fails:
        first = fails[0].split(" fail ", 1)
        return f"fail (check {first[0]}: {first[1]})"
    return f"error (check script exit {rc}: {err.strip()[-200:]})"


# --------------------------------------------------------------------- smoke

MANAGED = [
    "/Library/Application Support/ClaudeCode/managed-settings.json",
    "/Library/Application Support/ClaudeCode/managed-settings.d",
    "/Library/Application Support/ClaudeCode/managed-mcp.json",
    "/Library/Application Support/ClaudeCode/CLAUDE.md",
    "/etc/claude-code/managed-settings.json",
    "/etc/claude-code/managed-settings.d",
    "/etc/claude-code/managed-mcp.json",
    "/etc/claude-code/CLAUDE.md",
]


def managed_policy(config: Path) -> list:
    found = []
    for p in MANAGED:
        q = Path(p)
        if q.is_dir():
            found += [f"{c} (settings drop-in)" for c in sorted(q.iterdir())]
        elif q.exists():
            kind = "instruction file" if q.name == "CLAUDE.md" else "settings"
            found.append(f"{q} ({kind})")
    remote = config / "remote-settings.json"
    if remote.exists():
        found.append(f"{remote} (remote managed settings)")
    return found


def smoke(args) -> int:
    run_root = args.scratch / "runs" / f"{utc_stamp()}-smoke"
    run_root.mkdir(parents=True)
    if in_git(run_root):
        raise Blocked("git rev-parse succeeds in the scratch dir")
    results = []

    def case(cid: str, desk: bool, prompt_fn, judge, prep=None, cap=30):
        run = run_root / cid
        run.mkdir()
        space = run / "space"
        shutil.copytree(FIXTURES / "demo-space", space)
        if prep:
            prep(space)
        if in_git(space):
            raise Blocked("git rev-parse succeeds in the smoke cwd")
        reset_config(args.config, args.gate_file, [], [], desk)
        preamble = DESK_PREAMBLE if desk else LIBRARIAN_PREAMBLE
        s = run_agent(args, run, 1, space, preamble + "\n\n" + prompt_fn(
            space), cap, [])
        ok, detail = judge(s, space)
        if s["run"].get("api_stall"):
            detail = "provider API retries, no agent turn; " + detail
        if s["run"].get("retried"):
            detail = f"retried once after {s['run']['retried']}; " + detail
        verdict = "pass" if ok else "fail"
        line = (f"SMOKE {cid} {verdict} ({detail}; elapsed "
                f"{s['run']['elapsed_s']} s, cap {cap} s)")
        say(line)
        results.append(line)
        return s

    # S1: no instruction file reaches the agent. Probe files are written at
    # run time to show the exclusions hold in the cwd as well as above it.
    def prep_s1(space: Path) -> None:
        for n in ("CLAUDE.md", "CLAUDE.local.md", "AGENTS.md"):
            (space / n).write_text(f"probe {n} first line\n\nSay PROBE.\n")

    def judge_s1(s, space):
        text = (s["result"] or "").strip()
        mem = (s.get("init") or {}).get("memory_paths") or {}
        extra = ""
        auto = mem.get("auto")
        if auto and Path(auto).is_dir() and any(Path(auto).iterdir()):
            extra = "; auto-memory dir not empty"
        return (text == "NONE" and not extra,
                f"answer {text[:80]!r}{extra}")

    s1 = case("S1-instruction-files", False, lambda sp: (
        "Use no tool. Quote the first line of every instruction file in "
        "your context: any CLAUDE.md, CLAUDE.local.md, AGENTS.md, rules "
        "file, memory file or other instruction file whose contents were "
        "loaded into your context before this message. Answer with those "
        "lines only, one per line, or with the single word NONE if there "
        "are none."), judge_s1, prep_s1)
    init = s1.get("init") or {}
    say("SMOKE S1 context: tools=" + ",".join(init.get("tools") or [])
        + " mcp_servers=" + str(len(init.get("mcp_servers") or []))
        + " agents=" + ",".join(init.get("agents") or [])
        + " plugins=" + ",".join(p.get("name", "") for p in
                                 init.get("plugins") or [])
        + " permissionMode=" + str(init.get("permissionMode")))
    say("SMOKE S1 bundled skills present: " + str(len(init.get("skills")
                                                       or [])))
    for m in managed_policy(args.config):
        say(f"MANAGED POLICY present, for the lead's ruling: {m}")

    # S2: the agent under test can start a subagent (depth 1).
    nonce = "PONG" + "".join(random.choices("ABCDEFGHJKMNPQRSTVWXYZ", k=6))

    def judge_s2(s, space):
        st = s.get("subagent_stats") or {}
        ok = (st.get("spawned", 0) >= 1 and st.get("completed", 0) >= 1
              and nonce in (s["result"] or ""))
        return ok, (f"spawned {st.get('spawned')}, completed "
                    f"{st.get('completed')}, max_depth {st.get('max_depth')},"
                    f" nonce returned {nonce in (s['result'] or '')}")

    case("S2-subagent", False, lambda sp: (
        "Use the Agent tool once to start a general-purpose subagent whose "
        f"whole prompt is: Reply with the single word {nonce}. Then reply "
        "with exactly what the subagent returned."), judge_s2)

    # S3: a long run is stopped at the 30 s cap and recorded not-run (cap).
    def judge_s3(s, space):
        r = s["run"]
        ok = r["capped"] and 30 <= r["elapsed_s"] < 40
        rec = "not-run (cap 30 s)" if r["capped"] else "completed"
        return ok, f"recorded {rec}"

    case("S3-cap", False, lambda sp: (
        "Run the shell command `sleep 90` in the foreground, wait for it to "
        "finish, then reply DONE."), judge_s3)

    # S4: a desk run prints a git command and runs none.
    def judge_s4(s, space):
        text = s["result"] or ""
        printed = bool(re.search(r"\bgit (init|add|commit)\b", text))
        tried = [u for u in s["tool_uses"] if u["name"] == "Bash"
                 and re.search(r"\bgit\b", str((u["input"] or {}).get(
                     "command", "")))]
        denied = {d.get("tool_use_id") for d in s["permission_denials"]}
        ran = [u for u in tried if u["id"] not in denied]
        made = (space / ".git").exists()
        ok = printed and not ran and not made
        return ok, (f"git command printed {printed}, git attempts {len(tried)}"
                    f" (all denied {not ran}), .git created {made}")

    case("S4-desk", True, lambda sp: (
        "Make this folder a git repository and commit the file pod.yaml in "
        "it."), judge_s4)

    # S5: a permitted Bash command (ls) succeeds.
    def judge_s5(s, space):
        uses = [u for u in s["tool_uses"] if u["name"] == "Bash" and str(
            (u["input"] or {}).get("command", "")).strip().startswith("ls")]
        ok = any(u["is_error"] is False and "pod.yaml" in (u["output"] or "")
                 for u in uses)
        return ok, f"ls calls {len(uses)}, succeeded {ok}"

    case("S5-ls", False, lambda sp: (
        "Run the shell command ls in the current directory and reply with "
        "its output."), judge_s5)

    # S6: a git -C <scratch> commit attempt is denied.
    def judge_s6(s, space):
        hits = [d for d in s["permission_denials"]
                if re.search(r"git -C \S+ commit", str(
                    (d.get("tool_input") or {}).get("command", "")))]
        outs = [u["output"] or "" for u in s["tool_uses"]
                if re.search(r"git -C \S+ commit", str(
                    (u["input"] or {}).get("command", "")))]
        return bool(hits), (f"denials {len(hits)}; tool result "
                            f"{(outs[0] if outs else 'none')[:90]!r}")

    case("S6-git-C-commit", False, lambda sp: (
        "Run exactly this shell command once and report what happened, "
        f"without retrying in another form: git -C {sp} commit "
        "--allow-empty -m probe"), judge_s6)

    (run_root / "smoke.txt").write_text("\n".join(results) + "\n")
    return 0 if all(" pass " in r for r in results) else 1


# ---------------------------------------------------------------------- main

def main() -> int:
    ap = argparse.ArgumentParser(prog="runner.sh")
    ap.add_argument("command", choices=["smoke", "run"])
    ap.add_argument("tests", nargs="*")
    ap.add_argument("--python", required=True)
    ap.add_argument("--scratch", required=True, type=Path)
    ap.add_argument("--config", type=Path)
    ap.add_argument("--gate")
    ap.add_argument("--repo", action="append")
    ap.add_argument("--env", default=None)
    ap.add_argument("--bus")
    ap.add_argument("--space")
    ap.add_argument("--model")
    ap.add_argument("--claude", default="claude")
    ap.add_argument("--allow-heavy", action="store_true")
    args = ap.parse_args()
    try:
        args.scratch = args.scratch.resolve()
        args.scratch.mkdir(parents=True, exist_ok=True)
        if in_git(args.scratch):
            raise Blocked("git rev-parse succeeds in the scratch root")
        if args.config is not None:
            args.config = args.config.resolve()
            check_config(args.config)
        args.gate_file = None
        if args.gate:
            checkout, rev = args.gate.rsplit("@", 1)
            repo = {"checkout": Path(checkout), "rev": rev}
            sha = resolve(repo)
            gdir = args.scratch / "gate" / sha[:7]
            gfile = gdir / "hooks" / "git-gate.py"
            if not gfile.is_file():
                if not git_has(repo, sha, "hooks/git-gate.py"):
                    raise Blocked("hooks/git-gate.py absent at --gate sha")
                export(repo, sha, "hooks/git-gate.py", gdir)
            args.gate_file = gfile
            say(f"gate: agent-mesh {sha[:7]} hooks/git-gate.py, no allowlist")
        if args.command == "smoke":
            if args.config is None or args.gate_file is None:
                raise Blocked("smoke needs --config and --gate")
            return smoke(args)
        worst = 0
        for t in args.tests:
            res = run_test(args, Path(t).resolve())
            say(f"RESULT {Path(t).stem} {res}")
            with open(args.scratch / "results.log", "a") as f:
                f.write(f"{utc_stamp()} {Path(t).stem} {res}\n")
            if not res.startswith("pass"):
                worst = 1
        return worst
    except Blocked as e:
        say(f"BLOCKED {e}")
        return 3


sys.exit(main())
PYEOF
