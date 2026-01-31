# Session History Pruning - Discussion & Decision

> **Decision ID:** #G-SESSION-HISTORY-PRUNING
> **Status:** Approved
> **Date:** 2026-01-31
> **Origin:** fil-bizz startup hang investigation
> **Impacts:** All projects (global hook)
> **Updated:** 2026-01-31

## Table of Contents

| Section | Title                                                          | Line |
|---------|----------------------------------------------------------------|------|
| 1       | [Problem Statement](#1-problem-statement)                     | :22  |
| 2       | [Investigation Trail](#2-investigation-trail)                 | :49  |
| 3       | [Root Cause Analysis](#3-root-cause-analysis)                 | :104 |
| 4       | [Options Considered](#4-options-considered)                   | :143 |
| 5       | [Decision](#5-decision)                                       | :269 |
| 6       | [Implementation](#6-implementation)                           | :319 |
| 7       | [Future Considerations](#7-future-considerations)             | :363 |

---------------------------------------------------------------------------------------------------------------------------

## 1. Problem Statement

### 1.1 Symptom

Claude Code hangs indefinitely when launched from `fil-bizz/` directory. Behavior:
- Startup banner displays normally
- "Flibbertigibbeting..." spinner appears, then freezes
- No error message, no crash output
- Terminal becomes unresponsive (cannot type)
- Only affects `fil-bizz/` — all other project directories work normally
- Status bar shows "2 MCP servers failed" but this is unrelated

### 1.2 Context

- fil-bizz is a business planning project (BIZZ type) containing documents, images, PDFs, pilot studies
- The heavy files (2.8 GB of MP4 videos in `02_Research/03_Pilot_Studies/Evie/Marina B/`) had been present for weeks without issue
- The hang started after the most recent session, which appeared to end normally
- Previous sessions had experienced compaction failures ("Conversation Too Long, Compaction Failed")

---------------------------------------------------------------------------------------------------------------------------

## 2. Investigation Trail

### 2.1 Initial Hypothesis: Large Files (REJECTED)

**Theory:** The 2.8 GB of MP4 files in the project directory were causing Claude Code's indexer to choke.

**Investigation:**
- `du -sh fil-bizz/` → 2.9 GB total
- Traced to `02_Research/03_Pilot_Studies/Evie/Marina B/` → 3 MP4 files (1.0G, 930M, 921M)

**Why rejected:**
- `.gitignore` already blocks `*.mp4` — Claude Code respects `.gitignore` for file picker (`respectGitignore: true` default)
- These files were present for weeks without causing issues
- Something changed in the last session specifically

### 2.2 Second Hypothesis: MCP Servers (REJECTED)

**Theory:** The "2 MCP servers failed" in the status bar might be causing a hang.

**Investigation:**
- No `.mcp.json` in fil-bizz or parent FlowInLife directory
- MCP config comes from global settings/plugins, not project-specific

**Why rejected:**
- MCP failures show in status bar but don't block startup
- Same MCP config applies to all projects, only fil-bizz hangs

### 2.3 Third Hypothesis: Session History Files (CONFIRMED)

**Theory:** Claude Code's internal session `.jsonl` files accumulated to an unsustainable size.

**Investigation:**
- Checked `~/.claude/projects/-Users-mohammadshehata-Desktop-FILICITI-Products-FlowInLife-fil-bizz/`
- Found 7 `.jsonl` files totaling **297 MB**

| Session ID    | Size   | Summary                                    | Messages | Status       |
|---------------|--------|--------------------------------------------|----------|--------------|
| `cdef82da`    | 242 MB | Pilot Studies Analysis & Master Strategy   | 39       | indexed      |
| `91443e25`    | 32 MB  | FlowInLife Pilot Studies PDF: Layout Fixes | 37       | indexed      |
| `3bf6e94c`    | 12 MB  | (unknown)                                  | ?        | **ORPHANED** |
| `971aa6d3`    | 4.5 MB | Conversation Too Long, Compaction Failed   | 5        | indexed      |
| `d3d28048`    | 3.8 MB | Compliance Framework Tone & Structure      | 33       | indexed      |
| `99aad750`    | 2.4 MB | Pilot Migration & Business Plan Foundation | 38       | indexed      |
| `3aae3afd`    | 28 KB  | Session Setup Confirmation                 | 5        | indexed      |

**Key findings:**
1. `cdef82da` at **242 MB for 39 messages** = ~6.2 MB per message average (embedded images/PDFs)
2. `3bf6e94c` is **not in sessions-index.json** — orphaned from a crash
3. `971aa6d3` explicitly summarized as "Conversation Too Long, Compaction Failed"
4. `d3d28048` first prompt was "you crashed mid way and we could not compact"

**Confirmed:** Claude Code hangs on startup trying to parse/index 297 MB of session history.

---------------------------------------------------------------------------------------------------------------------------

## 3. Root Cause Analysis

### 3.1 How Session Files Bloat

```
User asks Claude to read pilot study PDF (1 MB)
    → Claude's Read tool returns file content
    → Content serialized into .jsonl session log (+1 MB)
    → User asks Claude to read 50 images
    → +50 MB to session log
    → Session file grows unbounded
```

The `.jsonl` files are conversation replay logs stored in `~/.claude/projects/{PROJECT_PATH}/`. Every message, tool call, and tool result is serialized. Binary file content (images, PDFs) gets base64-encoded into the log.

### 3.2 The Failure Cascade

```
1. Session accumulates large .jsonl (heavy file reads)
2. Context fills up → compaction triggers
3. Compaction tries to process massive session → fails or crashes
4. Crash leaves orphaned .jsonl (not properly finalized)
5. Next startup scans all .jsonl files → hangs on 297 MB
6. User can't start Claude Code in that directory anymore
```

### 3.3 Why Only fil-bizz?

fil-bizz is document/image-heavy by nature (business planning, pilot studies, PDFs, screenshots). Other projects (code repos) have smaller file reads. The bloat is proportional to how many heavy files Claude reads per session.

### 3.4 Why Now?

The accumulation crossed a threshold. Previous sessions added ~50 MB each. After 6 sessions without cleanup, total hit 297 MB. The tipping point was the 242 MB session that read many pilot study files.

---------------------------------------------------------------------------------------------------------------------------

## 4. Options Considered

### 4.1 `.claudeignore` File (REJECTED)

**Concept:** Create a `.claudeignore` to tell Claude Code to skip heavy directories.

**Why rejected:**
- `.claudeignore` is **deprecated** — Claude Code no longer supports it
- Even when it existed, it only affected file picker, not session log serialization
- The problem isn't indexing the directory — it's the session logs

### 4.2 Global Deny Rules in settings.json (REJECTED)

**Concept:** Add `"deny": ["Read(**/*.mp4)", "Read(**/*.png)", ...]` to prevent reading heavy files.

**Why rejected:**
- Makes files **completely invisible** to Claude Code — too aggressive
- User needs Claude to read images/PDFs for business analysis
- The problem isn't reading files — it's the session log growing unbounded
- Deny rules prevent the tool call, they don't prevent log growth from allowed reads

### 4.3 Run from Parent Directory Only (REJECTED)

**Concept:** Always run Claude Code from `FlowInLife/` parent instead of `fil-bizz/`.

**Why rejected:**
- **Moves the problem, doesn't solve it** — the FlowInLife project hash would accumulate the same bloated session files over time
- Changes workflow without addressing root cause
- User correctly identified: "the same issue will eventually happen but at the root level"

### 4.4 SessionEnd Hook Cleanup (REJECTED)

**Concept:** Delete session `.jsonl` files when the session ends cleanly.

**Why rejected:**
- **SessionEnd never fires on crash** — and crashes are exactly when bloat causes problems
- The sessions that create the most damage are the ones that crash mid-way
- Only handles the happy path

### 4.5 PostToolUse Monitoring (REJECTED)

**Concept:** Check session file sizes after every tool call.

**Why rejected:**
- **Too frequent** — PostToolUse fires 20-30 times per conversation turn
- Excessive disk I/O (running `stat`/`ls` on session dir dozens of times per prompt)
- **User can't act on it mid-turn** — Claude is already processing when the warning appears
- Even filtered to Read-only calls, still fires multiple times per turn

### 4.6 PostToolUse (Read only) + Threshold (SUPERSEDED)

**Concept:** Only check after Read tool calls, only warn above threshold.

**Why superseded by 4.7:**
- Still fires multiple times per turn if Claude reads several files
- Warning appears mid-response — user can't decide whether to continue before Claude acts
- UserPromptSubmit is strictly better: once per turn, before Claude starts working

### 4.7 UserPromptSubmit + Threshold (CHOSEN)

**Concept:** Check total session history size on every user prompt. Silent below threshold, detailed warning above.

**Why chosen:**
- **Once per turn** — exactly one check per user message, no throttling needed
- **Before Claude acts** — user sees warning before committing to the next prompt
- **Actionable** — user can decide to wrap up, delete specific sessions, or continue
- **No false alarms** — silent when total is below threshold
- **Covers mid-session** — fires during the session, not just at start/end

### 4.8 PreCompact Always-Warn (CHOSEN — companion)

**Concept:** Always show session history status before compaction starts.

**Why chosen:**
- **Compaction is when crashes happen** — seeing state right before is critical
- **Fires rarely** — no performance concern
- **Last warning before potential crash** — if current session is already 200 MB when compaction triggers, user knows to wrap up instead
- **Complements 4.7** — UserPromptSubmit catches accumulation, PreCompact catches the danger moment

---------------------------------------------------------------------------------------------------------------------------

## 5. Decision

### 5.1 Strategy: Two-Hook Monitoring with User Control

**Hook 1: UserPromptSubmit** — `check_session_history.sh --threshold 100`
- Fires on every user prompt
- Checks total `.jsonl` size for current project
- Silent below 100 MB threshold
- Above threshold: outputs detailed table with session date, summary, messages, size, status
- User decides action (delete specific sessions, wrap up, or continue)

**Hook 2: PreCompact** — `check_session_history.sh --always`
- Fires before every compaction
- Always outputs the detailed table regardless of size
- Gives user last chance to assess before compaction (which is where crashes happen)

### 5.2 Output Format

```
⚠️ SESSION HISTORY: 297 MB (threshold: 100 MB)
📁 Project: fil-bizz

| #   | Date             | Summary                                | Msgs | Size   | Status  |
|-----|------------------|----------------------------------------|------|--------|---------|
| 1   | 2026-01-20 02:38 | Pilot Studies Analysis & Master St...  | 39   | 242 MB | indexed |
| 2   | 2026-01-30 04:22 | FlowInLife Pilot Studies PDF: Layo...  | 37   | 32 MB  | indexed |
| 3   | 2026-01-30 20:56 | (not in index)                         | ?    | 12 MB  | ORPHAN  |

💡 Action: Ask Claude to delete sessions by number, or "wrap up" to end cleanly.
```

### 5.3 Design Principles

1. **User stays in control** — hook only warns, never auto-deletes
2. **Detailed visibility** — shows exactly what's consuming space and why
3. **Silent when healthy** — no noise below threshold
4. **Global scope** — applies to all projects, not just fil-bizz
5. **Crash-resilient** — works during the session (not just at end)

### 5.4 What the Hook Cannot Do

- Cannot truncate the **current** session's `.jsonl` — would corrupt the running session
- Cannot prevent a single session from bloating — that's a Claude Code internal behavior
- Cannot auto-delete without user consent — governance principle

### 5.5 User Workflow When Warning Appears

1. See warning with detailed session list
2. Option A: Tell Claude "delete session #1 and #3" → Claude deletes specific old `.jsonl` files
3. Option B: "wrap up" → clean session end, then delete history in next session
4. Option C: Continue working (acknowledge the risk)

---------------------------------------------------------------------------------------------------------------------------

## 6. Implementation

### 6.1 Files Created/Modified

| File                                              | Action   | Purpose                          |
|---------------------------------------------------|----------|----------------------------------|
| `Governance/scripts/check_session_history.sh`     | Created  | The monitoring hook script       |
| `~/.claude/settings.json`                         | Modified | Added UserPromptSubmit +         |
|                                                   |          | PreCompact hook entries          |
| `Governance/HOOKS_ARCHITECTURE_v3.3.md`           | Modified | Added hook #11 documentation     |

### 6.2 Cleanup Performed

- Deleted all `.jsonl` files in fil-bizz project cache (~297 MB)
- Reset `sessions-index.json` for fil-bizz
- Deleted orphaned session subdirectories

### 6.3 Configuration

- **Threshold:** 100 MB (configurable via script argument)
- **Scope:** Global (in `~/.claude/settings.json`, applies to all projects)
- **Script location:** `~/Desktop/FILICITI/Governance/scripts/check_session_history.sh`

---------------------------------------------------------------------------------------------------------------------------

## 7. Future Considerations

### 7.1 For Next Governance Version (v3.4+)

- Consider adding session history size to **status bar** (alongside context and duration)
- Consider **auto-archiving** old sessions (compress + move instead of delete)
- Consider **per-project thresholds** (BIZZ projects may need lower thresholds than CODE)
- Investigate if Claude Code will add native session size management

### 7.2 Known Limitations

- The current session's `.jsonl` cannot be pruned while running
- If a single session exceeds the threshold, the warning fires but the user can only wrap up
- The threshold is global — some projects may hit it sooner than others
- Session file size correlates with file reads, not conversation length — 39 messages produced 242 MB

### 7.3 Related Decisions

- `#I24` Large File Handling — `.gitignore` rules for binary files
- `#I25` Pre-Commit Large File Check — file size check before git commit

---------------------------------------------------------------------------------------------------------------------------

*Decision: #G-SESSION-HISTORY-PRUNING | Template: ~/.claude/templates/DOCUMENT_FORMAT-TEMPLATE.md | v3.3*
