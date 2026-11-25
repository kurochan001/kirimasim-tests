#!/usr/bin/env python3
"""Observe how Ghost and Verilator convert packed storage at the DPI boundary."""

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

import run_verilator
import suite_results


PROFILE = "dpi-packed-storage"
CHECKER = "tools/run_dpi_packed_storage.py"
CASE = "ch35/test_dpi_packed_storage_conversion"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
FORMS = (
    ("bit record", "transfer_bit_record", "PackedStructValue", "svBitVecVal", "SVBV"),
    ("bit grid", "transfer_bit_grid", "LogicVectorValue", "svBitVecVal", "SVBV"),
    ("logic record", "transfer_logic_record", "PackedStructValue", "svLogicVecVal", "SVLV"),
    ("logic grid", "transfer_logic_grid", "LogicVectorValue", "svLogicVecVal", "SVLV"),
)
TRACE_SCRIPT = """\
def observe(frame, location, internal_dict):
    thread = frame.GetThread()
    for i in range(1, min(thread.GetNumFrames(), 12)):
        name = (thread.GetFrameAtIndex(i).GetFunctionName() or '').split('(')[0]
        if name.endswith(('::tryInvokeDpiImport', '::marshalToC_BitVector', '::marshalToC_LogicVector')):
            print('DPI_PACKED_TRACE ' + frame.GetFunctionName().split('(')[0] + ' ' + name, flush=True)
            break
    return False
"""
TRACE_LINE = re.compile(r"^DPI_PACKED_TRACE sukimasim::ir::(\w+)::toLogicVector (.*)$")
TARGET_EXIT = re.compile(r"^Process \d+ exited with status = (-?\d+)\b", re.M)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def ghost_trial(tools: dict[str, Path], fixture: Path, library: Path, profile: dict, work: Path) -> dict:
    debugger_script = work / "probe.py"
    debugger_script.write_text(TRACE_SCRIPT, encoding="utf-8")
    expected = suite_results.expected_output(fixture).splitlines()
    observations = {}
    for form, (name, _, value_type, canonical_type, conversion) in enumerate(FORMS):
        command = [str(tools["lldb"]), "--batch", "--no-lldbinit", "-o", "settings set target.disable-aslr false",
                   "-o", f"command script import {debugger_script}",
                   "-o", "breakpoint set --name sukimasim::ir::PackedStructValue::toLogicVector",
                   "-o", "breakpoint set --name sukimasim::ir::LogicVectorValue::toLogicVector",
                   "-o", "breakpoint command add -F probe.observe 1 2", "-o", "run", "--",
                   str(tools["ghost"]), *profile["arguments"]]
        oracle = expected[2 * form:2 * form + 2]
        if conversion == "SVLV":
            command.append("+define+DPI_PACKED_UNKNOWN")
            oracle[0] = f"{name} words=02f34560/00f0000f,2/3"
        command += ["--lib", str(library), str(fixture), f"+form={form}"]
        result = subprocess.run(command, cwd=work, env={**os.environ, **profile["environment"]},
                                capture_output=True, text=True, errors="replace", timeout=60)
        lines = result.stdout.splitlines()
        trace = sorted({(match[1], match[2]) for line in lines if (match := TRACE_LINE.fullmatch(line))})
        output = [line for line in lines if any(line.startswith(f"{label} ") for label, *_ in FORMS)]
        exits = [int(code) for code in TARGET_EXIT.findall(result.stdout)]
        matches = result.returncode == 0 and exits == [0] and output == oracle and any(
            observed == value_type for observed, _ in trace)
        observations[name] = {"pass": matches, "debugger_exit": result.returncode, "target_exits": exits,
                              "storage_trace": trace, "canonical_buffer": canonical_type, "stdout": output}
    return observations


def generated_wrappers(directory: Path) -> dict:
    source = "\n".join(path.read_text(encoding="utf-8") for path in sorted(directory.glob("Vt*.cpp")))
    observations = {}
    for name, symbol, _, canonical_type, conversion in FORMS:
        pattern = rf"^void \w*__Vdpiimwrap_\w*__DOT__{symbol}_TOP\(([^\n]+)\) \{{(.*?)^\}}"
        definitions = re.findall(pattern, source, re.M | re.S)
        if len(definitions) != 1:
            observations[name] = {"pass": False, "definitions": len(definitions)}
            continue
        signature, body = definitions[0]
        model_scalar = signature.count("QData/*33:0*/") == 2
        buffers = re.findall(rf"\b{canonical_type} (\w+)\[2\];", body)
        conversions = [f"VL_SET_{conversion}_Q(34,", f"VL_SET_Q_{conversion}(34,"]
        passes = (model_scalar and len(set(buffers)) == 2 and all(flag in body for flag in conversions)
                  and re.search(rf"\b{symbol}\({buffers[0]}, {buffers[1]}\);", body) is not None)
        observations[name] = {"pass": passes, "storage": "QData" if model_scalar else None,
                              "canonical_buffer": canonical_type, "two_word_buffers": buffers,
                              "conversion_calls": [flag.removesuffix("(34,") for flag in conversions if flag in body]}
    return observations


def verilator_trial(exe: Path, fixture: Path, source: Path, work: Path) -> dict:
    directory = work / "obj"
    built = run_verilator.execute([str(exe), "--binary", "--timing", "-Wno-fatal", "--prefix", "Vt",
                                   "--top-module", fixture.stem, "--Mdir", str(directory), str(fixture), str(source)],
                                  run_verilator.BUILD_TIMEOUT, cwd=str(work))
    if built.returncode != 0:
        return {"compile_exit": built.returncode, "wrappers": {}, "runs": []}
    oracle = suite_results.expected_output(fixture).splitlines()
    runs = []
    for seed in (1, 73):
        result = run_verilator.execute([str(directory / "Vt"), f"+verilator+seed+{seed}"],
                                       run_verilator.RUN_TIMEOUT, cwd=str(work))
        output = [line for line in result.stdout.splitlines() if not run_verilator.BANNER.match(line)]
        runs.append({"seed": seed, "exit": result.returncode, "stdout": output,
                     "pass": result.returncode == 0 and output == oracle})
    return {"compile_exit": 0, "wrappers": generated_wrappers(directory), "runs": runs}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--verilator", required=True)
    parser.add_argument("--include", type=Path, required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--lldb", default="lldb")
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    programs = {name: shutil.which(command) for name, command in (
        ("ghost", args.ghost), ("verilator", args.verilator), ("lldb", args.lldb), ("cc", os.environ.get("CC", "cc")),
    )}
    if not all(programs.values()):
        parser.error("Both simulators, LLDB and a C compiler are required")
    tools = {name: Path(executable).absolute() for name, executable in programs.items()}
    launcher = tools["verilator"].resolve()
    backend = Path(os.environ.get("VERILATOR_BIN", str(launcher.with_name("verilator_bin"))))
    if backend.is_file():
        tools["verilator_backend"] = backend.resolve()
    verilator_root = subprocess.check_output([str(tools["verilator"]), "--getenv", "VERILATOR_ROOT"],
                                             text=True, timeout=30).strip()
    tools["verilated_h"] = Path(verilator_root) / "include/verilated.h"
    include = args.include.resolve()
    tools.update(profile=args.profile, svdpi=include / "svdpi.h")
    if not all(path.is_file() for path in tools.values()):
        parser.error("DPI headers and simulator tools are required")
    hashes = {name: digest(path) for name, path in tools.items()}
    profile = json.loads(args.profile.read_text(encoding="utf-8"))
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    checker, runner = checker_digest(), suite_results.runner_digest("ghost")
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    source = fixture.with_suffix(".c")
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        library = work / "storage.so"
        flags = ("-undefined", "dynamic_lookup") if sys.platform == "darwin" else ()
        built = subprocess.run([str(tools["cc"]), "-shared", "-fPIC", *flags, f"-I{include}",
                                str(source), "-o", str(library)], cwd=work, capture_output=True, timeout=30)
        ghost = ghost_trial(tools, fixture, library, profile, work) if built.returncode == 0 else {}
        verilator = verilator_trial(tools["verilator"], fixture, source, work)
    model_type = re.search(r"^using QData\s*=\s*(\w+)\s*;", tools["verilated_h"].read_text(encoding="utf-8"), re.M)
    verilator["qdata_scalar_type"] = model_type[1] if model_type else None
    if (hashes != {name: digest(path) for name, path in tools.items()} or checker != checker_digest()
            or runner != suite_results.runner_digest("ghost") or inputs != suite_results.fingerprints([fixture])):
        parser.exit(2, "Tools, checker, profile or fixture changed during qualification.\n")
    passed = (bool(ghost) and all(variant["pass"] for variant in ghost.values())
              and verilator["qdata_scalar_type"] == "uint64_t" and bool(verilator["runs"])
              and all(trial["pass"] for trial in [*verilator["wrappers"].values(), *verilator["runs"]]))
    version = f"private build {hashes['ghost'][:12]}"
    configuration = {"evidence_profile": PROFILE, "checker_sha256": checker, "artifact_sha256": hashes,
                     "verilator_version": suite_results.tool_version([str(tools["verilator"]), "--version"]),
                     "lldb_version": suite_results.tool_version([str(tools["lldb"]), "--version"])}
    verdict = ("pass", "") if passed else ("fail", "packed storage conversion evidence differed")
    suite_results.write(args.json, "ghost", "Ghost", version, {CASE: verdict}, inputs=inputs,
                        configuration=configuration, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({"version": version, "configuration": configuration,
        "runner_sha256": runner, "tests": {CASE: {"inputs_sha256": inputs[CASE], "ghost_build_exit": built.returncode,
                                                   "ghost": ghost, "verilator": verilator}}}, indent=2) + "\n",
        encoding="utf-8")
    for name, *_ in FORMS:
        print(name, ghost.get(name, {}).get("pass"), verilator["wrappers"].get(name, {}).get("pass"))
    return int(not passed)


if __name__ == "__main__":
    raise SystemExit(main())
