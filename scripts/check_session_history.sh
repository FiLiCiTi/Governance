#!/bin/bash
# check_session_history.sh
# Purpose: Monitor Claude Code session history (.jsonl) file sizes
# Events: UserPromptSubmit (--threshold N), PreCompact (--always)
# Decision: #G-SESSION-HISTORY-PRUNING
# Version: 1.0 | 2026-01-31

# --- Arguments ---
MODE="threshold"
THRESHOLD_MB=100

while [[ $# -gt 0 ]]; do
    case "$1" in
        --always)
            MODE="always"
            shift
            ;;
        --threshold)
            MODE="threshold"
            THRESHOLD_MB="${2:-100}"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# --- Resolve project session directory ---
WORKING_DIR="${CLAUDE_WORKING_DIR:-$(pwd)}"
PROJECT_DIR_NAME=$(echo "$WORKING_DIR" | tr '/' '-')
SESSION_DIR="$HOME/.claude/projects/${PROJECT_DIR_NAME}"

if [ ! -d "$SESSION_DIR" ]; then
    exit 0
fi

# --- Calculate total .jsonl size ---
TOTAL_BYTES=0
FILE_COUNT=0

for jsonl in "$SESSION_DIR"/*.jsonl; do
    [ -f "$jsonl" ] || continue
    SIZE=$(stat -f%z "$jsonl" 2>/dev/null || stat -c%s "$jsonl" 2>/dev/null)
    TOTAL_BYTES=$((TOTAL_BYTES + SIZE))
    FILE_COUNT=$((FILE_COUNT + 1))
done

if [ "$FILE_COUNT" -eq 0 ]; then
    exit 0
fi

TOTAL_MB=$((TOTAL_BYTES / 1048576))

# --- Check threshold (skip output if below and not --always) ---
if [ "$MODE" = "threshold" ] && [ "$TOTAL_MB" -lt "$THRESHOLD_MB" ]; then
    exit 0
fi

# --- Build detailed report ---
INDEX_FILE="$SESSION_DIR/sessions-index.json"
PROJECT_NAME=$(basename "$WORKING_DIR")

# Header
if [ "$MODE" = "always" ]; then
    echo "📋 SESSION HISTORY (PreCompact): ${TOTAL_MB} MB across ${FILE_COUNT} sessions"
else
    echo "⚠️ SESSION HISTORY WARNING: ${TOTAL_MB} MB (threshold: ${THRESHOLD_MB} MB)"
fi
echo "📁 Project: ${PROJECT_NAME} (${WORKING_DIR})"
echo ""

# Table header
printf "| %-3s | %-16s | %-40s | %-4s | %-7s | %-7s |\n" "#" "Date" "Summary" "Msgs" "Size" "Status"
printf "| %-3s | %-16s | %-40s | %-4s | %-7s | %-7s |\n" "---" "----------------" "----------------------------------------" "----" "-------" "-------"

# Collect and sort files by size (largest first)
ENTRY_NUM=0

for jsonl in "$SESSION_DIR"/*.jsonl; do
    [ -f "$jsonl" ] || continue

    ENTRY_NUM=$((ENTRY_NUM + 1))
    BASENAME=$(basename "$jsonl" .jsonl)
    SIZE_BYTES=$(stat -f%z "$jsonl" 2>/dev/null || stat -c%s "$jsonl" 2>/dev/null)

    # Format size
    if [ "$SIZE_BYTES" -ge 1048576 ]; then
        SIZE_FMT="$((SIZE_BYTES / 1048576)) MB"
    else
        SIZE_FMT="$((SIZE_BYTES / 1024)) KB"
    fi

    # Look up metadata in sessions-index.json
    SESSION_DATE="unknown"
    SESSION_SUMMARY="(no metadata)"
    SESSION_MSGS="?"
    SESSION_STATUS="indexed"

    if [ -f "$INDEX_FILE" ] && command -v jq &>/dev/null; then
        # Find this session in the index
        ENTRY=$(jq -r --arg id "$BASENAME" '.entries[] | select(.sessionId == $id)' "$INDEX_FILE" 2>/dev/null)

        if [ -n "$ENTRY" ] && [ "$ENTRY" != "null" ]; then
            # Extract modified date
            MODIFIED=$(echo "$ENTRY" | jq -r '.modified // empty' 2>/dev/null)
            if [ -n "$MODIFIED" ]; then
                # Parse ISO date to readable format (handles both GNU and BSD date)
                SESSION_DATE=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${MODIFIED%%.*}" "+%Y-%m-%d %H:%M" 2>/dev/null || \
                               date -d "$MODIFIED" "+%Y-%m-%d %H:%M" 2>/dev/null || \
                               echo "${MODIFIED:0:16}")
            fi

            # Extract summary (truncate to 40 chars)
            RAW_SUMMARY=$(echo "$ENTRY" | jq -r '.summary // "(no summary)"' 2>/dev/null)
            if [ ${#RAW_SUMMARY} -gt 37 ]; then
                SESSION_SUMMARY="${RAW_SUMMARY:0:37}..."
            else
                SESSION_SUMMARY="$RAW_SUMMARY"
            fi

            # Extract message count
            SESSION_MSGS=$(echo "$ENTRY" | jq -r '.messageCount // "?"' 2>/dev/null)
        else
            # Not in index = orphaned
            SESSION_STATUS="ORPHAN"
            SESSION_SUMMARY="(not in index)"
            # Try to get date from file modification time
            SESSION_DATE=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$jsonl" 2>/dev/null || \
                           stat -c "%y" "$jsonl" 2>/dev/null | cut -c1-16 || \
                           echo "unknown")
        fi
    else
        # No jq or no index file — use file dates only
        SESSION_DATE=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$jsonl" 2>/dev/null || \
                       stat -c "%y" "$jsonl" 2>/dev/null | cut -c1-16 || \
                       echo "unknown")
        SESSION_STATUS="no-idx"
    fi

    printf "| %-3s | %-16s | %-40s | %-4s | %-7s | %-7s |\n" \
        "$ENTRY_NUM" "$SESSION_DATE" "$SESSION_SUMMARY" "$SESSION_MSGS" "$SIZE_FMT" "$SESSION_STATUS"
done

echo ""
echo "💡 Action: Ask Claude to delete sessions by #, or 'wrap up' to end cleanly."
