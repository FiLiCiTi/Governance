# Plugin Selection Guide

> **Purpose:** Help you choose which Claude Code plugins to install based on cost, tech stack, and use case
> **Version:** 3.0
> **Updated:** 2026-01-06

---

## Table of Contents

| Section | Topic                                    |
|---------|------------------------------------------|
| 1       | Plugin Cost Categories                   |
| 2       | Installation Scopes (User/Project/Local) |
| 3       | Per-Tech-Stack Recommendations           |
| 4       | Common Use Cases                         |
| 5       | Plugin Discovery Workflow                |
| 6       | Cost Management Strategy                 |
| 7       | Quick Decision Tree                      |

---

## 1. Plugin Cost Categories

Claude Code plugins have different cost profiles based on when they consume tokens:

### 1.1 Cost Category Definitions

| Cost         | Symbol | Token Impact                | Count | When Active          |
|--------------|--------|-----------------------------|-------|----------------------|
| **Zero**     | -      | No cost when idle           | 28    | Only when invoked    |
| **Low**      | ✓      | Minimal (10-50 tokens)      | 5     | Small always-on cost |
| **Medium**   | ⚙️     | Multi-agent (500-2000 tokens)| 3     | Only when invoked    |
| **High**     | ⚠️     | Always active (1000+ tokens)| 3     | Every session        |

### 1.2 Zero Cost Plugins (28 total)

**Safe to install anytime** - Only consume tokens when actively used.

**Language Server Plugins (10):**
- typescript-lsp (TypeScript/JavaScript)
- pyright-lsp (Python)
- gopls-lsp (Go)
- rust-analyzer-lsp (Rust)
- csharp-lsp (C#)
- php-lsp (PHP)
- jdtls-lsp (Java)
- clangd-lsp (C/C++)
- swift-lsp (Swift)
- lua-lsp (Lua)

**External MCP Plugins (18):**
- context7 (AI documentation lookup)
- github (GitHub operations)
- serena (Serena AI assistant)
- supabase (Supabase integration)
- playwright (E2E testing)
- asana (Task management)
- firebase (Firebase integration)
- gitlab (GitLab operations)
- greptile (Code review)
- laravel-boost (Laravel tools)
- linear (Issue tracking)
- slack (Slack integration)
- stripe (Payment integration)
- atlassian (Jira/Confluence)
- figma (Design integration)
- notion (Notion integration)
- sentry (Error tracking)
- vercel (Deployment)

**Strategy:** Install all zero-cost plugins relevant to your stack. No downside.

### 1.3 Low Cost Plugins (5 total)

**Minimal always-on cost** (10-50 tokens per session)

| Plugin            | Type     | Purpose                         |
|-------------------|----------|---------------------------------|
| commit-commands   | Internal | Git workflow automation         |
| security-guidance | Internal | PreToolUse security checks      |
| hookify           | Internal | Hook creation via markdown      |
| plugin-dev        | Internal | Plugin development tools        |
| agent-sdk-dev     | Internal | Agent SDK development           |

**Strategy:** Install if you use the functionality regularly. Cost is minimal.

### 1.4 Medium Cost Plugins (3 total)

**Multi-agent workflows** (500-2000 tokens when invoked, zero when idle)

| Plugin          | Type     | When to Use                      |
|-----------------|----------|----------------------------------|
| feature-dev     | Internal | Building new features            |
| code-review     | Internal | Reviewing code before merge      |
| pr-review-toolkit | Internal | PR review automation           |

**Strategy:** Install but only invoke when needed. Don't run on every commit.

### 1.5 High Cost Plugins (3 total)

**Always active** (1000+ tokens per session, even if not invoked)

| Plugin                   | Type     | Impact                          |
|--------------------------|----------|---------------------------------|
| explanatory-output-style | Internal | Adds teaching explanations      |
| learning-output-style    | Internal | Interactive learning mode       |
| ralph-wiggum             | Internal | Self-referential loop technique |

**Strategy:** **Avoid unless absolutely necessary.** Only install ONE at a time max.

**Warning from SessionStart hook:**
```
⚠️  WARNING: 1 high-cost plugin(s) active (adds 1000+ tokens/session)
```

---

## 2. Installation Scopes

Claude Code offers three installation scopes:

### 2.1 Scope Definitions

| Scope     | Location                    | Visibility                     | Use When                        |
|-----------|-----------------------------|---------------------------------|---------------------------------|
| **User**  | `~/.claude/plugins/`        | Global to your Mac              | Everyday tools (LSPs, github)   |
| **Project** | Repo `.claude/` (committed) | Shared with team via git        | Team-standard tools             |
| **Local** | Repo `.claude/` (gitignored)| You only, this repo only        | Personal preferences, testing   |

### 2.2 Installation Strategy

**User Scope (Recommended for solo developers):**
- All LSPs for your languages (typescript-lsp, pyright-lsp, etc.)
- Universal tools (context7, github)
- Core workflows (commit-commands)

**Project Scope (Team collaboration):**
- Framework-specific tools (laravel-boost, playwright)
- Team-standard plugins (linear, slack)
- Shared workflows

**Local Scope (Testing/Personal):**
- Experimental plugins
- Personal workflow preferences
- Testing before promoting to User scope

**Solo Developer Tip:** Use **Local Scope** for flexibility. Once you find plugins you want everywhere, promote to **User Scope**.

### 2.3 Current Recommended Setup

**Your Current Setup (37 plugins installed):**
- ✅ 10 LSP plugins (User scope)
- ✅ 18 External plugins (Local scope)
- ✅ 9 Internal plugins (Local scope, excluding high-cost)
- ❌ 0 High-cost plugins

**Result:** Optimal balance - all useful plugins, zero high-cost bloat.

---

## 3. Per-Tech-Stack Recommendations

### 3.1 Next.js + FastAPI (FILICITI/COEVOLVE)

**Always Active (Zero Cost):**
- ✅ typescript-lsp (auto-activates for .ts/.tsx files)
- ✅ pyright-lsp (auto-activates for .py files)

**Install & Use On-Demand:**
- ✅ github (version control operations)
- ✅ context7 (AI documentation lookup)
- ⚙️ feature-dev (when building new features)
- ⚙️ code-review (before merging PRs)

**Optional (if using):**
- vercel (deployment to Vercel)
- supabase (if using Supabase backend)
- linear (if using Linear for issue tracking)

**File:** `~/Desktop/FILICITI/.claude/recommended_plugins.md`

### 3.2 React Native + PHP + Python (FlowInLife)

**Always Active (Zero Cost):**
- ✅ typescript-lsp (React + React Native)
- ✅ php-lsp (Swoole backend)
- ✅ pyright-lsp (YutaAI Python backend)

**Install & Use On-Demand:**
- ✅ github (version control)
- ✅ context7 (documentation)
- ⚙️ code-review (pre-merge review)

**Optional (if using):**
- playwright (E2E testing)
- firebase (if using Firebase)
- sentry (error tracking)

**File:** `~/Desktop/FlowInLife_env/.claude/recommended_plugins.md`

### 3.3 General Web Development

**Minimum Viable Stack:**
- typescript-lsp (JavaScript/TypeScript)
- github (version control)
- context7 (documentation)
- commit-commands (git workflow)

**Add Based on Backend:**
- Python → pyright-lsp
- PHP → php-lsp
- Go → gopls-lsp
- Rust → rust-analyzer-lsp
- C# → csharp-lsp
- Java → jdtls-lsp

### 3.4 Mobile Development

**React Native:**
- typescript-lsp (JavaScript/TypeScript)
- github (version control)
- Optional: firebase, sentry

**Swift (iOS):**
- swift-lsp
- github

---

## 4. Common Use Cases

### 4.1 "I'm building a new feature from scratch"

**Use:** `/feature-dev`

**What it does:**
- 7-phase development workflow
- Research → Plan → Implement → Review → Test → Document → Deploy
- 3 specialized agents (Researcher, Planner, Architect)

**Cost:** ⚙️ Medium (only when invoked)

**Alternative:** Manual implementation (no plugin)

### 4.2 "I want to review my code before committing"

**Use:** `/code-review`

**What it does:**
- 4 parallel review agents
- Code quality, security, performance, best practices
- Confidence scoring per suggestion

**Cost:** ⚙️ Medium (only when invoked)

**Alternative:** Manual review or `/commit` (low cost)

### 4.3 "I need to look up API documentation"

**Use:** `context7` plugin

**What it does:**
- AI-powered documentation search
- Provides MCP tools for doc lookup
- No slash command (invoke via natural language)

**Cost:** Zero (only when invoked)

**Example:** "Look up FastAPI dependency injection using context7"

### 4.4 "I want to create a git commit"

**Use:** `/commit`

**What it does:**
- Analyze staged changes
- Draft commit message
- Follow repository style
- Create commit with co-authored-by

**Cost:** ✓ Low

**Alternative:** Manual `git commit`

### 4.5 "I'm reviewing a GitHub PR"

**Use:** `github` plugin + `pr-review-toolkit`

**What it does:**
- Fetch PR details from GitHub
- 6 specialized review agents
- Post comments directly to PR

**Cost:**
- github: Zero (only when invoked)
- pr-review-toolkit: ⚙️ Medium (only when invoked)

### 4.6 "I want code to explain itself as it runs"

**Use:** `explanatory-output-style` plugin

**What it does:**
- Adds teaching explanations to all output
- Interactive educational mode

**Cost:** ⚠️ **HIGH (1000+ tokens per session)**

**Recommendation:** **Avoid** unless you're learning a new framework and need extra explanations. Uninstall after learning phase.

---

## 5. Plugin Discovery Workflow

### 5.1 How to Discover Available Plugins

**Step 1: Open Plugin Marketplace**
```bash
# In Claude Code:
# 1. Click "Discover plugins" tab
# 2. Browse 41 available plugins
```

**Step 2: Check Plugin Cost**
```bash
# Option A: Check CLAUDE_PLUGINS_REFERENCE.md
cat ~/Desktop/Governance/CLAUDE_PLUGINS_REFERENCE.md
# Search for plugin name
# Check "Cost" column in "Complete Plugin Inventory" table (line 3810+)

# Option B: Read plugin README
# Navigate to ~/.claude/plugins/marketplaces/claude-plugins-official/
# Read plugins/[plugin-name]/README.md or external_plugins/[plugin-name]/.claude-plugin/plugin.json
```

**Step 3: Check if Plugin Matches Your Tech Stack**
- LSPs → Install for every language you use
- External → Install if you use the service (github, linear, supabase, etc.)
- Internal → Install based on workflow needs (feature-dev, code-review, etc.)

**Step 4: Install in Appropriate Scope**
- Testing new plugin → Local scope
- Use daily → User scope
- Team collaboration → Project scope

**Step 5: Verify Installation**
```bash
# Check installed plugins
/plugin

# Check session output (SessionStart hook)
# Should show: "🔌 Plugins: 38 installed"
```

### 5.2 When NOT to Install a Plugin

**Don't install if:**
- ❌ High-cost plugin when you already have one installed
- ❌ Plugin for a service you don't use (e.g., supabase when using PostgreSQL directly)
- ❌ LSP for a language you don't write
- ❌ Duplicate functionality (e.g., both explanatory-output-style and learning-output-style)

**Example:**
- You use PostgreSQL directly → Don't install `supabase` plugin
- You use GitHub → Don't install `gitlab` plugin (unless you use both)

---

## 6. Cost Management Strategy

### 6.1 Install Strategy by Cost

| Cost Category | Strategy                                    |
|---------------|---------------------------------------------|
| Zero          | Install all relevant to your stack          |
| Low           | Install if you use the functionality        |
| Medium        | Install but invoke sparingly                |
| High          | **Avoid** - only 1 max, for specific needs |

### 6.2 Monitoring Plugin Cost

**SessionStart Hook Output:**
```bash
# Zero high-cost plugins (good):
📅 Date: 2026-01-06 | 🔌 Plugins: 37 installed

# High-cost plugin detected (warning):
⚠️  WARNING: 1 high-cost plugin(s) active (adds 1000+ tokens/session)
📅 Date: 2026-01-06 | 🔌 Plugins: 38 installed
```

**Action if warning appears:**
1. Run `/plugin` to see installed plugins
2. Identify high-cost plugin (explanatory-output-style, learning-output-style, ralph-wiggum)
3. Decide: Do I need this plugin right now?
4. If not: Uninstall via Claude Code UI

### 6.3 Token Budget Example

**Typical Session Token Budget:** ~10,000-50,000 tokens (depending on task)

**Plugin Impact:**

| Plugin Setup                  | Token Overhead  | % of Budget |
|-------------------------------|-----------------|-------------|
| 37 plugins (0 high-cost)      | ~100 tokens     | 0.2-1%      |
| 38 plugins (1 high-cost)      | ~1,100 tokens   | 2-11%       |
| 40 plugins (3 high-cost)      | ~3,100 tokens   | 6-31%       |

**Conclusion:** High-cost plugins can consume **6-31% of your token budget** before you even start working. Avoid them.

---

## 7. Quick Decision Tree

### "Should I install this plugin?"

```
START
  │
  ├─ Is it an LSP for a language I use?
  │  └─ YES → Install (User scope, zero cost)
  │  └─ NO → Continue
  │
  ├─ Is it external (github, supabase, linear, etc.)?
  │  └─ Do I use this service?
  │     └─ YES → Install (Local or User scope, zero cost)
  │     └─ NO → Don't install
  │
  ├─ Is it high-cost (output-style, ralph-wiggum)?
  │  └─ Do I absolutely need it right now?
  │     └─ YES → Install (max 1), uninstall when done
  │     └─ NO → Don't install
  │
  ├─ Is it medium-cost (feature-dev, code-review)?
  │  └─ Will I use this workflow regularly?
  │     └─ YES → Install (Local scope), invoke sparingly
  │     └─ NO → Don't install (use manual workflow)
  │
  └─ Is it low-cost (commit-commands, security-guidance)?
     └─ Do I use this functionality?
        └─ YES → Install (User scope)
        └─ NO → Don't install
```

---

## See Also

- [V2.5 Full Specification](~/Desktop/Governance/V2.5_FULL_SPEC.md)
- [CLAUDE_PLUGINS_REFERENCE.md](~/Desktop/Governance/CLAUDE_PLUGINS_REFERENCE.md) - Complete plugin documentation
- [Per-Product Setup Guide](~/Desktop/Governance/guides/per_product_setup.md)
- [Directory Reference](~/Desktop/Governance/CLAUDE_DIRECTORY_REFERENCE_v2.md)

---

**End of Plugin Selection Guide**

*Version: 3.0 | Updated: 2026-01-06*
