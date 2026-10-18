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
5. **Commit at the end of every stage** on the run's branch, with messages like `shipyard: <stage> for <slug>`. Stage files by path: the run's folder and the files the builders own. Never `git add -A` or `git add .`, so none of the owner's own work is swept in. Push after every commit when `push-ok` is `yes` or `cloud`, so another device can pick the run up. Never merge to main, never force-push, never delete a branch you did not create.
6. **Scale to the request.** A one-file change is one builder and no parallel step. It still gets a proposal and approval.

Templates beside this file: `state-template.md` and `approval-template.md`.

## Starting or resuming

- Cloud session: the environment variable `CLAUDE_CODE_REMOTE` is `true` (check with `echo "$CLAUDE_CODE_REMOTE"`). There, `push-ok` is `cloud`, and the branch is pushed at every commit.
- **Find an existing run first.** A run may have been started on another device, so its branch can exist only on the remote.
  - Run `git fetch --quiet` when there is a remote, then list `git branch -a --list '*shipyard/*'`.
  - Look for a `state.md` whose `stage` is not `done`: on the current branch, on each `shipyard/*` branch (local or `origin/`; read it with `git show <branch>:<path>`), under `docs/shipyard/*/` and under `openspec/changes/*/`.
- **Decide whether the message answers that run.** Continue a run only when exactly one is open and the text after `/shipyard` reads as a reply to it: an answer to its open question, an approval, or a change to its proposal. If the text reads as a new request, or more than one run is open, ask the owner which they mean (continue which run, or start a new one) and stop.
- **Continuing:** check out the run's branch (`git checkout shipyard/<slug>` also picks up a remote-only branch). Read `state.md`, `scout.md`, `approval.md` and `tasks.md`, then go to the stage named in `stage`.
- **Check approval against the tree on every resume.** If `approved:` is empty but there are changes outside the run's folder (`git status`, and `git diff <base>...HEAD`), stop, unless `scope-changes:` explains them (a re-approval after a scope change). Tell the owner what changed and ask what to do: approve the proposal as it stands, or set the changes aside. Setting aside means `git stash push -u -m "shipyard: set aside"` or committing them to a side branch. Never discard work: no `git checkout -- .`, `git reset --hard` or `git clean`. Do not build, and do not approve on their behalf.
- **New run.**
  - Make `<slug>`: kebab-case, at most 5 words, from the request.
  - If the working tree has uncommitted changes, ask the owner first whether to commit them, stash them, or leave them out of the run, and stop.
  - Create the branch `shipyard/<slug>` from the current HEAD and note that commit as `base`.
  - Write `state.md` from the template in `docs/shipyard/<slug>/`, with `stage: research`. That is the run's folder, unless the project has a change process of its own. For OpenSpec, the propose step creates `openspec/changes/<slug>/` (it refuses a folder that already exists), and the run's files then move there (stage 3).

## 1. Research

Dispatch `scout` with the request. Save its report as `scout.md` in the run's folder: its `## Project rules` go to every later agent. Set `stage: questions`.

## 2. Questions

Sort the scout's `## Unclear` items, and anything you see yourself: ask the ones whose wrong guess would change what the owner gets; settle the rest yourself and pass them to the planner as decisions to list. When nothing needs asking, skip straight to stage 3 in the same turn. Always ask how to run tests when the scout found no stated test command. Record each open question under `open-questions:` in `state.md`, then ask and stop. Write each answer under `answers:` in `state.md` as it comes back. When the answers come back, ask any follow-ups they raise. Move on only when nothing that matters is unclear. Set `stage: proposal`.

## 3. Proposal

- If the project has a process of its own (the scout's `## Project rules`), run its propose step yourself. For OpenSpec, use `/opsx:propose <slug>` through the Skill tool, or the `openspec` CLI. Then `git mv` the run's files from `docs/shipyard/<slug>/` into the new change folder, and update `folder:` in `state.md`.
- Dispatch `planner` with: the request, the scout report, the owner's answers, the run's folder, whether the project has its own process, and the path to `approval-template.md`.
- If the planner reports `## Unclear` items, go back to stage 2.
- Read `approval.md` yourself. It must have all eight sections in order (What changes, Picture, How it fits, Crew workflow, Files, Acceptance criteria, Risks, Decisions made) and at least two `mermaid` blocks. Send any gap back to the planner.
- Set `stage: awaiting-approval` and commit: `shipyard: proposal for <slug>`.

## 4. Approval

- Give the owner the path to `approval.md` and a 3-line summary. When you can publish an artifact, offer `approval.md` as a page.
- Locally (`push-ok: no`), ask once whether to push the branch so `approval.md` can be read on GitHub's mobile app. Record the answer as `push-ok: yes` or `no`, and push if yes.
- Ask the owner, with `AskUserQuestion`: approve as it stands, or change something. Then stop and wait.
- **Only a plain approval counts:** "approved", "approve", "yes, build it", "go ahead". Any approval with a change attached ("looks good, but…", "yes, and also…") is a change request:
  - send the change to the planner as a revision
  - leave `approved:` empty
  - commit the revised `approval.md`
  - show the owner what changed, and ask again
- On a plain approval: write `approved: <date> — <one-line summary of what was approved>`. Set `stage: build`, commit, and push if `push-ok` is `yes` or `cloud`.

## 5. Build

- **Hard check first:** `approved:` is filled in. If it is empty, go to stage 4.
- Split the tasks in `tasks.md` into areas whose files do not overlap. Give each builder: the run's folder, its task numbers, its owned files, and the project rules. Builders do not edit `tasks.md`: tick each task yourself from the builders' `## Done` reports.
- One area means one builder. Several areas mean builders dispatched in parallel, in one message.
- When a builder reports `## Blocked`, ask the owner, then dispatch it again with the answer. A file it needs that another builder owns waits until that builder is done.
- **A scope change** (a goal, screen or database change that is not in `approval.md`): have the planner update `approval.md`, record it under `scope-changes:`, empty `approved:`, and go to stage 4. Smaller adjustments are noted for the final summary.
- Commit: `shipyard: build for <slug>`. Set `stage: test`.

## 6. Test

- Dispatch `tester` with: the run's folder, the project's test commands and test-data rules, and the files the builders changed.
- When it reports `## Could not fix`, send that failure to the builder that owns the file, once, and test again. If it still fails, ask the owner.
- Commit: `shipyard: tests for <slug>`. Set `stage: review`.

## 7. Review

- Dispatch `reviewer` with: the run's folder, `base`, and the project rules.
- `critical` problems go back to the owning builders, then to the tester again. After 2 rounds, ask the owner.
- `## Scope changes` go to stage 4, as in stage 5.
- Warnings you leave are listed in the final summary.
- Commit: `shipyard: review fixes for <slug>`. Set `stage: finish`.

## 8. Finish

1. Run the project's closing steps from its rules, for example a version bump or ticking `tasks.md`.
2. Check that nothing the run made for testing is left behind (test users, test data, temporary files, extra branches), as the project's rules define it.
3. Set `stage: done` and commit: `shipyard: finish <slug>`.
4. Only now archive the change if the project's process does (for OpenSpec, `/opsx:archive`). The run's files move with it, and nothing is written to the old folder afterwards. Commit the archive.
5. Push the branch if `push-ok` is `yes` or `cloud`. If it is `no`, ask once more now; finished means pushed.
6. Reply with:
   - the branch, and whether it is pushed
   - what was built
   - the test command and its result
   - smaller changes made after approval
   - anything skipped, and why

The owner opens the pull request. Shipyard never merges.
