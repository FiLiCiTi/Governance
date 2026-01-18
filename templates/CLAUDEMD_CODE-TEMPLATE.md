# [Project Name]

> **Type:** CODE | **Updated:** YYYY-MM-DD

## Boundaries

- **CAN modify:** `src/`, `tests/`, `docs/`, `README.md`, config files
- **CANNOT modify:** `~/Desktop/Governance/`, `~/.claude/`, `~/.ssh/id_ed25519_personal`

## Critical Rules

1. **Test before commit**: Run test suite before committing
2. **No secrets in code**: Keep credentials in .env files (gitignored)
3. **Read before edit**: Always read files before modifying
4. **Follow doc system**: Use I###, G###, E###, Q### structure (see Documentation System below)

## Documentation System

**This project follows the v3 Code Documentation System.**

**Full specification:** `~/Desktop/Governance/templates/DOC_SYSTEM_CODE.md`

**Quick reference:**

### Directory Structure
```
docs/
├── specs/ARCHITECTURE.md (current design)
├── implementation/
│   ├── active/I###-Feature/
│   ├── completed/I###-Feature/
│   └── future/I###-Feature/
└── session_handoffs/
```

### Document Types
- **I###**: Implementation (feature/sprint work)
- **G###**: Bug/Glitch fixes (always separate file)
- **E###**: Educational/lessons (user-requested only)
- **Q###**: QA/Testing plans

### When to Create
- **I###**: Starting new feature (1-2 weeks)
- **G###**: Any bug discovered (always create)
- **E###**: After repeated failures, user requests doc
- **Q###**: Feature-specific testing needed

**See DOC_SYSTEM_CODE.md for complete guidelines.**

## Documentation Protocol

1. **Session wrap-up**: Before ending, update HANDOFF_REGISTRY.md and create session handoff
2. **Decision logging**: Use `#A` (architecture), `#D` (design), `#I` (infra), `#S` (security)
3. **Implementation docs**: Create I###.md for each feature, G###.md for each bug
4. **Code comments**: Add inline comments for complex logic only (avoid over-commenting)
5. **ARCHITECTURE updates**: Update specs/ARCHITECTURE.md when phase/sprint changes

## Architecture Notes

**Current Phase:** [Phase name]
**Current Sprint:** [Sprint number]
**Active Work:** [I-numbers in progress]

**Key files:** (list critical files for this project)
- `path/to/main.py` - Entry point
- `path/to/core.py` - Core logic

**Design docs:** See `docs/specs/ARCHITECTURE.md`

## Git Conventions

- **Branch naming**: `feature/*`, `fix/*`, `refactor/*`
- **Commit style**: Follow existing project style
- **Remote**: Define origin/upstream if applicable

## Links

- **Documentation System**: `~/Desktop/Governance/templates/DOC_SYSTEM_CODE.md`
- **Governance**: `~/Desktop/Governance/`
- **Full v3 Spec**: `~/Desktop/Governance/V3_FULL_SPEC.md`
- **Project Context**: `HANDOFF_REGISTRY.md` (git-ignored, local only)
- **Root Context**: `../HANDOFF_REGISTRY.md` (if part of multi-project)

---

*Type: CODE | Template: ~/Desktop/Governance/templates/TEMPLATE_CODE.md | v3*
