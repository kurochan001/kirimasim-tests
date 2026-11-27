#!/usr/bin/env python3
"""Observe VPI callback records at actual generated HDL object collection."""

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


CHECKER = "tools/run_vpi_class_reclaim.py"
PROFILE = "verilator-class-reclaim-reference"
CASE = "ch38/test_vpi_class_reclaim_lifetimes"
CASES = {CASE: suite_results.ROOT / "tests" / f"{CASE}.sv"}
MODEL = "Vreclaim"
SANITIZER = "-fsanitize=address"


def digest(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def checker_digest() -> str:
    return hashlib.sha256((digest(suite_results.ROOT / CHECKER)
                           + suite_results.runner_digest("verilator")).encode()).hexdigest()


def instrument(directory: Path) -> dict:
    hooks = {}
    for name in ("reclaim_record", "reclaim_peer"):
        header, = directory.glob(f"*{name}__Vclpkg.h")
        old = header.read_text(encoding="utf-8")
        pattern = re.compile(rf"^(    ~\w*{name}\(\)) \{{\}}$", re.M)
        original = pattern.findall(old)
        include = '#include "verilated.h"'
        if len(original) != 1 or old.count(include) != 1 or "__PVT__serial;" not in old:
            raise ValueError(f"could not locate generated {name} destructor and serial field")
        call = "observe_class_destruction(this, __PVT__serial);"
        with_hook = pattern.sub(lambda match: f"{match[1]} {{ {call} }}", old)
        declaration = "void observe_class_destruction(const VlClass *object, unsigned serial);"
        header.write_text(with_hook.replace(include, include + "\n" + declaration, 1), encoding="utf-8")
        hooks[name] = {"header": header.name, "before": original[0].strip() + " {}", "call": call}
    return hooks


def observe(verilator: Path, make: Path, fixture: Path, work: Path) -> dict:
    helpers = fixture.parent / "vpi_class_reclaim"
    for file in (fixture, helpers / "driver.cpp", helpers / "client.h"):
        shutil.copyfile(file, work / file.name)
    generation = run_verilator.execute([
        str(verilator), "--cc", "--exe", "--timing", "-DREFERENCE_RECLAIM", "-Wno-fatal", "--prefix", MODEL,
        "--top-module", fixture.stem, "-CFLAGS", SANITIZER, "-LDFLAGS", SANITIZER, fixture.name, "driver.cpp",
    ], 60, cwd=str(work))
    if generation.returncode != 0:
        raise ValueError(f"Verilator generation exited {generation.returncode}: {generation.stderr.strip()}")
    generated = work / "obj_dir"
    hooks = instrument(generated)
    build = run_verilator.execute([str(make), "-j2", "-C", "obj_dir", "-f", f"{MODEL}.mk"], 120, cwd=str(work))
    if build.returncode != 0:
        raise ValueError(f"Verilator reference build exited {build.returncode}: {build.stderr.strip()}")
    trials, checks = {}, {}
    for name, options in (("reference", []), ("held", ["--hold-first"])):
        run = subprocess.run([generated / MODEL, *options], cwd=work, capture_output=True, text=True,
                             errors="replace", timeout=30, env={**os.environ, "ASAN_OPTIONS": "detect_leaks=0"})
        output = [line for line in run.stdout.splitlines() if not run_verilator.BANNER.match(line)]
        diagnostics = run.stderr.replace(str(work), "<work>").splitlines()
        expected = (helpers / f"{name}.expected").read_text(encoding="utf-8").splitlines()
        checks[f"{name}_trace_matches"] = run.returncode == 0 and not diagnostics and output == expected
        trials[name] = {"exit": run.returncode, "output": output, "diagnostics": diagnostics}

    reference = trials["reference"]["output"]
    callbacks = [line.split()[1:3] for line in reference if line.startswith("callback ")]
    checks["typespec_and_direct_registration_select_different_instances"] = (
        callbacks == [["type", "serial=29"], ["object", "serial=29"], ["end", "serial=29"],
                      ["type", "serial=47"]]
        and "registrations create-type=1 reclaim-type=1 variable-rejected=1" in reference
        and "object registrations reclaim=1 end=1 create-rejected=1" in reference
        and "member registrations property=1 element=1" in reference)
    checks["callback_observes_valid_properties_before_release"] = (
        "callback object serial=29 no-time=1 class=1 dynamic=1 auto=1 clear=1 id64=1" in reference
        and "after serial=29 retired=10 remaining=0" in reference
        and "counts type=2 object=1 end=1 first-live=0 type-handle=1 type-callback=1" in reference)
    checks["surviving_strong_reference_prevents_reclaim"] = (
        "counts type=1 object=0 end=0 first-live=1 type-handle=1 type-callback=1" in trials["held"]["output"])
    return {"generated_destructor_hooks": hooks, "trials": trials, "checks": checks, "pass": all(checks.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verilator", default="verilator")
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    executable = shutil.which(args.verilator)
    make_path = shutil.which("make")
    if executable is None or make_path is None:
        parser.error("Verilator and make are required")
    verilator, make = Path(executable).absolute(), Path(make_path).absolute()
    root = run_verilator.execute([str(verilator), "--getenv", "VERILATOR_ROOT"], 30)
    if root.returncode or not root.stdout.strip():
        parser.error("could not locate the Verilator runtime")
    include = Path(root.stdout.strip()) / "include"
    artifacts = {"verilator": verilator, "make": make, "verilated.cpp": include / "verilated.cpp",
                 "verilated_types.h": include / "verilated_types.h",
                 "vpi_user.h": include / "vltstd" / "vpi_user.h",
                 "sv_vpi_user.h": include / "vltstd" / "sv_vpi_user.h"}
    backend = shutil.which(os.environ.get("VERILATOR_BIN", str(verilator.with_name("verilator_bin"))))
    if backend is not None:
        artifacts["verilator_bin"] = Path(backend)
    if not all(path.is_file() for path in artifacts.values()):
        parser.error("the Verilator runtime sources and VPI headers are required")
    hashes = {name: digest(path) for name, path in artifacts.items()}
    fixture = CASES[CASE]
    checker, inputs = checker_digest(), suite_results.input_digest(fixture)
    try:
        with tempfile.TemporaryDirectory() as directory:
            result = observe(verilator, make, fixture, Path(directory))
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"class reclaim qualification stopped: {error}\n")
    if (hashes != {name: digest(path) for name, path in artifacts.items()} or checker != checker_digest()
            or inputs != suite_results.input_digest(fixture)):
        parser.exit(2, "qualification inputs changed during the run\n")
    args.json.write_text(json.dumps({"profile": PROFILE, "checker_sha256": checker, "artifact_sha256": hashes,
                                     "verilator": suite_results.tool_version([str(verilator), "--version"]),
                                     "sanitizer": "address", "leak_detection": False,
                                     "tests": {CASE: {"inputs_sha256": inputs, **result}}}, indent=2) + "\n")
    for name, passed in result["checks"].items():
        print(f"{'PASS' if passed else 'FAIL'} {name}")
    return int(not result["pass"])


if __name__ == "__main__":
    raise SystemExit(main())
