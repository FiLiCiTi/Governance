# Claude Code Guide (for Governance)

> **Purpose:** Understand how Claude Code works vs. how Governance extends it
> **Created:** 2026-01-01

---

## How Claude Code Actually Works

### Memory System
- **`~/.claude/CLAUDE.md`** - User-level (all projects)
- **`./CLAUDE.md`** - Project-level (auto-loaded)
- **`./.claude/rules/*.md`** - Modular rules
- **Hierarchical** - Files higher in tree take precedence

### Sessions
- **Per-directory** - Same git repo shares sessions
- **Persistent** - Full message history saved
- **Resume** - Use `/resume` or `--continue`
- **Named** - Use `/rename` to name sessions

### Plan Mode
- **Triggered by** - `Shift+Tab` or `--permission-mode plan`
- **Creates files in** - `~/.claude/plans/[random-name].md`
- **Naming** - Random, NOT controllable
- **Ephemeral** - No auto-link to project

### Context Window
- **200k tokens** - Per conversation limit
- **Autocompact** - Summarizes old messages when full
- **Separate from** - 5-hour usage limits (API rate)

---

## How Governance Extends Claude Code

### Problem: Claude Code Gaps

| Gap | Claude Code | Governance Solution |
|-----|-------------|---------------------|
| Plan persistence | Random names, no link | `PLAN.md` references plan file |
| Session history | Session-based only | `10_Thought_Process/` dumps |
| State tracking | None built-in | `CONTEXT.md` per project |
| Decision log | None | `SESSION_LOG.md` with #IDs |

### Governance Layer Files

| File | Purpose | CC Equivalent |
|------|---------|---------------|
| `CLAUDE.md` | Project rules | Same (CC reads it) |
| `CONTEXT.md` | Current state | None |
| `SESSION_LOG.md` | Decision history | None |
| `PLAN.md` | Links to plan file | None (manual) |
| `10_Thought_Process/` | Full conversation dumps | `/resume` (limited) |

### The Key Insight

**Claude Code is session-centric. Governance is project-centric.**

CC expects you to resume sessions. Governance expects you to read CONTEXT.md and SESSION_LOG.md to rebuild context across sessions.

---

## Workflows

### Starting a Session (Governance Way)
1. Claude reads `CLAUDE.md` (automatic)
2. Claude reads `CONTEXT.md` (rule in CLAUDE.md)
3. Claude reads `PLAN.md` to find active plan
4. Start work

### Ending a Session (Warm-Up Protocol)
1. Update `CONTEXT.md` with current state
2. Update `SESSION_LOG.md` with decisions
3. Mark completed tasks in plan file
4. Optionally dump to `10_Thought_Process/`

### When Plan Changes
1. CC creates new plan in `~/.claude/plans/`
2. Manually update `PLAN.md` to reference it
3. Note the plan file path for future sessions

---

## Settings Reference

### Locations
```
~/.claude/
├── settings.json      # Global settings
├── CLAUDE.md          # Global memory
└── plans/             # Plan files (CC managed)

./
├── CLAUDE.md          # Project memory (CC reads)
├── .claude/
│   ├── settings.json  # Project settings
│   └── rules/         # Modular rules
```

### Useful Settings
- `autocompact` - Auto-summarize when full (default: true)
- `cleanupPeriodDays` - Session retention (default: 30)
- `permissions` - Tool access control

---

## See Also

- `.claude/ISSUES_LOG.md` - Known issues and workarounds
- `CLAUDE.md` - Project rules
- `~/.claude/plans/sharded-tickling-moon.md` - Current plan file
