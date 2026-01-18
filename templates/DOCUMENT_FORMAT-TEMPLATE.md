# Document Formatting Standards

> **Purpose:** STRICT formatting rules for all markdown documents
> **Updated:** 2026-01-18

## Table of Contents

| Section | Title                                         | Line |
|---------|-----------------------------------------------|------|
| 1       | [Overview](#1-overview)                       | :13  |
| 2       | [Document Structure](#2-document-structure)   | :28  |
| 3       | [TOC Formatting](#3-toc-formatting)           | :71  |
| 4       | [Table Formatting](#4-table-formatting)       | :103 |
| 5       | [Examples](#5-examples)                       | :175 |

---------------------------------------------------------------------------------------------------------------------------

## 1. Overview

**ALL markdown documents MUST follow these formatting standards. No exceptions.**

**Enforcement:**
- ⚠️ Creating/updating any .md file → check this template FIRST
- ⚠️ Every table MUST be pretty-formatted
- ⚠️ Every document MUST have TOC
- ⚠️ Major sections MUST use full separator lines

**Template location:**
- Global: `~/.claude/templates/DOCUMENT_FORMAT-TEMPLATE.md`
- Project: `~/Desktop/FILICITI/Governance/templates/DOCUMENT_FORMAT-TEMPLATE.md`

---------------------------------------------------------------------------------------------------------------------------

## 2. Document Structure

### 2.1 Standard Layout

```markdown
# Document Title

> **Metadata:** Key-value pairs
> **Updated:** YYYY-MM-DD

## Table of Contents

| Section | Title         | Line |
|---------|---------------|------|
| 1       | [Section](#1) | :XX  |

---------------------------------------------------------------------------------------------------------------------------

## 1. Section Name

Content here...

---------------------------------------------------------------------------------------------------------------------------

## 2. Another Section

More content...

---------------------------------------------------------------------------------------------------------------------------

*Footer with template reference and version*
```

### 2.2 Required Elements

1. **Title** (H1): Document name
2. **Metadata block**: Frontmatter or blockquote with key info
3. **TOC**: Table of Contents (3 columns: Section, Title, Line)
4. **Major section separators**: Full line of dashes (123 characters)
5. **Numbered sections**: Body content with numbered headings (## 1., ## 2., etc.)
6. **Footer**: Template reference and version

### 2.3 Major Section Separator (STRICT)

**REQUIRED:** Separate major sections with full line of dashes:

```
---------------------------------------------------------------------------------------------------------------------------
```

**Character count:** Exactly 123 dashes (consistent visual boundary)

**When to use:**
- After TOC, before first major section
- Between all major sections (## 1., ## 2., etc.)
- Before footer

---------------------------------------------------------------------------------------------------------------------------

## 3. TOC Formatting

### 3.1 Required Format (STRICT)

**ALL documents MUST have Table of Contents:**
- ⚠️ Exactly 3 columns: Section (number) | Title (link) | Line (:number)
- ⚠️ Must follow table formatting rules (Section 4)
- ⚠️ Section numbers are sequential integers (1, 2, 3...)
- ⚠️ Titles are markdown links to anchors
- ⚠️ Line numbers reference actual line in document

### 3.2 TOC Template

```markdown
## Table of Contents

| Section | Title                                   | Line |
|---------|-----------------------------------------|------|
| 1       | [First Section](#1-first-section)       | :XX  |
| 2       | [Second Section](#2-second-section)     | :XX  |
| 3       | [Third Section](#3-third-section)       | :XX  |
```

### 3.3 Section Numbering

- Use numbered headings: `## 1. First Section` (not `## First Section`)
- Anchor format: `#1-first-section` (lowercase, hyphens replace spaces)
- Subsections use nested numbers: `### 1.1 Subsection`

### 3.4 Line Numbers

- Format: `:49` (colon prefix, not `49` or `L49`)
- MUST reference actual line where section heading appears
- ⚠️ Update when document structure changes

---------------------------------------------------------------------------------------------------------------------------

## 4. Table Formatting

### 4.1 Pretty-Formatted Tables (STRICT)

**ALL tables MUST be pretty-formatted:**
- ⚠️ Pad cells with spaces: `| value |` NOT `|value|`
- ⚠️ Align columns by padding shorter values
- ⚠️ Header separator matches column width exactly
- ⚠️ No trailing spaces in cells

**Incorrect vs Correct:**

❌ **WRONG:**
```markdown
|Name|Age|City|
|---|---|---|
|John|25|NYC|
```

✅ **CORRECT:**
```markdown
| Name | Age | City |
|------|-----|------|
| John | 25  | NYC  |
```

### 4.2 Row Continuation Rule (STRICT)

**When a table row exceeds 150 characters, use continuation rows.**

**Threshold:** 150 characters (strict)

**Measurement:**
- Count raw markdown including `|`, spaces, all content
- Example: `| Name | Age | City |` = 20 characters

**Wrapping strategy:**
- SPLIT rightmost column content across rows (not move entirely)
- First line: Keep leftmost columns full, partial content from long columns
- Continuation line: Empty leftmost columns, remaining content from long columns

**Example - Row exceeds 150 chars:**

**Current (wrong - exceeds 150 chars):**
```markdown
| Step | Description           | Section | Implementation Details                                                             | Notes                   |
|------|-----------------------|---------|------------------------------------------------------------------------------------|-------------------------|
| 3.1  | Intent classification | §3      | intent_pattern query, similarity (0.7), intent_pattern data, similarity (0.9)      | Chat/Analyze, test text |
```

**Required (correct - content split across rows):**
```markdown
| Step | Description           | Section | Implementation Details                      | Notes            |
|------|-----------------------|---------|---------------------------------------------|------------------|
| 3.1  | Intent classification | §3      | intent_pattern query, similarity (0.7),     | Chat/Analyze,    |
|      |                       |         | intent_pattern data, similarity (0.9)       | test text        |
```

**Key points:**
- First line contains PARTIAL content from long columns (fits within 150 chars)
- Continuation line contains REMAINING content from those columns
- Leftmost columns (Step, Description, Section) are empty on continuation row
- Content is SPLIT within columns, not moved entirely

### 4.3 Column Alignment

- **Text columns**: Left-aligned (default)
- **Number columns**: Right-aligned (optional, preferred for clarity)
- **Separator row**: Must match header width exactly

**Example with right-aligned numbers:**
```markdown
| Name  | Age | Salary  |
|-------|----:|--------:|
| John  |  25 |  50,000 |
| Sarah |  30 | 120,000 |
```

### 4.4 Enforcement Checklist

Before committing any document:
1. ✅ All tables pretty-formatted (padded cells, aligned columns)
2. ✅ All rows measured against 150 char threshold
3. ✅ Continuation rows applied where needed
4. ✅ Header separators match column widths exactly
5. ✅ No trailing spaces

---------------------------------------------------------------------------------------------------------------------------

## 5. Examples

### 5.1 Complete Document

```markdown
# Architecture Decisions

> **Project:** MyProject
> **Type:** CODE
> **Updated:** 2026-01-18

## Table of Contents

| Section | Title                                    | Line |
|---------|------------------------------------------|------|
| 1       | [Overview](#1-overview)                  | :17  |
| 2       | [Decisions](#2-decisions)                | :28  |

---------------------------------------------------------------------------------------------------------------------------

## 1. Overview

This document captures architectural decisions for MyProject.

**Key principles:**
- Separation of concerns
- Single responsibility
- Clear boundaries

---------------------------------------------------------------------------------------------------------------------------

## 2. Decisions

### 2.1 State Management

**Decision:** Use separated state files

**Rationale:** Prevents cascading failures

---------------------------------------------------------------------------------------------------------------------------

*Template: ~/.claude/templates/DOCUMENT_FORMAT-TEMPLATE.md | v3.3*
```

### 5.2 Table with Row Continuation

```markdown
| #   | Journey Step      | MASTER Section        | ARCHITECTURE Section | REFERENCE       | Notes                     |
|-----|-------------------|-----------------------|----------------------|-----------------|---------------------------|
| 1.1 | Receive request   | §1 Request Intake     | TBD                  | 2.4-RAG_SPEC §1 | validate_input(),         |
|     |                   |                       |                      |                 | sanitize_input()          |
| 1.2 | Validate format   | §1 Request Validation | TBD                  | 2.4-RAG_SPEC §1 | Schema validation         |
```

**Why continuation rows used:**
- Row 1.1 with full Notes content would exceed 150 characters
- Notes column SPLIT across rows:
  - First line: `validate_input(),` (partial content)
  - Continuation line: `sanitize_input()` (remaining content)
- Leftmost columns (#, Journey Step, MASTER Section) empty on continuation row

### 5.3 TOC with Long Titles

```markdown
| Section | Title                                                                          | Line |
|---------|--------------------------------------------------------------------------------|------|
| 1       | [Overview](#1-overview)                                                        | :49  |
| 2       | [Global Directory (`~/.claude/`)](#2-global-directory-claude)                  | :62  |
| 3       | [Very Long Section Title That Needs Proper Alignment](#3-very-long-section)    | :105 |
```

**Note:** Even with long titles, maintain column alignment and padding.

---------------------------------------------------------------------------------------------------------------------------

*Template: ~/.claude/templates/DOCUMENT_FORMAT-TEMPLATE.md | v3.3 | Updated: 2026-01-18*
