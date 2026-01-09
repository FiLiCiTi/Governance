# Development Workflows Plugins Review

> **Category:** Internal Plugins - Development Workflows
> **Count:** 3 plugins
> **Reviewed:** 2026-01-07
> **Cost:** ⚙️ Medium (when invoked)

---

## Table of Contents

| Section | Title                                      | Line   |
|---------|-------------------------------------------|--------|
| 1       | [Overview](#1-overview)                   | :19    |
| 2       | [feature-dev](#2-feature-dev)             | :32    |
| 3       | [code-review](#3-code-review)             | :112   |
| 4       | [pr-review-toolkit](#4-pr-review-toolkit) | :191   |
| 5       | [Comparison Matrix](#5-comparison-matrix) | :274   |
| 6       | [Integration](#6-integration)             | :302   |
| 7       | [Recommendations](#7-recommendations)     | :330   |

---

## 1. Overview

### Category Summary

Development Workflows plugins provide structured approaches to feature development and code review. All 3 plugins use specialized autonomous agents to perform deep analysis in parallel, ensuring quality and consistency.

| Plugin            | Primary Use Case          | Agents | Cost            | Installs |
|-------------------|---------------------------|--------|-----------------|----------|
| feature-dev       | New feature development   | 3      | ⚙️ Medium        | 27.0K    |
| code-review       | Automated PR review       | 4      | ⚙️ Medium        | 24.1K    |
| pr-review-toolkit | Specialized code analysis | 6      | ⚙️ Medium        | 12.6K    |

### Common Characteristics

- **Cost model:** Medium cost when invoked, zero cost when inactive
- **Execution:** Parallel agent launches for faster results
- **Confidence scoring:** All use thresholds to filter false positives
- **Quality focus:** Proactive bug prevention vs reactive debugging

---

## 2. feature-dev

### Purpose

Systematic 7-phase workflow for building new features with built-in exploration, architecture design, and quality review.

### 7-Phase Workflow

| Phase | Purpose                     | Details                                                    |
|-------|-----------------------------|------------------------------------------------------------|
| 1     | Discovery                   | Clarifies requirements, constraints, success criteria      |
| 2     | Codebase Exploration        | Launches 2-3 code-explorer agents to find patterns        |
| 3     | Clarifying Questions        | Identifies ambiguities, waits for answers                 |
| 4     | Architecture Design         | Launches 2-3 code-architect agents with different options |
| 5     | Implementation              | Builds feature following chosen architecture              |
| 6     | Quality Review              | Launches 3 code-reviewer agents                           |
| 7     | Summary                     | Documents decisions, next steps                           |

### Specialized Agents (3)

**code-explorer**
- **Purpose:** Deeply analyze existing codebase by tracing execution paths
- **Output:** Entry points, call chains, data flow, architecture insights
- **Triggered:** Phase 2 (automatic) or manual invocation

**code-architect**
- **Purpose:** Design feature architectures with multiple approaches
- **Output:** Pattern analysis, architecture decisions, component design, implementation map
- **Triggered:** Phase 4 (automatic) or manual invocation

**code-reviewer**
- **Purpose:** Review code for bugs, quality issues, project conventions
- **Output:** Critical/important issues with confidence scores ≥80, specific fixes with file:line
- **Triggered:** Phase 6 (automatic) or manual invocation

### When to Use

✅ **USE for:**
- Complex features touching multiple files
- Features requiring architectural decisions
- Integrating new technologies
- Major refactoring with structure
- Learning codebase patterns

❌ **DON'T USE for:**
- Single-line bug fixes
- Trivial changes
- Well-defined, simple tasks
- Urgent hotfixes (but consider Phase 6 after fixing)

### Key Features

- **Parallel execution:** Multiple agents run simultaneously
- **Interactive:** Waits for input at decision points
- **Flexible:** Can invoke individual agents outside workflow
- **Quality-first:** Phase 6 catches bugs before production
- **Context-aware:** Agents read identified files for deep understanding

### Invocation

```bash
# Full workflow
/feature-dev Add rate limiting to API endpoints with Redis backend

# Manual agent invocation
"Launch code-explorer to trace how authentication works"
"Launch code-architect to design the caching layer"
"Launch code-reviewer to check my recent changes"
```

### Configuration

No configuration needed. Intelligent defaults:
- Auto-determines agent count (2-3 per phase)
- Adapts exploration depth based on codebase size
- Confidence threshold: ≥80 for code review

### Best Practices

1. Be specific in feature requests
2. Answer Phase 3 questions thoughtfully
3. Read suggested files from Phase 2
4. Choose architecture deliberately in Phase 4
5. Don't skip code review (Phase 6)
6. Trust the process - each phase builds on previous

---

## 3. code-review

### Purpose

Automated pull request code review using 4 parallel agents with confidence-based scoring (threshold: 80) to filter false positives.

### Workflow (7 Steps)

| Step | Action                    | Details                                          |
|------|---------------------------|--------------------------------------------------|
| 1    | Check if review needed    | Skips closed, draft, trivial, already-reviewed   |
| 2    | Gather guidelines         | Reads CLAUDE.md files from repository            |
| 3    | Summarize PR changes      | Analyzes git diff and commit messages            |
| 4    | Launch 4 parallel agents  | Independent audits from different perspectives   |
| 5    | Score each issue 0-100    | Confidence-based scoring                         |
| 6    | Filter issues <80         | Removes false positives                          |
| 7    | Post review comment       | GitHub comment with high-confidence issues only  |

### Review Agents (4)

| Agent   | Focus                            | Purpose                                     |
|---------|----------------------------------|---------------------------------------------|
| Agent 1 | CLAUDE.md compliance             | Verifies changes follow project guidelines  |
| Agent 2 | CLAUDE.md compliance (redundant) | Second opinion on guideline compliance      |
| Agent 3 | Obvious bugs                     | Scans for bugs in changes only              |
| Agent 4 | Historical context               | Analyzes git blame/history for context      |

### Confidence Scoring

| Score   | Meaning                            | Action           |
|---------|------------------------------------|------------------|
| 0-24    | Not confident, false positive      | Filtered out     |
| 25-49   | Somewhat confident, might be real  | Filtered out     |
| 50-74   | Moderately confident, real/minor   | Filtered out     |
| 75-79   | Highly confident, real/important   | Filtered out     |
| 80-100  | Very confident, definitely real    | ✓ Included       |

### When to Use

✅ **USE for:**
- All PRs with meaningful changes
- PRs touching critical code paths
- PRs from multiple contributors
- PRs where guideline compliance matters

❌ **DON'T USE for:**
- Closed or draft PRs (auto-skipped)
- Trivial automated PRs (auto-skipped)
- Urgent hotfixes requiring immediate merge
- PRs already reviewed (auto-skipped)

### Key Features

- **4 independent agents:** Comprehensive coverage
- **Confidence filtering:** 80+ threshold reduces noise
- **CLAUDE.md aware:** Explicit guideline verification
- **Change-focused:** Only reviews new code, not pre-existing
- **Historical context:** Git blame analysis
- **Automatic skipping:** Smart PR detection
- **Direct code links:** GitHub permalinks with SHA + line ranges

### Invocation

```bash
# Basic usage
/code-review

# Typical workflow
git push origin feature-branch
/code-review
# Check GitHub PR for posted comment
# Address high-confidence issues
# Merge when ready
```

### Configuration

**Adjust threshold (default: 80):**
Edit `commands/code-review.md`:
```markdown
Filter out any issues with a score less than 80.
```

**Customize focus:**
Edit `commands/code-review.md` to add:
- Security-focused agents
- Performance analysis agents
- Accessibility checking agents

### Requirements

- Git repository with GitHub integration
- GitHub CLI (`gh`) installed and authenticated
- CLAUDE.md files (optional but recommended)

---

## 4. pr-review-toolkit

### Purpose

Collection of 6 specialized review agents covering code comments, test coverage, error handling, type design, code quality, and code simplification.

### 6 Specialized Agents

**1. comment-analyzer**
- **Focus:** Code comment accuracy and maintainability
- **Analyzes:** Comment accuracy vs code, documentation completeness, comment rot, misleading comments
- **Use when:** After adding documentation, before finalizing PRs with comments
- **Output:** High/Low confidence issue identification

**2. pr-test-analyzer**
- **Focus:** Test coverage quality and completeness
- **Analyzes:** Behavioral vs line coverage, critical gaps, test quality, edge cases
- **Use when:** After creating PR, when adding new functionality
- **Output:** Test gaps rated 1-10 (10 = critical)

**3. silent-failure-hunter**
- **Focus:** Error handling and silent failures
- **Analyzes:** Silent failures in catch blocks, inadequate error handling, missing logging
- **Use when:** After implementing error handling, reviewing try/catch blocks
- **Output:** Severity-based findings (Critical/High/Medium)

**4. type-design-analyzer**
- **Focus:** Type design quality and invariants
- **Analyzes:** Type encapsulation (1-10), invariant expression (1-10), type usefulness (1-10)
- **Use when:** Introducing new types, refactoring type designs
- **Output:** 4 dimensions rated 1-10

**5. code-reviewer**
- **Focus:** General code review for project guidelines
- **Analyzes:** CLAUDE.md compliance, style violations, bugs, code quality
- **Use when:** After writing/modifying code, before committing
- **Output:** Issues scored 0-100 (91-100 = critical)

**6. code-simplifier**
- **Focus:** Code simplification and refactoring
- **Analyzes:** Clarity, unnecessary complexity, redundant code, consistency, overly clever code
- **Use when:** After writing code, when code works but feels complex
- **Output:** Qualitative complexity identification + suggestions

### Invocation

**Automatic (by natural language):**
```
"Check if tests cover edge cases" → pr-test-analyzer
"Review error handling" → silent-failure-hunter
"Is documentation accurate?" → comment-analyzer
```

**Explicit parallel:**
```
"Run pr-test-analyzer and comment-analyzer in parallel"
```

**Proactive (Claude auto-triggers):**
- After writing code → code-reviewer
- After adding docs → comment-analyzer
- Before creating PR → Multiple agents
- After adding types → type-design-analyzer

### Recommended Workflow

| Phase                | Agents                                              | Purpose                    |
|----------------------|-----------------------------------------------------|----------------------------|
| Before Committing    | code-reviewer, silent-failure-hunter                | Quality + error safety     |
| Before Creating PR   | pr-test-analyzer, comment-analyzer, type-design-analyzer | Coverage + docs + types    |
| After Passing Review | code-simplifier                                     | Polish and maintainability |
| During PR Review     | Any agent for specific concerns                     | Address feedback           |

### Key Features

- **Specialized expertise:** Each agent = one quality dimension
- **Confidence scoring:** All provide confidence/severity scores
- **Structured output:** Clear file:line references
- **Prioritized findings:** Sorted by severity/importance
- **Actionable:** Not just problems, but solutions
- **On-demand:** Individual or combined as needed

---

## 5. Comparison Matrix

### When to Use Which Plugin

| Scenario                              | Plugin              | Reason                                          |
|---------------------------------------|---------------------|-------------------------------------------------|
| Building new complex feature          | feature-dev         | Full 7-phase workflow with architecture design  |
| Creating PR ready for review          | code-review         | Automated 4-agent PR audit with GitHub posting  |
| Checking test coverage before PR      | pr-review-toolkit   | Use pr-test-analyzer for targeted test review   |
| Reviewing error handling              | pr-review-toolkit   | Use silent-failure-hunter for error analysis    |
| Validating documentation accuracy     | pr-review-toolkit   | Use comment-analyzer for doc verification       |
| General code quality check            | pr-review-toolkit   | Use code-reviewer for quality audit             |
| Simplifying complex code              | pr-review-toolkit   | Use code-simplifier for refactoring suggestions |
| Exploring existing codebase           | feature-dev         | Use code-explorer agent (Phase 2 or manual)     |
| Designing feature architecture        | feature-dev         | Use code-architect agent (Phase 4 or manual)    |
| CLAUDE.md compliance check            | code-review         | 2 of 4 agents focus on guideline compliance     |

### Agent Overlap Analysis

| Agent Name      | feature-dev | code-review | pr-review-toolkit | Scope Difference                           |
|-----------------|-------------|-------------|-------------------|--------------------------------------------|
| code-reviewer   | ✓ (Phase 6) | -           | ✓ (Agent 5)       | Same agent, reused across plugins          |
| code-explorer   | ✓ (Phase 2) | -           | -                 | Unique to feature-dev                      |
| code-architect  | ✓ (Phase 4) | -           | -                 | Unique to feature-dev                      |
| Compliance chk  | -           | ✓ (Agents 1,2)| ✓ (code-reviewer) | code-review = dedicated agents             |
| Bug detection   | ✓ (Phase 6) | ✓ (Agent 3) | ✓ (code-reviewer) | All include bug scanning                   |
| Test analyzer   | -           | -           | ✓                 | Unique to pr-review-toolkit                |
| Error handling  | -           | -           | ✓                 | Unique to pr-review-toolkit                |
| Type design     | -           | -           | ✓                 | Unique to pr-review-toolkit                |

---

## 6. Integration

### With Governance System

**Cost tracking:**
- All 3 plugins = Medium cost when invoked
- Zero cost when inactive
- SessionStart hook displays plugin count: "🔌 Plugins: 37 installed"

**Workflow integration:**
- feature-dev → Phases 1-7 for structured development
- code-review → Pre-PR automated quality gate
- pr-review-toolkit → On-demand targeted analysis

**CLAUDE.md integration:**
- code-review explicitly checks CLAUDE.md compliance (2 agents)
- pr-review-toolkit code-reviewer checks CLAUDE.md
- feature-dev code-reviewer (Phase 6) checks CLAUDE.md

### Recommended Plugin Stack

**For Feature Development Projects (COEVOLVE, FILICITI):**
```
✓ feature-dev          - Structured feature development
✓ code-review          - Automated PR review
✓ pr-review-toolkit    - Specialized on-demand analysis
✓ commit-commands      - Clean git workflow
```

**For Documentation/Governance Projects:**
```
✓ pr-review-toolkit    - Use comment-analyzer only
? code-review          - Only if PRs are created
✗ feature-dev          - Overkill for docs-only work
```

---

## 7. Recommendations

### Best Practices

1. **Sequential workflow:**
   ```
   /feature-dev → implement → /code-review → PR created
   ```

2. **Use pr-review-toolkit for targeted concerns:**
   - Don't run all 6 agents every time
   - Pick 1-2 agents based on current concern
   - Run comprehensive suite only before major PRs

3. **Trust confidence scores:**
   - code-review threshold: 80+
   - feature-dev code-reviewer: 80+
   - Don't lower thresholds to get more issues (increases noise)

4. **Maintain CLAUDE.md files:**
   - Better guidelines = better automated compliance checking
   - Document project-specific conventions
   - Update based on recurring review patterns

5. **Leverage parallel execution:**
   - feature-dev automatically parallelizes agents
   - code-review runs 4 agents simultaneously
   - pr-review-toolkit can run multiple agents in parallel when requested

### Cost Optimization

**Medium-cost plugins = use strategically:**
- ✓ Use /feature-dev for complex features (worth the cost)
- ✓ Use /code-review for all non-trivial PRs (prevents costly bugs)
- ✓ Use pr-review-toolkit agents selectively (targeted analysis)
- ✗ Don't run all tools on every small change

**Plugin selection by project phase:**
- **Early development:** feature-dev (exploration + architecture)
- **Active development:** pr-review-toolkit (targeted checks)
- **PR time:** code-review (comprehensive automated review)

### Integration with v2.5 Governance

**Plugin awareness (v2.5 §11-12):**
- All 3 plugins flagged as Medium cost
- Avoid running multiple workflows simultaneously
- Use ONE workflow plugin at a time maximum

**Status line tracking:**
- SessionStart shows plugin count
- No per-plugin cost tracking yet (potential v3 feature)
- Manual tracking via session logs

**Future enhancements (v3 candidate):**
- Auto-detect when to use /feature-dev vs /code-review
- Track actual plugin usage per session
- Cost analysis per project
- Workflow automation based on session state

---

## Summary

| Plugin            | Best For                       | Agents | Auto-trigger | GitHub Integration |
|-------------------|--------------------------------|--------|--------------|-------------------|
| feature-dev       | New feature development        | 3      | No           | No                |
| code-review       | Automated PR review            | 4      | No           | Yes (posts comment) |
| pr-review-toolkit | Targeted quality analysis      | 6      | Yes (proactive) | No                |

**Key Insight:** All 3 plugins complement each other:
- **feature-dev** = Build it right (architecture + implementation)
- **code-review** = Verify it's right (automated PR audit)
- **pr-review-toolkit** = Refine it right (targeted quality improvements)

---

*Review completed: 2026-01-07*
*Reviewer: Claude Sonnet 4.5*
*Source: CLAUDE_PLUGINS_REFERENCE.md (lines 110-559)*
