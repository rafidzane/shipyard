#!/usr/bin/env bash
# Runs the cloud SessionStart hook command from README.md against a fake `claude` that logs its arguments.
cd "$(dirname "$0")/.." || exit 1
hook=$(python3 -c "
import json, re
block = re.search(r'\`\`\`json\n(.*?)\`\`\`', open('README.md').read(), re.S).group(1)
print(json.loads(block)['hooks']['SessionStart'][0]['hooks'][0]['command'])")
[ -n "$hook" ] || { echo "FAIL no hook command found in README.md"; exit 1; }
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/claude" <<'SH'
#!/usr/bin/env bash
echo "$*" >> "$CALLS"
exit "${FAKE_EXIT:-0}"
SH
cat > "$tmp/curl" <<'SH'
#!/usr/bin/env bash
echo "curl $*" >> "$CALLS"
SH
chmod +x "$tmp/claude" "$tmp/curl"
export PATH="$tmp:$PATH" CALLS="$tmp/calls"
fail=0
check() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1: expected [$3], got [$2]"; fail=1; fi; }
run() { rm -f "$CALLS"; touch "$CALLS"; bash -c "$hook" 2>/dev/null; code=$?; calls=$(paste -sd '|' "$CALLS"); }

unset CLAUDE_CODE_REMOTE
run; check "laptop: no calls, no download" "$calls" ""; check "laptop: exit 0" "$code" "0"

export CLAUDE_CODE_REMOTE=true
expected="plugin marketplace add rafidzane/shipyard|plugin install shipyard@shipyard --scope user"
run; check "cloud: both calls in order, user scope, no download" "$calls" "$expected"; check "cloud: exit 0" "$code" "0"
run; check "cloud, second run: exit 0" "$code" "0"

FAKE_EXIT=1 run; check "claude fails: still exit 0" "$code" "0"

exit $fail
