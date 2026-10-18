#!/usr/bin/env bash
# Guards the orchestrator rules that no eval reaches yet (build and finish stages). Text checks only.
# Usage: tests/check-skill.sh [dir]   (dir defaults to the repo root)
root=${1:-$(dirname "$0")/..}
skill="$root/skills/shipyard/SKILL.md"; builder="$root/agents/builder.md"; state="$root/skills/shipyard/state-template.md"
fail=0
has() { if grep -qF -- "$3" "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }
has "I3 scout report saved in the repo" "$skill" 'Save its report as `scout.md`'
has "I3 answers saved in state.md" "$state" 'answers:'
has "I4 builders leave tasks.md alone" "$builder" 'Do not edit `tasks.md`'
has "I4 orchestrator ticks tasks" "$skill" 'tick each task yourself'
has "I5 setting aside never discards" "$skill" 'Never discard work'
has "I5 scope changes skip the warning" "$skill" 'unless `scope-changes:` explains them'
has "I6 stage by path, never add -A" "$skill" 'Never `git add -A`'
has "I6 dirty tree asked about first" "$skill" 'If the working tree has uncommitted changes'
has "I1 push after every commit" "$skill" 'Push after every commit'
has "I9 state starts outside openspec" "$skill" 'it refuses a folder that already exists'
has "I9 archive only after done" "$skill" 'Only now archive the change'
exit $fail
