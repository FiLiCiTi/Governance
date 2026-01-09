# Implementation Best Practices

> **Purpose:** Document common implementation gaps and solutions from v2 experience
> **Created:** 2026-01-07
> **Status:** ACTIVE (v2.5.1)

---

## Table of Contents

| Section | Title                                          | Line   |
|---------|------------------------------------------------|--------|
| 1       | [Overview](#1-overview)                        | :17    |
| 2       | [Git Wrapper Pattern](#2-git-wrapper-pattern)  | :31    |
| 3       | [CLAUDE.md Location](#3-claudemd-location)     | :90    |
| 4       | [Symlinks in Finder](#4-symlinks-in-finder)    | :140   |
| 5       | [Quick Reference](#5-quick-reference)          | :195   |

---

## 1. Overview

### What This Document Covers

This guide documents implementation patterns and common pitfalls discovered during v2 governance development. These best practices prevent:
- Script failures due to incorrect paths
- CLAUDE.md not loading where expected
- Confusion between symlinks and original files

### When to Use This Guide

- Setting up new projects with governance
- Debugging hook failures
- Understanding directory structure

---

## 2. Git Wrapper Pattern

### The Problem

**Issue:** Scripts that depend on git operations fail when `.git` is a file (worktree) instead of directory.

**Example failure:**
```bash
# Script assumes .git is a directory
if [ -d ".git" ]; then
    git rev-parse --abbrev-ref HEAD
fi
```

**Fails when:** `.git` is a file containing worktree reference:
```
gitdir: /Users/name/.git/worktrees/my-feature
```

### The Solution

**Pattern: Always use git commands, not .git directory checks**

```bash
# WRONG - Assumes .git is a directory
if [ -d ".git" ]; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi

# CORRECT - Use git command to check if in repo
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi
```

### Implementation

**In hooks (check_boundaries.sh, inject_context.sh, etc.):**

```bash
# Check if in git repo (handles both .git directory and worktree)
is_git_repo() {
    git rev-parse --git-dir > /dev/null 2>&1
}

# Get current branch (works with worktrees)
get_current_branch() {
    if is_git_repo; then
        git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown"
    else
        echo "not-a-repo"
    fi
}

# Get git root directory (works with worktrees)
get_git_root() {
    if is_git_repo; then
        git rev-parse --show-toplevel 2>/dev/null
    fi
}
```

### Testing

```bash
# Test in normal repo
cd ~/Desktop/FILICITI
git rev-parse --git-dir   # Should output: .git

# Test in worktree
git worktree add ../feature-xyz feature/xyz
cd ../feature-xyz
git rev-parse --git-dir   # Should output: /Users/.../.git/worktrees/feature-xyz
```

---

## 3. CLAUDE.md Location

### The Problem

**Issue:** Unclear precedence when multiple CLAUDE.md files exist.

**Confusion scenarios:**
1. Both `~/.claude/CLAUDE.md` and `~/Desktop/Project/CLAUDE.md` exist - which wins?
2. Symlink in project points to global - is this intentional or broken?
3. CLAUDE.md not loading - which location should I check?

### The Solution

**Layer Hierarchy (9-Layer System):**

| Layer | Location                              | Scope       | Loaded By           | Precedence |
|-------|---------------------------------------|-------------|---------------------|------------|
| 3     | `~/.claude/CLAUDE.md`                 | Global      | SessionStart hook   | Highest    |
| 2     | `~/Desktop/[Project]/CLAUDE.md`       | Project     | Claude Code auto    | Medium     |
| 1     | Inline prompts                        | Per-message | User types          | Lowest     |

**Loading order:**
1. Claude Code loads Layer 2 (project CLAUDE.md) automatically if exists
2. SessionStart hook injects Layer 3 (global CLAUDE.md) content
3. Layer 3 rules **override** Layer 2 if conflicts exist

### Best Practices

**1. Global rules in `~/.claude/CLAUDE.md`:**
```markdown
# Global Rules (Layer 3)
## Output Format
3. Never dump full files. Show changes: `+ added` / `- removed`
4. Summarize, don't dump.

## Tables in .md Files (STRICT)
5. ALL tables MUST be pretty-formatted
```

**2. Project-specific rules in `[Project]/CLAUDE.md`:**
```markdown
# Project Rules (Layer 2)
> **Type:** CODE | **Stack:** React + FastAPI

## Boundaries
- **CAN modify:** code/ folder
- **CANNOT modify:** /Volumes/, /etc/

## Links
- Governance: `~/Desktop/Governance/`
```

**3. Never duplicate global rules in project CLAUDE.md:**
```markdown
# ❌ WRONG - Duplicates global rules
## Output Format
3. Never dump full files...  # Already in global CLAUDE.md

# ✅ CORRECT - Only project-specific info
## Boundaries
- **CAN modify:** code/
```

### Symlinks vs Original Files

**When to use symlinks:**
- ✅ Never (avoid symlinks for CLAUDE.md)
- ✅ Create project-specific CLAUDE.md instead
- ✅ Reference global rules via "see ~/.claude/CLAUDE.md"

**Why avoid symlinks:**
- Hard to tell in Finder if file is symlink or original
- Claude Code may not follow symlinks consistently
- Editing symlink in one project affects all projects

---

## 4. Symlinks in Finder

### The Problem

**Issue:** Finder doesn't clearly distinguish symlinks from original files/folders.

**Example confusion:**
```
~/Desktop/FILICITI/      # Original folder?
~/Desktop/FILICITI/      # Or symlink to /Volumes/T7/FILICITI/?
```

### The Solution

**Method 1: Terminal - Check with `ls -la`**

```bash
# Check if directory is symlink
ls -la ~/Desktop/ | grep FILICITI

# Output if ORIGINAL:
drwxr-xr-x  50 user  staff  1600 Jan  7 10:00 FILICITI

# Output if SYMLINK:
lrwxr-xr-x   1 user  staff    25 Jan  7 10:00 FILICITI -> /Volumes/T7/FILICITI
                                                     ^^^^^^^^^^^^^^^^^^^^^^^^
                                                     Arrow indicates symlink target
```

**Method 2: Terminal - Use `file` command**

```bash
# Check file/folder type
file ~/Desktop/FILICITI

# Output if ORIGINAL:
/Users/user/Desktop/FILICITI: directory

# Output if SYMLINK:
/Users/user/Desktop/FILICITI: symbolic link to /Volumes/T7/FILICITI
```

**Method 3: Terminal - Use `readlink`**

```bash
# If symlink, shows target. If original, shows nothing
readlink ~/Desktop/FILICITI

# Output if SYMLINK:
/Volumes/T7/FILICITI

# Output if ORIGINAL:
(no output, exit code 1)
```

**Method 4: Finder - Get Info**

```
1. Select file/folder in Finder
2. Press Cmd+I (Get Info)
3. Look for "Original:" field
   - If present → It's an ALIAS (similar to symlink)
   - If absent → Check "Kind" field
     - "Folder" → Original
     - "Alias" → Symlink-like reference
```

### Best Practices

**1. Document symlinks in project CLAUDE.md:**

```markdown
# Project Structure (Layer 2)

## Important: This is a symlink
- Location: `~/Desktop/FILICITI/` (symlink)
- Target: `/Volumes/T7/FILICITI/` (original)
- Reason: T7 external SSD for large project

## Boundaries
- **CAN modify:** `/Volumes/T7/FILICITI/code/`
- **CANNOT modify:** `/Volumes/` (other volumes)
```

**2. Use absolute paths in hooks when dealing with symlinks:**

```bash
# Get real path (resolves symlinks)
REAL_PATH=$(cd "$CWD" && pwd -P)

# Now REAL_PATH is /Volumes/T7/FILICITI even if CWD is ~/Desktop/FILICITI
```

**3. Check symlinks during setup:**

```bash
# Add to project setup checklist
echo "Checking for symlinks..."
for dir in ~/Desktop/*/; do
    if [ -L "$dir" ]; then
        target=$(readlink "$dir")
        echo "Symlink: $(basename "$dir") -> $target"
    fi
done
```

---

## 5. Quick Reference

### Git Wrapper Commands

```bash
# Check if in git repo (handles worktrees)
git rev-parse --git-dir > /dev/null 2>&1

# Get current branch (handles worktrees)
git rev-parse --abbrev-ref HEAD

# Get git root (handles worktrees)
git rev-parse --show-toplevel
```

### CLAUDE.md Hierarchy

```
Layer 3 (Highest):  ~/.claude/CLAUDE.md          (Global rules)
Layer 2 (Medium):   ~/Desktop/[Project]/CLAUDE.md (Project rules)
Layer 1 (Lowest):   Inline prompts                (Per-message)
```

### Symlink Detection Commands

```bash
# Method 1: ls with -l flag
ls -la ~/Desktop/ | grep [folder]

# Method 2: file command
file ~/Desktop/[folder]

# Method 3: readlink
readlink ~/Desktop/[folder]

# Method 4: Get real path
cd ~/Desktop/[folder] && pwd -P
```

---

## Decision IDs

| ID   | Decision                                              |
|------|-------------------------------------------------------|
| #G47 | Use git commands (not .git directory checks)          |
| #G48 | Layer 3 (global) overrides Layer 2 (project)          |
| #G49 | Avoid CLAUDE.md symlinks (create project-specific)    |
| #G50 | Document symlinks in project CLAUDE.md if used        |

---

**End of Implementation Best Practices Guide**

*Created: 2026-01-07 | For: v2.5.1 and beyond*
