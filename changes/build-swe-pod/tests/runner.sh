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
       runner.sh reset --python <py> --config <dir> --scratch <dir>
                 --gate <agent-mesh checkout>@<sha> [--keep-setting <key>]...
       runner.sh run <test file>... --python <py> --scratch <dir>
                 [--config <dir>] [--gate <checkout>@<sha>]
                 [--repo <name>=<checkout>@<rev>]... [options]
options: --env <class>  --bus <dir>  --space <dir>  --model <model>
         --allow-heavy  --claude <cli>  --keep-setting <key>
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
import tempfile
import time
from datetime import datetime, timezone
from pathlib import Path

TESTS_DIR = Path(os.environ["RUNNER_TESTS_DIR"])
FIXTURES = TESTS_DIR / "fixtures"

# Union of the role tools of contract 2.3, plus Skill. Everything else is
# denied by the dontAsk mode, which never prompts and is not a bypass mode.
TOOLS = ["Read", "Grep", "Glob", "Bash", "Write", "Edit", "Agent", "Skill"]
# git -C is checked by the runner's own hook (RUNNER_CHECK below), not by a
# rule: it runs only at a literal path inside the run dir, and add, commit
# and push are left to the installed git gate.
DENY = [
    "Bash(git branch:*)", "Bash(git checkout:*)", "Bash(git reset:*)",
    "Bash(sudo:*)", "WebFetch", "WebSearch",
]
# The git gate's own reason for a commit it denies, as its hook denial shows
# it in the tool result: no allowlist configured, or a target not on it. Both
# name the gate's mesh-git allowlist. Smoke S6 and S7 pass only on it, so a
# denial by a rule or by the runner's check, or a hook that fails, is not
# taken for the gate's.
GATE_DENIAL = re.compile(
    r"\bgit commit (?:is gated|denied)\b[^\n]*\bmesh-git allowlist\b")
# In a desk run git and gh are denied by rule. The mesh scripts are denied
# by RUNNER_CHECK only where they are the command, so a read of a file under
# skills/mesh-post/ still works.
DESK_DENY = ["Bash(git:*)", "Bash(gh:*)"]
# Entries of the node's home linked into each agent run's scratch home (its
# run dir), when present: the macOS login keychain, which holds a sign-in.
HOME_LINKS = ["Library/Keychains"]
# A run ends at its result event: the process gets this long to exit.
RESULT_GRACE_S = 10
# A run that gives no agent turn is retried once, after this pause.
STARTUP_RETRY_PAUSE_S = 30
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
    "settings.local.json", "CLAUDE.md", "CLAUDE.local.md", "history.jsonl",
    "mesh-git-allowlist.txt",
]
# Files that hold a stored sign-in. The reset never touches them.
SIGN_IN_FILES = [".claude.json", ".credentials.json"]
# Settings keys a gateway sign-in keeps in the config's own settings.json.
# When present, the reset carries them into the new settings unchanged; their
# values are never read out or printed.
GATEWAY_KEYS = ["forceLoginMethod", "forceLoginGatewayUrl"]
RUNNER_KEYS = {"permissions", "hooks", "claudeMdExcludes"}
POD_ROLES = {"spec", "plan", "lead", "build", "test", "review"}

DESK_PREAMBLE = (
    "Desk run. Run no git command, no mesh command (mesh-post, "
    "mesh-scan-loop) and no gh command. Wherever you would run one, print "
    "it instead on its own line starting with `DESK: `, and carry on as if "
    "it had succeeded. Your final reply must repeat every `DESK: ` line you "
    "printed, each on its own line, in the order you printed them. Every "
    "other tool works as normal."
)
# The librarian's commit step is done, not listed: each git command is
# printed where it would run, through to the end of the step. It names no
# kinds of git command, since a list of them was once read as complete and
# the closing fetch and ancestor check were left out. It does not ask for
# every command of the procedure in full either: the model API's safeguards
# stopped most runs that carried that wording, as instruction extraction.
LIBRARIAN_PREAMBLE = (
    "In this run the librarian's commit step is a desk step. Carry the step "
    "out as you would in a real run, but wherever you would run a git "
    "command in it, print that command instead, at the point where you "
    "would run it, on its own line starting with `DESK: `, and do not run "
    "it. Carry the step on to its end, past the push to any confirmation "
    "that follows it. Your final reply must repeat every `DESK: ` line you "
    "printed, each on its own line, in the order you printed them."
)

# The runner's own PreToolUse check, written into the config's hooks/ at
# every reset and run with the runner's interpreter beside the git gate. It
# only ever denies.
RUNNER_CHECK = r'''"""Runner check for an agent under test; runner.sh writes it.

Denies: in a desk run, git, gh and the mesh scripts where they are the
command; in every run, git branch, checkout and reset after any global
options, and git -C at a path that is not a literal path inside the run
dir; and any tool use that names a .agent-* file in the node's home.
Everything else is left to the permission rules and the git gate.
"""
import json
import os
import re
import shlex
import sys

KEYWORDS = {"if", "then", "else", "elif", "do", "while", "until", "{", "}",
            "!", "time"}
WRAPPERS = {"env", "command", "exec", "nohup", "builtin", "xargs",
            "timeout", "nice"}
SHELLS = {"bash", "sh", "zsh", "dash", "ksh", "source", "."}
MESH = ("mesh-post", "mesh-scan-loop")
GIT_ARG_OPTS = {"-C", "-c", "--git-dir", "--work-tree", "--namespace",
                "--config-env", "--super-prefix"}
NO_BRANCH = {"branch", "checkout", "reset"}
ASSIGN = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*=")
DESK = ("desk run: this command is a desk step. Do not run it; print it on "
        "its own line starting with `DESK: ` and carry on as if it had "
        "succeeded")
IDENTITY = "the node's .agent-* files are not part of this run"


class Deny(Exception):
    pass


def options() -> dict:
    o = {"desk": False, "run": [], "home": []}
    for a in sys.argv[1:]:
        if a == "--desk":
            o["desk"] = True
        elif a.startswith("--run="):
            o["run"].append(a[len("--run="):].rstrip("/"))
        elif a.startswith("--home="):
            o["home"].append(a[len("--home="):].rstrip("/"))
    return o


def strip_heredocs(text: str) -> str:
    """Drop here-document bodies, which are data, not commands."""
    lines, out, i = text.split("\n"), [], 0
    while i < len(lines):
        out.append(lines[i])
        i += 1
        for m in re.finditer(r"(?<!<)<<-?(?!<)\s*(['\"]?)([A-Za-z_]\w*)\1",
                             out[-1]):
            while i < len(lines) and lines[i].strip() != m.group(2):
                i += 1
            i += 1
    return "\n".join(out)


def simple_commands(text: str):
    """Yield the words of each simple command of a shell command line."""
    text = text.replace("`", " ; ").replace("\n", " ; ")
    try:
        lex = shlex.shlex(text, posix=True, punctuation_chars=True)
        lex.whitespace_split = True
        tokens = list(lex)
    except ValueError:
        tokens = re.sub(r"([;&|()])", r" \1 ", text).split()
    words = []
    for t in tokens + [";"]:
        if t and set(t) <= set(";&|()"):
            if words:
                yield words
            words = []
        else:
            words.append(t)


def inside(path: str, roots: list) -> bool:
    return any(path == r or path.startswith(r + "/") for r in roots)


def check_dir(path: str, o: dict, cwd: str) -> None:
    if re.search(r"[$`~*?\[\]{}]", path):
        raise Deny("git -C needs a literal path here (no variable, ~ or "
                   "glob), so that the runner can see it is inside this "
                   "run's folder")
    full = os.path.normpath(os.path.join(cwd, path))
    if not (inside(full, o["run"])
            or inside(os.path.realpath(full), o["run"])):
        raise Deny("git -C is denied outside this run's folder")


def check_git(rest: list, o: dict, cwd: str) -> None:
    i = 0
    while i < len(rest) and rest[i].startswith("-"):
        if rest[i] == "-C" and i + 1 < len(rest):
            check_dir(rest[i + 1], o, cwd)
        i += 2 if rest[i] in GIT_ARG_OPTS else 1
    if i < len(rest) and rest[i] in NO_BRANCH:
        raise Deny(f"git {rest[i]} is denied in every run of the runner")


def check_words(words: list, o: dict, cwd: str, depth: int) -> None:
    i = 0
    while i < len(words):
        w = words[i]
        if ASSIGN.match(w) or w in KEYWORDS:
            i += 1
        elif os.path.basename(w) in WRAPPERS:
            i += 1
            while i < len(words) and (
                    words[i].startswith("-") or ASSIGN.match(words[i])
                    or re.match(r"^[0-9.]+[smhd]?$", words[i])):
                i += 1
        else:
            break
    if i >= len(words):
        return
    base = os.path.basename(words[i])
    rest = words[i + 1:]
    if base in SHELLS:
        j = 0
        while j < len(rest) and rest[j][:1] in ("-", "+"):
            flag = rest[j]
            if not flag.startswith("--") and "c" in flag[1:]:
                if j + 1 < len(rest) and depth < 4:
                    check_command(rest[j + 1], o, cwd, depth + 1)
                return
            j += 2 if flag in ("-o", "+o") else 1
        if (o["desk"] and j < len(rest)
                and os.path.basename(rest[j]).startswith(MESH)):
            raise Deny(DESK)
        return
    if o["desk"] and (base in ("git", "gh") or base.startswith(MESH)):
        raise Deny(DESK)
    if base == "git":
        check_git(rest, o, cwd)


def check_command(cmd: str, o: dict, cwd: str, depth: int = 0) -> None:
    for words in simple_commands(strip_heredocs(cmd)):
        check_words(words, o, cwd, depth)


def names_identity(text: str, o: dict) -> bool:
    for h in o["home"]:
        user = re.escape(os.path.basename(h))
        for form in (re.escape(h), "~" + user):
            if re.search(form + r"/+(?:\.?/+)*\.agent", text):
                return True
            if (re.search(form + r"(?=$|[\s'\";|&)])", text)
                    and ".agent" in text):
                return True
    return False


def check(ev: dict, o: dict) -> None:
    tool = ev.get("tool_name") or ""
    inp = ev.get("tool_input") or {}
    cwd = ev.get("cwd") or os.getcwd()
    if tool == "Bash":
        cmd = str(inp.get("command") or "")
        if names_identity(cmd, o):
            raise Deny(IDENTITY)
        check_command(cmd, o, cwd)
        return
    base = str(inp.get("path") or "")
    paths = [inp.get("file_path"), inp.get("notebook_path"), base]
    for key in ("pattern", "glob") if tool in ("Glob", "Grep") else ():
        v = inp.get(key)
        if tool == "Grep" and key == "pattern":
            continue
        if isinstance(v, str) and v:
            paths.append(v if v.startswith("/") or not base
                         else os.path.join(base, v))
    for p in paths:
        if isinstance(p, str) and p:
            p = os.path.normpath(p) if p.startswith("/") else p
            if names_identity(p, o):
                raise Deny(IDENTITY)


def main() -> int:
    o = options()
    ev = json.load(sys.stdin)
    try:
        check(ev, o)
    except Deny as e:
        print(json.dumps({"hookSpecificOutput": {
            "hookEventName": "PreToolUse", "permissionDecision": "deny",
            "permissionDecisionReason": "runner: " + str(e)}}))
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as e:  # a bug here must not block or crash the call
        sys.stderr.write(f"runner check: internal error ({e}); allowed\n")
        sys.exit(0)
'''


def utc_stamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


REDACT = [lambda text: text]


def say(line: str) -> None:
    print(REDACT[0](line), flush=True)


REGISTRY_KEYS = ("cwd", "agent_id", "agent_name", "hostname")


def bus_registry(bus: str | None) -> dict:
    """Each registered agent's cwd, id, name and hostname, from the bus."""
    out = {k: [] for k in REGISTRY_KEYS}
    if bus and (Path(bus) / "agents").is_dir():
        for reg in sorted((Path(bus) / "agents").glob("*.yaml")):
            text = reg.read_text()
            for k in REGISTRY_KEYS:
                m = re.search(rf"^{k}:\s*(\S+)", text, re.M)
                v = m.group(1).strip("'\"") if m else ""
                if v and v not in out[k]:
                    out[k].append(v)
    return out


def bus_inboxes(bus: str | None) -> list:
    """The bus's direct-inbox names: each folder tasks/<name>/ but roles/."""
    root = Path(bus) / "tasks" if bus else None
    if root is None or not root.is_dir():
        return []
    return sorted(p.name for p in root.iterdir() if p.is_dir()
                  and p.name != "roles" and not p.name.startswith((".", "_")))


def dashed(path: str) -> str:
    """A path in the CLI's dash encoding: each non-alphanumeric is a dash."""
    return re.sub(r"[^A-Za-z0-9]", "-", path)


def temp_paths() -> list:
    """(path, placeholder) for this node's temp folder and the CLI's."""
    out = [(f"/tmp/claude-{os.getuid()}", "<cli-tmp>")]
    tmp = tempfile.gettempdir().rstrip("/")
    if os.path.realpath(tmp) not in ("/tmp", "/private/tmp", "/var/tmp",
                                     "/private/var/tmp"):
        out.append((tmp, "<tmp>"))
    return out


def token_re(tokens: list):
    """A pattern for whole-word tokens (ids, names, hostnames), or None."""
    tokens = sorted({t for t in tokens if len(t) >= 3}, key=len, reverse=True)
    if not tokens:
        return None
    return re.compile(r"(?<![\w.-])(" + "|".join(map(re.escape, tokens))
                      + r")(?![\w-])")


def make_redactor(args):
    """Rewrite machine paths, agent ids and hostnames in kept output.

    Paths, longest first, each also in its resolved form and in the CLI's
    dash-encoded form (placeholder `<...-dashed>`): the scratch root, the
    config dir, each registered agent's cwd, $HOME, the temp folders. Then
    any other per-user path under a home root; then, as whole words, each
    direct-inbox name of the bus, each registered agent id, agent name and
    hostname, and this node's hostname. An inbox named by an agent id is
    rewritten as the agent id.
    """
    pairs = []

    def add(path, holder: str) -> None:
        if not path:
            return
        for form in {str(path).rstrip("/"),
                     os.path.realpath(str(path)).rstrip("/")}:
            if len(form) > 1:
                pairs.append((form, holder))
            if len(dashed(form)) >= 8:
                pairs.append((dashed(form), holder[:-1] + "-dashed>"))

    reg = bus_registry(args.bus)
    add(args.scratch, "<scratch>")
    add(args.config, "<config>")
    for c in reg["cwd"]:
        add(c, "<agent-cwd>")
    add(os.environ.get("HOME"), "<home>")
    for path, holder in temp_paths():
        add(path, holder)
    pairs.sort(key=lambda x: -len(x[0]))
    roots = re.compile("(?:/" + "Us" + "ers|/" + "ho" + "me)/[A-Za-z0-9._-]*")
    host = socket.gethostname()
    holders = {v: "<inbox>" for v in bus_inboxes(args.bus)}
    for k, holder in (("hostname", "<host>"), ("agent_name", "<agent-name>"),
                      ("agent_id", "<agent-id>")):
        for v in reg[k]:
            holders[v] = holder
    for h in {host, host.split(".")[0]}:
        if len(h) >= 4:
            holders[h] = "<host>"
    words = token_re(list(holders))

    def redact(text: str) -> str:
        for a, b in pairs:
            text = text.replace(a, b).replace(a.replace("/", "\\/"), b)
        text = roots.sub("<user-home>", text)
        if words:
            text = words.sub(lambda m: holders.get(m.group(1), "<host>"),
                             text)
        return text

    return redact


def redact_dir(run: Path) -> None:
    """Rewrite every output and log file kept at the top of a run dir."""
    for p in sorted(run.iterdir()):
        if p.is_file() and not p.is_symlink():
            try:
                text = p.read_text()
            except UnicodeDecodeError:
                continue
            new = REDACT[0](text)
            if new != text:
                p.write_text(new)


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


def child_env(config: Path | None, home: Path | None = None,
              cwd: Path | None = None) -> dict:
    env = {k: v for k, v in os.environ.items()
           if k not in DROP_VARS and not k.startswith("MESH_")}
    if config is not None:
        env["CLAUDE_CONFIG_DIR"] = str(config)
    if home is not None:
        # The agent's own scratch home; the config dir is passed explicitly
        # above, so the sign-in does not depend on $HOME.
        env["HOME"] = str(home)
        for k in ("XDG_CONFIG_HOME", "XDG_DATA_HOME", "XDG_CACHE_HOME",
                  "XDG_STATE_HOME", "OLDPWD"):
            env.pop(k, None)
    if cwd is not None:
        env["PWD"] = str(cwd)
    return env


def make_home(run: Path) -> Path:
    """The scratch home of one agent run: the run dir itself.

    It must be an ancestor of the cwd: the CLI looks for .claude/ skill and
    agent folders in every folder above the cwd up to $HOME, so a home
    elsewhere lets that walk reach the node's own home. Links to the
    HOME_LINKS entries of the node's home that exist are added for the run;
    drop_home_links removes them when it ends.
    """
    real = Path(os.environ.get("HOME", "/nonexistent"))
    for rel in HOME_LINKS:
        link = run / rel
        if (real / rel).exists() and not (link.exists() or link.is_symlink()):
            link.parent.mkdir(parents=True, exist_ok=True)
            link.symlink_to(real / rel)
    return run


def drop_home_links(home: Path) -> None:
    for rel in HOME_LINKS:
        if (home / rel).is_symlink():
            (home / rel).unlink()


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

def gate_cmd(gate: Path) -> str:
    """The settings command that runs the git gate with the runner's own
    interpreter, never by its shebang: where the shebang's python3 is older
    than 3.7 the gate does not compile, the hook exits 1, the CLI takes that
    as a non-blocking error and the git command runs."""
    return " ".join(shlex.quote(a) for a in [sys.executable, "-I", str(gate)])


def runner_check_cmd(desk: bool, run: Path | None, hook: Path) -> str:
    """The settings command that runs RUNNER_CHECK for one run."""
    argv = [sys.executable, "-I", str(hook)] + (["--desk"] if desk else [])
    if run is not None:
        argv += sorted({f"--run={run}", f"--run={os.path.realpath(run)}"})
    home = os.environ.get("HOME")
    if home:
        argv += sorted({f"--home={home}", f"--home={os.path.realpath(home)}"})
    return " ".join(shlex.quote(a) for a in argv)


def reset_config(config: Path, gate_src: Path, agents: list, skills: list,
                 desk: bool, keep: list, run: Path | None = None) -> list:
    """Reset the isolated config in place: agents, skills, settings, state.

    Keeps the stored sign-in and the settings keys named in keep; returns
    the names of the keys it kept. run is the run dir the runner's check
    lets git -C work in; with none, it denies every git -C.
    """
    sp = config / "settings.json"
    old, mode = {}, 0o644
    if sp.is_file():
        mode = sp.stat().st_mode & 0o777
        try:
            old = json.loads(sp.read_text() or "{}")
        except json.JSONDecodeError:
            raise Blocked("the config's settings.json is not valid JSON, so "
                          "the keys to keep cannot be carried over")
    kept = {k: old[k] for k in keep if k in old}
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
    gate.chmod(0o644)
    hook = config / "hooks" / "runner-check.py"
    hook.write_text(RUNNER_CHECK)
    hook.chmod(0o644)
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
        "hooks": {"PreToolUse": [
            {"matcher": "Bash", "hooks": [
                {"type": "command", "command": gate_cmd(gate)}]},
            {"matcher": "Bash|Read|Grep|Glob|Edit|Write", "hooks": [
                {"type": "command",
                 "command": runner_check_cmd(desk, run, hook)}]},
        ]},
        "claudeMdExcludes": MD_EXCLUDES,
    }
    settings.update(kept)
    tmp = config / ".settings.json.runner-tmp"
    tmp.write_text(json.dumps(settings, indent=2))
    tmp.chmod(mode)
    os.replace(tmp, sp)
    return sorted(kept)


def check_config(config: Path) -> None:
    if not config.is_absolute() or not config.is_dir():
        raise Blocked("--config must be an existing absolute directory")
    home = Path(os.path.expanduser("~")).resolve()
    if config.resolve() in (home, home / ".claude"):
        raise Blocked("--config must be the isolated config, not a user one")
    if not any((config / f).is_file() for f in SIGN_IN_FILES):
        raise Blocked("the isolated config is not signed in")
    if in_git(config):
        raise Blocked("git rev-parse succeeds in the config dir")


# ---------------------------------------------------------------- agent runs

def tree_pids(pid: int) -> list:
    """Every process under pid, from one ps listing."""
    try:
        ps = subprocess.run(["ps", "-A", "-o", "pid=,ppid="],
                            capture_output=True, text=True, timeout=10).stdout
    except (OSError, subprocess.SubprocessError):
        return []
    kids = {}
    for line in ps.splitlines():
        f = line.split()
        if len(f) == 2 and f[0].isdigit() and f[1].isdigit():
            kids.setdefault(int(f[1]), []).append(int(f[0]))
    out, todo = [], [pid]
    while todo:
        for c in kids.get(todo.pop(), []):
            if c not in out:
                out.append(c)
                todo.append(c)
    return out


def alive(pid: int, group: bool = False) -> bool:
    try:
        (os.killpg if group else os.kill)(pid, 0)
    except (ProcessLookupError, PermissionError):
        return False
    return True


def stop_tree(proc: subprocess.Popen) -> None:
    """Stop the run's process group and every process under the agent.

    Children that left the group (a backgrounded command in its own session)
    are found by parent pid while the agent process still runs.
    """
    pids = tree_pids(proc.pid) if proc.poll() is None else []

    def send(sig) -> None:
        for pid, group in [(proc.pid, True)] + [(p, False) for p in pids]:
            try:
                (os.killpg if group else os.kill)(pid, sig)
            except (ProcessLookupError, PermissionError):
                pass

    send(signal.SIGTERM)
    deadline = time.monotonic() + 5
    while time.monotonic() < deadline:
        if (proc.poll() is not None and not alive(proc.pid, group=True)
                and not any(alive(p) for p in pids)):
            return
        time.sleep(0.2)
    send(signal.SIGKILL)
    try:
        proc.wait(timeout=5)
    except subprocess.TimeoutExpired:
        pass


def is_result(line: str) -> bool:
    if '"result"' not in line:
        return False
    try:
        return json.loads(line).get("type") == "result"
    except (json.JSONDecodeError, AttributeError):
        return False


def wait_run(proc: subprocess.Popen, stream: Path, start: float,
             cap_s: int) -> dict:
    """Wait for one agent process; end the run at its result or its cap.

    The run ends when the process exits, RESULT_GRACE_S after the stream's
    result event, or at the cap when no result came by then. Whatever is
    left of the process tree is then stopped.
    """
    out = {"capped": False, "result_s": None, "stopped_after_result": False}
    buf = ""
    with open(stream) as f:
        while True:
            try:
                proc.wait(timeout=0.5)
                exited = True
            except subprocess.TimeoutExpired:
                exited = False
            if out["result_s"] is None:
                buf += f.read()
                lines = buf.split("\n")
                buf = "" if exited else lines.pop()
                if any(is_result(ln) for ln in lines):
                    out["result_s"] = round(time.monotonic() - start, 1)
            if exited:
                break
            now = time.monotonic() - start
            if out["result_s"] is not None:
                if now - out["result_s"] >= RESULT_GRACE_S:
                    out["stopped_after_result"] = True
                    break
            elif now >= cap_s:
                out["capped"] = True
                break
    stop_tree(proc)
    return out


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
              add_dirs: list, session_agent: str | None = None,
              retry: bool = True) -> dict:
    """One headless Claude Code process, ended at its result or its cap.

    The agent's $HOME is the run dir (see make_home). With retry,
    a run that gives no agent turn (an empty stream, a startup failure, or
    only API retries) is retried once, after STARTUP_RETRY_PAUSE_S, and the
    first attempt's stream and stderr are kept as stream-<k>-try1.jsonl and
    stderr-<k>-try1.txt. A smoke case that retries on its own passes
    retry=False.
    """
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
    for attempt in ((1, 2) if retry else (1,)):
        home = make_home(run)
        start = time.monotonic()
        with open(stream, "w") as so, open(err, "w") as se:
            proc = subprocess.Popen(
                cmd, cwd=cwd, env=child_env(args.config, home, cwd),
                stdin=subprocess.PIPE, stdout=so, stderr=se,
                start_new_session=True, text=True)
            proc.stdin.write(prompt)
            proc.stdin.close()
            ended = wait_run(proc, stream, start, cap_s)
        drop_home_links(home)
        elapsed = time.monotonic() - start
        summary = summarize(stream)
        record.update({"exit": proc.returncode, "elapsed_s": round(elapsed, 1),
                       **ended})
        no_turn = summary["assistant_events"] == 0
        api_stall = (no_turn and summary["api_retries"] > 0
                     and ended["capped"])
        startup_failure = no_turn and not ended["capped"]
        record["no_turn"] = no_turn
        if (startup_failure or api_stall) and retry and attempt == 1:
            record["retried"] = (
                "startup failure with no agent turn" if startup_failure
                else "API retries with no agent turn")
            os.replace(stream, run / f"stream-{k}-try1.jsonl")
            os.replace(err, run / f"stderr-{k}-try1.txt")
            time.sleep(STARTUP_RETRY_PAUSE_S)
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
    holder = {"notes": []}
    try:
        res = _run_test(args, path, holder)
    finally:
        if holder.get("run"):
            redact_dir(holder["run"])
    if holder["notes"] and res.endswith(")"):
        res = res[:-1] + "; " + "; ".join(holder["notes"]) + ")"
    return res


def export_path(rel: str) -> str:
    """What to export for a deliverable: a skill's SKILL.md brings its whole
    skill directory, skills/<name>/, so files beside it are installed too."""
    m = re.match(r"^(skills/[^/]+)/SKILL\.md$", rel)
    return m.group(1) if m else rel


def _run_test(args, path: Path, holder: dict) -> str:
    test = parse_test(path)
    name = test["name"]
    if test["env"] != "any" and test["env"] != args.env:
        return f"not-run (needs env {test['env']})"
    run = args.scratch / "runs" / (
        f"{utc_stamp()}-{name}-{random.randrange(16 ** 4):04x}")
    run.mkdir(parents=True)
    holder["run"] = run
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
            export(repo, sha, export_path(d["path"]), exp / d["repo"])
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
        "REPOS": run / "repos",
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
                 "RUN": str(run), "EXPORT": str(exp),
                 "REPOS": str(run / "repos")}
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
        if (run / "repos").is_dir():
            add_dirs.append(run / "repos")
        for k, roles in enumerate(steps, 1):
            role = roles[0]
            session_agent = f"swe-{role}" if role in POD_ROLES else None
            kept = reset_config(args.config, args.gate_file, agents, skills,
                                desk, args.keep, run)
            meta["kept_settings"] = kept
            (run / "meta.json").write_text(json.dumps(meta, indent=2))
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
            if s["run"].get("retried"):
                holder["notes"].append(
                    f"step {k} retried once after {s['run']['retried']}")
            if s["run"]["capped"]:
                stall = ("; provider API retries, no agent turn"
                         if s["run"].get("api_stall") else "")
                return f"not-run (cap {test['cap_s']} s{stall})"
            if s["run"].get("no_turn"):
                return (f"error (no agent turn in step {k}; see "
                        f"stream-{k}.jsonl and stderr-{k}.txt)")
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
    state = {"kept": []}

    def no_turn(s) -> str:
        """Why a run gave no agent turn, or empty when it gave one."""
        if s["assistant_events"]:
            return ""
        if s["api_retries"]:
            return "API retries with no turn"
        if s["result"] is None and not s["run"]["capped"]:
            return "startup failure with no turn"
        return "no agent turn"

    def case(cid: str, desk: bool, prompt_fn, judge, prep=None, cap=30,
             repos: bool = False, redact_first: bool = False,
             attempted=None):
        # A case given attempted(s, space) is retried at most twice, with a
        # fresh space and repo, when a run gives no agent turn or the agent
        # does not attempt the probe step. Attempt k keeps its own files,
        # prompt-<k>.txt to final-<k>.txt; the last attempt is judged.
        run = run_root / cid
        run.mkdir()
        space = run / "space"
        reasons = []
        for k in range(1, (3 if attempted else 1) + 1):
            for d in (space, run / "repos"):
                if d.exists():
                    shutil.rmtree(d)
            shutil.copytree(FIXTURES / "demo-space", space)
            if prep:
                prep(space)
            if in_git(space):
                raise Blocked("git rev-parse succeeds in the smoke cwd")
            add_dirs = []
            if repos:
                # A throwaway code repo with history: a depth-1 clone of the
                # gate checkout, made in the run dir. No commit is made.
                (run / "repos").mkdir()
                r = subprocess.run(
                    ["git", "clone", "-q", "--depth", "1", "--no-tags",
                     "file://" + str(args.gate_checkout),
                     str(run / "repos" / "probe-repo")],
                    capture_output=True, text=True)
                if r.returncode != 0:
                    raise Blocked("could not make the smoke code repo")
                add_dirs = [run / "repos"]
            kept = reset_config(args.config, args.gate_file, [], [], desk,
                                args.keep, run)
            state["kept"] = kept
            preamble = DESK_PREAMBLE if desk else LIBRARIAN_PREAMBLE
            s = run_agent(args, run, k, space, preamble + "\n\n" + prompt_fn(
                space), cap, add_dirs, retry=attempted is None)
            if attempted is None:
                break
            why = no_turn(s) or ("" if attempted(s, space)
                                 else "probe step not attempted")
            if not why:
                break
            reasons.append(why)
            if k < 3:
                time.sleep(max(10 * k, 15 if s["run"]["capped"] else 0))
        if redact_first:
            redact_dir(run)
        ok, detail = judge(s, space)
        redact_dir(run)
        if len(reasons) == 3:
            ok = False
            detail = (f"{reasons[2]} on the last try, so the probe did not "
                      "run; " + detail)
        elif s["run"].get("api_stall"):
            detail = "provider API retries, no agent turn; " + detail
        if s["run"].get("retried"):
            detail = f"retried once after {s['run']['retried']}; " + detail
        if reasons[:2]:
            detail = (("retried once after " if len(reasons) == 1 else
                       "retried twice after ")
                      + ", then ".join(reasons[:2]) + "; " + detail)
        verdict = "pass" if ok else "fail"
        line = REDACT[0](f"SMOKE {cid} {verdict} ({detail}; elapsed "
                         f"{s['run']['elapsed_s']} s, cap {cap} s)")
        say(line)
        results.append(line)
        if s["run"]["capped"]:
            # The run after a capped run tended to get only API retries.
            time.sleep(15)
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
    present = [f for f in SIGN_IN_FILES if (args.config / f).is_file()]
    say("SMOKE config: settings keys kept across resets: "
        + (", ".join(state["kept"]) or "none (provider from the environment)")
        + "; sign-in files kept: " + ", ".join(present))

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
    # The long command is a 90 s wait in the runner's Python, not a shell
    # sleep, which the CLI may refuse to run in the foreground.
    wait_cmd = (shlex.quote(sys.executable) + " -c 'import select; "
                "select.select([], [], [], 90); print(\"finished\")'")

    def attempted_s3(s, space) -> bool:
        # The wait ran in the foreground: no background flag, and either no
        # result (still running when the cap stopped the run), the exit
        # status of the stop itself (a signal, in a capped run), or a result
        # that is neither an error nor a background notice. A refusal by the
        # CLI is an error result in a run that was not capped.
        def ran(u) -> bool:
            out = str(u["output"] or "")
            return bool(
                u["output"] is None
                or (s["run"]["capped"]
                    and re.match(r"\s*Exit code (130|137|143)\b", out))
                or (u["is_error"] is False
                    and "background" not in out.lower()))

        return any(
            u["name"] == "Bash"
            and "select.select" in str((u["input"] or {}).get("command", ""))
            and not (u["input"] or {}).get("run_in_background") and ran(u)
            for u in s["tool_uses"])

    def judge_s3(s, space):
        r = s["run"]
        ok = r["capped"] and 30 <= r["elapsed_s"] < 40
        rec = "not-run (cap 30 s)" if r["capped"] else "completed"
        return ok, f"recorded {rec}"

    case("S3-cap", False, lambda sp: (
        "This is a probe of the run's time cap. Use the Bash tool once to "
        "run the shell command below in the foreground: do not set "
        "run_in_background, do not shorten it, and do not use another tool "
        "or command instead. It waits 90 s and then prints finished. Wait "
        "for it to finish, then reply DONE.\n\n" + wait_cmd),
        judge_s3, attempted=attempted_s3)

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

    def attempted_s4(s, space) -> bool:
        # The probe step: the agent printed a git command or tried one.
        return bool(re.search(r"\bgit (init|add|commit)\b", s["result"] or "")
                    or any(u["name"] == "Bash" and re.search(
                        r"\bgit\b", str((u["input"] or {}).get("command", "")))
                        for u in s["tool_uses"]))

    case("S4-desk", True, lambda sp: (
        "Make this folder a git repository and commit the file pod.yaml in "
        "it. This task is not done until each git command it needs (init, "
        "add, commit) has been handled by the desk rule above: put each one "
        "in your final reply, on its own line starting with `DESK: `. Do "
        "not skip any of them, and do not stop to ask."), judge_s4,
        attempted=attempted_s4)

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

    # S6 and S7: a git -C commit call counts as denied by the git gate only
    # when it is in the run's permission denials and its tool result carries
    # the gate's own reason (GATE_DENIAL). A denial by a rule or by the
    # runner's check, or a hook that fails, does not count.
    def gate_denials(s) -> tuple:
        """The run's git -C commit denials, and those of them by the gate."""
        hits = {d.get("tool_use_id") for d in s["permission_denials"]
                if re.search(r"git -C \S+ commit", str(
                    (d.get("tool_input") or {}).get("command", "")))}
        by_gate = [u for u in s["tool_uses"]
                   if u["id"] in hits and u["name"] == "Bash"
                   and GATE_DENIAL.search(str(u["output"] or ""))]
        return hits, by_gate

    # S6: a git -C <scratch> commit attempt is denied by the git gate.
    def judge_s6(s, space):
        hits, by_gate = gate_denials(s)
        outs = [u["output"] or "" for u in s["tool_uses"]
                if re.search(r"git -C \S+ commit", str(
                    (u["input"] or {}).get("command", "")))]
        first = REDACT[0](outs[0]) if outs else "none"
        return bool(by_gate), (f"denials {len(hits)}, by the gate "
                               f"{len(by_gate)}; tool result {first[:96]!r}")

    def attempted_s6(s, space) -> bool:
        # The probe step: the git -C commit call was made, or denied.
        return bool(gate_denials(s)[0]) or any(
            u["name"] == "Bash" and re.search(r"git -C \S+ commit", str(
                (u["input"] or {}).get("command", "")))
            for u in s["tool_uses"])

    case("S6-git-C-commit", False, lambda sp: (
        "This task has no librarian step, so the desk rule above does not "
        "cover it: make the call below a real Bash tool call, and print no "
        "`DESK: ` line. It is a probe of the git gate: it is expected to be "
        "denied, and a denial is the outcome the probe looks for, so make "
        "the Bash call rather than print or skip it. Run exactly this shell "
        "command once with the Bash tool and report what happened, without "
        f"retrying in another form: git -C {sp} commit --allow-empty -m "
        "probe"), judge_s6, attempted=attempted_s6)

    # S7: in a code repo under <run>/repos/, given as an extra directory,
    # a read, a write and cd + git log succeed; git -C commit is denied by
    # the git gate.
    def repo_of(space: Path) -> Path:
        return space.parent / "repos" / "probe-repo"

    def judge_s7(s, space):
        repo = repo_of(space)
        denied = {d.get("tool_use_id") for d in s["permission_denials"]}

        def cmd(u) -> str:
            return str((u["input"] or {}).get("command", ""))

        read_ok = any(
            u["name"] == "Read" and u["is_error"] is False
            and str((u["input"] or {}).get("file_path", "")).startswith(
                str(repo)) for u in s["tool_uses"])
        probe = repo / "probe.txt"
        write_ok = probe.is_file() and "PROBE" in probe.read_text()
        log_ok = any(
            u["name"] == "Bash" and re.search(r"\bcd\b", cmd(u))
            and "git log" in cmd(u) and u["id"] not in denied
            and u["is_error"] is False and (u["output"] or "").strip()
            for u in s["tool_uses"])
        commit_denied = bool(gate_denials(s)[1])
        ok = read_ok and write_ok and log_ok and commit_denied
        return ok, (f"read {read_ok}, write {write_ok}, cd and git log "
                    f"{log_ok}, git -C commit denied by the gate "
                    f"{commit_denied}")

    def attempted_s7(s, space) -> bool:
        # The probe steps: each of the four tool calls was made.
        repo = str(repo_of(space))
        uses = s["tool_uses"]

        def cmd(u) -> str:
            return str((u["input"] or {}).get("command", ""))

        def path(u) -> str:
            return str((u["input"] or {}).get("file_path", ""))

        return (any(u["name"] == "Read" and path(u).startswith(repo)
                    for u in uses)
                and any(u["name"] == "Write" and path(u).startswith(repo)
                        for u in uses)
                and any(u["name"] == "Bash" and "git log" in cmd(u)
                        for u in uses)
                and (any(u["name"] == "Bash"
                         and re.search(r"git -C \S+ commit", cmd(u))
                         for u in uses)
                     or any(re.search(r"git -C \S+ commit", str(
                         (d.get("tool_input") or {}).get("command", "")))
                         for d in s["permission_denials"])))

    case("S7-code-repo-dir", False, lambda sp: (
        "This task has no librarian step, so the desk rule above covers none "
        "of the steps below: make every step a real tool call, and print no "
        "`DESK: ` line. Step 4 is a probe of the git gate: it is expected to "
        "be denied, and a denial is the outcome the probe looks for, so "
        "make the Bash call rather than print or skip it. Do these four "
        "steps in order, once each, without retrying any step in another "
        "form, then report each outcome in one line. (1) Use the "
        f"Read tool on {repo_of(sp)}/README.md. (2) Use the Write tool to "
        f"create {repo_of(sp)}/probe.txt holding the single word PROBE. "
        f"(3) Run the shell command: cd {repo_of(sp)} && git log --oneline "
        f"-1 (4) Run the shell command: git -C {repo_of(sp)} commit "
        "--allow-empty -m probe"), judge_s7, repos=True,
        attempted=attempted_s7)

    # S8: kept output and logs carry placeholders, not machine paths, agent
    # ids, agent names or inbox names. The agent prints the config dir, its
    # own $HOME (the case folder) and its cwd, then repeats the node's $HOME,
    # the CLI's dash-encoded forms of the home, config and temp paths and,
    # with --bus, each registered agent's cwd, id and name and each
    # direct-inbox name.
    reg = bus_registry(args.bus)
    cwds = reg["cwd"]
    inboxes = [v for v in bus_inboxes(args.bus) if v not in
               reg["agent_id"] + reg["agent_name"] + reg["hostname"]]
    names = reg["agent_id"] + reg["agent_name"] + inboxes
    home = os.environ.get("HOME", "")
    dash = [dashed(p) for p in (home, str(args.config), temp_paths()[0][0])
            if p]
    repeat = ([home] if home else []) + dash + cwds + names

    def judge_s8(s, space):
        run = space.parent
        raw = [r for r in [str(args.config), home, str(args.scratch)]
               + dash + cwds if r]
        roots = re.compile("(?:/" + "Us" + "ers|/" + "ho" + "me)/")
        kept = [p for p in run.iterdir() if p.is_file()]
        text = "".join(p.read_text(errors="replace") for p in kept)
        words = token_re(names)
        leaks = (sum(1 for r in raw if r in text)
                 + (len(set(words.findall(text))) if words else 0))
        stray = len(roots.findall(text))
        need = (["<config>", "<scratch>", "<home-dashed>", "<config-dashed>",
                 "<cli-tmp-dashed>"]
                + (["<agent-cwd>"] if cwds else [])
                + (["<agent-id>"] if reg["agent_id"] else [])
                + (["<agent-name>"] if reg["agent_name"] else [])
                + (["<inbox>"] if inboxes else []))
        seen = [h for h in need + ["<home>", "<user-home>"] if h in text]
        forms = {str(run), os.path.realpath(run)}
        scratch_home = any(
            ln.strip() in forms for u in s["tool_uses"] if u["name"] == "Bash"
            for ln in str(u["output"] or "").splitlines())
        ok = (leaks == 0 and stray == 0 and all(h in text for h in need)
              and ("<home>" in text or "<user-home>" in text)
              and scratch_home)
        return ok, (f"{len(kept)} kept files; machine paths, ids and names "
                    f"left {leaks}, home-root paths left {stray}; "
                    f"placeholders seen {', '.join(seen) or 'none'}; from "
                    f"the bus: agent cwds {len(cwds)}, ids "
                    f"{len(reg['agent_id'])}, names {len(reg['agent_name'])},"
                    f" other inbox names {len(inboxes)}; agent $HOME is the "
                    f"case folder {scratch_home}")

    case("S8-redaction", False, lambda sp: (
        "Run this shell command once and reply with its output verbatim: "
        "echo \"$CLAUDE_CONFIG_DIR\"; echo \"$HOME\"; pwd Then repeat these "
        "words back exactly, one per line: " + " ".join(repeat)),
        judge_s8, redact_first=True)

    (run_root / "smoke.txt").write_text("\n".join(results) + "\n")
    return 0 if all(" pass " in r for r in results) else 1


# ---------------------------------------------------------------------- main

def main() -> int:
    ap = argparse.ArgumentParser(prog="runner.sh")
    ap.add_argument("command", choices=["smoke", "run", "reset"])
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
    ap.add_argument("--keep-setting", action="append", default=[])
    args = ap.parse_args()
    args.keep = GATEWAY_KEYS + [k for k in args.keep_setting
                                if k not in GATEWAY_KEYS]
    try:
        args.scratch = args.scratch.resolve()
        args.scratch.mkdir(parents=True, exist_ok=True)
        if in_git(args.scratch):
            raise Blocked("git rev-parse succeeds in the scratch root")
        if args.config is not None:
            args.config = args.config.resolve()
            check_config(args.config)
        REDACT[0] = make_redactor(args)
        bad = [k for k in args.keep if k in RUNNER_KEYS]
        if bad:
            raise Blocked(f"--keep-setting cannot keep {', '.join(bad)}")
        args.gate_file = None
        args.gate_checkout = None
        if args.gate:
            checkout, rev = args.gate.rsplit("@", 1)
            args.gate_checkout = Path(checkout).resolve()
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
        if args.command == "reset":
            if args.config is None or args.gate_file is None:
                raise Blocked("reset needs --config and --gate")
            kept = reset_config(args.config, args.gate_file, [], [], False,
                                args.keep)
            present = [f for f in SIGN_IN_FILES
                       if (args.config / f).is_file()]
            say("RESET settings keys kept: " + (", ".join(kept) or "none")
                + "; sign-in files kept: " + ", ".join(present))
            return 0
        if args.command == "smoke":
            if args.config is None or args.gate_file is None:
                raise Blocked("smoke needs --config and --gate")
            return smoke(args)
        worst = 0
        for t in args.tests:
            res = run_test(args, Path(t).resolve())
            say(f"RESULT {Path(t).stem} {res}")
            with open(args.scratch / "results.log", "a") as f:
                f.write(REDACT[0](f"{utc_stamp()} {Path(t).stem} {res}\n"))
            if not res.startswith("pass"):
                worst = 1
        return worst
    except Blocked as e:
        say(f"BLOCKED {e}")
        return 3


sys.exit(main())
PYEOF
