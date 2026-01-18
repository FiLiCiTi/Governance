#!/bin/bash
# scripts/reset_context.sh
# Hook: SessionStart (runs after init_session.sh)
# Purpose: Handle compact flag - reset context AND session timer
# v3.3.0: Single responsibility - compact flag handling only

# Determine per-project state file paths
CWD_PATH=$(pwd)
PROJECT_HASH=$(echo "$CWD_PATH" | tr '[:upper:]' '[:lower:]' | md5 -q 2>/dev/null || echo "$(basename "$CWD_PATH")")

SESSION_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_session.json"
CONTEXT_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_context.json"
COMPACT_FLAG="$HOME/.claude/compact_flag"

# Check if compact flag exists
if [[ ! -f "$COMPACT_FLAG" ]]; then
    # No compact requested, nothing to do
    exit 0
fi

# Check dependencies
if ! command -v jq &> /dev/null; then
    echo "⚠️  ERROR: jq not found. Cannot reset context." >&2
    rm "$COMPACT_FLAG"  # Clean up flag even if we can't process
    exit 0
fi

# Compact flag exists - reset context AND session timer
NOW=$(date +%s)

# Reset session timer (fresh start)
if [[ -f "$SESSION_FILE" ]]; then
    jq --argjson now "$NOW" '
        .start_time = $now |
        .last_update = $now
    ' "$SESSION_FILE" > "$SESSION_FILE.tmp" && mv "$SESSION_FILE.tmp" "$SESSION_FILE"
fi

# Reset context (zero out token count)
if [[ -f "$CONTEXT_FILE" ]]; then
    jq '
        .token_count = 0 |
        .last_calibration = 0
    ' "$CONTEXT_FILE" > "$CONTEXT_FILE.tmp" && mv "$CONTEXT_FILE.tmp" "$CONTEXT_FILE"
fi

# Delete compact flag (cleanup)
rm "$COMPACT_FLAG"

# Output confirmation
cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "✅ Context reset complete (compact flag processed)"
  }
}
EOF
