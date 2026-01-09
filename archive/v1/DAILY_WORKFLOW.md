# Daily Workflow

> **Source:** Extracted from REVISE.md:736-866
> **Updated:** 2026-01-02

---

## DAY START

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. OPEN TERMINAL                                                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. CHECK COMPANY CONTEXT (optional, if multi-project day)       │
│    cat ~/Desktop/FILICITI/_Governance/CONTEXT.md                │
│    └── See: company priorities, blockers, cross-project issues  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. CD INTO PROJECT                                              │
│    cd ~/Desktop/FILICITI/Products/COEVOLVE/businessplan         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. CLAUDE READS (automatic via CLAUDE.md rules)                 │
│    ├── ~/.claude/CLAUDE.md  → Layer 3 universal rules           │
│    ├── CLAUDE.md            → Layer 4 project rules             │
│    ├── CONTEXT.md           → Current state, blockers           │
│    └── PLAN.md              → Active plan reference             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 5. CONFIRM DATE & BOUNDARIES                                    │
│    Claude: "Today is 2026-01-02. Working on [project].          │
│             Boundaries: CAN modify [paths]                      │
│             Current: [state]. Next: [steps]."                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## DURING SESSION

```
┌─────────────────────────────────────────────────────────────────┐
│ WORK LOOP                                                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐                                           │
│  │ 1. DISCUSS      │──► Conversations/YYYYMMDD_session.md      │
│  │    (explore)    │    (append full conversation)             │
│  └────────┬────────┘                                           │
│           │                                                     │
│           ▼                                                     │
│  ┌─────────────────┐                                           │
│  │ 2. PLAN         │──► ~/.claude/plans/*.md                   │
│  │    (if needed)  │    + update PLAN.md with active plan name │
│  └────────┬────────┘                                           │
│           │                                                     │
│           ▼                                                     │
│  ┌─────────────────┐                                           │
│  │ 3. DECIDE       │──► SESSION_LOG.md (with #ID)              │
│  │                 │    + update CONTEXT.md                     │
│  └────────┬────────┘                                           │
│           │                                                     │
│           ▼                                                     │
│  ┌─────────────────┐                                           │
│  │ 4. EXECUTE      │──► Code/docs changes                      │
│  │                 │                                            │
│  └────────┬────────┘                                           │
│           │                                                     │
│           ▼                                                     │
│  ┌─────────────────┐                                           │
│  │ 5. COMMIT       │──► git commit (pre-commit hook checks)    │
│  │                 │                                            │
│  └────────┬────────┘                                           │
│           │                                                     │
│           ▼                                                     │
│  [Loop back to DISCUSS or continue to WARM-UP]                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## WARM-UP (Periodic)

**Trigger:** Every 1-2 hours OR when context heavy OR phase complete

```
┌─────────────────────────────────────────────────────────────────┐
│ WARM-UP PROTOCOL                                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Claude: "Warm-up: Updating docs..."                            │
│                                                                 │
│  ├── Append to Conversations/YYYYMMDD_session.md                │
│  ├── Update CONTEXT.md with current state                       │
│  ├── Update SESSION_LOG.md with decisions made                  │
│  ├── Mark completed tasks in plan file with [x]                 │
│  └── If cross-project: update other CONTEXT.md files            │
│                                                                 │
│  Claude: "Warm-up complete: [summary]"                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## DAY WRAP (End of Session)

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. FINALIZE CONVERSATION DUMP                                   │
│    └── Conversations/YYYYMMDD_session.md (complete)             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. UPDATE CONTEXT.md                                            │
│    ├── Current State: [where we ended]                          │
│    ├── Blocker: [any blockers]                                  │
│    ├── Next Steps: [what to do next session]                    │
│    └── Cross-Project: [any dependencies created]                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. UPDATE SESSION_LOG.md                                        │
│    └── Session entry with: Summary, Decisions, Files Modified   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. UPDATE PLAN FILE                                             │
│    └── Mark completed tasks with [x]                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 5. GIT COMMIT (if applicable)                                   │
│    git add -A && git commit -m "session(YYYYMMDD): [summary]"   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│ 6. CROSS-PROJECT UPDATES (if needed)                            │
│    └── Update other projects' CONTEXT.md if dependencies        │
└─────────────────────────────────────────────────────────────────┘
```

---

## Quick Reference

| Phase | Action | Output |
|-------|--------|--------|
| Start | Read CONTEXT.md, PLAN.md | Confirm date, boundaries |
| Work | Discuss → Plan → Decide → Execute | Conversations/, SESSION_LOG.md |
| Warm-Up | Update all tracking files | CONTEXT.md, SESSION_LOG.md, plan |
| End | Finalize, commit | Complete session record |

---

## When to Use Each Mode

| Situation | Mode | How to Activate | Governance Impact |
|-----------|------|-----------------|-------------------|
| Research/exploration | Normal | Default | Conversations/ only |
| Multi-step implementation | Plan Mode | `/plan` or user request | Creates `~/.claude/plans/*.md` |
| Quick single-file fix | Accept Edits | Shift+Tab cycling | Bypasses plan, direct edit |
| Complex refactoring | Plan Mode + TodoWrite | `/plan` then use TodoWrite | Full audit trail |
| Reading/understanding code | Normal | Default | No files modified |

### Plan Mode Details

- **When to enter:** Multi-file changes, architectural decisions, uncertain scope
- **What happens:** Claude creates `~/.claude/plans/[random-name].md`
- **Tracking:** Update `PLAN.md` with active plan filename
- **Exit:** `/plan` again or complete implementation

### Accept Edits Mode

- **When to use:** Single-file fixes, quick corrections, explicit user request
- **Cycle:** Shift+Tab toggles permissions
- **Caution:** Bypasses planning - use sparingly for complex changes

---

## TodoWrite Integration

### When to Use TodoWrite

- Tasks with 3+ steps
- Multi-file modifications
- Complex refactoring
- Any work that might span multiple sessions

### Sync Rules

```
TodoWrite ←──sync──► Plan File (checkboxes)
    │                     │
    │ (volatile)          │ (persistent)
    │ Lost on crash       │ Survives crashes
    │                     │
    └─────────────────────┘
```

**Key Principle:** Plan file is authoritative. If they diverge, trust plan file.

### On Session Resume

1. Read `PLAN.md` to find active plan file
2. Read plan file checkboxes
3. Recreate TodoWrite items from unchecked `[ ]` tasks
4. Mark `[x]` items as already complete

### TodoWrite Best Practices

- Update plan file `[x]` IMMEDIATELY after completing each task
- Don't batch completions - mark as you go
- If uncertain about completion, leave as `[ ]`

---

## Governance Impact Per Step

| Step | Files Updated | Governance Impact |
|------|---------------|-------------------|
| **DISCUSS** | `Conversations/YYYYMMDD_session.md` | Full context preserved for future reference |
| **PLAN** | `~/.claude/plans/*.md` + `PLAN.md` | Decision audit trail, resumable across sessions |
| **DECIDE** | `SESSION_LOG.md` with `#ID` | Cross-session searchable, decision history |
| **EXECUTE** | Code/doc changes | Boundary checks enforced (Layer 1-3) |
| **COMMIT** | Git + pre-commit hook | Prevents cross-boundary commits |
| **WARM-UP** | All tracking files | Context preserved for crashes/timeouts |

### Boundary Enforcement Layers

| Layer | Location | Purpose |
|-------|----------|---------|
| 1 | `CLAUDE.md` | Claude self-checks before edits |
| 2 | Watcher script | macOS notification on violations |
| 3 | Pre-commit hook | Git blocks boundary-crossing commits |

### Decision ID Scope

| Scope | Prefix | Where to Log | Where to Index |
|-------|--------|--------------|----------------|
| Project | `#P` | `SESSION_LOG.md` | `CONTEXT.md` |
| Product | `#PR` | `SESSION_LOG.md` + sibling `CONTEXT.md` | `_Integration/` |
| Company | `#G` | `SESSION_LOG.md` + `_Governance/` | `DECISIONS/_INDEX.md` |

---

## Cross-References

For detailed information, see:

- **Full governance system:** `GOVERNANCE_REFERENCE.md`
- **Testing projects:** `TESTING.md` and `scripts/governance_test.sh`
- **Templates:** `templates/CLAUDE_TEMPLATE_*.md`
- **Layer 3 rules:** `~/.claude/CLAUDE.md`

---

*Extracted from REVISE.md | Updated for Layer 3 architecture | Mode guidance added 2026-01-02*
