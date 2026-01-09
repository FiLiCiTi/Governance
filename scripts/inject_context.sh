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
if [ -f "$HOME/.claude/plugins/installed_plugins.json" ]; then
    HIGH_COST_PLUGINS=$(jq -r '.plugins[] | select(.name | test("output-style|ralph-wiggum")) | .name' "$HOME/.claude/plugins/installed_plugins.json" 2>/dev/null | wc -l | tr -d ' ')

    TOTAL_PLUGINS=$(jq -r '.plugins | length' "$HOME/.claude/plugins/installed_plugins.json" 2>/dev/null)
    PLUGIN_DISPLAY=" · 🔌 Plugins: $TOTAL_PLUGINS"

    if [ "$HIGH_COST_PLUGINS" -gt 0 ]; then
        # Prepend warning before the main output
        echo "⚠️  WARNING: $HIGH_COST_PLUGINS high-cost plugin(s) active (adds 1000+ tokens/session)" >&2
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
