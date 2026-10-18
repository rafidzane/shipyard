#!/usr/bin/env bash
# Installs Shipyard when a Claude Code cloud session starts; does nothing anywhere else.
# Run from a project's .claude/settings.json SessionStart hook (see the README). Never fails the session.
[ "$CLAUDE_CODE_REMOTE" = "true" ] || exit 0
claude plugin marketplace add rafidzane/shipyard >&2 || echo "shipyard: marketplace add failed" >&2
claude plugin install shipyard@shipyard --scope project >&2 || echo "shipyard: install failed" >&2
exit 0
