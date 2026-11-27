#!/usr/bin/env python3
"""Observe collection of generated SystemVerilog objects through a weak-view adapter."""

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


CHECKER = "tools/run_weak_reference_collection.py"
PROFILE = "verilator-weak-collection-reference"
CASE = "ch8/test_weak_reference_reclamation"
CASES = {CASE: suite_results.ROOT / "tests" / f"{CASE}.sv"}
MODEL = "Vweak"
SANITIZER = "-fsanitize=address"


def digest(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def checker_digest() -> str:
    return hashlib.sha256((digest(suite_results.ROOT / CHECKER)
                           + suite_results.runner_digest("verilator")).encode()).hexdigest()


def instrument(directory: Path) -> dict:
    hooks = {}
    for class_name, field, hook in (("weak_gc_payload", "serial", "payload"), ("weak_gc_view", "slot", "view")):
        header, = directory.glob(f"*{class_name}__Vclpkg.h")
        text = header.read_text(encoding="utf-8")
        empty = re.compile(rf"^(    ~\w*{class_name}\(\)) \{{\}}$", re.M)
        function = f"weak_observe_{hook}_destruction"
        call = f"{function}(this, __PVT__{field});"
        matches = empty.findall(text)
        include = '#include "verilated.h"'
        if len(matches) != 1 or text.count(include) != 1 or f"__PVT__{field};" not in text:
            raise ValueError(f"could not isolate the generated {class_name} destructor and field")
        declaration = f"void {function}(const VlClass *object, unsigned value);"
        header.write_text(empty.sub(lambda match: f"{match[1]} {{ {call} }}", text).replace(
            include, include + "\n" + declaration, 1), encoding="utf-8")
        hooks[class_name] = {"header": header.name, "before": matches[0].strip() + " {}", "injected": call}
    return hooks


def observe(verilator: Path, make: Path, fixture: Path, work: Path) -> dict:
    helpers = fixture.parent / "weak_reclamation"
    shutil.copyfile(fixture, work / fixture.name)
    shutil.copyfile(helpers / "driver.cpp", work / "driver.cpp")
    build = run_verilator.execute([
        str(verilator), "--cc", "--exe", "--timing", "-DREFERENCE_WEAK", "-Wno-fatal", "--prefix", MODEL,
        "--top-module", fixture.stem, "-CFLAGS", SANITIZER, "-LDFLAGS", SANITIZER, fixture.name, "driver.cpp",
    ], 60, cwd=str(work))
    if build.returncode:
        raise ValueError(f"Verilator generation failed ({build.returncode}): {build.stderr.strip()}")
    generated = work / "obj_dir"
    hooks = instrument(generated)
    built = run_verilator.execute([str(make), "-j2", "-C", "obj_dir", "-f", f"{MODEL}.mk"], 120, cwd=str(work))
    if built.returncode:
        raise ValueError(f"Verilator reference build failed ({built.returncode}): {built.stderr.strip()}")
    trials, checks = {}, {}
    for case, command in (("reference", []), ("strong", ["--keep-strong"])):
        run = subprocess.run([generated / MODEL, *command], cwd=work, capture_output=True, text=True,
                             errors="replace", timeout=30, env={**os.environ, "ASAN_OPTIONS": "detect_leaks=0"})
        output = [line for line in run.stdout.splitlines() if not run_verilator.BANNER.match(line)]
        diagnostics = run.stderr.replace(str(work), "<work>").splitlines()
        expected = (helpers / f"{case}.expected").read_text(encoding="utf-8").splitlines()
        trials[case] = {"exit": run.returncode, "output": output, "diagnostics": diagnostics}
        checks[f"{case}_trace_matches"] = run.returncode == 0 and not diagnostics and output == expected
    ref, strong = trials["reference"]["output"], trials["strong"]["output"]
    checks["only_weak_views_survive_after_last_strong_reference"] = (
        "weakly reachable strong=0 left=29 right=29 peer=47" in ref
        and "strong control strong=1 left=29 right=29 peer=47" in strong)
    checks["both_views_clear_at_native_destruction"] = (
        "destroy target strong=0 cleared=2 peer-alive=1" in ref
        and "after collection left=-1 right=-1" in ref and "after collection left=29 right=29" in strong)
    checks["a_wrapper_is_collected_with_live_referent"] = all(
        "destroy wrapper strong=0 target-alive=1" in trial["output"] for trial in trials.values())
    checks["numeric_key_survives_collection_and_id_reuse"] = (
        "after strong drop key=17 peer=47 peer-key=41" in ref and "reused=1 old-views=-1,-1" in ref
        and "reused=0 old-views=29,29" in strong)
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
    backend = shutil.which(os.environ.get("VERILATOR_BIN", str(verilator.with_name("verilator_bin"))))
    root = run_verilator.execute([str(verilator), "--getenv", "VERILATOR_ROOT"], 30)
    if root.returncode or not root.stdout.strip():
        parser.error("could not locate the Verilator runtime")
    include = Path(root.stdout.strip()) / "include"
    artifacts = {"verilator": verilator, "make": make, "verilated_types.h": include / "verilated_types.h",
                 "verilated.cpp": include / "verilated.cpp"}
    if backend is not None:
        artifacts["verilator_bin"] = Path(backend)
    if not all(path.is_file() for path in artifacts.values()):
        parser.error("the Verilator runtime sources are required")
    hashes = {name: digest(path) for name, path in artifacts.items()}
    fixture = CASES[CASE]
    checker, inputs = checker_digest(), suite_results.input_digest(fixture)
    try:
        with tempfile.TemporaryDirectory() as directory:
            result = observe(verilator, make, fixture, Path(directory))
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"weak collection qualification stopped: {error}\n")
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
