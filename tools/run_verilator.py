#!/usr/bin/env python3
"""Runs the tests whose expected output was recorded with Verilator and
compares each test's normalized output with its expected output.

Usage:
    python3 tools/run_verilator.py [--verilator PATH] [TEST ...]

With no TEST arguments, runs every tests/**/*.sv whose `:oracle:` lists
verilator@5.052. These are tests that Icarus Verilog 13.0 cannot compile or
run; their expected outputs were recorded with Verilator 5.052 and checked
against the standard. Verilator is a two-state simulator, so these tests do
not depend on x or z values (`:fourstate: no`). Each test is built with
`verilator --binary --timing` and run with random initial values, so a test
that depended on uninitialized values would show up as a difference.
Exits with 1 if any test does not match.

A test with `:dpi_c: @<file>.c` or `:vpi_c: @<file>.c` has C code next to it,
which is built with the model (Verilator compiles it as C++); for `:vpi_c:` the
model is also built with --vpi and --public-flat-rw.
"""

import argparse
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
NORMALIZE = ROOT / "tools" / "normalize_output.py"
# Lines that Verilator itself prints, not the test: its banners and its run-time
# warnings, such as the one for a randomize() call whose constraints fail.
BANNER = re.compile(r"^(?:- (?:\S+:\d+: Verilog \$finish|S i m u l a t i o n|Verilator: )|%Warning-)")


def header_field(test: Path, name: str) -> str | None:
    header = re.search(r"/\*(.*?)\*/", test.read_text(encoding="utf-8"), re.DOTALL)
    if not header:
        return None
    m = re.search(rf"^:{name}:\s*(.*)$", header.group(1), re.MULTILINE)
    return m.group(1).strip() if m else None


def expected_output(test: Path) -> str | None:
    value = header_field(test, "expected_stdout")
    if value is None:
        return None
    if value.startswith("@"):
        return (test.parent / value[1:]).read_text(encoding="utf-8")
    return value + "\n"


def c_source(test: Path, name: str) -> Path | None:
    value = header_field(test, name)
    if value is None:
        return None
    return (test.parent / value.removeprefix("@")).resolve()


def run(test: Path, verilator: str, seed: int) -> tuple[bool, str]:
    extra = []
    dpi, vpi = c_source(test, "dpi_c"), c_source(test, "vpi_c")
    if dpi is not None:
        extra.append(str(dpi))
    if vpi is not None:
        extra += ["--vpi", "--public-flat-rw", str(vpi)]
    with tempfile.TemporaryDirectory() as tmp:
        obj = Path(tmp) / "obj"
        b = subprocess.run([verilator, "--binary", "--timing", "-Wno-fatal", "-Wno-lint",
                            "-Wno-style", "--x-assign", "unique", "--x-initial", "unique",
                            "-Mdir", str(obj), "--prefix", "Vt", str(test), *extra],
                           capture_output=True, text=True)
        if b.returncode != 0:
            err = [l for l in b.stderr.splitlines() if l.startswith("%Error")]
            return False, "build failed: " + (err[0] if err else "")
        r = subprocess.run([str(obj / "Vt"), "+verilator+rand+reset+2",
                            f"+verilator+seed+{seed}"], capture_output=True, text=True,
                           cwd=tmp, timeout=60)
    raw = "".join(l + "\n" for l in r.stdout.splitlines() if not BANNER.match(l))
    norm = subprocess.run([sys.executable, str(NORMALIZE)], input=raw,
                          capture_output=True, text=True).stdout
    want = expected_output(test)
    if want is None:
        return False, "no :expected_stdout:"
    return (norm == want), ("" if norm == want else "output differs")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--verilator", default="verilator", help="verilator executable")
    ap.add_argument("--seed", type=int, default=1, help="seed for random initial values")
    ap.add_argument("tests", nargs="*", type=Path)
    args = ap.parse_args()

    tests = args.tests or [t for t in sorted((ROOT / "tests").rglob("*.sv"))
                           if "verilator@5.052" in (header_field(t, "oracle") or "").split()]
    failed = 0
    for t in tests:
        ok, why = run(t, args.verilator, args.seed)
        if not ok:
            failed += 1
            name = t.relative_to(ROOT) if t.is_absolute() else t
            print(f"FAIL {name}: {why}")
    print(f"{len(tests) - failed}/{len(tests)} tests match")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
