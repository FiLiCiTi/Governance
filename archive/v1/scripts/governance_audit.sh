#!/bin/bash
# governance_audit.sh
# Layer 2: Process compliance testing
#
# Usage:
#   ./governance_audit.sh [project_path]              # Full audit
#   ./governance_audit.sh [project_path] --daily      # Daily checks only
#   ./governance_audit.sh [project_path] --weekly     # Weekly checks only
#   ./governance_audit.sh [project_path] --rule "table-formatting"
#   ./governance_audit.sh [project_path] --section "General Rules"
#
# Checks:
#   DAILY:  Freshness (CONTEXT.md, SESSION_LOG.md), Decision IDs
#   WEEKLY: Cross-references, Workflow adherence, Conversation dumps

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Scoring weights
WEIGHT_FRESHNESS=30
WEIGHT_CONTENT=40
WEIGHT_WORKFLOW=30

# Parse arguments
PROJECT_PATH="."
MODE="full"
RULE_CHECK=""
SECTION_CHECK=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --daily)
            MODE="daily"
            shift
            ;;
        --weekly)
            MODE="weekly"
            shift
            ;;
        --rule)
            RULE_CHECK="$2"
            MODE="rule"
            shift 2
            ;;
        --section)
            SECTION_CHECK="$2"
            MODE="section"
            shift 2
            ;;
        *)
            PROJECT_PATH="$1"
            shift
            ;;
    esac
done

cd "$PROJECT_PATH"
PROJECT_NAME=$(basename "$(pwd)")

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  GOVERNANCE AUDIT - Layer 2: Process Compliance"
echo "  Project: $PROJECT_NAME"
echo "  Path: $(pwd)"
echo "  Mode: $MODE"
echo "  Date: $(date '+%Y-%m-%d %H:%M')"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Initialize scores
SCORE_FRESHNESS=0
SCORE_CONTENT=0
SCORE_WORKFLOW=0
ISSUES=()
RECOMMENDATIONS=()

# ═══════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════

days_since() {
    local date_str="$1"
    if [[ -z "$date_str" ]]; then
        echo "999"
        return
    fi

    # Try to parse various date formats
    local file_date
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        file_date=$(date -j -f "%Y-%m-%d" "$date_str" "+%s" 2>/dev/null || echo "0")
    else
        # Linux
        file_date=$(date -d "$date_str" "+%s" 2>/dev/null || echo "0")
    fi

    if [[ "$file_date" == "0" ]]; then
        echo "999"
        return
    fi

    local now=$(date "+%s")
    local diff=$(( (now - file_date) / 86400 ))
    echo "$diff"
}

extract_date() {
    local file="$1"
    local pattern="$2"

    if [[ -f "$file" ]]; then
        grep -oE "$pattern" "$file" 2>/dev/null | head -1 | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" || echo ""
    else
        echo ""
    fi
}

# ═══════════════════════════════════════════════════════════════════════════
# PER-RULE COMPLIANCE CHECK
# ═══════════════════════════════════════════════════════════════════════════

check_rule() {
    local rule="$1"

    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ RULE CHECK: $rule"
    echo "├─────────────────────────────────────────────────────────────┤"

    case "$rule" in
        "table-formatting")
            echo -e "  ${CYAN}Checking table alignment in recent outputs...${NC}"
            # Check if tables have consistent column widths
            if [[ -d "Conversations" ]]; then
                local latest=$(ls -t Conversations/*.md 2>/dev/null | head -1)
                if [[ -n "$latest" ]]; then
                    # Count tables and check for pipe alignment
                    local tables=$(grep -c "^|" "$latest" 2>/dev/null || echo "0")
                    if [[ "$tables" -gt 0 ]]; then
                        # Check if pipes are aligned (rough check)
                        local aligned=$(grep "^|" "$latest" | awk -F'|' '{print NF}' | sort -u | wc -l)
                        if [[ "$aligned" -le 2 ]]; then
                            echo -e "  ${GREEN}✓${NC} Tables appear aligned ($tables rows found)"
                        else
                            echo -e "  ${YELLOW}○${NC} Tables may have inconsistent columns"
                            ISSUES+=("Table formatting inconsistent in $latest")
                        fi
                    else
                        echo -e "  ${CYAN}i${NC} No tables found in recent conversation"
                    fi
                fi
            else
                echo -e "  ${CYAN}i${NC} No Conversations/ folder"
            fi
            ;;

        "read-before-edit")
            echo -e "  ${CYAN}Checking tool call patterns...${NC}"
            # Would need debug logs or history.jsonl for this
            if [[ -f "$HOME/.claude/history.jsonl" ]]; then
                echo -e "  ${CYAN}i${NC} Would analyze ~/.claude/history.jsonl for Read→Edit sequences"
                echo -e "  ${YELLOW}○${NC} Full implementation requires history parsing"
            fi
            ;;

        "date-usage")
            echo -e "  ${CYAN}Checking for correct year (2026)...${NC}"
            local wrong_year=0
            for file in CONTEXT.md SESSION_LOG.md PLAN.md; do
                if [[ -f "$file" ]]; then
                    local count=$(grep -c "2025" "$file" 2>/dev/null || echo "0")
                    if [[ "$count" -gt 0 ]]; then
                        echo -e "  ${RED}✗${NC} Found 2025 in $file ($count occurrences)"
                        wrong_year=$((wrong_year + count))
                    fi
                fi
            done
            if [[ "$wrong_year" -eq 0 ]]; then
                echo -e "  ${GREEN}✓${NC} All dates use 2026"
            else
                ISSUES+=("Wrong year (2025) found in $wrong_year places")
            fi
            ;;

        "decision-ids")
            echo -e "  ${CYAN}Checking decision ID format...${NC}"
            if [[ -f "SESSION_LOG.md" ]]; then
                local valid=$(grep -cE "#[A-Z]+[0-9]+" SESSION_LOG.md 2>/dev/null || echo "0")
                local invalid=$(grep -cE "#[a-z]|#[0-9]" SESSION_LOG.md 2>/dev/null || echo "0")
                echo -e "  ${GREEN}✓${NC} Valid IDs found: $valid"
                if [[ "$invalid" -gt 0 ]]; then
                    echo -e "  ${YELLOW}○${NC} Potentially malformed IDs: $invalid"
                fi
            fi
            ;;

        "token-efficiency")
            echo -e "  ${CYAN}Checking output brevity...${NC}"
            if [[ -d "Conversations" ]]; then
                local latest=$(ls -t Conversations/*.md 2>/dev/null | head -1)
                if [[ -n "$latest" ]]; then
                    local lines=$(wc -l < "$latest")
                    if [[ "$lines" -gt 1000 ]]; then
                        echo -e "  ${YELLOW}○${NC} Large conversation file: $lines lines"
                        RECOMMENDATIONS+=("Consider more concise outputs")
                    else
                        echo -e "  ${GREEN}✓${NC} Conversation file reasonable: $lines lines"
                    fi
                fi
            fi
            ;;

        *)
            echo -e "  ${RED}Unknown rule: $rule${NC}"
            echo "  Available rules:"
            echo "    - table-formatting"
            echo "    - read-before-edit"
            echo "    - date-usage"
            echo "    - decision-ids"
            echo "    - token-efficiency"
            ;;
    esac

    echo "└─────────────────────────────────────────────────────────────┘"
}

# ═══════════════════════════════════════════════════════════════════════════
# PER-SECTION CHECK
# ═══════════════════════════════════════════════════════════════════════════

check_section() {
    local section="$1"

    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ SECTION CHECK: $section"
    echo "├─────────────────────────────────────────────────────────────┤"

    if [[ ! -f "CLAUDE.md" ]]; then
        echo -e "  ${RED}✗${NC} CLAUDE.md not found"
        return
    fi

    # Extract section from CLAUDE.md
    local in_section=false
    local rules=()

    while IFS= read -r line; do
        if [[ "$line" =~ ^##[[:space:]]+"$section" ]]; then
            in_section=true
            continue
        fi
        if [[ "$in_section" == true ]] && [[ "$line" =~ ^## ]]; then
            break
        fi
        if [[ "$in_section" == true ]] && [[ "$line" =~ ^[0-9]+\. ]]; then
            rules+=("$line")
        fi
    done < CLAUDE.md

    if [[ ${#rules[@]} -eq 0 ]]; then
        echo -e "  ${YELLOW}○${NC} Section '$section' not found or has no numbered rules"
        echo "  Available sections:"
        grep "^## " CLAUDE.md | sed 's/## /    - /'
    else
        echo -e "  ${GREEN}Found ${#rules[@]} rules in section${NC}"
        echo ""
        for rule in "${rules[@]}"; do
            echo -e "  ${CYAN}•${NC} $rule"
        done
    fi

    echo "└─────────────────────────────────────────────────────────────┘"
}

# ═══════════════════════════════════════════════════════════════════════════
# FRESHNESS TESTS (DAILY)
# ═══════════════════════════════════════════════════════════════════════════

run_freshness_tests() {
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ FRESHNESS TESTS (Daily)                   Weight: ${WEIGHT_FRESHNESS}%      │"
    echo "├─────────────────────────────────────────────────────────────┤"

    local tests_passed=0
    local tests_total=4

    # Test 1: CONTEXT.md freshness
    if [[ -f "CONTEXT.md" ]]; then
        local last_updated=$(extract_date "CONTEXT.md" "Last Updated:.*[0-9]{4}-[0-9]{2}-[0-9]{2}")
        local days=$(days_since "$last_updated")

        if [[ "$days" -le 7 ]]; then
            echo -e "  ${GREEN}✓${NC} CONTEXT.md updated $days days ago"
            tests_passed=$((tests_passed + 1))
        elif [[ "$days" -le 14 ]]; then
            echo -e "  ${YELLOW}○${NC} CONTEXT.md updated $days days ago (stale)"
            RECOMMENDATIONS+=("Update CONTEXT.md - last updated $days days ago")
        else
            echo -e "  ${RED}✗${NC} CONTEXT.md outdated ($days days)"
            ISSUES+=("CONTEXT.md not updated in $days days")
        fi
    else
        echo -e "  ${RED}✗${NC} CONTEXT.md not found"
        ISSUES+=("CONTEXT.md missing")
    fi

    # Test 2: SESSION_LOG.md activity
    if [[ -f "SESSION_LOG.md" ]]; then
        local last_session=$(grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" SESSION_LOG.md | tail -1)
        local days=$(days_since "$last_session")

        if [[ "$days" -le 14 ]]; then
            echo -e "  ${GREEN}✓${NC} SESSION_LOG.md active ($days days ago)"
            tests_passed=$((tests_passed + 1))
        elif [[ "$days" -le 30 ]]; then
            echo -e "  ${YELLOW}○${NC} SESSION_LOG.md inactive ($days days)"
        else
            echo -e "  ${RED}✗${NC} SESSION_LOG.md very stale ($days days)"
            ISSUES+=("No session activity in $days days")
        fi
    else
        echo -e "  ${YELLOW}○${NC} SESSION_LOG.md not found"
    fi

    # Test 3: Conversations folder
    if [[ -d "Conversations" ]]; then
        local latest=$(ls -t Conversations/*.md 2>/dev/null | head -1)
        if [[ -n "$latest" ]]; then
            local file_date=$(stat -f "%Sm" -t "%Y-%m-%d" "$latest" 2>/dev/null || stat -c "%y" "$latest" 2>/dev/null | cut -d' ' -f1)
            local days=$(days_since "$file_date")

            if [[ "$days" -le 7 ]]; then
                echo -e "  ${GREEN}✓${NC} Recent conversation dump ($days days ago)"
                tests_passed=$((tests_passed + 1))
            else
                echo -e "  ${YELLOW}○${NC} No recent conversation dumps ($days days)"
            fi
        else
            echo -e "  ${YELLOW}○${NC} Conversations/ empty"
        fi
    else
        echo -e "  ${CYAN}i${NC} No Conversations/ folder"
        tests_passed=$((tests_passed + 1))  # Optional, don't penalize
    fi

    # Test 4: Plan file sync
    if [[ -f "PLAN.md" ]]; then
        local plan_ref=$(grep -oE "~/.claude/plans/[a-z-]+\.md" PLAN.md | head -1)
        if [[ -n "$plan_ref" ]]; then
            local plan_file="${plan_ref/#\~/$HOME}"
            if [[ -f "$plan_file" ]]; then
                local checked=$(grep -c "\[x\]" "$plan_file" 2>/dev/null || echo "0")
                local unchecked=$(grep -c "\[ \]" "$plan_file" 2>/dev/null || echo "0")
                echo -e "  ${GREEN}✓${NC} Plan file tracked: $checked done, $unchecked pending"
                tests_passed=$((tests_passed + 1))
            else
                echo -e "  ${YELLOW}○${NC} Plan file referenced but not found"
            fi
        else
            echo -e "  ${CYAN}i${NC} No active plan referenced"
            tests_passed=$((tests_passed + 1))  # Optional
        fi
    else
        echo -e "  ${CYAN}i${NC} No PLAN.md file"
        tests_passed=$((tests_passed + 1))  # Optional
    fi

    SCORE_FRESHNESS=$((tests_passed * 100 / tests_total))
    echo "├─────────────────────────────────────────────────────────────┤"
    echo -e "│ Freshness Score: ${SCORE_FRESHNESS}%                                       │"
    echo "└─────────────────────────────────────────────────────────────┘"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════
# CONTENT QUALITY TESTS (DAILY)
# ═══════════════════════════════════════════════════════════════════════════

run_content_tests() {
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ CONTENT QUALITY TESTS (Daily)              Weight: ${WEIGHT_CONTENT}%      │"
    echo "├─────────────────────────────────────────────────────────────┤"

    local tests_passed=0
    local tests_total=4

    # Test 1: Decision IDs in SESSION_LOG
    if [[ -f "SESSION_LOG.md" ]]; then
        local id_count=$(grep -cE "#[A-Z]+[0-9]+" SESSION_LOG.md 2>/dev/null || echo "0")
        if [[ "$id_count" -gt 0 ]]; then
            echo -e "  ${GREEN}✓${NC} Decision IDs found: $id_count"
            tests_passed=$((tests_passed + 1))
        else
            echo -e "  ${YELLOW}○${NC} No decision IDs in SESSION_LOG.md"
            RECOMMENDATIONS+=("Add decision IDs (#G1, #P1, etc.) to SESSION_LOG.md")
        fi
    else
        echo -e "  ${CYAN}i${NC} SESSION_LOG.md not found"
    fi

    # Test 2: Cross-reference (CONTEXT.md decisions → SESSION_LOG.md)
    if [[ -f "CONTEXT.md" ]] && [[ -f "SESSION_LOG.md" ]]; then
        local context_ids=$(grep -oE "#[A-Z]+[0-9]+" CONTEXT.md 2>/dev/null | sort -u)
        local missing=0

        for id in $context_ids; do
            if ! grep -q "$id" SESSION_LOG.md 2>/dev/null; then
                missing=$((missing + 1))
            fi
        done

        if [[ "$missing" -eq 0 ]] && [[ -n "$context_ids" ]]; then
            echo -e "  ${GREEN}✓${NC} All CONTEXT.md decision IDs found in SESSION_LOG"
            tests_passed=$((tests_passed + 1))
        elif [[ -z "$context_ids" ]]; then
            echo -e "  ${CYAN}i${NC} No decision IDs in CONTEXT.md to cross-reference"
            tests_passed=$((tests_passed + 1))
        else
            echo -e "  ${YELLOW}○${NC} $missing decision IDs in CONTEXT.md not in SESSION_LOG"
        fi
    else
        echo -e "  ${CYAN}i${NC} Missing files for cross-reference check"
        tests_passed=$((tests_passed + 1))
    fi

    # Test 3: Blocker tracking
    if [[ -f "CONTEXT.md" ]]; then
        local has_blocker=$(grep -qi "blocker" CONTEXT.md && echo "yes" || echo "no")
        local in_next_steps=$(grep -A10 "Next Steps" CONTEXT.md | grep -qi "blocker" && echo "yes" || echo "no")

        if [[ "$has_blocker" == "no" ]]; then
            echo -e "  ${GREEN}✓${NC} No blockers documented"
            tests_passed=$((tests_passed + 1))
        elif [[ "$in_next_steps" == "yes" ]]; then
            echo -e "  ${GREEN}✓${NC} Blocker documented and in Next Steps"
            tests_passed=$((tests_passed + 1))
        else
            echo -e "  ${YELLOW}○${NC} Blocker exists but may not be in Next Steps"
        fi
    else
        echo -e "  ${CYAN}i${NC} CONTEXT.md not found"
        tests_passed=$((tests_passed + 1))
    fi

    # Test 4: Phase tracking
    if [[ -f "CONTEXT.md" ]]; then
        if grep -qE "Phase:|## Current State" CONTEXT.md 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} Phase/state documented"
            tests_passed=$((tests_passed + 1))
        else
            echo -e "  ${YELLOW}○${NC} Current phase not clearly documented"
            RECOMMENDATIONS+=("Add current phase to CONTEXT.md")
        fi
    else
        echo -e "  ${CYAN}i${NC} CONTEXT.md not found"
    fi

    SCORE_CONTENT=$((tests_passed * 100 / tests_total))
    echo "├─────────────────────────────────────────────────────────────┤"
    echo -e "│ Content Quality Score: ${SCORE_CONTENT}%                                  │"
    echo "└─────────────────────────────────────────────────────────────┘"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════
# WORKFLOW ADHERENCE TESTS (WEEKLY)
# ═══════════════════════════════════════════════════════════════════════════

run_workflow_tests() {
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ WORKFLOW ADHERENCE TESTS (Weekly)         Weight: ${WEIGHT_WORKFLOW}%      │"
    echo "├─────────────────────────────────────────────────────────────┤"

    local tests_passed=0
    local tests_total=3

    # Test 1: Warm-up markers in conversations
    if [[ -d "Conversations" ]]; then
        local warmup_count=$(grep -rl "Warm-up:" Conversations/*.md 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$warmup_count" -gt 0 ]]; then
            echo -e "  ${GREEN}✓${NC} Warm-up protocol used in $warmup_count files"
            tests_passed=$((tests_passed + 1))
        else
            echo -e "  ${YELLOW}○${NC} No warm-up markers found in Conversations/"
            RECOMMENDATIONS+=("Use warm-up protocol during long sessions")
        fi
    else
        echo -e "  ${CYAN}i${NC} No Conversations/ folder"
        tests_passed=$((tests_passed + 1))
    fi

    # Test 2: Boundary declarations
    if [[ -f "CLAUDE.md" ]]; then
        if grep -q "CAN modify:" CLAUDE.md 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} Boundaries defined in CLAUDE.md"
            tests_passed=$((tests_passed + 1))
        else
            echo -e "  ${YELLOW}○${NC} No explicit boundaries in CLAUDE.md"
            RECOMMENDATIONS+=("Add 'CAN modify:' and 'CANNOT modify:' to CLAUDE.md")
        fi
    else
        echo -e "  ${RED}✗${NC} CLAUDE.md not found"
        ISSUES+=("CLAUDE.md missing - no boundary enforcement")
    fi

    # Test 3: Date confirmation in sessions
    if [[ -d "Conversations" ]]; then
        local latest=$(ls -t Conversations/*.md 2>/dev/null | head -1)
        if [[ -n "$latest" ]]; then
            if grep -qE "Today is [0-9]{4}-[0-9]{2}-[0-9]{2}|Date: [0-9]{4}" "$latest" 2>/dev/null; then
                echo -e "  ${GREEN}✓${NC} Date confirmed in recent session"
                tests_passed=$((tests_passed + 1))
            else
                echo -e "  ${YELLOW}○${NC} Date not confirmed in latest session"
            fi
        fi
    else
        echo -e "  ${CYAN}i${NC} No Conversations/ folder"
        tests_passed=$((tests_passed + 1))
    fi

    SCORE_WORKFLOW=$((tests_passed * 100 / tests_total))
    echo "├─────────────────────────────────────────────────────────────┤"
    echo -e "│ Workflow Adherence Score: ${SCORE_WORKFLOW}%                              │"
    echo "└─────────────────────────────────────────────────────────────┘"
    echo ""
}

# ═══════════════════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ═══════════════════════════════════════════════════════════════════════════

case "$MODE" in
    "rule")
        check_rule "$RULE_CHECK"
        ;;
    "section")
        check_section "$SECTION_CHECK"
        ;;
    "daily")
        run_freshness_tests
        run_content_tests
        ;;
    "weekly")
        run_freshness_tests
        run_content_tests
        run_workflow_tests
        ;;
    "full")
        run_freshness_tests
        run_content_tests
        run_workflow_tests
        ;;
esac

# Skip summary for rule/section checks
if [[ "$MODE" != "rule" ]] && [[ "$MODE" != "section" ]]; then
    # Calculate weighted total
    WEIGHTED_TOTAL=$(( \
        (SCORE_FRESHNESS * WEIGHT_FRESHNESS / 100) + \
        (SCORE_CONTENT * WEIGHT_CONTENT / 100) + \
        (SCORE_WORKFLOW * WEIGHT_WORKFLOW / 100) \
    ))

    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ AUDIT SUMMARY                                               │"
    echo "├─────────────────────────────────────────────────────────────┤"
    printf "│ %-25s %3d%% × %2d%% = %3d pts            │\n" "Freshness" "$SCORE_FRESHNESS" "$WEIGHT_FRESHNESS" "$((SCORE_FRESHNESS * WEIGHT_FRESHNESS / 100))"
    printf "│ %-25s %3d%% × %2d%% = %3d pts            │\n" "Content Quality" "$SCORE_CONTENT" "$WEIGHT_CONTENT" "$((SCORE_CONTENT * WEIGHT_CONTENT / 100))"
    printf "│ %-25s %3d%% × %2d%% = %3d pts            │\n" "Workflow Adherence" "$SCORE_WORKFLOW" "$WEIGHT_WORKFLOW" "$((SCORE_WORKFLOW * WEIGHT_WORKFLOW / 100))"
    echo "├─────────────────────────────────────────────────────────────┤"

    PASS_THRESHOLD=70
    if [[ "$WEIGHTED_TOTAL" -ge "$PASS_THRESHOLD" ]]; then
        echo -e "│ ${GREEN}AUDIT SCORE: ${WEIGHTED_TOTAL}/100 - HEALTHY${NC}                           │"
        RESULT="HEALTHY"
    elif [[ "$WEIGHTED_TOTAL" -ge 50 ]]; then
        echo -e "│ ${YELLOW}AUDIT SCORE: ${WEIGHTED_TOTAL}/100 - NEEDS ATTENTION${NC}                  │"
        RESULT="ATTENTION"
    else
        echo -e "│ ${RED}AUDIT SCORE: ${WEIGHTED_TOTAL}/100 - CRITICAL${NC}                         │"
        RESULT="CRITICAL"
    fi
    echo "└─────────────────────────────────────────────────────────────┘"
    echo ""

    # Issues
    if [[ ${#ISSUES[@]} -gt 0 ]]; then
        echo "┌─────────────────────────────────────────────────────────────┐"
        echo "│ ISSUES FOUND                                                │"
        echo "├─────────────────────────────────────────────────────────────┤"
        for issue in "${ISSUES[@]}"; do
            echo -e "│ ${RED}•${NC} $issue"
        done
        echo "└─────────────────────────────────────────────────────────────┘"
        echo ""
    fi

    # Recommendations
    if [[ ${#RECOMMENDATIONS[@]} -gt 0 ]]; then
        echo "┌─────────────────────────────────────────────────────────────┐"
        echo "│ RECOMMENDATIONS                                             │"
        echo "├─────────────────────────────────────────────────────────────┤"
        for rec in "${RECOMMENDATIONS[@]}"; do
            echo -e "│ ${CYAN}→${NC} $rec"
        done
        echo "└─────────────────────────────────────────────────────────────┘"
        echo ""
    fi

    # JSON output
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ JSON OUTPUT                                                 │"
    echo "├─────────────────────────────────────────────────────────────┤"
    cat << EOF
{
  "project": "$PROJECT_NAME",
  "path": "$(pwd)",
  "date": "$(date -Iseconds)",
  "mode": "$MODE",
  "score": $WEIGHTED_TOTAL,
  "result": "$RESULT",
  "breakdown": {
    "freshness": $SCORE_FRESHNESS,
    "content": $SCORE_CONTENT,
    "workflow": $SCORE_WORKFLOW
  },
  "issues": ${#ISSUES[@]},
  "recommendations": ${#RECOMMENDATIONS[@]}
}
EOF
    echo "└─────────────────────────────────────────────────────────────┘"
fi
