#!/usr/bin/env bash
# Checks scripts/cloud-bootstrap.sh against a fake `claude` that logs its arguments.
cd "$(dirname "$0")/.." || exit 1
script="$PWD/scripts/cloud-bootstrap.sh"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/claude" <<'SH'
#!/usr/bin/env bash
echo "$*" >> "$CALLS"
exit "${FAKE_EXIT:-0}"
SH
chmod +x "$tmp/claude"
export PATH="$tmp:$PATH" CALLS="$tmp/calls"
fail=0
check() { if [ "$2" = "$3" ]; then echo "ok   $1"; else echo "FAIL $1: expected [$3], got [$2]"; fail=1; fi; }
run() { rm -f "$CALLS"; touch "$CALLS"; bash "$script" 2>/dev/null; code=$?; calls=$(paste -sd '|' "$CALLS"); }

unset CLAUDE_CODE_REMOTE
run; check "laptop: no calls" "$calls" ""; check "laptop: exit 0" "$code" "0"

export CLAUDE_CODE_REMOTE=true
expected="plugin marketplace add rafidzane/shipyard|plugin install shipyard@shipyard --scope project"
run; check "cloud: both calls in order" "$calls" "$expected"; check "cloud: exit 0" "$code" "0"
run; check "cloud, second run: exit 0" "$code" "0"

FAKE_EXIT=1 run; check "claude fails: still exit 0" "$code" "0"

exit $fail
