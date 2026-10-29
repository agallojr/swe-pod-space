---
scenario: I2
mode: inspect
deliverables: [swe-pod:agents]
fixture: none
expected_s: 1
heavy: false
env: any
cap_s: 30
---

# I2 The six role definitions

Serves R7 to R9, R17, R21 and R23 through D2 (contract §2.3).

## Given

The `agents/` folder exported read-only from swe-pod at the sha under test.

## When

```text
The runner exports agents/ from swe-pod by sha and runs the check below on
it. No agent is run.
```

## Then

1. `agents/swe-spec.md`, `swe-plan.md`, `swe-lead.md`, `swe-build.md`,
   `swe-test.md` and `swe-review.md` all exist.
2. Each has front-matter with `name: swe-<role>`, a non-empty one-line
   `description:` and `model: inherit`.
3. Each has the tools of contract §2.3, as a set:
   - swe-spec: Read, Grep, Glob, Bash, Write, Edit.
   - swe-plan: Read, Grep, Glob, Bash, Write.
   - swe-lead: all tools, Agent included. A `tools:` line is optional; if
     present it holds Agent, Read, Grep, Glob, Bash, Write and Edit.
   - swe-build: Read, Grep, Glob, Bash, Write, Edit.
   - swe-test: Read, Grep, Glob, Bash, Write, Agent.
   - swe-review: Read, Grep, Glob, Bash, and neither Write nor Edit.

   `Task`, the older name of the Agent tool, counts as Agent.
4. Outside fenced blocks, each body's level-2 headings are `## Reads`,
   `## Writes`, `## Never` and `## Returns`, in that order, with at most one
   `## Steps` anywhere among them and no other level-2 heading.

```python check
import os
import re
import sys
from pathlib import Path

TAG = "I2"
OK = []
FENCE = "`" * 3
ROLES = ["spec", "plan", "lead", "build", "test", "review"]
BASE = {"Read", "Grep", "Glob", "Bash"}
TOOLS = {
    "spec": BASE | {"Write", "Edit"},
    "plan": BASE | {"Write"},
    "build": BASE | {"Write", "Edit"},
    "test": BASE | {"Write", "Agent"},
    "review": set(BASE),
}


def report(n: int, ok: bool, why: str) -> None:
    OK.append(ok)
    print(f"{TAG}.{n} {'pass' if ok else 'fail'} {why}")


def front(text: str) -> tuple:
    m = re.match(r"---\n(.*?)\n---\n", text, re.S)
    if not m:
        return None, text
    fm, key = {}, None
    for line in m.group(1).splitlines():
        km = re.match(r"([A-Za-z_-]+):\s*(.*)$", line)
        if km:
            key = km.group(1)
            fm[key] = km.group(2).strip()
        elif key and line.strip().startswith("- "):
            fm[key] = (fm[key] + "," + line.strip()[2:]).strip(",")
        elif key and line.strip():
            fm[key] = fm[key] + " " + line.strip()
    return fm, text[m.end():]


def tool_set(value: str) -> set:
    names = {t.strip().strip("'\"") for t in
             value.strip().strip("[]").split(",") if t.strip()}
    return {"Agent" if t == "Task" else t for t in names}


def headings(body: str) -> list:
    out, fenced = [], False
    for line in body.splitlines():
        if line.lstrip().startswith(FENCE):
            fenced = not fenced
            continue
        if not fenced and line.startswith("## "):
            out.append(line[3:].strip())
    return out


sha = os.environ.get("SHA_SWE_POD", "?")
root = Path(os.environ["EXPORT_SWE_POD"]) / "agents"
missing = [r for r in ROLES if not (root / f"swe-{r}.md").is_file()]
report(1, not missing, f"swe-pod {sha}: " + (
    "all six present" if not missing else
    "absent: " + ", ".join(f"agents/swe-{r}.md" for r in missing)))
bad_fm, bad_tools, bad_heads = [], [], []
for r in ROLES:
    p = root / f"swe-{r}.md"
    if not p.is_file():
        continue
    fm, body = front(p.read_text())
    if fm is None:
        bad_fm.append(f"swe-{r} (no front-matter)")
        bad_tools.append(f"swe-{r}")
        bad_heads.append(f"swe-{r}")
        continue
    probs = []
    if fm.get("name") != f"swe-{r}":
        probs.append("name")
    if not fm.get("description"):
        probs.append("description")
    if fm.get("model") != "inherit":
        probs.append("model")
    if probs:
        bad_fm.append(f"swe-{r} ({', '.join(probs)})")
    tools = fm.get("tools")
    if r == "lead":
        ok = tools in (None, "", "*") or (
            BASE | {"Write", "Edit", "Agent"}) <= tool_set(tools)
    else:
        ok = tools is not None and tool_set(tools) == TOOLS[r]
    if not ok:
        bad_tools.append(f"swe-{r}")
    h = headings(body)
    core = [x for x in h if x != "Steps"]
    if core != ["Reads", "Writes", "Never", "Returns"] or h.count(
            "Steps") > 1:
        bad_heads.append(f"swe-{r}")
if missing:
    report(2, False, "not checked for absent files")
    report(3, False, "not checked for absent files")
    report(4, False, "not checked for absent files")
else:
    report(2, not bad_fm, "front-matter: " + (", ".join(bad_fm) or "ok"))
    report(3, not bad_tools, "tools: " + (
        ", ".join(bad_tools) + " differ from contract 2.3"
        if bad_tools else "as contract 2.3"))
    report(4, not bad_heads, "body headings: " + (
        ", ".join(bad_heads) + " differ" if bad_heads else "as contract"))
sys.exit(0 if all(OK) else 1)
```

## Fails if

- A role file is missing, or its name, description or model is wrong.
- A role has a tool the contract does not give it, or lacks one it gives;
  in particular swe-review has Write or Edit, or swe-test lacks Agent.
- A body heading is missing, renamed, out of order, or extra.

## At base

Expected: fail, because `agents/` is absent at swe-pod `8fc5294`.

Observed 2026-10-27T23:55Z at the base commit set (space c814837,
swe-pod 8fc5294, agent-mesh 8ee5364), runner result:

```
fail (check I2.1: swe-pod 8fc5294: absent: agents/swe-spec.md, ... agents/swe-review.md)
```
