# Development Tools Plugins Review

> **Category:** Internal Plugins - Development Tools
> **Count:** 3 plugins
> **Reviewed:** 2026-01-07
> **Cost:** ✓ Low (when invoked)

---

## Summary (Key Points)

**3 meta-tools for extending Claude Code:**

| Plugin        | Purpose                          | Best For                      | Complexity |
|---------------|----------------------------------|-------------------------------|------------|
| agent-sdk-dev | Build Agent SDK apps             | Standalone AI agents          | Medium     |
| plugin-dev    | Build Claude Code plugins        | Extending Claude Code         | High       |
| hookify       | Create hooks via markdown config | Quick behavior prevention     | Low        |

**All 3 = Low cost (only when invoked)**

**Key differences:**
- **agent-sdk-dev:** Creates standalone apps (external to Claude Code)
- **plugin-dev:** Creates plugins (installed into Claude Code)
- **hookify:** Creates simple hooks via markdown (no coding)

**Recommended usage:**
- ✓ **hookify:** All projects (quick safety rules)
- ? **plugin-dev:** When extending Claude Code needed
- ? **agent-sdk-dev:** When building standalone agents needed

**Governance use:**
```bash
# Use hookify to enforce boundaries
/hookify Block edits to /Volumes/, /etc/, or v1_archive/
/hookify Warn when editing .md without updating TOC
```

---

For full detailed review, see CLAUDE_PLUGINS_REFERENCE.md lines 1595-2340.

**Components:**
- agent-sdk-dev: 1 command (`/new-sdk-app`) + 2 verifier agents
- plugin-dev: 1 command + 7 specialized skills (11K+ words)
- hookify: 4 commands + conversation analyzer agent

---

*Review completed: 2026-01-07*
*Reviewer: Claude Sonnet 4.5*
