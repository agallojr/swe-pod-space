---
scenario: R20.S1
mode: agent (skill, then skill)
deliverables: [swe-pod:skills/swe-pod, swe-pod:PROCESS.md as PROCESS.md]
fixture: demo-space
expected_s: 240
heavy: true
env: any
cap_s: 1200
---

# R20.S1 Regenerating STATUS.md from the records gives the same text

Serves R20 through D4 (the skill and `status-format.md`). Heavy: two agent
runs of about 2 min each.

## Given

- Two steps, each a fresh default agent in its own process with a reset
  config, each with the `swe-pod` skill installed and `PROCESS.md` copied to
  the space root.
- The demo space with this test's overlay: the two open changes of R18.S1,
  and no `STATUS.md`. The newest ledger line or record is
  2026-11-02T08:00Z.
- Step 1's `STATUS.md` stands for the committed one; step 2 rebuilds it from
  the same records without reading it.

```python setup
import hashlib
import json
import os
from pathlib import Path

RUN = Path(os.environ["RUN_DIR"])
SPACE = Path(os.environ["SPACE"])


def snapshot() -> None:
    """Record every space file's hash, and keep a copy of each ledger."""
    files = {}
    for p in sorted(SPACE.rglob("*")):
        if p.is_file():
            files[str(p.relative_to(SPACE))] = hashlib.sha256(
                p.read_bytes()).hexdigest()
    (RUN / "before.json").write_text(json.dumps(files, indent=1))
    for rel in files:
        if rel.endswith("ledger.md"):
            dst = RUN / "before" / rel
            dst.parent.mkdir(parents=True, exist_ok=True)
            dst.write_bytes((SPACE / rel).read_bytes())

snapshot()
```

## When

```text
Regenerate STATUS.md.
```

```text
Regenerate STATUS.md from the records, but write it to x-rebuild/STATUS.md in
the space, not to the space root, and do not open the space's own STATUS.md: I
want to compare the two.
```

## Then

1. Step 1 writes `STATUS.md`, whose first non-empty line is `# Status:
   proj:demo`, with the line `Generated from the records; never edited by
   hand. As of <UTC>.`
2. The As-of time is 2026-11-02T08:00Z, the newest ledger line, not the wall
   clock.
3. The pins line names alpha `a1a1a1a`, beta `b2b2b2b` and gamma `c3c3c3c`.
4. Step 2 neither reads nor writes the space's `STATUS.md`.
5. Step 2's `x-rebuild/STATUS.md` matches `STATUS.md` line for line, trailing
   spaces and blank lines at the end aside.

```python check
TAG = "R20.S1"
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

AGENT_TOOLS = ("Agent", "Task")


def events(path: Path) -> list:
    """Ordered (position, kind, parent, data) items of a stream-json file.

    kind is text, use (a tool call) or result (a tool result); parent is the
    Agent call id for a subagent's items, else None."""
    out = []
    for i, line in enumerate(path.read_text().splitlines()):
        try:
            ev = json.loads(line)
        except json.JSONDecodeError:
            continue
        t = ev.get("type")
        if t not in ("assistant", "user"):
            continue
        parent = ev.get("parent_tool_use_id")
        content = (ev.get("message") or {}).get("content") or []
        if not isinstance(content, list):
            continue
        for j, c in enumerate(content):
            if not isinstance(c, dict):
                continue
            ct, at = c.get("type"), (i, j)
            if ct == "text" and t == "assistant":
                out.append((at, "text", parent, c.get("text") or ""))
            elif ct == "tool_use":
                out.append((at, "use", parent, c))
            elif ct == "tool_result":
                body = c.get("content")
                if isinstance(body, list):
                    body = "\n".join(x.get("text", "") for x in body
                                     if isinstance(x, dict))
                out.append((at, "result", parent,
                            {"id": c.get("tool_use_id"),
                             "text": str(body or ""),
                             "is_error": bool(c.get("is_error"))}))
    return out


def agent_calls(evs: list, top: bool = True) -> list:
    """(position, call) for each Agent call; the session's own by default."""
    return [(at, d) for at, k, p, d in evs if k == "use"
            and d.get("name") in AGENT_TOOLS and (p is None or not top)]


def call_text(d: dict) -> str:
    inp = d.get("input") or {}
    return " ".join(str(inp.get(k, "")) for k in
                    ("subagent_type", "description", "prompt"))


def tool_blob(d: dict) -> str:
    inp = d.get("input") or {}
    return " ".join(str(inp.get(k, "")) for k in (
        "file_path", "path", "command", "pattern", "glob", "content",
        "new_string"))

st_p = SPACE / "STATUS.md"
st = st_p.read_text() if st_p.is_file() else ""
lines = [ln.rstrip() for ln in st.splitlines() if ln.strip()]
GEN = "Generated from the records; never edited by hand. As of "
gen = next((ln for ln in lines if ln.startswith(GEN)), "")
head_ok = bool(lines) and lines[0] == "# Status: proj:demo" and bool(gen)
report(1, head_ok, "STATUS.md " + (
    "absent" if not st else "header and Generated line " + (
        "present" if head_ok else "wrong")))
asof = gen[len(GEN):] if gen else ""
report(2, bool(re.match(r"2026-11-02[T ]08:00", asof)),
       "As of " + ("the newest ledger line" if re.match(
           r"2026-11-02[T ]08:00", asof) else "another time"))
pins = next((ln for ln in lines if ln.startswith("- pins: ")), "")
report(3, all(x in pins for x in ("alpha a1a1a1a", "beta b2b2b2b",
                                  "gamma c3c3c3c")), "pins line " + (
    "complete" if pins else "absent"))
peek = []
for at, k, p, d in events(stream(2)):
    if k != "use" or d.get("name") not in ("Read", "Grep", "Edit", "Write",
                                           "Bash"):
        continue
    b = tool_blob(d)
    if "STATUS.md" in b.replace("x-rebuild/STATUS.md", ""):
        peek.append(d.get("name"))
report(4, not peek, f"step 2 touched the space's STATUS.md {len(peek)} "
       "time(s)")
rb = SPACE / "x-rebuild" / "STATUS.md"


def norm(t: str) -> list:
    out = [ln.rstrip() for ln in t.splitlines()]
    while out and not out[-1]:
        out.pop()
    return out


a, b = norm(st), norm(rb.read_text()) if rb.is_file() else []
diff = next((i + 1 for i, (x, y) in enumerate(zip(a, b)) if x != y), None)
if diff is None and len(a) != len(b):
    diff = min(len(a), len(b)) + 1
report(5, bool(a) and rb.is_file() and diff is None, "rebuild " + (
    "absent" if not rb.is_file() else "matches" if diff is None and a else
    f"differs from line {diff}"))
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- The rebuild differs from `STATUS.md` in any line.
- The As-of time comes from the wall clock or a file time.
- Step 2 copies the committed `STATUS.md` rather than rebuilding it.

## At base

Expected: fail, because the swe-pod deliverables are absent at swe-pod
`8fc5294`; the runner records the first absent deliverable and starts no
agent.

Observed 2026-10-28T00:43Z at the base commit set (space c814837, swe-pod
8fc5294, agent-mesh 8ee5364), runner result:

```
fail (deliverable absent: swe-pod 8fc5294 skills/swe-pod)
```
