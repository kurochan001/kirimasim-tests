#!/usr/bin/env python3
"""Build and run the small libfst reader used by FST tests.

The reader is tools/fst_read.c. It is compiled against a gtkwave/libfst
source tree, because FST is a tool format outside IEEE 1800-2023 and the
suite does not vendor libfst.

Usage:
    python3 tools/fst_reader.py FILE.fst [TIME ...]
        [--libfst-src DIR] [--exe PATH]

The libfst source directory is found from --libfst-src, then $LIBFST_SRC,
then a few development locations. A test that cannot find it should skip
rather than fail: the Check workflow does not require libfst.
"""

import argparse
import hashlib
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "tools" / "fst_read.c"
CANDIDATES = (
    Path.home() / "Projects" / "kirimasim" / "build" / "release" / "_deps" / "libfst-src",
    Path.home() / "Projects" / "kirimasim" / "build" / "dev" / "_deps" / "libfst-src",
    Path("/usr/local/share/libfst"),
    Path("/opt/homebrew/share/libfst"),
)


def find_source(explicit: str | None = None) -> Path | None:
    """The directory that holds libfst's src/fstapi.c, or None."""
    candidates = [explicit, os.environ.get("LIBFST_SRC"), *CANDIDATES]
    for candidate in candidates:
        if not candidate:
            continue
        path = Path(candidate).expanduser()
        if (path / "src" / "fstapi.c").is_file():
            return path
    return None


def _cache_key(source: Path) -> str:
    digest = hashlib.sha256()
    digest.update(SOURCE.read_bytes())
    for name in ("fstapi.c", "fstapi.h", "lz4.c", "lz4.h", "fastlz.c", "fastlz.h"):
        digest.update((source / "src" / name).read_bytes())
    return digest.hexdigest()[:16]


def build(libfst_src: str | Path, cache_dir: str | Path | None = None) -> Path:
    """Compile and return the fst_read executable."""
    source = Path(libfst_src).expanduser()
    if not (source / "src" / "fstapi.c").is_file():
        raise FileNotFoundError(f"not a libfst source tree: {source}")
    base = Path(cache_dir) if cache_dir else Path(tempfile.gettempdir()) / "kirimasim-tests-fst"
    out = base / f"fst_read-{_cache_key(source)}"
    if out.is_file():
        return out
    base.mkdir(parents=True, exist_ok=True)
    cc = os.environ.get("CC", "cc")
    command = [
        cc, "-O2", "-I", str(source / "src"), "-o", str(out),
        str(SOURCE),
        str(source / "src" / "fstapi.c"),
        str(source / "src" / "lz4.c"),
        str(source / "src" / "fastlz.c"),
        "-lz", "-lbz2",
    ]
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode != 0:
        out.unlink(missing_ok=True)
        detail = (result.stderr or result.stdout).strip().splitlines()
        raise RuntimeError("cannot build fst_read: " + (detail[-1] if detail else "unknown error"))
    return out


def read(path: str | Path, times: list[int] | None = None,
         libfst_src: str | Path | None = None,
         exe: str | Path | None = None) -> str:
    """Return the deterministic text view of an FST file."""
    if exe is None:
        source = find_source(str(libfst_src) if libfst_src else None)
        if source is None:
            raise FileNotFoundError(
                "libfst source not found; pass --libfst-src or set LIBFST_SRC")
        exe = build(source)
    command = [str(exe), str(path), *[str(t) for t in (times or [])]]
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode != 0:
        detail = (result.stderr or result.stdout).strip()
        raise RuntimeError(f"fst_read failed ({result.returncode}): {detail}")
    return result.stdout


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("file", type=Path)
    ap.add_argument("times", nargs="*", type=int)
    ap.add_argument("--libfst-src", type=Path)
    ap.add_argument("--exe", type=Path)
    args = ap.parse_args()
    try:
        sys.stdout.write(read(args.file, args.times, args.libfst_src, args.exe))
    except (FileNotFoundError, RuntimeError) as error:
        print(f"fst_reader: {error}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
