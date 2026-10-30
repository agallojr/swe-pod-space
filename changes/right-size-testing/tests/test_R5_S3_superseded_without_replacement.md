---
scenario: R5.S3
mode: agent (skill)
class: agent
deliverables: [swe-pod:skills/swe-pod, swe-pod:PROCESS.md as PROCESS.md]
fixture: demo-space
expected_s: 120
heavy: true
env: any
cap_s: 600
risk: at risk: a false green from a superseded test with no passing replacement or no supersedes entry; an agent applying the skill must bar superseded by <key> when <key> fails or has no result, or when the spec's supersedes does not list the test's requirement, while a rightly superseded record (R5.S2's) is green
---

# R5.S3 A superseded test without a passing replacement

Serves R5 through contract 2.3, 2.4 and 2.5. Agent class: a
`superseded by <key>` result is no bar only when two things hold that an
agent must find in two records, `<key>`'s pass in the evidence and the
superseded test's requirement in the spec's `supersedes`. A script can
check that the skill states both conditions
(`test_R5_S2_superseded_with_replacement`), not that an agent checks both
before it calls the evidence green. One run regenerates `STATUS.md` over
four open changes, so one session shows three false-green cases and a
control.

The control is R5.S2's record. It is what makes the test fail at base:
there, a superseded test is not a pass, so every case of this scenario is
not green at base and only the control shows the loosened rule.

## Given

- A fresh default agent with the `swe-pod` skill from swe-pod at the sha
  under test, and that sha's `PROCESS.md` copied to the space root. No
  instruction file reaches the agent; it reads the space with its tools.
- The demo space (`proj:demo`; repos alpha `a1a1a1a`, beta `b2b2b2b` and
  gamma `c3c3c3c` at placeholder remotes no run can read), with its own
  change `add-greeting` removed and the files below built by the setup.
- An archived change, `changes/archive/2026-09-20-add-banner/`, with R1
  (scenarios R1.S1 and R1.S2) and R2 (R2.S1: `beta` prints the banner as
  its first line), whose three tests are the regression suite, in
  `tests/add-banner/`, all script class (`mode: inspect`):
  `test_R1_S1_banner_text`, `test_R1_S2_banner_width` and
  `test_R2_S1_banner_printed`.
- Four open changes, each small, in repo beta, after the go, with T1
  (build) done, T2 (blind test of R1.S1) done, T3 (verify) done with one
  evidence record at the branch head, and T4 (the whole-change review)
  `spec ok`. Each spec has one scenario, R1.S1, and no Quality section.
  Each record has `selection: full` (a full regression, on the operator's
  word, so no `not-selected` result plays a part), passes the unit suite
  (beta), passes `add-banner/R1.S1` and `add-banner/R1.S2`, and gives
  `add-banner/R2.S1` a `superseded by` result:

  | Change | Branch head | Spec `supersedes` | `R1.S1` | `add-banner/R2.S1` | Expected |
  |---|---|---|---|---|---|
  | `banner-late` (control, R5.S2) | beta `7a7a7a7` | `[add-banner/R2]` | pass | `superseded by R1.S1` | green |
  | `banner-quiet` | beta `7b7b7b7` | `[add-banner/R2]` | fail | `superseded by R1.S1` | not green: the named test fails |
  | `banner-boxed` | beta `7c7c7c7` | `[add-banner/R1]` | pass | `superseded by R1.S1` | not green: `supersedes` does not list add-banner/R2 |
  | `banner-dimmed` | beta `7d7d7d7` | `[add-banner/R2]` | pass | `superseded by R1.S3` | not green: the named key has no result in the record, and the spec has no R1.S3 |

- Each expected value comes from contract 2.4, applied by hand to the
  table above: `superseded by <key>` is no bar only when `<key>` holds
  `pass` in the same record and `supersedes` lists `add-banner/R2`, the
  requirement of a test keyed `add-banner/R2.S1`. The control's regression
  part, by contract 2.5, is `regression 2/2 pass, 1 superseded`: 2 tests
  need a pass and pass, and 1 is superseded and no bar.

```python setup
import hashlib
import json
import os
import shutil
from pathlib import Path

RUN = Path(os.environ["RUN_DIR"])
SPACE = Path(os.environ["SPACE"])
ARCH = "changes/archive/2026-09-20-add-banner"
TOUCHED = "[beta:beta/__main__.py, beta:tests/test_main.py]"
# Built, so that no line of this block is a bare fence or a level-2
# heading, which the runner would read as the end of the block or of
# a section of this test.
FENCE = "`" * 3
H2 = "#" * 2


def put(rel: str, body: str) -> None:
    p = SPACE / rel
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(body.strip("\n") + "\n")


def snapshot() -> None:
    """Record every space file's hash."""
    files = {}
    for p in sorted(SPACE.rglob("*")):
        if p.is_file():
            files[str(p.relative_to(SPACE))] = hashlib.sha256(
                p.read_bytes()).hexdigest()
    (RUN / "before.json").write_text(json.dumps(files, indent=1))


pod = (SPACE / "pod.yaml").read_text()
for pin in ("a1a1a1a", "b2b2b2b", "c3c3c3c"):
    assert f'pin: "{pin}"' in pod, f"demo pod.yaml lacks pin {pin}"
shutil.rmtree(SPACE / "changes" / "add-greeting")

# The archived change whose tests are the regression suite.
put(f"{ARCH}/spec.md", f"""
# add-banner: alpha holds a start-up banner that beta prints

- size: small
- owner: demo-owner
- repos: [alpha, beta]
- supersedes: []
- approved: demo-owner 2026-09-15T09:00Z
- integrated: demo-owner 2026-09-20T10:00Z

{H2} Why

beta should say when it is ready, in a text other tools can reuse.

{H2} Requirements

### R1 Banner text
`alpha` SHALL provide the banner `demo ready`, 10 characters wide.

#### R1.S1 Banner text
- GIVEN `alpha` at the branch head
- WHEN a caller asks for the banner
- THEN it gets the exact text `demo ready`

#### R1.S2 Banner width
- GIVEN `alpha` at the branch head
- WHEN a caller asks for the banner's width
- THEN it gets 10 (characters)

### R2 beta prints the banner
`beta` SHALL print the banner as its first line of output.

#### R2.S1 Banner printed
- GIVEN `beta` built against `alpha`
- WHEN `beta` starts with no arguments
- THEN its first line of standard output is `demo ready`

{H2} Approaches

1. Banner in `alpha`, printed by `beta` (picked).

{H2} Open calls

None.
""")
put(f"{ARCH}/plan.md", f"""
# add-banner plan

- change: add-banner
- spec: changes/archive/2026-09-20-add-banner/spec.md

Integrated 2026-09-20T10:00Z; every task is done.

{H2} 9 Test map

| Scenario | Test | Mode | Writes it |
|---|---|---|---|
| R1.S1 | test_R1_S1_banner_text | inspect | T3 |
| R1.S2 | test_R1_S2_banner_width | inspect | T3 |
| R2.S1 | test_R2_S1_banner_printed | inspect | T3 |
""")

SUITE = [
    ("test_R1_S1_banner_text", "R1.S1", "alpha:alpha/banner.py",
     "Banner text", "`alpha` at the commit set under test.",
     "The check calls `alpha.banner.banner()`.",
     "It returns `demo ready`."),
    ("test_R1_S2_banner_width", "R1.S2", "alpha:alpha/width.py",
     "Banner width", "`alpha` at the commit set under test.",
     "The check calls `alpha.width.width()`.",
     "It returns 10 (characters)."),
    ("test_R2_S1_banner_printed", "R2.S1", "beta:beta/__main__.py",
     "Banner printed",
     "`beta` at the commit set under test, with `alpha` beside it.",
     "The check runs `python3 -m beta` with no arguments.",
     "Its first line of standard output is `demo ready`."),
]
for name, sid, deliv, title, given, when, then in SUITE:
    put(f"tests/add-banner/{name}.md", f"""
---
scenario: {sid}
mode: inspect
deliverables: [{deliv}]
fixture: none
expected_s: 1
heavy: false
env: any
cap_s: 30
---

# {sid} {title}

Promoted from add-banner at its integrate.

{H2} Given

{given}

{H2} When

{when}

{H2} Then

1. {then}
""")

CASES = [
    dict(cid="banner-late", day="2026-10-07", head="7a7a7a7",
         space="8a8a8a8", wall=25,
         title="print the banner after the start-up checks",
         req="Banner after the checks", sup="add-banner/R2",
         text="`beta` SHALL print the banner as the last line of its "
              "start-up, after its checks pass.",
         why="add-banner R2 has beta print the banner first, before its "
             "checks can fail. This change moves it after them, so it "
             "supersedes add-banner/R2.",
         given="`beta` built against `alpha`, whose checks pass",
         when="`beta` starts with no arguments",
         then="its last start-up line is `demo ready`, after the line "
              "`checks ok`",
         slug="banner_after_checks", atbase="beta prints the banner first",
         r11="pass", key="R1.S1", note=""),
    dict(cid="banner-quiet", day="2026-10-08", head="7b7b7b7",
         space="8b8b8b8", wall=24, title="print no banner under --quiet",
         req="No banner when quiet", sup="add-banner/R2",
         text="`beta` SHALL print no banner when started with `--quiet`, "
              "and print it after its checks otherwise.",
         why="Scripts that run beta want no banner in its output. This "
             "change takes the banner off beta's first line, so it "
             "supersedes add-banner/R2.",
         given="`beta` built against `alpha`",
         when="`beta` starts with `--quiet`",
         then="its output holds no `demo ready` line",
         slug="banner_quiet", atbase="beta prints the banner under --quiet",
         r11="fail", key="R1.S1",
         note=" test_R1_S1_banner_quiet failed: beta printed `demo ready` "
              "under `--quiet`."),
    dict(cid="banner-boxed", day="2026-10-09", head="7c7c7c7",
         space="8c8c8c8", wall=26, title="print the banner in a box",
         req="Boxed banner", sup="add-banner/R1",
         text="`beta` SHALL print the banner inside a box of `+`, `-` and "
              "`|`, as its first three lines.",
         why="A boxed banner is easier to find in a long log. The box "
             "changes the text add-banner R1 fixes, so this change "
             "supersedes add-banner/R1.",
         given="`beta` built against `alpha`",
         when="`beta` starts with no arguments",
         then="its first three lines are `+------------+`, "
              "`| demo ready |` and `+------------+`",
         slug="banner_boxed", atbase="beta prints no box",
         r11="pass", key="R1.S1", note=""),
    dict(cid="banner-dimmed", day="2026-10-10", head="7d7d7d7",
         space="8d8d8d8", wall=25, title="print the banner dimmed",
         req="Dimmed banner", sup="add-banner/R2",
         text="`beta` SHALL print the banner dimmed (ANSI SGR 2) when its "
              "output is a terminal, after its checks pass.",
         why="A dimmed banner stays out of the way of the checks' output. "
             "This change takes the banner off beta's first line, so it "
             "supersedes add-banner/R2.",
         given="`beta` built against `alpha`, its output a terminal",
         when="`beta` starts with no arguments",
         then="its last start-up line is `demo ready` between the escape "
              "sequences `ESC[2m` and `ESC[0m`",
         slug="banner_dimmed", atbase="beta prints the banner undimmed",
         r11="pass", key="R1.S3", note=""),
]

for c in CASES:
    cid, d, head = c["cid"], c["day"], c["head"]
    dc = d.replace("-", "")
    test = f"test_R1_S1_{c['slug']}"
    put(f"changes/{cid}/spec.md", f"""
# {cid}: {c['title']}

- size: small
- owner: demo-owner
- repos: [beta]
- supersedes: [{c['sup']}]
- approved: demo-owner {d}T08:00Z

{H2} Why

{c['why']}

{H2} Requirements

### R1 {c['req']}
{c['text']}

#### R1.S1 {c['req']}
- GIVEN {c['given']}
- WHEN {c['when']}
- THEN {c['then']}

{H2} Approaches

1. Change `beta/__main__.py` only (picked).

{H2} Open calls

None.
""")
    put(f"changes/{cid}/plan.md", f"""
# {cid} plan

- change: {cid}
- spec: changes/{cid}/spec.md

{H2} 1 Goal and approach

One build task in `beta`, one blind test of R1.S1, verify, and the
whole-change review.

{H2} 5 Tasks

### T1 {c['req']} in beta
- role: build
- repo: beta
- after: []
- runs: local
- needs: any
- serves: [R1]
- risk: at risk: it replaces behavior an integrated change fixed
- touches: beta/__main__.py, tests/test_main.py
- done when: `python3 -m unittest discover -s tests -t .` passes in beta
  at the branch head

### T2 Blind test of R1.S1
- role: test
- repo: space
- after: []
- runs: local
- needs: any
- serves: [R1]
- done when: changes/{cid}/tests/{test}.md exists and fails at the base
  commit set for its stated reason

### T3 Verify
- role: test
- repo: space
- after: [T1, T2]
- runs: local
- needs: any
- serves: [R1]
- done when: an evidence record is filed with a result for every scenario,
  unit suite and regression test, in a full regression on the operator's
  word

### T4 Whole-change review
- role: review
- repo: space
- after: [T3]
- runs: local
- needs: any
- serves: [R1]
- done when: changes/{cid}/tasks/T4-review.md holds a verdict

### T5 Integrate
- role: lead
- repo: space
- after: [T3, T4]
- runs: local
- needs: any
- serves: [R1]
- done when: merged, tests promoted, pins advanced, final report filed

{H2} 6 Risk and expensive runs

| Requirement | Risk | Reason |
|---|---|---|
| R1 | at risk | it replaces behavior an integrated change fixed |

No agent-class or live-class run.

{H2} 9 Test map

| Scenario | Test | Class | Risk it covers | Expected (s) | Keep | Written by | Unit tests that also cover it |
|---|---|---|---|---|---|---|---|
| R1.S1 | {test} | script | at risk: the new start-up output | 1 | keep | T2 | tests/test_main.py |

{H2} 10 Dependency summary

T1 and T2 start at the go; T3 waits for both, T4 for T3, and T5 for T3 and
T4. The one build task is one wave, so the one review is the whole-change
review.
""")
    put(f"changes/{cid}/ledger.md", f"""
# Ledger: {cid}

{FENCE}
{d}T08:00Z spec approved by demo-owner
{d}T08:10Z go by demo-owner; branches change/{cid}: beta b2b2b2b
{d}T08:11Z dispatch T1 -> build (local, any), base beta b2b2b2b
{d}T08:11Z dispatch T2 -> test (local, any)
{d}T08:40Z T1 DONE, beta b2b2b2b..{head}, unit 4/4 pass
{d}T08:50Z T2 DONE
{d}T08:51Z T2 at base: {test} fail ({c['atbase']})
{d}T08:52Z filed changes/{cid}/tests/{test}.md
{d}T09:00Z dispatch T3 -> test (local, any)
{d}T11:30Z T3 DONE
{d}T11:31Z filed changes/{cid}/evidence/{dc}T1130Z.md
{d}T11:35Z dispatch T4 -> review (local, any)
{d}T12:00Z T4 review: spec ok; 0 Important
{d}T12:01Z filed changes/{cid}/tasks/T4-review.md
{FENCE}
""")
    put(f"changes/{cid}/tasks/T4-review.md", f"""
# T4 review: {cid}

- verdict: spec ok
- findings: none
""")
    put(f"changes/{cid}/tests/{test}.md", f"""
---
scenario: R1.S1
mode: inspect
class: script
deliverables: [beta:beta/__main__.py]
fixture: none
expected_s: 1
heavy: false
env: any
cap_s: 30
risk: at risk: the new start-up output
---

# R1.S1 {c['req']}

{H2} Given

{c['given'][0].upper() + c['given'][1:]}.

{H2} When

The check runs `python3 -m beta`: {c['when']}.

{H2} Then

1. {c['then'][0].upper() + c['then'][1:]}.
""")
    scen = (f"R1.S1: {c['r11']}, add-banner/R1.S1: pass, "
            f"add-banner/R1.S2: pass, "
            f"add-banner/R2.S1: superseded by {c['key']}")
    put(f"changes/{cid}/evidence/{dc}T1130Z.md", f"""
---
id: ev-{dc}T1130Z
change: {cid}
commit_set: {{space: {c['space']}, alpha: a1a1a1a, beta: {head}, gamma: c3c3c3c}}
env: macos-laptop
actor: demo-owner/test
selection: full
touched: {TOUCHED}
scenarios: {{{scen}}}
unit: {{beta: pass}}
quality: none-declared
wall_time_s: {c['wall']}
---

Selection: full, a full regression on the operator's word. Run: {test},
test_R1_S1_banner_text, test_R1_S2_banner_width. test_R2_S1_banner_printed
is superseded by {c['key']}, this change's test of the new start-up
output.{c['note']}
Run logs: the run dirs of the tests above, kept on the node, named by test.
""")

snapshot()
```

## When

```text
Regenerate STATUS.md.
```

## Then

The check reads `STATUS.md` in the space after the run, in the layout of
`status-format.md`: for each change, its `## <id>   state: <state>`
heading and its `- latest evidence: <ev id>, <env>, <green|not green>[,
stale]: <results>` line, with backticks and Markdown emphasis removed. No
phrase of the deliverables is checked.

1. `banner-quiet`'s latest evidence is `not green`, and its state is not
   `verified`.
2. `banner-boxed`'s latest evidence is `not green`, and its state is not
   `verified`.
3. `banner-dimmed`'s latest evidence is `not green`, and its state is not
   `verified`.
4. `banner-late`'s latest evidence is `ev-20261007T1130Z`, `green` and not
   `stale`.
5. `banner-late`'s results give the regression part
   `regression 2/2 pass, 1 superseded`, with no not-selected part.
6. No space file but `STATUS.md` is added, changed or removed.

```python check
import hashlib
import json
import os
import re
import sys
from pathlib import Path

TAG = "R5.S3"
OK = []
RUN = Path(os.environ["RUN_DIR"])
SPACE = Path(os.environ["SPACE"])


def report(n: int, ok: bool, why: str) -> None:
    OK.append(bool(ok))
    print(f"{TAG}.{n} {'pass' if ok else 'fail'} {why}")


st_path = SPACE / "STATUS.md"
st = st_path.read_text() if st_path.is_file() else ""
st = st.replace("`", "").replace("*", "")


def change(cid: str) -> tuple:
    """(state, latest-evidence verdict, stale, ev id, results) of a change."""
    m = re.search(r"^##\s+" + re.escape(cid) + r"(?![\w-])(.*)$", st, re.M)
    if not m:
        return None, None, False, None, None
    sm = re.search(r"state:\s*([a-z-]+)", m.group(1))
    rest = st[m.end():]
    n = re.search(r"^##\s", rest, re.M)
    body = rest[:n.start()] if n else rest
    line = None
    for ln in body.splitlines():
        s = ln.strip()
        if s.lower().startswith("- latest evidence:"):
            line = s[len("- latest evidence:"):].strip()
            break
    if line is None:
        return (sm.group(1) if sm else None), None, False, None, None
    head, _, results = line.partition(": ")
    h = head.lower()
    verdict = ("not green" if re.search(r"\bnot green\b", h) else
               "green" if re.search(r"\bgreen\b", h) else None)
    ev = head.split(",")[0].strip()
    return ((sm.group(1) if sm else None), verdict,
            bool(re.search(r"\bstale\b", h)), ev, results)


def said(cid: str) -> str:
    state, verdict, stale, ev, _ = change(cid)
    if not st:
        return "no STATUS.md written"
    return (f"{cid}: state {state or 'absent'}, latest evidence "
            f"{ev or 'absent'} {verdict or 'no verdict'}"
            + (", stale" if stale else ""))


for n, cid in ((1, "banner-quiet"), (2, "banner-boxed"),
               (3, "banner-dimmed")):
    state, verdict, stale, ev, _ = change(cid)
    report(n, verdict == "not green" and state not in (None, "verified"),
           said(cid))

state, verdict, stale, ev, results = change("banner-late")
report(4, verdict == "green" and not stale and ev == "ev-20261007T1130Z",
       said("banner-late"))

want = re.compile(r"(^|,\s*)regression 2/2 pass, 1 superseded\s*(,|$)")
got = re.search(r"regression [^,]*(, \d+ (not-selected|superseded))*",
                results or "")
report(5, bool(results) and bool(want.search(results)),
       "banner-late regression part: "
       + (repr(got.group(0)) if got else "absent"))

before = json.loads((RUN / "before.json").read_text())
now = {}
for p in SPACE.rglob("*"):
    if p.is_file():
        now[str(p.relative_to(SPACE))] = hashlib.sha256(
            p.read_bytes()).hexdigest()
moved = sorted(k for k in set(before) | set(now)
               if before.get(k) != now.get(k) and k != "STATUS.md")
report(6, not moved, f"{len(moved)} space file(s) added, changed or removed "
       "besides STATUS.md" + (f": {', '.join(moved[:4])}" if moved else ""))
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- The agent takes `superseded by <key>` as no bar without finding `<key>`'s
  pass in the record, and calls `banner-quiet` or `banner-dimmed` green.
- It takes `superseded by` as no bar without finding the test's
  requirement, `add-banner/R2`, in the spec's `supersedes`, or matches any
  entry of the same change, and calls `banner-boxed` green.
- It calls `banner-late` not green, though its one superseded test has a
  passing replacement and a `supersedes` entry: a rightly superseded test
  kept from green.
- `banner-late`'s line does not show the superseded test apart from the 2
  passes.
- It edits a record, such as an evidence record, instead of reading it.

## At base

Expected: fail at check 4, because swe-pod `b7fc257`'s skill needs a pass
of every regression test and knows no `superseded` result, so
`banner-late` is not green; checks 1 to 3 pass there, since every case of
the scenario is not green at base too, and check 5 fails, the base form
being `regression <p>/<n> pass` only.

Observed 2026-10-30T16:46Z at the base commit set (space 6f1e4e0, swe-pod
b7fc257, agent-mesh f27c611), after a passing smoke; 86 s wall time
(agent run 84 s, 11 turns), 0.42 USD as the CLI reports it, no spend-limit
or safeguard stop; runner result:

```
fail (check R5.S3.4: banner-late: state building, latest evidence ev-20261007T1130Z not green)
```

Checks 1 to 3 passed and 6 passed; check 5 failed with
`regression 2/3 pass`. The agent said each `superseded by` result "isn't a
pass", so `regression 2/3`, the base rule.
