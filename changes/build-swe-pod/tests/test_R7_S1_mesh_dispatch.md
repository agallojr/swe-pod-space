---
scenario: R7.S1
mode: desk (lead)
deliverables: [swe-pod:agents, swe-pod:PROCESS.md as PROCESS.md, swe-pod:templates/records, swe-pod:skills/swe-pod, agent-mesh:skills/space-librarian, agent-mesh:skills/mesh-post]
fixture: demo-space + demo-bus
expected_s: 300
heavy: true
env: any
cap_s: 900
---

# R7.S1 Mesh dispatch

Serves R7 (spec §7; D2, D5). Desk-verified per OD1, plus T20's live
observation; the pilot runs it live. Heavy: expected 300 s of agent time, so
the lead asks the operator before it runs (spec §5.4, §7).

## Given

- A fresh `swe-lead` session, desk: it prints every git and mesh command,
  `mesh-post` included, and runs none.
- The demo bus, with the demo space mounted at `spaces/proj-demo`. Of its
  two registered nodes only the linux-server one holds `swe.test`. The
  setup reads the macOS node's agent id from the bus copy and gives it to
  the lead as this node.
- The overlay: `plan.md` with T3 (the project-level tests) set to
  `runs: mesh` and `needs: linux-server`, and the ledger up to the go and
  T1's dispatch.

```python setup
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

RUN = Path(os.environ["RUN_DIR"])
SPACE = Path(os.environ["SPACE"])
REPOS = RUN / "repos"
SKIP = {".git", "__pycache__", ".pytest_cache"}
FAKE = {"A0": "a1a1a1a", "A1": "d4d4d4d", "B0": "b2b2b2b", "B1": "e5e5e5e"}
GIT_ENV = {
    "PATH": os.environ.get("PATH", "/usr/bin:/bin"),
    "HOME": os.environ["CHECK_HOME"],
    "GIT_CONFIG_NOSYSTEM": "1",
    "GIT_CONFIG_GLOBAL": os.devnull,
    "GIT_AUTHOR_NAME": "demo-owner",
    "GIT_AUTHOR_EMAIL": "demo-owner@example.invalid",
    "GIT_COMMITTER_NAME": "demo-owner",
    "GIT_COMMITTER_EMAIL": "demo-owner@example.invalid",
    "GIT_AUTHOR_DATE": "2026-11-01T08:00:00Z",
    "GIT_COMMITTER_DATE": "2026-11-01T08:00:00Z",
}


def tree(root: Path) -> dict:
    out = {}
    if root.is_dir():
        for p in sorted(root.rglob("*")):
            rel = p.relative_to(root)
            if (p.is_file() and not SKIP & set(rel.parts)
                    and p.suffix != ".pyc"):
                out[str(rel)] = hashlib.sha256(p.read_bytes()).hexdigest()
    return out


def git(cwd: Path, *args: str) -> str:
    r = subprocess.run(["git", *args], cwd=cwd, env=GIT_ENV,
                       capture_output=True, text=True, check=True)
    return r.stdout.strip()


def write_files(root: Path, files: dict) -> None:
    for rel, text in files.items():
        p = root / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(text)


def make_repo(name: str, base: dict, commits: tuple = (),
              real: bool = True) -> list:
    """REPOS/<name>: base on main, then each (task, files) commit on the
    change branch. Returns the sha7s, base first; a plain folder gets []."""
    root = REPOS / name
    write_files(root, base)
    if not real:
        for _, files in commits:
            write_files(root, files)
        return []
    git(root, "init", "-q")
    git(root, "symbolic-ref", "HEAD", "refs/heads/main")
    git(root, "add", "-A")
    git(root, "commit", "-q", "-m", f"{name} 1.0")
    shas = [git(root, "rev-parse", "--short=7", "HEAD")]
    git(root, "checkout", "-q", "-b", "change/add-greeting")
    for task, files in commits:
        write_files(root, files)
        git(root, "add", "-A")
        git(root, "commit", "-q", "-m", f"{task} in {name}", "-m",
            f"Change: add-greeting\nTask: {task}")
        shas.append(git(root, "rev-parse", "--short=7", "HEAD"))
    return shas


def values(alpha: list, beta: list) -> dict:
    out = dict(FAKE)
    for key, shas in (("A", alpha), ("B", beta)):
        for k, sha in enumerate(shas[:2]):
            out[f"{key}{k}"] = sha
    return out


def fill(vals: dict) -> None:
    """Replace the {{KEY}} placeholders in every text file of the space."""
    for p in SPACE.rglob("*"):
        if not p.is_file():
            continue
        try:
            text = p.read_text()
        except UnicodeDecodeError:
            continue
        new = re.sub(r"\{\{([A-Z][A-Z0-9]*)\}\}",
                     lambda m: vals.get(m.group(1), m.group(0)), text)
        if new != text:
            p.write_text(new)


def set_pins(vals: dict) -> None:
    pod = SPACE / "pod.yaml"
    text = pod.read_text()
    for old, key in (("a1a1a1a", "A0"), ("b2b2b2b", "B0")):
        text = text.replace(f'pin: "{old}"', f'pin: "{vals[key]}"')
    pod.write_text(text)


def edit(rel: str, old: str, new: str) -> None:
    p = SPACE / rel
    text = p.read_text()
    if old not in text:
        raise SystemExit(f"setup: text to edit not found in {rel}")
    p.write_text(text.replace(old, new, 1))


def finish_setup(extra: dict = None, keep: tuple = ()) -> None:
    data = {"REPOS": str(REPOS)}
    data.update(extra or {})
    (RUN / "subst.json").write_text(json.dumps(data))
    files = {r: (SPACE / r).read_text() for r in keep
             if (SPACE / r).is_file()}
    (RUN / "before.json").write_text(json.dumps(
        {"space": tree(SPACE), "repos": tree(REPOS), "files": files},
        indent=1))


fill(FAKE)
bus = Path(os.environ["BUS"])
node = ""
for p in sorted((bus / "agents").glob("*.yaml")):
    text = p.read_text()
    if re.search(r"^context:\s*macos-laptop\s*$", text, re.M):
        node = re.search(r"^agent_id:\s*(\S+)", text, re.M).group(1)
(RUN / "bus-before.json").write_text(json.dumps(tree(bus)))
finish_setup({"NODE": node}, keep=("changes/add-greeting/ledger.md",))
```

## When

One lead step.

```text
Dispatch T3 of add-greeting, and only T3.

Checkouts on this node, one per line:
Project Space proj:demo: {SPACE}
Mesh bus: {BUS}
swe-pod: {EXPORT}/swe-pod
agent-mesh: {EXPORT}/agent-mesh
This node: {NODE}
The human is demo-owner.
```

## Then

1. A `task.request` is posted as a desk step: a printed `mesh-post` line, or a
   new message file in the bus with `type: task.request`.
2. It is addressed to a `swe.test` holder of the linux-server class:
   `role:swe.test`, which only that node holds here, or that node's id, and not
   the macOS node.
3. Its Context holds the brief's path, `changes/add-greeting/tasks/T3-brief.md`,
   and that brief exists in the space.
4. It names the role definition `swe-pod/agents/swe-test.md` and the project
   `proj:demo` (contract §2.3, §2.7).
5. The ledger gains `dispatch T3 -> test (mesh, linux-server)`, optionally with
   `, base <repo> <sha7>` pairs after it.
6. No new ledger line names a machine: no agent id, hostname or home path of
   the bus's registrations, no home path at all, and no mesh task id.
7. No local subagent is started for T3.

```python check
import hashlib
import json
import os
import re
import sys
from pathlib import Path

TAG = "R7.S1"
OK = []
RUN = Path(os.environ["RUN_DIR"])
SPACE = Path(os.environ["SPACE"])
REPOS = RUN / "repos"
SKIP = {".git", "__pycache__", ".pytest_cache"}
BEFORE = json.loads((RUN / "before.json").read_text())
CHANGE = "changes/add-greeting"


def report(n: int, ok: bool, why: str) -> None:
    OK.append(bool(ok))
    print(f"{TAG}.{n} {'pass' if ok else 'fail'} {why}")


def finish() -> None:
    sys.exit(0 if OK and all(OK) else 1)


def tree(root: Path) -> dict:
    out = {}
    if root.is_dir():
        for p in sorted(root.rglob("*")):
            rel = p.relative_to(root)
            if (p.is_file() and not SKIP & set(rel.parts)
                    and p.suffix != ".pyc"):
                out[str(rel)] = hashlib.sha256(p.read_bytes()).hexdigest()
    return out


def changed(kind: str = "space") -> tuple:
    """(added, modified, removed) paths since setup, in the space or repos."""
    before = BEFORE[kind]
    after = tree(SPACE if kind == "space" else REPOS)
    added = sorted(set(after) - set(before))
    modified = sorted(k for k in before
                      if k in after and before[k] != after[k])
    removed = sorted(set(before) - set(after))
    return added, modified, removed


def summary(k: int) -> dict:
    p = os.environ.get(f"SUMMARY_{k}", "")
    if p and Path(p).is_file():
        return json.loads(Path(p).read_text())
    return {"tool_uses": [], "permission_denials": [], "result": ""}


def uses(k: int, names: tuple = (), sub: bool = False) -> list:
    """Tool calls of step k by the session agent (sub=False) or subagents."""
    return [u for u in summary(k).get("tool_uses") or []
            if (not names or u.get("name") in names)
            and bool(u.get("subagent")) == sub]


def arg(u: dict, key: str) -> str:
    return str((u.get("input") or {}).get(key, "") or "")


def final(k: int) -> str:
    return summary(k).get("result") or ""


def texts(k: int) -> list:
    """The session agent's text blocks of step k, the final one included."""
    out = []
    p = os.environ.get(f"STREAM_{k}", "")
    if p and Path(p).is_file():
        for line in Path(p).read_text().splitlines():
            try:
                ev = json.loads(line)
            except ValueError:
                continue
            if ev.get("type") != "assistant" or ev.get("parent_tool_use_id"):
                continue
            for c in (ev.get("message") or {}).get("content") or []:
                if isinstance(c, dict) and c.get("type") == "text":
                    out.append(c.get("text") or "")
    out.append(final(k))
    return out


def printed(k: int) -> list:
    """Lines the session agent printed: its text, Bash commands, outputs."""
    lines = []
    for t in texts(k):
        lines += t.splitlines()
    for u in uses(k, ("Bash",)):
        lines += arg(u, "command").splitlines()
        lines += str(u.get("output") or "").splitlines()
    return lines


def desk(k: int) -> list:
    """The commands a desk step printed instead of running."""
    return [ln.split("DESK:", 1)[1].strip().strip("`")
            for ln in printed(k) if "DESK:" in ln]


def events(text: str) -> list:
    """Ledger events, continuation lines joined to their event."""
    out = []
    for ln in text.splitlines():
        if re.match(r"\d{4}-\d\d-\d\dT\d\d:\d\dZ ", ln):
            out.append(ln.strip())
        elif out and ln.startswith(" " * 18) and ln.strip():
            out[-1] += " " + ln.strip()
    return out


def new_events(rel: str = CHANGE + "/ledger.md") -> list:
    old = set(events(BEFORE["files"].get(rel, "")))
    p = SPACE / rel
    now = events(p.read_text()) if p.is_file() else []
    return [e for e in now if e not in old]


def rel_token(tok: str) -> str:
    """A command token as a space-relative path where it is one."""
    tok = tok.strip("'\"`,;()")
    base = str(SPACE).rstrip("/") + "/"
    return tok[len(base):] if tok.startswith(base) else tok


def staged(lines: list) -> tuple:
    """Paths a list of git command lines stages, and whether any stages
    everything (-A, --all or .)."""
    paths, wholesale = [], False
    for ln in lines:
        m = re.search(r"\bgit\b(?:\s+-[Cc]\s+\S+)*\s+add\b([^;&|]*)", ln)
        if not m:
            continue
        for tok in m.group(1).split():
            tok = rel_token(tok)
            if tok in ("-A", "--all", ".", "./", "*", ":/"):
                wholesale = True
            elif tok and not tok.startswith("-"):
                paths.append(tok)
    return paths, wholesale


def covers(tok: str, path: str) -> bool:
    """A staged token covers a path: the same path, or a folder holding it."""
    tok = tok.rstrip("/")
    return bool(tok) and (path == tok or path.startswith(tok + "/"))


def section(text: str, name: str) -> str:
    """The body of the level-2 section whose title contains name."""
    out, on = [], False
    for ln in text.splitlines():
        if ln.startswith("## "):
            title = re.sub(r"^\d+\.?\s*", "", ln[3:]).strip().lower()
            on = name.lower() in title
            continue
        if on:
            out.append(ln)
    return "\n".join(out)


def read(rel: str) -> str:
    p = SPACE / rel
    return p.read_text() if p.is_file() else ""


BUS = Path(os.environ["BUS"])
BRIEF = CHANGE + "/tasks/T3-brief.md"
regs = {}
for p in sorted((BUS / "agents").glob("*.yaml")):
    f = dict(re.findall(r"^(\w+):\s*(.*)$", p.read_text(), re.M))
    regs[f.get("context", "")] = f
mac, lin = regs.get("macos-laptop", {}), regs.get("linux-server", {})
before = json.loads((RUN / "bus-before.json").read_text())
new_bus = [p for p in tree(BUS) if p not in before
           and not p.startswith("spaces/")]
msgs = [(BUS / p).read_text() for p in new_bus
        if "task.request" in (BUS / p).read_text()]
posts = [ln for ln in desk(1) if "mesh-post" in ln]
written = [arg(u, "content") for u in uses(1, ("Write",))
           if "task.request" in arg(u, "content")
           or "T3-brief.md" in arg(u, "content")]
text = "\n".join(posts + msgs + written)
report(1, bool(posts or msgs), f"{len(posts)} mesh-post line(s), "
       f"{len(msgs)} task.request file(s) in the bus")
to = re.findall(r"(?:--to\s+|\bto:\s*)['\"]?([\w.:-]+)", text)
good = {"role:swe.test", lin.get("agent_id", "?")}
ok2 = (any(t in good for t in to) and mac.get("agent_id", "?") not in to
       if to else "role:swe.test" in text)
report(2, ok2, f"{len(to)} recipient(s) found; linux-server holder "
       + ("addressed" if ok2 else "not addressed"))
report(3, BRIEF in text and (SPACE / BRIEF).is_file(),
       f"brief path {'in' if BRIEF in text else 'not in'} the request; "
       f"brief {'exists' if (SPACE / BRIEF).is_file() else 'absent'}")
report(4, "swe-pod/agents/swe-test.md" in text and "proj:demo" in text,
       "role definition and project " + (
           "named" if "swe-pod/agents/swe-test.md" in text
           and "proj:demo" in text else "not both named"))
ev = new_events()
line = [e for e in ev if re.search(
    r"\bdispatch T3 -> test \(mesh, linux-server\)"
    r"(, base [a-z0-9-]+ [0-9a-f]{7}(, [a-z0-9-]+ [0-9a-f]{7})*)?$", e)]
report(5, bool(line), f"{len(line)} mesh dispatch line(s) for T3")
neg = []
for f in regs.values():
    neg += [f.get("agent_id"), f.get("hostname"), f.get("cwd")]
    cwd = f.get("cwd") or ""
    if cwd.count("/") >= 2:
        neg.append("/".join(cwd.split("/")[:3]))
neg = [n for n in neg if n] + ["/Us" + "ers/", "/ho" + "me/"]
hits = [e for e in ev if any(n in e for n in neg)
        or re.search(r"\b\d{8}T\d{4}-\d{4}\b", e)]
report(6, not hits, f"{len(hits)} new ledger line(s) name a machine or task")
local = [u for u in uses(1, ("Agent", "Task")) if "T3" in arg(u, "prompt")]
report(7, not local, f"{len(local)} local subagent(s) for T3")
finish()
```

## Fails if

- The lead runs a `runs: mesh` task locally, or posts it to a role or node
  that is not of the linux-server class.
- The request's Context lacks the brief's path or the role definition, or it
  does not load the space.
- The ledger line names a node, hostname, agent id, task id or home path, or
  omits the role, `mesh` or the environment class.

## At base

Expected: fail, because `agents/` is absent at swe-pod `8fc5294`; the runner
records the absent deliverable and starts no agent.

Observed 2026-10-28T00:40Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), with no --config, so no agent could start;
runner result:

```
fail (deliverable absent: swe-pod 8fc5294 agents)
```
