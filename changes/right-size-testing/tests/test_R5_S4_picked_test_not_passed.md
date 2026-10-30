---
scenario: R5.S4
mode: agent (skill)
class: agent
deliverables: [swe-pod:skills/swe-pod, swe-pod:PROCESS.md as PROCESS.md]
fixture: demo-space
expected_s: 120
heavy: true
env: any
cap_s: 600
risk: at risk: a false green from a picked test given not-selected or not-run; an agent applying the skill must still bar a script-class test of a touched file, or an agent-class test the plan names, given not-selected, and a selected test given not-run (cap 600 s), while a rightly targeted record (R5.S1's, in small) is green
---

# R5.S4 A test the selection picks is not passed

Serves R5 through contract 2.1, 2.2, 2.4 and 2.5. Agent class: whether a
`not-selected` result is a bar depends on what the selection picks, which
an agent works out from each regression test's class and deliverables, the
record's `touched` list and the plan's test map. A script can check that
the skill states the rule (`test_R5_S1_not_selected_green`), not that an
agent applies it without reading every `not-selected` as no bar. One run
regenerates `STATUS.md` over four open changes, so one session shows the
three false-green cases of the scenario and a control.

The control is this scenario's GIVEN with nothing wrong in it, which is
R5.S1's record in small. It is what makes the test fail at base: there,
every regression test needs a pass, so the three bars of the scenario hold
at base and only the control shows the loosened rule.

## Given

- A fresh default agent with the `swe-pod` skill from swe-pod at the sha
  under test, and that sha's `PROCESS.md` copied to the space root. No
  instruction file reaches the agent; it reads the space with its tools.
- The demo space (`proj:demo`; repos alpha `a1a1a1a`, beta `b2b2b2b` and
  gamma `c3c3c3c` at placeholder remotes no run can read), with its own
  change `add-greeting` removed and the files below built by the setup.
- An archived change, `changes/archive/2026-09-20-add-banner/`, whose five
  tests are the regression suite, in `tests/add-banner/`:

  | Test | Class (from `mode:`) | Deliverables |
  |---|---|---|
  | `test_R1_S1_banner_text` | script (`inspect`) | `alpha:alpha/banner.py` |
  | `test_R1_S2_banner_width` | script (`inspect`) | `alpha:alpha/width.py` |
  | `test_R2_S1_banner_printed` | script (`inspect`) | `beta:beta/__main__.py` |
  | `test_R3_S1_banner_from_skill` | agent (`agent (skill)`) | `alpha:alpha/banner.py` |
  | `test_R3_S2_banner_on_node` | live (`live (node)`) | `alpha:alpha/banner.py` |

- Four open changes, each small, in repo alpha, after the go, with T1
  (build) done, T2 (blind test of R1.S1) done, T3 (verify) done with one
  evidence record at the branch head, and T4 (the whole-change review)
  `spec ok`. Each record has `selection: targeted` and
  `touched: [alpha:alpha/banner.py, alpha:tests/test_banner.py]`, passes
  the change's R1.S1, its unit suite (alpha), and has no Quality section
  (`quality: none-declared`). Each plan's test map names
  `test_R3_S1_banner_from_skill` (`add-banner/R3.S1`) for a risk.
- So, by contract 2.2, each change's selection picks
  `test_R1_S1_banner_text` (script class, reads the touched
  `alpha/banner.py`) and `test_R3_S1_banner_from_skill` (agent class,
  named by the plan), and picks no other: `test_R1_S2_banner_width` and
  `test_R2_S1_banner_printed` read no touched file, and
  `test_R3_S2_banner_on_node` reads one but is live class and not named.
  The four records differ only in these results:

  | Change | Branch head | `add-banner/R1.S1` | `add-banner/R3.S1` | Others | Expected |
  |---|---|---|---|---|---|
  | `pad-banner` (control) | alpha `1d1d1d1` | pass | pass | not-selected | green |
  | `trim-banner` | alpha `2e2e2e2` | not-selected | pass | not-selected | not green: a picked script-class test of a touched file not run |
  | `wrap-banner` | alpha `3f3f3f3` | pass | not-selected | not-selected | not green: the agent-class test the plan names not run |
  | `fold-banner` | alpha `4a4a4a4` | pass | `not-run (cap 600 s)` | not-selected | not green: a selected test stopped at its cap |

- Each expected value comes from contract 2.2 and 2.4, applied by hand to
  the table above: a `not-selected` result is no bar only for a test the
  selection does not pick, and `not-run` is always a bar. The control's
  regression part, by contract 2.5, is `regression 2/2 pass, 3
  not-selected`: 2 tests need a pass and pass, and 3 are `not-selected`
  and no bar.

```python setup
import hashlib
import json
import os
import shutil
from pathlib import Path

RUN = Path(os.environ["RUN_DIR"])
SPACE = Path(os.environ["SPACE"])
ARCH = "changes/archive/2026-09-20-add-banner"
TOUCHED = "[alpha:alpha/banner.py, alpha:tests/test_banner.py]"
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

### R3 The banner as an agent and a node report it
The banner an agent reads in `alpha`'s docs, and the one a running node
logs, SHALL be `alpha`'s banner.

#### R3.S1 An agent reads the banner
- GIVEN a fresh agent with `alpha`'s banner module and docs
- WHEN it is asked what `beta` prints at start-up
- THEN it answers `demo ready`

#### R3.S2 The banner on a running node
- GIVEN a demo node running `beta`
- WHEN `beta` restarts on it
- THEN the node's log gives `demo ready` as `beta`'s first line

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
| R3.S1 | test_R3_S1_banner_from_skill | agent (skill) | T3 |
| R3.S2 | test_R3_S2_banner_on_node | live (node) | T3 |
""")

SUITE = [
    ("test_R1_S1_banner_text", "R1.S1", "inspect", "alpha:alpha/banner.py",
     1, "Banner text", "`alpha` at the commit set under test.",
     "The check calls `alpha.banner.banner()`.",
     "It returns `demo ready`."),
    ("test_R1_S2_banner_width", "R1.S2", "inspect", "alpha:alpha/width.py",
     1, "Banner width", "`alpha` at the commit set under test.",
     "The check calls `alpha.width.width()`.",
     "It returns 10 (characters)."),
    ("test_R2_S1_banner_printed", "R2.S1", "inspect",
     "beta:beta/__main__.py", 1, "Banner printed",
     "`beta` at the commit set under test, with `alpha` beside it.",
     "The check runs `python3 -m beta` with no arguments.",
     "Its first line of standard output is `demo ready`."),
    ("test_R3_S1_banner_from_skill", "R3.S1", "agent (skill)",
     "alpha:alpha/banner.py", 180, "An agent reads the banner",
     "A fresh agent with `alpha/banner.py` exported read-only.",
     "It is asked what `beta` prints at start-up.",
     "It answers `demo ready`."),
    ("test_R3_S2_banner_on_node", "R3.S2", "live (node)",
     "alpha:alpha/banner.py", 600, "The banner on a running node",
     "A demo node running `beta` built against `alpha`.",
     "`beta` restarts on the node.",
     "The node's log gives `demo ready` as `beta`'s first line."),
]
for name, sid, mode, deliv, exp, title, given, when, then in SUITE:
    put(f"tests/add-banner/{name}.md", f"""
---
scenario: {sid}
mode: {mode}
deliverables: [{deliv}]
fixture: none
expected_s: {exp}
heavy: {"true" if exp > 60 else "false"}
env: any
cap_s: {max(30, 2 * exp)}
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
    dict(cid="pad-banner", day="2026-10-03", head="1d1d1d1",
         space="6a6a6a6", wall=212, title="pad the banner",
         req="Padded banner",
         text="`alpha` SHALL give the banner one space of padding on each "
              "side.",
         given="`alpha` at the branch head",
         when="a caller asks for the banner",
         then="it gets ` demo ready `, 12 characters",
         slug="banner_padded", why="no padding in alpha",
         r11="pass", r31="pass", note=""),
    dict(cid="trim-banner", day="2026-10-04", head="2e2e2e2",
         space="6b6b6b6", wall=205, title="trim the banner",
         req="Trimmed banner",
         text="`alpha` SHALL strip trailing white space from a banner its "
              "caller sets.",
         given="a caller has set the banner to `demo ready` and three spaces",
         when="it asks for the banner",
         then="it gets `demo ready`, 10 characters",
         slug="banner_trimmed", why="alpha keeps the trailing spaces",
         r11="not-selected", r31="pass", note=""),
    dict(cid="wrap-banner", day="2026-10-05", head="3f3f3f3",
         space="6c6c6c6", wall=31, title="wrap a long banner",
         req="Wrapped banner",
         text="`alpha` SHALL wrap a banner longer than 40 characters onto a "
              "second line.",
         given="a caller has set a banner of 50 characters",
         when="it asks for the banner",
         then="it gets two lines, the first of 40 characters",
         slug="banner_wrapped", why="alpha gives one line of 50 characters",
         r11="pass", r31="not-selected", note=""),
    dict(cid="fold-banner", day="2026-10-06", head="4a4a4a4",
         space="6d6d6d6", wall=640, title="fold the banner to lower case",
         req="Lower-case banner",
         text="`alpha` SHALL give the banner in lower case.",
         given="a caller has set the banner to `Demo Ready`",
         when="it asks for the banner",
         then="it gets `demo ready`",
         slug="banner_folded", why="alpha keeps the capitals",
         r11="pass", r31="not-run (cap 600 s)",
         note="test_R3_S1_banner_from_skill stopped at its cap of 600 s "
              "with no result."),
]

for c in CASES:
    cid, d, head = c["cid"], c["day"], c["head"]
    dc = d.replace("-", "")
    test = f"test_R1_S1_{c['slug']}"
    put(f"changes/{cid}/spec.md", f"""
# {cid}: {c['title']}

- size: small
- owner: demo-owner
- repos: [alpha]
- supersedes: []
- approved: demo-owner {d}T08:00Z

{H2} Why

The banner from add-banner needs one more rule; agents and nodes report it
(add-banner R3), so a change to it is at risk.

{H2} Requirements

### R1 {c['req']}
{c['text']}

#### R1.S1 {c['req']}
- GIVEN {c['given']}
- WHEN {c['when']}
- THEN {c['then']}

{H2} Approaches

1. Change `alpha/banner.py` only (picked).

{H2} Open calls

None.
""")
    put(f"changes/{cid}/plan.md", f"""
# {cid} plan

- change: {cid}
- spec: changes/{cid}/spec.md

{H2} 1 Goal and approach

One build task in `alpha`, one blind test of R1.S1, verify, and the
whole-change review.

{H2} 5 Tasks

### T1 {c['req']} in alpha
- role: build
- repo: alpha
- after: []
- runs: local
- needs: any
- serves: [R1]
- risk: at risk: agents and nodes report the banner (add-banner R3)
- touches: alpha/banner.py, tests/test_banner.py
- done when: `python3 -m unittest discover -s tests -t .` passes in alpha
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
  unit suite and regression test

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
| R1 | at risk | agents and nodes report the banner (add-banner R3) |

| Run | Class | Task | Runs | Wall time (s) | Spend (USD) | Caps |
|---|---|---|---|---|---|---|
| test_R3_S1_banner_from_skill | agent | T3 | 1 | 180 | 0.80 | 600 s |
| Total | | | 1 | 180 | 0.80 | |

{H2} 9 Test map

| Scenario | Test | Class | Risk it covers | Expected (s) | Keep | Written by | Unit tests that also cover it |
|---|---|---|---|---|---|---|---|
| R1.S1 | {test} | script | at risk: the new banner rule | 1 | keep | T2 | tests/test_banner.py |
| add-banner/R3.S1 | test_R3_S1_banner_from_skill | agent | at risk: an agent reading alpha reports the banner as changed | 180 | already in tests/ | add-banner | none |

{H2} 10 Dependency summary

T1 and T2 start at the go; T3 waits for both, T4 for T3, and T5 for T3 and
T4. The one build task is one wave, so the one review is the whole-change
review.
""")
    put(f"changes/{cid}/ledger.md", f"""
# Ledger: {cid}

{FENCE}
{d}T08:00Z spec approved by demo-owner
{d}T08:10Z go by demo-owner; branches change/{cid}: alpha a1a1a1a
{d}T08:11Z dispatch T1 -> build (local, any), base alpha a1a1a1a
{d}T08:11Z dispatch T2 -> test (local, any)
{d}T08:40Z T1 DONE, alpha a1a1a1a..{head}, unit 4/4 pass
{d}T08:50Z T2 DONE
{d}T08:51Z T2 at base: {test} fail ({c['why']})
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
deliverables: [alpha:alpha/banner.py]
fixture: none
expected_s: 1
heavy: false
env: any
cap_s: 30
risk: at risk: the new banner rule
---

# R1.S1 {c['req']}

{H2} Given

{c['given'][0].upper() + c['given'][1:]}.

{H2} When

The check calls `alpha.banner.banner()`: {c['when']}.

{H2} Then

1. {c['then'][0].upper() + c['then'][1:]}.
""")
    reg = [("R1.S1", c["r11"]), ("R1.S2", "not-selected"),
           ("R2.S1", "not-selected"), ("R3.S1", c["r31"]),
           ("R3.S2", "not-selected")]
    names = {sid: name for name, sid, *_ in SUITE}
    ran = [names[s] for s, r in reg if r != "not-selected"]
    skipped = [names[s] for s, r in reg if r == "not-selected"]
    tail = " " + c["note"] if c["note"] else ""
    scen = ", ".join(["R1.S1: pass"] +
                     [f"add-banner/{s}: {r}" for s, r in reg])
    put(f"changes/{cid}/evidence/{dc}T1130Z.md", f"""
---
id: ev-{dc}T1130Z
change: {cid}
commit_set: {{space: {c['space']}, alpha: {head}, beta: b2b2b2b, gamma: c3c3c3c}}
env: macos-laptop
actor: demo-owner/test
selection: targeted
touched: {TOUCHED}
scenarios: {{{scen}}}
unit: {{alpha: pass}}
quality: none-declared
wall_time_s: {c['wall']}
---

Selection: targeted, over the files `touched` lists. Run: {test},
{', '.join(ran)}. Not selected: {', '.join(skipped)}.{tail}
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

1. `trim-banner`'s latest evidence is `not green`, and its state is not
   `verified`.
2. `wrap-banner`'s latest evidence is `not green`, and its state is not
   `verified`.
3. `fold-banner`'s latest evidence is `not green`, and its state is not
   `verified`.
4. `pad-banner`'s latest evidence is `ev-20261003T1130Z`, `green` and not
   `stale`.
5. `pad-banner`'s results give the regression part
   `regression 2/2 pass, 3 not-selected`, with no superseded part.
6. No space file but `STATUS.md` is added, changed or removed.

```python check
import hashlib
import json
import os
import re
import sys
from pathlib import Path

TAG = "R5.S4"
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


for n, cid in ((1, "trim-banner"), (2, "wrap-banner"), (3, "fold-banner")):
    state, verdict, stale, ev, _ = change(cid)
    report(n, verdict == "not green" and state not in (None, "verified"),
           said(cid))

state, verdict, stale, ev, results = change("pad-banner")
report(4, verdict == "green" and not stale and ev == "ev-20261003T1130Z",
       said("pad-banner"))

want = re.compile(r"(^|,\s*)regression 2/2 pass, 3 not-selected"
                  r"(?!,\s*\d+\s+superseded)\s*(,|$)")
got = re.search(r"regression [^,]*(, \d+ (not-selected|superseded))*",
                results or "")
report(5, bool(results) and bool(want.search(results)),
       "pad-banner regression part: "
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

- The agent reads any `not-selected` as no bar, or trusts the record's own
  list of what it ran, and calls `trim-banner` or `wrap-banner` green: a
  false green from a test the selection picks.
- It reads `not-run (cap 600 s)` as no bar and calls `fold-banner` green.
- It calls `pad-banner` not green, though every test its selection picks
  passes: a rightly targeted verify kept from green.
- `pad-banner`'s line does not show the 3 not selected apart from the 2
  passes.
- It edits a record, such as an evidence record, instead of reading it.

## At base

Expected: fail at check 4, because swe-pod `b7fc257`'s skill needs a pass
of every regression test, so `pad-banner`'s three `not-selected` tests keep
it not green; checks 1 to 3 pass there, since every bar of the scenario is
a bar at base too, and check 5 fails, the base form being
`regression <p>/<n> pass` only.

Observed 2026-10-30T16:45Z at the base commit set (space 6f1e4e0, swe-pod
b7fc257, agent-mesh f27c611), after a passing smoke; 82 s wall time
(agent run 80 s, 14 turns), 0.47 USD as the CLI reports it, no spend-limit
or safeguard stop; runner result:

```
fail (check R5.S4.4: pad-banner: state building, latest evidence ev-20261003T1130Z not green)
```

Checks 1 to 3 passed and 6 passed; check 5 failed with
`regression 2/5 pass`. The agent said `not-selected` "doesn't count as a
pass", the base rule.
