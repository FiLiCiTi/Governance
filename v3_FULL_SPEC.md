# Governance v3 Full Specification

> **Version:** 3.0
> **Date:** 2026-01-09
> **Status:** Complete
> **Previous:** V2.5_FULL_SPEC.md

## Table of Contents

| Section | Title                                                                          | Line   |
|---------|--------------------------------------------------------------------------------|--------|
| 1       | [Executive Summary](#1-executive-summary)                                      | :49    |
| 2       | [Design Principles](#2-design-principles)                                      | :96    |
| 3       | [Core Concepts](#3-core-concepts)                                              | :175   |
| 4       | [10-Layer Prompt System](#4-10-layer-prompt-system)                            | :283   |
| 5       | [Hook System](#5-hook-system)                                                  | :355   |
| 6       | [Session Handoff System](#6-session-handoff-system)                            | :435   |
| 7       | [Context Management](#7-context-management)                                    | :591   |
| 8       | [Checkpoint & Recovery](#8-checkpoint--recovery)                               | :719   |
| 9       | [Archival System](#9-archival-system)                                          | :871   |
| 10      | [Plugin Integration](#10-plugin-integration)                                   | :1006  |
| 11      | [Directory Intelligence](#11-directory-intelligence)                           | :1169  |
| 12      | [Per-Product Setup](#12-per-product-setup)                                     | :1314  |
| 13      | [Portfolio Management](#13-portfolio-management)                               | :1603  |
| 14      | [Decision ID System](#14-decision-id-system)                                   | :1881  |
| 15      | [Scripts & Tools](#15-scripts--tools)                                          | :2126  |
| 16      | [Migration from v2.5](#16-migration-from-v25)                                  | :2604  |
| 17      | [Quick Reference](#17-quick-reference)                                         | :3004  |
| 18      | [Appendices](#18-appendices)                                                   | :3335  |

---------------------------------------------------------------------------------------------------------------------------

## 1. Executive Summary

### 1.1 What is v3

Governance v3 extends v2.5 with session continuity features. It adds Layer 6 (Session Context) to the prompt system and introduces structured session handoff files.

**Core components**:
- **CONTEXT.md**: Per-project state file summarizing progress, decisions, and blockers
- **session_handoffs/**: Directory containing structured session documentation
- **Session handoff files**: 12-section documents capturing session progress
- **Shared_context.md**: Optional global file tracking multiple projects
- **session_config.md**: Optional per-project configuration

**How it works**:
1. Session starts → Claude reads CONTEXT.md (Layer 6) + creates handoff file
2. Every 60-90min → User triggers checkpoint (saves handoff + CONTEXT + commits code)
3. Session ends → User triggers finalize (completes all handoff sections)
4. Monthly → User triggers archive (moves old handoffs to archive/YYYY/MM/)

All triggers are manual. No automatic handoff creation.

### 1.2 Key Decisions

v3 governance decisions (#G12-#G17, #P10-#P12, #I15-#I17):

| ID   | Decision                              | Impact                          |
|------|---------------------------------------|---------------------------------|
| #G12 | Adopt v3 governance system            | Enables session continuity      |
| #G13 | Manual checkpoint triggers only       | User controls all operations    |
| #G14 | Monthly archival process              | Keeps workspace clean           |
| #G15 | Optional v3 adoption (opt-in)         | v2.5 projects work unchanged    |
| #G16 | Add Layer 6 (Session Context)         | CONTEXT.md loads at start       |
| #G17 | 12-section handoff template           | Standardized documentation      |
| #P10 | Checkpoint every 60-90min             | Aligns with warmup status       |
| #P11 | Finalize before session end           | Complete handoff documentation  |
| #P12 | User triggers all handoff operations  | Manual control (no automation)  |
| #I15 | Store handoffs in session_handoffs/   | Separate from code files        |
| #I16 | CONTEXT.md in project root            | Easy access for Layer 6         |
| #I17 | Shared_context.md global location     | ~/.claude/ for portfolio view   |

### 1.3 Migration Path

v3 is **opt-in**. Existing v2.5 projects continue working without changes.

**Minimal migration** (30 minutes):
1. Create CONTEXT.md (project state summary)
2. Create session_handoffs/ directory
3. Optional: Create .claude/session_config.md (custom config)
4. Test first v3 session

**No breaking changes**:
- CLAUDE.md format unchanged
- Hook system unchanged (SessionStart, PreToolUse, PostToolUse, Stop)
- Layers 1-5 unchanged (same as v2.5)
- Plugins work identically

**Rollback available**: Delete v3 files, revert commits, continue with v2.5.

---------------------------------------------------------------------------------------------------------------------------

## 2. Design Principles

### 2.1 Manual Control

All session handoff operations are **manual** (user-triggered):
- Create handoff: User asks Claude
- Checkpoint: User says "checkpoint"
- Finalize: User says "finalize session handoff"
- Archive: User says "archive last month"

**Why manual**: Prevents unwanted commits, allows user to control git history, avoids checkpoint spam.

**No automation**: Claude does not automatically create handoffs at session start, checkpoint at time intervals, or finalize at session end.

### 2.2 Opt-In Adoption

v3 features are **optional**:
- v2.5 projects work without changes
- Migrate only projects needing session continuity
- Both v2.5 and v3 projects coexist
- No forced upgrades

**Who should migrate**:
- Long-running projects (>90min sessions)
- Frequent context loss frustration
- Need cross-session continuity
- Portfolio management (multiple projects)

**Who can stay on v2.5**:
- Short sessions (<60min)
- Single project, rarely interrupted
- Don't need handoff documentation

### 2.3 Minimal File Overhead

v3 adds minimal required files:
- CONTEXT.md (one per project)
- session_handoffs/ (directory)
- Session handoff files (created during sessions)

**Optional files**:
- .claude/session_config.md (custom config)
- ~/.claude/Shared_context.md (portfolio view)

**Not required**:
- No additional tools or dependencies
- No new git hooks
- No external services

### 2.4 Backward Compatibility

v3 maintains full v2.5 compatibility:
- Layer 1-5 unchanged
- Hook system unchanged
- Plugin system unchanged
- CLAUDE.md format unchanged
- Decision ID system unchanged

**New in v3**:
- Layer 6 (Session Context) - loads CONTEXT.md
- Session handoff templates
- Archival workflows

### 2.5 Factual Documentation

All v3 documentation is factual:
- Manual processes labeled as manual
- No overstating capabilities
- No marketing language
- Clear about what v3 is and is not

**Example corrections**:
- ❌ "Automated session handoff creation"
- ✅ "Manual session handoff creation (user triggers)"

### 2.6 Progressive Disclosure

Information provided when needed:
- Quick Reference (§17) for common workflows
- Full sections (§1-16) for detailed understanding
- Templates (§18) for implementation
- FAQ (§18.E) for common questions

**Learning path**:
1. Read Executive Summary (§1) - understand what v3 is
2. Review Quick Reference (§17) - learn workflows
3. Migrate one project (§16) - test v3 features
4. Consult full sections as needed

### 2.7 Context Efficiency

v3 designed for context efficiency:
- CONTEXT.md provides session summary (reduces re-reading files)
- Session handoffs capture progress (reduces conversation history)
- Checkpoints preserve state (reduces starting from scratch)
- Archival keeps active workspace clean

**Token savings**:
- Layer 6 loads CONTEXT.md (~2-5K tokens) instead of re-reading full codebase
- Session handoff provides structured context (vs unstructured conversation)
- Monthly archival moves old files out of active workspace

### 2.8 Portfolio Scalability

v3 scales from single project to portfolio:
- Single project: CONTEXT.md only
- Multiple projects: Add Shared_context.md
- Complex portfolios: Per-project session_config.md

**Scaling path**:
1. Start: One project with CONTEXT.md
2. Grow: Add second project with CONTEXT.md
3. Coordinate: Create Shared_context.md for portfolio view
4. Customize: Add session_config.md for project-specific needs

---------------------------------------------------------------------------------------------------------------------------

## 3. Core Concepts

### 3.1 Session Lifecycle

v3 sessions follow a three-phase lifecycle:

**Phase 1: Start** (manual trigger)
- User: "confirm and next"
- Claude announces: date, boundaries, warmup status
- User: "Create handoff for [topic]"
- Claude creates: session_handoffs/YYYYMMDD_HHMM_topic.md
- Claude reads: CONTEXT.md (Layer 6 - previous session summary)
- Claude fills: Section I (Metadata) in handoff
- Begin work

**Phase 2: Checkpoint** (every 60-90min, manual trigger)
- Warmup status shows ⚠️ (240-480m) or 🔴 (>480m)
- User: "checkpoint"
- Claude updates: session handoff (Sections II, III, V, VI)
- Claude updates: CONTEXT.md (Sections I, III, V, VII)
- Claude commits: git add . && git commit -m "Checkpoint: [description]"
- Continue work or end session

**Phase 3: Finalize** (manual trigger)
- User: "finalize session handoff"
- Claude fills: all handoff sections (I-XII)
- Claude updates: CONTEXT.md Section VII (add session entry)
- Claude marks: handoff status: finalized
- Claude commits: git commit -m "Session finalized: YYYY-MM-DD"
- Session ends

### 3.2 Context Hierarchy

Information flows through three levels:

**Level 1: Session Handoff** (most detailed)
- Per-session documentation
- 12 sections capturing all work done
- Stored in: session_handoffs/YYYYMMDD_HHMM_topic.md
- Updated: During session (checkpoint + finalize)
- Archived: Monthly to archive/YYYY/MM/

**Level 2: CONTEXT.md** (project summary)
- Per-project state file
- 7 sections summarizing overall progress
- Stored in: {project}/CONTEXT.md
- Updated: Every checkpoint and finalize
- Archived: Monthly to archive/YYYY/MM/CONTEXT_YYYYMM.md

**Level 3: Shared_context.md** (portfolio view)
- Global file tracking all projects
- 7 sections for cross-project coordination
- Stored in: ~/.claude/Shared_context.md
- Updated: After major milestones or monthly
- Optional: Only needed for 3+ projects

**Information flow**:
```
Session Handoff (detailed)
    ↓ (summarize)
CONTEXT.md (project level)
    ↓ (aggregate)
Shared_context.md (portfolio level)
```

### 3.3 File Structure

**Per-project files**:
```
{project}/
├── CLAUDE.md                    ← Layer 4: Project rules (required)
├── CONTEXT.md                   ← Layer 6: Current state (v3 NEW)
├── .claude/
│   └── session_config.md        ← Optional: Custom config
└── session_handoffs/
    ├── YYYYMMDD_HHMM_topic.md   ← Active handoffs
    ├── YYYYMMDD_HHMM_topic2.md
    └── archive/
        └── YYYY/MM/
            ├── handoff1.md       ← Archived handoffs
            └── CONTEXT_YYYYMM.md ← Archived CONTEXT
```

**Global files**:
```
~/.claude/
├── CLAUDE.md                    ← Layer 2: Global rules (v2.5)
├── Shared_context.md            ← Portfolio view (v3 NEW, optional)
├── templates/
│   └── session_handoff.md       ← Global template
└── sessions/
    └── {hash}_session.json      ← Session state (hooks)
```

### 3.4 Filename Convention

**Session handoff files**: `YYYYMMDD_HHMM_topic.md`
- YYYYMMDD: Session date (2026-01-09)
- HHMM: Session start time (1430 = 2:30 PM)
- topic: Brief description (feature-auth, bugfix-login)

**Examples**:
- 20260109_1430_feature-auth.md
- 20260109_1000_bugfix-login.md
- 20260105_1500_refactor-api.md

**Why this format**:
- Chronological sorting (date first)
- Unique filenames (date + time)
- Self-documenting (topic included)
- Easy to grep (YYYYMMDD pattern)

### 3.5 Archival Strategy

**Monthly archival** (first session of new month):

1. Create archive directory: session_handoffs/archive/YYYY/MM/
2. Move previous month's handoffs: mv YYYYMM*.md archive/YYYY/MM/
3. Archive CONTEXT.md: cp CONTEXT.md archive/YYYY/MM/CONTEXT_YYYYMM.md
4. Create fresh CONTEXT.md for new month
5. Commit: git commit -m "Archive: Session handoffs for YYYY-MM"

**Retention**:
- Keep all archived files indefinitely (disk space is cheap)
- Optional: Compress old archives (tar -czf YYYY.tar.gz archive/YYYY/)
- Optional: Move to cold storage (external drive, cloud backup)

**Never delete**:
- Current month's handoffs
- Active CONTEXT.md
- Any file marked as reference in handoff notes

---------------------------------------------------------------------------------------------------------------------------

## 4. 10-Layer Prompt System

### 4.1 Overview

v3 extends v2.5's 9-layer system to 10 layers by adding Layer 6 (Session Context).

**New in v3**: Layer 6 loads CONTEXT.md at session start, providing previous session summary without re-reading full codebase.

**Unchanged from v2.5**: Layers 1-5, 7-10

### 4.2 Complete Layer System

Layers in execution order (what loads first → last):

| Layer | Source                    | Status       | When Loaded        | Notes                                               |
|-------|---------------------------|--------------|--------------------|----------------------------------------------------|
| 1     | System Prompt             | v1 (built-in)| Always             | Anthropic baseline behavior                        |
| 2     | Global CLAUDE.md          | v1           | Session start      | ~/.claude/CLAUDE.md (universal rules)              |
| 3     | Product CLAUDE.md         | v2           | Session start      | Product-level rules (if exists)                    |
| 4     | Project CLAUDE.md         | v1           | Session start      | Project boundaries (CAN/CANNOT)                    |
| 5     | Hook-injected context     | v2           | Session start      | Date, boundaries, plugins (from hooks)             |
| 6     | Session context           | **v3 NEW**   | Session start      | CONTEXT.md (previous session summary)              |
| 7     | Plugin prompts            | v2.5         | When plugin active | Plugin-specific instructions                       |
| 8     | Conversation history      | v1 (built-in)| Accumulated        | Previous messages in current session               |
| 9     | Tool results              | v1 (built-in)| After tool use     | File contents, command outputs                     |
| 10    | Current message           | v1 (built-in)| Per message        | User's current request                             |

### 4.3 Layer 6 Details (Session Context)

**What it is**:
- Loads CONTEXT.md at session start
- Provides summary of previous sessions
- Includes current state, active work, blockers, decisions

**When it loads**:
- Automatically at session start (after Layer 5, before Layer 7)
- Only if CONTEXT.md exists (v3 projects)
- Skipped if CONTEXT.md missing (v2.5 projects work unchanged)

**What it contains** (from CONTEXT.md):
- Section I: Current State (project phase, progress)
- Section III: Active Work (in-progress items)
- Section IV: Decisions & Architecture (recent decisions)
- Section V: Blockers & Risks (current issues)
- Section VI: Roadmap (next steps)
- Section VII: Session History (last 10 sessions)

**Token cost**: ~2-5K tokens (much less than re-reading full codebase)

### 4.4 Layer Interaction

**Layers build on each other**:
1. Layer 1: Baseline behavior
2. Layer 2-4: Add project context (global → product → project)
3. Layer 5: Add session metadata (date, boundaries)
4. **Layer 6**: Add previous session summary (NEW in v3)
5. Layer 7: Add plugin capabilities
6. Layer 8-10: Add current conversation context

**Example at session start**:
```
Layer 1: "I am Claude, helpful assistant"
Layer 2: "Use decision IDs (#G, #I, etc.)"
Layer 3: [No product CLAUDE.md]
Layer 4: "CAN modify: src/, CANNOT modify: /Volumes/"
Layer 5: "Date: 2026-01-09, Warmup: ✅, Plugins: 37"
Layer 6: "Previous session: Completed auth feature. Next: Deploy to staging"
Layer 7: "hookify provides warmup monitoring"
Layer 8: [Current conversation messages]
Layer 9: [Tool results from current session]
Layer 10: "User asks: Deploy auth to staging"
```

---------------------------------------------------------------------------------------------------------------------------

## 5. Hook System

### 5.1 Overview

Hook system is **unchanged from v2.5**. v3 uses existing hooks for session coordination.

**Available hooks** (from v2.5):
- SessionStart: Runs at session beginning
- PreToolUse: Runs before each tool call
- PostToolUse: Runs after each tool call
- Stop: Runs when session ends naturally
- SubagentStop: Runs when subagent completes
- SessionEnd: Runs at session termination
- UserPromptSubmit: Runs when user submits message
- PreCompact: Runs before conversation compaction
- Notification: Runs for system notifications

### 5.2 SessionStart Hook (v3 Usage)

**What it does** (unchanged from v2.5):
- Injects date, boundaries, plugin count (Layer 5)
- Provides warmup status (✅/⚠️/🔴)
- Does NOT create session handoff (manual trigger required)

**Example output**:
```
📅 Date: 2026-01-09
📁 Project: Governance
✅ CAN: This folder (Governance/)
🚫 CANNOT: /Volumes/, /etc/, v1_archive/
🔌 Plugins: 37
⏱️ Warmup: ✅ <240m
```

**v3 enhancement**: Warmup status guides checkpoint decisions
- ✅ <240m: Continue working
- ⚠️ 240-480m: Checkpoint recommended
- 🔴 >480m: Checkpoint required

### 5.3 Stop Hook (v3 Usage)

**What it does** (unchanged from v2.5):
- Runs when session ends naturally
- Does NOT finalize handoff (manual trigger required)
- Can remind user to finalize if handoff incomplete

**Example**:
```
Session ending.
Reminder: Finalize session handoff?
Current handoff: session_handoffs/20260109_1430_feature-auth.md
Status: in_progress (not finalized)
```

**User response**: "finalize session handoff" or leave incomplete

### 5.4 PreToolUse/PostToolUse Hooks (Unchanged)

**Purpose**: Enforce boundaries (CAN/CANNOT modify)

**Not related to v3**:
- Do NOT automatically trigger checkpoints
- Do NOT create handoff files
- Do NOT update CONTEXT.md

**v2.5 behavior preserved**: Block dangerous operations, verify permissions

### 5.5 Hook Integration with v3 Workflows

**Session start workflow**:
1. SessionStart hook injects context (Layer 5)
2. Claude loads CONTEXT.md (Layer 6) - v3 NEW
3. User triggers handoff creation (manual)
4. Claude creates session_handoffs/YYYYMMDD_HHMM_topic.md

**Checkpoint workflow**:
1. User checks warmup status (from SessionStart hook)
2. User triggers checkpoint (manual: "checkpoint")
3. Claude updates handoff + CONTEXT.md
4. Claude commits code (git add . && git commit)
5. Warmup status resets to ✅

**Finalize workflow**:
1. User triggers finalize (manual: "finalize session handoff")
2. Claude fills all handoff sections
3. Claude updates CONTEXT.md
4. Stop hook may remind if finalize not triggered (optional)

**All triggers are manual**. Hooks provide information, not automation.

---------------------------------------------------------------------------------------------------------------------------

## 6. Session Handoff System

### 6.1 Purpose

Session handoffs capture work progress for continuity across sessions. This is a **manual documentation system** triggered by the user.

**What handoffs provide**:
- Comprehensive work summary (what was completed)
- Current state snapshot (where project stands)
- Changes detail (code, docs, config modified)
- Blockers and risks (issues encountered)
- Next steps (for next session)
- Context links (related files, decisions)

**What handoffs do NOT provide**:
- Automatic creation (user triggers)
- Real-time updates (manual checkpoint)
- Conversation history (too large to include)

### 6.2 12-Section Template Structure

All session handoffs use a standardized 12-section template (#G17):

| Section | Title                        | Content                                    | When Filled           |
|---------|------------------------------|--------------------------------------------|-----------------------|
| I       | Session Metadata             | Project, date, time, duration, model       | At creation (auto)    |
| II      | Work Summary                 | Completed/In Progress/Pending items        | Checkpoint + finalize |
| III     | State Snapshot               | Current phase, metrics, environment state  | Checkpoint + finalize |
| IV      | Changes Detail               | Code/docs/config modifications             | Finalize              |
| V       | Blockers & Risks             | Current blockers, risks, resolutions       | Checkpoint + finalize |
| VI      | Next Steps                   | Immediate/short-term/long-term actions     | Checkpoint + finalize |
| VII     | Context Links                | Related files, sessions, external refs     | Finalize              |
| VIII    | Project-Type-Specific        | CODE/BIZZ/OPS custom fields                | Finalize              |
| IX      | Plugin Cost Summary          | Active plugins, token overhead             | Finalize              |
| X       | Session Quality Metrics      | Warmup checks, checkpoints, errors (opt)   | Finalize              |
| XI      | Handoff Notes                | For next Claude (context to remember)      | Finalize              |
| XII     | Appendix                     | Error logs, research notes, code (opt)     | Finalize              |

Full template in §18.A.

### 6.3 Handoff Lifecycle

**1. Creation** (session start, manual trigger):
```
User: "Create handoff for feature-auth"
Claude creates: session_handoffs/20260109_1430_feature-auth.md
Claude fills: Section I (Metadata) - project, date, start time
Claude sets: status: in_progress
Other sections: Empty (to be filled during session)
```

**2. Checkpoint updates** (every 60-90min, manual trigger):
```
User: "checkpoint"
Claude updates:
- Section II: Work Summary (add completed items)
- Section III: State Snapshot (update current state)
- Section V: Blockers & Risks (note new issues)
- Section VI: Next Steps (update pending work)
```

**3. Finalization** (session end, manual trigger):
```
User: "finalize session handoff"
Claude fills:
- All sections (I-XII)
- Section I: Add end time, duration
- Section IV: Comprehensive changes list
- Section VII: All context links
- Section VIII: Project-type-specific details
- Section IX: Plugin cost summary
- Section XI: Handoff notes for next Claude

Claude sets: status: finalized
Claude marks: Immutable (no further edits)
```

**4. Archival** (monthly, manual trigger):
```
User: "archive last month's sessions"
Claude moves: session_handoffs/YYYYMM*.md → archive/YYYY/MM/
```

### 6.4 Usage in Session Lifecycle

**Phase 1: Start**
- Create handoff file (Section I filled)
- Read CONTEXT.md for previous session summary
- Use Section VI from CONTEXT.md as starting point

**Phase 2: Checkpoint**
- Update Sections II, III, V, VI
- Keep handoff current (minimize data loss if interrupted)
- Commit code changes

**Phase 3: Finalize**
- Fill all sections (I-XII)
- Provide comprehensive session record
- Mark immutable (reference for future)

### 6.5 Storage and Organization

**Active handoffs**:
- Location: {project}/session_handoffs/
- Naming: YYYYMMDD_HHMM_topic.md
- Status: in_progress or finalized
- Retention: Current month only

**Archived handoffs**:
- Location: {project}/session_handoffs/archive/YYYY/MM/
- Retention: Indefinite (or until manually deleted)
- Access: grep -r "keyword" archive/

**Git tracking**:
- Recommended: Commit all handoffs (audit trail)
- Optional: .gitignore in_progress files, commit only finalized
- Archive folder: Always committed

### 6.6 Project-Type Variations

**Section VIII** varies by project type:

**CODE projects**:
- Technical debt identified
- Performance notes
- Dependencies updated
- Test coverage metrics
- Build status

**BIZZ projects**:
- Strategic decisions
- Stakeholder updates
- Market research findings
- Budget tracking
- Timeline status

**OPS projects**:
- Operational metrics (uptime, incidents)
- Infrastructure changes
- Runbook updates
- Backup status
- Monitoring alerts

See §12 for full project-type examples.

### 6.7 Manual Control

All handoff operations are **manual**:
- User triggers creation: "Create handoff for [topic]"
- User triggers checkpoint: "checkpoint"
- User triggers finalize: "finalize session handoff"
- User triggers archive: "archive last month"

**No automation**:
- Claude does not create handoffs at session start
- Claude does not checkpoint at time intervals
- Claude does not finalize at session end
- Claude does not archive monthly (user schedules)

**Why manual**: User controls documentation frequency, git history, and when sessions are considered complete.

---------------------------------------------------------------------------------------------------------------------------

## 7. Context Management

### 7.1 Overview

Context management in v3 uses two main files:
- **CONTEXT.md**: Per-project state file (required for v3)
- **Shared_context.md**: Global portfolio view (optional)

### 7.2 CONTEXT.md Structure

**Location**: {project}/CONTEXT.md

**7 sections**:

**I. Current State**
- Phase: [Planning/Development/Testing/Deployed]
- Progress: One-paragraph summary
- Key metrics: Relevant measurements
- Last milestone: Recent completion
- Current focus: Active work

**II. Progress Summary**
- Completed: Finished work items
- In Progress: Active work items
- Pending: Planned work items

**III. Active Work**
- Current sprint/phase
- Detailed descriptions of in-progress items
- Relevant file paths

**IV. Decisions & Architecture**
- Recent decisions table (ID, Date, Decision, Rationale, Impact)
- Architecture notes
- System design
- Tech stack

**V. Blockers & Risks**
- Current blockers (description, impact, waiting on)
- Risks (probability, impact, mitigation)
- Resolved blockers (last 30 days)

**VI. Roadmap**
- Immediate next steps (next session)
- Short-term goals (this month)
- Long-term vision (this quarter)
- Future considerations

**VII. Session History**
- Table: Date, Handoff File, Summary, Duration
- Keep last 10 sessions
- Archive older sessions monthly

Full template in §18.B.

### 7.3 CONTEXT.md Updates

**When updated**:
- Checkpoint: Sections I, III, V, VII (add checkpoint entry)
- Finalize: All sections (comprehensive update)
- Manual: User can edit directly anytime

**What gets updated**:

**At checkpoint**:
- Section I: Latest project state
- Section III: Current active work
- Section V: New blockers or risks
- Section VII: Checkpoint timestamp

**At finalize**:
- Section I: Final session state
- Section II: Completed items from session
- Section III: Updated active work
- Section IV: New decisions made
- Section V: Resolved blockers
- Section VI: Next steps from handoff
- Section VII: Session entry with link to handoff

**Example Section VII entry**:
```markdown
| Date       | Handoff File                           | Summary                     | Duration |
|------------|----------------------------------------|-----------------------------|----------|
| 2026-01-09 | 20260109_1430_feature-auth.md          | Completed JWT authentication| 90min    |
```

### 7.4 CONTEXT.md in Layer 6

**How Layer 6 loads CONTEXT.md**:
1. Session starts
2. Claude loads Layers 1-5 (as usual)
3. Claude reads {project}/CONTEXT.md (if exists)
4. Claude extracts key information:
   - Section I: Where project currently is
   - Section III: What's actively being worked on
   - Section V: Current blockers to be aware of
   - Section VI: Next steps to prioritize
5. Claude uses this context for session planning

**Token efficiency**:
- CONTEXT.md: ~2-5K tokens
- vs re-reading full codebase: 10-50K tokens
- Savings: 5-45K tokens per session

### 7.5 Shared_context.md Structure

**Location**: ~/.claude/Shared_context.md

**Purpose**: Track multiple projects in portfolio view

**7 sections**:

**I. Active Projects**
- Table: Project, Type, Version, Status, Last Session, Next Priority

**II. Cross-Project Blockers**
- Shared dependencies
- Resource conflicts

**III. Recent Decisions (Cross-Project)**
- Table: ID, Date, Decision, Affects, Status

**IV. Shared Resources**
- Common utilities (templates, scripts, docs)
- Shared infrastructure (database, storage, CI/CD)
- Cost tracking

**V. Monthly Summary**
- Current month progress
- Previous months summary
- Keep current + last 3 months

**VI. Portfolio Metrics**
- Session activity (last 30 days)
- Context health (fresh/stale/inactive projects)
- Archive size
- Decision count

**VII. Notes**
- Project relationships
- Upcoming portfolio changes
- Portfolio health assessment

Full template in §18.C.

### 7.6 Shared_context.md Updates

**When updated** (manual):
- After major milestones
- Monthly review
- When blockers affect multiple projects
- When adding/removing projects

**Example workflow**:
```
User: "Update shared context after completing auth feature"

Claude:
1. Reads MyWebApp/CONTEXT.md (find completion details)
2. Reads ~/.claude/Shared_context.md
3. Updates Section I: Active Projects (mark auth feature done)
4. Updates Section V: Monthly Summary (add completion)
5. Confirms: "Shared context updated. Next: payment integration"
```

### 7.7 Context File Relationship

**Information flow**:
```
Session Handoff (20260109_1430.md)
    ↓ summarize completed work
CONTEXT.md (project level)
    ↓ aggregate milestone progress
Shared_context.md (portfolio level)
```

**Update frequency**:
- Session Handoff: Every checkpoint + finalize
- CONTEXT.md: Every checkpoint + finalize
- Shared_context.md: After milestones or monthly

**Detail level**:
- Session Handoff: Maximum detail (12 sections)
- CONTEXT.md: Project summary (7 sections)
- Shared_context.md: Portfolio summary (7 sections)

### 7.8 Archival Process

**Monthly archival** (for CONTEXT.md):

1. Save current version:
   ```bash
   cp CONTEXT.md session_handoffs/archive/YYYY/MM/CONTEXT_YYYYMM.md
   ```

2. Create fresh CONTEXT.md:
   - Copy template structure
   - Add note: "Archived CONTEXT_YYYYMM.md on [date]"
   - Carry forward active blockers from old version
   - Reset Section VII (Session History) to empty

3. Commit:
   ```bash
   git add CONTEXT.md session_handoffs/archive/
   git commit -m "Archive: CONTEXT for YYYY-MM"
   ```

**Shared_context.md archival**:
- Move old monthly summaries to archive section
- Keep current + last 3 months in Section V
- Archive older summaries as needed

---------------------------------------------------------------------------------------------------------------------------

## 8. Checkpoint & Recovery

### 8.1 Purpose

Checkpoints preserve session progress at regular intervals (60-90 minutes) to minimize context loss if the session is interrupted. This is a **manual process** triggered by the user when the warmup status shows ⚠️ or 🔴.

### 8.2 When to Checkpoint

**Warmup Status Indicators** (from SessionStart hook):

| Status | Token Age | Action Required       |
|--------|-----------|----------------------|
| ✅     | <240m     | Continue working      |
| ⚠️     | 240-480m  | Checkpoint recommended|
| 🔴     | >480m     | Checkpoint required   |

**User triggers checkpoint** when:
1. Warmup status shows ⚠️ (warning) or 🔴 (critical)
2. About to start complex/risky operation
3. Natural break point in work (feature complete, tests passing)
4. Before stepping away from keyboard

### 8.3 Checkpoint Workflow

**User command**: `"checkpoint"` or `"save progress"`

**Claude performs** (in order):

```markdown
1. Update session handoff file
   - Section II: Work Summary (add completed items)
   - Section III: State Snapshot (update current state)
   - Section V: Blockers & Risks (note any new issues)
   - Section VI: Next Steps (update pending work)

2. Update CONTEXT.md
   - Section I: Current State (latest snapshot)
   - Section III: Active Work (in-progress items)
   - Section V: Blockers & Risks (current issues)
   - Section VII: Session History (add checkpoint entry)

3. Commit code changes
   - Stage modified files: git add .
   - Create commit: git commit -m "Checkpoint: [brief description]"
   - Do NOT push (user decides when to push)

4. Confirm to user
   - List files updated
   - Show commit hash
   - Display warmup status after checkpoint
```

### 8.4 What Gets Saved

**Session Handoff Updates**:
- Completed work since last checkpoint
- Current in-progress items
- New blockers or risks discovered
- Updated next steps
- Code changes made

**CONTEXT.md Updates**:
- Latest project state
- Active work items
- Current blockers
- Checkpoint timestamp in session history

**Code Commits**:
- All modified files staged and committed
- Commit message includes "Checkpoint:" prefix
- Local commits only (no automatic push)

**NOT Saved**:
- Conversation history (too large, not needed)
- Tool results (can be regenerated)
- Temporary files (*.tmp, .DS_Store, etc.)

### 8.5 Recovery Process

**If session interrupted** (crash, network loss, force quit):

1. **Start new session**
   - User: `"confirm and next"`
   - Claude reads CONTEXT.md automatically (Layer 6)
   - Claude loads latest session handoff from filename

2. **Resume from checkpoint**
   - Review Section II: Work Summary (what was completed)
   - Review Section III: State Snapshot (where we were)
   - Review Section VI: Next Steps (what to do next)
   - Check git log for last commit: `git log -1`

3. **Verify state**
   - Run tests if applicable: `npm test` / `pytest` / etc.
   - Check file modifications: `git status`
   - Confirm with user before continuing work

**Example Recovery**:
```
User: "Session crashed. Recover from checkpoint."

Claude reads:
- CONTEXT.md → Section VII shows checkpoint at 14:30
- session_handoffs/20260109_1300.md → Section VI shows next steps
- git log → Shows "Checkpoint: Completed auth module tests" at 14:30

Claude responds:
"Recovered from checkpoint at 14:30. Last commit: auth module tests complete.
 Next steps: Implement password reset flow (from handoff Section VI).
 Git status shows working directory clean. Ready to continue?"
```

### 8.6 Checkpoint Frequency

**Recommended intervals**:
- Every 60-90 minutes (when ⚠️ appears)
- After completing logical units of work
- Before risky operations (migrations, refactors)
- When stepping away

**Not recommended**:
- Every few minutes (overhead too high)
- Mid-task (wait for logical break)
- When no meaningful progress made

### 8.7 Manual Control

All checkpoint operations are **manual**:
- User must type `"checkpoint"` command
- Claude does not automatically checkpoint at time intervals
- User decides when to commit and push
- User controls archival of old checkpoints

**Why manual**: Prevents unwanted commits, allows user to control git history, avoids checkpoint spam.

---------------------------------------------------------------------------------------------------------------------------

## 9. Archival System

### 9.1 Purpose

Archive old session handoff files monthly to keep the active workspace clean while preserving historical context. This is a **manual process** triggered by the user at the start of each month.

### 9.2 What Gets Archived

**Session handoff files**:
- All `session_handoffs/YYYYMMDD_HHMM_*.md` files from previous months
- Move to `session_handoffs/archive/YYYY/MM/`

**CONTEXT.md versions**:
- Save current CONTEXT.md as `CONTEXT_YYYYMM.md`
- Move to `session_handoffs/archive/YYYY/MM/`
- Create fresh CONTEXT.md for new month

**NOT archived**:
- Current month's handoff files (stay active)
- CLAUDE.md (never archived)
- session_config.md (never archived)
- Code files (managed by git)

### 9.3 Archive Folder Structure

```
{project}/
└── session_handoffs/
    ├── archive/
    │   ├── 2025/
    │   │   ├── 12/
    │   │   │   ├── 20251201_0900_feature_auth.md
    │   │   │   ├── 20251215_1400_bugfix_login.md
    │   │   │   └── CONTEXT_202512.md
    │   │   └── 11/
    │   │       ├── 20251105_1000_initial_setup.md
    │   │       └── CONTEXT_202511.md
    │   └── 2026/
    │       └── 01/
    │           ├── 20260108_0930_refactor_api.md
    │           └── CONTEXT_202601.md
    │
    ├── 20260209_1030_new_feature.md    ← Current month (active)
    ├── 20260210_1500_bug_fix.md        ← Current month (active)
    └── CONTEXT.md                       ← Current (active)
```

### 9.4 Monthly Archive Workflow

**User command** (first session of new month): `"archive last month's handoffs"`

**Claude performs**:

```markdown
1. Create archive directory
   mkdir -p session_handoffs/archive/YYYY/MM/

2. Move previous month's handoff files
   mv session_handoffs/YYYYMM*.md session_handoffs/archive/YYYY/MM/

3. Archive current CONTEXT.md
   cp CONTEXT.md session_handoffs/archive/YYYY/MM/CONTEXT_YYYYMM.md

4. Create fresh CONTEXT.md
   - Copy Section I-VI structure from template
   - Add note: "Archived CONTEXT_YYYYMM.md on [date]"
   - Carry forward active blockers from old CONTEXT.md
   - Reset session history to empty

5. Commit archival
   git add session_handoffs/archive/
   git commit -m "Archive: Session handoffs for YYYY-MM"

6. Confirm to user
   - List archived files
   - Show new CONTEXT.md location
   - Display archive folder structure
```

### 9.5 Retention Policy

**Keep indefinitely**:
- All archived handoff files (disk space is cheap)
- All archived CONTEXT.md files
- Archive folder structure

**Optional cleanup** (user decides):
- Delete handoffs older than 2 years if project is inactive
- Compress archives: `tar -czf YYYY.tar.gz archive/YYYY/`
- Move to cold storage (external drive, cloud backup)

**Never delete**:
- Current month's handoffs
- Active CONTEXT.md
- Any file marked as "reference" in handoff notes

### 9.6 Accessing Archived Sessions

**Search archived handoffs**:
```bash
# Find handoffs mentioning "authentication"
grep -r "authentication" session_handoffs/archive/

# List all handoffs from December 2025
ls session_handoffs/archive/2025/12/

# Read specific archived handoff
cat session_handoffs/archive/2025/12/20251215_1400_bugfix_login.md
```

**Why archive** (not delete):
- Historical context for debugging ("when did we change X?")
- Audit trail for compliance
- Learning from past decisions
- Onboarding new team members

---------------------------------------------------------------------------------------------------------------------------

## 10. Plugin Integration

### 10.1 Plugin Role in Sessions

Plugins extend Claude Code functionality but do **not** directly modify session handoff files. Plugins operate through Layer 7 (Plugin prompts) of the 10-layer system.

**What plugins CAN do**:
- Add context to session via hook injections (Layer 5)
- Provide specialized tools during sessions
- Generate artifacts that Claude includes in handoffs
- Track plugin-specific metrics for Section IX of handoff template

**What plugins CANNOT do**:
- Automatically create or modify session handoff files
- Override v3 session lifecycle (Start → Checkpoint → Finalize)
- Archive handoffs independently
- Bypass manual checkpoint triggers

### 10.2 Plugin Context in Handoffs

**Section IX: Plugin Cost Summary** (in session handoff template):

```markdown
## IX. Plugin Cost Summary

**Active Plugins** (37 total):
- explanatory-output-style: ~1200 tokens/session
- learning-output-style: ~1100 tokens/session
- hookify: ~50 tokens/session
- [others]: <10 tokens each

**Total plugin overhead**: ~2400 tokens

**Recommendation for next session**:
- Disable explanatory-output-style (not needed for coding work)
- Keep hookify (provides warmup status)
```

**Why track plugin costs**:
- High-cost plugins (>1000 tokens) reduce available context
- User can decide to disable expensive plugins for long sessions
- Helps explain why context fills faster than expected

### 10.3 Plugin-Generated Artifacts

**Plugins may create files** that Claude references in handoffs:

| Plugin                | Artifact              | Handoff Reference                            |
|-----------------------|-----------------------|---------------------------------------------|
| hookify               | hookify_rules.md      | Link in Section VII (Context Links)         |
| pr-review-toolkit     | PR review reports     | Include summary in Section IV (Changes)     |
| sentry                | Error analysis        | Include in Section V (Blockers & Risks)     |
| Notion                | Task sync status      | Note in Section VIII (Project-Specific)     |

**Example in handoff**:
```markdown
## IV. Changes Detail

### Code Changes
- Fixed authentication bug in src/auth.ts:45
- Added error handling in src/api.ts:123

### Plugin-Generated Reports
- sentry-issue-summarizer created error_analysis_20260109.md
  - 3 critical errors identified
  - See session_handoffs/reports/error_analysis_20260109.md
```

### 10.4 Hook Integration with Sessions

**SessionStart hook** (unchanged from v2.5):
- Injects date, boundaries, plugin count (Layer 5)
- Does NOT create session handoff (manual trigger required)
- Provides warmup status (✅/⚠️/🔴) for checkpoint decisions

**PreToolUse/PostToolUse hooks** (unchanged from v2.5):
- Enforce boundaries (CAN/CANNOT modify)
- Block dangerous operations
- Do NOT automatically trigger checkpoints

**Stop hook** (unchanged from v2.5):
- Runs when session ends naturally
- Does NOT finalize handoff (manual trigger required)
- Can remind user to finalize if handoff is incomplete

### 10.5 Plugin Recommendations

**For long sessions** (>480m context age):
- Disable output-styling plugins (explanatory, learning, ralph-wiggum)
- Keep essential plugins only (hookify for warmup status)
- Check `/plugin` list before session start

**For short sessions** (<240m):
- Safe to use multiple plugins
- Output styling plugins acceptable

**Tracking in handoff**:
```markdown
## IX. Plugin Cost Summary

**Session start**: 37 plugins active (2400 tokens overhead)
**Session end**: 3 plugins active (100 tokens overhead)

**Changes made**:
- Disabled explanatory-output-style at checkpoint 1
- Disabled learning-output-style at checkpoint 2
- Kept hookify for warmup monitoring
```

### 10.6 Plugin-Specific Session Config

Projects can configure plugin behavior in `session_config.md`:

```markdown
## Plugin Configuration

### Always Enable
- hookify (warmup status required)
- sentry (error monitoring needed)

### Always Disable
- explanatory-output-style (too verbose for this project)
- ralph-wiggum (humor not needed)

### Enable on Demand
- pr-review-toolkit (only when reviewing PRs)
- frontend-design (only when building UI)
```

Claude reads this config at session start and suggests plugin adjustments.

---------------------------------------------------------------------------------------------------------------------------

## 11. Directory Intelligence

### 11.1 Overview

Directory Intelligence is a **manual reference system** (not automated) that helps Claude navigate complex multi-product codebases by understanding folder hierarchies and project relationships.

**What it is**:
- Documentation file: `CLAUDE_DIRECTORY_REFERENCE_v2.md` (from v2.5)
- Describes folder structure, product boundaries, naming conventions
- Referenced by Claude when exploring unfamiliar projects
- Maintained manually by user

**What it is NOT**:
- Automatic folder scanning (user creates/updates manually)
- Live filesystem monitoring
- Auto-generated documentation

### 11.2 When to Use Directory Intelligence

**Claude references directory guide** when:
1. User says "explore the codebase structure"
2. Working across multiple products in a monorepo
3. Unclear where specific functionality lives
4. Planning where to place new features
5. Understanding product boundaries for governance

**Not needed** when:
- Working in single-project repo
- Folder structure is self-evident (standard conventions)
- User explicitly tells Claude where files are

### 11.3 Directory Reference Structure

**Minimal directory reference** (example):

```markdown
# Directory Reference - MyMonorepo

## Overview
Monorepo containing 3 products: Web, API, Mobile

## Structure
```
monorepo/
├── products/
│   ├── web/          ← React frontend (Type: CODE)
│   ├── api/          ← Node.js backend (Type: CODE)
│   └── mobile/       ← React Native app (Type: CODE)
├── shared/
│   └── utils/        ← Shared libraries
└── docs/             ← Product documentation (Type: BIZZ)
```

## Boundaries
- Web product: CAN modify products/web/, shared/utils/
- API product: CAN modify products/api/, shared/utils/
- Mobile product: CAN modify products/mobile/, shared/utils/
- CANNOT modify: products/*/node_modules/, .git/

## Naming Conventions
- Feature branches: feature/product-name/description
- CLAUDE.md location: products/{name}/CLAUDE.md
- Session handoffs: products/{name}/session_handoffs/
```

### 11.4 Multi-Product Navigation

**Example: User asks to add authentication**

Without directory intelligence:
```
User: "Add authentication"
Claude: "Where should I add it? Web product? API? Both?"
```

With directory intelligence:
```
User: "Add authentication"
Claude reads: CLAUDE_DIRECTORY_REFERENCE_v2.md
Claude: "I see this is a monorepo. Authentication should be:
  - API: products/api/src/auth/ (backend logic)
  - Web: products/web/src/components/Login/ (UI)
  - Shared: shared/utils/auth-helpers/ (validation)

  Should I proceed with all three?"
```

### 11.5 Creating Directory Reference

**User creates manually** when:
- Setting up new monorepo
- Onboarding Claude to complex codebase
- Folder structure is non-standard

**Steps**:
1. Create `CLAUDE_DIRECTORY_REFERENCE_v2.md` at repo root
2. Document folder structure (see §11.3 example)
3. Define product boundaries
4. Note naming conventions
5. Link from root CLAUDE.md

**Template** available at:
```
~/Desktop/Governance/templates/CLAUDE_DIRECTORY_REFERENCE_TEMPLATE.md
```

### 11.6 Updating Directory Reference

**When to update**:
- New product added to monorepo
- Folder structure reorganized
- Boundaries change (new CAN/CANNOT rules)
- Naming conventions updated

**How to update**:
- User edits CLAUDE_DIRECTORY_REFERENCE_v2.md directly
- Add changelog entry at bottom of file
- Update "Last Updated" date in frontmatter
- No automation (manual maintenance)

### 11.7 Relationship to Session Handoffs

**Directory intelligence does NOT**:
- Auto-populate handoff files
- Track session progress across products
- Generate Shared_context.md

**Directory intelligence DOES**:
- Help Claude understand where to save handoff files
- Guide multi-product checkpoint decisions
- Inform Section VII (Context Links) in handoffs

**Example in handoff**:
```markdown
## VII. Context Links

**Related Products** (from directory reference):
- This session: products/api/ (API product)
- Related: products/web/ (needs corresponding UI changes)
- See: CLAUDE_DIRECTORY_REFERENCE_v2.md for full structure
```

---------------------------------------------------------------------------------------------------------------------------

## 12. Per-Product Setup

### 12.1 Purpose

Per-product configuration allows projects to customize session handoff behavior without modifying global templates. This uses an optional `session_config.md` file in each project's `.claude/` directory.

### 12.2 Configuration File Location

```
{project}/
├── .claude/
│   └── session_config.md       ← Optional project-specific overrides
├── CLAUDE.md                    ← Required (project rules)
├── CONTEXT.md                   ← Created by v3
└── session_handoffs/            ← Created by v3
```

**If session_config.md exists**: Claude reads it at session start (after CLAUDE.md, before CONTEXT.md)

**If session_config.md missing**: Claude uses global defaults from `~/.claude/templates/session_handoff.md`

### 12.3 Configuration Structure

**Minimal session_config.md**:

```markdown
---------------------------------------------------------------------------------------------------------------------------
# Session Configuration
project_type: CODE
checkpoint_interval: 90  # minutes (60-90 recommended)
---------------------------------------------------------------------------------------------------------------------------

## Handoff Template Overrides

### Section III: State Snapshot (Custom Fields)
- Active feature flags: [list]
- Database migration status: [version]
- Deployment environment: [staging/prod]

## Plugin Configuration

### Always Enable
- sentry (error monitoring)
- hookify (warmup status)

### Always Disable
- explanatory-output-style (too verbose)

## Custom Workflows

### Before Checkpoint
1. Run tests: `npm test`
2. Check linting: `npm run lint`
3. Verify build: `npm run build`

### Before Finalize
1. Run full test suite: `npm run test:all`
2. Update changelog: CHANGELOG.md
3. Verify all TODOs resolved
```

### 12.4 Template Override Examples

**CODE Project** (add technical fields):

```markdown
## Handoff Template Overrides

### Section III: State Snapshot
**Custom fields**:
- Test coverage: [percentage]
- Build status: [passing/failing]
- Linting errors: [count]
- Active feature flags: [list]
- Database version: [migration number]

### Section VIII: Project-Type-Specific
**Technical debt**:
- Known issues: [list from backlog]
- Refactor targets: [components needing cleanup]
- Performance bottlenecks: [profiled slowdowns]
```

**BIZZ Project** (add strategy fields):

```markdown
## Handoff Template Overrides

### Section III: State Snapshot
**Custom fields**:
- OKR progress: [percentage toward quarterly goals]
- Stakeholder status: [list of stakeholder approvals]
- Budget tracking: [spent vs allocated]
- Timeline status: [on track / delayed]

### Section VIII: Project-Type-Specific
**Strategic decisions**:
- Market research findings: [key insights]
- Competitive analysis: [changes in landscape]
- Customer feedback: [themes from surveys]
```

**OPS Project** (add operational fields):

```markdown
## Handoff Template Overrides

### Section III: State Snapshot
**Custom fields**:
- Service uptime: [percentage]
- Incident count: [number since last session]
- Backup status: [last backup timestamp]
- Monitoring alerts: [active alert count]

### Section VIII: Project-Type-Specific
**Operational metrics**:
- Infrastructure costs: [current spend vs budget]
- Deployment frequency: [count this month]
- Mean time to recovery: [hours]
```

### 12.5 Plugin Configuration

**session_config.md can specify**:

```markdown
## Plugin Configuration

### Always Enable
- hookify (warmup monitoring)
- sentry (error tracking)
- pr-review-toolkit (PR workflow)

### Always Disable
- explanatory-output-style (high token cost)
- ralph-wiggum (humor not needed)

### Enable on Demand
- frontend-design (only for UI work)
- stripe (only for payment features)

### Plugin-Specific Settings
**sentry**:
- project: my-project-name
- alert_threshold: error

**Notion**:
- database_id: abc123...
- sync_frequency: manual
```

Claude reads this at session start and suggests plugin adjustments to user.

### 12.6 Custom Workflows

**Define project-specific procedures**:

```markdown
## Custom Workflows

### Session Start
1. Verify environment variables loaded
2. Check database connection
3. Pull latest from main branch
4. Run migrations if needed

### Before Checkpoint
1. Run tests: `npm test`
2. Commit with "Checkpoint:" prefix
3. Verify no uncommitted files

### Before Finalize
1. Run full test suite: `npm run test:all`
2. Update CHANGELOG.md with session changes
3. Verify all TODOs resolved or documented
4. Push to remote branch
5. Create PR if feature complete

### Monthly Archive
1. Generate code metrics: `npm run metrics`
2. Export test coverage report
3. Archive metrics with handoffs
```

**Manual execution**: User triggers these workflows by asking Claude (not automatic).

### 12.7 Configuration Inheritance

**Layer priority** (highest to lowest):

1. `{project}/.claude/session_config.md` (most specific)
2. `~/.claude/templates/session_handoff.md` (global default)
3. Built-in v3 template (fallback if no files exist)

**Example**:
- Global template defines 12 sections
- session_config.md adds custom fields to Section III
- Result: 12 sections with enhanced Section III

**Overrides are additive** (not replacements):
- Custom fields add to standard fields
- Standard sections remain (can't remove Section II, for example)
- Can only extend, not reduce

### 12.8 Creating session_config.md

**User creates manually**:

```bash
# Navigate to project
cd {project}

# Create .claude directory if missing
mkdir -p .claude

# Create config file
cat > .claude/session_config.md << 'EOF'
---------------------------------------------------------------------------------------------------------------------------
project_type: CODE
checkpoint_interval: 90
---------------------------------------------------------------------------------------------------------------------------

## Handoff Template Overrides
[Add custom fields here]

## Plugin Configuration
[Add plugin preferences here]
EOF
```

**Template available at**:
```
~/Desktop/Governance/templates/session_config_TEMPLATE.md
```

### 12.9 Validating Configuration

**At session start**, Claude checks:

```markdown
1. session_config.md exists?
   - Yes: Read and apply overrides
   - No: Use global template (no error)

2. Validate YAML frontmatter
   - project_type: CODE/BIZZ/OPS (required)
   - checkpoint_interval: 60-90 (optional)
   - Warn if invalid values

3. Apply template overrides
   - Merge custom fields into Section III, VIII
   - Note in session handoff: "Using custom config"

4. Configure plugins
   - Suggest enabling/disabling per config
   - User confirms changes
```

**Example output**:
```
Session start: 2026-01-09
Project: MyProject (TYPE: CODE)
Config: .claude/session_config.md found

Applying overrides:
- Section III: Added fields [test coverage, build status]
- Section VIII: Added technical debt tracking
- Plugins: Suggest enabling sentry, disabling explanatory-output-style

Proceed with these settings? (User confirms)
```

---------------------------------------------------------------------------------------------------------------------------

## 13. Portfolio Management

### 13.1 Purpose

Portfolio management tracks progress across multiple projects using a global `Shared_context.md` file. This provides a unified view of all active work.

### 13.2 Shared_context.md Location

```
~/.claude/
├── CLAUDE.md                    ← Global rules (Layer 2)
├── Shared_context.md            ← Portfolio view (NEW in v3)
├── templates/
│   └── session_handoff.md       ← Global template
└── sessions/
    └── {project_hash}_session.json
```

**Created manually** by user when managing multiple projects.

### 13.3 Shared_context.md Structure

```markdown
# Shared Context - Portfolio View

> Last updated: 2026-01-09

## I. Active Projects

| Project     | Type | Status | Last Session | Next Priority           |
|-------------|------|--------|--------------|-------------------------|
| Governance  | OPS  | Active | 2026-01-09   | Complete v3 spec        |
| MyWebApp    | CODE | Active | 2026-01-08   | Deploy auth feature     |
| Marketing   | BIZZ | Paused | 2025-12-15   | Q1 strategy review      |

## II. Cross-Project Blockers

**Shared dependencies**:
- Waiting for design system update (affects MyWebApp, MobileApp)
- Infrastructure migration pending (blocks deployment for all projects)

**Resource conflicts**:
- API rate limit shared across projects (need to upgrade plan)

## III. Recent Decisions (Cross-Project)

| ID   | Date       | Decision                    | Affects      |
|------|------------|-----------------------------|--------------|
| #G12 | 2026-01-09 | Adopt v3 governance         | All projects |
| #I5  | 2026-01-05 | Migrate to Backblaze        | Governance   |
| #S3  | 2025-12-20 | Enforce 2FA                 | All CODE     |

## IV. Shared Resources

**Common utilities**:
- `~/Desktop/Governance/templates/` (CLAUDE.md templates)
- `~/Desktop/Governance/scripts/` (automation scripts)

**Shared infrastructure**:
- Database: PostgreSQL on shared instance
- Storage: Backblaze account (all backups)
- CI/CD: GitHub Actions (shared runner)

## V. Monthly Summary

**January 2026**:
- Governance: Completed v3 specification
- MyWebApp: Shipped authentication feature
- Marketing: Paused for Q1 planning

**Upcoming (February 2026)**:
- Governance: Migrate all projects to v3
- MyWebApp: Add payment integration
- Marketing: Resume with new strategy

## VI. Portfolio Metrics

**Active sessions**: 2 projects
**Total context age**: 180m (Governance), 60m (MyWebApp)
**Checkpoint count**: 5 this week
**Archive size**: 12GB across all projects

## VII. Notes

- Governance is the master project (contains templates for all others)
- MyWebApp and MobileApp share authentication backend
- Marketing project uses BIZZ template
```

Full template in §18.C.

### 13.4 Updating Shared_context.md

**Manual updates** (user triggers):

```markdown
1. After major milestones
   - Project completes phase
   - New project added to portfolio
   - Project archived or paused

2. Monthly review
   - Update Section V: Monthly Summary
   - Archive completed projects
   - Plan next month's priorities

3. When blockers affect multiple projects
   - Add to Section II: Cross-Project Blockers
   - Reference in affected project CONTEXT.md files
```

**Example workflow**:
```
User: "Update shared context after completing auth feature"

Claude:
1. Reads MyWebApp/CONTEXT.md (find completion details)
2. Reads ~/.claude/Shared_context.md
3. Updates Section I: Active Projects (mark auth feature done)
4. Updates Section V: Monthly Summary (add completion)
5. Confirms to user: "Shared context updated. Next priority: payment integration"
```

### 13.5 Relationship to Per-Project CONTEXT.md

**Shared_context.md** (portfolio level):
- High-level progress across all projects
- Cross-project dependencies
- Shared resources and blockers
- Monthly summaries

**CONTEXT.md** (project level):
- Detailed state for one project
- Active work items
- Project-specific decisions
- Recent session history

**Information flow**:
```
Project CONTEXT.md → (manual) → Shared_context.md
   ↓                                     ↓
Detailed                             Summarized
Single project                       All projects
Updated every session                Updated monthly or at milestones
```

**Example**:
```
Governance/CONTEXT.md:
- Section III: Active Work = "Drafting v3 §8-18"
- Section IV: Decisions = "#G12: Adopt v3 governance"

~/.claude/Shared_context.md:
- Section I: Active Projects = "Governance: Complete v3 spec"
- Section III: Recent Decisions = "#G12: Adopt v3 governance (affects all)"
```

### 13.6 Multi-Project Sessions

**When working across projects in one session**:

```markdown
User: "Update auth in MyWebApp and MobileApp"

Claude:
1. Reads both CONTEXT.md files:
   - MyWebApp/CONTEXT.md
   - MobileApp/CONTEXT.md

2. Creates session handoffs in both projects:
   - MyWebApp/session_handoffs/20260109_1000.md
   - MobileApp/session_handoffs/20260109_1000.md

3. Updates both CONTEXT.md files at checkpoint

4. Notes in Shared_context.md:
   - Section II: "Auth update affects MyWebApp and MobileApp"
   - Section I: Update last session date for both projects
```

**Cross-references in handoffs**:
```markdown
## VII. Context Links

**Related project**: MobileApp
- See: MobileApp/session_handoffs/20260109_1000.md
- Shared auth backend changes require corresponding UI updates

**Portfolio view**: ~/.claude/Shared_context.md
- This session affects 2 of 5 active projects
```

### 13.7 Creating Shared_context.md

**User creates manually** when:
- Managing 3+ projects simultaneously
- Need cross-project visibility
- Coordinating shared resources

**Steps**:
1. Create `~/.claude/Shared_context.md`
2. Use template from §13.3 above
3. Add all active projects to Section I
4. Note shared resources in Section IV
5. Update monthly in Section V

**Not required** if:
- Working on single project
- Projects are completely independent
- No shared resources or dependencies

### 13.8 Portfolio Workflows

**Monthly portfolio review**:

```bash
# User triggers at start of month
User: "Monthly portfolio review"

Claude performs:
1. Read all active project CONTEXT.md files
2. Summarize progress in Shared_context.md Section V
3. Update Section I with latest session dates
4. Check for stale projects (no activity >30 days)
5. Suggest archiving inactive projects
6. Output summary report to user
```

**Example monthly summary**:
```markdown
## Portfolio Review - January 2026

**Completed**:
- Governance: v3 Full Spec (18 sections)
- MyWebApp: Authentication feature shipped

**In Progress**:
- MobileApp: Auth integration (80% complete)

**Paused**:
- Marketing: Waiting for Q1 budget approval

**Blockers**:
- Design system update (affects 2 projects)

**Recommended actions**:
- Archive Marketing project (inactive 25 days)
- Resume MobileApp (final 20% can complete this week)
- Start payment integration in MyWebApp
```

---------------------------------------------------------------------------------------------------------------------------

## 14. Decision ID System

### 14.1 Purpose

Decision IDs provide permanent references to architectural decisions, security choices, and governance policies. This system is unchanged from v2.5 and carries forward to v3.

### 14.2 ID Format

**Structure**: `#[PREFIX][NUMBER]`

**Prefixes** (from global CLAUDE.md):

| Prefix | Category       | Example                      | Usage                                               |
|--------|----------------|------------------------------|-----------------------------------------------------|
| `#G`   | Governance     | `#G12` - Adopt v3 system     | Project structure, templates, governance rules      |
| `#P`   | Process        | `#P5` - Weekly code reviews  | Workflows, procedures, recurring activities         |
| `#I`   | Infrastructure | `#I8` - Use PostgreSQL       | Tech stack, hosting, deployment decisions           |
| `#S`   | Security       | `#S3` - Enforce 2FA          | Authentication, encryption, access control          |
| `#B`   | Backup         | `#B1` - 3-2-1 backup strategy| Data protection, disaster recovery                  |

**Project-specific prefixes** (optional):

| Prefix | Category | Example                    |
|--------|----------|----------------------------|
| `#A`   | API      | `#A4` - REST over GraphQL  |
| `#D`   | Database | `#D2` - Normalize to 3NF   |
| `#U`   | UI/UX    | `#U7` - Material Design    |
| `#T`   | Testing  | `#T3` - 80% coverage min   |

### 14.3 Recording Decisions

**In CONTEXT.md** (Section IV: Decisions & Architecture):

```markdown
## IV. Decisions & Architecture

### Recent Decisions

| ID   | Date       | Decision                | Rationale                       | Impact       |
|------|------------|-------------------------|---------------------------------|--------------|
| #G12 | 2026-01-09 | Adopt v3 governance     | Session continuity needed       | All projects |
| #I8  | 2026-01-05 | Migrate to Backblaze    | Cost effective backup           | Governance   |
| #S3  | 2025-12-20 | Enforce 2FA             | Security compliance             | All users    |

### Architecture Notes

**#I8 Details** (Backblaze migration):
- Selected over AWS S3 due to simpler pricing
- $9/mo for unlimited storage
- Decision recorded: 2026-01-05
- Implementation: Pending (blocked on account setup)
- Affects: All backup workflows
```

**In session handoffs** (Section IV: Changes Detail):

```markdown
## IV. Changes Detail

### Decisions Made This Session

**#G12: Adopt v3 governance system**
- Rationale: Need session continuity for long-running projects
- Impact: All future projects use v3 templates
- Documented in: Governance/CONTEXT.md
- Implementation: Optional migration (see §16)
```

### 14.4 Referencing Decisions

**In code comments**:

```javascript
// Use Backblaze for backups (#I8)
const backupConfig = {
  provider: 'backblaze',
  bucket: 'filiciti-backups'
};
```

**In documentation**:

```markdown
## Authentication

This project uses 2FA for all users (#S3).
See CONTEXT.md #S3 for security requirements.
```

**In git commits**:

```bash
git commit -m "feat: Add Backblaze backup integration (#I8)"
```

**In session handoffs** (Section VII: Context Links):

```markdown
## VII. Context Links

**Related decisions**:
- #I8 (Backblaze migration) - See CONTEXT.md:45
- #S3 (2FA enforcement) - See docs/security.md
```

### 14.5 Decision Lifecycle

**1. Proposal** (during session):
```
User: "Should we use PostgreSQL or MySQL?"
Claude: "Recommend PostgreSQL for JSON support and better tooling.
         Shall I record this as decision #I8?"
User: "Yes"
Claude: Adds to CONTEXT.md Section IV with status "Proposed"
```

**2. Approval** (user confirms):
```
User: "Approved"
Claude: Updates CONTEXT.md → status "Approved"
        Adds to session handoff Section IV
```

**3. Implementation**:
```
Claude: Adds PostgreSQL to package.json, creates migrations
        References #I8 in commit message
        Updates CONTEXT.md → status "Implemented"
```

**4. Review** (validate decision):
```
User (1 month later): "How's PostgreSQL working?"
Claude: Reads CONTEXT.md → finds #I8
        Reviews performance metrics, issues
        Updates decision notes if needed
```

**5. Revision** (change decision):
```
User: "Switch to MySQL"
Claude: Creates new decision #I9 (supersedes #I8)
        Notes in CONTEXT.md: "#I9 replaces #I8 (reason: licensing)"
        Archives #I8 → status "Superseded by #I9"
```

### 14.6 Decision Categories in v3

**Governance decisions** (affect session management):

| ID   | Decision                       | v3 Impact                      |
|------|--------------------------------|--------------------------------|
| #G12 | Adopt v3 governance            | Enables session handoffs       |
| #G13 | Manual checkpoint triggers     | No automatic handoff creation  |
| #G14 | Monthly archival               | Move old handoffs to archive/  |
| #G15 | Optional v3 adoption           | v2.5 projects work unchanged   |
| #G16 | Add Layer 6 (Session Context)  | CONTEXT.md loads at start      |
| #G17 | 12-section handoff template    | Standardized documentation     |

**Process decisions** (affect workflows):

| ID   | Decision                       | v3 Impact                      |
|------|--------------------------------|--------------------------------|
| #P10 | Checkpoint every 60-90min      | Aligns with warmup status      |
| #P11 | Finalize before session end    | Ensure handoff completeness    |
| #P12 | User triggers all handoffs     | No automation (manual control) |

**Infrastructure decisions** (affect Layer 6 loading):

| ID   | Decision                            | v3 Impact                      |
|------|-------------------------------------|--------------------------------|
| #I15 | Store handoffs in session_handoffs/ | Separate from code files       |
| #I16 | CONTEXT.md in project root          | Easy access for Layer 6        |
| #I17 | Shared_context.md global            | Portfolio-level tracking       |

### 14.7 Cross-Project Decision Tracking

**In Shared_context.md** (Section III):

```markdown
## III. Recent Decisions (Cross-Project)

| ID   | Date       | Decision                | Affects      | Status      |
|------|------------|-------------------------|--------------|-------------|
| #G12 | 2026-01-09 | Adopt v3 governance     | All projects | Approved    |
| #I5  | 2026-01-05 | Backblaze for backups   | Governance   | Pending     |
| #S3  | 2025-12-20 | Enforce 2FA             | All CODE     | Implemented |
```

**Project-specific decisions** stay in project CONTEXT.md:

```markdown
MyWebApp/CONTEXT.md:
- #I20: Use Redis for sessions (affects MyWebApp only)

Governance/CONTEXT.md:
- #G12: Adopt v3 governance (affects all projects)
```

### 14.8 Decision Search

**Find decisions by ID**:

```bash
# Search all CONTEXT.md files
grep -r "#G12" ~/Desktop/*/CONTEXT.md

# Search session handoffs
grep -r "#G12" ~/Desktop/Governance/session_handoffs/

# Search code comments
grep -r "#G12" ~/Desktop/MyWebApp/src/
```

**Find decisions by category**:

```bash
# All governance decisions
grep "#G[0-9]" Governance/CONTEXT.md

# All security decisions across projects
grep -r "#S[0-9]" ~/Desktop/*/CONTEXT.md
```

### 14.9 Decision ID Best Practices

**DO**:
- Assign IDs immediately when decision is made
- Record rationale (why, not just what)
- Note impact (which files, projects affected)
- Reference IDs in code, commits, docs
- Keep decision history (don't delete old IDs)

**DON'T**:
- Reuse old IDs (numbers only go up)
- Skip recording small decisions (they matter later)
- Use IDs for tasks/todos (those are temporary)
- Forget to update status (Proposed → Approved → Implemented)

---------------------------------------------------------------------------------------------------------------------------

## 15. Scripts & Tools

### 15.1 Available Scripts

Scripts from v2.5 (unchanged) plus new v3-specific tools for session management.

**Location**: `~/Desktop/Governance/scripts/`

### 15.2 v2.5 Scripts (Carry Forward)

**Governance setup**:
```bash
# Create symlinks for governance files
./scripts/setup_governance_symlinks.sh

# Setup plan file symlinks
./scripts/setup_plan_symlinks.sh

# Create reference folder structure
./scripts/create_reference_structure.sh
```

**Usage** (unchanged from v2.5):
- Run once per project setup
- Creates `_governance/` folders with symlinks
- Links to central Governance hub

### 15.3 v3 Session Management Scripts

**New scripts** for v3 workflows:

#### 15.3.1 create_session_handoff.sh

**Purpose**: Initialize session handoff file at session start

**Usage**:
```bash
cd {project}
~/Desktop/Governance/scripts/create_session_handoff.sh "feature-name"
```

**What it does**:
1. Creates `session_handoffs/` directory if missing
2. Generates filename: `YYYYMMDD_HHMM_feature-name.md`
3. Copies template from `~/.claude/templates/session_handoff.md`
4. Fills Section I (Metadata) automatically
5. Leaves other sections empty for Claude to fill

#### 15.3.2 checkpoint_session.sh

**Purpose**: Save checkpoint (handoff + CONTEXT + git commit)

**Usage**:
```bash
cd {project}
~/Desktop/Governance/scripts/checkpoint_session.sh "checkpoint description"
```

**What it does**:
1. Prompts Claude to update current session handoff
2. Prompts Claude to update CONTEXT.md
3. Runs: `git add .`
4. Runs: `git commit -m "Checkpoint: [description]"`
5. Shows commit hash and updated files

**Does NOT**:
- Push to remote (manual)
- Create new handoff file (uses current)
- Run tests or linting (optional per project)

#### 15.3.3 finalize_session.sh

**Purpose**: Complete session handoff and mark immutable

**Usage**:
```bash
cd {project}
~/Desktop/Governance/scripts/finalize_session.sh
```

**What it does**:
1. Prompts Claude to fill all handoff sections (I-XII)
2. Updates CONTEXT.md Section VII (add session to history)
3. Adds frontmatter to handoff: `status: finalized`
4. Commits: `git commit -m "Session finalized: [date]"`
5. Outputs summary of session

#### 15.3.4 archive_sessions.sh

**Purpose**: Move old session handoffs to archive (monthly)

**Usage**:
```bash
cd {project}
~/Desktop/Governance/scripts/archive_sessions.sh 2025 12
```

**What it does**:
1. Creates `session_handoffs/archive/2025/12/`
2. Moves all `202512*.md` files to archive
3. Copies `CONTEXT.md` → `CONTEXT_202512.md` to archive
4. Creates fresh `CONTEXT.md` from template
5. Commits: `git commit -m "Archive: Session handoffs for 2025-12"`

### 15.4 Template Management Scripts

#### 15.4.1 sync_templates.sh

**Purpose**: Copy latest templates from Governance to global location

**Usage**:
```bash
~/Desktop/Governance/scripts/sync_templates.sh
```

**What it does**:
1. Copies `templates/session_handoff.md` → `~/.claude/templates/`
2. Copies `templates/TEMPLATE_*.md` → `~/.claude/templates/`
3. Verifies file integrity (checksums)
4. Outputs summary of synced files

**When to run**:
- After updating templates in Governance
- Before starting new project
- Monthly (to ensure latest versions)

#### 15.4.2 validate_project.sh

**Purpose**: Check project compliance with v3 requirements

**Usage**:
```bash
cd {project}
~/Desktop/Governance/scripts/validate_project.sh
```

**What it does**:
1. Checks for required files (CLAUDE.md, CONTEXT.md, session_handoffs/)
2. Validates CLAUDE.md format (Boundaries, Rules sections)
3. Checks session_config.md if exists (valid YAML)
4. Verifies handoff file naming (YYYYMMDD_HHMM pattern)
5. Outputs compliance report

**Example output**:
```
Project validation: MyWebApp

✅ CLAUDE.md exists and valid
✅ CONTEXT.md exists and valid
✅ session_handoffs/ directory exists
✅ session_config.md valid YAML
⚠️ Warning: 3 handoff files not finalized
❌ Error: Handoff file "2026-jan-09.md" invalid naming

Compliance: 4/6 checks passed
```

### 15.5 Utility Scripts

#### 15.5.1 session_summary.sh

**Purpose**: Generate summary of all sessions for a project

**Usage**:
```bash
cd {project}
~/Desktop/Governance/scripts/session_summary.sh
```

**Output**: Total sessions, date range, work time, completed work, decisions, recent sessions, next priority

#### 15.5.2 context_health.sh

**Purpose**: Check CONTEXT.md freshness and identify stale projects

**Usage**:
```bash
~/Desktop/Governance/scripts/context_health.sh
```

**Output**: Fresh projects (<7 days), stale projects (7-30 days), inactive projects (>30 days), recommendations

### 15.6 Script Installation

**Setup** (one-time):

```bash
# Navigate to Governance
cd ~/Desktop/Governance

# Make scripts executable
chmod +x scripts/*.sh

# Add to PATH (optional, for convenience)
echo 'export PATH="$PATH:~/Desktop/Governance/scripts"' >> ~/.zshrc
source ~/.zshrc
```

### 15.7 Script Customization

**Per-project overrides** (optional):

Create `{project}/.claude/scripts/` to override global scripts:

```
{project}/
├── .claude/
│   ├── session_config.md
│   └── scripts/
│       └── checkpoint_session.sh  ← Overrides global version
```

**Script priority**:
1. `{project}/.claude/scripts/` (most specific)
2. `~/Desktop/Governance/scripts/` (global)
3. Built-in (fallback)

---------------------------------------------------------------------------------------------------------------------------

## 16. Migration from v2.5

### 16.1 Migration Philosophy

v3 is **opt-in**. Existing v2.5 projects continue working without changes. Migration adds session continuity features but is not required.

### 16.2 Who Should Migrate

**Migrate to v3 if**:
- Long-running projects (>90min sessions common)
- Frequent context loss frustration
- Need cross-session continuity
- Want portfolio management (Shared_context.md)
- Multiple active projects (coordination needed)

**Stay on v2.5 if**:
- Short sessions (<60min typical)
- Single project, rarely interrupted
- Don't need handoff documentation
- Prefer minimal file structure

**Both work**: v2.5 and v3 projects can coexist. No forced upgrades.

### 16.3 Pre-Migration Checklist

**Before migrating**:

- [ ] Backup project (git commit all changes)
- [ ] Read v3_FULL_SPEC.md (this document)
- [ ] Verify v2.5 files exist (CLAUDE.md, ~/.claude/CLAUDE.md)
- [ ] Decide on project type (CODE/BIZZ/OPS)
- [ ] Review current context needs (CONTEXT.md structure)

**No breaking changes**:
- CLAUDE.md format unchanged
- Hook system unchanged
- Layer 1-5 unchanged
- Plugins work identically

### 16.4 Migration Steps

#### Step 1: Create CONTEXT.md

**Manual creation** (required for v3):

```bash
cd {project}

# Create CONTEXT.md from template
cat > CONTEXT.md << 'EOF'
# Context - {Project Name}

> Last updated: YYYY-MM-DD

## I. Current State

**Status**: [Active/Paused/Blocked]
**Phase**: [Planning/Development/Testing/Deployed]
**Progress**: [Brief summary]

## II. Progress Summary
[Completed/In Progress/Pending items]

## III. Active Work
[Current focus]

## IV. Decisions & Architecture
[Decision table]

## V. Blockers & Risks
[Current issues]

## VI. Roadmap
[Next steps]

## VII. Session History
[Empty - will fill during sessions]
EOF
```

**Fill with current project state** (one-time):
- Section I: Where project is now
- Section II: What's been completed
- Section III: Current work
- Section IV: Past decisions
- Section V: Known blockers
- Section VI: Next steps
- Section VII: Leave empty

**Commit**:
```bash
git add CONTEXT.md
git commit -m "Migration: Add CONTEXT.md for v3 (#G15)"
```

#### Step 2: Create session_handoffs/ Directory

```bash
cd {project}
mkdir -p session_handoffs/archive
```

**Optional .gitignore** (if handoffs should not be committed):
```bash
cat > session_handoffs/.gitignore << 'EOF'
*.md
!archive/
archive/**/*.md
EOF
```

**Or commit all handoffs** (recommended for audit trail).

**Commit**:
```bash
git add session_handoffs/
git commit -m "Migration: Create session_handoffs directory (#G15)"
```

#### Step 3: Optional - Create session_config.md

**Skip if using defaults**. Create only if project needs custom handoff fields or plugin configuration.

```bash
mkdir -p .claude

cat > .claude/session_config.md << 'EOF'
---------------------------------------------------------------------------------------------------------------------------
project_type: CODE  # or BIZZ, OPS
checkpoint_interval: 90
---------------------------------------------------------------------------------------------------------------------------

## Handoff Template Overrides
[Custom fields]

## Plugin Configuration
[Plugin preferences]
EOF
```

**Commit**:
```bash
git add .claude/session_config.md
git commit -m "Migration: Add session config (#G15)"
```

#### Step 4: Update Global Templates

**Sync latest v3 templates**:

```bash
~/Desktop/Governance/scripts/sync_templates.sh
```

**Verify**:
```bash
ls ~/.claude/templates/
# Should show: session_handoff.md, TEMPLATE_CODE.md, etc.
```

#### Step 5: Validate Migration

```bash
cd {project}
~/Desktop/Governance/scripts/validate_project.sh
```

**Expected output**:
```
✅ CLAUDE.md exists and valid
✅ CONTEXT.md exists and valid
✅ session_handoffs/ directory exists
✅ Ready for v3 sessions

Compliance: v3 migration complete
```

#### Step 6: First v3 Session

**Test v3 features**:

```bash
User: "confirm and next"
Claude reads CONTEXT.md (Layer 6)

User: "Create handoff for test-v3-migration"
Claude creates: session_handoffs/YYYYMMDD_HHMM_test-v3-migration.md

[Work for 30min]

User: "checkpoint"
Claude updates handoff + CONTEXT + commits

User: "finalize session handoff"
Claude fills all sections + marks immutable
```

### 16.5 Rollback (If Needed)

**If v3 doesn't work for you**:

```bash
# Remove v3 files
rm -rf session_handoffs/
rm CONTEXT.md
rm .claude/session_config.md

# Revert commits
git log --oneline | grep "Migration:"
git revert <hash1> <hash2> <hash3>

# Or reset (if not pushed)
git reset --hard HEAD~3
```

**Continue using v2.5**: CLAUDE.md, hooks, plugins, Layer 1-5 unchanged.

### 16.6 Partial Migration

**Migrate only some projects**:

```
Projects:
├── Governance/         ← v3 (needs session continuity)
├── MyWebApp/           ← v3 (long sessions)
├── SmallTool/          ← v2.5 (short sessions)
└── Experiments/        ← v2.5 (exploratory)
```

**Both coexist**:
- v3 projects have CONTEXT.md + session_handoffs/
- v2.5 projects have only CLAUDE.md
- Shared_context.md can track both types

### 16.7 Migrating Decision History

**Carry forward past decisions** to CONTEXT.md:

1. Find old decisions (in notes, docs, commits)
2. Assign decision IDs (retroactively)
3. Record in CONTEXT.md Section IV

**Example**:
```markdown
## IV. Decisions & Architecture

### Historical Decisions (Pre-v3)

| ID   | Date       | Decision               | Source              |
|------|------------|------------------------|---------------------|
| #I18 | 2025-10-15 | Use React for frontend | meeting_notes.md    |
| #I19 | 2025-11-01 | Deploy to Vercel       | slack conversation  |
```

Not required but helpful for continuity.

### 16.8 Migration Timeline

**Suggested approach**:

```
Week 1: Prepare
- Read v3_FULL_SPEC.md
- Decide which projects to migrate
- Backup all projects

Week 2: Migrate Governance
- Create CONTEXT.md
- Test first v3 session
- Validate workflows

Week 3: Migrate Active Projects
- Create CONTEXT.md (one at a time)
- Test checkpoint/finalize
- Refine session_config.md

Week 4: Create Shared_context.md
- Add all projects to portfolio
- Test cross-project tracking
- Archive first month's handoffs
```

No deadline. Migrate at your own pace.

### 16.9 Common Migration Issues

**Issue**: "CONTEXT.md too much work to fill initially"
**Solution**: Start minimal (Section I only, fill rest during sessions)

**Issue**: "Handoff files taking too much space"
**Solution**: Archive monthly, compress old archives

**Issue**: "Don't know which project type (CODE/BIZZ/OPS)"
**Solution**: Default to CODE if unsure. Can change later.

**Issue**: "Session handoffs feel like busywork"
**Solution**: Use scripts to automate file creation

**Issue**: "Want v3 features but not all the files"
**Solution**: Create only CONTEXT.md (minimal v3), skip session_handoffs/

---------------------------------------------------------------------------------------------------------------------------

## 17. Quick Reference

### 17.1 v3 Workflows

Quick reference cards for common v3 operations.

#### 17.1.1 Session Start Workflow

```
┌─────────────────────────────────────┐
│ SESSION START                       │
└─────────────────────────────────────┘

1. User: "confirm and next"

2. Claude announces:
   - Date: YYYY-MM-DD
   - Boundaries: CAN/CANNOT modify
   - Warmup status: ✅ <240m

3. User: "Create handoff for [topic]"

4. Claude creates:
   - session_handoffs/YYYYMMDD_HHMM_topic.md
   - Fills Section I (Metadata)
   - Reads CONTEXT.md (Layer 6)

5. Claude: "Ready. Next steps: [from CONTEXT.md Section VI]"

6. Begin work
```

**Files touched**: session_handoffs/YYYYMMDD_HHMM_topic.md (created), CONTEXT.md (read only)

#### 17.1.2 Checkpoint Workflow

```
┌─────────────────────────────────────┐
│ CHECKPOINT (Every 60-90min)         │
└─────────────────────────────────────┘

Trigger: Warmup status shows ⚠️ or 🔴

1. User: "checkpoint"

2. Claude updates session handoff:
   - Section II: Work Summary
   - Section III: State Snapshot
   - Section V: Blockers & Risks
   - Section VI: Next Steps

3. Claude updates CONTEXT.md:
   - Section I: Current State
   - Section III: Active Work
   - Section V: Blockers & Risks
   - Section VII: Add checkpoint entry

4. Claude commits:
   git add .
   git commit -m "Checkpoint: [description]"

5. Claude: "Checkpoint saved. Commit: [hash]"

6. Continue work or end session
```

**Files touched**: session_handoffs/YYYYMMDD_HHMM_topic.md (updated), CONTEXT.md (updated), code files (committed)

#### 17.1.3 Finalize Session Workflow

```
┌─────────────────────────────────────┐
│ FINALIZE SESSION (End of session)   │
└─────────────────────────────────────┘

1. User: "finalize session handoff"

2. Claude fills all handoff sections (I-XII)

3. Claude updates CONTEXT.md:
   - Section VII: Add session entry with link

4. Claude adds frontmatter:
   status: finalized

5. Claude commits:
   git commit -m "Session finalized: YYYY-MM-DD"

6. Claude: "Session finalized. Next priority: [Section VI]"
```

**Files touched**: session_handoffs/YYYYMMDD_HHMM_topic.md (finalized), CONTEXT.md (updated)

#### 17.1.4 Monthly Archive Workflow

```
┌─────────────────────────────────────┐
│ MONTHLY ARCHIVE (Start of month)    │
└─────────────────────────────────────┘

1. User: "Archive last month's sessions"

2. Claude creates: archive/YYYY/MM/

3. Claude moves: YYYYMM*.md → archive/YYYY/MM/

4. Claude archives: CONTEXT.md → CONTEXT_YYYYMM.md

5. Claude creates fresh CONTEXT.md

6. Claude commits:
   git commit -m "Archive: Session handoffs for YYYY-MM"
```

**Files touched**: session_handoffs/YYYYMM*.md (moved), archive/YYYY/MM/CONTEXT_YYYYMM.md (created), CONTEXT.md (reset)

### 17.2 File Locations Quick Reference

**Per-project**:
```
{project}/
├── CLAUDE.md                    ← Layer 4
├── CONTEXT.md                   ← Layer 6
├── .claude/session_config.md    ← Optional
└── session_handoffs/
    ├── YYYYMMDD_HHMM_topic.md
    └── archive/YYYY/MM/
```

**Global**:
```
~/.claude/
├── CLAUDE.md                    ← Layer 2
├── Shared_context.md            ← Portfolio
├── templates/session_handoff.md
└── sessions/{hash}_session.json
```

### 17.3 Command Quick Reference

| Task           | User Command                     | Claude Action                                |
|----------------|----------------------------------|---------------------------------------------|
| Start session  | "confirm and next"               | Announce date, boundaries, warmup           |
| Create handoff | "Create handoff for [topic]"     | Create session_handoffs/YYYYMMDD_HHMM.md    |
| Checkpoint     | "checkpoint"                     | Update handoff + CONTEXT + commit           |
| Finalize       | "finalize session handoff"       | Fill all sections + mark immutable          |
| Archive        | "archive last month"             | Move old handoffs to archive/               |
| Recover        | "recover from checkpoint"        | Read CONTEXT + latest handoff               |

### 17.4 Decision ID Quick Reference

| Prefix | Category       | Example                  |
|--------|----------------|--------------------------|
| `#G`   | Governance     | #G12 - Adopt v3          |
| `#P`   | Process        | #P10 - Checkpoint 60-90m |
| `#I`   | Infrastructure | #I15 - Store in session_handoffs/ |
| `#S`   | Security       | #S3 - Enforce 2FA        |
| `#B`   | Backup         | #B1 - 3-2-1 strategy     |

### 17.5 Warmup Status Quick Reference

| Icon | Token Age | Meaning        | Action                   |
|------|-----------|----------------|--------------------------|
| ✅   | <240m     | Fresh context  | Continue working         |
| ⚠️   | 240-480m  | Aging context  | Checkpoint recommended   |
| 🔴   | >480m     | Stale context  | Checkpoint required      |

### 17.6 Layer System Quick Reference

| #  | Layer                 | When Loaded   | Source                       |
|----|-----------------------|---------------|------------------------------|
| 1  | System Prompt         | Always        | Anthropic baseline           |
| 2  | Global CLAUDE.md      | Session start | ~/.claude/CLAUDE.md          |
| 3  | Product CLAUDE.md     | Session start | Product-level (if exists)    |
| 4  | Project CLAUDE.md     | Session start | {project}/CLAUDE.md          |
| 5  | Hook context          | Session start | Date, boundaries, plugins    |
| 6  | Session context       | Session start | **v3 NEW**: CONTEXT.md       |
| 7  | Plugin prompts        | When active   | Plugin-specific              |
| 8  | Conversation history  | Accumulated   | Previous messages            |
| 9  | Tool results          | After tool use| File contents, outputs       |
| 10 | Current message       | Per message   | User's current request       |

### 17.7 Migration Quick Reference

**Minimal v3 migration** (required files):
1. Create CONTEXT.md
2. Create session_handoffs/ directory
3. Done (session_config.md optional)

**Validation**:
```bash
~/Desktop/Governance/scripts/validate_project.sh
```

**Rollback**:
```bash
rm -rf session_handoffs/ CONTEXT.md .claude/session_config.md
git revert [migration commits]
```

---------------------------------------------------------------------------------------------------------------------------

## 18. Appendices

### 18.A Full Session Handoff Template

**File**: `~/.claude/templates/session_handoff.md`

See §6.2 for full 12-section template structure. Template includes:
- Section I: Session Metadata (auto-filled)
- Section II: Work Summary (Completed/In Progress/Pending)
- Section III: State Snapshot (phase, metrics, environment)
- Section IV: Changes Detail (code, docs, config)
- Section V: Blockers & Risks
- Section VI: Next Steps
- Section VII: Context Links
- Section VIII: Project-Type-Specific (CODE/BIZZ/OPS)
- Section IX: Plugin Cost Summary
- Section X: Session Quality Metrics (optional)
- Section XI: Handoff Notes (for next Claude)
- Section XII: Appendix (optional)

### 18.B Full CONTEXT.md Template

**File**: `{project}/CONTEXT.md`

7-section template:
- Section I: Current State (phase, progress, metrics)
- Section II: Progress Summary (completed/in progress/pending)
- Section III: Active Work (detailed descriptions)
- Section IV: Decisions & Architecture (decision table + notes)
- Section V: Blockers & Risks (current + resolved)
- Section VI: Roadmap (immediate/short-term/long-term)
- Section VII: Session History (last 10 sessions)

### 18.C Full Shared_context.md Template

**File**: `~/.claude/Shared_context.md`

7-section template for portfolio management:
- Section I: Active Projects (table with status)
- Section II: Cross-Project Blockers (dependencies + conflicts)
- Section III: Recent Decisions (cross-project table)
- Section IV: Shared Resources (utilities + infrastructure)
- Section V: Monthly Summary (current + past months)
- Section VI: Portfolio Metrics (sessions, context health, archive size)
- Section VII: Notes (relationships, changes, health)

### 18.D Example session_config.md (CODE Project)

Custom configuration showing:
- YAML frontmatter (project_type, checkpoint_interval)
- Handoff template overrides (custom fields for Section III, VIII)
- Plugin configuration (always enable/disable/on-demand)
- Custom workflows (session start, checkpoint, finalize, archive)
- Project-specific rules (code style, testing, git, deployment)
- Environment variables
- Troubleshooting (common issues)

### 18.E FAQ

**General Questions**:
- Q: Do I need to migrate to v3? A: No. v3 is opt-in.
- Q: Can v2.5 and v3 coexist? A: Yes.
- Q: Are handoffs automatic? A: No. All manual.
- Q: How often checkpoint? A: Every 60-90min when ⚠️ or 🔴.

**Migration Questions**:
- Q: How long does migration take? A: ~30 min per project.
- Q: Can I roll back? A: Yes. Delete v3 files, revert commits.
- Q: Breaking changes? A: No. CLAUDE.md, hooks, plugins unchanged.

**Session Management Questions**:
- Q: Forgot to finalize? A: Leave in_progress or finalize later.
- Q: Multiple active sessions? A: No. One handoff per session.
- Q: Session interrupted? A: Recovery process in §8.5.

**File Structure Questions**:
- Q: Where does session_handoffs/ go? A: Project root.
- Q: Should I commit handoffs? A: Recommended for audit trail.
- Q: Where does Shared_context.md go? A: ~/.claude/

**Template Questions**:
- Q: Can I modify template? A: Yes. Edit ~/.claude/templates/session_handoff.md.
- Q: Different templates per project? A: Yes. Use session_config.md overrides.
- Q: Sync template changes? A: Run ~/Desktop/Governance/scripts/sync_templates.sh.

**Plugin Questions**:
- Q: Do plugins work with v3? A: Yes. Unchanged from v2.5.
- Q: Disable plugins for long sessions? A: Yes. Disable high-cost plugins (>1000 tokens).
- Q: Can plugins auto-create handoffs? A: No. All manual.

**Archive Questions**:
- Q: When to archive? A: Monthly (start of new month).
- Q: Can I delete archives? A: Yes, but not recommended.
- Q: Search archived handoffs? A: grep -r "keyword" session_handoffs/archive/

**Decision ID Questions**:
- Q: When to create decision ID? A: Immediately when decision made.
- Q: Reuse old IDs? A: No. Numbers only go up.
- Q: Search decisions? A: grep "#G12" CONTEXT.md session_handoffs/*.md

**Workflow Questions**:
- Q: Can Claude auto-checkpoint? A: No. User must trigger.
- Q: Difference: checkpoint vs finalize? A: Checkpoint = mid-session save. Finalize = end-of-session complete.
- Q: Need scripts? A: No. Optional convenience.

**Portfolio Questions**:
- Q: Need Shared_context.md? A: Only if managing 3+ projects.
- Q: Update frequency? A: After milestones or monthly.
- Q: Auto-aggregate? A: No. Manual updates.

### 18.F Glossary

| Term                | Definition                                                                |
|---------------------|---------------------------------------------------------------------------|
| CLAUDE.md           | Project-level instruction file defining boundaries (Layer 4)              |
| CONTEXT.md          | Project state file summarizing progress, decisions, blockers (Layer 6)    |
| Session Handoff     | Structured document capturing session progress for continuity             |
| Checkpoint          | Mid-session save of handoff, CONTEXT, and code (manual trigger)           |
| Finalize            | End-of-session completion of handoff with all sections filled             |
| Archive             | Monthly process moving old handoffs to archive/YYYY/MM/                   |
| Warmup Status       | Token age indicator (✅ fresh, ⚠️ aging, 🔴 stale)                        |
| Layer 6             | Session Context layer (NEW in v3) loading CONTEXT.md at start             |
| Decision ID         | Permanent reference to decisions (#G12, #I8, etc.)                        |
| session_config.md   | Optional per-project configuration for handoff customization              |
| Shared_context.md   | Global portfolio view tracking multiple projects                          |
| v2.5                | Previous governance version (9-layer system, no session continuity)       |
| v3                  | Current governance version (10-layer system with session handoffs)        |

### 18.G FILICITI Folder Structure (v1 Reference)

**Complete folder structure from v1 governance** (for reference when setting up multi-product portfolios):

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
└── ~/.claude/plans/                            ← CLAUDE PLANS (symlink targets)
    ├── COEVOLVE_code/, COEVOLVE_bizplan/
    ├── FlowInLife_app/, FlowInLife_yutaai/, FlowInLife_bizplan/
    ├── LABS/
    └── Governance/
```

**Key v1 concepts** (for reference when building portfolio structures):

1. **Symlink Governance**: All governance files live in wrapper's `_governance/` folder, symlinked to project roots
2. **2-Repo Strategy**: Wrapper (private) + code (shareable) per product
3. **Company-Level**: `_Governance/` for cross-product decisions, `_Shared/` for shared resources
4. **Product Wrappers**: Each product has wrapper containing multiple projects + `_governance/`
5. **Inner Repos**: Shareable code repos ignore governance symlinks via .gitignore

**v3 adaptation**: Use this structure as inspiration for portfolio management (§13). Not required for single-project or simple multi-project setups.

---------------------------------------------------------------------------------------------------------------------------

**END OF v3 FULL SPECIFICATION**

*Last updated: 2026-01-09*
*Decision ID: #G12 (Adopt v3 governance)*
*Migration guide: §16*
*Quick reference: §17*
