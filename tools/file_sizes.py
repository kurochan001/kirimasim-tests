#!/usr/bin/env python3
# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Checks that no file tracked by git is too large.

Usage:
    python3 tools/file_sizes.py [--check] [--limit-mib N] [--top N]

GitHub warns about a file of more than 50 MiB and refuses a push of one of
more than 100 MiB. The large generated files are kept below that by
splitting them (coverage/behavior-history/, coverage/interaction-summary/,
coverage/test-matching/); this check fails when a tracked file exceeds the
limit (default 40 MiB), so that a file is split before GitHub objects.
Without --check it lists the largest files.
"""
import argparse
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LIMIT_MIB = 40


def tracked(root: Path = ROOT) -> list[tuple[int, str]]:
    names = subprocess.run(["git", "-C", str(root), "ls-files", "-z"], capture_output=True,
                           check=True).stdout.decode("utf-8").split("\0")
    sizes = []
    for name in names:
        path = root / name
        if name and path.is_file() and not path.is_symlink():
            sizes.append((path.stat().st_size, name))
    return sorted(sizes, reverse=True)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--limit-mib", type=float, default=LIMIT_MIB)
    ap.add_argument("--top", type=int, default=5)
    args = ap.parse_args()
    sizes = tracked()
    limit = int(args.limit_mib * (1 << 20))
    over = [(size, name) for size, name in sizes if size > limit]
    for size, name in (over if args.check else sizes[:args.top]):
        print(f"{size / (1 << 20):8.1f} MiB  {name}")
    if args.check:
        if over:
            print(f"file_sizes: {len(over)} tracked files exceed {args.limit_mib:g} MiB; split them",
                  file=sys.stderr)
            return 1
        largest = sizes[0] if sizes else (0, "")
        print(f"file_sizes: {len(sizes)} tracked files; the largest is {largest[1]} "
              f"({largest[0] / (1 << 20):.1f} MiB), below {args.limit_mib:g} MiB")
    return 0


if __name__ == "__main__":
    sys.exit(main())
