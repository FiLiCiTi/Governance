# Claude Code Governance Guide v2
## Comprehensive Understanding of Prompt Architecture, State Management, and Usage Rules

**Last Updated:** January 2026  
**Sources:** Anthropic official documentation, Claude Code docs, support articles, verified user testing

---

## Table of Contents

| Section | Title | Line |
|---------|-------|------|
| 1 | **PART 1: CLAUDE CODE ARCHITECTURE** | 30 |
| 1.1 | What Constitutes the "Final Prompt" | 34 |
| 1.2 | Persistent vs Ephemeral State | 70 |
| 1.3 | What Triggers State Changes | 95 |
| 1.4 | Context Window Limits | 130 |
| 1.5 | Plan Mode Architecture | 155 |
| 1.6 | Why Claude "Misbehaves" - Root Causes | 185 |
| 1.7 | Recommended CLAUDE.md Governance Structure | 220 |
| 2 | **PART 2: PERMISSION MODES** | 265 |
| 2.1 | The Three Modes (Shift+Tab Cycling) | 270 |
| 2.2 | What "Accept Edits On" Actually Does | 290 |
| 2.3 | Configuring Broader Auto-Permissions | 310 |
| 3 | **PART 3: MODEL CONFIGURATION** | 350 |
| 3.1 | Available Model Options | 355 |
| 3.2 | How to Set Models | 370 |
| 4 | **PART 4: USAGE LIMITS** | 405 |
| 4.1 | Token-Based (Not Message-Based) | 410 |
| 4.2 | 5-Hour Rolling Window | 430 |
| 4.3 | Weekly Rolling Window | 460 |
| 4.4 | How to Check Usage | 480 |
| 4.5 | Cross-Platform Sharing | 500 |
| 5 | **PART 5: TOKEN VISIBILITY** | 515 |
| 5.1 | Commands to See Token Usage | 520 |
| 5.2 | Verbose Mode | 540 |
| 6 | **PART 6: SYSTEM PROMPT ACCESS** | 560 |
| 7 | **PART 7: EXTRA USAGE PRICING** | 585 |
| 8 | **PART 8: KEY COMMANDS REFERENCE** | 615 |
| 9 | **PART 9: QUICK REFERENCE TABLES** | 650 |

---

## PART 1: CLAUDE CODE ARCHITECTURE

### 1.1 What Constitutes the "Final Prompt"

When you interact with Claude Code, the actual prompt sent to the AI model consists of multiple layers assembled in a specific order:

```
┌────────────────────────────────────────────────────────────────┐
│  1. SYSTEM PROMPT (Anthropic-controlled, hidden from user)    │
│     - Core behavior instructions (~5-10K tokens)               │
│     - Tool definitions and capabilities                        │
│     - Safety guidelines                                        │
├────────────────────────────────────────────────────────────────┤
│  2. ENTERPRISE POLICY (if applicable)                          │
│     Location:                                                  │
│       macOS: /Library/Application Support/ClaudeCode/CLAUDE.md │
│       Linux: /etc/claude-code/CLAUDE.md                        │
│       Windows: C:\Program Files\ClaudeCode\CLAUDE.md           │
│     Purpose: Organization-wide mandatory instructions          │
├────────────────────────────────────────────────────────────────┤
│  3. USER MEMORY (~/.claude/CLAUDE.md)                          │
│     Purpose: Your personal global preferences                  │
├────────────────────────────────────────────────────────────────┤
│  4. PROJECT MEMORY (./CLAUDE.md or ./.claude/CLAUDE.md)        │
│     Purpose: Team-shared project instructions                  │
│     + Any imported files via @path/to/file syntax              │
├────────────────────────────────────────────────────────────────┤
│  5. PROJECT RULES (.claude/rules/*.md files)                   │
│     Purpose: Modular, conditionally-loaded rules               │
│     Can be path-scoped with globs in frontmatter               │
├────────────────────────────────────────────────────────────────┤
│  6. LOCAL PROJECT MEMORY (./CLAUDE.local.md)                   │
│     Purpose: Your private project-specific preferences         │
│     Auto-added to .gitignore                                   │
├────────────────────────────────────────────────────────────────┤
│  7. CONVERSATION HISTORY                                       │
│     - All previous user messages                               │
│     - All previous Claude responses                            │
│     - Tool call results (file reads, bash output, etc.)        │
├────────────────────────────────────────────────────────────────┤
│  8. PLAN FILE (if in Plan Mode or exiting Plan Mode)           │
│     Location: Temporary file in project                        │
├────────────────────────────────────────────────────────────────┤
│  9. YOUR CURRENT MESSAGE                                       │
└────────────────────────────────────────────────────────────────┘
```

**Priority Order:** Enterprise Policy > Project Memory > Project Rules > User Memory > Local Memory

---

### 1.2 Persistent vs Ephemeral State

| Component | Persistence | Storage Location | When Loaded | Notes |
|-----------|-------------|------------------|-------------|-------|
| **System Prompt** | Ephemeral | Anthropic servers | Every request | Cannot modify |
| **Enterprise Policy** | Persistent | System directory | Session start | Managed by IT |
| **User Memory** | Persistent | `~/.claude/CLAUDE.md` | Session start | Global prefs |
| **Project Memory** | Persistent | `./CLAUDE.md` | Session start | Git-trackable |
| **Project Rules** | Persistent | `.claude/rules/*.md` | Session start or on-demand | Path-scoped |
| **Local Memory** | Persistent | `./CLAUDE.local.md` | Session start | Auto-gitignored |
| **Conversation History** | Semi-persistent | `~/.claude/projects/` | Session continuation | Lost on /clear |
| **Plan Files** | Temporary | Project directory | Plan mode exit | Survives compaction |
| **Tool Results** | Ephemeral | In-memory context | Current session | Discarded on /clear |
| **Session State** | Session-scoped | Memory | Current session | Resets on exit |

---

### 1.3 What Triggers State Changes

#### New Session Triggers
A new state begins when:
- You run `claude` from a new terminal
- You exit Claude Code completely (Ctrl+D) and restart
- You run `claude --resume <id>` (loads specific past session)
- You run `claude --continue` (loads most recent session)

#### Context Reset Triggers
Context is cleared when:
- `/clear` command - **Wipes conversation history completely**
- New session without `--continue` or `--resume`
- `/compact` - **Summarizes and replaces history** (not a full reset)

#### Compaction Triggers (Context Summarization)
- **Automatic**: When context reaches ~95% of window (200K tokens)
- **Manual**: `/compact [optional instructions]`
- **Result**: History summarized, plan files preserved, CLAUDE.md files reloaded

#### Memory File Reload Triggers
CLAUDE.md files are reloaded:
- On session start
- After `/clear`
- After `/compact`
- When Claude reads files in subdirectories (nested CLAUDE.md discovered)

**IMPORTANT:** `/clear` does NOT reset your usage limits - only conversation context.

---

### 1.4 Context Window Limits

```
┌─────────────────────────────────────────────────────────────┐
│                   200K TOKEN CONTEXT WINDOW                 │
│                  (500K for Enterprise Sonnet 4.5)           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  System Prompt (~5K-10K tokens)          │
│  └──────────────┘                                           │
│                                                             │
│  ┌──────────────┐  CLAUDE.md Files (~1K-5K tokens typical)  │
│  └──────────────┘                                           │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                                                         ││
│  │              CONVERSATION + TOOL RESULTS                ││
│  │                                                         ││
│  │         (This grows with each interaction)              ││
│  │                                                         ││
│  └─────────────────────────────────────────────────────────┘│
│                                                             │
│  ← 95% threshold triggers auto-compact ──────────────────→ │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Check Your Context Usage:** Run `/context` to see breakdown of token usage.

---

### 1.5 Plan Mode Architecture

Plan Mode creates a special workflow with restricted tools:

```
Normal Mode                          Plan Mode
───────────────────────              ───────────────────────
│ Full tool access     │   Shift+    │ READ-ONLY tools only │
│ Can edit files       │   Tab x2    │ Cannot edit files    │
│ Can run commands     │  ────────→  │ Cannot run commands  │
│ No plan file         │             │ Creates plan.md      │
└───────────────────────┘             └───────────────────────┘
                                              │
                                              │ Exit Plan Mode
                                              ▼
                                     ┌───────────────────────┐
                                     │ Plan file preserved   │
                                     │ Loaded into context   │
                                     │ Execution begins      │
                                     └───────────────────────┘
```

**Plan Mode Tools (Read-Only Only):**
- `Read` - View files
- `LS` - List directories
- `Glob` - Search file patterns
- `Grep` - Search content
- `Task` - Research subagents
- `TodoRead/TodoWrite` - Task management

**Key Insight:** Plan files survive `/compact` operations, making them valuable for preserving context during long sessions.

---

### 1.6 Why Claude "Misbehaves" - Root Causes

#### Problem 1: Makes Assumptions / Jumps to Conclusions
**Cause:** Insufficient instructions in CLAUDE.md files  
**Solution:** Add explicit rules:
```markdown
# In your CLAUDE.md
## Workflow Rules
- ALWAYS ask clarifying questions before starting work
- NEVER assume requirements - verify with user
- Create a plan and wait for approval before coding
- Use Plan Mode (Shift+Tab x2) for complex tasks
```

#### Problem 2: Loses Context
**Causes:**
1. Context window filling up → auto-compaction loses details
2. Starting new sessions without `--continue`
3. Not using CLAUDE.md for persistent instructions

**Solutions:**
1. Run `/context` regularly to monitor usage
2. Run `/compact` manually at logical breakpoints
3. Put critical instructions in CLAUDE.md (always reloaded)
4. Use `/clear` between unrelated tasks

#### Problem 3: Doesn't Follow Orders
**Causes:**
1. Instructions buried in conversation (low priority)
2. Conflicting instructions in different CLAUDE.md files
3. Instructions too vague or ambiguous

**Solutions:**
```markdown
# In your CLAUDE.md - use emphatic language
## CRITICAL RULES (MUST FOLLOW)
- YOU MUST ask for approval before making any file changes
- NEVER run destructive commands without confirmation
- ALWAYS show your plan before executing it
```

---

### 1.7 Recommended CLAUDE.md Governance Structure

```
your-project/
├── CLAUDE.md                    # Core project instructions (Git-tracked)
│   ├── @docs/architecture.md    # Import detailed docs
│   └── @docs/code-style.md      # Import style guide
├── CLAUDE.local.md              # Your personal overrides (Git-ignored)
├── .claude/
│   ├── CLAUDE.md                # Alternative location for project memory
│   ├── settings.json            # Tool permissions, model config
│   ├── rules/
│   │   ├── code-style.md        # General code rules
│   │   ├── testing.md           # Testing conventions
│   │   └── api/
│   │       └── security.md      # Path-scoped: only for src/api/**
│   └── commands/
│       ├── plan.md              # /project:plan command
│       └── review.md            # /project:review command
└── docs/
    ├── architecture.md          # Imported by CLAUDE.md
    └── code-style.md            # Imported by CLAUDE.md
```

**Example Governance CLAUDE.md:**
```markdown
# Project Governance - CLAUDE.md

## CRITICAL RULES (MANDATORY)
- YOU MUST ask clarifying questions before starting any task
- YOU MUST present a plan and wait for explicit approval before coding
- NEVER make assumptions about requirements
- NEVER modify files without showing the diff first

## Workflow
1. Read the task/issue completely
2. Ask clarifying questions if anything is ambiguous
3. Use Plan Mode (Shift+Tab x2) for complex tasks
4. Present your implementation plan
5. Wait for user approval
6. Implement in small, reviewable chunks

## Quality Gates
- Run tests after changes: `npm test`
- Run linter: `npm run lint`
- DO NOT commit until all checks pass
```

---

## PART 2: PERMISSION MODES

### 2.1 The Three Modes (Shift+Tab Cycling)

```
Normal Mode (default)
      ↓ Shift+Tab
⏵⏵ Accept Edits On (auto-approves file edits ONLY)
      ↓ Shift+Tab  
⏸ Plan Mode On (read-only, no edits allowed)
      ↓ Shift+Tab
Normal Mode (back to start)
```

You cycle through these three modes with Shift+Tab.

---

### 2.2 What "Accept Edits On" Actually Does

**IMPORTANT CORRECTION:** "Accept edits on" only auto-approves FILE EDITS.

| Mode | File Edits | Bash Commands | MCP Tools | Web Fetch |
|------|-----------|---------------|-----------|-----------|
| **Normal** | Asks | Asks | Asks | Asks |
| **⏵⏵ Accept Edits On** | **AUTO** | Asks | Asks | Asks |
| **⏸ Plan Mode** | Blocked | Blocked | Read-only | Blocked |

This is **by design** for safety - bash commands can be destructive.

---

### 2.3 Configuring Broader Auto-Permissions

If you want more things auto-approved:

**Option 1: Use `/permissions` to add specific tools:**
```
/permissions
# Then add patterns like:
# Bash(git commit:*)
# Bash(npm test:*)
# Bash(npm run:*)
```

**Option 2: Configure in settings.json:**
```json
// .claude/settings.json
{
  "permissions": {
    "allow": [
      "Edit",
      "Write",
      "Bash(npm run:*)",
      "Bash(git add:*)",
      "Bash(git commit:*)"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(git push:*)",
      "Bash(git reset --hard:*)"
    ]
  }
}
```

**Option 3: Dangerous mode (ONLY in containers!):**
```bash
claude --dangerously-skip-permissions
```

---

## PART 3: MODEL CONFIGURATION

### 3.1 Available Model Options

The `/model` command shows **3 options** (not 4):

```
❯ 1. Default (recommended) ✔  Opus 4.5 · Most capable for complex work
  2. Sonnet                   Sonnet 4.5 · Best for everyday tasks
  3. Haiku                    Haiku 4.5 · Fastest for quick answers
```

**Note:** There is NO automatic "Opus for planning, Sonnet for execution" option in the standard menu. You must switch manually.

---

### 3.2 How to Set Models

**You CANNOT set the model in CLAUDE.md** - that's for instructions only.

**Per Session (interactive):**
```
/model
# Select from menu
```

**Per Session (command line):**
```bash
claude --model claude-sonnet-4-5-20250929
claude --model claude-opus-4-5-20251101
claude --model claude-haiku-4-5-20251001
```

**Per Project (settings.json):**
```json
// .claude/settings.json
{
  "model": "claude-sonnet-4-5-20250929"
}
```

**Globally (environment variable):**
```bash
export ANTHROPIC_MODEL="claude-sonnet-4-5-20250929"
# Add to ~/.bashrc or ~/.zshrc for persistence
```

**Manual Research/Execute Pattern:**
1. Select Opus via `/model`
2. Enter Plan Mode (Shift+Tab x2)
3. Do research and planning
4. Exit Plan Mode
5. Switch to Sonnet via `/model`
6. Execute the plan

---

## PART 4: USAGE LIMITS

### 4.1 Token-Based (Not Message-Based)

Limits are **token-based**, not per-message. The "message" counts are estimates for short conversations.

| Plan | Approx Tokens/5hrs | Approx Messages/5hrs | Weekly Limit |
|------|-------------------|---------------------|--------------|
| **Pro** ($20/mo) | ~44K | ~45 chat OR 10-40 CC | 40-80 hours Sonnet |
| **Max 5x** ($100/mo) | ~88K | ~225 chat OR 50-200 CC | 140-280 hrs Sonnet + 15-35 hrs Opus |
| **Max 20x** ($200/mo) | ~220K | ~900 chat OR 200-800 CC | 240-480 hrs Sonnet + 24-40 hrs Opus |

The wide ranges depend on: message length, conversation history size, file attachments, and model used.

---

### 4.2 5-Hour Rolling Window

The 5-hour limit is a **ROLLING WINDOW**, not a fixed time:

- **Starts:** When you send your first message
- **Ends:** Exactly 5 hours later
- **Multiple sessions:** Can overlap

**Example Timeline:**
```
10:30 AM - First message → Window A starts (expires 3:30 PM)
12:15 PM - New conversation → Window B starts (expires 5:15 PM)
 3:30 PM - Window A expires, those tokens freed
 5:15 PM - Window B expires
```

When you see "resets at 7PM" - that's when your **current** rolling window expires, not a fixed daily time.

---

### 4.3 Weekly Rolling Window

The weekly limit is also a **ROLLING 7-DAY WINDOW**:

- Tracks usage over the **past 7 days**
- NOT a fixed "Monday to Sunday" cycle
- As old usage falls outside the 7-day window, capacity frees up

**Example:**
- Monday: Used 20 hours
- Following Monday: Those 20 hours "age out" and become available again

---

### 4.4 How to Check Usage

**In Claude.ai (Web/Desktop):**
- Settings → Usage
- Shows progress bars with exact reset times for both 5-hour and weekly

**In Claude Code:**
```
/status    # Shows remaining capacity, model, context %
/usage     # More detailed breakdown
/cost      # Cumulative cost and token stats
```

---

### 4.5 Cross-Platform Sharing

**IMPORTANT:** Usage is shared across ALL Claude surfaces:

- Claude.ai (web interface)
- Claude Desktop app
- Claude Code (terminal)

All count against the **same limits** for your account.

---

## PART 5: TOKEN VISIBILITY

### 5.1 Commands to See Token Usage

| Command | What It Shows |
|---------|---------------|
| `/context` | Breakdown by category (messages, files, MCP, etc.) |
| `/cost` | Cumulative cost, total tokens, duration |
| `/status` | Model, context %, remaining usage |

**Example `/context` output:**
```
Context usage: 45,234 / 200,000 tokens (23%)
├── System prompt: 8,500
├── CLAUDE.md files: 2,100
├── Conversation: 28,634
├── Tool results: 6,000
└── MCP servers: 0
```

---

### 5.2 Verbose Mode

Toggle with **Ctrl+R** or start with `--verbose`:

```bash
claude --verbose
```

Shows per-response: `6s · 20 tokens · esc to interrupt`

**For more debugging:**
```bash
CLAUDE_DEBUG=1 claude
```

**Third-party tools:**
```bash
npx ccusage          # Detailed token breakdown
npx ccusage --live   # Real-time monitoring
```

---

## PART 6: SYSTEM PROMPT ACCESS

### What You Can Access

**Officially Published (partial):**
- https://docs.claude.com/en/release-notes/system-prompts
- Contains main behavior instructions

**NOT Published:**
- Tool-specific instructions (web search, Claude Code tools)
- Full system prompt is ~120+ pages / 6,000+ tokens

**Ways to See More:**
1. Verbose mode (`--verbose` or Ctrl+R)
2. Debug mode (`CLAUDE_DEBUG=1`)
3. Session transcripts in `~/.claude/projects/`
4. Ask Claude directly (though it's instructed not to reveal everything)

**No "dump full prompt" feature exists.**

---

## PART 7: EXTRA USAGE PRICING

### Extra Usage = Standard API Rates

When you exceed plan limits and enable extra usage, you pay API rates:

| Model | Input (per MTok) | Output (per MTok) |
|-------|------------------|-------------------|
| Haiku 4.5 | $0.80 | $4.00 |
| Sonnet 4.5 | $3.00 | $15.00 |
| Opus 4.5 | $15.00 | $75.00 |

**To Enable:**
1. Settings → Usage → Extra usage section
2. Click "Enable"
3. Set spending cap
4. Configure auto-reload (optional)

**Average Costs:**
- Most developers: ~$6/day
- 90th percentile: ~$12/day
- Heavy Opus users: Can be significantly more

---

## PART 8: KEY COMMANDS REFERENCE

### Session Management
| Command | Effect |
|---------|--------|
| `/clear` | Wipes conversation history (NOT usage limits) |
| `/compact [instructions]` | Summarizes history, keeps plan |
| `/context` | Shows token usage breakdown |
| `/status` | Shows model, context %, remaining usage |
| `/usage` | Detailed usage statistics |
| `/cost` | Cumulative cost and tokens |

### Memory Management
| Command | Effect |
|---------|--------|
| `/memory` | Opens CLAUDE.md in editor |
| `#instruction` | Adds instruction to CLAUDE.md |
| `/init` | Bootstrap CLAUDE.md for project |

### Mode Controls
| Action | Effect |
|--------|--------|
| `Shift+Tab` | Cycle: Normal → Accept Edits → Plan Mode |
| `Escape` | Interrupt Claude |
| `Escape x2` | Edit previous prompt |
| `Ctrl+R` | Toggle verbose mode |
| `Ctrl+O` | Toggle extended thinking visibility |

### Session Continuation
| Command | Effect |
|---------|--------|
| `claude --continue` | Resume last session |
| `claude --resume <id>` | Resume specific session |
| `claude --resume` | Show session picker |

### Model & Permissions
| Command | Effect |
|---------|--------|
| `/model` | Change model (3 options) |
| `/permissions` | Manage tool permissions |
| `claude --model <name>` | Start with specific model |

---

## PART 9: QUICK REFERENCE TABLES

### Root Causes of Common Frustrations

| Issue | Root Cause | Solution |
|-------|------------|----------|
| Makes assumptions | No "stop and ask" instructions | Add explicit rules to CLAUDE.md |
| Jumps to conclusions | Not using Plan Mode | Use Shift+Tab x2 for research first |
| Loses context | Auto-compaction or new sessions | Monitor /context, use /compact strategically |
| Doesn't follow orders | Instructions in conversation, not CLAUDE.md | Put rules in CLAUDE.md with emphasis |
| Still asks permissions | "Accept edits" only covers file edits | Configure /permissions for bash commands |

### Usage Limit Summary

| Limit Type | Window | Reset Behavior |
|------------|--------|----------------|
| 5-hour session | Rolling | From first message |
| Weekly | Rolling 7-day | Oldest usage ages out |
| Context window | Per session | /clear or /compact |

### Mode Comparison

| Mode | File Edits | Bash | Purpose |
|------|-----------|------|---------|
| Normal | Asks | Asks | Default, full control |
| Accept Edits | Auto | Asks | Faster file changes |
| Plan Mode | Blocked | Blocked | Research only |

### Where to Configure What

| Setting | CLAUDE.md | settings.json | Environment | CLI Flag |
|---------|-----------|---------------|-------------|----------|
| Instructions | ✅ | ❌ | ❌ | ❌ |
| Model | ❌ | ✅ | ✅ | ✅ |
| Permissions | ❌ | ✅ | ❌ | ✅ |
| MCP Servers | ❌ | ✅ | ❌ | ✅ |

---

*Document Version: 2.0*  
*Created: January 2026*  
*Based on: Claude Code actual behavior testing + official documentation*
