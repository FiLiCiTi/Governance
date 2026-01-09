#!/bin/bash
# hooks/detect_loop.sh
# Hook: PostToolUse (additional)
# Purpose: Detect stuck loops - same error, same file, glitch cycles
# Injects warning when loop detected

# Check dependencies
if ! command -v jq &> /dev/null; then
    # Silent fail - loop detection not critical
    echo '{"decision": "approve"}'
    exit 0
fi

INPUT=$(cat)
if [[ -z "$INPUT" ]]; then
    echo '{"decision": "approve"}'
    exit 0
fi

STATE_FILE="$HOME/.claude/loop_state.json"
GOVERNANCE_SESSION="$HOME/.claude/governance_session.json"

# Thresholds
ERROR_THRESHOLD=3      # Same error 3+ times = warning
FILE_EDIT_THRESHOLD=5  # Same file edited 5+ times in 10 min = warning
TIME_WINDOW=600        # 10 minutes in seconds

# Extract info from input
TOOL=$(echo "$INPUT" | jq -r '.tool_name // ""')
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')
ERROR=$(echo "$INPUT" | jq -r '.tool_result.error // ""')
NOW=$(date +%s)

# Initialize state if not exists
if [[ ! -f "$STATE_FILE" ]]; then
    cat > "$STATE_FILE" << 'EOF'
{
  "file_edits": {},
  "error_counts": {},
  "last_cleanup": 0
}
EOF
fi

# Read current state
STATE=$(cat "$STATE_FILE")

# Cleanup old entries (older than TIME_WINDOW)
LAST_CLEANUP=$(echo "$STATE" | jq -r '.last_cleanup // 0')
if [[ $((NOW - LAST_CLEANUP)) -ge $TIME_WINDOW ]]; then
    # Reset counters periodically
    STATE=$(echo "$STATE" | jq --argjson now "$NOW" '
        .file_edits = {} |
        .error_counts = {} |
        .last_cleanup = $now
    ')
fi

WARNINGS=""

# Track file edits for Edit/Write tools
if [[ "$TOOL" == "Edit" || "$TOOL" == "Write" ]] && [[ -n "$FILE" ]]; then
    # Get current count for this file
    CURRENT_COUNT=$(echo "$STATE" | jq -r --arg file "$FILE" '.file_edits[$file].count // 0')
    FIRST_EDIT=$(echo "$STATE" | jq -r --arg file "$FILE" '.file_edits[$file].first_edit // 0')

    # Check if within time window
    if [[ "$FIRST_EDIT" -eq 0 ]] || [[ $((NOW - FIRST_EDIT)) -ge $TIME_WINDOW ]]; then
        # Reset counter for this file
        CURRENT_COUNT=1
        FIRST_EDIT=$NOW
    else
        CURRENT_COUNT=$((CURRENT_COUNT + 1))
    fi

    # Update state
    STATE=$(echo "$STATE" | jq --arg file "$FILE" --argjson count "$CURRENT_COUNT" --argjson first "$FIRST_EDIT" '
        .file_edits[$file] = {"count": $count, "first_edit": $first}
    ')

    # Check threshold
    if [[ $CURRENT_COUNT -ge $FILE_EDIT_THRESHOLD ]]; then
        WARNINGS="${WARNINGS}LOOP: File '$FILE' edited $CURRENT_COUNT times in 10min. "
    fi
fi

# Track errors
if [[ -n "$ERROR" && "$ERROR" != "null" ]]; then
    # Normalize error (first 100 chars)
    ERROR_KEY=$(echo "$ERROR" | head -c 100 | tr -d '\n' | tr -d '"')

    # Get current count for this error
    ERROR_COUNT=$(echo "$STATE" | jq -r --arg err "$ERROR_KEY" '.error_counts[$err] // 0')
    ERROR_COUNT=$((ERROR_COUNT + 1))

    # Update state
    STATE=$(echo "$STATE" | jq --arg err "$ERROR_KEY" --argjson count "$ERROR_COUNT" '
        .error_counts[$err] = $count
    ')

    # Check threshold
    if [[ $ERROR_COUNT -ge $ERROR_THRESHOLD ]]; then
        WARNINGS="${WARNINGS}LOOP: Same error $ERROR_COUNT times. "
    fi
fi

# Save state
echo "$STATE" > "$STATE_FILE"

# Output warning if detected
if [[ -n "$WARNINGS" ]]; then
    cat << EOF
{
  "decision": "approve",
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "\033[36m[LOOP]\033[0m ▸▸▸ $WARNINGS STOP and ask user for direction."
  }
}
EOF
else
    # No loop detected
    echo '{"decision": "approve"}'
fi
