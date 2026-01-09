#!/bin/bash
# governance_test.sh
# Automated governance compliance testing with scoring
#
# Usage: ./scripts/governance_test.sh [project_path]
# Example: ./scripts/governance_test.sh ~/Desktop/FILICITI/Products/COEVOLVE/code

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Scoring weights (must sum to 100)
WEIGHT_CLAUDE_MD=20
WEIGHT_CONTEXT_MD=15
WEIGHT_SESSION_LOG=15
WEIGHT_SYMLINKS=20
WEIGHT_PRECOMMIT=15
WEIGHT_LAYER3=10
WEIGHT_PLAN_MD=5

# Default to current directory if no path provided
PROJECT_PATH="${1:-.}"
cd "$PROJECT_PATH"
PROJECT_NAME=$(basename "$(pwd)")

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  GOVERNANCE COMPLIANCE TEST"
echo "  Project: $PROJECT_NAME"
echo "  Path: $(pwd)"
echo "  Date: $(date '+%Y-%m-%d %H:%M')"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Initialize scores
SCORE_CLAUDE_MD=0
SCORE_CONTEXT_MD=0
SCORE_SESSION_LOG=0
SCORE_SYMLINKS=0
SCORE_PRECOMMIT=0
SCORE_LAYER3=0
SCORE_PLAN_MD=0

TOTAL_TESTS=0
PASSED_TESTS=0

# Function to run a test
run_test() {
    local test_name="$1"
    local condition="$2"
    local weight_var="$3"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    if eval "$condition"; then
        echo -e "  ${GREEN}✓${NC} $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        eval "$weight_var=100"
        return 0
    else
        echo -e "  ${RED}✗${NC} $test_name"
        eval "$weight_var=0"
        return 1
    fi
}

# Function to run a partial test (can score 0-100)
run_partial_test() {
    local test_name="$1"
    local score="$2"
    local weight_var="$3"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    eval "$weight_var=$score"

    if [ "$score" -eq 100 ]; then
        echo -e "  ${GREEN}✓${NC} $test_name (100%)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    elif [ "$score" -ge 50 ]; then
        echo -e "  ${YELLOW}○${NC} $test_name (${score}%)"
    else
        echo -e "  ${RED}✗${NC} $test_name (${score}%)"
    fi
}

echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ TEST 1: CLAUDE.md (Weight: ${WEIGHT_CLAUDE_MD}%)                          │"
echo "├─────────────────────────────────────────────────────────────┤"

if [ -f "CLAUDE.md" ]; then
    # Check for required sections
    SECTIONS_FOUND=0
    SECTIONS_REQUIRED=5

    grep -q "^# " CLAUDE.md 2>/dev/null && SECTIONS_FOUND=$((SECTIONS_FOUND + 1))
    grep -q "## Overview\|## Boundaries" CLAUDE.md 2>/dev/null && SECTIONS_FOUND=$((SECTIONS_FOUND + 1))
    grep -q "## General Rules\|## Rules" CLAUDE.md 2>/dev/null && SECTIONS_FOUND=$((SECTIONS_FOUND + 1))
    grep -q "Template:" CLAUDE.md 2>/dev/null && SECTIONS_FOUND=$((SECTIONS_FOUND + 1))
    grep -q "Type:" CLAUDE.md 2>/dev/null && SECTIONS_FOUND=$((SECTIONS_FOUND + 1))

    SECTION_SCORE=$((SECTIONS_FOUND * 100 / SECTIONS_REQUIRED))
    run_partial_test "CLAUDE.md exists with required sections" "$SECTION_SCORE" "SCORE_CLAUDE_MD"
else
    run_test "CLAUDE.md exists" "false" "SCORE_CLAUDE_MD"
fi

echo "└─────────────────────────────────────────────────────────────┘"
echo ""

echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ TEST 2: CONTEXT.md (Weight: ${WEIGHT_CONTEXT_MD}%)                         │"
echo "├─────────────────────────────────────────────────────────────┤"

if [ -f "CONTEXT.md" ]; then
    # Check for required content
    CONTENT_FOUND=0
    CONTENT_REQUIRED=4

    grep -q "Current State\|## State" CONTEXT.md 2>/dev/null && CONTENT_FOUND=$((CONTENT_FOUND + 1))
    grep -q "Last Updated\|Updated:" CONTEXT.md 2>/dev/null && CONTENT_FOUND=$((CONTENT_FOUND + 1))
    grep -q "Next Steps\|## Next" CONTEXT.md 2>/dev/null && CONTENT_FOUND=$((CONTENT_FOUND + 1))
    # Check file is not empty (more than 50 bytes)
    [ $(wc -c < CONTEXT.md) -gt 50 ] && CONTENT_FOUND=$((CONTENT_FOUND + 1))

    CONTENT_SCORE=$((CONTENT_FOUND * 100 / CONTENT_REQUIRED))
    run_partial_test "CONTEXT.md exists with required content" "$CONTENT_SCORE" "SCORE_CONTEXT_MD"
else
    run_test "CONTEXT.md exists" "false" "SCORE_CONTEXT_MD"
fi

echo "└─────────────────────────────────────────────────────────────┘"
echo ""

echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ TEST 3: SESSION_LOG.md (Weight: ${WEIGHT_SESSION_LOG}%)                    │"
echo "├─────────────────────────────────────────────────────────────┤"

if [ -f "SESSION_LOG.md" ]; then
    # Check for session entries
    SESSION_COUNT=$(grep -c "^## Session:" SESSION_LOG.md 2>/dev/null || echo "0")

    if [ "$SESSION_COUNT" -ge 1 ]; then
        run_partial_test "SESSION_LOG.md with $SESSION_COUNT session(s)" "100" "SCORE_SESSION_LOG"
    else
        # File exists but no sessions
        run_partial_test "SESSION_LOG.md exists (no sessions yet)" "50" "SCORE_SESSION_LOG"
    fi
else
    run_test "SESSION_LOG.md exists" "false" "SCORE_SESSION_LOG"
fi

echo "└─────────────────────────────────────────────────────────────┘"
echo ""

echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ TEST 4: Symlinks (Weight: ${WEIGHT_SYMLINKS}%)                             │"
echo "├─────────────────────────────────────────────────────────────┤"

SYMLINK_SCORE=0
SYMLINK_TESTS=0

# Check if this is inside _governance (symlinked setup)
if [ -d "_governance" ]; then
    echo -e "  ${CYAN}i${NC} Found _governance/ folder (wrapper repo pattern)"
    SYMLINK_TESTS=$((SYMLINK_TESTS + 1))

    # Check if CLAUDE.md is a symlink or exists
    if [ -L "CLAUDE.md" ]; then
        if [ -e "CLAUDE.md" ]; then
            echo -e "  ${GREEN}✓${NC} CLAUDE.md symlink resolves correctly"
            SYMLINK_SCORE=$((SYMLINK_SCORE + 1))
        else
            echo -e "  ${RED}✗${NC} CLAUDE.md symlink is broken"
        fi
        SYMLINK_TESTS=$((SYMLINK_TESTS + 1))
    fi
elif [ -L "CLAUDE.md" ] || [ -L "CONTEXT.md" ] || [ -L "SESSION_LOG.md" ]; then
    # Inner repo with symlinks to _governance
    echo -e "  ${CYAN}i${NC} Found symlinks (inner repo pattern)"

    for file in CLAUDE.md CONTEXT.md SESSION_LOG.md; do
        if [ -L "$file" ]; then
            SYMLINK_TESTS=$((SYMLINK_TESTS + 1))
            if [ -e "$file" ]; then
                echo -e "  ${GREEN}✓${NC} $file symlink resolves"
                SYMLINK_SCORE=$((SYMLINK_SCORE + 1))
            else
                echo -e "  ${RED}✗${NC} $file symlink broken"
            fi
        fi
    done
else
    # No symlinks - standalone project or OPS type
    echo -e "  ${CYAN}i${NC} No symlinks (standalone project)"
    # Give full score if governance files exist directly
    if [ -f "CLAUDE.md" ]; then
        SYMLINK_SCORE=1
        SYMLINK_TESTS=1
    fi
fi

if [ "$SYMLINK_TESTS" -gt 0 ]; then
    SYMLINK_PERCENT=$((SYMLINK_SCORE * 100 / SYMLINK_TESTS))
else
    SYMLINK_PERCENT=100  # No symlinks needed
fi
SCORE_SYMLINKS=$SYMLINK_PERCENT

echo "└─────────────────────────────────────────────────────────────┘"
echo ""

echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ TEST 5: Pre-commit Hook (Weight: ${WEIGHT_PRECOMMIT}%)                     │"
echo "├─────────────────────────────────────────────────────────────┤"

if [ -d ".git" ]; then
    if [ -f ".git/hooks/pre-commit" ]; then
        if grep -q "boundary\|CLAUDE\|governance" .git/hooks/pre-commit 2>/dev/null; then
            run_partial_test "Pre-commit hook with boundary checks" "100" "SCORE_PRECOMMIT"
        else
            run_partial_test "Pre-commit hook exists (no boundary check)" "50" "SCORE_PRECOMMIT"
        fi
    else
        run_test "Pre-commit hook installed" "false" "SCORE_PRECOMMIT"
    fi
else
    echo -e "  ${CYAN}i${NC} Not a git repository - skipping"
    SCORE_PRECOMMIT=100  # N/A gets full score
fi

echo "└─────────────────────────────────────────────────────────────┘"
echo ""

echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ TEST 6: Layer 3 (~/.claude/CLAUDE.md) (Weight: ${WEIGHT_LAYER3}%)         │"
echo "├─────────────────────────────────────────────────────────────┤"

if [ -f "$HOME/.claude/CLAUDE.md" ]; then
    LAYER3_SIZE=$(wc -c < "$HOME/.claude/CLAUDE.md")
    if [ "$LAYER3_SIZE" -gt 100 ]; then
        run_partial_test "Layer 3 exists with content ($LAYER3_SIZE bytes)" "100" "SCORE_LAYER3"
    else
        run_partial_test "Layer 3 exists (minimal content)" "50" "SCORE_LAYER3"
    fi
else
    run_test "Layer 3 (~/.claude/CLAUDE.md) exists" "false" "SCORE_LAYER3"
fi

echo "└─────────────────────────────────────────────────────────────┘"
echo ""

echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ TEST 7: PLAN.md (Weight: ${WEIGHT_PLAN_MD}%)                               │"
echo "├─────────────────────────────────────────────────────────────┤"

if [ -f "PLAN.md" ]; then
    # Check if it references a plan file
    if grep -q "~/.claude/plans/\|Active.*Plan\|Current.*Plan" PLAN.md 2>/dev/null; then
        run_partial_test "PLAN.md tracks active plan" "100" "SCORE_PLAN_MD"
    else
        run_partial_test "PLAN.md exists (no plan reference)" "50" "SCORE_PLAN_MD"
    fi
else
    # PLAN.md is optional for some project types
    echo -e "  ${CYAN}i${NC} PLAN.md not found (optional for some types)"
    SCORE_PLAN_MD=50  # Partial score for missing optional file
fi

echo "└─────────────────────────────────────────────────────────────┘"
echo ""

# Calculate weighted total
WEIGHTED_TOTAL=$(( \
    (SCORE_CLAUDE_MD * WEIGHT_CLAUDE_MD / 100) + \
    (SCORE_CONTEXT_MD * WEIGHT_CONTEXT_MD / 100) + \
    (SCORE_SESSION_LOG * WEIGHT_SESSION_LOG / 100) + \
    (SCORE_SYMLINKS * WEIGHT_SYMLINKS / 100) + \
    (SCORE_PRECOMMIT * WEIGHT_PRECOMMIT / 100) + \
    (SCORE_LAYER3 * WEIGHT_LAYER3 / 100) + \
    (SCORE_PLAN_MD * WEIGHT_PLAN_MD / 100) \
))

echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ SCORE SUMMARY                                               │"
echo "├─────────────────────────────────────────────────────────────┤"
printf "│ %-30s %3d%% × %2d%% = %3d pts │\n" "CLAUDE.md" "$SCORE_CLAUDE_MD" "$WEIGHT_CLAUDE_MD" "$((SCORE_CLAUDE_MD * WEIGHT_CLAUDE_MD / 100))"
printf "│ %-30s %3d%% × %2d%% = %3d pts │\n" "CONTEXT.md" "$SCORE_CONTEXT_MD" "$WEIGHT_CONTEXT_MD" "$((SCORE_CONTEXT_MD * WEIGHT_CONTEXT_MD / 100))"
printf "│ %-30s %3d%% × %2d%% = %3d pts │\n" "SESSION_LOG.md" "$SCORE_SESSION_LOG" "$WEIGHT_SESSION_LOG" "$((SCORE_SESSION_LOG * WEIGHT_SESSION_LOG / 100))"
printf "│ %-30s %3d%% × %2d%% = %3d pts │\n" "Symlinks" "$SCORE_SYMLINKS" "$WEIGHT_SYMLINKS" "$((SCORE_SYMLINKS * WEIGHT_SYMLINKS / 100))"
printf "│ %-30s %3d%% × %2d%% = %3d pts │\n" "Pre-commit Hook" "$SCORE_PRECOMMIT" "$WEIGHT_PRECOMMIT" "$((SCORE_PRECOMMIT * WEIGHT_PRECOMMIT / 100))"
printf "│ %-30s %3d%% × %2d%% = %3d pts │\n" "Layer 3" "$SCORE_LAYER3" "$WEIGHT_LAYER3" "$((SCORE_LAYER3 * WEIGHT_LAYER3 / 100))"
printf "│ %-30s %3d%% × %2d%% = %3d pts │\n" "PLAN.md" "$SCORE_PLAN_MD" "$WEIGHT_PLAN_MD" "$((SCORE_PLAN_MD * WEIGHT_PLAN_MD / 100))"
echo "├─────────────────────────────────────────────────────────────┤"

# Determine pass/fail
PASS_THRESHOLD=80

if [ "$WEIGHTED_TOTAL" -ge "$PASS_THRESHOLD" ]; then
    echo -e "│ ${GREEN}TOTAL SCORE: ${WEIGHTED_TOTAL}/100 - PASS${NC}                              │"
    RESULT="PASS"
else
    echo -e "│ ${RED}TOTAL SCORE: ${WEIGHTED_TOTAL}/100 - FAIL (need ${PASS_THRESHOLD}+)${NC}                    │"
    RESULT="FAIL"
fi

echo "└─────────────────────────────────────────────────────────────┘"
echo ""

# Output JSON for automation
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ JSON OUTPUT (for automation)                                │"
echo "├─────────────────────────────────────────────────────────────┤"
cat << EOF
{
  "project": "$PROJECT_NAME",
  "path": "$(pwd)",
  "date": "$(date -Iseconds)",
  "score": $WEIGHTED_TOTAL,
  "threshold": $PASS_THRESHOLD,
  "result": "$RESULT",
  "breakdown": {
    "claude_md": $SCORE_CLAUDE_MD,
    "context_md": $SCORE_CONTEXT_MD,
    "session_log": $SCORE_SESSION_LOG,
    "symlinks": $SCORE_SYMLINKS,
    "precommit": $SCORE_PRECOMMIT,
    "layer3": $SCORE_LAYER3,
    "plan_md": $SCORE_PLAN_MD
  }
}
EOF
echo "└─────────────────────────────────────────────────────────────┘"
echo ""

# Exit with appropriate code
if [ "$RESULT" = "PASS" ]; then
    exit 0
else
    exit 1
fi
