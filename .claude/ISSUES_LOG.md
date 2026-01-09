# Claude Code Issues Log

> **Purpose:** Track confusions, workarounds, and feature gaps
> **Created:** 2026-01-01

---

## Issue Template

```markdown
### [ISSUE-N] Title
- **Date:** YYYY-MM-DD
- **Cause:** Why it happened
- **Workaround:** How to handle it
- **Status:** Open | Resolved | Won't Fix
```

---

## Issues

### [ISSUE-1] Plan file uses random names, no project link
- **Date:** 2026-01-01
- **Cause:** Claude Code generates `~/.claude/plans/[random-name].md` when entering plan mode. No way to control naming or auto-link to project.
- **Workaround:**
  1. Use `PLAN.md` in project to manually reference the plan file path
  2. Update `PLAN.md` when plan file changes
  3. Note: Plan file path shown in CC output after exiting plan mode
- **Status:** Open (CC limitation)

---

### [ISSUE-2] Session dumps not automatic
- **Date:** 2026-01-01
- **Cause:** Claude Code saves sessions but doesn't export conversation text to files.
- **Workaround:**
  1. Use Warm-Up Protocol to manually dump to `10_Thought_Process/`
  2. Can use `/resume` to access old sessions within CC
  3. Consider hook to auto-export (future)
- **Status:** Open (governance gap)

---

### [ISSUE-3] Context window vs usage limits confusion
- **Date:** 2026-01-01
- **Cause:** Two different limits look similar in UI
- **Workaround:**
  - Context (tokens) = per-conversation, autocompacts
  - Usage (5 hours) = API rate limit, time-based
- **Status:** Resolved (documentation)

---

### [ISSUE-4] CLAUDE.md in ~/Desktop/DataStoragePlan still loaded
- **Date:** 2026-01-01
- **Cause:** After renaming to Governance/, the old path still appears in `/context` output
- **Workaround:**
  1. CC caches CLAUDE.md locations
  2. Restart CC or use `/memory` to verify
- **Status:** Investigating

---

## Feature Requests

| ID | Feature | Priority | Notes |
|----|---------|----------|-------|
| FR-1 | Named plan files | Medium | `--plan-name` flag |
| FR-2 | Auto session dump | High | Hook on session end |
| FR-3 | CONTEXT.md auto-read | Low | Already possible via rules |

---

## Resolved Issues Archive

(Move resolved issues here after 30 days)
