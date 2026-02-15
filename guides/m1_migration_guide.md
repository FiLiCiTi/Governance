# M1 Laptop — Governance Migration Guide

> **Type:** GUIDE | **Updated:** 2026-02-15
> **Source:** MacBook Pro (mohammadshehata) | **Target:** MacBook M1

## Table of Contents

| Section | Title                                                    | Line |
|---------|----------------------------------------------------------|------|
| 1       | [Prerequisites](#1-prerequisites)                       | :18  |
| 2       | [Transfer Files](#2-transfer-files)                     | :30  |
| 3       | [Path Adaptation](#3-path-adaptation)                   | :80  |
| 4       | [Install Plugins](#4-install-plugins)                   | :109 |
| 5       | [Verify Setup](#5-verify-setup)                         | :141 |
| 6       | [Per-Project CLAUDE.md](#6-per-project-claudemd)        | :163 |

---------------------------------------------------------------------------------------------------------------------------

## 1. Prerequisites

On the M1 laptop:

1. **Install Claude Code:** `npm install -g @anthropic-ai/claude-code`
2. **Run once:** `claude` — this creates the `~/.claude/` directory
3. **Quit Claude** before copying files
4. **Note the M1 username:** run `whoami` — replace `{M1_USER}` below with actual value

**Transfer method:** AirDrop, USB drive, or `scp` over local network.

---------------------------------------------------------------------------------------------------------------------------

## 2. Transfer Files

### 2.1 Global Config (Required)

Copy these from source Mac to M1 `~/.claude/`:

| #  | Source File                       | Destination                       | Notes                       |
|----|-----------------------------------|-----------------------------------|-----------------------------|
| 1  | `~/.claude/CLAUDE.md`            | `~/.claude/CLAUDE.md`            | Global rules (Layer 3)      |
| 2  | `~/.claude/settings.json`        | `~/.claude/settings.json`        | **Needs path edits** (§3)   |
| 3  | `~/.claude/Shared_context.md`    | `~/.claude/Shared_context.md`    | Shared context              |

### 2.2 Templates (Required)

Copy the entire folder:

```bash
# On M1
mkdir -p ~/.claude/templates
```

Then copy all 19 files from `~/.claude/templates/` on source Mac.

### 2.3 Governance Project (Required)

Copy the entire Governance folder to the same relative path on M1:

```bash
# On M1 — create parent structure
mkdir -p ~/Desktop/FILICITI
```

Then copy `Governance/` folder. Key contents:
- `scripts/` — 18 hook scripts (all hooks point here)
- `templates/` — 16 project templates
- `CLAUDE.md` — project-level instructions
- `HANDOFF_REGISTRY.md` — session index
- `Gov_Design_v3.3.md`, `Architecture_v3.3.md`, `HOOKS_ARCHITECTURE_v3.3.md`

### 2.4 Skip (Do NOT Transfer)

| Skip These                     | Reason                    |
|--------------------------------|---------------------------|
| `~/.claude/projects/`         | Machine-specific sessions |
| `~/.claude/file-history/`     | Machine-specific history  |
| `~/.claude/history.jsonl`     | Machine-specific commands |
| `~/.claude/sessions/`         | Machine-specific state    |
| `~/.claude/debug/`            | Machine-specific logs     |
| `~/.claude/settings.local.json` | Machine-specific perms  |

---------------------------------------------------------------------------------------------------------------------------

## 3. Path Adaptation

**Critical:** `settings.json` contains hardcoded paths. You must update them.

### 3.1 Username Replacement

In `~/.claude/settings.json` on M1, replace ALL occurrences:

```bash
# On M1 — replace username in settings.json
sed -i '' 's|/Users/mohammadshehata/|/Users/{M1_USER}/|g' ~/.claude/settings.json
```

### 3.2 Paths That Change

| Path Pattern (Source)                                         | Replace With                                      |
|---------------------------------------------------------------|---------------------------------------------------|
| `/Users/mohammadshehata/Desktop/FILICITI/Governance/scripts/` | `/Users/{M1_USER}/Desktop/FILICITI/Governance/scripts/` |
| `/Users/mohammadshehata/Desktop/FILICITI/**`                  | `/Users/{M1_USER}/Desktop/FILICITI/**`            |
| `/Users/mohammadshehata/.claude/**`                           | `/Users/{M1_USER}/.claude/**`                     |

### 3.3 Files That Need Path Updates

| File                        | What to Update                              |
|-----------------------------|---------------------------------------------|
| `~/.claude/settings.json`  | permissions.allow, permissions.deny, hooks,  |
|                             | statusLine paths                             |
| `~/.claude/CLAUDE.md`      | Links section (Governance path, templates)   |

### 3.4 Make Scripts Executable

```bash
chmod +x ~/Desktop/FILICITI/Governance/scripts/*.sh
```

---------------------------------------------------------------------------------------------------------------------------

## 4. Install Plugins

Plugins are NOT transferred — install fresh on M1.

### 4.1 Essential Plugins (22)

Run these on M1:

```bash
claude plugins install commit-commands@claude-plugins-official
claude plugins install plugin-dev@claude-plugins-official
claude plugins install hookify@claude-plugins-official
claude plugins install github@claude-plugins-official
claude plugins install typescript-lsp@claude-plugins-official
claude plugins install pyright-lsp@claude-plugins-official
claude plugins install rust-analyzer-lsp@claude-plugins-official
claude plugins install gopls-lsp@claude-plugins-official
claude plugins install php-lsp@claude-plugins-official
claude plugins install jdtls-lsp@claude-plugins-official
claude plugins install csharp-lsp@claude-plugins-official
claude plugins install swift-lsp@claude-plugins-official
claude plugins install lua-lsp@claude-plugins-official
claude plugins install clangd-lsp@claude-plugins-official
claude plugins install feature-dev@claude-plugins-official
claude plugins install code-review@claude-plugins-official
claude plugins install pr-review-toolkit@claude-plugins-official
claude plugins install agent-sdk-dev@claude-plugins-official
claude plugins install security-guidance@claude-plugins-official
claude plugins install frontend-design@claude-plugins-official
claude plugins install playwright@claude-plugins-official
claude plugins install serena@claude-plugins-official
```

### 4.2 Skip LSP Plugins If Not Needed

If M1 is not used for all languages, skip unneeded LSP plugins:
- `php-lsp`, `jdtls-lsp`, `csharp-lsp`, `lua-lsp`, `clangd-lsp`

---------------------------------------------------------------------------------------------------------------------------

## 5. Verify Setup

### 5.1 Quick Checks

Run on M1 after setup:

```bash
# 1. Check settings loaded
claude config list

# 2. Check scripts are executable
ls -la ~/Desktop/FILICITI/Governance/scripts/*.sh

# 3. Check plugins installed
claude plugins list

# 4. Start a session — hooks should fire
claude
```

### 5.2 Expected Behavior

On first `claude` session in Governance project:
- SessionStart hook fires (init_session.sh, reset_context.sh)
- Status bar shows session info
- `confirm and next` displays boundaries and handoff info
- PreToolUse validates boundaries on Edit/Write

### 5.3 Troubleshooting

| Issue                      | Fix                                                    |
|----------------------------|--------------------------------------------------------|
| Hook script not found      | Check paths in `settings.json` match M1 paths          |
| Permission denied on script | `chmod +x` the script                                 |
| Plugin not loading         | `claude plugins install <name>` again                  |
| Status bar empty           | Check `status_bar.sh` path in `settings.json`          |

---------------------------------------------------------------------------------------------------------------------------

## 6. Per-Project CLAUDE.md

For each project you work on from the M1, create a `CLAUDE.md` in the project root.

### 6.1 Use Templates

Templates are in `~/.claude/templates/`:

| Project Type | Template                      |
|--------------|-------------------------------|
| OPS          | `CLAUDEMD_OPS-TEMPLATE.md`   |
| CODE         | `CLAUDEMD_CODE-TEMPLATE.md`  |
| BIZZ         | `CLAUDEMD_BIZZ-TEMPLATE.md`  |
| Root         | `CLAUDEMD_ROOT-TEMPLATE.md`  |

### 6.2 Required Sections

Every project CLAUDE.md must have:
- **Boundaries:** CAN modify / CANNOT modify
- **Critical Rules:** Project-specific rules
- **Links:** Key files and references

---------------------------------------------------------------------------------------------------------------------------

*Guide: ~/Desktop/FILICITI/Governance/guides/m1_migration_guide.md | v1.0*
