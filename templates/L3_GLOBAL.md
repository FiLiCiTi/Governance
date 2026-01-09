# Global Rules (Layer 3)

> **Location:** ~/.claude/CLAUDE.md
> **Scope:** ALL Claude Code projects

## Session Start

At session start, announce to user for confirmation:
1. Today's date (format: YYYY-MM-DD)
2. Project boundaries (CAN/CANNOT modify)

## Output Format

3. Never dump full files. Show changes: `+ added` / `- removed`
4. Summarize, don't dump. Reference `file:line` instead of quoting blocks.

## Tables in .md Files (STRICT)

5. ALL tables MUST be pretty-formatted:
   - Pad cells with spaces: `| value |` not `|value|`
   - Align columns by padding shorter values
   - Header separator matches column width

   ```
   WRONG:
   |Name|Age|
   |---|---|
   |John|25|

   CORRECT:
   | Name | Age |
   |------|-----|
   | John | 25  |
   ```

## Conventions

6. Decision IDs: `#G` governance, `#P` process, `#I` infra, `#S` security, `#B` backup

## Links

- Governance: `~/Desktop/Governance/`
- Full spec: `~/Desktop/Governance/V2_FULL_SPEC.md`

---
*Layer 3 Template - v2 | Updated: 2026-01-03*
