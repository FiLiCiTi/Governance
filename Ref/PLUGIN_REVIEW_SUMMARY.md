# Plugin Review Summary - 2026-01-07

> **Plugins Reviewed:** 23 (13 Internal + 10 LSPs)
> **Reviewer:** Claude Sonnet 4.5
> **Duration:** 2026-01-07 session

---

## Table of Contents

| Section | Title                                               | Line   |
|---------|-----------------------------------------------------|--------|
| 1       | [Executive Summary](#1-executive-summary)           | :19    |
| 2       | [Review Findings by Category](#2-review-findings-by-category) | :52    |
| 3       | [Cost Analysis](#3-cost-analysis)                   | :143   |
| 4       | [Project-Specific Recommendations](#4-project-specific-recommendations) | :184   |
| 5       | [Critical Warnings](#5-critical-warnings)           | :232   |
| 6       | [Integration Patterns](#6-integration-patterns)     | :259   |
| 7       | [Next Steps](#7-next-steps)                         | :300   |

---

## 1. Executive Summary

### Plugins Reviewed (23 Total)

**Internal Plugins (13):**
- Development Workflows: feature-dev, code-review, pr-review-toolkit
- Git Operations: commit-commands
- Security: security-guidance
- Design: frontend-design
- Output Styling: explanatory-output-style, learning-output-style, ralph-wiggum
- Development Tools: agent-sdk-dev, plugin-dev, hookify

**LSP Plugins (10):**
- typescript-lsp, pyright-lsp, gopls-lsp, rust-analyzer-lsp, csharp-lsp, php-lsp, jdtls-lsp, clangd-lsp, swift-lsp, lua-lsp

### Key Findings

**Cost Distribution:**
- ✅ Zero Cost: 10 LSPs (local processing)
- ✓ Low Cost: 7 plugins (commit-commands, security-guidance, frontend-design, agent-sdk-dev, plugin-dev, hookify)
- ⚙️ Medium Cost: 3 plugins (feature-dev, code-review, pr-review-toolkit)
- 🔴 HIGH Cost: 3 plugins (explanatory-output-style, learning-output-style, ralph-wiggum)

**Critical Warnings:**
- Output styling plugins (3) add 1000+ tokens per session - use ONE maximum, temporarily only
- LSPs are zero-cost - install all relevant to your stack
- Medium-cost plugins justified for production work (feature-dev, code-review)

---

## 2. Review Findings by Category

### Development Workflows (3 plugins)

**feature-dev** - ⚙️ Medium Cost
- 7-phase workflow for feature development
- Includes code-explorer, code-architect, code-reviewer agents
- WHEN: Building complex features requiring architecture
- DON'T: Single-line fixes, trivial changes

**code-review** - ⚙️ Medium Cost
- 4 parallel agents for PR review
- Confidence scoring (80+ threshold)
- WHEN: After creating PR with /commit-push-pr
- DON'T: Before PR exists, on every small change

**pr-review-toolkit** - ⚙️ Medium Cost
- 6 specialized agents (comment-analyzer, pr-test-analyzer, silent-failure-hunter, type-design-analyzer, code-reviewer, code-simplifier)
- On-demand targeted analysis
- WHEN: Before creating PR, after PR feedback
- DON'T: On every commit

**Key Insight:** feature-dev Phase 6 = single feature review, /code-review = entire PR review (multiple features interaction)

### Git Operations (1 plugin)

**commit-commands** - ✓ Low Cost
- 3 commands: /commit, /commit-push-pr, /clean_gone
- Auto-generates commit messages, creates PRs
- Replaces 5-7 manual git commands with 1 slash command
- WHEN: All git workflows
- Always safe to use (low cost)

### Security (1 plugin)

**security-guidance** - ✓ Low Cost (always active)
- PreToolUse hook (non-blocking warnings)
- Covers 6/10 OWASP Top 10 categories
- Educational, proactive vulnerability prevention
- WHEN: Always active (install and forget)
- DON'T: Uninstall (educational benefit > minimal cost)

### Design (1 plugin)

**frontend-design** - ✓ Low Cost (when triggered)
- Automatic for frontend tasks
- Distinctive aesthetics, production-ready code
- WHEN: Frontend work (React, dashboards, landing pages)
- DON'T: Backend work (won't trigger)

**Value:** FILICITI/COEVOLVE = High, Governance = Low

### Output Styling (3 plugins) - 🔴 HIGH COST WARNING

**explanatory-output-style** - 🔴 +2K-5K tokens/session
- Educational insights about implementation choices
- WHEN: Learning new codebase (1-2 weeks max)
- DON'T: Production work, after familiar with codebase

**learning-output-style** - 🔴 +3K-8K tokens/session
- Interactive learning, requests code contributions (5-10 lines)
- WHEN: Learning by doing (1-2 weeks max)
- DON'T: Production work, tight deadlines

**ralph-wiggum** - 🔴 +50K-1M tokens per loop
- Iterative autonomous loops until task complete
- WHEN: Greenfield rapid prototyping (budget 100K-500K tokens)
- DON'T: Production debugging, unclear success criteria

**v2.5 Global Rules (§11-12):**
- Install ONE maximum
- NEVER multiple simultaneously
- Only when educational value justifies 2x-50x cost
- Remove immediately after learning phase

### Development Tools (3 plugins)

**agent-sdk-dev** - ✓ Low Cost
- Creates Agent SDK applications (Python/TypeScript)
- Command: /new-sdk-app
- WHEN: Building standalone AI agents

**plugin-dev** - ✓ Low Cost
- 7 specialized skills for plugin development
- Command: /plugin-dev:create-plugin
- WHEN: Building Claude Code plugins

**hookify** - ✓ Low Cost
- Create hooks via markdown config (regex patterns)
- Commands: /hookify, /hookify:list, /hookify:configure
- WHEN: Quick behavior prevention (no coding)

**Layered:** hookify (quick) → plugin-dev (comprehensive) → agent-sdk-dev (standalone)

### LSP Plugins (10 plugins) - Zero Cost

**All 10 LSPs:**
- typescript-lsp (15.0K installs) - TypeScript/JavaScript
- pyright-lsp (8.7K) - Python
- gopls-lsp (3.3K) - Go
- rust-analyzer-lsp (2.8K) - Rust
- csharp-lsp (2.7K) - C#
- php-lsp (2.4K) - PHP
- jdtls-lsp (2.4K) - Java
- clangd-lsp (2.0K) - C/C++
- swift-lsp (2.0K) - Swift
- lua-lsp (1.3K) - Lua

**Characteristics:**
- Zero cost (local processing, no API calls)
- Automatic activation when editing supported files
- Auto-suggested by Claude Code based on project

**Recommendation:** Install all LSPs for your tech stack (no downside)

---

## 3. Cost Analysis

### Cost Tiers

| Tier          | Plugins                                | Token Impact       | Installation Policy              |
|---------------|----------------------------------------|--------------------|----------------------------------|
| Zero (LSPs)   | 10 LSPs                                | 0 tokens           | Install all relevant to stack    |
| ✓ Low         | 7 (commit, security, design, dev tools)| <500 tokens        | Safe to keep installed           |
| ⚙️ Medium      | 3 (feature-dev, code-review, pr-review)| 5K-20K per use     | Use strategically, justified     |
| 🔴 HIGH        | 3 (output styling)                     | 2K-1M tokens       | ONE max, temporary only          |

### Cost Justification Matrix

| Plugin                    | Cost      | Justified When                                | NOT Justified                    |
|---------------------------|-----------|-----------------------------------------------|----------------------------------|
| feature-dev               | Medium    | Complex features, architectural decisions     | Single-line fixes, trivial tasks |
| code-review               | Medium    | All non-trivial PRs, pre-merge quality        | Before PR exists, urgent hotfixes|
| pr-review-toolkit         | Medium    | Before creating PR, high-stakes features      | On every commit, trivial changes |
| explanatory-output-style  | HIGH      | Learning new codebase (1-2 weeks)             | Production work, familiar codebase|
| learning-output-style     | HIGH      | Learning by doing (1-2 weeks)                 | Production work, tight deadlines |
| ralph-wiggum              | EXTREME   | Greenfield rapid prototyping (budget 100K+)   | Production debugging             |

### Session Cost Impact

**Typical session WITHOUT high-cost plugins:**
```
Base Claude:        15K tokens
+ LSPs:             0K (local)
+ Low-cost plugins: +1K
+ Medium plugins:   +10K (if invoked)
= Total:            26K tokens
```

**Session WITH high-cost plugin (explanatory-output-style):**
```
Base Claude:        15K tokens
+ explanatory:      +5K (SessionStart hook + output)
+ LSPs:             0K
+ Low-cost:         +1K
+ Medium:           +10K
= Total:            31K tokens (+19% increase)
```

**Session WITH ralph-loop (50 iterations):**
```
Single iteration:   15K tokens
× 50 iterations:    750K tokens
```

---

## 4. Project-Specific Recommendations

### FILICITI (React TypeScript Production App)

**MUST INSTALL:**
```
✓ typescript-lsp       - Zero cost, essential for TypeScript/React
✓ commit-commands      - Low cost, streamlines git workflow
✓ feature-dev          - Medium cost, justified for feature development
✓ code-review          - Medium cost, justified for PR quality
✓ frontend-design      - Low cost, automatic for React UI work
✓ security-guidance    - Low cost, automatic security warnings
```

**OPTIONAL:**
```
? pr-review-toolkit    - Use specific agents as needed
? hookify              - If custom safety rules needed
? vercel              - If deploying to Vercel
? sentry              - If error monitoring configured
```

**DON'T INSTALL:**
```
✗ explanatory-output-style - Production work = no educational overhead
✗ learning-output-style    - Production work = no interactive learning
✗ ralph-wiggum             - Production = controlled development
```

### COEVOLVE (React TypeScript Production App)

**Same as FILICITI** (both are React TypeScript production apps)

### Governance (Markdown Documentation)

**MUST INSTALL:**
```
✓ commit-commands      - Low cost, git workflow for .md files
```

**OPTIONAL:**
```
? hookify              - Enforce governance boundaries
                         Example: Block edits to /Volumes/, /etc/, v1_archive/
```

**DON'T INSTALL:**
```
✗ typescript-lsp           - No TypeScript files
✗ feature-dev              - No software features to build
✗ code-review              - No code to review
✗ frontend-design          - No frontend work
✗ security-guidance        - No code security concerns
✗ explanatory-output-style - No learning phase needed
✗ learning-output-style    - No coding skills to build
✗ ralph-wiggum             - No autonomous project building
```

---

## 5. Critical Warnings

### Output Styling Plugins (🔴 HIGH COST)

**From Global CLAUDE.md §11-12:**
```
§11. Avoid output styling plugins (explanatory-output-style, 
     learning-output-style, ralph-wiggum) unless absolutely 
     necessary. These add 1000+ tokens per session.

§12. Only install ONE at a time maximum.
```

**Installation Policy:**
```
✓ Install ONE maximum
✗ NEVER install multiple simultaneously
✓ Only when educational value justifies 2x-50x cost
✗ Don't leave installed if not actively using
✓ Remove immediately after learning phase (1-2 weeks)
```

**Cost Impact:**
- explanatory: +2K-5K tokens per session
- learning: +3K-8K tokens per session
- ralph-wiggum: +50K-1M tokens per loop

### Plugin Overuse Warnings

**DON'T over-invoke plugins:**
```
❌ WRONG:
/feature-dev Add auth → /commit → "Run pr-test-analyzer" → /commit → 
"Run code-simplifier" → /commit → /code-review

✅ CORRECT:
/feature-dev Add auth → /commit → /commit-push-pr → /code-review
```

**Explanation:** feature-dev Phase 6 already includes code review. Don't run redundant reviews.

---

## 6. Integration Patterns

### Recommended Daily Workflow

**For Code Projects (FILICITI/COEVOLVE):**
```
1. /feature-dev Build feature (Phases 1-7 including testing)
2. /commit (save progress, iterate as needed)
3. Repeat 1-2 for additional features
4. Optional: "Run pr-test-analyzer" (before PR if high-stakes)
5. /commit-push-pr (create PR)
6. /code-review (review entire PR)
7. Fix issues → /commit
8. Merge

Post-merge (if external plugins configured):
  → vercel: Auto-deploy
  → sentry: Monitor errors
```

**For Documentation Projects (Governance):**
```
1. Edit .md files
2. /commit (creates descriptive commit)
3. Repeat
4. /commit-push-pr (if PR needed)
```

### Plugin Combinations

**Complementary:**
```
✓ feature-dev + code-review           (single feature + entire PR)
✓ commit-commands + all workflows     (git automation)
✓ security-guidance + code-review     (proactive + reactive security)
✓ frontend-design + typescript-lsp    (distinctive UI + type safety)
✓ hookify + all workflows             (prevent mistakes)
```

**Redundant/Wasteful:**
```
❌ feature-dev Phase 6 + pr-test-analyzer immediately after
❌ code-review + pr-review-toolkit on same changes
❌ explanatory + learning simultaneously
```

---

## 7. Next Steps

### Immediate Actions

**1. Update V2.5_FULL_SPEC.md:**
- Add Section 15: Plugin Recommendations by Project
- Include cost-benefit analysis
- Reference this summary document

**2. Create per-project plugin recommendations:**
- FILICITI/.claude/recommended_plugins.md
- COEVOLVE/.claude/recommended_plugins.md
- Governance (this project) - document in V2.5

**3. Verify current installations:**
```bash
/plugin
# Check for:
- High-cost plugins installed (uninstall if not learning)
- Missing LSPs for tech stack (install)
- Redundant plugins (consolidate)
```

### v3 Roadmap Enhancements

Based on plugin review findings:

**v3 Features (from V2.5_FULL_SPEC.md §14 FAQ + this review):**

1. **Real-time plugin activity indicator** (§14.2)
   ```
   Current:  🟢 Hooks: 6 | 🟢 Context: ~15K
   Proposed: 🟢 Hooks: 6 | 🟢 Context: ~15K | 🔵 Active: frontend-design
   ```

2. **Per-plugin token tracking**
   - Show actual cost per plugin per session
   - Identify high-cost culprits
   - Recommend removals based on usage

3. **Auto-suggest plugin removals**
   - Detect high-cost plugins unused for X days
   - Suggest removal after learning phase complete
   - Warn when multiple high-cost plugins active

4. **Workflow automation suggestions**
   - Auto-detect when to use /feature-dev vs /code-review
   - Suggest plugins based on task description
   - Prevent redundant plugin invocations

5. **Session ↔ Plan ↔ Todo linking** (#G47)
   - Link session JSON to related plan files
   - Track todos across sessions
   - Persistent plugin recommendations per project

### Documentation Updates

**Created:**
- ✓ reviews/development_workflows_review.md
- ✓ reviews/git_operations_review.md
- ✓ reviews/security_review.md
- ✓ reviews/design_review.md
- ✓ reviews/output_styling_review.md
- ✓ reviews/development_tools_review.md
- ✓ reviews/lsp_plugins_review.md
- ✓ PLUGIN_REVIEW_SUMMARY.md (this file)

**To Update:**
- ⏳ V2.5_FULL_SPEC.md Section 15: Plugin Recommendations
- ⏳ FILICITI/.claude/recommended_plugins.md
- ⏳ COEVOLVE/.claude/recommended_plugins.md

---

## Appendix: Quick Reference

### Plugin Cost Quick Lookup

| Plugin                    | Cost      | Install Policy                |
|---------------------------|-----------|-------------------------------|
| All LSPs (10)             | Zero      | Install all for your stack    |
| commit-commands           | Low       | Always install                |
| security-guidance         | Low       | Always install                |
| frontend-design           | Low       | Install if frontend work      |
| agent-sdk-dev             | Low       | Install if building SDK apps  |
| plugin-dev                | Low       | Install if building plugins   |
| hookify                   | Low       | Install if custom rules needed|
| feature-dev               | Medium    | Install, use strategically    |
| code-review               | Medium    | Install, use on all PRs       |
| pr-review-toolkit         | Medium    | Install, use as needed        |
| explanatory-output-style  | HIGH      | DON'T install (production)    |
| learning-output-style     | HIGH      | DON'T install (production)    |
| ralph-wiggum              | EXTREME   | DON'T install (production)    |

### External Plugins Quick Reference

**For comprehensive external plugin documentation, see:**
- CLAUDE_PLUGINS_REFERENCE.md (lines 2400-3600)
- External plugins covered: greptile, notion, figma, vercel, sentry, linear, jira, slack, and more

**Most valuable external plugins for FILICITI/COEVOLVE:**
```
✓ greptile  - Large codebase search
✓ vercel    - Deploy to production
✓ sentry    - Monitor production errors
? figma     - If Figma designs exist
? linear    - If using Linear for PM
```

---

**End of Plugin Review Summary**

*Completed: 2026-01-07*
*Next: Update V2.5_FULL_SPEC.md with recommendations*
