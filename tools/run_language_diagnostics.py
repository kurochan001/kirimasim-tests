#!/usr/bin/env python3
"""Check SystemVerilog diagnostics against a source-local control."""

import argparse
from dataclasses import dataclass
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import normalize_output
import run_ghost
import run_verilator
import suite_results


CHECKER = "tools/run_language_diagnostics.py"
PROFILES = {tool: f"{tool}-language-diagnostics"
            for tool in ("ghost", "icarus", "slang", "verilator")}
PORT = "ch23/test_net_ports_used_in_the_reverse_direction"
DPI = "ch35/test_legacy_dpi_import_compiler_diagnostic"
DIAGNOSTIC_REQUIREMENTS = {"SV2023-35.5.4-EXTRACT-DEPRECATED-DIAGNOSTIC"}
DIAGNOSTIC_ANCHOR = r"deprecat|obsolet|supersed"
C_MIGRATION = re.compile(
    r"(?=.*\b(?:may|might|could|possibly)\b)"
    r"(?=.*\bC\s+(?:source|code|application|implementation|program|library)\b)"
    r"(?=.*\b(?:chang|modif|adapt))", re.I
)
PORT_VALUES = re.compile(r"input outward=([01xz]) output inward=([01xz])")
GHOST_TRAILER = re.compile(r"^\[[^\]]+\] Simulation completed")


@dataclass(frozen=True)
class Advisory:
    stimulus: str
    control: str
    message: str


ADVISORIES = {
    "ch9/test_always_comb_incomplete_assignment_diagnostic": Advisory(
        "always_comb if (enable) retained = data;", "always_comb retained = data;",
        r"LATCH:|latch inferred|infer[^\n]*latch",
    ),
    "ch9/test_always_latch_unconditional_assignment_diagnostic": Advisory(
        "always_latch tracked = data;", "always_latch if (enable) tracked = data;",
        r"NOLATCH:|no latch|latch[^\n]*not (?:detected|inferred)",
    ),
    "ch9/test_always_ff_level_event_diagnostic": Advisory(
        "always_ff @* tracked = data;", "always_ff @(posedge clock) tracked <= data;",
        r"not sequential|requires[^\n]*edge sensitive|always_ff[^\n]*missing a pos/negedge",
    ),
}
CASES = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in (*ADVISORIES, PORT, DPI)}


def checker_digest() -> str:
    digest = hashlib.sha256()
    for name in (CHECKER, "tools/run_ghost.py", "tools/run_verilator.py", "tools/normalize_output.py"):
        digest.update(name.encode() + b"\0")
        digest.update(hashlib.sha256((suite_results.ROOT / name).read_bytes()).digest())
    return digest.hexdigest()


@dataclass(frozen=True)
class Compiler:
    tool: str
    executable: Path
    vvp: Path | None

    def run(self, command, directory):
        return subprocess.run(command, cwd=directory, capture_output=True, text=True,
                              errors="replace", timeout=120)

    def check(self, source, *, simulate=False, report_directions=False):
        command = [str(self.executable)]
        arguments = ["+report_directions"] if report_directions else []
        if self.tool == "ghost":
            command.extend(("--lrm-strict", "--quiet") if simulate else ("--lrm-strict", "--parse-only"))
        elif self.tool == "slang":
            command.append("--std=1800-2023")
        elif self.tool == "icarus":
            command.extend(("-g2012", "-Wall", "-o", "probe.vvp"))
        else:
            command.extend(("--binary" if simulate else "--lint-only", "--timing", "-Wno-fatal",
                            "--top-module", source.stem, "--Mdir", "obj", "-o", "probe"))
        command.append(source.name)
        if self.tool == "ghost":
            command.extend(arguments)
        build = self.run(command, source.parent)
        if not simulate or build.returncode or self.tool in ("slang", "ghost"):
            return build, build if simulate and self.tool == "ghost" else None
        runtime = ([str(self.vvp), "probe.vvp"] if self.tool == "icarus" else ["./obj/probe"])
        return build, self.run([*runtime, *arguments], source.parent)


def messages(result):
    return run_ghost.ANSI.sub("", result.stdout + "\n" + result.stderr).splitlines()


def at_line(result, filename, line):
    anchor = re.compile(rf"\b{re.escape(filename)}:{line}(?=[:\s])")
    return [message for message in messages(result) if anchor.search(message)]


def output_lines(result):
    if result is None or result.returncode != 0:
        return []
    lines = []
    for line in run_ghost.ANSI.sub("", result.stdout).splitlines():
        if GHOST_TRAILER.match(line):
            break
        if line.strip() and not run_verilator.BANNER.match(line) and not normalize_output.FINISH.match(line):
            lines.append(line)
    return lines


def paired_compile(compiler, test, stimulus, replacement):
    text = test.read_text(encoding="utf-8")
    if text.count(stimulus) != 1:
        raise ValueError(f"{test.name} must have one diagnostic statement")
    line = text.count("\n", 0, text.index(stimulus)) + 1
    with tempfile.TemporaryDirectory() as directory:
        source = Path(directory) / test.name
        source.write_text(text, encoding="utf-8")
        original, _ = compiler.check(source)
        source.write_text(text.replace(stimulus, replacement, 1), encoding="utf-8")
        control, _ = compiler.check(source)
    return original, control, line


def advisory_case(compiler, test, advisory):
    original, control, line = paired_compile(compiler, test, advisory.stimulus, advisory.control)

    def reported(result):
        return any(re.search(r"\bwarning\b", message, re.I) and re.search(advisory.message, message, re.I)
                   for message in at_line(result, test.name, line))

    warning = reported(original)
    control_warning = reported(control)
    observation = {"source_exit": original.returncode, "control_exit": control.returncode,
                   "source_warning": warning, "control_warning": control_warning}
    if original.returncode or control.returncode or control_warning:
        return "fail", "the advisory was not isolated by a successful source and control compilation", observation
    if not warning:
        return "unsupported", "recommended warning was not observed", observation
    if compiler.tool == "slang":
        return "pass", "", observation
    with tempfile.TemporaryDirectory() as directory:
        source = Path(directory) / test.name
        shutil.copyfile(test, source)
        _, runtime = compiler.check(source, simulate=True)
    matched = output_lines(runtime) == suite_results.expected_output(test).splitlines()
    observation["simulation_matched"] = matched
    return ("pass", "", observation) if matched else ("fail", "advisory simulation differed", observation)


def dpi_case(compiler, test):
    original, control, line = paired_compile(compiler, test, 'import "DPI"', 'import "DPI-C"')

    def migration_messages(result):
        return [message for message in at_line(result, test.name, line)
                if re.search(r"\b(?:warning|error)\b", message, re.I)
                and re.search(r"(?<!\w)DPI(?![-\w])", message) and "DPI-C" in message]

    candidates = migration_messages(original)
    deprecated = any(re.search(DIAGNOSTIC_ANCHOR, message, re.I) for message in candidates)
    complete = any(re.search(DIAGNOSTIC_ANCHOR, message, re.I) and C_MIGRATION.search(message)
                   for message in candidates)
    control_matched = bool(migration_messages(control))
    observation = {"legacy_exit": original.returncode, "current_exit": control.returncode,
                   "replacement_mentioned": bool(candidates), "deprecation_mentioned": deprecated,
                   "c_changes_mentioned": any(C_MIGRATION.search(message) for message in candidates),
                   "current_declaration_migration_diagnostic": control_matched}
    if original.returncode >= 0 and control.returncode == 0 and not control_matched and complete:
        return "pass", "", observation
    return "fail", "required legacy DPI migration information was incomplete or absent", observation


def port_warning(lines, port):
    return any(re.search(r"\bwarning\b", message, re.I)
               and re.search(rf"\b{port}\b", message)
               and re.search(r"direction|driv|coerc|\binout\b|\b(?:input|output) (?:net )?port\b",
                             message, re.I)
               for message in lines)


def port_case(compiler, test):
    with tempfile.TemporaryDirectory() as directory:
        source = Path(directory) / test.name
        shutil.copyfile(test, source)
        build, runtime = compiler.check(source, simulate=compiler.tool != "slang", report_directions=True)
    diagnostics = messages(build)
    if runtime is not None and runtime is not build:
        diagnostics.extend(messages(runtime))
    warnings = [port_warning(diagnostics, port) for port in ("input_backward", "output_backward")]
    observation = {"compile_or_run_exit": build.returncode, "input_warning": warnings[0],
                   "output_warning": warnings[1]}
    outputs = output_lines(runtime)
    match = PORT_VALUES.fullmatch(outputs[0]) if outputs else None
    if not match or outputs[1:] != suite_results.expected_output(test).splitlines():
        status = "unsupported" if compiler.tool == "slang" and build.returncode == 0 else "fail"
        return status, "port directions did not reach a checked simulation output", observation
    observation.update(input_outward=match[1], output_inward=match[2])
    if all(value == "1" or (value == "z" and warning)
           for value, warning in zip(match.groups(), warnings)):
        return "pass", "", observation
    return "fail", "a non-coerced port had no direction warning", observation


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tool", choices=PROFILES, required=True)
    parser.add_argument("--simulator", required=True)
    parser.add_argument("--vvp", help="Icarus runtime, defaults beside the compiler")
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    executable = shutil.which(args.simulator)
    if executable is None:
        parser.error("compiler is unavailable")
    executable = Path(executable).resolve()
    vvp = None
    binaries = {"compiler": executable}
    if args.tool == "icarus":
        runtime = shutil.which(args.vvp or str(executable.with_name("vvp")))
        if runtime is None:
            parser.error("Icarus runtime is unavailable")
        vvp = Path(runtime).resolve()
        binaries["runtime"] = vvp
    if args.tool == "verilator":
        backend = executable.with_name("verilator_bin")
        if backend.is_file():
            binaries["backend"] = backend.resolve()
    hashes = {name: hashlib.sha256(path.read_bytes()).hexdigest() for name, path in binaries.items()}
    checker_hash = checker_digest()
    runner_hash = None if args.tool == "slang" else suite_results.runner_digest(args.tool)
    inputs = suite_results.fingerprints(list(CASES.values()))
    compiler = Compiler(args.tool, executable, vvp)
    results, observations = {}, {}
    for case, test in CASES.items():
        try:
            if case in ADVISORIES:
                status, reason, observation = advisory_case(compiler, test, ADVISORIES[case])
            elif case == PORT:
                status, reason, observation = port_case(compiler, test)
            else:
                status, reason, observation = dpi_case(compiler, test)
        except (OSError, subprocess.TimeoutExpired):
            status, reason, observation = "fail", "compiler or runtime did not start or timed out", {}
        results[case] = status, reason
        observations[case] = {"inputs_sha256": inputs[case], "status": status, **observation}
        print(f"{status.upper()} {case}" + (f": {reason}" if reason else ""))
    if (hashes != {name: hashlib.sha256(path.read_bytes()).hexdigest() for name, path in binaries.items()}
            or checker_hash != checker_digest() or inputs != suite_results.fingerprints(list(CASES.values()))):
        parser.exit(2, "The compiler, checker or inputs changed during execution.\n")
    version_arg = "-V" if args.tool == "icarus" else "--version"
    version = (f"private build {hashes['compiler'][:12]}" if args.tool == "ghost"
               else suite_results.tool_version([str(executable), version_arg]))
    configuration = {"evidence_profile": PROFILES[args.tool], "checker_sha256": checker_hash,
                     "binary_sha256": hashes}
    suite_results.write(args.json, args.tool, "Ghost" if args.tool == "ghost" else args.tool,
                        version, results, inputs=inputs, runner_sha256=runner_hash,
                        configuration=configuration)
    args.observations.write_text(json.dumps({"tool": args.tool, "version": version, **configuration,
                                            "cases": observations}, indent=2) + "\n", encoding="utf-8")
    return int(any(status == "fail" for status, _ in results.values()))


if __name__ == "__main__":
    raise SystemExit(main())
