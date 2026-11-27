#!/usr/bin/env python3
"""Check two reference misc formats against four-state simulator values."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

import run_ghost
import run_icarus
import suite_results


CHECKER = "tools/run_vpi_misc_format_extensions.py"
PROFILE = "vpi-misc-formats-reference"
CASE = "ch38/test_vpi_misc_extension_formats"
CASES = {CASE: suite_results.ROOT / "tests" / f"{CASE}.sv"}
NATIVE_REQUEST = re.compile(
    r"(wide|narrow) native requested=([0-9a-f]+) returned=([0-9a-f]+) data=([01]) error=(\d+)"
)
REQUESTS = {"4b540101", "4b540102", "4b540103"}


def digest(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def checker_digest() -> str:
    return hashlib.sha256((digest(suite_results.ROOT / CHECKER)
                           + suite_results.runner_digest("ghost")
                           + suite_results.runner_digest("icarus")).encode()).hexdigest()


def compile_probe(compiler: Path, include: Path, probe: Path, library: Path, provider: Path | None) -> None:
    macro = "TEST_REFERENCE_FORMATS" if provider is not None else "TEST_NATIVE_FORMATS"
    sources = [probe] if provider is None else [probe, provider]
    linking = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
    build = subprocess.run([compiler, "-std=c11", "-Wall", "-Wextra", "-Werror", "-shared", "-fPIC",
                            *linking, "-I", include, f"-D{macro}=1", *sources, "-o", library],
                           cwd=library.parent, capture_output=True, text=True, timeout=60)
    if build.returncode:
        raise ValueError(f"the C compiler exited {build.returncode}: {build.stderr.strip()}")


def observe_ghost(ghost: Path, profile: dict, fixture: Path, library: Path, work: Path) -> dict:
    run = subprocess.run([ghost, *profile["arguments"], "--lib", library, fixture], cwd=work,
                         env={**os.environ, **profile["environment"]}, capture_output=True,
                         text=True, errors="replace", timeout=45)
    stderr = run.stderr.replace(str(work), "<work>")
    return {"exit": run.returncode, "output": run_ghost.normalize(run.stdout, profile).splitlines(),
            "diagnostics": run_ghost.normalize(stderr, profile).splitlines()}


def drifted_provider(helpers: Path, work: Path) -> Path:
    """Change the provider's bit-plane ID while leaving the consumer's header intact."""
    header = (helpers / "formats.h").read_text(encoding="utf-8")
    original = "testBitPlanes = testFormatNamespace + 1,"
    if header.count(original) != 1:
        raise ValueError("cannot isolate the bit-plane identifier for the control")
    (work / "formats.h").write_text(header.replace(original, "testBitPlanes = testFormatNamespace + 4,"),
                                    encoding="utf-8")
    provider = work / "provider.c"
    shutil.copyfile(helpers / "provider.c", provider)
    return provider


def variants(fixture: Path, work: Path) -> tuple[Path, dict]:
    helpers = fixture.parent / "vpi_misc_formats"
    return helpers / "probe.c", {"native": None, "reference": helpers / "provider.c",
                                  "drifted": drifted_provider(helpers, work)}


def ghost_runs(paths: dict, profile: dict, fixture: Path, work: Path) -> dict:
    probe, providers = variants(fixture, work)
    runs = {}
    for name, provider in providers.items():
        library = work / f"{name}.so"
        compile_probe(paths["cc"], paths["vpi_user.h"].parent, probe, library, provider)
        runs[name] = observe_ghost(paths["ghost"], profile, fixture, library, work)
    return runs


def icarus_runs(paths: dict, fixture: Path, work: Path) -> dict:
    probe, providers = variants(fixture, work)
    build = run_icarus.execute([str(paths["iverilog"]), "-g2012", "-s", fixture.stem, "-o", "test.vvp", str(fixture)],
                               run_icarus.COMPILE_TIMEOUT, cwd=str(work))
    if build.returncode:
        raise ValueError(f"Icarus HDL build exited {build.returncode}: {build.stderr.strip()}")
    runs = {}
    for name, provider in providers.items():
        macro = "TEST_NATIVE_FORMATS" if provider is None else "TEST_REFERENCE_FORMATS"
        sources = [probe] if provider is None else [probe, provider]
        build = run_icarus.execute([str(paths["iverilog-vpi"]), f"--name={name}", f"-D{macro}=1", *map(str, sources)],
                                   run_icarus.VPI_BUILD_TIMEOUT, cwd=str(work))
        if build.returncode:
            raise ValueError(f"Icarus VPI build exited {build.returncode}: {build.stderr.strip()}")
        run = run_icarus.execute([str(paths["vvp"]), "-M", str(work), f"-m{name}", "test.vvp"],
                                 run_icarus.RUN_TIMEOUT, cwd=str(work))
        runs[name] = {"exit": run.returncode, "output": run.stdout.splitlines(),
                      "diagnostics": run_icarus.neutral(run.stderr, str(work)).splitlines()}
    return runs


def qualify(runs: dict, fixture: Path, expect_native_requests: bool) -> dict:
    native, reference, drifted = runs["native"], runs["reference"], runs["drifted"]
    native_requests = []
    for line in native["output"]:
        match = NATIVE_REQUEST.fullmatch(line)
        if match is not None:
            native_requests.append({"object": match[1], "requested": match[2], "returned": match[3],
                                    "data_present": match[4] == "1", "error": int(match[5])})
    public_expected = suite_results.expected_output(fixture).splitlines()
    expected_file = fixture.parent / "vpi_misc_formats" / "reference.expected"
    reference_expected = expected_file.read_text(encoding="utf-8").splitlines()
    checks = {
        "standard_format_preserved_with_the_reference_provider": all(
            run["exit"] == 0 and [line for line in run["output"] if " standard " in line] == public_expected
            for run in (reference, drifted)),
        "registered_ids_select_their_expected_misc_payloads": reference["output"] == reference_expected,
        "unregistered_id_does_not_return_either_payload": [
            line for line in reference["output"] if " unknown " in line
        ] == ["wide unknown rejected=1", "narrow unknown rejected=1"],
        "changing_the_provider_identifier_loses_that_payload_only": drifted["exit"] == 0
        and drifted["output"] != reference_expected
        and drifted["output"] == [line for line in reference_expected if " id=4b540101 " not in line],
    }
    if expect_native_requests:
        wanted_requests = {(obj, request) for obj in ("wide", "narrow") for request in REQUESTS}
        checks["native_result_recorded_for_each_identifier"] = (
            native["exit"] == 0 and [line for line in native["output"] if " standard " in line] == public_expected
            and len(native_requests) == len(wanted_requests)
            and {(row["object"], row["requested"]) for row in native_requests} == wanted_requests)
    return {**runs, "native": {**native, "requests": native_requests}, "checks": checks, "pass": all(checks.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    host = parser.add_mutually_exclusive_group(required=True)
    host.add_argument("--ghost", help="Ghost executable")
    host.add_argument("--iverilog-bin", type=Path, help="directory with iverilog, iverilog-vpi and vvp")
    parser.add_argument("--include", type=Path, help="Ghost VPI headers")
    parser.add_argument("--profile", type=Path, help="Ghost runtime profile")
    parser.add_argument("--json", required=True, type=Path)
    args = parser.parse_args()
    profile = None
    if args.ghost is not None:
        ghost = shutil.which(args.ghost)
        compiler = shutil.which(os.environ.get("CC", "cc"))
        if ghost is None or compiler is None or args.include is None or args.profile is None:
            parser.error("Ghost requires a C compiler, --include and --profile")
        include = args.include.resolve()
        paths = {"ghost": Path(ghost).resolve(), "cc": Path(compiler).resolve(), "profile": args.profile,
                 "vpi_user.h": include / "vpi_user.h", "vpi_compatibility.h": include / "vpi_compatibility.h"}
        if not all(path.is_file() for path in paths.values()):
            parser.error("both VPI headers and the Ghost profile are required")
        profile = json.loads(args.profile.read_bytes())
        if "--lrm-strict" not in profile["arguments"]:
            parser.error("the Ghost profile must use --lrm-strict")
        version_options = {"ghost": "--version", "cc": "--version"}
    else:
        if args.include is not None or args.profile is not None:
            parser.error("--include and --profile apply to Ghost")
        paths = {name: args.iverilog_bin.absolute() / name for name in ("iverilog", "iverilog-vpi", "vvp")}
        if any(shutil.which(str(path)) is None for path in paths.values()):
            parser.error("all three Icarus executables are required")
        version_options = {"iverilog": "-V", "vvp": "-V"}
    artifacts = {name: digest(path) for name, path in paths.items()}
    fixture = CASES[CASE]
    inputs, checker = suite_results.input_digest(fixture), checker_digest()
    try:
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            runs = ghost_runs(paths, profile, fixture, work) if profile is not None else icarus_runs(paths, fixture, work)
            result = qualify(runs, fixture, expect_native_requests=profile is not None)
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"VPI misc qualification stopped: {error}\n")
    if (artifacts != {name: digest(path) for name, path in paths.items()}
            or checker != checker_digest() or inputs != suite_results.input_digest(fixture)):
        parser.exit(2, "Qualification inputs changed during the run.\n")
    args.json.write_text(json.dumps({
        "profile": PROFILE, "checker_sha256": checker, "artifact_sha256": artifacts,
        "versions": {name: suite_results.tool_version([paths[name], option]) for name, option in version_options.items()},
        "tests": {CASE: {"inputs_sha256": inputs, **result}},
    }, indent=2) + "\n", encoding="utf-8")
    for check, passed in result["checks"].items():
        print(f"{check}: {'PASS' if passed else 'FAIL'}")
    return int(not result["pass"])


if __name__ == "__main__":
    raise SystemExit(main())
