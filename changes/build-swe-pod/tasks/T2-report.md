# T2 report

- change: build-swe-pod
- task: T2
- actor: <handle>/build

## Status
BLOCKED

The content is done, and done-when (1) to (3) pass. Done-when (4) is not
met: the permission classifier refused the commit, so nothing is committed
or pushed. The ten files are staged by pathspec in the shared swe-pod
checkout, and no other task's files were touched. To finish, someone allowed
to commit runs the commit and push lines under Concerns, then the close
checks again.

## What I did
- Wrote the done-when checks as one shell script (below) and ran it before
  any content existed: 1 ok, 45 FAIL. The one ok is the SPEC.md check.
- Wrote one template per record kind under `templates/records/`, with
  placeholders only (`<id>`, `<handle>`, `<repo>`, `<sha7>`,
  `<YYYY-MM-DDTHH:MMZ>` and the like). Each uses the headings, front-matter
  keys and line forms of plan section 2.4, character for character. Each also
  has a short HTML comment giving its space path and the rules that go with
  it, to be deleted when the record is written.
  - `spec.md`: the header list of spec 5.1 and the six sections, with
    requirement, scenario (GIVEN/WHEN/THEN) and quality-check forms. The
    three state lines (`approved:`, `integrated:`, `abandoned:`) are given
    in their exact form inside the comment and not as live header lines, so
    a new spec made from the template reads as proposed.
  - `plan.md`: sections `## 1.` to `## 10.` of spec 5.2, then
    `## Self-review` (the five checks) and `## Questions for the spec` with
    groups (a), (b) and (c). Every task form has role, after, runs, needs and
    done when.
  - `brief.md`, `test-brief.md`: the section lists of 2.4. The test brief
    gives only the for-the-tester part of a suggestion, and ends with the
    exact closing line.
  - `report.md`: the six sections, the four status values, the disputed-test
    phrase of 2.5, and the `### T<n>.TS<k> <title>` form with its two lines.
  - `review.md`: front-matter `task:`, `diff:` (one line per range) and
    `verdict:`. The three sections, with missing, extra and misread under
    spec compliance, and the finding line form.
  - `evidence.md`: the eleven front-matter keys of 2.4, with
    `quality: none-declared` as the alternate form, and `none-present`,
    `x-checks`, `x-suggestions` and qualified regression ids. The body
    states the log-pointer rule and has `not-run (cap)` naming its cap.
  - `ledger.md`: one fenced block listing all 16 event forms of 2.4, each
    prefixed by `<YYYY-MM-DDTHH:MMZ>`, plus one continuation line indented
    18 spaces. The comment states the refused-line rule.
  - `handoff.md`, `final-report.md`: the 2.4 sections. The final report has
    the scenario table (scenario, test, result, evidence id) and the
    branches table.
- Ran the same script again: 45 ok, 1 FAIL. The one FAIL is the commit
  check, which can only pass after the commit.
- Found that my first script had left out done-when (3). I added it and
  showed it red against the T0 base tree and green against the working tree.
- Extra, not in the done-when: the front matter of `evidence.md` and
  `review.md` loads as YAML, placeholders included.
- Staged the ten paths by pathspec and ran the shareability check: 0 hits.
  The commit was then refused (see Status), and the check still gives 0 hits.

## Files
- swe-pod/templates/records/spec.md: created, spec record
- swe-pod/templates/records/plan.md: created, plan record
- swe-pod/templates/records/brief.md: created, build or review brief
- swe-pod/templates/records/test-brief.md: created, test-writing brief
- swe-pod/templates/records/report.md: created, task report
- swe-pod/templates/records/review.md: created, task and whole-change review
- swe-pod/templates/records/evidence.md: created, verify evidence
- swe-pod/templates/records/ledger.md: created, change ledger
- swe-pod/templates/records/handoff.md: created, handoff
- swe-pod/templates/records/final-report.md: created, final report

## Test output

### Checks (1), (2) and the local parts of (4)
- command: the script below, run as `bash -s` from `<checkout>`

```
cd <checkout> || exit 2
R=templates/records
P=0; F=0
ok() { echo "ok   $*"; P=$((P+1)); }
no() { echo "FAIL $*"; F=$((F+1)); }
fmof() { awk 'NR==1{if($0!="---")exit;next} $0=="---"{exit} {print}' "$1"; }
blkof() { awk '/^```/{n++;next} n==1{print}' "$1"; }
# chk <kind> <file> <item>...: one grep per item
#   line: an exact whole line   start: a line begins with it
#   has: a substring            fm: a front-matter line begins with it
#   fmhas: a front-matter substring   blk: a whole line of the fenced block
chk() {
  kind=$1; f=$R/$2.md; shift 2
  if [ ! -f "$f" ]; then no "$f $kind: $# items, file missing"; return; fi
  n=0; bad=""
  for s in "$@"; do
    case $kind in
      line) grep -qxF -- "$s" "$f" ;;
      start) awk -v s="$s" 'index($0,s)==1{f=1} END{exit !f}' "$f" ;;
      has) grep -qF -- "$s" "$f" ;;
      fm) fmof "$f" | awk -v s="$s" 'index($0,s)==1{f=1} END{exit !f}' ;;
      fmhas) fmof "$f" | grep -qF -- "$s" ;;
      blk) blkof "$f" | grep -qxF -- "<YYYY-MM-DDTHH:MMZ> $s" ;;
    esac
    if [ $? -eq 0 ]; then n=$((n+1)); else bad="$bad | $s"; fi
  done
  if [ -z "$bad" ]; then ok "$f $kind: $n/$# found"
  else no "$f $kind: $n/$# found; missing$bad"; fi
}
order() {
  f=$R/$1.md; shift
  want=$(printf '%s\n' "$@"); got=$(grep '^## ' "$f" 2>/dev/null)
  if [ "$got" = "$want" ]; then ok "$f: ## headings in the given order"
  else no "$f: ## headings not in the given order"; fi
}

echo "== (1) all 10 files exist"
for k in spec plan brief test-brief report review evidence ledger handoff \
         final-report; do
  [ -f $R/$k.md ] && ok "$R/$k.md exists" || no "$R/$k.md missing"
done
n=$(ls $R/*.md 2>/dev/null | wc -l | tr -d ' ')
[ "$n" = 10 ] && ok "$R holds exactly 10 files" || no "$R holds $n files"

echo "== (2) headings and front-matter keys, one grep per item"
H=("## Why" "## Scope" "## Requirements" "## Quality" "## Approaches"
   "## Open calls")
chk line spec "${H[@]}"; order spec "${H[@]}"
chk start spec "- approved: <handle> <YYYY-MM-DDTHH:MMZ>" \
  "- integrated: <handle> <UTC>" "- abandoned: <UTC> <reason>"
chk start spec "### R<n> " "#### R<n>.S<m> " "- GIVEN " "- WHEN " "- THEN " \
  "### Q<n> " "- check: "

H=("## 1. Goal and approach" "## 2. Interface contract"
   "## 3. Global constraints" "## 4. File map" "## 5. Tasks" "## 6. Test tasks"
   "## 7. Review tasks" "## 8. Integrate task" "## 9. Test map"
   "## 10. Dependency summary" "## Self-review" "## Questions for the spec")
chk line plan "${H[@]}" "### (a) Answered" \
  "### (b) Minor, with the default planned" "### (c) For the human"
order plan "${H[@]}"
chk start plan "- role: " "- repo: " "- after: " "- runs: " "- needs: " \
  "- serves: " "- touches: " "- consumes: " "- produces: " "- steps: " \
  "- done when: "

H=("## Task" "## Interfaces" "## Global constraints" "## Rulings"
   "## Start from" "## Result goes to")
chk line brief "${H[@]}"; order brief "${H[@]}"

H=("## Task" "## Spec" "## Interface contract" "## Global constraints"
   "## Test map" "## Start from" "## Suggestions" "## Result goes to")
chk line test-brief "${H[@]}" "### T<n>.TS<k> <title>"
order test-brief "${H[@]}"
chk start test-brief "- for the tester:"
if [ -f $R/test-brief.md ] && ! grep -q 'for the reviewer' $R/test-brief.md
then ok "$R/test-brief.md carries no reviewer part"
else no "$R/test-brief.md missing, or carries a reviewer part"; fi

H=("## Status" "## What I did" "## Files" "## Test output" "## Concerns"
   "## Test suggestions")
chk line report "${H[@]}" "### T<n>.TS<k> <title>"; order report "${H[@]}"
chk start report "- for the tester:" "- for the reviewer:"
chk has report "DONE" "DONE_WITH_CONCERNS" "BLOCKED" "NEEDS_CONTEXT" \
  "Disputed test: <test name>; spec clause: <clause>"

chk fm review "task: T<n>" "diff: <repo> <sha7>..<sha7>" "verdict: pass|fix"
H=("## Spec compliance" "## Quality" "## Findings")
chk line review "${H[@]}"; order review "${H[@]}"
chk start review "- missing:" "- extra:" "- misread:" \
  "- <Critical|Important|Minor> <repo>/<path>:<line> <text>"

chk fm evidence "id: ev-<YYYYMMDDTHHMMZ>" "change: " \
  "commit_set: {space: <sha7>, <repo>: <sha7>, ...}" \
  "env: <environment class>" "actor: <handle>/test" \
  "scenarios: {<Rn.Sm>: pass|fail|not-run, ...}" \
  "unit: {<repo>: pass|fail|none-present}" "quality: {<Qn>: pass|fail}" \
  "x-checks: {<In>: pass|fail}" "x-suggestions: {T<n>.TS<k>: pass|fail}" \
  "wall_time_s: <integer>"
chk fmhas evidence "quality: none-declared" "<change>/<Rn.Sm>"
chk has evidence "not-run (cap)" "- log: <space-relative path or URL>"

chk blk ledger "spec approved by <handle>" \
  "go by <handle>; branches change/<id>: <repo> <sha7>[, <repo> <sha7>]" \
  "dispatch T<n> -> <role> (<local|mesh>, <env class|any>)[, base <repo> <sha7>]" \
  "T<n> <DONE|DONE_WITH_CONCERNS|BLOCKED|NEEDS_CONTEXT>[, <repo> <sha7>..<sha7>][, unit <p>/<n> pass]" \
  "T<n> review: <spec ok|spec issues>; <k> <Severity> [<repo>/<path>:<line>]" \
  "T<n> fix round <r>/5: <a> addressed, <o> open, <sha7>..<sha7>" \
  "T<n> at base: <test name> <fail|pass> (<reason>)[, ...]" \
  "T<n> returned to test: <test name> passed at base" \
  "T<n>.TS<k> -> <test|spec|builder>" \
  "T<n>.TS<k> returned to builder: carries a computed value" \
  "T<n>.TS<k> outcome: <tested <test name>|proposed as scenario|unit-tested|declined: <reason>|dropped>" \
  "approval reopened for <Rn>[, <Rm>]; held T<a>[, T<b>]" \
  "heavy: asked <handle> before T<n>: <command name>; caps <caps>; expected <s> s" \
  "Ruling: <what>; <why>; <cost if wrong>" \
  "filed <space path>[, ...]" \
  "refused <space path>: <profile|reference|id|lane> line <n>"
f=$R/ledger.md
n=$(grep -c '^```' $f 2>/dev/null); n=${n:-0}
[ "$n" = 2 ] && ok "$f: one fenced block" || no "$f: $n fence lines, want 2"
if [ -f $f ] && blkof $f | awk '!/^<YYYY-MM-DDTHH:MMZ> / && !/^ {18}[^ ]/{b=1}
     /^ {18}[^ ]/{c=1} END{exit (b || !c)}'
then ok "$f: every block line is an event or an 18-space continuation"
else no "$f: block lines malformed, or no continuation example"; fi

H=("## State" "## Half-done" "## Open questions" "## Next command")
chk line handoff "${H[@]}"; order handoff "${H[@]}"

H=("## Scenarios" "## Rulings" "## Deferred minors" "## Test suggestions"
   "## Open questions" "## Branches")
chk line final-report "${H[@]}"; order final-report "${H[@]}"
chk start final-report "| Scenario | Test | Result | Evidence id |"

echo "== extra: no trailing whitespace"
if ls $R/*.md >/dev/null 2>&1 && ! grep -nE '[[:space:]]$' $R/*.md
then ok "no trailing whitespace"; else no "files missing or trailing whitespace"; fi

echo "== (4) standard close, local parts"
base=$(git log --format=%h -1 -E --grep='^Task: T0$' HEAD)
if [ -n "$base" ] && [ -z "$(git diff $base -- SPEC.md 'spec-process.*')" ]
then ok "SPEC.md and spec-process.* unchanged since $base"
else no "SPEC.md or spec-process.* differ from the T0 commit"; fi
c=$(git log --format=%H -1 -E --grep='^Task: T2$' HEAD)
if [ -n "$c" ]; then
  b=$(git log -1 --format=%B $c)
  echo "$b" | grep -qx 'Change: build-swe-pod' && echo "$b" | grep -qx 'Task: T2' \
    && ok "T2 commit $(git rev-parse --short $c) has both trailers" \
    || no "T2 commit lacks a trailer"
  want=$(for k in brief evidence final-report handoff ledger plan report \
         review spec test-brief; do echo $R/$k.md; done)
  got=$(git log --format= --name-only -E --grep='^Task: T2$' HEAD | sort -u | sed '/^$/d')
  [ "$got" = "$want" ] && ok "T2 commits touch exactly the 10 files" \
    || no "T2 commits touch other files"
  git fetch -q origin change/build-swe-pod
  git merge-base --is-ancestor $c origin/change/build-swe-pod \
    && ok "T2 commit is on origin/change/build-swe-pod" \
    || no "T2 commit is not pushed"
else no "no commit with trailer Task: T2"; fi

echo "== total: $P ok, $F FAIL"
```

- red, before any content:

```
== (1) all 10 files exist
FAIL templates/records/spec.md missing
FAIL templates/records/plan.md missing
FAIL templates/records/brief.md missing
FAIL templates/records/test-brief.md missing
FAIL templates/records/report.md missing
FAIL templates/records/review.md missing
FAIL templates/records/evidence.md missing
FAIL templates/records/ledger.md missing
FAIL templates/records/handoff.md missing
FAIL templates/records/final-report.md missing
FAIL templates/records holds 0 files
== (2) headings and front-matter keys, one grep per item
FAIL templates/records/spec.md line: 6 items, file missing
FAIL templates/records/spec.md: ## headings not in the given order
FAIL templates/records/spec.md start: 3 items, file missing
FAIL templates/records/spec.md start: 7 items, file missing
FAIL templates/records/plan.md line: 15 items, file missing
FAIL templates/records/plan.md: ## headings not in the given order
FAIL templates/records/plan.md start: 11 items, file missing
FAIL templates/records/brief.md line: 6 items, file missing
FAIL templates/records/brief.md: ## headings not in the given order
FAIL templates/records/test-brief.md line: 9 items, file missing
FAIL templates/records/test-brief.md: ## headings not in the given order
FAIL templates/records/test-brief.md start: 1 items, file missing
FAIL templates/records/test-brief.md missing, or carries a reviewer part
FAIL templates/records/report.md line: 7 items, file missing
FAIL templates/records/report.md: ## headings not in the given order
FAIL templates/records/report.md start: 2 items, file missing
FAIL templates/records/report.md has: 5 items, file missing
FAIL templates/records/review.md fm: 3 items, file missing
FAIL templates/records/review.md line: 3 items, file missing
FAIL templates/records/review.md: ## headings not in the given order
FAIL templates/records/review.md start: 4 items, file missing
FAIL templates/records/evidence.md fm: 11 items, file missing
FAIL templates/records/evidence.md fmhas: 2 items, file missing
FAIL templates/records/evidence.md has: 2 items, file missing
FAIL templates/records/ledger.md blk: 16 items, file missing
FAIL templates/records/ledger.md: 0 fence lines, want 2
FAIL templates/records/ledger.md: block lines malformed, or no continuation example
FAIL templates/records/handoff.md line: 4 items, file missing
FAIL templates/records/handoff.md: ## headings not in the given order
FAIL templates/records/final-report.md line: 6 items, file missing
FAIL templates/records/final-report.md: ## headings not in the given order
FAIL templates/records/final-report.md start: 1 items, file missing
== extra: no trailing whitespace
FAIL files missing or trailing whitespace
== (4) standard close, local parts
ok   SPEC.md and spec-process.* unchanged since 854e87c
FAIL no commit with trailer Task: T2
== total: 1 ok, 45 FAIL
```

- green, after the content (the commit check stays red; see Status):

```
== (1) all 10 files exist
ok   templates/records/spec.md exists
ok   templates/records/plan.md exists
ok   templates/records/brief.md exists
ok   templates/records/test-brief.md exists
ok   templates/records/report.md exists
ok   templates/records/review.md exists
ok   templates/records/evidence.md exists
ok   templates/records/ledger.md exists
ok   templates/records/handoff.md exists
ok   templates/records/final-report.md exists
ok   templates/records holds exactly 10 files
== (2) headings and front-matter keys, one grep per item
ok   templates/records/spec.md line: 6/6 found
ok   templates/records/spec.md: ## headings in the given order
ok   templates/records/spec.md start: 3/3 found
ok   templates/records/spec.md start: 7/7 found
ok   templates/records/plan.md line: 15/15 found
ok   templates/records/plan.md: ## headings in the given order
ok   templates/records/plan.md start: 11/11 found
ok   templates/records/brief.md line: 6/6 found
ok   templates/records/brief.md: ## headings in the given order
ok   templates/records/test-brief.md line: 9/9 found
ok   templates/records/test-brief.md: ## headings in the given order
ok   templates/records/test-brief.md start: 1/1 found
ok   templates/records/test-brief.md carries no reviewer part
ok   templates/records/report.md line: 7/7 found
ok   templates/records/report.md: ## headings in the given order
ok   templates/records/report.md start: 2/2 found
ok   templates/records/report.md has: 5/5 found
ok   templates/records/review.md fm: 3/3 found
ok   templates/records/review.md line: 3/3 found
ok   templates/records/review.md: ## headings in the given order
ok   templates/records/review.md start: 4/4 found
ok   templates/records/evidence.md fm: 11/11 found
ok   templates/records/evidence.md fmhas: 2/2 found
ok   templates/records/evidence.md has: 2/2 found
ok   templates/records/ledger.md blk: 16/16 found
ok   templates/records/ledger.md: one fenced block
ok   templates/records/ledger.md: every block line is an event or an 18-space continuation
ok   templates/records/handoff.md line: 4/4 found
ok   templates/records/handoff.md: ## headings in the given order
ok   templates/records/final-report.md line: 6/6 found
ok   templates/records/final-report.md: ## headings in the given order
ok   templates/records/final-report.md start: 1/1 found
== extra: no trailing whitespace
ok   no trailing whitespace
== (4) standard close, local parts
ok   SPEC.md and spec-process.* unchanged since 854e87c
FAIL no commit with trailer Task: T2
== total: 45 ok, 1 FAIL
```

### Check (3), the closing line of test-brief.md
- command:

```
CLOSE='Do not read plan.md, ledger.md, any other brief, report or review, or any code-repo diff or implementation body.'
check3() {
  label=$1; content=$2
  if printf '%s\n' "$content" | grep -qxF -- "$CLOSE"
  then echo "ok   (3) $label: closing line present, exactly"
  else echo "FAIL (3) $label: closing line absent"; fi
  if [ "$(printf '%s\n' "$content" | tail -n 1)" = "$CLOSE" ]
  then echo "ok   (3) $label: closing line is the last line"
  else echo "FAIL (3) $label: closing line is not the last line"; fi
}
check3 "854e87c:templates/records/test-brief.md" \
  "$(git show 854e87c:templates/records/test-brief.md 2>/dev/null)"
check3 "templates/records/test-brief.md" "$(cat templates/records/test-brief.md)"
```

- red, at the T0 base tree:

```
FAIL (3) 854e87c:templates/records/test-brief.md: closing line absent
FAIL (3) 854e87c:templates/records/test-brief.md: closing line is not the last line
```

- green, in the working tree:

```
ok   (3) templates/records/test-brief.md: closing line present, exactly
ok   (3) templates/records/test-brief.md: closing line is the last line
ok   (3) file ends with a newline after the closing line
```

### Check (4), shareability (plan 2.8)
- after staging, before the attempted commit: `shareability: 0 hits`
- again after the refused commit: `shareability: 0 hits`

The staged scan also covered another task's files staged in the shared
index at the time.

### Extra: front matter loads as YAML

```
templates/records/evidence.md: parsed, keys id,change,commit_set,env,actor,scenarios,unit,quality,x-checks,x-suggestions,wall_time_s
templates/records/review.md: parsed, keys task,diff,verdict
```

## Concerns
- **Commit and push not done.** The permission classifier refused this
  commit, so done-when (4) is open: no `Task: T2` commit, nothing pushed,
  and the task cannot go to review yet. The ten files are staged by pathspec
  in the shared swe-pod checkout. To finish, run these from the checkout,
  each on its own line, then re-run the close checks:
  - `git -C <checkout> commit -m "Add the ten record templates" --trailer "Change: build-swe-pod" --trailer "Task: T2" --trailer "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -- templates/records/spec.md templates/records/plan.md templates/records/brief.md templates/records/test-brief.md templates/records/report.md templates/records/review.md templates/records/evidence.md templates/records/ledger.md templates/records/handoff.md templates/records/final-report.md`
  - `git -C <checkout> push origin change/build-swe-pod`
- **Spec state lines sit in a comment.** In `spec.md` the three state lines
  are inside the HTML comment, starting at column 0, so a line grep can find
  them. If a spec author keeps that comment, a status reader that greps
  `^- approved:` will read an unapproved spec as approved. The T7 status
  skill should take state only from the header list outside comments, or
  check that the comment is gone.
- **One `diff:` line per range.** `review.md` follows 2.4 to the letter. A
  review over two or more ranges then repeats the key `diff:`, which strict
  YAML parsers reject and lenient ones reduce to the last range. Readers must
  read those lines one by one.
- **Placeholders hide when rendered.** A placeholder such as `<handle>` or
  `<id>` in body text is raw HTML to a Markdown renderer, so a rendered
  preview hides it. The templates are meant to be read as source.
- **My readings, where 2.4 is silent:**
  - plan headings use the form `## 1. Goal and approach`, as this change's
    own plan does, while PROCESS.md uses `## 1 ...`;
  - the evidence body uses `## Failures` with one entry per failed or capped
    result, each with a `- log:` pointer;
  - the test brief's `## Result goes to` lists tests, at-base results and,
    for a verify task, evidence;
  - the brief's `## Start from` gives one line per repo plus the space.
- **Check (3) was added late.** My first script left it out, so its red run
  is against the T0 base tree rather than the first run.

## Test suggestions
### T2.TS1 Fresh spec from the template keeps its comment
- for the tester: the proposed and approved states (spec 5, state table) and
  R1 are at risk. Input: a spec made from the spec template with only the
  visible placeholders replaced and its comments left in. Expected failure:
  the change reads as approved, or a go is dispatched, with no human
  approval.
- for the reviewer: swe-pod/templates/records/spec.md:8-22, where the
  state lines start at column 0 inside the HTML comment.

### T2.TS2 Review over two repos
- for the tester: R18 (status read from the records) is at risk. Input: a
  whole-change review whose diff spans two repos, so it has two diff lines.
  Expected failure: the status view or the lead reports only one repo's
  range, or treats the record as malformed.
- for the reviewer: swe-pod/templates/records/review.md:3, the repeated
  `diff:` key.

### T2.TS3 Ledger made from the template still lists the example events
- for the tester: R18.S1 is at risk. Input: a new change whose ledger was
  made from the ledger template without emptying the block. Expected
  failure: a fresh agent asked "where are we?" reports placeholder dispatches
  or approvals as real events.
- for the reviewer: swe-pod/templates/records/ledger.md:13-31.

### T2.TS4 Evidence for a spec with no Quality section
- for the tester: R12.S2 is at risk. Input: verify on a change whose spec
  has no Quality section. Expected failure: the evidence keeps the
  per-check quality map instead of saying none were declared.
- for the reviewer: swe-pod/templates/records/evidence.md:15-17.
