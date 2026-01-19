# Log Cleaning Guide

> **Purpose:** Guide for cleaning Claude Code conversation logs
> **Updated:** 2026-01-19
> **Version:** v1.0

## Table of Contents

| Section | Title                                              | Line |
|---------|---------------------------------------------------|------|
| 1       | [Overview](#1-overview)                            | :17  |
| 2       | [Script Selection](#2-script-selection)            | :39  |
| 3       | [clean_log.py (Small Files)](#3-clean_logpy-small-files) | :74  |
| 4       | [clean_log_large.py (Large Files)](#4-clean_log_largepy-large-files) | :115 |
| 5       | [Performance Results](#5-performance-results)      | :155 |
| 6       | [Best Practices](#6-best-practices)                | :188 |

---------------------------------------------------------------------------------------------------------------------------

## 1. Overview

### 1.1 Purpose

Claude Code conversation logs can grow very large due to:
- Status bar updates (Model, tokens, context indicators)
- ANSI cursor movement codes for terminal redraws
- Repeated interactions and duplicate outputs

This guide explains when and how to use each cleaning script.

### 1.2 Available Scripts

| Script                 | File Size      | Method                    | Memory Usage |
|------------------------|----------------|---------------------------|--------------|
| clean_log.py           | < 500MB        | Load entire file          | High         |
| clean_log_large.py     | > 500MB        | Streaming line-by-line    | Low          |
| clean_log_streaming.py | (deprecated)   | Simple duplicate removal  | Low          |

---------------------------------------------------------------------------------------------------------------------------

## 2. Script Selection

### 2.1 Decision Tree

```
File size?
├── < 500MB → Use clean_log.py
│   └── Standard block extraction + deduplication
│
└── > 500MB → Use clean_log_large.py
    └── Streaming processing + aggressive status bar removal
```

### 2.2 When to Use Each Script

**Use clean_log.py when:**
- File is under 500MB
- Memory is not a concern
- You want the original deduplication logic
- File has normal conversation structure

**Use clean_log_large.py when:**
- File is over 500MB
- File has excessive status bar updates
- Memory efficiency is critical
- You need aggressive deduplication (99%+ reduction)

---------------------------------------------------------------------------------------------------------------------------

## 3. clean_log.py (Small Files)

### 3.1 Usage

```bash
python3 scripts/clean_log.py <input.log> [output.log]
```

**Example:**
```bash
python3 scripts/clean_log.py Conversations/20260104_1635_Governance.log
```

### 3.2 How It Works

1. Loads entire file into memory
2. Extracts user input blocks (lines with background color ANSI codes)
3. Extracts Claude output blocks (lines starting with ⏺ marker)
4. Removes exact duplicate blocks
5. Keeps separators (deduplicated)
6. Writes cleaned output

### 3.3 Expected Results

- **Reduction:** 40-90% for normal logs
- **Processing time:** Fast for small files
- **Memory usage:** ~2-3x file size

### 3.4 Best For

- Regular conversation logs
- Files with normal user/Claude exchanges
- Files without excessive status bar churn

---------------------------------------------------------------------------------------------------------------------------

## 4. clean_log_large.py (Large Files)

### 4.1 Usage

```bash
python3 scripts/clean_log_large.py <input.log> [output.log]
```

**Example:**
```bash
python3 scripts/clean_log_large.py Conversations/20260106_0456_Governance.log
```

### 4.2 How It Works

1. Processes file line by line (streaming)
2. Removes status bar lines (Model:, No todos, tokens, etc.)
3. Extracts user inputs and Claude outputs
4. Aggressive deduplication using sets to track seen content
5. Removes consecutive separators
6. Writes output as it processes

### 4.3 Expected Results

- **Reduction:** 99%+ for logs with status bar churn
- **Processing time:** ~2-3 minutes per GB
- **Memory usage:** Constant (~20-30MB)

### 4.4 Best For

- Very large files (>500MB)
- Logs with excessive status bar updates
- Files with millions of lines
- When memory is limited

---------------------------------------------------------------------------------------------------------------------------

## 5. Performance Results

### 5.1 Test Case: 5.6GB Governance Log

**File characteristics:**
- Size: 5.64 GB
- Lines: 55,096,222
- Issue: Massive status bar churn from terminal redraws

**Results with clean_log_large.py:**

| Metric              | Value          |
|---------------------|----------------|
| Input size          | 5.64 GB        |
| Output size         | 4.8 MB         |
| Compressed (.xz)    | 204 KB         |
| Reduction           | 99.9%          |
| Lines read          | 55,096,222     |
| Lines written       | 53,332         |
| User inputs         | 175            |
| Claude outputs      | 2,525          |
| Status bars removed | 190,084        |
| Processing time     | ~3 minutes     |

---------------------------------------------------------------------------------------------------------------------------

## 6. Best Practices

### 6.1 Workflow

1. **Check file size first:**
   ```bash
   ls -lh Conversations/*.log
   ```

2. **Choose appropriate script:**
   - < 500MB: clean_log.py
   - > 500MB: clean_log_large.py

3. **Run cleaning:**
   ```bash
   python3 scripts/clean_log_[type].py input.log
   ```

4. **Compress result:**
   ```bash
   xz -9 -v output_cleaned.log
   ```

5. **Verify and delete original:**
   ```bash
   ls -lh Conversations/*
   rm original.log
   ```

### 6.2 File Naming Convention

- Original: `20260106_0456_Governance.log`
- Cleaned: `20260106_0456_Governance_cleaned.log`
- Compressed: `20260106_0456_Governance_cleaned.log.xz`
- Terminal save: `20260106_0456_Governance_TS.log` (never clean these!)

### 6.3 Never Clean These Files

**_TS.log files** (Terminal Session saves):
- These are manual saves from terminal sessions
- Keep them in original uncompressed form
- They're already curated content (no status bar churn)

### 6.4 Compression

Always compress cleaned logs:
```bash
xz -9 -v cleaned_file.log
```

**Compression ratios:**
- Typical: 20-40x reduction
- Example: 4.8MB → 204KB (23.5x reduction)

---------------------------------------------------------------------------------------------------------------------------

*Guide: ~/Desktop/FILICITI/Governance/scripts/LOG_CLEANING_GUIDE.md | v1.0 | Updated: 2026-01-19*
