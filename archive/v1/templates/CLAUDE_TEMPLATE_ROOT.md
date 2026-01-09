<!-- ════════════════════════════════════════════════════════════════════════════
     PROTECTED STRUCTURE - DO NOT MODIFY FORMAT
     Template: ~/Desktop/Governance/templates/CLAUDE_TEMPLATE_ROOT.md
     Type: root

     Rules:
     - Keep ALL section headers (mark N/A if not relevant)
     - Don't add new top-level sections (use Reminders for extras)
     - Edit CONTENT within sections only
════════════════════════════════════════════════════════════════════════════ -->

# [Folder Name]

> **Type:** ROOT - Multi-project index (wrapper repo)

## Overview

[Brief description of what this folder contains]

## Governance Structure (Option C - Symlinks)

```
[Product]/                         ← WRAPPER REPO (private)
├── .git/
├── .gitignore                     ← Ignores code/ inner repos
├── CLAUDE.md                      ← This file (ROOT type)
│
├── _governance/                   ← ALL governance files (tracked in wrapper)
│   ├── [project1]/
│   │   ├── CLAUDE.md
│   │   ├── CONTEXT.md
│   │   ├── SESSION_LOG.md
│   │   ├── PLAN.md
│   │   ├── plans/ → symlink
│   │   └── Conversations/
│   └── [project2]/
│       └── [same structure]
│
├── [project1]/                    ← INNER REPO (shareable)
│   ├── .git/
│   ├── .gitignore                 ← Ignores symlinks
│   ├── CLAUDE.md → symlink        ← Claude sees these
│   ├── CONTEXT.md → symlink
│   ├── SESSION_LOG.md → symlink
│   └── src/
│
└── _Archaeology/                  ← Auto-generated code docs
```

## General Rules (Apply to ALL sub-projects)

1. **Output format:** Never output full files/plans/documents. Show changes only: `+ added` / `- removed`
2. **Token efficiency:** Summarize, don't dump. Reference `file:line` instead of quoting blocks.
3. **Read before edit:** Always read files before modifying.
4. **Confirm current date** at the start of the session.
5. **Table formatting:** Always align columns with padding for readability.
6. **Table of contents:** All documents must have TOC with line numbers (e.g., `:42`).
7. **Read CONTEXT.md** at session start for current state and blockers.
8. **Plan File Sync:** Update plan file with `[x]` as tasks complete. Plan file = source of truth.
9. **Warm-Up Protocol:** On phase/task completion OR after 1 hour, update CONTEXT.md, SESSION_LOG.md, and plan file.

## Project Index

| Project | Type | Governance | Purpose |
|---------|------|------------|---------|
| `[folder]/` | [CODE/BIZZ] | `_governance/[folder]/` | [Description] |

## Boundaries

| Session | CAN modify | CANNOT modify |
|---------|------------|---------------|
| [Project1] | `[folder1]/**`, `_governance/[folder1]/**` | `[folder2]/**` |

## Parallel Sessions

| Session 1 | Session 2 | Safe? |
|-----------|-----------|-------|
| [Project1] | [Project2] | Yes |
| Same files | Same files | No |

## Key Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | This file - wrapper rules |
| `_governance/[project]/CLAUDE.md` | Project rules |
| `_governance/[project]/CONTEXT.md` | Current state, blockers |
| `_Archaeology/` | Auto-generated code docs |

## Reminders

- Check child project's CONTEXT.md before starting work
- Governance files are symlinked from `_governance/`
- Inner repos (.git in code/) are shareable with contractors
- [Add project-specific reminders]

---
*Template: ~/Desktop/Governance/templates/CLAUDE_TEMPLATE_ROOT.md*
