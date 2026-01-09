#!/bin/bash
# setup_plan_symlinks.sh
# Creates symlinks from project plans/ to ~/.claude/plans/[project]/
#
# Usage: ./setup_plan_symlinks.sh

set -e

# Projects: "plan_folder_name:governance_path"
# For products with _governance/, plans/ goes inside _governance/[project]/
# For standalone (DataStoragePlan), plans/ goes at root

PROJECTS=(
  "COEVOLVE_code:$HOME/Desktop/FILICITI/Products/COEVOLVE/_governance/code"
  "COEVOLVE_bizplan:$HOME/Desktop/FILICITI/Products/COEVOLVE/_governance/businessplan"
  "FlowInLife_app:$HOME/Desktop/FILICITI/Products/FlowInLife/_governance/app"
  "FlowInLife_yutaai:$HOME/Desktop/FILICITI/Products/FlowInLife/_governance/yutaai"
  "FlowInLife_bizplan:$HOME/Desktop/FILICITI/Products/FlowInLife/_governance/businessplan"
  "LABS:$HOME/Desktop/FILICITI/Products/LABS"
  "DataStoragePlan:$HOME/Desktop/DataStoragePlan"
)

echo "=== Setting up Plan Symlinks ==="
echo ""

for entry in "${PROJECTS[@]}"; do
  name="${entry%%:*}"
  path="${entry#*:}"

  # Create folder in ~/.claude/plans/
  plans_target="$HOME/.claude/plans/$name"
  mkdir -p "$plans_target"

  # Create symlink in governance folder
  symlink_location="$path/plans"

  if [ -d "$path" ]; then
    if [ ! -L "$symlink_location" ] && [ ! -e "$symlink_location" ]; then
      ln -s "$plans_target" "$symlink_location"
      echo "Created: $symlink_location -> $plans_target"
    elif [ -L "$symlink_location" ]; then
      echo "Exists:  $symlink_location (symlink)"
    else
      echo "WARNING: $symlink_location exists as regular file/folder"
    fi
  else
    echo "SKIP:    $path does not exist yet"
    echo "         (will create ~/.claude/plans/$name anyway)"
  fi
done

echo ""
echo "Done! Plan symlinks created."
echo ""
echo "Claude plans will be stored in ~/.claude/plans/[project]/"
echo "and accessible via [project]/plans/ symlink"
