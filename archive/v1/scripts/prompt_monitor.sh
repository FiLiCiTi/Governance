#!/bin/bash
# prompt_monitor.sh
# Assembles and validates all Claude Code prompt layers
# Extended with session tracking integration
#
# Usage:
#   ./scripts/prompt_monitor.sh [project_path]        # Show prompt layers
#   ./scripts/prompt_monitor.sh --session             # Show session status
#   ./scripts/prompt_monitor.sh --start [project]     # Start session tracking
#   ./scripts/prompt_monitor.sh --stop                # Stop session tracking
#
# Example: ./scripts/prompt_monitor.sh ~/Desktop/Governance

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Session state file (shared with governance_watch.sh)
SESSION_STATE="$HOME/.claude/governance_session.json"

# Parse arguments
MODE="layers"
PROJECT_PATH="."

while [[ $# -gt 0 ]]; do
    case $1 in
        --session)
            MODE="session"
            shift
            ;;
        --start)
            MODE="start"
            PROJECT_PATH="${2:-.}"
            shift 2 2>/dev/null || shift
            ;;
        --stop)
            MODE="stop"
            shift
            ;;
        *)
            PROJECT_PATH="$1"
            shift
            ;;
    esac
done

# ═══════════════════════════════════════════════════════════════════════════
# SESSION TRACKING FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════

elapsed_time() {
    local start="$1"
    local now=$(date +%s)
    local diff=$((now - start))
    local hours=$((diff / 3600))
    local mins=$(( (diff % 3600) / 60 ))
    if [[ $hours -gt 0 ]]; then
        echo "${hours}h ${mins}m"
    else
        echo "${mins}m"
    fi
}

show_session_status() {
    echo ""
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ SESSION STATUS                                              │"
    echo "├─────────────────────────────────────────────────────────────┤"

    if [[ -f "$SESSION_STATE" ]] && command -v jq &> /dev/null; then
        local state=$(cat "$SESSION_STATE")
        local project_name=$(echo "$state" | jq -r '.project_name // "unknown"')
        local start_time=$(echo "$state" | jq -r '.start_time // 0')
        local last_warmup=$(echo "$state" | jq -r '.last_warmup // 0')
        local status=$(echo "$state" | jq -r '.status // "unknown"')

        if [[ "$start_time" != "0" ]] && [[ "$start_time" != "null" ]]; then
            local elapsed=$(elapsed_time "$start_time")
            local now=$(date +%s)
            local since_warmup=$(( now - last_warmup ))
            local warmup_mins=$((since_warmup / 60))

            echo -e "│ ${GREEN}●${NC} Active Session"
            echo "│   Project: $project_name"
            echo "│   Duration: $elapsed"
            echo "│   Since warm-up: ${warmup_mins}m"

            # Warm-up indicator
            if [[ $since_warmup -ge 5400 ]]; then
                echo -e "│   ${RED}⚠ WARM-UP OVERDUE${NC}"
            elif [[ $since_warmup -ge 3600 ]]; then
                echo -e "│   ${YELLOW}○ Warm-up soon${NC}"
            else
                echo -e "│   ${GREEN}✓ Warm-up OK${NC}"
            fi
        else
            echo -e "│ ${YELLOW}○${NC} No active session"
        fi
    else
        echo -e "│ ${YELLOW}○${NC} No active session"
        echo "│   Start with: ./prompt_monitor.sh --start [project]"
    fi

    echo "└─────────────────────────────────────────────────────────────┘"
}

start_session() {
    local project="$1"
    local project_name=$(basename "$project")
    local now=$(date +%s)

    if command -v jq &> /dev/null; then
        cat > "$SESSION_STATE" << EOF
{
  "project": "$project",
  "project_name": "$project_name",
  "start_time": $now,
  "last_warmup": $now,
  "files_modified": [],
  "violations": [],
  "status": "active"
}
EOF
        echo -e "${GREEN}✓${NC} Session started for $project_name"
        echo "  Run ./prompt_monitor.sh --session to check status"
    else
        echo -e "${RED}✗${NC} jq required for session tracking"
    fi
}

stop_session() {
    if [[ -f "$SESSION_STATE" ]]; then
        if command -v jq &> /dev/null; then
            local state=$(cat "$SESSION_STATE")
            local project_name=$(echo "$state" | jq -r '.project_name // "unknown"')
            local start_time=$(echo "$state" | jq -r '.start_time // 0')
            local elapsed=$(elapsed_time "$start_time")

            echo -e "${GREEN}✓${NC} Session ended for $project_name"
            echo "  Duration: $elapsed"
        fi
        mv "$SESSION_STATE" "$SESSION_STATE.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || rm "$SESSION_STATE"
    else
        echo -e "${YELLOW}○${NC} No active session to stop"
    fi
}

# Handle session modes
case "$MODE" in
    "session")
        show_session_status
        exit 0
        ;;
    "start")
        start_session "$PROJECT_PATH"
        exit 0
        ;;
    "stop")
        stop_session
        exit 0
        ;;
esac

# Continue with normal layers mode
cd "$PROJECT_PATH"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  PROMPT LAYER MONITOR"
echo "  Project: $(pwd)"
echo "  Date: $(date '+%Y-%m-%d %H:%M')"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Function to count tokens (approximate: 1 token ≈ 4 chars)
count_tokens() {
    local file="$1"
    if [ -f "$file" ]; then
        local chars=$(wc -c < "$file" | tr -d ' ')
        echo $((chars / 4))
    else
        echo "0"
    fi
}

# Function to count lines
count_lines() {
    local file="$1"
    if [ -f "$file" ]; then
        wc -l < "$file" | tr -d ' '
    else
        echo "0"
    fi
}

echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ LAYER ANALYSIS                                              │"
echo "├─────────────────────────────────────────────────────────────┤"

# Layer 3: User Memory
USER_MEMORY="$HOME/.claude/CLAUDE.md"
if [ -f "$USER_MEMORY" ]; then
    TOKENS=$(count_tokens "$USER_MEMORY")
    LINES=$(count_lines "$USER_MEMORY")
    echo -e "│ ${GREEN}✓${NC} Layer 3 (User Memory):    ~/.claude/CLAUDE.md"
    echo "│   Lines: $LINES | Tokens: ~$TOKENS"
else
    echo -e "│ ${RED}✗${NC} Layer 3 (User Memory):    MISSING!"
    echo "│   Action: Create ~/.claude/CLAUDE.md"
fi

# Layer 4: Project Memory
PROJECT_MEMORY="./CLAUDE.md"
if [ -f "$PROJECT_MEMORY" ]; then
    TOKENS=$(count_tokens "$PROJECT_MEMORY")
    LINES=$(count_lines "$PROJECT_MEMORY")
    echo -e "│ ${GREEN}✓${NC} Layer 4 (Project Memory): ./CLAUDE.md"
    echo "│   Lines: $LINES | Tokens: ~$TOKENS"
else
    echo -e "│ ${RED}✗${NC} Layer 4 (Project Memory): MISSING!"
fi

# Layer 5: Project Rules
RULES_DIR=".claude/rules"
if [ -d "$RULES_DIR" ]; then
    RULE_COUNT=$(find "$RULES_DIR" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$RULE_COUNT" -gt 0 ]; then
        echo -e "│ ${GREEN}✓${NC} Layer 5 (Project Rules):  .claude/rules/"
        echo "│   Files: $RULE_COUNT"
        find "$RULES_DIR" -name "*.md" 2>/dev/null | while read file; do
            TOKENS=$(count_tokens "$file")
            echo "│     - $(basename "$file"): ~$TOKENS tokens"
        done
    else
        echo -e "│ ${YELLOW}○${NC} Layer 5 (Project Rules):  Empty (.claude/rules/)"
    fi
else
    echo -e "│ ${YELLOW}○${NC} Layer 5 (Project Rules):  Not configured"
fi

# Layer 6: Local Memory
LOCAL_MEMORY="./CLAUDE.local.md"
if [ -f "$LOCAL_MEMORY" ]; then
    TOKENS=$(count_tokens "$LOCAL_MEMORY")
    LINES=$(count_lines "$LOCAL_MEMORY")
    echo -e "│ ${GREEN}✓${NC} Layer 6 (Local Memory):   ./CLAUDE.local.md"
    echo "│   Lines: $LINES | Tokens: ~$TOKENS"
else
    echo -e "│ ${YELLOW}○${NC} Layer 6 (Local Memory):   Not configured"
fi

echo "└─────────────────────────────────────────────────────────────┘"
echo ""

# Governance files check
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ GOVERNANCE FILES                                            │"
echo "├─────────────────────────────────────────────────────────────┤"

for file in CONTEXT.md SESSION_LOG.md PLAN.md; do
    if [ -f "$file" ]; then
        LINES=$(count_lines "$file")
        echo -e "│ ${GREEN}✓${NC} $file ($LINES lines)"
    else
        echo -e "│ ${RED}✗${NC} $file MISSING"
    fi
done

# Check for Conversations folder
if [ -d "Conversations" ]; then
    SESSION_COUNT=$(find "Conversations" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    echo -e "│ ${GREEN}✓${NC} Conversations/ ($SESSION_COUNT sessions)"
elif [ -d "10_Thought_Process" ]; then
    echo -e "│ ${YELLOW}!${NC} 10_Thought_Process/ (rename to Conversations/)"
else
    echo -e "│ ${YELLOW}○${NC} Conversations/ not found"
fi

echo "└─────────────────────────────────────────────────────────────┘"
echo ""

# Conflict check
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ CONFLICT CHECK                                              │"
echo "├─────────────────────────────────────────────────────────────┤"

CONFLICTS=0

# Check for duplicate rules between Layer 3 and Layer 4
if [ -f "$USER_MEMORY" ] && [ -f "$PROJECT_MEMORY" ]; then
    # Check for "General Rules" in project CLAUDE.md (should be slimmed)
    if grep -q "Output format:" "$PROJECT_MEMORY" 2>/dev/null; then
        if grep -q "Output format:" "$USER_MEMORY" 2>/dev/null; then
            echo -e "│ ${YELLOW}!${NC} Duplicate: 'Output format' in both Layer 3 & 4"
            CONFLICTS=$((CONFLICTS + 1))
        fi
    fi

    if grep -q "Token efficiency:" "$PROJECT_MEMORY" 2>/dev/null; then
        if grep -q "Token efficiency:" "$USER_MEMORY" 2>/dev/null; then
            echo -e "│ ${YELLOW}!${NC} Duplicate: 'Token efficiency' in both Layer 3 & 4"
            CONFLICTS=$((CONFLICTS + 1))
        fi
    fi
fi

if [ "$CONFLICTS" -eq 0 ]; then
    echo -e "│ ${GREEN}✓${NC} No conflicts detected"
fi

echo "└─────────────────────────────────────────────────────────────┘"
echo ""

# Stats summary
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ STATS SUMMARY                                               │"
echo "├─────────────────────────────────────────────────────────────┤"

# Calculate total tokens
TOTAL_TOKENS=0
for file in "$USER_MEMORY" "$PROJECT_MEMORY" "$LOCAL_MEMORY"; do
    if [ -f "$file" ]; then
        TOKENS=$(count_tokens "$file")
        TOTAL_TOKENS=$((TOTAL_TOKENS + TOKENS))
    fi
done

if [ -d "$RULES_DIR" ]; then
    find "$RULES_DIR" -name "*.md" 2>/dev/null | while read file; do
        TOKENS=$(count_tokens "$file")
        TOTAL_TOKENS=$((TOTAL_TOKENS + TOKENS))
    done
fi

echo "│ Total CLAUDE.md tokens: ~$TOTAL_TOKENS"
echo "│ Context window: 200K tokens"
echo "│ CLAUDE.md usage: ~$((TOTAL_TOKENS * 100 / 200000))% of context"

# Check stats-cache.json if exists
STATS_CACHE="$HOME/.claude/stats-cache.json"
if [ -f "$STATS_CACHE" ]; then
    TOTAL_SESSIONS=$(grep -o '"totalSessions": [0-9]*' "$STATS_CACHE" | grep -o '[0-9]*' || echo "?")
    TOTAL_MESSAGES=$(grep -o '"totalMessages": [0-9]*' "$STATS_CACHE" | grep -o '[0-9]*' || echo "?")
    echo "│ Total sessions: $TOTAL_SESSIONS"
    echo "│ Total messages: $TOTAL_MESSAGES"
fi

echo "└─────────────────────────────────────────────────────────────┘"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""
