#!/bin/bash
# scripts/finalize_session.sh
# Hook: SessionEnd (quit)
# Purpose: Archive session state and mark finalized
# v3.3.0: Single responsibility - session finalization only

# Determine per-project state file paths
CWD_PATH=$(pwd)
PROJECT_HASH=$(echo "$CWD_PATH" | tr '[:upper:]' '[:lower:]' | md5 -q 2>/dev/null || echo "$(basename "$CWD_PATH")")

SESSION_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_session.json"
CONTEXT_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_context.json"
TOOLS_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_tools.json"
ARCHIVE_DIR="$HOME/.claude/sessions"

# Check if state files exist
if [[ ! -f "$SESSION_FILE" ]]; then
    exit 0  # No state to save
fi

# Create archive directory
mkdir -p "$ARCHIVE_DIR" 2>/dev/null || exit 0

# Archive filename with timestamp
ARCHIVE_FILE="$ARCHIVE_DIR/$(date +%Y%m%d_%H%M%S).json"

# Check if jq is available
if command -v jq &> /dev/null; then
    # Calculate session metadata
    END_TIME=$(date +%s)
    START_TIME=$(jq -r '.start_time // 0' "$SESSION_FILE" 2>/dev/null)
    DURATION=$((END_TIME - START_TIME))

    # Read all state files and merge into archive
    SESSION_DATA=$(cat "$SESSION_FILE" 2>/dev/null || echo "{}")
    CONTEXT_DATA=$(cat "$CONTEXT_FILE" 2>/dev/null || echo "{}")
    TOOLS_DATA=$(cat "$TOOLS_FILE" 2>/dev/null || echo "{}")

    # Merge all data into single archive file
    jq -n \
        --argjson session "$SESSION_DATA" \
        --argjson context "$CONTEXT_DATA" \
        --argjson tools "$TOOLS_DATA" \
        --argjson end "$END_TIME" \
        --argjson dur "$DURATION" \
        '$session + $context + $tools + {
            end_time: $end,
            status: "finalized",
            duration_seconds: $dur
        }' > "$ARCHIVE_FILE" 2>/dev/null || {
        # jq failed, just copy session file
        cp "$SESSION_FILE" "$ARCHIVE_FILE" 2>/dev/null || exit 0
    }
else
    # No jq, just copy session file
    cp "$SESSION_FILE" "$ARCHIVE_FILE" 2>/dev/null || exit 0
fi

# Remove current state files (session is finalized)
rm "$SESSION_FILE" 2>/dev/null
rm "$CONTEXT_FILE" 2>/dev/null
rm "$TOOLS_FILE" 2>/dev/null
