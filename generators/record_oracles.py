#!/usr/bin/env python3
"""Records in generators/oracles.txt which releases produce the expected
output of each generated test, from the --json results of the runners.

Usage:
    python3 generators/record_oracles.py [--icarus ICARUS.json]
                                         [--verilator SEED1.json SEED73.json]
                                         [--dry-run]

ICARUS.json comes from tools/run_icarus.py with Icarus Verilog 13.0, and the
two Verilator files from tools/run_verilator.py with one pinned release of
Verilator (5.052, or 5.054 while the pin moves) and two seeds. As for the
other tests (README, "Where the expected outputs come from"), a test that a
release reproduces gets that release's token next to spec, and a test that
both reproduce lists both. Verilator is a two-state simulator, so a test that
depends on x or z gets no Verilator token.

Only the tokens of the simulators given are changed, and only for the tests
that their results contain: a test that Icarus Verilog 13.0 now matches gets
iverilog@13.0 and one it ran without matching loses it; the same holds for
the Verilator release of the files given, which have to match with both
seeds. A test that already lists the other Verilator release is left as it is
and reported, since moving the pin decides that. A case whose generator says
that the match of a simulator is not evidence (Case.unregistered) never gets
that simulator's token. Comment lines and the order of the file are kept; new
tests are added at the end. Each file has to be a result of the simulator it
is given for, with the version of the pinned release, and its input digests
have to be those of the tests now. Then run python3 generators/generate.py to
write the :oracle: fields.
"""

import argparse
import json
import re
import sys
from pathlib import Path

import common

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import suite_results  # noqa: E402

# The release tokens and the version strings that identify them, as
# tools/behavior_coverage.py reads them.
RELEASES = {"icarus": (("iverilog@13.0", r"version 13\.0(?:\s|$)"),),
            "verilator": (("verilator@5.052", r"Verilator 5\.052(?:\s|$)"),
                          ("verilator@5.054", r"Verilator 5\.054(?:\s|$)"))}
PREFIX = {"icarus": "iverilog@", "verilator": "verilator@"}


class Refused(Exception):
    pass


def load(path: Path, simulator: str) -> tuple[str, dict[str, str]]:
    """The release token of a runner result and, per generated test name, its
    status; refuses a result of another simulator or release, or one whose
    inputs are not those of the tests now."""
    data = json.loads(path.read_text(encoding="utf-8"))
    if data.get("simulator") != simulator:
        raise Refused(f"{path}: a result of {data.get('simulator')!r}, not of {simulator}")
    version = str(data.get("version", ""))
    tokens = [t for t, pattern in RELEASES[simulator] if re.search(pattern, version)]
    if len(tokens) != 1:
        raise Refused(f"{path}: version {version!r} is not a pinned release of {simulator}")
    statuses = {}
    for test, record in data.get("tests", {}).items():
        if not test.startswith("gen/"):
            continue
        source = ROOT / "tests" / f"{test}.sv"
        recorded = record.get("inputs_sha256")
        if not source.is_file() or (recorded and recorded != suite_results.input_digest(source)):
            raise Refused(f"{path}: {test} changed after the run (or is gone); run it again")
        statuses[test.rsplit("/", 1)[-1]] = record["status"]
    return tokens[0], statuses


def updated(oracle: str, case, results: dict[str, tuple[str, set[str], set[str]]],
            notes: list[str]) -> str:
    """The new oracle of a case: results maps a simulator to its release token,
    the tests it ran and the tests it matched."""
    words = oracle.split()
    tokens = [w for w in words if w != "spec"]
    before = list(tokens)
    for sim, (token, ran, matched) in results.items():
        if case.name not in ran:
            continue
        others = [t for t in tokens if t.startswith(PREFIX[sim]) and t != token]
        reproduces = (case.name in matched and sim not in case.unregistered
                      and not (sim == "verilator" and case.fourstate))
        if others:
            if reproduces != (token in tokens):
                notes.append(f"{case.name}: lists {' '.join(others)}; {token} is not recorded")
            continue
        if reproduces and token not in tokens:
            tokens.append(token)
        elif not reproduces and token in tokens:
            tokens.remove(token)
    if tokens == before:
        return oracle
    return " ".join(["spec", *tokens])


def record(lines: list[str], cases: list, results: dict) -> tuple[list[str], list[str], int]:
    """The new lines of oracles.txt, the notes, and how many lines changed."""
    by_name = {c.name: c for c in cases}
    notes, changed, seen, out = [], 0, set(), []
    for line in lines:
        if not line.strip() or line.startswith("#"):
            out.append(line)
            continue
        name, oracle = line.split(None, 1)
        seen.add(name)
        case = by_name.get(name)
        new = updated(oracle, case, results, notes) if case else oracle
        changed += new != oracle
        out.append(f"{name} {new}")
    for name in sorted(set(by_name) - seen):
        new = updated("spec", by_name[name], results, notes)
        if new != "spec":
            out.append(f"{name} {new}")
            changed += 1
    return out, notes, changed


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--icarus", type=Path)
    ap.add_argument("--verilator", type=Path, nargs=2, default=None)
    ap.add_argument("--dry-run", action="store_true", help="report the changes, write nothing")
    args = ap.parse_args()
    if not args.icarus and not args.verilator:
        ap.error("give --icarus, --verilator or both")

    import generate
    try:
        results = {}
        if args.icarus:
            token, statuses = load(args.icarus, "icarus")
            results["icarus"] = (token, set(statuses), {t for t, s in statuses.items() if s == "pass"})
        if args.verilator:
            (token, first), (other, second) = (load(p, "verilator") for p in args.verilator)
            if token != other:
                raise Refused(f"the two Verilator files are of {token} and {other}")
            results["verilator"] = (token, set(first) & set(second),
                                    {t for t in first if first[t] == "pass" and second.get(t) == "pass"})
    except Refused as error:
        print(f"record_oracles: {error}", file=sys.stderr)
        return 1
    cases = [c for g in generate.GENERATORS for c in g.cases()]
    lines = common.ORACLES.read_text(encoding="utf-8").splitlines() if common.ORACLES.exists() else [
        "# The releases that produce the expected output of each generated test,",
        "# written by generators/record_oracles.py; generate.py puts them in :oracle:."]
    out, notes, changed = record(lines, cases, results)
    for note in notes:
        print(f"record_oracles: {note}", file=sys.stderr)
    if not args.dry_run:
        common.ORACLES.write_text("\n".join(out) + "\n", encoding="utf-8")
    print(f"{changed} lines {'would change' if args.dry_run else 'changed'} in "
          f"{common.ORACLES.relative_to(common.ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
