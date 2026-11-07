---
scenario: T1.TS1
mode: inspect
class: script
deliverables: [swe-pod:PROCESS.md, swe-pod:skills/swe-pod, swe-pod:agents/swe-lead.md, swe-pod:templates/records/ledger.md]
fixture: none
expected_s: 2
heavy: false
env: any
cap_s: 30
risk: a cap ruling the status view must read as closing the finding; at a small change whose Important finding is still open after fix round 2/2, the lead's Ruling line reaches the ledger, but if the status view's rules still count the finding open, STATUS.md never reads the change as verified and the ruling cannot carry it to integrate and its final report
---

# T1.TS1 A ruling at the cap is read by the status view as closing the finding

Builder suggestion T1.TS1, routed by the lead for a risk no planned test
covers. Serves R13 at the point after the cap, for R13.S1 (small, open
after round 2) and R13.S2 (large, open after round 3), through contract 2.3:
"At the cap the lead starts no further round, rules on each open finding in
a `Ruling:` line (§13)".

The expected value comes from the spec. R13 says that at the cap the lead
starts no further round and rules on each open finding; R13.S1 says the
`Ruling:` line reaches the final report, which is written only after the
change is verified and reviewed. At the cap no round can address the
finding, so the ruling is the one thing that ends it: if the status view
still counts the finding open, the change can never read as verified, and
the loop the spec closes at the cap stays open in `STATUS.md`.

The part of the risk this test covers: the rules by which the skill
regenerates `STATUS.md` (the status view) must read a ruling on a finding
as closing it, at a small change as at any size, and must not keep a ruled
finding open, or keep any finding open until a fix round addresses it. The
lead's side must say the same, so the lead and the view read one rule; and
where the view closes findings only on a `Ruling:` line of a set form, the
lead must be given that form, at the cap above all, or the line the lead
writes reaches the ledger and the view still counts the finding open.

## Given

- `PROCESS.md`, `skills/swe-pod/`, `agents/swe-lead.md` and
  `templates/records/ledger.md` exported read-only from swe-pod at the sha
  under test.
- The scenario, a small change (cap 2, spec R13) whose task T1 has one
  Important finding, with these ledger lines (invented shas):
  - `T1 fix round 1/2: 0 addressed, 1 open, 1a2b3c4..5d6e7f8`
  - `T1 fix round 2/2: 0 addressed, 1 open, 5d6e7f8..9a0b1c2`
  - a `Ruling:` line on that finding (contract 2.3), after which verify is
    green.

  The status view should then read the finding as closed and the change as
  free to read as verified. The check reads the rules the view follows; it
  writes no file.

## When

```text
The runner exports the deliverables by sha and runs the check below on
them. No agent is run.
```

## Then

The status view is every file of `skills/swe-pod/` and each level-2
section of `PROCESS.md` whose heading names `status` or `state`; the lead's
side is the rest of `PROCESS.md` and `agents/swe-lead.md`, and for check 4
also `templates/records/ledger.md`.

Text is read with backticks and Markdown emphasis removed, in lower case,
with white-space runs as one space. A unit is a paragraph, a list item
(read together with its lead-in, the paragraph before the list when it ends
in a colon) or a table row (read together with the table's header row). A
clause is a part of a unit between sentence ends, semicolons, table cell
bounds and colons (but the colon of `Ruling:`). A match is negated when
`no`, `not`, `never`, `nor`, `none`, `without` or `nothing` comes at most
two words before it in its clause. A unit under a heading holding one of
those words (as `## Never`), or a list item after a lead-in holding one, is
in a negated context, where a prohibition on reading a ruled finding as
open counts as reading it closed.

A unit names a ruling when it holds `ruling`, `rulings`, `ruled` (not
`ruled out`) or `rules on`. A clause is about a ruling when it names one,
or when it names a finding (or `it`, `them`, `those`) right after a clause
that names one. A closing reading is a close, park, settle, resolve or
retire word, `disposes of`, or a count, read, show, list, mark or treat
word followed, at most six words later, by `as` addressed, closed,
resolved, settled, parked, done, handled or ruled; or a not-open reading: `no
longer ... open`, `not ... open`, `no longer`, `not` or `never` before
`blocks`, `out of the open`, a drop, remove or take word with `from` (or
`out of`) `the open`, or `less`, `minus`, `excluding`, `except`, `other
than` or `but not` before a ruled or ruling word. A unit covers a small
change when it names no size, or names small or an every-size phrase, and
does not tie itself to a round 3 or later without naming small or the cap.

1. The status view reads a ruling as closing the finding: it has a unit
   that names a finding and covers a small change, with a clause about a
   ruling that holds a closing reading not negated (spec R13, R13.S1;
   contract 2.3).
2. Nothing in the status view keeps a ruled finding open: no unit that
   names a finding has a clause about a ruling that reads it as still open
   (`stays`, `remains` or `still open`, `still blocks`, counted, read,
   shown, listed or kept `as open`) or negates a close word ("a ruling does
   not close it"); and no unit that names a finding and no ruling, outside
   a negated context, keeps a finding open until (or unless) a fix, a round
   or a re-review addresses it, or says only a fix or a round closes it.
3. The lead's side agrees: `PROCESS.md` outside the status view, or
   `agents/swe-lead.md`, has a unit as in check 1, in which a ruling closes
   or parks a finding.
4. The lead's side gives the `Ruling:` form the status view closes on. A
   form is a code span that begins `Ruling:` and holds a `<...>`
   placeholder, read with each placeholder as `<>`; it is set when the text
   after `Ruling:` does not begin with a placeholder (`Ruling: T<n> ...` is
   set; `Ruling: <what>; ...`, which any ruling fits, is not). When a
   check 1 unit holds a set form, the lead's side must hold a form that
   begins with it, and every unit of the lead's side that names the cap
   (`cap`, `capped` or `at most`), a round and a ruling, and holds a form,
   holds one that begins with it: an at-cap unit that gives only another
   form (as the general `Ruling: <what>; <why>; <cost if wrong>`) tells the
   lead to write, at the cap, a line the view does not close on. When no
   check 1 unit holds a set form, the view reads any `Ruling:` line on the
   finding, and the check passes.

```python check
import os
import re
import sys
from pathlib import Path

TAG = "T1.TS1"
OK = []
FENCE = "`" * 3
ROOT = Path(os.environ.get("EXPORT_SWE_POD") or "/nonexistent")
NEG = re.compile(r"\b(?:no|not|never|nor|none|without|nothing)\b")
NEG_NEAR = re.compile(r"\b(?:no|not|never|nor|none|without|nothing)\b"
                      r"(?:\s+\S+){0,2}\s*$")
RUL = re.compile(r"\brulings?\b|\bruled\b(?! out)|\brules? on\b")
FIND = re.compile(r"\bfindings?\b")
PRON = re.compile(r"\bfindings?\b|\bit\b|\bthem\b|\bthose\b")
CLOSE = re.compile(
    r"\b(?:clos(?:e|es|ed|ing)|park(?:s|ed|ing)?|settl(?:e|es|ed|ing)"
    r"|resolv(?:e|es|ed|ing)|retir(?:e|es|ed|ing)|dispos(?:e|es|ed) of)\b"
    r"|\b(?:count|counts|counted|read|reads|show|shows|list|lists|mark"
    r"|marks|marked|treat|treats|treated)\b(?:\s+\S+){0,6}?\s+as "
    r"(?:addressed|closed|resolved|settled|parked|done|handled|ruled)\b")
NOTOPEN = re.compile(
    r"\bno longer (?:\S+ ){0,3}?open\b|\bnot (?:\S+ ){0,3}?open\b"
    r"|\b(?:no longer|not|never) (?:\S+ ){0,2}?blocks?\b"
    r"|\bout of the open\b|\b(?:drops?|removes?|takes?) (?:\S+ ){0,3}?"
    r"(?:from|out of) the open\b|\b(?:less|minus|excluding|except|other "
    r"than|but not)\b(?:\s+\S+){0,5}?\s+(?:rul(?:ed|ing|ings)\b|rules? on\b)")
OPENKEEP = re.compile(
    r"\b(?:stays?|remains?|is still|are still|still)\s+open\b"
    r"|\bstill blocks?\b"
    r"|\b(?:count|counts|counted|read|reads|show|shows|list|lists|keep"
    r"|keeps)\b(?:\s+\S+){0,8}?\s+as open\b")
UNTIL_FIX = re.compile(
    r"\bopen\b(?:\s+\S+){0,4}?\s+(?:until|unless|till)\b(?:\s+\S+){0,6}?\s+"
    r"(?:fix|fixed|fixes|addressed|addresses|rounds?|re-review)\b")
ONLY_FIX = re.compile(
    r"\bonly\b(?:\s+\S+){0,6}?\s+(?:fix|fixes|fixed|rounds?|re-review)\b"
    r"|\b(?:fix|fixes|fixed|rounds?|re-review)\b(?:\s+\S+){0,3}?\s+only\b")
SIZEW = re.compile(r"\b(?:small|medium|large|project)\b")
ALLSIZE = re.compile(r"\b(?:every|any|each|all) sizes?\b")
BIGROUND = re.compile(
    r"\brounds?\s+[3-9]\b|\b(?:third|fourth|fifth|sixth)\s+(?:fix\s+)?round"
    r"|\bfix rounds?\s+\S*/[3-9]\b")
ITEM = re.compile(r"\s*(?:[-+*]|\d+\.)\s")
SPAN = re.compile(r"`\s*(ruling:\s[^`]*<[^`>]+>[^`]*)`", re.I)
CAPW = re.compile(r"\bcap\b|\bcapped\b|\bat most\b")
ROUND = re.compile(r"\brounds?\b")


def report(n: int, ok: bool, why: str) -> None:
    OK.append(bool(ok))
    print(f"{TAG}.{n} {'pass' if ok else 'fail'} {why}")


def text(rel: str) -> str:
    p = ROOT / rel
    return p.read_text(errors="replace") if p.is_file() else ""


def flat(s: str) -> str:
    s = s.replace("`", "").replace("*", "")
    return re.sub(r"\s+", " ", s).strip().lower()


def units_ctx(t: str) -> list:
    """(unit, negated, lead-in) triples: paragraphs, list items and table
    rows. A list item's lead-in is the last paragraph before it that ends in
    a colon; a table row's is the table's header row. Units under a heading
    holding a negation (as ## Never), or list items after a negated lead-in,
    are in a negated context."""
    out = []
    st = {"head": False, "lead": False, "text": "", "thead": None,
          "cur": [], "item": False, "fenced": False}

    def emit() -> None:
        u = flat("\n".join(st["cur"]))
        item = st["item"]
        st["cur"], st["item"] = [], False
        if not u:
            return
        out.append((u, st["head"] or (item and st["lead"]),
                    st["text"] if item else ""))
        if not item:
            colon = u.endswith(":")
            st["lead"] = colon and NEG.search(u) is not None
            st["text"] = u if colon else ""

    for line in t.splitlines():
        s = line.strip()
        if s.startswith(FENCE):
            emit()
            st["fenced"] = not st["fenced"]
            continue
        if not st["fenced"] and line.startswith("#"):
            emit()
            st["thead"] = None
            st["head"] = NEG.search(flat(line)) is not None
            st["lead"], st["text"] = False, ""
            continue
        if not s:
            emit()
            st["thead"] = None
            continue
        if not st["fenced"] and s.startswith("|"):
            emit()
            if re.fullmatch(r"[|:\-\s]+", s):
                continue
            row = flat(s.strip("|").replace("|", " ; "))
            if st["thead"] is None:
                st["thead"] = row
                out.append((row, st["head"], ""))
            else:
                out.append((row, st["head"], st["thead"]))
            continue
        if not st["fenced"] and ITEM.match(line):
            emit()
            st["item"] = True
        st["cur"].append(line)
    emit()
    return out


def clauses(u: str) -> list:
    return [c.strip() for c in re.split(
        r"\.(?=\s|$)|;|(?<!ruling):(?=\s|$)", u) if c.strip()]


def negated_at(c: str, start: int) -> bool:
    return NEG_NEAR.search(c[:start]) is not None


def closes(c: str, neg_ctx: bool) -> bool:
    """The clause reads a finding as closed (or parked, or not open)."""
    if neg_ctx:
        return any(not negated_at(c, m.start())
                   for m in OPENKEEP.finditer(c))
    for rx in (CLOSE, NOTOPEN):
        for m in rx.finditer(c):
            if not negated_at(c, m.start()):
                return True
    return False


def keeps_open(c: str, neg_ctx: bool) -> bool:
    """The clause reads a finding as still open (or not closed)."""
    if neg_ctx:
        return any(not negated_at(c, m.start()) for m in CLOSE.finditer(c))
    if any(not negated_at(c, m.start()) for m in OPENKEEP.finditer(c)):
        return True
    return any(negated_at(c, m.start()) for m in CLOSE.finditer(c))


def about_ruling(cs: list, i: int) -> bool:
    """Clause i names a ruling, or names a finding (or it) after a clause
    that names a ruling."""
    if RUL.search(cs[i]):
        return True
    return i > 0 and PRON.search(cs[i]) is not None \
        and RUL.search(cs[i - 1]) is not None


def covers_small(u: str) -> bool:
    if SIZEW.search(u) and not (ALLSIZE.search(u)
                                or re.search(r"\bsmall\b", u)):
        return False
    if BIGROUND.search(u) and not (re.search(r"\bsmall\b|\bcap\b", u)):
        return False
    return True


def closing_units(docs: dict) -> list:
    hits = []
    for name, t in docs.items():
        for u, neg, lead in units_ctx(t):
            p = (lead + " " + u).strip()
            if not FIND.search(p) or not covers_small(p):
                continue
            cs = clauses(u)
            if any(about_ruling(cs, i) and closes(cs[i], neg)
                   for i in range(len(cs))):
                hits.append((name, p))
    return hits


def short(s: str, n: int = 100) -> str:
    return s if len(s) <= n else s[:n - 3] + "..."


def norm(f: str) -> str:
    return re.sub(r"<[^>]+>", "<>", f).rstrip(" .:")


def doc_forms(t: str) -> list:
    """Each Ruling: line form written as a code span in t that holds a
    placeholder, flattened."""
    return [flat(m.group(1)) for m in SPAN.finditer(t)]


def specific(f: str) -> bool:
    """A form that fixes text after Ruling: (as T<n> ...), not a bare
    placeholder (as <what>), which any ruling fits."""
    return not f[len("ruling:"):].lstrip().startswith("<")


def h2_sections(t: str) -> list:
    out, cur, fenced = [], None, False
    for line in t.splitlines():
        if line.lstrip().startswith(FENCE):
            fenced = not fenced
        if not fenced and line.startswith("## "):
            cur = [line]
            out.append(cur)
        elif cur is not None:
            cur.append(line)
    return out


process = text("PROCESS.md")
view, rest = {}, []
skill_dir = ROOT / "skills" / "swe-pod"
for f in sorted(skill_dir.rglob("*")) if skill_dir.is_dir() else []:
    if f.is_file():
        try:
            view[str(f.relative_to(ROOT))] = f.read_text()
        except UnicodeDecodeError:
            continue
for sec in h2_sections(process):
    head = flat(sec[0][3:])
    if re.search(r"\bstatus\b|\bstates?\b", head):
        view["PROCESS.md " + head.split(" ", 1)[0]] = "\n".join(sec)
    else:
        rest.append("\n".join(sec))

# 1. The status view reads a ruling as closing the finding.
hits = closing_units(view)
where = ", ".join(sorted(view)) or "absent"
report(1, bool(hits), f"status view ({where}): " + (
    f"{len(hits)} unit(s) read a ruling as closing a finding, first "
    f"{hits[0][0]}: {short(hits[0][1])}" if hits else
    "no unit reads a ruling as closing, parking or settling a finding, "
    "for a small change"))

# 2. Nothing in the status view keeps a ruled finding open.
bad = []
for name, t in view.items():
    for u, neg, lead in units_ctx(t):
        p = (lead + " " + u).strip()
        cs = clauses(u)
        for i, c in enumerate(cs):
            if about_ruling(cs, i) and FIND.search(p) and keeps_open(c, neg):
                bad.append(f"{name}: {short(c)}")
                break
            if neg or RUL.search(p) or not FIND.search(p):
                continue
            if UNTIL_FIX.search(c) or (ONLY_FIX.search(c)
                                       and CLOSE.search(c)):
                bad.append(f"{name}: {short(c)}")
                break
report(2, not bad, "status view clauses keeping a ruled finding open, or a "
       "finding open until a fix: " + ("none" if not bad else
                                       f"{len(bad)}, first " + bad[0]))

# 3. The lead's side: a ruling parks or closes the finding.
lead_docs = {"PROCESS.md": "\n\n".join(rest),
             "agents/swe-lead.md": text("agents/swe-lead.md")}
lh = closing_units(lead_docs)
report(3, bool(lh), "PROCESS.md outside the status view, and "
       "agents/swe-lead.md: " + (
           f"{len(lh)} unit(s) in which a ruling closes or parks a "
           f"finding, first {lh[0][0]}: {short(lh[0][1])}" if lh else
           "absent" if not process else
           "no unit in which a ruling closes or parks a finding"))

# 4. The lead's side gives the Ruling: form the status view closes on.
vforms = set()
for name, p in hits:
    vforms |= {norm(f) for f in doc_forms(view[name]) if f in p
               and specific(f)}
vforms = sorted(vforms)
lead_docs["templates/records/ledger.md"] = text("templates/records/ledger.md")
given, at_cap_other = [], []
for name, t in lead_docs.items():
    dforms = doc_forms(t)
    for u, neg, lead in units_ctx(t):
        p = (lead + " " + u).strip()
        fs = [norm(f) for f in dforms if f in p]
        given += [f"{name}: {f}" for f in fs
                  if any(f.startswith(v) for v in vforms)]
        if fs and CAPW.search(p) and ROUND.search(p) and RUL.search(p) \
                and not any(f.startswith(v) for f in fs for v in vforms):
            at_cap_other.append(f"{name}: {fs[0]} (in: {short(p, 70)})")
if not vforms:
    report(4, True, "the status view's closing rule names no Ruling: form "
           "of its own, so it reads any Ruling: line on the finding")
else:
    ok = bool(given) and not at_cap_other
    report(4, ok, "status view closes on " + ", ".join(vforms)
           + "; lead's side " + (f"gives it ({given[0]})" if given else
                                 "never gives that form") + (
               "" if not at_cap_other else "; an at-cap unit gives "
               "another form, " + at_cap_other[0]))
sys.exit(0 if OK and all(OK) else 1)
```

## Fails if

- The status view has no rule by which a ruling closes, parks or settles
  a finding, or has one only for medium or large, or only after a round 3
  or later, so a small change's finding open after round 2/2 stays open
  once ruled.
- The status view says a ruling leaves a finding open, does not close it,
  or still blocks the change, or counts a finding open until a fix round or
  re-review addresses it, with no ruling as the other way out.
- The process and the lead's role do not say that a ruling closes or parks
  the finding, so the lead and the status view read different rules.
- The status view closes findings only on a `Ruling:` line of a set form
  that the lead's side never gives, or that an at-cap unit of the lead's
  side contradicts with another form, so the ruling the lead writes at the
  cap reaches the ledger and the view still counts the finding open.

## At base

Expected, stated before the first run: fail at check 1, the gap the
builder's suggestion names (no rule by which the base status view reads a
ruling as closing a finding); checks 2 and 3 to hold, as guards of what the
change keeps.

That first version (checks 1 to 3) passed at the base commit set, all
three checks, 2026-11-07T18:04Z: the base status view already reads a
ruling as closing a finding, but only a line that begins with a set form.
So the risk at the cap is not the closing rule but the form: the line the
lead is told to write at the cap must be the one the view closes on. Check
4 was added for it. Expected for check 4, stated before its run: fail at
base if the base lead's side never gives the view's set form.

Observed 2026-11-07T18:08Z at the base commit set (space b02a772, swe-pod
3b22a1b; the check reads only swe-pod), 1 s wall time, no agent; runner
result:

```
fail (check T1.TS1.4: status view closes on ruling: t<> open findings, ruling: t<> open findings parked: <>; <>; <>; lead's side never gives that form)
```

Checks 1 to 3 passed: the base view's rule on ruled findings closes the
task's findings, nothing in the view keeps a ruled finding open, and the
base process and lead role park findings with a ruling. Check 4 failed: the
base view closes only on `Ruling: T<n> open findings ...`, while the base
`PROCESS.md`, `swe-lead.md` and ledger template give only the general
`Ruling: <what>; <why>; <cost if wrong>`, so a ruling the lead writes from
them at the cap reaches the ledger and the view still counts the finding
open.

On control exports written from the spec and contract alone (six of them,
stating the rules in different phrasings, three with a set form that the
lead's side gives: in the role, in the ledger template, or as a case of the
general form), every check passes; each fault planted in a copy of them is caught
by the check this file's Fails if names for it.
