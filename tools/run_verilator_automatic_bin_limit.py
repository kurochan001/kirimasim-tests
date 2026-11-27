#!/usr/bin/env python3
"""Check Verilator's automatic-bin cap using its coverage records and diagnostics."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import run_verilator
import suite_results


CHECKER = "tools/run_verilator_automatic_bin_limit.py"
PROFILE = "verilator-automatic-bin-limit"
CASE = "ch19/test_cg_implementation_automatic_bin_limit"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
CAPS = (5, 9, 13, 20)
SEEDS = (1, 73)
REQUESTED = 13
POINTS = {"wide_point": (16, (0, 3, 15)), "narrow_point": (4, (0, 1, 3))}
COVER_RECORD = re.compile(r"^C '(.*)' (\d+)$")
POINT_BIN = re.compile(r"\.measurement\.(wide_point|narrow_point)\.auto_(\d+)$")
CAP_WARNING = re.compile(
    r"^%Warning-COVERIGN: .*?:(\d+):\d+: Unsupported: more than (\d+) automatic bins "
    r"from 'option.auto_bin_max'; using (\d+)\.$", re.M
)


def digest(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def expected_bins(cap: int) -> tuple[dict, list[str]]:
    counts, selected = {}, []
    for point, (domain, probes) in POINTS.items():
        effective = min(domain, REQUESTED, cap)
        stride = domain // effective
        # The last bin absorbs the remainder. The sweep visits each wide value
        # once and each narrow value four times.
        hits = dict.fromkeys(range(effective), 0)
        indices = {min(value // stride, effective - 1) for value in probes}
        selected.append(100 * len(indices) / effective)
        for value in (*probes, *(index % domain for index in range(16))):
            hits[min(value // stride, effective - 1)] += 1
        counts[point] = hits
    return counts, [f"selected wide={selected[0]:.6f} narrow={selected[1]:.6f}",
                    "sweep wide=100.000000 narrow=100.000000"]


def read_bins(path: Path) -> dict:
    counts = {name: {} for name in POINTS}
    for line in path.read_text(encoding="utf-8").splitlines():
        record = COVER_RECORD.fullmatch(line)
        if record is None:
            continue
        fields = dict(field.split("\x02", 1) for field in record[1].split("\x01") if "\x02" in field)
        if fields.get("t") != "covergroup":
            continue
        item = POINT_BIN.search(fields.get("h", ""))
        if item is None:
            raise ValueError("unexpected covergroup entry in the automatic-bin report")
        name, index = item[1], int(item[2])
        if index in counts[name] or fields.get("B") != f"auto_{index}":
            raise ValueError("duplicate or inconsistent automatic-bin record")
        counts[name][index] = int(record[2])
    return counts


def trial(exe: str, work: Path, source: Path, cap: int, wide_declaration: int) -> dict:
    directory = work / str(cap)
    directory.mkdir()
    build = run_verilator.execute([
        exe, "--binary", "--timing", "--coverage-user", "--coverage-max-bins", str(cap),
        "-Wno-fatal", "--top-module", source.stem, "--prefix", "Vlimit",
        "--Mdir", "obj", str(source),
    ], run_verilator.BUILD_TIMEOUT, cwd=str(directory))
    warnings = [list(map(int, match)) for match in CAP_WARNING.findall(build.stderr)]
    expected_warnings = [[wide_declaration, cap, cap]] if cap < REQUESTED else []
    counts, expected = expected_bins(cap)
    runs = []
    if build.returncode == 0:
        for seed in SEEDS:
            raw = directory / f"seed-{seed}.dat"
            execution = run_verilator.execute([
                str(directory / "obj" / "Vlimit"), "+verilator+rand+reset+2",
                f"+verilator+seed+{seed}", f"+verilator+coverage+file+{raw}",
            ], run_verilator.RUN_TIMEOUT, cwd=str(directory))
            stdout = [line for line in execution.stdout.splitlines() if not run_verilator.BANNER.match(line)]
            hits = read_bins(raw) if raw.is_file() else {}
            runs.append({"seed": seed, "exit": execution.returncode, "stdout": stdout, "hits": hits,
                         "coverage_sha256": digest(raw) if raw.is_file() else None,
                         "pass": execution.returncode == 0 and stdout == expected and hits == counts})
    return {"build_exit": build.returncode, "cap_warnings": warnings, "expected_warnings": expected_warnings,
            "bin_counts": {name: len(hits) for name, hits in counts.items()}, "runs": runs,
            "pass": len(runs) == len(SEEDS) and warnings == expected_warnings and all(run["pass"] for run in runs)}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verilator", default="verilator")
    parser.add_argument("--json", type=Path, required=True, help="suite execution result")
    parser.add_argument("--observations", type=Path, required=True, help="bin counters and warnings")
    args = parser.parse_args()
    exe = shutil.which(args.verilator)
    if exe is None:
        parser.error("Verilator executable is unavailable")
    launcher = Path(exe).absolute()
    tools = {"verilator": launcher}
    backend = Path(os.environ.get("VERILATOR_BIN", launcher.resolve().with_name("verilator_bin")))
    if backend.is_file():
        tools["verilator_backend"] = backend
    artifacts = {name: digest(path) for name, path in tools.items()}
    source = CASES[CASE]
    inputs = suite_results.fingerprints([source])
    checker, runner = checker_digest(), suite_results.runner_digest("verilator")
    version = suite_results.tool_version([str(launcher), "--version"])
    declaration, = [line for line, text in enumerate(source.read_text().splitlines(), 1)
                    if f"wide_point: coverpoint word {{ option.auto_bin_max = {REQUESTED}; }}" in text]
    if expected_bins(max(CAPS))[1] != suite_results.expected_output(source).splitlines():
        raise ValueError("the unrestricted run differs from the ordinary fixture expectation")
    try:
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            records = {cap: trial(str(launcher), work, source, cap, declaration) for cap in CAPS}
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"Automatic-bin qualification stopped: {error}\n")
    if (artifacts != {name: digest(path) for name, path in tools.items()} or checker != checker_digest()
            or inputs != suite_results.fingerprints([source]) or runner != suite_results.runner_digest("verilator")):
        parser.exit(2, "The qualification inputs changed during the run.\n")
    passed = all(row["pass"] for row in records.values())
    config = {"evidence_profile": PROFILE, "checker_sha256": checker, "artifact_sha256": artifacts,
              "caps": list(CAPS), "seeds": list(SEEDS)}
    verdict = ("pass", "") if passed else ("fail", "bin counts, hit counts, percentages, or cap warnings differed")
    suite_results.write(args.json, "verilator", "Verilator", version, {CASE: verdict},
                        inputs=inputs, runner_sha256=runner, configuration=config)
    args.observations.write_text(json.dumps({
        "version": version, "configuration": config,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], "trials": records, "pass": passed}},
    }, indent=2) + "\n", encoding="utf-8")
    for cap, row in records.items():
        print(f"cap={cap} {row['bin_counts']}: {'PASS' if row['pass'] else 'FAIL'}")
    return int(not passed)


if __name__ == "__main__":
    raise SystemExit(main())
