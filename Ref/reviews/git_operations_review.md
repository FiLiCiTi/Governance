# Git Operations Plugin Review

> **Category:** Internal Plugins - Git Operations
> **Count:** 1 plugin
> **Reviewed:** 2026-01-07
> **Cost:** ✓ Low (when invoked)

---

## Table of Contents

| Section | Title                                | Line   |
|---------|--------------------------------------|--------|
| 1       | [Overview](#1-overview)              | :18    |
| 2       | [commit-commands](#2-commit-commands) | :28    |
| 3       | [Integration](#3-integration)        | :155   |
| 4       | [Recommendations](#4-recommendations) | :182   |

---

## 1. Overview

### Category Summary

Git Operations provides workflow automation for common git tasks. Single plugin (commit-commands) with 3 commands covering the complete git workflow from committing to PR creation.

| Plugin          | Commands | Cost      | Installs |
|-----------------|----------|-----------|----------|
| commit-commands | 3        | ✓ Low     | 17.9K    |

---

## 2. commit-commands

### Purpose

Streamline git workflow with simple commands for committing, pushing, and creating pull requests.

### Commands (3)

**`/commit`**
- **Purpose:** Create git commit with auto-generated message
- **Workflow:**
  1. Analyzes git status
  2. Reviews changes
  3. Examines recent commits for style
  4. Stages files
  5. Creates commit with appropriate message
- **Features:**
  - Matches repo commit style
  - Follows conventional commits
  - Avoids committing secrets (.env, credentials.json)
  - Adds Claude Code attribution

**`/commit-push-pr`**
- **Purpose:** Complete workflow (commit + push + create PR)
- **Workflow:**
  1. Creates branch if needed
  2. Commits changes
  3. Pushes to remote
  4. Creates PR via GitHub CLI
  5. Provides PR URL
- **Features:**
  - Comprehensive PR descriptions
  - Test plan checklist
  - Uses GitHub CLI (gh)
  - Claude Code attribution in commits + PR body

**`/clean_gone`**
- **Purpose:** Clean up local branches deleted from remote
- **Workflow:**
  1. Lists [gone] branches
  2. Removes worktrees if present
  3. Deletes local branches
  4. Reports cleanup results
- **Features:**
  - Handles worktrees safely
  - Clear feedback
  - Prevents accidental deletion

### Use Cases

**1. Quick commit during development:**
```bash
# Make changes
/commit
# → Claude stages files and creates commit with appropriate message
```

**2. Feature branch workflow:**
```bash
# Develop feature with multiple commits
/commit  # First commit
# More changes
/commit  # Second commit
# Ready for PR
/commit-push-pr  # Creates PR with comprehensive description
```

**3. Repository maintenance:**
```bash
# After merging several PRs
/clean_gone
# → Removes all stale local branches
```

**4. Learning commit style:**
```bash
# Let Claude learn from your repo
/commit
# → Analyzes recent commit messages to match style
```

**5. Avoiding manual git commands:**
```bash
# Instead of:
# git add .
# git commit -m "message"
# git push origin branch
# gh pr create --title "..." --body "..."

# Just run:
/commit-push-pr
```

### Workflow Comparison

| Manual Git Workflow                | commit-commands Workflow |
|------------------------------------|--------------------------|
| `git status`                       | `/commit`                |
| `git diff`                         | (automatic)              |
| `git log --oneline`                | (automatic)              |
| `git add file1 file2...`           | (automatic)              |
| `git commit -m "descriptive msg"`  | (automatic)              |
| `git push origin branch`           | -                        |
| `gh pr create --title... --body...`| -                        |
| **Total:** 7 commands              | **Total:** 1 command     |

For full PR workflow:

| Manual Workflow                    | commit-commands Workflow |
|------------------------------------|--------------------------|
| `git checkout -b feature/xyz`      | `/commit-push-pr`        |
| `git add .`                        | (automatic)              |
| `git commit -m "..."`              | (automatic)              |
| `git push -u origin feature/xyz`   | (automatic)              |
| `gh pr create --title... --body...`| (automatic)              |
| **Total:** 5 commands              | **Total:** 1 command     |

### When to Use

✅ **USE for:**
- Routine commits during development
- Creating pull requests quickly
- Cleaning up after merging multiple PRs
- Minimizing context switching
- Learning from repo's commit style

❌ **DON'T USE for:**
- Commit messages needing very specific wording
- Granular control over what's staged
- Complex rebase/merge operations
- Interactive rebases
- Cherry-picking commits

### Key Features

- **Auto-generated messages:** Learns from your repo's commit style
- **Conventional commits:** Follows best practices automatically
- **Secret detection:** Won't commit .env, credentials.json, etc.
- **Branch management:** Creates feature branches automatically
- **PR descriptions:** Comprehensive summaries with test plans
- **Claude Code attribution:** Adds attribution to commits and PRs
- **Worktree safety:** clean_gone handles worktrees before deleting branches

### Configuration

No configuration needed. The plugin automatically:
- Detects your repo's commit message style
- Follows conventional commit format when appropriate
- Uses GitHub CLI (gh) if available
- Handles branch naming intelligently

### Requirements

- Git installed and configured
- For `/commit-push-pr`: GitHub CLI (gh) installed and authenticated
- Repository with a remote (for push operations)

### Troubleshooting

**No changes to commit:**
- Ensure you have unstaged or staged changes
- Run `git status` to verify

**/commit-push-pr fails:**
- Install gh: `brew install gh` (macOS)
- Authenticate: `gh auth login`
- Ensure repo has GitHub remote

**/clean_gone finds nothing:**
- Run `git fetch --prune` to update remote tracking
- Branches must be deleted from remote to show as [gone]

### Best Practices

1. **Let Claude draft messages:** Trust the analysis—it learns from your repo
2. **Review before pushing:** `/commit` creates local commits—review before `/commit-push-pr`
3. **Use /commit frequently:** Small, focused commits during development
4. **Save /commit-push-pr for PR time:** Use when feature is complete
5. **Regular cleanup:** Run `/clean_gone` weekly to maintain tidy branch list
6. **Combine with code-review:** `/commit-push-pr` then `/code-review`

---

## 3. Integration

### With Development Workflows

**Recommended sequence:**
```bash
# 1. Build feature
/feature-dev Add user authentication

# 2. Commit during development
/commit  # First milestone
/commit  # Second milestone

# 3. Create PR
/commit-push-pr

# 4. Automated review
/code-review
```

### With Governance System

**Cost tracking:**
- commit-commands = Low cost (when invoked)
- Zero cost when inactive
- Minimal token usage per invocation

**Workflow integration:**
- Global CLAUDE.md rules (Layer 3) define git safety protocol
- SessionStart hook shows plugin count
- No hook dependencies

**Git Safety Protocol (from CLAUDE.md):**
- ✓ NEVER update git config
- ✓ NEVER run destructive commands without confirmation
- ✓ NEVER skip hooks (--no-verify)
- ✓ Avoid `git commit --amend` unless specific conditions met
- ✓ NEVER force push to main/master
- ✓ NEVER commit without user request

commit-commands respects all safety rules automatically.

### Typical Workflows

**Governance project workflow:**
```bash
# Edit governance docs
# ...

# Commit changes
/commit
# → Claude analyzes changes, stages .md files, creates descriptive commit
```

**Feature development workflow:**
```bash
# Use /feature-dev to build feature
/feature-dev Add dark mode toggle

# Throughout implementation, commit milestones
/commit  # After Phase 5 (implementation)

# When ready, create PR
/commit-push-pr

# Run automated review
/code-review
```

---

## 4. Recommendations

### Best Practices

1. **Use /commit for iterative development:**
   - Commit after each logical unit of work
   - Let Claude analyze and create descriptive messages
   - Small commits = easier debugging later

2. **Use /commit-push-pr for feature completion:**
   - Wait until feature is fully implemented
   - One PR = one complete feature
   - Claude creates comprehensive PR description

3. **Run /clean_gone weekly:**
   - After merging multiple PRs
   - Prevents branch clutter
   - Safe worktree handling

4. **Combine with review plugins:**
   ```bash
   /commit-push-pr  # Create PR
   /code-review     # Automated review
   # → Fix issues
   /commit          # Commit fixes
   # → Merge when ready
   ```

### Cost Optimization

**Low-cost plugin = safe to use frequently:**
- ✓ Use /commit as often as needed during development
- ✓ Use /commit-push-pr for every feature PR
- ✓ Use /clean_gone weekly without cost concern
- No need to batch commits to save costs

### Plugin Selection by Project

**All projects (universal):**
```
✓ commit-commands  - Git workflow automation
```

No project exclusions. Even documentation-only projects benefit from `/commit` and `/commit-push-pr`.

### Integration with v2.5 Governance

**Plugin awareness (v2.5 §11-12):**
- commit-commands = Low cost (always safe to have active)
- No high-cost warnings needed
- Can stay active across all projects

**Status line tracking:**
- SessionStart shows plugin count
- No per-plugin cost tracking yet

**Future enhancements (v3 candidate):**
- Auto-trigger /commit after significant work
- Auto-suggest /commit-push-pr when branch is ready
- Track commit frequency per project
- Learn optimal commit message style per project

### Comparison with Manual Git

| Aspect                  | Manual Git Commands | commit-commands       | Winner               |
|-------------------------|---------------------|----------------------|----------------------|
| Commands needed         | 5-7                 | 1                    | commit-commands      |
| Commit message quality  | Manual effort       | Auto-learned style   | commit-commands      |
| Secret detection        | Manual vigilance    | Automatic            | commit-commands      |
| PR description          | Manual writing      | Comprehensive auto   | commit-commands      |
| Context switching       | High (CLI → editor) | Low (stays in Claude)| commit-commands      |
| Granular control        | Full control        | Limited              | Manual Git           |
| Complex operations      | Supported           | Not supported        | Manual Git           |
| Learning curve          | Requires git knowledge | Slash command only | commit-commands      |

**Recommendation:** Use commit-commands for 90% of git operations. Fall back to manual git for complex operations (rebase, cherry-pick, etc.).

---

## Summary

| Command         | Purpose                    | Cost      | Replaces                        |
|-----------------|----------------------------|-----------|---------------------------------|
| /commit         | Create commit              | ✓ Low     | git add + git commit            |
| /commit-push-pr | Commit + push + PR         | ✓ Low     | 5 git/gh commands               |
| /clean_gone     | Clean stale branches       | ✓ Low     | git branch -d + worktree cleanup|

**Key Insight:** commit-commands eliminates git command complexity while maintaining safety through automatic secret detection and learned commit styles.

**Recommended workflow:**
```
Edit → /commit (iterate) → /commit-push-pr → /code-review → Merge
```

---

*Review completed: 2026-01-07*
*Reviewer: Claude Sonnet 4.5*
*Source: CLAUDE_PLUGINS_REFERENCE.md (lines 594-765)*
