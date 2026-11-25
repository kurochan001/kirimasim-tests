#!/usr/bin/env python3
"""Check pragma state, pragma interpretation and command-line library binding with Slang."""

import argparse
from dataclasses import dataclass
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import run_protect_pragma_syntax as protect
import run_slang
import suite_results


PROFILE = "slang-source-checks"
CHECKER = "tools/run_slang_source_checks.py"
PRAGMA = protect.PREFIX
UUENCODE = 'encoding=(enctype="uuencode", bytes=3)'
RESET_OPTIONS = (*protect.OPTIONS, "-Wempty-member", "-Wno-error=empty-member")
IGNORE_EMPTY = '`pragma diagnostic ignore="-Wempty-member"'
PROTECT_BASE64 = '`pragma protect encoding=(enctype="base64", bytes=2)'
RESET_PROTECT = "`pragma reset protect"
RESET_BOTH = "`pragma reset protect, diagnostic"
PROTECT_RESET = "`pragma protect reset"
RESET_ALL = "`pragma resetall"
OMITTED = "// omitted by source control"
STANDARD_INCLUDE = "ch22/test_angle_include_search_uses_only_standard_files"


@dataclass(frozen=True)
class Change:
    before: str
    after: str
    reported_at: str
    diagnostic: str


@dataclass(frozen=True)
class ResetProbe:
    replace: tuple[str, str] | None = None
    warnings: tuple[str, ...] = ()
    encoding_error: str | None = None
    encoding_message: str = "invalid base64 byte"


PRAGMA_CASES = {
    "ch34/test_protect_sequence_split_changes_active_encoding": {
        "reverse_expressions": Change(
            f"{PRAGMA}{UUENCODE}\n{PRAGMA}data_block\n#04)#",
            f"{PRAGMA}data_block\n#04)#\n{PRAGMA}{UUENCODE}",
            "#04)#", "invalid base64 byte '#'",
        ),
    },
    "ch34/test_protect_sequence_combined_changes_encoding_left_to_right": {
        "reverse_expressions": Change(
            f"{PRAGMA}{UUENCODE}, data_block", f"{PRAGMA}data_block, {UUENCODE}",
            "#04)#", "invalid base64 byte '#'",
        ),
    },
    "ch34/test_protect_two_envelopes_close_independently": {
        "remove_close_between_envelopes": Change(
            f"{PRAGMA}end\n{PRAGMA}begin\nmodule protect_state_top;",
            f"{PRAGMA}begin // still inside the first envelope\nmodule protect_state_top;",
            "still inside the first envelope", "[-Wnested-protect-begin]",
        ),
        "add_unmatched_end": Change(
            f"\nendmodule\n{PRAGMA}end\n",
            f"\nendmodule\n{PRAGMA}end\n{PRAGMA}end // unmatched close\n",
            "unmatched close", "[-Wextra-protect-end]",
        ),
    },
    "ch34/test_protect_open_envelope_matches_its_end_after_source": {
        "remove_open": Change(
            f"{PRAGMA}begin\nmodule protect_state_top;",
            f"{PRAGMA}reset\nmodule protect_state_top;",
            f"\n{PRAGMA}end\n", "[-Wextra-protect-end]",
        ),
    },
}

for scheme, size, payload, other, invalid_byte in (
    ("base64", 2, "QUI=", "uuencode", "invalid uuencode byte 'Q'"),
    ("uuencode", 3, "#04)#", "base64", "invalid base64 byte '#'"),
):
    PRAGMA_CASES[f"ch34/test_protect_{scheme}_descriptor_selects_algorithm_and_byte_count"] = {
        "wrong_algorithm": Change(f'enctype="{scheme}"', f'enctype="{other}"', payload, invalid_byte),
        "wrong_byte_count": Change(
            f"bytes={size}", f"bytes={size - 1}", payload,
            f"{size} bytes decoded in protected envelope but encoding pragma said to expect {size - 1}",
        ),
    }
    PRAGMA_CASES[f"ch34/test_protect_{scheme}_data_decrypt_key_uses_only_the_next_line"] = {
        "move_key_to_second_line": Change(
            payload, "\n" + payload, PRAGMA + "data_decrypt_key",
            f"0 bytes decoded in protected envelope but encoding pragma said to expect {size}",
        ),
    }

LIBRARY_CASES = {
    "ch33/test_library_search_option_overrides_map_default_order": {
        "map_order": ((), "red"),
        "single_name": (("blueLib",), "blue"),
    },
    "ch33/test_library_search_option_follows_two_names_in_order": {
        "blue_before_red": (("blueLib", "redLib"), "blue"),
        "red_before_blue": (("redLib", "blueLib"), "red"),
    },
}
RESET_CASES = {
    "ch34/test_pragma_reset_lists_protect_and_diagnostic_state": {
        "selected_states": ResetProbe(warnings=("initial warning", "restored warning")),
        "no_first_reset": ResetProbe((RESET_PROTECT + "\n", OMITTED + "\n"),
                                     ("initial warning", "restored warning"), "?first"),
        "diagnostic_only": ResetProbe((RESET_PROTECT + "\n", "`pragma reset diagnostic\n"),
                                      ("initial warning", "selective warning", "restored warning"), "?first"),
        "no_list_reset": ResetProbe((RESET_BOTH, OMITTED), ("initial warning",), "?both"),
        "no_warning_override": ResetProbe((IGNORE_EMPTY, OMITTED),
                                          ("initial warning", "selective warning", "restored warning")),
    },
    "ch34/test_pragma_resetall_restores_protect_and_diagnostic_state": {
        "all_states": ResetProbe(warnings=("initial warning", "restored warning")),
        "no_reset": ResetProbe((RESET_ALL, OMITTED), ("initial warning",), "?all"),
        "protect_only": ResetProbe((RESET_ALL, RESET_PROTECT), ("initial warning",)),
    },
    "ch34/test_protect_reset_stops_encoding_state_at_file_boundary": {
        "protect_reset": ResetProbe(),
        "named_reset": ResetProbe((PROTECT_RESET, RESET_PROTECT)),
        "state_leaks_without_reset": ResetProbe((PROTECT_RESET, OMITTED), encoding_error="?next"),
    },
    "ch34/test_protect_reset_restores_default_before_reconfiguration": {
        "reconfigure_after_reset": ResetProbe(),
        "reconfigure_after_named_reset": ResetProbe((PROTECT_RESET, RESET_PROTECT)),
        "old_encoding_without_reset": ResetProbe((PROTECT_RESET, OMITTED), encoding_error="?restored"),
        "invalid_new_encoding": ResetProbe(("#04)#", '"not_uu"'), encoding_error='"not_uu"',
                                           encoding_message="invalid uuencode byte"),
    },
}
INCLUDE_CASES = {STANDARD_INCLUDE: "markers/search_value.svh"}
CASES = PRAGMA_CASES | LIBRARY_CASES | RESET_CASES | INCLUDE_CASES


def checker_digest() -> str:
    digest = hashlib.sha256()
    for name in (CHECKER, protect.CHECKER, "tools/run_slang.py", "tools/suite_results.py"):
        digest.update(name.encode() + b"\0")
        digest.update(hashlib.sha256((suite_results.ROOT / name).read_bytes()).digest())
    return digest.hexdigest()


def changed_source(source: str, change: Change) -> tuple[str, int]:
    if source.count(change.before) != 1:
        raise ValueError(f"expected exactly one source fragment {change.before!r}")
    changed = source.replace(change.before, change.after, 1)
    if change.before == change.after or changed.count(change.reported_at) != 1:
        raise ValueError(f"expected one diagnostic anchor {change.reported_at!r}")
    anchor = change.reported_at.lstrip("\n")
    start = changed.index(change.reported_at) + len(change.reported_at) - len(anchor)
    return changed, changed.count("\n", 0, start) + 1


def pragma_checks(test: Path, executable: Path, top: str, work: Path, changes: dict) -> dict:
    source = test.read_text(encoding="utf-8")
    probe = work / test.name
    probe.write_text(source, encoding="utf-8")
    code, errors = protect.compile_source(executable, probe, top)
    results = {"control": {"pass": code == 0 and not errors, "returncode": code, "diagnostics": errors}}
    for label, change in changes.items():
        changed, line = changed_source(source, change)
        probe.write_text(changed, encoding="utf-8")
        code, errors = protect.compile_source(executable, probe, top)
        matched = code is not None and code > 0 and any(
            message.startswith(f"{test.name}:{line}:") and change.diagnostic in message
            for message in errors
        )
        results[label] = {"pass": matched, "returncode": code, "diagnostics": errors,
                          "expected_line": line, "expected_diagnostic": change.diagnostic}
    return results


def reset_checks(test: Path, executable: Path, top: str, work: Path, probes: dict) -> dict:
    sources, _ = suite_results.files(test)
    source_text = {path.name: path.read_text(encoding="utf-8") for path in (*sources, test)}
    if len(source_text) != len(sources) + 1:
        raise ValueError(f"{test.name} must use distinct source basenames")
    compilation = ["--single-unit"] if suite_results.header(test).get("compilation_unit") == "single" else []
    observed = {}
    for label, probe in probes.items():
        text = source_text.copy()
        if probe.replace:
            before, after = probe.replace
            changed = [name for name, contents in text.items() if before in contents]
            if len(changed) != 1 or text[changed[0]].count(before) != 1:
                raise ValueError(f"expected one reset control anchor {before!r}")
            text[changed[0]] = text[changed[0]].replace(before, after, 1)

        def expected(anchor, message, severity):
            locations = [(name, i) for name, contents in text.items()
                         for i, line in enumerate(contents.splitlines(), 1) if anchor in line]
            if len(locations) != 1:
                raise ValueError(f"expected one diagnostic location for {anchor!r}")
            filename, line = locations[0]
            return {"file": filename, "line": line, "message": message, "severity": severity}

        expected_diagnostics = [expected(anchor, "extra ';' has no effect", "warning")
                                for anchor in probe.warnings]
        if probe.encoding_error:
            expected_diagnostics.append(expected(probe.encoding_error, probe.encoding_message, "error"))
        for name, contents in text.items():
            (work / name).write_text(contents, encoding="utf-8")
        command = [str(executable), *RESET_OPTIONS, *compilation, "--top", top, *text]
        try:
            process = subprocess.run(command, cwd=work, capture_output=True, text=True, timeout=45)
        except subprocess.TimeoutExpired:
            observed[label] = {"pass": False, "returncode": None, "diagnostics": [],
                               "expected_diagnostics": expected_diagnostics}
            continue
        diagnostics = [run_slang.relative(line, str(work))
                       for line in (process.stdout + process.stderr).splitlines()
                       if re.search(r"(?:\bwarning|\berror): ", line)]
        diagnostic_matches = all(any(
            re.match(rf"^{re.escape(item['file'])}:{item['line']}:\d+: {item['severity']}: ", message)
            and item["message"] in message for message in diagnostics) for item in expected_diagnostics)
        exit_matches = process.returncode > 0 if probe.encoding_error else process.returncode == 0
        observed[label] = {
            "pass": exit_matches and diagnostic_matches and len(diagnostics) == len(expected_diagnostics),
            "returncode": process.returncode, "diagnostics": diagnostics,
            "expected_diagnostics": expected_diagnostics,
        }
    return observed


def include_checks(test: Path, executable: Path, top: str, work: Path, header: str) -> dict:
    for relative in suite_results.header(test)["files"].split():
        origin = test.parent / relative
        destination = work / Path(relative).relative_to("angle_include_search")
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(origin, destination)
    directory = work / "working"
    source = directory / test.name
    shutil.copyfile(test, source)
    angle = f"`include <{header}>"
    contents = source.read_text(encoding="utf-8")
    if contents.count(angle) != 1:
        raise ValueError("expected one angle include statement")
    angle_line = contents.count("\n", 0, contents.index(angle)) + 1
    command = [str(executable), *run_slang.OPTIONS, "--top", top, "-I", str(work / "user"),
               "--ast-json", "design.json", source.name]
    system = ["--isystem", str(work / "standard")]

    def run(options, quoted):
        result = subprocess.run([*command, *options], cwd=directory, capture_output=True,
                                text=True, timeout=45)
        errors = [run_slang.relative(line, str(directory)) for line in result.stderr.splitlines()
                  if run_slang.ERROR.search(line)]
        values = {}
        if result.returncode == 0:
            design = json.loads((directory / "design.json").read_text(encoding="utf-8"))["design"]
            for instance in design["members"]:
                if instance["kind"] == "Instance" and instance["name"] == top:
                    values = {item["name"]: int(item["value"]) for item in instance["body"]["members"]
                              if item["kind"] == "Parameter"}
        if quoted is None:
            passed = result.returncode > 0 and any(
                message.startswith(f"{source.name}:{angle_line}:") and header in message
                and "No such file" in message for message in errors)
        else:
            passed = (result.returncode == 0 and not errors
                      and values == {"QUOTED_VALUE": quoted, "STANDARD_VALUE": 37})
        return {"pass": passed, "returncode": result.returncode, "values": values, "diagnostics": errors}

    comparisons = {"all_search_locations": run(system, 11), "no_system_location": run([], None)}
    (work / "standard" / header).unlink()
    comparisons["missing_standard_header"] = run(system, None)
    shutil.copyfile(test.parent / "angle_include_search" / "standard" / header, work / "standard" / header)
    (directory / header).unlink()
    comparisons["quoted_user_fallback"] = run(system, 19)
    return comparisons


def library_checks(test: Path, executable: Path, top: str, work: Path, orders: dict) -> dict:
    fields = suite_results.header(test)
    _, include_dirs = suite_results.files(test)
    maps = [test.parent / name for name in fields["files"].split() if name.endswith(".map")]
    if len(maps) != 2:
        raise ValueError(f"{test.name} must declare two library maps")
    ast = work / "design.json"
    results = {}
    for label, (names, selected) in orders.items():
        order_options = [option for name in names for option in ("-L", name)]
        map_options = [option for path in maps for option in ("--libmap", str(path))]
        # The library maps themselves supply the source declarations.
        command = [str(executable), *run_slang.OPTIONS, *map_options,
                   "--top", top, "--ast-json", str(ast), "--ast-json-source-info",
                   *[f"-I{directory}" for directory in include_dirs], *order_options, str(test)]
        process = subprocess.run(command, cwd=work, capture_output=True, text=True, timeout=45)
        errors = [run_slang.relative(line, str(work)) for line in process.stderr.splitlines()
                  if run_slang.ERROR.search(line)]
        bindings = {}
        if process.returncode == 0:
            design = json.loads(ast.read_text(encoding="utf-8"))["design"]
            for instance in design["members"]:
                if instance["kind"] == "Instance" and instance["name"] == top:
                    for child in instance["body"]["members"]:
                        if child["kind"] == "Instance":
                            path = (work / child["body"]["source_file"]).resolve()
                            root = suite_results.ROOT
                            bindings[child["name"]] = (path.relative_to(root).as_posix()
                                                        if path.is_relative_to(root) else path.name)
        expected = {
            "selected": f"tests/ch33/libmap_order/{selected}/units.sv",
            "supplemental": "tests/ch33/libmap_order/blue/units.sv",
        }
        results[label] = {"pass": process.returncode == 0 and bindings == expected,
                          "returncode": process.returncode, "library_order": list(names),
                          "bindings": bindings, "expected_bindings": expected, "diagnostics": errors}
    return results


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--slang", required=True, help="Slang compiler executable")
    parser.add_argument("--json", required=True, type=Path, help="qualification record")
    args = parser.parse_args()
    program = shutil.which(args.slang)
    if program is None:
        parser.error("Slang compiler is unavailable")
    executable = Path(program).resolve()
    binary_hash = hashlib.sha256(executable.read_bytes()).hexdigest()
    checker_hash = checker_digest()
    version = suite_results.tool_version([str(executable), "--version"])
    fixtures = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in CASES}
    inputs = suite_results.fingerprints(list(fixtures.values()))
    records = {}
    for case, test in fixtures.items():
        top = suite_results.top_module(test)
        if top is None:
            raise ValueError(f"{test.name} must declare a top module")
        if case in PRAGMA_CASES:
            check = pragma_checks
        elif case in RESET_CASES:
            check = reset_checks
        elif case in INCLUDE_CASES:
            check = include_checks
        else:
            check = library_checks
        with tempfile.TemporaryDirectory() as directory:
            result = check(test, executable, top, Path(directory), CASES[case])
        records[case] = {"inputs_sha256": inputs[case], "checks": result}
    if (binary_hash != hashlib.sha256(executable.read_bytes()).hexdigest()
            or checker_hash != checker_digest()
            or inputs != suite_results.fingerprints(list(fixtures.values()))):
        parser.exit(2, "Compiler, checker or input changed during qualification.\n")
    passed = sum(check["pass"] for record in records.values() for check in record["checks"].values())
    total = sum(len(record["checks"]) for record in records.values())
    run_slang.write(args.json, {
        "profile": PROFILE, "compiler": "Slang", "version": version, "binary_sha256": binary_hash,
        "checker_sha256": checker_hash, "pragma_options": list(protect.OPTIONS),
        "library_options": run_slang.OPTIONS, "reset_options": RESET_OPTIONS,
        "passed_checks": passed, "total_checks": total,
        "tests": records,
    })
    print(f"{version}: {passed}/{total} source checks matched across {len(records)} fixtures")
    return int(passed != total)


if __name__ == "__main__":
    raise SystemExit(main())
