#!/bin/bash
# scripts/audit_sessions.sh
# Purpose: Audit all session files with full session history per project
# Usage: ./audit_sessions.sh (auto-saves to sessionaudit/)
# Output: ~/Desktop/Governance/sessionaudit/YYYYMMDD_audit.txt
# v2.0: Multi-session history, cross-reference with logs, auto-save

# Configuration
SESSIONS_DIR="$HOME/.claude/sessions"
OUTPUT_DIR="$HOME/Desktop/Governance/sessionaudit"
STALE_DAYS=7
STALE_SECONDS=$((STALE_DAYS * 24 * 3600))
NOW=$(date +%s)
TODAY=$(date +%Y%m%d)
OUTPUT_FILE="$OUTPUT_DIR/${TODAY}_audit.txt"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Start output
exec > "$OUTPUT_FILE"

echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                         SESSION AUDIT REPORT                               ║"
echo "║                         $(date '+%Y-%m-%d %H:%M')                                       ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Counters
TOTAL_PROJECTS=0
TOTAL_SESSIONS=0
TOTAL_ISSUES=0

# Check if sessions directory exists
if [[ ! -d "$SESSIONS_DIR" ]]; then
    echo "ERROR: Sessions directory not found: $SESSIONS_DIR"
    exit 1
fi

# Collect unique projects by project_name
declare_projects() {
    for f in "$SESSIONS_DIR"/*_session.json; do
        [[ ! -f "$f" ]] && continue
        size=$(stat -f%z "$f" 2>/dev/null || echo "0")
        [[ "$size" == "0" ]] && continue

        name=$(jq -r '.project_name // ""' "$f" 2>/dev/null)
        path=$(jq -r '.project // ""' "$f" 2>/dev/null)

        [[ -z "$name" || "$name" == "null" ]] && continue
        echo "$name|$path|$f"
    done | sort -t'|' -k1,1 -u
}

# Find log files for a project (strict matching)
find_logs() {
    local project_path="$1"
    local project_name="$2"
    local project_name_lower=$(echo "$project_name" | tr '[:upper:]' '[:lower:]')

    # Check possible log locations - project-specific only
    local log_paths=(
        "$project_path/../_governance/$project_name/Conversations"
        "$project_path/../_governance/$project_name_lower/Conversations"
        "$project_path/Conversations"
    )

    for lp in "${log_paths[@]}"; do
        if [[ -d "$lp" ]]; then
            # Strict match: filename must contain exact project name
            # Pattern: YYYYMMDD_HHMM_projectname.log or YYYYMMDD_HHMM_projectname_TS.log
            find "$lp" -maxdepth 1 -type f \( -name "*_${project_name}.log" -o -name "*_${project_name}_*.log" -o -name "*_${project_name_lower}.log" -o -name "*_${project_name_lower}_*.log" \) 2>/dev/null | head -20
            return
        fi
    done

    # Fallback: Governance Conversations (only if project is governance)
    if [[ "$project_name_lower" == "governance" ]]; then
        local gov_path="$HOME/Desktop/Governance/Conversations"
        if [[ -d "$gov_path" ]]; then
            find "$gov_path" -maxdepth 1 -type f \( -name "*_governance.log" -o -name "*_governance_*.log" -o -name "*_Governance.log" -o -name "*_Governance_*.log" \) 2>/dev/null | head -20
        fi
    fi
}

# Parse log filename to get session info
parse_log() {
    local log_file="$1"
    local filename=$(basename "$log_file")

    # Extract date/time from filename: 20260112_0359_project.log
    local date_part=$(echo "$filename" | grep -oE '^[0-9]{8}' || echo "")
    local time_part=$(echo "$filename" | grep -oE '^[0-9]{8}_[0-9]{4}' | cut -d'_' -f2 || echo "")

    if [[ -n "$date_part" && -n "$time_part" ]]; then
        local formatted_date="${date_part:0:4}-${date_part:4:2}-${date_part:6:2}"
        local formatted_time="${time_part:0:2}:${time_part:2:2}"

        # Get file modification time as end time
        local mod_time=$(stat -f "%Sm" -t "%H:%M" "$log_file" 2>/dev/null || echo "--:--")
        local mod_epoch=$(stat -f "%m" "$log_file" 2>/dev/null || echo "0")

        # Calculate start epoch
        local start_epoch=$(date -j -f "%Y%m%d%H%M" "${date_part}${time_part}" "+%s" 2>/dev/null || echo "0")

        # Calculate duration
        local duration="--"
        if [[ "$start_epoch" != "0" && "$mod_epoch" != "0" ]]; then
            local dur_secs=$((mod_epoch - start_epoch))
            local dur_hours=$((dur_secs / 3600))
            local dur_mins=$(((dur_secs % 3600) / 60))
            duration="${dur_hours}h ${dur_mins}m"
        fi

        # Determine status
        local status="Completed"
        local age=$((NOW - mod_epoch))
        if [[ $age -lt 300 ]]; then
            status="Active"
        elif [[ $age -gt $STALE_SECONDS ]]; then
            status="Stale"
        fi

        echo "$formatted_date|$formatted_time|$mod_time|$duration|$status|$log_file"
    fi
}

# Process each unique project
while IFS='|' read -r project_name project_path session_file; do
    [[ -z "$project_name" ]] && continue

    ((TOTAL_PROJECTS++))

    echo "┌──────────────────────────────────────────────────────────────────────────────┐"
    echo "│ PROJECT: $project_name"
    echo "├──────────────────────────────────────────────────────────────────────────────┤"
    echo "│ Path: $project_path"

    # Validate path
    if [[ -d "$project_path" ]]; then
        echo "│ Path Valid: ✓"
    else
        echo "│ Path Valid: ✗ NOT FOUND"
        ((TOTAL_ISSUES++))
    fi

    # Current session info from JSON
    if [[ -f "$session_file" ]]; then
        start_time=$(jq -r '.start_time // 0' "$session_file" 2>/dev/null)
        last_update=$(jq -r '.last_update // 0' "$session_file" 2>/dev/null)
        token_count=$(jq -r '.token_count // 0' "$session_file" 2>/dev/null)

        if [[ "$start_time" != "0" && "$start_time" != "null" ]]; then
            current_start=$(date -r "$start_time" '+%Y-%m-%d %H:%M' 2>/dev/null || echo "Invalid")
            echo "│ Current Session: Started $current_start"
        fi

        if [[ "$token_count" != "0" ]]; then
            token_k=$((token_count / 1000))
            echo "│ Tokens: ~${token_k}K"
        fi
    fi

    echo "│"
    echo "│ Sessions:"
    echo "│ ┌────────────┬───────┬───────┬──────────┬───────────┐"
    echo "│ │ Date       │ Start │ End   │ Duration │ Status    │"
    echo "│ ├────────────┼───────┼───────┼──────────┼───────────┤"

    # Collect sessions from log files
    session_count=0
    while IFS= read -r log_file; do
        [[ -z "$log_file" || ! -f "$log_file" ]] && continue

        # Skip non-TS files if TS version exists (avoid duplicates)
        base_name=$(basename "$log_file")
        if [[ "$base_name" != *"_TS"* ]]; then
            ts_version="${log_file%.log}_TS.log"
            [[ -f "$ts_version" ]] && continue
        fi

        session_info=$(parse_log "$log_file")
        if [[ -n "$session_info" ]]; then
            IFS='|' read -r s_date s_start s_end s_dur s_status s_file <<< "$session_info"
            printf "│ │ %-10s │ %-5s │ %-5s │ %-8s │ %-9s │\n" "$s_date" "$s_start" "$s_end" "$s_dur" "$s_status"
            ((session_count++))
            ((TOTAL_SESSIONS++))
        fi
    done < <(find_logs "$project_path" "$project_name" | sort -r | head -10)

    if [[ $session_count -eq 0 ]]; then
        echo "│ │ (No log files found)                              │"
    fi

    echo "│ └────────────┴───────┴───────┴──────────┴───────────┘"

    # Issues
    issues=()

    # Check for empty/invalid session file
    if [[ -f "$session_file" ]]; then
        size=$(stat -f%z "$session_file" 2>/dev/null || echo "0")
        if [[ "$size" == "0" ]]; then
            issues+=("Empty session file (0 bytes)")
        fi

        start_time=$(jq -r '.start_time // 0' "$session_file" 2>/dev/null)
        if [[ "$start_time" == "0" || "$start_time" == "null" ]]; then
            issues+=("Invalid start_time (epoch 0)")
        fi
    fi

    # Check path
    if [[ ! -d "$project_path" ]]; then
        issues+=("Path no longer exists (moved/deleted?)")
    fi

    if [[ ${#issues[@]} -gt 0 ]]; then
        echo "│"
        echo "│ Issues:"
        for issue in "${issues[@]}"; do
            echo "│   ⚠️  $issue"
            ((TOTAL_ISSUES++))
        done
    fi

    echo "└──────────────────────────────────────────────────────────────────────────────┘"
    echo ""

done < <(declare_projects)

# Also check for empty/invalid session files not linked to projects
echo "┌──────────────────────────────────────────────────────────────────────────────┐"
echo "│ ORPHANED/CORRUPT SESSION FILES                                              │"
echo "├──────────────────────────────────────────────────────────────────────────────┤"

orphan_count=0
for f in "$SESSIONS_DIR"/*_session.json; do
    [[ ! -f "$f" ]] && continue

    size=$(stat -f%z "$f" 2>/dev/null || echo "0")
    hash=$(basename "$f" | sed 's/_session.json//')

    if [[ "$size" == "0" ]]; then
        echo "│ ⚠️  EMPTY: $hash"
        ((orphan_count++))
        ((TOTAL_ISSUES++))
    else
        name=$(jq -r '.project_name // ""' "$f" 2>/dev/null)
        if [[ -z "$name" || "$name" == "null" ]]; then
            echo "│ ⚠️  INVALID JSON: $hash"
            ((orphan_count++))
            ((TOTAL_ISSUES++))
        fi
    fi
done

if [[ $orphan_count -eq 0 ]]; then
    echo "│ ✓ None found"
fi

echo "└──────────────────────────────────────────────────────────────────────────────┘"
echo ""

# Summary
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                              SUMMARY                                       ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""
printf "  %-25s %d\n" "Total Projects:" "$TOTAL_PROJECTS"
printf "  %-25s %d\n" "Total Sessions (logs):" "$TOTAL_SESSIONS"
printf "  %-25s %d\n" "Total Issues:" "$TOTAL_ISSUES"
echo ""

if [[ $TOTAL_ISSUES -gt 0 ]]; then
    echo "⚠️  $TOTAL_ISSUES issue(s) found. Review above for details."
else
    echo "✓ No issues found."
fi

echo ""
echo "Report saved: $OUTPUT_FILE"
echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
