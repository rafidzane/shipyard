---
description: Show how well Shipyard's forecasts, sizing and challenges have held up in this project.
allowed-tools: Bash(cat:*), Bash(test:*), Bash(tail:*), Bash(grep:*)
---

Scorecard: !`test -f docs/shipyard/memory/scorecard.md && cat docs/shipyard/memory/scorecard.md || echo "none"`

Incidents: !`test -f docs/shipyard/memory/incidents.md && tail -n 20 docs/shipyard/memory/incidents.md || echo "none"`

Read-only: change nothing. When the scorecard is `none`, reply that this project has no Shipyard scorecard yet: it starts with the first run that finishes, and its numbers show after five runs.

Otherwise reply with, in plain words:
- the three numbers (forecast hit rate, sizing matched, challenge yield) as the scorecard states them, or "not enough runs yet"
- the last five runs, one line each: name, mode, and what was missed in the run and after merge
- the incidents added in the last 30 days, one line each with its ID
