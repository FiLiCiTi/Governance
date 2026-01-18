#!/bin/bash
# scripts/track_time.sh
# Hook: PostToolUse
# Purpose: Update session timer - track last activity
# v3.3.0: Single responsibility - time tracking only

# Check dependencies
if ! command -v jq &> /dev/null; then
    # Silent fail - tracking not critical
    echo '{"decision": "approve"}'
    exit 0
fi

# Read hook input
INPUT=$(cat)
if [[ -z "$INPUT" ]]; then
    echo '{"decision": "approve"}'
    exit 0
fi

# Determine per-project session file path
CWD_PATH=$(echo "$INPUT" | jq -r '.cwd // ""' 2>/dev/null)
if [[ -z "$CWD_PATH" || "$CWD_PATH" == "null" ]]; then
    CWD_PATH=$(pwd)
fi

PROJECT_HASH=$(echo "$CWD_PATH" | tr '[:upper:]' '[:lower:]' | md5 -q 2>/dev/null || echo "$(basename "$CWD_PATH")")
SESSION_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_session.json"

# Ensure session file exists
if [[ ! -f "$SESSION_FILE" ]]; then
    # Silent fail - let init_session.sh handle creation
    echo '{"decision": "approve"}'
    exit 0
fi

# Update last_update timestamp
NOW=$(date +%s)
jq --argjson now "$NOW" '
    .last_update = $now
' "$SESSION_FILE" > "$SESSION_FILE.tmp" && mv "$SESSION_FILE.tmp" "$SESSION_FILE"

# PostToolUse hooks must output JSON with decision
echo '{"decision": "approve"}'
