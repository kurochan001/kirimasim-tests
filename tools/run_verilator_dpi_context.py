#!/usr/bin/env python3
"""Check scope instrumentation in Verilator's generated DPI wrappers and call sites."""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import suite_results


PROFILE = "verilator-dpi-context-codegen"
CHECKER = "tools/run_verilator_dpi_context.py"
CASE = "ch35/test_dpi_context_and_noncontext_access_in_two_instances"
CASES = {CASE: ("h65_context", "h65_arguments")}
WRAPPER = re.compile(
    r"^void (?P<name>\w+__Vdpiimwrap\w+__(?P<callee>h65_context|h65_arguments)_TOP)"
    r"\((?P<parameters>[^;\n]*)\) \{\n(?P<body>.*?)^}", re.M | re.S
)
SCOPE = re.compile(r"\b__Vscopep_\w+__(left|right)\b")


def checker_digest() -> str:
    return hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes()).hexdigest()


def calls(generated: str, wrapper: re.Match) -> list[str]:
    return re.findall(r"^[ \t]*" + re.escape(wrapper["name"]) + r"\((.*?)\);\s*$", generated, re.M | re.S)


def inspect(generated: str) -> dict:
    checks = dict.fromkeys(("context_initialized_before_call", "ordinary_keeps_original_arguments",
                            "context_passes_instance_scopes", "ordinary_has_no_scope_argument"), False)
    matches = list(WRAPPER.finditer(generated))
    wrappers = {match["callee"]: match for match in matches}
    if len(matches) != len(wrappers) or wrappers.keys() != set(CASES[CASE]):
        return checks
    context = wrappers["h65_context"]
    ordinary = wrappers["h65_arguments"]
    instrument = context["body"].find("Verilated::dpiContext(__Vscopep, __Vfilenamep, __Vlineno)")
    context_call = context["body"].find("h65_context(")
    checks["context_initialized_before_call"] = (
        "VerilatedScope" in context["parameters"] and 0 <= instrument < context_call
    )
    checks["ordinary_keeps_original_arguments"] = (
        "VerilatedScope" not in ordinary["parameters"] and "dpiContext(" not in ordinary["body"]
        and "h65_arguments(item__Vcvt, &count__Vcvt)" in ordinary["body"]
    )
    scopes = [SCOPE.findall(arguments) for arguments in calls(generated, context)]
    checks["context_passes_instance_scopes"] = scopes == [["left"], ["right"], ["left"]]
    ordinary_calls = calls(generated, ordinary)
    checks["ordinary_has_no_scope_argument"] = len(ordinary_calls) == 3 and all(
        "__Vscopep" not in arguments for arguments in ordinary_calls
    )
    return checks


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verilator", default="verilator", help="Verilator executable")
    parser.add_argument("--json", required=True, type=Path, help="write qualification results")
    args = parser.parse_args()
    executable = shutil.which(args.verilator)
    if executable is None:
        parser.error("Verilator executable is unavailable")
    executable = str(Path(executable).resolve())
    backend = shutil.which(os.environ.get("VERILATOR_BIN", str(Path(executable).with_name("verilator_bin"))))
    tools = {"launcher": Path(executable)}
    if backend is not None:
        tools["compiler"] = Path(backend)
    hashes = {name: hashlib.sha256(path.read_bytes()).hexdigest() for name, path in tools.items()}
    checker = checker_digest()
    fixture = suite_results.ROOT / "tests" / (CASE + ".sv")
    fingerprint = suite_results.input_digest(fixture)
    with tempfile.TemporaryDirectory() as directory:
        result = subprocess.run(
            [executable, "--cc", "--timing", "-Wno-fatal", "--top-module", fixture.stem,
             "--prefix", "Vcontext", "--Mdir", directory, str(fixture)],
            capture_output=True, timeout=120,
        )
        generated = "\n".join(path.read_text() for path in sorted(Path(directory).glob("*.cpp")))
        checks = inspect(generated if result.returncode == 0 else "")
    if (checker != checker_digest() or fingerprint != suite_results.input_digest(fixture)
            or any(hashes[name] != hashlib.sha256(p.read_bytes()).hexdigest() for name, p in tools.items())):
        parser.exit(2, "Verilator, the fixture or the checker changed during execution.\n")
    artifact = {
        "profile": PROFILE, "version": suite_results.tool_version([executable, "--version"]),
        "binary_sha256": hashes, "checker_sha256": checker,
        "tests": {CASE: {"inputs_sha256": fingerprint, "generated": result.returncode == 0, "checks": checks}},
    }
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(json.dumps(artifact, indent=2) + "\n")
    print(f"{CASE}: {sum(checks.values())}/{len(checks)} instrumentation checks match")
    return int(not all(checks.values()))


if __name__ == "__main__":
    raise SystemExit(main())
