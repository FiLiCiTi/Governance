#!/bin/bash
# hooks/check_boundaries.sh
# Hook: PreToolUse (Edit|Write)
# Purpose: Block edits to files matching CANNOT modify patterns
# Exit 2 = Block action, stderr shown to Claude
# v2.5.1: Allow ~/.claude/* (sessions, plans, etc.)

# Check dependencies
if ! command -v jq &> /dev/null; then
    echo -e "\033[36m[BOUNDARY]\033[0m ▸▸▸ ⚠️ ERROR: jq not found. Cannot check boundaries." >&2
    exit 0  # Allow operation if jq missing (fail open for usability)
fi

INPUT=$(cat)
if [[ -z "$INPUT" ]]; then
    echo -e "\033[36m[BOUNDARY]\033[0m ▸▸▸ ⚠️ ERROR: No input received." >&2
    exit 0
fi

FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null)
CWD=$(echo "$INPUT" | jq -r '.cwd' 2>/dev/null)

# Skip if no file path
if [[ -z "$FILE" || "$FILE" == "null" ]]; then
    exit 0
fi

# v2.5.1: Allow ~/.claude/* (system files)
# This includes sessions, plans, compact_flag, etc.
if [[ "$FILE" == "$HOME/.claude/"* ]]; then
    exit 0
fi

# Check project CLAUDE.md for boundaries
CLAUDE_MD="$CWD/CLAUDE.md"
if [[ -f "$CLAUDE_MD" ]]; then
    # Extract CANNOT modify patterns (comma-separated, backtick-wrapped)
    # Pattern: `/path1/`, `/path2/`, `path3/`
    while IFS= read -r pattern; do
        # Clean pattern: remove backticks, asterisks, trim whitespace
        pattern=$(echo "$pattern" | tr -d '`*' | xargs)
        # Skip empty patterns
        if [[ -n "$pattern" && ${#pattern} -gt 1 ]]; then
            if [[ "$FILE" == *"$pattern"* ]]; then
                echo -e "\033[36m[BOUNDARY]\033[0m ▸▸▸ BLOCKED: $FILE matches CANNOT modify: $pattern" >&2
                exit 2
            fi
        fi
    done < <(grep -i "CANNOT modify:" "$CLAUDE_MD" | sed 's/.*CANNOT modify://' | tr ',' '\n')
fi

exit 0
