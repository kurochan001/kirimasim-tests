#!/usr/bin/env python3
"""Records in generators/oracles.txt which releases produce the expected
output of each generated test, from the --json results of the runners.

Usage:
    python3 generators/record_oracles.py --icarus ICARUS.json
                                         [--verilator SEED1.json SEED7.json]

ICARUS.json comes from tools/run_icarus.py with Icarus Verilog 13.0, and the
Verilator files from tools/run_verilator.py with Verilator 5.052 and two
seeds. As for the other tests (README, "Where the expected outputs come
from"), a test that Icarus Verilog 13.0 matches gets iverilog@13.0; one that
it does not match gets verilator@5.052 when Verilator matches it with both
seeds and the test does not depend on x or z; any other is spec alone. Then
run python3 generators/generate.py to write the :oracle: fields.
"""

import argparse
import json
import sys
from pathlib import Path

import common


def passed(path: Path) -> set[str]:
    tests = json.loads(path.read_text())["tests"]
    return {t.rsplit("/", 1)[-1] for t, r in tests.items() if r["status"] == "pass"}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--icarus", type=Path, required=True)
    ap.add_argument("--verilator", type=Path, nargs=2, default=None)
    args = ap.parse_args()

    import generate
    icarus = passed(args.icarus)
    verilator = (passed(args.verilator[0]) & passed(args.verilator[1])
                 if args.verilator else set())
    oracles = common.read_oracles()
    for g in generate.GENERATORS:
        for case in g.cases():
            if case.name in icarus:
                oracles[case.name] = "spec iverilog@13.0"
            elif case.name in verilator and not case.fourstate:
                oracles[case.name] = "spec verilator@5.052"
            elif case.name in icarus | verilator or args.verilator or case.name not in oracles:
                oracles[case.name] = "spec"
    lines = ["# The releases that produce the expected output of each generated test,",
             "# written by generators/record_oracles.py; generate.py puts them in :oracle:."]
    lines += [f"{name} {oracle}" for name, oracle in sorted(oracles.items())]
    common.ORACLES.write_text("\n".join(lines) + "\n")
    print(f"{len(oracles)} tests recorded in {common.ORACLES.relative_to(common.ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
