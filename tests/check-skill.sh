#!/usr/bin/env bash
# Guards the orchestrator rules that no eval reaches yet (build and finish stages). Text checks only.
# Usage: tests/check-skill.sh [dir]   (dir defaults to the repo root)
root=${1:-$(dirname "$0")/..}
skill="$root/skills/shipyard/SKILL.md"; builder="$root/agents/builder.md"; state="$root/skills/shipyard/state-template.md"
fail=0
has() { if grep -qF -- "$3" "$2"; then echo "ok   $1"; else echo "FAIL $1"; fail=1; fi; }
has "I3 scout report saved in the repo" "$skill" 'as `scout.md` in the run'
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
has "0.1.1 base branch recorded" "$state" 'base-branch:'
has "0.1.1 finish asks to merge and push" "$skill" 'Merge and push'
has "0.1.1 merge stops on conflict" "$skill" 'On a conflict'
has "0.1.1 numbered OpenSpec names" "$skill" 'rejects a name that starts with a digit'
has "0.1.1 ignored change folder force-added" "$skill" 'git add -f'
has "0.1.1 another session in the checkout" "$skill" 'not made by the crew'
has "0.1.1 closing steps stay with the orchestrator" "$root/agents/planner.md" 'closing steps'
has "0.2.0 mode recorded in state" "$state" 'mode:'
has "0.2.0 quick prefix" "$skill" '`quick:`'
has "0.2.0 deep prefix" "$skill" '`deep:`'
has "0.2.0 project default in CLAUDE.md" "$skill" 'Shipyard mode:'
has "0.2.0 mode suggested at approval" "$skill" 'Suggest a mode'
has "0.2.0 same safety rules in every mode" "$skill" 'Every mode keeps'
has "0.2.0 names the mode when stopping" "$skill" 'Name the run'\''s mode'
has "0.2.0 merge-to recorded" "$state" 'merge-to:'
has "0.2.0 test result recorded" "$state" 'tests:'
has "0.2.0 review result recorded" "$state" 'review:'
has "0.2.0 merge when clean" "$skill" 'merge when clean'
has "0.2.0 not clean falls back to asking" "$skill" 'say why it is not clean'
has "0.3.0 scout starts from the knowledge graph" "$root/agents/scout.md" 'graphify query'
has "0.3.0 graph updated at the finish" "$skill" 'run `graphify update .`'
has "0.3.0 design skills for screen work" "$skill" 'Use the design skills for screen work'
has "0.3.0 builder loads the design skills" "$builder" 'frontend-design:frontend-design'
has "0.3.0 builder may use the Skill tool" "$builder" 'tools: Read, Grep, Glob, Write, Edit, Bash, Skill'
has "0.3.0 reviewer checks screens" "$root/agents/reviewer.md" 'check each changed screen'
exit $fail
