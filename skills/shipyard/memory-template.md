# Project memory

Shipyard keeps three files in `docs/shipyard/memory/` in the project, committed with each run. Every run reads them first and adds to them at the finish. The owner may edit or delete any entry.

## The files

| File | Holds |
|---|---|
| `decisions.md` | Choices the owner made or approved that a future run should not reopen |
| `incidents.md` | What went wrong, its cause, and the guard against it |
| `patterns.md` | How this project does things, learned from runs and the owner's corrections |

Each file starts with its heading (`# Decisions`, `# Incidents`, `# Patterns`) and this line: `Written by Shipyard at the end of each run. Edit or delete freely: an entry you changed is never rewritten.` Then one entry per line.

## One entry

```markdown
- D-007 2026-10-18 (run share-timeout-password-savings): sign-out after 15 minutes idle on every device, enforced on the server. Why: the owner's answer. Supersedes: none
- I-003 2026-10-18 (run idle-signout-message): the idle sign-out lost its message: 401s from refetches redirected first. Cause: apiFetch's own 401 redirect. Guard: markSigningOut(). Files: frontend/src/lib/api.ts, frontend/src/components/idle-signout.tsx
- P-012 2026-10-18 (seen 3 runs, last idle-signout-message): phone-only styles use the max-md: variant, the bottom bar's breakpoint
```

- **ID:** `D-`, `I-` or `P-` and a number, never reused. Take the highest number of that letter on HEAD and on every local and `origin/` `shipyard/*` branch, and add one, as for change numbers.
- **Date and run:** the day the entry was written, and the run's slug.
- **Decision:** what was decided, then `Why:` and `Supersedes:` (an earlier ID, or `none`).
- **Incident:** what went wrong, `Cause:`, `Guard:` (what now prevents it), and `Files:`.
- **Pattern:** the convention, with `seen N runs` and the last run that followed it.

## Rules

- **Cap:** at most 150 entries a file. Past it, fold the oldest entries on one subject into a single entry that lists the IDs it replaces (`Replaces: I-001, I-004, I-009`). Nothing is dropped without a trace.
- **The owner's edits win:** never rewrite or delete an entry the owner changed by hand (a later commit than the run's touched that line). Supersede it with a new entry that cites its ID.
- **Never goes in:** credentials, tokens, keys or passwords; anything from `secrets.ini`, `.env` or the like; personal data; real people's emails or names (test accounts too); customer names.
