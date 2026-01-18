# Context - [Project Name]

> **Type:** [CODE/BIZZ/OPS]
> **Last updated:** YYYY-MM-DD
> **Status:** [Active/Paused/Blocked]

## I. Current State

**Phase**: [Planning/Development/Testing/Deployed]

**Progress**: [One-paragraph summary of where the project stands now]

**Key metrics**:
- [Metric 1]: [Value]
- [Metric 2]: [Value]
- [Metric 3]: [Value]

**Last milestone**: [What was recently completed]

**Current focus**: [What is being worked on now]

## II. Progress Summary

### Completed
- [Feature 1] - [Completion date]
- [Feature 2] - [Completion date]
- [Bug fix 1] - [Completion date]

### In Progress
- [Feature 3] - [Started date] - [Current status %]
- [Refactor 1] - [Started date] - [Blocker if any]

### Pending
- [Feature 4] - [Planned for]
- [Feature 5] - [Depends on X]

## III. Active Work

> **Implementation tracking:** See [implementation/IMPLEMENTATION_REGISTRY.md](implementation/IMPLEMENTATION_REGISTRY.md) for complete status
>
> This section provides high-level summary. Registry has detailed tracking and workflow status.

**Current sprint/phase**: [Name or number]

**Active work items**:

1. **[Work item 1 title]**
   - Status: [In progress/Blocked]
   - Started: [Date]
   - Details: [Description]
   - Files: [Relevant file paths]

2. **[Work item 2 title]**
   - Status: [In progress]
   - Started: [Date]
   - Details: [Description]
   - Files: [Relevant file paths]

## IV. Decisions & Architecture

### Recent Decisions

| ID   | Date       | Decision                     | Rationale                      | Impact           |
|------|------------|------------------------------|--------------------------------|------------------|
| #I20 | 2026-01-05 | Use PostgreSQL               | JSON support, better tools     | All data layer   |
| #S5  | 2026-01-03 | Enforce 2FA                  | Security compliance            | All users        |
| #P13 | 2025-12-28 | Weekly code reviews          | Quality improvement            | Dev workflow     |

### Architecture Notes

**System design**:
[High-level architecture description or link to architecture doc]

**Key patterns**:
- [Pattern 1]: [Where used]
- [Pattern 2]: [Where used]

**Tech stack**:
- Frontend: [Technologies]
- Backend: [Technologies]
- Database: [Technologies]
- Deployment: [Platform]

## V. Blockers & Risks

### Current Blockers

**Blocker 1**: [Description]
- Impact: [High/Medium/Low]
- Blocked since: [Date]
- Waiting on: [What needs to happen]
- Workaround: [If available]

### Risks

**Risk 1**: [Description]
- Probability: [High/Medium/Low]
- Impact: [High/Medium/Low]
- Mitigation: [Plan]

### Resolved Blockers (Last 30 days)

| Date Resolved | Blocker                          | Resolution                     |
|---------------|----------------------------------|--------------------------------|
| 2026-01-08    | Missing API key                  | Obtained from admin            |
| 2026-01-05    | Test flakiness                   | Fixed timing issues            |

## VI. Roadmap

### Immediate Next Steps
1. [Action 1] - [For next session]
2. [Action 2] - [This week]
3. [Action 3] - [This week]

### Short-term Goals (This Month)
- [Goal 1]
- [Goal 2]
- [Goal 3]

### Long-term Vision (This Quarter)
- [Vision item 1]
- [Vision item 2]

### Future Considerations
- [Idea 1] - [Why deferred]
- [Idea 2] - [Depends on X]

## VII. Session History

| Date       | Handoff File                                                                   | Summary                             | Duration |
|------------|--------------------------------------------------------------------------------|-------------------------------------|----------|
| 2026-01-09 | [20260109_1430_auth-feature.md](session_handoffs/20260109_1430_auth-feature.md) | Completed JWT authentication        | 90min    |
| 2026-01-08 | [20260108_1000_bugfix-login.md](session_handoffs/20260108_1000_bugfix-login.md) | Fixed login edge case               | 60min    |
| 2026-01-05 | [20260105_1500_api-refactor.md](session_handoffs/20260105_1500_api-refactor.md) | Refactored API layer                | 120min   |

[Keep last 10 sessions. Archive older ones monthly to archive/YYYY/MM/CONTEXT_YYYYMM.md]

---------------------------------------------------------------------------------------------------------------------------

**Archived contexts**:
- [CONTEXT_202512.md](session_handoffs/archive/2025/12/CONTEXT_202512.md) - December 2025
- [CONTEXT_202511.md](session_handoffs/archive/2025/11/CONTEXT_202511.md) - November 2025

---------------------------------------------------------------------------------------------------------------------------

*Template: ~/Desktop/Governance/templates/CONTEXT_TEMPLATE.md*
*Usage: Create as `{project}/CONTEXT.md`*
*Update: Every checkpoint and finalize*
*Archive: Monthly (copy to archive/YYYY/MM/CONTEXT_YYYYMM.md)*
