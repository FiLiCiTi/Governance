# Zombie Process Incident — 2026-02-02

> **Type:** Technical Issue
> **Severity:** High (system performance impact)
> **Date:** 2026-02-02 17:07
> **Resolution:** Immediate kill

---

## Issue Summary

Three orphaned Claude Code processes consumed 98% CPU each for 37+ hours, causing laptop to run at 99% CPU utilization despite no active work.

---

## Technical Details

**Discovered processes:**
```
PID    CPU%   Runtime      Terminal  Status
56267  98.5%  2243min (37h) s007     Running (zombie)
46258  98.2%  2287min (38h) s002     Running (zombie)
48422  98.0%  2281min (38h) s004     Running (zombie)
```

**System impact:**
- CPU: 67% user + 17% sys = 84% busy, only 14% idle
- Duration: Processes started ~Saturday 5-6 AM, discovered Sunday 5 PM
- Heat: Laptop thermal throttling likely
- Battery: Significant drain if unplugged

---

## What Are Zombie Processes?

**Definition:**
A "zombie process" (more accurately: runaway/orphaned process) is a process that:
1. Was started normally but lost connection to its parent
2. Continues running in infinite loop
3. Consumes resources (CPU/memory) indefinitely
4. Cannot be stopped by normal exit commands (requires `kill -9`)

**How they happen in Claude Code:**
- Session crashes/exits without cleanup
- Terminal closed while agent running
- Network disconnection during API call
- Hook script failure causing infinite retry loop
- Process spawned but parent dies

**Why they're hard to detect:**
- Run in background terminals (s002, s004, s007)
- No visible UI feedback
- macOS doesn't auto-kill orphaned processes
- `top` command needed to discover them

---

## Root Cause Analysis

**Likely trigger:**
Session from Saturday morning (5-6 AM) terminated abnormally:
- Terminal window closed while agents running? OR
- Claude Code crash during hook execution? OR
- Network timeout during API call?

**Why 3 processes:**
- Multiple Claude sessions running simultaneously (fil-bizz, fil-yuta, fil-app)
- Each got orphaned when parent session crashed
- All entered CPU-burning infinite loop

**Why 98% CPU each:**
- Likely stuck in hook script retry loop
- Or stuck waiting for API response that never comes
- Or infinite error handling loop

---

## Resolution

**Immediate fix:**
```bash
kill -9 56267 46258 48422
```

**Result:**
- CPU dropped: 99% → 42% (57% idle)
- System responsive immediately
- No data loss (processes were orphaned, not doing useful work)

---

## Prevention Strategies

### 1. Regular Process Audits

**Weekly check:**
```bash
ps aux | grep claude | grep -v grep
```

**Look for:**
- Multiple `claude` processes with high CPU time
- Processes in terminals you're not using (s002, s003, etc.)
- Runtime >60 minutes for idle sessions

**Action:** Kill any suspicious high-CPU claude processes

### 2. Clean Session Exits

**Always exit Claude properly:**
- Use "wrap up" command before quitting
- Wait for session handoff to complete
- Don't force-quit terminal during active work
- Don't close terminal with Cmd+W during agent execution

**Bad practices to avoid:**
- Closing terminal while agents running
- Force quitting Claude Code (Cmd+Q)
- Killing terminal process externally
- Hard shutdown/restart during sessions

### 3. Session Lifecycle Management

**At session start:**
```bash
ps aux | grep claude | grep -v grep
# Kill any old sessions before starting new
```

**During session:**
- Monitor agent completion before starting new tasks
- Don't launch >2 background agents simultaneously
- Check CPU periodically: `top -l 1 | grep "CPU usage"`

**At session end:**
- "wrap up" command
- Verify agents completed: check output files
- Close terminal properly

### 4. Automated Cleanup

**Option A: Daily cron job**
```bash
# Kill claude processes >8 hours old
# Add to crontab: 0 */8 * * * /path/to/cleanup.sh
```

**Option B: Login hook**
```bash
# ~/.zshrc or ~/.bash_profile
# Kill zombie claude on shell start
pkill -9 -f "claude.*[0-9]{4}min"
```

**Option C: Manual alias**
```bash
alias claude-cleanup='ps aux | grep claude | grep -v grep | awk "{if(\$10>480) print \$2}" | xargs kill -9'
```

### 5. Monitoring

**Set up alerts:**
- macOS Activity Monitor: Set alert for >90% CPU sustained >10min
- Use `iStat Menus` or similar: CPU/temp monitoring in menu bar
- Background script: check every 30min, notify if claude >80% CPU

**Dashboard check:**
```bash
# Quick health check
echo "Claude processes:"; ps aux | grep claude | grep -v grep | wc -l
echo "High CPU processes:"; ps aux | awk '$3 > 80 {print $2, $11, $3"%"}'
```

---

## Lessons Learned

1. **Multiple sessions = multiplied risk**
   - 3 projects × 1 crash = 3 zombie processes
   - Consider consolidating work into single session

2. **Background agents need monitoring**
   - No built-in timeout for runaway agents
   - Manual checks required during long operations

3. **Terminal hygiene matters**
   - Don't close terminals casually
   - Always check for running processes first

4. **CPU is early warning sign**
   - 99% CPU when "nothing running" = zombie processes
   - Check immediately, don't wait

5. **Hooks can cause infinite loops**
   - 12 hooks × failed tool call = potential spiral
   - Consider reducing hook count for stability

---

## Action Items

- [ ] Add weekly `ps aux | grep claude` to workflow
- [ ] Create `claude-cleanup` alias in shell config
- [ ] Document "wrap up" importance in governance
- [ ] Consider reducing active hook count (12 → 6-8)
- [ ] Set up CPU monitoring alert (>90% sustained)
- [ ] Test session crash recovery behavior
- [ ] Add "check for zombies" to session start checklist

---

## References

- Process IDs: 56267, 46258, 48422
- Discovery time: 2026-02-02 17:07
- Session context: 201 MB (threshold warning active)
- Active work: Image audit Batch 2 completing

---

*Incident documented: 2026-02-02 17:10*
*For governance: ~/Desktop/FILICITI/Governance/*
