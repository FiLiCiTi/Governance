#!/bin/bash
# scripts/track_context.sh
# Hook: PostToolUse
# Purpose: Track context usage - estimate tokens and update context state
# v3.3.0: Single responsibility - token tracking only

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

# Determine per-project context file path
CWD_PATH=$(echo "$INPUT" | jq -r '.cwd // ""' 2>/dev/null)
if [[ -z "$CWD_PATH" || "$CWD_PATH" == "null" ]]; then
    CWD_PATH=$(pwd)
fi

PROJECT_HASH=$(echo "$CWD_PATH" | tr '[:upper:]' '[:lower:]' | md5 -q 2>/dev/null || echo "$(basename "$CWD_PATH")")
CONTEXT_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_context.json"

# Ensure context file exists
if [[ ! -f "$CONTEXT_FILE" ]]; then
    # Create minimal context file
    mkdir -p "$HOME/.claude/sessions" 2>/dev/null
    cat > "$CONTEXT_FILE" << EOF
{
  "token_count": 0,
  "last_calibration": 0,
  "context_factor": 1.0
}
EOF
fi

# Estimate tokens from this interaction (~4 chars per token)
INPUT_LENGTH=${#INPUT}
ESTIMATED_TOKENS=$((INPUT_LENGTH / 4))

# Update token count in context file
CURRENT_TOKENS=$(jq -r '.token_count // 0' "$CONTEXT_FILE" 2>/dev/null)
NEW_TOKENS=$((CURRENT_TOKENS + ESTIMATED_TOKENS))

# Safety cap: Reset if exceeds 200K (likely accumulated from previous session)
# Actual sessions get summarized/compacted before reaching 200K
if [[ $NEW_TOKENS -gt 200000 ]]; then
    # Reset to estimated current interaction only
    NEW_TOKENS=$ESTIMATED_TOKENS
fi

# Update context file
jq --argjson tokens "$NEW_TOKENS" '
    .token_count = $tokens
' "$CONTEXT_FILE" > "$CONTEXT_FILE.tmp" && mv "$CONTEXT_FILE.tmp" "$CONTEXT_FILE"

# PostToolUse hooks must output JSON with decision
echo '{"decision": "approve"}'
