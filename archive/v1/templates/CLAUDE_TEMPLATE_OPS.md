<!-- ════════════════════════════════════════════════════════════════════════════
     PROTECTED STRUCTURE - DO NOT MODIFY FORMAT
     Template: ~/Desktop/Governance/templates/CLAUDE_TEMPLATE_OPS.md
     Type: ops

     Rules:
     - Keep ALL section headers (mark N/A if not relevant)
     - Don't add new top-level sections (use Special Rules)
     - Edit CONTENT within sections only
════════════════════════════════════════════════════════════════════════════ -->

# [Project Name]

> **Parent:** `../CLAUDE.md` (if applicable)
> **Type:** OPS - Operations/Infrastructure

## Overview

[Brief description of the project]

**Current Status:** [Status description]

## Boundaries

- **CAN modify:** `[paths]`
- **CANNOT modify:** `[paths]`
- **Read-only:** `[paths]`

## General Rules

1. **Output format:** Never output full files/plans/documents. Show changes only: `+ added` / `- removed`
2. **Token efficiency:** Summarize, don't dump. Reference `file:line` instead of quoting blocks.
3. **Read before edit:** Always read files before modifying.
4. **Safety first:** No destructive operations without explicit confirmation.
5. **Confirm current date** at the start of the session.
6. **Table formatting:** Always align columns with padding for readability.
7. **Table of contents:** All documents must have TOC with line numbers (e.g., `:42`).
8. **Read CONTEXT.md** at session start for current state, blockers, and next steps.
9. **Plan File Sync:** Update plan file with `[x]` as tasks complete. Plan file = source of truth.
10. **Warm-Up Protocol:** On phase/task completion OR after 1 hour, update CONTEXT.md, SESSION_LOG.md, and plan file.

## Workflow

```
1. Discuss     → Conversations/YYYYMMDD_session.md (full conversation dump)
2. Plan        → plans/ + PLAN.md (plans/ symlinks to ~/.claude/plans/[project]/)
3. Document    → SESSION_LOG.md (decisions with #IDs)
4. Execute     → Implementation
5. Results     → SESSION_LOG.md + PLAN.md + CONTEXT.md
```

## Folder Structure

```
[project]/
├── CLAUDE.md
├── CONTEXT.md             ← Current state, blockers, next steps
├── SESSION_LOG.md
├── PLAN.md
├── plans/ → symlink       ← Points to ~/.claude/plans/[project]/
├── Conversations/    ← Full conversation dumps
│   └── YYYY/MM/
│       └── YYYYMMDD_session.md
├── logs/                  # Operation logs
├── scripts/               # Automation scripts
└── [project-specific]/
```

## Decision IDs

Track decisions with prefixed IDs in SESSION_LOG.md:

| Prefix | Category | Example |
|--------|----------|---------|
| `#I` | Infrastructure | `#I1` - Use Backblaze for backup |
| `#S` | Security | `#S1` - Encrypt all backups |
| `#P` | Process | `#P1` - Weekly backup verification |
| `#B` | Backup | `#B1` - 3-2-1 backup strategy |

## Key Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | This file - project rules |
| `CONTEXT.md` | Current state, blockers, next steps |
| `SESSION_LOG.md` | Session history, decisions |
| `PLAN.md` | Current plan |
| `plans/` | Claude plans (symlink to ~/.claude/plans/) |
| `Conversations/` | Full conversation dumps |
| `[main doc]` | [Description] |

## Environment

```bash
# [Critical commands for this project]
```

## Special Rules

[Add project-specific rules here, or leave empty]

## Reminders

- Use TodoWrite for multi-step tasks
- Log all operations in `logs/`
- Always verify before destructive actions
- [Add project-specific reminders]

---
*Template: ~/Desktop/Governance/templates/CLAUDE_TEMPLATE_OPS.md*
