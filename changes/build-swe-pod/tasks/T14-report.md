# T14 report

- change: build-swe-pod
- task: T14
- role: build
- repo: agent-mesh

## Status

DONE

## What I did

- Started from `change/build-swe-pod` at c6aa593 (T13's commit). T10's review
  r1 and T13's review had both closed. The shared checkout was clean.
- Wrote the done-when checks first, as two shell scripts, and ran them. Check
  2 (the content the steps ask for) failed on all 10 items. Check 3 (the
  `Task: T14` commit) failed because there was no commit yet.
- `README.md`, Layout table: the `skills/` row now lists `mesh-load` and
  `space-librarian` after the five skills it already listed.
- `README.md`, new section `## Project spaces`, after the library section. Its
  first paragraph covers memory spaces and project spaces (`proj:<name>`):
  - the operator mounts a space by hand under `spaces/` and lists it in
    `spaces.yaml`, and a node clones it on first need;
  - a session loads it with `load <project>` (`mesh-load`), and a task loads
    it through `project:` (`mesh-post --project`);
  - one librarian writes each space, through `space-librarian` (profile,
    reference and id checks, then a commit and a push to `main`), and a
    session with no bus runs the same skill as its own librarian;
  - result `files:` reach the space through that librarian.

  It links `spec/memory-spaces.md`, `spec/PROTOCOL.md` (§3 and §5) and
  `docs/operator-manual.md` (§8, mounting).
- Its second paragraph names the SWE Pod's six roles: `swe.spec`, `swe.plan`,
  `swe.lead`, `swe.build`, `swe.test` and `swe.review`. It says they are
  per-task-output roles (PROTOCOL §2) that any number of nodes may hold. A
  node takes one by adding it to `AGENT_ROLES`, and the protocol, guidance
  and poller are unchanged. This matches T9's wording in the operator manual.
- Each claim was checked against PROTOCOL §2, §3, §5 and §5.1, the
  memory-spaces Status table, and the two skills. The README claims nothing
  the Status table marks "not yet".
- Ran the checks again, all green. `git diff --check` is clean. Staged by
  pathspec and ran the shareability check: 0 hits. Committed by pathspec with
  both trailers. The merge-base check exited 0, so there was no rebase.
  Pushed, then ran every check and the shareability check again on
  `origin/change/build-swe-pod`.

## Files

- `README.md` (agent-mesh): +27 lines, -1 line
- Commit range: `agent-mesh c6aa593..e0f6af0`. It is one commit, e0f6af0,
  with trailers `Change: build-swe-pod` and `Task: T14`, pushed to
  `change/build-swe-pod`.
- `changes/build-swe-pod/tasks/T14-report.md` (space): this report, for the
  librarian to file

## Test output

Checkout paths are replaced with placeholders.

The done-when checks, `check.sh <agent-mesh checkout> <ref>`. With ref `WT`
it reads the working-tree README and checks its paths against `HEAD`'s tree.
With any other ref it reads both from that ref.

```sh
repo=$1; ref=$2
cd "$repo" || exit 2
if [ "$ref" = WT ]; then readme=$(cat README.md); tree=HEAD
else readme=$(git show "$ref:README.md"); tree=$ref; fi
# check 1, done-when (1): every repo-relative link target exists in $tree
links=$(printf '%s\n' "$readme" | grep -o '](\([^)]*\))' |
  sed -e 's/^](//' -e 's/)$//' -e 's/#.*$//' | sort -u)
for l in $links; do
  case $l in http://*|https://*|mailto:*|'') continue ;; esac
  git cat-file -e "$tree:${l%/}" 2>/dev/null && echo "ok   $l" || echo "MISS $l"
done
# check 2, the steps: the skills row names `mesh-load` and `space-librarian`;
# the README links ](spec/memory-spaces.md); a "## Project spaces" heading;
# each of the six `swe.*` roles appears in backticks
```

Check 1 is a guard: every link in the old README already resolved, so it
passes before and after. To show it can fail, a negative control fed it a
link to a missing file:

```
MISS spec/no-such-file.md (negative control)
```

Red, before the content (working tree at c6aa593):

```
== check 1: every repo-relative README link exists on HEAD
ok   docs/operator-manual.md
ok   docs/positioning.md
ok   docs/product-data-split.md
ok   docs/reinstall-after-split.md
ok   INSTALL.md
ok   install/README.md
ok   lenses/README.md
ok   spec/PROTOCOL.md
links=8 check1 exit=0
== check 2: steps content
MISS skills row lists mesh-load
MISS skills row lists space-librarian
MISS links spec/memory-spaces.md
MISS project spaces section
MISS names swe.spec
MISS names swe.plan
MISS names swe.lead
MISS names swe.build
MISS names swe.test
MISS names swe.review
check2 exit=1
overall exit=1
```

Green, after the content (working tree), and again after the push, read from
`origin/change/build-swe-pod`. The two runs gave the same lines:

```
== check 1: every repo-relative README link exists on origin/change/build-swe-pod
ok   docs/operator-manual.md
ok   docs/positioning.md
ok   docs/product-data-split.md
ok   docs/reinstall-after-split.md
ok   INSTALL.md
ok   install/README.md
ok   lenses/README.md
ok   spec/memory-spaces.md
ok   spec/PROTOCOL.md
links=9 check1 exit=0
== check 2: steps content
ok   skills row lists mesh-load
ok   skills row lists space-librarian
ok   links spec/memory-spaces.md
ok   project spaces section
ok   names swe.spec
ok   names swe.plan
ok   names swe.lead
ok   names swe.build
ok   names swe.test
ok   names swe.review
check2 exit=0
overall exit=0
```

The standard-close checks, `close.sh <agent-mesh checkout> <swe-pod checkout>`:

```sh
# check 3: each Task: T14 commit on origin/change/build-swe-pod carries
# "Change: build-swe-pod" and changes exactly README.md
shas=$(git log --format=%h --grep='^Task: T14$' origin/change/build-swe-pod)
# check 4: swe-pod SPEC.md and spec-process.* unchanged since the latest T0
t0=$(git log -1 --all --format=%h --grep='^Task: T0$')
git diff "$t0" -- SPEC.md 'spec-process.*' | wc -c
```

Red, before the commit:

```
== check 3: Task: T14 commits on origin/change/build-swe-pod
no Task: T14 commit
check3 exit=1
== check 4: swe-pod SPEC.md and spec-process.* unchanged since latest T0
T0=74d23f1 diff-bytes=0
check4 exit=0
overall exit=1
```

Green, after the push:

```
== check 3: Task: T14 commits on origin/change/build-swe-pod
commits: e0f6af0
e0f6af0 files: README.md
check3 exit=0
== check 4: swe-pod SPEC.md and spec-process.* unchanged since latest T0
T0=74d23f1 diff-bytes=0
check4 exit=0
overall exit=0
```

74d23f1 is also the latest `Task: T0` commit on `origin/change/build-swe-pod`
in swe-pod. Check 4 passes both times, since T14 does not touch swe-pod.

`git diff --check README.md` before staging: no output, exit 0.

Push: `c6aa593..e0f6af0  change/build-swe-pod -> change/build-swe-pod`.
The merge-base check exited 0 before the push, so there was no rebase.

Shareability check (§2.8), last line, after staging: `shareability: 0 hits`.
After the commit and push: `shareability: 0 hits`.

Unit suite: agent-mesh has no unit suite. It has no test files and no test
runner, and its one `package.json`, under `services/librarian-ingress/`, has
no test script. So there is no `unit <p>/<n>` line.

## Concerns

- **For information only; the lead need not act.** The Layout table had two
  gaps before this change, and I left both as they were. The `skills/` row
  still leaves out `lens`, `mm`, `mm-on` and `mm-off`, and the `spec/` row
  names only `PROTOCOL.md`. The steps name only the two new skills, and the
  new section links `spec/memory-spaces.md` itself.

## Test suggestions

### T14.TS1 README links resolve on the change branch

- for the tester: R7 and R17 through spec §14 M2 and M5. On
  `change/build-swe-pod`, take every repo-relative link in the agent-mesh
  README, ignoring URLs and `#` anchors. Each target should exist in the
  branch's tree. The README should link the memory spaces design. A broken
  or renamed target fails.
- for the reviewer: `agent-mesh/README.md:129-153`, the new section, which
  links `spec/memory-spaces.md`, `spec/PROTOCOL.md` and
  `docs/operator-manual.md`. A later rename of any of them breaks the links
  without warning, and nothing in the repo checks them.

### T14.TS2 README claims no more than the product implements

- for the tester: spec §14 M2, M3 and M5, and the Status table of the memory
  spaces design. Read the README's project spaces section. It should not
  claim a part the Status table marks "not yet": a shared lore space, core
  and lore split into spaces, the `active:` default, auto-load at session
  start, or the session-start catalog. It should say mounting is a manual
  operator step, and that one librarian writes each space.
- for the reviewer: `agent-mesh/README.md:131-146`. Check each sentence
  against PROTOCOL §3, §5 and §5.1 and `skills/mesh-load/SKILL.md` and
  `skills/space-librarian/SKILL.md`. The wording is drawn from those
  sources, and it can drift from them when they change.

### T14.TS3 README names the six pod roles as per-task-output roles

- for the tester: R7 and spec §14 M1. The README should name `swe.spec`,
  `swe.plan`, `swe.lead`, `swe.build`, `swe.test` and `swe.review`. It
  should call them per-task-output roles that any number of nodes may hold,
  and it should agree with the operator manual's "SWE Pod roles" bullet.
- for the reviewer: `agent-mesh/README.md:148-153`, against
  `docs/operator-manual.md` section 1, the "SWE Pod roles" bullet from T9.
  Two copies of the same rule can drift apart.
