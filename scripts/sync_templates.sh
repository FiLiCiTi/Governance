#!/bin/bash
# scripts/sync_templates.sh
# Purpose: Sync template files between Governance/templates and ~/.claude/templates
# v3: Prevents template drift between version-controlled and global locations
# Usage:
#   ./sync_templates.sh          # Push from Governance to ~/.claude (default)
#   ./sync_templates.sh push     # Same as default
#   ./sync_templates.sh pull     # Pull from ~/.claude to Governance
#   ./sync_templates.sh check    # Check for differences (dry-run)

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paths
GOVERNANCE_DIR="$HOME/Desktop/Governance"
GOVERNANCE_TEMPLATES="$GOVERNANCE_DIR/templates"
GLOBAL_TEMPLATES="$HOME/.claude/templates"

# Shared templates (synced between both locations)
SHARED_TEMPLATES=(
    "CONTEXT_TEMPLATE.md"
    "session_handoff.md"
    "Shared_context_TEMPLATE.md"
)

# Mode: push (default), pull, or check
MODE="${1:-push}"

# Validate mode
if [[ ! "$MODE" =~ ^(push|pull|check)$ ]]; then
    echo -e "${RED}Error: Invalid mode '$MODE'${NC}"
    echo "Usage: $0 [push|pull|check]"
    exit 1
fi

# Ensure directories exist
if [[ ! -d "$GOVERNANCE_TEMPLATES" ]]; then
    echo -e "${RED}Error: Governance templates directory not found: $GOVERNANCE_TEMPLATES${NC}"
    exit 1
fi

if [[ ! -d "$GLOBAL_TEMPLATES" ]]; then
    echo -e "${YELLOW}Warning: Global templates directory not found. Creating: $GLOBAL_TEMPLATES${NC}"
    mkdir -p "$GLOBAL_TEMPLATES"
fi

# Function: Compare two files and report status
compare_files() {
    local file="$1"
    local source="$2"
    local dest="$3"

    if [[ ! -f "$source" ]]; then
        echo -e "${YELLOW}  ⚠ Missing in source${NC}"
        return 1
    elif [[ ! -f "$dest" ]]; then
        echo -e "${BLUE}  → New file (will be created)${NC}"
        return 2
    elif diff -q "$source" "$dest" >/dev/null 2>&1; then
        echo -e "${GREEN}  ✓ Identical${NC}"
        return 0
    else
        echo -e "${YELLOW}  ≠ Different${NC}"
        return 3
    fi
}

# Function: Sync file from source to dest
sync_file() {
    local file="$1"
    local source="$2"
    local dest="$3"

    if [[ ! -f "$source" ]]; then
        echo -e "${RED}    Error: Source file not found: $source${NC}"
        return 1
    fi

    cp "$source" "$dest"
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}    ✓ Synced${NC}"
        return 0
    else
        echo -e "${RED}    ✗ Failed to sync${NC}"
        return 1
    fi
}

# Main execution
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Template Sync Tool - v3${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

case "$MODE" in
    push)
        echo -e "${BLUE}Mode: PUSH${NC} (Governance → ~/.claude)"
        echo -e "Source: ${GOVERNANCE_TEMPLATES}"
        echo -e "Dest:   ${GLOBAL_TEMPLATES}"
        echo ""

        SYNCED=0
        SKIPPED=0
        FAILED=0

        for template in "${SHARED_TEMPLATES[@]}"; do
            echo -e "${BLUE}${template}${NC}"
            SOURCE="$GOVERNANCE_TEMPLATES/$template"
            DEST="$GLOBAL_TEMPLATES/$template"

            compare_files "$template" "$SOURCE" "$DEST"
            STATUS=$?

            if [[ $STATUS -eq 0 ]]; then
                # Files identical, skip
                ((SKIPPED++))
            elif [[ $STATUS -eq 1 ]]; then
                # Missing in source, error
                ((FAILED++))
            else
                # Different or new, sync
                sync_file "$template" "$SOURCE" "$DEST"
                if [[ $? -eq 0 ]]; then
                    ((SYNCED++))
                else
                    ((FAILED++))
                fi
            fi
        done

        echo ""
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "Summary: ${GREEN}${SYNCED} synced${NC}, ${YELLOW}${SKIPPED} skipped${NC}, ${RED}${FAILED} failed${NC}"
        ;;

    pull)
        echo -e "${BLUE}Mode: PULL${NC} (~/.claude → Governance)"
        echo -e "Source: ${GLOBAL_TEMPLATES}"
        echo -e "Dest:   ${GOVERNANCE_TEMPLATES}"
        echo ""
        echo -e "${YELLOW}⚠ Warning: This will overwrite files in version-controlled Governance/templates/${NC}"
        read -p "Continue? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Aborted${NC}"
            exit 0
        fi

        SYNCED=0
        SKIPPED=0
        FAILED=0

        for template in "${SHARED_TEMPLATES[@]}"; do
            echo -e "${BLUE}${template}${NC}"
            SOURCE="$GLOBAL_TEMPLATES/$template"
            DEST="$GOVERNANCE_TEMPLATES/$template"

            compare_files "$template" "$SOURCE" "$DEST"
            STATUS=$?

            if [[ $STATUS -eq 0 ]]; then
                # Files identical, skip
                ((SKIPPED++))
            elif [[ $STATUS -eq 1 ]]; then
                # Missing in source, error
                ((FAILED++))
            else
                # Different or new, sync
                sync_file "$template" "$SOURCE" "$DEST"
                if [[ $? -eq 0 ]]; then
                    ((SYNCED++))
                else
                    ((FAILED++))
                fi
            fi
        done

        echo ""
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "Summary: ${GREEN}${SYNCED} synced${NC}, ${YELLOW}${SKIPPED} skipped${NC}, ${RED}${FAILED} failed${NC}"

        if [[ $SYNCED -gt 0 ]]; then
            echo ""
            echo -e "${YELLOW}Note: Don't forget to commit changes to Governance repository${NC}"
        fi
        ;;

    check)
        echo -e "${BLUE}Mode: CHECK${NC} (dry-run, no changes)"
        echo ""

        IDENTICAL=0
        DIFFERENT=0
        MISSING=0

        for template in "${SHARED_TEMPLATES[@]}"; do
            echo -e "${BLUE}${template}${NC}"
            SOURCE="$GOVERNANCE_TEMPLATES/$template"
            DEST="$GLOBAL_TEMPLATES/$template"

            echo -n "  Governance → ~/.claude: "
            compare_files "$template" "$SOURCE" "$DEST"
            STATUS=$?

            if [[ $STATUS -eq 0 ]]; then
                ((IDENTICAL++))
            elif [[ $STATUS -eq 1 ]]; then
                ((MISSING++))
            else
                ((DIFFERENT++))
            fi
        done

        echo ""
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "Summary: ${GREEN}${IDENTICAL} identical${NC}, ${YELLOW}${DIFFERENT} different${NC}, ${RED}${MISSING} missing${NC}"

        if [[ $DIFFERENT -gt 0 ]] || [[ $MISSING -gt 0 ]]; then
            echo ""
            echo -e "${YELLOW}Recommendation: Run './sync_templates.sh push' to sync${NC}"
        else
            echo ""
            echo -e "${GREEN}All templates are in sync!${NC}"
        fi
        ;;
esac

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
