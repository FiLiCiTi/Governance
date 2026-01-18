# Architecture v3.3

> **Purpose:** Implementation details (how it works)
> **Version:** 3.3.0
> **Updated:** 2026-01-18

## Table of Contents

| Section | Title                                           | Line |
|---------|-------------------------------------------------|------|
| 1       | [State File Schemas](#1-state-file-schemas)     | :17  |
| 2       | [Hook Implementation](#2-hook-implementation)   | :121 |
| 3       | [Hook Flow](#3-hook-flow)                       | :268 |
| 4       | [Migration Implementation](#4-migration-implementation) | :334 |
| 5       | [Testing](#5-testing)                           | :419 |

---------------------------------------------------------------------------------------------------------------------------

## 1. State File Schemas

### 1.1 File Locations

```
~/.claude/sessions/
├─ {PROJECT_HASH}_session.json    # Session state
├─ {PROJECT_HASH}_context.json    # Context tracking
├─ {PROJECT_HASH}_tools.json      # Tool tracking
└─ 20260118_053000.json           # Archived sessions
```

**PROJECT_HASH calculation:**
```bash
PROJECT_HASH=$(echo -n "$CLAUDE_WORKING_DIR" | shasum -a 256 | cut -d' ' -f1 | head -c 16)
```

---------------------------------------------------------------------------------------------------------------------------

### 1.2 Schema: `{HASH}_session.json`

**Purpose:** Session timing and metadata

**Schema:**
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

**Field Definitions:**

| Field               | Type           | Purpose              | Set By                  | Required |
|---------------------|----------------|----------------------|-------------------------|----------|
| `start_time`        | Unix timestamp | Session start        | init_session.sh         | Yes      |
| `end_time`          | Unix timestamp | Session end          | finalize_session.sh     | No       |
| `last_update`       | Unix timestamp | Last activity        | track_time.sh           | Yes      |
| `status`            | String         | "active"/"finalized" | init/finalize           | Yes      |
| `project`           | String         | Absolute path        | init_session.sh         | Yes      |
| `project_name`      | String         | Basename of project  | init_session.sh         | Yes      |
| `log_file`          | String         | Relative log path    | init_session.sh         | Yes      |
| `model`             | String         | Current model name   | User instruction        | Yes      |
| `model_confirmed_at`| Unix timestamp | When model was set   | User instruction        | Yes      |

**Owned by:**
- `init_session.sh` (create/initialize)
- `track_time.sh` (update last_update)
- `finalize_session.sh` (set end_time, archive)

---------------------------------------------------------------------------------------------------------------------------

### 1.3 Schema: `{HASH}_context.json`

**Purpose:** Context tracking and calibration

**Schema:**
```json
{
  "token_count": 15818,
  "last_calibration": 0,
  "context_factor": 1.0
}
```

**Field Definitions:**

| Field              | Type           | Purpose                | Set By              | Required |
|--------------------|----------------|------------------------|---------------------|----------|
| `token_count`      | Integer        | Cumulative tokens      | track_context.sh    | Yes      |
| `last_calibration` | Unix timestamp | Last calibration       | User command        | Yes      |
| `context_factor`   | Float          | Calibration multiplier | User command        | Yes      |

**Owned by:**
- `track_context.sh` (update token_count)
- `reset_context.sh` (reset on compact)
- `check_context_usage.sh` (read for warnings)

---------------------------------------------------------------------------------------------------------------------------

### 1.4 Schema: `{HASH}_tools.json`

**Purpose:** Tool usage tracking

**Schema:**
```json
{
  "tool_count": 16,
  "last_tool": "Bash",
  "last_tool_time": 1768743841
}
```

**Field Definitions:**

| Field            | Type           | Purpose         | Set By        | Required |
|------------------|----------------|-----------------|---------------|----------|
| `tool_count`     | Integer        | Total tools     | log_tool.sh   | Yes      |
| `last_tool`      | String         | Last tool name  | log_tool.sh   | Yes      |
| `last_tool_time` | Unix timestamp | Last tool time  | log_tool.sh   | Yes      |

**Owned by:**
- `log_tool.sh` (update all fields)

---------------------------------------------------------------------------------------------------------------------------

## 2. Hook Implementation

### 2.1 Complete Hook List

| # | Hook Name                  | Event       | Purpose                  | State Files           |
|---|----------------------------|-------------|--------------------------|-----------------------|
| 1 | `init_session.sh`          | SessionStart| Initialize session       | session, context,     |
|   |                            |             |                          | tools                 |
| 2 | `reset_context.sh`         | SessionStart| Handle compact flag      | session, context      |
| 3 | `track_context.sh`         | PostToolUse | Update token count       | context               |
| 4 | `track_time.sh`            | PostToolUse | Update session timer     | session               |
| 5 | `log_tool.sh`              | PostToolUse | Log tool usage           | tools                 |
| 6 | `validate_boundaries.sh`   | PreToolUse  | Validate file paths      | (read-only)           |
| 7 | `detect_loop.sh`           | PostToolUse | Detect infinite loops    | (stateful internal)   |
| 8 | `check_session_duration.sh`| Stop        | Warn if session too long | session               |
| 9 | `check_context_usage.sh`   | Stop        | Warn if context too high | context               |
| 10| `finalize_session.sh`      | SessionEnd  | Archive session          | all 3                 |

**Additional (not hooks):**
- `status_bar.sh` - Status line display (reads all 3 state files)

---------------------------------------------------------------------------------------------------------------------------

### 2.2 Hook: `init_session.sh`

**Event:** SessionStart

**Purpose:** Initialize session state (create/restore state files)

**Logic:**
```bash
#!/bin/bash
# Calculate PROJECT_HASH
PROJECT_HASH=$(echo -n "$CLAUDE_WORKING_DIR" | shasum -a 256 | cut -d' ' -f1 | head -c 16)

SESSION_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_session.json"
CONTEXT_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_context.json"
TOOLS_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_tools.json"

# Check for v3.0 migration (see Section 4)
if [[ -f "$SESSION_FILE" ]] && jq -e '.token_count' "$SESSION_FILE" > /dev/null 2>&1; then
    # OLD FORMAT DETECTED - MIGRATE
    migrate_v30_to_v33
fi

# If state files don't exist, create them
if [[ ! -f "$SESSION_FILE" ]]; then
    NOW=$(date +%s)
    jq -n --argjson now "$NOW" --arg project "$CLAUDE_WORKING_DIR" \
          --arg project_name "$(basename "$CLAUDE_WORKING_DIR")" \
          --arg log_file "./Conversations/$(date +%Y%m%d_%H%M).log" \
          '{
            start_time: $now,
            end_time: null,
            last_update: $now,
            status: "active",
            project: $project,
            project_name: $project_name,
            log_file: $log_file,
            model: "sonnet",
            model_confirmed_at: $now
          }' > "$SESSION_FILE"
fi

# Create context.json if doesn't exist
if [[ ! -f "$CONTEXT_FILE" ]]; then
    jq -n '{token_count: 0, last_calibration: 0, context_factor: 1.0}' > "$CONTEXT_FILE"
fi

# Create tools.json if doesn't exist
if [[ ! -f "$TOOLS_FILE" ]]; then
    jq -n '{tool_count: 0, last_tool: "--", last_tool_time: 0}' > "$TOOLS_FILE"
fi

# Output session metadata
PROJECT_NAME=$(jq -r '.project_name' "$SESSION_FILE")
echo "📁 Project: $PROJECT_NAME"
```

---------------------------------------------------------------------------------------------------------------------------

### 2.3 Hook: `reset_context.sh`

**Event:** SessionStart (runs after init_session.sh)

**Purpose:** Handle compact flag - reset context AND session timer

**Logic:**
```bash
#!/bin/bash
COMPACT_FLAG="$HOME/.claude/compact_flag"

if [[ ! -f "$COMPACT_FLAG" ]]; then
    exit 0  # No compact requested
fi

# Calculate file paths
PROJECT_HASH=$(echo -n "$CLAUDE_WORKING_DIR" | shasum -a 256 | cut -d' ' -f1 | head -c 16)
SESSION_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_session.json"
CONTEXT_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_context.json"

NOW=$(date +%s)

# Reset session timer (fresh start)
jq --argjson now "$NOW" '.start_time = $now | .last_update = $now' "$SESSION_FILE" \
   > "$SESSION_FILE.tmp" && mv "$SESSION_FILE.tmp" "$SESSION_FILE"

# Reset context
jq '.token_count = 0 | .last_calibration = 0' "$CONTEXT_FILE" \
   > "$CONTEXT_FILE.tmp" && mv "$CONTEXT_FILE.tmp" "$CONTEXT_FILE"

# Delete flag
rm "$COMPACT_FLAG"

echo "🔄 Context and timer reset"
```

---------------------------------------------------------------------------------------------------------------------------

### 2.4 Hook: `track_context.sh`

**Event:** PostToolUse

**Purpose:** Track context usage - estimate tokens and update context state

**Logic:**
```bash
#!/bin/bash
# Estimate tokens from input length
INPUT_LENGTH=${#CLAUDE_INPUT}
ESTIMATED_TOKENS=$((INPUT_LENGTH / 4))

# Read current token count
PROJECT_HASH=$(echo -n "$CLAUDE_WORKING_DIR" | shasum -a 256 | cut -d' ' -f1 | head -c 16)
CONTEXT_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_context.json"

CURRENT_TOKENS=$(jq -r '.token_count' "$CONTEXT_FILE")
NEW_TOKENS=$((CURRENT_TOKENS + ESTIMATED_TOKENS))

# Update context file only
jq --argjson tokens "$NEW_TOKENS" '.token_count = $tokens' "$CONTEXT_FILE" \
   > "$CONTEXT_FILE.tmp" && mv "$CONTEXT_FILE.tmp" "$CONTEXT_FILE"
```

---------------------------------------------------------------------------------------------------------------------------

### 2.5 Hook: `status_bar.sh`

**Type:** Status line display (continuous, not a hook)

**Purpose:** Display status bar (read-only, pulls from all 3 state files)

**Logic:**
```bash
#!/bin/bash
PROJECT_HASH=$(echo -n "$CLAUDE_WORKING_DIR" | shasum -a 256 | cut -d' ' -f1 | head -c 16)

SESSION_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_session.json"
CONTEXT_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_context.json"
TOOLS_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_tools.json"

# Read from 3 separated state files
MODEL=$(jq -r '.model // "sonnet"' "$SESSION_FILE" | sed 's/\b\(.\)/\u\1/')  # Capitalize
START_TIME=$(jq -r '.start_time' "$SESSION_FILE")
TOKEN_COUNT=$(jq -r '.token_count' "$CONTEXT_FILE")
CONTEXT_FACTOR=$(jq -r '.context_factor' "$CONTEXT_FILE")
LAST_TOOL=$(jq -r '.last_tool' "$TOOLS_FILE")

# Calculate context display
USABLE_CONTEXT=200000
CALIBRATED_TOKENS=$((TOKEN_COUNT * CONTEXT_FACTOR))
CONTEXT_PCT=$((CALIBRATED_TOKENS * 100 / USABLE_CONTEXT))
CONTEXT_DISPLAY="~${CALIBRATED_TOKENS}K"

# Calculate session duration
NOW=$(date +%s)
SESSION_DURATION=$(( (NOW - START_TIME) / 60 ))

# Display format: Model · Context · Duration · Last Tool
echo "$MODEL · 🟢 Context: $CONTEXT_DISPLAY · ✅ 🕐 ${SESSION_DURATION}m · 🔧 $LAST_TOOL"
```

---------------------------------------------------------------------------------------------------------------------------

## 3. Hook Flow

### 3.1 Session Lifecycle

```
SESSION START
    ↓
1. init_session.sh (SessionStart)
    ├─ Calculate PROJECT_HASH
    ├─ Check for old v3.0 state (auto-migrate if found)
    ├─ Create/restore session.json, context.json, tools.json
    └─ Output session metadata
    ↓
2. reset_context.sh (SessionStart)
    ├─ Check for ~/.claude/compact_flag
    ├─ If exists: Reset session start_time + context token_count
    └─ Delete flag
    ↓
DURING SESSION (per tool use)
    ↓
3. validate_boundaries.sh (PreToolUse - Edit/Write only)
    ├─ Read CLAUDE.md boundaries
    ├─ Validate file path
    └─ Approve or deny
    ↓
[Tool executes]
    ↓
4. track_context.sh (PostToolUse)
    ├─ Estimate tokens from input length
    └─ Update context.json: token_count += estimated
    ↓
5. track_time.sh (PostToolUse)
    └─ Update session.json: last_update = NOW
    ↓
6. log_tool.sh (PostToolUse)
    ├─ Log to ~/.claude/audit/tool_use.log
    └─ Update tools.json: tool_count++, last_tool, last_tool_time
    ↓
7. detect_loop.sh (PostToolUse)
    ├─ Track file edits
    ├─ Track errors
    └─ Warn if loop detected
    ↓
[Between tool calls]
    ↓
8. check_session_duration.sh (Stop)
    ├─ Read session.json: start_time
    ├─ Calculate duration
    └─ Warn if ≥2h or ≥2.5h
    ↓
9. check_context_usage.sh (Stop)
    ├─ Read context.json: token_count, context_factor
    ├─ Calculate context %
    └─ Warn if ≥70% or ≥85%
    ↓
[Real-time]
    ↓
10. status_bar.sh (Status Line - continuous)
    ├─ Read session.json: model, start_time
    ├─ Read context.json: token_count, context_factor
    ├─ Read tools.json: last_tool, last_tool_time
    └─ Display: Model · Context · Duration · Last Tool
    ↓
SESSION END
    ↓
11. finalize_session.sh (SessionEnd)
    ├─ Read all state files
    ├─ Calculate duration
    ├─ Set status = "finalized"
    ├─ Archive to timestamped file
    └─ Delete current state files
```

---------------------------------------------------------------------------------------------------------------------------

## 4. Migration Implementation

### 4.1 Auto-Migration (v3.0 → v3.3)

**Trigger:** `init_session.sh` on first SessionStart

**Detection Logic:**
```bash
OLD_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_session.json"

# Check if old unified file exists
if [[ -f "$OLD_FILE" ]]; then
    # Check if it's v3.0 format (has token_count in session file)
    if jq -e '.token_count' "$OLD_FILE" > /dev/null 2>&1; then
        # OLD FORMAT DETECTED - MIGRATE
        migrate_v30_to_v33
    fi
fi
```

---------------------------------------------------------------------------------------------------------------------------

### 4.2 Migration Function

```bash
migrate_v30_to_v33() {
    OLD_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_session.json"

    # 1. Backup old file
    cp "$OLD_FILE" "$OLD_FILE.v3.0.backup"

    # 2. Split into 3 files

    # session.json (time + metadata + model)
    jq '{
      start_time, end_time, last_update, status,
      project, project_name, log_file,
      model: (.model // "sonnet"),
      model_confirmed_at: (.model_confirmed_at // .start_time)
    }' "$OLD_FILE" > "${HOME}/.claude/sessions/${PROJECT_HASH}_session.json"

    # context.json (token tracking + calibration)
    jq '{
      token_count, last_calibration, context_factor
    }' "$OLD_FILE" > "${HOME}/.claude/sessions/${PROJECT_HASH}_context.json"

    # tools.json (tool tracking)
    jq '{
      tool_count: (.tool_count // 0),
      last_tool: "--",
      last_tool_time: 0
    }' "$OLD_FILE" > "${HOME}/.claude/sessions/${PROJECT_HASH}_tools.json"

    # 3. Log migration
    echo "$(date -Iseconds) | Migration: v3.0 → v3.3 | $CLAUDE_WORKING_DIR" >> \
         "$HOME/.claude/sessions/migration.log"

    # 4. Delete old unified file
    rm "$OLD_FILE"

    echo "✅ Migrated v3.0 → v3.3 (backup: ${OLD_FILE}.v3.0.backup)"
}
```

---------------------------------------------------------------------------------------------------------------------------

### 4.3 Rollback Plan

If v3.3 has issues:
```bash
# Restore from backup
cd ~/.claude/sessions
mv {HASH}_session.json.v3.0.backup {HASH}_session.json
rm {HASH}_context.json {HASH}_tools.json

# Revert settings.json to v3.0 hooks
# (keep old hooks in scripts/deprecated/ for this purpose)
```

---------------------------------------------------------------------------------------------------------------------------

### 4.4 Fields Removed (v3.0 → v3.3)

**Removed fields:**
- `last_warmup` - DEPRECATED (warmup concept removed)
- `duplicate_session` - Unused
- `todo_total` - Should be in Claude Code's todo_state.json
- `todo_done` - Should be in Claude Code's todo_state.json

---------------------------------------------------------------------------------------------------------------------------

## 5. Testing

### 5.1 Test: Fresh Session Start

```bash
# 1. Delete existing state files
rm ~/.claude/sessions/{HASH}_*.json

# 2. Start new session
cc

# Expected:
# - 3 new state files created
# - status bar shows: Sonnet · 🟢 Context: ~0K · ✅ 🕐 0m · 🔧 --
```

---------------------------------------------------------------------------------------------------------------------------

### 5.2 Test: Migration from v3.0

```bash
# 1. Create old v3.0 state file
cat > ~/.claude/sessions/{HASH}_session.json <<EOF
{
  "start_time": 1768743045,
  "last_update": 1768743841,
  "status": "active",
  "token_count": 15818,
  "last_calibration": 0,
  "context_factor": 1.0,
  "tool_count": 16,
  "project": "/path/to/project",
  "project_name": "project",
  "log_file": "./Conversations/20260118.log"
}
EOF

# 2. Start session
cc

# Expected:
# - Migration message: "✅ Migrated v3.0 → v3.3"
# - 3 new state files created
# - Backup file created: {HASH}_session.json.v3.0.backup
# - Old unified file deleted
```

---------------------------------------------------------------------------------------------------------------------------

### 5.3 Test: Compact Flag Flow

```bash
# 1. User says "refresh context"
touch ~/.claude/compact_flag

# 2. Exit and restart session
exit
cc

# Expected:
# - reset_context.sh runs
# - session.json: start_time = NOW
# - context.json: token_count = 0
# - compact_flag deleted
# - Status bar shows: ~0K context, 0m duration
```

---------------------------------------------------------------------------------------------------------------------------

### 5.4 Test: Model Name Update

```bash
# User says "set model to Opus"
# Claude updates session.json:

jq '.model = "opus" | .model_confirmed_at = 1768743900' \
   ~/.claude/sessions/{HASH}_session.json

# Expected:
# - session.json updated
# - Status bar shows: Opus · ... (immediately)
```

---------------------------------------------------------------------------------------------------------------------------

### 5.5 Test: State File Isolation

```bash
# Corrupt context.json
echo '{"broken": "json"' > ~/.claude/sessions/{HASH}_context.json

# Start session
cc

# Expected:
# - Session timer still works (reads session.json)
# - Tool tracking still works (reads tools.json)
# - Only context display fails
# - No cascading failures
```

---------------------------------------------------------------------------------------------------------------------------

*Template: ~/Desktop/FILICITI/Governance/templates/DOCUMENT_FORMAT-TEMPLATE.md | v3.3*
