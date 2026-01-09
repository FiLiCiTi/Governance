#!/bin/bash
# hooks/check_warmup.sh
# Hook: Stop
# Purpose: Monitor session health - warmup, duration, context
# v2 Enhanced: Added session duration + context monitoring

# Check dependencies
if ! command -v jq &> /dev/null; then
    cat << EOF
{
  "decision": "approve",
  "systemMessage": "\033[36m[WARMUP]\033[0m ▸▸▸ ⚠️ ERROR: jq not found. Cannot monitor session health."
}
EOF
    exit 0
fi

# Determine per-project state file path
CWD_PATH=$(pwd)
# Normalize path to lowercase for consistent hashing (macOS case-insensitive)
PROJECT_HASH=$(echo "$CWD_PATH" | tr '[:upper:]' '[:lower:]' | md5 -q 2>/dev/null || echo "$(basename "$CWD_PATH")")
STATE_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_session.json"

# Thresholds
WARMUP_INTERVAL=5400      # 90 minutes - warmup reminder
SESSION_WARN=14400        # 4 hours - quality warning
SESSION_CRITICAL=28800    # 8 hours - strong warning
CONTEXT_WARN=70           # 70% context usage - warning
CONTEXT_CRITICAL=85       # 85% context usage - wrap up

WARNINGS=""

if [[ -f "$STATE_FILE" ]]; then
    NOW=$(date +%s)

    # Read state values
    START_TIME=$(jq -r '.start_time // 0' "$STATE_FILE" 2>/dev/null)
    LAST_WARMUP=$(jq -r '.last_warmup // 0' "$STATE_FILE" 2>/dev/null)
    TOKEN_COUNT=$(jq -r '.token_count // 0' "$STATE_FILE" 2>/dev/null)

    # Calculate durations
    SESSION_DURATION=$((NOW - START_TIME))
    WARMUP_ELAPSED=$((NOW - LAST_WARMUP))

    # Convert to human readable
    SESSION_HOURS=$((SESSION_DURATION / 3600))
    SESSION_MINS=$(((SESSION_DURATION % 3600) / 60))
    WARMUP_MINS=$((WARMUP_ELAPSED / 60))

    # Estimate context % (200K tokens = 100%)
    if [[ $TOKEN_COUNT -gt 0 ]]; then
        CONTEXT_PCT=$((TOKEN_COUNT * 100 / 200000))
    else
        CONTEXT_PCT=0
    fi

    # Check 1: Warmup due (90 min)
    if [[ $WARMUP_ELAPSED -ge $WARMUP_INTERVAL ]]; then
        WARNINGS="${WARNINGS}⏰ Warm-up due: ${WARMUP_MINS}m since last (90m threshold). "
    fi

    # Check 2: Session duration warnings
    if [[ $SESSION_DURATION -ge $SESSION_CRITICAL ]]; then
        WARNINGS="${WARNINGS}🔴 LONG SESSION: ${SESSION_HOURS}h ${SESSION_MINS}m. Quality may decline. Consider wrap-up. "
    elif [[ $SESSION_DURATION -ge $SESSION_WARN ]]; then
        WARNINGS="${WARNINGS}🟡 Session: ${SESSION_HOURS}h ${SESSION_MINS}m. Consider break or wrap-up soon. "
    fi

    # Check 3: Context usage warnings
    if [[ $CONTEXT_PCT -ge $CONTEXT_CRITICAL ]]; then
        WARNINGS="${WARNINGS}🔴 CONTEXT ${CONTEXT_PCT}%: Start new session soon. "
    elif [[ $CONTEXT_PCT -ge $CONTEXT_WARN ]]; then
        WARNINGS="${WARNINGS}🟡 Context ${CONTEXT_PCT}%: Monitor usage. "
    fi

    # Output result
    if [[ -n "$WARNINGS" ]]; then
        cat << EOF
{
  "decision": "approve",
  "systemMessage": "\033[36m[WARMUP]\033[0m ▸▸▸ ${WARNINGS}"
}
EOF
        exit 0
    fi
fi

# All checks passed - no warnings
cat << EOF
{
  "decision": "approve"
}
EOF
