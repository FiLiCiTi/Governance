<!-- ════════════════════════════════════════════════════════════════════════════
     PROTECTED STRUCTURE - DO NOT MODIFY FORMAT
     Template: ~/Desktop/Governance/templates/CLAUDE_TEMPLATE_CODE.md
     Type: code

     Rules:
     - Keep ALL section headers (mark N/A if not relevant)
     - Don't add new top-level sections (use Special Rules)
     - Edit CONTENT within sections only
════════════════════════════════════════════════════════════════════════════ -->

# [Project Name]

> **Parent:** `../CLAUDE.md`
> **Type:** CODE - Technical codebase

## Overview

[Brief description of the project]

## Boundaries

- **CAN modify:** `[paths]`
- **CANNOT modify:** `[paths]`
- **Read-only:** `[paths]`

## General Rules

1. **Output format:** Never output full files/plans/documents. Show changes only: `+ added` / `- removed`
2. **Token efficiency:** Summarize, don't dump. Reference `file:line` instead of quoting blocks.
3. **Read before edit:** Always read files before modifying.
4. **Confirm current date** at the start of the session.
5. **Table formatting:** Always align columns with padding for readability.
6. **Table of contents:** All documents must have TOC with line numbers (e.g., `:42`).
7. **Read CONTEXT.md** at session start for current state, blockers, and next steps.
8. **Plan File Sync:** Update plan file with `[x]` as tasks complete. Plan file = source of truth.
9. **Warm-Up Protocol:** On phase/task completion OR after 1 hour, update CONTEXT.md, SESSION_LOG.md, and plan file.

## Workflow

```
1. Discuss     → Conversations/YYYYMMDD_session.md (full conversation dump)
2. Plan        → plans/ + PLAN.md (plans/ symlinks to ~/.claude/plans/[project]/)
3. Document    → SESSION_LOG.md (decisions with #IDs)
4. Execute     → Implementation
5. Results     → SESSION_LOG.md + PLAN.md + CONTEXT.md
```

## Folder Structure (Symlink Governance)

```
[project]/                         ← INNER REPO (shareable with contractors)
├── .git/
├── .gitignore                     ← Ignores governance symlinks
│
├── CLAUDE.md → symlink            ← Points to ../_governance/[project]/CLAUDE.md
├── CONTEXT.md → symlink           ← Current state, blockers, next steps
├── SESSION_LOG.md → symlink
├── PLAN.md → symlink
├── plans/ → symlink               ← Points to ~/.claude/plans/[project]/
├── Conversations/ → symlink  ← Full conversation dumps
│
├── src/                           ← ACTUAL CODE (tracked in this repo)
├── tests/
└── README.md                      ← Public documentation
```

**Note:** Governance files are symlinked from `../_governance/[project]/` (tracked in wrapper repo).
Contractors cloning this repo get pure source code only.

## Git Commit Format

```bash
# Format: type(scope): description
# Types: feat, fix, docs, refactor, test, chore

# Examples:
git commit -m "feat(auth): add OAuth2 login"
git commit -m "docs(readme): update setup instructions"
git commit -m "fix(api): handle timeout errors"
```

## Decision IDs

Track decisions with prefixed IDs in SESSION_LOG.md:

| Prefix | Category | Example |
|--------|----------|---------|
| `#A` | Architecture | `#A1` - Use WebSocket for real-time |
| `#C` | Case/behavior | `#C1` - Retry failed requests 3 times |
| `#D` | Data | `#D1` - Store timestamps as Unix INT |
| `#M` | Memory/state | `#M1` - Cache user sessions in Redis |
| `#T` | Testing | `#T1` - Unit tests for all services |

## Feature Sizing

| Size | Scope |
|------|-------|
| XS | Config, UI tweak |
| S | New screen/endpoint |
| M | Feature with complexity |
| L | Major feature, new models |

*Details in project-specific docs.*

## Key Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | This file - project rules (symlink) |
| `CONTEXT.md` | Current state, blockers, next steps (symlink) |
| `SESSION_LOG.md` | Session history, decisions (symlink) |
| `PLAN.md` | Current plan (symlink) |
| `plans/` | Claude plans (symlink to ~/.claude/plans/) |
| `Conversations/` | Full conversation dumps (symlink) |
| `[main entry]` | [Description] |

## Environment

```bash
# Setup
[setup commands]

# Run
[run commands]

# Test
[test commands]
```

## Repository Structure

N/A - Single repo, standard git workflow.

*Or if multi-repo:*
<!--
| Clone | Branch | Purpose | origin | upstream |
|-------|--------|---------|--------|----------|
| `repo/` | main | Production | origin | - |
-->

## Database Notes

N/A - No database.

*Or if has database:*
<!--
- `[table]` - [description]
- `[field]` ENUM: `('val1', 'val2')`
-->

## Special Rules

[Add project-specific rules here, or leave empty]

## Reminders

- Use TodoWrite for multi-step tasks
- [Add project-specific reminders]

---
*Template: ~/Desktop/Governance/templates/CLAUDE_TEMPLATE_CODE.md*
