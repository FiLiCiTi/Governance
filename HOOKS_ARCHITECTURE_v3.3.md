# Hooks Architecture v3.3

> **Purpose:** Practical reference for v3.3 hook system
> **Version:** 3.3.0
> **Updated:** 2026-01-18

## Table of Contents

| Section | Title                                              | Line |
|---------|---------------------------------------------------|------|
| 1       | [Quick Reference](#1-quick-reference)             | :17  |
| 2       | [State Files](#2-state-files)                     | :65  |
| 3       | [Hook Lifecycle](#3-hook-lifecycle)               | :136 |
| 4       | [Hook Details](#4-hook-details)                   | :217 |
| 5       | [Troubleshooting](#5-troubleshooting)             | :420 |

---------------------------------------------------------------------------------------------------------------------------

## 1. Quick Reference

### 1.1 All 10 Hooks

| # | Hook Name                   | Event       | Purpose                              | State Files  |
|---|-----------------------------|-------------|--------------------------------------|--------------|
| 1 | `init_session.sh`           | SessionStart| Initialize session state             | All 3        |
| 2 | `reset_context.sh`          | SessionStart| Handle compact flag                  | session,     |
|   |                             |             |                                      | context      |
| 3 | `track_context.sh`          | PostToolUse | Update token count                   | context      |
| 4 | `track_time.sh`             | PostToolUse | Update session timer                 | session      |
| 5 | `log_tool.sh`               | PostToolUse | Log tool usage                       | tools        |
| 6 | `validate_boundaries.sh`    | PreToolUse  | Validate file paths                  | (read-only)  |
| 7 | `detect_loop.sh`            | PostToolUse | Detect infinite loops                | (internal)   |
| 8 | `check_session_duration.sh` | Stop        | Warn if session too long             | session      |
| 9 | `check_context_usage.sh`    | Stop        | Warn if context too high             | context      |
| 10| `finalize_session.sh`       | SessionEnd  | Archive session                      | All 3        |

**Additional:**
- `status_bar.sh` - Status line display (reads all 3 state files)

---------------------------------------------------------------------------------------------------------------------------

### 1.2 v3.3 Key Changes from v3.0

**OLD (v3.0):**
- 1 unified state file (`{HASH}_session.json`)
- 7 hooks (inject_context.sh, log_tool_use.sh, check_warmup.sh, suggest_model.sh, save_session.sh,
  check_boundaries.sh, detect_loop.sh)
- Hooks with multiple responsibilities

**NEW (v3.3):**
- 3 separated state files (session.json, context.json, tools.json)
- 10 focused hooks (one responsibility each)
- Auto-migration from v3.0 → v3.3

---------------------------------------------------------------------------------------------------------------------------

### 1.3 Related Documentation

**For design decisions (what and why):**
- Read: `Gov_Design_v3.3.md`

**For implementation details (how it works):**
- Read: `Architecture_v3.3.md`

**This document:**
- Quick reference and troubleshooting

---------------------------------------------------------------------------------------------------------------------------

## 2. State Files

### 2.1 File Locations

```
~/.claude/sessions/
├─ {PROJECT_HASH}_session.json    # Session state (time + metadata + model)
├─ {PROJECT_HASH}_context.json    # Context tracking (tokens + calibration)
├─ {PROJECT_HASH}_tools.json      # Tool tracking (count + last tool)
└─ 20260118_053000.json           # Archived sessions (finalized)
```

**PROJECT_HASH calculation:**
```bash
PROJECT_HASH=$(echo -n "$CLAUDE_WORKING_DIR" | shasum -a 256 | cut -d' ' -f1 | head -c 16)
```

---------------------------------------------------------------------------------------------------------------------------

### 2.2 Schema: session.json

```json
{
  "start_time": 1768743045,
  "end_time": null,
  "last_update": 1768743841,
  "status": "active",
  "project": "/Users/mohammadshehata/Desktop/FILICITI/Governance",
  "project_name": "governance",
  "log_file": "./Conversations/20260118_0530.log",
  "model": "sonnet",
  "model_confirmed_at": 1768743045
}
```

**Owned by:** init_session.sh, track_time.sh, finalize_session.sh

---------------------------------------------------------------------------------------------------------------------------

### 2.3 Schema: context.json

```json
{
  "token_count": 15818,
  "last_calibration": 0,
  "context_factor": 1.0
}
```

**Owned by:** track_context.sh, reset_context.sh, check_context_usage.sh

---------------------------------------------------------------------------------------------------------------------------

### 2.4 Schema: tools.json

```json
{
  "tool_count": 16,
  "last_tool": "Bash",
  "last_tool_time": 1768743841
}
```

**Owned by:** log_tool.sh

---------------------------------------------------------------------------------------------------------------------------

## 3. Hook Lifecycle

### 3.1 Session Start Flow

```
USER RUNS: cc
    │
    ▼
1. init_session.sh (SessionStart)
    ├─ Calculate PROJECT_HASH
    ├─ Check for v3.0 migration (auto-migrate if found)
    ├─ Create/restore: session.json, context.json, tools.json
    └─ Output session metadata
    │
    ▼
2. reset_context.sh (SessionStart)
    ├─ Check for ~/.claude/compact_flag
    ├─ If exists: Reset session start_time + context token_count
    └─ Delete flag
    │
    ▼
✅ SESSION STARTED
   Status bar: Sonnet · 🟢 Context: ~0K · ✅ 🕐 0m · 🔧 --
```

---------------------------------------------------------------------------------------------------------------------------

### 3.2 During Session Flow

```
TOOL REQUEST
    │
    ▼
3. validate_boundaries.sh (PreToolUse - Edit/Write only)
    ├─ Read CLAUDE.md boundaries
    ├─ Validate file path
    └─ Approve or deny
    │
    ▼
[Tool executes]
    │
    ▼
4. track_context.sh (PostToolUse)
    └─ Update context.json: token_count += estimated
    │
5. track_time.sh (PostToolUse)
    └─ Update session.json: last_update = NOW
    │
6. log_tool.sh (PostToolUse)
    ├─ Log to ~/.claude/audit/tool_use.log
    └─ Update tools.json: tool_count++, last_tool, last_tool_time
    │
7. detect_loop.sh (PostToolUse)
    └─ Warn if loop detected
    │
    ▼
[Between tool calls]
    │
8. check_session_duration.sh (Stop)
    └─ Warn if ≥2h or ≥2.5h
    │
9. check_context_usage.sh (Stop)
    └─ Warn if ≥70% or ≥85%
    │
    ▼
[Real-time]
    │
10. status_bar.sh (continuous)
    └─ Display: Model · Context · Duration · Last Tool
```

---------------------------------------------------------------------------------------------------------------------------

### 3.3 Session End Flow

```
USER: exit
    │
    ▼
11. finalize_session.sh (SessionEnd)
    ├─ Read all state files
    ├─ Calculate duration
    ├─ Set status = "finalized"
    ├─ Archive to timestamped file: ~/.claude/sessions/YYYYMMDD_HHMMSS.json
    └─ Delete current state files
    │
    ▼
✅ SESSION ENDED
```

---------------------------------------------------------------------------------------------------------------------------

## 4. Hook Details

### 4.1 Hook: init_session.sh

**Event:** SessionStart

**Purpose:** Initialize session state (create/restore state files)

**Logic:**
1. Calculate PROJECT_HASH
2. Check for v3.0 migration (auto-migrate if old format detected)
3. Create session.json if doesn't exist
4. Create context.json if doesn't exist
5. Create tools.json if doesn't exist
6. Output session metadata

**Key feature:** Auto-migration from v3.0 → v3.3

---------------------------------------------------------------------------------------------------------------------------

### 4.2 Hook: reset_context.sh

**Event:** SessionStart (runs after init_session.sh)

**Purpose:** Handle compact flag - reset context AND session timer

**Logic:**
1. Check for `~/.claude/compact_flag`
2. If exists:
   - Reset session.json: `start_time = NOW`
   - Reset context.json: `token_count = 0`
   - Delete compact flag
3. If doesn't exist: exit (no action)

**User command:** "refresh context"

---------------------------------------------------------------------------------------------------------------------------

### 4.3 Hook: track_context.sh

**Event:** PostToolUse

**Purpose:** Track context usage - estimate tokens and update context state

**Logic:**
1. Estimate tokens from input length: `tokens = input_length / 4`
2. Read current token_count from context.json
3. Calculate new total: `new_tokens = current + estimated`
4. Update context.json

**Files modified:** context.json

---------------------------------------------------------------------------------------------------------------------------

### 4.4 Hook: track_time.sh

**Event:** PostToolUse

**Purpose:** Update session timer

**Logic:**
1. Get current timestamp: `NOW = date +%s`
2. Update session.json: `last_update = NOW`

**Files modified:** session.json

---------------------------------------------------------------------------------------------------------------------------

### 4.5 Hook: log_tool.sh

**Event:** PostToolUse

**Purpose:** Log tool usage and track tool count

**Logic:**
1. Log to audit file: `~/.claude/audit/tool_use.log`
   - Format: `TIMESTAMP | TOOL_NAME | PROJECT_PATH`
2. Update tools.json:
   - `tool_count++`
   - `last_tool = TOOL_NAME`
   - `last_tool_time = NOW`

**Files modified:** tools.json

---------------------------------------------------------------------------------------------------------------------------

### 4.6 Hook: validate_boundaries.sh

**Event:** PreToolUse (Edit/Write only)

**Purpose:** Validate file paths against CLAUDE.md boundaries

**Logic:**
1. Read CLAUDE.md (global + project)
2. Parse CAN modify section
3. Parse CANNOT modify section
4. Validate file path
5. Return: `decision: "approve"` or `"deny"`

**Files read:** CLAUDE.md (read-only, no state modification)

---------------------------------------------------------------------------------------------------------------------------

### 4.7 Hook: detect_loop.sh

**Event:** PostToolUse

**Purpose:** Detect infinite loops (same file 5+ edits, same error 3+ times)

**Logic:**
1. Track file edits (file path + count + time window)
2. Track error messages (normalized + count)
3. If same file ≥5 edits in 10min → Warn
4. If same error ≥3 times → Warn
5. Cleanup old state periodically

**State:** Internal (loop_state.json)

---------------------------------------------------------------------------------------------------------------------------

### 4.8 Hook: check_session_duration.sh

**Event:** Stop (between tool calls)

**Purpose:** Monitor session duration and warn if too long

**Logic:**
1. Read session.json: `start_time`
2. Calculate duration: `(NOW - start_time) / 60`
3. Warn if ≥120m (2h): ⚠️
4. Warn if ≥150m (2.5h): 🔴
5. Guard against epoch 0 corruption

**Files read:** session.json (read-only)

---------------------------------------------------------------------------------------------------------------------------

### 4.9 Hook: check_context_usage.sh

**Event:** Stop (between tool calls)

**Purpose:** Monitor context usage and warn if getting full

**Logic:**
1. Read context.json: `token_count`, `context_factor`
2. Calculate context %: `(token_count * context_factor) / USABLE_CONTEXT`
3. Warn if ≥70%: 🟡
4. Warn if ≥85%: 🔴

**Files read:** context.json (read-only)

---------------------------------------------------------------------------------------------------------------------------

### 4.10 Hook: finalize_session.sh

**Event:** SessionEnd (quit)

**Purpose:** Archive session state and mark finalized

**Logic:**
1. Read all 3 state files
2. Calculate duration: `end_time - start_time`
3. Merge into single archived JSON:
   ```json
   {
     ...session_data,
     ...context_data,
     ...tools_data,
     "end_time": NOW,
     "status": "finalized"
   }
   ```
4. Save to: `~/.claude/sessions/YYYYMMDD_HHMMSS.json`
5. Delete current state files

**Files modified:** All 3 (deleted after archival)

---------------------------------------------------------------------------------------------------------------------------

### 4.11 Status Bar: status_bar.sh

**Type:** Status line display (continuous, not a hook)

**Purpose:** Display status bar (read-only, pulls from all 3 state files)

**Logic:**
1. Read session.json: `model`, `start_time`
2. Read context.json: `token_count`, `context_factor`
3. Read tools.json: `last_tool`, `last_tool_time`
4. Calculate context %
5. Calculate session duration
6. Display: `Model · Context · Duration · Last Tool`

**Display format:**
```
Sonnet · 🟢 Context: ~45K · ✅ 🕐 28m · 🔧 Bash
```

**Files read:** All 3 (read-only)

---------------------------------------------------------------------------------------------------------------------------

## 5. Troubleshooting

### 5.1 Issue: Session Duration Shows Wrong Number

**Symptom:**
```
Status bar: 🕐 29478966m (huge number!)
```

**Root Cause:** Epoch 0 corruption in session.json: `start_time = 0`

**Fix:**
```bash
# Option A: Restart session
exit
cc  # Fresh session will reset

# Option B: Manual fix
jq '.start_time = '$(date +%s) ~/.claude/sessions/{HASH}_session.json > /tmp/fix.json
mv /tmp/fix.json ~/.claude/sessions/{HASH}_session.json
```

---------------------------------------------------------------------------------------------------------------------------

### 5.2 Issue: Context Doesn't Reset After Compact

**Symptom:**
```
Before: 🔴 Context: ~145K
After "refresh context" + exit + cc: 🔴 Context: ~145K (still!)
```

**Root Cause:** Compact flag not detected or context.json not reset

**Debug:**
```bash
# Check compact flag
ls -la ~/.claude/compact_flag
# If not found: Flag was deleted but compact didn't work

# Check context.json
jq '.token_count' ~/.claude/sessions/{HASH}_context.json
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

---------------------------------------------------------------------------------------------------------------------------

### 5.3 Issue: Hooks Not Running

**Symptom:**
```
No hook metadata on session start
No status bar updates
```

**Root Cause:** Hook scripts not executable or wrong paths in settings.json

**Debug:**
```bash
# Check hook scripts have execute permission
ls -la ~/Desktop/FILICITI/Governance/scripts/*.sh
# Should show: -rwxr-xr-x (execute bit set)

# Check settings.json paths
grep "FILICITI/Governance/scripts" ~/.claude/settings.json
# Should find all hook paths
```

**Fix:**
```bash
# Make all scripts executable
chmod +x ~/Desktop/FILICITI/Governance/scripts/*.sh

# Verify settings.json paths are correct
```

---------------------------------------------------------------------------------------------------------------------------

### 5.4 Issue: State File Isolation Not Working

**Symptom:**
```
Corrupt context.json → session timer also fails
```

**Root Cause:** Not using v3.3 (still on v3.0 with unified state file)

**Debug:**
```bash
# Check if using separated files
ls -la ~/.claude/sessions/{HASH}_*.json

# Should see:
# {HASH}_session.json
# {HASH}_context.json
# {HASH}_tools.json

# If you only see {HASH}_session.json → still on v3.0
```

**Fix:**
```bash
# Option A: Wait for auto-migration
# Next session start will detect v3.0 and auto-migrate

# Option B: Manual migration (not recommended)
# Better to let init_session.sh handle it
```

---------------------------------------------------------------------------------------------------------------------------

### 5.5 Manual Hook Testing

#### Test: SessionStart Hook

```bash
cd ~/Desktop/FILICITI/Governance
bash scripts/init_session.sh

# Check output
jq . ~/.claude/sessions/{HASH}_session.json
jq . ~/.claude/sessions/{HASH}_context.json
jq . ~/.claude/sessions/{HASH}_tools.json

# Expected: All 3 files created with correct schema
```

#### Test: Compact Flag

```bash
# Create flag
touch ~/.claude/compact_flag

# Run reset_context.sh
bash scripts/reset_context.sh

# Check
jq '.token_count' ~/.claude/sessions/{HASH}_context.json
# Expected: 0

jq '.start_time' ~/.claude/sessions/{HASH}_session.json
# Expected: current timestamp (recent)
```

---------------------------------------------------------------------------------------------------------------------------

### 5.6 Log File Locations

```
~/.claude/sessions/
├─ {PROJECT_HASH}_session.json      # Current session state
├─ {PROJECT_HASH}_context.json      # Current context state
├─ {PROJECT_HASH}_tools.json        # Current tools state
├─ 20260118_053000.json             # Archived sessions (finalized)
└─ migration.log                    # v3.0 → v3.3 migration log

~/.claude/
├─ compact_flag                     # Compact request flag (temp)
├─ loop_state.json                  # Loop detection state
└─ audit/
   └─ tool_use.log                  # All tool uses logged

~/Desktop/FILICITI/Governance/
├─ Conversations/
│  ├─ YYYYMMDD_HHMM_project_clean.log  # Cleaned session log (98% smaller, readable)
│  └─ YYYYMMDD_HHMM_project.log.xz     # Compressed raw log (backup)
└─ scripts/
   ├─ clean_log.py                 # Log cleaning script (ANSI-preserving)
   ├─ batch_clean_logs.py          # Batch processor for old logs
   ├─ init_session.sh              # SessionStart hook
   ├─ reset_context.sh             # Compact flag handler
   └─ ... (8 more hooks)
```

---------------------------------------------------------------------------------------------------------------------------

### 5.6 Session Logs

**Log Files Created:**

After each `cc` session, two files are created automatically:

1. **Clean log** (`*_clean.log`):
   - Human-readable, ANSI codes preserved
   - 98.4% smaller than raw (1.7MB → 0.03MB)
   - Contains: User inputs + Claude responses (duplicates removed)
   - Use this for: Reading conversations, debugging, reference

2. **Compressed raw log** (`*.log.xz`):
   - Original recording with all terminal redraws
   - Compressed with xz (90%+ compression)
   - Use this for: Full session replay if needed (decompress with `unxz`)

**Viewing Logs:**

```bash
# View clean log with colors preserved
less -R Conversations/20260118_1401_governance_clean.log

# Navigate:
# - Arrow keys or Page Up/Down to scroll
# - /search_term to search
# - n for next match, N for previous
# - q to quit

# Decompress and view raw log (if needed)
unxz Conversations/20260118_1401_governance.log.xz
less -R Conversations/20260118_1401_governance.log
```

**Batch Processing Old Logs:**

For existing unprocessed logs:
```bash
python3 scripts/batch_clean_logs.py
# Scans ~/Desktop/FILICITI and ~/Desktop/DataStoragePlan
# Shows summary by folder
# Asks for confirmation
# Shows progress bar during processing
```

**How It Works:**

- cc wrapper (`bin/cc`) records session with `script` command
- After session ends, `clean_log.py` runs automatically
- Raw log compressed with `xz -9`, original deleted
- Clean and compressed files kept

**Log Cleaning Rules:**

1. **User inputs**: Identified by `[48;2;55;55;55m[38;2;255;255;255m>` (background color)
2. **Claude outputs**: Identified by `⏺` marker (any color) until separator
3. **Duplicates**: Exact duplicates removed (keystroke captures, redraws)
4. **Separators**: Deduplicated (keeps structure)
5. **ANSI codes**: Preserved (colors/formatting intact)

---------------------------------------------------------------------------------------------------------------------------

*Template: ~/Desktop/FILICITI/Governance/templates/DOCUMENT_FORMAT-TEMPLATE.md | v3.3*
*Related: Gov_Design_v3.3.md, Architecture_v3.3.md*
