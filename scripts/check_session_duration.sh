#!/bin/bash
# scripts/check_session_duration.sh
# Hook: Stop (between tool calls)
# Purpose: Monitor session duration and warn if too long
# v3.3.0: Single responsibility - session duration checking only

# Check dependencies
if ! command -v jq &> /dev/null; then
    cat << EOF
{
  "decision": "approve",
  "systemMessage": "\033[36m[SESSION]\033[0m ▸▸▸ ⚠️ ERROR: jq not found. Cannot monitor session duration."
}
EOF
    exit 0
fi

# Determine per-project state file path
CWD_PATH=$(pwd)
PROJECT_HASH=$(echo "$CWD_PATH" | tr '[:upper:]' '[:lower:]' | md5 -q 2>/dev/null || echo "$(basename "$CWD_PATH")")
SESSION_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_session.json"

# Check if session file exists
if [[ ! -f "$SESSION_FILE" ]]; then
    # No session file, nothing to check
    cat << EOF
{
  "decision": "approve"
}
EOF
    exit 0
fi

# Thresholds
SESSION_WARN=7200        # 2 hours - quality warning
SESSION_CRITICAL=9000    # 2.5 hours - strong warning

NOW=$(date +%s)

# Read start time
START_TIME=$(jq -r '.start_time // 0' "$SESSION_FILE" 2>/dev/null)

# Guard against epoch 0 corruption
if [[ "$START_TIME" == "0" || "$START_TIME" == "null" ]]; then
    # Corrupted state - reset start_time
    jq --argjson now "$NOW" '.start_time = $now' "$SESSION_FILE" > "$SESSION_FILE.tmp" && \
        mv "$SESSION_FILE.tmp" "$SESSION_FILE"

    # No warning needed, just fixed
    cat << EOF
{
  "decision": "approve"
}
EOF
    exit 0
fi

# Calculate session duration
SESSION_DURATION=$((NOW - START_TIME))
SESSION_HOURS=$((SESSION_DURATION / 3600))
SESSION_MINS=$(((SESSION_DURATION % 3600) / 60))

# Check duration thresholds
WARNING=""

if [[ $SESSION_DURATION -ge $SESSION_CRITICAL ]]; then
    WARNING="🔴 LONG SESSION: ${SESSION_HOURS}h ${SESSION_MINS}m. Quality may decline. Consider wrap-up."
elif [[ $SESSION_DURATION -ge $SESSION_WARN ]]; then
    WARNING="🟡 Session: ${SESSION_HOURS}h ${SESSION_MINS}m. Consider break or wrap-up soon."
fi

# Output result
if [[ -n "$WARNING" ]]; then
    cat << EOF
{
  "decision": "approve",
  "systemMessage": "\033[36m[SESSION]\033[0m ▸▸▸ ${WARNING}"
}
EOF
else
    cat << EOF
{
  "decision": "approve"
}
EOF
fi
