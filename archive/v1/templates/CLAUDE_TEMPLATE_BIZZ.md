<!-- ════════════════════════════════════════════════════════════════════════════
     PROTECTED STRUCTURE - DO NOT MODIFY FORMAT
     Template: ~/Desktop/Governance/templates/CLAUDE_TEMPLATE_BIZZ.md
     Type: bizz

     Rules:
     - Keep ALL section headers (mark N/A if not relevant)
     - Don't add new top-level sections (use Special Rules)
     - Edit CONTENT within sections only
════════════════════════════════════════════════════════════════════════════ -->

# [Project Name]

> **Parent:** `../CLAUDE.md`
> **Type:** BIZZ - Business strategy/planning

## Overview

[Brief description of the project]

**Current Phase:** [Phase description]

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
[project]/                         ← Part of wrapper repo
│
├── CLAUDE.md → symlink            ← Points to ../_governance/[project]/CLAUDE.md
├── CONTEXT.md → symlink           ← Current state, blockers, next steps
├── SESSION_LOG.md → symlink
├── PLAN.md → symlink
├── plans/ → symlink               ← Points to ~/.claude/plans/[project]/
├── Conversations/ → symlink  ← Full conversation dumps
│
├── 01_Strategy/           # Vision, decisions, execution plan
├── 02_Research/           # Personas, market research
├── 03_Awareness/          # Content, campaigns, events
├── 04_Convert/            # Pricing, selection, onboarding
├── 05_Deliver/            # Client profiles, delivery
├── 06_Operations/         # Tools, processes
├── 07_Grow/               # Testimonials, referrals
├── 08_Templates/          # Reusable templates
├── 09_Meeting_Notes/      # YYYYMMDD_type_title.md
└── Archive/
```

**Note:** Governance files are symlinked from `../_governance/[project]/` (tracked in wrapper repo).

## Git Commit Format

```bash
# Format: type(scope): description
# Types: feat, fix, docs, refactor, chore

# Examples:
git commit -m "docs(strategy): update pricing matrix"
git commit -m "feat(events): add webinar playbook"
```

## Decision IDs

Track decisions with prefixed IDs in SESSION_LOG.md:

| Prefix | Category | Example |
|--------|----------|---------|
| `#S` | Strategy | `#S1` - Focus on coaches first |
| `#P` | Pricing | `#P1` - Tiered pricing model |
| `#M` | Marketing | `#M1` - LinkedIn primary channel |
| `#O` | Operations | `#O1` - Use Notion for CRM |
| `#C` | Customer | `#C1` - Target solo practitioners |

## Document Boundaries

| Folder | Contains | Does NOT Contain |
|--------|----------|------------------|
| 01_Strategy | Decisions, vision, execution plan | Event-specific details |
| 02_Research | Personas, market research | Strategy decisions |
| 03_Awareness | Content, campaigns, events | Pricing, selection criteria |
| 04_Convert | Pricing, selection, onboarding | Event content |
| 09_Meeting_Notes | Factual meeting records | Analysis, decisions |
| Conversations | Discussion dumps, reasoning | Final decisions (go to SESSION_LOG) |

## Naming Conventions

| Type | Format | Example |
|------|--------|---------|
| Playbook (evergreen) | `Name_Playbook.md` | `Seminar_Playbook.md` |
| Event/Runbook (specific) | `YYYYMMDD_Name.md` | `20250205_Webinar.md` |
| Meeting notes | `YYYYMMDD_type_title.md` | `20251230_meeting_client.md` |
| Thought process | `YYYYMMDD_session.md` | `20251231_session.md` |

## Key Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | This file - project rules (symlink) |
| `CONTEXT.md` | Current state, blockers, next steps (symlink) |
| `SESSION_LOG.md` | Session history, decisions (symlink) |
| `PLAN.md` | Current plan (symlink) |
| `plans/` | Claude plans (symlink to ~/.claude/plans/) |
| `Conversations/` | Full conversation dumps (symlink) |
| `01_Strategy/MASTER_STRATEGY.md` | Central strategy (if exists) |

## Special Rules

[Add project-specific rules here, or leave empty]

## Reminders

- Use TodoWrite for multi-step tasks
- Playbooks = generic (no date prefix), Events = specific (date prefix)
- Meeting notes go in `09_Meeting_Notes/`
- [Add project-specific reminders]

---
*Template: ~/Desktop/Governance/templates/CLAUDE_TEMPLATE_BIZZ.md*
