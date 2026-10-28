---
scenario: I6
mode: inspect
deliverables: [agent-mesh:skills/mesh-post]
fixture: none
expected_s: 5
heavy: false
env: any
cap_s: 60
---

# I6 mesh-post --project: the three cases of contract §2.7

Serves R7 through D5 (M2).

## Given

- `skills/mesh-post/` exported read-only from agent-mesh at the sha under
  test.
- A throwaway repo made at run time with `git init` in the run dir, with no
  remote, passed as an explicit `--repo`. `REPO_PATH` is unset and `HOME` is
  a fresh empty folder in the run dir, so no mesh identity is read.
- Every call uses `--dry-run`, so the script writes and stages its message
  file and commits nothing. The message body is a four-section stub built at
  run time.

## When

```text
The runner exports skills/mesh-post from agent-mesh by sha and runs the check
below, which calls mesh-post.sh against the throwaway repo. No agent is run.
```

## Then

1. Valid value: `--project proj:demo` exits 0 and the message file it writes
   has `project: proj:demo` as the line right after `timeout_min:`.
2. A value with digits and a hyphen, `proj:demo-2`, is accepted the same
   way.
3. Invalid values `Proj:demo`, `proj:`, `proj:-demo`, `demo` and
   `proj:demo_x` each exit 1, print
   `mesh-post: invalid --project value: <value>`, and write no message file.
4. The value is checked before any repo check: an invalid value given first,
   with `--repo` naming a folder that does not exist, still exits 1 with the
   invalid-value message.
5. Without the flag, the call exits 0 and the message's front-matter has no
   `project:` line.

```python check
import os
import subprocess
import sys
from pathlib import Path

TAG = "I6"
OK = []


def report(n: int, ok: bool, why: str) -> None:
    OK.append(ok)
    print(f"{TAG}.{n} {'pass' if ok else 'fail'} {why}")


run = Path(os.environ["RUN_DIR"])
sha = os.environ.get("SHA_AGENT_MESH", "?")
script = Path(os.environ["EXPORT_AGENT_MESH"]) / "skills" / "mesh-post" / \
    "mesh-post.sh"
if not script.is_file():
    report(1, False, f"skills/mesh-post/mesh-post.sh absent at agent-mesh "
           f"{sha}")
    sys.exit(1)
repo = run / "i6-repo"
subprocess.run(["git", "-c", "init.defaultBranch=main", "init", "-q",
                str(repo)], check=True)
body = run / "i6-body.md"
body.write_text("## Goal\nProbe.\n## Context\nNone.\n## Done when\n"
                "Never.\n## On failure\nStop.\n")
queue = repo / "tasks" / "roles" / "swe.test"
env = {k: v for k, v in os.environ.items() if k != "REPO_PATH"}
env["HOME"] = os.environ["CHECK_HOME"]


def post(title: str, extra_first: list, repo_path: Path = repo):
    cmd = ["bash", str(script)] + extra_first + [
        "--to", "role:swe.test", "--type", "task.request", "--title", title,
        "--from", "demo-op-01", "--repo", str(repo_path), "--body-file",
        str(body), "--dry-run"]
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=30,
                       env=env)
    files = sorted(queue.glob(f"*-{title}.md")) if queue.is_dir() else []
    return r, files


def front(path: Path) -> list:
    lines = path.read_text().splitlines()
    end = lines.index("---", 1) if "---" in lines[1:] else len(lines)
    return lines[1:end]


def first_line(r) -> str:
    text = (r.stderr + r.stdout).strip().splitlines()
    return text[0][:120] if text else "no output"


for n, (value, title) in enumerate([("proj:demo", "probe-valid"),
                                    ("proj:demo-2", "probe-digits")], 1):
    r, files = post(title, ["--project", value])
    ok = r.returncode == 0 and len(files) == 1
    if ok:
        fm = front(files[0])
        idx = [i for i, ln in enumerate(fm) if ln.startswith("timeout_min:")]
        ok = bool(idx) and idx[0] + 1 < len(fm) and \
            fm[idx[0] + 1] == f"project: {value}"
        why = f"{value}: project line " + ("right after timeout_min" if ok
                                           else "missing or misplaced")
    else:
        why = f"{value}: exit {r.returncode}, {first_line(r)}"
    report(n, ok, why)
bad = ["Proj:demo", "proj:", "proj:-demo", "demo", "proj:demo_x"]
fails = []
for i, value in enumerate(bad):
    title = f"probe-bad-{i}"
    r, files = post(title, ["--project", value])
    msg = f"mesh-post: invalid --project value: {value}"
    if not (r.returncode == 1 and msg in r.stdout + r.stderr and not files):
        fails.append(f"{value!r} (exit {r.returncode}, {first_line(r)})")
report(3, not fails, "invalid values: " + ("all refused with the message"
                                           if not fails else
                                           "; ".join(fails[:2])))
r, files = post("probe-order", ["--project", "Bad_Value"],
                run / "no-such-repo")
report(4, r.returncode == 1 and
       "mesh-post: invalid --project value: Bad_Value" in r.stdout + r.stderr,
       f"checked before the repo: exit {r.returncode}, {first_line(r)}")
r, files = post("probe-none", [])
ok5 = r.returncode == 0 and len(files) == 1 and not any(
    ln.startswith("project:") for ln in front(files[0]))
report(5, ok5, "no flag: " + ("no project line" if ok5 else
                              f"exit {r.returncode}, {first_line(r)}"))
sys.exit(0 if all(OK) else 1)
```

## Fails if

- A valid value is refused, or its `project:` line is missing or not right
  after `timeout_min:`.
- An invalid value is accepted, exits other than 1, prints another message,
  or leaves a message file behind.
- The repo is checked before the value.
- A line is written when the flag is absent.

## At base

Expected: fail, because `--project` is an unknown argument at agent-mesh
`8ee5364` (`mesh-post: unknown arg: --project`, exit 1).

Observed 2026-10-27T23:55Z at the base commit set (space c814837,
swe-pod 8fc5294, agent-mesh 8ee5364), runner result:

```
fail (check I6.1: proj:demo: exit 1, mesh-post: unknown arg: --project)
```
