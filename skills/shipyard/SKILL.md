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
4. **State lives in the repo.** `state.md` and `tasks.md` in the run's folder are the record. Update `state.md` when the stage changes. A run on any device resumes from them alone.
5. **Commit at the end of every stage** on the run's branch, with messages like `shipyard: <stage> for <slug>`. Never merge to main, never force-push, never delete a branch you did not create.
6. **Scale to the request.** A one-file change is one builder and no parallel step. It still gets a proposal and approval.

Templates beside this file: `state-template.md` and `approval-template.md`.

## Starting or resuming

- Cloud session: the environment variable `CLAUDE_CODE_REMOTE` is `true` (check with `echo "$CLAUDE_CODE_REMOTE"`). There, `push-ok` is `cloud`, and the branch is pushed at every commit.
- **Find an existing run first.** Look for a `state.md` whose `stage` is not `done`: on the current branch if it is `shipyard/<slug>`, else under `docs/shipyard/*/` and `openspec/changes/*/`. If one exists, this message continues it: the text after `/shipyard` is the owner's reply (an answer, an approval, or a change request), not a new request. Read `state.md`, `approval.md` and `tasks.md`, then go to the stage named in `stage`.
- **Check approval against the tree on every resume.** If `approved:` is empty but there are changes outside the run's folder (`git status`, and `git diff <base>...HEAD`), stop. Tell the owner what changed and ask what to do: approve the proposal as it stands, or set the changes aside. Do not build, and do not approve on their behalf.
- **New run.**
  - Make `<slug>`: kebab-case, at most 5 words, from the request.
  - Create the branch `shipyard/<slug>` from the current HEAD and note that commit as `base`.
  - The run's folder is the project's change folder when it has one (for OpenSpec, `openspec/changes/<slug>/`); otherwise `docs/shipyard/<slug>/`.
  - Write `state.md` from the template, with `stage: research`.

## 1. Research

Dispatch `scout` with the request. Keep its report: `## Project rules` is passed to every later agent. Set `stage: questions`.

## 2. Questions

Sort the scout's `## Unclear` items, and anything you see yourself: ask the ones whose wrong guess would change what the owner gets; settle the rest yourself and pass them to the planner as decisions to list. When nothing needs asking, skip straight to stage 3 in the same turn. Always ask how to run tests when the scout found no stated test command. Record each open question under `open-questions:` in `state.md`, then ask and stop. When the answers come back, ask any follow-ups they raise. Move on only when nothing that matters is unclear. Set `stage: proposal`.

## 3. Proposal

- If the project has a process of its own (the scout's `## Project rules`), run its propose step yourself. For OpenSpec, use `/opsx:propose <slug>` through the Skill tool, or the `openspec` CLI.
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
- Split the tasks in `tasks.md` into areas whose files do not overlap. Give each builder: the run's folder, its task numbers, its owned files, and the project rules.
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

1. Run the project's closing steps from its rules: for example a version bump, ticking `tasks.md`, or archiving the change (for OpenSpec, `/opsx:archive`).
2. Check that nothing the run made for testing is left behind (test users, test data, temporary files, extra branches), as the project's rules define it.
3. Set `stage: done` and commit: `shipyard: finish <slug>`.
4. Push the branch if `push-ok` is `yes` or `cloud`. If it is `no`, ask once more now; finished means pushed.
5. Reply with:
   - the branch, and whether it is pushed
   - what was built
   - the test command and its result
   - smaller changes made after approval
   - anything skipped, and why

The owner opens the pull request. Shipyard never merges.
