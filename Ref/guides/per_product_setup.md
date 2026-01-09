# Per-Product Setup Guide

> **Purpose:** Guide to setting up governance for different products in the FILICITI ecosystem
> **Version:** 3.0
> **Updated:** 2026-01-06

---

## Table of Contents

| Section | Topic                                    |
|---------|------------------------------------------|
| 1       | Understanding Product vs Project vs Global |
| 2       | FILICITI/COEVOLVE Setup                  |
| 3       | FlowInLife Setup                         |
| 4       | FILICITI_LABS Setup                      |
| 5       | New Product Onboarding Checklist         |
| 6       | Troubleshooting                          |

---

## 1. Understanding Product vs Project vs Global

### 1.1 Three-Layer Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│  GLOBAL LAYER (~/.claude/)                                   │
│  - Applies to ALL projects on this Mac                      │
│  - CLAUDE.md Layer 3: Universal rules                       │
│  - All installed plugins (37 currently)                     │
│  - Global settings.json (hook configuration)                │
└─────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  PRODUCT LAYER (~/Desktop/FILICITI/.claude/)                │
│  - Applies to all projects within this product              │
│  - Optional CLAUDE.md Layer 2: Product-level rules          │
│  - recommended_plugins.md (NEW in v2.5)                       │
│  - Product-specific workflows                               │
└─────────────────────────────────────────────────────────────┘
                            ▼
┌─────────────────────────────────────────────────────────────┐
│  PROJECT LAYER (~/Desktop/FILICITI/code/CLAUDE.md)          │
│  - Applies to this specific project only                    │
│  - CLAUDE.md Layer 1: Project boundaries (CAN/CANNOT)       │
│  - Conversation history (if using per-project conversations)│
│  - Project-specific overrides                               │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 When to Use Each Layer

| Layer    | Use When                                      | Example                           |
|----------|-----------------------------------------------|-----------------------------------|
| Global   | Rule applies everywhere                       | Date format, table formatting     |
| Product  | Rule applies across product repos             | Product architecture, tech stack  |
| Project  | Rule applies to single project/repo           | CAN/CANNOT modify boundaries      |

### 1.3 Layer Priority (Highest to Lowest)

1. **Project CLAUDE.md** (most specific)
2. **Product CLAUDE.md** (if exists)
3. **Global CLAUDE.md** (universal)
4. **Hook-injected context** (SessionStart)
5. **Claude Code system prompt**

**Conflict Resolution:** More specific layer wins (Project > Product > Global)

---

## 2. FILICITI/COEVOLVE Setup

### 2.1 Product Overview

| Property      | Value                                        |
|---------------|----------------------------------------------|
| **Product**   | FILICITI/COEVOLVE                            |
| **Type**      | AI workflow automation platform              |
| **Structure** | Monorepo (frontend + backend in same repo)   |
| **Tech Stack**| Next.js 13 + FastAPI (Python 3.13)           |
| **Database**  | PostgreSQL 15, Redis                         |
| **Deployment**| Docker Compose (3 containers)                |

### 2.2 Folder Structure

```
~/Desktop/FILICITI/
├── _Governance/ → ~/Desktop/Governance/    ← Symlink
├── Products/
│   └── COEVOLVE/
│       ├── code/                           ← Git repo
│       │   ├── CLAUDE.md                   ← Project Layer 1
│       │   ├── backend/                    ← FastAPI
│       │   ├── frontend/                   ← Next.js
│       │   ├── docker-compose.yml
│       │   └── README.md
│       ├── businessplan/                   ← Markdown docs
│       └── _governance/                    ← Private governance
└── .claude/                                ← NEW in v2.5
    └── recommended_plugins.md              ← Product plugin guide
```

### 2.3 Setup Steps

**Step 1: Create Product `.claude/` Folder**

```bash
mkdir -p ~/Desktop/FILICITI/.claude
```

**Step 2: Create `recommended_plugins.md`**

```bash
# File: ~/Desktop/FILICITI/.claude/recommended_plugins.md
```

**Content:**
```markdown
# FILICITI/COEVOLVE Recommended Plugins

## Always Active (Zero Cost)
- typescript-lsp (auto-activates for .ts/.tsx files)
- pyright-lsp (auto-activates for .py files)

## Install & Use On-Demand
- github (version control operations)
- context7 (AI documentation lookup)
- feature-dev (when building new features)
- code-review (before merging PRs)

## Tech Stack-Specific
- Next.js: Already supported via typescript-lsp
- FastAPI: Already supported via pyright-lsp
- PostgreSQL: No plugin needed (use Bash for psql)
- Docker: No plugin needed (use Bash for docker commands)

## See Also
- [Plugin Selection Guide](~/Desktop/Governance/guides/plugin_selection.md)
```

**Step 3: Verify Plugin Installation**

```bash
# Check installed plugins
/plugin

# Should have (at minimum):
# - typescript-lsp
# - pyright-lsp
# - github
# - context7
```

**Step 4: Update Project CLAUDE.md (Optional)**

```bash
# File: ~/Desktop/FILICITI/Products/COEVOLVE/code/CLAUDE.md
```

**Add reference to product plugins:**
```markdown
## Links

- Product plugins: `~/Desktop/FILICITI/.claude/recommended_plugins.md`
- Governance: `~/Desktop/Governance/`
```

### 2.4 Typical Workflow (FILICITI)

**Daily Development:**
1. Start session: `cc` → SessionStart shows "🔌 Plugins: 37 installed"
2. Work on feature: typescript-lsp + pyright-lsp auto-activate
3. Use context7 for API docs: "Look up FastAPI dependency injection"
4. Build feature: `/feature-dev` (medium cost, only when needed)
5. Review code: `/code-review` (medium cost, before merge)
6. Commit: `/commit` (low cost)
7. Push: `git push`

**Plugin Usage:**
- LSPs: Always active (zero cost when idle)
- github: On-demand for PR operations
- context7: On-demand for doc lookup
- feature-dev: Only for new features (not every commit)
- code-review: Only before merge (not every file change)

---

## 3. FlowInLife Setup

### 3.1 Product Overview

| Property      | Value                                        |
|---------------|----------------------------------------------|
| **Product**   | FlowInLife                                   |
| **Type**      | Production SaaS (journaling + AI)            |
| **Structure** | Monorepo (web + mobile)                      |
| **Tech Stack**| React 18.3, React Native 0.77, PHP, Python   |
| **Database**  | MySQL, Redis, OpenSearch                     |
| **Deployment**| Docker Compose + PM2                         |

### 3.2 Folder Structure

```
~/Desktop/FlowInLife_env/
├── CLAUDE.md                               ← Project Layer 1
├── FlowInLifeApp/                          ← Main codebase
│   ├── frontend/                           ← React web app
│   ├── mobile/                             ← React Native
│   ├── api/                                ← PHP/Swoole backend
│   ├── yutaai/                             ← Python/Flask AI
│   ├── package.json
│   └── docker-compose.yml
└── .claude/                                ← NEW in v2.5
    └── recommended_plugins.md              ← Product plugin guide
```

### 3.3 Setup Steps

**Step 1: Create Product `.claude/` Folder**

```bash
mkdir -p ~/Desktop/FlowInLife_env/.claude
```

**Step 2: Create `recommended_plugins.md`**

```bash
# File: ~/Desktop/FlowInLife_env/.claude/recommended_plugins.md
```

**Content:**
```markdown
# FlowInLife Recommended Plugins

## Always Active (Zero Cost)
- typescript-lsp (React + React Native)
- php-lsp (Swoole backend)
- pyright-lsp (YutaAI Python backend)

## Install & Use On-Demand
- github (version control)
- context7 (documentation)
- code-review (pre-merge review)

## Tech Stack-Specific
- React Native: Already supported via typescript-lsp
- PHP/Swoole: Already supported via php-lsp
- MySQL: No plugin needed (use Bash)

## Optional (if using)
- playwright (E2E testing)
- firebase (if using Firebase)
- sentry (error tracking)

## See Also
- [Plugin Selection Guide](~/Desktop/Governance/guides/plugin_selection.md)
```

**Step 3: Verify Plugin Installation**

```bash
# Check installed plugins
/plugin

# Should have (at minimum):
# - typescript-lsp
# - php-lsp
# - pyright-lsp
# - github
# - context7
```

**Step 4: Update Project CLAUDE.md (Optional)**

```bash
# File: ~/Desktop/FlowInLife_env/CLAUDE.md
```

**Add reference to product plugins:**
```markdown
## Links

- Product plugins: `~/Desktop/FlowInLife_env/.claude/recommended_plugins.md`
- Governance: `~/Desktop/Governance/`
```

### 3.4 Typical Workflow (FlowInLife)

**Daily Development:**
1. Start session: `cc` → SessionStart shows plugins
2. Work on frontend: typescript-lsp auto-activates
3. Work on backend: php-lsp auto-activates
4. Work on YutaAI: pyright-lsp auto-activates
5. Review code: `/code-review` (before merge)
6. Commit: `/commit`

**Plugin Usage:**
- LSPs: Always active for all 3 languages (TypeScript, PHP, Python)
- github: On-demand for PR operations
- context7: On-demand for doc lookup (React Native APIs, PHP APIs)

---

## 4. FILICITI_LABS Setup

### 4.1 Product Overview

| Property      | Value                                        |
|---------------|----------------------------------------------|
| **Product**   | FILICITI_LABS                                |
| **Type**      | R&D / Experimental projects                  |
| **Structure** | Multiple independent projects                |
| **Projects**  | 2 (COEVOLVE technical + businessplan)        |

### 4.2 Folder Structure

```
~/Desktop/FILICITI_LABS/
├── CLAUDE.md                               ← Root index
├── COEVOLVE/                               ← Technical project
│   ├── backend/                            ← FastAPI
│   ├── frontend/                           ← Next.js
│   └── CLAUDE.md                           ← Project Layer 1
└── COEVOLVE_businessplan/                  ← Business/GTM project
    ├── 01_Strategy/
    ├── 02_Research/
    └── CLAUDE.md                           ← Project Layer 1
```

### 4.3 Setup Strategy

**Option A: Share FILICITI Plugin Recommendations**

COEVOLVE technical project uses same stack as FILICITI/COEVOLVE.

**Setup:**
```bash
# No new setup needed
# Refer to ~/Desktop/FILICITI/.claude/recommended_plugins.md
```

**Option B: Create Labs-Specific Recommendations (Optional)**

If Labs has unique requirements:

```bash
mkdir -p ~/Desktop/FILICITI_LABS/.claude
# Create recommended_plugins.md with Labs-specific tools
```

**Recommended Approach:** Use Option A (share FILICITI recommendations). Labs is experimental, keep it simple.

### 4.4 Businessplan Project

**Tech Stack:** Markdown only (no code)

**Required Plugins:** None

**Recommended Plugins:**
- github (version control for markdown)
- commit-commands (git workflow)

**No LSPs needed** - just text editing.

---

## 5. New Product Onboarding Checklist

Use this checklist when setting up governance for a brand new product.

### 5.1 Pre-Setup Questions

**Answer these questions first:**

| Question                          | Answer                                  |
|-----------------------------------|-----------------------------------------|
| What's the product name?          | _________________                       |
| What's the tech stack?            | Frontend: _______ Backend: ______       |
| Is it a monorepo or multi-repo?   | Monorepo / Multi-repo                   |
| What databases/services are used? | _________________                       |
| Will this be team collaboration?  | Yes / No (solo)                         |

### 5.2 Setup Checklist

**Step 1: Identify Tech Stack**

- [ ] Frontend framework (React, Next.js, Vue, etc.)
- [ ] Backend language (Python, PHP, Go, Rust, etc.)
- [ ] Database (PostgreSQL, MySQL, MongoDB, etc.)
- [ ] Other services (Redis, OpenSearch, etc.)

**Step 2: Determine Required LSPs**

Match your tech stack to LSPs:

| Tech Stack     | LSP Plugin         |
|----------------|--------------------|
| TypeScript/JS  | typescript-lsp     |
| Python         | pyright-lsp        |
| PHP            | php-lsp            |
| Go             | gopls-lsp          |
| Rust           | rust-analyzer-lsp  |
| C#             | csharp-lsp         |
| Java           | jdtls-lsp          |
| C/C++          | clangd-lsp         |
| Swift          | swift-lsp          |
| Lua            | lua-lsp            |

- [ ] Install required LSPs (User scope)

**Step 3: Create Product `.claude/` Folder**

```bash
mkdir -p ~/Desktop/[PRODUCT_NAME]/.claude
```

- [ ] Folder created

**Step 4: Create `recommended_plugins.md`**

Template:

```markdown
# [PRODUCT_NAME] Recommended Plugins

## Always Active (Zero Cost)
- [lsp-name] (auto-activates for .[ext] files)
- [lsp-name] (auto-activates for .[ext] files)

## Install & Use On-Demand
- github (version control operations)
- context7 (AI documentation lookup)
- feature-dev (when building new features)
- code-review (before merging PRs)

## Tech Stack-Specific
- [Framework]: Already supported via [lsp-name]
- [Framework]: Already supported via [lsp-name]

## Optional (if using)
- [service-plugin] (if using [service])

## See Also
- [Plugin Selection Guide](~/Desktop/Governance/guides/plugin_selection.md)
```

- [ ] File created: `~/Desktop/[PRODUCT_NAME]/.claude/recommended_plugins.md`

**Step 5: Verify Plugin Installation**

```bash
/plugin
```

- [ ] All required LSPs installed
- [ ] github installed
- [ ] context7 installed
- [ ] Zero high-cost plugins

**Step 6: Update Project CLAUDE.md (Optional)**

Add reference to product plugins:

```markdown
## Links

- Product plugins: `~/Desktop/[PRODUCT_NAME]/.claude/recommended_plugins.md`
- Governance: `~/Desktop/Governance/`
```

- [ ] CLAUDE.md updated

**Step 7: Test Session Start**

```bash
cc
# Should show: "🔌 Plugins: [count] installed"
```

- [ ] SessionStart shows plugin count
- [ ] No high-cost plugin warnings
- [ ] Date and boundaries displayed correctly

**Step 8: Document Product in Directory Reference (Optional)**

Update `~/Desktop/Governance/CLAUDE_DIRECTORY_REFERENCE_v2.md` with new product structure.

- [ ] Directory reference updated (optional)

### 5.3 Validation Checklist

After setup, verify:

- [ ] ✅ All LSPs for tech stack installed
- [ ] ✅ recommended_plugins.md created
- [ ] ✅ No high-cost plugins installed
- [ ] ✅ SessionStart shows plugin count
- [ ] ✅ Project CLAUDE.md references product plugins (optional)
- [ ] ✅ Plugin installation scope chosen (User/Local)

---

## 6. Troubleshooting

### 6.1 "LSP not activating for my files"

**Problem:** typescript-lsp not working for .ts files

**Check:**
1. Is the plugin installed? → `/plugin`
2. Is the file extension correct? → typescript-lsp works for .ts, .tsx, .js, .jsx
3. Is there a language server binary? → `which typescript-language-server`

**Solution:**
```bash
# Install TypeScript language server globally
npm install -g typescript-language-server typescript

# Restart Claude Code session
```

### 6.2 "SessionStart not showing plugin count"

**Problem:** SessionStart hook doesn't show "🔌 Plugins: 37 installed"

**Check:**
1. Is the hook updated? → Read `~/Desktop/Governance/hooks/inject_context.sh`
2. Does lines 50-70 exist with plugin tracking?

**Solution:**
- Update hook with plugin tracking code (see V2.5_FULL_SPEC.md Section 5.2)
- Restart session

### 6.3 "High-cost plugin warning appearing"

**Problem:** `⚠️  WARNING: 1 high-cost plugin(s) active`

**Check:**
```bash
/plugin
# Look for: explanatory-output-style, learning-output-style, ralph-wiggum
```

**Solution:**
- Uninstall high-cost plugin via Claude Code UI
- Only keep 1 max if absolutely needed

### 6.4 "Can't find recommended_plugins.md"

**Problem:** Product `.claude/` folder doesn't exist

**Check:**
```bash
ls ~/Desktop/[PRODUCT_NAME]/.claude/
```

**Solution:**
```bash
# Create folder
mkdir -p ~/Desktop/[PRODUCT_NAME]/.claude

# Create recommended_plugins.md using template from Section 5.2
```

### 6.5 "Don't know which plugins to install"

**Problem:** Unsure which plugins match my tech stack

**Solution:**
1. Read `~/Desktop/Governance/guides/plugin_selection.md` Section 3 (Per-Tech-Stack Recommendations)
2. Consult `~/Desktop/Governance/CLAUDE_PLUGINS_REFERENCE.md` Section 11 (Complete Plugin Inventory)
3. Use decision tree in plugin_selection.md Section 7

---

## See Also

- [V2.5 Full Specification](~/Desktop/Governance/V2.5_FULL_SPEC.md)
- [Plugin Selection Guide](~/Desktop/Governance/guides/plugin_selection.md)
- [Migration v2 → v2.5](~/Desktop/Governance/guides/migration_v2_to_v2.5.md)
- [CLAUDE_PLUGINS_REFERENCE.md](~/Desktop/Governance/CLAUDE_PLUGINS_REFERENCE.md)
- [Directory Reference](~/Desktop/Governance/CLAUDE_DIRECTORY_REFERENCE_v2.md)

---

**End of Per-Product Setup Guide**

*Version: 3.0 | Updated: 2026-01-06*
