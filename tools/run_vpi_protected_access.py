#!/usr/bin/env python3
"""Qualify VPI access with two independently recovered source layouts."""

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
import run_protect_block_boundaries as boundaries
import run_protect_encryption as encryptor
import suite_results


CHECKER = "tools/run_vpi_protected_access.py"
PROFILE = "vpi-protected-access-reference"
CASE = "ch38/test_vpi_protected_access_controls"
CASES = {CASE: suite_results.ROOT / "tests" / f"{CASE}.sv"}
DIAGNOSTIC_ANCHOR = "reference_matches_allowed_and_denied_operations"
DIAGNOSTIC_REQUIREMENTS = {
    "SV2023-37.3.6-EXTRACT-PROTECTED-ACCESS",
    "SV2023-38.6-EXTRACT-GET-PROTECTED-ERROR",
    "SV2023-38.7-EXTRACT-GET64-PROTECTED-ERROR",
    "SV2023-38.11-EXTRACT-STRING-PROTECTED",
    "SV2023-38.18-EXTRACT-HANDLE-PROTECTED",
    "SV2023-38.19-EXTRACT-INDEX-PROTECTED",
    "SV2023-38.20-EXTRACT-MULTI-INDEX-PROTECTED",
    "SV2023-38.21-EXTRACT-NAME-PROTECTION",
    "SV2023-38.23-EXTRACT-ITERATOR-PROTECTED",
}
TASK = "$vt_protection_arguments"
FUNCTION = "$vt_protection_function"
PRAGMA_LINES = re.compile(rb"^`pragma protect (?:begin|end)\r?\n", re.M)


def digest(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def checker_digest() -> str:
    return hashlib.sha256((digest(suite_results.ROOT / CHECKER) + boundaries.checker_digest()
                           + suite_results.runner_digest("ghost")).encode()).hexdigest()


def alternate_layout(source: bytes) -> bytes:
    plain = PRAGMA_LINES.sub(b"", source)
    for label in (b"left leaf", b"left objects"):
        first = re.compile(rb"^[ \t]*// " + label + rb" begin\n", re.M)
        last = re.compile(rb"^[ \t]*// " + label + rb" end\n", re.M)
        plain, openings = first.subn(lambda match: match[0] + b"`pragma protect begin\n", plain)
        plain, closings = last.subn(lambda match: b"`pragma protect end\n" + match[0], plain)
        if (openings, closings) != (1, 1):
            raise ValueError(f"missing layout marker for {label.decode()}")
    return plain


def recover(paths: dict, source: bytes, work: Path) -> tuple[bytes, list]:
    staged = work / "input.sv"
    staged.write_bytes(source)
    openssl = str(paths["openssl"])
    private, public = encryptor.exchange_key(openssl, work, "fixture")
    wire = encryptor.encrypt(str(paths["python"]), staged, public, work / "encrypted.sv",
                             (b"Qualification", b"vpi"))
    _, bodies = boundaries.recovered_ranges(openssl, private, wire)
    layout = encryptor.split(source, encryptor.SOURCE_BEGIN, encryptor.SOURCE_END)
    if len(bodies) != 2 or [body.strip() for body in bodies] != [body.strip() for body in layout.bodies]:
        raise ValueError("the recovered plaintext differs inside an envelope")

    chunks, cursor = [], 0
    for opening, closing, body, original in zip(encryptor.SOURCE_BEGIN.finditer(source),
                                                encryptor.SOURCE_END.finditer(source), bodies,
                                                layout.bodies, strict=True):
        # Restore framing whitespace trimmed by the encryptor so source lines stay aligned.
        first = len(original) - len(original.lstrip())
        last = len(original.rstrip())
        chunks.extend((source[cursor:opening.end()], original[:first], body.strip(), original[last:]))
        cursor = closing.start()
    restored = b"".join((*chunks, source[cursor:]))
    if restored != source:
        raise ValueError("recovered design does not match original source")
    ranges = [(restored.count(b"\n", 0, begin.start()) + 1, restored.count(b"\n", 0, end.start()) + 1)
              for begin, end in zip(encryptor.SOURCE_BEGIN.finditer(restored),
                                    encryptor.SOURCE_END.finditer(restored), strict=True)]
    return restored, ranges


def observe(command: list, work: Path, env: dict | None = None) -> subprocess.CompletedProcess:
    return subprocess.run(command, cwd=work, env=env, capture_output=True, text=True, errors="replace", timeout=60)


def build_probe(paths: dict, source: Path, work: Path, reference: bool) -> Path:
    library = work / ("reference.so" if reference else "native.so")
    helpers = source.parent / "vpi_protected_access"
    flags = ["-DREFERENCE_ACCESS", str(helpers / "adapter.c")] if reference else []
    linking = ["-undefined", "dynamic_lookup"] if sys.platform == "darwin" else []
    build = observe([paths["cc"], "-std=c11", "-Wall", "-Wextra", "-Werror", "-shared", "-fPIC", *linking,
                     "-I", paths["vpi_user.h"].parent, "-I", work, *flags, helpers / "probe.c", "-o", library], work)
    if build.returncode != 0:
        raise ValueError(f"probe compilation exited {build.returncode}: {build.stderr.strip()}")
    return library


def documents(node):
    if isinstance(node, dict):
        yield node
        for value in node.values():
            yield from documents(value)
    elif isinstance(node, list):
        for value in node:
            yield from documents(value)


def source_origins(slang: Path, source: Path, top: str, ranges: list, work: Path) -> dict:
    built = observe([slang, "--std=1800-2023", "--define-system-task", TASK,
                     "--define-system-task", f"function int {FUNCTION}(logic [6:0] a, bit [3:0] b)", "--top", top,
                     "--ast-json", "design.json", "--ast-json-source-info", source], work)
    if built.returncode != 0:
        raise ValueError(f"Slang elaboration exited {built.returncode}: {built.stderr.strip()}")
    design = json.loads((work / "design.json").read_text(encoding="utf-8"))["design"]
    root, = (item for item in design["members"] if item["kind"] == "Instance" and item["name"] == top)
    members = {node["name"]: node for node in root["body"]["members"]}

    def origin(node: dict, prefix: str = "source_line") -> dict:
        file_key = prefix.replace("line", "file")
        if Path(work / node[file_key]).resolve() != source.resolve():
            raise ValueError("unexpected source file in the fixture hierarchy")
        line = node[prefix]
        envelope = next((i for i, (first, last) in enumerate(ranges) if first < line < last), None)
        return {"line": line, "envelope": envelope}

    origins = {"top": origin(root)}
    for side in ("left", "right"):
        for suffix in ("grid", "object", "scope"):
            name = f"{side}_{suffix}"
            origins[name] = origin(members[name])
        body = members[f"{side}_scope"]["body"]
        origins[f"{side}_definition"] = origin(body)
        for role, subroutine in (("task", TASK), ("function", FUNCTION)):
            call, = (item for item in documents(body)
                     if item.get("kind") == "Call" and item["subroutine"] == subroutine)
            origins[f"{side}_{role}"] = origin(call, "source_line_start")
            for index, arg in enumerate(call["arguments"], 1):
                origins[f"{side}_{role}_arg{index}"] = {**origin(arg, "source_line_start"), "type": arg["type"]}
    return origins


def simulate(ghost: Path, profile: dict, source: Path, library: Path, top: str, work: Path) -> dict:
    result = observe([ghost, *profile["arguments"], "--top", top, "--lib", library, source], work,
                     {**os.environ, **profile["environment"]})
    error = result.stderr.replace(str(work), "<work>")
    diagnostics = [line for line in run_ghost.normalize(error, profile).splitlines()
                   if not line.startswith("[UVM_NATIVE_DISPATCH]")]
    return {"exit": result.returncode, "output": run_ghost.normalize(result.stdout, profile).splitlines(),
            "diagnostics": diagnostics}


def qualify(paths: dict, profile: dict, fixture: Path, work: Path) -> dict:
    top = suite_results.top_module(fixture) or fixture.stem
    original = fixture.read_bytes()
    layouts = {"right": original, "left": alternate_layout(original)}
    native_lib = build_probe(paths, fixture, work, reference=False)
    public = suite_results.expected_output(fixture).splitlines()
    helpers = fixture.parent / "vpi_protected_access"
    trials, checks = {}, {}
    for side, source in layouts.items():
        directory = work / side
        directory.mkdir()
        restored, ranges = recover(paths, source, directory)
        source_path = directory / "restored.sv"
        source_path.write_bytes(restored)
        origins = source_origins(paths["slang"], source_path, top, ranges, directory)
        expected = (helpers / f"{side}.expected").read_text(encoding="utf-8").splitlines()
        mem = ", ".join(f"{{{first}, {last}}}" for first, last in ranges)
        (directory / "envelope_ranges.h").write_text(f"static const int envelope_ranges[][2] = {{{mem}}};\n")
        adapter_lib = build_probe(paths, fixture, directory, reference=True)
        native = simulate(paths["ghost"], profile, source_path, native_lib, top, directory)
        reference = simulate(paths["ghost"], profile, source_path, adapter_lib, top, directory)
        encrypted = simulate(paths["ghost"], profile, directory / "encrypted.sv", native_lib, top, directory)
        trials[side] = {"ranges": ranges, "origins": origins, "native_restored": native,
                        "native_encrypted": encrypted, "reference": reference}
        checks[f"{side}_origins_match_recovered_envelopes"] = (
            origins["top"]["envelope"] is None
            and all((item["envelope"] is not None) == name.startswith(side + "_")
                    for name, item in origins.items() if name != "top")
            and all(origins[f"{branch}_{role}_arg{index}"]["type"] == kind
                    for branch in layouts for role in ("task", "function")
                    for index, kind in ((1, "logic[6:0]"), (2, "bit[3:0]"))))
        checks[f"{side}_{DIAGNOSTIC_ANCHOR}"] = (
            reference["exit"] == 0 and reference["output"] == expected and not reference["diagnostics"])
        checks[f"{side}_native_restored_observation_matches_public_control"] = (
            native["exit"] == 0 and native["output"] == public and not native["diagnostics"])
        checks[f"{side}_native_encrypted_result_recorded"] = encrypted["exit"] >= 0
    checks["layout_swap_preserves_design_and_swaps_access"] = (
        PRAGMA_LINES.sub(b"", layouts["right"]) == PRAGMA_LINES.sub(b"", layouts["left"])
        and trials["right"]["reference"]["output"] != trials["left"]["reference"]["output"])
    return {"layouts": trials, "checks": checks, "pass": all(checks.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", required=True)
    parser.add_argument("--slang", required=True)
    parser.add_argument("--python", required=True, help="Python environment containing hdl-encrypt")
    parser.add_argument("--openssl", default="openssl")
    parser.add_argument("--include", type=Path, required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    paths = {}
    for name in ("ghost", "slang", "python", "openssl", "cc"):
        program = shutil.which(os.environ.get("CC", "cc") if name == "cc" else getattr(args, name))
        if program is None:
            parser.error(f"missing tool: {name}")
        paths[name] = Path(program).absolute()
    include = args.include.resolve()
    paths.update({"profile": args.profile, "vpi_user.h": include / "vpi_user.h",
                  "vpi_compatibility.h": include / "vpi_compatibility.h"})
    if not all(path.is_file() for path in paths.values()):
        parser.error("the VPI headers and Ghost profile are required")
    profile = json.loads(args.profile.read_bytes())
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("Ghost must use the strict LRM mode")
    fixtures = CASES[CASE]
    checker, inputs = checker_digest(), suite_results.input_digest(fixtures)
    hashes = {name: digest(path) for name, path in paths.items()}
    try:
        package = encryptor.tool_info(str(paths["python"]))
        with tempfile.TemporaryDirectory() as directory:
            result = qualify(paths, profile, fixtures, Path(directory).resolve())
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"protected access qualification stopped: {error}\n")
    if (hashes != {name: digest(path) for name, path in paths.items()} or checker != checker_digest()
            or package != encryptor.tool_info(str(paths["python"])) or inputs != suite_results.input_digest(fixtures)):
        parser.exit(2, "qualification inputs changed during the run\n")
    versions = {name: suite_results.tool_version([paths[name], option])
                for name, option in (("ghost", "--version"), ("slang", "--version"),
                                     ("cc", "--version"), ("openssl", "version"))}
    args.json.write_text(json.dumps({"profile": PROFILE, "checker_sha256": checker, "artifact_sha256": hashes,
                                     "versions": versions, "encryptor": package,
                                     "tests": {CASE: {"inputs_sha256": inputs, **result}}}, indent=2) + "\n")
    for name, passed in result["checks"].items():
        print(f"{'PASS' if passed else 'FAIL'} {name}")
    return int(not result["pass"])


if __name__ == "__main__":
    raise SystemExit(main())
