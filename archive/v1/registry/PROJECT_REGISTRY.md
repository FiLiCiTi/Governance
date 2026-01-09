# Claude Project Registry

> **Template:** ~/Desktop/Governance/templates/
> **Last Updated:** 2026-01-02

## Overview

Central registry of all Claude-managed projects. Used for governance audits and compliance tracking.

## FILICITI Structure (NEW)

Projects are being migrated to `~/Desktop/FILICITI/` structure.

### Migrated Projects

| Project | New Path | Type | Test Score | Status |
|---------|----------|------|------------|--------|
| Governance | Desktop/Governance/ | OPS | N/A | Working Directory |
| COEVOLVE (code) | Desktop/FILICITI/Products/COEVOLVE/code/ | CODE | 100% | MIGRATED |
| COEVOLVE (bizplan) | Desktop/FILICITI/Products/COEVOLVE/businessplan/ | BIZZ | 100% | MIGRATED |
| LABS | Desktop/FILICITI/Products/LABS/ | ROOT | 100% | MIGRATED |
| google_extractor | Desktop/FILICITI/Products/LABS/google_extractor/ | CODE | - | Included in LABS |

### Pending Migration (Deferred)

| Project | Current Path | Target Path | Status |
|---------|--------------|-------------|--------|
| FlowInLife | Desktop/FlowInLife_env/YutaAI_mem_Railway2/ | Desktop/FILICITI/Products/FlowInLife/ | User actively working |
| YutaAI | Desktop/FlowInLife_env/YutaAI_mem_Railway2/ | Desktop/FILICITI/Products/FlowInLife/ | User actively working |
| Code_Archaeology | Desktop/FlowInLife_env/.../Code_Archaeology/ | Desktop/FILICITI/Products/FlowInLife/_Archaeology/ | Part of YutaAI_mem_Railway2 |

### Excluded from Migration

| Project | Path | Reason |
|---------|------|--------|
| 18-Matt Lewis_FI | Desktop/Team Flow Ultimatum/.../18-Matt Lewis_FI/ | User decision - not part of FILICITI |
| YutaAI_mem_* variants | Various | Need architecture consolidation first |

---

## Legacy Paths (Original Locations)

| Project | Path | Type | CLAUDE.md | SESSION_LOG | PLAN.md | 10_Thought_Process | Status |
|---------|------|------|-----------|-------------|---------|-------------------|--------|
| FILICITI_LABS | Desktop/FILICITI_LABS/ | ROOT | Yes | N/A | N/A | N/A | Source (keep until stable) |
| COEVOLVE | Desktop/FILICITI_LABS/COEVOLVE/ | CODE | Yes | Yes | Yes | Yes | Source (keep until stable) |
| COEVOLVE_businessplan | Desktop/FILICITI_LABS/COEVOLVE_businessplan/ | BIZZ | Yes | Yes | Yes | Yes | Source (keep until stable) |
| Claude_env | Desktop/Claude_env/ | ROOT | Yes | N/A | N/A | N/A | Source (keep until stable) |
| google_extractor | Desktop/Claude_env/google_extractor/ | CODE | Yes | Yes | Yes | Yes | Source (keep until stable) |
| Governance | Desktop/Governance/ | OPS | Yes | Yes | Yes | Yes | Active (working directory) |
| YutaAI_mem_Railway2 | Desktop/FlowInLife_env/YutaAI_mem_Railway2/ | ROOT | Yes | N/A | N/A | N/A | Pending Migration |
| Code_Archaeology | Desktop/FlowInLife_env/.../Code_Archaeology/ | CODE | Yes | Yes | Yes | Yes | Pending Migration |
| FlowInLife | Desktop/FlowInLife_env/.../FlowInLife/ | CODE | Yes | Exists | Yes | Yes | Pending Migration |
| YutaAI | Desktop/FlowInLife_env/.../YutaAI/ | CODE | Yes | Exists | Yes | Yes | Pending Migration |

## Type Summary

| Type | Count (FILICITI) | Count (Legacy) | Description |
|------|-----------------|----------------|-------------|
| ROOT | 1 | 3 | Multi-project index folders |
| CODE | 2 | 5 | Technical codebases |
| BIZZ | 1 | 1 | Business strategy/planning |
| OPS | 1 | 1 | Operations/infrastructure |
| Excluded | 2 | - | Not part of migration |

## Required Files by Type

| Type | CLAUDE.md | SESSION_LOG.md | PLAN.md | 10_Thought_Process/ |
|------|-----------|----------------|---------|---------------------|
| ROOT | Yes | No (in children) | No (in children) | No (in children) |
| CODE | Yes | Yes | Yes | Yes |
| BIZZ | Yes | Yes | Yes | Yes |
| OPS | Yes | Yes | Yes | Yes |

## Notes

### Migration Protocol
- **Copy first, delete later** - Original locations kept until new structure is stable
- **Testing required** - Run `governance_test.sh` before marking as MIGRATED
- **Pass threshold** - 80% minimum score required
- **User approval** - Required before deleting original folders

### FlowInLife/YutaAI (Deferred)
- **Status:** User actively working - cannot migrate now
- **Structure:** YutaAI_mem_Railway2 contains both projects + contractor baseline
- **Pattern:** Parallel development (fil-app + fil-yuta forks from fil)
- **When ready:** Copy whole YutaAI_mem_Railway2 → FILICITI/Products/FlowInLife/

### 18-Matt Lewis_FI (Excluded)
- **Status:** Not part of FILICITI migration
- **Reason:** User decision - separate from main product structure

## Adding New Projects

1. Create project folder in appropriate FILICITI location
2. Copy appropriate template from `~/Desktop/Governance/templates/CLAUDE_TEMPLATE_[TYPE].md`
3. Create required files (CONTEXT.md, SESSION_LOG.md, PLAN.md, 10_Thought_Process/)
4. Set up _governance/ symlinks if wrapper repo pattern
5. Add entry to this registry
6. Run `governance_test.sh` to verify compliance (must pass 80%+)

---
*Managed by: ~/Desktop/Governance/ | Updated: 2026-01-02*
