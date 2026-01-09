# Security Plugin Review

> **Category:** Internal Plugins - Security
> **Count:** 1 plugin
> **Reviewed:** 2026-01-07
> **Cost:** ✓ Low (always active)

---

## Table of Contents

| Section | Title                                    | Line   |
|---------|------------------------------------------|--------|
| 1       | [Overview](#1-overview)                  | :18    |
| 2       | [security-guidance](#2-security-guidance)| :28    |
| 3       | [Integration](#3-integration)            | :133   |
| 4       | [Recommendations](#4-recommendations)    | :160   |

---

## 1. Overview

### Category Summary

Security provides automatic security reminders via PreToolUse hook. Single plugin (security-guidance) that activates automatically during file edit operations.

| Plugin            | Type        | Cost            | Installs |
|-------------------|-------------|-----------------|----------|
| security-guidance | PreToolUse Hook | ✓ Low (always active) | 15.2K    |

---

## 2. security-guidance

### Purpose

Security reminder hook that warns about potential security issues when editing files.

### How It Works

**PreToolUse Hook** that:
1. Intercepts Edit, Write, and MultiEdit tool calls
2. Analyzes file paths and content for security concerns
3. Provides warnings about potential security issues
4. Allows operation to proceed after showing guidance

### Hook Configuration

```json
{
  "description": "Security reminder hook for file edits",
  "hooks": {
    "PreToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 ${CLAUDE_PLUGIN_ROOT}/hooks/security_reminder_hook.py"
          }
        ],
        "matcher": "Edit|Write|MultiEdit"
      }
    ]
  }
}
```

### Use Cases

**1. Prevent credential leaks:**
```
Editing .env file
→ Warning about not committing sensitive data
```

**2. SQL injection prevention:**
```
Writing database query code
→ Guidance on SQL injection prevention
```

**3. XSS protection:**
```
Editing frontend code with user input
→ Reminder about XSS vulnerabilities
```

**4. Authentication best practices:**
```
Modifying authentication logic
→ Warnings about common auth vulnerabilities
```

**5. File permission reminders:**
```
Creating configuration files
→ Guidance on appropriate file permissions
```

### Security Topics Covered

- **Credential management:** .env files, API keys, secrets
- **SQL injection prevention:** Parameterized queries, ORM best practices
- **Cross-Site Scripting (XSS):** Input sanitization, output encoding
- **Cross-Site Request Forgery (CSRF):** Token validation, SameSite cookies
- **Authentication and authorization:** Password hashing, session management
- **File permissions:** Appropriate chmod settings
- **Input validation:** Whitelist validation, type checking
- **Output encoding:** Context-aware escaping
- **Secure communication (HTTPS):** TLS/SSL best practices
- **Dependency vulnerabilities:** Keeping libraries updated

### When to Use

✅ **Automatically active for:**
- All file edits
- All file writes
- All multi-file edits

✅ **Especially valuable when working with:**
- Authentication/authorization code
- Database queries
- User input handling
- Configuration files
- Sensitive data

❌ **Cannot be disabled:**
- Always active when plugin installed
- To disable: uninstall the plugin

### Key Features

- **Automatic activation:** No manual intervention required
- **Context-aware:** Provides relevant guidance based on file type and content
- **Non-blocking:** Shows warnings but doesn't prevent operations
- **Educational:** Helps build security awareness over time
- **OWASP focused:** Covers top security vulnerabilities

### Workflow

**Typical flow:**
```
1. Claude attempts to edit a file
2. Hook intercepts the operation
3. Security guidance displayed (if relevant)
4. Operation proceeds
```

**Example session:**
```
User: "Add user login to the API"

Claude: *Starts editing auth.py*

[security-guidance hook triggers]
⚠️ Security Reminder:
- Hash passwords with bcrypt/scrypt
- Use secure session management
- Implement rate limiting for login attempts
- Never log passwords
- Use HTTPS for authentication endpoints

Claude: *Proceeds with implementation*
```

### Configuration

No configuration options. The plugin works automatically with built-in security guidance.

### Requirements

- Python 3
- No external dependencies

### Best Practices

1. **Read the warnings:** Security guidance is educational—take time to understand
2. **Apply preventatively:** Use guidance to avoid vulnerabilities before they occur
3. **Combine with code-review:** Use together for comprehensive security coverage
4. **Update dependencies:** Keep libraries current to avoid known vulnerabilities
5. **Follow OWASP guidelines:** Learn more at https://owasp.org/

---

## 3. Integration

### With Development Workflows

**Security-first development:**
```
1. Edit file → security-guidance hook triggers
2. Read security guidance
3. Implement with security best practices
4. /commit → commits with security in mind
5. /code-review → code-review plugin checks for bugs
```

**Combined with code-review:**
- security-guidance = Proactive (before writing vulnerable code)
- code-review = Reactive (catches bugs in changes)
- Together = Comprehensive security coverage

### With Governance System

**Cost tracking:**
- security-guidance = Low cost (always active)
- Minimal token overhead per activation
- Non-blocking hook execution

**Hook integration:**
- PreToolUse hook (before Edit/Write/MultiEdit)
- Complements existing governance hooks:
  - check_boundaries.sh (boundary enforcement)
  - inject_context.sh (context injection)
  - log_tool_use.sh (audit logging)

**Global CLAUDE.md integration:**
- security-guidance provides warnings
- Global CLAUDE.md rules enforce boundaries
- Together = Defense in depth

### With Other Security Tools

**Complementary tools:**
- **code-review:** Bug detection in PRs
- **pr-review-toolkit (silent-failure-hunter):** Error handling audit
- **commit-commands:** Secret detection in commits

**Security stack:**
```
Layer 1: security-guidance (proactive warnings)
Layer 2: coding with security awareness
Layer 3: pr-review-toolkit silent-failure-hunter (error handling)
Layer 4: code-review (bug detection)
Layer 5: commit-commands (secret detection)
```

---

## 4. Recommendations

### Best Practices

1. **Keep plugin active at all times:**
   - Low cost makes it safe to always have enabled
   - Educational benefit builds security awareness
   - Prevents vulnerabilities proactively

2. **Read and learn from warnings:**
   - Don't dismiss warnings without reading
   - Use warnings as learning opportunities
   - Build mental models for secure coding

3. **Combine with other security plugins:**
   ```
   security-guidance (proactive) + code-review (reactive) = comprehensive coverage
   ```

4. **Apply OWASP Top 10 principles:**
   - Use warnings as OWASP education
   - Reference https://owasp.org/ for deeper understanding
   - Implement defense in depth

5. **Document security decisions:**
   - Add comments explaining security choices
   - Reference OWASP guidelines in code
   - Document threat model if applicable

### Cost Optimization

**Low-cost plugin = always safe:**
- ✓ Keep active across all projects
- ✓ No cost concern for frequency of use
- ✓ Educational benefit outweighs minimal cost
- No optimization needed

### Plugin Selection by Project

**All projects (universal):**
```
✓ security-guidance  - Automatic security warnings
```

No project exclusions. Even non-sensitive projects benefit from security awareness.

**Project-specific value:**
- **High value:** FILICITI, COEVOLVE (user-facing apps with auth)
- **Medium value:** Governance (configuration files, scripts)
- **Low value:** Documentation-only projects (still useful for general awareness)

### Integration with v2.5 Governance

**Plugin awareness (v2.5 §11-12):**
- security-guidance = Low cost (always safe to have active)
- No high-cost warnings needed
- Can stay active across all projects

**Status line tracking:**
- SessionStart shows plugin count
- No per-plugin cost tracking yet

**Future enhancements (v3 candidate):**
- Track which security topics triggered most often
- Learn project-specific security patterns
- Customize warnings based on tech stack
- Integration with security scanning tools

### Hook Architecture

**PreToolUse hook pattern:**
```
User request → Claude decides to Edit file → PreToolUse hook
                                              ↓
                                        security-guidance
                                              ↓
                                    Display warnings (if relevant)
                                              ↓
                                      Edit proceeds
```

**Non-blocking design:**
- Hook executes before tool use
- Displays guidance
- Does NOT prevent operation
- Educational, not enforcement

**Contrast with governance hooks:**
```
check_boundaries.sh    = BLOCKING (prevents unauthorized edits)
security-guidance      = NON-BLOCKING (warns but allows)
```

### OWASP Top 10 Coverage

| OWASP Category                              | security-guidance Coverage |
|---------------------------------------------|----------------------------|
| A01:2021 - Broken Access Control            | ✓ Auth/authorization       |
| A02:2021 - Cryptographic Failures           | ✓ Credential management    |
| A03:2021 - Injection                        | ✓ SQL injection, XSS       |
| A04:2021 - Insecure Design                  | ○ Partial (educational)    |
| A05:2021 - Security Misconfiguration        | ✓ File permissions         |
| A06:2021 - Vulnerable Components            | ✓ Dependency updates       |
| A07:2021 - Identification & Authentication  | ✓ Auth best practices      |
| A08:2021 - Software & Data Integrity        | ○ Partial                  |
| A09:2021 - Security Logging & Monitoring    | ○ Not covered              |
| A10:2021 - Server-Side Request Forgery      | ○ Not covered              |

**Coverage:** 6/10 categories (60%)

---

## Summary

| Feature               | Details                                       |
|-----------------------|-----------------------------------------------|
| Type                  | PreToolUse hook                               |
| Activation            | Automatic (Edit/Write/MultiEdit)              |
| Cost                  | ✓ Low (always active)                         |
| Blocking              | No (educational warnings only)                |
| OWASP Coverage        | 6/10 categories                               |
| Configuration         | None (built-in defaults)                      |
| Requirements          | Python 3 only                                 |

**Key Insight:** security-guidance acts as a real-time security mentor, providing educational warnings before vulnerable code is written. Non-blocking design means it enhances without interfering.

**Recommended for:**
- ✓ All projects (especially those with authentication, databases, user input)
- ✓ Learning security best practices
- ✓ Building security awareness in development teams
- ✓ Proactive vulnerability prevention

**Not a replacement for:**
- Code review by security experts
- Automated security scanning tools
- Penetration testing
- Security audits

---

*Review completed: 2026-01-07*
*Reviewer: Claude Sonnet 4.5*
*Source: CLAUDE_PLUGINS_REFERENCE.md (lines 768-906)*
