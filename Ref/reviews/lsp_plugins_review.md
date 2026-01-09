# LSP Plugins Review

> **Category:** Language Server Plugins (LSP)
> **Count:** 10 plugins
> **Reviewed:** 2026-01-07
> **Cost:** Zero (when idle), Local (no API calls)

---

## Table of Contents

| Section | Title                            | Line   |
|---------|----------------------------------|--------|
| 1       | [Overview](#1-overview)          | :18    |
| 2       | [All 10 LSPs](#2-all-10-lsps)    | :38    |
| 3       | [Integration](#3-integration)    | :97    |
| 4       | [Recommendations](#4-recommendations) | :128   |

---

## 1. Overview

### What Are LSPs?

Language Server Protocol (LSP) plugins provide intelligent code features:
- ✅ Smart code completion (context-aware)
- ✅ Go-to-definition (jump to symbol definitions)
- ✅ Find references (find all usages)
- ✅ Real-time error checking (catch errors as you type)
- ✅ Refactoring support (rename, extract methods)

### Key Characteristics

**All LSPs share:**
- **Cost:** Zero (local language servers, no API calls)
- **Activation:** Automatic when editing supported file types
- **Performance:** Local processing, instant results
- **Installation:** Auto-suggested by Claude Code based on project files

---

## 2. All 10 LSPs

| LSP               | Language    | Extensions           | Install Count | Requirements        |
|-------------------|-------------|----------------------|---------------|---------------------|
| typescript-lsp    | TypeScript/JS | .ts, .tsx, .js, .jsx | 15.0K         | None                |
| pyright-lsp       | Python      | .py, .pyi            | 8.7K          | None                |
| gopls-lsp         | Go          | .go                  | 3.3K          | None                |
| rust-analyzer-lsp | Rust        | .rs                  | 2.8K          | None                |
| csharp-lsp        | C#          | .cs                  | 2.7K          | .NET SDK 6.0+       |
| php-lsp           | PHP         | .php                 | 2.4K          | None                |
| jdtls-lsp         | Java        | .java                | 2.4K          | Java 17+ (JDK)      |
| clangd-lsp        | C/C++       | .c, .cpp, .h, .hpp   | 2.0K          | None                |
| swift-lsp         | Swift       | .swift               | 2.0K          | Xcode / Swift toolchain |
| lua-lsp           | Lua         | .lua                 | 1.3K          | None                |

### typescript-lsp

**Language:** TypeScript & JavaScript
**Key Features:**
- Type-aware auto-completion
- Real-time TypeScript error checking
- Refactoring (rename, extract)
- Go-to-definition for imports and symbols

**When to use:** Essential for TypeScript/JavaScript development

**Projects:** FILICITI (React/TypeScript), COEVOLVE (React/TypeScript)

### pyright-lsp

**Language:** Python
**Key Features:**
- Static type checking with type hints
- Smart auto-completion for Python libraries
- Type inference and diagnostics
- Go-to-definition across modules

**When to use:** Python projects with type hints

### gopls-lsp

**Language:** Go
**Key Features:**
- Go-aware code completion
- Automatic imports management
- Code formatting
- Build and test integration

**When to use:** Essential for Go development

### rust-analyzer-lsp

**Language:** Rust
**Key Features:**
- Rust-specific auto-completion with macro expansion
- Borrow checker integration
- Inline type hints
- Run and debug support

**When to use:** Essential for Rust development

### csharp-lsp

**Language:** C#
**Key Features:**
- .NET framework-aware completion
- Namespace and using management
- Code diagnostics and fixes

**Requirements:** .NET SDK 6.0 or later

### php-lsp

**Language:** PHP
**Key Features:**
- PHP-aware auto-completion
- Framework detection (Laravel, Symfony, WordPress)
- Code diagnostics and formatting

**When to use:** PHP development with frameworks

### jdtls-lsp

**Language:** Java
**Key Features:**
- Java-specific code completion
- Maven/Gradle project support
- Advanced refactoring tools

**Requirements:** Java 17 or later (JDK)

### clangd-lsp

**Language:** C/C++
**Key Features:**
- Clang-based error checking
- Cross-reference navigation
- Code formatting (clang-format)

**When to use:** C/C++ development, system programming, embedded

### swift-lsp

**Language:** Swift
**Key Features:**
- Swift-specific auto-completion
- SwiftUI support
- Protocol and extension navigation

**Requirements:** Xcode (macOS) or Swift toolchain

### lua-lsp

**Language:** Lua
**Key Features:**
- Lua-aware completion
- EmmyLua annotations support
- Diagnostics and formatting

**When to use:** Lua scripting, game dev (Roblox, Love2D), Neovim config

---

## 3. Integration

### With Governance System

**Cost tracking:**
- All LSPs = Zero cost (local)
- No API token consumption
- Safe to install all needed LSPs

**Auto-installation:**
- Claude Code suggests LSPs based on project files detected
- v2.5 §G45: LSPs auto-install by Claude Code (no forced installs)

### With Development Workflows

**LSPs enhance all workflows:**

```
/feature-dev Build feature
  ↓
Phase 5: Implementation
  ↓
LSPs provide real-time:
  - Type checking
  - Auto-completion
  - Error detection
  ↓
Cleaner code, fewer bugs
```

**LSPs work alongside:**
- feature-dev (implementation phase)
- code-review (catch errors earlier)
- frontend-design (TypeScript/React projects)

### Project-Specific LSPs

**FILICITI (React/TypeScript):**
```
✓ typescript-lsp  - Essential for TypeScript/React
? tailwind-lsp    - If using Tailwind CSS (external)
```

**COEVOLVE (React/TypeScript):**
```
✓ typescript-lsp  - Essential for TypeScript/React
? tailwind-lsp    - If using Tailwind CSS (external)
```

**Governance (Markdown/Shell):**
```
✗ No LSPs needed  - Plain text .md files
? lua-lsp         - If Neovim config present
```

---

## 4. Recommendations

### Best Practices

**1. Install LSPs for your stack:**
```
TypeScript/React → typescript-lsp
Python           → pyright-lsp
Go               → gopls-lsp
Rust             → rust-analyzer-lsp
C#               → csharp-lsp
PHP              → php-lsp
Java             → jdtls-lsp
C/C++            → clangd-lsp
Swift            → swift-lsp
Lua              → lua-lsp
```

**2. Zero cost = install proactively:**
- LSPs consume zero tokens
- Install all LSPs for languages you might use
- No downside to having them installed

**3. Auto-suggestions:**
- Claude Code detects project files
- Auto-suggests relevant LSPs
- Accept suggestions for best experience

**4. LSPs + type hints:**
- Maximum benefit with type annotations
- TypeScript: Use strict type checking
- Python: Add type hints to functions
- Rust: Already has strong typing

**5. LSPs complement, don't replace review:**
```
LSPs catch:         code-review catches:
- Syntax errors     - Logic errors
- Type errors       - Design issues
- Missing imports   - Security vulnerabilities
- Formatting        - Code quality
```

### Cost Optimization

**Zero cost = no optimization needed:**
- LSPs run locally (no API calls)
- Install all relevant to your projects
- Leave installed even if not actively using

### Plugin Selection by Project

**FILICITI (React TypeScript):**
```
✓ typescript-lsp   - MUST HAVE
```

**COEVOLVE (React TypeScript):**
```
✓ typescript-lsp   - MUST HAVE
```

**Governance (Markdown docs):**
```
✗ No LSPs needed
```

**Multi-language projects:**
```
Install all relevant LSPs
Example: Full-stack project
  ✓ typescript-lsp  - Frontend
  ✓ pyright-lsp     - Backend
  ✓ gopls-lsp       - Microservices
```

### Integration with v2.5 Governance

**v2.5 §G45:**
- LSPs auto-install by Claude Code
- No forced installs
- User retains control

**Future v3 enhancements:**
- Track LSP usage per project
- Auto-disable unused LSPs
- LSP performance metrics

### When NOT to Use LSPs

**Rare scenarios:**
- ✗ Performance-critical low-level editing (rare)
- ✗ Projects without supported languages
- ✗ Plain text files (.txt, .md, etc.)

**For all other cases: USE LSPs**

---

## Summary

| Aspect               | Details                                    |
|----------------------|--------------------------------------------|
| Count                | 10 LSPs covering major languages           |
| Cost                 | Zero (local processing, no API calls)      |
| Activation           | Automatic when editing supported files     |
| Installation         | Auto-suggested by Claude Code              |
| Performance          | Local, instant results                     |
| Recommendation       | Install all LSPs for your tech stack       |

**Key Insights:**

1. **Zero cost = install freely:** No token consumption, no downside
2. **Automatic activation:** Work seamlessly in background
3. **Language-specific:** Each LSP optimized for its language
4. **Complementary to review:** Catch errors early, review catches logic/design issues
5. **Project-essential:** TypeScript/React projects MUST have typescript-lsp

**Recommended for:**
- ✓ FILICITI: typescript-lsp (MUST)
- ✓ COEVOLVE: typescript-lsp (MUST)
- ✗ Governance: None needed (markdown docs)

**v2.5 Integration:**
- Auto-install suggested based on project files
- Zero cost = no governance cost concerns
- Always safe to install relevant LSPs

---

*Review completed: 2026-01-07*
*Reviewer: Claude Sonnet 4.5*
*Source: CLAUDE_PLUGINS_REFERENCE.md (lines 3612-3820)*
