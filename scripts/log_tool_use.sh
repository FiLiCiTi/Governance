#!/bin/bash
# hooks/log_tool_use.sh
# Hook: PostToolUse
# Purpose: Log tool usage + track tokens + todo state for model suggestions
# v2 Enhanced: Added token estimation + todo tracking

# Check dependencies
if ! command -v jq &> /dev/null; then
    # Silent fail - logging not critical, don't interrupt workflow
    echo '{"decision": "approve"}'
    exit 0
fi

INPUT=$(cat)
if [[ -z "$INPUT" ]]; then
    echo '{"decision": "approve"}'
    exit 0  # No input, nothing to log
fi

LOG_DIR="$HOME/.claude/audit"

# Determine per-project state file paths
CWD_PATH=$(echo "$INPUT" | jq -r '.cwd // ""' 2>/dev/null)
if [[ -z "$CWD_PATH" || "$CWD_PATH" == "null" ]]; then
    CWD_PATH=$(pwd)
fi
# Normalize path to lowercase for consistent hashing (macOS case-insensitive)
PROJECT_HASH=$(echo "$CWD_PATH" | tr '[:upper:]' '[:lower:]' | md5 -q 2>/dev/null || echo "$(basename "$CWD_PATH")")
STATE_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_session.json"
TODO_STATE="$HOME/.claude/sessions/${PROJECT_HASH}_todo.json"

# Try to create log directory
if ! mkdir -p "$LOG_DIR" 2>/dev/null; then
    # Can't create log dir, fail silently
    exit 0
fi

TOOL=$(echo "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null)
TIMESTAMP=$(date -Iseconds 2>/dev/null || date)
PROJECT=$(echo "$INPUT" | jq -r '.cwd // "unknown"' 2>/dev/null)

# Log tool use
echo "$TIMESTAMP | $TOOL | $PROJECT" >> "$LOG_DIR/tool_use.log"

# Track last tool for status line display
echo "$TOOL" > "$HOME/.claude/last_tool_name"
date +%s > "$HOME/.claude/last_tool_time"

# Estimate tokens from this interaction (~4 chars per token)
INPUT_LENGTH=${#INPUT}
ESTIMATED_TOKENS=$((INPUT_LENGTH / 4))

# Update token count, tool count, and timestamp in state file
if [[ -f "$STATE_FILE" ]]; then
    CURRENT_TOKENS=$(jq -r '.token_count // 0' "$STATE_FILE" 2>/dev/null)
    CURRENT_TOOLS=$(jq -r '.tool_count // 0' "$STATE_FILE" 2>/dev/null)
    NEW_TOKENS=$((CURRENT_TOKENS + ESTIMATED_TOKENS))
    NEW_TOOLS=$((CURRENT_TOOLS + 1))

    # Safety cap: Reset if exceeds 200K (likely accumulated from previous session)
    # Actual sessions get summarized/compacted before reaching 200K
    if [[ $NEW_TOKENS -gt 200000 ]]; then
        # Reset to estimated current interaction only
        NEW_TOKENS=$ESTIMATED_TOKENS
    fi

    # Update state file with new counts AND last_update timestamp
    NOW=$(date +%s)
    jq --argjson tokens "$NEW_TOKENS" --argjson tools "$NEW_TOOLS" --argjson updated "$NOW" \
       '.token_count = $tokens | .tool_count = $tools | .last_update = $updated' \
       "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
fi

# Track TodoWrite for model suggestions
if [[ "$TOOL" == "TodoWrite" ]]; then
    # Extract todos from tool input and save state with project tracking
    TODOS=$(echo "$INPUT" | jq -r '.tool_input // {}')
    if [[ -n "$TODOS" && "$TODOS" != "{}" ]]; then
        # Add project and timestamp metadata (Option C: project filtering)
        SAVED_AT=$(date +%s)
        echo "$TODOS" | jq --arg proj "$PROJECT" --argjson ts "$SAVED_AT" '. + {project: $proj, saved_at: $ts}' > "$TODO_STATE"

        # Update todo counts in session state
        if [[ -f "$STATE_FILE" ]]; then
            TOTAL=$(echo "$TODOS" | jq -r '.todos | length' 2>/dev/null || echo "0")
            DONE=$(echo "$TODOS" | jq -r '[.todos[] | select(.status == "completed")] | length' 2>/dev/null || echo "0")
            jq --argjson total "$TOTAL" --argjson done "$DONE" '.todo_total = $total | .todo_done = $done' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
        fi
    fi
fi

# Keep log file manageable (last 10000 lines)
if [[ -f "$LOG_DIR/tool_use.log" ]]; then
    tail -10000 "$LOG_DIR/tool_use.log" > "$LOG_DIR/tool_use.log.tmp" && mv "$LOG_DIR/tool_use.log.tmp" "$LOG_DIR/tool_use.log"
fi

# PostToolUse hooks must output JSON with decision
echo '{"decision": "approve"}'
