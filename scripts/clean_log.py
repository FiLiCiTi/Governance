#!/usr/bin/env python3
"""
Clean Claude Code log files
Keeps ANSI codes, removes duplicates intelligently

Rules:
1. User input: Lines with [48;2;55;55;55m and [38;2;255;255;255m
2. Claude output: Lines starting with ⏺ (any color) until separator
3. Remove exact duplicates

Usage:
    python3 clean_log.py <input.log> [output.log]
"""

import re
import sys
from pathlib import Path

def is_user_input_final(line):
    """Check if line is final submitted user input (has background color)"""
    return '[48;2;55;55;55m' in line and '[38;2;255;255;255m' in line

def is_separator(line):
    """Check if line is a separator"""
    return '[38;2;136;136;136m──────' in line

def has_claude_marker(line):
    """Check if line has Claude output marker ⏺ with any color"""
    # Match [38;2;R;G;B]m⏺ where R,G,B are any digits
    pattern = r'\[38;2;\d+;\d+;\d+m⏺'
    return re.search(pattern, line) is not None

def extract_blocks(content):
    """Extract user inputs and Claude outputs"""
    lines = content.split('\n')
    blocks = []
    i = 0

    while i < len(lines):
        line = lines[i]

        # Check for user input (final submitted) - single line
        if is_user_input_final(line):
            blocks.append(('user', line))
            i += 1
            continue

        # Check for Claude output
        if has_claude_marker(line):
            # Collect until empty line or separator
            block_lines = [line]
            i += 1
            while i < len(lines):
                if is_separator(lines[i]):
                    break
                block_lines.append(lines[i])
                i += 1
            blocks.append(('claude', '\n'.join(block_lines)))
            continue

        # Check for separator - only keep one per sequence
        if is_separator(line):
            # Skip if last block was also separator
            if not blocks or blocks[-1][0] != 'separator':
                blocks.append(('separator', line))
            i += 1
            continue

        i += 1

    return blocks

def deduplicate_blocks(blocks):
    """Remove exact duplicate blocks"""
    seen = set()
    result = []

    for block_type, content in blocks:
        # For separators, always keep (but we already deduplicated consecutive ones)
        if block_type == 'separator':
            result.append((block_type, content))
            continue

        # Check if we've seen this exact content
        if content not in seen:
            seen.add(content)
            result.append((block_type, content))

    return result

def clean_log(input_file, output_file=None):
    """Clean log file"""
    input_path = Path(input_file)

    if not input_path.exists():
        print(f"❌ Error: File not found: {input_file}")
        return None

    if output_file is None:
        output_file = str(input_path).replace('.log', '_cleaned.log')

    print(f"📖 Reading: {input_file}")

    try:
        with open(input_file, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
    except Exception as e:
        print(f"❌ Error reading file: {e}")
        return None

    original_size = len(content)
    original_mb = original_size / 1024 / 1024
    print(f"📊 Original size: {original_size:,} chars ({original_mb:.2f} MB)")

    # Extract blocks
    print("🔍 Extracting user inputs and Claude outputs...")
    blocks = extract_blocks(content)
    print(f"   Found {len(blocks)} blocks")

    # Count block types
    user_blocks = sum(1 for t, _ in blocks if t == 'user')
    claude_blocks = sum(1 for t, _ in blocks if t == 'claude')
    separators = sum(1 for t, _ in blocks if t == 'separator')
    print(f"   User inputs: {user_blocks}, Claude outputs: {claude_blocks}, Separators: {separators}")

    # Deduplicate
    print("🔄 Removing duplicates...")
    cleaned_blocks = deduplicate_blocks(blocks)
    user_blocks_clean = sum(1 for t, _ in cleaned_blocks if t == 'user')
    claude_blocks_clean = sum(1 for t, _ in cleaned_blocks if t == 'claude')
    separators_clean = sum(1 for t, _ in cleaned_blocks if t == 'separator')
    print(f"   After dedup: User inputs: {user_blocks_clean}, Claude outputs: {claude_blocks_clean}, Separators: {separators_clean}")

    # Rebuild content
    cleaned_lines = []
    for block_type, content in cleaned_blocks:
        cleaned_lines.append(content)
        if block_type != 'separator':
            cleaned_lines.append('')  # Add spacing after non-separators

    cleaned_content = '\n'.join(cleaned_lines)

    cleaned_size = len(cleaned_content)
    cleaned_mb = cleaned_size / 1024 / 1024
    reduction = (1 - cleaned_size / original_size) * 100 if original_size > 0 else 0

    print(f"📊 Cleaned size: {cleaned_size:,} chars ({cleaned_mb:.2f} MB)")
    print(f"📉 Reduction: {reduction:.1f}%")

    # Save
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(cleaned_content)
        print(f"✅ Saved to: {output_file}")
        return output_file
    except Exception as e:
        print(f"❌ Error writing file: {e}")
        return None

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 clean_log.py <logfile.log> [output.log]")
        print("")
        print("Example:")
        print("  python3 clean_log.py Conversations/20260104_1635_Governance.log")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None

    clean_log(input_file, output_file)

if __name__ == '__main__':
    main()
