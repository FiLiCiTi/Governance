# Output Styling Plugins Review

> **Category:** Internal Plugins - Output Styling
> **Count:** 3 plugins
> **Reviewed:** 2026-01-07
> **Cost:** 🔴 HIGH (1000+ tokens/session)

---

## ⚠️ CRITICAL WARNING

**These are HIGH-COST plugins explicitly mentioned in Global CLAUDE.md §11-12:**

> **§11. High-cost plugins warning:** Avoid output styling plugins (explanatory-output-style, learning-output-style, ralph-wiggum) unless absolutely necessary. These add 1000+ tokens per session. Only install ONE at a time maximum.

**Cost impact:**
- SessionStart hook adds permanent instructions (~1000 tokens)
- Additional output per response (variable, 100-500 tokens)
- Cumulative across entire session

**Installation policy:**
- ✅ Install ONE maximum
- ✅ Only when learning/educational value justifies cost
- ❌ NEVER install multiple simultaneously
- ❌ Don't leave installed if not actively using

---

## Table of Contents

| Section | Title                                              | Line   |
|---------|---------------------------------------------------|--------|
| 1       | [Overview](#1-overview)                           | :39    |
| 2       | [explanatory-output-style](#2-explanatory-output-style) | :53    |
| 3       | [learning-output-style](#3-learning-output-style) | :122   |
| 4       | [ralph-wiggum](#4-ralph-wiggum)                   | :198   |
| 5       | [Comparison Matrix](#5-comparison-matrix)         | :310   |
| 6       | [Integration](#6-integration)                     | :342   |
| 7       | [Recommendations](#7-recommendations)             | :377   |

---

## 1. Overview

### Category Summary

Output Styling plugins modify Claude's response format and interaction model. All 3 use SessionStart hooks to inject permanent instructions, significantly increasing token usage.

| Plugin                    | Type           | Cost             | Installs | v2.5 Warning |
|---------------------------|----------------|------------------|----------|--------------|
| explanatory-output-style  | SessionStart   | 🔴 HIGH (1000+)  | N/A      | ✓ Discouraged|
| learning-output-style     | SessionStart   | 🔴 HIGH (1000+)  | N/A      | ✓ Discouraged|
| ralph-wiggum              | Stop Hook      | 🔴 HIGH (varies) | N/A      | ✓ Discouraged|

---

## 2. explanatory-output-style

### Purpose

Adds educational insights about implementation choices to Claude's output using SessionStart hooks.

**Recreates deprecated "Explanatory" output style from v1 settings.**

### How It Works

SessionStart hook injects instructions that encourage Claude to:
1. Provide educational insights about implementation choices
2. Explain codebase patterns and decisions
3. Balance task completion with learning opportunities

Insights formatted as:
```
★ Insight ─────────────────────────────────────
[2-3 key educational points]
─────────────────────────────────────────────────
```

### Use Cases

**1. Learning a new codebase:**
```
"Add caching to the API"
→ Claude explains existing caching patterns before implementing
```

**2. Understanding design decisions:**
```
"Refactor the authentication"
→ Claude explains current auth approach and tradeoffs
```

**3. Onboarding new team members:**
```
Any development task
→ Automatic insights about project conventions
```

**4. Building institutional knowledge:**
```
Regular development work
→ Continuous learning about your codebase
```

**5. Debugging with context:**
```
"Fix the session timeout bug"
→ Insights about session management approach
```

### Key Features

- **Automatic activation:** Works from session start
- **Codebase-specific:** Tailored to your project, not generic
- **Formatted insights:** Clear visual separation with stars
- **Balanced approach:** Doesn't slow down task completion
- **No commands required:** Just install and work normally

### When to Use

✅ **USE when:**
- Learning a new codebase
- Onboarding team members
- Understanding complex architectural decisions
- Building documentation from insights

❌ **DON'T USE when:**
- Tight token budgets
- Urgent tasks where speed matters
- Simple, well-understood tasks
- Already familiar with codebase

### Configuration

No configuration options. Works with default settings.

**Disabling:**
- Use `/stop` and restart without the plugin
- Or uninstall the plugin

### Cost Impact

**HIGH COST:**
- SessionStart hook: ~1000 tokens added to context
- Per-response overhead: 100-300 tokens (insights)
- Cumulative across session: 2000-5000+ tokens

**Example:**
```
Session without plugin: 15K tokens
Session with plugin:    20K tokens (+33% increase)
```

### Migration Note

Replaces deprecated setting:
```json
{
  "outputStyle": "Explanatory"
}
```

---

## 3. learning-output-style

### Purpose

Interactive learning mode that requests meaningful code contributions from you at key decision points, combined with explanatory insights.

**Combines unshipped "Learning" output style with explanatory functionality.**

### How It Works

SessionStart hook injects instructions that encourage Claude to:
1. Identify opportunities for you to write 5-10 lines of meaningful code
2. Focus on business logic and design choices (not boilerplate)
3. Prepare context and explain trade-offs
4. Provide educational insights throughout

### Learning Approach

**Claude WILL request contributions for:**
- Business logic with multiple valid approaches
- Error handling strategies
- Algorithm implementation choices
- Data structure decisions
- User experience decisions
- Design patterns and architecture choices

**Claude will NOT request contributions for:**
- Boilerplate or repetitive code
- Obvious implementations with no meaningful choices
- Configuration or setup code
- Simple CRUD operations

### Use Cases

**1. Learning by doing:**
```
"Add authentication middleware"
→ Claude sets up structure, asks you to implement timeout logic
```

**2. Understanding trade-offs:**
```
"Add caching"
→ Claude explains approaches, asks you to choose and implement
```

**3. Building practical skills:**
```
"Implement search feature"
→ You write the actual search algorithm with guidance
```

**4. Onboarding with hands-on practice:**
```
Any feature development
→ Regular opportunities to contribute key logic
```

**5. Code review as learning:**
```
"Refactor error handling"
→ You implement the new error handling approach
```

### Example Interaction

```
User: "Add session timeout handling"

Claude: I've set up the authentication middleware. The session timeout
behavior is a security vs. UX trade-off:

Option 1: Auto-extend on activity (better UX, longer exposure)
Option 2: Hard timeout (more secure, might frustrate users)

In `auth/middleware.ts`, implement the `handleSessionTimeout()` function
to define the timeout behavior. Consider the trade-offs above.

User: [Writes 5-10 lines implementing chosen approach]

Claude: Great choice! That balances security and UX well.
★ Insight ─────────────────────────────────────
Your implementation uses sliding window timeouts, which is common in
applications prioritizing user experience while maintaining reasonable
security posture.
─────────────────────────────────────────────────
```

### Key Features

- **Interactive learning:** Active participation, not passive observation
- **Meaningful contributions:** 5-10 line segments focusing on logic, not boilerplate
- **Trade-off explanations:** Understand why decisions matter
- **Educational insights:** Combined with explanatory-output-style
- **Context preparation:** Claude sets up structure before asking for code
- **Automatic activation:** Works from session start

### When to Use

✅ **USE when:**
- Learning a new language or framework
- Understanding architectural patterns
- Building practical coding skills
- Onboarding with hands-on experience

❌ **DON'T USE when:**
- Production work with tight deadlines
- Simple, well-understood tasks
- When you just want answers quickly
- Tight token budgets

### Philosophy

**"Learning by doing is more effective than passive observation."**

Transforms interaction from "watch and learn" to "build and understand."

### Cost Impact

**HIGHEST COST of all output styling plugins:**
- SessionStart hook: ~1500 tokens added to context
- Per-response overhead: 200-500 tokens (insights + interaction prompts)
- User wait time: Additional back-and-forth for contributions
- Cumulative across session: 3000-8000+ tokens

**Example:**
```
Session without plugin: 15K tokens
Session with plugin:    25K tokens (+67% increase)
```

---

## 4. ralph-wiggum

### Purpose

Implements the Ralph Wiggum technique for iterative, self-referential AI development loops using a Stop hook.

**Core concept:** "Ralph is a Bash loop" - continuous AI agent iteration until task completion.

### How It Works

Stop hook intercepts Claude's exit attempts, creating self-referential feedback loop:

```bash
# You run ONCE:
/ralph-loop "Your task description" --completion-promise "DONE" --max-iterations 50

# Then Claude Code automatically:
# 1. Works on the task
# 2. Tries to exit
# 3. Stop hook blocks exit
# 4. Stop hook feeds the SAME prompt back
# 5. Repeat until completion promise or max iterations
```

**Self-referential feedback loop:**
- Prompt never changes between iterations
- Claude's previous work persists in files
- Each iteration sees modified files and git history
- Claude autonomously improves by reading its own past work

### Commands

**`/ralph-loop`**
- **Syntax:** `/ralph-loop "<prompt>" --max-iterations <n> --completion-promise "<text>"`
- **Options:**
  - `--max-iterations <n>`: Stop after N iterations (default: unlimited)
  - `--completion-promise "<text>"`: Phrase that signals completion

**`/cancel-ralph`**
- **Syntax:** `/cancel-ralph`
- **Purpose:** Cancel active Ralph loop

### Use Cases

**1. Test-driven development:**
```bash
/ralph-loop "Build REST API for todos. Requirements: CRUD, validation, tests.
Output <promise>COMPLETE</promise> when all tests pass."
--completion-promise "COMPLETE" --max-iterations 50
```

**2. Bug fixing with verification:**
```bash
/ralph-loop "Fix the authentication bug. Run tests after each fix.
Output <promise>TESTS PASS</promise> when bug is resolved."
--completion-promise "TESTS PASS" --max-iterations 20
```

**3. Incremental feature building:**
```bash
/ralph-loop "Phase 1: User auth (JWT, tests). Phase 2: Product catalog (list/search, tests).
Phase 3: Shopping cart (add/remove, tests). Output <promise>ALL PHASES DONE</promise>."
--completion-promise "ALL PHASES DONE" --max-iterations 100
```

**4. Self-correcting implementation:**
```bash
/ralph-loop "Implement feature X following TDD: 1. Write failing tests 2. Implement
3. Run tests 4. If any fail, debug and fix 5. Refactor if needed 6. Repeat until all green
7. Output: <promise>COMPLETE</promise>"
--max-iterations 30
```

**5. Greenfield projects:**
```bash
/ralph-loop "Create a CLI tool for managing tasks with: add, list, complete, delete commands.
Include tests and README. Output <promise>PROJECT COMPLETE</promise>."
--completion-promise "PROJECT COMPLETE" --max-iterations 50
```

### Prompt Writing Best Practices

**1. Clear Completion Criteria:**

❌ Bad: "Build a todo API and make it good."

✅ Good:
```markdown
Build a REST API for todos.

When complete:
- All CRUD endpoints working
- Input validation in place
- Tests passing (coverage > 80%)
- README with API docs
- Output: <promise>COMPLETE</promise>
```

**2. Incremental Goals:**

❌ Bad: "Create a complete e-commerce platform."

✅ Good:
```markdown
Phase 1: User authentication (JWT, tests)
Phase 2: Product catalog (list/search, tests)
Phase 3: Shopping cart (add/remove, tests)

Output <promise>COMPLETE</promise> when all phases done.
```

**3. Self-Correction Instructions:**

✅ Good:
```markdown
Implement feature X following TDD:
1. Write failing tests
2. Implement feature
3. Run tests
4. If any fail, debug and fix
5. Refactor if needed
6. Repeat until all green
7. Output: <promise>COMPLETE</promise>
```

**4. Safety: Always Use --max-iterations:**

```bash
# ALWAYS set iteration limit to prevent infinite loops
/ralph-loop "Task description" --max-iterations 20

# In prompt, include what to do if stuck:
# "After 15 iterations, if not complete:
#  - Document what's blocking progress
#  - List what was attempted
#  - Suggest alternative approaches"
```

### When to Use

✅ **USE when:**
- Well-defined tasks with clear success criteria
- Tasks requiring iteration (getting tests to pass)
- Greenfield projects where you can walk away
- Tasks with automatic verification (tests, linters)

❌ **DON'T USE when:**
- Tasks requiring human judgment
- One-shot operations
- Unclear success criteria
- Production debugging (use targeted debugging instead)

### Key Features

- **Self-referential loop:** Same prompt every iteration
- **Persistent state:** Work saved in files between iterations
- **Autonomous improvement:** Claude debugs and fixes itself
- **Completion detection:** Stops when promise phrase detected
- **Safety limit:** --max-iterations prevents infinite loops
- **Single session:** All iterations in one Claude Code session

### Philosophy

**Core Principles:**
1. **Iteration > Perfection:** Don't aim for perfect on first try
2. **Failures Are Data:** "Deterministically bad" means predictable, informative failures
3. **Operator Skill Matters:** Success depends on writing good prompts
4. **Persistence Wins:** Keep trying until success

### Real-World Results

- Successfully generated 6 repositories overnight (Y Combinator hackathon testing)
- One $50k contract completed for $297 in API costs
- Created entire programming language ("cursed") over 3 months

### Cost Impact

**EXTREMELY HIGH COST:**
- SessionStart hook: ~500 tokens
- Per-iteration overhead: 5K-20K tokens (full task context repeated)
- Iterations: 5-50+ iterations typical
- Total cost: **50K-1M+ tokens per ralph-loop**

**Example:**
```
Single /feature-dev: 15K tokens
/ralph-loop (10 iterations): 150K tokens (10x increase)
/ralph-loop (50 iterations): 750K tokens (50x increase)
```

**Cost comparison:**
```
One $50k contract = $297 in API costs (documented result)
→ ~990K tokens at $0.30/1M tokens (estimated)
→ ~50 iterations average
```

---

## 5. Comparison Matrix

### Cost Comparison

| Plugin                    | SessionStart Hook | Per-Response Overhead | Typical Session Cost | Use Frequency     |
|---------------------------|-------------------|-----------------------|----------------------|-------------------|
| explanatory-output-style  | ~1000 tokens      | 100-300 tokens        | +2K-5K tokens        | Continuous        |
| learning-output-style     | ~1500 tokens      | 200-500 tokens        | +3K-8K tokens        | Continuous        |
| ralph-wiggum              | ~500 tokens       | 5K-20K per iteration  | +50K-1M tokens       | Per /ralph-loop   |

### Use Case Comparison

| Scenario                     | explanatory | learning | ralph-wiggum |
|------------------------------|-------------|----------|--------------|
| Learn new codebase           | ✓ Best      | ✓ Good   | ✗            |
| Onboard team member          | ✓ Best      | ✓ Good   | ✗            |
| Learn by doing               | ✗           | ✓ Best   | ✗            |
| Build practical skills       | ✗           | ✓ Best   | ✗            |
| Autonomous feature building  | ✗           | ✗        | ✓ Best       |
| Test-driven development      | ✗           | ✗        | ✓ Best       |
| Greenfield project           | ✗           | ✗        | ✓ Best       |
| Production work              | ✗           | ✗        | ✗            |
| Tight token budgets          | ✗           | ✗        | ✗            |

### Installation Policy

**v2.5 Global Rules (§11-12):**
```
✓ Install ONE maximum
✗ NEVER install multiple simultaneously
✓ Only when learning value justifies cost
✗ Don't leave installed if not actively using
```

---

## 6. Integration

### With Governance System

**Cost tracking:**
- All 3 = HIGH cost
- SessionStart warnings: "⚠️ WARNING: X high-cost plugins active"
- Manual uninstall required when not needed

**Plugin awareness (v2.5 §11-12):**
- Explicitly discouraged in global rules
- Not banned, but strongly advised against
- ONE at a time maximum

**Status line (future v3):**
- Should show active output styling plugin
- Proposed: `🔴 Active: explanatory-output-style`

### With Development Workflows

**Conflicts:**
```
❌ WRONG:
explanatory-output-style + learning-output-style
→ Redundant, wasteful (3K-8K token overhead)

❌ WRONG:
explanatory-output-style + /ralph-loop
→ Ralph already verbose (adds 2K-5K more)

❌ WRONG:
learning-output-style + /feature-dev
→ /feature-dev expects autonomy, learning expects participation
```

**Compatible:**
```
✓ explanatory-output-style alone (learning mode)
✓ learning-output-style alone (hands-on learning)
✓ ralph-wiggum alone (autonomous building)
```

### Project Suitability

| Project    | explanatory | learning | ralph-wiggum | Reason                           |
|------------|-------------|----------|--------------|----------------------------------|
| FILICITI   | ?           | ?        | ✗            | Production code = minimize cost  |
| COEVOLVE   | ?           | ?        | ✗            | Production code = minimize cost  |
| Governance | ✗           | ✗        | ✗            | Docs work = no value added       |
| Learning   | ✓           | ✓        | ✗            | Educational benefit justifies    |

---

## 7. Recommendations

### Best Practices

**1. Default: Don't install any output styling plugins**
- Base Claude already provides good explanations
- Cost rarely justified
- Reserve for specific learning scenarios

**2. If learning a new codebase:**
```
Install: explanatory-output-style
Duration: 1-2 weeks during ramp-up
Remove: After familiar with codebase patterns
```

**3. If learning by doing:**
```
Install: learning-output-style
Duration: 1-2 weeks during skill building
Remove: After comfortable with implementation patterns
```

**4. If greenfield autonomous project:**
```
Use: /ralph-loop (no install needed - it's a command)
Duration: Single project/feature
Cost: Budget 50K-1M tokens per project
```

**5. NEVER install multiple simultaneously:**
```
❌ explanatory + learning
❌ explanatory + ralph
❌ learning + ralph
```

### Cost Optimization

**Minimize output styling usage:**
- ✓ Use base Claude (zero overhead)
- ✓ Install output styling only for learning
- ✓ Uninstall immediately after learning phase
- ✓ ONE plugin maximum
- ✗ Don't leave installed "just in case"

**Ralph cost management:**
- Set realistic `--max-iterations` (10-20 for features)
- Include escape hatch in prompt ("After 15 iterations, document blockers")
- Monitor token usage during ralph-loop
- Cancel with `/cancel-ralph` if runaway

### Plugin Selection by Scenario

**Scenario 1: New developer onboarding**
```
Week 1-2: explanatory-output-style (learn codebase)
Week 3-4: learning-output-style (hands-on practice)
Week 5+:   Remove all (familiar with codebase)
```

**Scenario 2: Production development**
```
All phases: NO output styling plugins
→ Use /feature-dev + /code-review instead
→ Cost-effective, production-ready workflow
```

**Scenario 3: Greenfield hackathon project**
```
/ralph-loop for rapid autonomous building
Budget: 100K-500K tokens (higher cost acceptable for speed)
```

**Scenario 4: Learning new framework**
```
Month 1: learning-output-style (hands-on practice)
Month 2+: Remove (comfortable with framework)
```

### Integration with v2.5 Governance

**v2.5 §11-12 compliance:**
- Output styling = HIGH cost category
- Globally discouraged (not banned)
- ONE at a time maximum
- Remove when not actively learning

**Future v3 enhancements:**
- Auto-detect when learning phase complete
- Suggest removing after X days of inactivity
- Track actual token overhead per plugin
- Warn when multiple high-cost plugins installed

### Cost-Benefit Analysis

| Plugin                    | Cost per Session | Benefit                      | Justified When              |
|---------------------------|------------------|------------------------------|----------------------------|
| explanatory-output-style  | +2K-5K tokens    | Learn codebase patterns      | New codebase onboarding    |
| learning-output-style     | +3K-8K tokens    | Build hands-on skills        | Learning new language/framework |
| ralph-wiggum              | +50K-1M tokens   | Autonomous project completion| Greenfield rapid prototyping |

**ROI threshold:**
- Educational value must exceed 2x-50x base cost
- Only install if learning cannot happen another way
- Remove immediately after learning phase complete

---

## Summary

| Plugin                    | Type        | Cost               | When Justified                |
|---------------------------|-------------|-------------------|-------------------------------|
| explanatory-output-style  | SessionStart| 🔴 HIGH (+2K-5K)  | Learning new codebase         |
| learning-output-style     | SessionStart| 🔴 HIGH (+3K-8K)  | Building hands-on skills      |
| ralph-wiggum              | Stop Hook   | 🔴 EXTREME (+50K-1M)| Autonomous greenfield building|

**Key Insights:**

1. **Default stance:** Don't install - base Claude is sufficient
2. **Installation threshold:** Educational value must exceed 2x-50x cost
3. **Maximum count:** ONE output styling plugin at a time
4. **Duration:** Temporary (1-2 weeks) for learning phases only
5. **Production use:** NEVER - use /feature-dev + /code-review instead

**Recommended for:**
- ✗ FILICITI/COEVOLVE (production = minimize cost)
- ✗ Governance (docs = no value)
- ✓ Personal learning projects (educational value)
- ? One-time greenfield prototypes (ralph-wiggum)

**v2.5 Global Rules:**
```
§11. Avoid output styling plugins unless absolutely necessary
§12. Only install ONE at a time maximum
```

---

*Review completed: 2026-01-07*
*Reviewer: Claude Sonnet 4.5*
*Source: CLAUDE_PLUGINS_REFERENCE.md (lines 1081-1592)*
