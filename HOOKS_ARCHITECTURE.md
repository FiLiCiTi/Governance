# Hooks Architecture

> **Type:** OPS | **Version:** 3.0.0 | **Updated:** 2026-01-17 | **Status:** All hooks functional

---

## Table of Contents

| Section | Title                                                                        | Line   |
|---------|------------------------------------------------------------------------------|--------|
| 1       | [Overview](#1-overview)                                                      | :20    |
| 2       | [Hook Architecture](#2-hook-architecture)                                    | :50    |
| 3       | [All 10 Scripts Reference](#3-all-10-scripts-reference)                      | :120   |
| 4       | [Session Lifecycle - Three Flows](#4-session-lifecycle---three-flows)        | :280   |
| 5       | [State File Schema](#5-state-file-schema)                                    | :480   |
| 6       | [Hook Categories & Technical Details](#6-hook-categories--technical-details) | :560   |
| 7       | [Debugging & Troubleshooting](#7-debugging--troubleshooting)                 | :820   |
| 8       | [Version History & Fixes (v3.0.0)](#8-version-history--fixes-v300)          | :950   |

---

## 1. Overview

### What are Hooks?

Hooks are automated scripts that execute at specific Claude Code events, enabling:
- **Session tracking:** Monitor session duration, context usage, token counts
- **Context management:** Reset context after compact, detect stale sessions
- **Safety validation:** Prevent modifications to protected directories
- **Loop detection:** Warn when stuck in infinite patterns
- **Real-time monitoring:** Display live session metrics in status bar

### Event Timeline

```
Session Lifecycle with Hook Triggers:

START EVENT (SessionStart)
       ↓
    inject_context.sh
    ├─ Initialize session state
    ├─ Detect stale sessions
    └─ Handle compact flag
       ↓
DURING SESSION (Continuous)
       ├─ [Each tool use]
       │  ├─ PreToolUse: check_boundaries.sh (if Edit/Write)
       │  └─ PostToolUse: log_tool_use.sh + detect_loop.sh
       │
       ├─ [Between tool calls]
       │  └─ Stop: check_warmup.sh (health monitoring)
       │
       └─ [Real-time]
          └─ Status Line: suggest_model.sh (continuous updates)
       ↓
END EVENT (SessionEnd)
       ↓
    save_session.sh
    ├─ Archive session
    ├─ Mark finalized
    └─ Clean up state file
       ↓
    [Session ended]
```

---

## 2. Hook Architecture

### All Scripts Overview Table

| #  | Script               | Type          | Trigger                          | Purpose                                                                 | Status    |
|----|----------------------|---------------|----------------------------------|-------------------------------------------------------------------------|-----------|
| 1  | inject_context.sh    | Hook          | SessionStart                     | Initialize session state, detect stale sessions, handle compact flag   | ✅ Fixed  |
| 2  | check_boundaries.sh  | Hook          | PreToolUse (Edit/Write)          | Validate file paths against CAN/CANNOT rules in CLAUDE.md             | ✅ OK     |
| 3  | log_tool_use.sh      | Hook          | PostToolUse (all tools)          | Track tool usage, estimate tokens, update todo state                  | ✅ OK     |
| 4  | detect_loop.sh       | Hook          | PostToolUse (all tools)          | Detect infinite loops (same file 5+ edits, same error 3+ times)       | ✅ Fixed  |
| 5  | check_warmup.sh      | Hook          | Stop (between calls)             | Monitor session health (warmup timer, duration, context %)            | ✅ OK     |
| 6  | suggest_model.sh     | Status Line   | Continuous (real-time)           | Display context %, session duration, recommendations                  | ✅ OK     |
| 7  | save_session.sh      | Hook          | SessionEnd (quit)                | Archive session state, mark finalized, calculate duration             | ✅ Fixed  |
| 8  | audit_sessions.sh    | Utility       | Manual (`./audit_sessions.sh`)   | Generate session audit report per project, find orphaned files        | ✅ OK     |
| 9  | check_protocol.sh    | Utility       | Manual (`./check_protocol.sh`)   | Validate protocol steps followed (CODE/BIZZ/OPS types)               | ✅ Fixed  |
| 10 | sync_templates.sh    | Utility       | Manual (`./sync_templates.sh`)   | Sync templates between Governance/ and ~/.claude/templates            | ✅ OK     |

### Hook Dependencies Diagram

```
                        ┌─────────────────────┐
                        │  SESSION STARTS     │
                        │   (cc command)      │
                        └──────────┬──────────┘
                                   │
                                   ▼
                      ┌────────────────────────┐
                      │ inject_context.sh      │
                      │ (SessionStart Hook)    │
                      │ ✓ Create/reset state   │
                      │ ✓ Detect stale sess    │
                      │ ✓ Handle compact flag  │
                      └────────────┬───────────┘
                                   │
                    ┌──────────────┬──────────────┐
                    │              │              │
                    ▼              ▼              ▼
            ┌─────────────┐  ┌────────────┐  ┌─────────────┐
            │ check_      │  │ log_tool_  │  │ suggest_    │
            │ boundaries  │  │ use.sh     │  │ model.sh    │
            │ .sh         │  │ (track $)  │  │ (status bar)│
            │ (PreTool)   │  │ (PostTool) │  │ (real-time) │
            └─────────────┘  └────────────┘  └─────────────┘
                    │              │              │
                    │    ┌─────────┴──────────┐   │
                    │    ▼                    ▼   │
                    │ ┌──────────────────────┐    │
                    │ │ detect_loop.sh       │    │
                    │ │ (PostTool)           │    │
                    │ │ ✓ Track edits/errors │    │
                    │ └──────────────────────┘    │
                    │                              │
                    └─────────┬──────────┬─────────┘
                              │          │
                    ┌─────────▼──────────▼────────┐
                    │ check_warmup.sh             │
                    │ (Stop Hook - between calls) │
                    │ ✓ Session duration monitor  │
                    │ ✓ Context % warnings        │
                    └─────────┬────────────────────┘
                              │
                              ▼
                    ┌─────────────────────┐
                    │  USER EXITS         │
                    │  (exit command)     │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ save_session.sh     │
                    │ (SessionEnd Hook)   │
                    │ ✓ Mark finalized    │
                    │ ✓ Archive state     │
                    │ ✓ Clean up files    │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │  SESSION ENDED      │
                    └─────────────────────┘

UTILITIES (Manual/On-demand):
├─ audit_sessions.sh     (Review all sessions)
├─ check_protocol.sh     (Validate protocol adherence)
└─ sync_templates.sh     (Keep templates in sync)
```

---

## 3. All 10 Scripts Reference

### Category: HOOKS (7 scripts)

These execute automatically at Claude Code events.

#### 1. inject_context.sh
**Trigger:** SessionStart | **Type:** Hook

```bash
# Location: Governance/scripts/inject_context.sh
# Execution: Runs when you start a session (cc command)
# Exit Codes: 0 (success), silent fail on errors
```

**Responsibilities:**
1. Calculate PROJECT_HASH from current directory
2. Determine state file path: `~/.claude/sessions/{PROJECT_HASH}_session.json`
3. Handle three initialization scenarios:

| Scenario | File Status | Action |
|----------|-------------|--------|
| **New Session** | File doesn't exist | Create fresh state (start_time=NOW, token_count=0, status="active") |
| **Stale Session** | File exists + age ≥5min + status="finalized" | RESET all fields (fresh session start_time, token_count=0) |
| **Active Session** | File exists + recent + status="active" | Preserve existing fields (continue session) |

4. Handle compact flag: If `~/.claude/compact_flag` exists:
   - Reset `token_count = 0`
   - Reset `start_time = NOW`
   - Delete flag (cleanup)

5. Count active hooks and check execute permissions

6. Output JSON metadata for Claude announcement

**State File Created:**
```json
{
  "start_time": 1768651202,
  "last_warmup": 1768651202,
  "last_update": 1768651202,
  "project": "/Users/mohammadshehata/Desktop/FILICITI/Governance",
  "project_name": "governance",
  "token_count": 0,
  "tool_count": 0,
  "context_factor": 1.0,
  "last_calibration": 0,
  "duplicate_session": false,
  "status": "active"
}
```

**Key Logic:**
```bash
# Calculate PROJECT_HASH
PROJECT_HASH=$(echo "$CWD_PATH" | tr '[:upper:]' '[:lower:]' | md5 -q 2>/dev/null)
STATE_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_session.json"

# Detect stale sessions
FILE_AGE=$((NOW - FILE_MOD_TIME))
SESSION_STATUS=$(jq -r '.status // "unknown"' "$STATE_FILE")

if [[ $FILE_AGE -ge 300 && "$SESSION_STATUS" == "finalized" ]]; then
    # Reset for fresh session
fi
```

---

#### 2. check_boundaries.sh
**Trigger:** PreToolUse (Edit/Write) | **Type:** Hook

```bash
# Location: Governance/scripts/check_boundaries.sh
# Execution: Before each Edit or Write tool use
# Purpose: Prevent modifications to protected paths
```

**Logic:**
1. Read CLAUDE.md files (global + project)
2. Parse CAN modify section (allowed paths)
3. Parse CANNOT modify section (protected paths)
4. Validate file path against both sections
5. Approve or deny tool use

**Protected Paths (from CLAUDE.md):**
```
CANNOT modify:
  - /Volumes/*
  - /etc/*
  - v1_archive/
```

**Decision:** Returns JSON with `decision: "approve"` or `"deny"`

---

#### 3. log_tool_use.sh
**Trigger:** PostToolUse (all tools) | **Type:** Hook

```bash
# Location: Governance/scripts/log_tool_use.sh
# Execution: After every tool use (Read, Edit, Write, Bash, etc.)
# Purpose: Track usage + estimate tokens + update todo state
```

**Actions:**
1. Calculate PROJECT_HASH from current working directory
2. Read session state file: `~/.claude/sessions/{PROJECT_HASH}_session.json`

3. **Log tool use:**
   - Write to: `~/.claude/audit/tool_use.log`
   - Format: `TIMESTAMP | TOOL_NAME | PROJECT_PATH`

4. **Track last tool:**
   - Write tool name → `~/.claude/last_tool_name`
   - Write timestamp → `~/.claude/last_tool_time`
   - (Used by suggest_model.sh for status bar)

5. **Estimate tokens:**
   - Formula: `tokens = input_length / 4` (rough estimate)
   - Update state: `token_count += estimated_tokens`

6. **Update state file fields:**
   - `token_count` (cumulative)
   - `tool_count` (cumulative)
   - `last_update` (current timestamp)

7. **Track TodoWrite:**
   - If tool is TodoWrite, save todo state
   - File: `~/.claude/sessions/{PROJECT_HASH}_todo.json`

**Example State Update:**
```bash
# Before
jq -r '.token_count // 0' state.json  # → 5000
jq -r '.tool_count // 0' state.json   # → 12

# After tool use
# token_count: 5000 + 2500 (estimated) = 7500
# tool_count: 12 + 1 = 13
```

---

#### 4. detect_loop.sh
**Trigger:** PostToolUse (all tools) | **Type:** Hook

```bash
# Location: Governance/scripts/detect_loop.sh
# Execution: After every tool use
# Purpose: Detect stuck loops and warn user
```

**Detection Thresholds:**
- Same file edited **≥5 times** in 10-minute window → Loop warning
- Same error **≥3 times** → Loop warning

**State Tracking:**
```json
{
  "file_edits": {
    "/path/to/file": {
      "count": 5,
      "first_edit": 1768651202
    }
  },
  "error_counts": {
    "Error: ENOENT": 3
  },
  "last_cleanup": 1768651202
}
```

**Output:**
- If no loop: `{"decision": "approve"}` (silent)
- If loop detected:
```json
{
  "decision": "approve",
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "[LOOP] ▸▸▸ File edited 5 times in 10min. STOP and ask user."
  }
}
```

---

#### 5. check_warmup.sh
**Trigger:** Stop (between tool calls) | **Type:** Hook

```bash
# Location: Governance/scripts/check_warmup.sh
# Execution: Between Claude tool calls (Stop event)
# Purpose: Monitor session health and warn if issues detected
```

**Health Checks:**

| Check | Threshold | Warning |
|-------|-----------|---------|
| Warmup elapsed | ≥90 minutes | "⏰ Warm-up due: Xm since last" |
| Session duration | ≥4 hours | "🟡 Session: Xh Ym. Consider break." |
| Session duration | ≥8 hours | "🔴 LONG SESSION: Xh Ym. Consider wrap-up." |
| Context usage | ≥70% | "🟡 Context 70%: Monitor usage." |
| Context usage | ≥85% | "🔴 CONTEXT 85%: Start new session soon." |

**State Fields Read:**
- `start_time` (calculate session duration)
- `last_warmup` (calculate warmup elapsed)
- `token_count` (estimate context %)

**Output:**
```bash
# No warnings
{"decision": "approve"}

# With warnings
{
  "decision": "approve",
  "systemMessage": "[WARMUP] ▸▸▸ 🟡 Session: 2h 15m. Consider break or wrap-up soon."
}
```

---

#### 6. suggest_model.sh
**Trigger:** Status Line (continuous) | **Type:** Status Line Hook

```bash
# Location: Governance/scripts/suggest_model.sh
# Execution: Real-time status bar updates (every interaction)
# Purpose: Display session metrics and recommendations
```

**Display Format:**
```
🟢 Context: ~45K · ✅ 🕐 28m · 🔧 Bash

Breakdown:
├─ 🟢 Context indicator (red/yellow/green)
├─ ~45K = calibrated context usage (estimated tokens / 1000)
├─ ✅ = session duration status (✅ <2h, ⚠️ 2-2.5h, 🔴 ≥2.5h)
├─ 🕐 28m = session duration in minutes
└─ 🔧 Bash = last tool used (if < 5min old)
```

**Recommendations Display:**
```
Priority-based, shows:
1. Critical: Model not confirmed → "Confirm model (/status)"
2. Critical: Context ≥85% → "⚠️ /compact → touch ~/.claude/compact_flag"
3. Critical: Hook errors → "🔴 Hook errors: 2"
4. Warning: Calibration needed → "Check /context"
5. Warning: Long session → "⚠️ Start new session"
6. Info: Model suggestion → "Consider /model opus"
```

**State Fields Used:**
- `token_count` + `context_factor` → Calculate context %
- `start_time` → Calculate session duration
- `tool_count` → Detect high activity
- `status` → Validate session state

---

#### 7. save_session.sh
**Trigger:** SessionEnd (quit) | **Type:** Hook

```bash
# Location: Governance/scripts/save_session.sh
# Execution: When user quits session (exit command)
# Purpose: Archive session state + mark finalized + cleanup
```

**Actions:**
1. Calculate PROJECT_HASH from current directory
2. Read current state file: `~/.claude/sessions/{PROJECT_HASH}_session.json`

3. **Calculate session metadata:**
   - `end_time` = current Unix timestamp
   - `duration_seconds` = end_time - start_time

4. **Archive session:**
   - Add to JSON: `status: "finalized"`, `end_time`, `duration_seconds`
   - Save to: `~/.claude/sessions/YYYYMMDD_HHMMSS.json`

5. **Cleanup:**
   - Delete current state file

**Archived State Example:**
```json
{
  "start_time": 1768651202,
  "end_time": 1768651927,
  "duration_seconds": 725,
  "status": "finalized",
  "project": "/Users/mohammadshehata/Desktop/FILICITI/Governance",
  "project_name": "governance",
  "token_count": 12450,
  "tool_count": 47,
  "context_factor": 1.0,
  "last_calibration": 1768651500
}
```

**Next Session Flow:**
- When you run `cc` again, `inject_context.sh` detects:
  - State file doesn't exist (just deleted)
  - Creates FRESH state with `start_time = NOW`
  - Context + timer reset ✓

---

### Category: UTILITIES (3 scripts)

These run manually for debugging/maintenance.

#### 8. audit_sessions.sh
**Trigger:** Manual (`./audit_sessions.sh`) | **Type:** Utility

```bash
# Location: Governance/scripts/audit_sessions.sh
# Usage: cd Governance && ./audit_sessions.sh
# Output: Governance/sessionaudit/YYYYMMDD_audit.txt
```

**Generates Report:**
1. Per-project session history
2. Cross-reference with log files
3. Detect orphaned/corrupt session files
4. Calculate session durations from logs
5. Flag stale or invalid sessions

**Report Includes:**
- Project name + path
- Current session info (if active)
- Session history table (date, start, end, duration, status)
- Issues found (path invalid, empty files, corrupt JSON)
- Summary counts

**Example Command:**
```bash
cd ~/Desktop/FILICITI/Governance
./audit_sessions.sh
# Output: sessionaudit/20260117_audit.txt
```

---

#### 9. check_protocol.sh
**Trigger:** Manual (`./check_protocol.sh [CODE|BIZZ|OPS]`) | **Type:** Utility

```bash
# Location: Governance/scripts/check_protocol.sh
# Usage: ./check_protocol.sh            (auto-detect from CLAUDE.md)
#        ./check_protocol.sh CODE       (validate CODE protocol)
#        ./check_protocol.sh BIZZ       (validate BIZZ protocol)
#        ./check_protocol.sh OPS        (validate OPS protocol)
```

**Validates:**
- Session initialization (start_time set, boundaries confirmed)
- During session (TodoWrite used, protocol steps followed)
- Session end (warmup performed, git commits, tests run)

**Output Format:**
```
Results: 18 pass, 0 fail, 2 warn
Status: PROTOCOL OK ✓
```

**Project Types:**
- **CODE:** Requires tests, git commits, TodoWrite usage
- **BIZZ:** Requires decision tracking, business metrics
- **OPS:** Requires audit logging, operational tracking

---

#### 10. sync_templates.sh
**Trigger:** Manual (`./sync_templates.sh [push|pull|check]`) | **Type:** Utility

```bash
# Location: Governance/scripts/sync_templates.sh
# Usage: ./sync_templates.sh push       (Governance → ~/.claude)
#        ./sync_templates.sh pull       (Warning: overwrites Governance/)
#        ./sync_templates.sh check      (dry-run, no changes)
```

**Syncs:**
- `CONTEXT_TEMPLATE.md`
- `session_handoff.md`
- `Shared_context_TEMPLATE.md`

**Between:**
- Source: `Governance/templates/`
- Destination: `~/.claude/templates/`

**Example:**
```bash
./sync_templates.sh check
# Summary: 3 identical, 0 different, 0 missing
# → All templates are in sync! ✓
```

---

## 4. Session Lifecycle - Three Flows

### Flow 1: START (cc command)

```
USER RUNS: cc
    │
    ├─ Claude Code starts
    ├─ Reads working directory
    └─ Triggers: SessionStart event
         │
         ▼
    ╔════════════════════════════════════════════════╗
    ║ inject_context.sh (SessionStart Hook)         ║
    ╚════════════════════════════════════════════════╝
         │
         ├─ Step 1: Calculate PROJECT_HASH
         │  └─ Path: /Users/mohammadshehata/Desktop/FILICITI/Governance
         │  └─ Hash: md5 (lowercase path) = "54f3a7e16b20f1c8fe2df7cbf568e81f"
         │
         ├─ Step 2: Determine state file path
         │  └─ ~/.claude/sessions/54f3a7e16b20f1c8fe2df7cbf568e81f_session.json
         │
         ├─ Step 3: Check state file
         │  │
         │  ├─ CASE A: File doesn't exist (BRAND NEW SESSION)
         │  │  │
         │  │  └─ CREATE fresh state:
         │  │     {
         │  │       "start_time": 1768651202,
         │  │       "token_count": 0,
         │  │       "tool_count": 0,
         │  │       "status": "active"
         │  │     }
         │  │
         │  ├─ CASE B: File exists + age ≥5min + status="finalized"
         │  │  │
         │  │  └─ RESET FOR FRESH SESSION:
         │  │     {
         │  │       "start_time": <NOW>,
         │  │       "token_count": 0,
         │  │       "tool_count": 0,
         │  │       "status": "active"
         │  │     }
         │  │
         │  └─ CASE C: File exists + recent + status="active"
         │     │
         │     └─ PRESERVE existing state (continue session)
         │        Add missing fields if needed
         │
         ├─ Step 4: Check for compact flag
         │  │
         │  └─ if [ -f ~/.claude/compact_flag ]; then
         │     ├─ token_count = 0
         │     ├─ start_time = NOW
         │     ├─ last_warmup = NOW
         │     └─ rm ~/.claude/compact_flag
         │
         ├─ Step 5: Validate hook health
         │  │
         │  └─ Check each hook has execute permission
         │     Write hook status → ~/.claude/hook_status
         │
         └─ Step 6: Output metadata
            │
            └─ JSON:
               {
                 "hookSpecificOutput": {
                   "additionalContext": "📅 Date: 2026-01-17 04:11 AM · 📁 Project: governance · 🔌 Plugins: 22"
                 }
               }
    │
    ├─ Claude announces session metadata + boundaries
    ├─ Status bar loads: suggest_model.sh
    │  └─ Displays: 🟢 Context: ~0K · ✅ 🕐 0m
    │
    └─ ✅ SESSION STARTED
       Ready for tools
```

**Key Scenario: Stale Session Reset**

If you exit Claude, wait 5+ minutes, then run `cc` again:
```
Old session file: ~/.claude/sessions/{HASH}_session.json
├─ File age: 450 seconds (7.5 minutes) ✓ ≥ 300s
├─ status: "finalized" ✓
└─ Action: RESET ALL FIELDS
   ├─ start_time: 1768651202 → 1768652000 (NEW)
   ├─ token_count: 12450 → 0 (RESET)
   ├─ status: "finalized" → "active" (RESET)
   └─ Fresh session begins! ✓
```

---

### Flow 2: DURING SESSION (Tool calls + Monitoring)

```
SESSION ACTIVE
    │
    ├─────────────────────────────────────────────────┐
    │ [User requests: Edit or Write tool]             │
    │                                                 │
    ▼                                                 │
╔═══════════════════════════════════════════════════╗│
║ PreToolUse: check_boundaries.sh                   ║│
╠═══════════════════════════════════════════════════╣│
║ 1. Read CLAUDE.md CAN/CANNOT sections             ║│
║ 2. Validate file path against boundaries          ║│
║ 3. Return: decision="approve" or "deny"           ║│
╚═══════════════════════════════════════════════════╝│
    │                                                 │
    └─ If denied → Tool blocked, return to user       │
    │
    ▼
╔═══════════════════════════════════════════════════╗
║ [Tool executes]                                    ║
║ (Edit, Write, Bash, Read, etc.)                   ║
╚═══════════════════════════════════════════════════╝
    │
    ├─────────────────────────────────────────────────┐
    │ [After ANY tool completes]                      │
    │                                                 │
    ▼                                                 │
╔═══════════════════════════════════════════════════╗ ├─ [Parallel]
║ PostToolUse: log_tool_use.sh                      ║ │
╠═══════════════════════════════════════════════════╣ │
║ 1. Extract tool name (Edit, Bash, etc.)          ║ │
║ 2. Estimate tokens: input_length / 4             ║ │
║ 3. Update state file:                            ║ │
║    - token_count += estimated_tokens             ║ │
║    - tool_count += 1                             ║ │
║    - last_update = NOW                           ║ │
║ 4. Track last tool → ~/.claude/last_tool_name    ║ │
║ 5. Log to: ~/.claude/audit/tool_use.log          ║ │
║ 6. If TodoWrite: save todo state                 ║ │
╚═══════════════════════════════════════════════════╝ │
    │                                                 │
    ├─────────────────────────────────────────────────┤
    │                                                 │
    ▼                                                 │
╔═══════════════════════════════════════════════════╗ │
║ PostToolUse: detect_loop.sh                       ║ │
╠═══════════════════════════════════════════════════╣ │
║ 1. Track file edits (file path + count)          ║ │
║ 2. Track error messages (normalized)             ║ │
║ 3. If same file 5+ edits in 10min → Warn        ║ │
║ 4. If same error 3+ times → Warn                ║ │
║ 5. Return: decision="approve" + optional warning ║ │
╚═══════════════════════════════════════════════════╝ └─ [Parallel]
    │
    ├─────────────────────────────────────────────────┐
    │ [Between tool calls]                            │
    │                                                 │
    ▼                                                 │
╔═══════════════════════════════════════════════════╗
║ Stop: check_warmup.sh                             ║
╠═══════════════════════════════════════════════════╣
║ 1. Read session state file                       ║
║ 2. Check 1: Warmup elapsed > 90min?              ║
║ 3. Check 2: Session duration warnings            ║
║ 4. Check 3: Context usage warnings               ║
║ 5. Output system message if warnings detected    ║
╚═══════════════════════════════════════════════════╝
    │
    ├─────────────────────────────────────────────────┐
    │ [Real-time - Continuous]                        │
    │                                                 │
    ▼                                                 │
╔═══════════════════════════════════════════════════╗
║ Status Line: suggest_model.sh                     ║
╠═══════════════════════════════════════════════════╣
║ Display:                                          ║
║   🟢 Context: ~45K · ✅ 🕐 28m · 🔧 Bash        ║
║                                                 ║
║ Updates every interaction with:                  ║
║ • Context % (calibrated tokens / 155K)          ║
║ • Session duration in minutes                   ║
║ • Last tool used (if recent)                    ║
║ • Recommendations (if any)                      ║
╚═══════════════════════════════════════════════════╝
    │
    └─ Repeat for next tool...
```

**Example Scenario: Editing a file**

```
Timeline:
─────────────────────────────────────────────────

T+00s:  User: "Fix the bug in src/app.ts"
T+01s:  → PreToolUse: check_boundaries.sh
        └─ Check: src/app.ts is allowed? YES ✓
T+02s:  → Edit tool executes
T+03s:  → PostToolUse: log_tool_use.sh
        ├─ Input size: ~8000 chars
        ├─ Estimated tokens: 8000/4 = 2000
        ├─ State before: token_count=5000, tool_count=10
        ├─ State after: token_count=7000, tool_count=11
        └─ last_tool_name = "Edit"
T+04s:  → PostToolUse: detect_loop.sh
        └─ File count: 1 (no loop yet)
T+05s:  → Status bar updates:
        └─ 🟢 Context: ~45K · ✅ 🕐 8m · 🔧 Edit

[Claude processes and responds]

T+30s: → Stop: check_warmup.sh
       └─ All checks pass (session 8m, context 45%)
```

---

### Flow 3: COMPACT & END

```
SCENARIO A: COMPACT (Refresh Context)
═════════════════════════════════════════════════════

CURRENT SESSION (running for 2+ hours)
├─ token_count: 145,000 (context 93%)
├─ status: "active"
└─ time: 2h 15m

USER ACTION: Type "refresh context"
    │
    ├─ Claude runs: touch ~/.claude/compact_flag
    │  (Persistent flag between sessions)
    │
    └─ User: type "exit"
         │
         ▼
    ╔════════════════════════════════════════════╗
    ║ SessionEnd: save_session.sh                ║
    ╠════════════════════════════════════════════╣
    ║ 1. Read state file                         ║
    ║ 2. Calculate:                              ║
    ║    - end_time = NOW (1768652000)           ║
    ║    - duration = 1768652000 - 1768651000    ║
    ║             = 1000 seconds = 16.7 min     ║
    ║ 3. Set status = "finalized"                ║
    ║ 4. Archive to:                             ║
    ║    ~/.claude/sessions/20260117_041527.json ║
    ║ 5. Delete current state file               ║
    ╚════════════════════════════════════════════╝
    │
    └─ Session ended ✓
       ~/.claude/compact_flag still exists


NEXT SESSION (user runs: cc)
    │
    ▼
╔════════════════════════════════════════════╗
║ SessionStart: inject_context.sh            ║
╠════════════════════════════════════════════╣
║ 1. Calculate PROJECT_HASH                  ║
║ 2. Check state file:                       ║
║    → Doesn't exist (was deleted)           ║
║ 3. Check for compact flag:                 ║
║    → YES! ~/.claude/compact_flag exists    ║
║ 4. Action: RESET                           ║
║    {                                       ║
║      "start_time": 1768652100,  ← NEW      ║
║      "token_count": 0,          ← RESET    ║
║      "tool_count": 0,           ← RESET    ║
║      "status": "active"         ← FRESH    ║
║    }                                       ║
║ 5. Delete: ~/.claude/compact_flag          ║
║ 6. Output: Fresh session started!          ║
╚════════════════════════════════════════════╝
    │
    ├─ Status bar shows: 🟢 Context: ~0K
    ├─ Session timer: ✅ 🕐 0m
    └─ ✅ FRESH SESSION with reset context!


SCENARIO B: NORMAL END (Exit)
═════════════════════════════════════════════════════

CURRENT SESSION (running for 45 minutes)
├─ token_count: 32,000
├─ tool_count: 23
├─ status: "active"
└─ time: 45m

USER ACTION: type "exit"
    │
    ├─ NO compact flag (user didn't request)
    │
    ▼
╔════════════════════════════════════════════╗
║ SessionEnd: save_session.sh                ║
╠════════════════════════════════════════════╣
║ 1. Read state: start_time = 1768651100    ║
║ 2. Calculate:                              ║
║    - NOW = 1768652800                      ║
║    - duration = 1768652800 - 1768651100   ║
║             = 1700 seconds = 28.3 min     ║
║ 3. Archive with metadata:                  ║
║    {                                       ║
║      "start_time": 1768651100,             ║
║      "end_time": 1768652800,               ║
║      "duration_seconds": 1700,             ║
║      "status": "finalized",                ║
║      "token_count": 32000,                 ║
║      "tool_count": 23                      ║
║    }                                       ║
║ 4. Save to:                                ║
║    ~/.claude/sessions/20260117_041600.json ║
║ 5. Delete current state file               ║
╚════════════════════════════════════════════╝
    │
    └─ Session archived ✓


NEXT SESSION (user runs: cc after 2 hours)
    │
    ▼
╔════════════════════════════════════════════╗
║ SessionStart: inject_context.sh            ║
╠════════════════════════════════════════════╣
║ 1. Check state file:                       ║
║    → Doesn't exist (was deleted)           ║
║ 2. Create FRESH state:                     ║
║    {                                       ║
║      "start_time": 1768659300,  ← NEW      ║
║      "token_count": 0,          ← NEW      ║
║      "tool_count": 0,           ← NEW      ║
║      "status": "active"         ← NEW      ║
║    }                                       ║
║ 3. (No compact flag, just fresh start)     ║
╚════════════════════════════════════════════╝
    │
    └─ ✅ NEW SESSION started fresh!
```

---

## 5. State File Schema

### File Location
```
~/.claude/sessions/{PROJECT_HASH}_session.json

Where PROJECT_HASH = md5(lowercase_path_to_project)
Example: 54f3a7e16b20f1c8fe2df7cbf568e81f
```

### Full State File Schema

```json
{
  "start_time": 1768651202,
  "end_time": 1768651927,
  "duration_seconds": 725,
  "last_warmup": 1768651202,
  "last_update": 1768651917,
  "last_calibration": 1768651500,
  "project": "/Users/mohammadshehata/Desktop/FILICITI/Governance",
  "project_name": "governance",
  "token_count": 12450,
  "tool_count": 47,
  "context_factor": 1.0,
  "duplicate_session": false,
  "status": "active"
}
```

### Field Definitions

| Field | Type | Description | Set By | Notes |
|-------|------|-------------|--------|-------|
| `start_time` | Unix timestamp | Session start | inject_context.sh | Reset on new/stale sessions |
| `end_time` | Unix timestamp | Session end | save_session.sh | Only set at SessionEnd |
| `duration_seconds` | Integer | Total session time | save_session.sh | Calculated: end_time - start_time |
| `last_warmup` | Unix timestamp | Last warmup check | inject_context.sh | Updated by check_warmup.sh |
| `last_update` | Unix timestamp | Last state change | log_tool_use.sh | Updated after every tool |
| `last_calibration` | Unix timestamp | Last context calibration | Manual (user command) | Used for recalibration reminders |
| `project` | String | Absolute project path | inject_context.sh | `/Users/mohammadshehata/Desktop/FILICITI/Governance` |
| `project_name` | String | Basename of project | inject_context.sh | `governance` |
| `token_count` | Integer | Cumulative tokens | log_tool_use.sh | ~4 chars per token estimate |
| `tool_count` | Integer | Number of tools used | log_tool_use.sh | Incremented after each tool |
| `context_factor` | Float | Calibration multiplier | Manual calibration | Default: 1.0. User can set to adjust estimates. |
| `duplicate_session` | Boolean | Is duplicate session | inject_context.sh | Internal tracking |
| `status` | String | Session state | inject_context.sh / save_session.sh | `"active"` or `"finalized"` |

### Status Lifecycle

```
STATE PROGRESSION:
─────────────────

[File Creation]
    │
    └─ status: "active"
       └─ Used for: 30 seconds to hours (session duration)

[Session Active]
    │
    └─ status: "active"
       ├─ token_count: growing
       ├─ tool_count: growing
       └─ last_update: continuously updated

[User Quits: exit]
    │
    └─ save_session.sh runs
       ├─ status: "active" → "finalized" ✓
       ├─ end_time: set to NOW
       ├─ duration_seconds: calculated
       └─ Archive to: ~/.claude/sessions/{TIMESTAMP}.json
          └─ Current file: DELETED

[Next Session Starts: cc]
    │
    └─ inject_context.sh checks:
       ├─ File age ≥5min AND status="finalized"?
       │  └─ YES: Create FRESH state (start_time=NOW, status="active")
       │  └─ NO: Preserve state (continue session)
```

### Context Usage Calculation

```bash
# Formula:
USABLE_CONTEXT = 200000 - 45000 = 155000 tokens
CONTEXT_PCT = (token_count * context_factor) * 100 / 155000

# Example 1: Fresh session
token_count = 0
context_factor = 1.0
CONTEXT_PCT = 0%
Display: 🟢 Context: ~0K

# Example 2: Mid-session
token_count = 45000
context_factor = 1.0
CONTEXT_PCT = 45000 * 1.0 * 100 / 155000 = 29%
Display: 🟢 Context: ~45K

# Example 3: High usage
token_count = 120000
context_factor = 1.0
CONTEXT_PCT = 120000 * 1.0 * 100 / 155000 = 77%
Display: 🟡 Context: ~120K

# Example 4: Critical
token_count = 145000
context_factor = 1.0
CONTEXT_PCT = 145000 * 1.0 * 100 / 155000 = 93%
Display: 🔴 Context: ~145K (needs compact)

# Example 5: Calibrated
token_count = 100000
context_factor = 0.75 (actual/estimate = 75K/100K)
CONTEXT_PCT = 100000 * 0.75 * 100 / 155000 = 48%
Display: 🟢 Context: ~75K*
```

---

## 6. Hook Categories & Technical Details

### A. Session Lifecycle Hooks (3)

These control session initialization and finalization.

**inject_context.sh:**
- Creates/resets state on session start
- Detects stale sessions (age ≥5min + status="finalized")
- Handles compact flag
- Outputs session metadata

**save_session.sh:**
- Archives session on quit
- Marks status="finalized"
- Calculates duration_seconds
- Cleans up current state file

**check_warmup.sh:**
- Monitors health between tool calls
- Warns if session/context too high
- Suggests actions (compact, break, new session)

### B. Tool Tracking Hooks (2)

These track what tools are being used.

**log_tool_use.sh:**
- Logs every tool use
- Estimates tokens from input length
- Updates state file counters
- Tracks last tool for status bar
- Stores todo state

**detect_loop.sh:**
- Tracks file edits (count + time window)
- Tracks error messages (count)
- Warns if looping detected
- Resets counters periodically

### C. Validation Hooks (2)

These validate and protect operations.

**check_boundaries.sh:**
- Reads CLAUDE.md boundary rules
- Validates file paths before Edit/Write
- Prevents modifications to protected dirs
- Returns approve/deny decision

**check_warmup.sh:**
- Validates session health
- Warns about long sessions
- Warns about high context usage
- Suggests warmup or wrap-up

### D. Display Hooks (1)

Real-time status updates.

**suggest_model.sh:**
- Calculates context % usage
- Shows session duration timer
- Displays last tool used
- Provides recommendations
- Suggests model upgrades/downgrades

### E. Utilities (3)

Manual tools for debugging.

**audit_sessions.sh:**
- Reviews all session archives
- Finds orphaned files
- Generates audit report

**check_protocol.sh:**
- Validates protocol adherence
- Checks per-project requirements
- Reports pass/fail/warn status

**sync_templates.sh:**
- Keeps templates synchronized
- Push/pull modes
- Prevents template drift

---

## 7. Debugging & Troubleshooting

### Common Issues & Fixes

#### Issue 1: Session Duration Shows Wrong Number

**Symptom:**
```
Status bar: 🕐 57915823m (huge number!)
```

**Root Cause:**
- State file corrupted: `start_time = 0` or missing
- Formula uses epoch 0 as fallback

**Debug:**
```bash
# Check state file
cat ~/.claude/sessions/{HASH}_session.json | jq '.start_time'

# Should be: 1768651202 (recent Unix timestamp)
# Not: 0 or null
```

**Fix:**
```bash
# Option A: Restart session
exit
cc  # Fresh session will reset

# Option B: Manual state file fix
jq '.start_time = '$(date +%s) ~/.claude/sessions/{HASH}_session.json > /tmp/fix.json
mv /tmp/fix.json ~/.claude/sessions/{HASH}_session.json
```

---

#### Issue 2: Context Doesn't Reset After Compact

**Symptom:**
```
Before: 🔴 Context: ~145K
After touch flag + exit + cc: 🔴 Context: ~145K (still!)
```

**Root Cause:**
- Compact flag not detected
- State file not reset properly

**Debug:**
```bash
# Check compact flag was created
ls -la ~/.claude/compact_flag
# If not found: Flag was deleted but compact didn't work

# Check state file exists
ls -la ~/.claude/sessions/{HASH}_session.json

# Check token_count
jq '.token_count' ~/.claude/sessions/{HASH}_session.json
# Should be: 0 after compact
```

**Fix:**
```bash
# Step 1: Create flag manually
touch ~/.claude/compact_flag

# Step 2: Exit current session
exit

# Step 3: Start new session
cc

# Step 4: Verify reset
# Status bar should show: 🟢 Context: ~0K
```

---

#### Issue 3: Hooks Not Running

**Symptom:**
```
No hook metadata on session start
No status bar updates
```

**Root Cause:**
- Hook scripts not executable
- Settings.json has wrong paths
- Hooks disabled in settings

**Debug:**
```bash
# Check hook scripts have execute permission
ls -la ~/Desktop/FILICITI/Governance/scripts/*.sh
# Should show: -rwx--x--x (execute bit set)

# Check settings.json has correct paths
grep "Desktop/FILICITI/Governance/scripts" ~/.claude/settings.json
# Should find all hook paths

# Check if hooks are enabled
jq '.hooks' ~/.claude/settings.json
# Should show: not empty
```

**Fix:**
```bash
# Make all scripts executable
chmod +x ~/Desktop/FILICITI/Governance/scripts/*.sh

# Verify settings.json paths are correct
cd ~/Desktop/FILICITI/Governance
grep -r "Desktop/Governance" ~/.claude/settings.json
# If found (old path): Need to update to FILICITI/Governance
```

---

#### Issue 4: Stale Session Not Resetting

**Symptom:**
```
Quit session after 30 seconds
Wait 10 minutes
Run cc
Status bar still shows: 🕐 15m (old session time!)
```

**Root Cause:**
- Session file not marked as "finalized"
- inject_context.sh stale detection not triggering

**Debug:**
```bash
# Check session file status
jq '.status' ~/.claude/sessions/{HASH}_session.json
# Should be: "finalized" (if properly saved)

# Check file modification time
stat -f "%Sm" ~/.claude/sessions/{HASH}_session.json
# Should be: > 5 min ago

# Check inject_context.sh logic manually
NOW=$(date +%s)
FILE_MOD=$(stat -f%m ~/.claude/sessions/{HASH}_session.json)
FILE_AGE=$((NOW - FILE_MOD))
echo "File age: $FILE_AGE seconds"
# Should be: ≥ 300
```

**Fix:**
```bash
# Manually update status to finalized
jq '.status = "finalized"' ~/.claude/sessions/{HASH}_session.json > /tmp/fix.json
mv /tmp/fix.json ~/.claude/sessions/{HASH}_session.json

# Then exit and start new session
exit
cc  # Should detect stale and reset
```

---

### Manual Hook Testing

#### Test 1: SessionStart Hook

```bash
# Simulate session start
cd ~/Desktop/FILICITI/Governance
bash scripts/inject_context.sh

# Check output
jq . ~/.claude/sessions/{HASH}_session.json

# Expected:
{
  "start_time": <recent>,
  "status": "active",
  "token_count": 0
}
```

#### Test 2: Boundary Validation

```bash
# Test protected path (should deny)
cd ~/Desktop/FILICITI/Governance
echo '{"tool_input": {"file_path": "/etc/passwd"}}' | bash scripts/check_boundaries.sh
# Expected: "deny"

# Test allowed path (should approve)
echo '{"tool_input": {"file_path": "docs/README.md"}}' | bash scripts/check_boundaries.sh
# Expected: "approve"
```

#### Test 3: Loop Detection

```bash
# Simulate repeated file edit
for i in {1..5}; do
    echo '{"tool_name": "Edit", "tool_input": {"file_path": "src/app.ts"}}' | bash scripts/detect_loop.sh
done

# Should detect loop after 5 edits
# Output should include: "LOOP: File edited 5 times"
```

#### Test 4: Warmup Check

```bash
# Simulate warmup check
bash scripts/check_warmup.sh

# Expected output (if no warnings):
# {"decision": "approve"}

# With warnings:
# {"decision": "approve", "systemMessage": "[WARMUP] ..."}
```

---

### Log File Locations

```
~/.claude/sessions/
├─ {PROJECT_HASH}_session.json      (Current session state)
├─ {TIMESTAMP}_session.json         (Archived sessions)
└─ {TIMESTAMP}_session.json         (More archived sessions)

~/.claude/
├─ hook_status                       (Hook health status)
├─ last_tool_name                    (Last tool used)
├─ last_tool_time                    (Last tool timestamp)
├─ loop_state.json                   (Loop detection state)
├─ compact_flag                      (Compact request flag - temp)
└─ audit/
   └─ tool_use.log                   (All tool uses logged)

Governance/
└─ sessionaudit/
   └─ YYYYMMDD_audit.txt            (Audit report)
```

---

## 8. Version History & Fixes (v3.0.0)

### Migration from v2.5 to v3.0.0

**Date:** 2026-01-17
**Status:** All fixes applied ✅

### Problems Fixed

**Bug #1: No .log file creation / No start messages**
- **Root Cause:** save_session.sh used hardcoded `~/.claude/governance_session.json` path
- **Impact:** Session state never properly initialized; startup hooks failed silently
- **Fix:** Added PROJECT_HASH-based path calculation (same as other hooks)
- **File:** `save_session.sh:8-11`

**Bug #2: Status bar showing weird numbers (e.g., "🕐 57915823m")**
- **Root Cause:** State file missing/corrupted; start_time=0 caused epoch calculation error
- **Impact:** Huge nonsensical duration displayed
- **Fix:**
  1. Added stale session detection to inject_context.sh (reset if file > 5min old + status="finalized")
  2. Added guard in suggest_model.sh to catch invalid start_time
- **Files:** `inject_context.sh:42-65`, `suggest_model.sh:181`

**Bug #3: Time and context don't restart when quitting**
- **Root Cause:** SessionEnd hook never found state file (wrong path); stale sessions not reset on next start
- **Impact:** New sessions inherited old start_time and token_count from previous sessions
- **Fixes:**
  1. Fixed save_session.sh to use PROJECT_HASH path + mark status="finalized"
  2. Added stale session detection (age ≥5min + status="finalized" = reset)
  3. Reset start_time to NOW when compact flag detected
- **Files:** `save_session.sh`, `inject_context.sh:80-89`

**Bug #4: After compact, context doesn't reset**
- **Root Cause:** Compact flag checked but didn't reset start_time; only reset token_count
- **Impact:** New session shows new context but old timer still running
- **Fix:** Enhanced compact flag handling to reset both token_count AND start_time
- **File:** `inject_context.sh:80-89`

### Scripts Updated

| Script | Changes | Lines |
|--------|---------|-------|
| `save_session.sh` | Added PROJECT_HASH path, status field, end_time, duration_seconds | 7-46 |
| `inject_context.sh` | Added stale session detection, status field, enhanced compact flag | 22-89 |
| `detect_loop.sh` | Removed unused hardcoded path reference | 20 |
| `check_protocol.sh` | Added PROJECT_HASH path calculation | 24-28 |

### New Fields Added to State File

```json
{
  "status": "active|finalized",        // NEW: Track session lifecycle
  "end_time": 1768651927,              // NEW: Set at SessionEnd only
  "duration_seconds": 725              // NEW: Calculated duration
}
```

### Breaking Changes

**None.** All changes are backward-compatible.
- Old state files without `status` field will be auto-populated as "active"
- Missing `end_time` won't cause errors (only set at session end)
- Existing workflows unchanged

### Migration Path

**For existing sessions:**

1. Current session files at `~/.claude/governance_session.json` are orphaned
   - Will be ignored (new path uses PROJECT_HASH)
   - Safe to delete: `rm ~/.claude/governance_session.json`

2. Next time you run `cc`:
   - `inject_context.sh` creates new state file at correct path
   - Fresh session starts automatically

3. No manual actions needed ✓

### Testing the Fixes

```bash
# Test 1: Fresh session starts with correct state
cd ~/Desktop/FILICITI/Governance
exit     # Exit if running
cc       # Start new session
# Check: Status bar shows 🟢 Context: ~0K · ✅ 🕐 0m

# Test 2: Stale session resets
cc       # Session A
# Wait 5+ minutes...
exit     # Exit session A
wait 5 min
cc       # Session B
# Check: Status bar shows fresh time (0m or low), not old time

# Test 3: Compact resets context
cc       # Session running
# Wait for high context...
refresh context   # Touch flag + exit
cc       # New session
# Check: 🟢 Context: ~0K (reset!)

# Test 4: Hooks running
cc
# Check: Startup message shows hook metadata
# Check: Status bar updates in real-time
```

### Known Limitations

None identified. All systems operational.

---

**Document Version:** 3.0.0
**Last Updated:** 2026-01-17 04:15 AM
**Maintainer:** Governance Operations
**Next Review:** 2026-02-15
