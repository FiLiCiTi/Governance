---
project: [Auto-filled from CLAUDE.md]
type: [CODE/BIZZ/OPS]
session_date: YYYY-MM-DD
session_start: HH:MM
session_end: HH:MM (filled at finalize)
status: in_progress (changes to "finalized" at end)
---

# Session Handoff - [Topic]

## I. Session Metadata

| Field        | Value                  |
|--------------|------------------------|
| Project      | [Project name]         |
| Type         | [CODE/BIZZ/OPS]        |
| Date         | YYYY-MM-DD             |
| Start time   | HH:MM                  |
| End time     | HH:MM (at finalize)    |
| Duration     | [Calculated at finalize] |
| Claude model | [claude-sonnet-4-5]    |
| Session ID   | [From ~/.claude/sessions/] |

## II. Work Summary

### Completed
- [ ] [Item 1]
- [ ] [Item 2]

### In Progress
- [ ] [Item 1]
- [ ] [Item 2]

### Pending
- [ ] [Item 1]
- [ ] [Item 2]

## III. State Snapshot

**Current phase**: [Planning/Development/Testing/Deployed]

**Key metrics**:
- [Metric 1]: [Value]
- [Metric 2]: [Value]

**Environment state**:
- Branch: [git branch name]
- Commit: [git hash]
- Dependencies: [Up to date / needs update]

## IV. Changes Detail

### Code Changes

**Files modified**:
```
src/file.ts:45 - [Description of change]
src/file2.ts:123 - [Description of change]
tests/file.test.ts - [Description of change]
```

**Commits**:
- [abc1234] feat: [Description]
- [def5678] test: [Description]
- [ghi9012] Checkpoint: [Description]

### Documentation Changes
- [Documentation update 1]
- [Documentation update 2]

### Configuration Changes
- [Config change 1]
- [Config change 2]

## V. Blockers & Risks

### Current Blockers
- None

### Risks
- None

### Resolved This Session
- **Blocker**: [Description]
  - **Resolution**: [How it was resolved]
  - **When**: [timestamp]

## VI. Next Steps

### Immediate (Next Session)
1. [Next action 1]
2. [Next action 2]
3. [Next action 3]

### Short-term (This Week)
- [Goal 1]
- [Goal 2]

### Long-term
- [Vision item 1]
- [Vision item 2]

## VII. Context Links

**Related files**:
- CONTEXT.md - Overall project state
- CLAUDE.md - Project boundaries and rules
- .claude/session_config.md - Custom configuration

**Related sessions**:
- Previous: session_handoffs/YYYYMMDD_HHMM_[topic].md
- Next: [Will be created next session]

**External references**:
- [Link to PR, issue, docs, etc.]

## VIII. Project-Type-Specific

### For CODE Projects

**Implementation progress**:
- Active I-numbers: [I###, I###] (if using Code Documentation System)
- Bugs encountered: [G###, G###] (if applicable)
- Phase/Sprint: [Current phase and sprint status]

**Technical debt identified**:
- [Issue 1]
- [Issue 2]

**Performance notes**:
- [Metric]: [Value]
- [Observation]

**Dependencies updated**:
- [package]: [old version] → [new version]

**Documentation updates** (if applicable):
- ARCHITECTURE.md: [Section updated]
- Implementation docs: [I###-*.md files created/updated]
- Educational docs: [E###-*.md if created]

### For BIZZ Projects

**Strategic decisions**:
- [Decision with rationale]

**Stakeholder updates**:
- [Who was informed of what]

**Market research**:
- [Key findings]

### For OPS Projects

**Operational metrics**:
- Uptime: [percentage]
- Incident count: [number]

**Infrastructure changes**:
- [What was modified]

**Runbook updates**:
- [Which procedures changed]

## IX. Plugin Cost Summary

**Active plugins** (start of session):
- [plugin-name]: ~[tokens] tokens
- Total: ~[total] tokens overhead

**Active plugins** (end of session):
- [plugin-name]: ~[tokens] tokens
- Total: ~[total] tokens overhead

**Recommendation for next session**:
- [Plugin management recommendations]

## X. Session Quality Metrics (Optional)

| Metric                | Value                                |
|-----------------------|--------------------------------------|
| Warmup checks         | [count] ([status] → [status] → ...) |
| Checkpoints           | [count]                              |
| Context calibrations  | [count] ([actual tokens])            |
| Errors encountered    | [count]                              |
| Rollbacks needed      | [count]                              |

## XI. Handoff Notes

**For next Claude**:

Context loaded from this session:
- Read CONTEXT.md (Layer 6) - shows [summary]
- Review Section VI: Next Steps - [priority action]
- Note Section V: [Blockers status]

Key context to remember:
- [Important context item 1]
- [Important context item 2]
- [Important context item 3]

Working patterns that worked well:
- [Pattern 1]
- [Pattern 2]

Avoid:
- [Anti-pattern 1]
- [Anti-pattern 2]

## XII. Appendix (Optional)

### Error Logs
[Paste relevant error output if debugging occurred]

### Research Notes
[Links or summaries of documentation consulted]

### Code Snippets
[Important code samples for reference]

---------------------------------------------------------------------------------------------------------------------------

**Session finalized**: [YYYY-MM-DD HH:MM]
**Total duration**: [X hours Y minutes]
**Next session priority**: [Brief summary from Section VI]
