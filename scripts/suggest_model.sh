#!/bin/bash
# scripts/suggest_model.sh
# Purpose: Simplified status line (v2.5.1)
# Usage: Called by Claude Code statusLine setting
# Output: 🟢 Context: ~XK (calibrated) · ✅ Warmup: Xm · 🔌 Active Plugins: name
# v2.5.1: Removed Model, Todos, Hooks, Recommendations. Using centered dots (·)

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

# Format context display (v2.5.1: show calibration status)
CALIBRATED_K=$((CALIBRATED_TOKENS / 1000))
# Check if calibration was ever done (last_calibration exists and > 0)
if [[ "$LAST_CALIBRATION" != "0" && "$LAST_CALIBRATION" != "null" && -n "$LAST_CALIBRATION" ]]; then
    CONTEXT_DISPLAY="${CONTEXT_INDICATOR} Context: ~${CALIBRATED_K}K (calibrated)"
else
    CONTEXT_DISPLAY="${CONTEXT_INDICATOR} Context: ~${CALIBRATED_K}K (uncalibrated)"
fi

# Check if calibration reminder needed (every 30 min)
CALIBRATION_INTERVAL=1800  # 30 minutes
CALIBRATION_ELAPSED=$((NOW - LAST_CALIBRATION))
NEEDS_CALIBRATION=false
if [[ $CALIBRATION_ELAPSED -ge $CALIBRATION_INTERVAL ]]; then
    NEEDS_CALIBRATION=true
fi

# ============================================================
# SECTION 6: Warmup Timer (v2.5.1: threshold-based colors)
# ============================================================
LAST_WARMUP=$(jq -r '.last_warmup // 0' "$STATE_FILE" 2>/dev/null)
WARMUP_ELAPSED=$(((NOW - LAST_WARMUP) / 60))

# v2.5.1: Threshold-based warmup status
# ✅ <240m (4h) = Ready, ⚠️ 240-480m (4-8h) = Stale, 🔴 >480m (8h) = Cold
if [[ $WARMUP_ELAPSED -ge 480 ]]; then
    WARMUP_DISPLAY="🔴 Warmup: ${WARMUP_ELAPSED}m"
elif [[ $WARMUP_ELAPSED -ge 240 ]]; then
    WARMUP_DISPLAY="⚠️ Warmup: ${WARMUP_ELAPSED}m"
else
    WARMUP_DISPLAY="✅ Warmup: ${WARMUP_ELAPSED}m"
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

# Warning: Warmup due
if [[ $WARMUP_ELAPSED -ge 90 ]]; then
    RECOMMENDATIONS+=("Warmup due")
fi

# Warning: Long session
SESSION_START=$(jq -r '.start_time // 0' "$STATE_FILE" 2>/dev/null)
SESSION_DURATION=$(((NOW - SESSION_START) / 3600))
if [[ $SESSION_DURATION -ge 8 ]]; then
    RECOMMENDATIONS+=("⚠️ Long session (${SESSION_DURATION}h)")
elif [[ $SESSION_DURATION -ge 4 ]]; then
    RECOMMENDATIONS+=("Session ${SESSION_DURATION}h")
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
# SECTION 8: Active Plugins Detection (v2.5.1)
# ============================================================
ACTIVE_PLUGINS="none"
PLUGIN_FILE="$HOME/.claude/active_plugin"

# Check if any automatic plugin is currently running
# (This file is updated by PreToolUse hooks when plugins execute)
if [[ -f "$PLUGIN_FILE" ]]; then
    PLUGIN_CONTENT=$(cat "$PLUGIN_FILE" 2>/dev/null)
    if [[ -n "$PLUGIN_CONTENT" && "$PLUGIN_CONTENT" != "none" ]]; then
        ACTIVE_PLUGINS="$PLUGIN_CONTENT"
    fi
fi

# ============================================================
# SECTION 9: Format Output (v2.5.1 Simplified)
# ============================================================
# v2.5.1: Only Context, Warmup, Active Plugins with centered dots

# Final status line (simplified)
echo "$CONTEXT_DISPLAY · $WARMUP_DISPLAY · 🔌 Active Plugins: $ACTIVE_PLUGINS"
