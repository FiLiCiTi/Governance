<!-- ════════════════════════════════════════════════════════════════════════════
     PROTECTED STRUCTURE - DO NOT MODIFY FORMAT
     Template: ~/Desktop/Governance/templates/CLAUDE_TEMPLATE_OPS.md
     Type: ops

     Rules:
     - Keep ALL section headers (mark N/A if not relevant)
     - Don't add new top-level sections (use Special Rules)
     - Edit CONTENT within sections only
════════════════════════════════════════════════════════════════════════════ -->

# Governance Hub

> **Type:** OPS - Operations/Infrastructure
> **Renamed:** 2026-01-01 (was DataStoragePlan/)

## Overview

Central governance hub for all FILICITI Claude projects, templates, and automation scripts.
Also contains DataStoragePlan subfolder for drive/storage operations.

**Current Status:** Phase 2.7 In Progress - Governance self-update

## Boundaries

- **CAN modify:** This folder (`Governance/`)
- **CANNOT modify:** Actual drives/data without explicit approval
- **Read-only:** Drive contents (for analysis), FILICITI projects (use their CLAUDE.md)

## General Rules

> **Universal rules (1-9) are in `~/.claude/CLAUDE.md` (Layer 3)**
> Below are OPS-specific rules only.

1. **Safety first:** No destructive operations without explicit confirmation.
2. **Logs required:** All drive operations must be logged in `DataStoragePlan/logs/`.

## Workflow

```
1. Discuss     → Conversations/YYYY/MM/YYYYMMDD_session.md (full dump)
2. Plan        → ~/.claude/plans/*.md (track active plan in PLAN.md)
3. Document    → SESSION_LOG.md (decisions with #IDs)
4. Execute     → Implementation
5. Results     → SESSION_LOG.md + PLAN.md + CONTEXT.md
```

See `DAILY_WORKFLOW.md` for detailed session flow.

## Folder Structure

```
Governance/                        ← RENAMED from DataStoragePlan/
├── CLAUDE.md                      # This file
├── CONTEXT.md                     # Current state, blockers, next steps
├── SESSION_LOG.md                 # Session history
├── PLAN.md                        # Current plan (tracks active ~/.claude/plans/*.md)
├── DAILY_WORKFLOW.md              # Session flow documentation
├── Conversations/                 # Full conversation dumps
│   └── YYYY/MM/
│
├── templates/                     # CLAUDE.md templates for all projects
│   ├── CLAUDE_TEMPLATE_ROOT.md
│   ├── CLAUDE_TEMPLATE_CODE.md
│   ├── CLAUDE_TEMPLATE_BIZZ.md
│   └── CLAUDE_TEMPLATE_OPS.md
│
├── registry/                      # Project tracking
│   ├── PROJECT_REGISTRY.md
│   └── AUDIT_LOG.md
│
├── scripts/                       # Automation scripts
│   ├── setup_governance_symlinks.sh
│   ├── setup_plan_symlinks.sh
│   └── create_reference_structure.sh
│
└── DataStoragePlan/               # Drive/storage operations (original content)
    ├── STRATEGY.md                # Master storage strategy
    ├── DRIVES.md                  # Drive inventory
    ├── logs/                      # Operation logs
    └── archive/                   # Past session summaries
```

## Decision IDs

Track decisions with prefixed IDs in SESSION_LOG.md:

| Prefix | Category | Example |
|--------|----------|---------|
| `#I` | Infrastructure | `#I1` - Use Backblaze for backup |
| `#S` | Security | `#S1` - Encrypt all backups |
| `#P` | Process | `#P1` - Weekly backup verification |
| `#B` | Backup | `#B1` - 3-2-1 backup strategy |
| `#G` | Governance | `#G1` - Monthly Claude project audits |

## Key Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | This file - project rules |
| `CONTEXT.md` | Current state, blockers, next steps |
| `SESSION_LOG.md` | Session history, decisions |
| `PLAN.md` | Current plan (tracks active ~/.claude/plans/*.md) |
| `DAILY_WORKFLOW.md` | Session flow documentation |
| `Conversations/` | Full conversation dumps |
| `templates/` | CLAUDE.md templates for all projects |
| `registry/PROJECT_REGISTRY.md` | All Claude projects |
| `registry/AUDIT_LOG.md` | Audit history |
| `scripts/` | Governance and automation scripts |
| `DataStoragePlan/STRATEGY.md` | Master storage strategy |
| `DataStoragePlan/DRIVES.md` | Drive inventory details |

## Environment

```bash
# Setup governance symlinks (after migration)
./scripts/setup_governance_symlinks.sh

# Setup plan symlinks
./scripts/setup_plan_symlinks.sh

# Create reference folder structure
./scripts/create_reference_structure.sh
```

## Drive Quick Reference

See `DataStoragePlan/STRATEGY.md` for full details.

| Drive | Contents | Priority |
|-------|----------|----------|
| HD1 | Memories | HIGH (single copy) |
| HD2 | Cairo-Toyama | HIGH (single copy) |
| HD7 | FiLiCiTi_M2 | BLOCKED (recovery in progress) |

## Claude Governance

### Templates Location
`templates/`
- `CLAUDE_TEMPLATE_ROOT.md` - Multi-project index folders
- `CLAUDE_TEMPLATE_CODE.md` - Technical codebases
- `CLAUDE_TEMPLATE_BIZZ.md` - Business strategy/planning
- `CLAUDE_TEMPLATE_OPS.md` - Operations/infrastructure

### Audit Triggers
| Trigger | Action |
|---------|--------|
| Before starting project | Quick compliance check |
| After completing project | Update registry/AUDIT_LOG.md |
| Monthly | Full audit of all projects |

### Required Files by Type
| Type | CONTEXT.md | SESSION_LOG | PLAN.md | Conversations/ |
|------|------------|-------------|---------|----------------|
| ROOT | No (in children) | No | No | No |
| CODE | Yes (symlink) | Yes (symlink) | Yes (symlink) | Yes (symlink) |
| BIZZ | Yes (symlink) | Yes (symlink) | Yes (symlink) | Yes (symlink) |
| OPS | Yes | Yes | Yes | Yes |

### Plan File Sync & Warm-Up
> See `~/.claude/CLAUDE.md` (Layer 3) for detailed rules.
> See `DAILY_WORKFLOW.md` for session flow.

## Special Rules

- Claude project governance is managed here (Option C - Symlink approach)
- All template changes must be documented in SESSION_LOG.md
- New projects must be added to PROJECT_REGISTRY.md
- Governance files in products live in `_governance/` folder, symlinked to project roots
- Inner repos (shareable with contractors) have symlinks ignored via .gitignore

## Reminders

- Use TodoWrite for multi-step tasks
- Log all operations in `DataStoragePlan/logs/`
- Always verify before destructive actions
- iPhone photos: 3+ years with 0 backups (CRITICAL)
- Backblaze setup pending ($9/mo)
- Run audit before/after working on any Claude project
- **Sync plan file with TodoWrite** (checkbox format)

---
*Template: ~/Desktop/Governance/templates/CLAUDE_TEMPLATE_OPS.md*
