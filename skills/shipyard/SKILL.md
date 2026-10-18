---
name: shipyard
description: Runs a crew of agents (scout, planner, builders, tester, reviewer) that turns a plain-words request into a pushed branch. Asks the owner at every unclear point, gets approval of a visual proposal before any code, then builds, tests and reviews. Use for "/shipyard <request>", "build this with the crew", or to continue or answer a Shipyard run already in progress.
---

# Shipyard

You are the orchestrator. You run in the main session because only you can start subagents and talk to the owner. The crew (`scout`, `planner`, `builder`, `tester`, `reviewer`) does the work; the owner makes the decisions. The owner is the person who sent the request.

## Rules that hold at every stage

1. **Ask instead of guessing, on what matters.** When two reasonable readings would give the owner something they would notice and care about (where something goes, how a number is worked out, a database change, what is in scope), ask the owner. A detail a sensible builder would settle alone (formatting, naming, trimming whitespace, where a helper lives) is not a question: decide it and list it under `Decisions made` in `approval.md`, where the owner checks it at approval. A clear request goes straight to the proposal with no questions. Use `AskUserQuestion`: at most 4 questions per call, most important first. If that tool is unavailable, put the questions in your reply. Either way, **stop after asking**: end your turn and wait for the answer. Never carry on with an assumed answer.
2. **No production code before approval.** Nothing outside the run's folder changes until `state.md` has a filled-in `approved:` line. Only the owner approves, in their own words. You never write `approved:` on your own judgment.
3. **The project's rules win.** Follow its `CLAUDE.md` / `AGENTS.md`: its process, test commands, version bumps, rules on test data. Shipyard's defaults apply only where the project says nothing.
4. **State lives in the repo.** The run's folder holds the record: `state.md`, `tasks.md`, the scout's report as `scout.md`, and the owner's answers under `answers:` in `state.md`. Update `state.md` when the stage changes. A run on any device resumes from these files alone, never from this chat.
5. **Commit at the end of every stage** on the run's branch, with messages like `shipyard: <stage> for <slug>`. Stage files by path: the run's folder and the files the builders own. Never `git add -A` or `git add .`, so none of the owner's own work is swept in. Push after every commit when `push-ok` is `yes` or `cloud`, so another device can pick the run up. Never merge without the owner's answer at the finish (stage 8), never force-push, never delete a branch you did not create.
7. **Each run has its own worktree, and only the crew changes it.** Other sessions and people may share the owner's checkout, so the run never works there: at the start you create a git worktree for the run's branch (see New run), and every agent, command and commit uses it. Never switch branches, stash, reset or clean in the owner's checkout. Before each commit, compare `git status` in the worktree with the files this run touched. Changes not made by the crew are left alone, never staged, and reported to the owner. A `Shipyard worktree: no` line in the project's `CLAUDE.md` or `AGENTS.md` turns worktrees off; the run then works in the checkout itself.
6. **Scale to the request.** A one-file change is one builder and no parallel step. It still gets a proposal and approval.
8. **Use the knowledge graph when the project has one.** When `graphify-out/graph.json` exists, the scout maps the change with `graphify query`, `graphify explain` and `graphify path` before reading files, and you run `graphify update .` at the finish (stage 8), in every mode. With no graph, or no `graphify` command, carry on without it and say so in `scout.md`.
9. **Screen work keeps the UI consistent.** When the change adds or alters something people see (a page, a component, a layout, an email), tell the planner, the builders that own UI files and the reviewer `ui: yes`. The aim is a screen that looks like it was always part of the app:
   - **The app's own design comes first.** Use its tokens, components and the layout of its nearest existing screen. Never add new colours, fonts, spacing scales or one-off styles where a token or component exists. A design document (`DESIGN.md` or the like) counts only when it matches the code: the code wins, and a stale document is reported to the owner.
   - **The design skills are for craft, not a new look.** Load `frontend-design:frontend-design` and `design-taste-frontend` with the Skill tool for hierarchy, spacing rhythm, states (empty, loading, error), contrast and a pre-flight check. Their push for a distinctive aesthetic applies only when the owner asks for a redesign or a new look.
   - When a skill is not installed, the agent says so in its report and carries on.
10. **Leave other people's processes and files alone.** This holds for you and for every agent. Pass it, with the worktree path, to each one you dispatch.
   - Stop only processes the run started, by the PID noted when starting them. Never `pkill`, `killall`, or kill by name or by port.
   - Start a server for a check from the run's worktree, on a free port (not the project's usual one), and stop it before reporting.
   - Never `git stash`, `git checkout <branch>`, `git switch`, `git reset` or `git clean`, and never touch the owner's checkout or another worktree.
   - Put temporary files in the worktree or a `mktemp -d` folder, and remove them. A symlink made to borrow `node_modules` or the like is removed too.

## Modes

A run has one mode: `quick`, `standard` or `deep`. It sets how much effort goes into each stage. **Every mode keeps** the rules above: ask on what matters, no code before approval, the project's rules, nothing left behind, and the merge question at the finish.

- **Name the run's mode** in every message where you stop for the owner, for example "(deep mode)".
- **Choosing it:** a `quick:` or `deep:` prefix on the request (strip it from the request); else a `Shipyard mode: <mode>` line in the project's `CLAUDE.md` or `AGENTS.md`; else `quick` when the request is a **small change**; else `standard`. Record it as `mode:` in `state.md`. A resumed run keeps its recorded mode.
- **A small change** likely touches under about 50 lines in at most 3 files, and no database migration, money or calculation logic, sign-in, permissions or security. When you pick `quick` for that reason, say so in one line. When research shows a `quick` run is bigger than that, switch to `standard` before the proposal and say why.

| Stage | `quick` | `standard` | `deep` |
|---|---|---|---|
| 1. Research | no scout: you read the files the request names, their neighbours and the project's rules file, and write a short `scout.md` | one scout | three scouts in parallel, in one message, each with a focus: the code; the tests and specs; history and prior art (git log, similar features in the repo) |
| 2. Questions | only blockers; everything else becomes a listed decision | as written | also edge cases and what could go wrong |
| 3. Proposal | no planner: you write the short `approval.md` (What changes, Picture, Files, Acceptance criteria, Decisions made) and `tasks.md` | all eight sections | all eight, plus Alternatives considered, Pre-mortem and Test plan |
| 5. Build | one builder, which also writes or updates the tests for its change | parallel builders by area | parallel builders, tests written first, dispatched with `model: opus` |
| 6. Test | no tester: you run the tests nearest the change | the full test command | the full test command, plus a browser or end-to-end check when the project's rules allow test accounts, plus tests for the Pre-mortem's risks |
| 7. Review | your own check of the diff against the acceptance criteria, no reviewer | one reviewer | three reviewers in parallel, in one message, each with a focus (correctness, security, the project's rules), dispatched with `model: opus`; up to 3 rounds |

Templates beside this file: `state-template.md` and `approval-template.md`.

## Starting or resuming

- Cloud session: the environment variable `CLAUDE_CODE_REMOTE` is `true` (check with `echo "$CLAUDE_CODE_REMOTE"`). There, `push-ok` is `cloud`, and the branch is pushed at every commit.
- **Find an existing run first.** A run may have been started on another device, so its branch can exist only on the remote.
  - Run `git fetch --quiet` when there is a remote, then list `git branch -a --list '*shipyard/*'`.
  - Look for a `state.md` whose `stage` is not `done`: on the current branch, on each `shipyard/*` branch (local or `origin/`; read it with `git show <branch>:<path>`), under `docs/shipyard/*/` and under `openspec/changes/*/`.
- **Decide whether the message answers that run.** Continue a run only when exactly one is open and the text after `/shipyard` reads as a reply to it: an answer to its open question, an approval, or a change to its proposal. If the text reads as a new request, or more than one run is open, ask the owner which they mean (continue which run, or start a new one) and stop.
- **Continuing:** work in the run's worktree. When the `worktree:` path in `state.md` exists and holds the branch, use it; otherwise create it with `git worktree add <path> shipyard/<slug>`, which also picks up a remote-only branch. With worktrees off, check out the branch instead. A run whose `state.md` has no `worktree:` line was started before worktrees: it carries on in the checkout, as before. Read `state.md`, `scout.md`, `approval.md` and `tasks.md`, then go to the stage named in `stage`.
- **Check approval against the tree on every resume.** If `approved:` is empty but there are changes outside the run's folder (`git status` in the worktree, and `git diff <base>...HEAD`), stop, unless `scope-changes:` explains them (a re-approval after a scope change). Tell the owner what changed and ask what to do: approve the proposal as it stands, or set the changes aside. Setting aside means committing them to a side branch, or `git stash push -u -m "shipyard: set aside"` in the run's worktree when the owner asks for that. Never discard work: no `git checkout -- .`, `git reset --hard` or `git clean`. Do not build, and do not approve on their behalf.
- **New run.**
  - Set the mode (see Modes) and strip any `quick:` / `deep:` prefix from the request.
  - **Merge permission given up front:** a `merge to <branch>:` part of the prefix (`merge to main:`, or with a mode, `deep, merge to main:`) means merge when clean. Strip it and record `merge-to: <branch>`. Without it, `merge-to:` stays empty and the finish asks.
  - Make `<slug>`: kebab-case, at most 5 words, from the request.
  - If the working tree has uncommitted changes: with worktrees on, they stay in the owner's checkout and are not part of the run; say so in one line and carry on. With worktrees off, ask the owner first whether to commit them, stash them, or leave them out of the run, and stop.
  - Note the current branch (`git branch --show-current`; `detached` when empty) as `base-branch`. Create the branch and its worktree from the current HEAD in one step: `git worktree add -b shipyard/<slug> <path> HEAD`, with `<path>` = `<parent folder of the repo>/<repo folder name>.shipyard/<slug>`. Note the commit as `base` and the path as `worktree:`. From now on run every command there. With worktrees off, create the branch in the checkout instead.
  - A new worktree has only what git tracks. When the checks need more (installed dependencies such as `node_modules` or a virtualenv, an untracked `secrets.ini` or `.env.local`), install the dependencies, or symlink or copy the owner's, and list each one under `copied:` in `state.md`. The finish removes them.
  - **Reserve the change number** when the project numbers its changes (`NNN-name` folders, as in `openspec/changes/`). Take the highest number used in those folders, and in their archive, on HEAD and on every local and `origin/` branch (`git ls-tree -r --name-only <ref> <folder>`). Also count the `change-number:` line in any open run's `state.md` on a `shipyard/*` branch. Add one, and record the result as `change-number:`. At stage 3, check again: when another branch has taken it since, take the next free number.
  - Write `state.md` from the template in `docs/shipyard/<slug>/`, in the worktree, with `stage: research`. Commit it and push straight away when `push-ok` allows, so a parallel run sees the reserved number. That is the run's folder, unless the project has a change process of its own. For OpenSpec, the propose step creates `openspec/changes/<slug>/` (it refuses a folder that already exists), and the run's files then move there (stage 3).

## 1. Research

In `quick`, do the research yourself (see Modes). Otherwise dispatch the scout or scouts the mode calls for, with the request (and each one's focus in `deep`), the worktree path, rule 10, and whether `graphify-out/graph.json` exists. Save the report, or the reports one after another, as `scout.md` in the run's folder: its `## Project rules` go to every later agent. Set `stage: questions`.

## 2. Questions

Sort the scout's `## Unclear` items, and anything you see yourself, as the mode says: ask the ones whose wrong guess would change what the owner gets; settle the rest yourself and pass them to the planner as decisions to list. When nothing needs asking, skip straight to stage 3 in the same turn. Always ask how to run tests when the scout found no stated test command. Record each open question under `open-questions:` in `state.md`, then ask and stop. Write each answer under `answers:` in `state.md` as it comes back. When the answers come back, ask any follow-ups they raise. Move on only when nothing that matters is unclear. Set `stage: proposal`.

## 3. Proposal

- If the project has a process of its own (the scout's `## Project rules`), run its propose step yourself. For OpenSpec, use `/opsx:propose <slug>` through the Skill tool, or the `openspec` CLI. Then `git mv` the run's files from `docs/shipyard/<slug>/` into the new change folder, and update `folder:` in `state.md`.
  - The `openspec` CLI rejects a name that starts with a digit. When the project numbers its changes (`NNN-name`), create the change with its plain name, then rename the folder to the reserved `change-number:`.
  - At archive, OpenSpec applies a `## MODIFIED Requirements` block only when its header matches a requirement in the main spec word for word. A requirement the main spec doesn't have yet goes under `## ADDED Requirements`.
  - When the propose command isn't available in this session, create the change with the CLI and have the planner write its files in the format of an existing change.
  - When the change folder is ignored by git but the project already tracks files there (`git ls-files <folder>` lists some), stage the run's files with `git add -f`.
- In `quick`, write the short `approval.md` (from `approval-template.md`) and `tasks.md` yourself. Otherwise dispatch `planner` with: the request, the scout report, the owner's answers, the run's folder in the worktree, whether the project has its own process, the path to `approval-template.md`, and `ui: yes` when the change touches a screen (rule 9).
- If the planner reports `## Unclear` items, go back to stage 2.
- Give the planner the mode. Read `approval.md` yourself. It must have the sections the mode calls for, in the template's order: in `standard` and `deep`, at least two `mermaid` blocks; in `quick`, the short form. Send any gap back to the planner.
- Set `stage: awaiting-approval` and commit: `shipyard: proposal for <slug>`.

## 4. Approval

- Give the owner the path to `approval.md` and a 3-line summary. When you can publish an artifact, offer `approval.md` as a page.
- Locally (`push-ok: no`), ask once whether to push the branch so `approval.md` can be read on GitHub's mobile app. Record the answer as `push-ok: yes` or `no`, and push if yes.
- **Suggest a mode** when the run's mode doesn't fit what the proposal touches: `deep` for a database migration, money or calculation logic, sign-in, permissions or security; `quick` for a small change (see Modes) in `standard`. Say why in one line. Switching to `deep` runs its extra research and proposal sections before approval.
- Ask the owner, with `AskUserQuestion`: approve as it stands; approve and merge into `base-branch` when clean (offer `main` too when it differs); change something; or switch mode when you suggested one. Then stop and wait. An approval with a merge target records `merge-to: <branch>`.
- **Only a plain approval counts:** "approved", "approve", "yes, build it", "go ahead". Any approval with a change attached ("looks good, but…", "yes, and also…") is a change request:
  - send the change to the planner as a revision
  - leave `approved:` empty
  - commit the revised `approval.md`
  - show the owner what changed, and ask again
- On a plain approval: write `approved: <date> — <one-line summary of what was approved>`. Set `stage: build`, commit, and push if `push-ok` is `yes` or `cloud`.

## 5. Build

- **Hard check first:** `approved:` is filled in. If it is empty, go to stage 4.
- Split the tasks in `tasks.md` into areas whose files do not overlap. Give each builder: the worktree path, the run's folder, its task numbers, its owned files, the project rules, rule 10, and `ui: yes` when it owns UI files (rule 9). In `quick`, tell it to write or update the tests for its change too. Builders do not edit `tasks.md`: tick each task yourself from the builders' `## Done` reports. The closing steps (version bump, ticking, archiving) are yours, at stage 8: never give them to a builder.
- One area means one builder. Several areas mean builders dispatched in parallel, in one message. In `quick`, one builder takes every area. In `deep`, tell each builder to write its tests first, and dispatch it with `model: opus`.
- When a builder reports `## Blocked`, ask the owner, then dispatch it again with the answer. A file it needs that another builder owns waits until that builder is done.
- **A scope change** (a goal, screen or database change that is not in `approval.md`): have the planner update `approval.md`, record it under `scope-changes:`, empty `approved:`, and go to stage 4. Smaller adjustments are noted for the final summary.
- Commit: `shipyard: build for <slug>`. Set `stage: test`.

## 6. Test

- In `quick`, run the tests nearest the change yourself, in the worktree. Otherwise dispatch `tester` with: the worktree path, the run's folder, the mode, the project's test commands and test-data rules, rule 10, and the files the builders changed.
- When it reports `## Could not fix`, send that failure to the builder that owns the file, once, and test again. If it still fails, ask the owner.
- Record the result in `state.md` as `tests: passed — <command>` or `tests: failed — <command> (<what failed>)`.
- Commit: `shipyard: tests for <slug>`. Set `stage: review`.

## 7. Review

- As the mode says: in `quick`, check the diff against the acceptance criteria yourself. Otherwise dispatch `reviewer` with: the worktree path, the run's folder, `base`, the project rules, `ui: yes` when the diff touches a screen (rule 9), and its focus in `deep` (three at once).
- `critical` problems go back to the owning builders, then to the tester again. After 2 rounds, ask the owner.
- `## Scope changes` go to stage 4, as in stage 5.
- Warnings you leave are listed in the final summary.
- Record the result in `state.md` as `review: clean` or `review: <n> critical left`.
- Commit: `shipyard: review fixes for <slug>`. Set `stage: finish`.

## 8. Finish

1. Run the project's closing steps from its rules, for example a version bump or ticking `tasks.md`. When `graphify-out/graph.json` exists, run `graphify update .` (rule 8); commit what it changes only if the project tracks `graphify-out/`.
2. Check that nothing the run made for testing is left behind (test users, test data, temporary files, extra branches, servers it started), as the project's rules define it.
3. Set `stage: done` and commit: `shipyard: finish <slug>`.
4. Only now archive the change if the project's process does (for OpenSpec, `/opsx:archive`). The run's files move with it, and nothing is written to the old folder afterwards. Commit the archive.
5. Push the branch if `push-ok` is `yes` or `cloud`. If it is `no`, ask once more now; finished means pushed.
6. **Merge when clean:** when `merge-to:` names a branch and the run is clean (`tests: passed`, `review: clean`, nothing pending under `scope-changes:`), don't ask: merge into that branch and push, as in step 7. When `merge-to:` is set but the run is not clean, ask as below, and say why it is not clean.
   **Merge and push?** Otherwise ask the owner, with `AskUserQuestion`, whether to merge `shipyard/<slug>` and push the result. When it isn't merged, still remove the worktree (step 8). Offer:
   - into `base-branch` (the branch the run started from), first, unless it is `main` or `detached`
   - into `main`
   - into another branch the owner names
   - don't merge, leave the branch pushed

   Put this question last in your message, with every option listed by name, even when you also give the step 8 summary. Then stop and wait. Never merge without this answer or a `merge-to:` the owner gave.
7. On a branch answer, merge in the run's worktree, so the owner's checkout is never switched:
   - `git fetch origin <target>` when it has an upstream, then `git checkout --detach origin/<target>` (or `<target>` without one), then `git merge --no-edit shipyard/<slug>`, then `git push origin HEAD:<target>`.
   - Then move the local `<target>` up when it only moves forward. When no worktree has it checked out, use `git branch -f <target> HEAD`. When a clean checkout has it, use `git -C <that checkout> merge --ff-only <commit>`. Otherwise leave it, and tell the owner to pull.
   - On a conflict, a failed fetch or a refused push, stop: run `git merge --abort` if a merge is half done, tell the owner what happened and ask. Never force-push, and never delete `shipyard/<slug>`.
   - With worktrees off: `git checkout <target>`, `git pull --ff-only` when it has an upstream, `git merge --no-edit shipyard/<slug>`, `git push`, and stay on the target branch.
8. Remove what the run made outside git: everything listed under `copied:`, then the worktree (`git worktree remove <path>`, after the last push; the branch stays).
9. Reply with:
   - the branch, whether it is pushed, and where it was merged (or the pull request link the push printed, when not merged)
   - what was built
   - the test command and its result
   - smaller changes made after approval
   - anything skipped, and why

Shipyard merges only into a branch the owner picked: up front (`merge-to:`), at approval, or at step 6.
