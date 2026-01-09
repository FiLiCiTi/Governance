#!/bin/bash
# Enhanced Drive Audit Script with Progress Indicators
# Run on M1 with drives connected
# Features: Spinner, percentage, parallel audit, Time Machine detection
#           7-level folder listing with stats for deepest level
#           Stats include: subfolders, files, size, date range (oldest → newest)
#
# For regular drives: 7 levels from volume root
# For Time Machine: 7 levels from Desktop folder in latest backup

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLAN_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$PLAN_DIR/logs"
DATE_STAMP=$(date +%Y%m%d_%H%M%S)
TEMP_DIR=$(mktemp -d)

# Colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Spinner characters
SPIN='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

# Progress bar function
progress_bar() {
  local percent=$1
  local width=20
  local filled=$((percent * width / 100))
  local empty=$((width - filled))
  printf "["
  printf "%${filled}s" | tr ' ' '█'
  printf "%${empty}s" | tr ' ' '░'
  printf "] %3d%%" "$percent"
}

# Spinner function (runs in background)
spinner_pid=""
start_spinner() {
  local msg="$1"
  (
    i=0
    while true; do
      printf "\r  ${SPIN:i++%${#SPIN}:1} ${msg}"
      sleep 0.1
    done
  ) &
  spinner_pid=$!
}

stop_spinner() {
  local msg="$1"
  if [[ -n "$spinner_pid" ]]; then
    kill "$spinner_pid" 2>/dev/null
    wait "$spinner_pid" 2>/dev/null
  fi
  printf "\r  ${GREEN}✓${NC} ${msg}\n"
  spinner_pid=""
}

# Get stats for a folder (subfolders, files, size, date range)
get_folder_stats() {
  local dir="$1"
  local subfolders=$(find "$dir" -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
  local files=$(find "$dir" -type f 2>/dev/null | wc -l | tr -d ' ')
  local size=$(du -sh "$dir" 2>/dev/null | cut -f1)

  # Get date range (oldest and newest file modification times)
  local oldest_ts=$(find "$dir" -type f -print0 2>/dev/null | xargs -0 stat -f "%m" 2>/dev/null | sort -n | head -1)
  local newest_ts=$(find "$dir" -type f -print0 2>/dev/null | xargs -0 stat -f "%m" 2>/dev/null | sort -n | tail -1)

  local oldest_date="N/A"
  local newest_date="N/A"
  if [[ -n "$oldest_ts" && "$oldest_ts" =~ ^[0-9]+$ ]]; then
    oldest_date=$(date -r "$oldest_ts" '+%Y-%m-%d' 2>/dev/null || echo "N/A")
  fi
  if [[ -n "$newest_ts" && "$newest_ts" =~ ^[0-9]+$ ]]; then
    newest_date=$(date -r "$newest_ts" '+%Y-%m-%d' 2>/dev/null || echo "N/A")
  fi

  echo "[$subfolders subfolders, $files files, $size, $oldest_date → $newest_date]"
}

# Generate 7-level folder listing
generate_folder_listing() {
  local vol="$1"
  local output_file="$2"
  local is_tm="$3"
  local max_depth=7

  echo "" >> "$output_file"
  echo "--- FOLDER STRUCTURE (7 levels) ---" >> "$output_file"

  if [[ "$is_tm" == "0" ]]; then
    # Time Machine: find Desktop folder in latest backup
    local latest_backup=$(ls -d "$vol"/*.previous 2>/dev/null | head -1)
    if [[ -z "$latest_backup" ]]; then
      latest_backup=$(ls -d "$vol"/*.backup 2>/dev/null | tail -1)
    fi

    local desktop_path="$latest_backup/Data/Users/mohammadshehata/Desktop"
    if [[ -d "$desktop_path" ]]; then
      echo "Source: $desktop_path" >> "$output_file"
      echo "" >> "$output_file"

      # Get all folders up to 7 levels
      find "$desktop_path" -maxdepth $max_depth -type d 2>/dev/null | while read -r dir; do
        local rel_path="${dir#$desktop_path}"
        local depth=$(echo "$rel_path" | tr -cd '/' | wc -c)

        if [[ $depth -eq $max_depth ]]; then
          # Deepest level: add stats
          local stats=$(get_folder_stats "$dir")
          echo "$dir  $stats" >> "$output_file"
        else
          echo "$dir" >> "$output_file"
        fi
      done
    else
      echo "Desktop folder not found in Time Machine backup" >> "$output_file"
    fi
  else
    # Regular drive: 7 levels from root
    echo "Source: $vol" >> "$output_file"
    echo "" >> "$output_file"

    find "$vol" -maxdepth $max_depth -type d 2>/dev/null | grep -v "^\." | while read -r dir; do
      local rel_path="${dir#$vol}"
      local depth=$(echo "$rel_path" | tr -cd '/' | wc -c)

      if [[ $depth -eq $max_depth ]]; then
        # Deepest level: add stats
        local stats=$(get_folder_stats "$dir")
        echo "$dir  $stats" >> "$output_file"
      else
        echo "$dir" >> "$output_file"
      fi
    done
  fi

  echo "" >> "$output_file"
}

# Detect Time Machine data
detect_timemachine() {
  local vol=$1
  local output_file=$2

  # Check for TM indicators
  if [[ -f "$vol/backup_manifest.plist" ]] || \
     ls "$vol"/*.backup &>/dev/null 2>&1 || \
     ls "$vol"/*.previous &>/dev/null 2>&1; then

    echo "" >> "$output_file"
    echo "--- TIME MACHINE DATA ---" >> "$output_file"
    echo "Status: Active Time Machine drive" >> "$output_file"

    # Get snapshots via tmutil
    local snapshots=$(tmutil listbackups "$vol" 2>/dev/null)
    if [[ -n "$snapshots" ]]; then
      local count=$(echo "$snapshots" | wc -l | tr -d ' ')
      local oldest=$(echo "$snapshots" | head -1 | xargs basename 2>/dev/null)
      local latest=$(echo "$snapshots" | tail -1 | xargs basename 2>/dev/null)

      echo "Snapshots: $count found" >> "$output_file"

      # Extract dates from snapshot names
      local oldest_date=$(echo "$oldest" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
      local latest_date=$(echo "$latest" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)

      if [[ -n "$oldest_date" && -n "$latest_date" ]]; then
        echo "Date range: $oldest_date to $latest_date" >> "$output_file"
      fi

      echo "Oldest: $oldest" >> "$output_file"
      echo "Latest: $latest" >> "$output_file"

      echo "" >> "$output_file"
      echo "All snapshots:" >> "$output_file"
      echo "$snapshots" | while read -r snap; do
        echo "  - $(basename "$snap")" >> "$output_file"
      done
    fi

    # Check for in-progress or interrupted backups
    local inprogress=$(ls -d "$vol"/*.inprogress 2>/dev/null | head -1)
    local interrupted=$(ls -d "$vol"/*.interrupted 2>/dev/null | head -1)

    if [[ -n "$inprogress" ]]; then
      echo "" >> "$output_file"
      echo "In progress: $(basename "$inprogress")" >> "$output_file"
    fi
    if [[ -n "$interrupted" ]]; then
      echo "Interrupted: $(basename "$interrupted")" >> "$output_file"
    fi

    return 0  # Is Time Machine
  fi
  return 1  # Not Time Machine
}

# Audit a single drive
audit_drive() {
  local vol=$1
  local drive_num=$2
  local total_drives=$3
  local temp_output="$TEMP_DIR/drive_${drive_num}.txt"
  local progress_file="$TEMP_DIR/progress_${drive_num}.txt"

  local vol_name=$(basename "$vol")

  echo "0|Starting|$vol_name" > "$progress_file"

  {
    echo "======================================"
    echo "VOLUME: $vol"
    echo "======================================"

    # Step 1: Disk usage (20%)
    echo "20|Disk usage|$vol_name" > "$progress_file"
    echo ""
    echo "--- DISK USAGE ---"
    df -h "$vol" 2>/dev/null

    # Step 2: Top-level contents (40%)
    echo "40|Contents|$vol_name" > "$progress_file"
    echo ""
    echo "--- TOP-LEVEL CONTENTS ---"
    ls -la "$vol" 2>/dev/null

    # Step 3: Folder sizes (60%)
    echo "60|Folder sizes|$vol_name" > "$progress_file"
    echo ""
    echo "--- FOLDER SIZES ---"
    du -sh "$vol"*/ 2>/dev/null | sort -h

    # Step 4: File count (80%)
    echo "80|Counting files|$vol_name" > "$progress_file"
    echo ""
    echo "--- FILE COUNT ---"
    local file_count=$(find "$vol" -type f 2>/dev/null | wc -l | tr -d ' ')
    local folder_count=$(find "$vol" -type d 2>/dev/null | wc -l | tr -d ' ')
    echo "Total files: $file_count"
    echo "Total folders: $folder_count"

    # Step 5: Time Machine detection (85%)
    echo "85|Time Machine|$vol_name" > "$progress_file"
    detect_timemachine "$vol" "$temp_output"
    local is_tm=$?

    # Step 6: Folder structure (7 levels) (95%)
    echo "95|Folder listing|$vol_name" > "$progress_file"
    generate_folder_listing "$vol" "$temp_output" "$is_tm"

    echo "100|Complete|$vol_name|$is_tm|$file_count" > "$progress_file"
    echo ""
  } >> "$temp_output" 2>&1
}

# Display progress for all drives
display_progress() {
  local total=$1
  shift
  local volumes=("$@")

  while true; do
    local all_complete=true
    printf "\r\033[K"  # Clear line

    for i in $(seq 1 $total); do
      local progress_file="$TEMP_DIR/progress_${i}.txt"
      if [[ -f "$progress_file" ]]; then
        local data=$(cat "$progress_file")
        local percent=$(echo "$data" | cut -d'|' -f1)
        local step=$(echo "$data" | cut -d'|' -f2)
        local name=$(echo "$data" | cut -d'|' -f3)

        if [[ "$percent" != "100" ]]; then
          all_complete=false
        fi

        # Get spinner char
        local spin_idx=$(($(date +%s%N | cut -c1-10) % ${#SPIN}))
        local spin_char="${SPIN:$spin_idx:1}"

        if [[ "$percent" == "100" ]]; then
          printf "%s %-15s " "${GREEN}✓${NC}" "$name"
        else
          printf "%s %-15s %s %s  " "${CYAN}$spin_char${NC}" "$name" "$(progress_bar $percent)" "$step"
        fi
      fi
    done

    if $all_complete; then
      printf "\n"
      break
    fi

    sleep 0.2
  done
}

# Main execution
main() {
  echo "======================================"
  echo "=== DRIVE AUDIT (Parallel Mode) ==="
  echo "======================================"
  echo "Date: $(date)"
  echo "Machine: $(hostname)"
  echo ""

  # Collect external volumes
  declare -a volumes
  for vol in /Volumes/*/; do
    # Skip system volumes and the shared plan folder
    if [[ "$vol" == *"Macintosh HD"* ]] || \
       [[ "$vol" == *"Recovery"* ]] || \
       [[ "$vol" == *"Preboot"* ]] || \
       [[ "$vol" == *"DataStoragePlan"* ]] || \
       [[ "$vol" == *"com.apple"* ]]; then
      continue
    fi
    volumes+=("$vol")
  done

  local total=${#volumes[@]}

  if [[ $total -eq 0 ]]; then
    echo "${RED}No external drives found!${NC}"
    exit 1
  fi

  echo "Drives found: $total"
  for i in "${!volumes[@]}"; do
    local name=$(basename "${volumes[$i]}")
    local size=$(df -h "${volumes[$i]}" 2>/dev/null | tail -1 | awk '{print $2}')
    echo "  $((i+1)). $name ($size)"
  done
  echo ""
  echo "Auditing in parallel..."
  echo ""

  # Start parallel audits
  for i in "${!volumes[@]}"; do
    audit_drive "${volumes[$i]}" $((i+1)) $total &
  done

  # Display progress
  sleep 0.5  # Let processes start
  display_progress $total "${volumes[@]}"

  # Wait for all to complete
  wait

  # Save each drive to its own file and show summary
  echo ""
  echo "${BOLD}=== SUMMARY ===${NC}"

  declare -a saved_files

  for i in $(seq 1 $total); do
    local temp_output="$TEMP_DIR/drive_${i}.txt"
    local progress_file="$TEMP_DIR/progress_${i}.txt"

    if [[ -f "$progress_file" ]]; then
      local data=$(cat "$progress_file")
      local name=$(echo "$data" | cut -d'|' -f3)
      local is_tm=$(echo "$data" | cut -d'|' -f4)
      local files=$(echo "$data" | cut -d'|' -f5)

      # Create individual file for this drive
      local drive_output="$LOG_DIR/AUDIT_${name}_${DATE_STAMP}.txt"

      {
        echo "=== DRIVE AUDIT: $name ==="
        echo "Date: $(date)"
        echo "Machine: $(hostname)"
        echo ""
        cat "$temp_output"
        echo ""
        echo "======================================"
        echo "AUDIT COMPLETE"
        echo "======================================"
      } > "$drive_output"

      saved_files+=("$drive_output")

      # Show summary line
      if [[ "$is_tm" == "0" ]]; then
        local snap_count=$(grep -c "^  - " "$temp_output" 2>/dev/null || echo "?")
        printf "%s %-15s %s files, %s (%s snapshots)\n" "${GREEN}✓${NC}" "$name" "$files" "${YELLOW}Time Machine${NC}" "$snap_count"
      else
        printf "%s %-15s %s files\n" "${GREEN}✓${NC}" "$name" "$files"
      fi
      echo "   → Saved: $drive_output"
    fi
  done

  echo ""
  echo "======================================"
  echo "${GREEN}AUDIT COMPLETE${NC}"
  echo "Files saved to: $LOG_DIR/"
  for f in "${saved_files[@]}"; do
    echo "  - $(basename "$f")"
  done

  # Cleanup
  rm -rf "$TEMP_DIR"

  # Update M1 status
  echo "[$(date)] Audit complete. $total drives. Individual files saved to $LOG_DIR/" >> "$PLAN_DIR/logs/M1_STATUS.txt"
}

# Run main
main "$@"
