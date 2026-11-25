#!/usr/bin/env python3
"""Use the same prebuilt DPI libraries in Ghost and Verilator."""

import argparse
import hashlib
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

import run_verilator
import suite_results


PROFILE = "dpi-shared-binary"
CHECKER = "tools/run_dpi_binary_compatibility.py"
CASES = {
    "ch35/test_dpi_portable_multiword_bit_and_scalar": "packed bit and scalar inout",
    "ch35/test_dpi_portable_logic_chunks_and_scalar_ports": "canonical logic and signed byte output",
    "ch35/test_dpi_unrelated_libraries_private_and_numeric_keys": "independent C and C++ context imports",
    "ch35/test_dpi_library_keys_isolate_two_instances_in_reverse_order": "same keys in separate scopes",
}


def sha256(path: Path) -> str:
    with path.open("rb") as source:
        return hashlib.file_digest(source, "sha256").hexdigest()


def checker_digest() -> str:
    digest = hashlib.sha256()
    for name in (CHECKER, "tools/run_verilator.py"):
        digest.update(name.encode() + b"\0")
        digest.update(bytes.fromhex(sha256(suite_results.ROOT / name)))
    return digest.hexdigest()


def simulation_result(command: list[str], cwd: Path, expected: str) -> str:
    try:
        result = subprocess.run(command, cwd=cwd, capture_output=True, text=True,
                                errors="replace", timeout=90)
    except subprocess.TimeoutExpired:
        return "timed_out"
    if result.returncode < 0:
        return "crashed"
    if result.returncode:
        return "nonzero_exit"
    # Both programs can add a tool trailer after the test's own output.
    return "pass" if result.stdout.startswith(expected) else "output_differs"


def build_libraries(fixture: Path, directory: Path, compiler: str, cxx: str, include: Path) -> tuple[str, list[Path]]:
    fields = suite_results.header(fixture)
    source = fixture.parent / fields["dpi_c"].removeprefix("@")
    cpp_sources = [fixture.parent / name for name in fields.get("files", "").split()
                   if Path(name).suffix == ".cpp"]
    shared_flags = ["-DDPI_BUILD_SEPARATE_LIBRARIES"] if cpp_sources else []
    if cpp_sources and sys.platform == "darwin":
        shared_flags.extend(["-undefined", "dynamic_lookup"])
    inputs = [(compiler, "c", source), *((cxx, "c++", path) for path in cpp_sources)]
    suffix = ".dylib" if sys.platform == "darwin" else ".so"
    libraries = []
    for index, (driver, language, path) in enumerate(inputs):
        library = directory / f"portable_{index}{suffix}"
        try:
            result = subprocess.run(
                [driver, "-shared", "-fPIC", "-x", language, *shared_flags, f"-I{include}",
                 "-o", str(library), str(path)],
                cwd=directory, capture_output=True, text=True, timeout=60,
            )
        except subprocess.TimeoutExpired:
            return "timed_out", []
        if result.returncode:
            return "build_failed", []
        libraries.append(library)
    return "pass", libraries


def run_case(fixture: Path, ghost: str, verilator: str, compiler: str, include: Path, cxx: str = "c++") -> dict:
    expected = suite_results.expected_output(fixture)
    if not expected:
        raise ValueError(f"missing expected output for {fixture.name}")
    checks = {"build_shared": "not_run", "ghost": "not_run", "verilator_build": "not_run",
              "verilator": "not_run", "same_binary": "not_run"}
    with tempfile.TemporaryDirectory() as temporary:
        directory = Path(temporary)
        checks["build_shared"], libraries = build_libraries(fixture, directory, compiler, cxx, include)
        if not libraries:
            return {"checks": checks}
        initial_hashes = {lib.name: sha256(lib) for lib in libraries}
        ghost_args = [item for lib in libraries for item in ("--lib", str(lib))]
        checks["ghost"] = simulation_result(
            [ghost, "--quiet", "--lrm-strict", *ghost_args, str(fixture)], directory, expected
        )
        after_ghost = {lib.name: sha256(lib) for lib in libraries}

        # Give Verilator the linked objects. The foreign application source is
        # absent from the build command and cannot be rebuilt for this model.
        link_args = [item for lib in libraries for item in ("-LDFLAGS", "../" + lib.name)]
        if len(libraries) > 1 and sys.platform == "linux":
            link_args.extend(["-LDFLAGS", "-Wl,--export-dynamic"])
        try:
            result = run_verilator.execute([
                verilator, "--binary", "--timing", "-Wno-fatal", "--top-module", fixture.stem,
                "--prefix", "Vportable", "--Mdir", "obj", *link_args, str(fixture),
            ], timeout=180, cwd=temporary)
        except subprocess.TimeoutExpired:
            checks["verilator_build"] = "timed_out"
        else:
            checks["verilator_build"] = "build_failed" if result.returncode else "pass"
        after_build = {lib.name: sha256(lib) for lib in libraries}
        if checks["verilator_build"] == "pass":
            # A relative library load name is resolved from the build directory.
            checks["verilator"] = simulation_result([str(directory / "obj/Vportable")], directory / "obj", expected)
        final_hashes = {lib.name: sha256(lib) for lib in libraries}
        checks["same_binary"] = (
            "pass" if initial_hashes == after_ghost == after_build == final_hashes else "library_changed"
        )
    return {"checks": checks, "library_sha256": initial_hashes}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--simulator", required=True, help="private Ghost executable")
    parser.add_argument("--verilator", default="verilator", help="Verilator executable")
    parser.add_argument("--include", required=True, type=Path, help="directory with svdpi.h for building the objects")
    parser.add_argument("--json", required=True, type=Path, help="write public results to this file")
    args = parser.parse_args()
    if sys.platform not in ("darwin", "linux"):
        parser.error("requires a Unix shared-library toolchain")
    ghost = shutil.which(args.simulator)
    verilator = shutil.which(args.verilator)
    compiler = shutil.which(os.environ.get("CC", "cc"))
    cxx = shutil.which(os.environ.get("CXX", "c++"))
    include = args.include.resolve()
    if not (ghost and verilator and compiler and cxx and (include / "svdpi.h").is_file()):
        parser.error("Ghost, Verilator, C and C++ compilers, and svdpi.h are required")
    ghost = os.path.abspath(ghost)
    verilator = os.path.abspath(verilator)
    compiler = os.path.abspath(compiler)
    cxx = os.path.abspath(cxx)
    launcher = Path(verilator).resolve()
    backend = shutil.which(os.environ.get("VERILATOR_BIN", str(launcher.with_name("verilator_bin"))))
    artifacts = {"ghost": Path(ghost), "verilator_launcher": launcher, "svdpi_header": include / "svdpi.h",
                 "compiler_c": Path(compiler), "compiler_cxx": Path(cxx)}
    if backend is not None:
        artifacts["verilator_backend"] = Path(backend)
    hashes = {name: sha256(path) for name, path in artifacts.items()}
    checker = checker_digest()
    runner = suite_results.runner_digest("ghost")
    fixtures = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in CASES}
    inputs = suite_results.fingerprints(list(fixtures.values()))
    observations = {}
    results = {}
    for case, fixture in fixtures.items():
        observations[case] = {"interface": CASES[case], **run_case(fixture, ghost, verilator, compiler, include, cxx)}
        checks = observations[case]["checks"]
        reasons = ", ".join(f"{name}={value}" for name, value in checks.items() if value != "pass")
        results[case] = ("fail", reasons) if reasons else ("pass", "")
        print(f"{results[case][0].upper()} {case}" + (f" {reasons}" if reasons else ""))
    if checker != checker_digest() or any(hashes[name] != sha256(p) for name, p in artifacts.items()):
        parser.exit(2, "A tool, the header or the checker changed during execution.\n")
    suite_results.write(
        args.json, "ghost", "Ghost", f"private build {hashes['ghost'][:12]}", results,
        inputs=inputs, runner_sha256=runner,
        configuration={"evidence_profile": PROFILE, "checker_sha256": checker, "sha256": hashes,
                       "verilator": suite_results.tool_version([verilator, "--version"]),
                       "compiler": suite_results.tool_version([compiler, "--version"]),
                       "compiler_cxx": suite_results.tool_version([cxx, "--version"]),
                       "platform": sys.platform, "cases": observations},
    )
    return int(any(status != "pass" for status, _ in results.values()))


if __name__ == "__main__":
    raise SystemExit(main())
