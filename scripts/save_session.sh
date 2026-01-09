#!/bin/bash
# hooks/save_session.sh
# Hook: SessionEnd
# Purpose: Archive session state and finalize logs

STATE_FILE="$HOME/.claude/governance_session.json"
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
    # Add end time to session state
    END_TIME=$(date +%s)
    if ! jq --argjson end "$END_TIME" '. + {end_time: $end}' "$STATE_FILE" > "$ARCHIVE_FILE" 2>/dev/null; then
        # jq failed, just copy the file
        cp "$STATE_FILE" "$ARCHIVE_FILE" 2>/dev/null || exit 0
    fi
else
    # No jq, just copy the file
    cp "$STATE_FILE" "$ARCHIVE_FILE" 2>/dev/null || exit 0
fi

# Remove current session file
rm "$STATE_FILE" 2>/dev/null
