#!/usr/bin/env python3
"""
Batch process old log files - clean and compress

Scans for .log files, cleans them, and compresses originals.
"""

import os
import sys
import subprocess
from pathlib import Path

def find_log_files(base_paths):
    """Find all .log files that need processing"""
    folders = {}

    for base_path in base_paths:
        base = Path(base_path)
        if not base.exists():
            print(f"⚠️  Path not found: {base_path}")
            continue

        # Find all Conversations folders
        for conv_folder in base.rglob('Conversations'):
            if not conv_folder.is_dir():
                continue

            log_files = []
            for log_file in conv_folder.glob('*.log'):
                # Skip if already processed
                clean_file = log_file.parent / f"{log_file.stem}_clean.log"
                compressed = log_file.parent / f"{log_file.name}.xz"
                compressed_gz = log_file.parent / f"{log_file.name}.gz"

                if clean_file.exists() or compressed.exists() or compressed_gz.exists():
                    continue

                log_files.append(log_file)

            if log_files:
                folders[str(conv_folder)] = log_files

    return folders

def format_size(size_bytes):
    """Format bytes to human readable"""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if size_bytes < 1024.0:
            return f"{size_bytes:.1f}{unit}"
        size_bytes /= 1024.0
    return f"{size_bytes:.1f}TB"

def clean_and_compress(log_file, script_dir):
    """Clean and compress a single log file"""
    clean_file = log_file.parent / f"{log_file.stem}_clean.log"

    # Run clean_log.py
    result = subprocess.run(
        ['python3', str(script_dir / 'clean_log.py'), str(log_file), str(clean_file)],
        capture_output=True,
        text=True
    )

    if result.returncode != 0 or not clean_file.exists():
        return False, "Cleaning failed"

    # Compress original
    if subprocess.run(['which', 'xz'], capture_output=True).returncode == 0:
        result = subprocess.run(['xz', '-z', '-9', str(log_file)], capture_output=True)
        compressed_file = f"{log_file}.xz"
    else:
        result = subprocess.run(['gzip', '-9', str(log_file)], capture_output=True)
        compressed_file = f"{log_file}.gz"

    if result.returncode != 0:
        return False, "Compression failed"

    return True, compressed_file

def main():
    # Paths to scan
    base_paths = [
        '/Users/mohammadshehata/Desktop/FILICITI',
        '/Users/mohammadshehata/Desktop/DataStoragePlan'
    ]

    print("🔍 Scanning for log files...")
    print("")

    folders = find_log_files(base_paths)

    if not folders:
        print("✅ No log files need processing!")
        return

    # Show summary
    total_files = 0
    total_size = 0

    for folder, files in folders.items():
        folder_size = sum(f.stat().st_size for f in files)
        total_files += len(files)
        total_size += folder_size
        print(f"📁 {folder}")
        print(f"   Files: {len(files)}, Size: {format_size(folder_size)}")
        print("")

    print("─" * 60)
    print(f"📊 Total: {total_files} files, {format_size(total_size)}")
    print("─" * 60)
    print("")

    # Confirm
    response = input(f"Process all {total_files} files? [y/N]: ").strip().lower()
    if response != 'y':
        print("❌ Cancelled")
        return

    print("")
    print("🚀 Processing files...")
    print("")

    # Get script directory
    script_dir = Path(__file__).parent

    # Process with progress
    processed = 0
    failed = 0

    for folder, files in folders.items():
        for log_file in files:
            processed += 1

            # Progress bar
            percent = (processed / total_files) * 100
            bar_length = 40
            filled = int(bar_length * processed / total_files)
            bar = '█' * filled + '░' * (bar_length - filled)

            print(f"\r[{bar}] {percent:.1f}% ({processed}/{total_files})", end='', flush=True)

            # Process file
            success, msg = clean_and_compress(log_file, script_dir)
            if not success:
                failed += 1

    print("\n")
    print("─" * 60)
    print(f"✅ Processed: {processed - failed}/{total_files}")
    if failed > 0:
        print(f"❌ Failed: {failed}/{total_files}")
    print("─" * 60)

if __name__ == '__main__':
    main()
