#!/bin/bash
# scripts/check_protocol.sh
# Purpose: Validate protocol steps were followed in session
# Usage: ./check_protocol.sh [CODE|BIZZ|OPS]
#        If no type provided, auto-detects from CLAUDE.md

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get project type
if [[ -n "$1" ]]; then
    TYPE="$1"
elif [[ -f "./CLAUDE.md" ]]; then
    TYPE=$(grep -oP 'Type:\s*\K\w+' ./CLAUDE.md 2>/dev/null || echo "CODE")
else
    TYPE="CODE"
fi

# Determine per-project state file path
CWD_PATH=$(pwd)
# Normalize path to lowercase for consistent hashing (macOS case-insensitive)
PROJECT_HASH=$(echo "$CWD_PATH" | tr '[:upper:]' '[:lower:]' | md5 -q 2>/dev/null || echo "$(basename "$CWD_PATH")")
STATE_FILE="$HOME/.claude/sessions/${PROJECT_HASH}_session.json"
HISTORY_FILE="$HOME/.claude/history.jsonl"

echo ""
echo "============================================"
echo "  Protocol Check: $TYPE"
echo "============================================"
echo ""

PASS=0
FAIL=0
WARN=0

check() {
    local name="$1"
    local status="$2"  # pass, fail, warn, skip

    case "$status" in
        pass)
            echo -e "${GREEN}[PASS]${NC} $name"
            ((PASS++))
            ;;
        fail)
            echo -e "${RED}[FAIL]${NC} $name"
            ((FAIL++))
            ;;
        warn)
            echo -e "${YELLOW}[WARN]${NC} $name"
            ((WARN++))
            ;;
        skip)
            echo -e "[SKIP] $name"
            ;;
    esac
}

# ============================================
# COMMON CHECKS (All project types)
# ============================================

echo "--- Session Start (1.x) ---"

# 1.0 Date confirmed
if [[ -f "$STATE_FILE" ]]; then
    START_TIME=$(jq -r '.start_time // 0' "$STATE_FILE" 2>/dev/null)
    if [[ "$START_TIME" -gt 0 ]]; then
        check "1.0 Session initialized" "pass"
    else
        check "1.0 Session initialized" "fail"
    fi
else
    check "1.0 Session initialized" "fail"
fi

# 1.1 Boundaries confirmed (check if CLAUDE.md was read)
# This is hard to verify without parsing history, so we check if CLAUDE.md exists
if [[ -f "./CLAUDE.md" ]]; then
    if grep -q "CAN modify\|CANNOT modify" "./CLAUDE.md" 2>/dev/null; then
        check "1.1 Boundaries defined in CLAUDE.md" "pass"
    else
        check "1.1 Boundaries defined in CLAUDE.md" "warn"
    fi
else
    check "1.1 Boundaries defined in CLAUDE.md" "fail"
fi

echo ""
echo "--- During Session (2.x) ---"

# 2.x TodoWrite used (Required for all types)
if [[ -f "$HOME/.claude/audit/tool_use.log" ]]; then
    TODO_COUNT=$(grep -c "TodoWrite" "$HOME/.claude/audit/tool_use.log" 2>/dev/null || echo "0")
    if [[ "$TODO_COUNT" -gt 0 ]]; then
        check "2.x TodoWrite used ($TODO_COUNT times)" "pass"
    else
        check "2.x TodoWrite used" "warn"
    fi
else
    check "2.x TodoWrite used" "warn"
fi

# ============================================
# TYPE-SPECIFIC CHECKS
# ============================================

echo ""
echo "--- Type-Specific: $TYPE ---"

case "$TYPE" in
    CODE)
        # Tests run
        if [[ -f "$HOME/.claude/audit/tool_use.log" ]]; then
            if grep -qE "pytest|npm test|jest|mocha" "$HOME/.claude/audit/tool_use.log" 2>/dev/null; then
                check "Tests executed" "pass"
            else
                check "Tests executed" "warn"
            fi
        else
            check "Tests executed" "skip"
        fi

        # Git commit
        if git log --oneline -1 --since="today" >/dev/null 2>&1; then
            check "Git commit today" "pass"
        else
            check "Git commit today" "warn"
        fi
        ;;

    BIZZ)
        # Decision IDs logged
        if [[ -f "$HOME/.claude/audit/tool_use.log" ]]; then
            check "Decision tracking available" "pass"
        else
            check "Decision tracking available" "skip"
        fi
        ;;

    OPS)
        # Operations logged
        if [[ -d "$HOME/.claude/audit" ]]; then
            check "Audit logging active" "pass"
        else
            check "Audit logging active" "fail"
        fi

        # Git commit
        if git log --oneline -1 --since="today" >/dev/null 2>&1; then
            check "Git commit today" "pass"
        else
            check "Git commit today" "warn"
        fi
        ;;
esac

# ============================================
# SESSION END CHECKS (9.x)
# ============================================

echo ""
echo "--- Session End (9.x) ---"

# 9.0 Warm-up completed
if [[ -f "$STATE_FILE" ]]; then
    LAST_WARMUP=$(jq -r '.last_warmup // 0' "$STATE_FILE" 2>/dev/null)
    START_TIME=$(jq -r '.start_time // 0' "$STATE_FILE" 2>/dev/null)
    if [[ "$LAST_WARMUP" -gt "$START_TIME" ]]; then
        check "9.0 Warm-up performed" "pass"
    else
        check "9.0 Warm-up performed" "warn"
    fi
else
    check "9.0 Warm-up performed" "skip"
fi

# ============================================
# SUMMARY
# ============================================

echo ""
echo "============================================"
TOTAL=$((PASS + FAIL + WARN))
echo "  Results: $PASS pass, $FAIL fail, $WARN warn"

if [[ "$FAIL" -eq 0 ]]; then
    echo -e "  Status: ${GREEN}PROTOCOL OK${NC}"
    exit 0
else
    echo -e "  Status: ${RED}PROTOCOL ISSUES${NC}"
    exit 1
fi
