# Governance v1 vs v2 Comparison

> **Created:** 2026-01-03
> **Purpose:** Document differences and recommendations for v2 implementation

---

## Table of Contents

| #   | Section              | Line |
|-----|----------------------|------|
| 1   | Design Principles    | 21   |
| 2   | Goals & Enforcement  | 45   |
| 3   | Daily Workflow       | 65   |
| 4   | Architecture         | 80   |
| 5   | File Structure       | 110  |
| 6   | Implementation Plan  | 155  |
| 7   | Recommendations      | 210  |
| 8   | Decision Points      | 245  |

---

## 1. Design Principles

### v2 Rules

| Priority | Principle                                          |
|----------|----------------------------------------------------|
| 1        | Depend on Claude infrastructure as much as possible |
| 2        | Depend on code (hooks, scripts) as much as possible |
| 3        | Minimize prompt context as much as possible         |
| 4        | Highlight only critical information in CLAUDE.md    |

### Key Shift

| v1                           | v2                              |
|------------------------------|---------------------------------|
| Advisory (CLAUDE.md text)    | Enforced (hooks + code)         |
| Manual updates               | Automatic triggers              |
| Large prompt context         | Minimal prompt context          |
| Trust Claude to follow       | Verify and block violations     |

---

## 2. Goals & Enforcement

| Goal             | v1 (Advisory)          | v2 (Enforced)                         |
|------------------|------------------------|---------------------------------------|
| Boundaries       | CLAUDE.md text         | `PreToolUse` hook (exit 2 = block)    |
| Decision #IDs    | CLAUDE.md text         | `PostToolUse` hook reminder           |
| Warm-up          | CLAUDE.md text         | `Stop` hook timer check               |
| PLAN.md sync     | Manual                 | Symlink to `.claude/plans/*.md`       |
| Session dumps    | Manual                 | `SessionEnd` hook auto-dump           |
| Date (2026)      | CLAUDE.md text         | `UserPromptSubmit` hook inject        |
| Read before edit | CLAUDE.md text         | Built-in (already enforced)           |
| Session logging  | Manual SESSION_LOG.md  | Parse `history.jsonl`                 |
| Token efficiency | CLAUDE.md text         | Output-styles config                  |

---

## 3. Daily Workflow

| Step          | v1                               | v2                                    |
|---------------|----------------------------------|---------------------------------------|
| Session start | Read CLAUDE.md manually          | `SessionStart` hook loads context     |
| During work   | Trust Claude                     | `PreToolUse` blocks violations        |
| Warm-up       | User remembers (often forgotten) | `Stop` hook checks elapsed time       |
| Session end   | Manual updates (often missed)    | `SessionEnd` hook auto-saves          |

---

## 4. Architecture

### Bottom-Up (Code → LLM)

| v1                           | v2                                  |
|------------------------------|-------------------------------------|
| .sh scripts run manually     | Hooks trigger .sh automatically     |
| Results shown to user        | Results fed back to Claude          |

### Top-Down (LLM → Code)

| v1                           | v2                                  |
|------------------------------|-------------------------------------|
| CLAUDE.md rules (advisory)   | Minimal rules in CLAUDE.md          |
| Claude decides to follow     | Hooks enforce compliance            |

### Project Cross-Interaction

| Aspect             | v1                               | v2                                 |
|--------------------|----------------------------------|------------------------------------|
| Shared rules       | Copy CLAUDE.md to each project   | `~/.claude/CLAUDE.md` (L3) once    |
| Project-specific   | Each CLAUDE.md has all rules     | `.claude/settings.json` hooks      |
| Boundary isolation | Text-based                       | Hook blocks cross-project edits    |

---

## 5. File Structure

### v1 Files (Archived)

| Category  | Files                                                          |
|-----------|----------------------------------------------------------------|
| Docs      | `GOVERNANCE_REFERENCE.md`, `DAILY_WORKFLOW.md`, `TESTING.md`   |
| State     | `CLAUDE.md`, `CONTEXT.md`, `SESSION_LOG.md`, `PLAN.md`         |
| Templates | `CLAUDE_TEMPLATE_ROOT/CODE/BIZZ/OPS.md`                        |
| Scripts   | 10 .sh files                                                   |
| Other     | `registry/`, `Conversations/`, `DataStoragePlan/`              |

### v2 Files (New)

| Category | Files                              | Purpose                    |
|----------|------------------------------------|----------------------------|
| Docs     | `CLAUDE_CODE_DOCS.md`              | Architecture reference     |
| Docs     | `Claude-Code-Governance-Guide-v2.md` | Comprehensive guide      |
| Docs     | `Claude-Code-Documentation-Map.md` | Official docs index        |
| Config   | `.claude/settings.json`            | Hooks configuration        |
| Scripts  | `hooks/*.sh`                       | Hook implementations       |
| State    | Symlinks to `.claude/`             | Auto-managed by Claude     |

### v2 CLAUDE.md (Minimal)

```markdown
# Project Name

## Boundaries
- CAN modify: [paths]
- CANNOT modify: [paths]

## Critical Rules (3-5 max)
1. [Only rules that can't be enforced by hooks]

## See Also
- Full guide: Claude-Code-Governance-Guide-v2.md
```

---

## 6. Implementation Plan

### Phase 1: Hooks Setup

| Hook             | Script                 | Purpose                       |
|------------------|------------------------|-------------------------------|
| `PreToolUse`     | `check_boundaries.sh`  | Block out-of-bounds edits     |
| `PostToolUse`    | `remind_updates.sh`    | Remind about docs             |
| `SessionStart`   | `load_context.sh`      | Inject date, project info     |
| `SessionEnd`     | `save_session.sh`      | Auto-dump to history          |
| `Stop`           | `check_warmup.sh`      | Timer-based reminder          |

### Phase 2: Config Structure

```
Governance/
├── .claude/
│   └── settings.json           ← Hooks config
├── hooks/
│   ├── check_boundaries.sh
│   ├── remind_updates.sh
│   ├── load_context.sh
│   ├── save_session.sh
│   └── check_warmup.sh
├── CLAUDE.md                   ← Minimal (boundaries only)
├── CLAUDE_CODE_DOCS.md
├── Claude-Code-Governance-Guide-v2.md
└── Claude-Code-Documentation-Map.md
```

### Phase 3: Template Slimming

| v1 Template        | v2 Template                 |
|--------------------|-----------------------------|
| ~150 lines each    | ~30 lines each              |
| All rules in text  | Boundaries + critical only  |
| Manual workflow    | Hook-enforced workflow      |

### Phase 4: Testing

| Test                  | Method                          |
|-----------------------|---------------------------------|
| Boundary enforcement  | Try editing blocked file        |
| Warm-up trigger       | Wait for Stop hook              |
| Session auto-save     | End session, check history      |
| Date injection        | Start session, verify 2026      |

---

## 7. Recommendations

### Must Implement

| Item                        | Reason                    |
|-----------------------------|---------------------------|
| `PreToolUse` boundary hook  | Core enforcement          |
| Minimal CLAUDE.md           | Reduce token waste        |
| Symlink PLAN.md             | Zero manual sync          |

### Should Implement

| Item                     | Reason                    |
|--------------------------|---------------------------|
| `SessionEnd` auto-dump   | Never miss session logs   |
| `Stop` warm-up check     | Never forget updates      |
| `UserPromptSubmit` date  | Never use wrong year      |

### Nice to Have

| Item                       | Reason                    |
|----------------------------|---------------------------|
| Governance plugin          | Shareable across projects |
| Custom `/gov` skill        | Quick status checks       |
| CI integration (headless)  | Automated audits          |

---

## 8. Decision Points for Discussion

| #   | Question                                      | Options                               |
|-----|-----------------------------------------------|---------------------------------------|
| 1   | Keep SESSION_LOG.md or use history.jsonl only? | A) Keep both  B) history.jsonl only  |
| 2   | Keep CONTEXT.md or auto-generate?             | A) Keep manual  B) Auto from history |
| 3   | Conversations/ manual or SessionEnd hook?     | A) Manual  B) Auto-dump              |
| 4   | One global hook config or per-project?        | A) Global  B) Per-project            |
| 5   | Warm-up interval?                             | A) 60min  B) 90min  C) Custom        |

---

*Document created: 2026-01-03*
