---
description: Show which Shipyard version is installed and loaded in this session.
allowed-tools: Bash(grep:*)
---

Installed Shipyard: !`grep -m1 '"version"' "${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json" | sed -E 's/.*"version": *"([^"]+)".*/\1/'`

Reply with one line: `Shipyard <version>`, using the version above. When it is empty, say the version could not be read and that `claude plugin list` shows it.
