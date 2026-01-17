#!/bin/bash
# hooks/inject_context.sh
# Hook: SessionStart
# Purpose: Signal session start with basic metadata
# Claude will read CLAUDE.md files and format announcement per Rule #1
# v3.0.0: Removed CLAUDE.md parsing (Claude reads natively)

CWD=$(pwd)
PROJECT_RAW=$(basename "$CWD")
# Normalize project name to lowercase for consistency (matches cc script)
PROJECT=$(echo "$PROJECT_RAW" | tr '[:upper:]' '[:lower:]')
DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%I:%M %p')

# Determine per-project state file path
CWD_PATH=$(pwd)
# Normalize path to lowercase for consistent hashing (macOS case-insensitive)
PROJECT_HASH=$(echo "$CWD_PATH" | tr '[:upper:]' '[:lower:]' | md5 -q 2>/dev/null || echo "$(basename "$CWD_PATH")")
STATE_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_session.json"

# Initialize state file if it doesn't exist or is missing required fields
if [[ ! -f "$STATE_FILE" ]]; then
    # Create new state file with all required fields
    mkdir -p "$HOME/.claude/sessions"
    NOW=$(date +%s)
    cat > "$STATE_FILE" << EOF
{
  "start_time": $NOW,
  "last_warmup": $NOW,
  "last_update": $NOW,
  "last_calibration": 0,
  "project": "$CWD_PATH",
  "project_name": "$(basename "$CWD_PATH")",
  "token_count": 0,
  "tool_count": 0,
  "context_factor": 1.0,
  "duplicate_session": false,
  "status": "active"
}
EOF
else
    # Check if this is a stale session (file exists, > 10 sec old, status == "finalized")
    NOW=$(date +%s)
    FILE_MOD_TIME=$(stat -f%m "$STATE_FILE" 2>/dev/null || echo "0")
    FILE_AGE=$((NOW - FILE_MOD_TIME))
    SESSION_STATUS=$(jq -r '.status // "unknown"' "$STATE_FILE" 2>/dev/null)

    # If session is stale (10+ seconds old AND properly finalized), reset it for fresh session
    if [[ $FILE_AGE -ge 10 && "$SESSION_STATUS" == "finalized" ]]; then
        # Stale session detected - reset for fresh start
        cat > "$STATE_FILE" << EOF
{
  "start_time": $NOW,
  "last_warmup": $NOW,
  "last_update": $NOW,
  "last_calibration": 0,
  "project": "$CWD_PATH",
  "project_name": "$(basename "$CWD_PATH")",
  "token_count": 0,
  "tool_count": 0,
  "context_factor": 1.0,
  "duplicate_session": false,
  "status": "active"
}
EOF
    else
        # Session is either recent or corrupted - ensure all required fields exist
        jq --argjson now "$NOW" '
            .last_calibration //= 0 |
            .context_factor //= 1.0 |
            .last_warmup //= $now |
            .start_time //= $now |
            .token_count //= 0 |
            .tool_count //= 0 |
            .status //= "active"
        ' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    fi
fi

# Check for manual compact flag (Option D)
COMPACT_FLAG="$HOME/.claude/compact_flag"
if [[ -f "$COMPACT_FLAG" ]]; then
    # User ran /compact and created flag, reset token count AND start_time for fresh session
    if [[ -f "$STATE_FILE" ]]; then
        NOW=$(date +%s)
        jq --argjson now "$NOW" '.token_count = 0 | .start_time = $now | .last_warmup = $now' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    fi
    rm "$COMPACT_FLAG"
fi

# Check for warmup reset flag (touch ~/.claude/warmup_flag to reset timer)
WARMUP_FLAG="$HOME/.claude/warmup_flag"
if [[ -f "$WARMUP_FLAG" ]]; then
    # Reset warmup timer to now
    if [[ -f "$STATE_FILE" ]]; then
        NOW=$(date +%s)
        jq --argjson ts "$NOW" '.last_warmup = $ts' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    fi
    rm "$WARMUP_FLAG"
fi

# Count active hooks and check their health
SETTINGS="$HOME/.claude/settings.json"
HOOK_COUNT=0
HOOK_ERRORS=0
HOOK_STATUS_FILE="$HOME/.claude/hook_status"

if [[ -f "$SETTINGS" ]]; then
    # Get unique hook scripts
    HOOK_SCRIPTS=$(jq -r '.hooks | to_entries[] | .value[] | .hooks[]? | .command' "$SETTINGS" 2>/dev/null | sort -u)
    HOOK_COUNT=$(echo "$HOOK_SCRIPTS" | grep -c .)

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

    # Write hook status for suggest_model.sh to read
    echo "{\"count\": $HOOK_COUNT, \"errors\": $HOOK_ERRORS, \"failed\": \"$FAILED_HOOKS\"}" > "$HOOK_STATUS_FILE"
fi

# Determine hook display (v2.5.1: simplified, hooks moved to status bar)
# Only show errors if any exist
HOOK_DISPLAY=""
if [[ $HOOK_ERRORS -gt 0 ]]; then
    HOOK_DISPLAY=" · ⚠️ Hooks: $HOOK_COUNT ($HOOK_ERRORS errors)"
fi

# Plugin cost tracking (v2.5.1)
PLUGIN_DISPLAY=""
if [ -f "$SETTINGS" ]; then
    # Count ENABLED plugins from settings.json, not installed plugins
    TOTAL_PLUGINS=$(jq -r '.enabledPlugins | length' "$SETTINGS" 2>/dev/null)
    PLUGIN_DISPLAY=" · 🔌 Plugins: $TOTAL_PLUGINS"

    # Check for high-cost plugins among enabled ones
    if [ -f "$HOME/.claude/plugins/installed_plugins.json" ]; then
        ENABLED_NAMES=$(jq -r '.enabledPlugins[]' "$SETTINGS" 2>/dev/null)
        HIGH_COST_PLUGINS=0
        while IFS= read -r plugin; do
            if echo "$plugin" | grep -qE "output-style|ralph-wiggum"; then
                ((HIGH_COST_PLUGINS++))
            fi
        done <<< "$ENABLED_NAMES"

        if [ "$HIGH_COST_PLUGINS" -gt 0 ]; then
            # Prepend warning before the main output
            echo "⚠️  WARNING: $HIGH_COST_PLUGINS high-cost plugin(s) active (adds 1000+ tokens/session)" >&2
        fi
    fi
fi

# Output JSON with additionalContext (v3.0.0: minimal signal, Claude reads CLAUDE.md)
cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "📅 Date and Time: $DATE $TIME · 📁 Project: $PROJECT$HOOK_DISPLAY$PLUGIN_DISPLAY"
  }
}
EOF
