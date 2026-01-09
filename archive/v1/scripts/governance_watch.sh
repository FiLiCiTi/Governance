#!/bin/bash
# governance_watch.sh
# Layer 3: Runtime Monitoring
#
# Usage:
#   ./governance_watch.sh start [project_path]      # Start monitoring session
#   ./governance_watch.sh stop                      # Stop and summarize
#   ./governance_watch.sh status                    # Show current status
#   ./governance_watch.sh warmup                    # Trigger manual warm-up
#   ./governance_watch.sh check                     # Check for violations
#
# Features:
#   - Session duration tracking
#   - Warm-up reminders (90 min default)
#   - Boundary violation detection
#   - macOS notifications

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# State file
STATE_FILE="$HOME/.claude/governance_session.json"
VIOLATIONS_LOG="$HOME/.claude/violations.log"
WARMUP_INTERVAL=5400  # 90 minutes in seconds

# ═══════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════

notify() {
    local title="$1"
    local message="$2"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null || true
    else
        # Linux notification (if available)
        notify-send "$title" "$message" 2>/dev/null || echo "[$title] $message"
    fi
}

get_state() {
    if [[ -f "$STATE_FILE" ]]; then
        cat "$STATE_FILE"
    else
        echo "{}"
    fi
}

set_state() {
    local key="$1"
    local value="$2"

    if command -v jq &> /dev/null; then
        local current=$(get_state)
        echo "$current" | jq ".$key = $value" > "$STATE_FILE"
    fi
}

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

log_violation() {
    local type="$1"
    local details="$2"

    echo "$(date -Iseconds) | $type | $details" >> "$VIOLATIONS_LOG"
}

# ═══════════════════════════════════════════════════════════════════════════
# START SESSION
# ═══════════════════════════════════════════════════════════════════════════

start_session() {
    local project="${1:-$(pwd)}"
    local project_name=$(basename "$project")
    local now=$(date +%s)

    echo ""
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ STARTING GOVERNANCE WATCH                                   │"
    echo "├─────────────────────────────────────────────────────────────┤"
    echo "  Project: $project_name"
    echo "  Path: $project"
    echo "  Started: $(date '+%Y-%m-%d %H:%M')"
    echo ""

    # Create state file
    if command -v jq &> /dev/null; then
        cat > "$STATE_FILE" << EOF
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
    else
        # Fallback without jq
        echo "project=$project" > "$STATE_FILE.txt"
        echo "start_time=$now" >> "$STATE_FILE.txt"
        echo "last_warmup=$now" >> "$STATE_FILE.txt"
    fi

    # Parse boundaries from CLAUDE.md
    if [[ -f "$project/CLAUDE.md" ]]; then
        local can_modify=$(grep "CAN modify:" "$project/CLAUDE.md" | head -1 | sed 's/.*CAN modify://' | xargs)
        local cannot_modify=$(grep "CANNOT modify:" "$project/CLAUDE.md" | head -1 | sed 's/.*CANNOT modify://' | xargs)

        echo "  Boundaries:"
        echo -e "    ${GREEN}CAN:${NC}    $can_modify"
        echo -e "    ${RED}CANNOT:${NC} $cannot_modify"
    else
        echo -e "  ${YELLOW}⚠${NC} No CLAUDE.md found - boundaries not enforced"
    fi

    echo ""
    echo "  Warm-up reminder: Every $(($WARMUP_INTERVAL / 60)) minutes"
    echo ""
    echo "  Commands:"
    echo "    ./governance_watch.sh status   - Check session status"
    echo "    ./governance_watch.sh warmup   - Record warm-up"
    echo "    ./governance_watch.sh stop     - End session"
    echo "└─────────────────────────────────────────────────────────────┘"

    notify "Governance Watch" "Session started for $project_name"
}

# ═══════════════════════════════════════════════════════════════════════════
# CHECK STATUS
# ═══════════════════════════════════════════════════════════════════════════

check_status() {
    if [[ ! -f "$STATE_FILE" ]]; then
        echo -e "${YELLOW}No active session${NC}"
        echo "Start with: ./governance_watch.sh start [project_path]"
        return
    fi

    echo ""
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ SESSION STATUS                                              │"
    echo "├─────────────────────────────────────────────────────────────┤"

    if command -v jq &> /dev/null; then
        local state=$(get_state)
        local project=$(echo "$state" | jq -r '.project // "unknown"')
        local project_name=$(echo "$state" | jq -r '.project_name // "unknown"')
        local start_time=$(echo "$state" | jq -r '.start_time // 0')
        local last_warmup=$(echo "$state" | jq -r '.last_warmup // 0')
        local violations=$(echo "$state" | jq '.violations | length')
        local status=$(echo "$state" | jq -r '.status // "unknown"')

        local now=$(date +%s)
        local elapsed=$(elapsed_time "$start_time")
        local since_warmup=$(( now - last_warmup ))

        echo "  Project: $project_name"
        echo "  Status: $status"
        echo "  Duration: $elapsed"
        echo ""

        # Warm-up status
        local warmup_mins=$((since_warmup / 60))
        if [[ $since_warmup -ge $WARMUP_INTERVAL ]]; then
            echo -e "  ${RED}⚠ WARM-UP OVERDUE${NC} ($warmup_mins min since last)"
            notify "Warm-up Needed" "Session running $elapsed - consider warm-up"
        elif [[ $since_warmup -ge $((WARMUP_INTERVAL * 2 / 3)) ]]; then
            echo -e "  ${YELLOW}○ Warm-up soon${NC} ($warmup_mins min since last)"
        else
            echo -e "  ${GREEN}✓ Warm-up OK${NC} ($warmup_mins min since last)"
        fi

        # Violations
        if [[ "$violations" -gt 0 ]]; then
            echo -e "  ${RED}Violations: $violations${NC}"
        else
            echo -e "  ${GREEN}Violations: 0${NC}"
        fi
    fi

    echo "└─────────────────────────────────────────────────────────────┘"
}

# ═══════════════════════════════════════════════════════════════════════════
# RECORD WARM-UP
# ═══════════════════════════════════════════════════════════════════════════

record_warmup() {
    if [[ ! -f "$STATE_FILE" ]]; then
        echo -e "${RED}No active session${NC}"
        return
    fi

    local now=$(date +%s)
    set_state "last_warmup" "$now"

    echo ""
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ WARM-UP RECORDED                                            │"
    echo "├─────────────────────────────────────────────────────────────┤"
    echo "  Time: $(date '+%Y-%m-%d %H:%M')"
    echo ""
    echo "  Warm-up actions:"
    echo "    1. Update CONTEXT.md with current state"
    echo "    2. Update SESSION_LOG.md with decisions"
    echo "    3. Mark completed tasks in plan file [x]"
    echo "    4. Append to Conversations/ if needed"
    echo "└─────────────────────────────────────────────────────────────┘"

    notify "Warm-up Complete" "Governance files should be updated"
}

# ═══════════════════════════════════════════════════════════════════════════
# CHECK FOR VIOLATIONS
# ═══════════════════════════════════════════════════════════════════════════

check_violations() {
    if [[ ! -f "$STATE_FILE" ]]; then
        echo -e "${YELLOW}No active session${NC}"
        return
    fi

    echo ""
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ VIOLATION CHECK                                             │"
    echo "├─────────────────────────────────────────────────────────────┤"

    if command -v jq &> /dev/null; then
        local state=$(get_state)
        local project=$(echo "$state" | jq -r '.project // "."')

        # Check for CLAUDE.md
        if [[ -f "$project/CLAUDE.md" ]]; then
            echo -e "  ${GREEN}✓${NC} CLAUDE.md exists"

            # Parse boundaries
            local can_modify=$(grep "CAN modify:" "$project/CLAUDE.md" | head -1 | sed 's/.*CAN modify://' | xargs)

            # Check recent git changes (if git repo)
            if [[ -d "$project/.git" ]]; then
                echo ""
                echo "  Recent changes (git):"
                cd "$project"
                local changed=$(git diff --name-only HEAD~5 2>/dev/null || git diff --name-only 2>/dev/null || echo "")

                if [[ -n "$changed" ]]; then
                    echo "$changed" | while read file; do
                        # Simple boundary check
                        if [[ -n "$can_modify" ]]; then
                            local allowed=false
                            for pattern in $can_modify; do
                                if [[ "$file" == $pattern* ]] || [[ "$file" == *.${pattern##*.} ]]; then
                                    allowed=true
                                    break
                                fi
                            done

                            if [[ "$allowed" == true ]]; then
                                echo -e "    ${GREEN}✓${NC} $file"
                            else
                                echo -e "    ${YELLOW}?${NC} $file (verify boundary)"
                            fi
                        else
                            echo "    • $file"
                        fi
                    done
                else
                    echo "    No recent changes"
                fi
            fi
        else
            echo -e "  ${YELLOW}○${NC} No CLAUDE.md - cannot check boundaries"
        fi
    fi

    echo "└─────────────────────────────────────────────────────────────┘"
}

# ═══════════════════════════════════════════════════════════════════════════
# STOP SESSION
# ═══════════════════════════════════════════════════════════════════════════

stop_session() {
    if [[ ! -f "$STATE_FILE" ]]; then
        echo -e "${YELLOW}No active session to stop${NC}"
        return
    fi

    echo ""
    echo "┌─────────────────────────────────────────────────────────────┐"
    echo "│ SESSION SUMMARY                                             │"
    echo "├─────────────────────────────────────────────────────────────┤"

    if command -v jq &> /dev/null; then
        local state=$(get_state)
        local project_name=$(echo "$state" | jq -r '.project_name // "unknown"')
        local start_time=$(echo "$state" | jq -r '.start_time // 0')
        local violations=$(echo "$state" | jq '.violations | length')

        local elapsed=$(elapsed_time "$start_time")

        echo "  Project: $project_name"
        echo "  Duration: $elapsed"
        echo "  Violations: $violations"
        echo ""
        echo "  End Checklist:"
        echo "    [ ] CONTEXT.md updated with current state"
        echo "    [ ] SESSION_LOG.md has session entry"
        echo "    [ ] Plan file tasks marked [x]"
        echo "    [ ] Conversation dumped (if applicable)"
    fi

    echo "└─────────────────────────────────────────────────────────────┘"

    # Archive state
    mv "$STATE_FILE" "$STATE_FILE.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || rm "$STATE_FILE"

    notify "Session Ended" "Remember to update governance files"
}

# ═══════════════════════════════════════════════════════════════════════════
# BACKGROUND WATCHER (Optional - requires fswatch)
# ═══════════════════════════════════════════════════════════════════════════

start_watcher() {
    if ! command -v fswatch &> /dev/null; then
        echo -e "${YELLOW}fswatch not installed${NC}"
        echo "Install with: brew install fswatch"
        return
    fi

    local project="${1:-$(pwd)}"

    echo "Starting file watcher on $project..."
    echo "Press Ctrl+C to stop"

    fswatch -0 "$project" | while read -d "" event; do
        local file=$(basename "$event")

        # Skip hidden files and common temp files
        if [[ "$file" == .* ]] || [[ "$file" == *~ ]]; then
            continue
        fi

        # Log the change
        echo "$(date '+%H:%M:%S') Modified: $event"

        # Could add boundary checking here
    done
}

# ═══════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════

case "${1:-status}" in
    start)
        start_session "${2:-$(pwd)}"
        ;;
    stop)
        stop_session
        ;;
    status)
        check_status
        ;;
    warmup)
        record_warmup
        ;;
    check)
        check_violations
        ;;
    watch)
        start_watcher "${2:-$(pwd)}"
        ;;
    *)
        echo "Usage: governance_watch.sh {start|stop|status|warmup|check|watch} [project_path]"
        ;;
esac
