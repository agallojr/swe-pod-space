---
scenario: I7
mode: inspect
deliverables: [agent-mesh:spec/PROTOCOL.md, agent-mesh:skills/mesh-on, agent-mesh:skills/mesh-load, agent-mesh:skills/space-librarian, agent-mesh:docs, agent-mesh:guidance, agent-mesh:README.md, agent-mesh:INSTALL.md]
fixture: none
expected_s: 1
heavy: false
env: any
cap_s: 30
---

# I7 The agent-mesh documents

Serves R7, R13 and R17 through D5 (M1 to M3 and M5; contract §2.7).

## Given

`spec/PROTOCOL.md`, `skills/mesh-on/`, `skills/mesh-load/`,
`skills/space-librarian/`, `docs/`, `guidance/`, `README.md` and `INSTALL.md`
exported read-only from agent-mesh at the sha under test; together they are
"the agent-mesh documents". Sections of `PROTOCOL.md` are its level-2 headings
`## <n>. <title>`.

## When

```text
The runner exports the documents from agent-mesh by sha and runs the check
below on them. No agent is run.
```

## Then

1. `project:`: PROTOCOL §5 documents the optional task field
   `project: proj:<name>`.
2. `files:`: PROTOCOL documents the result front-matter list `files:` with
   its `sha256`, the `<task-id>-files/` folder in the outbox, and the
   1048576-byte limit; §9 sweeps those files with their task.
3. The spaces rows: PROTOCOL §3 has a row or line for `spaces/` and one for
   `spaces.yaml`.
4. The six roles: `swe.spec`, `swe.plan`, `swe.lead`, `swe.build`,
   `swe.test` and `swe.review` are all named in one of the agent-mesh
   documents. M1 is registration
   only, with no protocol change, so §2 is not required to list them.
5. The `mesh-load` skill: `skills/mesh-load/SKILL.md` exists with
   `name: mesh-load`, gives the verbs "load" and "drop", and the line form
   `NOT MOUNTED proj:<name>`.
6. The `space-librarian` skill: `skills/space-librarian/SKILL.md` exists with
   `name: space-librarian` and gives the output forms `FILED` and
   `REFUSED`.
7. The scan-loop list mode: `MESH_SCAN_LIST=1` is documented in one of the
   agent-mesh documents.

```python check
import os
import re
import sys
from pathlib import Path

TAG = "I7"
OK = []


def report(n: int, ok: bool, why: str) -> None:
    OK.append(ok)
    print(f"{TAG}.{n} {'pass' if ok else 'fail'} {why}")


def sections(text: str) -> dict:
    out, cur = {}, None
    for ln in text.splitlines():
        m = re.match(r"## (\d+)\.", ln)
        if m:
            cur = m.group(1)
            out[cur] = []
        if cur is not None:
            out[cur].append(ln)
    return {k: "\n".join(v) for k, v in out.items()}


def skill(path: Path, name: str) -> str:
    if not path.is_file():
        return ""
    t = path.read_text()
    m = re.match(r"---\n(.*?)\n---", t, re.S)
    if not m or not re.search(rf"^name:\s*{name}\s*$", m.group(1), re.M):
        return ""
    return t


sha = os.environ.get("SHA_AGENT_MESH", "?")
root = Path(os.environ["EXPORT_AGENT_MESH"])
proto_p = root / "spec" / "PROTOCOL.md"
proto = proto_p.read_text() if proto_p.is_file() else ""
sec = sections(proto)
s5 = sec.get("5", "")
report(1, re.search(r"project:\s*proj:", s5) is not None,
       f"agent-mesh {sha}: PROTOCOL section 5 "
       + ("documents" if re.search(r"project:\s*proj:", s5) else
          "does not document") + " the project field")
parts = {"files: list": "files:" in proto, "sha256": "sha256" in proto,
         "-files/ folder": "-files/" in proto,
         "1048576-byte limit": "1048576" in proto,
         "sweep in section 9": re.search(r"-files|result files|files:",
                                         sec.get("9", "")) is not None}
lack = [k for k, v in parts.items() if not v]
report(2, not lack, "result files: " + (
    "documented, and swept in section 9" if not lack else
    "missing " + ", ".join(lack)))
s3 = sec.get("3", "")
ok3 = re.search(r"spaces/", s3) is not None and "spaces.yaml" in s3
report(3, ok3, "section 3 spaces rows " + ("present" if ok3 else "absent"))
roles = ["swe.spec", "swe.plan", "swe.lead", "swe.build", "swe.test",
         "swe.review"]
role_docs = sorted(root.rglob("*.md")) if root.is_dir() else []
best = 0
for p in role_docs:
    if p.is_file():
        text = p.read_text()
        best = max(best, sum(1 for r in roles if r in text))
report(4, best == 6, f"six roles: at most {best} of 6 named in one "
       "document")
ml = skill(root / "skills" / "mesh-load" / "SKILL.md", "mesh-load")
ok5 = bool(ml) and "NOT MOUNTED proj:" in ml and re.search(
    r"\bload\b", ml) is not None and re.search(r"\bdrop\b", ml) is not None
report(5, ok5, "mesh-load skill " + (
    "as contract" if ok5 else "absent or incomplete"))
sl = skill(root / "skills" / "space-librarian" / "SKILL.md",
           "space-librarian")
ok6 = bool(sl) and "FILED" in sl and "REFUSED" in sl
report(6, ok6, "space-librarian skill " + (
    "as contract" if ok6 else "absent or incomplete"))
docs = role_docs
ok7 = any("MESH_SCAN_LIST=1" in p.read_text() for p in docs if p.is_file())
report(7, ok7, "scan-loop list mode " + (
    "documented" if ok7 else "not documented"))
sys.exit(0 if all(OK) else 1)
```

## Fails if

- PROTOCOL does not document the `project:` field, the `files:` result list
  with its folder, hash, size limit and sweep, or the spaces rows, in the
  sections named.
- No agent-mesh document names all six roles.
- Either new skill is missing, misnamed, or lacks its output forms.
- The scan-loop list mode is not documented.

## At base

Expected: fail, because the new content is absent at agent-mesh `8ee5364`:
PROTOCOL §5 has no `project:` field, and `skills/mesh-load/` and
`skills/space-librarian/` do not exist.

Observed 2026-10-27T23:55Z at the base commit set (space c814837,
swe-pod 8fc5294, agent-mesh 8ee5364), runner result:

```
fail (check I7.1: agent-mesh 8ee5364: PROTOCOL section 5 does not document the project field)
```
