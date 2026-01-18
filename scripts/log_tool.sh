#!/bin/bash
# scripts/log_tool.sh
# Hook: PostToolUse
# Purpose: Log tool usage and track tool count
# v3.3.0: Single responsibility - pure logging + tool tracking only

# Check dependencies
if ! command -v jq &> /dev/null; then
    # Silent fail - logging not critical
    echo '{"decision": "approve"}'
    exit 0
fi

# Read hook input
INPUT=$(cat)
if [[ -z "$INPUT" ]]; then
    echo '{"decision": "approve"}'
    exit 0
fi

LOG_DIR="$HOME/.claude/audit"

# Determine per-project tools file path
CWD_PATH=$(echo "$INPUT" | jq -r '.cwd // ""' 2>/dev/null)
if [[ -z "$CWD_PATH" || "$CWD_PATH" == "null" ]]; then
    CWD_PATH=$(pwd)
fi

PROJECT_HASH=$(echo "$CWD_PATH" | tr '[:upper:]' '[:lower:]' | md5 -q 2>/dev/null || echo "$(basename "$CWD_PATH")")
TOOLS_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_tools.json"

# Ensure tools file exists
if [[ ! -f "$TOOLS_FILE" ]]; then
    mkdir -p "$HOME/.claude/sessions" 2>/dev/null
    cat > "$TOOLS_FILE" << EOF
{
  "tool_count": 0,
  "last_tool": "--",
  "last_tool_time": 0
}
EOF
fi

# Create log directory if needed
mkdir -p "$LOG_DIR" 2>/dev/null || {
    echo '{"decision": "approve"}'
    exit 0
}

# Extract tool information
TOOL=$(echo "$INPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null)
TIMESTAMP=$(date -Iseconds 2>/dev/null || date)
PROJECT=$(echo "$INPUT" | jq -r '.cwd // "unknown"' 2>/dev/null)
NOW=$(date +%s)

# Log tool use to audit log
echo "$TIMESTAMP | $TOOL | $PROJECT" >> "$LOG_DIR/tool_use.log"

# Update tools state file
CURRENT_COUNT=$(jq -r '.tool_count // 0' "$TOOLS_FILE" 2>/dev/null)
NEW_COUNT=$((CURRENT_COUNT + 1))

jq --argjson count "$NEW_COUNT" --arg tool "$TOOL" --argjson time "$NOW" '
    .tool_count = $count |
    .last_tool = $tool |
    .last_tool_time = $time
' "$TOOLS_FILE" > "$TOOLS_FILE.tmp" && mv "$TOOLS_FILE.tmp" "$TOOLS_FILE"

# Keep log file manageable (last 10000 lines)
if [[ -f "$LOG_DIR/tool_use.log" ]]; then
    tail -10000 "$LOG_DIR/tool_use.log" > "$LOG_DIR/tool_use.log.tmp" && \
        mv "$LOG_DIR/tool_use.log.tmp" "$LOG_DIR/tool_use.log"
fi

# PostToolUse hooks must output JSON with decision
echo '{"decision": "approve"}'
