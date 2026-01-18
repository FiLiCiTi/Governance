#!/bin/bash
# scripts/status_bar.sh
# Purpose: Display status bar with model, context, duration, last tool
# Usage: Called by Claude Code statusLine setting
# Output: Model · 🟢 Context: ~XK · ✅ 🕐 Xm · 🔧 Last Tool
# v3.3.0: Complete rewrite - reads from separated state files

# Determine per-project state file paths
CWD_PATH=$(pwd)
PROJECT_HASH=$(echo "$CWD_PATH" | tr '[:upper:]' '[:lower:]' | md5 -q 2>/dev/null || echo "$(basename "$CWD_PATH")")

SESSION_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_session.json"
CONTEXT_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_context.json"
TOOLS_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_tools.json"

# Context configuration
TOTAL_CONTEXT=200000
BUFFER_SIZE=45000
USABLE_CONTEXT=$((TOTAL_CONTEXT - BUFFER_SIZE))  # 155000

NOW=$(date +%s)

# ============================================================
# SECTION 1: Model Name (from session.json)
# ============================================================
MODEL="sonnet"  # Default

if [[ -f "$SESSION_FILE" ]]; then
    MODEL_RAW=$(jq -r '.model // "sonnet"' "$SESSION_FILE" 2>/dev/null)
    # Capitalize first letter for display
    MODEL=$(echo "$MODEL_RAW" | sed 's/\b\(.\)/\u\1/')
fi

# ============================================================
# SECTION 2: Context Tracking (from context.json)
# ============================================================
CONTEXT_INDICATOR="🟢"
CONTEXT_DISPLAY="Context: ~0K"

if [[ -f "$CONTEXT_FILE" ]]; then
    TOKEN_COUNT=$(jq -r '.token_count // 0' "$CONTEXT_FILE" 2>/dev/null)
    CONTEXT_FACTOR=$(jq -r '.context_factor // 1.0' "$CONTEXT_FILE" 2>/dev/null)
    LAST_CALIBRATION=$(jq -r '.last_calibration // 0' "$CONTEXT_FILE" 2>/dev/null)

    # Apply calibration factor
    if [[ "$CONTEXT_FACTOR" != "null" && "$CONTEXT_FACTOR" != "1.0" ]]; then
        if command -v bc &> /dev/null; then
            CALIBRATED_TOKENS=$(echo "$TOKEN_COUNT * $CONTEXT_FACTOR" | bc 2>/dev/null | cut -d. -f1)
        else
            CALIBRATED_TOKENS=$TOKEN_COUNT
        fi
    else
        CALIBRATED_TOKENS=$TOKEN_COUNT
    fi

    # Calculate percentage
    CONTEXT_PCT=$((CALIBRATED_TOKENS * 100 / USABLE_CONTEXT))
    if [[ $CONTEXT_PCT -gt 100 ]]; then
        CONTEXT_PCT=100
    fi

    # Context indicator
    if [[ $CONTEXT_PCT -ge 85 ]]; then
        CONTEXT_INDICATOR="🔴"
    elif [[ $CONTEXT_PCT -ge 70 ]]; then
        CONTEXT_INDICATOR="🟡"
    fi

    # Format context display
    CALIBRATED_K=$((CALIBRATED_TOKENS / 1000))
    if [[ "$LAST_CALIBRATION" != "0" && "$LAST_CALIBRATION" != "null" && -n "$LAST_CALIBRATION" ]]; then
        CONTEXT_DISPLAY="${CONTEXT_INDICATOR} Context: ~${CALIBRATED_K}K"
    else
        CONTEXT_DISPLAY="${CONTEXT_INDICATOR} Context: ~${CALIBRATED_K}K*"
    fi
fi

# ============================================================
# SECTION 3: Session Duration (from session.json)
# ============================================================
SESSION_DISPLAY="✅ 🕐 0m"

if [[ -f "$SESSION_FILE" ]]; then
    SESSION_START=$(jq -r '.start_time // 0' "$SESSION_FILE" 2>/dev/null)

    # Guard against epoch 0 corruption
    if [[ "$SESSION_START" == "0" || "$SESSION_START" == "null" ]]; then
        SESSION_DURATION=0
    else
        SESSION_DURATION=$(((NOW - SESSION_START) / 60))
    fi

    # Status thresholds: ✅ <120m, ⚠️ 120-149m, 🔴 ≥150m
    if [[ $SESSION_DURATION -ge 150 ]]; then
        SESSION_DISPLAY="🔴 🕐 ${SESSION_DURATION}m"
    elif [[ $SESSION_DURATION -ge 120 ]]; then
        SESSION_DISPLAY="⚠️ 🕐 ${SESSION_DURATION}m"
    else
        SESSION_DISPLAY="✅ 🕐 ${SESSION_DURATION}m"
    fi
fi

# ============================================================
# SECTION 4: Last Tool Used (from tools.json)
# ============================================================
LAST_TOOL=""

if [[ -f "$TOOLS_FILE" ]]; then
    TOOL_NAME=$(jq -r '.last_tool // "--"' "$TOOLS_FILE" 2>/dev/null)
    TOOL_TIME=$(jq -r '.last_tool_time // 0' "$TOOLS_FILE" 2>/dev/null)

    # Show tool if used recently (within 5 minutes)
    if [[ "$TOOL_NAME" != "--" && "$TOOL_TIME" != "0" ]]; then
        TOOL_AGE=$((NOW - TOOL_TIME))
        if [[ $TOOL_AGE -lt 300 ]]; then
            LAST_TOOL=" · 🔧 $TOOL_NAME"
        fi
    fi
fi

# ============================================================
# SECTION 5: Format Output
# ============================================================
# Format: Model · Context · Duration · Last Tool (if recent)
# Example: Sonnet · 🟢 Context: ~45K · ✅ 🕐 28m · 🔧 Bash

echo "$MODEL · $CONTEXT_DISPLAY · $SESSION_DISPLAY$LAST_TOOL"
