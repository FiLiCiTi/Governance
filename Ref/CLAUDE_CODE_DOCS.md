# Claude Code Architecture Reference

> **Created:** 2026-01-03
> **Purpose:** Comprehensive reference for Claude Code components and governance integration

---

## Table of Contents

| #   | Section                | Line |
|-----|------------------------|------|
| 1   | Architecture Overview  | 23   |
| 2   | Settings               | 53   |
| 3   | Hooks                  | 79   |
| 4   | Tools                  | 146  |
| 5   | Agents                 | 185  |
| 6   | MCP Servers            | 217  |
| 7   | Model Choices          | 258  |
| 8   | Context Window         | 284  |
| 9   | Additional Topics      | 318  |

---

## 1. Architecture Overview

| #  | Component/Factor     | Purpose                  | Control   | Basis  | Info Source                 |
|----|----------------------|--------------------------|-----------|--------|-----------------------------|
| 1  | System prompt        | Core behavior, safety    | Anthropic | LLM    | Hardcoded                   |
| 2  | Tool definitions     | Built-in actions         | Anthropic | LLM    | Hardcoded                   |
| 3  | User memory          | Global rules             | You       | LLM    | `~/.claude/CLAUDE.md`       |
| 4  | Project memory       | Project rules            | You       | LLM    | `./CLAUDE.md`               |
| 5  | Project rules        | Modular rules            | You       | LLM    | `.claude/rules/*.md`        |
| 6  | Local memory         | Local overrides          | You       | LLM    | `./CLAUDE.local.md`         |
| 7  | MCP tool defs        | External tool schemas    | You       | LLM    | MCP servers                 |
| 8  | Skill defs           | Slash command schemas    | You       | LLM    | `.claude/skills/`           |
| 9  | Conversation history | Context continuity       | Dynamic   | LLM    | Session state               |
| 10 | Settings             | Permissions, configs     | You       | Code   | `.claude/settings.json`     |
| 11 | Hooks                | Trigger scripts          | You       | Hybrid | Settings + your .sh         |
| 12 | Tools                | Single actions           | Anthropic | Code   | Built-in                    |
| 13 | Agents               | Multi-step tasks         | Anthropic | Hybrid | Task tool                   |
| 14 | MCP execution        | External calls           | You       | Code   | MCP servers                 |
| 15 | Plans                | Task tracking            | Mixed     | LLM    | `.claude/plans/`            |
| 16 | Todos                | Progress tracking        | Mixed     | LLM    | TodoWrite state             |
| 17 | Model choice         | Intelligence level       | You       | Code   | Config                      |
| 18 | Context window       | Memory limit             | Dynamic   | Code   | Auto-managed                |

**Basis Legend:**
- **LLM** = Injected into prompt, processed by model
- **Code** = Runs outside model as infrastructure
- **Hybrid** = Code-based but can inject back to LLM

---

## 2. Settings

### 2.1 Available Settings

| Setting         | Location                 | Purpose              |
|-----------------|--------------------------|----------------------|
| `permissions`   | `.claude/settings.json`  | Allow/deny tools     |
| `hooks`         | `.claude/settings.json`  | Event triggers       |
| `allowedTools`  | `.claude/settings.json`  | Whitelist tools      |
| `deniedTools`   | `.claude/settings.json`  | Blacklist tools      |
| `trustMcpTools` | `.claude/settings.json`  | Auto-allow MCP       |
| `env`           | `.claude/settings.json`  | Environment vars     |

### 2.2 Scope Hierarchy

Priority order (highest → lowest):

| #  | Scope                         | File                           | Committed |
|----|-------------------------------|--------------------------------|-----------|
| 1  | Enterprise policy             | Managed                        | N/A       |
| 2  | Project local                 | `.claude/settings.local.json`  | No        |
| 3  | Project                       | `.claude/settings.json`        | Yes       |
| 4  | User global                   | `~/.claude/settings.json`      | No        |

---

## 3. Hooks

### 3.1 Available Hook Events

| Hook                | When Triggered                    | Can Block |
|---------------------|-----------------------------------|-----------|
| `SessionStart`      | Session begins                    | No        |
| `SessionEnd`        | Session ends                      | No        |
| `UserPromptSubmit`  | User sends message                | Yes       |
| `PreToolUse`        | Before tool runs                  | Yes       |
| `PostToolUse`       | After tool runs                   | No        |
| `PermissionRequest` | Permission dialog shows           | Yes       |
| `Notification`      | Claude sends notification         | No        |
| `Stop`              | Claude finishes responding        | Yes       |
| `SubagentStop`      | Subagent finishes                 | Yes       |
| `PreCompact`        | Before context compaction         | No        |

### 3.2 Hook Configuration

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/script.sh",
            "timeout": 60
          }
        ]
      }
    ]
  }
}
```

### 3.3 Hook Types

| Type      | Description                    | LLM Used |
|-----------|--------------------------------|----------|
| `command` | Run shell script               | No       |
| `prompt`  | LLM evaluates condition        | Haiku    |

### 3.4 Exit Codes

| Code | Meaning                              |
|------|--------------------------------------|
| 0    | Success (allow action)               |
| 2    | Block action (stderr shown to Claude)|
| Other| Non-blocking error                   |

### 3.5 Hook Input (stdin JSON)

```json
{
  "session_id": "abc123",
  "cwd": "/current/directory",
  "hook_event_name": "PreToolUse",
  "tool_name": "Edit",
  "tool_input": { "file_path": "...", "old_string": "...", "new_string": "..." }
}
```

---

## 4. Tools

### 4.1 Built-in Tools

| Tool           | Purpose                          | Modifiable |
|----------------|----------------------------------|------------|
| `Read`         | Read file contents               | No         |
| `Edit`         | Replace text in file             | No         |
| `Write`        | Create/overwrite file            | No         |
| `Bash`         | Execute shell commands           | No         |
| `Glob`         | Find files by pattern            | No         |
| `Grep`         | Search file contents             | No         |
| `Task`         | Launch background agents         | No         |
| `TodoWrite`    | Manage task list                 | No         |
| `WebFetch`     | Fetch URL content                | No         |
| `WebSearch`    | Search the web                   | No         |
| `NotebookEdit` | Edit Jupyter notebooks           | No         |
| `AskUserQuestion` | Prompt user for input         | No         |

### 4.2 Tool Control via Settings

```json
{
  "allowedTools": ["Read", "Glob", "Grep"],
  "deniedTools": ["Bash"]
}
```

### 4.3 Tool Permissions

| Permission Level | Description                      |
|------------------|----------------------------------|
| `default`        | Ask before destructive actions   |
| `acceptEdits`    | Auto-accept file edits           |
| `plan`           | Read-only, no edits              |
| `bypassPermissions` | Allow all (dangerous)         |

---

## 5. Agents

### 5.1 Built-in Agent Types

| Agent              | Purpose                           | Tools Available |
|--------------------|-----------------------------------|-----------------|
| `Explore`          | Search/explore codebase           | Read, Glob, Grep |
| `Plan`             | Design implementation             | All tools       |
| `claude-code-guide`| Answer Claude Code questions      | Read, Glob, Grep, WebFetch, WebSearch |
| `general-purpose`  | Complex multi-step tasks          | All tools       |

### 5.2 Agent vs Tool

| Aspect      | Tool                | Agent                    |
|-------------|---------------------|--------------------------|
| Scope       | Single action       | Multi-step task          |
| Context     | Same conversation   | Separate subprocess      |
| Execution   | Inline, blocking    | Background, parallel     |
| Launched by | Direct use          | `Task` tool              |

### 5.3 Launching Agents

```
Task tool parameters:
- subagent_type: "Explore" | "Plan" | "claude-code-guide" | "general-purpose"
- prompt: Task description
- model: "sonnet" | "opus" | "haiku" (optional)
- run_in_background: true/false
```

---

## 6. MCP Servers

### 6.1 What is MCP

**Model Context Protocol** - Allows external tools/integrations.

### 6.2 Configuration

Location: `.claude/settings.json` or `~/.claude/settings.json`

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-memory"]
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-filesystem", "/path"]
    }
  }
}
```

### 6.3 MCP Tool Naming

MCP tools appear as: `mcp__<server>__<tool>`

Example: `mcp__memory__store`, `mcp__filesystem__read`

### 6.4 Trust Settings

```json
{
  "trustMcpTools": true
}
```

---

## 7. Model Choices

### 7.1 Available Models

| Model    | ID                          | Use Case                |
|----------|-----------------------------|-----------------------  |
| Opus     | `claude-opus-4-5-20251101`  | Complex reasoning       |
| Sonnet   | `claude-sonnet-4-...`       | Balanced (default)      |
| Haiku    | `claude-haiku-...`          | Fast, cheap tasks       |

### 7.2 Model Selection

- **Default:** Inherits from parent/config
- **Per-agent:** Specify in Task tool `model` param
- **Hooks (prompt type):** Always uses Haiku

### 7.3 Cost/Speed Tradeoff

| Model  | Speed  | Cost   | Intelligence |
|--------|--------|--------|--------------|
| Haiku  | Fast   | Low    | Basic        |
| Sonnet | Medium | Medium | Good         |
| Opus   | Slow   | High   | Best         |

---

## 8. Context Window

### 8.1 Limits

| Model  | Context Window |
|--------|----------------|
| All    | 200K tokens    |

### 8.2 What Consumes Context

| Item                  | Tokens (approx)     |
|-----------------------|---------------------|
| System prompt (L1-2)  | ~5-10K              |
| CLAUDE.md files (L3-6)| Varies              |
| Conversation history  | Grows over time     |
| Tool outputs          | Per-use             |

### 8.3 Context Management

| Event         | Trigger                    | Hook Available |
|---------------|----------------------------|----------------|
| Compaction    | Context ~80% full          | `PreCompact`   |
| Summarization | Auto when needed           | No             |
| Truncation    | Oldest messages dropped    | No             |

### 8.4 Best Practices

- Keep CLAUDE.md files concise
- Use `Read` with line limits for large files
- Prefer agents for exploration (separate context)
- Watch for "context getting full" warnings

---

## 9. Additional Topics (See Documentation Map)

Reference: `Claude-Code-Documentation-Map.md`

| #  | Topic            | What It Does                          | Use in Governance                        | Map Line |
|----|------------------|---------------------------------------|------------------------------------------|----------|
| 1  | Skills           | Create custom `/slash` commands       | `/warmup`, `/boundary`, `/audit`         | 183      |
| 2  | Plugins          | Bundles of skills + hooks + MCP       | Package governance as shareable plugin   | 156      |
| 3  | Memory           | How L3-L6 load, merge, override       | Understand why rules get ignored         | 801      |
| 4  | Checkpointing    | Save/restore conversation state       | Recover from crashes, undo mistakes      | 897      |
| 5  | Headless         | Run non-interactively                 | Automate governance checks in CI/cron    | 251      |
| 6  | CLI Reference    | All CLI flags                         | Script governance_*.sh integrations      | 828      |
| 7  | Slash Commands   | Built-in `/clear`, `/help`, etc.      | Know what's available vs custom          | 853      |
| 8  | Interactive Mode | Shortcuts, Shift+Tab cycling          | Train users on permission workflow       | 836      |
| 9  | Output Styles    | Control verbosity, format             | Enforce token-efficient responses        | 222      |

---

*Document created: 2026-01-03*
