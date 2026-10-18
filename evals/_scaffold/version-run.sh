#!/usr/bin/env bash
# The files of a Shipyard run "add-version-flag" at the stage given as $1, not approved. Part of the generated scaffolds.
set -e
d=docs/shipyard/add-version-flag
mkdir -p "$d"
base=$(git rev-parse main)
cat > "$d/state.md" <<MD
# Shipyard run: add-version-flag

slug: add-version-flag
branch: shipyard/add-version-flag
base: $base
base-branch: main
folder: $d
stage: $1
approved:
push-ok: no
open-questions:
- none
scope-changes:
- none
MD
cat > "$d/proposal.md" <<'MD'
# Add a --version flag

`python cli.py --version` prints the contents of `VERSION` and exits 0. Nothing else changes.
MD
cat > "$d/tasks.md" <<'MD'
# Tasks

## Area 1: cli
- [ ] 1.1 Handle `--version` in `main` in `cli.py`: print `VERSION`'s contents, stripped, and return 0
- [ ] 1.2 Add `test_version` to `test_cli.py`
MD
cat > "$d/approval.md" <<'MD'
# Approval: add-version-flag

## What changes
`python cli.py --version` prints the version from the `VERSION` file and exits with 0. Every other command behaves as before.

## Picture
```text
$ python cli.py --version
0.3.0
```

## How it fits
```mermaid
flowchart LR
  U[python cli.py --version] --> M[main in cli.py] --> V[(VERSION file)]
```

## Crew workflow
```mermaid
flowchart LR
  B[builder: tasks 1.1-1.2, cli.py and test_cli.py] --> T[tester] --> R[reviewer]
```

## Files
- `cli.py`: handle `--version`
- `test_cli.py`: a test for it

## Acceptance criteria
- [ ] `python cli.py --version` prints `0.3.0` and exits 0
- [ ] `python cli.py hello` still prints `hello`

## Risks
- None worth noting.

## Decisions made
- Owner: only `--version`; nothing else changes.
- Planner: the version is read from `VERSION` each time, not stored in code.
MD
