#!/usr/bin/env python3
"""Build the Icarus 13.0 vendor startup table with two application entries."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tarfile
import tempfile

import run_icarus
import suite_results


PROFILE = "icarus-vendor-startup"
CHECKER = "tools/run_icarus_vendor_startup.py"
CASE = "ch38/test_vpi_vendor_startup_table"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
SOURCE_SHA256 = "c897bbfa9848688982c6d5c30529fc29d68df0b9ff22ffa73bad89db73a7ce49"
TABLE_START = "void (*vlog_startup_routines[])(void) = {"
TABLE_END = "      vams_simparam_register,\n      0\n};"
PLATFORM_MODULE = re.compile(r'(?m)^:vpi_module "[^"\n]*/system\.vpi";$')
APPLICATION_ENTRIES = ("register_vendor_startup_first", "register_vendor_startup_second")
APPLICATION_TASKS = ("$vendor_startup_first", "$vendor_startup_second")


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def replace_once(text: str, old: str, new: str) -> str:
    if text.count(old) != 1:
        raise ValueError("a vendor source anchor did not match")
    return text.replace(old, new, 1)


def add_application_entries(text: str) -> str:
    first, second = APPLICATION_ENTRIES
    text = replace_once(text, TABLE_START, f"extern void {first}(void);\nextern void {second}(void);\n\n"
                        f"{TABLE_START}\n      {first},")
    return replace_once(text, TABLE_END, f"      vams_simparam_register,\n      {second},\n      0\n}};")


def run_stage(command: list[Path | str], cwd: Path, timeout: int, name: str) -> subprocess.CompletedProcess:
    result = run_icarus.execute(list(map(str, command)), timeout, cwd=str(cwd))
    if result.returncode != 0:
        detail = run_icarus.neutral(result.stderr.strip(), str(cwd)).splitlines()
        raise ValueError(f"{name} exited {result.returncode}" + (f" ({detail[-1]})" if detail else ""))
    return result


def build_modules(archive: Path, work: Path, fixture: Path, make: Path) -> dict[str, Path]:
    with tarfile.open(archive) as upstream:
        upstream.extractall(work, filter="data")
    vendor = work / "iverilog-13_0"
    modules = vendor / "vpi"
    run_stage(["sh", "autoconf.sh"], vendor, 120, "vendor autoconf")
    run_stage(["./configure"], vendor, 180, "vendor configure")
    build = [make, "-j2", "system.vpi"]
    run_stage(build, modules, 300, "stock VPI build")
    stock = work / "stock-system.vpi"
    shutil.copyfile(modules / "system.vpi", stock)

    table = modules / "sys_table.c"
    table.write_text(add_application_entries(table.read_text(encoding="utf-8")), encoding="utf-8")
    makefile = modules / "Makefile"
    makefile.write_text(replace_once(makefile.read_text(encoding="utf-8"), "O = sys_table.o",
                                     "O = vendor_application.o sys_table.o"), encoding="utf-8")
    application, _ = suite_results.header(fixture)["files"].split()
    shutil.copyfile(fixture.parent / application, modules / "vendor_application.c")
    # Force the table to be recompiled and linked even on coarse build clocks.
    (modules / "sys_table.o").unlink()
    (modules / "system.vpi").unlink()
    run_stage(build, modules, 300, "extended VPI build")
    return {"stock": stock, "extended": modules / "system.vpi"}


def use_module(design: Path, module: Path, output: Path) -> None:
    escaped = str(module).replace("\\", "\\\\").replace('"', '\\"')
    text = design.read_text(encoding="utf-8")
    if len(PLATFORM_MODULE.findall(text)) != 1:
        raise ValueError("Icarus did not emit one system.vpi module reference")
    output.write_text(PLATFORM_MODULE.sub(lambda _: f':vpi_module "{escaped}";', text), encoding="utf-8")


def observe(archive: Path, fixture: Path, tools: dict[str, Path], work: Path) -> dict:
    modules = build_modules(archive, work, fixture, tools["make"])
    test = work / fixture.name
    shutil.copyfile(fixture, test)
    design = work / "compiled.vvp"
    compile_design = [tools["iverilog"], "-g2012", "-s", fixture.stem, "-o", design]
    run_stage([*compile_design, test.name], work, 60, "stock control HDL build")
    stock_control = work / "stock-control.vvp"
    use_module(design, modules["stock"], stock_control)
    run_stage([*compile_design, "-DVENDOR_STARTUP_EXTENDED", test.name], work, 60, "witness HDL build")
    expected = suite_results.expected_output(fixture).splitlines()
    _, extended_oracle = suite_results.header(fixture)["files"].split()
    extended_expected = (fixture.parent / extended_oracle).read_text(encoding="utf-8").splitlines()
    results = {}
    for stage, module in (("stock_control", modules["stock"]), ("stock_witness", modules["stock"]),
                          ("extended_witness", modules["extended"])):
        variant = stock_control if stage == "stock_control" else work / f"{stage}.vvp"
        if stage != "stock_control":
            use_module(design, module, variant)
        run = run_icarus.execute([str(tools["vvp"]), variant.name], 60, cwd=str(work))
        unresolved = [name for name in APPLICATION_TASKS
                      if f"System task/function {name}() is not defined by any module." in run.stderr]
        output = [line for line in run.stdout.splitlines() if "Program not runnable" not in line]
        results[stage] = {"exit": run.returncode, "stdout": output, "unresolved_tasks": unresolved}
    correct = (results["stock_control"] == {"exit": 0, "stdout": expected, "unresolved_tasks": []}
               and results["stock_witness"]["exit"] > 0
               and results["stock_witness"]["stdout"] == []
               and results["stock_witness"]["unresolved_tasks"] == list(APPLICATION_TASKS)
               and results["extended_witness"] == {"exit": 0, "stdout": extended_expected, "unresolved_tasks": []})
    return {"pass": correct, "stages": results}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-archive", type=Path, required=True, help="the upstream v13_0 tag tarball")
    parser.add_argument("--iverilog-bin", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    make = shutil.which("make")
    bindir = args.iverilog_bin.resolve()
    tools = {name: bindir / name for name in ("iverilog", "vvp")}
    if make is None or not all(os.access(path, os.X_OK) for path in tools.values()):
        parser.error("Icarus Verilog and make are required")
    tools["make"] = Path(make).resolve()
    version = suite_results.tool_version([str(tools["iverilog"]), "-V"])
    if not re.search(r"version 13\.0(?:\s|$)", version):
        parser.error("the installed Icarus Verilog must match the upstream 13.0 source")
    archive = args.source_archive.resolve()
    if not archive.is_file() or digest(archive) != SOURCE_SHA256:
        parser.error("the source archive must be the upstream v13_0 codeload tarball")
    fingerprints = {name: digest(path) for name, path in tools.items()}
    checksum = checker_digest()
    runner = suite_results.runner_digest("icarus")
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    try:
        with tempfile.TemporaryDirectory() as directory:
            observation = observe(archive, fixture, tools, Path(directory))
    except (OSError, ValueError, subprocess.TimeoutExpired, tarfile.TarError) as error:
        parser.exit(2, f"{error}\n")
    if (fingerprints != {name: digest(path) for name, path in tools.items()} or checksum != checker_digest()
            or runner != suite_results.runner_digest("icarus") or inputs != suite_results.fingerprints([fixture])
            or digest(archive) != SOURCE_SHA256):
        parser.exit(2, "Tool, checker, or inputs changed during qualification.\n")
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checksum, "artifact_sha256": fingerprints,
                     "vendor_source_sha256": SOURCE_SHA256}
    status = ("pass", "") if observation["pass"] else ("fail", "vendor startup table observations differed")
    suite_results.write(args.json, "icarus", "Icarus Verilog", version, {CASE: status}, inputs=inputs,
                        configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({
        "version": version, "configuration": configuration, "runner_sha256": runner,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], **observation}},
    }, indent=2) + "\n", encoding="utf-8")
    print(observation)
    return int(not observation["pass"])


if __name__ == "__main__":
    raise SystemExit(main())
