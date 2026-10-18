#!/usr/bin/env bash
# Each agent's frontmatter names itself, lists its tools, and the read-only ones cannot write.
cd "$(dirname "$0")/.." || exit 1
fail=()
field() { awk -v k="$2" 'NR==1&&$0!="---"{exit} NR>1&&$0=="---"{exit} index($0,k": ")==1{sub(k": ",""); print}' "$1"; }
for a in scout planner builder tester reviewer; do
  f="agents/$a.md"
  [[ -f $f ]] || { fail+=("$f: missing"); continue; }
  [[ $(field "$f" name) == "$a" ]] || fail+=("$f: name is not $a")
  tools=$(field "$f" tools)
  [[ -n $tools ]] || fail+=("$f: no tools")
  if [[ $a == scout || $a == reviewer ]] && grep -qwE 'Write|Edit' <<<"$tools"; then fail+=("$f: read-only agent has Write/Edit"); fi
done
((${#fail[@]})) && { printf 'FAIL %s\n' "${fail[@]}"; exit 1; }
echo "PASS: 5 agents"
