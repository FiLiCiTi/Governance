# Governance v2 Full Specification

> **Created:** 2026-01-03
> **Status:** DRAFT - Pending Review
> **Purpose:** Complete specification for v2 implementation

---

## Table of Contents

| #    | Section                        | Line | Referenced In       |
|------|--------------------------------|------|---------------------|
| 1    | Executive Summary              | 37   | -                   |
| 2    | Design Principles              | 85   | -                   |
| 3    | FILICITI Folder Structure      | 111  | -                   |
| 3.1  | - Full Folder Tree             | 113  | -                   |
| 3.2  | - Symlink Governance (Option C)| 172  | -                   |
| 3.3  | - Two-Repo Strategy            | 205  | -                   |
| 3.4  | - Company-Level Governance     | 216  | -                   |
| 3.5  | - Per-Project Conversations    | 227  | -                   |
| 3.6  | - Project Types                | 239  | -                   |
| 3.7  | - Design Reasoning Summary     | 248  | -                   |
| 3.8  | LABS Product Types             | 261  | -                   |
| 4    | Governance Folder Structure    | 297  | -                   |
| 5    | Prompt Layers (9 Layers)       | 340  | -                   |
| 6    | Daily Workflow                 | 430  | **Master Index**    |
| 7    | Information Flows              | 550  | Daily §6.0          |
| 8    | Terminal Capture (cc)          | 610  | Daily §6.1          |
| 9    | Hooks Specification            | 670  | Daily §6.2          |
| 10   | Settings.json Configuration    | 800  | Daily §6.2          |
| 11   | When to Use Each Mode          | 955  | Daily §6.3          |
| 12   | TodoWrite Integration          | 910  | Daily §6.3          |
| 13   | Warm-up Protocol               | 960  | Daily §6.4          |
| 14   | CLAUDE.md Templates            | 1020 | Daily §6.5          |
| 15   | Decision ID System             | 1100 | Daily §6.5          |
| 16   | Issue Protocol                 | 1150 | Daily §6.6          |
| 17   | Git Strategy                   | 1230 | Daily §6.7          |
| 18   | Scripts Reference              | 1300 | Daily §6.8          |
| 19   | Testing Methods                | 1360 | -                   |
| 20   | Troubleshooting                | 1430 | -                   |
| 21   | Quick Reference                | 1490 | -                   |
| 22   | Risk Analysis                  | 1500 | -                   |
| 23   | Migration Guide (v1 → v2)      | 1569 | -                   |

---

## 1. Executive Summary

### 1.1 v1 Summary (What We Had)

| Component        | v1 Approach                              |
|------------------|------------------------------------------|
| Enforcement      | CLAUDE.md text (advisory)                |
| Session capture  | Manual copy/paste                        |
| Warm-up          | User remembers                           |
| Boundaries       | Trust Claude to follow                   |
| Session logs     | Manual SESSION_LOG.md                    |
| Plan sync        | Manual PLAN.md updates                   |
| File count       | 10+ governance files per project         |

### 1.2 The Problem

| Issue                          | Impact                                |
|--------------------------------|---------------------------------------|
| Rules in CLAUDE.md ignored     | Boundaries violated, dates wrong      |
| Manual updates forgotten       | SESSION_LOG.md stale, PLAN.md outdated|
| No session capture             | Context lost on crash                 |
| Large prompt context           | Tokens wasted on unused rules         |
| No enforcement                 | Advisory only = optional              |

### 1.3 The Solution: v2

| v1 Problem            | v2 Solution                           |
|-----------------------|---------------------------------------|
| Advisory rules        | Hooks enforce (exit 2 = block)        |
| Manual capture        | `cc` wrapper auto-records             |
| Forgotten warm-ups    | `Stop` hook timer                     |
| Manual logs           | `history.jsonl` + auto-generate       |
| Large CLAUDE.md       | Minimal (~25 lines, boundaries only)  |
| No audit trail        | `PostToolUse` logs all actions        |

### 1.4 Key Decisions

| ID   | Decision                                              |
|------|-------------------------------------------------------|
| #G30 | Hooks over CLAUDE.md text for enforcement             |
| #G31 | Minimal CLAUDE.md (~25 lines)                         |
| #G32 | `cc` wrapper for terminal capture                     |
| #G33 | 90-minute warm-up interval                            |
| #G34 | Global hooks config, project boundaries in CLAUDE.md  |
| #G35 | Auto-generate session summary from history.jsonl      |

---

## 2. Design Principles

### 2.1 v2 Rules

| Priority | Principle                                           |
|----------|-----------------------------------------------------|
| 1        | Depend on Claude infrastructure as much as possible |
| 2        | Depend on code (hooks, scripts) as much as possible |
| 3        | Minimize prompt context as much as possible         |
| 4        | Highlight only critical information in CLAUDE.md    |
| 5        | Automate everything, minimize manual work           |
| 6        | Enforce, don't advise                               |

### 2.2 Key Shift

| v1                           | v2                              |
|------------------------------|---------------------------------|
| Advisory (CLAUDE.md text)    | Enforced (hooks + code)         |
| Manual updates               | Automatic triggers              |
| Large prompt context         | Minimal prompt context          |
| Trust Claude to follow       | Verify and block violations     |
| Manual session capture       | Auto-capture via `cc` wrapper   |
| 10+ files per project        | 1 slim CLAUDE.md + hooks        |

---

## 3. FILICITI Folder Structure

### 3.1 Full Folder Tree

```
~/Desktop/FILICITI/                         ← Company root
│
├── _Governance/ → ~/Desktop/Governance/    ← Symlink to Governance hub
│
├── Products/
│   │
│   ├── COEVOLVE/                           ← Product folder
│   │   ├── CLAUDE.md                       ← ROOT (index for product)
│   │   │
│   │   ├── code/                           ← CODE project (git repo)
│   │   │   ├── CLAUDE.md → ../_governance/code/CLAUDE.md
│   │   │   ├── .gitignore                  ← Ignores symlinks
│   │   │   └── src/
│   │   │
│   │   ├── businessplan/                   ← BIZZ project
│   │   │   └── CLAUDE.md → ../_governance/businessplan/CLAUDE.md
│   │   │
│   │   └── _governance/                    ← Private governance files
│   │       ├── code/
│   │       │   ├── CLAUDE.md               ← Actual CLAUDE.md
│   │       │   └── Conversations/          ← Session logs (cc saves here)
│   │       │       └── YYYYMMDD_HHMM_code.log
│   │       └── businessplan/
│   │           ├── CLAUDE.md
│   │           └── Conversations/
│   │
│   ├── FlowInLife/                         ← Multi-repo product
│   │   ├── CLAUDE.md                       ← ROOT
│   │   │
│   │   ├── fil-app/                        ← CODE (FlowInLife team)
│   │   │   ├── CLAUDE.md → ../_governance/app/CLAUDE.md
│   │   │   └── .gitignore
│   │   │
│   │   ├── fil-yuta/                       ← CODE (YutaAI team)
│   │   │   ├── CLAUDE.md → ../_governance/yutaai/CLAUDE.md
│   │   │   └── .gitignore
│   │   │
│   │   └── _governance/
│   │       ├── app/
│   │       │   ├── CLAUDE.md
│   │       │   └── Conversations/
│   │       └── yutaai/
│   │           ├── CLAUDE.md
│   │           └── Conversations/
│   │
│   └── LABS/                               ← ROOT (experiments index)
│       ├── CLAUDE.md
│       └── google_extractor/               ← CODE
│           └── CLAUDE.md
│
└── README.md
```

### 3.1.1 v1 → v2 File Changes

| v1 File | v2 Status | Replacement |
|---------|-----------|-------------|
| `CONTEXT.md` | **REMOVED** | Warm-up protocol via hooks |
| `SESSION_LOG.md` | **REMOVED** | `~/.claude/history.jsonl` |
| `PLAN.md` | **REMOVED** | `~/.claude/plans/*.md` (auto) |
| `10_Thought_Process/` | **REMOVED** | `Conversations/` via `cc` |
| `CLAUDE.md` | **KEPT** | Required for boundaries |
| `Conversations/` | **NEW** | `cc` terminal capture |

### 3.2 Symlink Governance Strategy (Option C)

**Problem Solved:** Governance files are private, but code may be shared with contractors.

**Solution:**
```
┌─────────────────────────────────────────────────────────────────────────────┐
│  SYMLINK GOVERNANCE (OPTION C)                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  code/                          _governance/code/                           │
│  ├── CLAUDE.md ─────────────────→ CLAUDE.md        (actual file)            │
│  ├── .gitignore                   └── Conversations/                        │
│  │   └── ignores: CLAUDE.md                                                 │
│  └── src/                                                                   │
│                                                                             │
│  Contractor sees:               You see (resolved):                         │
│  - src/                         - CLAUDE.md (boundaries)                    │
│  - (no CLAUDE.md)               - Conversations/ (session logs)             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Implementation:**
```bash
# In code/.gitignore:
CLAUDE.md
Conversations/
```

### 3.3 Two-Repo Strategy

| Repo Type  | Contains               | Push To     | Share With       |
|------------|------------------------|-------------|------------------|
| Wrapper    | Product folder + _governance/ | Private repo | No one           |
| Code       | src/, tests/, docs/    | Shareable repo | Contractors     |

**Example:**
- `FiLiCiTi/COEVOLVE` (wrapper) → Private GitHub repo
- `COEVOLVE/code/` (code) → Shareable GitHub repo (no governance files)

### 3.4 Company-Level Governance

```
~/Desktop/FILICITI/
└── _Governance/ → ~/Desktop/Governance/
```

- **Symlink** connects FILICITI to Governance hub
- All FILICITI projects reference `../../_Governance/` or `~/Desktop/Governance/`
- Centralized templates, hooks, scripts shared across all products

### 3.5 Per-Project Conversations

**v2 Change:** Conversations/ is now **per-project**, not global.

| Location                                    | Contains                    |
|---------------------------------------------|-----------------------------|
| `_governance/code/Conversations/`           | code project sessions       |
| `_governance/businessplan/Conversations/`   | businessplan sessions       |
| `~/Desktop/Governance/Conversations/`       | Governance hub sessions     |

**cc script updated to save per-project.** See Section 8.

### 3.6 Project Types

| Type | Purpose              | CLAUDE.md Size | Governance Files                  | Example                  |
|------|----------------------|----------------|-----------------------------------|--------------------------|
| ROOT | Index/container      | ~15 lines      | None (in children)                | LABS/, COEVOLVE/         |
| CODE | Technical codebase   | ~25 lines      | CLAUDE.md + Conversations/        | COEVOLVE/code/           |
| BIZZ | Business/strategy    | ~20 lines      | CLAUDE.md + Conversations/        | COEVOLVE/businessplan/   |
| OPS  | Operations/infra     | ~25 lines      | CLAUDE.md + Conversations/ (local)| Governance/              |

### 3.7 Design Reasoning Summary

| Problem                               | Decision                        | Reasoning                           |
|---------------------------------------|--------------------------------|-------------------------------------|
| Governance private, code shareable    | Symlinks in code/              | .gitignore hides symlinks           |
| Multiple repos per product            | Wrapper + code repos           | Wrapper private, code shareable     |
| Contractors shouldn't see governance  | _governance/ outside code/     | Clean code repo for sharing         |
| Session logs scattered                | Per-project Conversations/     | Context stays with project          |
| Templates shared across projects      | Central Governance hub         | Single source of truth              |
| Boundary enforcement                  | Hooks read CLAUDE.md           | Symlink resolves to actual file     |

---

## 3.8 LABS Product Types

> **Purpose:** Different governance levels for experimental projects.

| Type       | Governance Level | CLAUDE.md | SESSION_LOG | Conversations/ |
|------------|------------------|-----------|-------------|----------------|
| CODE       | Full             | Required  | Required    | Required       |
| RESEARCH   | Light            | Required  | Optional    | Optional       |
| PROTOTYPE  | Minimal          | Optional  | No          | No             |

### When to Use Each

| Type       | Use When                                          | Example                    |
|------------|---------------------------------------------------|----------------------------|
| CODE       | Production-ready, may be shared                   | google_extractor/          |
| RESEARCH   | Exploring ideas, may become CODE                  | ML experiments             |
| PROTOTYPE  | Quick test, likely to be deleted                  | One-off scripts            |

### LABS Folder Structure

```
LABS/
├── CLAUDE.md                    ← ROOT (index)
│
├── google_extractor/            ← CODE (full governance)
│   └── CLAUDE.md
│
├── research_project/            ← RESEARCH (light governance)
│   └── CLAUDE.md                ← Minimal, no symlinks
│
└── quick_test/                  ← PROTOTYPE (no governance)
    └── (no CLAUDE.md)
```

---

## 4. Governance Folder Structure

```
~/Desktop/Governance/
│
├── .claude/
│   └── settings.json              ← Hooks configuration
│
├── hooks/                         ← Hook scripts (5)
│   ├── check_boundaries.sh        ← PreToolUse
│   ├── inject_context.sh          ← SessionStart
│   ├── check_warmup.sh            ← Stop
│   ├── log_tool_use.sh            ← PostToolUse
│   └── save_session.sh            ← SessionEnd
│
├── bin/                           ← User scripts
│   └── cc                         ← Terminal capture wrapper
│
├── templates/                     ← Slim CLAUDE.md templates
│   ├── TEMPLATE_CODE.md           ← ~25 lines
│   ├── TEMPLATE_BIZZ.md           ← ~20 lines
│   └── TEMPLATE_OPS.md            ← ~25 lines
│
├── issues/                        ← Issue tracking
│   └── YYYYMMDD_*.md
│
├── Conversations/                 ← Auto-saved sessions
│   └── YYYYMMDD_HHMM.log
│
├── CLAUDE.md                      ← Minimal (this project)
├── CLAUDE_CODE_DOCS.md            ← Architecture reference
├── Claude-Code-Governance-Guide-v2.md
├── Claude-Code-Documentation-Map.md
├── GOVERNANCE_V1_VS_V2.md
├── V2_FULL_SPEC.md                ← This file
│
├── [see ~/Desktop/DataStoragePlan/]  ← Drive ops (now separate project)
│
└── v1_archive/                    ← Archived v1 files
```

---

## 5. Prompt Layers (9 Layers)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  LAYER 1: SYSTEM PROMPT                                                     │
│  ───────────────────────────────────────────────────────────────────────── │
│  Source:     Anthropic (hardcoded, hidden)                                  │
│  Content:    Core behavior (~5-10K tokens), tool definitions, safety        │
│  Control:    Anthropic only                                                 │
│  Governance: None (cannot modify)                                           │
├─────────────────────────────────────────────────────────────────────────────┤
│  LAYER 2: ENTERPRISE POLICY                                                 │
│  ───────────────────────────────────────────────────────────────────────── │
│  Source:     macOS: /Library/Application Support/ClaudeCode/CLAUDE.md       │
│              Linux: /etc/claude-code/CLAUDE.md                              │
│              Windows: C:\Program Files\ClaudeCode\CLAUDE.md                 │
│  Content:    Organization-wide mandatory instructions                       │
│  Control:    IT/Admin                                                       │
│  Governance: N/A (not used in personal setup)                               │
├─────────────────────────────────────────────────────────────────────────────┤
│  LAYER 3: USER MEMORY                                                       │
│  ───────────────────────────────────────────────────────────────────────── │
│  Source:     ~/.claude/CLAUDE.md                                            │
│  Content:    Global personal preferences, universal rules                   │
│  Control:    You                                                            │
│  Governance: Keep minimal (~30 lines), critical rules only                  │
│  v2 Action:  Move enforcement to hooks, keep only non-hookable rules        │
├─────────────────────────────────────────────────────────────────────────────┤
│  LAYER 4: PROJECT MEMORY                                                    │
│  ───────────────────────────────────────────────────────────────────────── │
│  Source:     ./CLAUDE.md or ./.claude/CLAUDE.md                             │
│  Content:    Project-specific instructions, boundaries                      │
│  Control:    You (committed to repo)                                        │
│  Governance: Minimal (~25 lines), boundaries only                           │
│  v2 Action:  CAN/CANNOT modify paths, link to full guide                    │
├─────────────────────────────────────────────────────────────────────────────┤
│  LAYER 5: PROJECT RULES                                                     │
│  ───────────────────────────────────────────────────────────────────────── │
│  Source:     .claude/rules/*.md                                             │
│  Content:    Modular, conditionally-loaded rules                            │
│  Control:    You (committed to repo)                                        │
│  Governance: Optional, use for complex projects                             │
│  v2 Action:  Not required for most projects                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│  LAYER 6: LOCAL PROJECT MEMORY                                              │
│  ───────────────────────────────────────────────────────────────────────── │
│  Source:     ./CLAUDE.local.md                                              │
│  Content:    Private project-specific preferences                           │
│  Control:    You (auto-added to .gitignore)                                 │
│  Governance: Session-specific overrides                                     │
│  v2 Action:  Use for temporary rules, experiments                           │
├─────────────────────────────────────────────────────────────────────────────┤
│  LAYER 7: CONVERSATION HISTORY                                              │
│  ───────────────────────────────────────────────────────────────────────── │
│  Source:     Session state (in-memory + ~/.claude/history.jsonl)            │
│  Content:    All messages, responses, tool outputs                          │
│  Control:    Dynamic (auto-managed)                                         │
│  Governance: Captured by `cc` wrapper, parsed by governance scripts         │
│  v2 Action:  Auto-capture via terminal recording                            │
├─────────────────────────────────────────────────────────────────────────────┤
│  LAYER 8: PLAN FILE                                                         │
│  ───────────────────────────────────────────────────────────────────────── │
│  Source:     ~/.claude/plans/*.md (when in Plan Mode)                       │
│  Content:    Current plan with checkboxes                                   │
│  Control:    Claude + You                                                   │
│  Governance: Auto-created by plan mode, survives crashes                    │
│  v2 Action:  Symlink PLAN.md to active plan file                            │
├─────────────────────────────────────────────────────────────────────────────┤
│  LAYER 9: CURRENT MESSAGE                                                   │
│  ───────────────────────────────────────────────────────────────────────── │
│  Source:     Your current prompt                                            │
│  Content:    What you just typed                                            │
│  Control:    You                                                            │
│  Governance: Processed by UserPromptSubmit hook (can inject context)        │
│  v2 Action:  Hook injects date, can validate/block                          │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Layer Priority (Highest → Lowest)

| Priority | Layer                | Override Behavior          |
|----------|----------------------|----------------------------|
| 1        | Enterprise Policy    | Overrides all below        |
| 2        | Project Memory       | Overrides user memory      |
| 3        | Project Rules        | Extends project memory     |
| 4        | User Memory          | Global defaults            |
| 5        | Local Memory         | Personal overrides         |

---

## 6. Daily Workflow (Master Index)

> **This section references all other sections.** Use it as your main guide.

### 6.0 Information Flow Overview

Before starting, understand how data flows: → **Section 7: Information Flows**

```
TOP-DOWN:  Governance → Projects → Sessions
BOTTOM-UP: Sessions → history.jsonl → Reports
CROSS:     Project A ↔ Governance ↔ Project B
```

---

### 6.1 DAY START

| Step | Action                          | Details                        |
|------|---------------------------------|--------------------------------|
| 1    | Open terminal                   | -                              |
| 2    | `cd ~/project`                  | Navigate to project            |
| 3    | `cc`                            | **→ Section 8: Terminal Capture** |
| 4    | Session starts                  | **→ Section 9: Hooks (SessionStart)** |
| 5    | Date/context injected           | Auto via `inject_context.sh`   |
| 6    | Read CLAUDE.md boundaries       | **→ Section 14: Templates**    |

**Hooks triggered:** `SessionStart` → `inject_context.sh`

**Suggested starting prompt:** `confirm date & boundaries. What are next steps?`

---

### 6.2 DURING SESSION

| Event                  | Trigger                    | Details                        |
|------------------------|----------------------------|--------------------------------|
| Edit/Write file        | `PreToolUse` hook          | **→ Section 9: Hooks**         |
| Boundary violation     | `check_boundaries.sh`      | Blocked (exit 2)               |
| Any tool completes     | `PostToolUse` hook         | Logged to audit trail          |
| Permission config      | `.claude/settings.json`    | **→ Section 10: Settings**     |

**Model switching:** Session-only switches via slash commands (no interruption):
- `/model haiku` - Fast, simple tasks
- `/model sonnet` - Balanced performance (default)
- `/model opus` - Complex reasoning, planning
- Takes effect immediately, does not persist to settings.json
- Status line shows current model and suggestion based on todos

**Context management:** When context fills up:
1. `/compact` - Summarize conversation to free context
2. After `/compact`, run: `touch ~/.claude/compact_flag`
   - Next hook invocation detects flag and resets token counter
   - **Why:** Prevents status line from showing inflated context %
   - **Status line will remind** when context ≥85%: `⚠️ /compact → touch ~/.claude/compact_flag`

**Status line monitoring:** → **Section 18.4: Status Line**

Always visible below input field. Format:
```
[Model] todos  |  🟢 Hooks  |  🟡 Context  |  Last tool  |  ✓ Warmup  ||  recommendations
```

**Follow recommendations (right side after `||`):**

| Recommendation | Action to Take |
|----------------|----------------|
| `⚠️ /compact → touch ~/.claude/compact_flag` | Run `/compact`, then run the touch command |
| `⚠️ Check hooks` | Verify `~/.claude/settings.json` has 6 hooks |
| `Warmup due` | Ask "provide warmup summary" |
| `⚠️ Long session (Xh)` | Consider wrap-up or break |
| `Session Xh` | Monitor for quality decline |
| `Consider /model opus` | Switch if working on complex task |
| `Consider /model haiku` | Switch if doing simple operations |
| `✓ All good` | Continue working normally |

**Mode selection:** → **Section 11: When to Use Each Mode**

| Situation              | Use Mode      | Result                         |
|------------------------|---------------|--------------------------------|
| Research/exploration   | Normal        | Direct interaction             |
| Multi-step task        | Plan Mode     | Creates plan file              |
| Quick single edit      | Accept Edits  | Auto-approve file changes      |

**Task management:** → **Section 12: TodoWrite Integration**

---

### 6.3 WORK LOOP

```
┌─────────────────────────────────────────────────────────────┐
│                        WORK LOOP                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   1. Receive task                                           │
│      └─→ Check boundaries (auto via hook)                   │
│                                                             │
│   2. Plan if complex                                        │
│      └─→ Plan Mode creates ~/.claude/plans/*.md             │
│      └─→ Section 11: When to Use Each Mode                  │
│                                                             │
│   3. Execute                                                │
│      └─→ PreToolUse checks boundaries                       │
│      └─→ PostToolUse logs action                            │
│                                                             │
│   4. Track progress                                         │
│      └─→ TodoWrite for 3+ step tasks                        │
│      └─→ Section 12: TodoWrite Integration                  │
│                                                             │
│   5. Check warm-up trigger                                  │
│      └─→ Stop hook checks timer                             │
│      └─→ Section 13: Warm-up Protocol                       │
│                                                             │
│   6. Loop back to 1                                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

### 6.4 WARM-UP (Periodic)

**Triggers:** → **Section 13: Warm-up Protocol**

| Trigger         | How                              |
|-----------------|----------------------------------|
| 90 minutes      | `Stop` hook timer                |
| Todos complete  | `PostToolUse` detects            |
| Manual          | User asks "provide warmup summary" |

**Actions:**
1. State current progress
2. List completed/remaining todos
3. Note blockers
4. Update timestamps

---

### 6.5 DOCUMENTATION

**During session, update as needed:**

| Document              | When                    | Details                        |
|-----------------------|-------------------------|--------------------------------|
| Decision IDs          | Major decisions         | **→ Section 15: Decision IDs** |
| CLAUDE.md boundaries  | If scope changes        | **→ Section 14: Templates**    |

---

### 6.6 ISSUES

**If unexpected behavior:** → **Section 16: Issue Protocol**

```
Detect → Log (issues/YYYYMMDD_*.md) → Debug → Fix → Prevent
```

---

### 6.7 GIT OPERATIONS

**When committing:** → **Section 17: Git Strategy**

| Action              | Convention                         |
|---------------------|------------------------------------|
| Commit message      | `type: description (#ID)`          |
| Branch naming       | `feature/name`, `fix/name`         |
| What to commit      | Code + CLAUDE.md, not logs         |

---

### 6.8 DAY WRAP

| Step | Action                          | Details                        |
|------|---------------------------------|--------------------------------|
| 1    | Final warm-up                   | State progress, blockers       |
| 2    | `exit` or `/quit`               | End Claude session             |
| 3    | `SessionEnd` hook fires         | **→ Section 9: Hooks**         |
| 4    | Session log finalized           | Moved to Conversations/        |
| 5    | Terminal recording stops        | `cc` wrapper saves log         |

**View session logs in terminal:**
1. With colors: `less -R Conversations/*.log`
2. Plain text: `sed 's/\x1b\[[0-9;]*m//g; s/\x1b\[[0-9;?]*[a-zA-Z]//g' Conversations/*.log | less`

**Scripts available:** → **Section 18: Scripts Reference**

---

## 7. Information Flows

### 7.1 TOP-DOWN Flow (Governance → Projects)

```
~/.claude/CLAUDE.md (L3: Global rules)
         │
         ▼
~/.claude/settings.json (Hooks config)
         │
         ▼
./CLAUDE.md (L4: Project boundaries)
         │
         ▼
Session (Rules enforced by hooks)
```

### 7.2 BOTTOM-UP Flow (Sessions → Governance)

```
Session activity
         │
         ├──► ~/.claude/history.jsonl (Auto-logged)
         │
         ├──► Conversations/*.log (Terminal capture)
         │
         ▼
    Learnings / Issues / Patterns
         │
         ├──► Project CLAUDE.md (boundary updates)
         ├──► _shared/DECISIONS.md (product decisions)
         ├──► Governance/issues/*.md (problem tracking)
         └──► Governance/templates/ (pattern → template)
                   │
                   ▼
         generate_decisions.sh (on-demand index)

         When to run:
  - Monthly audit
  - Before planning session
  - When searching for past decision
```

#### 7.2.1 Decision Propagation Table

| Decision Scope              | Where to Log                      | Where to Index                          |
|-----------------------------|-----------------------------------|-----------------------------------------|
| Single project              | `history.jsonl` + Conversations/  | Project CLAUDE.md (if boundary change)  |
| Same product, multi-project | `history.jsonl` + _shared/        | Product `_shared/DECISIONS.md`          |
| Cross-product               | `history.jsonl` + Governance      | `Governance/issues/` or templates/      |
| Company-wide                | `history.jsonl` + Governance      | `Governance/` + all affected CLAUDE.md  |

#### 7.2.2 Scenario Examples

| Scenario                          | Flow                              | Scope             | Example                                      |
|-----------------------------------|-----------------------------------|-------------------|----------------------------------------------|
| Feature issue → Business decision | Code SESSION → Bizz _shared/      | Same product      | Bug reveals pricing flaw → update strategy   |
| Technical blocker → Resource req  | Code SESSION → Governance         | Cross-product     | Need library → approve budget                |
| Pattern detected → Rule update    | Session analysis → CLAUDE.md      | Single project    | Same error 3x → add prevention rule          |
| Security issue → Policy change    | Any project → Governance          | Company-wide      | Vulnerability → update all boundaries        |
| Integration failure → API contract| Project A → _shared/              | Same product      | YutaAI API breaks → update contract          |
| Governance improvement            | Governance SESSION → templates/   | Company-wide      | Better workflow → update all templates       |

#### 7.2.3 Decision Index Strategy

**Decision (#G36):** No manual DECISIONS/ folder. Use auto-generated index.

| Approach            | Pros                | Cons                      | v2 Alignment                  |
|---------------------|---------------------|---------------------------|-------------------------------|
| DECISIONS/ folder   | Single source       | Manual updates, gets stale| ❌ Against "automate everything"|
| Decentralized only  | No maintenance      | Hard to find, no overview | ⚠️ Partial                    |
| **Auto-generated**  | Best of both        | Needs script              | ✅ Fits v2 philosophy          |

**Implementation:** `scripts/generate_decisions.sh`
- Parses `history.jsonl` + `issues/` for #G, #P, #I, #S, #B patterns
- Outputs: `Governance/DECISIONS_INDEX.md` (generated, not committed)
- Run on-demand when overview needed

### 7.3 CROSS-PROJECT Flow

```
Project A                    Governance                    Project B
    │                            │                            │
    └──── boundaries ───────────►│◄─────── boundaries ────────┘
                                 │
                        Shared hooks config
                        (~/.claude/settings.json)
```

### 7.4 Decision Type Quick Reference

> **Note:** See Section 7.2.1 for full propagation table.

| Decision Type    | Where Logged          | Action Required                    |
|------------------|-----------------------|------------------------------------|
| Global rule      | `~/.claude/CLAUDE.md` | Update Layer 3, affects all        |
| Project rule     | `./CLAUDE.md`         | Update Layer 4, this project only  |
| Session decision | `history.jsonl`       | Auto-logged, use #ID prefix        |
| Issue fix        | `issues/*.md`         | Update hooks/settings if needed    |
| Cross-project    | `_shared/`            | Notify affected projects           |

---

## 8. Terminal Capture (cc)

### 8.1 Script: bin/cc

**v2 Change:** Saves per-project, not globally.

```bash
#!/bin/bash
# cc - Claude with Conversation capture
# v2: Saves per-project to _governance/[project]/Conversations/
#     Falls back to Governance/Conversations/ if not in a governed project

CWD=$(pwd)
PROJECT=$(basename "$CWD")
TIMESTAMP=$(date +%Y%m%d_%H%M)

# Determine log location (per-project or global fallback)
determine_log_dir() {
    if [[ -d "../_governance/$PROJECT" ]]; then
        echo "../_governance/$PROJECT/Conversations"
    elif [[ -d "./_governance" ]]; then
        echo "./_governance/Conversations"
    elif [[ -f "./CLAUDE.md" ]]; then
        echo "./Conversations"
    else
        echo "$HOME/Desktop/Governance/Conversations"
    fi
}

LOG_DIR=$(determine_log_dir)
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/${TIMESTAMP}_${PROJECT}.log"

# Initialize session state
STATE_FILE="$HOME/.claude/governance_session.json"
cat > "$STATE_FILE" << EOF
{
  "start_time": $(date +%s),
  "last_warmup": $(date +%s),
  "project": "$CWD",
  "project_name": "$PROJECT",
  "log_file": "$LOG_FILE"
}
EOF

# macOS syntax
script -q "$LOG_FILE" claude $*
```

### 8.2 Log Location Priority

| Priority | Condition                      | Log Location                           |
|----------|--------------------------------|----------------------------------------|
| 1        | `../_governance/$PROJECT/`     | `../_governance/$PROJECT/Conversations/` |
| 2        | `./_governance/` exists        | `./_governance/Conversations/`         |
| 3        | `./CLAUDE.md` exists           | `./Conversations/`                     |
| 4        | Fallback                       | `~/Desktop/Governance/Conversations/`  |

### 8.3 Installation

```bash
chmod +x ~/Desktop/Governance/bin/cc
echo 'export PATH="$HOME/Desktop/Governance/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### 8.4 Usage

```bash
cd ~/my-project
cc                    # Start recording + claude
# ... work ...
exit                  # Auto-saves to Conversations/
```

---

## 9. Hooks Specification

### 9.0 Hook Output Format

**All hooks use colored prefixes for clarity:**

```
\033[36m[HOOK-NAME]\033[0m ▸▸▸ message
```

**Examples:**
- `[SESSION] ▸▸▸ Please confirm with user: Date: 2026-01-04...`
- `[BOUNDARY] ▸▸▸ BLOCKED: file.txt matches CANNOT modify: /etc/`
- `[WARMUP] ▸▸▸ ⏰ Warm-up due: 95m since last (90m threshold)`
- `[LOOP] ▸▸▸ LOOP: File edited 5 times in 10min. STOP and ask user.`

This format distinguishes hook messages from Claude responses.

### 9.0.1 Hook Visibility Strategy (Hybrid A+D)

**Problem:** Users need to know hooks are running, but don't want noise on every tool use.

**Solution:** Three-tier visibility:

| Tier | When | What User Sees | Hook(s) |
|------|------|----------------|---------|
| **Always** | Session start | Hook summary with count: `[HOOKS] ▸▸▸ 6 hooks active: ✓ SessionStart...` | inject_context.sh |
| **Always** | Status line | `🟢 Hooks: 6` (persistent below input field) | suggest_model.sh |
| **On Trigger** | Warning/Error | `[WARMUP] ▸▸▸ ⏰ Warm-up due...` or `[BOUNDARY] ▸▸▸ ⚠️ ERROR: ...` | All hooks |
| **Never** | Background | Silent logging, no output | log_tool_use.sh, save_session.sh |

**Error Handling:**
- All hooks check for `jq` dependency
- Critical hooks (check_boundaries, check_warmup) show `⚠️ ERROR:` if jq missing
- Non-critical hooks (log_tool_use, detect_loop) fail silently to avoid interruption
- Errors always use colored `[HOOK-NAME] ▸▸▸ ⚠️ ERROR:` format

**Decision (#G41):** Hybrid visibility provides confirmation without noise.

### 9.1 Hook Summary

| Hook           | Script                 | Trigger            | Purpose                  |
|----------------|------------------------|--------------------|--------------------------|
| `SessionStart` | `inject_context.sh`    | Session begins     | Inject date, env vars    |
| `PreToolUse`   | `check_boundaries.sh`  | Before Edit/Write  | Block violations         |
| `PostToolUse`  | `log_tool_use.sh`      | After any tool     | Audit trail + tokens     |
| `PostToolUse`  | `detect_loop.sh`       | After any tool     | Detect stuck loops       |
| `Stop`         | `check_warmup.sh`      | Claude stops       | Timer + context check    |
| `SessionEnd`   | `save_session.sh`      | Session ends       | Finalize logs            |

### 9.2 Hook: inject_context.sh (SessionStart)

```bash
#!/bin/bash
# hooks/inject_context.sh
cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "env": {
      "GOV_DATE": "$(date '+%Y-%m-%d')",
      "GOV_YEAR": "2026",
      "GOV_PROJECT": "$(basename $(pwd))"
    }
  }
}
EOF
```

### 9.3 Hook: check_boundaries.sh (PreToolUse)

```bash
#!/bin/bash
# hooks/check_boundaries.sh

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')
CWD=$(echo "$INPUT" | jq -r '.cwd')

CLAUDE_MD="$CWD/CLAUDE.md"
if [[ -f "$CLAUDE_MD" ]]; then
    CANNOT_MODIFY=$(grep "CANNOT modify:" "$CLAUDE_MD" | sed 's/.*CANNOT modify://' | xargs)

    for pattern in $CANNOT_MODIFY; do
        if [[ "$FILE" == *"$pattern"* ]]; then
            echo "BLOCKED: $FILE matches CANNOT modify: $pattern" >&2
            exit 2
        fi
    done
fi
exit 0
```

### 9.4 Hook: log_tool_use.sh (PostToolUse)

**Purpose:** Audit trail + token estimation + todo state tracking

**Key Features:**
1. Logs every tool use to `~/.claude/audit/tool_use.log`
2. Estimates tokens (~4 chars per token)
3. Tracks TodoWrite state for model suggestions
4. **Safety cap** prevents runaway accumulation

**Token Estimation with Safety Cap:**

```bash
# Estimate tokens from this interaction (~4 chars per token)
INPUT_LENGTH=${#INPUT}
ESTIMATED_TOKENS=$((INPUT_LENGTH / 4))

# Update token count in state file
CURRENT_TOKENS=$(jq -r '.token_count // 0' "$STATE_FILE")
NEW_TOKENS=$((CURRENT_TOKENS + ESTIMATED_TOKENS))

# Safety cap: Reset if exceeds 200K (likely accumulated from previous session)
# Actual sessions get summarized/compacted before reaching 200K
if [[ $NEW_TOKENS -gt 200000 ]]; then
    # Reset to estimated current interaction only
    NEW_TOKENS=$ESTIMATED_TOKENS
fi

# Update state file
jq --argjson tokens "$NEW_TOKENS" '.token_count = $tokens' "$STATE_FILE" > "$STATE_FILE.tmp"
```

**Why Safety Cap? (#G42)**
- Continued sessions (after `/compact`) don't reset `governance_session.json`
- Token count could accumulate beyond 200K limit
- Cap auto-resets to prevent status line showing >100%
- Sessions are compacted before truly reaching 200K anyway

**Output:** Silent (background logging only)

### 9.5 Hook: check_warmup.sh (Stop)

```bash
#!/bin/bash
# hooks/check_warmup.sh

STATE_FILE="$HOME/.claude/governance_session.json"
WARMUP_INTERVAL=5400  # 90 minutes

if [[ -f "$STATE_FILE" ]]; then
    LAST_WARMUP=$(jq -r '.last_warmup // 0' "$STATE_FILE")
    NOW=$(date +%s)
    ELAPSED=$((NOW - LAST_WARMUP))

    if [[ $ELAPSED -ge $WARMUP_INTERVAL ]]; then
        echo '{"decision":"block","reason":"Warm-up due: 90+ min since last update"}'
        exit 0
    fi
fi
echo '{"decision":"allow"}'
```

### 9.6 Hook: save_session.sh (SessionEnd)

```bash
#!/bin/bash
# hooks/save_session.sh

STATE_FILE="$HOME/.claude/governance_session.json"
if [[ -f "$STATE_FILE" ]]; then
    ARCHIVE="$HOME/.claude/sessions/$(date +%Y%m%d_%H%M%S).json"
    mkdir -p "$(dirname "$ARCHIVE")"
    mv "$STATE_FILE" "$ARCHIVE"
fi
```

### 9.7 Hook: detect_loop.sh (PostToolUse)

**Purpose:** Detect stuck loops (same file edited repeatedly, same error repeatedly)

**Thresholds:**
- Same file edited **5+ times** in 10 minutes → Warning
- Same error **3+ times** → Warning

**State:** `~/.claude/loop_state.json`

```json
{
  "file_edits": {
    "/path/to/file.js": {"count": 3, "first_edit": 1704384000}
  },
  "error_counts": {
    "Error: Cannot find module": 2
  },
  "last_cleanup": 1704384000
}
```

**Output on detection:**
```json
{
  "decision": "approve",
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "\033[36m[LOOP]\033[0m ▸▸▸ LOOP: File edited 5 times in 10min. STOP and ask user for direction."
  }
}
```

**Integration:** Added to PostToolUse hooks array in `~/.claude/settings.json`

---

## 10. Settings.json Configuration

### 10.1 Settings Strategy

**Decision (#G38):** Centralized permissions in global settings, hooks apply everywhere.

| Scope | File | Purpose | Use Case |
|-------|------|---------|----------|
| **Global** | `~/.claude/settings.json` | Permissions + Hooks | All allow rules, all hooks |
| **Project** | `.claude/settings.json` | Deny overrides only | Project-specific restrictions (rare) |
| **Local** | `.claude/settings.local.json` | **DEPRECATED** | Do not use in v2 |

### 10.2 Permissions Structure

```json
{
  "permissions": {
    "allow": [
      "Read(**)",
      "Glob(**)",
      "Grep(**)",
      "Edit(/Users/[username]/Desktop/FILICITI/**)",
      "Edit(/Users/[username]/Desktop/Governance/**)",
      "Write(/Users/[username]/Desktop/FILICITI/**)",
      "Write(/Users/[username]/Desktop/Governance/**)",
      "Bash(git:*)",
      "Bash(docker:*)",
      "Bash(mysql:*)",
      "Bash(python3:*)",
      "Bash(python:*)",
      "Bash(curl:*)",
      "Bash(npm:*)",
      "Bash(node:*)",
      "Bash(pip:*)",
      "Bash(pytest:*)",
      "Bash(ls:*)",
      "Bash(cat:*)",
      "Bash(head:*)",
      "Bash(tail:*)",
      "Bash(grep:*)",
      "Bash(find:*)",
      "Bash(xargs:*)",
      "Bash(chmod:*)",
      "Bash(mkdir:*)",
      "Bash(cp:*)",
      "Bash(mv:*)",
      "Bash(echo:*)",
      "Bash(wc:*)",
      "Bash(date:*)",
      "Bash(jq:*)",
      "Bash(sed:*)",
      "Bash(tr:*)",
      "Bash(du:*)",
      "Bash(zip:*)",
      "Bash(unzip:*)",
      "Bash(fold:*)",
      "Bash(pkill:*)",
      "WebSearch"
    ],
    "deny": [
      "Edit(/Volumes/**)",
      "Edit(/etc/**)",
      "Edit(/Users/[username]/Desktop/Governance/v1_archive/**)",
      "Write(/Volumes/**)",
      "Write(/etc/**)",
      "Write(/Users/[username]/Desktop/Governance/v1_archive/**)",
      "Bash(rm -rf:*)",
      "Bash(sudo:*)"
    ],
    "defaultMode": "dontAsk"
  }
}
```

### 10.3 Hooks Configuration

Location: `~/.claude/settings.json` (global)

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/Desktop/Governance/hooks/inject_context.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/Desktop/Governance/hooks/check_boundaries.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/Desktop/Governance/hooks/log_tool_use.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/Desktop/Governance/hooks/check_warmup.sh"
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/Desktop/Governance/hooks/save_session.sh"
          }
        ]
      }
    ]
  }
}
```

---

## 11. When to Use Each Mode

| Situation                  | Mode         | Trigger            | Result                    |
|----------------------------|--------------|--------------------|---------------------------|
| Research/exploration       | Normal       | Default            | Direct interaction        |
| Multi-step implementation  | Plan Mode    | `/plan` or auto    | Creates plan file         |
| Quick single-file fix      | Accept Edits | `Shift+Tab`        | Auto-approve edits        |
| Complex refactoring        | Plan + Todo  | `/plan` + TodoWrite| Full audit trail          |

### Plan Mode Details

| Aspect          | Behavior                                    |
|-----------------|---------------------------------------------|
| Trigger         | Complex task or explicit `/plan`            |
| Creates         | `~/.claude/plans/random-name.md`            |
| Survives crash  | Yes (file persists)                         |
| Exit            | `ExitPlanMode` tool                         |

### Accept Edits Mode

| Aspect          | Behavior                                    |
|-----------------|---------------------------------------------|
| Trigger         | `Shift+Tab` to cycle modes                  |
| Effect          | Auto-approve Edit/Write tools               |
| Risk            | Less review, faster execution               |
| Best for        | Trusted, small changes                      |

---

## 12. TodoWrite Integration

### When to Use

| Task Complexity | Use TodoWrite? |
|-----------------|----------------|
| 1-2 steps       | No             |
| 3+ steps        | Yes            |
| Multi-session   | Yes            |

### Sync Rules

| Event              | Action                               |
|--------------------|--------------------------------------|
| Create todos       | Match plan file checkboxes           |
| Complete todo      | Mark immediately (not batched)       |
| Session crash      | Plan file survives, todos lost       |
| Session resume     | Read plan file, recreate todos       |

### On Session Resume

```
1. Read ~/.claude/plans/*.md (most recent)
2. Parse [ ] and [x] checkboxes
3. Recreate TodoWrite state
4. Continue work
```

---

## 13. Warm-up Protocol

### Triggers

| Trigger         | Detection                         | Hook              |
|-----------------|-----------------------------------|-------------------|
| Time (90 min)   | `Stop` hook elapsed check         | `check_warmup.sh` |
| Todos complete  | `PostToolUse` on TodoWrite        | `check_warmup.sh` |
| Manual          | User asks "provide warmup summary" | None (just ask)  |

### Warm-up Actions

| Step | Action                                   |
|------|------------------------------------------|
| 1    | State current progress                   |
| 2    | List completed todos                     |
| 3    | List remaining todos                     |
| 4    | Note any blockers                        |
| 5    | Update `last_warmup` timestamp           |

### Output Example

```markdown
## Warm-up: 2026-01-03 14:30

**Progress:** 3/5 tasks complete

**Done:**
- [x] Archive v1 files
- [x] Create comparison doc
- [x] Discuss recommendations

**Remaining:**
- [ ] Implement v2
- [ ] Test v2

**Blockers:** None
```

---

## 14. CLAUDE.md Templates

### Template: CODE (~25 lines)

```markdown
# [Project Name]

> **Type:** CODE | **Updated:** YYYY-MM-DD

## Boundaries

- **CAN modify:** `src/`, `tests/`, `docs/`
- **CANNOT modify:** `node_modules/`, `.env`, `*.lock`

## Critical Rules

1. Run tests before commit
2. No secrets in code

## Links

- Governance: `~/Desktop/Governance/`
- Full guide: `Claude-Code-Governance-Guide-v2.md`
```

### Template: BIZZ (~20 lines)

```markdown
# [Project Name]

> **Type:** BIZZ | **Updated:** YYYY-MM-DD

## Boundaries

- **CAN modify:** `docs/`, `plans/`, `research/`
- **CANNOT modify:** `financials/`, `contracts/`

## Critical Rules

1. Date format: YYYY-MM-DD
2. Decision IDs: #[A-Z][0-9]+

## Links

- Governance: `~/Desktop/Governance/`
```

### Template: OPS (~25 lines)

```markdown
# [Project Name]

> **Type:** OPS | **Updated:** YYYY-MM-DD

## Boundaries

- **CAN modify:** `scripts/`, `config/`, `docs/`
- **CANNOT modify:** System files, `/etc/`

## Critical Rules

1. Log all operations
2. Backup before destructive actions

## Links

- Governance: `~/Desktop/Governance/`
```

---

## 15. Decision ID System

### 15.1 Design Decision (#G39)

**v1 had two systems:**
- Project scope: `#P` (project), `#PR` (product), `#G` (company)
- Category prefixes: `#I`, `#S`, `#B`, `#G`, `#P`

**v2 consolidation:** Single global system by **category**, not scope.

| Approach | Pros | Cons | Decision |
|----------|------|------|----------|
| Scope-based (#P, #PR, #G) | Shows where decision applies | Confusing, #P conflicts | ❌ Deprecated |
| Category-based (#G, #I, #S, #B, #P) | Clear what decision is about | Need context for scope | ✅ v2 Standard |

### 15.2 Prefixes (Global)

| Prefix | Category        | Scope        | Example                          |
|--------|-----------------|--------------|----------------------------------|
| `#G`   | Governance      | Company-wide | `#G30` - Hooks over CLAUDE.md    |
| `#P`   | Process         | Any          | `#P1` - Weekly backup verify     |
| `#I`   | Infrastructure  | Any          | `#I1` - Use Backblaze            |
| `#S`   | Security        | Any          | `#S1` - Encrypt all backups      |
| `#B`   | Backup          | Any          | `#B1` - 3-2-1 strategy           |

**Note:** Scope is indicated in the decision description, not the prefix.

**Examples:**
- `#G40` - "COEVOLVE: Use Docker for local dev" (project-specific governance)
- `#I5` - "FlowInLife: Deploy to Railway" (project-specific infra)
- `#S3` - "All projects: No secrets in code" (company-wide security)

### 15.3 Usage

| Where               | Format                           |
|---------------------|----------------------------------|
| Commit message      | `fix: resolve issue (#G30)`      |
| Issue files         | Reference in resolution          |
| Warm-up output      | Include in progress summary      |
| Spec updates        | Inline decision markers          |

### 15.4 Numbering

- **Global sequence:** Single counter across all projects
- **Current highest:** `#G39` (this section)
- **Lookup:** Use `generate_decisions.sh` to find all IDs

---

## 16. Issue Protocol

### Lifecycle

```
Detect → Log → Debug → Fix → Prevent → Close
```

### Steps

| Step    | Action                              | Output                 |
|---------|-------------------------------------|------------------------|
| Detect  | Notice unexpected behavior          | Mental note            |
| Log     | Create `issues/YYYYMMDD_*.md`       | Issue file             |
| Debug   | Check settings, hooks, history      | Root cause             |
| Fix     | Update settings/hooks/docs          | Code change            |
| Prevent | Add test or hook                    | Prevention             |
| Close   | Mark resolved                       | Updated issue          |

### Issue Template

```markdown
# Issue: YYYYMMDD_short_name

**Status:** Open | Fixed | Closed

## Symptom
[What happened]

## Context
- Project: [name]
- Action: [what you were doing]

## Root Cause
[Why it happened]

## Fix
[What was changed]

## Prevention
[Hook/test added]
```

---

## 17. Git Strategy

### Branch Naming

| Type    | Format              | Example              |
|---------|---------------------|----------------------|
| Feature | `feature/name`      | `feature/add-hooks`  |
| Fix     | `fix/name`          | `fix/boundary-check` |
| Docs    | `docs/name`         | `docs/update-spec`   |

### Commit Convention

```
type: description (#ID)

types: feat, fix, docs, refactor, test, chore
```

### What to Commit

| Commit              | Don't Commit               |
|---------------------|----------------------------|
| Code changes        | `Conversations/*.log`      |
| CLAUDE.md           | `.claude/sessions/`        |
| hooks/*.sh          | `issues/` (optional)       |
| templates/          | Personal notes             |

### .gitignore Template

```
# Governance
Conversations/
.claude/sessions/
*.log

# Local
CLAUDE.local.md
.claude/settings.local.json
```

---

## 18. Scripts Reference

### 18.1 Hooks (Auto-triggered)

| Script                | Hook           | Purpose                              |
|-----------------------|----------------|--------------------------------------|
| `inject_context.sh`   | SessionStart   | Inject date, env vars                |
| `check_boundaries.sh` | PreToolUse     | Block violations                     |
| `log_tool_use.sh`     | PostToolUse    | Audit trail + token tracking + todos |
| `detect_loop.sh`      | PostToolUse    | Detect stuck loops (file edits, errors) |
| `check_warmup.sh`     | Stop           | Timer + context monitoring           |
| `save_session.sh`     | SessionEnd     | Finalize logs                        |

### 18.2 User Scripts (bin/)

| Script | Purpose                              |
|--------|--------------------------------------|
| `cc`   | Terminal capture + claude launcher   |

### 18.3 Governance Scripts (scripts/)

| Script                | Purpose                              | Trigger        |
|-----------------------|--------------------------------------|----------------|
| `check_protocol.sh`   | Validate protocol steps followed     | Manual or hook |
| `suggest_model.sh`    | Analyze todos, suggest model         | StatusLine     |
| `generate_decisions.sh` | Create decision index from history | On-demand      |

### 18.4 Status Line (Enhanced v2.1)

**Decision (#G45):** Interactive model tracking + context calibration.

**Format:** `Model: [X] | todos | Hooks | Context | Warmup || recommendations`

**Full Example:**
```
Model: [Opus] | 3/7 todos | 🟢 Hooks: 6 | 🟢 Context: ~97K | 🟢 Warmup: 45m || ✓ All good
```

**Components:**

| Component       | Example              | Description                                      |
|-----------------|----------------------|--------------------------------------------------|
| Model           | `Model: [Opus]`      | User-confirmed model (? if not confirmed)        |
| Todos           | `3/7 todos`          | Done/total from `~/.claude/todo_state.json`      |
| Hooks Health    | `🟢 Hooks: 6`        | Number of active hooks with color indicator      |
| Context         | `🟢 Context: ~97K`   | Calibrated estimate (~ prefix = approximate)     |
| Warmup Timer    | `🟢 Warmup: 45m`     | Minutes since last warmup                        |
| Recommendations | `✓ All good`         | Priority-based actionable suggestions            |

**Color Indicators:**

| Indicator | Meaning | Thresholds |
|-----------|---------|------------|
| 🟢 Hooks | All hooks active | 6+ hooks configured |
| 🟡 Hooks | Some hooks active | 3-5 hooks configured |
| 🔴 Hooks | Missing hooks | <3 hooks configured |
| 🟢 Context | Low usage | <70% of 200K tokens |
| 🟡 Context | High usage | 70-84% of 200K tokens |
| 🔴 Context | Critical usage | ≥85% of 200K tokens |

**Smart Recommendations (Priority-Based):**

| Priority     | Condition              | Recommendation                     |
|--------------|------------------------|------------------------------------|
| 🔴 Critical  | Model not confirmed    | `Confirm model (/status)`          |
| 🔴 Critical  | Context ≥85%           | `⚠️ /compact → touch ~/.claude/compact_flag` |
| 🔴 Critical  | Hooks <3               | `⚠️ Check hooks`                   |
| 🟡 Warning   | Calibration due (30m)  | `Check /context`                   |
| 🟡 Warning   | Warmup ≥90min          | `Warmup due`                       |
| 🟡 Warning   | Session ≥8h            | `⚠️ Long session (Xh)`             |
| 🟡 Warning   | Session ≥4h            | `Session Xh`                       |
| 🟢 Info      | High complexity todos  | `Consider /model opus`             |
| 🟢 Info      | Low complexity todos   | `Consider /model haiku`            |
| 🟢 None      | All metrics good       | `✓ All good`                       |

**Multiple Recommendations:**
- Show up to 3 joined by ` | `
- If >3: show first 2 + count `(+N)`
- Separated from metrics by ` || `

**Examples by State:**
```bash
# Session start (model not confirmed):
Model: [?] | No todos | 🟢 Hooks: 6 | 🟢 Context: ~0K (uncalibrated) | 🟢 Warmup: 0m || Confirm model (/status)

# After model confirmed:
Model: [Opus] | 3/7 todos | 🟢 Hooks: 6 | 🟢 Context: ~45K | 🟢 Warmup: 15m || ✓ All good

# Calibration reminder (30m since last):
Model: [Opus] | 5/7 todos | 🟢 Hooks: 6 | 🟢 Context: ~65K | 🟢 Warmup: 35m || Check /context

# Critical context:
Model: [Opus] | 3/7 todos | 🟢 Hooks: 6 | 🔴 Context: ~140K | 🟢 Warmup: 30m || ⚠️ /compact → touch ~/.claude/compact_flag

# Multiple warnings:
Model: [Sonnet] | 2/5 todos | 🟡 Hooks: 4 | 🟡 Context: ~95K | 🔴 Warmup: 92m || Warmup due | Check hooks

# All good:
Model: [Opus] | 6/7 todos | 🟢 Hooks: 6 | 🟢 Context: ~55K | 🟢 Warmup: 20m || ✓ All good
```

**Configuration** (`~/.claude/settings.json`):
```json
{
  "statusLine": {
    "type": "command",
    "command": "/path/to/Governance/scripts/suggest_model.sh"
  }
}
```

### 18.5 Model & Context Tracking

**Interactive Model Tracking (#G45):**

Claude Code doesn't expose the current model to hooks, so we use interactive tracking:

1. Session start: Show `Model: [?]` with recommendation "Confirm model (/status)"
2. User runs `/status` and tells Claude: "I'm on Opus"
3. Claude updates state file with confirmed model
4. User switches model and tells Claude: "I switched to Haiku"
5. Claude updates state and tracks history

**State file** (`~/.claude/sessions/{hash}_session.json`):
```json
{
  "model": "Opus",
  "model_history": [
    {"model": "Opus", "at": 1704384000, "source": "user"},
    {"model": "Haiku", "at": 1704387600, "source": "user"}
  ]
}
```

**Context Calibration (#G46):**

Actual token count is internal to Claude Code. We use calibration:

1. Script estimates tokens from tool use (~4 chars/token)
2. Every 30 minutes: Recommendation "Check /context"
3. User runs `/context` and tells Claude: "Context shows 97K"
4. Claude calculates factor: `actual / estimated` (e.g., 97000 / 22000 = 4.4)
5. Future estimates multiplied by factor for accuracy

**State file** (per-project, persistent):
```json
{
  "token_count": 22000,
  "context_factor": 4.4,
  "last_calibration": 1704384000,
  "context_calibrations": [
    {"estimated": 22000, "actual": 97000, "factor": 4.4, "at": 1704384000}
  ]
}
```

**Display:** `Context: ~97K` (~ indicates calibrated approximation)

**Todo Detection:**

Reads from Claude Code's actual todo state:
- **Source:** `~/.claude/todo_state.json` (not per-project hash file)
- **Filter:** Only shows todos where `project` matches current `pwd`
- **Format:** `3/7 todos` (done/total)

**Complexity Analysis:**

| Todo Keywords                                                              | Complexity | Suggested Model |
|----------------------------------------------------------------------------|------------|-----------------|
| plan, design, architect, refactor, debug, fix, investigate, migrate, complex | High       | Opus            |
| (default)                                                                  | Medium     | Sonnet          |
| check, find, list, read, search, simple, quick, verify                     | Low        | Haiku           |

**State Files (Per-Project #G43):**

```
~/.claude/sessions/
└── {project_hash}_session.json  ← Model, context factor, warmup, timestamps
~/.claude/todo_state.json        ← Claude Code's actual todos (single file)
```

### 18.6 Protocol Checking

**Script:** `scripts/check_protocol.sh [CODE|BIZZ|OPS]`

**Common checks (all types):**
- 1.0 Session initialized
- 1.1 Boundaries defined
- 2.x TodoWrite used
- 9.0 Warm-up performed

**Type-specific checks:**

| Check | CODE | BIZZ | OPS |
|-------|------|------|-----|
| Tests executed | Required | N/A | N/A |
| Git commit | Required | Optional | Required |
| Decision IDs | Optional | Required | Optional |
| Operations logged | N/A | N/A | Required |

### 18.7 Optional Scripts (from v1)

| Script                     | Keep?  | Purpose                    |
|----------------------------|--------|----------------------------|
| `governance_test.sh`       | Yes    | Structure validation       |
| `governance_report.sh`     | Yes    | Generate reports           |
| `governance_claude_sync.sh`| Yes    | Parse history.jsonl        |
| `prompt_monitor.sh`        | Yes    | Show layer sizes           |
| `governance_audit.sh`      | No     | Replaced by hooks          |
| `governance_watch.sh`      | No     | Replaced by Stop hook      |

---

## 19. Testing Methods

### 19.1 Testing Architecture (v2)

```
┌─────────────────────────────────────────────────────────────────────┐
│                    V2 GOVERNANCE TESTING                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Layer 1: STRUCTURE              Layer 2: HOOKS                     │
│  (governance_test.sh)            (Manual + Auto)                    │
│  ──────────────────              ─────────────────                  │
│  • CLAUDE.md exists?             • 5 hooks active?                  │
│  • Boundaries defined?           • Boundary blocking?               │
│  • Symlinks work?                • Warm-up timer?                   │
│  • Conversations/ exists?        • Session capture?                 │
│                                                                     │
│  [RUN: per-migration]            [RUN: per-session]                 │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Layer 3: REPORTING              Layer 4: .CLAUDE/ INTEGRATION      │
│  (governance_report.sh)          (governance_claude_sync.sh)        │
│  ─────────────────────           ──────────────────────────────     │
│  • Combine scores                • Parse history.jsonl              │
│  • Project scorecards            • TodoWrite ↔ Plan sync            │
│  • Export results                • Session tracking                 │
│                                                                     │
│  [RUN: on-demand]                [RUN: per-session]                 │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

**v1 → v2 Changes:**
- Layer 2 (Process/Audit) → Replaced by hooks
- Layer 3 (Runtime Watch) → Replaced by Stop hook
- Simplified to 4 layers

---

### 19.2 Scoring System

#### Goals & Weights (v2)

| Goal | Description | Weight | v1 Equivalent |
|------|-------------|--------|---------------|
| G1   | CLAUDE.md exists with boundaries | 30% | Was 20% |
| G2   | Symlinks work correctly | 25% | Was 20% |
| G3   | Hooks active (5 hooks in settings.json) | 25% | Was pre-commit 15% |
| G4   | Layer 3 (~/.claude/CLAUDE.md) exists | 10% | Same |
| G5   | Conversations/ directory exists | 10% | NEW |

**Removed from v1:**
- ~~G2: CONTEXT.md~~ → Replaced by warm-up protocol
- ~~G3: SESSION_LOG.md~~ → Replaced by history.jsonl
- ~~G7: PLAN.md~~ → Auto-managed by ~/.claude/plans/

#### Pass/Fail Criteria

| Result | Score | Action |
|--------|-------|--------|
| **PASS** | ≥ 80% | Migration approved |
| **FAIL** | < 80% | Fix issues, re-test |

#### Scoring Logic

| Score | Meaning |
|-------|---------|
| 100%  | Full compliance |
| 50%   | Partial (exists but incomplete) |
| 0%    | Missing or broken |

---

### 19.3 Test Categories

| Category         | What to Test                    | How                    |
|------------------|---------------------------------|------------------------|
| Structure        | Files/folders exist             | `governance_test.sh`   |
| Hook execution   | Each hook runs                  | Manual trigger         |
| Boundary block   | Violations blocked              | Edit blocked file      |
| Warm-up trigger  | Timer works                     | Wait or simulate       |
| Terminal capture | Sessions saved                  | Run `cc`, check output |
| E2E              | Full workflow                   | Complete session       |

---

### 19.4 Test Commands

```bash
# Test boundary hook
echo '{"tool_name":"Edit","tool_input":{"file_path":"/etc/passwd"},"cwd":"'$(pwd)'"}' | ./hooks/check_boundaries.sh; echo "Exit: $?"

# Test session start
./hooks/inject_context.sh

# Test warmup check
./hooks/check_warmup.sh

# Test tool logging
echo '{"tool_name":"Read","cwd":"'$(pwd)'"}' | ./hooks/log_tool_use.sh

# Test structure (when script exists)
./scripts/governance_test.sh ~/Desktop/FILICITI/Products/COEVOLVE/code
```

---

### 19.5 JSON Output Format

```json
{
  "project": "COEVOLVE/code",
  "path": "/Users/.../COEVOLVE/code",
  "date": "2026-01-03T12:00:00",
  "score": 85,
  "threshold": 80,
  "result": "PASS",
  "breakdown": {
    "claude_md": 100,
    "symlinks": 100,
    "hooks": 70,
    "layer3": 100,
    "conversations": 50
  }
}
```

---

### 19.6 Migration Gate

**Rule:** Projects must pass governance tests before old folders can be deleted.

```
1. Copy project to FILICITI/
2. Setup _governance/ + symlinks
3. Run: ./scripts/governance_test.sh [project]
4. If PASS → Mark migrated
5. If FAIL → Fix issues, re-test
6. Delete old folder ONLY after PASS + user approval
```

---

### 19.7 Verification Checklists

#### Pre-Migration

| # | Check | Status |
|---|-------|--------|
| 1 | Source project exists | [ ] |
| 2 | Correct type identified (CODE/BIZZ/ROOT) | [ ] |
| 3 | FILICITI target ready | [ ] |

#### Post-Migration

| # | Check | Status |
|---|-------|--------|
| 1 | `governance_test.sh` returns PASS (≥80%) | [ ] |
| 2 | Can open project with `cc` | [ ] |
| 3 | CLAUDE.md loads correctly | [ ] |
| 4 | Symlinks resolve (not broken) | [ ] |
| 5 | Conversations/ directory exists | [ ] |

#### Hook Verification

| # | Test                        | Expected            | Pass |
|---|-----------------------------|---------------------|------|
| 1 | Run `cc`                    | Recording starts    | [ ]  |
| 2 | Edit CAN file               | Allowed             | [ ]  |
| 3 | Edit CANNOT file            | Blocked (exit 2)    | [ ]  |
| 4 | Check audit log             | Tool logged         | [ ]  |
| 5 | Exit session                | Log saved           | [ ]  |
| 6 | Wait 90 min                 | Warm-up reminder    | [ ]  |

#### Final Cleanup

| # | Check | Status |
|---|-------|--------|
| 1 | All projects score ≥ 80% | [ ] |
| 2 | User approved deletion of old folders | [ ] |

---

## 20. Troubleshooting

### Common Issues

| Issue                          | Cause                        | Fix                           |
|--------------------------------|------------------------------|-------------------------------|
| Hook not running               | Path wrong in settings.json  | Use absolute path             |
| Boundary not blocking          | Pattern mismatch             | Check CANNOT modify syntax    |
| Permission still asked         | Tool not in allowlist        | Update settings.json          |
| `cc` not found                 | Not in PATH                  | Add bin/ to PATH              |
| Warm-up not triggering         | State file missing           | Check governance_session.json |

### Debug Steps

1. Check hook exists: `ls ~/Desktop/Governance/hooks/`
2. Check settings: `cat ~/.claude/settings.json`
3. Check state: `cat ~/.claude/governance_session.json`
4. Check audit: `cat ~/.claude/audit/tool_use.log`
5. Test hook manually: `echo '{}' | ./hooks/hook_name.sh`

---

## 21. Quick Reference

### Commands

| Command        | Purpose                      |
|----------------|------------------------------|
| `cc`           | Start session with recording |
| `exit`         | End session                  |
| `Shift+Tab`    | Cycle permission modes       |
| `/plan`        | Enter plan mode              |
| `/help`        | Show help                    |

### Files

| File                          | Purpose                |
|-------------------------------|------------------------|
| `~/.claude/settings.json`     | Global hooks config    |
| `~/.claude/CLAUDE.md`         | Global rules (L3)      |
| `./CLAUDE.md`                 | Project rules (L4)     |
| `~/.claude/history.jsonl`     | Session history        |
| `~/.claude/plans/*.md`        | Plan files             |

### Folders

| Folder                              | Purpose              |
|-------------------------------------|----------------------|
| `~/Desktop/Governance/hooks/`       | Hook scripts         |
| `~/Desktop/Governance/bin/`         | User scripts         |
| `~/Desktop/Governance/Conversations/`| Session logs        |
| `~/Desktop/Governance/issues/`      | Issue tracking       |

### Decision ID Prefixes

| Prefix | Category       |
|--------|----------------|
| `#G`   | Governance     |
| `#P`   | Process        |
| `#I`   | Infrastructure |
| `#S`   | Security       |
| `#B`   | Backup         |

---

## 22. Risk Analysis

### 22.1 Risk Register

| ID  | Risk                            | Impact | Likelihood | v2 Mitigation                          |
|-----|--------------------------------|--------|------------|----------------------------------------|
| R1  | Boundary violation             | HIGH   | MEDIUM     | `check_boundaries.sh` blocks (exit 2)  |
| R2  | Wrong date used                | MEDIUM | HIGH       | `inject_context.sh` + session start confirm |
| R3  | Session context lost           | HIGH   | LOW        | `cc` terminal capture + history.jsonl  |
| R4  | Forgotten warm-ups             | MEDIUM | MEDIUM     | `check_warmup.sh` 90-min timer         |
| R5  | Governance files committed     | LOW    | MEDIUM     | .gitignore in code repos               |
| R6  | Symlinks broken                | MEDIUM | LOW        | Test script validates symlinks         |
| R7  | Hook script fails              | HIGH   | LOW        | Test before deploy, error logging      |
| R8  | Settings.json corrupted        | HIGH   | LOW        | Backup in templates/settings.json      |

### 22.2 v1 → v2 Risk Comparison

| Risk | v1 Mitigation          | v2 Mitigation                    | Improvement       |
|------|------------------------|----------------------------------|-------------------|
| R1   | CLAUDE.md text (advisory) | Hook blocks before action      | **Enforced**      |
| R2   | User remembers         | Auto-inject + confirm prompt     | **Automated**     |
| R3   | Manual copy/paste      | Auto-capture via `cc`            | **Automated**     |
| R4   | User remembers         | Timer hook blocks after 90 min   | **Automated**     |
| R5   | Manual .gitignore      | Template .gitignore              | Same              |
| R6   | Manual check           | Test script                      | **Automated**     |
| R7   | N/A                    | Test + fallback                  | New (hooks new)   |
| R8   | N/A                    | Backup + template                | New (settings new)|

### 22.3 Residual Risks

| Risk               | Why Remains                              | Acceptable? |
|--------------------|------------------------------------------|-------------|
| Hook bypass        | User can disable hooks in settings.json  | Yes (intentional) |
| Pattern mismatch   | CANNOT modify patterns can be wrong      | Yes (user error)  |
| cc not used        | User can run `claude` directly           | Yes (opt-in)      |

### 22.4 Disaster Recovery

| Scenario                    | Recovery Steps                                           |
|-----------------------------|----------------------------------------------------------|
| Session crash               | 1. Check `~/.claude/history.jsonl` 2. Check `Conversations/` |
| Settings corrupted          | Copy from `templates/settings_backup.json`               |
| Hook script deleted         | Re-create from V2_FULL_SPEC.md Section 9                 |
| Symlinks broken             | Run `scripts/setup_governance_symlinks.sh`               |
| Wrong boundaries committed  | Git revert, fix CLAUDE.md, recommit                      |

---

## 23. Migration Guide (v1 → v2)

> **Purpose:** Checklist and reasoning for migrating projects from v1 to v2 governance.

### 23.1 Pre-Migration Validation

| Check | Command | Pass Criteria |
|-------|---------|---------------|
| v2 Governance folder exists | `ls ~/Desktop/Governance/hooks/` | 5 hook scripts present |
| Global settings configured | `cat ~/.claude/settings.json` | Hooks + permissions defined |
| Target structure ready | `ls ~/Desktop/FILICITI/Products/` | Product folder exists |

### 23.2 Files to DELETE

| v1 File | Reason | v2 Replacement |
|---------|--------|----------------|
| `CONTEXT.md` | Manual status tracking obsolete | Warm-up protocol via hooks |
| `SESSION_LOG.md` | Manual logging obsolete | `~/.claude/history.jsonl` (auto) |
| `PLAN.md` | Manual plan tracking obsolete | `~/.claude/plans/*.md` (auto) |
| `10_Thought_Process/` | Old conversation folder | `Conversations/` via `cc` wrapper |
| `.claude/settings.local.json` | Project-level permissions | Merged to global `~/.claude/settings.json` |

### 23.3 Files to SLIM

| v1 File | v1 Size | v2 Size | What to Remove |
|---------|---------|---------|----------------|
| `CLAUDE.md` | 150-230 lines | ~20-25 lines | Workflow, Decision IDs, Folder docs, Key files, Git format, SESSION_LOG template, Feature sizing |

**v2 CLAUDE.md keeps only:**
- Type declaration
- Boundaries (CAN/CANNOT modify)
- 2-3 critical rules
- Links to Governance

### 23.4 Content Disposition Table

| v1 Content | v2 Location | Reasoning |
|------------|-------------|-----------|
| Workflow (Discuss→Plan→Execute) | `Governance/V2_FULL_SPEC.md` §6 | Centralized, same for all projects |
| Decision ID prefixes | `Governance/V2_FULL_SPEC.md` §15 | Global system, not per-project |
| Folder structure docs | **DELETE** or `README.md` | Not governance, optional dev docs |
| Key files table | **DELETE** | Self-documenting via code |
| Git commit format | `~/.claude/CLAUDE.md` (Layer 3) | Global rule, same for all |
| SESSION_LOG template | **DELETE** | Replaced by `history.jsonl` |
| Current status/progress | **DELETE** | Replaced by warm-up protocol |
| Feature sizing (XS/S/M/L) | **DELETE** or `Governance/` | Optional, not core governance |

### 23.5 Settings Migration

**Decision (#G37):** Project `.claude/settings.local.json` files are deprecated in v2.

| v1 Approach | v2 Approach | Reasoning |
|-------------|-------------|-----------|
| Per-project permissions | Global `~/.claude/settings.json` | Centralized, wildcard patterns cover all |
| Project-specific denies | Project `.claude/settings.json` (deny only) | Rare, only for special restrictions |
| Hardcoded commands | Wildcard patterns (`Bash(git:*)`) | Cleaner, covers all variants |

**Migration steps:**
1. Review project `.claude/settings.local.json`
2. Check if patterns covered by global wildcards
3. If unique pattern needed → add to global
4. Delete project settings file

### 23.6 Files to CREATE

| File/Folder | Location | Purpose |
|-------------|----------|---------|
| `_governance/` | Product root | Private governance files |
| `_governance/[project]/CLAUDE.md` | Per project | Actual CLAUDE.md (symlinked) |
| `_governance/[project]/Conversations/` | Per project | Session logs from `cc` |
| `CLAUDE.md` symlink | Project root | Points to `_governance/` |
| `.gitignore` update | Code project | Ignore `CLAUDE.md` symlink |

### 23.7 Migration Checklist Template

Copy this checklist for each project migration:

```markdown
## Migration: [PROJECT_NAME] v1 → v2

**Date:** YYYY-MM-DD
**Source:** ~/Desktop/[old_location]/
**Target:** ~/Desktop/FILICITI/Products/[product]/[project]/

### Pre-Migration
- [ ] Backup source folder
- [ ] Confirm target structure exists
- [ ] Read v1 CLAUDE.md for project-specific rules

### DELETE
- [ ] CONTEXT.md
- [ ] SESSION_LOG.md
- [ ] PLAN.md
- [ ] 10_Thought_Process/ (or old conversations folder)
- [ ] .claude/settings.local.json

### SLIM
- [ ] CLAUDE.md: [old_lines] → ~20 lines

### CREATE
- [ ] _governance/[project]/ folder
- [ ] _governance/[project]/CLAUDE.md (minimal)
- [ ] _governance/[project]/Conversations/
- [ ] Symlink: project/CLAUDE.md → _governance/
- [ ] .gitignore updated (if code project)

### VALIDATE
- [ ] `cc` starts correctly in project
- [ ] CLAUDE.md boundaries displayed
- [ ] Can edit CAN files
- [ ] Cannot edit CANNOT files
- [ ] Conversations/ receives logs

### POST-MIGRATION
- [ ] Delete source folder (after 1 day validation)
```

---

## Implementation Checklist

| #  | Task                              | Dependency | Status |
|----|-----------------------------------|------------|--------|
| 1  | Create `hooks/` folder            | None       | [x]    |
| 2  | Create 5 hook scripts             | 1          | [x]    |
| 3  | Create `bin/cc`                   | None       | [x]    |
| 4  | Create `.claude/settings.json`    | 2          | [x]    |
| 5  | Create `templates/`               | None       | [x]    |
| 6  | Create `issues/`                  | None       | [x]    |
| 7  | Create `Conversations/`           | None       | [x]    |
| 8  | Create minimal `CLAUDE.md`        | 5          | [x]    |
| 9  | Test all hooks                    | 1-4        | [x]    |
| 10 | Test full workflow                | All        | [ ]    |
| 11 | Update cc for per-project logs    | 7          | [x]    |
| 12 | Create _governance/ symlinks      | None       | [x]    |
| 13 | Expand v2 TESTING section         | None       | [x]    |
| 14 | Delete old FILICITI, create new   | None       | [x]    |
| 15 | Migrate COEVOLVE (pilot)          | 14         | [x]    |
| 16 | Test COEVOLVE for 1 day           | 15         | [ ]    |
| 17 | Migrate FlowInLife                | 16         | [ ]    |
| 18 | Migrate LABS                      | 16         | [ ]    |

---

*Specification created: 2026-01-03*
*Implementation started: 2026-01-03*
*COEVOLVE pilot migrated: 2026-01-03*
*Status: PILOT TESTING - Test COEVOLVE for 1 day before expanding*
