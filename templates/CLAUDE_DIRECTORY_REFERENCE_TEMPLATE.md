# Directory Reference - [Project/Monorepo Name]

> **Purpose:** Help Claude navigate complex folder structures
> **Created:** YYYY-MM-DD
> **Last Updated:** YYYY-MM-DD

## Overview

[Brief description of the codebase structure]

**Repository type**: [Monorepo / Multi-repo / Single project]
**Products**: [List main products or components]
**Total projects**: [Number]

## Structure

```
[root]/
├── [folder1]/              ← [Description] (Type: CODE/BIZZ/OPS)
│   ├── [subfolder]/
│   └── [files]
├── [folder2]/              ← [Description] (Type: CODE/BIZZ/OPS)
│   ├── [subfolder]/
│   └── [files]
├── [shared]/               ← [Shared utilities/libraries]
└── [docs]/                 ← [Documentation] (Type: BIZZ)
```

**Example**:
```
monorepo/
├── products/
│   ├── web/          ← React frontend (Type: CODE)
│   ├── api/          ← Node.js backend (Type: CODE)
│   └── mobile/       ← React Native app (Type: CODE)
├── shared/
│   └── utils/        ← Shared libraries
└── docs/             ← Product documentation (Type: BIZZ)
```

## Boundaries

**Global rules** (apply to all projects):
- CANNOT modify: `.git/`, `node_modules/`, `venv/`, `__pycache__/`
- Read-only: `[shared folders]`

**Per-project rules**:

### [Project 1 name]
- **CAN modify**: `[paths]`
- **CANNOT modify**: `[paths]`
- **Read-only**: `[paths]`

### [Project 2 name]
- **CAN modify**: `[paths]`
- **CANNOT modify**: `[paths]`
- **Read-only**: `[paths]`

## Naming Conventions

**Branches**:
- Feature: `feature/[project-name]/[description]`
- Bugfix: `bugfix/[project-name]/[description]`
- Release: `release/[version]`

**CLAUDE.md location**:
- Root: `[root]/CLAUDE.md`
- Projects: `[root]/[project]/CLAUDE.md`

**Session handoffs**:
- Location: `[project]/session_handoffs/`
- Naming: `YYYYMMDD_HHMM_[topic].md`

**CONTEXT.md**:
- Location: `[project]/CONTEXT.md`

## Project Relationships

**Dependencies**:
- [Project A] depends on [Project B] for [reason]
- [Project C] provides [service] to [Project D]

**Shared resources**:
- [Resource 1]: Used by [projects]
- [Resource 2]: Used by [projects]

## Git Strategy

**Repository layout**:
- Main repo: `[url]` (contains [what])
- [Project 1] repo: `[url]` (shareable)
- [Project 2] repo: `[url]` (shareable)

**Branch protection**:
- `main`: Protected (requires PR)
- `dev`: Integration branch
- Feature branches: Created from `dev`

## Common Paths

**Frequently modified**:
- [Path 1]: [What it contains]
- [Path 2]: [What it contains]

**Reference only**:
- [Path 1]: [What it contains]
- [Path 2]: [What it contains]

**Generated/Ignored**:
- `node_modules/`: Dependencies (not tracked)
- `build/`: Build output (not tracked)
- `dist/`: Distribution files (not tracked)

## Special Folders

**[Folder name]**:
- Purpose: [What it's for]
- Managed by: [Who/what maintains it]
- Modify: [Yes/No/With approval]

**[Folder name]**:
- Purpose: [What it's for]
- Managed by: [Who/what maintains it]
- Modify: [Yes/No/With approval]

## Navigation Examples

### "Add authentication"

Without directory reference:
```
User: "Add authentication"
Claude: "Where should I add it? Project A? Project B? Both?"
```

With directory reference:
```
User: "Add authentication"
Claude: "I see this is a monorepo. Authentication should be:
  - API: products/api/src/auth/ (backend logic)
  - Web: products/web/src/components/Login/ (UI)
  - Shared: shared/utils/auth-helpers/ (validation)

  Should I proceed with all three?"
```

### "Update the pricing model"

```
Claude reads directory reference:
- Pricing logic: products/api/src/pricing/
- Pricing UI: products/web/src/pages/Pricing/
- Business docs: docs/business/pricing-strategy.md
```

## Changelog

| Date       | Change                              | By      |
|------------|-------------------------------------|---------|
| YYYY-MM-DD | Initial creation                    | [Name]  |
| YYYY-MM-DD | [Description of change]             | [Name]  |

---------------------------------------------------------------------------------------------------------------------------

*Template: ~/Desktop/Governance/templates/CLAUDE_DIRECTORY_REFERENCE_TEMPLATE.md*
*Usage: Create as `[root]/CLAUDE_DIRECTORY_REFERENCE_v2.md`*
*Link from root CLAUDE.md for Claude to reference*
