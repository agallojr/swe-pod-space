---
scenario: I3
mode: inspect
deliverables: [swe-pod:templates/space, swe-pod:templates/records]
fixture: none
expected_s: 1
heavy: false
env: any
cap_s: 30
---

# I3 The D3 files: sections, keys, and the space.yaml keys

This is right-size-testing's replacement of build-swe-pod's
`test_I3_d3_templates`: at integrate it replaces build-swe-pod's test of the
same name in `tests/build-swe-pod/` (open call 16). Its checks are
build-swe-pod's I3 checks unchanged, except the version line: check 14 now
expects `templates/space/pod.yaml` to give `process: swe-pod-process@2`, the
process version open call 16 sets (this change's interface contract §2.11).
Its `mode: inspect` makes it script class (R13).

Section, contract and requirement numbers below are build-swe-pod's, except
open call 16. The checks serve build-swe-pod's R4, R5, R11, R12, R16, R18,
R21 and R22 through D3 (build-swe-pod's contract §2.1 and §2.4).

## Given

`templates/space/` and `templates/records/` exported read-only from swe-pod
at the sha under test. The `space.yaml` keys are those of the space manifest
in `notes/note-20261027T2142Z-0a31-memory-spaces-design.md` §3.1, which the
spec relies on.

## When

```text
The runner exports templates/space and templates/records from swe-pod by sha
and runs the check below on them. No agent is run.
```

## Then

Section lists are checked in order, as level-2 headings outside fenced
blocks; other headings may sit between them.

1. `templates/space/` holds `space.yaml`, `pod.yaml`, `AGENTS.md`,
   `README.md`, and `changes/`, `tests/`, `decisions/`, `handoffs/`, `notes/`
   and `lore/`, each with a `.gitkeep`.
2. `templates/records/` holds `spec.md`, `plan.md`, `brief.md`,
   `test-brief.md`, `report.md`, `review.md`, `evidence.md`, `ledger.md`,
   `handoff.md` and `final-report.md`.
3. Spec: header lines `- approved:`, `- integrated:` and `- abandoned:`;
   sections Why, Scope, Requirements, Quality, Approaches, Open calls.
4. Plan: exactly twelve level-2 sections, the ten of spec §5.2 (Goal and
   approach, Interface contract, Global constraints, File map, Tasks, Test
   tasks, Review tasks, Integrate task, Test map, Dependency summary, a
   leading number allowed), then `## Self-review`, then
   `## Questions for the spec`, whose text sorts questions as answered, minor
   with the default planned, or for the human.
5. Brief: Task, Interfaces, Global constraints, Rulings, Start from, Result
   goes to.
6. Test-writing brief: Task, Spec, Interface contract, Global constraints,
   Test map, Start from, Suggestions, Result goes to; its last non-empty line
   is exactly `Do not read plan.md, ledger.md, any other brief, report or
   review, or any code-repo diff or implementation body.`
7. Report: Status, What I did, Files, Test output, Concerns, Test
   suggestions; Status names `DONE`, `DONE_WITH_CONCERNS`, `BLOCKED` and
   `NEEDS_CONTEXT`; Test suggestions shows a `### T<n>.TS<k>` heading with
   `- for the tester:` and `- for the reviewer:` lines.
8. Review: front-matter keys `task`, `diff` and `verdict` (pass or fix);
   sections Spec compliance, Quality, Findings; Findings shows the line form
   `- <severity> <repo>/<path>:<line> <text>`.
9. Evidence: front-matter keys `id` (an `ev-` id), `change`, `commit_set`,
   `env`, `actor` (a `/test` actor), `scenarios`, `unit`, `quality` and
   `wall_time_s`.
10. Ledger: one fenced block.
11. Handoff: State, Half-done, Open questions, Next command.
12. Final report: Scenarios (with a table), Rulings, Deferred minors, Test
    suggestions, Open questions, Branches.
13. `space.yaml` has exactly the 11 top-level keys of the manifest, by
    name: `space`, `id`, `kind`, `title`, `visibility`, `owners`,
    `writer_model`, `categories`, `header_profile`, `may_reference` and
    `retention`, with `kind: project` and `header_profile: shareable` (spec
    §8: kind project, shareable).
14. `pod.yaml` has the top-level keys `pod`, `project`, `process`, `repos`,
    `depends` and `gates`, with `process: swe-pod-process@2` (open call 16).

```python check
import os
import re
import sys
from pathlib import Path

TAG = "I3"
OK = []
FENCE = "`" * 3
LAST = ("Do not read plan.md, ledger.md, any other brief, report or review, "
        "or any code-repo diff or implementation body.")
VERSION = "swe-pod-process@2"


def report(n: int, ok: bool, why: str) -> None:
    OK.append(ok)
    print(f"{TAG}.{n} {'pass' if ok else 'fail'} {why}")


def outside(text: str) -> list:
    out, fenced = [], False
    for line in text.splitlines():
        if line.lstrip().startswith(FENCE):
            fenced = not fenced
            continue
        if not fenced:
            out.append(line)
    return out


def h2(text: str) -> list:
    return [ln[3:].strip() for ln in outside(text) if ln.startswith("## ")]


def norm(h: str) -> str:
    return re.sub(r"^\d+\.?\s*", "", h).strip().lower()


def in_order(heads: list, want: list) -> bool:
    it = iter(norm(h) for h in heads)
    return all(any(x == w.lower() for x in it) for w in want)


def section(text: str, name: str) -> str:
    out, on = [], False
    for ln in text.splitlines():
        if ln.startswith("## "):
            on = norm(ln[3:]) == name.lower()
            continue
        if on:
            out.append(ln)
    return "\n".join(out)


def front_keys(text: str) -> dict:
    m = re.match(r"---\n(.*?)\n---", text, re.S)
    if not m:
        return {}
    keys = {}
    for ln in m.group(1).splitlines():
        km = re.match(r"([A-Za-z_][\w-]*):\s*(.*)$", ln)
        if km:
            keys[km.group(1)] = km.group(2)
    return keys


def top_keys(text: str) -> dict:
    keys = {}
    for ln in text.splitlines():
        km = re.match(r"([A-Za-z_][\w-]*):(.*)$", ln)
        if km:
            keys[km.group(1)] = km.group(2).split("#", 1)[0].strip()
    return keys


sha = os.environ.get("SHA_SWE_POD", "?")
root = Path(os.environ["EXPORT_SWE_POD"]) / "templates"
sp, rec = root / "space", root / "records"
dirs = ["changes", "tests", "decisions", "handoffs", "notes", "lore"]
need = [sp / f for f in ("space.yaml", "pod.yaml", "AGENTS.md",
                         "README.md")] + [sp / d / ".gitkeep" for d in dirs]
miss = [str(p.relative_to(root.parent)) for p in need if not p.is_file()]
report(1, not miss, f"swe-pod {sha} templates/space: " + (
    "complete" if not miss else "absent: " + ", ".join(miss[:4])))
names = ["spec", "plan", "brief", "test-brief", "report", "review",
         "evidence", "ledger", "handoff", "final-report"]
miss_r = [n for n in names if not (rec / f"{n}.md").is_file()]
report(2, not miss_r, f"swe-pod {sha} templates/records: " + (
    "complete" if not miss_r else "absent: " + ", ".join(
        f"{n}.md" for n in miss_r[:4])))


def read(n: str) -> str:
    p = rec / f"{n}.md"
    return p.read_text() if p.is_file() else ""


t = read("spec")
hdr = all(re.search(rf"^\s*- {k}:", t, re.M)
          for k in ("approved", "integrated", "abandoned"))
report(3, bool(t) and hdr and in_order(h2(t), [
    "Why", "Scope", "Requirements", "Quality", "Approaches", "Open calls"]),
    "spec template header lines and sections")
t = read("plan")
ten = ["goal and approach", "interface contract", "global constraints",
       "file map", "tasks", "test tasks", "review tasks", "integrate task",
       "test map", "dependency summary"]
heads = [norm(h) for h in h2(t)]
ok4 = (len(heads) == 12 and all(heads[i].startswith(ten[i])
                                for i in range(10))
       and heads[10] == "self-review"
       and heads[11] == "questions for the spec")
q = section(t, "Questions for the spec").lower()
ok4 = ok4 and all(w in q for w in ("answered", "minor", "human"))
report(4, bool(t) and ok4, f"plan template: {len(heads)} level-2 sections"
       " against the 12 of contract 2.4, and the question sorting")
t = read("brief")
report(5, bool(t) and in_order(h2(t), [
    "Task", "Interfaces", "Global constraints", "Rulings", "Start from",
    "Result goes to"]), "brief template sections")
t = read("test-brief")
last = [ln.strip() for ln in t.splitlines() if ln.strip()]
report(6, bool(t) and in_order(h2(t), [
    "Task", "Spec", "Interface contract", "Global constraints", "Test map",
    "Start from", "Suggestions", "Result goes to"])
    and bool(last) and last[-1] == LAST,
    "test-brief template sections and exact last line")
t = read("report")
st = section(t, "Status")
ts = section(t, "Test suggestions")
ok7 = (in_order(h2(t), ["Status", "What I did", "Files", "Test output",
                        "Concerns", "Test suggestions"])
       and all(re.search(rf"\b{s}\b", st) for s in (
           "DONE", "DONE_WITH_CONCERNS", "BLOCKED", "NEEDS_CONTEXT"))
       and re.search(r"^### T\S*\.TS\S*", ts, re.M) is not None
       and "- for the tester:" in ts and "- for the reviewer:" in ts)
report(7, bool(t) and ok7, "report template sections, statuses and "
       "suggestion form")
t = read("review")
fk = front_keys(t)
fnd = section(t, "Findings")
ok8 = ({"task", "diff", "verdict"} <= set(fk)
       and "pass" in fk.get("verdict", "") and "fix" in fk.get("verdict", "")
       and in_order(h2(t), ["Spec compliance", "Quality", "Findings"])
       and re.search(r"^- <?(Critical|Important|Minor)\b.*\S/\S*:\S",
                     fnd, re.M) is not None)
report(8, bool(t) and ok8, "review template front-matter, sections and "
       "finding line form")
t = read("evidence")
fk = front_keys(t)
want9 = {"id", "change", "commit_set", "env", "actor", "scenarios", "unit",
         "quality", "wall_time_s"}
ok9 = (want9 <= set(fk) and fk.get("id", "").startswith("ev-")
       and "/test" in fk.get("actor", ""))
report(9, bool(t) and ok9, "evidence template front-matter keys: missing "
       + (", ".join(sorted(want9 - set(fk))) or "none"))
t = read("ledger")
report(10, bool(t) and t.count(FENCE) == 2, "ledger template has one "
       "fenced block")
t = read("handoff")
report(11, bool(t) and in_order(h2(t), [
    "State", "Half-done", "Open questions", "Next command"]),
    "handoff template sections")
t = read("final-report")
scen = section(t, "Scenarios")
report(12, bool(t) and in_order(h2(t), [
    "Scenarios", "Rulings", "Deferred minors", "Test suggestions",
    "Open questions", "Branches"]) and "|" in scen,
    "final-report template sections and scenario table")
p = sp / "space.yaml"
k = top_keys(p.read_text()) if p.is_file() else {}
MANIFEST = {"space", "id", "kind", "title", "visibility", "owners",
            "writer_model", "categories", "header_profile", "may_reference",
            "retention"}
lack, extra = sorted(MANIFEST - set(k)), sorted(set(k) - MANIFEST)
vals_ok = (k.get("kind") == "project"
           and k.get("header_profile") == "shareable")
report(13, p.is_file() and not lack and not extra and vals_ok,
       "space.yaml: " + ("absent" if not p.is_file() else
                         f"missing {', '.join(lack) or 'none'}; extra "
                         f"{', '.join(extra) or 'none'}; kind and "
                         f"header_profile {'as spec' if vals_ok else 'wrong'}"))
p = sp / "pod.yaml"
k = top_keys(p.read_text()) if p.is_file() else {}
lack14 = sorted({"pod", "project", "process", "repos", "depends", "gates"}
                - set(k))
report(14, not lack14 and k.get("process") == VERSION,
       f"pod.yaml keys and pinned process against {VERSION!r} (open call "
       f"16): missing {', '.join(lack14) or 'none'}; process is "
       f"{k.get('process', '<none>')!r}")
sys.exit(0 if all(OK) else 1)
```

## Fails if

- A template file or folder of build-swe-pod's contract §2.1 is missing.
- A record template lacks a section, header line or front-matter key of
  build-swe-pod's contract §2.4, or has them out of order.
- The test-writing brief template does not end with the exact line.
- `space.yaml` lacks one of the 11 manifest keys or has another top-level
  key, or `kind` is not `project`, or `header_profile` is not `shareable`.
- `pod.yaml` lacks a key of build-swe-pod's spec §4, or its `process:` is
  not `swe-pod-process@2` (open call 16), as when it still pins
  `swe-pod-process@1`.

## At base

Expected: fail on check I3.14 only. At the base commit set the process
version has not moved: the space's `pod.yaml` names `swe-pod-process@1`, and
open call 16 moves it to `@2` in this change. Checks I3.1 to I3.13 are
build-swe-pod's unchanged, and T3's done-when expects them to pass at base,
where swe-pod is at its pin.

Observed 2026-10-30T16:28Z at the base commit set (space 6f1e4e0,
swe-pod b7fc257, agent-mesh f27c611; the check reads only swe-pod's
`templates/space/` and `templates/records/`), wall time 1 s for this run and
I1's together, runner result:

```
fail (check I3.14: pod.yaml keys and pinned process against 'swe-pod-process@2' (open call 16): missing none; process is 'swe-pod-process@1')
```

Its check output: I3.1 to I3.13 pass, I3.14 fails, as expected.

```
I3.1 pass swe-pod b7fc257 templates/space: complete
I3.2 pass swe-pod b7fc257 templates/records: complete
I3.3 pass spec template header lines and sections
I3.4 pass plan template: 12 level-2 sections against the 12 of contract 2.4, and the question sorting
I3.5 pass brief template sections
I3.6 pass test-brief template sections and exact last line
I3.7 pass report template sections, statuses and suggestion form
I3.8 pass review template front-matter, sections and finding line form
I3.9 pass evidence template front-matter keys: missing none
I3.10 pass ledger template has one fenced block
I3.11 pass handoff template sections
I3.12 pass final-report template sections and scenario table
I3.13 pass space.yaml: missing none; extra none; kind and header_profile as spec
I3.14 fail pod.yaml keys and pinned process against 'swe-pod-process@2' (open call 16): missing none; process is 'swe-pod-process@1'
```
