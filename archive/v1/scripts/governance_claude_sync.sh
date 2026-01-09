#!/bin/bash
# governance_claude_sync.sh
# Layer 5: .claude/ Integration
#
# Usage:
#   ./governance_claude_sync.sh                     # Full sync check
#   ./governance_claude_sync.sh --project PATH      # Check specific project
#   ./governance_claude_sync.sh --sessions          # List sessions per project
#   ./governance_claude_sync.sh --todos             # Check TodoWrite ↔ Plan sync
#   ./governance_claude_sync.sh --history           # Analyze history.jsonl
#
# Integrates with:
#   ~/.claude/history.jsonl     - Session history
#   ~/.claude/projects/         - Per-project configs
#   ~/.claude/todos/            - TodoWrite state
#   ~/.claude/plans/            - Plan files
#   ~/.claude/CLAUDE.md         - Layer 3 rules

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Paths
CLAUDE_DIR="$HOME/.claude"
HISTORY_FILE="$CLAUDE_DIR/history.jsonl"
PROJECTS_DIR="$CLAUDE_DIR/projects"
TODOS_DIR="$CLAUDE_DIR/todos"
PLANS_DIR="$CLAUDE_DIR/plans"
LAYER3_FILE="$CLAUDE_DIR/CLAUDE.md"

# Parse arguments
MODE="full"
PROJECT_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --project)
            PROJECT_PATH="$2"
            MODE="project"
            shift 2
            ;;
        --sessions)
            MODE="sessions"
            shift
            ;;
        --todos)
            MODE="todos"
            shift
            ;;
        --history)
            MODE="history"
            shift
            ;;
        *)
            shift
            ;;
    esac
done

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  GOVERNANCE CLAUDE SYNC - Layer 5: .claude/ Integration"
echo "  Mode: $MODE"
echo "  Date: $(date '+%Y-%m-%d %H:%M')"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# CHECK PREREQUISITES
# ═══════════════════════════════════════════════════════════════════════════

check_prerequisites() {
    local missing=0

    if [[ ! -d "$CLAUDE_DIR" ]]; then
        echo -e "${RED}✗${NC} ~/.claude/ directory not found"
        exit 1
    fi

    if [[ ! -f "$HISTORY_FILE" ]]; then
        echo -e "${YELLOW}○${NC} history.jsonl not found"
        missing=$((missing + 1))
    fi

    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}○${NC} jq not installed (some features limited)"
        echo "  Install with: brew install jq"
    fi

    return $missing
}

# ═══════════════════════════════════════════════════════════════════════════
# SESSIONS PER PROJECT
# ═══════════════════════════════════════════════════════════════════════════

show_sessions() {
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ SESSIONS PER PROJECT                                        │"
    echo "├─────────────────────────────────────────────────────────────┤"

    if [[ ! -f "$HISTORY_FILE" ]]; then
        echo -e "  ${RED}✗${NC} history.jsonl not found"
        echo "└─────────────────────────────────────────────────────────────┘"
        return
    fi

    if command -v jq &> /dev/null; then
        # Use jq for proper JSON parsing
        jq -r '.project' "$HISTORY_FILE" 2>/dev/null | \
            sort | uniq -c | sort -rn | head -15 | \
            while read count project; do
                local short_project=$(echo "$project" | sed 's|/Users/[^/]*/Desktop/||')
                printf "  %4d │ %s\n" "$count" "$short_project"
            done
    else
        # Fallback without jq
        grep -oE '"project":"[^"]*"' "$HISTORY_FILE" | \
            cut -d'"' -f4 | sort | uniq -c | sort -rn | head -15 | \
            while read count project; do
                local short_project=$(echo "$project" | sed 's|/Users/[^/]*/Desktop/||')
                printf "  %4d │ %s\n" "$count" "$short_project"
            done
    fi

    echo "└─────────────────────────────────────────────────────────────┘"
    echo ""

    # Show unique session IDs
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ UNIQUE SESSIONS (Last 7 days)                               │"
    echo "├─────────────────────────────────────────────────────────────┤"

    if command -v jq &> /dev/null; then
        local week_ago=$(($(date +%s) - 604800))
        local week_ago_ms=$((week_ago * 1000))

        jq -r "select(.timestamp > $week_ago_ms) | .sessionId" "$HISTORY_FILE" 2>/dev/null | \
            sort -u | wc -l | xargs echo "  Sessions this week:"

        # Group by project
        jq -r "select(.timestamp > $week_ago_ms) | \"\(.project)|\(.sessionId)\"" "$HISTORY_FILE" 2>/dev/null | \
            sort -u | cut -d'|' -f1 | sort | uniq -c | sort -rn | head -10 | \
            while read count project; do
                local short_project=$(echo "$project" | sed 's|/Users/[^/]*/Desktop/||')
                printf "  %4d sessions │ %s\n" "$count" "$short_project"
            done
    fi

    echo "└─────────────────────────────────────────────────────────────┘"
}

# ═══════════════════════════════════════════════════════════════════════════
# TODOWRITE ↔ PLAN SYNC
# ═══════════════════════════════════════════════════════════════════════════

check_todos_sync() {
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ TODOWRITE ↔ PLAN FILE SYNC                                  │"
    echo "├─────────────────────────────────────────────────────────────┤"

    # Find most recent plan file
    local latest_plan=$(ls -t "$PLANS_DIR"/*.md 2>/dev/null | head -1)

    if [[ -z "$latest_plan" ]]; then
        echo -e "  ${YELLOW}○${NC} No plan files found in $PLANS_DIR"
        echo "└─────────────────────────────────────────────────────────────┘"
        return
    fi

    local plan_name=$(basename "$latest_plan")
    echo -e "  ${CYAN}Active Plan:${NC} $plan_name"
    echo ""

    # Count checkboxes in plan
    local plan_checked=$(grep -c "\[x\]" "$latest_plan" 2>/dev/null || echo "0")
    local plan_unchecked=$(grep -c "\[ \]" "$latest_plan" 2>/dev/null || echo "0")
    local plan_total=$((plan_checked + plan_unchecked))

    echo "  Plan File Status:"
    echo -e "    ${GREEN}✓ Completed:${NC} $plan_checked"
    echo -e "    ${YELLOW}○ Pending:${NC}   $plan_unchecked"
    echo -e "    Total:      $plan_total"
    echo ""

    # Check todos directory
    if [[ -d "$TODOS_DIR" ]]; then
        local todo_files=$(ls -1 "$TODOS_DIR"/*.json 2>/dev/null | wc -l | tr -d ' ')
        echo "  TodoWrite State:"
        echo "    Files in todos/: $todo_files"

        if command -v jq &> /dev/null && [[ "$todo_files" -gt 0 ]]; then
            local latest_todo=$(ls -t "$TODOS_DIR"/*.json 2>/dev/null | head -1)
            if [[ -f "$latest_todo" ]]; then
                local todo_completed=$(jq '[.[] | select(.status == "completed")] | length' "$latest_todo" 2>/dev/null || echo "0")
                local todo_pending=$(jq '[.[] | select(.status == "pending" or .status == "in_progress")] | length' "$latest_todo" 2>/dev/null || echo "0")
                echo -e "    ${GREEN}✓ Completed:${NC} $todo_completed"
                echo -e "    ${YELLOW}○ Pending:${NC}   $todo_pending"
            fi
        fi
    else
        echo -e "  ${CYAN}i${NC} todos/ directory not found"
    fi

    echo ""
    echo "  Sync Check:"
    if [[ "$plan_checked" -gt 0 ]] || [[ "$plan_unchecked" -gt 0 ]]; then
        local progress=$((plan_checked * 100 / plan_total))
        echo -e "    Plan progress: ${GREEN}$progress%${NC} ($plan_checked/$plan_total)"

        if [[ "$progress" -ge 80 ]]; then
            echo -e "    ${GREEN}✓${NC} Plan nearly complete!"
        elif [[ "$progress" -ge 50 ]]; then
            echo -e "    ${CYAN}i${NC} Good progress on plan"
        else
            echo -e "    ${YELLOW}○${NC} Plan in early stages"
        fi
    fi

    echo "└─────────────────────────────────────────────────────────────┘"
}

# ═══════════════════════════════════════════════════════════════════════════
# HISTORY ANALYSIS
# ═══════════════════════════════════════════════════════════════════════════

analyze_history() {
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ HISTORY.JSONL ANALYSIS                                      │"
    echo "├─────────────────────────────────────────────────────────────┤"

    if [[ ! -f "$HISTORY_FILE" ]]; then
        echo -e "  ${RED}✗${NC} history.jsonl not found"
        echo "└─────────────────────────────────────────────────────────────┘"
        return
    fi

    local file_size=$(du -h "$HISTORY_FILE" | cut -f1)
    local total_entries=$(wc -l < "$HISTORY_FILE" | tr -d ' ')

    echo "  File Size: $file_size"
    echo "  Total Entries: $total_entries"
    echo ""

    if command -v jq &> /dev/null; then
        # Recent activity (last 24 hours)
        local day_ago=$(($(date +%s) - 86400))
        local day_ago_ms=$((day_ago * 1000))

        local today_count=$(jq -r "select(.timestamp > $day_ago_ms) | .project" "$HISTORY_FILE" 2>/dev/null | wc -l | tr -d ' ')
        echo "  Last 24 hours: $today_count messages"

        # Projects worked on today
        echo ""
        echo "  Projects (last 24h):"
        jq -r "select(.timestamp > $day_ago_ms) | .project" "$HISTORY_FILE" 2>/dev/null | \
            sort -u | head -5 | \
            while read project; do
                local short=$(echo "$project" | sed 's|/Users/[^/]*/Desktop/||')
                echo -e "    ${CYAN}•${NC} $short"
            done

        # Check for potential issues in recent messages
        echo ""
        echo "  Quick Compliance Check (last 24h):"

        # Check for 2025 mentions
        local wrong_year=$(jq -r "select(.timestamp > $day_ago_ms) | .display" "$HISTORY_FILE" 2>/dev/null | grep -c "2025" || echo "0")
        if [[ "$wrong_year" -gt 0 ]]; then
            echo -e "    ${RED}✗${NC} Found 2025 in $wrong_year messages (should be 2026)"
        else
            echo -e "    ${GREEN}✓${NC} No 2025 dates found"
        fi

        # Check for warm-up mentions
        local warmups=$(jq -r "select(.timestamp > $day_ago_ms) | .display" "$HISTORY_FILE" 2>/dev/null | grep -ic "warm-up" || echo "0")
        if [[ "$warmups" -gt 0 ]]; then
            echo -e "    ${GREEN}✓${NC} Warm-up protocol used ($warmups times)"
        else
            echo -e "    ${YELLOW}○${NC} No warm-up markers in recent history"
        fi
    fi

    echo "└─────────────────────────────────────────────────────────────┘"
}

# ═══════════════════════════════════════════════════════════════════════════
# PROJECT-SPECIFIC CHECK
# ═══════════════════════════════════════════════════════════════════════════

check_project() {
    local project="$1"

    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ PROJECT: $project"
    echo "├─────────────────────────────────────────────────────────────┤"

    if [[ ! -f "$HISTORY_FILE" ]]; then
        echo -e "  ${RED}✗${NC} history.jsonl not found"
        echo "└─────────────────────────────────────────────────────────────┘"
        return
    fi

    if command -v jq &> /dev/null; then
        # Count sessions for this project
        local session_count=$(jq -r "select(.project == \"$project\") | .sessionId" "$HISTORY_FILE" 2>/dev/null | sort -u | wc -l | tr -d ' ')
        local message_count=$(jq -r "select(.project == \"$project\") | .display" "$HISTORY_FILE" 2>/dev/null | wc -l | tr -d ' ')

        echo "  Total Sessions: $session_count"
        echo "  Total Messages: $message_count"

        # Last activity
        local last_ts=$(jq -r "select(.project == \"$project\") | .timestamp" "$HISTORY_FILE" 2>/dev/null | sort -n | tail -1)
        if [[ -n "$last_ts" ]] && [[ "$last_ts" != "null" ]]; then
            local last_date=$(date -r $((last_ts / 1000)) "+%Y-%m-%d %H:%M" 2>/dev/null || echo "unknown")
            echo "  Last Activity: $last_date"
        fi

        echo ""
        echo "  Project Config:"

        # Check for project-specific settings
        local project_hash=$(echo "$project" | sed 's|/|-|g')
        if [[ -d "$PROJECTS_DIR" ]]; then
            local config=$(ls "$PROJECTS_DIR" 2>/dev/null | grep -F "$project_hash" | head -1)
            if [[ -n "$config" ]]; then
                echo -e "    ${GREEN}✓${NC} Project config exists"
            else
                echo -e "    ${CYAN}i${NC} No project-specific config"
            fi
        fi

        # Check for CLAUDE.md in project
        if [[ -f "$project/CLAUDE.md" ]]; then
            echo -e "    ${GREEN}✓${NC} CLAUDE.md exists in project"
        else
            echo -e "    ${YELLOW}○${NC} No CLAUDE.md in project"
        fi
    fi

    echo "└─────────────────────────────────────────────────────────────┘"
}

# ═══════════════════════════════════════════════════════════════════════════
# LAYER 3 CHECK
# ═══════════════════════════════════════════════════════════════════════════

check_layer3() {
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ LAYER 3: ~/.claude/CLAUDE.md                                │"
    echo "├─────────────────────────────────────────────────────────────┤"

    if [[ -f "$LAYER3_FILE" ]]; then
        local size=$(wc -c < "$LAYER3_FILE" | tr -d ' ')
        local lines=$(wc -l < "$LAYER3_FILE" | tr -d ' ')

        echo -e "  ${GREEN}✓${NC} Layer 3 exists"
        echo "    Size: $size bytes, $lines lines"

        # Check for key sections
        if grep -q "Universal Rules" "$LAYER3_FILE" 2>/dev/null; then
            echo -e "    ${GREEN}✓${NC} Universal Rules section found"
        fi

        if grep -q "2026" "$LAYER3_FILE" 2>/dev/null; then
            echo -e "    ${GREEN}✓${NC} 2026 date configured"
        fi
    else
        echo -e "  ${RED}✗${NC} Layer 3 not found"
        echo "    Create with: cp templates/CLAUDE_LAYER3.md ~/.claude/CLAUDE.md"
    fi

    echo "└─────────────────────────────────────────────────────────────┘"
}

# ═══════════════════════════════════════════════════════════════════════════
# FULL SYNC CHECK
# ═══════════════════════════════════════════════════════════════════════════

full_sync() {
    check_prerequisites

    check_layer3
    echo ""

    show_sessions
    echo ""

    check_todos_sync
    echo ""

    analyze_history
}

# ═══════════════════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ═══════════════════════════════════════════════════════════════════════════

case "$MODE" in
    "sessions")
        show_sessions
        ;;
    "todos")
        check_todos_sync
        ;;
    "history")
        analyze_history
        ;;
    "project")
        check_project "$PROJECT_PATH"
        ;;
    "full")
        full_sync
        ;;
esac

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  Sync complete. Use --sessions, --todos, --history for details"
echo "═══════════════════════════════════════════════════════════════"
