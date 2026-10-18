#!/usr/bin/env bash
# A bare JavaScript project: no CLAUDE.md, no package.json, no tests.
set -e
cat > index.js <<'JS'
function add(a, b) {
  return a + b;
}

module.exports = { add };
JS
git add -A
git -c user.name=Eval -c user.email=eval@example.invalid commit -qm "add"
