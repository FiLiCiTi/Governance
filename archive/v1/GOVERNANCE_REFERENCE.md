# FILICITI Governance System Reference

> **Purpose:** Permanent reference for governance system design
> **Created:** 2026-01-01
> **Source:** Plan file `~/.claude/plans/sharded-tickling-moon.md`

---

## Table of Contents

| Section | Description |
|---------|-------------|
| [Executive Summary](#executive-summary) | Problem, solution, key decisions |
| [Core Principle](#core-principle-symlink-governance) | How Option C works |
| [Folder Structure](#complete-folder-structure) | Full target structure |
| [File Types](#file-types--purposes) | Governance files explained |
| [Information Flows](#information-flows) | How data moves between projects |
| [Daily Workflow](#daily-workflow) | Day start, work loop, day wrap |
| [Git Strategy](#git-strategy) | Repos, commits, branches |
| [Automation Scripts](#automation-scripts) | All helper scripts (8 total) |
| [Boundary Enforcement](#boundary-enforcement) | 3-layer protection |
| [Risk Analysis](#risk-analysis) | Known risks and mitigations |
| [LABS Product Types](#labs-product-types) | CODE/RESEARCH/PROTOTYPE |
| [~/.claude/ Integration](#claude-integration) | Claude Code folder structure |
| [Migration Approach](#migration-approach) | Phase 3 project migration |

---

## Executive Summary

### The Problem
- Governance files (CLAUDE.md, CONTEXT.md, SESSION_LOG.md) are private
- Code should be shareable with contractors
- Need separation without complexity

### The Solution: Option C (Symlinks)
- All governance files live in wrapper's `_governance/` folder
- Symlinks in code/ and businessplan/ point to governance files
- code/.gitignore ignores symlinks → contractors get pure source
- 2 repos per product (wrapper + code)

### Key Decisions

| # | Decision | Choice |
|---|----------|--------|
| 1 | Governance location | `_governance/` in wrapper, symlinked to projects |
| 2 | Git strategy | 2 repos per product (wrapper private, code shareable) |
| 3 | Migration approach | DataStoragePlan first, then empty reference, then migrate |
| 4 | Boundary enforcement | All 3 layers (Claude rule + Watcher + Pre-commit) |
| 5 | Alerts | macOS Notification + Terminal Alert |
| 6 | ConvoHistory | → Conversations/ with full dumps |
| 7 | Plans | Symlinked from ~/.claude/plans/[project]/ |
| 8 | Claude_env | → FILICITI/Products/LABS/ |

---

## Core Principle: Symlink Governance

### How It Works

```
PRODUCT/                           ← WRAPPER REPO (private)
├── .git/
├── _governance/                   ← ALL governance files live here
│   ├── code/
│   │   ├── CLAUDE.md
│   │   ├── CONTEXT.md
│   │   ├── SESSION_LOG.md
│   │   ├── PLAN.md
│   │   └── Conversations/
│   └── businessplan/
│       └── [same structure]
│
├── code/                          ← INNER REPO (shareable)
│   ├── .git/
│   ├── .gitignore                 ← Ignores governance symlinks
│   ├── CLAUDE.md → ../_governance/code/CLAUDE.md      ← SYMLINK
│   ├── CONTEXT.md → ../_governance/code/CONTEXT.md    ← SYMLINK
│   ├── SESSION_LOG.md → symlink
│   ├── PLAN.md → symlink
│   ├── plans/ → symlink
│   ├── Conversations/ → symlink
│   ├── src/                       ← ACTUAL CODE (tracked in inner repo)
│   └── README.md                  ← Public docs
│
└── businessplan/                  ← Part of wrapper (no inner .git)
    ├── CLAUDE.md → symlink
    ├── CONTEXT.md → symlink
    └── [01-10 folders]            ← Content tracked in wrapper
```

### Why This Works

| Aspect | How |
|--------|-----|
| **Claude sees governance** | Symlinks appear as real files in project root |
| **Contractors get clean code** | code/.gitignore ignores symlinks |
| **Governance is versioned** | _governance/ tracked in wrapper repo |
| **2 repos only** | wrapper (private) + code (shareable) |

---

## Complete Folder Structure

```
~/Desktop/
│
├── FILICITI/                                    ← COMPANY ROOT
│   │
│   ├── _Governance/                             ← COMPANY-LEVEL (git: filiciti-governance)
│   │   ├── .git/
│   │   ├── CONTEXT.md                          ← Company-wide current state
│   │   ├── DECISIONS/
│   │   │   ├── _INDEX.md                       ← All cross-product decisions
│   │   │   └── NNNN-decision-name.md           ← ADR format
│   │   ├── SESSION_INDEX.md                    ← Find any session
│   │   └── CROSS_PROJECT.md                    ← Cross-repo change tracking
│   │
│   ├── _Shared/                                 ← SHARED RESOURCES (git: filiciti-shared)
│   │   ├── .git/
│   │   ├── Personas/
│   │   ├── Integration/
│   │   │   └── COEVOLVE_FlowInLife.md
│   │   └── Market/
│   │
│   ├── Products/
│   │   │
│   │   ├── COEVOLVE/                           ← PRODUCT WRAPPER (git: coevolve)
│   │   │   ├── .git/
│   │   │   ├── .gitignore                      ← Ignores code/
│   │   │   ├── CLAUDE.md                       ← ROOT type
│   │   │   ├── _governance/                    ← All project governance
│   │   │   │   ├── code/
│   │   │   │   │   ├── CLAUDE.md, CONTEXT.md, SESSION_LOG.md, PLAN.md
│   │   │   │   │   ├── plans/ → ~/.claude/plans/COEVOLVE_code/
│   │   │   │   │   └── Conversations/
│   │   │   │   └── businessplan/
│   │   │   │       └── [same structure]
│   │   │   ├── code/                           ← INNER REPO (git: coevolve-code)
│   │   │   │   ├── .git/, .gitignore
│   │   │   │   ├── [symlinks to _governance/code/]
│   │   │   │   ├── src/, tests/, README.md
│   │   │   ├── businessplan/                   ← Part of wrapper
│   │   │   │   ├── [symlinks to _governance/businessplan/]
│   │   │   │   └── [01-10 folders]
│   │   │   └── _Archaeology/
│   │   │
│   │   ├── FlowInLife/                         ← PRODUCT WRAPPER (git: flowinlife)
│   │   │   ├── _governance/
│   │   │   │   ├── app/, yutaai/, businessplan/
│   │   │   ├── _Integration/                   ← app ↔ yutaai contracts
│   │   │   ├── app/                            ← INNER REPO (git: flowinlife-app)
│   │   │   ├── yutaai/                         ← INNER REPO (git: flowinlife-yutaai)
│   │   │   ├── businessplan/
│   │   │   └── _Archaeology/
│   │   │
│   │   └── LABS/                               ← RESEARCH ARM (git: labs)
│   │       ├── _governance/
│   │       ├── google_extractor/, ssl-learning/, ai-HCMR/, graphreasoning/
│   │       └── _Archaeology/
│   │
│   └── Corporate/                              ← Future
│
├── Governance/                                  ← OPS HUB (was DataStoragePlan)
│   ├── CLAUDE.md, CONTEXT.md, SESSION_LOG.md, PLAN.md
│   ├── Conversations/
│   ├── templates/                              ← CLAUDE.md templates
│   ├── registry/                               ← PROJECT_REGISTRY.md, AUDIT_LOG.md
│   ├── scripts/                                ← All automation
│   ├── DataStoragePlan/                        ← Original storage ops content
│   │   ├── STRATEGY.md, DRIVES.md
│   │   ├── logs/, archive/
│   └── .claude/                                ← CC docs
│       ├── CLAUDE_CODE_GUIDE.md
│       └── ISSUES_LOG.md
│
├── FILICITI/                                    ← TARGET STRUCTURE (was FILICITI_REFERENCE)
│
└── ~/.claude/plans/                            ← CLAUDE PLANS (symlink targets)
    ├── COEVOLVE_code/, COEVOLVE_bizplan/
    ├── FlowInLife_app/, FlowInLife_yutaai/, FlowInLife_bizplan/
    ├── LABS/
    └── Governance/
```

---

## File Types & Purposes

### Governance Files (per project)

| File | Type | Purpose | Updated |
|------|------|---------|---------|
| `CLAUDE.md` | Rules | Project boundaries, workflow, conventions | Rarely |
| `CONTEXT.md` | State | Current blockers, next steps, active work | Every session |
| `SESSION_LOG.md` | History | Full session history, decisions (#IDs) | During session |
| `PLAN.md` | Plan | Current plan, links to ./plans/ | When plan changes |
| `plans/` | Plans | Claude plan files (symlinked) | During planning |
| `Conversations/` | Dump | Full conversation dumps | Every session |

### CONTEXT.md Structure

```markdown
# [Project] Context

> **Last Updated:** YYYY-MM-DD HH:MM
> **Last Session:** [link to SESSION_LOG entry]

## Current State
- **Phase:** [what phase of work]
- **Active Work:** [what's being worked on]
- **Blocker:** [current blocker or "None"]

## Recent Decisions
| ID | Decision | Date |
|----|----------|------|
| #XX | [summary] | YYYY-MM-DD |

## Next Steps
1. [immediate next]
2. [then]

## Cross-Project Dependencies
- **Depends on:** [other projects this needs]
- **Depended by:** [other projects that need this]

## Open Questions
- [ ] [unresolved question]
```

### Conversations/ Structure

```
Conversations/
├── 2026/
│   ├── 01/
│   │   ├── 20260101_session.md      ← Full conversation dump
│   │   └── 20260102_session.md
│   └── 02/
└── Archive/
    └── 2025.tar.gz                  ← Compressed old years
```

### Tracking Responsibilities

| Document | When Updated | Who Updates | Source of Truth For |
|----------|--------------|-------------|---------------------|
| `CLAUDE.md` | Rarely | Human approval | Project rules, boundaries |
| `CONTEXT.md` | Every session (start + end) | Claude | Current state, blockers |
| `SESSION_LOG.md` | During session | Claude | History, decisions (#IDs) |
| `PLAN.md` | When plan changes | Claude | Link to active plan file |
| `plans/*.md` | During execution | Claude | Task completion status |
| `TodoWrite` | Real-time | Claude | Current session tasks |

**Key Rule:** Plan file and TodoWrite MUST stay in sync. If they diverge, plan file is authoritative.

---

## Information Flows

### TOP-DOWN FLOW (Company → Project)

```
FILICITI/_Governance/CONTEXT.md
    │
    │ "Company priority: Launch COEVOLVE pilot by Feb 2026"
    │
    ├──► COEVOLVE/code/CONTEXT.md
    │    └── "Priority: Complete auth for pilot"
    │
    └──► FlowInLife/yutaai/CONTEXT.md
         └── "Priority: Integration for COEVOLVE (lower priority)"
```

### BOTTOM-UP FLOW (Project → Company)

```
COEVOLVE/businessplan/SESSION_LOG.md
    │
    │ Decision: #PR1 - Pioneer pricing = $1000-5000/mo
    │
    ├──► COEVOLVE/businessplan/CONTEXT.md
    ├──► FILICITI/_Governance/DECISIONS/_INDEX.md
    └──► FILICITI/_Governance/SESSION_INDEX.md
```

### CROSS-PROJECT FLOW (Project ↔ Project)

```
FlowInLife/yutaai/ ──► FlowInLife/_Integration/API_CONTRACT.md
                                    │
                                    ▼
                       FlowInLife/app/CONTEXT.md
                       └── "Blocker: yutaai API changed"
```

### Decision Propagation Rules

| Decision Scope | Where to Log | Where to Index |
|----------------|--------------|----------------|
| Single project | SESSION_LOG.md | Project CONTEXT.md |
| Same product, multiple projects | SESSION_LOG.md + other CONTEXT.md | Product _Integration/ |
| Multiple products | SESSION_LOG.md + company | _Governance/DECISIONS/ |
| Company-wide | SESSION_LOG.md | _Governance/DECISIONS/ + all CONTEXT.md |

---

## Daily Workflow

### DAY START

1. **Open Terminal**
2. **Check Company Context** (optional): `cat ~/Desktop/FILICITI/_Governance/CONTEXT.md`
3. **CD into Project**: `cd ~/Desktop/FILICITI/Products/COEVOLVE/code`
4. **Claude Reads** (automatic): CLAUDE.md → CONTEXT.md → PLAN.md
5. **Confirm Date & Boundaries**: Claude announces project, boundaries, current state

### DURING SESSION (Work Loop)

1. **DISCUSS** → append to Conversations/YYYYMMDD_session.md
2. **PLAN** (if needed) → update PLAN.md with link
3. **DECIDE** → SESSION_LOG.md with #ID + update CONTEXT.md
4. **EXECUTE** → Code/docs changes
5. **COMMIT** → git commit (pre-commit hook checks)
6. Loop back or continue to WARM-UP

### WARM-UP PROTOCOL

**Trigger:** Phase/task completion OR 1 hour passed

**Actions:**
1. Update CONTEXT.md (current state)
2. Update SESSION_LOG.md (decisions)
3. Mark completed tasks in plan file with `[x]`
4. Announce: "Warm-up complete: [summary]"

### DAY WRAP

1. Finalize Conversations/YYYYMMDD_session.md
2. Update CONTEXT.md (where we ended, blockers, next steps)
3. Update SESSION_LOG.md (summary, decisions, files modified)
4. Git commit: `git commit -m "session(YYYYMMDD): [summary]"`
5. Update indexes (SESSION_INDEX.md, DECISIONS/_INDEX.md)
6. Cross-project updates if needed

---

## Git Strategy

### Repository Structure

| Repo | Location | Visibility | Contains |
|------|----------|------------|----------|
| `coevolve` | Products/COEVOLVE/ | Private | Wrapper (_governance/, businessplan) |
| `coevolve-code` | Products/COEVOLVE/code/ | Shareable | Source only |
| `flowinlife` | Products/FlowInLife/ | Private | Wrapper |
| `flowinlife-app` | Products/FlowInLife/app/ | Shareable | App source |
| `flowinlife-yutaai` | Products/FlowInLife/yutaai/ | Shareable | AI source |
| `labs` | Products/LABS/ | Private | Research projects |
| `filiciti-governance` | _Governance/ | Private | Company governance |
| `filiciti-shared` | _Shared/ | Private | Shared resources |
| `governance` | Governance/ | Private | Meta-governance + ops |

### What Gets Committed

| File | Git? | Reason |
|------|------|--------|
| CLAUDE.md | Yes | Project rules |
| CONTEXT.md | Yes | State snapshots |
| SESSION_LOG.md | Yes | History |
| PLAN.md | Yes | Plan tracking |
| plans/ (symlink) | No | Symlink only |
| Conversations/ | Yes | Full history |
| src/ | Yes | Code |

### .gitignore Templates

**Wrapper .gitignore:**
```gitignore
code/
```

**Inner (code/) .gitignore:**
```gitignore
CLAUDE.md
CONTEXT.md
SESSION_LOG.md
PLAN.md
plans/
Conversations/
```

### Branch Strategy

```
main          ← Production-ready (protected)
  │
  ├── dev     ← Development integration
  │     ├── feature/[name]
  │     └── session/YYYYMMDD
  │
  └── stage   ← Pre-production testing
```

### Commit Convention

```bash
git commit -m "session(20260101): pricing discussion, #PR1-PR9"
git commit -m "feat(auth): add OAuth2 login"
git commit -m "docs(bizplan): update pricing matrix"
git commit -m "fix(api): handle timeout errors"
```

---

## Automation Scripts

### 1. Governance Symlinks Setup

```bash
#!/bin/bash
# scripts/setup_governance_symlinks.sh

FILICITI="$HOME/Desktop/FILICITI/Products"
PROJECTS=(
  "$FILICITI/COEVOLVE:code"
  "$FILICITI/COEVOLVE:businessplan"
  "$FILICITI/FlowInLife:app"
  "$FILICITI/FlowInLife:yutaai"
  "$FILICITI/FlowInLife:businessplan"
)

GOVERNANCE_FILES=(
  "CLAUDE.md" "CONTEXT.md" "SESSION_LOG.md" "PLAN.md" "Conversations"
)

for entry in "${PROJECTS[@]}"; do
  wrapper="${entry%%:*}"
  project="${entry#*:}"
  gov_src="$wrapper/_governance/$project"
  project_dir="$wrapper/$project"

  mkdir -p "$gov_src/Conversations/$(date +%Y/%m)"

  for file in "${GOVERNANCE_FILES[@]}"; do
    if [[ "$file" != "Conversations" && ! -f "$gov_src/$file" ]]; then
      touch "$gov_src/$file"
    fi
    if [ ! -L "$project_dir/$file" ]; then
      ln -sf "../_governance/$project/$file" "$project_dir/$file"
    fi
  done
done
```

### 2. Plan Symlinks Setup

```bash
#!/bin/bash
# scripts/setup_plan_symlinks.sh

PROJECTS=(
  "COEVOLVE_code:~/Desktop/FILICITI/Products/COEVOLVE/_governance/code"
  "FlowInLife_app:~/Desktop/FILICITI/Products/FlowInLife/_governance/app"
  "Governance:~/Desktop/Governance"
)

for entry in "${PROJECTS[@]}"; do
  name="${entry%%:*}"
  path="${entry#*:}"
  path="${path/#\~/$HOME}"
  mkdir -p "$HOME/.claude/plans/$name"
  if [ ! -L "$path/plans" ]; then
    ln -s "$HOME/.claude/plans/$name" "$path/plans"
  fi
done
```

### 3. Session Index Generator

```bash
#!/bin/bash
# scripts/update_session_index.sh

OUTPUT="$HOME/Desktop/FILICITI/_Governance/SESSION_INDEX.md"
echo "# Session Index" > "$OUTPUT"
echo "| Date | Project | Topics | Link |" >> "$OUTPUT"
echo "|------|---------|--------|------|" >> "$OUTPUT"

find ~/Desktop/FILICITI -name "SESSION_LOG.md" | while read log; do
  project=$(dirname "$log" | xargs basename)
  grep "^## Session:" "$log" | while read line; do
    date=$(echo "$line" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
    echo "| $date | $project | - | $log |" >> "$OUTPUT"
  done
done
```

### 4. Boundary Watcher

```bash
#!/bin/bash
# scripts/boundary_watcher.sh

if [ -f "/tmp/claude_current_project" ]; then
  CURRENT_PROJECT=$(cat /tmp/claude_current_project)
fi

fswatch -o "$HOME/Desktop/FILICITI" | while read; do
  CHANGED=$(fswatch -1 "$HOME/Desktop/FILICITI")
  if [[ -n "$CURRENT_PROJECT" && ! "$CHANGED" =~ "$CURRENT_PROJECT" ]]; then
    terminal-notifier -title "Boundary Violation" -message "Edit outside $CURRENT_PROJECT" -sound "Basso"
  fi
done
```

### 5. Start Session

```bash
#!/bin/bash
# scripts/start_session.sh [project_path]

echo "$1" > /tmp/claude_current_project
if ! pgrep -f "boundary_watcher.sh" > /dev/null; then
  nohup "$HOME/Desktop/Governance/scripts/boundary_watcher.sh" &
fi
cd "$1"
echo "=== Session Started ==="
grep -A3 "CAN modify" CLAUDE.md
cat CONTEXT.md
```

### 6. Multi-repo Helper Scripts

```bash
# scripts/clone_all.sh - Clone all FILICITI repos
#!/bin/bash
REPOS=(
  "coevolve:git@github.com:filiciti/coevolve.git"
  "coevolve-code:git@github.com:filiciti/coevolve-code.git"
  "flowinlife:git@github.com:filiciti/flowinlife.git"
  "flowinlife-app:git@github.com:filiciti/flowinlife-app.git"
  "flowinlife-yutaai:git@github.com:filiciti/flowinlife-yutaai.git"
  "labs:git@github.com:filiciti/labs.git"
)

for entry in "${REPOS[@]}"; do
  name="${entry%%:*}"
  url="${entry#*:}"
  git clone "$url" "$name"
done

# scripts/pull_all.sh - Pull all repos
#!/bin/bash
find ~/Desktop/FILICITI -name ".git" -type d | while read gitdir; do
  repo=$(dirname "$gitdir")
  echo "Pulling $repo..."
  git -C "$repo" pull
done

# scripts/status_all.sh - Status of all repos
#!/bin/bash
find ~/Desktop/FILICITI -name ".git" -type d | while read gitdir; do
  repo=$(dirname "$gitdir")
  echo "=== $repo ==="
  git -C "$repo" status -s
done
```

### 7. Code Archaeology Auto-Update

```bash
#!/bin/bash
# scripts/update_archaeology.sh
# Run weekly or on significant changes

for product in COEVOLVE FlowInLife LABS; do
  ARCH_DIR="$HOME/Desktop/FILICITI/Products/$product/_Archaeology"

  mkdir -p "$ARCH_DIR"

  # Update codebase map (file tree)
  tree -I 'node_modules|venv|__pycache__|.git' \
    "$HOME/Desktop/FILICITI/Products/$product" > "$ARCH_DIR/CODEBASE_MAP.md"

  # Update API endpoints (grep for routes)
  grep -r "app\.\(get\|post\|put\|delete\)" \
    "$HOME/Desktop/FILICITI/Products/$product/*/src" 2>/dev/null > "$ARCH_DIR/API_ENDPOINTS.md"

  # Update changelog from git
  git -C "$HOME/Desktop/FILICITI/Products/$product" log \
    --oneline -50 2>/dev/null > "$ARCH_DIR/CHANGELOG.md"

  echo "Updated archaeology for $product"
done
```

### 8. Pre-commit Hook Installation

```bash
#!/bin/bash
# scripts/install_hooks.sh
# Install boundary-checking pre-commit hooks in all git repos

find ~/Desktop/FILICITI -name ".git" -type d | while read gitdir; do
  repo=$(dirname "$gitdir")
  hook_file="$gitdir/hooks/pre-commit"

  cat > "$hook_file" << 'HOOK'
#!/bin/bash
# Boundary enforcement pre-commit hook

CLAUDE_MD="$(git rev-parse --show-toplevel)/CLAUDE.md"
if [ ! -f "$CLAUDE_MD" ]; then
  exit 0  # No CLAUDE.md, skip check
fi

CAN_MODIFY=$(grep -A1 "CAN modify" "$CLAUDE_MD" | tail -1 | sed 's/.*`\(.*\)`.*/\1/')
if [ -z "$CAN_MODIFY" ]; then
  exit 0  # No boundaries defined
fi

for file in $(git diff --cached --name-only); do
  if ! echo "$file" | grep -qE "^($CAN_MODIFY)"; then
    echo "❌ COMMIT BLOCKED: $file outside boundaries"
    echo "   Allowed: $CAN_MODIFY"
    exit 1
  fi
done
HOOK

  chmod +x "$hook_file"
  echo "Installed hook in $repo"
done
```

---

## Boundary Enforcement

### Layer 1: Claude Rule (in CLAUDE.md)

```markdown
## Boundaries
- **CAN modify:** `code/src/**`, `code/tests/**`, `docs/**`
- **CANNOT modify:** `../businessplan/**`, `../_Governance/**`
- **Read-only:** `../_Shared/**`

## Boundary Protocol
Before ANY edit:
1. Check if file is within CAN modify paths
2. If outside → STOP and ask user
3. If cross-project needed → suggest switching projects
```

### Layer 2: Background Watcher

- Runs `fswatch` on FILICITI folder
- Sends macOS notification on boundary violation
- Terminal beep alert

### Layer 3: Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

CLAUDE_MD="$(git rev-parse --show-toplevel)/CLAUDE.md"
CAN_MODIFY=$(grep -A1 "CAN modify" "$CLAUDE_MD" | tail -1 | sed 's/.*`\(.*\)`.*/\1/')

for file in $(git diff --cached --name-only); do
  if ! echo "$file" | grep -qE "^($CAN_MODIFY)"; then
    echo "❌ COMMIT BLOCKED: $file outside boundaries"
    exit 1
  fi
done
```

---

## Risk Analysis

### Risk Register

| # | Risk | Impact | Likelihood | Mitigation |
|---|------|--------|------------|------------|
| R1 | Plan file staleness | High | High | Plan File Sync rule (checkbox `[x]`) |
| R2 | Symlink breakage | High | Medium | Re-create symlinks after folder moves |
| R3 | Context loss on crash | Medium | Medium | Frequent CONTEXT.md updates (warm-up) |
| R4 | Boundary violations | Medium | Low | 3-layer enforcement |
| R5 | Conversations growth | Low | High | Annual archiving |
| R6 | Governance complexity | Medium | Medium | Automation + monthly audit |
| R7 | Template drift | Medium | Low | PROJECT_REGISTRY.md tracking |
| R8 | Multi-tracking confusion | High | Medium | Clear rules per document type |

### Plan File Sync Rule

```markdown
## Plan File Sync Rule
- Plan files use checkbox format: `[ ] pending` → `[x] done`
- Update plan file immediately after completing each task
- If session crashes, TodoWrite lost but plan file survives
- Plan file = source of truth for multi-session work
- On session resume: read plan file, sync TodoWrite from it
```

**Example in plan file:**
```markdown
## Tasks
- [x] Create CONTEXT.md
- [x] Create Conversations folder
- [x] Create automation scripts
- [ ] Update templates  ← current
- [ ] Update CLAUDE.md
```

### Warm-Up Protocol

**Trigger:** Phase/task completion OR 1 hour passed without update

**Actions:**
1. Update CONTEXT.md (current state)
2. Update SESSION_LOG.md (decisions)
3. Mark completed tasks in plan file with `[x]`
4. Announce: "Warm-up complete: [summary]"

### Tracking Responsibilities

| Document | When Updated | Who Updates | Source of Truth For |
|----------|--------------|-------------|---------------------|
| `CLAUDE.md` | Rarely | Human approval | Project rules, boundaries |
| `CONTEXT.md` | Every session (start + end) | Claude | Current state, blockers |
| `SESSION_LOG.md` | During session | Claude | History, decisions (#IDs) |
| `PLAN.md` | When plan changes | Claude | Link to active plan file |
| `plans/*.md` | During execution | Claude | Task completion status |
| `TodoWrite` | Real-time | Claude | Current session tasks |

**Key Rule:** Plan file and TodoWrite MUST stay in sync. If they diverge, plan file is authoritative.

---

## LABS Product Types

| Type | Description | Governance Level |
|------|-------------|------------------|
| CODE | Reusable tools (e.g., google_extractor) | Full (CLAUDE, CONTEXT, SESSION_LOG, PLAN) |
| RESEARCH | Experiments, notebooks | Light (CLAUDE, CONTEXT, results) |
| PROTOTYPE | Early-stage products | Light → Full as matures |

---

## Archive Script for Conversations

```bash
#!/bin/bash
# scripts/archive_conversations.sh
# Run quarterly to compress old conversation dumps

YEAR_TO_ARCHIVE=$1  # e.g., 2025

find ~/Desktop/FILICITI -type d -name "Conversations" | while read dir; do
  if [ -d "$dir/$YEAR_TO_ARCHIVE" ]; then
    mkdir -p "$dir/Archive"
    tar -czf "$dir/Archive/$YEAR_TO_ARCHIVE.tar.gz" "$dir/$YEAR_TO_ARCHIVE"
    rm -rf "$dir/$YEAR_TO_ARCHIVE"
    echo "Archived: $dir/$YEAR_TO_ARCHIVE"
  fi
done
```

---

## ~/.claude/ Integration

### Folder Structure

```
~/.claude/
├── CLAUDE.md              ← Layer 3 User Memory (universal rules)
├── settings.json          ← Global permissions, behavior
├── settings.local.json    ← Extended permissions
├── plans/                 ← Plan files (random names, ignores subfolders)
├── projects/[path]/       ← Session history per project (.jsonl)
├── todos/[session].json   ← TodoWrite state (PERSISTS across sessions!)
├── file-history/[session] ← File versions (audit trail)
├── stats-cache.json       ← Usage metrics
└── history.jsonl          ← Command history
```

### Prompt Layers (Priority Order)

| Layer | Location | Purpose | Priority |
|-------|----------|---------|----------|
| 1 | System Prompt | Anthropic core behavior | Highest |
| 2 | Enterprise Policy | Org-wide rules | - |
| 3 | `~/.claude/CLAUDE.md` | User preferences (global) | High |
| 4 | `./CLAUDE.md` | Project rules | Medium |
| 5 | `.claude/rules/*.md` | Modular rules | Medium |
| 6 | `./CLAUDE.local.md` | Personal overrides | Low |
| 7 | Conversation History | Session context | - |
| 8 | Plan File | Current plan | - |
| 9 | Current Message | User input | - |

### Integration Points

| ~/.claude/ | → | Governance File | Sync |
|------------|---|-----------------|------|
| `todos/[session].json` | → | `SESSION_LOG.md` | Manual (completed items) |
| `file-history/[session]/` | → | `Conversations/` | Optional (files touched) |
| `plans/*.md` | → | `PLAN.md` | Track active plan name |
| `stats-cache.json` | → | Monitoring | Parse for usage metrics |
| `projects/[path]/` | → | Resume | `claude --continue` |

### Key Insights

1. **plans/ ignores subfolders** - Track active plan in PLAN.md by name
2. **todos/ persists** - Can resume tasks across sessions
3. **stats-cache.json** - Full usage metrics (sessions, messages, tokens)
4. **Layer 3 applies globally** - Universal rules for ALL projects

---

## Migration Approach

### Principle: Document First, Migrate Later

1. **Update Governance only** - All governance decisions documented here
2. **Create empty reference folder** - Full structure as template
3. **Migration list per project** - Identify technical issues before moving

### Projects to Migrate (Phase 3)

| # | Current Location | Target Location | Type | Status |
|---|------------------|-----------------|------|--------|
| 1 | Governance/ | Desktop/FILICITI/_Governance/ | OPS | Pending |
| 2 | FILICITI_LABS/COEVOLVE/ | Products/COEVOLVE/code/ | CODE | Pending |
| 3 | FILICITI_LABS/COEVOLVE_businessplan/ | Products/COEVOLVE/businessplan/ | BIZZ | Pending |
| 4 | Claude_env/ | Products/LABS/ | ROOT | Pending |
| 5 | Claude_env/google_extractor/ | Products/LABS/google_extractor/ | CODE | Pending |
| 6 | FlowInLife_env/.../FlowInLife/ | Products/FlowInLife/app/ | CODE | Pending |
| 7 | FlowInLife_env/.../YutaAI/ | Products/FlowInLife/yutaai/ | CODE | Pending |
| 8 | FlowInLife_env/.../Code_Archaeology/ | Products/FlowInLife/_Archaeology/ | DOCS | Pending |
| ~~9~~ | ~~YutaAI_mem_Railway2~~ | ~~SKIPPED~~ | - | Architecture consolidation needed |
| ~~10~~ | ~~18-Matt Lewis_FI~~ | ~~SKIPPED~~ | - | Not formatted |

### Technical Issues Per Project

| Project | Issue | Mitigation |
|---------|-------|------------|
| FlowInLife | Railway deployment configs | Update Railway project settings after move |
| YutaAI | Git remote URLs | `git remote set-url origin [new]` |
| COEVOLVE | Git remote URLs | `git remote set-url origin [new]` |
| All CODE | Absolute paths in code | `grep -r "/Users/mohammadshehata"` |
| All | Symlinks will break | Re-create after move |
| Docker | Volume mounts may have paths | Update docker-compose.yml |

### Migration Message Template

```markdown
# Migration Assessment: [Project Name]

## Current State
- Location: [current path]
- Git repo: [yes/no, remote URL]
- Railway: [yes/no, project name]
- Dependencies: [list]

## Target State
- Location: [target path]
- Git repo: [new remote URL]

## Technical Checks
- [ ] Search for hardcoded paths
- [ ] Check Railway config
- [ ] Check Docker volumes
- [ ] Check imports/requires
- [ ] Check CI/CD configs
- [ ] Check symlinks

## Migration Steps
1. [step]
2. [step]

## Rollback Plan
[how to undo if issues]
```

### Migration Protocol

1. **Copy** (not move) project to FILICITI target
2. **Update** CLAUDE.md to correct template
3. **Create** governance symlinks
4. **Run** `governance_test.sh` on migrated project
5. **Pass** = mark "migrated" in registry
6. **Fail** = fix issues, re-test
7. **Delete old** only after ALL projects pass + user approval

**Principle:** One project at a time, with testing between.

---

*Reference document for FILICITI Governance System (Option C - Symlinks)*
*Source: Plan file created 2026-01-01*
