#!/bin/bash
# scripts/suggest_model.sh
# Purpose: Simplified status line (v2.5.3)
# Usage: Called by Claude Code statusLine setting
# Output: 🟢 Context: ~XK · ✅ 🕐 Xm · 🔧 Last Tool
# v2.5.3: Replaced warmup timer with session duration timer (2.5h max enforcement)

# Determine per-project state file path
CWD_PATH=$(pwd)
PROJECT_HASH=$(echo "$CWD_PATH" | tr '[:upper:]' '[:lower:]' | md5 -q 2>/dev/null || echo "$(basename "$CWD_PATH")")
STATE_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_session.json"

# Claude Code's actual todo state (single file with project field)
TODO_STATE="$HOME/.claude/todo_state.json"

# Context configuration
TOTAL_CONTEXT=200000
BUFFER_SIZE=45000
USABLE_CONTEXT=$((TOTAL_CONTEXT - BUFFER_SIZE))  # 155000

NOW=$(date +%s)

# ============================================================
# SECTION 1: Model Tracking (Interactive)
# ============================================================
# Read model from state file (user-confirmed)
# Show "?" if not set, with recommendation to confirm
CURRENT_MODEL=$(jq -r '.model // ""' "$STATE_FILE" 2>/dev/null)
MODEL_CONFIRMED=true

if [[ -z "$CURRENT_MODEL" || "$CURRENT_MODEL" == "null" ]]; then
    CURRENT_MODEL="?"
    MODEL_CONFIRMED=false
fi

# ============================================================
# SECTION 2: Todo Detection (from Claude Code's todo_state.json)
# ============================================================
DONE=0
TOTAL=0
PENDING=""

if [[ -f "$TODO_STATE" ]]; then
    TODOS=$(cat "$TODO_STATE" 2>/dev/null)
    TODO_PROJECT=$(echo "$TODOS" | jq -r '.project // ""' 2>/dev/null)

    # Check if todos belong to current project
    if [[ "$TODO_PROJECT" == "$CWD_PATH" ]]; then
        TOTAL=$(echo "$TODOS" | jq -r '.todos | length' 2>/dev/null || echo "0")
        DONE=$(echo "$TODOS" | jq -r '[.todos[] | select(.status == "completed")] | length' 2>/dev/null || echo "0")
        PENDING=$(echo "$TODOS" | jq -r '.todos[] | select(.status == "pending" or .status == "in_progress") | .content' 2>/dev/null)
    fi
fi

# ============================================================
# SECTION 3: Complexity Analysis for Model Suggestions
# ============================================================
HIGH_KEYWORDS="plan|design|architect|refactor|debug|fix|investigate|migrate|restructure|complex|multi-file"
LOW_KEYWORDS="check|find|list|read|search|look|show|display|simple|quick|verify"

analyze_complexity() {
    local content="$1"
    local content_lower=$(echo "$content" | tr '[:upper:]' '[:lower:]')

    if echo "$content_lower" | grep -qE "$HIGH_KEYWORDS"; then
        echo "high"
    elif echo "$content_lower" | grep -qE "$LOW_KEYWORDS"; then
        echo "low"
    else
        echo "medium"
    fi
}

MAX_COMPLEXITY="medium"  # Default to medium, not low
if [[ -n "$PENDING" ]]; then
    while IFS= read -r todo; do
        COMPLEXITY=$(analyze_complexity "$todo")
        case "$COMPLEXITY" in
            high)
                MAX_COMPLEXITY="high"
                break
                ;;
            medium)
                MAX_COMPLEXITY="medium"
                ;;
        esac
    done <<< "$PENDING"
fi

# Suggest model based on complexity
case "$MAX_COMPLEXITY" in
    high) SUGGESTED="Opus" ;;
    medium) SUGGESTED="Sonnet" ;;
    low) SUGGESTED="Haiku" ;;
esac

# ============================================================
# SECTION 4: Hook Health
# ============================================================
HOOK_STATUS_FILE="$HOME/.claude/hook_status"
HOOK_COUNT=0
HOOK_ERRORS=0
HOOK_INDICATOR="🔴"

if [[ -f "$HOOK_STATUS_FILE" ]]; then
    HOOK_COUNT=$(jq -r '.count // 0' "$HOOK_STATUS_FILE" 2>/dev/null)
    HOOK_ERRORS=$(jq -r '.errors // 0' "$HOOK_STATUS_FILE" 2>/dev/null)

    if [[ "$HOOK_ERRORS" -gt 0 ]]; then
        HOOK_INDICATOR="🔴"
    elif [[ "$HOOK_COUNT" -ge 6 ]]; then
        HOOK_INDICATOR="🟢"
    elif [[ "$HOOK_COUNT" -ge 3 ]]; then
        HOOK_INDICATOR="🟡"
    fi
else
    # Fallback: count from settings
    SETTINGS="$HOME/.claude/settings.json"
    if [[ -f "$SETTINGS" ]]; then
        HOOK_COUNT=$(jq -r '.hooks | to_entries[] | .value[] | .hooks[]? | .command' "$SETTINGS" 2>/dev/null | sort -u | wc -l | xargs)
        HOOK_INDICATOR="🟡"
    fi
fi

# ============================================================
# SECTION 5: Context Calibration (Per-Project)
# ============================================================
# Read raw token estimate and calibration factor
TOKEN_COUNT=$(jq -r '.token_count // 0' "$STATE_FILE" 2>/dev/null)
CONTEXT_FACTOR=$(jq -r '.context_factor // 1.0' "$STATE_FILE" 2>/dev/null)
LAST_CALIBRATION=$(jq -r '.last_calibration // 0' "$STATE_FILE" 2>/dev/null)

# Apply calibration factor
if [[ "$CONTEXT_FACTOR" != "null" && "$CONTEXT_FACTOR" != "1.0" ]]; then
    # Use bc for floating point, fallback to integer if not available
    CALIBRATED_TOKENS=$(echo "$TOKEN_COUNT * $CONTEXT_FACTOR" | bc 2>/dev/null | cut -d. -f1)
    if [[ -z "$CALIBRATED_TOKENS" ]]; then
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
CONTEXT_INDICATOR="🟢"
if [[ $CONTEXT_PCT -ge 85 ]]; then
    CONTEXT_INDICATOR="🔴"
elif [[ $CONTEXT_PCT -ge 70 ]]; then
    CONTEXT_INDICATOR="🟡"
fi

# Format context display (v2.5.2: shortened calibration status)
CALIBRATED_K=$((CALIBRATED_TOKENS / 1000))
# Check if calibration was ever done (last_calibration exists and > 0)
if [[ "$LAST_CALIBRATION" != "0" && "$LAST_CALIBRATION" != "null" && -n "$LAST_CALIBRATION" ]]; then
    CONTEXT_DISPLAY="${CONTEXT_INDICATOR} Context: ~${CALIBRATED_K}K"
else
    CONTEXT_DISPLAY="${CONTEXT_INDICATOR} Context: ~${CALIBRATED_K}K*"
fi

# Check if calibration reminder needed (every 30 min)
CALIBRATION_INTERVAL=1800  # 30 minutes
CALIBRATION_ELAPSED=$((NOW - LAST_CALIBRATION))
NEEDS_CALIBRATION=false
if [[ $CALIBRATION_ELAPSED -ge $CALIBRATION_INTERVAL ]]; then
    NEEDS_CALIBRATION=true
fi

# ============================================================
# SECTION 6: Session Duration Timer
# ============================================================
SESSION_START=$(jq -r '.start_time // 0' "$STATE_FILE" 2>/dev/null)

# Guard against epoch 0
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

# ============================================================
# SECTION 7: Recommendations (Priority-Based)
# ============================================================
RECOMMENDATIONS=()

# Critical: Model not confirmed
if [[ "$MODEL_CONFIRMED" == false ]]; then
    RECOMMENDATIONS+=("Confirm model (/status)")
fi

# Critical: Context issues
if [[ $CONTEXT_PCT -ge 85 ]]; then
    RECOMMENDATIONS+=("⚠️ /compact → touch ~/.claude/compact_flag")
fi

# Critical: Hook issues
if [[ $HOOK_ERRORS -gt 0 ]]; then
    RECOMMENDATIONS+=("🔴 Hook errors: $HOOK_ERRORS")
elif [[ $HOOK_COUNT -lt 3 ]]; then
    RECOMMENDATIONS+=("⚠️ Check hooks")
fi

# Warning: Calibration needed
if [[ "$NEEDS_CALIBRATION" == true ]]; then
    RECOMMENDATIONS+=("Check /context")
fi

# Warning: Session duration (2.5h max enforcement)
if [[ $SESSION_DURATION -ge 150 ]]; then
    RECOMMENDATIONS+=("⚠️ Start new session")
elif [[ $SESSION_DURATION -ge 120 ]]; then
    RECOMMENDATIONS+=("Consider wrapping up")
fi

# Info: Model suggestions (only if no warnings and model confirmed)
if [[ ${#RECOMMENDATIONS[@]} -eq 0 && "$MODEL_CONFIRMED" == true ]]; then
    if [[ "$MAX_COMPLEXITY" == "high" ]] && [[ "$CURRENT_MODEL" != "Opus" ]]; then
        RECOMMENDATIONS+=("Consider /model opus")
    elif [[ "$MAX_COMPLEXITY" == "low" ]] && [[ "$CURRENT_MODEL" != "Haiku" ]] && [[ "$TOTAL" -gt 0 ]]; then
        RECOMMENDATIONS+=("Consider /model haiku")
    fi
fi

# Format recommendations
if [[ ${#RECOMMENDATIONS[@]} -eq 0 ]]; then
    REC_DISPLAY="✓ All good"
elif [[ ${#RECOMMENDATIONS[@]} -le 3 ]]; then
    REC_DISPLAY=$(IFS=' | '; echo "${RECOMMENDATIONS[*]}")
else
    REC_DISPLAY="${RECOMMENDATIONS[0]} | ${RECOMMENDATIONS[1]} | (+$((${#RECOMMENDATIONS[@]} - 2)))"
fi

# ============================================================
# SECTION 8: Last Tool Used (v2.5.2: replaced active plugins)
# ============================================================
LAST_TOOL="--"
TOOL_FILE="$HOME/.claude/last_tool_name"
TOOL_TIME_FILE="$HOME/.claude/last_tool_time"

# Show last tool used (updated by log_tool_use.sh PostToolUse hook)
if [[ -f "$TOOL_FILE" ]]; then
    TOOL_NAME=$(cat "$TOOL_FILE" 2>/dev/null)
    if [[ -n "$TOOL_NAME" ]]; then
        # Check if tool use was recent (within 5 minutes)
        if [[ -f "$TOOL_TIME_FILE" ]]; then
            TOOL_TIME=$(cat "$TOOL_TIME_FILE" 2>/dev/null)
            TOOL_AGE=$((NOW - TOOL_TIME))
            if [[ $TOOL_AGE -lt 300 ]]; then
                LAST_TOOL="$TOOL_NAME"
            else
                LAST_TOOL="--"
            fi
        fi
    fi
fi

# ============================================================
# SECTION 9: Format Output (v2.5.3 Simplified)
# ============================================================
# v2.5.3: Context, Session Timer, Last Tool (if recent)

# Final status line (simplified)
if [[ "$LAST_TOOL" != "--" ]]; then
    echo "$CONTEXT_DISPLAY · $SESSION_DISPLAY · 🔧 $LAST_TOOL"
else
    echo "$CONTEXT_DISPLAY · $SESSION_DISPLAY"
fi
