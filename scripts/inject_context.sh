#!/bin/bash
# hooks/inject_context.sh
# Hook: SessionStart
# Purpose: Inject date, boundaries, and environment at session start
# Claude should announce these for user confirmation
# v2.5.1: Simplified output (centered dots, hooks only shown if errors)

CWD=$(pwd)
PROJECT=$(basename "$CWD")
DATE=$(date '+%Y-%m-%d')
CLAUDE_MD="$CWD/CLAUDE.md"

# Extract boundaries from CLAUDE.md
CAN_MODIFY=""
CANNOT_MODIFY=""
if [[ -f "$CLAUDE_MD" ]]; then
    CAN_MODIFY=$(grep -i "CAN modify:" "$CLAUDE_MD" | head -1 | sed 's/.*CAN modify://' | tr -d '`*' | xargs)
    CANNOT_MODIFY=$(grep -i "CANNOT modify:" "$CLAUDE_MD" | head -1 | sed 's/.*CANNOT modify://' | tr -d '`*' | xargs)
fi

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
  "duplicate_session": false
}
EOF
else
    # Ensure all required fields exist in existing state file
    NOW=$(date +%s)
    jq --argjson now "$NOW" '
        .last_calibration //= 0 |
        .context_factor //= 1.0 |
        .last_warmup //= $now |
        .start_time //= $now |
        .token_count //= 0 |
        .tool_count //= 0
    ' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
fi

# Check for manual compact flag (Option D)
COMPACT_FLAG="$HOME/.claude/compact_flag"
if [[ -f "$COMPACT_FLAG" ]]; then
    # User ran /compact and created flag, reset token count
    if [[ -f "$STATE_FILE" ]]; then
        jq '.token_count = 0' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
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

# Output JSON with additionalContext (v2.5.1: simplified with centered dots)
cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "📅 Date: $DATE · 📁 Project: $PROJECT · ✅ CAN: $CAN_MODIFY · 🚫 CANNOT: $CANNOT_MODIFY$HOOK_DISPLAY$PLUGIN_DISPLAY"
  }
}
EOF
