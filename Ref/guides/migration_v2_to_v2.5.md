# Migration Guide: v2 → v2.5

> **Purpose:** Guide to upgrading from Governance v2 to v2.5 (Plugin-Aware Governance)
> **Version:** 3.0
> **Updated:** 2026-01-06

---

## Table of Contents

| Section | Topic                                    |
|---------|------------------------------------------|
| 1       | What's New in V2.5                         |
| 2       | Breaking Changes                         |
| 3       | Optional Upgrades                        |
| 4       | Migration Steps                          |
| 5       | Verification                             |
| 6       | Rollback Instructions                    |

---

## 1. What's New in V2.5

### 1.1 Core Concept: Plugin-Aware Governance

**V2.5 adds plugin awareness to v2 governance**, helping you make informed plugin installation decisions based on cost, tech stack, and project needs.

### 1.2 New Features

| Feature                        | Description                                  | File                           |
|--------------------------------|----------------------------------------------|--------------------------------|
| Plugin cost tracking           | SessionStart shows plugin count + warnings   | `hooks/inject_context.sh`      |
| Per-product plugin guides      | Recommended plugins per tech stack           | `[PRODUCT]/.claude/recommended_plugins.md` |
| Plugin selection guide         | How to choose plugins                        | `guides/plugin_selection.md`   |
| Per-product setup guide        | Product setup instructions                   | `guides/per_product_setup.md`  |
| V2.5 full specification          | Complete v2.5 documentation                    | `V2.5_FULL_SPEC.md`              |
| Global plugin awareness        | Plugin cost warnings in CLAUDE.md            | `~/.claude/CLAUDE.md`          |

### 1.3 What Changed from v2

| Component          | v2                             | v2.5                                       |
|--------------------|--------------------------------|------------------------------------------|
| SessionStart hook  | Shows date + boundaries        | Shows date + boundaries + plugin count   |
| Global CLAUDE.md   | 10 rules                       | 12 rules (added plugin awareness)        |
| Per-product setup  | Not defined                    | recommended_plugins.md per product       |
| Plugin guidance    | None                           | 3 new guides (selection, setup, migration)|
| Specification      | V2_FULL_SPEC.md                | V2.5_FULL_SPEC.md (plugin sections added)  |

### 1.4 What Stayed the Same (100% Backward Compatible)

**All v2 features preserved:**

- ✅ 9-layer prompt system (unchanged)
- ✅ Hook enforcement (exit 2 = block)
- ✅ Minimal CLAUDE.md approach (~25 lines)
- ✅ `cc` wrapper for terminal capture
- ✅ Decision ID system (#G, #P, #I, #S, #B)
- ✅ All scripts (audit, test, watch, sync)
- ✅ Warm-up protocol (90-minute timer)
- ✅ Company-level vs per-project governance

---

## 2. Breaking Changes

### 2.1 Summary

**ZERO BREAKING CHANGES** - v2.5 is fully backward compatible with v2.

### 2.2 What This Means

**You can:**
- ✅ Continue using v2 projects without any changes
- ✅ Mix v2 and v2.5 features (upgrade incrementally)
- ✅ Skip v2.5 features entirely (v2 still works)
- ✅ Rollback to v2 anytime (no data loss)

**You don't need to:**
- ❌ Update any existing CLAUDE.md files (optional)
- ❌ Modify hooks (optional enhancement)
- ❌ Create new files (optional)
- ❌ Change workflows (optional improvements)

### 2.3 V2 Projects Work Unchanged

**Example: FILICITI project in v2 mode**

```
~/Desktop/FILICITI/
└── Products/COEVOLVE/code/
    └── CLAUDE.md                  ← v2 format (still works)
```

**After v2.5 release:**
- ✅ Session starts normally
- ✅ Hooks enforce boundaries
- ✅ `cc` wrapper captures terminal
- ✅ Everything works as before

**Optionally add v2.5:**
```
~/Desktop/FILICITI/
├── .claude/
│   └── recommended_plugins.md     ← NEW (optional)
└── Products/COEVOLVE/code/
    └── CLAUDE.md                  ← v2 format (unchanged)
```

---

## 3. Optional Upgrades

### 3.1 Upgrade Decision Matrix

| Upgrade                     | Benefit                          | Effort | Recommended For    |
|-----------------------------|----------------------------------|--------|--------------------|
| Global CLAUDE.md (2 rules)  | Plugin cost awareness            | 2 min  | Everyone           |
| SessionStart hook           | See plugin count at session start| 5 min  | Everyone           |
| Per-product plugin guides   | Tech stack-specific guidance     | 10 min | Multi-product users|
| Read v2.5 guides              | Learn plugin selection           | 30 min | New plugin users   |

### 3.2 Recommended Upgrade Path

**For solo developers (like you):**

1. ✅ **First:** Update global CLAUDE.md (2 new rules) → 2 minutes
2. ✅ **Second:** Enhance SessionStart hook → 5 minutes
3. ✅ **Third:** Create per-product plugin guides → 10 minutes per product
4. ✅ **Fourth:** Read plugin selection guide → 30 minutes

**Total time:** ~1 hour for complete v2.5 upgrade

**For teams:**

1. ✅ Update global CLAUDE.md
2. ✅ Enhance SessionStart hook
3. ✅ Create per-product plugin guides
4. ✅ Share guides with team
5. ✅ Train team on plugin selection

---

## 4. Migration Steps

### 4.1 Step 1: Update Global CLAUDE.md (2 Minutes)

**File:** `~/.claude/CLAUDE.md`

**Add these 2 new rules:**

```markdown
## Plugin Cost Awareness (NEW in v2.5)

11. **High-cost plugins warning**: Avoid output styling plugins (explanatory-output-style, learning-output-style, ralph-wiggum) unless absolutely necessary
    - These add 1000+ tokens per session
    - Only install ONE at a time maximum
    - Check `/plugin` to verify active plugins

12. **Plugin recommendations**: See ~/Desktop/Governance/guides/plugin_selection.md for:
    - Zero-cost plugins (safe to install anytime)
    - Per-project plugin recommendations
    - Tech stack-specific plugins
```

**Update version reference (in "Links" section):**

```markdown
## Links

- Governance: `~/Desktop/Governance/`
- Full spec: `~/Desktop/Governance/V2.5_FULL_SPEC.md`  ← Change from V2_FULL_SPEC.md
```

**Verification:**

```bash
# Check file updated
cat ~/.claude/CLAUDE.md | grep "Plugin Cost Awareness"
# Should show new section

# Count rules
cat ~/.claude/CLAUDE.md | grep "^[0-9]\\+\\." | wc -l
# Should show 12 (was 10 in v2)
```

### 4.2 Step 2: Enhance SessionStart Hook (5 Minutes)

**File:** `~/Desktop/Governance/hooks/inject_context.sh`

**Add lines 50-70 (plugin tracking):**

```bash
# Plugin cost tracking (v2.5)
if [ -f "$HOME/.claude/plugins/installed_plugins.json" ]; then
    HIGH_COST_PLUGINS=$(jq -r '.plugins[] | select(.name | test("output-style|ralph-wiggum")) | .name' "$HOME/.claude/plugins/installed_plugins.json" 2>/dev/null | wc -l | tr -d ' ')

    if [ "$HIGH_COST_PLUGINS" -gt 0 ]; then
        echo "⚠️  WARNING: $HIGH_COST_PLUGINS high-cost plugin(s) active (adds 1000+ tokens/session)"
    fi

    TOTAL_PLUGINS=$(jq -r '.plugins | length' "$HOME/.claude/plugins/installed_plugins.json" 2>/dev/null)
    echo "🔌 Plugins: $TOTAL_PLUGINS installed"
fi
```

**Where to add:** After line 49 (after the "Hooks: $HOOKS_COUNT" output)

**Verification:**

```bash
# Test hook manually
bash ~/Desktop/Governance/hooks/inject_context.sh

# Should output:
# 📅 Date: 2026-01-06 | 📁 Project: Governance | ✅ CAN: ... | 🔧 Hooks: 6 | 🔌 Plugins: 37 installed

# If high-cost plugins installed:
# ⚠️  WARNING: 1 high-cost plugin(s) active (adds 1000+ tokens/session)
# 📅 Date: 2026-01-06 | ... | 🔌 Plugins: 38 installed
```

### 4.3 Step 3: Create Per-Product Plugin Guides (10 Minutes Per Product)

**For FILICITI/COEVOLVE:**

```bash
# Create folder
mkdir -p ~/Desktop/FILICITI/.claude

# Create file
cat > ~/Desktop/FILICITI/.claude/recommended_plugins.md << 'EOF'
# FILICITI/COEVOLVE Recommended Plugins

## Always Active (Zero Cost)
- typescript-lsp (auto-activates for .ts/.tsx files)
- pyright-lsp (auto-activates for .py files)

## Install & Use On-Demand
- github (version control operations)
- context7 (AI documentation lookup)
- feature-dev (when building new features)
- code-review (before merging PRs)

## Tech Stack-Specific
- Next.js: Already supported via typescript-lsp
- FastAPI: Already supported via pyright-lsp
- PostgreSQL: No plugin needed (use Bash for psql)
- Docker: No plugin needed (use Bash for docker commands)

## See Also
- [Plugin Selection Guide](~/Desktop/Governance/guides/plugin_selection.md)
- [Per-Product Setup Guide](~/Desktop/Governance/guides/per_product_setup.md)
EOF
```

**For FlowInLife:**

```bash
# Create folder
mkdir -p ~/Desktop/FlowInLife_env/.claude

# Create file
cat > ~/Desktop/FlowInLife_env/.claude/recommended_plugins.md << 'EOF'
# FlowInLife Recommended Plugins

## Always Active (Zero Cost)
- typescript-lsp (React + React Native)
- php-lsp (Swoole backend)
- pyright-lsp (YutaAI Python backend)

## Install & Use On-Demand
- github (version control)
- context7 (documentation)
- code-review (pre-merge review)

## Tech Stack-Specific
- React Native: Already supported via typescript-lsp
- PHP/Swoole: Already supported via php-lsp
- MySQL: No plugin needed (use Bash)

## See Also
- [Plugin Selection Guide](~/Desktop/Governance/guides/plugin_selection.md)
- [Per-Product Setup Guide](~/Desktop/Governance/guides/per_product_setup.md)
EOF
```

**Verification:**

```bash
# Check files created
ls ~/Desktop/FILICITI/.claude/recommended_plugins.md
ls ~/Desktop/FlowInLife_env/.claude/recommended_plugins.md

# Verify content
cat ~/Desktop/FILICITI/.claude/recommended_plugins.md
```

### 4.4 Step 4: Update Governance CLAUDE.md (1 Minute)

**File:** `~/Desktop/Governance/CLAUDE.md`

**Update version reference:**

```markdown
## Links

- Full spec: `V2.5_FULL_SPEC.md`  ← Change from V2_FULL_SPEC.md
```

**Verification:**

```bash
cat ~/Desktop/Governance/CLAUDE.md | grep "Full spec"
# Should show: - Full spec: `V2.5_FULL_SPEC.md`
```

### 4.5 Step 5: Read V2.5 Guides (30 Minutes)

**Read in order:**

1. **V2.5_FULL_SPEC.md** (sections 1-3 for overview) → 10 minutes
2. **guides/plugin_selection.md** (all sections) → 15 minutes
3. **guides/per_product_setup.md** (your products only) → 5 minutes

**Files:**
- `~/Desktop/Governance/V2.5_FULL_SPEC.md`
- `~/Desktop/Governance/guides/plugin_selection.md`
- `~/Desktop/Governance/guides/per_product_setup.md`

---

## 5. Verification

### 5.1 Verification Checklist

After migration, verify:

**Global Layer:**
- [ ] `~/.claude/CLAUDE.md` has 12 rules (not 10)
- [ ] Rules 11-12 reference plugin cost awareness
- [ ] Links section references V2.5_FULL_SPEC.md

**Hooks:**
- [ ] `inject_context.sh` has plugin tracking code (lines 50-70)
- [ ] SessionStart shows plugin count: "🔌 Plugins: 37 installed"
- [ ] If high-cost plugins, warning appears

**Per-Product:**
- [ ] `~/Desktop/FILICITI/.claude/recommended_plugins.md` exists
- [ ] `~/Desktop/FlowInLife_env/.claude/recommended_plugins.md` exists
- [ ] Files contain tech stack-specific recommendations

**Governance:**
- [ ] `~/Desktop/Governance/CLAUDE.md` references V2.5_FULL_SPEC.md
- [ ] `~/Desktop/Governance/V2.5_FULL_SPEC.md` exists
- [ ] `~/Desktop/Governance/guides/` folder contains 3 guides

### 5.2 Test Session

**Start a new session and verify:**

```bash
cc
```

**Expected output:**

```
📅 Date: 2026-01-06 | 📁 Project: Governance | ✅ CAN: This folder (Governance/) | 🚫 CANNOT: /Volumes/, /etc/, v1_archive/ | 🔧 Hooks: 6 | 🔌 Plugins: 37 installed
```

**Check:**
- ✅ Date shows 2026-01-06
- ✅ Project detected
- ✅ Boundaries listed
- ✅ Hooks count: 6
- ✅ **NEW:** Plugins count shown

**If high-cost plugin installed:**

```
⚠️  WARNING: 1 high-cost plugin(s) active (adds 1000+ tokens/session)
📅 Date: 2026-01-06 | ... | 🔌 Plugins: 38 installed
```

### 5.3 Test Plugin Commands

```bash
# List installed plugins
/plugin

# Should show all 37-38 plugins with categories
```

### 5.4 Test Per-Product Guides

```bash
# Read FILICITI recommendations
cat ~/Desktop/FILICITI/.claude/recommended_plugins.md

# Read FlowInLife recommendations
cat ~/Desktop/FlowInLife_env/.claude/recommended_plugins.md
```

---

## 6. Rollback Instructions

### 6.1 When to Rollback

**Rollback if:**
- ❌ SessionStart hook errors out
- ❌ Plugin tracking causes issues
- ❌ You prefer v2 simplicity

**No need to rollback if:**
- ✅ You just don't want v2.5 features → Simply don't use them (v2 still works)
- ✅ You want partial v2.5 → Keep what you like, skip what you don't

### 6.2 Rollback Steps

**Step 1: Revert Global CLAUDE.md**

```bash
# Remove rules 11-12 (plugin awareness)
# Change V2.5_FULL_SPEC.md back to V2_FULL_SPEC.md in Links section
```

**Step 2: Revert SessionStart Hook**

```bash
# Edit ~/Desktop/Governance/hooks/inject_context.sh
# Remove lines 50-70 (plugin tracking code)
```

**Step 3: Delete Per-Product Plugin Guides (Optional)**

```bash
# Only if you want to remove them
rm ~/Desktop/FILICITI/.claude/recommended_plugins.md
rm ~/Desktop/FlowInLife_env/.claude/recommended_plugins.md
```

**Step 4: Revert Governance CLAUDE.md**

```bash
# Change V2.5_FULL_SPEC.md back to V2_FULL_SPEC.md in Links section
```

**Step 5: Verify Rollback**

```bash
# Start session
cc

# Should show v2 output (no plugin count):
# 📅 Date: 2026-01-06 | 📁 Project: Governance | ✅ CAN: ... | 🔧 Hooks: 6
```

### 6.3 No Data Loss

**Rollback is safe:**
- ✅ No v2 files were modified (except optionally)
- ✅ All v2 features still work
- ✅ Can re-upgrade to v2.5 anytime
- ✅ No git history affected

---

## See Also

- [V2.5 Full Specification](~/Desktop/Governance/V2.5_FULL_SPEC.md)
- [Plugin Selection Guide](~/Desktop/Governance/guides/plugin_selection.md)
- [Per-Product Setup Guide](~/Desktop/Governance/guides/per_product_setup.md)
- [V2 Full Specification](~/Desktop/Governance/V2_FULL_SPEC.md)
- [CLAUDE_PLUGINS_REFERENCE.md](~/Desktop/Governance/CLAUDE_PLUGINS_REFERENCE.md)

---

**End of Migration Guide**

*Version: 3.0 | Updated: 2026-01-06*
