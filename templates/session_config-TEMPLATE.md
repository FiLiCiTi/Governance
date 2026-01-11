---
# Session Configuration - [Project Name]
project_type: CODE  # CODE, BIZZ, or OPS
checkpoint_interval: 90  # minutes (60-90 recommended)
---

# Session Configuration

> This file customizes session handoff behavior for this project.
> Location: `{project}/.claude/session_config.md`
> Optional: If missing, global defaults from `~/.claude/templates/session_handoff.md` are used.

## Handoff Template Overrides

### Section III: State Snapshot (Custom Fields)

**For CODE projects**:
- Test coverage: [Run `npm run coverage` to get %]
- Build status: [passing/failing]
- Linting errors: [Run `npm run lint` for count]
- Active feature flags: [List from config/feature-flags.json]
- Database migration version: [Current migration number]
- Deployment environment: [development/staging/production]

**For BIZZ projects**:
- OKR progress: [percentage toward quarterly goals]
- Stakeholder status: [list of stakeholder approvals]
- Budget tracking: [spent vs allocated]
- Timeline status: [on track / delayed]

**For OPS projects**:
- Service uptime: [percentage]
- Incident count: [number since last session]
- Backup status: [last backup timestamp]
- Monitoring alerts: [active alert count]

### Section VIII: Project-Type-Specific (Custom Fields)

**For CODE projects**:
- Technical debt items: [list from backlog]
- Refactor targets: [components needing cleanup]
- Performance bottlenecks: [profiled slowdowns]

**For BIZZ projects**:
- Market research findings: [key insights]
- Competitive analysis: [changes in landscape]
- Customer feedback: [themes from surveys]

**For OPS projects**:
- Infrastructure costs: [current spend vs budget]
- Deployment frequency: [count this month]
- Mean time to recovery: [hours]

## Plugin Configuration

### Always Enable
- hookify (warmup status monitoring)
- [plugin-name] ([reason needed])

### Always Disable
- explanatory-output-style (high token cost)
- [plugin-name] ([reason not needed])

### Enable on Demand
- frontend-design (only when building UI)
- stripe (only when working on payment features)
- [plugin-name] ([when to use])

### Plugin-Specific Settings

**[plugin-name]**:
- [setting-key]: [value]
- [setting-key]: [value]

## Custom Workflows

### Session Start
```bash
# Commands to run at session start
# Example:
# Verify environment variables loaded
# Check database connection
# Pull latest from main branch
# Run migrations if needed
```

### Before Checkpoint
```bash
# Commands to run before checkpoint
# Example:
# Run tests: npm test
# Check linting: npm run lint
# Verify build: npm run build
```

### Before Finalize
```bash
# Commands to run before finalize
# Example:
# Run full test suite: npm run test:all
# Update CHANGELOG.md
# Verify all TODOs resolved or documented
# Push to remote branch
```

### Monthly Archive
```bash
# Commands to run during archival
# Example:
# Generate code metrics: npm run metrics
# Export test coverage report
# Archive metrics with handoffs
```

## Project-Specific Rules

### Code Style
- [Style rule 1]
- [Style rule 2]

### Testing Requirements
- [Testing rule 1]
- [Testing rule 2]

### Git Workflow
- Branch naming: [pattern]
- Commit message format: [pattern]
- [Other git rules]

### Deployment
- [Deployment rule 1]
- [Deployment rule 2]

## Environment Variables

**Required for local development**:
```bash
# Copy to .env and fill in values
VARIABLE_NAME=[description or source]
```

**Optional**:
```bash
# Optional environment variables
OPTIONAL_VAR=[description]
```

## Troubleshooting

### Common Issues

**Issue 1**:
```bash
# Problem description
# Solution commands
```

**Issue 2**:
```bash
# Problem description
# Solution commands
```

## Notes

- [Project-specific note 1]
- [Project-specific note 2]

---------------------------------------------------------------------------------------------------------------------------

*Template: ~/Desktop/Governance/templates/session_config_TEMPLATE.md*
*Copy to: {project}/.claude/session_config.md*
*Customize sections as needed for your project*
