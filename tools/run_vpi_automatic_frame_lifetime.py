#!/usr/bin/env python3
"""Observe VPI lifecycle callbacks backed by real generated frame and thread storage."""

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


CHECKER = "tools/run_vpi_automatic_frame_lifetime.py"
PROFILE = "verilator-frame-lifetime-reference"
CASE = "ch37/test_vpi_automatic_frame_lifetime"
CASES = {CASE: suite_results.ROOT / "tests" / f"{CASE}.sv"}
MODEL = "Vframe_life"
SANITIZER = "-fsanitize=address"
SCOPE_DECLARATION = """\
#include <cstdint>
#include <memory>
class VlProcess;
std::shared_ptr<VlProcess> observed_child_process(const std::shared_ptr<VlProcess> &, unsigned);
void enter_frame(unsigned, const uint32_t *, const uint8_t *);
void leave_frame(unsigned);

struct ObservedFrameScope {
    unsigned branch;
    ObservedFrameScope(unsigned index, const uint32_t *stamp, const uint8_t *vector) : branch(index) {
        enter_frame(branch, stamp, vector);
    }
    ~ObservedFrameScope() { leave_frame(branch); }
};
"""


def digest(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def checker_digest() -> str:
    return hashlib.sha256((digest(suite_results.ROOT / CHECKER)
                           + suite_results.runner_digest("verilator")).encode()).hexdigest()


def instrument(directory: Path, top: str) -> dict:
    marker = re.compile(rf"^    {MODEL}___024root____Vdpiimwrap_{top}__DOT__observe_body_TOP"
                        r"\(branch, stamp, \(::IData\)\(vector\), 0U\);$", re.M)
    sources = [(file, file.read_text(encoding="utf-8")) for file in directory.glob(f"{MODEL}*root*.cpp")]
    matches = [(file, code) for file, code in sources if marker.search(code)]
    if len(matches) != 1:
        raise ValueError("expected one generated work coroutine with a body observation")
    file, code = matches[0]
    task = re.search(rf"^VlCoroutine {MODEL}___024root::__VnoInFunc_{top}__DOT__work_TOP\(.*?^}}",
                     code, re.M | re.S)
    if task is None or len(marker.findall(task[0])) != 1 or not all(
        re.search(field, task[0]) for field in (
            r"::IData/\*31:0\*/ stamp;", r"::CData/\*7:0\*/ vector;", r"stamp = ", r"vector = ", r"co_return;"
        )
    ):
        raise ValueError("work needs distinct coroutine storage for the observed automatic variables")
    original = marker.search(task[0])[0]
    code = marker.sub("    ObservedFrameScope witness_scope{branch, &stamp, &vector};\n" + original, code)
    factory = re.compile(rf"^(    {MODEL}\w*__Vfork_\d+__([01])\(vlSelf, )"
                         r"std::make_shared<VlProcess>\(vlProcess\)\);$", re.M)
    fork_calls = list(factory.finditer(code))
    if sorted(hit[2] for hit in fork_calls) != ["0", "1"]:
        raise ValueError("expected two generated fork process factories in the initial block")
    code = factory.sub(lambda hit: f"{hit[1]}observed_child_process(vlProcess, {hit[2]}U));", code)
    file.write_text(SCOPE_DECLARATION + code, encoding="utf-8")
    return {"source": file.name, "scope_before": original.strip(), "fork_factories": [s[0].strip() for s in fork_calls]}


def observe(verilator: Path, make: Path, fixture: Path, work: Path) -> dict:
    helpers = fixture.parent / "vpi_frame_lifetime"
    for file in (fixture, helpers / "driver.cpp"):
        shutil.copyfile(file, work / file.name)
    generated = work / "obj_dir"
    generation = run_verilator.execute([
        str(verilator), "--cc", "--exe", "--timing", "--no-sched-zero-delay", "-DREFERENCE_FRAME_LIFETIME",
        "--prefix", MODEL, "--top-module", fixture.stem, "-CFLAGS", SANITIZER, "-LDFLAGS", SANITIZER,
        fixture.name, "driver.cpp",
    ], 60, cwd=str(work))
    if generation.returncode != 0:
        raise ValueError(f"Verilator generation exited {generation.returncode}: {generation.stderr.strip()}")
    hooks = instrument(generated, fixture.stem)
    build = run_verilator.execute([str(make), "-j2", "-C", "obj_dir", "-f", f"{MODEL}.mk"], 120, cwd=str(work))
    if build.returncode != 0:
        raise ValueError(f"Verilator reference build exited {build.returncode}: {build.stderr.strip()}")
    run = subprocess.run([generated / MODEL], cwd=work, capture_output=True, text=True, errors="replace",
                         timeout=30, env={**os.environ, "ASAN_OPTIONS": "detect_leaks=0"})
    output = [line for line in run.stdout.splitlines() if not run_verilator.BANNER.match(line)]
    diagnostics = run.stderr.replace(str(work), "<work>").splitlines()
    expected = (helpers / "reference.expected").read_text(encoding="utf-8").splitlines()
    ordinary = suite_results.expected_output(fixture).splitlines()
    checks = {
        "native_frame_and_thread_storage_trace_matches": run.returncode == 0 and not diagnostics and output == expected,
        "reference_preserves_hdl_execution": [line for line in output if not line.startswith(("callback ", "registry "))]
        == ordinary,
        "automatic_locals_live_exactly_with_their_frame": all(line in output for line in (
            "registry phase=0 0/0/0 0/0/0 callbacks=0",
            "registry phase=6 1/1/3:53/37/0 1/0/0 callbacks=9",
            "registry phase=1 1/1/3:53/37/0 1/1/3:54/38/0 callbacks=12",
            "registry phase=2 1/0/0 1/1/3:54/38/0 callbacks=9",
            "registry phase=3 0/0/0 1/0/0 callbacks=3",
            "registry phase=5 0/0/0 0/0/0 callbacks=0",
        )),
    }
    return {"generated_hooks": hooks, "observation": {"exit": run.returncode, "output": output,
        "diagnostics": diagnostics}, "checks": checks, "pass": all(checks.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verilator", default="verilator")
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    executable, build_tool = shutil.which(args.verilator), shutil.which("make")
    if executable is None or build_tool is None:
        parser.error("Verilator and make are required")
    verilator, make = Path(executable).absolute(), Path(build_tool).absolute()
    runtime_root = run_verilator.execute([str(verilator), "--getenv", "VERILATOR_ROOT"], 30)
    if runtime_root.returncode or not runtime_root.stdout.strip():
        parser.error("could not locate the Verilator runtime")
    include = Path(runtime_root.stdout.strip()) / "include"
    artifacts = {"verilator": verilator, "make": make, "verilated.cpp": include / "verilated.cpp",
                 "verilated_types.h": include / "verilated_types.h", "verilated_timing.cpp": include / "verilated_timing.cpp",
                 "verilated_timing.h": include / "verilated_timing.h", "svdpi.h": include / "vltstd" / "svdpi.h",
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
        parser.exit(2, f"frame lifetime qualification stopped: {error}\n")
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
