#!/bin/bash
# governance_report.sh
# Layer 4: Combined Reporting
#
# Usage:
#   ./governance_report.sh                          # Full report (all projects)
#   ./governance_report.sh [project_path]           # Single project report
#   ./governance_report.sh --quick                  # Structure only
#   ./governance_report.sh --save                   # Save to AUDIT_LOG.md
#
# Combines:
#   - Layer 1: Structure (governance_test.sh)
#   - Layer 2: Process (governance_audit.sh)
#   - Layer 5: .claude/ sync (governance_claude_sync.sh)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Script locations
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GOVERNANCE_DIR="$(dirname "$SCRIPT_DIR")"
AUDIT_LOG="$GOVERNANCE_DIR/registry/AUDIT_LOG.md"

# Parse arguments
MODE="full"
SAVE_REPORT=false
PROJECT_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --quick)
            MODE="quick"
            shift
            ;;
        --save)
            SAVE_REPORT=true
            shift
            ;;
        *)
            PROJECT_PATH="$1"
            shift
            ;;
    esac
done

# Report date
REPORT_DATE=$(date '+%Y-%m-%d')
REPORT_TIME=$(date '+%H:%M')

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           GOVERNANCE REPORT - $REPORT_DATE $REPORT_TIME            ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════

run_structure_test() {
    local project="$1"
    local output

    if [[ -f "$SCRIPT_DIR/governance_test.sh" ]]; then
        output=$("$SCRIPT_DIR/governance_test.sh" "$project" 2>&1 | grep -E "TOTAL SCORE|PASS|FAIL" | tail -1)
        echo "$output" | grep -oE "[0-9]+" | head -1
    else
        echo "N/A"
    fi
}

run_process_audit() {
    local project="$1"
    local output

    if [[ -f "$SCRIPT_DIR/governance_audit.sh" ]]; then
        output=$("$SCRIPT_DIR/governance_audit.sh" "$project" --daily 2>&1 | grep -E "AUDIT SCORE" | tail -1)
        echo "$output" | grep -oE "[0-9]+" | head -1
    else
        echo "N/A"
    fi
}

get_status_emoji() {
    local score="$1"

    if [[ "$score" == "N/A" ]]; then
        echo "⚪"
    elif [[ "$score" -ge 80 ]]; then
        echo "✅"
    elif [[ "$score" -ge 50 ]]; then
        echo "🟡"
    else
        echo "🔴"
    fi
}

get_status_text() {
    local score="$1"

    if [[ "$score" == "N/A" ]]; then
        echo "N/A"
    elif [[ "$score" -ge 80 ]]; then
        echo "HEALTHY"
    elif [[ "$score" -ge 50 ]]; then
        echo "ATTENTION"
    else
        echo "CRITICAL"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════
# SINGLE PROJECT REPORT
# ═══════════════════════════════════════════════════════════════════════════

report_single_project() {
    local project="$1"
    local project_name=$(basename "$project")

    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ PROJECT: $project_name"
    echo "├─────────────────────────────────────────────────────────────┤"

    # Run structure test
    echo -e "  ${CYAN}Running Layer 1: Structure Test...${NC}"
    local structure_score=$(run_structure_test "$project")

    # Run process audit
    echo -e "  ${CYAN}Running Layer 2: Process Audit...${NC}"
    local process_score=$(run_process_audit "$project")

    # Calculate overall
    local overall="N/A"
    if [[ "$structure_score" =~ ^[0-9]+$ ]] && [[ "$process_score" =~ ^[0-9]+$ ]]; then
        overall=$(( (structure_score * 60 / 100) + (process_score * 40 / 100) ))
    elif [[ "$structure_score" =~ ^[0-9]+$ ]]; then
        overall="$structure_score"
    fi

    echo ""
    echo "  ┌───────────────────┬────────┬───────────┐"
    echo "  │ Layer             │ Score  │ Status    │"
    echo "  ├───────────────────┼────────┼───────────┤"
    printf "  │ %-17s │ %5s%% │ %-9s │\n" "Structure (L1)" "$structure_score" "$(get_status_text $structure_score)"
    printf "  │ %-17s │ %5s%% │ %-9s │\n" "Process (L2)" "$process_score" "$(get_status_text $process_score)"
    printf "  │ %-17s │ %5s%% │ %-9s │\n" "Runtime (L3)" "N/A" "N/A"
    echo "  ├───────────────────┼────────┼───────────┤"
    printf "  │ %-17s │ %5s%% │ %-9s │\n" "OVERALL" "$overall" "$(get_status_text $overall)"
    echo "  └───────────────────┴────────┴───────────┘"

    echo "└─────────────────────────────────────────────────────────────┘"
}

# ═══════════════════════════════════════════════════════════════════════════
# MULTI-PROJECT REPORT
# ═══════════════════════════════════════════════════════════════════════════

report_all_projects() {
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ GOVERNANCE SCORECARD                                        │"
    echo "├─────────────────────────────────────────────────────────────┤"
    echo ""

    # Define projects to check
    local projects=(
        "$GOVERNANCE_DIR"
        "$HOME/Desktop/FILICITI/Products/COEVOLVE/code"
        "$HOME/Desktop/FILICITI/Products/COEVOLVE/businessplan"
        "$HOME/Desktop/FILICITI/Products/LABS"
    )

    echo "  ┌──────────────────────────┬───────────┬──────────┬─────────┐"
    echo "  │ Project                  │ Structure │ Process  │ Overall │"
    echo "  ├──────────────────────────┼───────────┼──────────┼─────────┤"

    local total_structure=0
    local total_process=0
    local total_overall=0
    local count=0

    for project in "${projects[@]}"; do
        if [[ -d "$project" ]]; then
            local name=$(basename "$project")
            local parent=$(basename "$(dirname "$project")")

            # Combine name for nested projects
            if [[ "$parent" != "Desktop" ]] && [[ "$parent" != "Products" ]]; then
                name="$parent/$name"
            fi

            # Truncate long names
            if [[ ${#name} -gt 24 ]]; then
                name="${name:0:21}..."
            fi

            local structure=$(run_structure_test "$project")
            local process=$(run_process_audit "$project")

            local overall="N/A"
            if [[ "$structure" =~ ^[0-9]+$ ]] && [[ "$process" =~ ^[0-9]+$ ]]; then
                overall=$(( (structure * 60 / 100) + (process * 40 / 100) ))
                total_structure=$((total_structure + structure))
                total_process=$((total_process + process))
                total_overall=$((total_overall + overall))
                count=$((count + 1))
            elif [[ "$structure" =~ ^[0-9]+$ ]]; then
                overall="$structure"
            fi

            printf "  │ %-24s │ %7s%% │ %6s%% │ %5s%% │\n" "$name" "$structure" "$process" "$overall"
        fi
    done

    echo "  ├──────────────────────────┼───────────┼──────────┼─────────┤"

    # Averages
    if [[ "$count" -gt 0 ]]; then
        local avg_structure=$((total_structure / count))
        local avg_process=$((total_process / count))
        local avg_overall=$((total_overall / count))
        printf "  │ %-24s │ %7s%% │ %6s%% │ %5s%% │\n" "AVERAGE" "$avg_structure" "$avg_process" "$avg_overall"
    fi

    echo "  └──────────────────────────┴───────────┴──────────┴─────────┘"
    echo ""
    echo "└─────────────────────────────────────────────────────────────┘"
}

# ═══════════════════════════════════════════════════════════════════════════
# CLAUDE SYNC SUMMARY
# ═══════════════════════════════════════════════════════════════════════════

show_claude_summary() {
    echo ""
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ .CLAUDE/ INTEGRATION SUMMARY                                │"
    echo "├─────────────────────────────────────────────────────────────┤"

    if [[ -f "$SCRIPT_DIR/governance_claude_sync.sh" ]]; then
        # Quick session count
        if [[ -f "$HOME/.claude/history.jsonl" ]]; then
            local week_ago=$(($(date +%s) - 604800))
            local week_ago_ms=$((week_ago * 1000))

            if command -v jq &> /dev/null; then
                local sessions_week=$(jq -r "select(.timestamp > $week_ago_ms) | .sessionId" "$HOME/.claude/history.jsonl" 2>/dev/null | sort -u | wc -l | tr -d ' ')
                echo "  Sessions (last 7 days): $sessions_week"
            fi
        fi

        # Plan progress
        local latest_plan=$(ls -t "$HOME/.claude/plans"/*.md 2>/dev/null | head -1)
        if [[ -n "$latest_plan" ]]; then
            local checked=$(grep -c "\[x\]" "$latest_plan" 2>/dev/null || echo "0")
            local unchecked=$(grep -c "\[ \]" "$latest_plan" 2>/dev/null || echo "0")
            local total=$((checked + unchecked))
            if [[ "$total" -gt 0 ]]; then
                local progress=$((checked * 100 / total))
                echo "  Plan Progress: $progress% ($checked/$total tasks)"
            fi
        fi

        # Layer 3 status
        if [[ -f "$HOME/.claude/CLAUDE.md" ]]; then
            echo -e "  Layer 3: ${GREEN}Active${NC}"
        else
            echo -e "  Layer 3: ${YELLOW}Not configured${NC}"
        fi
    fi

    echo "└─────────────────────────────────────────────────────────────┘"
}

# ═══════════════════════════════════════════════════════════════════════════
# RECOMMENDATIONS
# ═══════════════════════════════════════════════════════════════════════════

show_recommendations() {
    echo ""
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ RECOMMENDATIONS                                             │"
    echo "├─────────────────────────────────────────────────────────────┤"

    local recs=()

    # Check for stale CONTEXT.md files
    for project in "$GOVERNANCE_DIR" "$HOME/Desktop/FILICITI/Products/"*/*; do
        if [[ -f "$project/CONTEXT.md" ]]; then
            local last=$(grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" "$project/CONTEXT.md" | head -1)
            # Simple staleness check
            if [[ -n "$last" ]] && [[ "$last" < "$(date -v-7d '+%Y-%m-%d' 2>/dev/null || date -d '7 days ago' '+%Y-%m-%d' 2>/dev/null)" ]]; then
                recs+=("Update CONTEXT.md in $(basename $project)")
            fi
        fi
    done

    # Check for missing Conversations/
    if [[ ! -d "$GOVERNANCE_DIR/Conversations" ]]; then
        recs+=("Create Conversations/ folder for session dumps")
    fi

    # Check Layer 3
    if [[ ! -f "$HOME/.claude/CLAUDE.md" ]]; then
        recs+=("Create ~/.claude/CLAUDE.md for Layer 3 rules")
    fi

    if [[ ${#recs[@]} -eq 0 ]]; then
        echo -e "  ${GREEN}✓${NC} No immediate recommendations"
    else
        for rec in "${recs[@]}"; do
            echo -e "  ${CYAN}→${NC} $rec"
        done
    fi

    echo "└─────────────────────────────────────────────────────────────┘"
}

# ═══════════════════════════════════════════════════════════════════════════
# SAVE TO AUDIT_LOG
# ═══════════════════════════════════════════════════════════════════════════

save_to_audit_log() {
    if [[ ! -f "$AUDIT_LOG" ]]; then
        mkdir -p "$(dirname "$AUDIT_LOG")"
        echo "# Governance Audit Log" > "$AUDIT_LOG"
        echo "" >> "$AUDIT_LOG"
        echo "Historical record of governance audits." >> "$AUDIT_LOG"
        echo "" >> "$AUDIT_LOG"
    fi

    echo "" >> "$AUDIT_LOG"
    echo "## Audit: $REPORT_DATE $REPORT_TIME" >> "$AUDIT_LOG"
    echo "" >> "$AUDIT_LOG"
    echo "| Project | Structure | Process | Overall |" >> "$AUDIT_LOG"
    echo "|---------|-----------|---------|---------|" >> "$AUDIT_LOG"

    # Add each project
    for project in "$GOVERNANCE_DIR" "$HOME/Desktop/FILICITI/Products/"*/*; do
        if [[ -d "$project" ]] && [[ -f "$project/CLAUDE.md" ]]; then
            local name=$(basename "$project")
            local structure=$(run_structure_test "$project")
            local process=$(run_process_audit "$project")
            local overall="N/A"
            if [[ "$structure" =~ ^[0-9]+$ ]] && [[ "$process" =~ ^[0-9]+$ ]]; then
                overall=$(( (structure * 60 / 100) + (process * 40 / 100) ))
            fi
            echo "| $name | $structure% | $process% | $overall% |" >> "$AUDIT_LOG"
        fi
    done

    echo "" >> "$AUDIT_LOG"
    echo -e "${GREEN}✓${NC} Report saved to $AUDIT_LOG"
}

# ═══════════════════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ═══════════════════════════════════════════════════════════════════════════

if [[ -n "$PROJECT_PATH" ]]; then
    report_single_project "$PROJECT_PATH"
else
    report_all_projects
    show_claude_summary
    show_recommendations
fi

if [[ "$SAVE_REPORT" == true ]]; then
    save_to_audit_log
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  Report complete. Run with --save to append to AUDIT_LOG.md  ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
