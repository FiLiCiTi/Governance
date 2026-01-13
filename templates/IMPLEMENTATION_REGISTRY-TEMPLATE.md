# Implementation Registry

> **Purpose:** Single source of truth for all implementation items
> **Created:** YYYY-MM-DD
> **Last Updated:** YYYY-MM-DD
> **Governance:** Compliant with v3.2 §13 (Code Documentation System)

This registry tracks ALL implementation items (Features, Issues, Governance) across [Project Name] development phases.

## Table of Contents

| Section | Title                                       | Line  |
|---------|---------------------------------------------|-------|
| 1       | [Workflow Rules](#1-workflow-rules)         | :24   |
| 2       | [Progress Summary](#2-progress-summary)     | :89   |
| 3       | [Active](#3-active)                         | :121  |
| 4       | [Completed](#4-completed)                   | :136  |
| 5       | [Future (Phase 0)](#5-future-phase-0)       | :175  |
| 6       | [Future (Phase 1)](#6-future-phase-1)       | :197  |
| 7       | [Future (Phase 2)](#7-future-phase-2)       | :221  |
| 8       | [ID Conventions](#8-id-conventions)         | :249  |
| 9       | [Terminology](#9-terminology)               | :297  |
| 10      | [Quick Reference](#10-quick-reference)      | :315  |

---

## 1. Workflow Rules

### When to Create Item in `future/`

**Trigger:**
- Planning session identifies new work
- User requests new feature/enhancement
- Scope expansion during implementation

**Actions:**
1. Create minimal detail doc in `future/IXXX-Title/IXXX-Title.md`
2. Add entry to registry "Future" section (appropriate phase)
3. Use minimal template (title, size, phase, dependencies, wireframe/design)

**Required fields:**
- ID (I###, F#.#, G###)
- Title (brief, descriptive)
- Phase (references ARCHITECTURE.md phases)
- Size (XS/S/M/L/XL)
- Dependencies (list or "None")
- Design reference (if applicable)

### When to Move `future/` → `active/`

**Trigger:**
- Starting work NOW (this session)
- About to write code for this item
- User says "start working on X"

**Pre-move checklist:**
- [ ] Detail doc expanded with implementation plan
- [ ] Acceptance criteria defined
- [ ] Files to create/modify identified
- [ ] Technical approach decided

**Actions:**
1. Move folder: `future/IXXX-Title/` → `active/IXXX-Title/`
2. Update registry: Change section from "Future" → "Active"
3. Expand detail doc (add Implementation Plan, Acceptance Criteria, Testing Notes)
4. Create TodoWrite list for tracking session progress
5. **Update immediately** (not at session end)

### When to Move `active/` → `completed/`

**Trigger:**
- ALL acceptance criteria met ✓
- Code implemented and tested ✓
- Changes committed to git ✓

**Pre-move checklist:**
- [ ] Code complete
- [ ] Manual testing passed
- [ ] All bugs resolved
- [ ] Git commit created
- [ ] Documentation updated

**Actions:**
1. Move folder: `active/IXXX-Title/` → `completed/IXXX-Title/`
2. Update registry: Add to "Completed" section with date
3. Finalize detail doc (add completion date, commits, files changed, testing results)
4. **Update immediately** after commit (not batched)

### Retention Policy

**Completed items:**
- Keep ALL completed docs indefinitely (no archival)
- Provides historical record of implementation journey
- Reference for similar future features

**Active items:**
- Move to completed when done (don't accumulate stale items)
- If abandoned: Move to future/ with note "Deferred - [reason]"

---

## 2. Progress Summary

> **Note:** I-numbers are chronological (order of creation), not sequential within phases.

### Phase 0: [Phase Name] (X completed, Y active, Z future)
- [x] I001 [Feature Name]
- [🔄] I002 [Feature Name] *(in progress)*
- [ ] I003 [Feature Name]

### Phase 1: [Phase Name] (X completed, Y active, Z future)
- [ ] I004 [Feature Name]
- [ ] I005 [Feature Name]

### Phase 2: [Phase Name] (X completed, Y active, Z future)
- [ ] I006 [Feature Name]
- [ ] I007 [Feature Name]

**Total:** X completed, Y active, Z future | **Progress:** XX% Phase 0, XX% Phase 1-2

---

## 3. Active

**Status:** Currently being worked on

| ID   | Title         | Phase | Size | Priority | Document                     |
|------|---------------|-------|------|----------|------------------------------|
| I00X | [Title]       | X     | XS   | High     | [Link](active/I00X-*.md)     |

**Notes:**
- I00X: [Brief status note]

---

## 4. Completed

**Status:** Implemented and verified

| ID   | Title              | Phase | Size | Completed  | Document                              |
|------|--------------------|-------|------|------------|---------------------------------------|
| I001 | [Feature Name]     | 0     | S    | YYYY-MM-DD | [Link](completed/I001-*.md)           |
| I002 | [Feature Name]     | 0     | M    | YYYY-MM-DD | [Link](completed/I002-*.md)           |
| G001 | [Bug Fix]          | -     | XS   | YYYY-MM-DD | [Link](completed/I001-*/G001-*.md)    |

**Notes:**
- I001: [What was implemented]
- I002: [What was implemented]
- G001: [What was fixed]

---

## 5. Future (Phase 0)

### [Phase Name]

> **Note:** "Phase" refers to major milestone groupings defined in [ARCHITECTURE.md](../specs/ARCHITECTURE.md). This registry tracks implementation items within those phases.

**Sprint:** [Description]
**Status:** [Planned/In progress]

| ID   | Title         | Size | Effort         | Dependencies | Design           | Document                           |
|------|---------------|------|----------------|--------------|------------------|------------------------------------|
| I003 | [Feature]     | S    | Frontend only  | None         | `design-*.png`   | [Link](future/I003-*.md)           |
| I004 | [Feature]     | M    | API + Frontend | I003         | Spec document    | [Link](future/I004-*.md)           |

**Notes:**
- I003: [Brief description]
- I004: [Brief description, depends on I003]

---

## 6. Future (Phase 1)

### [Phase Name]

**Sprint:** [Description]
**Status:** Planned

| ID   | Title         | Size | Effort         | Dependencies | Design           | Document                           |
|------|---------------|------|----------------|--------------|------------------|------------------------------------|
| I005 | [Feature]     | L    | Full stack     | I004         | `design-*.png`   | [Link](future/I005-*.md)           |

**Notes:**
- I005: [Brief description]

---

## 7. Future (Phase 2)

### [Phase Name]

**Sprint:** [Description]
**Status:** Planned

| ID   | Title         | Size | Effort         | Dependencies | Design           | Document                           |
|------|---------------|------|----------------|--------------|------------------|------------------------------------|
| I006 | [Feature]     | M    | Backend focus  | I005         | TBD              | [Link](future/I006-*.md)           |

**Notes:**
- I006: [Brief description]

---

## 8. ID Conventions

### Prefixes (Gov 3.2 §13.3)

| Prefix | Type           | Usage                                      | When to Create              | Example          |
|--------|----------------|--------------------------------------------|-----------------------------|------------------|
| F      | Feature        | Major new features (with version numbers)  | Planning phase              | F0.1, F1.2, F2.0 |
| I      | Implementation | Implementation items, enhancements, tasks  | Starting new feature/sprint | I001, I006, I015 |
| G      | Governance     | Bugs, blockers, infrastructure issues      | **ANY bug discovered**      | G003, G005       |
| E      | Educational    | Lessons learned, patterns                  | **User requests only**      | E021 (rare)      |
| Q      | QA/Testing     | Feature-specific testing plans             | Feature needs testing       | Q021 (rare)      |

**Key Rules (Gov 3.2 §13.6):**
- **G### files:** ALWAYS create separate file for every bug (even 1-hour fixes)
- **E### files:** ONLY when user explicitly requests after repeated failures (not automatic)
- **Q### files:** Feature-specific testing only (cross-cutting testing = new I-number)

### Numbering

- **Features (F)**: Use semantic versioning (F0.1, F1.0, F2.5)
- **Implementation (I)**: Sequential (I001-I999)
- **Governance (G)**: Sequential (G001-G999)
- **Educational (E)**: Sequential (E001-E999) or tied to I-number (E021a)
- **QA/Testing (Q)**: Match I-number (Q021 for I021)

### File Relationships (Gov 3.2 §13.7)

**Parent-child structure:**
- Implementation (I###) is PARENT
- Bugs (G###), lessons (E###), tests (Q###) are CHILDREN
- Children live in parent's folder: `I021-Feature/G021-Bug.md`
- All children reference parent in frontmatter

**Example:**
```
I021-Feature/ (PARENT)
├── I021-Feature.md
├── G021-Bug-Fix.md (CHILD - references I021)
├── E021-Lesson.md (CHILD - references G021, G022)
└── Q021-Tests.md (CHILD - references I021)
```

### ID Changes

| Old ID | New ID | Reason            | Date       |
|--------|--------|-------------------|------------|
| -      | -      | -                 | -          |

---

## 9. Terminology (Gov 3.2 §13.5)

**Critical:** Avoid terminology confusion

| Term                     | Duration   | Location                        | Usage                          |
|--------------------------|------------|---------------------------------|--------------------------------|
| **Phase**                | 2-3 months | ARCHITECTURE.md (defines)       | Major milestones (strategic)   |
| **Sprint**               | 2 weeks    | ARCHITECTURE.md §8              | Time-boxed delivery (tactical) |
| **I-number**             | 1-2 weeks  | This registry + implementation/ | Single feature unit            |
| **Implementation Stage** | 2-5 days   | Inside I###.md                  | Backend, Frontend, Testing     |
| **Task**                 | Hours-days | Inside I###.md (checkboxes)     | Atomic work unit               |

**Rule:** "Phase" in this registry references phases defined in ARCHITECTURE.md (not creating new terminology).

---

## 10. Quick Reference

### By Status

- **Active:** Y items (I00X, ...)
- **Completed:** X items (I001, I002, G001, ...)
- **Future:** Z items (I003, I004, ...)

### By Phase

- **Phase 0 ([Name]):** X completed, Y active, Z future
- **Phase 1 ([Name]):** X items
- **Phase 2 ([Name]):** X items

### By Size

- **XS:** I001, I002, G001
- **S:** I003, I005
- **M:** I004, I006
- **L:** I007
- **XL:** [None yet]

---

*Last updated: YYYY-MM-DD | Template: ~/Desktop/Governance/templates/IMPLEMENTATION_REGISTRY-TEMPLATE.md | v3.2*
