#!/usr/bin/env python3
"""
Streaming log cleaner for large files (>500MB)
Memory-efficient line-by-line processing

Strategy:
1. Read file line by line (low memory)
2. Remove consecutive duplicate lines (status bar churn)
3. Remove excessive ANSI cursor movement sequences
4. Write cleaned output as we go

Usage:
    python3 clean_log_streaming.py <input.log> [output.log]
"""

import sys
from pathlib import Path


def is_ansi_cursor_line(line):
    """Check if line is pure ANSI cursor movement (should be removed)"""
    # Lines that are just cursor positioning/clearing
    if not line.strip():
        return False

    # Common cursor movement sequences
    cursor_codes = [
        '[?25l',  # Hide cursor
        '[?25h',  # Show cursor
        '[?2004h',  # Bracketed paste mode
        '[?2004l',
        '[?2026h',  # Synchronized output
        '[?2026l',
        '[2K',    # Clear line
        '[1A',    # Move cursor up
        '[G',     # Move cursor to column 1
    ]

    # Check if line is ONLY cursor codes (no actual content)
    temp = line
    for code in cursor_codes:
        temp = temp.replace(code, '')

    # If after removing cursor codes, line is empty or just whitespace
    return len(temp.strip()) == 0


def clean_log_streaming(input_file, output_file=None):
    """Clean log file using streaming approach"""
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
    print(f"🔄 Processing line by line (streaming mode)...")

    lines_read = 0
    lines_written = 0
    lines_removed_duplicate = 0
    lines_removed_cursor = 0
    last_line = None

    try:
        with open(input_file, 'r', encoding='utf-8', errors='ignore') as infile:
            with open(output_file, 'w', encoding='utf-8') as outfile:
                for line in infile:
                    lines_read += 1

                    # Progress indicator every 1M lines
                    if lines_read % 1_000_000 == 0:
                        print(f"   📍 Processed {lines_read:,} lines")

                    # Remove pure cursor movement lines
                    if is_ansi_cursor_line(line):
                        lines_removed_cursor += 1
                        continue

                    # Remove consecutive duplicates
                    if line == last_line:
                        lines_removed_duplicate += 1
                        continue

                    # Write line
                    outfile.write(line)
                    lines_written += 1
                    last_line = line

        # Calculate stats
        output_size = Path(output_file).stat().st_size
        output_size_gb = output_size / 1024 / 1024 / 1024
        reduction_pct = (1 - output_size / file_size) * 100 if file_size > 0 else 0

        print(f"\n✅ Complete!")
        print(f"📊 Stats:")
        print(f"   Lines read: {lines_read:,}")
        print(f"   Lines written: {lines_written:,}")
        print(f"   Removed (cursor): {lines_removed_cursor:,}")
        print(f"   Removed (duplicate): {lines_removed_duplicate:,}")
        print(f"   Total removed: {lines_removed_cursor + lines_removed_duplicate:,}")
        print(f"   Reduction: {reduction_pct:.1f}%")
        print(f"   Output size: {output_size_gb:.2f} GB")
        print(f"   Saved to: {output_file}")

        return output_file

    except Exception as e:
        print(f"❌ Error processing file: {e}")
        return None


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 clean_log_streaming.py <logfile.log> [output.log]")
        print("")
        print("Example:")
        print("  python3 clean_log_streaming.py Conversations/large_file.log")
        print("")
        print("Note: This script uses streaming processing for large files (>500MB)")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None

    clean_log_streaming(input_file, output_file)


if __name__ == '__main__':
    main()
