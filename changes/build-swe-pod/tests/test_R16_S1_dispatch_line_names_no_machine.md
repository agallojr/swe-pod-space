---
scenario: R16.S1
mode: inspect
deliverables: [swe-pod:templates/records/ledger.md]
fixture: none
expected_s: 2
heavy: false
env: any
cap_s: 60
---

# R16.S1 A dispatch line names no machine

Serves R16 through D3 (the ledger template) and through every ledger the
pod's agents write in the other tests' runs. Run it last, after every other
test of the change, with the same `--scratch`, so that their run dirs exist.

## Given

- `templates/records/ledger.md` exported read-only from swe-pod at the sha
  under test.
- The run dirs beside this one under `<scratch>/runs/`: in each, the space
  copy (`space/`, or `bus/spaces/proj-demo/`) and its ledgers,
  `changes/*/ledger.md` and `changes/archive/*/ledger.md`. A line that the
  run's overlay put there is a fixture line; any other line was written by an
  agent.
- With `--space`, the Project Space's own ledgers are read as well.
- Machine values, gathered at run time and never printed: the agent ids,
  hostnames and `cwd` (and its first two path components) of every agent
  registered in each run's bus copy and in `--bus`; the mesh task ids in
  `--bus` `tasks/`, `status/` and `_archive/`; the credential names in the
  bus registrations' `credentials_available`; this node's hostname and
  `$HOME`; the names of credential-like environment variables; and, as
  patterns, absolute paths under the macOS and Linux home roots, the mesh
  task id shape, and credential-shaped names.

## When

```text
The runner exports templates/records/ledger.md from swe-pod by sha and runs
the check below on it and on the ledgers of the other runs. No agent is run.
```

## Then

1. The template holds at least one dispatch line, and each is in the contract
   form `dispatch T<n> -> <role> (<local|mesh>, <env class|any>)[, base <repo>
   <sha7>]`, as placeholders or filled in.
2. At least one dispatch line in the other runs' ledgers (or in the space's
   own) was written by an agent.
3. Every dispatch line read is in that form: a pod role, `local` or `mesh`, an
   environment class (lower-case words joined by hyphens) or `any`, then only
   `base` repo and sha7 pairs.
4. No dispatch line holds a machine value: no hostname, agent id, mesh task
   id, home path or credential name. Each hit is printed as `<source>:<line>
   <kind>`, never the matched text.

```python check
TAG = "R16.S1"
import json
import os
import re
import sys
from pathlib import Path

RUN = Path(os.environ["RUN_DIR"])
SPACE = Path(os.environ["SPACE"])
OK = []


def report(n: int, ok: bool, why: str) -> None:
    OK.append(bool(ok))
    print(f"{TAG}.{n} {'pass' if ok else 'fail'} {why}")


def final(k: int = 1) -> str:
    return Path(os.environ[f"FINAL_{k}"]).read_text()


def stream(k: int = 1) -> Path:
    return Path(os.environ[f"STREAM_{k}"])

STAMP = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}(:\d{2})?Z ")


def ledger_events(text: str) -> list:
    """Events of a ledger, each continuation line joined to its event."""
    out = []
    for ln in text.splitlines():
        if STAMP.match(ln):
            out.append(ln.rstrip())
        elif ln.startswith(" " * 18) and ln.strip() and out:
            out[-1] += " " + ln.strip()
    return out


def ledger_new(rel: str) -> list:
    """Events in the space's ledger at rel that setup did not put there."""
    now, old = SPACE / rel, RUN / "before" / rel
    cur = ledger_events(now.read_text()) if now.is_file() else []
    was = set(ledger_events(old.read_text())) if old.is_file() else set()
    return [e for e in cur if e not in was]

import socket

TESTS = Path(os.environ["TESTS_DIR"])
POD = {"spec", "plan", "lead", "build", "test", "review"}
ENV = re.compile(r"^[a-z][a-z0-9]*(-[a-z0-9]+)*$")
LINE = re.compile(r"^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}Z) dispatch (T\d+) -> "
                  r"(\S+) \(([^,()]*), ([^()]*)\)(.*)$")
REST = re.compile(r"^(, base [A-Za-z0-9][\w.-]* [0-9a-f]{7}"
                  r"(, [A-Za-z0-9][\w.-]* [0-9a-f]{7})*)?$")
FORM = ("dispatch T<n> -> <role> (<local|mesh>, <env class|any>)")


def form_ok(e: str) -> bool:
    m = LINE.match(e)
    return bool(m) and m.group(3) in POD and m.group(4) in (
        "local", "mesh") and (m.group(5) == "any" or bool(
            ENV.match(m.group(5)))) and bool(REST.match(m.group(6)))


def numbered(text: str) -> list:
    """(line number, event) for each ledger event, continuations joined."""
    out = []
    for n, ln in enumerate(text.splitlines(), 1):
        if STAMP.match(ln):
            out.append([n, ln.rstrip()])
        elif ln.startswith(" " * 18) and ln.strip() and out:
            out[-1][1] += " " + ln.strip()
    return [tuple(x) for x in out]


sha = os.environ.get("SHA_SWE_POD", "?")
tpl = Path(os.environ.get("EXPORT_SWE_POD", str(RUN / "none"))) / (
    "templates/records/ledger.md")
tt = tpl.read_text() if tpl.is_file() else ""
tl = [(n, ln.strip()) for n, ln in enumerate(tt.splitlines(), 1)
      if re.search(r"(^|\s)dispatch T", ln)]
good = [x for x in tl if FORM in x[1] or form_ok(x[1].strip("`"))]
report(1, bool(tl) and len(good) == len(tl), f"swe-pod {sha}: " + (
    "templates/records/ledger.md absent" if not tt else
    f"{len(good)} of {len(tl)} template dispatch line(s) in the form"))
values = {}


def val(v: str, kind: str) -> None:
    v = (v or "").strip().strip('"').strip("'")
    if len(v) >= 4:
        values.setdefault(v, kind)


def from_bus(bus: Path) -> None:
    for p in sorted((bus / "agents").glob("*.yaml")):
        for ln in p.read_text().splitlines():
            k, _, v = ln.partition(":")
            v = v.strip().strip('"')
            if k == "agent_id":
                val(v, "agent id")
            elif k == "hostname":
                val(v, "hostname")
                val(v.split(".")[0], "hostname")
            elif k == "cwd":
                val(v, "home path")
                parts = v.strip("/").split("/")
                if len(parts) >= 2:
                    val("/" + "/".join(parts[:2]), "home path")
            elif k == "credentials_available":
                for c in re.findall(r"[A-Za-z_][A-Za-z0-9_]{3,}", v):
                    val(c, "credential name")
    for sub in ("tasks", "status", "_archive"):
        if (bus / sub).is_dir():
            for p in (bus / sub).rglob("*"):
                for t in re.findall(r"\d{8}T\d{4}-\d{4}", p.name):
                    val(t, "mesh task id")


sources, nruns = [], 0
for rd in sorted(p for p in RUN.parent.iterdir() if p.is_dir() and p != RUN):
    m = re.match(r"\d{8}T\d{6}Z-(.+)-[0-9a-f]{4}$", rd.name)
    if not m:
        continue
    nruns += 1
    if (rd / "bus" / "agents").is_dir():
        from_bus(rd / "bus")
    for sp in (rd / "space", rd / "bus" / "spaces" / "proj-demo"):
        if not sp.is_dir():
            continue
        for lg in sorted(sp.glob("changes/*/ledger.md")) + sorted(
                sp.glob("changes/archive/*/ledger.md")):
            rel = str(lg.relative_to(sp))
            ov = TESTS / "fixtures" / "overlays" / m.group(1) / rel
            base = {e for n, e in numbered(ov.read_text())} if (
                ov.is_file()) else set()
            sources.append((f"{rd.name}:{rel}", numbered(lg.read_text()),
                            base))
real = os.environ.get("REAL_SPACE", "")
if real:
    rs = Path(real)
    for lg in sorted(rs.glob("changes/*/ledger.md")) + sorted(
            rs.glob("changes/archive/*/ledger.md")):
        sources.append((f"space:{lg.relative_to(rs)}",
                        numbered(lg.read_text()), None))
if os.environ.get("REAL_BUS"):
    from_bus(Path(os.environ["REAL_BUS"]))
host = socket.gethostname()
val(host, "hostname")
val(host.split(".")[0], "hostname")
val(os.environ.get("HOME", ""), "home path")
for k in os.environ:
    if re.search(r"(TOKEN|SECRET|PASSWORD|_KEY|_PAT)$", k):
        val(k, "credential name")
lines = []
for label, evs_, base in sources:
    for n, e in evs_:
        if re.match(r"^\S+ dispatch ", e):
            lines.append((label, n, e, base is None or e not in base))
lines += [(f"swe-pod {sha}:templates/records/ledger.md", n, e, False)
          for n, e in tl]
agent = [x for x in lines if x[3]]
report(2, bool(agent), f"{len(agent)} agent-written dispatch line(s) in "
       f"{len(sources)} ledger(s) of {nruns} other run(s)")
bad = [x for x in lines if not x[0].startswith("swe-pod ")
       and not form_ok(x[2])]
report(3, not bad, f"{len(bad)} dispatch line(s) not in the form" + "".join(
    f"; {x[0]}:{x[1]}" for x in bad[:3]))
PAT = [(re.compile("/" + "Us" + r"ers/[^/\s]+|/" + "ho" + r"me/[^/\s]+"),
        "home path"),
       (re.compile(r"\b\d{8}T\d{4}-\d{4}\b"), "mesh task id"),
       (re.compile(r"\b[A-Z][A-Z0-9]*_(TOKEN|KEY|PAT|SECRET|PASSWORD)\b"),
        "credential name")]
hits = []
for label, n, e, _ in lines:
    for v, kind in values.items():
        if re.search(r"(?<![A-Za-z0-9_-])" + re.escape(v)
                     + r"(?![A-Za-z0-9_-])", e):
            hits.append(f"{label}:{n} {kind}")
    for rx, kind in PAT:
        if rx.search(e):
            hits.append(f"{label}:{n} {kind}")
for h in sorted(set(hits)):
    print(h)
report(4, not hits, f"{len(set(hits))} machine value hit(s) in dispatch "
       "lines")
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- The template is absent, or shows a dispatch line in another form.
- No agent-written dispatch line is found: the test ran before the others, or
  in another scratch root.
- A dispatch line names a node, host, path, task id or credential, or carries
  text past the form.

## At base

Expected: fail, because `templates/records/ledger.md` is absent at swe-pod
`8fc5294`.

Observed 2026-10-28T00:43Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), runner result:

```
fail (check R16.S1.1: swe-pod 8fc5294: templates/records/ledger.md absent)
```
