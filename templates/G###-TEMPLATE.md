# G###: Bug Title

> **Type:** Bug Fix / Glitch Resolution
> **Discovered:** YYYY-MM-DD (during I###, user report, testing)
> **Status:** Investigating | Root Cause Found | Fixed | Verified
> **Severity:** Critical | High | Medium | Low
> **Related:** I### (parent implementation)
> **Total Debugging Time:** X days (Y runs)

---

## Table of Contents

| Section | Title                                                                          | Line   |
|---------|--------------------------------------------------------------------------------|--------|
| 1       | [Symptom](#1-symptom)                                                          | :36    |
| 2       | [Root Cause](#2-root-cause)                                                    | :56    |
| 3       | [Debugging Timeline](#3-debugging-timeline)                                    | :80    |
| 4       | [Fix Applied](#4-fix-applied)                                                  | :146   |
| 5       | [Verification](#5-verification)                                                | :180   |
| 6       | [Prevention](#6-prevention)                                                    | :206   |

---

## 1. Symptom

### What the User Sees

**Description:**
Clear description of what fails, errors out, or behaves incorrectly from the user's perspective.

**Example:**
```
User query: "What did I do last week?"
Expected: Activities from last 7 days
Actual: Returns activities from THIS week
```

### Reproduction Steps

1. Step one to reproduce
2. Step two to reproduce
3. Observe the issue

**Reproducibility:** Always | Sometimes (X%) | Rare

**Environment:**
- Browser/Device: [Chrome 120, Safari iOS 17, etc.]
- User role: [Admin, User, etc.]
- Data conditions: [Specific data state needed]

---

## 2. Root Cause

### Technical Explanation

**What causes this bug:**
Technical explanation of why the bug occurs. Be specific about the code/logic issue.

**Code Example:**
```python
# File: path/to/file.py:45
def problematic_function():
    current_date = datetime.now()  # BUG: Uses system time, not user's timezone
    # Missing: LLM prompt doesn't include current date context
```

**Why this is a problem:**
- LLM prompt doesn't include current date context
- Relative time queries ("last week") fail because LLM doesn't know "today"
- Database query returns correct data, but LLM interprets it wrong

### Impact

**Who is affected:**
- All users
- Users in specific timezone
- Users with specific data patterns

**Severity justification:**
Why this is Critical/High/Medium/Low severity.

---

## 3. Debugging Timeline

### Run 1: Initial Investigation (YYYY-MM-DD, X hours)

**Hypothesis:**
What we thought was wrong

**Approach:**
How we investigated
- Logged queries
- Checked database
- Reviewed related code

**Tests Performed:**
- Test 1: What we tested
- Test 2: What we tested

**Result:** ❌ Hypothesis incorrect | ⚠️ Partially correct | ✅ Confirmed

**Findings:**
What we learned from this run

---

### Run 2: Deeper Investigation (YYYY-MM-DD, X hours/days)

**Hypothesis:**
Updated hypothesis based on Run 1 findings

**Approach:**
New investigation strategy
- Added extensive logging
- Traced execution flow
- Compared with working scenarios

**Tests Performed:**
- Test 1: Description
- Test 2: Description

**Result:** ❌ Still not found | ⚠️ Getting closer | ✅ Root cause identified

**Findings:**
What we learned

---

### Run 3: Fix Implementation (YYYY-MM-DD, X hours)

**Hypothesis:**
Final confirmed root cause

**Approach:**
How we fixed it
- Modified code at specific location
- Added missing functionality
- Updated logic

**Tests Performed:**
- Unit test for specific case
- Integration test for full flow
- Manual verification

**Result:** ✅ BUG FIXED

**Verification:**
How we confirmed the fix works

---

### Run 4: Additional Testing (if needed)

[Repeat structure above for additional debugging runs]

---

## 4. Fix Applied

### Code Changes

**File 1:** `path/to/file.py:45-50`

```python
# BEFORE (buggy code)
def build_prompt(query: str) -> str:
    return f"User query: {query}"

# AFTER (fixed code)
def build_prompt(query: str) -> str:
    current_date = datetime.now().strftime("%Y-%m-%d")
    return f"Current date: {current_date}\n\nUser query: {query}"
```

**Explanation:**
Why this fix resolves the issue.

---

**File 2:** `path/to/another_file.py:123-130`

```python
# BEFORE
[old code]

# AFTER
[new code]
```

**Explanation:**
Why this change was needed.

---

### Files Modified

| File | Lines | Change Type |
|------|-------|-------------|
| path/to/file.py | 45-50 | Added date context to prompt |
| path/to/another.py | 123-130 | Updated validation logic |

**Total:** X files modified

---

## 5. Verification

### Manual Tests

**Test 1: Original failing case**
- [x] Query: "What did I do last week?"
- [x] Result: Returns activities from last 7 days ✅
- [x] Verified on: YYYY-MM-DD

**Test 2: Edge case**
- [x] Query: "Activities this month"
- [x] Result: Returns current month activities ✅
- [x] Verified on: YYYY-MM-DD

**Test 3: Regression check**
- [x] Query: "Yesterday's journal"
- [x] Result: Returns previous day ✅
- [x] Verified on: YYYY-MM-DD

### Automated Tests

**Unit Tests:**
- [ ] `tests/unit/test_relative_time.py` - Added
- [ ] Coverage: X new test cases

**Integration Tests:**
- [ ] `tests/integration/test_query_flow.py` - Updated

**Status:** Tests passing ✅ | Tests pending ⏳

---

## 6. Prevention

### How to Avoid This in the Future

**Code Review Checklist:**
- [ ] Always include temporal context in LLM prompts
- [ ] Test time-relative queries with fixed dates
- [ ] Add logging for date interpretation

**Testing Strategy:**
- Unit tests for date handling
- Integration tests with various time queries
- Add to regression test suite

**Documentation:**
- Update coding guidelines
- Document this pattern for future reference
- Add to [E###-Educational-Doc.md](./E###-Educational-Doc.md) if pattern emerges

### Related Issues

**Similar bugs to watch for:**
- Other LLM prompts missing context
- Date/time handling in other modules

**Future improvements:**
- Centralize date context injection
- Create helper function for temporal prompts

---

## Status Summary

**Resolution:** ✅ Fixed & Verified | 🔄 In Progress | ⏸️ Deferred

**Fixed Date:** YYYY-MM-DD

**Deployed:** Yes (YYYY-MM-DD) | No (pending release)

**Total Time:** X days, Y debugging runs

**Educational Doc Created:** [E###-Pattern-Name.md](./E###-Pattern-Name.md) (if user requested)

---

*Created: YYYY-MM-DD*
*Last Updated: YYYY-MM-DD*
*Template: ~/Desktop/Governance/templates/G###-TEMPLATE.md*
