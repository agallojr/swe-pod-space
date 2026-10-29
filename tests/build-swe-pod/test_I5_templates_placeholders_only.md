---
scenario: I5
mode: inspect
deliverables: [swe-pod:templates/space, swe-pod:templates/records]
fixture: none
expected_s: 2
heavy: false
env: any
cap_s: 30
---

# I5 The D3 templates hold placeholders only (R16)

Serves R16 through the D3 templates.

## Given

- `templates/space/` and `templates/records/` exported read-only from swe-pod
  at the sha under test.
- The real values to look for, all read at run time and never written down:
  - from the bus given as `--bus` (read-only): each `agents/*.yaml`
    `agent_id`, `hostname` (and its first label), `cwd` (and its first two
    path components) and `credentials_available` names, and every mesh task
    id named under `tasks/`, `status/` and `_archive/`;
  - from the Project Space given as `--space` (read-only): the owner handles,
    from its `space.yaml` keys whose name starts with `owner`, and from the
    `- owner:` and `- approved:` lines of its change specs;
  - from the node: its hostname (and first label) and `$HOME`;
  - absolute per-user paths under the macOS and Linux home roots.

## When

```text
The runner exports the templates from swe-pod by sha and runs the check below
on them, with --bus and --space naming the node's bus and the real Project
Space. No agent is run.
```

## Then

Each hit is printed as `<file>:<line> <kind>`, never with the matched text.

1. Both template folders exist.
2. Real values are available: `--bus` names a bus with at least one
   `agents/*.yaml`, and `--space` yields at least one owner handle.
3. No template line holds a real hostname.
4. No template line holds a real agent id.
5. No template line holds a home path: `$HOME`, a registered agent's `cwd`
   or its first two components, or an absolute per-user path under the macOS
   or Linux home root. A placeholder such as `<handle>` in the user part is
   not a real path.
6. No template line holds a real credential key name.
7. No template line holds a real owner handle.
8. No template line holds a mesh task id that the bus holds.
9. Identity fields are placeholders: in `pod.yaml` the `project` value and
   every `remote` and `pin` value contain a `<...>` placeholder, and in
   `space.yaml` the `id` value and every key starting with `owner` contain
   one.

```python check
import os
import re
import socket
import sys
from pathlib import Path

TAG = "I5"
OK = []
HITS = []


def report(n: int, ok: bool, why: str) -> None:
    OK.append(ok)
    print(f"{TAG}.{n} {'pass' if ok else 'fail'} {why}")


def field(text: str, key: str) -> str:
    m = re.search(rf"^{key}:\s*(.*)$", text, re.M)
    return m.group(1).strip().strip("'\"") if m else ""


def flow(value: str) -> list:
    return [v.strip().strip("'\"") for v in value.strip("[] ").split(",")
            if v.strip()]


sha = os.environ.get("SHA_SWE_POD", "?")
root = Path(os.environ["EXPORT_SWE_POD"]) / "templates"
files = [p for d in ("space", "records") for p in sorted(
    (root / d).rglob("*")) if p.is_file()] if root.is_dir() else []
have = all((root / d).is_dir() for d in ("space", "records"))
report(1, have, f"swe-pod {sha}: " + (
    f"{len(files)} template files" if have else
    "templates/space or templates/records absent"))

values = {k: set() for k in ("hostname", "agent id", "home path",
                             "credential name", "handle", "mesh task id")}
bus = Path(os.environ["REAL_BUS"]) if os.environ.get("REAL_BUS") else None
regs = sorted((bus / "agents").glob("*.yaml")) if bus else []
for reg in regs:
    t = reg.read_text()
    for v in (field(t, "agent_id"), reg.stem):
        if v:
            values["agent id"].add(v)
    h = field(t, "hostname")
    if h:
        values["hostname"].update({h, h.split(".")[0]})
    c = field(t, "cwd")
    if c:
        values["home path"].add(c.rstrip("/"))
        parts = [x for x in c.split("/") if x]
        if len(parts) >= 2:
            values["home path"].add("/" + "/".join(parts[:2]))
    values["credential name"].update(
        flow(field(t, "credentials_available")))
id_re = re.compile(r"\d{8}T\d{4}-\d{4}")
if bus:
    for d in ("tasks", "status", "_archive"):
        if (bus / d).is_dir():
            for p in (bus / d).rglob("*"):
                values["mesh task id"].update(id_re.findall(p.name))
space = Path(os.environ["REAL_SPACE"]) if os.environ.get(
    "REAL_SPACE") else None
if space and (space / "space.yaml").is_file():
    for ln in (space / "space.yaml").read_text().splitlines():
        km = re.match(r"(owner\w*):\s*(.*)$", ln)
        if km:
            values["handle"].update(flow(km.group(2)))
if space:
    for spec in list(space.glob("changes/*/spec.md")) + list(
            space.glob("changes/archive/*/spec.md")):
        for m in re.finditer(r"^- (?:owner|approved):\s*(\S+)",
                             spec.read_text(), re.M):
            values["handle"].add(m.group(1))
host = socket.gethostname()
values["hostname"].update({host, host.split(".")[0]})
home = os.environ.get("HOME", "")
if home:
    values["home path"].add(home.rstrip("/"))
values = {k: {v for v in vs if len(v) >= 3 and not v.startswith("<")}
          for k, vs in values.items()}
report(2, bool(regs) and bool(values["handle"]),
       f"real values read: {len(regs)} registrations, "
       f"{len(values['handle'])} handle(s)")

roots = ["/" + "Us" + "ers/", "/" + "ho" + "me/"]
home_re = re.compile("(?:" + "|".join(re.escape(r) for r in roots)
                     + r")[A-Za-z0-9._-]+")
for f in files:
    rel = f.relative_to(root)
    try:
        lines = f.read_text().splitlines()
    except UnicodeDecodeError:
        continue
    for i, ln in enumerate(lines, 1):
        for kind, vs in values.items():
            for v in vs:
                pat = r"(?<![\w.-])" + re.escape(v) + r"(?![\w-])"
                if re.search(pat, ln):
                    HITS.append((kind, f"{rel}:{i} {kind}"))
        if home_re.search(ln):
            HITS.append(("home path", f"{rel}:{i} home path"))
for h in sorted({h for _, h in HITS}):
    print(h)
n = 3
for kind in ("hostname", "agent id", "home path", "credential name",
             "handle", "mesh task id"):
    k = [h for kd, h in HITS if kd == kind]
    report(n, have and not k, f"{len(set(k))} {kind} hit(s)" if have
           else "not checked: templates absent")
    n += 1
ph = re.compile(r"<[^<>]+>")
bad = []
pod = root / "space" / "pod.yaml"
if pod.is_file():
    t = pod.read_text()
    if not ph.search(field(t, "project")):
        bad.append("pod.yaml project")
    for m in re.finditer(r"\b(remote|pin):\s*\"?([^,}\n]*)", t):
        if not ph.search(m.group(2)):
            bad.append(f"pod.yaml {m.group(1)}")
spy = root / "space" / "space.yaml"
if spy.is_file():
    t = spy.read_text()
    if not ph.search(field(t, "id")):
        bad.append("space.yaml id")
    for km in re.finditer(r"^(owner\w*):\s*(.*)$", t, re.M):
        if not ph.search(km.group(2)):
            bad.append(f"space.yaml {km.group(1)}")
report(9, have and pod.is_file() and spy.is_file() and not bad,
       "identity fields: " + (
           "not checked: templates absent" if not (pod.is_file() and
                                                   spy.is_file())
           else ", ".join(sorted(set(bad))) or "placeholders only"))
sys.exit(0 if all(OK) else 1)
```

## Fails if

- Any template line carries a real hostname, agent id, home path,
  credential key name, owner handle or held mesh task id, or an absolute
  per-user path under a home root.
- An identity field in `pod.yaml` or `space.yaml` holds a value in place of
  a placeholder.
- The run has no bus or no Project Space to read the real values from.

## At base

Expected: fail, because `templates/` is absent at swe-pod `8fc5294`.

Observed 2026-10-27T23:55Z at the base commit set (space c814837,
swe-pod 8fc5294, agent-mesh 8ee5364), runner result:

```
fail (check I5.1: swe-pod 8fc5294: templates/space or templates/records absent)
```
