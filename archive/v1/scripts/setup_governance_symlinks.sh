#!/bin/bash
# setup_governance_symlinks.sh
# Creates symlinks from project roots to _governance/ folder (Option C)
#
# Usage: ./setup_governance_symlinks.sh
# Run after migrating projects to new FILICITI structure

set -e

FILICITI="$HOME/Desktop/FILICITI/Products"

# Define projects: "wrapper_path:project_name"
PROJECTS=(
  "$FILICITI/COEVOLVE:code"
  "$FILICITI/COEVOLVE:businessplan"
  "$FILICITI/FlowInLife:app"
  "$FILICITI/FlowInLife:yutaai"
  "$FILICITI/FlowInLife:businessplan"
)

GOVERNANCE_FILES=(
  "CLAUDE.md"
  "CONTEXT.md"
  "SESSION_LOG.md"
  "PLAN.md"
  "Conversations"
)

echo "=== Setting up Governance Symlinks (Option C) ==="
echo ""

for entry in "${PROJECTS[@]}"; do
  wrapper="${entry%%:*}"
  project="${entry#*:}"

  gov_src="$wrapper/_governance/$project"
  project_dir="$wrapper/$project"

  # Check if wrapper exists
  if [ ! -d "$wrapper" ]; then
    echo "SKIP: $wrapper does not exist yet"
    continue
  fi

  echo "=== Setting up $project_dir ==="

  # Create governance source folder if missing
  mkdir -p "$gov_src"
  mkdir -p "$gov_src/Conversations/$(date +%Y/%m)"

  # Create symlinks for each governance file
  for file in "${GOVERNANCE_FILES[@]}"; do
    src="$gov_src/$file"
    dest="$project_dir/$file"

    # Create source file if missing (except Conversations)
    if [[ "$file" != "Conversations" && ! -f "$src" ]]; then
      touch "$src"
      echo "  Created: $src"
    fi

    # Create symlink if project dir exists
    if [ -d "$project_dir" ]; then
      if [ ! -L "$dest" ] && [ ! -e "$dest" ]; then
        ln -sf "../_governance/$project/$file" "$dest"
        echo "  Symlink: $dest -> ../_governance/$project/$file"
      elif [ -L "$dest" ]; then
        echo "  Exists: $dest (symlink)"
      else
        echo "  WARNING: $dest exists as regular file"
      fi
    fi
  done

  # Add symlinks to inner repo's .gitignore
  if [ -d "$project_dir/.git" ]; then
    gitignore="$project_dir/.gitignore"
    touch "$gitignore"
    for file in "${GOVERNANCE_FILES[@]}"; do
      if ! grep -q "^$file$" "$gitignore" 2>/dev/null; then
        echo "$file" >> "$gitignore"
      fi
    done
    echo "  Updated .gitignore"
  fi

  echo ""
done

echo "Done! Governance symlinks created."
echo ""
echo "Next steps:"
echo "  1. Run setup_plan_symlinks.sh to create plan symlinks"
echo "  2. Populate governance files with content"
