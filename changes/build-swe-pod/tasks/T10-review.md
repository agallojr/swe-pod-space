---
task: T10
diff: agent-mesh e70dfc2..92f1dcf
verdict: fix
---

Range: agent-mesh e70dfc2..92f1dcf. One commit carries the trailer `Task: T10`: 92f1dcf, "Add space-librarian skill for filing records into a memory space". It has the trailers `Change: build-swe-pod` and `Task: T10`, and its subject is one line of plain ASCII. Its parent is e70dfc2 (T11's commit on the shared branch, which itself sits on the 8ee5364 pin). The commit adds one file, `skills/space-librarian/SKILL.md` (376 lines), and that is the task's only touch. `git show --check` is clean, and the file has no non-ASCII bytes. T9's two files are staged in the shared index but are not in 92f1dcf.

## Spec compliance

- **Missing.** No missing parts.
  - Output lines are `FILED <space path> <sha7>` and `REFUSED <space path>: <profile|reference|id> line <n>`. No matched text is ever printed.
  - Profile: the values come from the bus (`agents/*.yaml`, the `tasks/` inbox names, task ids from `tasks/`, `status/` and `_archive/`) and from the node (hostname, credential key names). It has the four home-path patterns. Generic `~/` paths are allowed, and so is an id-shaped example that no bus holds.
  - Reference: covers the four front-matter fields, plus qualified ids in the body outside code and fences. It resolves URLs, records, `may_reference`, live and archived change folders, and `<change>/T<n>`.
  - Id: covers the collision-free form and the UTC forms for evidence, decisions and handoffs, and checks that the id is not already present.
  - Commit stage: one commit per record, by literal path, with a plain message. Then `fetch origin`, `rebase origin/main` and `push origin HEAD:main`, and `FILED` only after a fresh fetch and `merge-base --is-ancestor`. It never force-pushes.
  - The skill says a mesh librarian uses it for every rw space `spaces.yaml` assigns to its role (lines 16 to 24), and that without a bus the session uses it directly (lines 26 to 28).
- **Extra (all flagged in the report, all acceptable).**
  - `rebase --autostash`.
  - The check runs again after the rebase.
  - A record already on `origin/main` unchanged is reported `FILED` with no new commit.
  - A changed event file at a filed path is refused as `id`.
  - Values shorter than 3 characters are skipped.
  - Reference and id are checked for Markdown files only.
  - There is a `CHECKED` working line and a Desk run section.
- **Misread.** One. The profile rule "no real ... agent id, mesh task id" is matched with `-` as a word character, so hyphen-joined real values pass (Important, below).

## Done-when, run by the reviewer

Each run used the committed blob, which is identical to the worktree copy. The script was extracted from SKILL.md lines 121 to 294, and the space was copied without `.git` into a scratch directory outside every repo (`git rev-parse` fails there). The bus was found through the node's identity file, and its registry values were included (187 words, 7 paths).

1. All five clean copies are accepted (`CHECKED`): `spec.md`, `plan.md`, `ledger.md`, note-20261027T2142Z-0a31 and note-20261027T2242Z-0786. The run took 1.24 s wall time under /bin/sh, and the result was the same under /bin/dash.
2. Five records were built at run time, each with a fresh id. Each was refused, with only the check and the line number printed:
   - local `$HOME`: profile line 10;
   - a registered agent's `cwd` root (one not under a home root): profile line 10;
   - an agent id from the registry: profile line 10;
   - a citation of `proj:other-space/...`: reference line 10;
   - a duplicate of the 0a31 id: id line 2.

   Every output line matches the REFUSED form exactly, stderr was empty, and a scan for each probe value found none in the output. Controls against an empty registry accept the cwd-root and agent-id records, which shows the registry patterns are what refuse them. The results were identical under /bin/sh, /bin/dash and /bin/ksh.
3. The report's desk output gives the full section 2 sequence for its own path, in skill order. The space's log and reflog show no `File changes/build-swe-pod/tasks/T10-report.md` commit, and the report is still untracked, so the sequence was not run.
4. Standard close:
   - `share-check.py --task T10` prints `shareability: 0 hits`, exit 0.
   - In swe-pod, `git diff 854e87c -- SPEC.md spec-process.*` is 0 lines, and 854e87c is the only `Task: T0` commit.
   - `ls-remote` shows `change/build-swe-pod` at 92f1dcf.
   - This review has one open Important finding, so the close does not hold yet.

Extra checks:

- A read-only run over all 44 files of the live space checkout, tracked and untracked, accepted every one.
- In a scratch clone with an `origin/main`:
  - the original 0a31 note passes, because its id is at the same path on `origin/main`, while a copy at a new path is refused as `id`;
  - an edited existing note with the same id passes;
  - a new evidence record `ev-<UTC>` passes.
- Probes:
  - `<change>/T10` resolves, and `<change>/T99` is refused;
  - an unresolved block-list `related` is refused at its own line;
  - `swe-pod/R4` in `superseded_by` is refused;
  - a `lore/` citation is refused, since `may_reference` is `[]`;
  - an upper-case id form is refused.
- A task id or agent id joined by a hyphen passes; see Findings.
- Portability: no `-P`, no `\d`, `\s`, `\w` or `\b`, and no interval expressions in awk. Only `grep -E`, `sed -E` and POSIX awk are used. GNU tools are not installed on this node and the container runtime is down, so the GNU run is still owed. T20 or I8 on `linux-server` should run the five clean and five built records there.

## Quality

- The script is careful and compact:
  - its value lists stay in a temporary directory that a trap removes on exit;
  - every regex value goes through `esc`;
  - every pattern list is filtered so that it holds no empty pattern, so `grep -f` cannot match everything;
  - the first failing line is found by a numeric sort.
- Section 2 handles the retry and partial-failure paths explicitly: nothing to commit, a rejected push (three pushes at most), a rebase conflict (abort), and the recheck and reset after a rebase. The only gap is the failed ancestor check (Minor, below).
- The skill's front matter matches the other agent-mesh skills (`name`, `description`, `allowed-tools`). The description says when to invoke the skill, not a standing directive.

## Findings

- Important agent-mesh/skills/space-librarian/SKILL.md:168 The profile word patterns treat `-` as a word character on both sides (`(^|[^A-Za-z0-9_-])<value>([^A-Za-z0-9_-]|$)`), so a real bus value joined by a hyphen passes. Reproduced against the live registry: a real mesh task id written in the bus's own file-name form `_archive/<yyyy-mm>/<task id>-result.md` is CHECKED, and so are `task-<task id>` and `node-<agent id>`. Every task message and result on the bus is named `<task id>-<slug>`, and §2.7 names `<task-id>-files/`, so this is the most likely way a task id gets copied into a record, and R16 forbids it. Fix: give task-id and agent-id values a boundary that allows `-` (for example `(^|[^A-Za-z0-9])<tid>([^0-9]|$)`, with an alphanumeric boundary for the hex agent ids), and keep the hyphen boundary only where it prevents false refusals (hostname labels, credential key names). Add a probe for `<task id>-result.md` to the harness.
- Minor agent-mesh/skills/space-librarian/SKILL.md:193 `holders` matches file names by prefix (`-name "$1*"`), so a truncated citation such as `note-<YYYYMMDD>` resolves to any record whose name starts with it (reproduced: `related: [note-<8 digits>]` passes reference). This fails open, but only for date-shaped prefixes of real names.
- Minor agent-mesh/skills/space-librarian/SKILL.md:195 `holders` counts an `id:` line anywhere in another .md file, a fenced example included, as holding the id. A new record can then be refused as `id` when it should not be. This fails closed, and the live space has no such case today.
- Minor agent-mesh/skills/space-librarian/SKILL.md:357 Step 5 does not say what happens when `merge-base --is-ancestor` exits non-zero. The record then gets no line and the caller gets no message, which breaks the Output contract of one line per record. It should say, as step 4 does, that filing stopped at this record.
- Minor agent-mesh/skills/space-librarian/SKILL.md:79 Reference reads only YAML front-matter. The spec record's bullet header `- supersedes:` (whose template value is `<change>/<Rn>`) is therefore never checked, and §2.7 has no rule that resolves `<change>/<Rn>`. This is a plan-level gap the builder flagged. It goes to the ledger for the lead, not to a T10 fix.
- Minor agent-mesh/skills/space-librarian/SKILL.md:184 The body scan catches a qualified id only when its record id is date-shaped. A body citation `proj:<other>/<change id>` to a space outside `may_reference` passes (reproduced). That is a fair reading of §2.7's `<space id>/<record id>`, but it is worth a line in the skill.

