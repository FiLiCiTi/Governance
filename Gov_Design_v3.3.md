# Governance Design v3.3

> **Purpose:** Design principles and decisions (what and why)
> **Version:** 3.3.0
> **Updated:** 2026-01-18

## Table of Contents

| Section | Title                                                | Line |
|---------|------------------------------------------------------|------|
| 1       | [Overview](#1-overview)                              | :19  |
| 2       | [Design Principles](#2-design-principles)            | :39  |
| 3       | [Problems Solved](#3-problems-solved)                | :56  |
| 4       | [Key Decisions](#4-key-decisions)                    | :80  |
| 5       | [Benefits](#5-benefits)                              | :209 |
| 9       | [Known Issues & Future Improvements](#9-known-issues-future-improvements) | :314 |

---------------------------------------------------------------------------------------------------------------------------

## 1. Overview

### 1.1 What is v3.3?

v3.3 is a major refactoring of the Governance hook system focusing on:
- **One Hook = One Function** (strict single responsibility)
- **Separation of Concerns** (decoupled state files)
- **Clear Naming** (verb_noun.sh convention)
- **No Deprecated Code** (removed warmup concept)

### 1.2 Why v3.3?

**From v3.0/v3.2, we had:**
- ❌ Hooks violating single responsibility (inject_context.sh had 7 responsibilities)
- ❌ State file coupling unrelated concerns (time + context + tools in one file)
- ❌ Cascading failures from state corruption (~0K* context + 29M minutes)
- ❌ Deprecated warmup concept cluttering codebase
- ❌ Unclear naming (inject_context.sh doesn't actually inject context)
- ❌ No model name visibility in status bar

---------------------------------------------------------------------------------------------------------------------------

## 2. Design Principles

### 2.1 Single Responsibility Principle

**STRICT:** One hook performs exactly one function.

**Examples:**
- `init_session.sh` → Initialize session state ONLY
- `track_context.sh` → Track token usage ONLY
- `log_tool.sh` → Log tool usage ONLY

### 2.2 Separation of Concerns

**STRICT:** State files separated by concern, not by hook.

**Separation:**
- Session timing → `session.json`
- Context tracking → `context.json`
- Tool tracking → `tools.json`

### 2.3 Fail Independently

**STRICT:** Corruption in one state file MUST NOT cascade to others.

**Example:** If `context.json` corrupts → session timer still works.

---------------------------------------------------------------------------------------------------------------------------

## 3. Problems Solved

### 3.1 Problem: State File Coupling (BUG 3)

**OLD (v3.0):** Unified state file couples time + context
```json
{
  "start_time": 0,        // ← Epoch 0 corruption
  "token_count": 0,       // ← Both in same file
  "last_update": 0
}
```

**Result:** Both time and context crash together:
- Session shows: 29,478,966 minutes
- Context shows: ~0K*

**NEW (v3.3):** Separated state files
```
session.json  → { "start_time": 0 }     // Only time affected
context.json  → { "token_count": 15818 } // Context survives
```

**Result:** Independent failure modes, no cascading.

### 3.2 Problem: Hook Complexity

**OLD (v3.0):** inject_context.sh (7 responsibilities)
1. State initialization
2. Stale session detection
3. Compact flag handling
4. Hook health monitoring
5. Plugin counting
6. Session metadata output
7. Migration logic

**NEW (v3.3):** Focused hooks (1 responsibility each)
- `init_session.sh` → Initialize only
- `reset_context.sh` → Compact only
- `track_time.sh` → Time tracking only

---------------------------------------------------------------------------------------------------------------------------

## 4. Key Decisions

### 4.1 Decision A: State File Consolidation

**What:** 3 consolidated state files (session, context, tools)

**Why:**
- Critical separation (time vs context) prevents cascading failures
- Not too fragmented (easier to manage than 5 separate files)
- Clear ownership boundaries (each hook owns specific file)

**State Files:**

| File                  | Purpose          | Owned By                                          |
|-----------------------|------------------|---------------------------------------------------|
| `{HASH}_session.json` | Session state    | init_session.sh, track_time.sh,                   |
|                       |                  | finalize_session.sh                               |
| `{HASH}_context.json` | Context tracking | track_context.sh, check_context_usage.sh,         |
|                       |                  | reset_context.sh                                  |
| `{HASH}_tools.json`   | Tool tracking    | log_tool.sh                                       |

**Benefits:**
- ✅ Time corruption doesn't crash context tracking
- ✅ Context corruption doesn't crash time tracking
- ✅ Independent failure modes

---------------------------------------------------------------------------------------------------------------------------

### 4.2 Decision B: Two Stop Hooks

**What:** Keep two separate Stop hooks (session duration + context usage)

**Why:**
- Clear separation of concerns (time ≠ context)
- Independent failure modes
- Can disable one without affecting the other
- Easier to adjust thresholds independently

**Hooks:**
- `check_session_duration.sh` - Warns if session too long
- `check_context_usage.sh` - Warns if context too high

**Thresholds:**

| Hook             | Warning                   | Critical                    |
|------------------|---------------------------|-----------------------------|
| Session Duration | ≥120m (2h): ⚠️            | ≥150m (2.5h): 🔴            |
| Context Usage    | ≥70%: 🟡                  | ≥85%: 🔴                    |

---------------------------------------------------------------------------------------------------------------------------

### 4.3 Decision C: Model Name in Status Bar

**What:** Manual model name update, displayed first in status bar

**Why:**
- User needs to see which model is active (Sonnet vs Opus vs Haiku)
- Manual update gives explicit control (no auto-detection guessing)
- Freeform validation allows custom names ("sonnet-4.5", "opus-new", etc.)

**Configuration:**
- **Position:** First (leftmost) in status bar
- **Validation:** Freeform (no strict checking)
- **Default:** "sonnet" (lowercase in storage, capitalized in display)

**Display Format:**
```
Sonnet · 🟢 Context: ~45K · ✅ 🕐 28m · 🔧 Bash
^^^^^^^
Model name (capitalized for display)
```

**User Update Flow:**
```
User: "set model to Opus"
Claude: Updates session.json via jq
Status bar: Automatically reflects change
```

---------------------------------------------------------------------------------------------------------------------------

### 4.4 Decision D: Backwards Compatibility

**What:** Auto-migrate v3.0 → v3.3 (Option A)

**Why:**
- Governance is actively used - can't afford data loss
- Migration is one-time cost (runs once per project)
- Can remove migration code in v4.0 (3 months from now)
- Seamless user experience (no manual steps required)

**Migration Trigger:**
- Runs automatically in `init_session.sh` on first SessionStart
- Detects old unified state file format
- Splits into 3 new files
- Archives old file as `.v3.0.backup`

**Cleanup Plan:**
- v3.3.0 (2026-01-18): Add migration logic
- v4.0.0 (2026-04-18): Remove migration code (assumes all projects migrated)

---------------------------------------------------------------------------------------------------------------------------

### 4.5 Decision E: Compact Flag Location

**What:** Dedicated `reset_context.sh` hook (Option 3)

**Why:**
- Compact is a distinct operation (deserves own hook)
- Keeps init_session.sh focused on initialization only
- Easy to maintain/test/understand
- Clear naming: `reset_context.sh` = exactly what it does

**Hook Order:**
```json
"SessionStart": [
  {
    "hooks": [
      {"command": "init_session.sh"},      // 1. Initialize session state
      {"command": "reset_context.sh"}      // 2. Handle compact flag if exists
    ]
  }
]
```

**What resets when user says "refresh context":**
- Context: `token_count` → 0
- Session: `start_time` → NOW (fresh start)

---------------------------------------------------------------------------------------------------------------------------

### 4.6 Decision F: Naming Convention

**What:** `verb_noun.sh` format (strict)

**Why:**
- Immediately clear what hook does from filename
- Verb = action, Noun = object
- Consistent pattern across all hooks

**Examples:**
- `init_session.sh` (initialize session)
- `track_context.sh` (track context usage)
- `validate_boundaries.sh` (validate file boundaries)
- `check_session_duration.sh` (check session duration)
- `finalize_session.sh` (finalize session)

**Special cases:**
- `status_bar.sh` (noun only, acceptable for display hooks)
- `detect_loop.sh` (already follows pattern, kept as-is)

---------------------------------------------------------------------------------------------------------------------------

## 5. Benefits

### 5.1 Fault Isolation

**Before v3.3:**
- Epoch 0 in `start_time` → Session shows 29M minutes
- Epoch 0 in `start_time` → Context shows ~0K* (coupled in same file)
- Both crash together

**After v3.3:**
- `session.json` corrupts → Only time affected, context survives
- `context.json` corrupts → Only context affected, time survives
- Independent recovery possible

### 5.2 Maintainability

**Before v3.3:**
- Single hook with 7 responsibilities
- Hard to debug (which part failed?)
- Hard to test (test all 7 at once?)

**After v3.3:**
- 10 focused hooks, each testable independently
- Easy to debug (check specific hook)
- Easy to maintain (modify one without breaking others)

### 5.3 Clarity

**Before v3.3:**
- `inject_context.sh` - doesn't inject context, does 7 things
- `log_tool_use.sh` - logs tools but also tracks time and context

**After v3.3:**
- `init_session.sh` - initializes session (clear)
- `track_context.sh` - tracks context (clear)
- `log_tool.sh` - logs tools (clear)

### 5.4 Flexibility

**Before v3.3:**
- Can't disable time tracking without affecting context tracking
- Can't adjust context thresholds without touching session duration logic

**After v3.3:**
- Disable `check_session_duration.sh` → context warnings still work
- Adjust context thresholds in `check_context_usage.sh` → time warnings unaffected


---------------------------------------------------------------------------------------------------------------------------

## 9. Known Issues & Future Improvements

### 9.1 Critical Bugs

#### Issue #1: Session Timer Corruption After "Refresh Context"

**Status:** 🔴 Critical - Needs fix

**Observed behavior:**
```
User runs: "refresh context"
Claude resets context state successfully
Status bar shows: 🕐 29480493m (29 million minutes ≈ 56 years!)
```

**Expected behavior:**
- Session timer should continue from original start time
- Should show reasonable elapsed time (e.g., "45m" or "2h 30m")

**Root cause (suspected):**
- "refresh context" creates/updates `~/.claude/sessions/{hash}_context.json`
- Session timer likely stored in separate `{hash}_session.json` file (v3.3 architecture)
- When context file created fresh, timer calculation corrupts

**Impact:** High - Makes status bar unusable after context refresh

---

#### Issue #2: Project Hash vs Session ID Confusion

**Status:** 🔴 Critical - Architecture flaw

**Observed behavior:**
```
User runs: "refresh context"
Claude finds sessionId in sessions-index.json: e87daee5-676d-4022-b331-d9ca841e2711
Claude says: "I need to find the project hash (not session ID)"
Claude computes: MD5 hash of project path → 5451836db64d6ce0ef81383ac34ba32e
Claude uses: {project_hash}_context.json for state file
```

**The problem:**
- **Collision risk**: Multiple sessions in same project overwrite each other's state
- **Inconsistency**: Session-specific state should use session ID, not project hash
- **Architecture unclear**: v3.3 doesn't specify state file naming convention

**Example scenario showing collision:**
```
Session 1 in fil-yuta: Uses 5451836db64d6ce0ef81383ac34ba32e_context.json
Session 2 in fil-yuta: Uses 5451836db64d6ce0ef81383ac34ba32e_context.json (same file!)
→ Session 2 overwrites Session 1's context state
```

**Proposed solution:**
- Use session ID for state files: `{sessionId}_context.json`, `{sessionId}_session.json`
- OR document why project hash is used and handle multi-session scenarios

**Impact:** High - Makes multi-session work unreliable

---

### 9.2 Enhancements Needed

#### Enhancement #1: Log Cleaning Script Refinement

**Status:** 🟡 Working but needs tweak

**Current state:**
- ✅ `clean_log.py` works for files <500MB
- ✅ `clean_log_large.py` works for files >500MB (99%+ reduction)
- ✅ Successfully processed 21.6GB → 675KB across 3 large files

**Needs improvement:**
- Additional filtering or optimization (specific tweak not detailed yet)
- Document edge cases
- Add validation checks
- Session header before "confirm and next" is lost

**Priority:** Medium - Functional but can be refined

---

#### Enhancement #2: Reconsider Custom Status Bar

**Status:** 🟢 Working - Needs review

**Context:**
- v3.3 implements custom status bar with context tracking
- Status bar shows: Model, todos, hooks, context size, warmup time, session timer

**Observation:**
- Context tracking working well with separated state files
- Log cleaning reduces storage needs dramatically
- Question: Is complex status bar still necessary?

**Consider:**
- Simplify status bar (remove less useful indicators)
- Keep essential info only (model, context, timer)
- Remove indicators that add complexity without value
- Focus on reliability over features
- Automated update by detecting /command

**Priority:** Low - Nice to have, not urgent

---------------------------------------------------------------------------------------------------------------------------


MY NOTES:

Prompt to Avoid This Problem                                                                                                                                                                            
                                                                                                                                                                                                          
  When asking Claude to create a document, use this pattern:                                                                                                                                              
                                                                                                                                                                                                          
  Save the summary above to [filename].md                                                                                                                                                                 
                                                                                                                                                                                                          
  Rules:                                                                                                                                                                                                  
  1. Use EXACTLY the content I approved (don't expand/reinvent)                                                                                                                                           
  2. Add only: header metadata, TOC, separators per template                                                                                                                                              
  3. Follow DOCUMENT_FORMAT-TEMPLATE.md for structure                                                                                                                                                     
                                                                                                                                                                                                          
  Or more explicitly:                                                                                                                                                                                     
                                                                                                                                                                                                          
  Create [filename].md using this exact content:                                                                                                                                                          
  [paste your approved summary here]                                                                                                                                                                      
                                                                                                                                                                                                          
  Format: Add template header/TOC/separators only. Do not add sections.                                                                                                                                   
                                                                                                                                                                                                          
  ---                                                                                                                                                                                                     
  Why this works:                                                                                                                                                                                         
  - "EXACTLY" tells me not to expand                                                                                                                                                                      
  - "don't expand/reinvent" prevents over-engineering                                                                                                                                                     
  - Explicit content reference = what you see is what you get                                                                                                                                             
                                                                                                                                                                                                          
  The root problem was: When you said "create document", I interpreted it as "create comprehensive documentation" instead of "save approved output with formatting."                                      
                                                                                                                                                                                                          
  Add to CLAUDE.md? You could add a rule like:                                                                                                                                                            
                                                                                                                                                                                                          
  ## Document Creation Rule                                                                                                                                                                               
  When user says "save this to document" or "create document from above":                                                                                                                                 
  - Use the conversation output EXACTLY as shown                                                                                                                                                          
  - Add ONLY template formatting (header, TOC, separators)                                                                                                                                                
  - Do NOT expand, reinvent, or add comprehensive sections                                                                                                                                                
                                                                                                                                                                                                          
  Want me to add this to fil-bizz/CLAUDE.md?                                       



  ________


  2. Avoiding This in Future                                                                                                                                                                              
                                                                                                                                                                                                          
  New Rule for CLAUDE.md (fil-yuta):                                                                                                                                                                      
                                                                                                                                                                                                          
  ## Spec Document Rules (#D-SPEC)                                                                                                                                                                        
                                                                                                                                                                                                          
  **NEVER summarize/paraphrase spec content. Violations cause semantic drift.**                                                                                                                           
                                                                                                                                                                                                          
  When creating or updating spec documents:                                                                                                                                                               
  1. **VERBATIM COPY** - Tables, rules, code blocks must be copied exactly                                                                                                                                
  2. **REFERENCE, DON'T REWRITE** - If section is long, reference: "See 2.10 §7.3"                                                                                                                        
  3. **NO SYNONYMS** - "Report Terminal" ≠ "Report is Terminal" ≠ "Report cannot exit"                                                                                                                    
  4. **PRESERVE STRUCTURE** - Keep same numbering (R1-R8, not renumber to fit)                                                                                                                            
                                                                                                                                                                                                          
  Rationale: G1 gap showed R1-R8 rules inverted meaning through paraphrasing.          
------------



*Template: ~/Desktop/FILICITI/Governance/templates/DOCUMENT_FORMAT-TEMPLATE.md | v3.3*
