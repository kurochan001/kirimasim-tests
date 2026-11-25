#!/usr/bin/env python3
"""Check DPI-C with and without the optional SV3.1a packed-data declarations."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import run_dpi_binary_compatibility as binary
import run_ghost
import run_verilator
import suite_results


CHECKER = "tools/run_dpi_optional_packed_compatibility.py"
CASE = "ch35/test_dpi_c_without_deprecated_packed_declarations"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
LEGACY = suite_results.ROOT / "tests/ch35/test_dpi_legacy_and_current_packed_values_use_each_declared_abi.sv"
PROFILES = {"feature": "dpi-sv31a-optional-runtime", "header": "dpi-sv31a-optional-header"}
LEGACY_MACRO = "-DDPI_REQUIRE_OBSOLETE_GET"
HEADER_START = "DEPRECATED PORTION OF FILE STARTS FROM HERE."
HEADER_END = "DEPRECATED PORTION OF FILE ENDS HERE."
COMMENTS = re.compile(r"/\*[\s\S]*?\*/")


def checker_digest() -> str:
    checksums = (binary.sha256(suite_results.ROOT / CHECKER), binary.checker_digest(),
                 suite_results.input_digest(LEGACY))
    return hashlib.sha256("\n".join(checksums).encode()).hexdigest()


def without_deprecated_portion(source: str) -> str:
    comments = list(COMMENTS.finditer(source))
    beginnings = [comment for comment in comments if HEADER_START in comment[0]]
    endings = [comment for comment in comments if HEADER_END in comment[0]]
    if len(beginnings) != 1 or len(endings) != 1 or beginnings[0].end() >= endings[0].start():
        raise ValueError("svdpi.h did not delimit one deprecated portion")
    begin, end = beginnings[0].start(), endings[0].end()
    if not all(name in source[begin:end] for name in ("SV_CANONICAL_SIZE", "svBitVec32", "svGetBitVec32")):
        raise ValueError("the delimited portion did not contain the legacy declarations")
    return source[:begin] + source[end:]


def header_check(c_compiler: str, cxx: str, source: Path, include: Path, work: Path) -> dict:
    checks = {}
    for name, driver, args in (("c", c_compiler, ["-x", "c", "-std=c11"]),
                               ("cxx", cxx, ["-x", "c++", "-std=c++17"])):
        command = [driver, *args, "-Werror", "-fsyntax-only", f"-I{include}", str(source)]
        modern = subprocess.run(command, cwd=work, capture_output=True, text=True, timeout=30)
        legacy = subprocess.run([*command, LEGACY_MACRO], cwd=work, capture_output=True, text=True, timeout=30)
        checks[name] = {"modern_exit": modern.returncode, "legacy_exit": legacy.returncode,
                        "missing_legacy_declaration": legacy.returncode > 0 and "error:" in legacy.stderr
                        and "svBitVec32" in legacy.stderr and "svGetBitVec32" in legacy.stderr}
    return checks


def packed_fault_controls(ghost: str, include: Path, profile: dict, directory: Path) -> dict:
    """Run compilable C changes that affect one transfer and leave the other visible."""
    directory.mkdir()
    test = directory / LEGACY.name
    application = test.with_suffix(".c")
    outcome = test.with_suffix(".expected")
    shutil.copyfile(LEGACY, test)
    source = LEGACY.with_suffix(".c").read_text(encoding="utf-8")
    expected = suite_results.expected_output(LEGACY)
    modern_end = "    fflush(stdout);\n}\n\nvoid legacy_transfer"
    controls = {
        "modern_high_bit": (modern_end, "x[2] ^= 1u;", "modern"),
        "modern_unknown_state": (modern_end, "y[0].aval ^= y[0].bval;", "modern"),
        "legacy_high_bit": ("    svPutBitVec32(x, bits, width);", "bits[2] ^= 1u;", "legacy"),
        "legacy_unknown_state": ("    svPutLogicVec32(y, state, width);", "state[0].c ^= state[0].d;", "legacy"),
    }
    observations = {}
    for name, (anchor, fault, side) in controls.items():
        verdicts = (f"{side} round trip=1", f"{side}=1")
        if source.count(anchor) != 1 or any(expected.count(line) != 1 for line in verdicts):
            raise ValueError(f"packed transfer control anchor changed for {name}")
        application.write_text(source.replace(anchor, f"    {fault}\n{anchor}"), encoding="utf-8")
        mutated_output = expected
        for line in verdicts:
            mutated_output = mutated_output.replace(line, line[:-1] + "0")
        outcome.write_text(mutated_output, encoding="utf-8")
        status, reason = run_ghost.run(test, ghost, include, profile)
        observations[name] = {"matches_isolated_fault": status == "pass", "reason": reason}
    return observations


def observe(artifacts: dict[str, Path], ghost_include: Path, profile: dict, work: Path) -> dict:
    paths = {name: str(path) for name, path in artifacts.items()}
    fixture = CASES[CASE]
    application = fixture.parent / suite_results.header(fixture)["dpi_c"].removeprefix("@")
    header = artifacts["verilator_header"]
    reduced = work / "reduced"
    reduced.mkdir()
    (reduced / "svdpi.h").write_text(without_deprecated_portion(header.read_text(encoding="utf-8")),
                                   encoding="utf-8")
    variants = {}
    for name, include in (("full", header.parent), ("reduced", reduced)):
        syntax = header_check(paths["cc"], paths["cxx"], application, include, work)
        runtime = binary.run_case(fixture, paths["ghost"], paths["verilator"], paths["cc"], include, paths["cxx"])
        variants[name] = {"compile": syntax, "runtime": runtime}

    ghost_status, ghost_reason = run_ghost.run(LEGACY, paths["ghost"], ghost_include, profile)
    parse = run_verilator.execute(
        [paths["verilator"], "--lint-only", "--top-module", LEGACY.stem, str(LEGACY)], timeout=60, cwd=str(work),
    )
    unsupported_dialect = parse.returncode > 0 and "Unsupported DPI type 'DPI'" in parse.stderr
    binding = run_verilator.execute([
        paths["verilator"], "--binary", "--timing", "--top-module", fixture.stem,
        "--Mdir", "legacy-link", "-CFLAGS", LEGACY_MACRO, str(fixture), str(application),
    ], timeout=180, cwd=str(work))
    linker = binding.stdout + "\n" + binding.stderr
    missing_symbol = (binding.returncode > 0 and "svGetBitVec32" in linker
                      and bool(re.search(r"undefined symbols|undefined reference|symbol\(s\) not found", linker, re.I)))
    controls = packed_fault_controls(paths["ghost"], ghost_include, profile, work / "packed-controls")
    legacy = {"inputs_sha256": suite_results.input_digest(LEGACY), "ghost": ghost_status,
              "fault_controls": controls,
              "ghost_reason": ghost_reason, "verilator_dialect_exit": parse.returncode,
              "verilator_rejects_legacy_dialect": unsupported_dialect, "verilator_link_exit": binding.returncode,
              "verilator_missing_legacy_symbol": missing_symbol}
    full_runtime = set(variants["full"]["runtime"]["checks"].values()) == {"pass"}
    reduced_runtime = set(variants["reduced"]["runtime"]["checks"].values()) == {"pass"}
    full_header = all(entry["modern_exit"] == entry["legacy_exit"] == 0
                      for entry in variants["full"]["compile"].values())
    reduced_header = all(entry["modern_exit"] == 0 and entry["missing_legacy_declaration"]
                         for entry in variants["reduced"]["compile"].values())
    return {"header_variants": variants, "legacy": legacy, "checks": {
        "feature": full_runtime and ghost_status == "pass" and unsupported_dialect,
        "header": full_header and reduced_header and full_runtime and reduced_runtime and missing_symbol,
        "fault_controls": all(control["matches_isolated_fault"] for control in controls.values()),
    }}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--ghost-include", required=True, type=Path)
    parser.add_argument("--ghost-profile", required=True, type=Path)
    parser.add_argument("--verilator", default="verilator")
    parser.add_argument("--feature-json", required=True, type=Path)
    parser.add_argument("--header-json", required=True, type=Path)
    parser.add_argument("--observations", required=True, type=Path)
    args = parser.parse_args()
    executables = {name: shutil.which(program) for name, program in {
        "ghost": args.ghost, "verilator": args.verilator, "cc": os.environ.get("CC", "cc"),
        "cxx": os.environ.get("CXX", "c++"),
    }.items()}
    if not all(executables.values()):
        parser.error("Ghost, Verilator, and C and C++ compilers are required")
    artifacts = {name: Path(path).absolute() for name, path in executables.items()}
    tool_root = subprocess.run([executables["verilator"], "--getenv", "VERILATOR_ROOT"],
                               capture_output=True, text=True, timeout=30)
    if tool_root.returncode or not tool_root.stdout.strip():
        parser.error("could not locate the native Verilator header")
    artifacts["verilator_header"] = Path(tool_root.stdout.strip()) / "include/vltstd/svdpi.h"
    launcher = artifacts["verilator"].resolve()
    backend = shutil.which(os.environ.get("VERILATOR_BIN", str(launcher.with_name("verilator_bin"))))
    if backend is not None:
        artifacts["verilator_backend"] = Path(backend)
    ghost_include = args.ghost_include.resolve()
    artifacts["ghost_header"] = ghost_include / "svdpi.h"
    if not all(path.is_file() for path in artifacts.values()):
        parser.error("Ghost and Verilator must provide the native DPI headers")
    profile_bytes = args.ghost_profile.read_bytes()
    profile = json.loads(profile_bytes)
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    hashes = {name: binary.sha256(path) for name, path in artifacts.items()}
    checksum = checker_digest()
    runner = suite_results.runner_digest("ghost")
    inputs = suite_results.fingerprints([CASES[CASE]])
    try:
        with tempfile.TemporaryDirectory() as directory:
            observation = observe(artifacts, ghost_include, profile, Path(directory))
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"{error}\n")
    if (hashes != {name: binary.sha256(path) for name, path in artifacts.items()} or checksum != checker_digest()
            or runner != suite_results.runner_digest("ghost") or profile_bytes != args.ghost_profile.read_bytes()
            or inputs != suite_results.fingerprints([CASES[CASE]])):
        parser.exit(2, "Tool, profile, or inputs changed during qualification.\n")
    configuration = {"checker_sha256": checksum, "artifact_sha256": hashes,
                     "profile_sha256": hashlib.sha256(profile_bytes).hexdigest(),
                     "verilator_version": suite_results.tool_version([executables["verilator"], "--version"])}
    version = f"private build {hashes['ghost'][:12]}"
    for kind, path in (("feature", args.feature_json), ("header", args.header_json)):
        verdict = ("pass", "") if observation["checks"][kind] else ("fail", f"DPI optional {kind} observations differed")
        suite_results.write(path, "ghost", "Ghost", version, {CASE: verdict}, inputs=inputs,
                            configuration={**configuration, "evidence_profile": PROFILES[kind]},
                            runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "version": version, "configuration": configuration, "runner_sha256": runner,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], **observation}},
    }, indent=2) + "\n", encoding="utf-8")
    print(observation)
    return int(not all(observation["checks"].values()))


if __name__ == "__main__":
    raise SystemExit(main())
