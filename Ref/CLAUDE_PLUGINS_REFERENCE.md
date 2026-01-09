# Claude Code Plugins Reference

> **Comprehensive Documentation for Claude Code Plugins** | Updated: 2026-01-06

---

## Table of Contents

| Section | Category                               | Plugins | Line   |
|---------|----------------------------------------|---------|--------|
| 1       | [Overview](#1-overview)                | -       | :35    |
| 2       | [Development Workflows](#2-development-workflows) | 3       | :63    |
| 2.1     | [feature-dev](#21-feature-dev)         | -       | :65    |
| 2.2     | [code-review](#22-code-review)         | -       | :197   |
| 2.3     | [pr-review-toolkit](#23-pr-review-toolkit) | -       | :375   |
| 3       | [Git Operations](#3-git-operations)    | 1       | :549   |
| 3.1     | [commit-commands](#31-commit-commands) | -       | :551   |
| 4       | [Security](#4-security)                | 1       | :723   |
| 4.1     | [security-guidance](#41-security-guidance) | -       | :725   |
| 5       | [Design](#5-design)                    | 1       | :864   |
| 5.1     | [frontend-design](#51-frontend-design) | -       | :866   |
| 6       | [Output Styling](#6-output-styling)    | 3       | :1036  |
| 6.1     | [explanatory-output-style](#61-explanatory-output-style) | -       | :1038  |
| 6.2     | [learning-output-style](#62-learning-output-style) | -       | :1166  |
| 6.3     | [ralph-wiggum](#63-ralph-wiggum)       | -       | :1318  |
| 7       | [Development Tools](#7-development-tools) | 3       | :1550  |
| 7.1     | [agent-sdk-dev](#71-agent-sdk-dev)     | -       | :1552  |
| 7.2     | [plugin-dev](#72-plugin-dev)           | -       | :1765  |
| 7.3     | [hookify](#73-hookify)                 | -       | :1999  |
| 8       | [Examples](#8-examples)                | 1       | :2295  |
| 8.1     | [example-plugin](#81-example-plugin)   | -       | :2297  |
| 9       | [External Plugins](#9-external-plugins) | 18      | :2509  |
| 9.1     | [context7](#91-context7)                 | -       | :2513  |
| 9.2     | [github](#92-github)                   | -       | :2568  |
| 9.3     | [serena](#93-serena)                   | -       | :2628  |
| 9.4     | [supabase](#94-supabase)               | -       | :2684  |
| 9.5     | [atlassian](#95-atlassian)             | -       | :2744  |
| 9.6     | [playwright](#96-playwright)           | -       | :2802  |
| 9.7     | [figma](#97-figma)                     | -       | :2860  |
| 9.8     | [Notion](#98-notion)                   | -       | :2918  |
| 9.9     | [linear](#99-linear)                   | -       | :2976  |
| 9.10    | [laravel-boost](#910-laravel-boost)    | -       | :3035  |
| 9.11    | [greptile](#911-greptile)              | -       | :3093  |
| 9.12    | [sentry](#912-sentry)                  | -       | :3153  |
| 9.13    | [vercel](#913-vercel)                  | -       | :3212  |
| 9.14    | [gitlab](#914-gitlab)                  | -       | :3272  |
| 9.15    | [slack](#915-slack)                    | -       | :3331  |
| 9.16    | [stripe](#916-stripe)                  | -       | :3390  |
| 9.17    | [firebase](#917-firebase)              | -       | :3449  |
| 9.18    | [asana](#918-asana)                    | -       | :3509  |
| 10      | [Language Server Plugins](#10-language-server-plugins-lsp) | 10      | :3587  |
| 10.1    | [typescript-lsp](#101-typescript-lsp)  | -       | :3602  |
| 10.2    | [pyright-lsp](#102-pyright-lsp)        | -       | :3621  |
| 10.3    | [gopls-lsp](#103-gopls-lsp)            | -       | :3640  |
| 10.4    | [rust-analyzer-lsp](#104-rust-analyzer-lsp) | -       | :3659  |
| 10.5    | [csharp-lsp](#105-csharp-lsp)          | -       | :3678  |
| 10.6    | [php-lsp](#106-php-lsp)                | -       | :3699  |
| 10.7    | [jdtls-lsp](#107-jdtls-lsp)            | -       | :3718  |
| 10.8    | [clangd-lsp](#108-clangd-lsp)          | -       | :3739  |
| 10.9    | [swift-lsp](#109-swift-lsp)            | -       | :3758  |
| 10.10   | [lua-lsp](#1010-lua-lsp)               | -       | :3779  |
| 11      | [Complete Plugin Inventory](#11-complete-plugin-inventory) | 41      | :3798  |

---

## 1. Overview

This document provides comprehensive documentation for Claude Code's **31 plugins** (13 internal + 18 external), excluding Language Server plugins.

### Plugin Categories

| Category              | Count | Download | Integration [Usability: Where]     | Invocation                                | Cost      |
|-----------------------|-------|----------|---------------------------------------|-------------------------------------------|-----------|
| Development Workflows | 3     | Manual   | Feature development, before coding    | `/feature-dev`, `/code-review`, Automatic | ⚙️ Medium |
| Git Operations        | 1     | Manual   | After coding, during git workflow     | `/commit`, `/commit-push-pr`, `/clean_gone` | ✓ Low   |
| Security              | 1     | Manual   | Automatic during file edits           | Automatic (PreToolUse hook)               | ✓ Low     |
| Design                | 1     | Manual   | Automatic for frontend work           | Automatic (frontend tasks)                | ✓ Low     |
| Output Styling        | 3     | Manual   | Automatic in all sessions             | Automatic (SessionStart hook)             | ⚠️ High   |
| Development Tools     | 3     | Manual   | Plugin/agent development, as needed   | `/new-sdk-app`, `/hookify`, Automatic     | ✓ Low     |
| Examples              | 1     | Manual   | Learning plugin structure             | `/example-command`, Study structure       | ✓ Low     |

### Installation Scopes

Claude Code offers three installation scopes:

| Scope | Description | Use When | Location |
|-------|-------------|----------|----------|
| **User** | Global to your Mac, works across all projects | Everyday tools (LSPs, `context7`, `github`) | `~/.claude/plugins/` |
| **Project** | Shared with team via git (opt-in for collaborators) | Team-standard tools (`laravel-boost`, `linear`) | Repo `.claude/` (committed) |
| **Local** | You only, this repo only (not shared) | Personal preferences, testing plugins | Repo `.claude/` (gitignored) |

**Installation Strategy:**
- **User Scope**: LSPs for your languages, universal tools (`context7`, `github`)
- **Project Scope**: Framework/team tools (if working with collaborators)
- **Local Scope**: Everything else, testing, personal workflow
- **High-cost plugins** (⚠️ Output Styling): Choose carefully - only one at a time

**Solo Developer Tip:** Use **Local Scope** for flexibility until you find plugins you want everywhere, then switch to User Scope.

### Documentation Notes

- **Focus**: Plugin functionality only (governance integration to be added later)
- **Comparison tables**: Not included initially (to be added later)
- **Use cases**: 3-5 practical scenarios per plugin

---

## 2. Development Workflows

### 2.1 feature-dev

**Purpose**: Systematic 7-phase workflow for building new features with built-in exploration, architecture design, and quality review.

**Maintainer**: Anthropic (Internal)

#### Overview

The feature-dev plugin provides a structured approach to building features that ensures thoughtful design before implementation. Instead of jumping directly into code, it guides you through understanding the codebase, asking clarifying questions, designing architecture with multiple options, and reviewing quality—resulting in better-designed features that integrate seamlessly with existing code.

#### 7-Phase Workflow

| Phase | Purpose                                    | What Happens                                                          |
|-------|--------------------------------------------|-----------------------------------------------------------------------|
| 1     | Discovery                                  | Clarifies requirements, constraints, and success criteria             |
| 2     | Codebase Exploration                       | Launches 2-3 code-explorer agents to understand existing patterns     |
| 3     | Clarifying Questions                       | Identifies ambiguities and waits for your answers                     |
| 4     | Architecture Design                        | Launches 2-3 code-architect agents with different approaches          |
| 5     | Implementation                             | Builds the feature following chosen architecture                      |
| 6     | Quality Review                             | Launches 3 code-reviewer agents checking bugs, simplicity, conventions|
| 7     | Summary                                    | Documents what was built, decisions made, and next steps              |

#### Specialized Agents

**code-explorer**
- **Purpose**: Deeply analyzes existing codebase features by tracing execution paths
- **Outputs**: Entry points, call chains, data flow, architecture insights, essential files
- **When triggered**: Automatically in Phase 2, or manually for code exploration

**code-architect**
- **Purpose**: Designs feature architectures with multiple implementation approaches
- **Outputs**: Pattern analysis, architecture decisions, component design, implementation map
- **When triggered**: Automatically in Phase 4, or manually for architecture design

**code-reviewer**
- **Purpose**: Reviews code for bugs, quality issues, and project conventions
- **Outputs**: Critical/important issues with confidence scores, specific fixes with file:line
- **When triggered**: Automatically in Phase 6, or manually after writing code

#### Use Cases

1. **Building complex features**: New features that touch multiple files and require architectural decisions
   ```
   /feature-dev Add rate limiting to API endpoints with Redis backend
   ```

2. **Integrating new technologies**: Features requiring integration with existing systems
   ```
   /feature-dev Add OAuth authentication alongside existing JWT auth
   ```

3. **Refactoring with structure**: Major refactoring that benefits from exploration and planning
   ```
   /feature-dev Refactor authentication to support multiple providers
   ```

4. **Learning codebase patterns**: Use Phase 2 exploration to understand how similar features work
   ```
   /feature-dev Build caching layer similar to existing session management
   ```

5. **Ensuring quality**: Use Phase 6 review even when skipping earlier phases
   ```
   Launch code-reviewer to check my recent changes
   ```

#### How to Use

**Full workflow (recommended):**
```bash
/feature-dev Add user profile editing with avatar upload
```

**Manual agent invocation:**
```
"Launch code-explorer to trace how authentication works"
"Launch code-architect to design the caching layer"
"Launch code-reviewer to check my recent changes"
```

**Skip phases when appropriate:**
- Simple features: Skip Phase 3 (clarifying questions) if requirements are crystal clear
- Familiar patterns: Skip Phase 2 (exploration) if you know the codebase well
- Urgent fixes: Skip to Phase 5 (implementation) for time-sensitive work

#### Key Features

- **Parallel agent execution**: Multiple agents run simultaneously for faster analysis
- **Context-aware**: Agents read identified files to build deep understanding
- **Interactive**: Waits for your input at key decision points
- **Flexible**: Can invoke individual agents outside the full workflow
- **Quality-focused**: Phase 6 ensures bugs are caught before they reach production

#### Configuration

No configuration needed. The plugin works out of the box with intelligent defaults:
- Automatically determines number of agents to launch (2-3 per phase)
- Adapts exploration depth based on codebase size
- Confidence threshold for code review issues: ≥80

#### Tips & Best Practices

1. **Be specific in feature requests**: "Add OAuth with Google and GitHub providers" better than "Add OAuth"
2. **Answer Phase 3 questions thoughtfully**: These prevent confusion later
3. **Read suggested files**: Phase 2 identifies key files—read them for context
4. **Choose architecture deliberately**: Phase 4 gives options for a reason—consider trade-offs
5. **Don't skip code review**: Phase 6 catches issues before production
6. **Trust the process**: Each phase builds on previous ones—skipping phases risks quality

**When to use:**
- New features touching multiple files
- Features requiring architectural decisions
- Complex integrations with existing code
- Features where requirements are somewhat unclear

**When NOT to use:**
- Single-line bug fixes
- Trivial changes
- Well-defined, simple tasks
- Urgent hotfixes (but consider Phase 6 review after fixing)

#### Requirements

- Claude Code installed
- Git repository (for code review features)
- Project with existing codebase (workflow learns from existing patterns)

**Author**: Sid Bidasaria (sbidasaria@anthropic.com)
**Version**: 1.0.0

---

### 2.2 code-review

**Purpose**: Automated pull request code review using multiple specialized agents with confidence-based scoring to filter false positives.

**Maintainer**: Anthropic (Internal)

#### Overview

The code-review plugin automates PR review by launching 4 independent agents in parallel to audit changes from different perspectives. It uses confidence scoring (threshold: 80) to filter out false positives, ensuring only high-quality, actionable feedback is posted to the pull request.

#### Workflow

| Step | Action                                             | Details                                                              |
|------|---------------------------------------------------|----------------------------------------------------------------------|
| 1    | Check if review needed                             | Skips closed, draft, trivial, or already-reviewed PRs                |
| 2    | Gather guidelines                                  | Reads relevant CLAUDE.md files from repository                       |
| 3    | Summarize PR changes                               | Analyzes git diff and commit messages                                |
| 4    | Launch 4 parallel agents                           | Independent audits from different perspectives                       |
| 5    | Score each issue 0-100                             | Confidence-based scoring for every finding                           |
| 6    | Filter issues <80 confidence                       | Removes false positives                                              |
| 7    | Post review comment                                | GitHub comment with high-confidence issues only                      |

#### Review Agents (4 Total)

| Agent   | Focus                             | Purpose                                                    |
|---------|-----------------------------------|-----------------------------------------------------------|
| Agent 1 | CLAUDE.md compliance              | Verifies changes follow project guidelines                 |
| Agent 2 | CLAUDE.md compliance (redundant)  | Second opinion on guideline compliance                     |
| Agent 3 | Obvious bugs                      | Scans for bugs in changes (not pre-existing issues)        |
| Agent 4 | Historical context                | Analyzes git blame/history for context-based issues        |

#### Confidence Scoring System

| Score | Meaning                                    | Action                              |
|-------|-------------------------------------------|-------------------------------------|
| 0-24  | Not confident, false positive              | Filtered out                        |
| 25-49 | Somewhat confident, might be real          | Filtered out                        |
| 50-74 | Moderately confident, real but minor       | Filtered out                        |
| 75-79 | Highly confident, real and important       | Filtered out (just below threshold) |
| 80-100| Very confident, definitely real            | ✓ Included in review                |

#### Use Cases

1. **Automated PR review**: Run on all non-trivial pull requests
   ```bash
   # On a PR branch:
   /code-review
   ```

2. **CLAUDE.md compliance checking**: Ensures team guidelines are followed
   ```
   # Reviews against all CLAUDE.md files in repo
   /code-review
   ```

3. **Bug detection in changes**: Catches obvious bugs before merge
   ```
   # Focuses on changes, not pre-existing code
   /code-review
   ```

4. **Historical context analysis**: Uses git blame for context
   ```
   # Agents check who wrote related code and when
   /code-review
   ```

5. **CI/CD integration**: Automate as part of PR workflow
   ```bash
   # Trigger on PR creation/update
   # Skips if review already exists
   /code-review
   ```

#### How to Use

**Basic usage:**
```bash
/code-review
```

**Typical workflow:**
```bash
# 1. Create PR with changes
git push origin feature-branch

# 2. Run automated review
/code-review

# 3. Review feedback
# Check GitHub PR for posted comment

# 4. Make fixes
# Address high-confidence issues

# 5. Merge when ready
```

#### Key Features

- **Multiple independent agents**: 4 agents provide comprehensive coverage
- **Confidence-based filtering**: 80+ threshold reduces noise
- **CLAUDE.md aware**: Explicitly verifies guideline compliance
- **Change-focused**: Only reviews new code, not pre-existing issues
- **Historical context**: Git blame analysis for better understanding
- **Automatic skipping**: Closed/draft/trivial/reviewed PRs skipped
- **Direct code links**: GitHub permalinks with full SHA and line ranges

#### Review Comment Format

```markdown
## Code review

Found 3 issues:

1. Missing error handling for OAuth callback (CLAUDE.md says "Always handle OAuth errors")

https://github.com/owner/repo/blob/abc123.../src/auth.ts#L67-L72

2. Memory leak: OAuth state not cleaned up (bug due to missing cleanup in finally block)

https://github.com/owner/repo/blob/abc123.../src/auth.ts#L88-L95

3. Inconsistent naming pattern (src/conventions/CLAUDE.md says "Use camelCase for functions")

https://github.com/owner/repo/blob/abc123.../src/utils.ts#L23-L28
```

#### Configuration

**Adjusting confidence threshold:**

Default threshold is 80. To adjust, modify `commands/code-review.md`:
```markdown
Filter out any issues with a score less than 80.
```

Change `80` to your preferred threshold (0-100).

**Customizing review focus:**

Edit `commands/code-review.md` to add or modify agent tasks:
- Add security-focused agents
- Add performance analysis agents
- Add accessibility checking agents

#### Tips & Best Practices

1. **Maintain clear CLAUDE.md files**: Better guidelines = better compliance checking
2. **Trust the 80+ threshold**: False positives are already filtered
3. **Run on all non-trivial PRs**: Catches issues early
4. **Review as starting point**: Use automated findings to guide human review
5. **Update CLAUDE.md**: Learn from recurring patterns
6. **Include context in PRs**: Helps agents understand intent

**When to use:**
- All PRs with meaningful changes
- PRs touching critical code paths
- PRs from multiple contributors
- PRs where guideline compliance matters

**When NOT to use:**
- Closed or draft PRs (automatically skipped)
- Trivial automated PRs (automatically skipped)
- Urgent hotfixes requiring immediate merge
- PRs already reviewed (automatically skipped)

#### Requirements

- Git repository with GitHub integration
- GitHub CLI (`gh`) installed and authenticated
- CLAUDE.md files (optional but recommended)

**Author**: Boris Cherny (boris@anthropic.com)
**Version**: 1.0.0

---

### 2.3 pr-review-toolkit

**Purpose**: Comprehensive collection of 6 specialized review agents covering code comments, test coverage, error handling, type design, code quality, and code simplification.

**Maintainer**: Anthropic (Internal)

#### Overview

The pr-review-toolkit bundles 6 expert review agents that each focus on a specific aspect of code quality. Use them individually for targeted reviews or together for comprehensive PR analysis. Unlike code-review which automates full PR workflow, these agents provide deep, specialized analysis on demand.

#### 6 Specialized Agents

**1. comment-analyzer**
- **Focus**: Code comment accuracy and maintainability
- **Analyzes**: Comment accuracy vs code, documentation completeness, comment rot, misleading comments
- **Use when**: After adding documentation, before finalizing PRs with comments
- **Triggers**: "Check if the comments are accurate", "Review the documentation I added"

**2. pr-test-analyzer**
- **Focus**: Test coverage quality and completeness
- **Analyzes**: Behavioral vs line coverage, critical gaps, test quality, edge cases
- **Use when**: After creating PR, when adding new functionality
- **Triggers**: "Check if the tests are thorough", "Review test coverage for this PR"

**3. silent-failure-hunter**
- **Focus**: Error handling and silent failures
- **Analyzes**: Silent failures in catch blocks, inadequate error handling, missing logging
- **Use when**: After implementing error handling, reviewing try/catch blocks
- **Triggers**: "Review the error handling", "Check for silent failures"

**4. type-design-analyzer**
- **Focus**: Type design quality and invariants
- **Analyzes**: Type encapsulation (1-10), invariant expression (1-10), type usefulness (1-10)
- **Use when**: Introducing new types, refactoring type designs
- **Triggers**: "Review the UserAccount type design", "Check if this type has strong invariants"

**5. code-reviewer**
- **Focus**: General code review for project guidelines
- **Analyzes**: CLAUDE.md compliance, style violations, bugs, code quality
- **Use when**: After writing/modifying code, before committing
- **Triggers**: "Review my recent changes", "Check if everything looks good"

**6. code-simplifier**
- **Focus**: Code simplification and refactoring
- **Analyzes**: Clarity, unnecessary complexity, redundant code, consistency, overly clever code
- **Use when**: After writing code, when code works but feels complex
- **Triggers**: "Simplify this code", "Make this clearer", "Refine this implementation"

#### Agent Comparison

| Agent                  | When to Use                      | Output                                    | Confidence System     |
|------------------------|----------------------------------|-------------------------------------------|-----------------------|
| comment-analyzer       | After adding docs                | Issue identification with high confidence | High/Low confidence   |
| pr-test-analyzer       | Before creating PR               | Test gaps rated 1-10 (10 = critical)      | 1-10 severity scale   |
| silent-failure-hunter  | After error handling             | Severity-based findings                   | Critical/High/Medium  |
| type-design-analyzer   | When adding new types            | 4 dimensions rated 1-10                   | 1-10 quality scores   |
| code-reviewer          | Before committing                | Issues scored 0-100 (91-100 = critical)   | 0-100 confidence      |
| code-simplifier        | After passing review             | Complexity identification + suggestions   | Qualitative           |

#### Use Cases

1. **Comprehensive PR review**: Run multiple agents before creating PR
   ```
   "I'm ready to create this PR. Please:
   1. Review test coverage
   2. Check for silent failures
   3. Verify code comments are accurate
   4. Review any new types
   5. General code review"
   ```

2. **Targeted review**: Focus on specific concern
   ```
   "Can you check if the tests cover all edge cases?"
   → Triggers pr-test-analyzer
   ```

3. **Documentation validation**: After adding comments
   ```
   "I've added documentation - is it accurate?"
   → Triggers comment-analyzer
   ```

4. **Error handling audit**: After implementing error handling
   ```
   "Review the error handling in the API client"
   → Triggers silent-failure-hunter
   ```

5. **Type system design**: When introducing new data models
   ```
   "Review the UserAccount type design"
   → Triggers type-design-analyzer
   ```

#### How to Use

**Individual agent (automatic):**
```
Ask questions matching agent focus area:
- "Check if tests cover edge cases" → pr-test-analyzer
- "Review error handling" → silent-failure-hunter
- "Is documentation accurate?" → comment-analyzer
```

**Multiple agents in parallel:**
```
"Run pr-test-analyzer and comment-analyzer in parallel"
```

**Sequential execution:**
```
"First review test coverage, then check code quality"
```

**Proactive usage:**
Claude may automatically trigger agents based on context:
- After writing code → code-reviewer
- After adding docs → comment-analyzer
- Before creating PR → Multiple agents
- After adding types → type-design-analyzer

#### Key Features

- **Specialized expertise**: Each agent focuses on one quality dimension
- **Confidence scoring**: All agents provide confidence/severity scores
- **Structured output**: Clear issue identification with file:line references
- **Prioritized findings**: Issues sorted by severity/importance
- **Actionable suggestions**: Not just problems, but solutions
- **On-demand**: Run individually or in combination as needed

#### Recommended Workflow

| Phase                | Agents to Run                               | Purpose                        |
|----------------------|---------------------------------------------|--------------------------------|
| Before Committing    | code-reviewer, silent-failure-hunter        | General quality + error safety |
| Before Creating PR   | pr-test-analyzer, comment-analyzer, type-design-analyzer | Coverage + docs + types        |
| After Passing Review | code-simplifier                             | Polish and maintainability     |
| During PR Review     | Any agent for specific concerns             | Address reviewer feedback      |

#### Configuration

No configuration needed. Each agent has built-in defaults optimized for their focus area.

#### Tips & Best Practices

1. **Be specific**: Target specific agents for focused review
2. **Use proactively**: Run before creating PRs, not after
3. **Address critical first**: Agents prioritize findings by severity
4. **Iterate**: Run again after fixes to verify resolution
5. **Don't over-use**: Focus on changed code, not entire codebase
6. **Combine with workflow**: Works great with build-validator and project agents

**When to use:**
- Before committing significant changes
- Before creating pull requests
- After implementing specific features (error handling, types, tests)
- When code works but could be improved

**When NOT to use:**
- Trivial changes (typo fixes)
- Non-code files
- Entire codebase reviews (too broad)

#### Requirements

- Claude Code installed
- Git repository (for change detection)

**Author**: Daisy (daisy@anthropic.com)
**Version**: 1.0.0

---

## 3. Git Operations

### 3.1 commit-commands

**Purpose**: Streamline git workflow with simple commands for committing, pushing, and creating pull requests.

**Maintainer**: Anthropic (Internal)

#### Overview

The commit-commands plugin automates common git operations, reducing context switching and manual command execution. Instead of running multiple git commands, use a single slash command to handle your entire workflow—from committing changes to creating pull requests.

#### Commands

**`/commit`**
- **Purpose**: Create git commit with auto-generated message
- **Workflow**: Analyzes git status → Reviews changes → Examines recent commits → Stages files → Creates commit
- **Features**: Matches repo commit style, follows conventional commits, avoids committing secrets

**`/commit-push-pr`**
- **Purpose**: Complete workflow (commit + push + create PR)
- **Workflow**: Creates branch if needed → Commits → Pushes → Creates PR → Provides URL
- **Features**: Comprehensive PR descriptions, test plan checklist, uses GitHub CLI

**`/clean_gone`**
- **Purpose**: Clean up local branches deleted from remote
- **Workflow**: Lists [gone] branches → Removes worktrees → Deletes branches → Reports cleanup
- **Features**: Handles worktrees safely, clear feedback

#### Use Cases

1. **Quick commit during development**:
   ```bash
   # Make changes
   /commit
   # Claude stages files and creates commit with appropriate message
   ```

2. **Feature branch workflow**:
   ```bash
   # Develop feature with multiple commits
   /commit  # First commit
   # More changes
   /commit  # Second commit
   # Ready for PR
   /commit-push-pr  # Creates PR with comprehensive description
   ```

3. **Repository maintenance**:
   ```bash
   # After merging several PRs
   /clean_gone
   # Removes all stale local branches
   ```

4. **Learning commit style**:
   ```bash
   # Let Claude learn from your repo
   /commit
   # Analyzes recent commit messages to match style
   ```

5. **Avoiding manual git commands**:
   ```bash
   # Instead of:
   # git add .
   # git commit -m "message"
   # git push origin branch
   # gh pr create --title "..." --body "..."

   # Just run:
   /commit-push-pr
   ```

#### How to Use

**Quick commit:**
```bash
/commit
```

**Full workflow (commit + push + PR):**
```bash
/commit-push-pr
```

**Cleanup stale branches:**
```bash
/clean_gone
```

**Typical workflow:**
```bash
# 1. Make changes
# edit files...

# 2. Commit
/commit

# 3. Continue development
# more changes...

# 4. Final commit
/commit

# 5. Create PR when ready
/commit-push-pr
# → Claude creates branch, commits, pushes, opens PR
```

#### Key Features

- **Auto-generated messages**: Learns from your repo's commit style
- **Conventional commits**: Follows best practices automatically
- **Secret detection**: Won't commit .env, credentials.json, etc.
- **Branch management**: Creates feature branches automatically
- **PR descriptions**: Comprehensive summaries with test plans
- **Claude Code attribution**: Adds attribution in commit messages
- **Worktree safety**: clean_gone handles worktrees before deleting branches

#### Configuration

No configuration needed. The plugin automatically:
- Detects your repo's commit message style
- Follows conventional commit format when appropriate
- Uses GitHub CLI (gh) if available
- Handles branch naming intelligently

#### Tips & Best Practices

1. **Let Claude draft messages**: Trust the analysis—it learns from your repo
2. **Review before pushing**: /commit creates local commits—review before /commit-push-pr
3. **Use /commit frequently**: Small, focused commits during development
4. **Save /commit-push-pr for PR time**: Use when feature is complete
5. **Regular cleanup**: Run /clean_gone weekly to maintain tidy branch list
6. **Combine with code-review**: /commit-push-pr then /code-review

**When to use:**
- Routine commits during development
- Creating pull requests quickly
- Cleaning up after merging multiple PRs
- When you want to minimize context switching

**When NOT to use:**
- When commit message needs very specific wording
- When you need granular control over what's staged
- For complex rebase/merge operations

#### Requirements

- Git installed and configured
- For /commit-push-pr: GitHub CLI (gh) installed and authenticated
- Repository with a remote (for push operations)

#### Troubleshooting

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

**Author**: Anthropic (support@anthropic.com)
**Version**: 1.0.0

---

## 4. Security

### 4.1 security-guidance

**Purpose**: Security reminder hook that warns about potential security issues when editing files.

**Maintainer**: Anthropic (Internal)

#### Overview

The security-guidance plugin provides automatic security reminders using a PreToolUse hook. When you edit or write files, the hook analyzes the operation and provides relevant security guidance to help prevent common security vulnerabilities.

#### How It Works

Uses a **PreToolUse hook** that:
1. Intercepts Edit, Write, and MultiEdit tool calls
2. Analyzes file paths and content for security concerns
3. Provides warnings about potential security issues
4. Allows operation to proceed after showing guidance

Hook configuration:
```json
{
  "description": "Security reminder hook for file edits",
  "hooks": {
    "PreToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 ${CLAUDE_PLUGIN_ROOT}/hooks/security_reminder_hook.py"
          }
        ],
        "matcher": "Edit|Write|MultiEdit"
      }
    ]
  }
}
```

#### Use Cases

1. **Prevent credential leaks**: Warns when editing sensitive files
   ```
   Editing .env file
   → Warning about not committing sensitive data
   ```

2. **SQL injection prevention**: Reminds about parameterized queries
   ```
   Writing database query code
   → Guidance on SQL injection prevention
   ```

3. **XSS protection**: Warns about user input handling
   ```
   Editing frontend code with user input
   → Reminder about XSS vulnerabilities
   ```

4. **Authentication best practices**: Security guidance for auth code
   ```
   Modifying authentication logic
   → Warnings about common auth vulnerabilities
   ```

5. **File permission reminders**: Warns about overly permissive files
   ```
   Creating configuration files
   → Guidance on appropriate file permissions
   ```

#### How to Use

**Automatic activation:**
No commands needed. The plugin activates automatically when you edit or write files.

**Typical workflow:**
```
1. Claude attempts to edit a file
2. Hook intercepts the operation
3. Security guidance displayed (if relevant)
4. Operation proceeds
```

#### Key Features

- **Automatic activation**: No manual intervention required
- **Context-aware**: Provides relevant guidance based on file type and content
- **Non-blocking**: Shows warnings but doesn't prevent operations
- **Educational**: Helps build security awareness over time
- **OWASP focused**: Covers top security vulnerabilities

#### Security Topics Covered

- Credential management
- SQL injection prevention
- Cross-Site Scripting (XSS)
- Cross-Site Request Forgery (CSRF)
- Authentication and authorization
- File permissions
- Input validation
- Output encoding
- Secure communication (HTTPS)
- Dependency vulnerabilities

#### Configuration

No configuration options. The plugin works automatically with built-in security guidance.

#### Tips & Best Practices

1. **Read the warnings**: Security guidance is educational—take time to understand
2. **Apply preventatively**: Use guidance to avoid vulnerabilities before they occur
3. **Combine with code-review**: Use together for comprehensive security coverage
4. **Update dependencies**: Keep libraries current to avoid known vulnerabilities
5. **Follow OWASP guidelines**: Learn more at https://owasp.org/

**When to use:**
- Automatically active for all file edits
- Especially valuable when working with:
  - Authentication/authorization code
  - Database queries
  - User input handling
  - Configuration files
  - Sensitive data

**When NOT to use:**
- Cannot be disabled (always active)
- If you need to disable, uninstall the plugin

#### Requirements

- Python 3
- No external dependencies

**Author**: Anthropic
**Version**: 1.0.0

---

## 5. Design

### 5.1 frontend-design

**Purpose**: Generates distinctive, production-grade frontend interfaces that avoid generic AI aesthetics.

**Maintainer**: Anthropic (Internal)

#### Overview

The frontend-design plugin automatically enhances Claude's frontend design capabilities. When working on frontend tasks, Claude chooses bold aesthetic directions and implements production-ready code with meticulous attention to typography, colors, animations, and visual details—avoiding the generic look common in AI-generated interfaces.

#### How It Works

Claude automatically uses this skill for frontend work. The plugin encourages:
- **Bold aesthetic choices**: Distinctive design directions
- **Distinctive typography**: Carefully selected fonts and type scales
- **Unique color palettes**: Memorable, cohesive color schemes
- **High-impact animations**: Purposeful, polished animations
- **Context-aware implementation**: Designs that match the domain

#### Use Cases

1. **Dashboard design**: Rich, data-dense interfaces
   ```
   "Create a dashboard for a music streaming app"
   → Bold color scheme with album art-inspired aesthetics
   → Smooth animations for playback controls
   → Typography reflecting music industry style
   ```

2. **Landing pages**: High-impact marketing sites
   ```
   "Build a landing page for an AI security startup"
   → Professional, technical aesthetic
   → Animations that convey security and reliability
   → Color palette suggesting trust and innovation
   ```

3. **Application UI**: Polished user interfaces
   ```
   "Design a settings panel with dark mode"
   → Careful attention to dark mode colors
   → Smooth transitions between light/dark
   → Typography optimized for readability
   ```

4. **Component libraries**: Distinctive, reusable components
   ```
   "Create a button component library"
   → Unique button styles
   → Multiple variants with consistent aesthetics
   → Accessibility and interaction states
   ```

5. **E-commerce interfaces**: Engaging shopping experiences
   ```
   "Build a product catalog page"
   → Product-focused layout
   → Smooth filtering animations
   → Typography highlighting product details
   ```

#### How to Use

**Automatic activation:**
Simply request frontend work:
```
"Create a dashboard for analytics"
"Build a landing page for a SaaS product"
"Design a settings panel"
```

Claude automatically applies distinctive design principles.

**No explicit invocation needed**—the plugin enhances all frontend work.

#### Key Features

- **Automatic enhancement**: No commands needed
- **Context-aware aesthetics**: Design matches domain and purpose
- **Production-ready code**: Not just mockups—full implementation
- **Distinctive choices**: Avoids generic AI aesthetics
- **Attention to detail**: Typography, colors, spacing, animations all considered
- **Accessibility**: Follows best practices for usability

#### Design Principles

**Typography:**
- Carefully selected font pairings
- Appropriate type scales for hierarchy
- Readability across devices

**Colors:**
- Memorable, cohesive palettes
- Context-appropriate choices
- Proper contrast ratios

**Animations:**
- Purposeful, not gratuitous
- Smooth and polished
- Performance-optimized

**Layout:**
- Responsive and adaptive
- Visual hierarchy
- White space utilization

#### Configuration

No configuration options. The plugin enhances all frontend work automatically.

#### Tips & Best Practices

1. **Provide context**: More detail → more tailored design
   ```
   Good: "Create a dashboard for a music streaming app targeting Gen Z"
   Better than: "Create a dashboard"
   ```

2. **Specify aesthetic preferences**: Guide the design direction
   ```
   "Build a landing page with a minimal, Swiss design aesthetic"
   "Create a dashboard with a cyberpunk-inspired color scheme"
   ```

3. **Request specific details**: Get targeted improvements
   ```
   "Make the animations more subtle"
   "Use a more distinctive color palette"
   "Improve the typography hierarchy"
   ```

4. **Iterate on designs**: Refine based on preferences
   ```
   "Make it more professional"
   "Add more visual interest"
   "Simplify the design"
   ```

5. **Reference examples**: Provide inspiration
   ```
   "Create a design similar to Stripe's landing page but with warmer colors"
   ```

**When to use:**
- Always active for frontend work
- Especially valuable for:
  - Landing pages requiring high visual impact
  - Dashboards needing data visualization
  - Marketing sites requiring brand personality
  - Applications needing polished UI

**When NOT to use:**
- Backend development (plugin doesn't activate)
- Quick prototypes where aesthetics don't matter
- When you want basic, generic designs

#### Requirements

- Claude Code installed
- No additional dependencies

#### Learn More

See the [Frontend Aesthetics Cookbook](https://github.com/anthropics/claude-cookbooks/blob/main/coding/prompting_for_frontend_aesthetics.ipynb) for detailed guidance on prompting for high-quality frontend design.

**Authors**: Prithvi Rajasekaran (prithvi@anthropic.com), Alexander Bricken (alexander@anthropic.com)
**Version**: 1.0.0

---

## 6. Output Styling

### 6.1 explanatory-output-style

**Purpose**: Adds educational insights about implementation choices to Claude's output using SessionStart hooks.

**Maintainer**: Anthropic (Internal)

#### Overview

This plugin recreates the deprecated "Explanatory" output style as a SessionStart hook. When enabled, Claude provides brief educational explanations before and after writing code, focusing on codebase-specific patterns and decisions rather than general programming concepts.

**WARNING**: This plugin increases token usage due to additional instructions and output. Only install if you're comfortable with the cost.

#### How It Works

Uses SessionStart hook to inject instructions that encourage Claude to:
1. Provide educational insights about implementation choices
2. Explain codebase patterns and decisions
3. Balance task completion with learning opportunities

Insights are formatted as:
```
`★ Insight ─────────────────────────────────────`
[2-3 key educational points]
`─────────────────────────────────────────────────`
```

#### Use Cases

1. **Learning a new codebase**: Understand patterns as you work
   ```
   "Add caching to the API"
   → Claude explains existing caching patterns before implementing
   ```

2. **Understanding design decisions**: Learn why code is structured a certain way
   ```
   "Refactor the authentication"
   → Claude explains current auth approach and tradeoffs
   ```

3. **Onboarding new team members**: Educational context for every change
   ```
   Any development task
   → Automatic insights about project conventions
   ```

4. **Building institutional knowledge**: Learn project-specific details
   ```
   Regular development work
   → Continuous learning about your codebase
   ```

5. **Debugging with context**: Understand why bugs might exist
   ```
   "Fix the session timeout bug"
   → Insights about session management approach
   ```

#### How to Use

**Installation:**
```bash
# Install from marketplace
/plugins
# Find "explanatory-output-style"
# Install
```

**Activation:**
Once installed, the plugin activates automatically at the start of every session. No additional commands needed.

**Insights focus on:**
- Specific implementation choices for your codebase
- Patterns and conventions in your code
- Trade-offs and design decisions
- Codebase-specific details (not generic programming advice)

#### Key Features

- **Automatic activation**: Works from session start
- **Codebase-specific**: Tailored to your project, not generic
- **Formatted insights**: Clear visual separation with stars
- **Balanced approach**: Doesn't slow down task completion
- **No commands required**: Just install and work normally

#### Configuration

No configuration options. The plugin works with default settings optimized for educational output.

**Disabling temporarily:**
- Use `/stop` and restart without the plugin
- Or uninstall the plugin

#### Tips & Best Practices

1. **Read the insights**: They provide valuable context about your codebase
2. **Use for learning**: Especially valuable when working with unfamiliar code
3. **Consider token costs**: This increases output length—monitor API usage
4. **Combine with learning-output-style**: For even more interactive learning
5. **Team onboarding**: Great for new developers learning the codebase

**When to use:**
- Learning a new codebase
- Onboarding team members
- Understanding complex architectural decisions
- Building documentation from insights

**When NOT to use:**
- Tight token budgets
- Urgent tasks where speed matters
- Simple, well-understood tasks

#### Migration from Output Styles

Replaces deprecated setting:
```json
{
  "outputStyle": "Explanatory"
}
```

Now use this plugin instead.

**Author**: Anthropic
**Version**: 1.0.0

---

### 6.2 learning-output-style

**Purpose**: Interactive learning mode that requests meaningful code contributions from you at key decision points, combined with explanatory insights.

**Maintainer**: Anthropic (Internal)

#### Overview

This plugin combines the unshipped "Learning" output style with the explanatory-output-style plugin. Instead of Claude implementing everything automatically, it engages you in active learning by requesting you write 5-10 lines of meaningful code at decision points—focusing on business logic and design choices where your input truly matters.

**WARNING**: This plugin increases token usage and requires interactive participation. Only install if you want hands-on learning and are comfortable with the cost.

#### How It Works

Uses SessionStart hook to inject instructions that encourage Claude to:
1. Identify opportunities for you to write 5-10 lines of meaningful code
2. Focus on business logic and design choices (not boilerplate)
3. Prepare context and explain trade-offs
4. Provide educational insights throughout

#### Learning Approach

**Claude WILL request contributions for:**
- Business logic with multiple valid approaches
- Error handling strategies
- Algorithm implementation choices
- Data structure decisions
- User experience decisions
- Design patterns and architecture choices

**Claude will NOT request contributions for:**
- Boilerplate or repetitive code
- Obvious implementations with no meaningful choices
- Configuration or setup code
- Simple CRUD operations

#### Use Cases

1. **Learning by doing**: Actively participate in implementation
   ```
   "Add authentication middleware"
   → Claude sets up structure, asks you to implement timeout logic
   ```

2. **Understanding trade-offs**: Make informed decisions
   ```
   "Add caching"
   → Claude explains approaches, asks you to choose and implement
   ```

3. **Building practical skills**: Write meaningful code, not just read
   ```
   "Implement search feature"
   → You write the actual search algorithm with guidance
   ```

4. **Onboarding with hands-on practice**: Learn by building
   ```
   Any feature development
   → Regular opportunities to contribute key logic
   ```

5. **Code review as learning**: Understand decisions firsthand
   ```
   "Refactor error handling"
   → You implement the new error handling approach
   ```

#### How to Use

**Installation:**
```bash
# Install from marketplace
/plugins
# Find "learning-output-style"
# Install
```

**Activation:**
Once installed, the plugin activates automatically. No additional commands needed.

**Example interaction:**
```
User: "Add session timeout handling"

Claude: I've set up the authentication middleware. The session timeout
behavior is a security vs. UX trade-off:

Option 1: Auto-extend on activity (better UX, longer exposure)
Option 2: Hard timeout (more secure, might frustrate users)

In `auth/middleware.ts`, implement the `handleSessionTimeout()` function
to define the timeout behavior. Consider the trade-offs above.

User: [Writes 5-10 lines implementing chosen approach]

Claude: Great choice! That balances security and UX well.
`★ Insight ─────────────────────────────────────`
Your implementation uses sliding window timeouts, which is common in
applications prioritizing user experience while maintaining reasonable
security posture.
`─────────────────────────────────────────────────`
```

#### Key Features

- **Interactive learning**: Active participation, not passive observation
- **Meaningful contributions**: 5-10 line segments focusing on logic, not boilerplate
- **Trade-off explanations**: Understand why decisions matter
- **Educational insights**: Combined with explanatory-output-style
- **Context preparation**: Claude sets up structure before asking for code
- **Automatic activation**: Works from session start

#### Configuration

No configuration options. The plugin works with default settings optimized for interactive learning.

#### Tips & Best Practices

1. **Embrace the process**: Learning by doing is more effective than watching
2. **Ask questions**: If trade-offs unclear, ask Claude to explain more
3. **Take your time**: Think through decisions—speed isn't the goal
4. **Review Claude's setup**: Understand context before writing
5. **Iterate**: If your code has issues, Claude will help refine

**When to use:**
- Learning a new language or framework
- Understanding architectural patterns
- Building practical coding skills
- Onboarding with hands-on experience

**When NOT to use:**
- Production work with tight deadlines
- Simple, well-understood tasks
- When you just want answers quickly
- Tight token budgets

#### Philosophy

**"Learning by doing is more effective than passive observation."**

This plugin transforms your interaction from "watch and learn" to "build and understand," ensuring you develop practical skills through hands-on coding of meaningful logic.

#### Migration from Output Styles

Combines unshipped "Learning" output style with explanatory functionality. Provides both interactive learning and educational insights.

**Author**: Anthropic
**Version**: 1.0.0

---

### 6.3 ralph-wiggum

**Purpose**: Implements the Ralph Wiggum technique for iterative, self-referential AI development loops using a Stop hook.

**Maintainer**: Anthropic (Internal)

#### Overview

Ralph is a development methodology based on continuous AI agent loops. The plugin implements Ralph using a Stop hook that intercepts Claude's exit attempts, creating a self-referential feedback loop where Claude iteratively improves its work until completion—all within a single session.

**Core Concept**: "Ralph is a Bash loop" - but implemented as an internal Stop hook that automatically feeds the same prompt back to Claude after each iteration, allowing autonomous improvement until a completion promise is detected or max iterations reached.

#### How It Works

```bash
# You run ONCE:
/ralph-loop "Your task description" --completion-promise "DONE" --max-iterations 50

# Then Claude Code automatically:
# 1. Works on the task
# 2. Tries to exit
# 3. Stop hook blocks exit
# 4. Stop hook feeds the SAME prompt back
# 5. Repeat until completion promise or max iterations
```

This creates a **self-referential feedback loop** where:
- The prompt never changes between iterations
- Claude's previous work persists in files
- Each iteration sees modified files and git history
- Claude autonomously improves by reading its own past work

#### Commands

**`/ralph-loop`**
- **Purpose**: Start a Ralph loop in current session
- **Syntax**: `/ralph-loop "<prompt>" --max-iterations <n> --completion-promise "<text>"`
- **Options**:
  - `--max-iterations <n>`: Stop after N iterations (default: unlimited)
  - `--completion-promise "<text>"`: Phrase that signals completion

**`/cancel-ralph`**
- **Purpose**: Cancel the active Ralph loop
- **Syntax**: `/cancel-ralph`

#### Use Cases

1. **Test-driven development**: Iterate until all tests pass
   ```bash
   /ralph-loop "Build REST API for todos. Requirements: CRUD, validation, tests.
   Output <promise>COMPLETE</promise> when all tests pass."
   --completion-promise "COMPLETE" --max-iterations 50
   ```

2. **Bug fixing with verification**: Keep fixing until error disappears
   ```bash
   /ralph-loop "Fix the authentication bug. Run tests after each fix.
   Output <promise>TESTS PASS</promise> when bug is resolved."
   --completion-promise "TESTS PASS" --max-iterations 20
   ```

3. **Incremental feature building**: Build complex features phase by phase
   ```bash
   /ralph-loop "Phase 1: User auth (JWT, tests). Phase 2: Product catalog (list/search, tests).
   Phase 3: Shopping cart (add/remove, tests). Output <promise>ALL PHASES DONE</promise>."
   --completion-promise "ALL PHASES DONE" --max-iterations 100
   ```

4. **Self-correcting implementation**: Let Claude debug and fix autonomously
   ```bash
   /ralph-loop "Implement feature X following TDD: 1. Write failing tests 2. Implement
   3. Run tests 4. If any fail, debug and fix 5. Refactor if needed 6. Repeat until all green
   7. Output: <promise>COMPLETE</promise>"
   --max-iterations 30
   ```

5. **Greenfield projects**: Walk away and come back to completed work
   ```bash
   /ralph-loop "Create a CLI tool for managing tasks with: add, list, complete, delete commands.
   Include tests and README. Output <promise>PROJECT COMPLETE</promise>."
   --completion-promise "PROJECT COMPLETE" --max-iterations 50
   ```

#### How to Use

**Basic syntax:**
```bash
/ralph-loop "<prompt>" --max-iterations <n> --completion-promise "<text>"
```

**Example:**
```bash
/ralph-loop "Build a REST API for todos. Requirements: CRUD operations, input validation, tests.
Output <promise>COMPLETE</promise> when done."
--completion-promise "COMPLETE" --max-iterations 50
```

**To cancel:**
```bash
/cancel-ralph
```

#### Prompt Writing Best Practices

**1. Clear Completion Criteria:**

❌ Bad:
```
"Build a todo API and make it good."
```

✅ Good:
```markdown
Build a REST API for todos.

When complete:
- All CRUD endpoints working
- Input validation in place
- Tests passing (coverage > 80%)
- README with API docs
- Output: <promise>COMPLETE</promise>
```

**2. Incremental Goals:**

❌ Bad:
```
"Create a complete e-commerce platform."
```

✅ Good:
```markdown
Phase 1: User authentication (JWT, tests)
Phase 2: Product catalog (list/search, tests)
Phase 3: Shopping cart (add/remove, tests)

Output <promise>COMPLETE</promise> when all phases done.
```

**3. Self-Correction Instructions:**

✅ Good:
```markdown
Implement feature X following TDD:
1. Write failing tests
2. Implement feature
3. Run tests
4. If any fail, debug and fix
5. Refactor if needed
6. Repeat until all green
7. Output: <promise>COMPLETE</promise>
```

**4. Safety: Always Use --max-iterations:**

```bash
# ALWAYS set iteration limit to prevent infinite loops
/ralph-loop "Task description" --max-iterations 20

# In prompt, include what to do if stuck:
# "After 15 iterations, if not complete:
#  - Document what's blocking progress
#  - List what was attempted
#  - Suggest alternative approaches"
```

#### Key Features

- **Self-referential loop**: Same prompt every iteration
- **Persistent state**: Work saved in files between iterations
- **Autonomous improvement**: Claude debugs and fixes itself
- **Completion detection**: Stops when promise phrase detected
- **Safety limit**: --max-iterations prevents infinite loops
- **Single session**: All iterations in one Claude Code session

#### Configuration

**Completion promise:**
- Uses exact string matching
- Cannot have multiple completion conditions
- Primary safety mechanism is --max-iterations

**Iteration limit:**
- Recommended: Always set --max-iterations
- Typical values: 20-50 for features, 10-20 for bug fixes

#### Tips & Best Practices

1. **Be specific**: More detail = fewer wasted iterations
2. **Include verification**: "Run tests" ensures quality
3. **Set realistic limits**: --max-iterations prevents runaway
4. **Trust iteration**: Don't aim for perfect first try
5. **Use for well-defined tasks**: Clear success criteria work best
6. **Include escape hatch**: Document what to do if stuck
7. **Let failures teach**: Each failure informs next iteration

**When to use:**
- Well-defined tasks with clear success criteria
- Tasks requiring iteration (getting tests to pass)
- Greenfield projects where you can walk away
- Tasks with automatic verification (tests, linters)

**When NOT to use:**
- Tasks requiring human judgment
- One-shot operations
- Unclear success criteria
- Production debugging (use targeted debugging instead)

#### Philosophy

**Core Principles:**
1. **Iteration > Perfection**: Don't aim for perfect on first try
2. **Failures Are Data**: "Deterministically bad" means predictable, informative failures
3. **Operator Skill Matters**: Success depends on writing good prompts
4. **Persistence Wins**: Keep trying until success

#### Real-World Results

- Successfully generated 6 repositories overnight (Y Combinator hackathon testing)
- One $50k contract completed for $297 in API costs
- Created entire programming language ("cursed") over 3 months

#### Learn More

- Original technique: https://ghuntley.com/ralph/
- Ralph Orchestrator: https://github.com/mikeyobrien/ralph-orchestrator

**Author**: Anthropic
**Version**: 1.0.0

---

## 7. Development Tools

### 7.1 agent-sdk-dev

**Purpose**: Comprehensive toolkit for creating and verifying Claude Agent SDK applications in Python and TypeScript.

**Maintainer**: Anthropic (Internal)

#### Overview

The agent-sdk-dev plugin streamlines the entire lifecycle of building Agent SDK applications, from initial scaffolding to verification against best practices. It helps you quickly start new projects with the latest SDK versions and ensures your applications follow official documentation patterns.

#### Components

**Command: `/new-sdk-app`**
- **Purpose**: Interactive command for creating new Agent SDK applications
- **Features**: Asks questions, installs latest SDK, creates files, verifies setup
- **Languages**: TypeScript and Python

**Agent: `agent-sdk-verifier-py`**
- **Purpose**: Verifies Python SDK applications
- **Checks**: Installation, environment, patterns, security, documentation
- **Output**: PASS/PASS WITH WARNINGS/FAIL with specific recommendations

**Agent: `agent-sdk-verifier-ts`**
- **Purpose**: Verifies TypeScript SDK applications
- **Checks**: Installation, TypeScript config, types, patterns, security, documentation
- **Output**: PASS/PASS WITH WARNINGS/FAIL with specific recommendations

#### Use Cases

1. **Quick project setup**: Start new SDK app in minutes
   ```bash
   /new-sdk-app customer-support-agent
   # → Asks language, agent type, starting point
   # → Creates project with latest SDK
   # → Verifies setup automatically
   ```

2. **Multiple agent types**: Choose appropriate starting point
   ```bash
   /new-sdk-app code-reviewer
   # → Choose "Coding agent" template
   # → Gets code review-specific boilerplate
   ```

3. **Verification before deploy**: Ensure best practices
   ```
   "Verify my TypeScript Agent SDK application"
   # → Runs comprehensive checks
   # → Reports issues and warnings
   ```

4. **Learning SDK patterns**: Start with working examples
   ```bash
   /new-sdk-app learning-project
   # → Choose "basic" starting point
   # → Get well-commented example code
   ```

5. **Troubleshooting issues**: Identify setup problems
   ```
   "Check if my SDK app follows best practices"
   # → Verifier identifies misconfigurations
   # → Provides SDK documentation links
   ```

#### How to Use

**Create new project:**
```bash
/new-sdk-app my-project-name
```

**Or interactive:**
```bash
/new-sdk-app
```

**Interactive questions:**
1. Language choice (TypeScript or Python)
2. Project name (if not provided)
3. Agent type (coding, business, custom)
4. Starting point (minimal, basic, specific example)
5. Tooling preferences (npm/yarn/pnpm or pip/poetry)

**Verify existing project:**
```
"Verify my Python Agent SDK application"
"Check if my SDK app follows best practices"
```

**Typical workflow:**
```bash
# 1. Create project
/new-sdk-app code-reviewer-agent

# 2. Answer questions
Language: TypeScript
Agent type: Coding agent (code review)
Starting point: Basic agent with common features

# 3. Automatic verification runs

# 4. Set API key
echo "ANTHROPIC_API_KEY=your_key_here" > .env

# 5. Run agent
npm start

# 6. Verify after changes
"Verify my SDK application"
```

#### Key Features

- **Latest SDK version**: Checks for and installs latest version
- **Interactive setup**: Guided questions for configuration
- **Multiple templates**: Minimal, basic, and specific examples
- **Automatic verification**: Runs verifier after creation
- **Type checking**: TypeScript projects validated with tsc
- **Environment setup**: Creates .env.example and .gitignore
- **Best practices**: Ensures official patterns followed
- **Documentation links**: Verifiers provide SDK doc references

#### Verification Checks

**Python (agent-sdk-verifier-py):**
- SDK installation and version
- requirements.txt or pyproject.toml
- Correct SDK usage patterns
- Agent initialization and configuration
- Environment and security (.env, API keys)
- Error handling and functionality
- Documentation completeness

**TypeScript (agent-sdk-verifier-ts):**
- SDK installation and version
- tsconfig.json configuration
- Type safety and imports
- Agent initialization and configuration
- Environment and security (.env, API keys)
- Error handling and functionality
- Documentation completeness

#### Verification Output

```
Overall Status: PASS WITH WARNINGS

Critical Issues:
- None

Warnings:
- Consider adding error handling for API timeouts
- README could include more usage examples

Passed Checks:
✓ SDK installed (latest version)
✓ Environment file configured
✓ Agent initialization correct
✓ TypeScript types valid
✓ Security: No hardcoded keys

Recommendations:
1. Add try/catch for network errors (see SDK docs: error-handling)
2. Include example usage in README
```

#### Configuration

No configuration needed. The plugin handles:
- SDK version checking
- Template selection
- File creation
- Verification standards

#### Tips & Best Practices

1. **Always use latest SDK**: /new-sdk-app installs latest automatically
2. **Verify before deploying**: Run verifier before production
3. **Keep API keys secure**: Never commit .env files
4. **Follow SDK documentation**: Verifiers check against official patterns
5. **Type check regularly**: Run `npx tsc --noEmit` for TypeScript projects
6. **Test your agents**: Create test cases for functionality

**When to use:**
- Starting new Agent SDK projects
- Verifying existing applications
- Before deploying to production
- Learning SDK patterns and best practices

**When NOT to use:**
- Non-SDK agent projects
- Claude Code plugin development (use plugin-dev instead)

#### Requirements

- Claude Code installed
- Node.js (for TypeScript projects)
- Python 3.7+ (for Python projects)
- Internet connection (for SDK installation)

#### Resources

- [Agent SDK Overview](https://docs.claude.com/en/api/agent-sdk/overview)
- [TypeScript SDK Reference](https://docs.claude.com/en/api/agent-sdk/typescript)
- [Python SDK Reference](https://docs.claude.com/en/api/agent-sdk/python)
- [Agent SDK Examples](https://docs.claude.com/en/api/agent-sdk/examples)

**Author**: Ashwin Bhat (ashwin@anthropic.com)
**Version**: 1.0.0

---

### 7.2 plugin-dev

**Purpose**: Comprehensive toolkit for developing Claude Code plugins with 7 specialized skills covering hooks, MCP integration, plugin structure, and more.

**Maintainer**: Anthropic (Internal)

#### Overview

The plugin-dev toolkit provides seven specialized skills and a guided workflow command to help you build high-quality Claude Code plugins. Each skill uses progressive disclosure: lean core documentation, detailed references when needed, and working examples with utility scripts.

#### 7 Specialized Skills

**1. Hook Development**
- **Focus**: Prompt-based and command hooks for event-driven automation
- **Triggers**: "create a hook", "PreToolUse hook", "block dangerous commands"
- **Resources**: Core SKILL.md (1,619 words) + 3 examples + 3 utilities

**2. MCP Integration**
- **Focus**: Model Context Protocol server configuration and integration
- **Triggers**: "add MCP server", "configure .mcp.json", "stdio/SSE/HTTP server"
- **Resources**: Core SKILL.md (1,666 words) + 3 examples + 3 references

**3. Plugin Structure**
- **Focus**: Plugin directory structure, manifest, auto-discovery
- **Triggers**: "plugin structure", "plugin.json manifest", "component organization"
- **Resources**: Core SKILL.md (1,619 words) + 3 examples + 2 references

**4. Plugin Settings**
- **Focus**: Configuration using .claude/plugin-name.local.md files
- **Triggers**: "plugin settings", ".local.md files", "YAML frontmatter"
- **Resources**: Core SKILL.md (1,623 words) + 3 examples + 2 utilities

**5. Command Development**
- **Focus**: Creating slash commands with frontmatter and arguments
- **Triggers**: "create a slash command", "command frontmatter", "define arguments"
- **Resources**: Core SKILL.md (1,535 words) + examples + patterns

**6. Agent Development**
- **Focus**: Creating autonomous agents with AI-assisted generation
- **Triggers**: "create an agent", "write a subagent", "agent frontmatter"
- **Resources**: Core SKILL.md (1,438 words) + 2 examples + 1 utility

**7. Skill Development**
- **Focus**: Creating skills with progressive disclosure and strong triggers
- **Triggers**: "create a skill", "improve skill description", "organize skill content"
- **Resources**: Core SKILL.md (1,232 words) + references + methodology

#### Guided Workflow Command

**`/plugin-dev:create-plugin`**
- **Purpose**: End-to-end workflow for creating plugins from scratch
- **8 Phases**:
  1. Discovery - Understand plugin purpose
  2. Component Planning - Determine needed components
  3. Detailed Design - Specify each component
  4. Structure Creation - Set up directories and manifest
  5. Component Implementation - Create components using agents
  6. Validation - Run plugin-validator and checks
  7. Testing - Verify plugin works
  8. Documentation - Finalize README

**Usage:**
```bash
/plugin-dev:create-plugin [optional description]

# Examples:
/plugin-dev:create-plugin
/plugin-dev:create-plugin A plugin for managing database migrations
```

#### Use Cases

1. **Create database plugin**: MCP integration + hooks
   ```
   "What's the structure for a plugin with MCP integration?"
   → plugin-structure skill provides layout

   "How do I configure an stdio MCP server for PostgreSQL?"
   → mcp-integration skill shows configuration

   "Add a Stop hook to ensure connections close properly"
   → hook-development skill provides pattern
   ```

2. **Create validation plugin**: PreToolUse hooks
   ```
   "Create hooks that validate all file writes for security"
   → hook-development skill with examples

   "Test my hooks before deploying"
   → Use validate-hook-schema.sh and test-hook.sh
   ```

3. **Integrate external service**: MCP + commands
   ```
   "Add Asana MCP server with OAuth"
   → mcp-integration skill covers SSE servers

   "Use Asana tools in my commands"
   → mcp-integration tool-usage reference
   ```

4. **Build custom workflow**: Commands + agents
   ```
   "/plugin-dev:create-plugin Custom code review workflow"
   → Guided through all 8 phases
   → Creates agents, commands, validates
   ```

5. **Learn plugin development**: Study examples
   ```
   "Show me how to create a plugin manifest"
   → plugin-structure skill with examples

   "How do I make hooks portable?"
   → hook-development explains ${CLAUDE_PLUGIN_ROOT}
   ```

#### How to Use

**Install plugin:**
```bash
/plugin install plugin-dev@claude-code-marketplace
```

**Trigger skills automatically:**
```
"What's the best directory structure for a plugin with commands and MCP?"
→ plugin-structure skill loads automatically

"How do I add an MCP server for database access?"
→ mcp-integration skill loads automatically

"Create a PreToolUse hook that validates file writes"
→ hook-development skill loads automatically
```

**Use guided workflow:**
```bash
/plugin-dev:create-plugin
# Or with description:
/plugin-dev:create-plugin A plugin for API testing workflows
```

**Use utility scripts:**
```bash
# Validate hooks.json structure
./validate-hook-schema.sh hooks/hooks.json

# Test hooks before deployment
./test-hook.sh my-hook.sh test-input.json

# Lint hook scripts
./hook-linter.sh my-hook.sh
```

#### Key Features

- **Progressive Disclosure**: Metadata → Core SKILL.md → References/Examples
- **Automatic Skill Loading**: Ask questions, skills load when relevant
- **Working Examples**: 12+ examples (hooks, MCP configs, plugin layouts)
- **Utility Scripts**: 6 validation/testing/parsing scripts
- **AI-Assisted Generation**: Uses Claude Code's proven agent-creation prompt
- **Security-First**: Best practices for hooks, MCP, and configuration
- **Portability**: ${CLAUDE_PLUGIN_ROOT} usage throughout

#### Skill Loading System

Skills load automatically based on trigger phrases:

| Trigger Phrase                        | Skill Loaded          | Purpose                          |
|---------------------------------------|-----------------------|----------------------------------|
| "create a hook"                       | hook-development      | Hook creation guidance           |
| "add MCP server"                      | mcp-integration       | MCP configuration help           |
| "plugin structure"                    | plugin-structure      | Directory layout guidance        |
| "plugin settings"                     | plugin-settings       | Configuration file help          |
| "create a slash command"              | command-development   | Command creation guidance        |
| "create an agent"                     | agent-development     | Agent creation with AI assist    |
| "create a skill"                      | skill-development     | Skill creation guidance          |

#### Utility Scripts

**hook-development utilities:**
- `validate-hook-schema.sh`: Validates hooks.json structure
- `test-hook.sh`: Tests hooks before deployment
- `hook-linter.sh`: Lints hook scripts for best practices

**plugin-settings utilities:**
- `validate-settings.sh`: Validates .local.md settings files
- `parse-frontmatter.sh`: Extracts YAML frontmatter from markdown

**agent-development utility:**
- `validate-agent.sh`: Validates agent file structure and frontmatter

#### Configuration

No configuration needed. Skills load automatically when you ask relevant questions.

#### Tips & Best Practices

**From all skills:**
1. **Security First**: Input validation, HTTPS, environment variables, least privilege
2. **Portability**: Use ${CLAUDE_PLUGIN_ROOT} everywhere, relative paths only
3. **Testing**: Validate configs, test hooks, use debug mode (`claude --debug`)
4. **Documentation**: Clear READMEs, documented env vars, usage examples

**When to use:**
- Building new Claude Code plugins
- Adding hooks, MCP servers, commands, agents, or skills
- Learning plugin development patterns
- Validating plugin components before deployment

**When NOT to use:**
- Agent SDK development (use agent-sdk-dev instead)
- General coding questions unrelated to plugins

#### Requirements

- Claude Code installed
- Python 3 (for utility scripts)
- Bash shell (for hook testing)

#### Total Content

- **Core Skills**: ~11,065 words across 7 SKILL.md files
- **Reference Docs**: ~10,000+ words of detailed guides
- **Examples**: 12+ working examples
- **Utilities**: 6 production-ready scripts

**Author**: Daisy Hollman (daisy@anthropic.com)
**Version**: 0.1.0

---

### 7.3 hookify

**Purpose**: Easily create custom hooks to prevent unwanted behaviors through simple markdown configuration files with regex pattern matching.

**Maintainer**: Anthropic (Internal)

#### Overview

The hookify plugin makes it simple to create hooks without editing complex hooks.json files. Instead, create lightweight markdown configuration files that define patterns to watch for and messages to show when those patterns match. Rules take effect immediately—no restart needed.

#### Key Features

- 🎯 Analyze conversations to find unwanted behaviors automatically
- 📝 Simple markdown configuration with YAML frontmatter
- 🔍 Regex pattern matching for powerful rules
- 🚀 No coding required—just describe the behavior
- 🔄 Easy enable/disable without restarting
- ⚡ Instant activation—rules work on next tool use

#### Commands

**`/hookify <description>`**
- **Purpose**: Create rule from explicit instructions
- **Example**: `/hookify Warn me when I use rm -rf commands`
- **Creates**: `.claude/hookify.warn-rm.local.md`

**`/hookify` (no arguments)**
- **Purpose**: Analyze recent conversation to find unwanted behaviors
- **Finds**: Behaviors you've corrected or been frustrated by

**`/hookify:list`**
- **Purpose**: List all hookify rules
- **Shows**: Active and inactive rules

**`/hookify:configure`**
- **Purpose**: Interactively enable/disable rules
- **Interface**: Interactive configuration UI

**`/hookify:help`**
- **Purpose**: Show help information

#### Use Cases

1. **Block dangerous commands**: Prevent destructive operations
   ```bash
   /hookify Don't allow rm -rf or dd commands
   ```
   Creates rule that blocks execution of dangerous commands.

2. **Warn about debug code**: Catch debug statements before commit
   ```bash
   /hookify Warn me when I add console.log to TypeScript files
   ```
   Shows warning but allows operation to proceed.

3. **Prevent credential leaks**: Stop hardcoded secrets
   ```bash
   /hookify Block writing API keys or tokens to code files
   ```
   Prevents committing sensitive data.

4. **Enforce code standards**: Remind about project conventions
   ```bash
   /hookify Warn when modifying files without updating tests
   ```
   Encourages test coverage.

5. **Session completion checks**: Ensure work is complete
   ```bash
   /hookify Don't let Claude stop until tests have been run
   ```
   Blocks session end if tests not executed.

#### How to Use

**Create rule with explicit description:**
```bash
/hookify Don't use console.log in TypeScript files
```

**Create rule from conversation analysis:**
```bash
/hookify
# Analyzes recent messages for unwanted patterns
```

**List all rules:**
```bash
/hookify:list
```

**Configure interactively:**
```bash
/hookify:configure
```

**Test immediately:**
```
Ask Claude to do something that should trigger the rule
→ Rule activates on next tool use (no restart!)
```

#### Rule Configuration Format

**Simple rule (single pattern):**

`.claude/hookify.dangerous-rm.local.md`:
```markdown
---
name: block-dangerous-rm
enabled: true
event: bash
pattern: rm\s+-rf
action: block
---

⚠️ **Dangerous rm command detected!**

This command could delete important files. Please:
- Verify the path is correct
- Consider using a safer approach
- Make sure you have backups
```

**Advanced rule (multiple conditions):**

`.claude/hookify.sensitive-files.local.md`:
```markdown
---
name: warn-sensitive-files
enabled: true
event: file
action: warn
conditions:
  - field: file_path
    operator: regex_match
    pattern: \.env$|credentials|secrets
  - field: new_text
    operator: contains
    pattern: KEY
---

🔐 **Sensitive file edit detected!**

Ensure credentials are not hardcoded and file is in .gitignore.
```

#### Event Types

| Event    | Triggers On                       | Use For                                    |
|----------|-----------------------------------|--------------------------------------------|
| bash     | Bash tool commands                | Command validation, dangerous operation prevention |
| file     | Edit, Write, MultiEdit tools      | File content checks, credential detection   |
| stop     | Claude wants to stop              | Completion checks, quality gates            |
| prompt   | User prompt submission            | Input validation, trigger warnings          |
| all      | All events                        | Universal monitoring                        |

#### Pattern Syntax

| Pattern          | Matches            | Example                |
|------------------|--------------------|------------------------|
| `rm\s+-rf`       | rm -rf             | rm -rf /tmp            |
| `console\.log\(` | console.log(       | console.log("test")    |
| `(eval\|exec)\(` | eval( or exec(     | eval("code")           |
| `\.env$`         | files ending .env  | .env, .env.local       |
| `chmod\s+777`    | chmod 777          | chmod 777 file.txt     |

**Tips:**
- Use `\s` for whitespace
- Escape special chars: `\.` for literal dot
- Use `|` for OR: `(foo|bar)`
- Use `.*` to match anything

#### Action Types

| Action | Behavior                                                |
|--------|---------------------------------------------------------|
| warn   | Shows warning but allows operation (default)            |
| block  | Prevents operation (PreToolUse) or stops session (Stop) |

#### Operators Reference

| Operator      | Meaning                        | Example                              |
|---------------|--------------------------------|--------------------------------------|
| regex_match   | Pattern must match (most common)| `pattern: \.env$`                    |
| contains      | String must contain pattern    | `pattern: API_KEY`                   |
| equals        | Exact string match             | `pattern: production`                |
| not_contains  | String must NOT contain pattern| `pattern: test`                      |
| starts_with   | String starts with pattern     | `pattern: /tmp/`                     |
| ends_with     | String ends with pattern       | `pattern: .env`                      |

#### Field Reference

**For bash events:**
- `command`: The bash command string

**For file events:**
- `file_path`: Path to file being edited
- `new_text`: New content being added (Edit, Write)
- `old_text`: Old content being replaced (Edit only)
- `content`: File content (Write only)

**For prompt events:**
- `user_prompt`: The user's submitted prompt text

**For stop events:**
- Use general matching on session state

#### Management

**Enable/disable rules:**
```bash
# Edit .local.md file
enabled: true  # or false

# Or use interactive tool
/hookify:configure
```

**Delete rules:**
```bash
rm .claude/hookify.my-rule.local.md
```

**View all rules:**
```bash
/hookify:list
```

#### Key Features

- **Instant activation**: No restart needed—rules work immediately
- **Flexible patterns**: Regex support for powerful matching
- **Multiple conditions**: All conditions must match for trigger
- **Action control**: Warn or block based on severity
- **Easy management**: Enable/disable with file edits
- **No external dependencies**: Uses Python stdlib only

#### Configuration

Rules are stored in `.claude/` directory at project root (not plugin directory).

**File naming convention:**
```
.claude/hookify.<rule-name>.local.md
```

#### Tips & Best Practices

1. **Start simple**: Begin with basic patterns, add complexity as needed
2. **Test patterns separately**: Use `python3 -c "import re; print(re.search(r'pattern', 'text'))"`
3. **Use specific event types**: `bash`, `file` more efficient than `all`
4. **Always set --max-iterations**: Safety net for dangerous operations
5. **Keep patterns simple**: Avoid complex regex for performance
6. **Limit active rules**: Too many rules can slow down operations

**When to use:**
- Preventing dangerous operations
- Enforcing coding standards
- Catching debug code before commits
- Preventing credential leaks
- Session completion checks

**When NOT to use:**
- Complex business logic (use proper agents instead)
- Performance-critical operations (patterns add overhead)
- Every single guideline (focus on critical ones)

#### Troubleshooting

**Rule not triggering:**
1. Check file exists in `.claude/` (project root)
2. Verify `enabled: true`
3. Test regex pattern separately
4. Try `/hookify:list` to see if loaded

**Pattern not matching:**
- Test regex: `python3 -c "import re; print(re.search(r'pattern', 'text'))"`
- Use unquoted patterns in YAML
- Start simple, add complexity incrementally

**Hook seems slow:**
- Keep patterns simple
- Use specific event types (not "all")
- Limit number of active rules

#### Requirements

- Python 3.7+
- No external dependencies (stdlib only)

**Author**: Anthropic
**Version**: 1.0.0

---

## 8. Examples

### 8.1 example-plugin

**Purpose**: Comprehensive example plugin demonstrating all Claude Code extension options—commands, skills, and MCP servers.

**Maintainer**: Anthropic (Internal)

#### Overview

The example-plugin serves as a reference implementation showing how to structure a Claude Code plugin and utilize all available extension mechanisms. Use it as a template when creating your own plugins or learning plugin development patterns.

#### Structure

```
example-plugin/
├── .claude-plugin/
│   └── plugin.json        # Plugin metadata
├── .mcp.json              # MCP server configuration
├── commands/
│   └── example-command.md # Slash command definition
└── skills/
    └── example-skill/
        └── SKILL.md       # Skill definition
```

#### Extension Options

**1. Commands (commands/)**
- **Purpose**: User-invoked slash commands
- **Format**: Markdown files with YAML frontmatter
- **Example**: `/example-command [args]`

**Frontmatter:**
```yaml
---
description: Short description for /help
argument-hint: <arg1> [optional-arg]
allowed-tools: [Read, Glob, Grep]
---
```

**2. Skills (skills/)**
- **Purpose**: Model-invoked capabilities
- **Format**: SKILL.md in subdirectory
- **Example**: Activates based on task context

**Frontmatter:**
```yaml
---
name: skill-name
description: Trigger conditions for this skill
version: 1.0.0
---
```

**3. MCP Servers (.mcp.json)**
- **Purpose**: External tool integration via Model Context Protocol
- **Format**: JSON configuration
- **Example**: Connects to external APIs

**Configuration:**
```json
{
  "server-name": {
    "type": "http",
    "url": "https://mcp.example.com/api"
  }
}
```

#### Use Cases

1. **Learning plugin structure**: Understand plugin organization
   ```
   Read example-plugin/ to see standard plugin layout
   → Understand file organization
   → See frontmatter formats
   → Learn best practices
   ```

2. **Creating first plugin**: Use as template
   ```
   Copy example-plugin structure
   → Modify for your use case
   → Customize commands and skills
   → Deploy your plugin
   ```

3. **Understanding commands**: See command syntax
   ```
   Read commands/example-command.md
   → Learn frontmatter fields
   → See argument hints
   → Understand tool restrictions
   ```

4. **Understanding skills**: See skill format
   ```
   Read skills/example-skill/SKILL.md
   → Learn skill frontmatter
   → See trigger descriptions
   → Understand skill organization
   ```

5. **MCP integration**: Learn MCP configuration
   ```
   Read .mcp.json
   → Understand server types
   → See configuration options
   → Learn integration patterns
   ```

#### How to Use

**As learning resource:**
```bash
# Read the plugin files
cat ~/.claude/plugins/marketplaces/claude-plugins-official/plugins/example-plugin/commands/example-command.md
cat ~/.claude/plugins/marketplaces/claude-plugins-official/plugins/example-plugin/skills/example-skill/SKILL.md
cat ~/.claude/plugins/marketplaces/claude-plugins-official/plugins/example-plugin/.mcp.json
```

**As template:**
```bash
# Copy structure for new plugin
cp -r example-plugin/ my-new-plugin/
# Modify files for your use case
```

**Test example command:**
```bash
/example-command [args]
```

**The example skill** activates automatically based on task context.

**The example MCP** activates automatically when configured.

#### Key Features

- **Complete reference**: Shows all extension options
- **Well-documented**: Comments and explanations throughout
- **Production-ready structure**: Follows best practices
- **Minimal complexity**: Easy to understand and modify
- **Real examples**: Working code, not just documentation

#### Files Explained

**plugin.json:**
- Plugin metadata
- Name, version, description
- Author information

**example-command.md:**
- Slash command definition
- YAML frontmatter configuration
- Command prompt and instructions

**SKILL.md:**
- Skill definition
- Trigger conditions
- Skill instructions

**.mcp.json:**
- MCP server configuration
- Server types and endpoints
- Authentication details

#### Configuration

No configuration needed for the example. It's a reference implementation.

**To modify:**
1. Copy the structure
2. Update plugin.json with your metadata
3. Modify commands and skills for your use case
4. Configure MCP servers as needed

#### Tips & Best Practices

1. **Study before building**: Read all files to understand structure
2. **Use as template**: Don't start from scratch—copy and modify
3. **Follow patterns**: Stick to established conventions
4. **Read plugin-dev**: Use plugin-dev for detailed guidance
5. **Test incrementally**: Start with one extension option, add more as needed

**When to use:**
- Learning plugin development
- Creating your first plugin
- Understanding extension options
- Referencing best practices

**When NOT to use:**
- Production workloads (it's an example)
- Complex plugin requirements (use plugin-dev for guidance)

#### Requirements

- Claude Code installed
- No additional dependencies

#### Related Resources

- **plugin-dev**: Comprehensive toolkit for plugin development
- **Plugin Documentation**: https://docs.claude.com/en/docs/claude-code/plugins
- **MCP Documentation**: https://docs.claude.com/en/docs/model-context-protocol

**Author**: Anthropic
**Version**: 1.0.0

---

## 9. External Plugins

External plugins are community-managed integrations that connect Claude Code to third-party services and platforms. These plugins are maintained by their respective companies and provide deep integration with popular development tools, services, and platforms.

### 9.1 context7

**Purpose:** Access up-to-date documentation and code examples
**Category:** AI/Documentation
**Maintainer:** Upstash (Community Managed)

#### Overview

Context7 is a documentation lookup service that pulls version-specific documentation and code examples directly from source repositories into your LLM context. It ensures you always have access to the latest, most accurate documentation for the libraries and frameworks you're using.

#### Use Cases

1. **Version-Specific Documentation**: Get documentation for the exact version of a library you're using, avoiding confusion from outdated or newer versions
2. **Code Example Retrieval**: Find real-world code examples from official repositories and documentation
3. **Framework Learning**: Access comprehensive guides and tutorials for new frameworks or libraries you're adopting
4. **API Reference**: Quickly look up API signatures, parameters, and return types from official sources

#### How to Use

After installation, Context7 runs as an MCP server that can be queried for documentation:
```bash
npx -y @upstash/context7-mcp
```

The plugin provides tools for searching and retrieving documentation directly within your Claude Code workflow.

#### Key Features

- **Version-aware**: Fetches documentation for specific library versions
- **Multi-source**: Aggregates from official docs, GitHub READMEs, and code examples
- **Real-time updates**: Always pulls the latest documentation from source
- **Code examples**: Includes working code snippets from official repositories

#### Configuration

Runs via MCP server configuration. No additional setup required after installation.

#### Tips & Best Practices

- Specify exact version numbers when querying for framework documentation
- Use for quick API reference lookups during development
- Combine with your existing code to get contextual examples
- Great for onboarding to new libraries or upgrading versions

#### Requirements

- Claude Code installed
- Node.js/npx (for running the MCP server)
- Internet connection for documentation retrieval

**Author**: Upstash
**Install Count**: 51.3K

---

### 9.2 github

**Purpose:** Official GitHub repository management integration
**Category:** Version Control
**Maintainer:** GitHub (Official)

#### Overview

The official GitHub MCP server provides comprehensive repository management capabilities directly from Claude Code. Create issues, manage pull requests, review code, search repositories, and interact with GitHub's full API without leaving your development environment.

#### Use Cases

1. **Issue Management**: Create, update, search, and close GitHub issues from your terminal
2. **Pull Request Workflows**: Review PRs, add comments, approve changes, and merge directly
3. **Repository Search**: Find repositories, code, commits, and issues across GitHub
4. **Code Review**: Read diff contents, add review comments, and suggest changes inline
5. **Project Management**: Track milestones, manage projects, and update labels

#### How to Use

After installation, the GitHub plugin provides MCP tools for all GitHub operations:
- Repository browsing and searching
- Issue creation and management
- Pull request operations
- Code review workflows
- GitHub API access

Authenticate with your GitHub account during first use.

#### Key Features

- **Full API Access**: Complete GitHub REST API integration
- **Real-time Updates**: Live data from your repositories
- **Multi-repo Support**: Work across multiple repositories and organizations
- **Review Tools**: Inline code review and commenting
- **Search Capabilities**: Powerful search across all GitHub resources

#### Configuration

Requires GitHub authentication token. Configure via MCP settings or environment variables.

#### Tips & Best Practices

- Set up SSH keys for seamless repository access
- Use labels and milestones for better issue organization
- Combine with commit-commands plugin for complete git workflow
- Leverage search to find similar issues or code examples across repos

#### Requirements

- Claude Code installed
- GitHub account
- GitHub personal access token or OAuth authentication
- Internet connection

**Author**: GitHub
**Install Count**: 30.5K

---

### 9.3 serena

**Purpose:** Semantic code analysis and intelligent understanding
**Category:** Code Analysis
**Maintainer:** Oraios (Community Managed)

#### Overview

Serena is a semantic code analysis MCP server that provides intelligent code understanding, refactoring suggestions, and codebase navigation through language server protocol integration. It offers AI-powered insights into code structure, dependencies, and potential improvements.

#### Use Cases

1. **Code Navigation**: Navigate large codebases semantically based on functionality rather than file structure
2. **Refactoring Suggestions**: Get intelligent suggestions for code improvements and refactoring opportunities
3. **Dependency Analysis**: Understand how different parts of your codebase relate and depend on each other
4. **Code Quality**: Identify code smells, anti-patterns, and areas for improvement
5. **Documentation**: Auto-generate documentation based on semantic understanding of code

#### How to Use

Serena integrates with Claude Code as an MCP server and provides semantic analysis tools:
- Automatic code scanning and indexing
- Intelligent suggestions during development
- Refactoring recommendations
- Code navigation enhancements

#### Key Features

- **Semantic Understanding**: Goes beyond syntax to understand code meaning and purpose
- **LSP Integration**: Works with language servers for accurate code analysis
- **Refactoring Tools**: Intelligent code transformation suggestions
- **Cross-reference**: Find all usages and dependencies quickly
- **Pattern Recognition**: Identifies common patterns and anti-patterns

#### Configuration

Runs as MCP server. Configure language-specific settings as needed.

#### Tips & Best Practices

- Let Serena index your codebase before expecting instant results
- Use for refactoring large codebases systematically
- Combine with language-specific LSPs for best results
- Review all suggested refactorings before applying

#### Requirements

- Claude Code installed
- Project codebase to analyze
- Language server support for your programming language

**Author**: Oraios
**Install Count**: 27.4K

---

### 9.4 supabase

**Purpose:** Backend-as-a-Service for database, auth, and storage
**Category:** Backend/Database
**Maintainer:** Supabase (Official)

#### Overview

The Supabase MCP integration provides comprehensive access to Supabase's backend services including Postgres databases, authentication, file storage, and real-time subscriptions. Manage your Supabase projects, run SQL queries, and interact with your backend infrastructure directly from Claude Code.

#### Use Cases

1. **Database Operations**: Execute SQL queries, manage tables, and interact with Postgres databases
2. **Authentication Management**: Handle user authentication, manage auth policies, and configure providers
3. **Storage Operations**: Upload files, manage buckets, and handle file permissions
4. **Real-time Subscriptions**: Set up real-time data synchronization and live updates
5. **Project Management**: Configure Supabase projects, manage environments, and handle migrations

#### How to Use

After installation and authentication:
- Run SQL queries directly from your editor
- Manage authentication policies and users
- Upload and organize files in storage buckets
- Configure real-time subscriptions
- Access Supabase project settings

Authenticate with your Supabase project credentials during setup.

#### Key Features

- **Full Backend Access**: Complete Supabase API integration
- **SQL Editor**: Run queries and manage databases inline
- **Auth Management**: User authentication and authorization tools
- **File Storage**: Upload and manage files programmatically
- **Real-time**: Configure live data synchronization

#### Configuration

Requires Supabase project URL and API keys. Configure via MCP settings.

#### Tips & Best Practices

- Use environment variables for project credentials
- Test queries in development before running in production
- Leverage Row Level Security (RLS) policies for data protection
- Combine with database migrations for schema management

#### Requirements

- Claude Code installed
- Supabase project and account
- Project API keys (anon/service)
- Internet connection

**Author**: Supabase
**Install Count**: 15.5K

---

### 9.5 atlassian

**Purpose:** Jira and Confluence integration for project management
**Category:** Project Management
**Maintainer:** Atlassian (Community Managed)

#### Overview

Connect to Atlassian products including Jira for issue tracking and Confluence for documentation. Manage projects, create tickets, update documentation, and track work without leaving your development environment.

#### Use Cases

1. **Issue Tracking**: Create, update, and track Jira issues and tickets
2. **Sprint Management**: Manage sprints, backlogs, and agile workflows
3. **Documentation**: Access and update Confluence pages and documentation
4. **Project Planning**: View roadmaps, timelines, and project status
5. **Team Collaboration**: Comment on issues, tag team members, and track progress

#### How to Use

After installation and authentication with Atlassian:
- Create and search Jira issues
- Update issue status and assignees
- Access Confluence documentation
- Track sprint progress
- Link commits to issues

#### Key Features

- **Jira Integration**: Full issue tracking and agile workflow support
- **Confluence Access**: Read and update documentation
- **Search**: Find issues, projects, and docs quickly
- **Workflow Automation**: Trigger workflows and transitions
- **Multi-project**: Work across multiple Jira projects

#### Configuration

Requires Atlassian account and API token. Configure domain and credentials.

#### Tips & Best Practices

- Link commits to Jira issues for better traceability
- Use JQL (Jira Query Language) for advanced searches
- Keep Confluence docs updated alongside code changes
- Automate issue transitions based on git events

#### Requirements

- Claude Code installed
- Atlassian account (Jira/Confluence)
- API token or OAuth authentication
- Internet connection

**Author**: Atlassian
**Install Count**: 14.7K

---

### 9.6 playwright

**Purpose:** Browser automation and end-to-end testing
**Category:** Testing
**Maintainer**: Microsoft (Official)

#### Overview

Playwright is Microsoft's browser automation and end-to-end testing framework integrated as an MCP server. Enable Claude to interact with web pages, take screenshots, fill forms, click elements, and perform automated browser testing workflows directly from your development environment.

#### Use Cases

1. **E2E Testing**: Write and execute end-to-end browser tests for web applications
2. **Web Scraping**: Automate data extraction from websites
3. **UI Testing**: Test user interfaces across multiple browsers (Chrome, Firefox, WebKit)
4. **Screenshot Automation**: Capture screenshots for visual regression testing
5. **Form Automation**: Fill out forms, submit data, and test user flows

#### How to Use

After installation, Playwright provides MCP tools for browser automation:
- Launch browsers (Chromium, Firefox, WebKit)
- Navigate to URLs and interact with pages
- Execute JavaScript in browser context
- Take screenshots and generate PDFs
- Test responsive designs with device emulation

#### Key Features

- **Multi-browser Support**: Test across Chrome, Firefox, and Safari
- **Headless Mode**: Run tests without visible browser windows
- **Device Emulation**: Test mobile and tablet viewports
- **Network Interception**: Mock API responses and test offline scenarios
- **Auto-wait**: Smart waiting for elements to be ready

#### Configuration

No special configuration required. Browsers are downloaded automatically on first use.

#### Tips & Best Practices

- Use headless mode for faster test execution in CI/CD
- Leverage device emulation for responsive design testing
- Implement page object models for maintainable tests
- Use screenshots for debugging test failures
- Mock network requests for faster, more reliable tests

#### Requirements

- Claude Code installed
- Node.js (Playwright runtime)
- Disk space for browser binaries (~300MB per browser)

**Author**: Microsoft
**Install Count**: 13.1K

---

### 9.7 figma

**Purpose:** Design platform integration for UI/UX workflows
**Category:** Design
**Maintainer:** Figma (Community Managed)

#### Overview

Figma design platform integration enables access to design files, export assets, read design tokens, and synchronize UI implementations with design specifications. Bridge the gap between design and development workflows.

#### Use Cases

1. **Asset Export**: Export images, icons, and design assets directly from Figma files
2. **Design Tokens**: Extract colors, typography, spacing, and other design tokens
3. **Component Sync**: Keep code components aligned with Figma designs
4. **Design Review**: Access design files and specifications during development
5. **Handoff**: Streamline designer-to-developer handoff process

#### How to Use

After installation and Figma authentication:
- Access Figma files and frames
- Export design assets programmatically
- Read design specifications and measurements
- Extract design tokens for code generation
- View component documentation

#### Key Features

- **File Access**: Browse and access Figma design files
- **Asset Export**: Download images, SVGs, and other assets
- **Design Tokens**: Extract design system variables
- **Version History**: Access previous versions of designs
- **Team Libraries**: Access shared component libraries

#### Configuration

Requires Figma account and personal access token. Configure via MCP settings.

#### Tips & Best Practices

- Use design tokens to maintain consistency between design and code
- Automate asset export for CI/CD pipelines
- Version control exported assets alongside code
- Keep component names consistent between Figma and codebase

#### Requirements

- Claude Code installed
- Figma account
- Personal access token
- Internet connection

**Author**: Figma
**Install Count**: 12.4K

---

### 9.8 Notion

**Purpose:** Workspace and documentation integration
**Category:** Productivity
**Maintainer:** Notion (Community Managed)

#### Overview

Notion workspace integration enables searching pages, creating and updating documents, managing databases, and accessing your knowledge base directly from Claude Code. Seamlessly integrate your documentation workflow with development.

#### Use Cases

1. **Documentation Management**: Access and update Notion pages alongside code
2. **Knowledge Base Search**: Search your team's knowledge base for context and information
3. **Project Notes**: Create and maintain project documentation in Notion
4. **Database Operations**: Query and update Notion databases for project tracking
5. **Meeting Notes**: Access meeting notes and decisions during development

#### How to Use

After installation and Notion authentication:
- Search Notion pages and databases
- Create new pages and documents
- Update existing content
- Query Notion databases
- Link documentation to code changes

#### Key Features

- **Full Workspace Access**: Browse all Notion pages and databases
- **Search**: Find information across your entire workspace
- **Create & Edit**: Update documentation programmatically
- **Database Queries**: Access structured data in Notion databases
- **Rich Content**: Support for blocks, embeds, and formatting

#### Configuration

Requires Notion integration token and workspace access. Configure via MCP settings.

#### Tips & Best Practices

- Keep technical documentation in Notion synced with code changes
- Use Notion databases for tracking bugs and features
- Link code commits to relevant Notion pages
- Maintain API documentation in Notion for easy team access

#### Requirements

- Claude Code installed
- Notion workspace and account
- Integration token
- Internet connection

**Author**: Notion
**Install Count**: 7.6K

---

### 9.9 linear

**Purpose:** Modern issue tracking and project management
**Category:** Project Management
**Maintainer:** Linear (Official)

#### Overview

Linear issue tracking integration provides access to Linear's modern issue tracker. Create issues, manage projects, update statuses, search across workspaces, and streamline your software development workflow with Linear's fast, keyboard-first interface.

#### Use Cases

1. **Issue Creation**: Create detailed issues directly from error logs or code
2. **Status Updates**: Track and update issue progress during development
3. **Sprint Planning**: View and manage sprint backlogs and cycles
4. **Project Tracking**: Monitor project status and team velocity
5. **Workflow Automation**: Auto-create issues from bugs or test failures

#### How to Use

After installation and Linear authentication:
- Create issues with full context
- Search issues across teams and projects
- Update issue status and assignees
- Link commits to Linear issues
- View project roadmaps and cycles

#### Key Features

- **Fast Issue Creation**: Quick issue creation with templates
- **Keyboard Shortcuts**: Efficient workflow with keyboard-first design
- **Project Views**: Roadmaps, cycles, and board views
- **Team Collaboration**: Assign issues, add labels, and track progress
- **Git Integration**: Link commits and PRs to issues

#### Configuration

Requires Linear API key. Configure workspace and team settings.

#### Tips & Best Practices

- Use issue templates for consistent bug reports
- Link commits to Linear issues automatically
- Leverage labels for better organization
- Set up Linear cycles for sprint planning
- Use estimates for capacity planning

#### Requirements

- Claude Code installed
- Linear workspace and account
- API key
- Internet connection

**Author**: Linear
**Install Count**: 6.4K

---

### 9.10 laravel-boost

**Purpose:** Laravel framework development toolkit
**Category:** Framework
**Maintainer:** Laravel (Community Managed)

#### Overview

Laravel development toolkit MCP server provides intelligent assistance for Laravel applications. Get help with Artisan commands, Eloquent queries, routing, migrations, and framework-specific code generation tailored for Laravel development.

#### Use Cases

1. **Artisan Commands**: Generate controllers, models, migrations with proper Laravel conventions
2. **Eloquent Queries**: Build complex database queries with Laravel's ORM
3. **Routing**: Create and manage routes following Laravel best practices
4. **Migrations**: Generate database migrations and seeders
5. **Testing**: Create Laravel-specific tests with proper structure

#### How to Use

After installation in a Laravel project:
- Generate boilerplate code following Laravel conventions
- Get suggestions for Eloquent relationships and queries
- Create migrations with proper schema definitions
- Build routes with middleware and validation
- Generate tests following Laravel testing patterns

#### Key Features

- **Framework-Aware**: Understands Laravel conventions and patterns
- **Code Generation**: Artisan-style code generation
- **Best Practices**: Follows Laravel community standards
- **Query Builder**: Intelligent Eloquent query assistance
- **Testing Support**: Laravel-specific test generation

#### Configuration

Auto-detects Laravel projects. No additional configuration required.

#### Tips & Best Practices

- Follow Laravel naming conventions for generated code
- Use service providers for better code organization
- Leverage Eloquent relationships over manual queries
- Write tests alongside feature development
- Use Laravel's validation in requests, not controllers

#### Requirements

- Claude Code installed
- Laravel project (Laravel 8+)
- PHP and Composer installed

**Author**: Laravel
**Install Count**: 5.6K

---

### 9.11 greptile

**Purpose:** AI-powered code review for GitHub and GitLab
**Category:** Code Search
**Maintainer:** Greptile (Community Managed)

#### Overview

Greptile is an AI code review agent that analyzes pull requests on GitHub and GitLab. View and resolve Greptile's automated review comments directly from Claude Code, combining AI-powered code analysis with your development workflow.

#### Use Cases

1. **Automated Code Review**: Get AI-generated review feedback on PRs
2. **Code Quality**: Identify potential bugs, security issues, and improvements
3. **Best Practices**: Receive suggestions for code quality and maintainability
4. **Review Resolution**: Address Greptile's comments directly in Claude Code
5. **Learning**: Learn from AI feedback to improve coding practices

#### How to Use

After installation and integration with GitHub/GitLab:
- Greptile automatically reviews PRs when configured
- View review comments in Claude Code
- Address issues and suggestions
- Re-request reviews after changes
- Track review history and improvements

#### Key Features

- **AI Code Review**: Automated analysis of code changes
- **Multi-platform**: Works with GitHub and GitLab
- **Contextual**: Understands codebase context for relevant suggestions
- **Learning**: Improves over time based on your codebase
- **Integration**: Seamless workflow within Claude Code

#### Configuration

Requires Greptile account and repository configuration. Set up webhooks for automated reviews.

#### Tips & Best Practices

- Configure Greptile for repositories you want to monitor
- Review AI suggestions critically - not all will be applicable
- Use as a learning tool for junior developers
- Combine with human code review for best results
- Fine-tune review settings based on your team's needs

#### Requirements

- Claude Code installed
- Greptile account
- GitHub or GitLab repository
- Webhook access for automated reviews
- Internet connection

**Author**: Greptile
**Install Count**: 5.5K

---

### 9.12 sentry

**Purpose:** Error monitoring and performance tracking
**Category:** Error Monitoring
**Maintainer:** Sentry (Community Managed)

#### Overview

Sentry error monitoring integration provides access to error reports, performance metrics, and application health data. Monitor production issues, debug errors, track performance bottlenecks, and maintain application reliability directly from your development environment.

#### Use Cases

1. **Error Debugging**: Access detailed error reports with stack traces and context
2. **Performance Monitoring**: Track slow transactions and performance issues
3. **Release Tracking**: Monitor error rates across deployments and releases
4. **Issue Management**: Triage, assign, and resolve production issues
5. **Alerting**: Configure and manage error alerts and notifications

#### How to Use

After installation and Sentry authentication:
- View error reports and stack traces
- Search issues by release, environment, or user
- Access performance metrics and traces
- Manage issue status and assignments
- Configure alerts and notifications

#### Key Features

- **Real-time Errors**: Instant error reporting from production
- **Stack Traces**: Detailed error context and source mapping
- **Performance**: Transaction traces and performance metrics
- **Releases**: Track error rates across deployments
- **Integrations**: Works with CI/CD, Slack, and other tools

#### Configuration

Requires Sentry account and DSN configuration. Set project and environment settings.

#### Tips & Best Practices

- Configure source maps for better stack traces
- Use releases to track error regression
- Set up alerts for critical error spikes
- Tag errors by user, feature, or environment
- Regularly triage and resolve high-impact issues

#### Requirements

- Claude Code installed
- Sentry account and project
- Auth token
- Internet connection

**Author**: Sentry
**Install Count**: 4.9K

---

### 9.13 vercel

**Purpose:** Deployment platform for frontend applications
**Category:** Deployment
**Maintainer:** Vercel (Community Managed)

#### Overview

Vercel deployment platform integration enables managing deployments, previews, environment variables, and serverless functions. Deploy applications, manage domains, and monitor production directly from Claude Code.

#### Use Cases

1. **Deployment Management**: Deploy and manage Vercel projects
2. **Preview Deployments**: Create and view preview deployments for branches
3. **Environment Variables**: Manage environment configuration across deployments
4. **Domain Management**: Configure custom domains and DNS settings
5. **Serverless Functions**: Deploy and manage Edge and Serverless Functions

#### How to Use

After installation and Vercel authentication:
- Deploy projects to Vercel
- View deployment status and logs
- Manage environment variables
- Configure domains and SSL
- Monitor serverless function performance

#### Key Features

- **Instant Deployments**: Push to deploy with Git integration
- **Preview URLs**: Automatic preview deployments for PRs
- **Edge Network**: Global CDN for fast content delivery
- **Serverless**: Deploy serverless and edge functions
- **Analytics**: Real-time performance and visitor analytics

#### Configuration

Requires Vercel account and API token. Link Git repositories for automatic deployments.

#### Tips & Best Practices

- Use preview deployments to test before merging
- Configure environment variables per environment (dev/staging/prod)
- Leverage Edge Functions for dynamic server-side logic
- Monitor Core Web Vitals for performance optimization
- Use Vercel Analytics for user insights

#### Requirements

- Claude Code installed
- Vercel account
- API token
- Git repository (for automatic deployments)
- Internet connection

**Author**: Vercel
**Install Count**: 4.1K

---

### 9.14 gitlab

**Purpose:** Complete DevOps platform integration
**Category:** Version Control
**Maintainer:** GitLab (Official)

#### Overview

GitLab DevOps platform integration provides comprehensive access to repositories, merge requests, CI/CD pipelines, issues, and wikis. Manage the complete DevOps lifecycle from planning to deployment directly within Claude Code.

#### Use Cases

1. **Repository Management**: Clone, browse, and manage GitLab repositories
2. **Merge Requests**: Create, review, and merge MRs with full diff access
3. **CI/CD Pipelines**: Monitor pipeline status, view logs, and trigger jobs
4. **Issue Tracking**: Create and manage GitLab issues and milestones
5. **Wiki Documentation**: Access and update project wikis

#### How to Use

After installation and GitLab authentication:
- Manage repositories and branches
- Create and review merge requests
- Monitor CI/CD pipeline status
- Track issues and milestones
- Update wiki documentation

#### Key Features

- **Full DevOps**: Complete lifecycle management
- **CI/CD Integration**: Pipeline monitoring and control
- **Code Review**: Inline MR comments and suggestions
- **Issue Tracking**: Built-in project management
- **Wiki**: Collaborative documentation

#### Configuration

Requires GitLab account and personal access token. Configure for GitLab.com or self-hosted instances.

#### Tips & Best Practices

- Use GitLab CI/CD for automated testing and deployment
- Leverage merge request templates for consistency
- Configure protected branches for production code
- Use GitLab Issues for agile project management
- Maintain wiki documentation for team knowledge

#### Requirements

- Claude Code installed
- GitLab account (GitLab.com or self-hosted)
- Personal access token
- Internet connection

**Author**: GitLab
**Install Count**: 4.0K

---

### 9.15 slack

**Purpose:** Team communication and collaboration
**Category:** Communication
**Maintainer:** Slack (Official)

#### Overview

Slack workspace integration enables searching messages, accessing channels, reading threads, and staying connected with team communications while coding. Find relevant discussions and context quickly without leaving your development environment.

#### Use Cases

1. **Message Search**: Find team discussions and decisions from within Claude Code
2. **Channel Access**: Read channel messages for context and updates
3. **Thread Monitoring**: Follow important conversation threads
4. **Context Retrieval**: Access past discussions related to current work
5. **Team Coordination**: Stay updated on team communications

#### How to Use

After installation and Slack authentication:
- Search messages across channels
- Read channel conversations
- Access thread discussions
- View shared files and links
- Search by user, date, or keyword

#### Key Features

- **Workspace Search**: Find messages across all channels
- **Channel Access**: Read public and private channels
- **Thread Support**: Navigate conversation threads
- **File Access**: View shared files and attachments
- **User Lookup**: Find messages from specific team members

#### Configuration

Requires Slack workspace access and OAuth authentication.

#### Tips & Best Practices

- Search Slack for context when working on features
- Reference past discussions in code comments
- Use for finding decisions and requirements
- Search by keywords related to current work
- Respect channel privacy and permissions

#### Requirements

- Claude Code installed
- Slack workspace membership
- OAuth authentication
- Internet connection

**Author**: Slack
**Install Count**: 3.8K

---

### 9.16 stripe

**Purpose:** Payment processing and API development
**Category:** Payments
**Maintainer:** Stripe (Official)

#### Overview

Stripe development plugin provides tools for building payment integrations, testing webhooks, managing API keys, and developing Stripe-powered applications. Access Stripe's payment infrastructure directly from your development workflow.

#### Use Cases

1. **Payment Integration**: Build and test payment flows
2. **Webhook Testing**: Test and debug Stripe webhook events
3. **API Development**: Interact with Stripe's REST API
4. **Customer Management**: Manage customers, subscriptions, and invoices
5. **Security**: Handle payment data securely with Stripe's tools

#### How to Use

After installation and Stripe authentication:
- Test payment integrations
- Manage API keys and secrets
- Receive and test webhook events
- Query customer and payment data
- Access Stripe documentation

#### Key Features

- **API Access**: Full Stripe API integration
- **Webhook Testing**: Local webhook event testing
- **Test Mode**: Safe development environment
- **Security**: PCI-compliant payment handling
- **Documentation**: Inline access to Stripe docs

#### Configuration

Requires Stripe account and API keys. Configure test vs. live mode.

#### Tips & Best Practices

- Always use test mode during development
- Secure API keys with environment variables
- Test all webhook events before going live
- Follow PCI compliance guidelines
- Use Stripe's test card numbers for testing

#### Requirements

- Claude Code installed
- Stripe account
- API keys (test and/or live)
- Internet connection

**Author**: Stripe
**Install Count**: 2.2K

---

### 9.17 firebase

**Purpose:** Google's backend platform for mobile and web
**Category:** Backend/Database
**Maintainer:** Google (Official)

#### Overview

Google Firebase MCP integration provides comprehensive access to Firestore databases, authentication, cloud functions, hosting, and storage. Build and manage your Firebase backend infrastructure directly from your development workflow.

#### Use Cases

1. **Firestore Database**: Query and manage NoSQL database collections
2. **Authentication**: Configure auth providers and manage users
3. **Cloud Functions**: Deploy and manage serverless functions
4. **Hosting**: Deploy and manage web hosting
5. **Storage**: Manage file uploads and cloud storage

#### How to Use

After installation and Firebase authentication:
- Query Firestore collections and documents
- Manage authentication users and providers
- Deploy Cloud Functions
- Configure hosting settings
- Access Firebase Storage

#### Key Features

- **Firestore**: Real-time NoSQL database
- **Auth**: Multi-provider authentication
- **Functions**: Serverless backend logic
- **Hosting**: Fast, secure web hosting
- **Storage**: File storage and serving

#### Configuration

Requires Firebase project and service account credentials. Configure project ID and credentials.

#### Tips & Best Practices

- Use security rules to protect Firestore data
- Test Cloud Functions locally before deployment
- Leverage Firebase Auth for user management
- Use Firebase Hosting for static site deployment
- Monitor usage and costs in Firebase Console

#### Requirements

- Claude Code installed
- Firebase project
- Service account credentials
- Node.js (for Cloud Functions)
- Internet connection

**Author**: Google
**Install Count**: 2.1K

---

### 9.18 asana

**Purpose:** Project and task management integration
**Category:** Project Management
**Maintainer:** Asana (Official)

#### Overview

Asana project management integration enables creating and managing tasks, searching projects, updating assignments, tracking progress, and integrating development workflow with Asana's work management platform. Keep development work synchronized with project plans.

#### Use Cases

1. **Task Management**: Create tasks directly from code or bugs
2. **Project Tracking**: Monitor project progress and status
3. **Sprint Planning**: Organize development work in Asana
4. **Assignment Updates**: Update task status and assignees
5. **Workflow Integration**: Link commits to Asana tasks

#### How to Use

After installation and Asana authentication:
- Create tasks with context from development
- Search and update existing tasks
- Track project milestones
- Update task assignments and status
- Link code changes to Asana tasks

#### Key Features

- **Task Creation**: Quick task creation from errors or features
- **Project Views**: Multiple view types (list, board, timeline)
- **Collaboration**: Comments, attachments, and mentions
- **Custom Fields**: Track additional metadata
- **Automation**: Trigger workflows based on task changes

#### Configuration

Requires Asana workspace access and personal access token.

#### Tips & Best Practices

- Create tasks from bug reports automatically
- Link commits to Asana tasks for traceability
- Use custom fields for technical metadata
- Organize tasks in projects for better visibility
- Set due dates and assignees for accountability

#### Requirements

- Claude Code installed
- Asana workspace membership
- Personal access token
- Internet connection

**Author**: Asana
**Install Count**: 951

---

## 10. Language Server Plugins (LSP)

Language Server Protocol (LSP) plugins provide intelligent code completion, go-to-definition, find references, error checking, and refactoring capabilities for specific programming languages. These plugins activate automatically when you open files with supported extensions.

**Key Benefits:**
- ✅ **Smart Code Completion**: Context-aware auto-complete suggestions
- ✅ **Go-to-Definition**: Jump to symbol definitions instantly
- ✅ **Find References**: Find all usages of a symbol across your project
- ✅ **Real-time Error Checking**: Catch errors as you type
- ✅ **Refactoring Support**: Rename symbols, extract methods, and more

**Cost**: LSPs only consume tokens when you're actively editing files in their supported languages. **Zero cost when idle or working with other file types.**

---

### 10.1 typescript-lsp

**Language:** TypeScript & JavaScript
**Supported Extensions:** `.ts`, `.tsx`, `.js`, `.jsx`, `.mts`, `.cts`, `.mjs`, `.cjs`

**What it does:** Provides code intelligence for TypeScript and JavaScript projects including type checking, auto-completion, and refactoring.

**Key Features:**
- Type-aware auto-completion
- Go-to-definition for imports and symbols
- Real-time TypeScript error checking
- Refactoring (rename, extract, etc.)

**When to use:** Essential for any TypeScript or JavaScript development work.

**Install Count:** 15.0K

---

### 10.2 pyright-lsp

**Language:** Python
**Supported Extensions:** `.py`, `.pyi`

**What it does:** Provides static type checking and code intelligence for Python, powered by Microsoft's Pyright.

**Key Features:**
- Static type checking with type hints
- Smart auto-completion for Python libraries
- Go-to-definition across modules
- Type inference and diagnostics

**When to use:** For Python projects, especially those using type hints and modern Python features.

**Install Count:** 8.7K

---

### 10.3 gopls-lsp

**Language:** Go
**Supported Extensions:** `.go`

**What it does:** Official Go language server providing code intelligence, refactoring, and analysis for Go projects.

**Key Features:**
- Go-aware code completion
- Automatic imports management
- Code refactoring and formatting
- Build and test integration

**When to use:** Essential for Go development.

**Install Count:** 3.3K

---

### 10.4 rust-analyzer-lsp

**Language:** Rust
**Supported Extensions:** `.rs`

**What it does:** Provides comprehensive code intelligence and analysis for Rust projects.

**Key Features:**
- Rust-specific auto-completion with macro expansion
- Borrow checker integration
- Inline type hints
- Run and debug support

**When to use:** Essential for Rust development, significantly improves Rust coding experience.

**Install Count:** 2.8K

---

### 10.5 csharp-lsp

**Language:** C#
**Supported Extensions:** `.cs`

**What it does:** Provides code intelligence and diagnostics for C# development.

**Key Features:**
- .NET framework-aware completion
- Namespace and using management
- Code diagnostics and fixes
- Symbol navigation

**When to use:** For C# and .NET development projects.

**Requirements:** .NET SDK 6.0 or later

**Install Count:** 2.7K

---

### 10.6 php-lsp

**Language:** PHP
**Supported Extensions:** `.php`

**What it does:** Powered by Intelephense, provides code intelligence for PHP projects.

**Key Features:**
- PHP-aware auto-completion
- Framework detection (Laravel, Symfony, etc.)
- Code diagnostics and formatting
- Symbol navigation and references

**When to use:** For PHP development, especially with frameworks like Laravel or WordPress.

**Install Count:** 2.4K

---

### 10.7 jdtls-lsp

**Language:** Java
**Supported Extensions:** `.java`

**What it does:** Eclipse JDT Language Server providing comprehensive Java code intelligence and refactoring.

**Key Features:**
- Java-specific code completion
- Maven/Gradle project support
- Advanced refactoring tools
- Build integration

**When to use:** Essential for Java development, especially enterprise Java projects.

**Requirements:** Java 17 or later (JDK)

**Install Count:** 2.4K

---

### 10.8 clangd-lsp

**Language:** C/C++
**Supported Extensions:** `.c`, `.h`, `.cpp`, `.cc`, `.cxx`, `.hpp`, `.hxx`, `.C`, `.H`

**What it does:** LLVM-based language server providing code intelligence for C and C++ projects.

**Key Features:**
- Clang-based error checking
- Cross-reference navigation
- Code completion with compiler accuracy
- Code formatting (clang-format)

**When to use:** For C/C++ development, system programming, or embedded development.

**Install Count:** 2.0K

---

### 10.9 swift-lsp

**Language:** Swift
**Supported Extensions:** `.swift`

**What it does:** SourceKit-LSP provides code intelligence for Swift development, included with the Swift toolchain.

**Key Features:**
- Swift-specific auto-completion
- SwiftUI support
- Protocol and extension navigation
- Compiler integration

**When to use:** For iOS, macOS, or server-side Swift development.

**Requirements:** Xcode (macOS) or Swift toolchain

**Install Count:** 2.0K

---

### 10.10 lua-lsp

**Language:** Lua
**Supported Extensions:** `.lua`

**What it does:** Provides code intelligence and diagnostics for Lua scripting.

**Key Features:**
- Lua-aware completion
- EmmyLua annotations support
- Symbol navigation
- Diagnostics and formatting

**When to use:** For Lua scripting, game development (Roblox, Love2D), or Neovim configuration.

**Install Count:** 1.3K

---

## 11. Complete Plugin Inventory

### All Available Plugins (41 Total)

This table shows all plugins available in the Claude Code Marketplace with their invocation methods and token costs.

**Cost Legend:**
- **Zero (idle)** - No cost when not invoked
- **✓ Low** - Minimal token usage
- **⚙️ Medium** - Moderate token usage for multi-agent workflows
- **⚠️ High** - Always active with significant token usage

| # | Plugin Name                | Type     | Category              | Invoke Method     | Cost            | Installs |
|---|----------------------------|----------|-----------------------|-------------------|-----------------|----------|
| 1 | feature-dev                | Internal | Development Workflows | `/feature-dev`    | ⚙️ Medium (when invoked) | 27.0K    |
| 2 | code-review                | Internal | Development Workflows | `/code-review`    | ⚙️ Medium (when invoked) | 24.1K    |
| 3 | pr-review-toolkit          | Internal | Development Workflows | Agent triggers    | ⚙️ Medium (when invoked) | 12.6K    |
| 4 | commit-commands            | Internal | Git Operations        | `/commit`         | ✓ Low (when invoked)     | 17.9K    |
| 5 | security-guidance          | Internal | Security              | Auto (PreToolUse) | ✓ Low (always active)    | 15.2K    |
| 6 | frontend-design            | Internal | Design                | Auto (on demand)  | ✓ Low (when triggered)   | 55.2K    |
| 7 | explanatory-output-style   | Internal | Output Styling        | Auto (SessionStart) | ⚠️ High (always active) | 8.0K     |
| 8 | learning-output-style      | Internal | Output Styling        | Auto (SessionStart) | ⚠️ High (always active) | 5.5K     |
| 9 | ralph-wiggum               | Internal | Output Styling        | Auto (SessionStart) | ⚠️ High (always active) | 10.0K    |
| 10 | agent-sdk-dev             | Internal | Development Tools     | `/new-sdk-app`    | ✓ Low (when invoked)     | 12.9K    |
| 11 | plugin-dev                | Internal | Development Tools     | Skills/commands   | ✓ Low (when invoked)     | 6.8K     |
| 12 | hookify                   | Internal | Development Tools     | `/hookify`        | ✓ Low (when invoked)     | 6.1K     |
| 13 | example-plugin            | Internal | Examples              | `/example-command` | ✓ Low (when invoked)    | <1K      |
| 14 | typescript-lsp            | LSP      | Language Server       | Auto (`.ts/.js` files) | Zero (idle)    | 15.0K    |
| 15 | pyright-lsp               | LSP      | Language Server       | Auto (`.py` files)     | Zero (idle)    | 8.7K     |
| 16 | gopls-lsp                 | LSP      | Language Server       | Auto (`.go` files)     | Zero (idle)    | 3.3K     |
| 17 | rust-analyzer-lsp         | LSP      | Language Server       | Auto (`.rs` files)     | Zero (idle)    | 2.8K     |
| 18 | csharp-lsp                | LSP      | Language Server       | Auto (`.cs` files)     | Zero (idle)    | 2.7K     |
| 19 | php-lsp                   | LSP      | Language Server       | Auto (`.php` files)    | Zero (idle)    | 2.4K     |
| 20 | jdtls-lsp                 | LSP      | Language Server       | Auto (`.java` files)   | Zero (idle)    | 2.4K     |
| 21 | clangd-lsp                | LSP      | Language Server       | Auto (`.c/.cpp` files) | Zero (idle)    | 2.0K     |
| 22 | swift-lsp                 | LSP      | Language Server       | Auto (`.swift` files)  | Zero (idle)    | 2.0K     |
| 23 | lua-lsp                   | LSP      | Language Server       | Auto (`.lua` files)    | Zero (idle)    | 1.3K     |
| 24 | context7                  | External | AI/Documentation      | MCP Tools         | Zero (idle)              | 51.3K    |
| 25 | github                    | External | Version Control       | MCP Tools         | Zero (idle)              | 30.5K    |
| 26 | serena                    | External | Code Analysis         | MCP Tools         | Zero (idle)              | 27.4K    |
| 27 | supabase                  | External | Backend/Database      | MCP Tools         | Zero (idle)              | 15.5K    |
| 28 | atlassian                 | External | Project Management    | MCP Tools         | Zero (idle)              | 14.7K    |
| 29 | playwright                | External | Testing               | MCP Tools         | Zero (idle)              | 13.1K    |
| 30 | figma                     | External | Design                | MCP Tools         | Zero (idle)              | 12.4K    |
| 31 | Notion                    | External | Productivity          | MCP Tools         | Zero (idle)              | 7.6K     |
| 32 | linear                    | External | Project Management    | MCP Tools         | Zero (idle)              | 6.4K     |
| 33 | laravel-boost             | External | Framework             | MCP Tools         | Zero (idle)              | 5.6K     |
| 34 | greptile                  | External | Code Search           | MCP Tools         | Zero (idle)              | 5.5K     |
| 35 | sentry                    | External | Error Monitoring      | MCP Tools         | Zero (idle)              | 4.9K     |
| 36 | vercel                    | External | Deployment            | MCP Tools         | Zero (idle)              | 4.1K     |
| 37 | gitlab                    | External | Version Control       | MCP Tools         | Zero (idle)              | 4.0K     |
| 38 | slack                     | External | Communication         | MCP Tools         | Zero (idle)              | 3.8K     |
| 39 | stripe                    | External | Payments              | MCP Tools         | Zero (idle)              | 2.2K     |
| 40 | firebase                  | External | Backend/Database      | MCP Tools         | Zero (idle)              | 2.1K     |
| 41 | asana                     | External | Project Management    | MCP Tools         | Zero (idle)              | 951      |

### Summary Statistics

| Type              | Count | Status                          |
|-------------------|-------|---------------------------------|
| Internal Plugins  | 13    | ✅ Documented (Sections 2-8)    |
| Language Servers  | 10    | ✅ Documented (Section 10)      |
| External Plugins  | 18    | ✅ Documented (Section 9)       |
| **Total**         | **41**| -                               |

---

*End of Claude Code Plugins Reference*
