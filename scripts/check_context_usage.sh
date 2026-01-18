#!/bin/bash
# scripts/check_context_usage.sh
# Hook: Stop (between tool calls)
# Purpose: Monitor context usage and warn if getting full
# v3.3.0: Single responsibility - context usage checking only

# Check dependencies
if ! command -v jq &> /dev/null; then
    cat << EOF
{
  "decision": "approve",
  "systemMessage": "\033[36m[CONTEXT]\033[0m ▸▸▸ ⚠️ ERROR: jq not found. Cannot monitor context usage."
}
EOF
    exit 0
fi

# Determine per-project state file path
CWD_PATH=$(pwd)
PROJECT_HASH=$(echo "$CWD_PATH" | tr '[:upper:]' '[:lower:]' | md5 -q 2>/dev/null || echo "$(basename "$CWD_PATH")")
CONTEXT_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_context.json"

# Check if context file exists
if [[ ! -f "$CONTEXT_FILE" ]]; then
    # No context file, nothing to check
    cat << EOF
{
  "decision": "approve"
}
EOF
    exit 0
fi

# Thresholds
CONTEXT_WARN=70         # 70% context usage - warning
CONTEXT_CRITICAL=85     # 85% context usage - wrap up
USABLE_CONTEXT=155000   # 200K - 45K buffer

# Read context values
TOKEN_COUNT=$(jq -r '.token_count // 0' "$CONTEXT_FILE" 2>/dev/null)
CONTEXT_FACTOR=$(jq -r '.context_factor // 1.0' "$CONTEXT_FILE" 2>/dev/null)

# Calculate calibrated token count
if command -v bc &> /dev/null && [[ "$CONTEXT_FACTOR" != "1.0" ]]; then
    CALIBRATED_TOKENS=$(echo "$TOKEN_COUNT * $CONTEXT_FACTOR" | bc 2>/dev/null | cut -d. -f1)
else
    CALIBRATED_TOKENS=$TOKEN_COUNT
fi

# Calculate context percentage
if [[ $CALIBRATED_TOKENS -gt 0 ]]; then
    CONTEXT_PCT=$((CALIBRATED_TOKENS * 100 / USABLE_CONTEXT))
else
    CONTEXT_PCT=0
fi

# Check context thresholds
WARNING=""

if [[ $CONTEXT_PCT -ge $CONTEXT_CRITICAL ]]; then
    WARNING="🔴 CONTEXT ${CONTEXT_PCT}%: Start new session soon (run 'refresh context')."
elif [[ $CONTEXT_PCT -ge $CONTEXT_WARN ]]; then
    WARNING="🟡 Context ${CONTEXT_PCT}%: Monitor usage."
fi

# Output result
if [[ -n "$WARNING" ]]; then
    cat << EOF
{
  "decision": "approve",
  "systemMessage": "\033[36m[CONTEXT]\033[0m ▸▸▸ ${WARNING}"
}
EOF
else
    cat << EOF
{
  "decision": "approve"
}
EOF
fi
