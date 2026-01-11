# E###: Educational Topic Title

> **Type:** Educational / Lessons Learned
> **Created:** YYYY-MM-DD (after repeated failures / user request)
> **Trigger:** [Describe what prompted this doc: 3+ failed debug attempts, pattern discovery, etc.]
> **Applies To:** This project | All CODE projects | All projects
> **Related:** I### (if tied to implementation), G###, G###, G### (bugs that revealed pattern)
> **Author:** Human + Claude (collaboration context)

---

## Table of Contents

| Section | Title                                                                          | Line   |
|---------|--------------------------------------------------------------------------------|--------|
| 1       | [Context](#1-context)                                                          | :40    |
| 2       | [The Problem](#2-the-problem)                                                  | :64    |
| 3       | [Failed Approaches](#3-failed-approaches)                                      | :92    |
| 4       | [The Solution](#4-the-solution)                                                | :128   |
| 5       | [When to Apply](#5-when-to-apply)                                              | :162   |
| 6       | [Case Studies](#6-case-studies)                                                | :184   |
| 7       | [Implementation Guide](#7-implementation-guide)                                | :224   |
| 8       | [References](#8-references)                                                    | :256   |

---

## 1. Context

### Why This Document Exists

**Created because:**
This document was created after [describe trigger: 3 failed debugging attempts, multiple similar bugs, user request for pattern documentation].

**The journey:**
- [Date]: First encountered issue in [G###]
- [Date]: Second occurrence in [G###]
- [Date]: Third time in [G###] - pattern emerged
- [Date]: User requested educational doc

**Problem scope:**
Describe how widespread or recurring this issue is:
- Affects: [specific component, all similar code, etc.]
- Frequency: [every time X happens, occasional, rare but critical]
- Impact: [delays, bugs, architectural issues]

### Historical Context

**Previous attempts:**
How we tried to solve this before (if applicable)

**Evolution:**
How understanding of this problem evolved over time

---

## 2. The Problem

### Problem Statement

**What goes wrong:**
Clear, concise description of the problem or challenge.

**Example scenario:**
```
Situation: Debugging RAG retrieval issues
Problem: Embeddings are opaque - can't "see" why relevance scores are wrong
Result: 3+ debugging runs with different hypotheses, all wrong
```

### Why This is Difficult

**Key challenges:**
1. **Challenge 1:** Description
   - Why this makes debugging hard
   - What misleads developers

2. **Challenge 2:** Description
   - Specific difficulty
   - Common misconception

3. **Challenge 3:** Description
   - Hidden complexity
   - Non-obvious failure modes

### Common Misconceptions

**Misconception 1:**
What developers often think → Why that's wrong

**Misconception 2:**
Common assumption → Reality

---

## 3. Failed Approaches

### Approach 1: [What we tried first]

**Description:**
What this approach was and why it seemed logical

**Why it failed:**
- Reason 1
- Reason 2
- Actual result vs expected

**What we learned:**
Key insight from this failure

**Example from [G###]:**
Concrete example of this approach failing

---

### Approach 2: [Second attempt]

**Description:**
Next strategy we tried

**Why it failed:**
- Reason 1
- Reason 2

**What we learned:**
What this taught us

**Example from [G###]:**
Concrete example

---

### Approach 3: [Third attempt]

**Description:**
Third strategy

**Why it failed:**
Root cause of failure

**What we learned:**
Critical insight that led to solution

---

### Pattern Recognition

**After 3+ failures, we realized:**
The key insight that changed our approach

**The missing piece:**
What we weren't considering before

---

## 4. The Solution

### The Systematic Approach

**Step-by-step strategy that works:**

#### Step 1: [First action]
**What:** Description
**Why:** Rationale
**How:** Specific method

```bash
# Example command or code
command here
```

**Output to look for:**
What indicates success/failure at this step

---

#### Step 2: [Second action]
**What:** Description
**Why:** Rationale
**How:** Specific method

```python
# Example code
code here
```

**Checkpoint:**
How to verify this step worked

---

#### Step 3: [Third action]
**What:** Description
**Why:** Rationale
**How:** Specific method

---

### Key Principles

**Principle 1:** [Name]
Description of this guiding principle

**Principle 2:** [Name]
Description

**Principle 3:** [Name]
Description

---

## 5. When to Apply

### Applicability

**Use this pattern when:**
- ✅ Condition 1
- ✅ Condition 2
- ✅ Condition 3

**Don't use this pattern when:**
- ❌ Condition 1
- ❌ Condition 2
- ❌ Condition 3

### Decision Tree

```
Is the issue related to [X]?
├─ YES → Follow this pattern
└─ NO → Is it related to [Y]?
    ├─ YES → Follow alternative approach
    └─ NO → Standard debugging
```

### Warning Signs

**Indicators you need this approach:**
- Warning sign 1
- Warning sign 2
- Warning sign 3

---

## 6. Case Studies

### Case Study 1: [G###] - [Brief Title]

**Situation:**
What was happening when we encountered this

**Challenge:**
Specific difficulty faced

**How we applied the pattern:**
1. Step taken
2. Step taken
3. Result

**Outcome:**
What happened after applying the solution

**Time saved:**
Estimated time saved vs previous approach

**Lesson learned:**
Key takeaway from this case

---

### Case Study 2: [G###] - [Brief Title]

**Situation:**
Different scenario with similar pattern

**Challenge:**
Unique aspect of this case

**How we applied the pattern:**
1. Step taken
2. Step taken

**Outcome:**
Result

**Variation:**
How we adapted the pattern for this case

---

### Case Study 3: [G###] - [Brief Title]

[Repeat structure]

---

## 7. Implementation Guide

### Quick Start

**For new similar issue:**
1. Recognize pattern (see §5 When to Apply)
2. Follow steps in §4 The Solution
3. Document results in G### file
4. Update this doc if variations emerge

### Code Examples

**Example 1: [Scenario]**

```python
# Before (problematic pattern)
def old_approach():
    # What doesn't work
    pass

# After (applying pattern)
def new_approach():
    # What works and why
    pass
```

**Example 2: [Scenario]**

```typescript
// Before
const oldPattern = () => {
  // Problematic approach
};

// After
const newPattern = () => {
  // Solution applying pattern
};
```

### Testing Strategy

**How to verify the pattern works:**
1. Test case 1
2. Test case 2
3. Expected results

### Tools & Resources

**Helpful tools:**
- Tool 1: Purpose
- Tool 2: Purpose

**External resources:**
- [Link to relevant documentation]
- [Link to related article]

---

## 8. References

### Related Bugs

All bugs that contributed to this pattern:
- [G###-Bug-Title.md](./G###-Bug-Title.md) - First occurrence
- [G###-Another-Bug.md](./G###-Another-Bug.md) - Second occurrence
- [G###-Final-Bug.md](./G###-Final-Bug.md) - Pattern confirmed

### Related Documentation

**Implementation:**
- [I###-Parent-Feature.md](./I###-Parent-Feature.md) - Where this pattern was applied

**Specs:**
- [ARCHITECTURE.md](../specs/ARCHITECTURE.md) §X - Relevant design section

### External References

- [Article/Documentation URL] - Topic
- [Another reference] - Why relevant

### Updates Log

| Date | Update | Reason |
|------|--------|--------|
| YYYY-MM-DD | Created | After 3rd similar bug |
| YYYY-MM-DD | Added Case Study 4 | New variation discovered |

---

## Summary

**Key Takeaways:**
1. Takeaway 1 - Most important lesson
2. Takeaway 2 - Second key point
3. Takeaway 3 - Third insight

**When you encounter [problem type]:**
Remember to apply [pattern name] as documented in §4.

**Keep this doc updated:**
If you discover variations or new insights, update relevant sections.

---

*Created: YYYY-MM-DD*
*Last Updated: YYYY-MM-DD*
*Template: ~/Desktop/Governance/templates/E###-TEMPLATE.md*
