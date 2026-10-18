# Shipyard

A Claude Code plugin that turns a plain-words request into a pushed branch. A small crew of agents does the work; you make the decisions.

- It **asks instead of guessing** whenever a wrong guess would change what gets built.
- It writes **`approval.md`** (a wireframe, a diagram of the parts involved and the crew's workflow) and builds nothing until you approve it.
- It **follows your project's own rules** from `CLAUDE.md` / `AGENTS.md`: its process, test commands, version bumps, test-data rules.
- It **finishes on a pushed branch**, `shipyard/<slug>`. You open the pull request; Shipyard never merges.

## The run

```mermaid
flowchart TD
  R[/shipyard request/] --> S[Scout: map the code the change touches]
  S --> Q{Anything unclear?}
  Q -- yes --> A[Ask the owner] --> Q
  Q -- no --> P[Planner: proposal + approval.md, in the project's format]
  P --> G{Owner approves?}
  G -- changes --> P
  G -- yes --> B[Builders in parallel, one per area, owning disjoint files]
  B --> T[Tester: write and run tests]
  T --> V[Reviewer: check the result against the proposal]
  V -- problems --> B
  V -- clean --> F[Finish: the project's closing steps, a summary to the owner]
  B -. unclear .-> A
  T -. can't fix .-> A
```

## Install (terminal, desktop, remote control)

```
/plugin marketplace add rafidzane/shipyard
/plugin install shipyard@shipyard
```

## Use

```
/shipyard add a discount field to the checkout
```

The run's state lives in the repo (`state.md` and `tasks.md` next to the proposal), so you can start on your laptop and carry on from a cloud session or your phone.

## Cloud sessions (web and mobile)

Cloud sessions don't load installed plugins. See below for how to make Shipyard available there.

_To be filled in once the cloud route is proven._
