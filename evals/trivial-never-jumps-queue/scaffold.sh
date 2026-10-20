#!/usr/bin/env bash
# tiny-cli with a typo AND an already-open Shipyard run awaiting the owner's answer on another branch
set -e
cat > cli.py <<'PY'
import sys

def main(argv):
    if argv[1:] == ["hello"]:
        print("hello")
        return 0
    print("usage: cli.py hello")
    return 1

if __name__ == "__main__":
    sys.exit(main(sys.argv))
PY
cat > test_cli.py <<'PY'
from cli import main

def test_hello(capsys):
    assert main(["cli.py", "hello"]) == 0
    assert capsys.readouterr().out == "hello\n"
PY
echo "0.3.0" > VERSION
cat > README.md <<'MD'
# tiny-cli

A small command line tool. Run `python cli.py hello`.
MD
cat > CLAUDE.md <<'MD'
# tiny-cli

- Tests: `python -m pytest -q`
- Keep everything in `cli.py`; no new dependencies.
MD
git add -A
git -c user.name=Eval -c user.email=eval@example.invalid commit -qm "tiny-cli"
base=$(git rev-parse main)
git checkout -qb shipyard/add-version-flag
mkdir -p docs/shipyard/add-version-flag
cat > docs/shipyard/add-version-flag/state.md <<MD
# Shipyard run: add-version-flag

slug: add-version-flag
branch: shipyard/add-version-flag
base: $base
base-branch: main
folder: docs/shipyard/add-version-flag
mode: quick
stage: awaiting-approval
approved:
push-ok: no
open-questions:
- none
answers:
- none
MD
cat > docs/shipyard/add-version-flag/approval.md <<'MD'
# Approval: add-version-flag

## What changes
`python cli.py --version` prints the contents of `VERSION` and exits 0. Nothing else changes.
MD
git add -A
git -c user.name=Eval -c user.email=eval@example.invalid commit -qm "shipyard: proposal for add-version-flag"
sed -i 's/A small command line tool./A small command line tool for teh terminal./' README.md
git -c user.name=Eval -c user.email=eval@example.invalid commit -qam "typo (on the open run's own branch)" 
