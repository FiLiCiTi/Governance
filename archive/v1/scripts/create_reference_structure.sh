#!/bin/bash
# create_reference_structure.sh
# Creates empty FILICITI_REFERENCE folder as template for migrations
#
# Usage: ./create_reference_structure.sh

set -e

REF="$HOME/Desktop/FILICITI_REFERENCE"

echo "=== Creating FILICITI Reference Structure ==="
echo "Location: $REF"
echo ""

# Check if already exists
if [ -d "$REF" ]; then
  echo "WARNING: $REF already exists"
  read -p "Overwrite? (y/n): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
  fi
  rm -rf "$REF"
fi

# Create company-level structure
mkdir -p "$REF/_Governance/DECISIONS"
mkdir -p "$REF/_Shared/Personas"
mkdir -p "$REF/_Shared/Integration"
mkdir -p "$REF/_Shared/Market"

# Create COEVOLVE product structure
mkdir -p "$REF/Products/COEVOLVE/_governance/code/10_Thought_Process"
mkdir -p "$REF/Products/COEVOLVE/_governance/businessplan/10_Thought_Process"
mkdir -p "$REF/Products/COEVOLVE/code/src"
mkdir -p "$REF/Products/COEVOLVE/businessplan/01_Strategy"
mkdir -p "$REF/Products/COEVOLVE/businessplan/02_Research"
mkdir -p "$REF/Products/COEVOLVE/businessplan/03_Awareness"
mkdir -p "$REF/Products/COEVOLVE/businessplan/04_Convert"
mkdir -p "$REF/Products/COEVOLVE/businessplan/05_Deliver"
mkdir -p "$REF/Products/COEVOLVE/businessplan/06_Operations"
mkdir -p "$REF/Products/COEVOLVE/businessplan/07_Grow"
mkdir -p "$REF/Products/COEVOLVE/businessplan/08_Templates"
mkdir -p "$REF/Products/COEVOLVE/businessplan/09_Meeting_Notes"
mkdir -p "$REF/Products/COEVOLVE/_Archaeology"

# Create FlowInLife product structure
mkdir -p "$REF/Products/FlowInLife/_governance/app/10_Thought_Process"
mkdir -p "$REF/Products/FlowInLife/_governance/yutaai/10_Thought_Process"
mkdir -p "$REF/Products/FlowInLife/_governance/businessplan/10_Thought_Process"
mkdir -p "$REF/Products/FlowInLife/_Integration"
mkdir -p "$REF/Products/FlowInLife/app/src"
mkdir -p "$REF/Products/FlowInLife/yutaai/src"
mkdir -p "$REF/Products/FlowInLife/businessplan"
mkdir -p "$REF/Products/FlowInLife/_Archaeology"

# Create LABS product structure
mkdir -p "$REF/Products/LABS/_governance/google_extractor/10_Thought_Process"
mkdir -p "$REF/Products/LABS/google_extractor/src"
mkdir -p "$REF/Products/LABS/ssl-learning"
mkdir -p "$REF/Products/LABS/ai-HCMR"
mkdir -p "$REF/Products/LABS/graphreasoning"
mkdir -p "$REF/Products/LABS/_Archaeology"

# Create Corporate placeholder
mkdir -p "$REF/Corporate"

# Create placeholder files - Company level
touch "$REF/_Governance/CONTEXT.md"
touch "$REF/_Governance/SESSION_INDEX.md"
touch "$REF/_Governance/CROSS_PROJECT.md"
touch "$REF/_Governance/DECISIONS/_INDEX.md"

# Create placeholder files - COEVOLVE
touch "$REF/Products/COEVOLVE/CLAUDE.md"
touch "$REF/Products/COEVOLVE/.gitignore"
touch "$REF/Products/COEVOLVE/_governance/code/CLAUDE.md"
touch "$REF/Products/COEVOLVE/_governance/code/CONTEXT.md"
touch "$REF/Products/COEVOLVE/_governance/code/SESSION_LOG.md"
touch "$REF/Products/COEVOLVE/_governance/code/PLAN.md"
touch "$REF/Products/COEVOLVE/_governance/businessplan/CLAUDE.md"
touch "$REF/Products/COEVOLVE/_governance/businessplan/CONTEXT.md"
touch "$REF/Products/COEVOLVE/_governance/businessplan/SESSION_LOG.md"
touch "$REF/Products/COEVOLVE/_governance/businessplan/PLAN.md"
touch "$REF/Products/COEVOLVE/code/.gitignore"
touch "$REF/Products/COEVOLVE/code/README.md"

# Create placeholder files - FlowInLife
touch "$REF/Products/FlowInLife/CLAUDE.md"
touch "$REF/Products/FlowInLife/.gitignore"
touch "$REF/Products/FlowInLife/_governance/app/CLAUDE.md"
touch "$REF/Products/FlowInLife/_governance/app/CONTEXT.md"
touch "$REF/Products/FlowInLife/_governance/yutaai/CLAUDE.md"
touch "$REF/Products/FlowInLife/_governance/yutaai/CONTEXT.md"
touch "$REF/Products/FlowInLife/_governance/businessplan/CLAUDE.md"
touch "$REF/Products/FlowInLife/_governance/businessplan/CONTEXT.md"
touch "$REF/Products/FlowInLife/_Integration/API_CONTRACT.md"
touch "$REF/Products/FlowInLife/_Integration/DECISIONS.md"
touch "$REF/Products/FlowInLife/app/.gitignore"
touch "$REF/Products/FlowInLife/yutaai/.gitignore"

# Create placeholder files - LABS
touch "$REF/Products/LABS/CLAUDE.md"
touch "$REF/Products/LABS/CONTEXT.md"
touch "$REF/Products/LABS/_governance/google_extractor/CLAUDE.md"
touch "$REF/Products/LABS/_governance/google_extractor/CONTEXT.md"

# Add .gitignore content for code repos
cat > "$REF/Products/COEVOLVE/code/.gitignore" << 'EOF'
# Governance symlinks (tracked in wrapper)
CLAUDE.md
CONTEXT.md
SESSION_LOG.md
PLAN.md
plans/
10_Thought_Process/

# OS files
.DS_Store
EOF

cat > "$REF/Products/FlowInLife/app/.gitignore" << 'EOF'
# Governance symlinks (tracked in wrapper)
CLAUDE.md
CONTEXT.md
SESSION_LOG.md
PLAN.md
plans/
10_Thought_Process/

# OS files
.DS_Store
EOF

cat > "$REF/Products/FlowInLife/yutaai/.gitignore" << 'EOF'
# Governance symlinks (tracked in wrapper)
CLAUDE.md
CONTEXT.md
SESSION_LOG.md
PLAN.md
plans/
10_Thought_Process/

# OS files
.DS_Store
EOF

# Add .gitignore content for wrapper repos
cat > "$REF/Products/COEVOLVE/.gitignore" << 'EOF'
# Inner repos (have their own git)
code/

# OS files
.DS_Store
EOF

cat > "$REF/Products/FlowInLife/.gitignore" << 'EOF'
# Inner repos (have their own git)
app/
yutaai/

# OS files
.DS_Store
EOF

echo ""
echo "Created structure:"
find "$REF" -type d | head -50
echo "..."
echo ""
echo "Total folders: $(find "$REF" -type d | wc -l)"
echo "Total files: $(find "$REF" -type f | wc -l)"
echo ""
echo "Done! Reference structure created at $REF"
echo ""
echo "Use this as a template when migrating projects."
