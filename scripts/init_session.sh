#!/bin/bash
# scripts/init_session.sh
# Hook: SessionStart
# Purpose: Initialize session state (v3.3 - separated concerns)
# v3.3.0: Complete rewrite - single responsibility, auto-migration from v3.0

CWD=$(pwd)
PROJECT_RAW=$(basename "$CWD")
# Normalize project name to lowercase for consistency
PROJECT=$(echo "$PROJECT_RAW" | tr '[:upper:]' '[:lower:]')
DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%I:%M %p')
NOW=$(date +%s)

# Determine per-project state file paths
CWD_PATH=$(pwd)
# Normalize path to lowercase for consistent hashing (macOS case-insensitive)
PROJECT_HASH=$(echo "$CWD_PATH" | tr '[:upper:]' '[:lower:]' | md5 -q 2>/dev/null || echo "$(basename "$CWD_PATH")")

# v3.3 STATE FILES (separated by concern)
SESSION_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_session.json"
CONTEXT_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_context.json"
TOOLS_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_tools.json"

# Migration detection: old v3.0 unified file
OLD_UNIFIED_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_session.json"

# ============================================================
# MIGRATION: v3.0 → v3.3 (Auto-migrate if old format detected)
# ============================================================

migrate_v30_to_v33() {
    local old_file="$1"

    echo "🔄 Migrating v3.0 → v3.3 state files..." >&2

    # Backup old file
    cp "$old_file" "$old_file.v3.0.backup" 2>/dev/null

    # Extract session fields (time + metadata + model)
    jq --argjson now "$NOW" '{
        start_time: (.start_time // $now),
        end_time: (.end_time // null),
        last_update: (.last_update // $now),
        status: (.status // "active"),
        project: .project,
        project_name: .project_name,
        log_file: (.log_file // ""),
        model: (.model // "sonnet"),
        model_confirmed_at: (.model_confirmed_at // .start_time // $now)
    }' "$old_file" > "$SESSION_FILE" 2>/dev/null

    # Extract context fields (token tracking + calibration)
    jq '{
        token_count: (.token_count // 0),
        last_calibration: (.last_calibration // 0),
        context_factor: (.context_factor // 1.0)
    }' "$old_file" > "$CONTEXT_FILE" 2>/dev/null

    # Extract/create tools fields
    jq '{
        tool_count: (.tool_count // 0),
        last_tool: "--",
        last_tool_time: 0
    }' "$old_file" > "$TOOLS_FILE" 2>/dev/null

    # Log migration
    mkdir -p "$HOME/.claude/sessions" 2>/dev/null
    echo "$(date -Iseconds) | Migration: v3.0 → v3.3 | $CWD_PATH" >> \
         "$HOME/.claude/sessions/migration.log"

    # Delete old unified file (backup exists)
    rm "$old_file" 2>/dev/null

    echo "✅ Migration complete! (backup: ${old_file}.v3.0.backup)" >&2
}

# Check if migration needed
if [[ -f "$OLD_UNIFIED_FILE" ]] && [[ ! -f "$CONTEXT_FILE" ]]; then
    # Old unified file exists, but context file doesn't = needs migration
    # Additional check: ensure it's actually old format (has token_count in session file)
    if jq -e '.token_count' "$OLD_UNIFIED_FILE" > /dev/null 2>&1; then
        migrate_v30_to_v33 "$OLD_UNIFIED_FILE"
    fi
fi

# ============================================================
# INITIALIZATION: Create/restore session state
# ============================================================

# Create sessions directory
mkdir -p "$HOME/.claude/sessions" 2>/dev/null

# Function: Create fresh session state
create_fresh_session() {
    cat > "$SESSION_FILE" << EOF
{
  "start_time": $NOW,
  "end_time": null,
  "last_update": $NOW,
  "status": "active",
  "project": "$CWD_PATH",
  "project_name": "$(basename "$CWD_PATH")",
  "log_file": "",
  "model": "sonnet",
  "model_confirmed_at": $NOW
}
EOF

    cat > "$CONTEXT_FILE" << EOF
{
  "token_count": 0,
  "last_calibration": 0,
  "context_factor": 1.0
}
EOF

    cat > "$TOOLS_FILE" << EOF
{
  "tool_count": 0,
  "last_tool": "--",
  "last_tool_time": 0
}
EOF
}

# Initialize or restore session state
if [[ ! -f "$SESSION_FILE" ]]; then
    # CASE A: No session file = brand new session
    create_fresh_session
elif [[ ! -f "$CONTEXT_FILE" ]] || [[ ! -f "$TOOLS_FILE" ]]; then
    # CASE B: Session file exists but missing context/tools = corrupted, recreate
    create_fresh_session
else
    # CASE C: All files exist - check if stale session
    FILE_MOD_TIME=$(stat -f%m "$SESSION_FILE" 2>/dev/null || echo "0")
    FILE_AGE=$((NOW - FILE_MOD_TIME))
    SESSION_STATUS=$(jq -r '.status // "unknown"' "$SESSION_FILE" 2>/dev/null)

    # If session is stale (10+ seconds old AND properly finalized), reset for fresh session
    if [[ $FILE_AGE -ge 10 && "$SESSION_STATUS" == "finalized" ]]; then
        # Stale session detected - reset for fresh start
        create_fresh_session
    else
        # Active/recent session - ensure all required fields exist
        jq --argjson now "$NOW" '
            .last_update //= $now |
            .start_time //= $now |
            .status //= "active" |
            .model //= "sonnet" |
            .model_confirmed_at //= $now |
            .log_file //= "" |
            .end_time //= null
        ' "$SESSION_FILE" > "$SESSION_FILE.tmp" && mv "$SESSION_FILE.tmp" "$SESSION_FILE"

        jq '
            .token_count //= 0 |
            .last_calibration //= 0 |
            .context_factor //= 1.0
        ' "$CONTEXT_FILE" > "$CONTEXT_FILE.tmp" && mv "$CONTEXT_FILE.tmp" "$CONTEXT_FILE"

        jq '
            .tool_count //= 0 |
            .last_tool //= "--" |
            .last_tool_time //= 0
        ' "$TOOLS_FILE" > "$TOOLS_FILE.tmp" && mv "$TOOLS_FILE.tmp" "$TOOLS_FILE"
    fi
fi

# ============================================================
# HOOK HEALTH CHECK
# ============================================================

# Count active hooks and check their health
SETTINGS="$HOME/.claude/settings.json"
HOOK_COUNT=0
HOOK_ERRORS=0
HOOK_STATUS_FILE="$HOME/.claude/hook_status"

if [[ -f "$SETTINGS" ]]; then
    # Get unique hook scripts
    HOOK_SCRIPTS=$(jq -r '.hooks | to_entries[] | .value[] | .hooks[]? | .command' "$SETTINGS" 2>/dev/null | sort -u)
    HOOK_COUNT=$(echo "$HOOK_SCRIPTS" | grep -c . || echo "0")

    # Check each hook for execute permission
    FAILED_HOOKS=""
    while IFS= read -r script; do
        [[ -z "$script" ]] && continue
        if [[ -f "$script" ]] && [[ ! -x "$script" ]]; then
            ((HOOK_ERRORS++))
            FAILED_HOOKS="${FAILED_HOOKS}${script##*/} "
        elif [[ ! -f "$script" ]]; then
            ((HOOK_ERRORS++))
            FAILED_HOOKS="${FAILED_HOOKS}${script##*/}(missing) "
        fi
    done <<< "$HOOK_SCRIPTS"

    # Write hook status for status_bar.sh to read
    echo "{\"count\": $HOOK_COUNT, \"errors\": $HOOK_ERRORS, \"failed\": \"$FAILED_HOOKS\"}" > "$HOOK_STATUS_FILE"
fi

# ============================================================
# PLUGIN TRACKING
# ============================================================

PLUGIN_DISPLAY=""
if [[ -f "$SETTINGS" ]]; then
    # Count ENABLED plugins from settings.json
    TOTAL_PLUGINS=$(jq -r '.enabledPlugins | length' "$SETTINGS" 2>/dev/null || echo "0")
    PLUGIN_DISPLAY=" · 🔌 Plugins: $TOTAL_PLUGINS"

    # Check for high-cost plugins among enabled ones
    if [[ -f "$HOME/.claude/plugins/installed_plugins.json" ]]; then
        ENABLED_NAMES=$(jq -r '.enabledPlugins | keys[]' "$SETTINGS" 2>/dev/null)
        HIGH_COST_PLUGINS=0
        while IFS= read -r plugin; do
            if echo "$plugin" | grep -qE "output-style|ralph-wiggum"; then
                ((HIGH_COST_PLUGINS++))
            fi
        done <<< "$ENABLED_NAMES"

        if [[ "$HIGH_COST_PLUGINS" -gt 0 ]]; then
            echo "⚠️  WARNING: $HIGH_COST_PLUGINS high-cost plugin(s) active (adds 1000+ tokens/session)" >&2
        fi
    fi
fi

# ============================================================
# OUTPUT: Session metadata for Claude announcement
# ============================================================

# Hook display (only show errors if any exist)
HOOK_DISPLAY=""
if [[ $HOOK_ERRORS -gt 0 ]]; then
    HOOK_DISPLAY=" · ⚠️ Hooks: $HOOK_COUNT ($HOOK_ERRORS errors)"
fi

# Output JSON with additionalContext
cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "📅 Date and Time: $DATE $TIME · 📁 Project: $PROJECT$HOOK_DISPLAY$PLUGIN_DISPLAY"
  }
}
EOF
