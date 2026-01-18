#!/bin/bash
# hooks/save_session.sh
# Hook: SessionEnd
# Purpose: Archive session state and finalize logs
# v3.0.0: Fixed to use PROJECT_HASH-based state file path + add status/end_time fields

# Determine per-project state file path
CWD_PATH=$(pwd)
# Normalize path to lowercase for consistent hashing (macOS case-insensitive)
PROJECT_HASH=$(echo "$CWD_PATH" | tr '[:upper:]' '[:lower:]' | md5 -q 2>/dev/null || echo "$(basename "$CWD_PATH")")
STATE_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_session.json"
ARCHIVE_DIR="$HOME/.claude/sessions"

# Check if state file exists
if [[ ! -f "$STATE_FILE" ]]; then
    exit 0  # No state to save
fi

# Create archive directory
if ! mkdir -p "$ARCHIVE_DIR" 2>/dev/null; then
    exit 0  # Can't create directory, fail silently
fi

# Archive with timestamp
ARCHIVE_FILE="$ARCHIVE_DIR/$(date +%Y%m%d_%H%M%S).json"

# Check if jq is available
if command -v jq &> /dev/null; then
    # Add end time, status=finalized, and calculate duration
    END_TIME=$(date +%s)
    START_TIME=$(jq -r '.start_time // 0' "$STATE_FILE" 2>/dev/null)
    DURATION=$((END_TIME - START_TIME))

    if ! jq --argjson end "$END_TIME" --argjson dur "$DURATION" \
       '. + {end_time: $end, status: "finalized", duration_seconds: $dur}' \
       "$STATE_FILE" > "$ARCHIVE_FILE" 2>/dev/null; then
        # jq failed, just copy the file
        cp "$STATE_FILE" "$ARCHIVE_FILE" 2>/dev/null || exit 0
    fi
else
    # No jq, just copy the file
    cp "$STATE_FILE" "$ARCHIVE_FILE" 2>/dev/null || exit 0
fi

# Remove current session file
rm "$STATE_FILE" 2>/dev/null
