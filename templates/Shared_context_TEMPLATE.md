# Shared Context - Portfolio View

> **Last updated:** YYYY-MM-DD
> **Active projects:** [N]
> **Portfolio owner:** [Your name]

## I. Active Projects

| Project     | Type | Version | Status | Last Session | Next Priority           |
|-------------|------|---------|--------|--------------|-------------------------|
| Governance  | OPS  | v3      | Active | 2026-01-09   | Complete v3 spec        |
| MyWebApp    | CODE | v3      | Active | 2026-01-08   | Deploy auth feature     |
| MobileApp   | CODE | v2.5    | Paused | 2025-12-20   | Resume UI work          |
| Marketing   | BIZZ | v2.5    | Paused | 2025-11-15   | Q1 strategy review      |

**Legend**:
- **Active**: Currently being worked on
- **Paused**: Temporarily stopped (planned resume)
- **Blocked**: Waiting on external dependency
- **Archived**: Completed or abandoned

## II. Cross-Project Blockers

### Shared Dependencies

**[Dependency 1]**:
- Affects: [Project A, Project B]
- Blocker: [What is blocking]
- Impact: [Description of impact]
- Workaround: [If available]
- ETA: [Expected resolution date]

**[Dependency 2]**:
- Affects: [Project C]
- Blocker: [What is blocking]
- Impact: [Description of impact]
- Workaround: [If available]
- ETA: [Expected resolution date]

### Resource Conflicts

**[Resource 1]**:
- Shared across: [Projects]
- Current usage: [Percentage or metric]
- Impact: [Description]
- Resolution: [Action needed] ([Decision ID])

**[Resource 2]**:
- Shared across: [Projects]
- Current usage: [Percentage or metric]
- Impact: [Description]
- Resolution: [Action needed] ([Decision ID])

## III. Recent Decisions (Cross-Project)

| ID   | Date       | Decision                        | Affects          | Status      |
|------|------------|---------------------------------|------------------|-------------|
| #G12 | 2026-01-09 | Adopt v3 governance             | All projects     | Implementing|
| #I25 | 2026-01-07 | Upgrade API tier                | All projects     | Approved    |
| #I5  | 2026-01-05 | Migrate to Backblaze            | Governance       | Pending     |
| #S3  | 2025-12-20 | Enforce 2FA                     | All CODE projects| Implemented |
| #P14 | 2025-12-15 | Unified code review process     | All CODE projects| Implemented |

## IV. Shared Resources

### Common Utilities

**Template repository**: `~/Desktop/Governance/templates/`
- CLAUDE.md templates (CODE, BIZZ, OPS)
- session_handoff.md (v3 template)
- session_config_TEMPLATE.md
- CONTEXT_TEMPLATE.md
- Shared_context_TEMPLATE.md

**Automation scripts**: `~/Desktop/Governance/scripts/`
- Session management (create, checkpoint, finalize, archive)
- Governance setup (symlinks, structure)
- Validation tools (project compliance)

**Documentation**: `~/Desktop/Governance/`
- v3_FULL_SPEC.md (this document)
- CLAUDE_CODE_DOCS.md (Claude Code reference)
- CLAUDE_PLUGINS_REFERENCE.md (plugin documentation)

### Shared Infrastructure

**Services**:
- Database: [Database type and location]
- Storage: [Storage service and account]
- CI/CD: [CI/CD platform]
- Monitoring: [Monitoring service]

**Credentials** (stored in):
- [Credential manager]: [Vault or location]
- Environment variables: Per-project .env files (not committed)

**Cost tracking**:
- Monthly infrastructure: ~$[amount]/month
- Breakdown by project:
  - [Project 1]: $[amount] ([services])
  - [Project 2]: $[amount] ([services])
  - [Project 3]: $[amount] ([services])

## V. Monthly Summary

### [Current Month] (Current)

**Completed**:
- [Project]: [What was completed]
- [Project]: [What was completed]

**In Progress**:
- [Project]: [Current work] ([% complete])
- [Project]: [Current work] ([% complete])

**Planned**:
- [Project]: [What is planned]
- [Project]: [What is planned]

**Blockers addressed**:
- Resolved: [Blocker description]
- Ongoing: [Blocker description]

**Metrics**:
- Total sessions: [count] across all projects
- Total duration: ~[hours] hours
- Commits: [count]
- Decisions: [count] ([list decision IDs])

### [Previous Month -1]

**Completed**:
- [Project]: [What was completed]
- [Project]: [What was completed]

**Metrics**:
- Total sessions: [count]
- Total duration: ~[hours] hours
- Commits: [count]

### [Previous Month -2]

**Completed**:
- [Project]: [What was completed]

**Metrics**:
- Total sessions: [count]
- Total duration: ~[hours] hours

[Keep current + last 3 months. Archive older summaries.]

## VI. Portfolio Metrics

**Session activity** (last 30 days):
- Total sessions: [count]
- Active projects: [count] ([list names])
- Average session duration: [minutes]
- Checkpoint frequency: [average per session]

**Context health**:
- ✅ Fresh (< 7 days): [Project 1, Project 2]
- ⚠️ Stale (7-30 days): [Project 3]
- 🔴 Inactive (>30 days): [Project 4]

**Archive size**:
- Total across all projects: [GB]
- By project:
  - [Project 1]: [GB]
  - [Project 2]: [GB]
  - [Project 3]: [GB]

**Decision count** (all time):
- Governance (#G): [count]
- Infrastructure (#I): [count]
- Security (#S): [count]
- Process (#P): [count]
- Backup (#B): [count]

## VII. Notes

**Project relationships**:
- [Relationship 1: e.g., "Governance is master project containing templates"]
- [Relationship 2: e.g., "MyWebApp and MobileApp share auth backend"]
- [Relationship 3]

**Upcoming portfolio changes**:
- [ ] [Planned change 1]
- [ ] [Planned change 2]
- [ ] [Planned change 3]

**Portfolio health assessment**:
- **Good**: [What is working well]
- **Attention needed**: [What needs focus]
- **Archive candidate**: [Projects to potentially archive]
- **Overall**: [General portfolio health summary]

---------------------------------------------------------------------------------------------------------------------------

**Next portfolio review**: YYYY-MM-DD
**Last archived**: YYYY-MM-DD (moved [year] summaries to archive)

---------------------------------------------------------------------------------------------------------------------------

*Template: ~/Desktop/Governance/templates/Shared_context_TEMPLATE.md*
*Usage: Create as `~/.claude/Shared_context.md`*
*Update: After major milestones or monthly*
*Optional: Only needed for 3+ projects*
