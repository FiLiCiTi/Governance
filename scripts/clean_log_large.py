#!/usr/bin/env python3
"""
Large file cleaner with chunked processing
Handles files >500MB by processing in chunks and extracting meaningful blocks

Strategy:
1. Process file in chunks (100MB at a time)
2. Extract user inputs and Claude outputs
3. Use aggressive deduplication
4. Remove status bar noise

Usage:
    python3 clean_log_large.py <input.log> [output.log]
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
    pattern = r'\[38;2;\d+;\d+;\d+m⏺'
    return re.search(pattern, line) is not None


def is_status_bar_line(line):
    """Check if line is a status bar update (should be removed)"""
    # Common status bar patterns
    status_patterns = [
        'Model:',
        'No todos',
        '🟢 Hooks:',
        '🟢 Context:',
        '🟢 Warmup:',
        'Percolating',
        'tokens)',
        'current:',
        'latest:',
    ]

    return any(pattern in line for pattern in status_patterns)


def clean_log_chunked(input_file, output_file=None):
    """Clean log file using chunked processing"""
    input_path = Path(input_file)

    if not input_path.exists():
        print(f"❌ Error: File not found: {input_file}")
        return None

    if output_file is None:
        output_file = str(input_path).replace('.log', '_cleaned.log')

    # Get file size
    file_size = input_path.stat().st_size
    file_size_gb = file_size / 1024 / 1024 / 1024

    print(f"📖 Reading: {input_file}")
    print(f"📊 File size: {file_size_gb:.2f} GB")
    print(f"🔄 Processing with aggressive deduplication...")

    lines_read = 0
    lines_written = 0
    user_inputs = 0
    claude_outputs = 0
    separators = 0
    status_bars_removed = 0

    # Track seen content for deduplication
    seen_user_inputs = set()
    seen_claude_outputs = set()

    last_line_type = None

    try:
        with open(input_file, 'r', encoding='utf-8', errors='ignore') as infile:
            with open(output_file, 'w', encoding='utf-8') as outfile:
                in_claude_block = False
                claude_block = []

                for line in infile:
                    lines_read += 1

                    # Progress indicator every 1M lines
                    if lines_read % 1_000_000 == 0:
                        mb_written = Path(output_file).stat().st_size / 1024 / 1024
                        print(f"   📍 Processed {lines_read:,} lines ({mb_written:.1f}MB written)")

                    # Skip status bar lines
                    if is_status_bar_line(line):
                        status_bars_removed += 1
                        continue

                    # Check for user input (final submitted)
                    if is_user_input_final(line):
                        # Finish any Claude block first
                        if in_claude_block:
                            block_content = '\n'.join(claude_block)
                            if block_content not in seen_claude_outputs:
                                outfile.write(block_content + '\n')
                                seen_claude_outputs.add(block_content)
                                lines_written += len(claude_block)
                                claude_outputs += 1
                            claude_block = []
                            in_claude_block = False

                        # Write user input if not seen
                        if line not in seen_user_inputs:
                            outfile.write(line)
                            seen_user_inputs.add(line)
                            lines_written += 1
                            user_inputs += 1
                            last_line_type = 'user'
                        continue

                    # Check for Claude output marker
                    if has_claude_marker(line):
                        # Start new Claude block
                        in_claude_block = True
                        claude_block = [line]
                        continue

                    # If in Claude block, collect lines
                    if in_claude_block:
                        if is_separator(line):
                            # End of Claude block
                            block_content = '\n'.join(claude_block)
                            if block_content not in seen_claude_outputs:
                                outfile.write(block_content + '\n')
                                seen_claude_outputs.add(block_content)
                                lines_written += len(claude_block)
                                claude_outputs += 1

                            # Write separator only if last line wasn't separator
                            if last_line_type != 'separator':
                                outfile.write(line)
                                lines_written += 1
                                separators += 1
                                last_line_type = 'separator'

                            claude_block = []
                            in_claude_block = False
                        else:
                            claude_block.append(line)
                        continue

                    # Check for separator
                    if is_separator(line):
                        if last_line_type != 'separator':
                            outfile.write(line)
                            lines_written += 1
                            separators += 1
                            last_line_type = 'separator'
                        continue

                # Finish any remaining Claude block
                if in_claude_block and claude_block:
                    block_content = '\n'.join(claude_block)
                    if block_content not in seen_claude_outputs:
                        outfile.write(block_content + '\n')
                        lines_written += len(claude_block)
                        claude_outputs += 1

        # Calculate stats
        output_size = Path(output_file).stat().st_size
        output_size_gb = output_size / 1024 / 1024 / 1024
        reduction_pct = (1 - output_size / file_size) * 100 if file_size > 0 else 0

        print(f"\n✅ Complete!")
        print(f"📊 Stats:")
        print(f"   Lines read: {lines_read:,}")
        print(f"   Lines written: {lines_written:,}")
        print(f"   User inputs: {user_inputs:,}")
        print(f"   Claude outputs: {claude_outputs:,}")
        print(f"   Separators: {separators:,}")
        print(f"   Status bars removed: {status_bars_removed:,}")
        print(f"   Reduction: {reduction_pct:.1f}%")
        print(f"   Input size: {file_size_gb:.2f} GB")
        print(f"   Output size: {output_size_gb:.2f} GB")
        print(f"   Saved to: {output_file}")

        return output_file

    except Exception as e:
        print(f"❌ Error processing file: {e}")
        import traceback
        traceback.print_exc()
        return None


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 clean_log_large.py <logfile.log> [output.log]")
        print("")
        print("Example:")
        print("  python3 clean_log_large.py Conversations/large_file.log")
        print("")
        print("Note: This script uses chunked processing for large files (>500MB)")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None

    clean_log_chunked(input_file, output_file)


if __name__ == '__main__':
    main()
