# Claude Directory Reference

> **v3.2 Governance Reference** | Updated: 2026-01-06

---

## Table of Contents

| Section | Title                                                                          | Line   |
|---------|--------------------------------------------------------------------------------|--------|
| 1       | [Overview](#1-overview)                                                        | :44    |
| 2       | [Global Directory (`~/.claude/`)](#2-global-directory-claude)                  | :57    |
| 2.1     | [Structure Tree](#21-structure-tree)                                           | :59    |
| 2.2     | [Folders & Files (global ~/.claude/)](#22-folders--files)                     | :167   |
| 2.2.A   | [Part A: User-Managed](#part-a-user-managed-components)                        | :171   |
| 2.2.B   | [Part B: Claude Internal](#part-b-claude-code-internal-components)             | :199   |
| 2.3     | [Internal/Hidden Files](#23-internalhidden-files)                              | :245   |
| 3       | [Project Directory (`<project>/.claude/`)](#3-project-directory-projectclaude) | :255   |
| 3.1     | [Structure Tree](#31-structure-tree)                                           | :257   |
| 3.2     | [Files](#32-files)                                                             | :384   |
| 3.3     | [Also: Project Root `CLAUDE.md`](#33-also-project-root-claudemd)               | :391   |
| 4       | [Schema Reference](#4-schema-reference)                                        | :399   |
| 4.A     | [Part A: User-Managed](#part-a-user-managed-components-1)                      | :403   |
| 4.B     | [Part B: Claude Internal](#part-b-claude-code-internal-components-1)           | :696   |
| 5       | [File Access Sequences](#5-file-access-sequences)                              | :893   |
| 5.1     | [Session Start](#51-session-start)                                             | :904   |
| 5.2     | [During Session (Normal Mode)](#52-during-session-normal-mode)                 | :972   |
| 5.3     | [During Session (Plan Mode)](#53-during-session-plan-mode)                     | :1043  |
| 5.4     | [Todo Operations](#54-todo-operations)                                         | :1098  |
| 5.5     | [Session End / Stop](#55-session-end--stop)                                    | :1128  |
| 5.6     | [Compact Operation](#56-compact-operation)                                     | :1195  |
| 5.7     | [Global ↔ Project Interaction](#57-global--project-interaction)                | :1225  |
| 6       | [Governance Integration](#6-governance-integration)                            | :1316  |
| 6.1     | [Hook Execution Flow](#61-hook-execution-flow)                                 | :1318  |
| 6.2     | [Session Tracking Flow](#62-session-tracking-flow)                             | :1354  |
| 6.3     | [File Linking Solutions](#63-file-linking-solutions)                           | :1376  |
| 6.4     | [What Claude Reads vs YOUR Logs](#64-what-claude-reads-vs-your-logs)           | :1620  |
| 7       | [Quick Reference](#7-quick-reference)                                          | :1647  |
| 8       | [Implementation Checklist](#8-implementation-checklist)                        | :1692  |
| 9       | [Document Changelog](#9-document-changelog)                                    | :1846  |

---

## 1. Overview

Claude Code uses two `.claude/` directories:

| Scope   | Path                    | Purpose                              |
|---------|-------------------------|--------------------------------------|
| Global  | `~/.claude/`            | User-wide settings, history, plugins |
| Project | `<project>/.claude/`    | Project-specific overrides           |

**Precedence:** Project settings override global settings.

##############################################################################################################

## 2. Global Directory (`~/.claude/`)

### 2.1 Structure Tree

```
~/.claude/
│
├── # ─────────────── CONFIG FILES ─────────────── #
├── CLAUDE.md                         # User instructions (markdown)
├── settings.json                     # Global settings & hooks (json)
├── settings.local.json               # Local overrides (json)
├── .credentials.json                 # Auth credentials (json, hidden)
│
├── # ─────────────── STATE FILES ──────────────── #
├── history.jsonl                     # Command history (jsonl)
├── stats-cache.json                  # Usage statistics (json)
├── todo_state.json                   # Global todo state (json)
├── loop_state.json                   # Loop detection state (json)
├── hook_status                       # Hook execution status (json)
├── last_tool_name                    # Last tool called (text)
├── last_tool_time                    # Last tool timestamp (text)
│
├── # ─────────────── FOLDERS ──────────────────── #
│
├── audit/                            # Tool use auditing
│   └── tool_use.log                      # *.log
│
├── debug/                            # Debug logs per session
│   ├── {uuid}.txt                        # *.txt (debug output)
│   └── latest                            # symlink to current
│
├── downloads/                        # Downloaded files
│                                         # 📂 EMPTY
│
├── file-history/                     # File version history
│   └── {uuid}/                           # Per-session folder
│       └── {hash}@v{n}                   # File versions (no ext)
│
├── plans/                            # Plan mode documents
│   └── {adjective-verb-noun}.md          # *.md (plan files)
│
├── plugins/                          # Plugin system
│   ├── installed_plugins.json            # *.json
│   ├── known_marketplaces.json           # *.json
│   └── marketplaces/
│       └── claude-plugins-official/
│           ├── README.md
│           ├── plugins/
│           │   └── {plugin-name}/
│           │       ├── README.md
│           │       ├── .claude-plugin/
│           │       │   └── plugin.json
│           │       ├── commands/
│           │       │   └── *.md
│           │       ├── skills/
│           │       │   └── {skill}/
│           │       │       └── SKILL.md
│           │       ├── agents/
│           │       │   └── *.md
│           │       └── hooks/
│           │           └── hooks.json
│           └── external_plugins/
│
├── projects/                         # Per-project settings cache
│   └── {-path-encoded}/                  # e.g., -Users-mohammadshehata-Desktop-...
│       └── {uuid}.jsonl                  # *.jsonl (project history)
│
├── session-env/                      # Session environment snapshots
│   └── {uuid}/                           # Per-session folder
│                                         # (env data)
│
├── sessions/                         # Session state (governance)
│   ├── {hash}_session.json               # Session metadata (json)
│   └── {hash}_todo.json                  # Session todos (json)
│
├── shell-snapshots/                  # Shell state snapshots
│   └── snapshot-{shell}-{ts}-{id}.sh     # *.sh (shell scripts)
│
├── statsig/                          # Statsig telemetry
│   ├── statsig.cached.evaluations.*      # Feature flags cache
│   ├── statsig.failed_logs.*             # Failed log uploads
│   ├── statsig.last_modified_time.*      # Timestamp tracking
│   ├── statsig.session_id.*              # Current session ID
│   └── statsig.stable_id.*               # Persistent user ID
│
├── telemetry/                        # Telemetry data
│                                         # 📂 EMPTY
│
├── templates/                        # User templates
│                                         # 📂 EMPTY
│
└── todos/                            # Per-session todo files
    └── {uuid}-agent-{uuid}.json          # *.json (agent todos)
```

**Legend:**
- `📂 EMPTY` - Folder exists but has no files

**Unique file types:**

| Extension   | Purpose                    | Locations                          |
|-------------|----------------------------|------------------------------------|
| `.json`     | Config, state, metadata    | Root, sessions/, todos/, plugins/  |
| `.jsonl`    | Append-only logs           | Root (history), projects/          |
| `.md`       | Instructions, plans, docs  | Root, plans/, plugins/             |
| `.txt`      | Debug logs                 | debug/                             |
| `.log`      | Audit logs                 | audit/                             |
| `.sh`       | Shell snapshots            | shell-snapshots/                   |
| (no ext)    | File versions, symlinks    | file-history/, debug/latest        |


##############################################################################################################

### 2.2 Folders & Files by Function (in global ~/.claude/)

**See also:** [Section 4: Schema Reference](#4-schema-reference) for detailed file formats.

#### Part A: User-Managed Components

Components the user can read, write, or configure directly.

##### A.1 Configuration

| #     | Item                  | Type   | Purpose                          | Read By      | Written By   |
|-------|-----------------------|--------|----------------------------------|--------------|--------------|
| A.1.1 | CLAUDE.md             | File   | Global user instructions         | Claude       | User         |
| A.1.2 | settings.json         | File   | Permissions, hooks, model        | Claude,Hooks | User         |
| A.1.3 | settings.local.json   | File   | Local overrides (not committed)  | Claude       | User         |

##### A.2 Content & Templates

| #     | Item                  | Type   | Purpose                          | Read By      | Written By   |
|-------|-----------------------|--------|----------------------------------|--------------|--------------|
| A.2.1 | templates/            | Folder | User-defined templates           | Claude       | User         |
| A.2.2 | plugins/              | Folder | Plugin marketplace & installed   | Claude       | Claude       |
| A.2.3 | plans/                | Folder | Plan mode documents              | Claude,User  | Claude       |

##### A.3 Session Management (Hook-Managed)

| #     | Item                  | Type   | Purpose                          | Read By      | Written By   |
|-------|-----------------------|--------|----------------------------------|--------------|--------------|
| A.3.1 | sessions/             | Folder | Per-session metadata & todos     | Claude,Hooks | Hooks        |
| A.3.2 | todos/                | Folder | Per-agent todo files             | Claude       | Claude       |
| A.3.3 | todo_state.json       | File   | Global todo list state           | Claude       | Claude       |

#### Part B: Claude Code Internal Components

Managed by Claude Code binary. Read-only for user (informational).

##### B.1 Session Storage

| #     | Item                  | Type   | Purpose                          | Read By      | Written By   |
|-------|-----------------------|--------|----------------------------------|--------------|--------------|
| B.1.1 | projects/             | Folder | Per-project session JSONL data   | Claude       | Claude       |
| B.1.2 | session-env/          | Folder | Session environment snapshots    | Claude       | Claude       |

##### B.2 History & Statistics

| #     | Item                  | Type   | Purpose                          | Read By      | Written By   |
|-------|-----------------------|--------|----------------------------------|--------------|--------------|
| B.2.1 | history.jsonl         | File   | Command history (all sessions)   | Claude       | Claude       |
| B.2.2 | stats-cache.json      | File   | Usage statistics cache           | Claude       | Claude       |
| B.2.3 | file-history/         | Folder | File version history             | Claude       | Claude       |
| B.2.4 | shell-snapshots/      | Folder | Shell state snapshots            | Claude       | Claude       |

##### B.3 Hook State

| #     | Item                  | Type   | Purpose                          | Read By      | Written By   |
|-------|-----------------------|--------|----------------------------------|--------------|--------------|
| B.3.1 | loop_state.json       | File   | Loop detection tracking          | Hooks        | Hooks        |
| B.3.2 | hook_status           | File   | Current hook execution status    | Hooks        | Hooks        |
| B.3.3 | last_tool_name        | File   | Name of last tool called         | Hooks        | Hooks        |
| B.3.4 | last_tool_time        | File   | Unix timestamp of last tool      | Hooks        | Hooks        |

##### B.4 Debugging & Telemetry

| #     | Item                  | Type   | Purpose                          | Read By      | Written By   |
|-------|-----------------------|--------|----------------------------------|--------------|--------------|
| B.4.1 | debug/                | Folder | Debug logs per session           | User,Claude  | Claude       |
| B.4.2 | audit/                | Folder | Tool use auditing                | User,Hooks   | Hooks        |
| B.4.3 | statsig/              | Folder | Feature flags & telemetry        | Claude       | Claude       |
| B.4.4 | telemetry/            | Folder | Telemetry data                   | Claude       | Claude       |

##### B.5 Downloads

| #     | Item                  | Type   | Purpose                          | Read By      | Written By   |
|-------|-----------------------|--------|----------------------------------|--------------|--------------|
| B.5.1 | downloads/            | Folder | Downloaded files                 | User,Claude  | Claude       |

**Note:** `.credentials.json` (hidden file, API authentication) is managed entirely by Claude Code and not listed above.

### 2.3 Internal/Hidden Files

| File/Location                        | Purpose                     | Visible |
|--------------------------------------|-----------------------------|---------|
| Binary conversation state            | Full conversation history   | No      |
| `~/.claude/.credentials.json`        | Auth tokens                 | Hidden  |
| `statsig/statsig.*`                  | Feature flags, session IDs  | Yes     |

##############################################################################################################

## 3. Project Directory (`<project>/.claude/`)

### 3.1 Structure Tree

```
# ═══════════════════════════════════════════════════════════════
# PROJECT: COEVOLVE (inside FILICITI)
# Path: ~/Desktop/FILICITI/Products/COEVOLVE/
# ═══════════════════════════════════════════════════════════════

~/Desktop/FILICITI/Products/COEVOLVE/
│
├── # ─────────────── CLAUDE CONFIG ─────────────── #
├── CLAUDE.md                                        # 460 bytes
│
├── # ─────────────── GOVERNANCE DATA ────────────── #
├── _governance/ $$$ are we missing .git for wraper
│   ├── 20260104_COEVOLVE_migration_sync.md
│   ├── businessplan/
│   │   └── Conversations/
│   │       └── *.log, *_TS.log
│   └── code/
│       └── Conversations/
│           └── *.log, *_TS.log, *.md
│
├── # ─────────────── SUBPROJECTS ────────────────── #
│
├── businessplan/
│   ├── # ─────── CONFIG ─────── #
│   ├── CLAUDE.md -> ../_governance/businessplan/CLAUDE.md   # symlink
│   ├── .gitignore
│   ├── # ─────── CONTENT ────── #
│   ├── 01_Strategy/
│   ├── 02_Research/
│   ├── 03_Awareness/
│   ├── 04_Convert/
│   ├── 05_Deliver/
│   ├── 06_Operations/
│   ├── 07_Grow/
│   ├── 08_Templates/
│   ├── 09_Meeting_Notes/
│   └── Archive/
│
└── code/
    ├── # ─────── CONFIG ─────── #
    ├── CLAUDE.md -> ../_governance/code/CLAUDE.md           # symlink
    ├── .env.example
    ├── .gitignore
    ├── docker-compose.yml
    ├── .claude/
    │   └── settings.local.json
    ├── # ─────── SCRIPTS ────── #
    ├── bootstrap.sh
    ├── dev.sh
    ├── reset.sh
    ├── # ─────── DOCS ───────── #
    ├── README.md
    ├── docs/
    ├── # ─────── SOURCE ─────── #
    ├── .git/
    ├── backend/
    └── frontend/


# ═══════════════════════════════════════════════════════════════
# PROJECT: Governance
# Path: ~/Desktop/Governance/
# ═══════════════════════════════════════════════════════════════

~/Desktop/Governance/
│
├── # ─────────────── CLAUDE CONFIG ─────────────── #
├── CLAUDE.md                                        # 449 bytes
├── .claude/
│   ├── CLAUDE_CODE_GUIDE.md
│   ├── ISSUES_LOG.md
│   └── settings.local.json
│
├── # ─────────────── VERSION CONTROL ────────────── #
├── .git/                                            # ⚠️ MISSING
│
├── # ─────────────── DOCUMENTATION ──────────────── #
├── CLAUDE_CODE_DOCS.md
├── CLAUDE_DIRECTORY_REFERENCE.md
├── Claude-Code-Documentation-Map.md
├── Claude-Code-Governance-Guide-v2.md
├── GOVERNANCE_V1_VS_V2.md
├── V2_FULL_SPEC.md
│
├── # ─────────────── GOVERNANCE TOOLS ───────────── #
├── bin/
│   └── cc                                           # wrapper script
├── hooks/
│   ├── check_boundaries.sh
│   ├── check_warmup.sh
│   ├── detect_loop.sh
│   ├── inject_context.sh
│   ├── log_tool_use.sh
│   └── save_session.sh
├── scripts/
│   ├── check_protocol.sh
│   └── suggest_model.sh
├── templates/
│   ├── L3_GLOBAL.md
│   ├── TEMPLATE_BIZZ.md
│   ├── TEMPLATE_CODE.md
│   ├── TEMPLATE_OPS.md
│   └── TEMPLATE_ROOT.md
│
├── # ─────────────── SESSION DATA ───────────────── #
├── Conversations/
│   └── *.log, *_TS.log
│
├── # ─────────────── ISSUE TRACKING ─────────────── #
├── issues/                                          # 📂 EMPTY
│
├── # ─────────────── ARCHIVE ────────────────────── #
└── v1_archive/
```

**Legend:**
- `⚠️ MISSING` - Should exist per v2 spec but doesn't
- `📂 EMPTY` - Folder exists but has no files

**Note on Conversations/:**
- Written by `cc` wrapper and hooks (YOUR logs)
- Claude Code does NOT read these folders
- For your reference only

### 3.2 Files

| File                  | Purpose                           | Owner  |
|-----------------------|-----------------------------------|--------|
| `settings.local.json` | Project permission overrides      | User   |
| Custom `.md` files    | Project-specific documentation    | User   |

### 3.3 Also: Project Root `CLAUDE.md`

| File                   | Purpose                          | Owner  |
|------------------------|----------------------------------|--------|
| `<project>/CLAUDE.md`  | Project instructions (Layer 2)   | User   |


##############################################################################################################

## 4. Schema Reference

**See also:** [Section 5: File Access Sequences](#5-file-access-sequences) for when these files are created/updated.

#### Part A: User-Managed Components

User can read, write, and configure these components. Governance hooks may manage some files.

##### A.1 Configuration

###### A.1.1 settings.json

```json
{
  "permissions": {
    "allow": [
      "Read(**)",
      "Bash(git:*)",
      "Edit(/path/to/project/**)"
    ],
    "deny": [
      "Edit(/Volumes/**)",
      "Bash(rm -rf:*)"
    ],
    "defaultMode": "dontAsk"
  },
  "model": "opus",
  "hooks": {
    "SessionStart": [{"hooks": [{"type": "command", "command": "..."}]}],
    "PreToolUse": [{"matcher": "Edit|Write", "hooks": [...]}],
    "PostToolUse": [{"matcher": ".*", "hooks": [...]}],
    "Stop": [{"hooks": [...]}],
    "SessionEnd": [{"hooks": [...]}]
  },
  "statusLine": {
    "type": "command",
    "command": "/path/to/status_script.sh"
  },
  "alwaysThinkingEnabled": true
}
```

##### A.2 Content & Templates

###### A.2.1 templates/

**Purpose:** User-defined templates for Claude Code
**Status:** 📂 EMPTY - Reserved for future use
**Owner:** User
**Access:** `<via: claude>` reads, User creates

**Current Structure (Empty):**
```
templates/
└── (no files yet)
```

**Future Structure (Speculative):**
```
templates/
├── project-templates/                  # Full project scaffolding
│   ├── react-app/
│   │   ├── template.json              # Metadata (name, description, files)
│   │   ├── CLAUDE.md                  # Project instructions template
│   │   ├── package.json               # Package template
│   │   ├── .gitignore                 # Git ignore template
│   │   └── src/                       # Source folder structure
│   └── python-cli/
│       └── ...
└── file-templates/                     # Individual file templates
    ├── CLAUDE_PROJECT.md              # Project-level CLAUDE.md template
    ├── CLAUDE_GLOBAL.md               # Global CLAUDE.md template
    ├── hook.sh                        # Hook script template
    └── README.md                      # README template
```

**Future Usage (Speculative):**

| Command | Purpose | Example |
|---------|---------|---------|
| `claude init --template <name>` | Initialize project from template | `claude init --template react-app` |
| `/init <name>` | Shorthand for init command | `/init python-cli` |
| `claude generate <file> --template <name>` | Generate single file | `claude generate CLAUDE.md --template project` |

**Global vs Project-Local Templates:**

| Location | Scope | Purpose | Precedence |
|----------|-------|---------|------------|
| `~/.claude/templates/` | **Global** | Company-wide, shareable templates | Lower |
| `<project>/.claude/templates/` | **Project** | Project-specific overrides | Higher |

**Precedence Rules:**

1. **Project-local overrides global:** If same template name exists in both locations, project-local wins
2. **Extend vs Override:** Currently undefined - likely full replacement (override)
3. **Fallback:** If template only in global, use global; if only in project, use project

**Example Scenario:**

```
# Global template
~/.claude/templates/project-templates/web-app/
└── CLAUDE.md  → "Standard web app instructions"

# Project override
~/Desktop/MyProject/.claude/templates/project-templates/web-app/
└── CLAUDE.md  → "Custom instructions for MyProject"

# Result when running: claude init --template web-app
→ Uses ~/Desktop/MyProject/.claude/templates/.../CLAUDE.md (project wins)
```

**Comparison with Governance Templates:**

Your `~/Desktop/Governance/templates/` folder contains **governance-specific** templates (not Claude Code templates):

```
~/Desktop/Governance/templates/
├── L3_GLOBAL.md          # Layer 3 global instructions
├── TEMPLATE_BIZZ.md      # Business project CLAUDE.md template
├── TEMPLATE_CODE.md      # Code project CLAUDE.md template
├── TEMPLATE_OPS.md       # Operations project CLAUDE.md template
└── TEMPLATE_ROOT.md      # Root-level CLAUDE.md template
```

These work within **your governance system**, not via `claude init`. They're manually copied/referenced when creating new projects.

**Current Status:**
- ❌ No built-in template system yet
- ❌ `claude init --template` not implemented
- ✅ Can manually create template files for future use
- ✅ Plugins can read templates/ folder for custom workflows

###### A.2.2 plugins/

**Purpose:** Installed Claude Code plugins
**Status:** Marketplace configured, **no plugins installed**
**Owner:** Claude Code
**Access:** `<via: claude>` reads/writes

**See also:** [CLAUDE_PLUGINS_REFERENCE.md](./CLAUDE_PLUGINS_REFERENCE.md) for comprehensive documentation of all 13 internal plugins.

**Current Structure:**
```
plugins/
├── installed_plugins.json          # Plugin registry (empty)
├── known_marketplaces.json         # Marketplace sources
└── marketplaces/
    └── claude-plugins-official/    # Official Anthropic plugin marketplace
        ├── .claude-plugin/
        ├── plugins/                # 23 internal plugins
        │   ├── feature-dev/
        │   ├── commit-commands/
        │   ├── code-review/
        │   ├── typescript-lsp/
        │   └── ...
        └── external_plugins/       # 13 external plugins
            ├── github/
            ├── stripe/
            └── ...
```

**Current Installation Status:**

```json
// installed_plugins.json
{
  "version": 2,
  "plugins": {}  // ← NO PLUGINS INSTALLED
}
```

```json
// known_marketplaces.json
{
  "claude-plugins-official": {
    "source": {"source": "github", "repo": "anthropics/claude-plugins-official"},
    "installLocation": "~/.claude/plugins/marketplaces/claude-plugins-official",
    "lastUpdated": "2026-01-06T12:56:58.493Z"
  }
}
```

**Available Plugins (36 total):**

**Internal Plugins (23 - Anthropic-maintained):**

| Category | Plugins | Description |
|----------|---------|-------------|
| **Development Workflows** | `feature-dev`, `code-review`, `pr-review-toolkit` | Full 7-phase feature workflow, automated PR reviews |
| **Git Operations** | `commit-commands` | Auto-generated commit messages, push, PR creation |
| **Language Servers** | `typescript-lsp`, `pyright-lsp`, `gopls-lsp`, `rust-analyzer-lsp`, `clangd-lsp`, `csharp-lsp`, `jdtls-lsp`, `php-lsp`, `lua-lsp`, `swift-lsp` | LSP integrations for 10 languages |
| **Output Styling** | `explanatory-output-style`, `learning-output-style`, `ralph-wiggum` | Customize Claude's response format |
| **Development Tools** | `agent-sdk-dev`, `plugin-dev`, `hookify` | Build custom agents, plugins, and hooks |
| **Security** | `security-guidance` | Security review automation |
| **Design** | `frontend-design` | UI/UX development workflows |
| **Example** | `example-plugin` | Reference implementation |

**External Plugins (13 - Community/Partners):**

| Category | Plugins | Description |
|----------|---------|-------------|
| **Project Management** | `asana`, `linear` | Task tracking integration |
| **Version Control** | `github`, `gitlab` | Enhanced Git platform features |
| **Communication** | `slack` | Team notifications |
| **Development Services** | `firebase`, `supabase`, `stripe`, `laravel-boost` | Platform-specific integrations |
| **Testing** | `playwright` | E2E testing workflows |
| **AI Tools** | `context7`, `greptile`, `serena` | Code analysis and search |

**⭐ Featured Plugin: `feature-dev`**

**7-Phase Development Workflow:**

| Phase | Purpose | What Happens |
|-------|---------|--------------|
| 1. Discovery | Understand requirements | Clarifies feature request, identifies constraints |
| 2. Exploration | Analyze codebase | Launches 2-3 `code-explorer` agents to trace similar features |
| 3. Questions | Resolve ambiguities | Asks clarifying questions before design |
| 4. Architecture | Design approaches | Launches 2-3 `code-architect` agents for different approaches |
| 5. Implementation | Build the feature | Implements chosen architecture with progress tracking |
| 6. Review | Quality assurance | Launches 3 `code-reviewer` agents (bugs, style, conventions) |
| 7. Summary | Document completion | Summarizes changes, decisions, and next steps |

**Specialized Agents:**
- `code-explorer`: Traces execution flows, analyzes architecture
- `code-architect`: Designs implementation blueprints
- `code-reviewer`: Reviews for bugs, quality, conventions (confidence-based filtering ≥80%)

**Usage:** `/feature-dev Add user authentication`

**Plugin Standard Structure:**

```
{plugin-name}/
├── .claude-plugin/
│   └── plugin.json              # Plugin metadata (required)
├── .mcp.json                    # MCP server configuration (optional)
├── commands/                    # Slash commands (optional)
│   └── example-command.md
├── agents/                      # Agent definitions (optional)
│   └── code-reviewer.md
├── skills/                      # Skill definitions (optional)
│   └── example-skill/
│       └── SKILL.md
├── hooks/                       # Hook configurations (optional)
│   └── hooks.json
└── README.md                    # Documentation
```

**Plugin Capabilities:**

| Capability | File | Description |
|------------|------|-------------|
| **Commands** | `commands/*.md` | Slash commands like `/commit`, `/review` |
| **Skills** | `skills/*/SKILL.md` | Complex multi-step workflows |
| **Agents** | `agents/*.md` | Specialized sub-agents for tasks |
| **Hooks** | `hooks/hooks.json` | Event-driven automations |
| **MCP Servers** | `.mcp.json` | External tool integrations |

**Installation:**

```bash
# Via CLI
claude plugin install feature-dev@claude-plugins-official

# Via slash command (in session)
/plugin install feature-dev
```

**Plugin vs Skill vs MCP Server:**

| Type | Purpose | Location | Example |
|------|---------|----------|---------|
| **Plugin** | Package that extends Claude Code | `~/.claude/plugins/{id}/` | `feature-dev`, `commit-commands` |
| **Skill** | Pre-packaged workflow (can be in plugin) | Plugin's `skills/` folder | `/commit`, `/review-pr` |
| **MCP Server** | External tool integration | Referenced by plugin `.mcp.json` | Filesystem, database, API access |

**Note:** Built-in skills (like those shown in system prompt) are **not plugins** - they're compiled into Claude Code. Plugins can add **additional** skills.

**Marketplace Source:**

- **GitHub Repository:** [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official)
- **Auto-updated:** Marketplace syncs periodically
- **Last synced:** 2026-01-06 12:56 UTC

###### B.4.1 statsig/ + telemetry/

**Purpose:** Feature flags and anonymous metrics
**Owner:** Claude Code
**Access:** `<via: claude>` reads/writes

**statsig/** (ACTIVE):
- Feature flags configuration
- Session tracking data
- Anonymous usage metrics

**telemetry/** (EMPTY):
- Reserved for additional telemetry data

#### Part B: Claude Code Internal Components

Managed by Claude Code binary. Read-only for user (informational).

##### B.1 Session Storage
###### B.1.1 projects/

**Purpose:** Per-project session storage and cache
**Owner:** Claude Code
**Access:** `<via: claude>` reads/writes

**Structure:**
```
projects/
└── {-path-encoded}/                # Encoded project directory path
    ├── {uuid}.jsonl                # Main session conversation (1KB - 10MB)
    ├── agent-{id}.jsonl            # Sub-agent task session (1-200KB)
    └── {uuid}/                     # Session-specific folder (optional)
        └── tool-results/
            └── toolu_{id}.txt      # Cached large tool outputs
```

**Path encoding:**
- Algorithm: Replace `/` with `-`, prepend `-` to absolute paths
- Example: `/Users/mohammadshehata/Desktop/Governance` → `-Users-mohammadshehata-Desktop-Governance`
- Purpose: Flat folder structure for filesystem compatibility

**File Types:**

| File Pattern       | Purpose                        | Size Range  | Created When                |
|--------------------|--------------------------------|-------------|-----------------------------|
| `{uuid}.jsonl`     | Main session conversation      | 1KB - 10MB  | Every interactive session   |
| `agent-{id}.jsonl` | Sub-agent task (Explore/Plan)  | 1KB - 200KB | Task tool launches agent    |
| `{uuid}/`          | Session-specific subfolder     | N/A         | Large tool outputs cached   |
| `tool-results/*.txt` | Cached tool outputs          | Varies      | Read/Bash output > threshold |

**JSONL Format:**

Each line is a JSON event with parent-child tracking:

```jsonl
{"type":"summary","summary":"Session title","leafUuid":"..."}
{"type":"file-history-snapshot","messageId":"...","snapshot":{...}}
{"parentUuid":null,"type":"user","message":{"role":"user","content":"help"},"uuid":"msg-1","sessionId":"ab9c185f..."}
{"parentUuid":"msg-1","type":"assistant","message":{"role":"assistant","content":[{"type":"thinking","thinking":"..."}]},"uuid":"msg-2"}
{"parentUuid":"msg-2","type":"assistant","message":{"content":[{"type":"tool_use","id":"toolu_01Abc","name":"Read"}]},"uuid":"msg-3"}
{"parentUuid":"msg-3","type":"user","message":{"content":[{"tool_use_id":"toolu_01Abc","type":"tool_result","content":"..."}]},"uuid":"msg-4"}
```

**Key Fields:**

| Field          | Purpose                                    | Example                                    |
|----------------|--------------------------------------------|--------------------------------------------|
| `uuid`         | Unique message identifier                  | `"84abff6a-5176-41f5-9d96-1fafd3ebc005"`   |
| `parentUuid`   | Points to previous message (builds chain)  | `"6fe095ff-b7a8-4eab-a0c1-8cba5f2a6e7c"`   |
| `sessionId`    | Links agent back to main session           | `"ab9c185f-065c-439c-9b7d-3260e83ae023"`   |
| `isSidechain`  | `false` for agents, `true` for main        | `false`                                    |
| `type`         | Message type                               | `"user"`, `"assistant"`, `"tool_result"`   |
| `timestamp`    | ISO 8601 timestamp                         | `"2026-01-06T13:00:10.968Z"`               |
| `cwd`          | Working directory when message sent        | `"/Users/.../Desktop/Governance"`          |

**Agent ↔ Main Session Tracking:**

```jsonl
// Main session (ab9c185f-065c-439c-9b7d-3260e83ae023.jsonl)
{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Task","input":{"subagent_type":"Explore"}}]}}

// Agent session (agent-a230cc4.jsonl)
{
  "sessionId": "ab9c185f-065c-439c-9b7d-3260e83ae023",  // ← Links back to main
  "isSidechain": false,
  "parentUuid": "dc5c491a-3d5d-40a0-92c3-b7a63c9d08ec",  // ← Parent in main session
  "type": "assistant",
  "message": {...}
}
```

**Tool Results Tracking:**

```jsonl
// Tool use
{"type":"assistant","content":[{"type":"tool_use","id":"toolu_01QryVZsNe63J6gRXt9SSFkN","name":"Read"}]}

// Small result (inline)
{"type":"user","content":[{"tool_use_id":"toolu_01QryVZsNe63J6gRXt9SSFkN","type":"tool_result","content":"file contents..."}]}

// Large result (cached to file)
{"type":"user","content":[{"tool_use_id":"toolu_01QryVZsNe63J6gRXt9SSFkN","type":"tool_result","content":"[Cached to tool-results/toolu_01QryVZsNe63J6gRXt9SSFkN.txt]"}]}
```

**When Created:**

1. **Session start:** Claude Code encodes working directory path
2. **First message:** Creates `{uuid}.jsonl` for main session
3. **Agent launch:** Creates `agent-{id}.jsonl` linked via `sessionId`
4. **Large tool output:** Creates `{uuid}/tool-results/` subfolder + cache files

**Size Analysis:**

- **Small sessions (1-10KB):** Brief interactions, few tool calls
- **Medium sessions (100KB-1MB):** Typical development session
- **Large sessions (5-10MB):** Long conversations, many file reads
- **Agent sessions (1-5KB):** Quick tasks, minimal back-and-forth

**Storage Notes:**

- All sessions in same working directory share one encoded folder
- JSONL format allows streaming reads (line-by-line processing)
- Parent-child chain enables conversation replay
- Agent sessions are independent JSONL files, linked via `sessionId`

###### B.4.2 session-env/

**Purpose:** Session environment snapshots
**Owner:** Claude Code
**Access:** `<via: claude>` reads/writes

**Structure:**
```
session-env/
└── {uuid}/                         # Per-session folder
    └── (environment data)
```

###### B.4.3 shell-snapshots/

**Purpose:** Shell state snapshots
**Owner:** Claude Code
**Access:** `<via: claude>` reads/writes

**Structure:**
```
shell-snapshots/
└── (shell state data)
```

###### B.5.1 downloads/

**Purpose:** Files downloaded by Claude during sessions
**Owner:** Claude Code
**Access:** `<via: claude>` writes, User reads

**Usage:**
- WebFetch downloaded files
- Tool-generated downloads
- Temporary file storage

###### B.5.2 file-history/

**Purpose:** Track file changes across sessions
**Owner:** Claude Code
**Access:** `<via: claude>` reads/writes

**Usage:**
- File change tracking
- Version history
- Edit history

###### B.4.4 debug/

**Purpose:** Debug logs per session
**Owner:** Claude Code
**Access:** `<via: claude>` writes, User reads

**Usage:**
- Session debug logging
- Error tracking
- Diagnostic information

###### A.2.3 plans/

**Purpose:** Plan files created during plan mode
**Owner:** Claude (LLM)
**Access:** `<via: claude>` writes, User reads

**Structure:**
```
plans/
└── {hash}-{random-name}.md         # e.g., 89380ed1fe13c0ee-crystalline-hugging-boot.md
```

**Format:**
```markdown
<!-- session: 89380ed1fe13c0ee42c2d5fc3fa8300d -->
<!-- created: 2026-01-05T13:46:00Z -->
# Plan: Task Description

## Approach
...
```

**[7,9] Phase 2 Linking:**
- `[7]` Header contains session hash
- `[9]` Filename embeds first 16 chars of session hash

##############################################################################################################

## 5. File Access Sequences

**See also:** [Section 4: Schema Reference](#4-schema-reference) for file formats used in these sequences, [Section 6: Governance Integration](#6-governance-integration) for hook integration.


KEY: 
- [overrides] = Extend with higher precedence
  - <via: claude> = Claude (LLM) or Claude Code binary directly
  - <via: hook> = Hook script executes


### 5.1 Session Start

**Precedence: Project overrides Global**

```
┌─────────────────────────────────────┐      ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐
│     ~/.claude/ (GLOBAL)             │             <project>/ (LOCAL)
│     ═══════════════════             │      │     ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─       │
│                                     │
│  READ:                              │      │  READ:                           │
│  ┌───────────────────────────────┐  │         ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐
│  │ settings.json ────────────────┼──┼──────┼──► .claude/settings.local.json   │
│  │ <via: claude>                 │  │      │  │ <via: claude>  [overrides] │
│  └───────────────────────────────┘  │         └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  │
│                                     │      │
│  ┌───────────────────────────────┐  │         ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  │
│  │ CLAUDE.md ────────────────────┼──┼──────┼──► CLAUDE.md
│  │ <via: claude>                 │  │      │  │ <via: claude>  [overrides] │  │
│  └───────────────────────────────┘  │         └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
│                                     │      │                                  │
│  HOOKS EXECUTE:                     │         HOOKS WRITE TO:
│  ┌───────────────────────────────┐  │      │  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  │
│  │ SessionStart hooks            │  │         │ Conversations/*.log
│  │ → inject_context.sh ──────────┼──┼──────┼──► <via: hook>               │  │
│  │ <via: hook>                   │  │      │  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
│  └───────────────────────────────┘  │      │                                  │
│                                     │
│  WRITE:                             │      │
│  ┌───────────────────────────────┐  │
│  │ sessions/{hash}_session.json  │◄─┼──────┼── Hooks update session state     │
│  │ <via: hook>                   │  │      │
│  │ [8] READ previous_session     │  │
│  └───────────────────────────────┘  │      │
│                                     │
│  CLAUDE CODE INTERNALS:             │      │
│  ┌───────────────────────────────┐  │
│  │ projects/{project_id}/        │  │      │
│  │ → Read project cache          │  │
│  │ <via: claude>                 │  │      │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │      │
│  │ history.jsonl                 │  │
│  │ → Append session start        │  │      │
│  │ <via: claude>                 │  │
│  └───────────────────────────────┘  │      │
│  ┌───────────────────────────────┐  │
│  │ stats-cache.json              │  │      │
│  │ → Read/update statistics      │  │
│  │ <via: claude>                 │  │      │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │      │
│  │ statsig/                      │  │
│  │ → Read feature flags          │  │      │
│  │ <via: claude>                 │  │
│  └───────────────────────────────┘  │      │
│  ┌───────────────────────────────┐  │
│  │ debug/                        │  │      │
│  │ → Start debug logging         │  │
│  │ <via: claude>                 │  │      │
│  └───────────────────────────────┘  │      └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
│                                     │
│  ───── = Claude controlled          │        ─ ─ ─ = User/Hooks controlled
└─────────────────────────────────────┘
```

**Phase 2 Linking:**
- `[8]` Read `previous_session` field from `sessions/{hash}_session.json` to display lineage

### 5.2 During Session (Normal Mode)

**Precedence: Project boundaries checked first**

```
┌─────────────────────────────────────┐      ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐
│     ~/.claude/ (GLOBAL)             │             <project>/ (LOCAL)
│     ═══════════════════             │      │     ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─       │
│                                     │
│  PRE-TOOL HOOKS:                    │      │  BOUNDARY CHECK:                 │
│  ┌───────────────────────────────┐  │         ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐
│  │ check_boundaries.sh ──────────┼──┼──────┼──► Validate path in project     │
│  │ <via: hook>                   │  │      │  │ <via: hook>               │
│  └───────────────────────────────┘  │         │                           │  │
│         │                           │      │  │ BLOCKED → Return error
│         │ ALLOWED                   │         │ ALLOWED → Execute tool    │  │
│         ▼                           │      │  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
│  ┌───────────────────────────────┐  │      │                                  │
│  │ Tool executes                 │  │         TOOL MODIFIES:
│  │ <via: claude>                 │──┼──────┼──► project files                 │
│  └───────────────────────────────┘  │      │  <via: claude>
│         │                           │                                        │
│         ▼                           │      │
│  POST-TOOL HOOKS:                   │         HOOKS WRITE:
│  ┌───────────────────────────────┐  │      │  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  │
│  │ log_tool_use.sh               │  │         │ Conversations/*.log
│  │ detect_loop.sh  ──────────────┼──┼──────┼──► <via: hook>               │  │
│  │ <via: hook>                   │  │      │  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
│  └───────────────────────────────┘  │      │                                  │
│         │                           │
│         ▼                           │      │
│  WRITE:                             │
│  ┌───────────────────────────────┐  │      │
│  │ last_tool_name, last_tool_time│  │
│  │ sessions/{hash}_session.json  │◄─┼──────┼── Update token_count, tool_count │
│  │ loop_state.json               │  │      │
│  │ hook_status                   │  │
│  │ <via: hook>                   │  │      │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │      │
│  │ audit/tool_use.log            │  │
│  │ → Append tool usage           │  │      │
│  │ <via: hook>                   │  │
│  └───────────────────────────────┘  │      │
│                                     │
│  CLAUDE CODE INTERNALS:             │      │
│  ┌───────────────────────────────┐  │
│  │ file-history/                 │  │      │
│  │ → Track file changes          │  │
│  │ <via: claude>                 │  │      │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │      │
│  │ debug/                        │  │
│  │ → Continue debug logging      │  │      │
│  │ <via: claude>                 │  │
│  └───────────────────────────────┘  │      │
│  ┌───────────────────────────────┐  │
│  │ downloads/                    │  │      │
│  │ → Save downloaded files       │  │
│  │ <via: claude>                 │  │      │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │      │
│  │ projects/{project_id}/        │  │
│  │ → Update project cache        │  │      │
│  │ <via: claude>                 │  │      └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
│  └───────────────────────────────┘  │
│                                     │
│  ═════ = Claude controlled          │        ─ ─ ─ = User/Hooks controlled
└─────────────────────────────────────┘
```

### 5.3 During Session (Plan Mode)

**Precedence: Global plans, Project read-only**

```
┌─────────────────────────────────────┐      ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐
│     ~/.claude/ (GLOBAL)             │             <project>/ (LOCAL)
│     ═══════════════════             │      │     ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─       │
│                                     │
│  WRITE:                             │      │  READ-ONLY:                      │
│  ┌───────────────────────────────┐  │         ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐
│  │ plans/{hash}-{random}.md      │  │      │  │ Read, Glob, Grep files      │
│  │ [9] Filename embeds session   │  │         │ Explore agents
│  │     e.g., 89380ed1fe13c0ee-   │  │      │  │ <via: claude>             │  │
│  │     crystalline-hugging-boot  │  │         │                           │
│  │ [7] Header has session hash:  │  │      │  │ NO: Edit, Write, Bash     │  │
│  │     <!-- session: {hash} -->  │  │         └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
│  │ <via: claude>                 │  │      │                                  │
│  └───────────────────────────────┘  │
│                                     │         HOOKS WRITE:
│  HOOKS STILL ACTIVE:                │         ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  │
│  ┌───────────────────────────────┐  │      │  │ Conversations/*.log
│  │ PostToolUse hooks ────────────┼──┼──────┼──► <via: hook>               │  │
│  │ <via: hook>                   │  │         └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
│  └───────────────────────────────┘  │      │                                  │
│  ┌───────────────────────────────┐  │
│  │ Hook state continues:         │  │      │
│  │ → sessions/, loop_state.json  │  │
│  │ → hook_status, audit/         │  │      │
│  │ <via: hook>                   │  │
│  └───────────────────────────────┘  │      │
│                                     │
│  CLAUDE CODE INTERNALS:             │      │
│  ┌───────────────────────────────┐  │
│  │ file-history/, debug/         │  │      │
│  │ → Continue tracking           │  │
│  │ <via: claude>                 │  │      │
│  └───────────────────────────────┘  │
│                                     │      │
│  ON EXIT:                           │
│  ┌───────────────────────────────┐  │
│  │ ExitPlanMode                  │  │      │
│  │ → User approves plan          │  │
│  │ → Normal mode resumes         │  │      │
│  │ <via: claude>                 │  │
│  └───────────────────────────────┘  │      └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
│                                     │
│  ═════ = Claude controlled          │        ─ ─ ─ = User/Hooks controlled
└─────────────────────────────────────┘
```

**Phase 2 Linking:**
- `[7]` Write session hash to plan file header as HTML comment
- `[9]` Embed first 16 chars of session hash in plan filename

### 5.4 Todo Operations

**Note:** Global-only operation, no project interaction.

```
┌─────────────────────────────────────────────────────────────┐
│                   TODO WRITE                                │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
              ┌─────────────────────────┐
              │  Claude calls           │
              │  TodoWrite tool         │
              │  <via: claude>          │
              └───────────┬─────────────┘
                          │
              ┌───────────┴───────────┐
              │                       │
       Session-scoped          Global-scoped
              │                       │
              ▼                       ▼
   ┌──────────────────┐    ┌──────────────────┐
   │ Write to:        │    │ Write to:        │
   │ ~/.claude/       │    │ ~/.claude/       │
   │ sessions/        │    │ todo_state.json  │
   │ {hash}_todo.json │    │                  │
   │ <via: claude>    │    │ <via: claude>    │
   └──────────────────┘    └──────────────────┘
```

### 5.5 Session End / Stop

**Precedence: Global state finalized, Project logs saved**

```
┌─────────────────────────────────────┐      ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐
│     ~/.claude/ (GLOBAL)             │             <project>/ (LOCAL)
│     ═══════════════════             │      │     ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─       │
│                                     │
│  STOP HOOK:                         │      │
│  ┌───────────────────────────────┐  │
│  │ check_warmup.sh               │  │      │
│  │ (context warnings)            │  │
│  │ <via: hook>                   │  │      │
│  └───────────────────────────────┘  │
│         │                           │      │
│         ▼                           │
│  SESSION END HOOK:                  │      │  FINAL LOGS:
│  ┌───────────────────────────────┐  │         ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐
│  │ save_session.sh ──────────────┼──┼──────┼──► Conversations/*.log        │
│  │ (final state save)            │  │      │  │ Final session summary
│  │ <via: hook>                   │  │         │ <via: hook>             │  │
│  └───────────────────────────────┘  │      │  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
│         │                           │                                        │
│         ▼                           │      │
│  HOOK STATE FINALIZATION:           │
│  ┌───────────────────────────────┐  │      │
│  │ sessions/{hash}_session.json  │  │
│  │ [8] WRITE: previous_session   │  │      │
│  │     Links to prior session    │  │
│  │ <via: hook>                   │  │      │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │      │
│  │ audit/tool_use.log            │  │
│  │ → Final audit entry           │  │      │
│  │ <via: hook>                   │  │
│  └───────────────────────────────┘  │      │
│                                     │
│  CLAUDE CODE FINALIZATION:          │      │
│  ┌───────────────────────────────┐  │
│  │ history.jsonl                 │  │      │
│  │ → Append final session data   │  │
│  │ <via: claude>                 │  │      │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │      │
│  │ stats-cache.json              │  │
│  │ → Update final statistics     │  │      │
│  │ <via: claude>                 │  │
│  └───────────────────────────────┘  │      │
│  ┌───────────────────────────────┐  │
│  │ projects/{project_id}/        │  │      │
│  │ → Save project state          │  │
│  │ <via: claude>                 │  │      │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │      │
│  │ debug/                        │  │
│  │ → Close debug logs            │  │      │
│  │ <via: claude>                 │  │      └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
│  └───────────────────────────────┘  │
│                                     │
│  ═════ = Claude controlled          │        ─ ─ ─ = User/Hooks controlled
└─────────────────────────────────────┘
```

**Phase 2 Linking:**
- `[8]` Write `previous_session` field to `sessions/{hash}_session.json` for session continuity

### 5.6 Compact Operation

**Note:** Global-only operation, no project interaction.

```
┌─────────────────────────────────────────────────────────────┐
│                      /compact                               │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
              ┌─────────────────────────┐
              │  User runs /compact     │
              │  Then: touch            │
              │  ~/.claude/compact_flag │
              └───────────┬─────────────┘
                          │
                          ▼
              ┌─────────────────────────┐
              │  Next hook detects      │
              │  compact_flag           │
              └───────────┬─────────────┘
                          │
                          ▼
              ┌─────────────────────────┐
              │  Reset token_count      │
              │  in session.json        │
              │  Remove compact_flag    │
              └─────────────────────────┘
```

### 5.7 Global ↔ Project Interaction

**Precedence: Project overrides Global**

**See also:** [Section 6.3: File Linking Solutions](#63-file-linking-solutions) for session linking improvements, [Section 2.2: Folders & Files](#22-folders--files) for permission details.

#### Full Lifecycle Table

| Phase          | Global `~/.claude/`                                                           | Project `<project>/`                              |
|----------------|-------------------------------------------------------------------------------|---------------------------------------------------|
| Session Start  | READ: settings.json, CLAUDE.md `<via: claude>`                                | READ: .claude/settings.local.json `<via: claude>` |
|                | READ: projects/, statsig/ `<via: claude>`                                     | READ: CLAUDE.md `<via: claude>`                   |
|                | WRITE: sessions/{hash}_session.json `<via: hook>` `[8]`                       | WRITE: Conversations/*.log `<via: hook>`          |
|                | WRITE: history.jsonl, stats-cache.json, debug/ `<via: claude>`                |                                                   |
|                | EXECUTE: SessionStart hooks `<via: hook>`                                     |                                                   |
| Normal Mode    | WRITE: sessions/, loop_state.json, hook_status `<via: hook>`                  | MODIFY: project files `<via: claude>`             |
|                | WRITE: last_tool_name, last_tool_time, audit/ `<via: hook>`                   | WRITE: Conversations/*.log `<via: hook>`          |
|                | WRITE: file-history/, debug/, downloads/ `<via: claude>`                      |                                                   |
|                | WRITE: projects/ (cache updates) `<via: claude>`                              |                                                   |
|                | EXECUTE: PreToolUse, PostToolUse hooks `<via: hook>`                          |                                                   |
| Plan Mode      | WRITE: plans/{hash}-{random}.md `<via: claude>` `[7,9]`                       | READ-ONLY: all files `<via: claude>`              |
|                | WRITE: sessions/, loop_state.json, audit/ `<via: hook>`                       | WRITE: Conversations/*.log `<via: hook>`          |
|                | WRITE: file-history/, debug/ `<via: claude>`                                  |                                                   |
|                | EXECUTE: PostToolUse hooks `<via: hook>`                                      |                                                   |
| Session End    | WRITE: sessions/ (+ previous_session) `<via: hook>` `[8]`                     | WRITE: Conversations/*.log `<via: hook>`          |
|                | WRITE: audit/ (final entry) `<via: hook>`                                     |                                                   |
|                | WRITE: history.jsonl, stats-cache.json `<via: claude>`                        |                                                   |
|                | WRITE: projects/ (final state), debug/ (close) `<via: claude>`                |                                                   |
|                | EXECUTE: Stop, SessionEnd hooks `<via: hook>`                                 |                                                   |

#### What Hooks Can Modify

**Currently Implemented:**

| Location           | Files/Folders                            | Hook                  |
|--------------------|------------------------------------------|-----------------------|
| Global             | `sessions/{hash}_session.json`           | log_tool_use.sh       |
| Global             | `last_tool_name`, `last_tool_time`       | log_tool_use.sh       |
| Global             | `loop_state.json`                        | detect_loop.sh        |
| Global             | `hook_status`                            | inject_context.sh     |
| Global             | `audit/tool_use.log`                     | log_tool_use.sh       |
| Project            | `Conversations/*.log`                    | cc wrapper, hooks     |
| Project            | `_governance/*/Conversations/*.log`      | cc wrapper, hooks     |

**Potential Future Modifications:**

| Location           | Files/Folders                            | Use Case              |
|--------------------|------------------------------------------|-----------------------|
| Global             | `sessions/{hash}_todo.json`              | Auto-save todos       |
| Global             | `plans/{name}.md`                        | Plan annotations      |
| Project            | `.claude/session_cache.json`             | Local session cache   |
| Project            | `issues/*.md`                            | Auto-create issues    |

```
┌─────────────────────────────────────┐      ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐
│     ~/.claude/ (GLOBAL)             │             <project>/ (LOCAL)
│     ═══════════════════             │      │     ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─       │
│                                     │
│  ┌───────────────────────────────┐  │      │  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  │
│  │ settings.json ────────────────┼──┼──────┼──►  .claude/settings.local.json
│  │ <via: claude>                 │  │      │  │ <via: claude>  [overrides] │  │
│  └───────────────────────────────┘  │         └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
│                                     │      │                                  │
│  ┌───────────────────────────────┐  │         ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐
│  │ CLAUDE.md ────────────────────┼──┼──────┼──►  CLAUDE.md                    │
│  │ <via: claude>                 │  │      │  │ <via: claude>  [overrides] │
│  └───────────────────────────────┘  │         └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  │
│                                     │      │
│  ┌───────────────────────────────┐  │         ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  │
│  │ sessions/{hash}_session.json  │◄─┼──────┼──  Hooks write metadata
│  │ [8] previous_session field    │  │      │  │ (cc wrapper, log_tool_use) │  │
│  │ <via: hook>                   │  │         └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
│  └───────────────────────────────┘  │      │                                  │
│                                     │         ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐
│  ┌───────────────────────────────┐  │      │  │ Plans created in global:
│  │ plans/{hash}-{random}.md      │  │         │ [7] Header with session │  │
│  │ [7,9] Session hash embedded   │  │      │  │ [9] Filename embedding      │
│  │ <via: claude>                 │  │         └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  │
│  └───────────────────────────────┘  │      │
│                                     │
│  ═════ = Claude controlled          │         ─ ─ ─ = User/Hooks controlled
└─────────────────────────────────────┘      └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘
```

**Phase 2 Linking:**
- `[7]` Plan file headers contain session hash as HTML comment
- `[8]` Session files track previous_session for continuity chain
- `[9]` Plan filenames embed first 16 chars of session hash

##############################################################################################################

## 6. Governance Integration

### 6.1 Hook Execution Flow

```
User Input
    │
    ▼
┌─────────────────┐
│  SessionStart   │ ← inject_context.sh (boundaries, date, project)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  PreToolUse     │ ← check_boundaries.sh (Edit|Write only)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Tool Execution │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  PostToolUse    │ ← log_tool_use.sh + detect_loop.sh
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Stop           │ ← check_warmup.sh (context warnings)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  SessionEnd     │ ← save_session.sh (final state)
└─────────────────┘
```

### 6.2 Session Tracking Flow

```
/model opus
    │
    ▼
Claude updates session.json:
  + "model": "opus"
  + "model_history": [{...}]

/context → 85k tokens
    │
    ▼
User: "calibrate context to 85k"
    │
    ▼
Claude updates session.json:
  + "context_actual": 85000
  + "context_factor": calculated
  + "context_calibrations": [{...}]
```

### 6.3 File Linking Solutions

**See also:** [Section 4: Schema Reference](#4-schema-reference), [Section 8: Implementation Checklist](#8-implementation-checklist) (Phase 2) for implementation tasks.

| Relationship          | Current State                    | Linked? | Proposed Solution                           |
|-----------------------|----------------------------------|---------|---------------------------------------------|
| Session → Todo        | Same hash prefix                 | Yes     | ✓ Working - no change needed                |
| Session → Log         | `log_file` field                 | Yes     | ✓ Working - no change needed                |
| Session → Plan        | No link (random plan names)      | No      | Add `session` field to plan header          |
| Session → Previous    | No `previous_session` field      | No      | Add `previous_session` to session.json      |
| Plan → Session        | No session hash in plan          | No      | Name plans `{hash}-{random}.md`             |

---

#### Implementation Analysis

**Task 7: Add `session: {hash}` to plan file header**

**Implementation Example:**
```markdown
<!-- session: 89380ed1fe13c0ee42c2d5fc3fa8300d -->
<!-- created: 2026-01-05T13:46:00Z -->
# Plan: Fix Authentication Bug

## Context
...
```

**Impact:**
- **Who writes:** Claude Code (during plan creation in Plan Mode)
- **Who reads:** Hooks (for registry), User (for debugging), Governance scripts
- **Files affected:** `~/.claude/plans/*.md`

**Feasibility:** ✅ HIGH
- Simple HTML comment at top of plan file
- No parsing required for basic usage
- Standard markdown comment syntax

**Failure Modes:**
- ⚠️ **LLM forgets header:** Claude doesn't add header during plan creation
- ⚠️ **Hallucinated hash:** Wrong session hash written to header
- ⚠️ **Format inconsistency:** Different comment styles (`<!-- -->` vs `[//]: #`)
- ⚠️ **Header corruption:** Manual edits break metadata

**Mitigation:**
- Use filename as fallback (Task 9)
- Governance script validates header vs filename hash
- Template enforcement in plan creation

---

**Task 8: Add `previous_session` field to session.json schema**

**Implementation Example:**
```json
{
  "start_time": 1767625000,
  "last_warmup": 1767625000,
  "last_update": 1767625100,
  "project": "/Users/mohammadshehata/desktop/Governance",
  "project_name": "Governance",
  "log_file": "./Conversations/20260105_1346_Governance.log",
  "token_count": 0,
  "duplicate_session": false,
  "session_hash": "89380ed1fe13c0ee42c2d5fc3fa8300d",
  "previous_session": "91875ecdf9de053d8f4504a670fa8cfe"
}
```

**Impact:**
- **Who writes:** Hooks (`save_session.sh`) on session end, `cc` wrapper on session start after `/compact`
- **Who reads:** Hooks (`inject_context.sh`) on session start, Governance scripts, User
- **Files affected:** `~/.claude/sessions/{hash}_session.json`

**Feasibility:** ⚠️ MEDIUM
- Requires hook modification (`save_session.sh`)
- Needs state tracking between sessions
- Must handle first session (null value acceptable)

**Failure Modes:**
- ⚠️ **Hook failure:** `save_session.sh` doesn't execute (permission, crash, timeout)
- ⚠️ **Wrong hash:** Copy-paste error, environment variable not set
- ⚠️ **Null on first session:** Expected, but must handle gracefully
- ⚠️ **Race condition:** Session ends before write completes
- ⚠️ **Disk full:** JSON write fails silently
- ⚠️ **Session not found:** Previous session file deleted/moved

**Mitigation:**
- Hook error handling with logging to `audit/tool_use.log`
- Validate hash format (32-char hex) before writing
- Registry reconciliation detects broken chains
- Atomic write with temp file + rename

---

**Task 9: Rename plans to `{hash}-{random}.md` format**

**Implementation Example:**
```bash
# Current naming:
~/.claude/plans/crystalline-hugging-boot.md

# New naming (first 8 chars of session hash):
~/.claude/plans/89380ed1-crystalline-hugging-boot.md

# Or (first 16 chars for collision safety):
~/.claude/plans/89380ed1fe13c0ee-crystalline-hugging-boot.md
```

**Impact:**
- **Who writes:** Claude Code (internal plan naming logic)
- **Who reads:** User (filesystem), Hooks (for registry), Scripts, `ls`/`find` commands
- **Files affected:** `~/.claude/plans/` directory

**Feasibility:** ✅ HIGH
- Internal Claude Code change (no hook modification needed)
- Filesystem-level linking (most reliable)
- Instant visual session association

**Failure Modes:**
- ⚠️ **Hash truncation collision:** Two sessions with same first N chars (extremely rare)
- ⚠️ **Inconsistent truncation:** Sometimes 8 chars, sometimes 16 chars
- ⚠️ **Random collision:** `{hash}-{random}` combination already exists
- ⚠️ **Backward compatibility:** Old plans without hash prefix orphaned
- ⚠️ **Manual rename:** User renames file, breaks link

**Mitigation:**
- Use 16-char hash prefix (collision ~1 in 10^19)
- Check file existence before writing
- Migration script renames old plans (add `unknown-` prefix)
- Registry tracks both old and new formats

---

#### Redundancy Strategy (No Single Point of Failure)

**Problem:** Hooks fail, LLMs hallucinate, files get corrupted/moved.

**Solution:** 4-layer redundancy system

**Layer 1: Filename (Task 9)** - Primary
```
89380ed1fe13c0ee-crystalline-hugging-boot.md
└─────┬─────────┘ └──────────┬──────────────┘
  Session hash       Random adjective-verb-noun
```
- **Pros:** Always visible, filesystem-level, survives file moves, fast grep
- **Cons:** Can be manually renamed, truncation might cause collision
- **Authority:** HIGH - Most reliable, hardest to break accidentally

**Layer 2: File Header (Task 7)** - Fallback
```markdown
<!-- session: 89380ed1fe13c0ee42c2d5fc3fa8300d -->
```
- **Pros:** Inside file (survives renames), full hash (no truncation), metadata extensible
- **Cons:** Requires file read, LLM might forget/hallucinate
- **Authority:** MEDIUM - Depends on LLM correctness

**Layer 3: session.json (Task 8)** - Lineage
```json
"previous_session": "91875ecdf9de053d8f4504a670fa8cfe"
```
- **Pros:** Hook-written (more reliable than LLM), enables session chains
- **Cons:** Hook can fail, requires session file to exist
- **Authority:** MEDIUM-HIGH - Hook-based, but external dependency

**Layer 4: Session Registry (Proposed)** - Reconciliation
```json
{
  "sessions": [{
    "hash": "89380ed1fe13c0ee42c2d5fc3fa8300d",
    "previous_session": "91875ecdf9de053d8f4504a670fa8cfe",
    "plans": ["89380ed1fe13c0ee-crystalline-hugging-boot.md"],
    "todos": ["89380ed1fe13c0ee42c2d5fc3fa8300d_todo.json"],
    "logs": ["Conversations/20260105_1346_Governance.log"]
  }]
}
```
- **Location:** `~/Desktop/Governance/.governance/session_registry.json`
- **Pros:** Single source of truth, audit trail, orphan detection, relationship recovery
- **Cons:** Another file to maintain, synchronization overhead
- **Authority:** HIGHEST - Governance-controlled, reconciliation-based

**Reconciliation Flow:**
1. Scan `~/.claude/plans/` for files with hash prefix (Layer 1)
2. Read plan headers to verify hash match (Layer 2)
3. Check `sessions/{hash}_session.json` exists (Layer 3)
4. Update registry with discovered relationships (Layer 4)
5. Report orphans: plans without sessions, sessions without plans

---

#### Affected Sequences

**Where Phase 2 changes impact File Access Sequences:**

**Section 5.1 (Session Start):**
- `[8]` Read `previous_session` from `~/.claude/sessions/{hash}_session.json`
- Use case: Display session lineage, restore context from previous

**Section 5.3 (Plan Mode):**
- `[7]` Write `<!-- session: {hash} -->` header to plan file
- `[9]` Create plan with filename: `{hash}-{random}.md`
- Both happen when `EnterPlanMode` → `ExitPlanMode` flow completes

**Section 5.5 (Session End):**
- `[8]` Write `previous_session` field to current `session.json` for next session
- Hook: `save_session.sh` gets current hash, stores as "previous" for continuation

**Section 5.7 (Global ↔ Project Interaction):**
- `[7,8,9]` All linking tasks affect traceability between global plans and project sessions

**Notation to add:**
```markdown
**Phase 2 Linking:** `[7]` Plan header, `[8]` Previous session, `[9]` Plan filename
```

---

#### Open Questions

1. **Hash truncation length for Task 9?**
   - Option A: 8 chars (`89380ed1-`) - shorter, more collision risk
   - Option B: 16 chars (`89380ed1fe13c0ee-`) - longer, safer (recommended)

2. **Session Registry location?**
   - Option A: `~/Desktop/Governance/.governance/session_registry.json` - project-specific
   - Option B: `~/.claude/governance/session_registry.json` - all projects tracked

3. **Registry update frequency?**
   - On every session end (real-time, high overhead)
   - On demand via governance script (manual, but efficient)
   - Daily cron job (automated, delayed)

4. **Backward compatibility for old plans?**
   - Rename with `unknown-` prefix: `unknown-crystalline-hugging-boot.md`
   - Leave as-is and mark as orphaned in registry
   - Manual migration required (user decision)

5. **Who owns session_hash field in session.json?**
   - Currently not in schema (Section 4)
   - Should we add it alongside `previous_session`?
   - Or derive from filename?

### 6.4 What Claude Reads vs YOUR Logs

**Critical distinction:** Not all `.claude/` files are read by Claude Code.

#### Claude Code Reads (at session start)

| Location                         | Purpose                    | When Read       |
|----------------------------------|----------------------------|-----------------|
| `~/.claude/CLAUDE.md`            | Global instructions        | Session start   |
| `~/.claude/settings.json`        | Permissions, hooks, model  | Session start   |
| `<project>/CLAUDE.md`            | Project instructions       | Session start   |
| `<project>/.claude/settings.local.json` | Permission overrides | Session start   |

#### Claude Code Does NOT Read

| Location                         | Purpose                    | Who Uses It     |
|----------------------------------|----------------------------|-----------------|
| `~/.claude/sessions/`            | Session metadata           | Hooks only      |
| `~/.claude/history.jsonl`        | Command history            | Claude CLI      |
| `<project>/Conversations/`       | YOUR session logs          | You (reference) |
| `<project>/_governance/`         | YOUR governance data       | You (reference) |
| `_governance/*/Conversations/`   | YOUR subproject logs       | You (reference) |

**Key insight:** `Conversations/` folders are written by YOUR `cc` wrapper and hooks. Claude Code's internal conversation state is stored elsewhere in binary format.

##############################################################################################################

## 7. Quick Reference

### File Ownership Summary

| Owner   | Items                                                                    |
|---------|--------------------------------------------------------------------------|
| User    | CLAUDE.md, settings.json, settings.local.json, templates/                |
| Claude  | sessions/, plans/, plugins/, todos/, debug/, downloads/, file-history/   |
|         | projects/, session-env/, shell-snapshots/, statsig/, telemetry/          |
|         | history.jsonl, stats-cache.json, todo_state.json, .credentials.json      |
| Hooks   | audit/, loop_state.json, hook_status, last_tool_name, last_tool_time     |
| Hybrid  | plans/*.md (Claude writes, user approves)                                |

### Folder Count Summary

| Category          | Count | Folders                                              |
|-------------------|-------|------------------------------------------------------|
| Session State     | 4     | sessions/, session-env/, todos/, shell-snapshots/    |
| History           | 2     | file-history/, projects/                             |
| Plans & Plugins   | 3     | plans/, plugins/, templates/                         |
| Debug & Audit     | 2     | debug/, audit/                                       |
| Telemetry         | 2     | statsig/, telemetry/                                 |
| Downloads         | 1     | downloads/                                           |
| **Total**         | **14**| (excluding root files)                               |

### Hook Types

| Hook Event    | Trigger                    | Example Use              |
|---------------|----------------------------|--------------------------|
| SessionStart  | Session begins             | Inject context           |
| PreToolUse    | Before tool execution      | Boundary checks          |
| PostToolUse   | After tool execution       | Logging, loop detection  |
| Stop          | Claude stops responding    | Warmup warnings          |
| SessionEnd    | Session terminates         | Save final state         |

### Empty Folders (Reserved)

| Folder        | Status      | Purpose When Used                    |
|---------------|-------------|--------------------------------------|
| `downloads/`  | 📂 EMPTY    | Downloaded files from web            |
| `telemetry/`  | 📂 EMPTY    | Additional telemetry data            |
| `templates/`  | 📂 EMPTY    | User-defined templates               |

##############################################################################################################

## 8. Implementation Checklist

### Phase 1: CLAUDE_DIRECTORY_REFERENCE.md Improvements ✓

- [x] **Diagram Notes**
  - [x] Add note to Section 5.4: "Global-only operation, no project interaction"
  - [x] Add note to Section 5.6: "Global-only operation, no project interaction"

- [x] **Table of Contents**
  - [x] Add TOC at top of document with links to all major sections
  - [x] Use anchor links for quick navigation

- [x] **Changelog**
  - [x] Add version history section at bottom
  - [x] Document v3 changes and update dates
  - [x] Track major revisions

- [x] **Cross-References**
  - [x] Add "See also: Section X.X" links throughout document
  - [x] Link related sections (e.g., schemas to sequences)
  - [x] Add backward references where helpful

- [x] **Via Tags Consistency**
  - [x] Add `<via: claude>` tag to Section 5.4 Todo Operations
  - [x] Verify all sequences use consistent via notation

- [x] **Section 6.3 Solutions**
  - [x] Change title from "File Linking (Current Gap)" to "File Linking Solutions"
  - [x] Add proposed solutions for each gap
  - [x] Include implementation approach

### Phase 2: Gov v3 - Fix Linking Gaps

- [ ] **Session → Plan Linking**
  - [ ] Add `session: {hash}` field to plan file header
  - [ ] Update plan creation logic to embed session hash
  - [ ] Test plan-to-session traceability

- [ ] **Session → Previous Session**
  - [ ] Add `previous_session` field to session.json schema (Section 4)
  - [ ] Update hooks to populate on session continuation
  - [ ] Handle first session (null previous)

- [ ] **Plan → Session Naming**
  - [ ] Rename plan files to `{hash}-{random}.md` format
  - [ ] Update plan file references in sequences
  - [ ] Migration strategy for existing plans

### Phase 3: Gov v3 - Implement Empty Folders

- [ ] **Auto-Issue Creation**
  - [ ] Create hook for auto-issue creation
  - [ ] Define issue template format
  - [ ] Implement `issues/{date}_{topic}.md` naming
  - [ ] Test issue creation on errors/blocks

- [ ] **Default Templates**
  - [ ] Create template files for `~/.claude/templates/`
  - [ ] Include: project CLAUDE.md, hooks config, session template
  - [ ] Document template usage in Section 6.8

- [ ] **.git Requirement**
  - [ ] Initialize git in Governance project
  - [ ] OR remove `.git/` requirement from v3 spec
  - [ ] Update Section 3.1 accordingly

### Phase 4: Gov v3 - Hook Enhancements

- [ ] **Auto-Save Todos**
  - [ ] Implement hook to auto-save todos to `sessions/{hash}_todo.json`
  - [ ] Trigger on TodoWrite tool use
  - [ ] Update Section 5.4 sequence

- [ ] **Auto-Create Issues**
  - [ ] Hook to create issues on errors/blocks
  - [ ] Format: `issues/{date}_{topic}.md`
  - [ ] Link to session that created issue

- [ ] **Plan Linking Enhancement**
  - [ ] Embed session hash in plan filename during creation
  - [ ] Add session metadata to plan file header
  - [ ] Update Section 5.3 to reflect linking

### Phase 5: Gov v3 - Token Estimation

- [ ] **Algorithm Improvement**
  - [ ] Review current estimation in `log_tool_use.sh`
  - [ ] Current factor: 13.45x underestimate
  - [ ] Implement better token counting
  - [ ] Test accuracy against `/context` output

- [ ] **Warning System**
  - [ ] Add warning when `context_factor > 10x`
  - [ ] Display in status line or session start
  - [ ] Suggest `/context` calibration

### Phase 6: Gov v3 - Documentation Updates

- [ ] **CLAUDE.md Templates**
  - [ ] Update all templates in `templates/` folder
  - [ ] Add clarification: "Conversations/ = YOUR logs, not read by Claude"
  - [ ] Update TEMPLATE_BIZZ.md, TEMPLATE_CODE.md, TEMPLATE_OPS.md, TEMPLATE_ROOT.md

- [ ] **V2_FULL_SPEC.md**
  - [ ] Add session → plan linking requirement
  - [ ] Document `previous_session` field
  - [ ] Update schema examples

- [ ] **Global CLAUDE.md**
  - [ ] Add session continuity instructions
  - [ ] Document `/compact` and session reset
  - [ ] Explain session hash usage

### Phase 7: Hook Fixes

- [ ] **check_boundaries.sh**
  - [ ] Document current issues
  - [ ] Blocking session file updates from bash
  - [ ] Fix: Allow writes to `~/.claude/sessions/` by governance hooks
  - [ ] Test: Model update, context calibration

- [ ] **check_warmup.sh**
  - [ ] Document current issues
  - [ ] Review context warning thresholds
  - [ ] Fix identified issues
  - [ ] Test warning display

- [ ] **detect_loop.sh**
  - [ ] Document current issues
  - [ ] Review loop detection accuracy
  - [ ] Fix false positives/negatives
  - [ ] Test with actual loops

- [ ] **inject_context.sh**
  - [ ] Document current issues
  - [ ] Review context injection format
  - [ ] Fix formatting or missing data
  - [ ] Test session start context

- [ ] **log_tool_use.sh**
  - [ ] Document current issues
  - [ ] Token estimation 13.45x underestimate
  - [ ] Session file update blocking
  - [ ] Fix estimation algorithm
  - [ ] Test accuracy

- [ ] **save_session.sh**
  - [ ] Document current issues
  - [ ] Review session state persistence
  - [ ] Fix data loss or corruption
  - [ ] Test session end flow

##############################################################################################################

## 9. Document Changelog

### v3.2 - 2026-01-06

**Major Reorganization:**
- **Section 2.2:** Restructured with Part A (User-Managed) / Part B (Claude Internal) split
  - Added "Read By" and "Written By" columns to all tables
  - Changed title to include "(in global ~/.claude/)"
  - Hierarchical numbering: A.1.1, A.1.2, B.1.1, B.1.2, etc.
  - Merged Control Matrix information (Read/Write permissions) into table columns

- **Section 4 (was 6):** Schema Reference reorganized with Part A/B structure
  - User-Managed (Part A): A.1 Configuration, A.2 Content & Templates
  - Claude Internal (Part B): B.1 Session Storage, B.2 History & Statistics, B.3 Hook State, B.4 Debugging & Telemetry, B.5 Downloads
  - All subsections renumbered to A.x.x and B.x.x format
  - Physically reordered to appear before Section 5 (File Access Sequences)

- **Deleted Section 4:** Control Matrix merged into Section 2.2 as additional columns

- **Section Renumbering:**
  - Section 6 → Section 4 (Schema Reference)
  - Section 7 → Section 6 (Governance Integration)
  - Section 8 → Section 7 (Quick Reference)
  - Section 9 → Section 8 (Implementation Checklist)
  - Section 10 → Section 9 (Document Changelog)

- **Table of Contents:** Updated with Part A/B entries and corrected all line numbers

- **Cross-References:** Updated all internal section references throughout document

**Rationale:** Clearer separation between user-editable and system-managed components. Part A/B split makes it easier to understand what files users can modify vs what Claude Code manages internally.

### v3.1 - 2026-01-06

**Major Expansions:**
- **Section 6.11 (projects/):** Comprehensive documentation of session storage
  - Path encoding algorithm explained
  - JSONL format with line-by-line examples
  - Agent ↔ Main Session tracking mechanism
  - Tool results caching system
  - Size analysis (small/medium/large sessions)
  - Parent-child UUID chain tracking

- **Section 6.8 (templates/):** Future use case documentation
  - Speculative structure for project-templates and file-templates
  - Global vs project-local precedence rules
  - Usage examples with `claude init --template`
  - Comparison with Governance templates

- **Section 6.9 (plugins/):** Complete plugin marketplace documentation
  - 36 available plugins (23 internal + 13 external)
  - Featured plugin: `feature-dev` with 7-phase workflow
  - Plugin structure and capabilities tables
  - Installation instructions
  - Plugin vs Skill vs MCP Server comparison

**Improvements:**
- Updated Table of Contents with correct line numbers (all Section 6+ and 7+)
- Updated document header to v3.1 with 2026-01-06 date
- Added 271 lines of detailed technical documentation

**Structure:**
- 2294 total lines (was 2023 in v3.0)
- Section 6 now has comprehensive schema reference for all directories

### v3.0 - 2026-01-05

**Major Changes:**
- Added two-column ASCII diagrams showing Global ↔ Project interaction (Sections 5.1, 5.2, 5.3, 5.5)
- Added Full Lifecycle Table with inline `<via:>` tags (Section 5.7)
- Added "What Hooks Can Modify" subsection with current and future modifications (Section 5.7)
- Added precedence rules to all interaction sequences
- Updated Section 7.3 from "File Linking (Current Gap)" to "File Linking Solutions" with proposed implementations
- Added Implementation Checklist as Section 9 with 26 tasks across 7 phases

**Improvements:**
- Added Table of Contents with anchor links for quick navigation
- Added cross-references throughout document linking related sections
- Added `<via: claude>` tags to Section 5.4 for consistency
- Added notes to Sections 5.4 and 5.6: "Global-only operation, no project interaction"
- Updated all sequence diagrams with visual distinction: `═════` for Claude-controlled, `─ ─ ─` for User/Hooks-controlled

**Structure:**
- 10 sections total (was 8 sections in v2)
- 44 subsections with detailed cross-references
- Complete coverage of `~/.claude/` (15 folders, 11 files) and project `.claude/` structures

### v2.0 - 2026-01-04

**Initial comprehensive reference:**
- Full directory structure trees for global and project `.claude/`
- Control Matrix with ownership and access patterns
- File Access Sequences for all major operations
- Schema Reference for all JSON/JSONL files
- Governance Integration with hook flows
- Quick Reference tables

**Coverage:**
- 8 main sections
- Global directory: 14 folders documented
- Project examples: COEVOLVE and Governance structures
- 7 schema definitions with examples

---

*v3.1 Governance Reference | Updated: 2026-01-06*


##############################################################################################################
##############################################################################################################
##############################################################################################################
= manual copy of last 2 messages:

___ BEFORE LAST MESSAGE
Based on the docs, here's the current state and the gap:

  When Claude Creates a New Plan

  Trigger: User enters plan mode (EnterPlanMode tool)
  - User asks complex implementation question
  - Claude determines planning is needed
  - Enters plan mode, creates plan file

  Current filename: {random-adjective-verb-noun}.md
  - Example: crystalline-hugging-boot.md
  - NO session identifier!

  After Phase 2 [9]: {hash}-{random-name}.md
  - Example: 89380ed1fe13c0ee-crystalline-hugging-boot.md
  - First 16 chars of session hash embedded

  Plan File Content

  Current format:
  # Plan: Fix Authentication Bug

  ## Context
  ...

  ## Approach
  ...

  ## Files to Modify
  ...

  After Phase 2 [7]:
  <!-- session: 89380ed1fe13c0ee42c2d5fc3fa8300d -->
  <!-- created: 2026-01-05T13:46:00Z -->
  # Plan: Fix Authentication Bug

  ## Approach
  ...

  Relationship Between plans/ and projects/

  CRITICAL GAP - Currently Claude DOESN'T know the relationship!

  From Section 7.3:

  | Relationship       | Current State               | Linked? | Problem                            |
  |--------------------|-----------------------------|---------|------------------------------------|
  | Session → Plan     | No link (random plan names) | ❌ No   | Can't find plan from session       |
  | Plan → Session     | No session hash in plan     | ❌ No   | Can't find session from plan       |
  | Session → Projects | No explicit link            | ❌ No   | Indirect via project path encoding |

  How they SHOULD connect:
  Session (in projects/):
    projects/-Users-mohammadshehata-Desktop-Governance/
      └── 89380ed1fe13c0ee42c2d5fc3fa8300d.jsonl  # Full conversation

  Plan (in plans/):
    plans/
      └── 89380ed1fe13c0ee-crystalline-hugging-boot.md  # Plan from that session
           ^^^^^^^^^^^^^^
           Session hash!

  After Phase 2 [7,8,9]:
  - [7] Plan header has session hash → find session from plan
  - [8] Session has previous_session → session continuity chain
  - [9] Plan filename has session hash → filesystem-level link

  4-Layer Redundancy (Section 7.3):
  1. Filename: 89380ed1fe13c0ee-{name}.md
  2. Header: <!-- session: {hash} -->
  3. session.json: previous_session field
  4. Registry: Proposed global index file

  Current workaround: None - relationship is lost!

  Todos
  ☒ Add note to sections 5.4, 5.6: 'Global-only operation, no project interaction'
  ☒ Add Table of Contents to CLAUDE_DIRECTORY_REFERENCE.md
  ☒ Add changelog/version history to bottom of CLAUDE_DIRECTORY_REFERENCE.md
  ☒ Add cross-references throughout CLAUDE_DIRECTORY_REFERENCE.md
  ☒ Add <via: claude> tag to Section 5.4 for consistency
  ☒ Update Section 7.3 title from 'Current Gap' and add proposed solutions
  ☐ Add session hash to plan file headers (session: {hash})
  ☐ Add previous_session field to session.json schema
  ☐ Rename plans to {hash}-{random}.md format
  ☐ Implement auto-issue creation hook for issues/ folder
  ☐ Ship default templates in ~/.claude/templates/
  ☐ Initialize .git in Governance project or remove from spec
  ☐ Auto-save todos to sessions/{hash}_todo.json via hook
  ☐ Auto-create issues to issues/{date}_{topic}.md via hook
  ☐ Embed session hash in plan filenames
  ☐ Improve token estimation algorithm in log_tool_use.sh
  ☐ Add warning when context_factor > 10x
  ☐ Update CLAUDE.md templates with Conversations/ clarification
  ☐ Update V2_FULL_SPEC.md with session → plan linking requirement
  ☐ Update Global CLAUDE.md with session continuity instructions
  ☐ Fix check_boundaries.sh issues
  ☐ Fix check_warmup.sh issues
  ☐ Fix detect_loop.sh issues
  ☐ Fix inject_context.sh issues
  ☐ Fix log_tool_use.sh issues (token estimation, session updates)
  ☐ Fix save_session.sh issues




  __ LAST MESSAGE 
   Based on the docs, here's the current state and the gap:

  When Claude Creates a New Plan

  Trigger: User enters plan mode (EnterPlanMode tool)
  - User asks complex implementation question
  - Claude determines planning is needed
  - Enters plan mode, creates plan file

  Current filename: {random-adjective-verb-noun}.md
  - Example: crystalline-hugging-boot.md
  - NO session identifier!

  After Phase 2 [9]: {hash}-{random-name}.md
  - Example: 89380ed1fe13c0ee-crystalline-hugging-boot.md
  - First 16 chars of session hash embedded

  Plan File Content

  Current format:
  # Plan: Fix Authentication Bug

  ## Context
  ...

  ## Approach
  ...

  ## Files to Modify
  ...

  After Phase 2 [7]:
  <!-- session: 89380ed1fe13c0ee42c2d5fc3fa8300d -->
  <!-- created: 2026-01-05T13:46:00Z -->
  # Plan: Fix Authentication Bug

  ## Approach
  ...

  Relationship Between plans/ and projects/

  CRITICAL GAP - Currently Claude DOESN'T know the relationship!

  From Section 7.3:

  | Relationship       | Current State               | Linked? | Problem                            |
  |--------------------|-----------------------------|---------|------------------------------------|
  | Session → Plan     | No link (random plan names) | ❌ No   | Can't find plan from session       |
  | Plan → Session     | No session hash in plan     | ❌ No   | Can't find session from plan       |
  | Session → Projects | No explicit link            | ❌ No   | Indirect via project path encoding |

  How they SHOULD connect:
  Session (in projects/):
    projects/-Users-mohammadshehata-Desktop-Governance/
      └── 89380ed1fe13c0ee42c2d5fc3fa8300d.jsonl  # Full conversation

  Plan (in plans/):
    plans/
      └── 89380ed1fe13c0ee-crystalline-hugging-boot.md  # Plan from that session
           ^^^^^^^^^^^^^^
           Session hash!

  After Phase 2 [7,8,9]:
  - [7] Plan header has session hash → find session from plan
  - [8] Session has previous_session → session continuity chain
  - [9] Plan filename has session hash → filesystem-level link

  4-Layer Redundancy (Section 7.3):
  1. Filename: 89380ed1fe13c0ee-{name}.md
  2. Header: <!-- session: {hash} -->
  3. session.json: previous_session field
  4. Registry: Proposed global index file

  Current workaround: None - relationship is lost!

> wrap up the session 

∴ Thinking…

  The user is asking me to wrap up the session. This typically means:
  1. Summarize what we accomplished
  2. Note what's remaining
  3. Provide any final recommendations

  Let me create a comprehensive summary of what we did in this session.

⏺ Session Wrap-Up

  What We Accomplished

  1. Fixed <via: claude+hook> → <via: hook> (5 instances)
  - Section 5.1: SessionStart hooks
  - Section 5.10 (now 5.7): Full Lifecycle Table
  - Clarified that hooks execute, Claude Code just triggers

  2. Added All ~/.claude/ Directories to Section 5 Sequences
  - 5.1 Session Start: Added projects/, history.jsonl, stats-cache.json, statsig/, debug/
  - 5.2 Normal Mode: Added loop_state.json, hook_status, audit/, file-history/, downloads/
  - 5.3 Plan Mode: Added hook state continuity, file-history/, debug/
  - 5.5 Session End: Separated hook vs Claude Code finalization, added all files
  - 5.9 Telemetry: Expanded with <via: claude> tags for statsig/

  3. Reorganized Document Structure
  - Moved to Section 6: Templates (5.7→6.8), Plugins (5.8→6.9), Telemetry (5.9→6.10)
  - Renumbered: Global ↔ Project Interaction (5.10→5.7)
  - Added 10 new subsections to Section 6:
    - 6.8 templates/, 6.9 plugins/, 6.10 statsig/+telemetry/
    - 6.11 projects/ (with path encoding details), 6.12 session-env/, 6.13 shell-snapshots/
    - 6.14 downloads/, 6.15 file-history/, 6.16 debug/, 6.17 plans/

  4. Clarified Key Concepts
  - projects/: Path-encoded directories based on working directory, contains JSONL session data
  - plans/: Currently no link to sessions (Gap! - Phase 2 will fix with tasks 7,8,9)
  - Override semantics: "Extend with higher precedence" - both files active, project/local wins conflicts
  - Claude Code vs Hooks: Verified Claude Code doesn't read ~/.claude/sessions/ (governance-only)

  5. Updated Throughout
  - Table of Contents (removed 5.7-5.9, renumbered 5.10→5.7, added 6.8-6.17)
  - All cross-references
  - Changelog entries
  - Implementation checklist references

  Current State

  Section 5 (File Access Sequences): Complete coverage of all ~/.claude/ files showing WHEN accessed
  Section 6 (Schema Reference): Complete coverage of all directories showing WHAT they contain
  All sequences: Clearly distinguish <via: claude> (Claude Code binary) vs <via: hook> (hook scripts)

  What's Next

  Phase 2 Implementation (Tasks 7, 8, 9) will fix the plans/ ↔ sessions/ ↔ projects/ linking gap:
  - [7] Plan headers with session hash
  - [8] Session files with previous_session links
  - [9] Plan filenames with session hash prefix

  Remaining todos: 20 pending items in Implementation Checklist (Section 9)

  Document Status: CLAUDE_DIRECTORY_REFERENCE.md is now a comprehensive v3 reference with all ~/.claude/ files documented.

  ---
  Ready for your review of the File Access Sequences for hallucinations, then Phase 2 implementation when you're ready.

  Todos
  ☒ Add note to sections 5.4, 5.6: 'Global-only operation, no project interaction'
  ☒ Add Table of Contents to CLAUDE_DIRECTORY_REFERENCE.md
  ☒ Add changelog/version history to bottom of CLAUDE_DIRECTORY_REFERENCE.md
  ☒ Add cross-references throughout CLAUDE_DIRECTORY_REFERENCE.md
  ☒ Add <via: claude> tag to Section 5.4 for consistency
  ☒ Update Section 7.3 title from 'Current Gap' and add proposed solutions
  ☐ Add session hash to plan file headers (session: {hash})
  ☐ Add previous_session field to session.json schema
  ☐ Rename plans to {hash}-{random}.md format
  ☐ Implement auto-issue creation hook for issues/ folder
  ☐ Ship default templates in ~/.claude/templates/
  ☐ Initialize .git in Governance project or remove from spec
  ☐ Auto-save todos to sessions/{hash}_todo.json via hook
  ☐ Auto-create issues to issues/{date}_{topic}.md via hook
  ☐ Embed session hash in plan filenames
  ☐ Improve token estimation algorithm in log_tool_use.sh
  ☐ Add warning when context_factor > 10x
  ☐ Update CLAUDE.md templates with Conversations/ clarification
  ☐ Update V2_FULL_SPEC.md with session → plan linking requirement
  ☐ Update Global CLAUDE.md with session continuity instructions
  ☐ Fix check_boundaries.sh issues
  ☐ Fix check_warmup.sh issues
  ☐ Fix detect_loop.sh issues
  ☐ Fix inject_context.sh issues
  ☐ Fix log_tool_use.sh issues (token estimation, session updates)
  ☐ Fix save_session.sh issues


