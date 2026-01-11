# Code Project Documentation System (v3)

> **Type:** Reference / Governance
> **Version:** 3.0
> **Created:** 2026-01-11
> **Purpose:** Standard documentation structure for all CODE-type projects
> **Applies To:** fil-yuta, COEVOLVE, and all future coding projects

---

## Table of Contents

| Section | Title                                                                          | Line   |
|---------|--------------------------------------------------------------------------------|--------|
| 1       | [Overview](#1-overview)                                                        | :38    |
| 2       | [Directory Structure](#2-directory-structure)                                  | :62    |
| 3       | [Hierarchy & Terminology](#3-hierarchy--terminology)                           | :124   |
| 4       | [Document Types](#4-document-types)                                            | :168   |
| 5       | [Naming Conventions](#5-naming-conventions)                                    | :286   |
| 6       | [File Relationships](#6-file-relationships)                                    | :342   |
| 7       | [When to Create Each Type](#7-when-to-create-each-type)                       | :394   |
| 8       | [Grouping Rules](#8-grouping-rules)                                            | :468   |
| 9       | [Cross-Cutting Testing](#9-cross-cutting-testing)                              | :522   |
| 10      | [Educational Docs Strategy](#10-educational-docs-strategy)                     | :564   |
| 11      | [Best Practices](#11-best-practices)                                           | :620   |
| 12      | [Examples](#12-examples)                                                       | :674   |

---

## 1. Overview

### Purpose

This document defines the **standard documentation structure** for all CODE-type projects in the v3 governance system. It establishes:

- Directory organization
- File naming conventions
- Document types and when to use them
- Relationships between documents

### Philosophy

**Structured yet flexible:**
- Clear organization for easy navigation
- Scalable from small features to large phases
- Captures both implementation and lessons learned
- Maintains history without clutter

**Implementation-centric:**
- Documentation lives close to code
- Each implementation (I-number) has its own subdirectory
- Related bugs, tests, and lessons grouped together

---

## 2. Directory Structure

### Standard Layout

```
<project-root>/
├── docs/
│   ├── specs/
│   │   ├── ARCHITECTURE.md (current version)
│   │   ├── DATA_MODEL.md
│   │   ├── API_REFERENCE.md
│   │   └── archive/
│   │       ├── ARCHITECTURE_v1.md
│   │       └── ARCHITECTURE_v2.md
│   │
│   ├── implementation/
│   │   ├── active/
│   │   │   ├── I021-Feature-Name/
│   │   │   │   ├── I021-Feature-Name.md
│   │   │   │   ├── G021-Bug-Fix.md
│   │   │   │   ├── G022-Another-Bug.md
│   │   │   │   ├── Q021-Test-Plan.md
│   │   │   │   └── E021-Lesson-Learned.md
│   │   │   │
│   │   │   └── I022-Another-Feature/
│   │   │       └── I022-Another-Feature.md
│   │   │
│   │   ├── completed/
│   │   │   └── I001-First-Feature/
│   │   │       ├── I001-First-Feature.md
│   │   │       └── G001-Bug-Fix.md
│   │   │
│   │   └── future/
│   │       └── I030-Planned-Feature/
│   │           └── I030-Planned-Feature.md
│   │
│   ├── educational/ (RARE - cross-project patterns only)
│   │   └── E001-General-Pattern/
│   │       └── E001-General-Pattern.md
│   │
│   ├── session_handoffs/
│   │   ├── YYYYMMDD_HHMM_session-name.md (current)
│   │   └── archive/
│   │       └── YYYY/MM/
│   │           └── session-handoff-YYYY-MM-DD.md
│   │
│   └── archive/ (deprecated docs)
│
├── src/ (or yuta/, backend/, frontend/)
├── tests/
└── README.md
```

### Folder Purposes

| Folder | Purpose | What Goes Here |
|--------|---------|----------------|
| `specs/` | Current design specifications | ARCHITECTURE.md, DATA_MODEL.md, API docs |
| `specs/archive/` | Old spec versions | Previous versions when major updates happen |
| `implementation/active/` | Work in progress | Current sprint implementations |
| `implementation/completed/` | Finished work | Completed features and their bugs/tests |
| `implementation/future/` | Planned work | Future features with initial planning |
| `educational/` | Cross-project lessons | Rare - only patterns that apply to ALL projects |
| `session_handoffs/` | Daily work logs | Session summaries for continuity |

---

## 3. Hierarchy & Terminology

### Levels of Organization

```
PROJECT (e.g., YutaAI, COEVOLVE)
│
├── Phase 1: Major Milestone (2-3 months)
│   │
│   ├── Sprint 1 (2 weeks) = I001 + I002
│   │   │
│   │   ├── I001: Implementation Unit (1-2 weeks)
│   │   │   │
│   │   │   ├── Backend Implementation (2-3 days)
│   │   │   │   └── Task: Create API endpoint (1 day)
│   │   │   │
│   │   │   └── Frontend Implementation (2-3 days)
│   │   │       └── Task: Build UI component (1 day)
│   │   │
│   │   └── I002: Another Implementation
│   │
│   └── Sprint 2 (2 weeks) = I003 + I004
│
└── Phase 2: Next Milestone (2-3 months)
```

### Definitions

| Term | Duration | Scope | Document Location |
|------|----------|-------|-------------------|
| **Phase** | 2-3 months | Major milestone, multiple sprints | ARCHITECTURE.md §7 |
| **Sprint** | 2 weeks | 1-2 I-numbers, time-boxed delivery | ARCHITECTURE.md §8 |
| **I-number** | 1-2 weeks | Single implementation unit | implementation/I###/ |
| **Implementation Stage** | 2-5 days | Backend, Frontend, Testing | Inside I###.md |
| **Task** | Hours-days | Single atomic unit of work | Checkbox in I###.md |
| **Session** | 1 day | Single coding session | session_handoffs/ |

**Critical:**
- Use "Phase" only in ARCHITECTURE.md for major milestones
- Use descriptive headings in I###.md (e.g., "Backend Implementation", not "Phase 1")

---

## 4. Document Types

### I###: Implementation Document

**Purpose:** Document a single feature/implementation unit

**Location:** `implementation/{active|completed|future}/I###-Feature-Name/I###-Feature-Name.md`

**When to create:**
- Starting a new feature
- Beginning a sprint
- When work spans 1-2 weeks

**Contains:**
- Overview and requirements
- Technical design
- Implementation progress (Backend, Frontend, Testing stages)
- Brief bug summaries (detail in G###)
- Files modified
- Testing checklist

**Template:** `~/Desktop/Governance/templates/I###-TEMPLATE.md`

---

### G###: Bug/Glitch Fix Document

**Purpose:** Document a bug discovery, debugging process, and fix

**Location:** `implementation/{active|completed}/I###-Parent-Feature/G###-Bug-Title.md`

**When to create:**
- ALWAYS create separate G### file (for consistency)
- Bug discovered during I### implementation
- Bug reported by users
- Bug found during testing

**Contains:**
- Symptom (what user sees)
- Root cause analysis
- Debugging timeline (Run 1, Run 2, Run 3...)
- Fix applied with code changes
- Verification tests

**Multiple runs in ONE file** (no G###-R1, G###-R2 files)

**Template:** `~/Desktop/Governance/templates/G###-TEMPLATE.md`

---

### E###: Educational/Lesson Learned Document

**Purpose:** Capture patterns, lessons, and reusable knowledge from implementation

**Location:**
- **Common:** `implementation/{active|completed}/I###-Feature/E###-Topic.md` (tied to I-number)
- **Rare:** `educational/E###-Topic/E###-Topic.md` (cross-project pattern)

**When to create:**
- **User explicitly requests** after repeated failures
- Debugging reveals broader pattern (not just a bug)
- Solution is reusable for similar problems
- Complex architectural decision worth documenting

**Contains:**
- Context (why this doc was created)
- The problem/challenge
- The solution/pattern
- Case studies (references to G### bugs)
- When to apply this pattern

**Numbering:**
- If tied to I-number: E###a, E###b (e.g., E021-RAG-Debug-Guide.md in I021/)
- If standalone: E001, E002 (rare)

**Template:** `~/Desktop/Governance/templates/E###-TEMPLATE.md`

---

### Q###: QA/Testing Document

**Purpose:** Document testing plans, coverage, and findings for a feature

**Location:** `implementation/{active|completed}/I###-Feature/Q###-Test-Scope.md`

**When to create:**
- Feature-specific testing (unit, integration tests)
- Test plan for complex feature
- QA coverage tracker

**Contains:**
- Test plan and strategy
- Test cases (manual and automated)
- Coverage metrics
- Testing results

**Note:** Cross-cutting QA (testing entire phase) should be a new I-number (e.g., I014-Phase3-Testing)

**Template:** `~/Desktop/Governance/templates/Q###-TEMPLATE.md`

---

### ARCHITECTURE.md (Specs)

**Purpose:** Current system design and implementation roadmap

**Location:** `docs/specs/ARCHITECTURE.md`

**Contains:**
- Vision and core concepts
- Architecture decisions
- Tech stack
- Implementation phases (with I-numbers)
- Current sprint status
- Future phases

**Versioning:** When major changes, save current to `specs/archive/ARCHITECTURE_v#.md`

**Template:** `~/Desktop/Governance/templates/ARCHITECTURE_TEMPLATE.md`

---

## 5. Naming Conventions

### File Naming Patterns

| Type | Pattern | Example | Notes |
|------|---------|---------|-------|
| **Implementation** | `I###-Feature-Name.md` | `I021-RAG-Routing.md` | 3 digits, kebab-case |
| **Bug/Glitch** | `G###-Bug-Title.md` | `G021-Router-Logic.md` | Number matches issue # |
| **Educational (tied)** | `E###a-Topic.md` | `E021-RAG-Debug-Guide.md` | Uses I-number prefix |
| **Educational (standalone)** | `E###-Topic.md` | `E001-Git-Workflow.md` | Rare, cross-project |
| **QA/Testing** | `Q###-Test-Scope.md` | `Q021-Unit-Tests.md` | Matches I-number |
| **Grouped bugs** | `G###-to-G###-Title.md` | `G012-to-G016-Analyze-Fixes.md` | Range for related bugs |
| **Architecture** | `ARCHITECTURE.md` | Current version | |
| **Architecture archive** | `ARCHITECTURE_v#.md` | `ARCHITECTURE_v1.md` | Version number |

### Number Assignment

**Sequential per project:**
- I001, I002, I003... (never reuse)
- G001, G002, G003... (never reuse)
- E001, E002, E003... (rare standalone, never reuse)

**Scoped to I-number:**
- E###a, E###b... (educational docs from I### implementation)
- Q### can match I### (e.g., Q021 for I021 testing)

### Subdirectory Naming

```
I###-Short-Feature-Name/
```

Examples:
- `I021-RAG-Routing/`
- `I014-Phase3-Testing/`
- `I030-Chat-Lifecycle/`

---

## 6. File Relationships

### Parent-Child Relationships

```
I021-RAG-Routing/
├── I021-RAG-Routing.md (PARENT - main implementation)
├── G021-Router-Logic.md (CHILD - bug discovered during I021)
├── G022-Query-Processing.md (CHILD - another bug)
├── E021-RAG-Debug-Guide.md (CHILD - lesson learned)
└── Q021-Unit-Tests.md (CHILD - feature tests)
```

**All child documents reference parent in front matter:**

```markdown
# G021-Router-Logic.md

> **Related:** I021-RAG-Routing (discovered during implementation)
```

### Cross-References

**In ARCHITECTURE.md:**
```markdown
### Phase 2: Flow Execution ✅ (I4-I7)
- [x] Flow execution backend (I4)

**Reference:** [I4-Persistence-ExecutionPlan.md](../implementation/completed/I4-*/I4-*.md)
```

**In I### doc:**
```markdown
## Bugs Encountered

### G021: Router Logic Bug
**See:** [G021-Router-Logic-Bug.md](./G021-Router-Logic-Bug.md)
```

**In G### doc:**
```markdown
> **Related:** I021-RAG-Routing (discovered during implementation)
> **Educational:** See [E021-RAG-Debug-Guide.md](./E021-RAG-Debug-Guide.md)
```

---

## 7. When to Create Each Type

### Decision Tree

```
Starting new work?
├── New feature (1-2 weeks)? → Create I### folder + I###.md
├── Bug found? → Create G###.md in related I### folder
├── Pattern discovered after 3+ failed attempts? → User decides: Create E###.md
└── Testing needed? → Create Q###.md in I### folder
```

### I### Creation Triggers

**Create I-number when:**
- ✅ Starting new feature implementation
- ✅ Beginning sprint with defined deliverable
- ✅ Cross-cutting work (e.g., I014-Phase3-Testing)
- ✅ Major refactor or migration

**Don't create I-number for:**
- ❌ Small bug fix (1-2 hours) - just commit
- ❌ Documentation updates - update existing docs
- ❌ Minor tweaks - commit directly

### G### Creation Triggers

**Always create G### when:**
- ✅ Bug discovered during implementation
- ✅ Bug reported by users
- ✅ Bug found during testing
- ✅ Issue requires investigation (any duration)

**Even if:**
- Bug fixed in 1 hour - still create G### for consistency
- Bug is minor - still document for history

### E### Creation Triggers

**Create E### only when:**
- ✅ User explicitly requests after repeated failures
- ✅ Pattern emerges from 3+ similar bugs
- ✅ Complex architectural lesson worth documenting
- ✅ Solution is reusable across features/projects

**Don't create E### for:**
- ❌ Every bug fix - just document in G###
- ❌ Simple solutions - document in I###
- ❌ One-off issues - keep in G###

### Q### Creation Triggers

**Create Q### when:**
- ✅ Feature needs comprehensive test plan
- ✅ Complex testing strategy required
- ✅ QA coverage tracker needed

**Don't create Q### for:**
- ❌ Simple unit tests - list in I###.md testing section
- ❌ Cross-cutting QA - create new I-number instead

---

## 8. Grouping Rules

### When to Group G### Files

**Group multiple bugs in ONE file when:**
1. ✅ Related (same component/root cause)
2. ✅ Solved at same time (same session/day)
3. ✅ Each bug took <3 days to fix
4. ✅ Combined score ≥3 points (see decision matrix)

**Don't group when:**
- ❌ Separate issues (different root causes)
- ❌ Any bug took >3 days (long debugging)
- ❌ Discovered at different times
- ❌ Unrelated components

### Grouping Decision Matrix

```
Score each criterion:
1. Same component/feature? → YES = +1
2. Same root cause or related? → YES = +1
3. Discovered same session? → YES = +1
4. Fixed in same commit? → YES = +1
5. Any bug took >3 days? → YES = -2

Total score:
- ≥3 points → GROUP into one file
- <3 points → Separate files
```

### Grouped File Naming

```
G###-to-G###-Topic.md (range)
G###-G###-Topic.md (pair)

Examples:
G012-to-G016-Analyze-Fixes.md (5 related bugs, fixed together)
G031-G032-Template-Bugs.md (2 related bugs)
```

---

## 9. Cross-Cutting Testing

### Testing as Implementation

**Cross-cutting QA = New I-number**

When testing spans multiple features or entire phase:

```
Phase 3 complete → Time to test everything

Solution: Create I014-Phase3-Testing/
├── I014-Phase3-Testing.md (main plan)
├── I014a-Coverage-Tracker.md (110 test items)
├── I014b-Findings-Log.md (bugs found)
├── G031-Bug-Found.md
└── G032-Another-Bug.md
```

**This is NOT a Q### doc** - it's a full implementation with:
- Planning (test strategy)
- Execution (running tests)
- Bug discovery (G### files)
- Lessons learned (E### files)

### Naming Convention

| Testing Scope | Naming | Example |
|---------------|--------|---------|
| Phase testing | `I###-Phase#-Testing` | I014-Phase3-Testing |
| Sprint testing | `I###-Sprint#-QA` | I025-Sprint5-QA |
| Pre-launch | `I###-Production-Readiness` | I099-Production-Readiness |

---

## 10. Educational Docs Strategy

### Two Types of E### Docs

#### Type 1: Implementation-Specific (Common)

**Location:** `implementation/I###-Feature/E###a-Topic.md`

**Characteristics:**
- Created during/after I### implementation
- Lesson learned from specific debugging
- References specific G### bugs
- Uses I-number prefix (E021, E014a)

**Example:**
```
I021-RAG-Routing/
└── E021-RAG-Debug-Guide.md

Created after: 3 failed debugging attempts on G021
Contains: Step-by-step RAG debugging strategy
References: G021, G022 as case studies
```

#### Type 2: Cross-Project (Rare)

**Location:** `educational/E###-Topic/E###-Topic.md`

**Characteristics:**
- Applies to ALL projects (not just one)
- General pattern or best practice
- Not tied to specific I-number
- Standalone numbering (E001, E002)

**Examples:**
- E001-Git-Workflow.md (applies to all repos)
- E002-Testing-Strategy.md (applies to all code)

**When to use:** Very rare - only if truly cross-project

### Creation Workflow

```
Claude: Attempts to fix bug
Claude: Fails → Retry
Claude: Fails → Retry
Claude: Fails → Retry (3rd time)
                ↓
User: "This keeps failing, create E### doc to capture the pattern"
                ↓
Claude: Creates E###.md with:
- What failed repeatedly
- Why it failed
- Systematic approach that works
- References to G### bugs as examples
```

---

## 11. Best Practices

### Navigation

**Finding documents:**
```bash
# List all active implementations
ls docs/implementation/active/

# Find all bugs in project
find docs/implementation -name "G*.md"

# Find all educational docs
find docs/implementation -name "E*.md"
find docs/educational -name "E*.md"
```

**Cross-referencing:**
- Always use relative paths: `[G021](./G021-Bug.md)`
- Always include front matter with Related: field
- Update ARCHITECTURE.md when I-number completes

### Maintenance

**Moving files:**
```bash
# When I-number completes, move from active/ to completed/
mv docs/implementation/active/I021-RAG/ docs/implementation/completed/

# Archive old ARCHITECTURE.md versions
cp docs/specs/ARCHITECTURE.md docs/specs/archive/ARCHITECTURE_v2.md
```

**Archiving session handoffs:**
```bash
# Move old sessions monthly
mv docs/session_handoffs/20260103_*.md docs/session_handoffs/archive/2026/01/
```

### Document Hygiene

**Keep current:**
- Update ARCHITECTURE.md when sprint/phase changes
- Move completed I-numbers from active/ to completed/
- Archive old specs when major version changes

**Don't over-document:**
- Simple fixes don't need I-number (just commit)
- Not every debug session needs E### doc (user decides)
- Group related bugs instead of 10 separate G### files

---

## 12. Examples

### Example 1: Simple Feature Implementation

```
Sprint 5: RAG Routing (2 weeks)

Work:
1. Implement RAG routing logic
2. Found 1 bug during development
3. Created unit tests

Documents created:
I021-RAG-Routing/
├── I021-RAG-Routing.md (main implementation)
├── G021-Router-Logic.md (bug found, fixed in 2 days)
└── Q021-Unit-Tests.md (test plan)
```

### Example 2: Complex Feature with Lessons

```
Sprint 7: Flow Templates (2 weeks)

Work:
1. Implement template import/export
2. Found 18 bugs during implementation (4 rounds of fixes)
3. Discovered UI update pattern issue
4. User requested educational doc on patterns

Documents created:
I013-Templates/
├── I013-Templates.md (main implementation)
├── G031-to-G035-Import-Bugs.md (5 related bugs, fixed together)
├── G036-Color-Picker.md (separate bug, took 5 days)
├── G037-to-G040-Export-Bugs.md (4 related bugs)
├── E013a-UI-Update-Patterns.md (user requested after failures)
└── Q013-Integration-Tests.md (test plan)
```

### Example 3: Cross-Cutting Testing

```
Phase 3 complete → Testing sprint

Work:
1. Test all Phase 3 features (I8-I13)
2. Found 10 bugs across multiple features
3. Discovered distributed state sync pattern

Documents created:
I014-Phase3-Testing/
├── I014-Phase3-Testing.md (main testing plan)
├── I014a-Coverage-Tracker.md (110 test items)
├── I014b-Findings-Log.md (bug tracking)
├── G041-Checkpoint-Bug.md (blocker in I8)
├── G042-Artifact-UI.md (blocker in I10)
├── E014a-UI-Update-Patterns.md (pattern discovered)
└── E014b-Distributed-State-Sync.md (complex pattern)
```

---

## Summary

This documentation system provides:

✅ **Clear structure** - Easy to navigate and find documents
✅ **Scalable** - Works for small features and large phases
✅ **Consistent** - Same patterns across all projects
✅ **Historical** - Captures implementation journey
✅ **Practical** - Balances documentation with speed

**Key principles:**
- Subdirectories by I-number keep related docs together
- Always create separate G### for consistency
- E### only when pattern emerges (user decides)
- Cross-cutting QA is a new I-number, not Q###
- Use descriptive headings in I### docs (not "Phase")

---

*Version: 3.0*
*Created: 2026-01-11*
*Last Updated: 2026-01-11*
*Template Location: ~/Desktop/Governance/templates/DOC_SYSTEM_CODE.md*
