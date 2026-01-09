# Governance Testing Framework

> **Created:** 2026-01-02
> **Updated:** 2026-01-02 (5-layer architecture)

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                    GOVERNANCE TESTING LAYERS                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Layer 1: STRUCTURE          Layer 2: PROCESS         Layer 3: RUNTIME
│  (governance_test.sh)        (governance_audit.sh)    (governance_watch.sh)
│  ──────────────────          ─────────────────────    ──────────────────────
│  • Files exist?              • Files fresh? (DAILY)   • Boundaries live?
│  • Sections present?         • IDs logged? (DAILY)    • Warm-ups triggered?
│  • Symlinks work?            • Cross-refs? (WEEKLY)   • Session tracking?
│  • Hook installed?           • Per-rule check         • Violations caught?
│                                                                     │
│  [RUN: per-project]          [RUN: daily/weekly]      [RUN: during session]
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Layer 4: REPORTING              Layer 5: .CLAUDE/ INTEGRATION      │
│  (governance_report.sh)          (governance_claude_sync.sh)        │
│  ─────────────────────           ──────────────────────────────     │
│  • Combines all layers           • Parse history.jsonl              │
│  • Trend analysis                • Session rule compliance          │
│  • Project scorecards            • TodoWrite ↔ Plan sync            │
│  • Export to AUDIT_LOG.md        • Project activity tracking        │
│                                                                     │
│  [RUN: on-demand/monthly]        [RUN: per-session/daily]           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Quick Reference

| Layer | Script | Purpose | Frequency |
|-------|--------|---------|-----------|
| 1 | `governance_test.sh` | Structure compliance | Per-migration |
| 2 | `governance_audit.sh` | Process compliance | Daily/Weekly |
| 3 | `governance_watch.sh` | Runtime monitoring | During sessions |
| 4 | `governance_report.sh` | Combined reporting | Monthly |
| 5 | `governance_claude_sync.sh` | .claude/ integration | Per-session |

---

## Layer 1: Structure Tests (governance_test.sh)

Automated compliance testing for FILICITI governance system. Tests projects against governance requirements and produces a weighted score.

## Usage

```bash
# Test a specific project
./scripts/governance_test.sh ~/Desktop/FILICITI/Products/COEVOLVE/code

# Test current directory
./scripts/governance_test.sh

# Test multiple projects
for dir in ~/Desktop/FILICITI/Products/*/; do
    ./scripts/governance_test.sh "$dir"
done
```

## Scoring System

### Goals & Weights

| Goal | Description | Weight |
|------|-------------|--------|
| G1 | CLAUDE.md exists with correct template sections | 20% |
| G2 | CONTEXT.md exists with current state | 15% |
| G3 | SESSION_LOG.md exists with sessions | 15% |
| G4 | Symlinks work correctly | 20% |
| G5 | Pre-commit hook active | 15% |
| G6 | Layer 3 (~/.claude/CLAUDE.md) exists | 10% |
| G7 | PLAN.md tracks active plan | 5% |

### Pass/Fail Criteria

- **PASS:** Score ≥ 80%
- **FAIL:** Score < 80%

### Scoring Logic

Each test can score 0-100%:

| Score | Meaning |
|-------|---------|
| 100% | Full compliance |
| 50% | Partial compliance (file exists but incomplete) |
| 0% | Missing or broken |

## Test Categories

### 1. Structure Tests
- Files exist in correct locations
- Required sections present in markdown files
- File size > minimum (not just empty placeholders)

### 2. Content Tests
- CLAUDE.md has: title, Overview/Boundaries, Rules, Template reference
- CONTEXT.md has: Current State, Last Updated, Next Steps
- SESSION_LOG.md has: At least one `## Session:` entry

### 3. Symlink Tests
- Detects wrapper repo pattern (`_governance/` folder)
- Detects inner repo pattern (symlinks to governance)
- Validates symlinks resolve correctly

### 4. Boundary Tests
- Pre-commit hook exists
- Hook contains boundary-checking logic

### 5. Integration Tests
- Layer 3 (~/.claude/CLAUDE.md) exists globally
- PLAN.md references active plan file

## JSON Output

The script outputs JSON for automation:

```json
{
  "project": "COEVOLVE",
  "path": "/Users/.../COEVOLVE/code",
  "date": "2026-01-02T12:00:00-08:00",
  "score": 85,
  "threshold": 80,
  "result": "PASS",
  "breakdown": {
    "claude_md": 100,
    "context_md": 100,
    "session_log": 50,
    "symlinks": 100,
    "precommit": 0,
    "layer3": 100,
    "plan_md": 50
  }
}
```

## Migration Gate

**Rule:** Projects must pass governance tests before old folders can be deleted.

```bash
# Migration workflow
1. Copy project to FILICITI/
2. Update governance files
3. Run: ./scripts/governance_test.sh [project]
4. If PASS → Mark migrated in registry
5. If FAIL → Fix issues, re-test
6. Delete old folder ONLY after all projects pass
```

## Manual Checklist

For projects that need manual verification:

### Pre-Migration
- [ ] Source project exists
- [ ] Target folder in FILICITI is empty/placeholder
- [ ] Correct template type identified (CODE/BIZZ/OPS/ROOT)

### Post-Migration
- [ ] `governance_test.sh` returns PASS
- [ ] Can open project in Claude Code
- [ ] CLAUDE.md loads correctly
- [ ] No broken symlinks
- [ ] Git history preserved (if applicable)

### Final Cleanup
- [ ] All projects score ≥ 80%
- [ ] PROJECT_REGISTRY.md updated with new paths
- [ ] User approved deletion of old folders

## Troubleshooting

### Common Failures

| Issue | Solution |
|-------|----------|
| CLAUDE.md missing sections | Compare against template in `Governance/templates/` |
| Broken symlinks | Re-run `scripts/setup_governance_symlinks.sh` |
| Pre-commit hook missing | Run `scripts/install_hooks.sh` (if exists) |
| Layer 3 missing | Create `~/.claude/CLAUDE.md` |

### Partial Scores

- **50% on SESSION_LOG.md:** File exists but no sessions logged yet
- **50% on PLAN.md:** File exists but doesn't reference `~/.claude/plans/`
- **50% on Pre-commit:** Hook exists but no boundary checks

---

## Layer 2: Process Tests (governance_audit.sh)

### Usage

```bash
# Full audit
./scripts/governance_audit.sh ~/Desktop/Governance

# Daily checks only
./scripts/governance_audit.sh ~/Desktop/Governance --daily

# Weekly checks
./scripts/governance_audit.sh ~/Desktop/Governance --weekly

# Per-rule compliance
./scripts/governance_audit.sh ~/Desktop/Governance --rule "table-formatting"
./scripts/governance_audit.sh ~/Desktop/Governance --rule "date-usage"
./scripts/governance_audit.sh ~/Desktop/Governance --rule "decision-ids"

# Per-section check
./scripts/governance_audit.sh ~/Desktop/Governance --section "General Rules"
```

### Available Rules

| Rule | What it checks |
|------|----------------|
| `table-formatting` | Tables have aligned columns |
| `date-usage` | Uses 2026 not 2025 |
| `decision-ids` | Proper #ID format in SESSION_LOG |
| `token-efficiency` | Response brevity |
| `read-before-edit` | Read tool before Edit tool |

---

## Layer 3: Runtime Monitoring (governance_watch.sh)

### Usage

```bash
# Start monitoring
./scripts/governance_watch.sh start ~/Desktop/Governance

# Check status (warm-up timer, violations)
./scripts/governance_watch.sh status

# Record warm-up
./scripts/governance_watch.sh warmup

# Check for violations
./scripts/governance_watch.sh check

# End session
./scripts/governance_watch.sh stop
```

### Features

- Session duration tracking
- Warm-up reminders (90 min default)
- Boundary violation detection
- macOS notifications

---

## Layer 4: Combined Reporting (governance_report.sh)

### Usage

```bash
# Full report (all projects)
./scripts/governance_report.sh

# Single project
./scripts/governance_report.sh ~/Desktop/Governance

# Save to AUDIT_LOG.md
./scripts/governance_report.sh --save
```

---

## Layer 5: .claude/ Integration (governance_claude_sync.sh)

### Usage

```bash
# Full sync check
./scripts/governance_claude_sync.sh

# Sessions per project
./scripts/governance_claude_sync.sh --sessions

# TodoWrite ↔ Plan sync
./scripts/governance_claude_sync.sh --todos

# History analysis
./scripts/governance_claude_sync.sh --history

# Specific project
./scripts/governance_claude_sync.sh --project ~/Desktop/Governance
```

### Data Sources

| File | Purpose |
|------|---------|
| `~/.claude/history.jsonl` | Session history, rule compliance |
| `~/.claude/projects/` | Project activity tracking |
| `~/.claude/todos/` | TodoWrite state |
| `~/.claude/plans/` | Plan file progress |
| `~/.claude/CLAUDE.md` | Layer 3 rules |

---

*Testing framework created: 2026-01-02 (#G20)*
*5-layer architecture added: 2026-01-02 (#G23-#G28)*
