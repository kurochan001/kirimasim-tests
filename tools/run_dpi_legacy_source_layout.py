#!/usr/bin/env python3
"""Check deprecated DPI source declarations and replay two packed-object ABIs."""

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
import suite_results


CHECKER = "tools/run_dpi_legacy_source_layout.py"
PROFILE = "dpi-legacy-source-layout-reference"
CASE = "ch35/test_dpi_legacy_source_layout"
CASES = {CASE: suite_results.ROOT / "tests" / (CASE + ".sv")}
LAYOUTS = ("words", "bytes")
HEADER = "svdpi_src.h"
MACROS = {"SV_BIT_PACKED_ARRAY", "SV_LOGIC_PACKED_ARRAY"}
DEFINITIONS = re.compile(r"^#define (\w+)(.*)$", re.M)
SHAPE = re.compile(r"host shape bit=(\d+) logic=(\d+) state=(\d+)")
BASE = '#include "svdpi.h"\n'
WITH_SOURCE = BASE + '#include "svdpi_src.h"\n'
ARRAY_DECLARATIONS = """#define SV_BIT_PACKED_ARRAY(WIDTH, NAME) svBitVec32 NAME[SV_CANONICAL_SIZE(WIDTH)]
#define SV_LOGIC_PACKED_ARRAY(WIDTH, NAME) svLogicVec32 NAME[SV_CANONICAL_SIZE(WIDTH)]
"""
TYPE_PROBE = WITH_SOURCE + """
SV_BIT_PACKED_ARRAY(65, bits);
SV_LOGIC_PACKED_ARRAY(33 + 32, state);
SV_BIT_PACKED_ARRAY(65, bit_rows)[2];
SV_LOGIC_PACKED_ARRAY(65, state_rows)[2];
#ifdef __cplusplus
#include <type_traits>
#define ASSERT_NON_ARRAY(VALUE, LABEL) static_assert(!std::is_array_v<decltype(VALUE)>, LABEL)
#define ASSERT_ROW_NON_ARRAY(VALUE, LABEL) ASSERT_NON_ARRAY(std::remove_extent_t<decltype(VALUE)>{}, LABEL)
#else
/* The conditional expression converts an array to a pointer, preserving a struct. */
#define ASSERT_NON_ARRAY(VALUE, LABEL) _Static_assert( \
    __builtin_types_compatible_p(__typeof__(VALUE), __typeof__(1 ? (VALUE) : (VALUE))), LABEL)
#define ASSERT_ROW_NON_ARRAY(VALUE, LABEL) ASSERT_NON_ARRAY((VALUE)[0], LABEL)
#endif
ASSERT_NON_ARRAY(bits, "bit macro declared an array");
ASSERT_NON_ARRAY(state, "logic macro declared an array");
ASSERT_ROW_NON_ARRAY(bit_rows, "bit row has an extra array dimension");
ASSERT_ROW_NON_ARRAY(state_rows, "logic row has an extra array dimension");
"""


def digest(path: Path) -> str:
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def checker_digest() -> str:
    return hashlib.sha256((digest(suite_results.ROOT / CHECKER)
                           + suite_results.runner_digest("ghost")).encode()).hexdigest()


def execute(command: list[str], *, source: str | None = None, cwd: Path | None = None,
            env: dict | None = None) -> subprocess.CompletedProcess:
    return subprocess.run(command, input=source, cwd=cwd, env=env, capture_output=True, text=True,
                          errors="replace", timeout=60)


def checked(command: list[str], source: str | None = None) -> str:
    proc = execute(command, source=source)
    if proc.returncode != 0:
        raise ValueError(f"compiler exited with {proc.returncode}: {proc.stderr.strip()}")
    return proc.stdout


def inspect_header(command: list[str]) -> dict:
    base = dict(DEFINITIONS.findall(checked([*command, "-E", "-dM", "-"], BASE)))
    extension = dict(DEFINITIONS.findall(checked([*command, "-E", "-dM", "-"], WITH_SOURCE)))
    new = {name: text.strip() for name, text in extension.items() if name not in base}
    changed = sorted(name for name, text in base.items() if extension.get(name) != text)
    base_tokens = checked([*command, "-E", "-P", "-"], BASE).split()
    source_tokens = checked([*command, "-E", "-P", "-"], WITH_SOURCE).split()
    types = execute([*command, "-fsyntax-only", "-"], source=TYPE_PROBE)
    return {
        "new_macros": new, "changed_or_removed_macros": changed,
        "declaration_tokens_unchanged": base_tokens == source_tokens,
        "type_check_exit": types.returncode,
        "bit_array_detected": "bit macro declared an array" in types.stderr,
        "logic_array_detected": "logic macro declared an array" in types.stderr,
    }


def qualify_headers(directory: Path, include: Path, fixtures: Path, compilers: dict[str, str]) -> dict:
    first = (fixtures / "words" / HEADER).read_text(encoding="utf-8")
    paths = {layout: fixtures / layout for layout in LAYOUTS}
    if (include / HEADER).is_file():
        paths["provided"] = include
    supported_layouts = tuple(paths)
    for name, source in {
        "additional_macro": first + "#define SV_SOURCE_LAYOUT_UNRELATED 1\n",
        "additional_type": first + "typedef unsigned int svLegacyExtraType;\n",
        "array_macro": ARRAY_DECLARATIONS,
    }.items():
        paths[name] = directory / name
        paths[name].mkdir()
        (paths[name] / HEADER).write_text(source, encoding="utf-8")

    observations = {}
    for language, standard in (("c", "c11"), ("c++", "c++17")):
        base = [compilers[language], "-x", language, f"-std={standard}"]
        observations[language] = {
            name: inspect_header([*base, "-I", str(path), "-I", str(include)])
            for name, path in paths.items()
        }
    checks = {}
    for language, rows in observations.items():
        checks[language] = {
            "only_two_macro_definitions": all(set(rows[layout]["new_macros"]) == MACROS
                                              and not rows[layout]["changed_or_removed_macros"]
                                              and rows[layout]["declaration_tokens_unchanged"]
                                              for layout in supported_layouts),
            "both_macros_declare_non_array_types": all(rows[layout]["type_check_exit"] == 0
                                                       for layout in supported_layouts),
            "extra_macro_detected": set(rows["additional_macro"]["new_macros"])
            == MACROS | {"SV_SOURCE_LAYOUT_UNRELATED"},
            "extra_type_detected": not rows["additional_type"]["declaration_tokens_unchanged"],
            "both_array_controls_detected": rows["array_macro"]["type_check_exit"] > 0
            and rows["array_macro"]["bit_array_detected"] and rows["array_macro"]["logic_array_detected"],
        }
    return {"observations": observations, "checks": checks,
            "pass": all(all(verdicts.values()) for verdicts in checks.values())}


def application_objects(compiler: str, include: Path, directory: Path, fixtures: Path, source: Path) -> dict:
    command = [compiler, "-std=c11", "-Wall", "-Wextra", "-Werror", "-fPIC", "-c"]
    base_header = ["-I", str(include)]
    objects = {name: directory / f"{name}.o" for name in ("opaque", *LAYOUTS, "dropped_unknown")}
    checked([*command, *base_header, "-o", str(objects["opaque"]), str(source)])
    for layout in LAYOUTS:
        checked([*command, "-DDPI_USE_SOURCE_LAYOUT", "-I", str(fixtures / layout), *base_header,
                 "-o", str(objects[layout]), str(source)])
    original = source.read_text(encoding="utf-8")
    output = "    svPutLogicVec32(received_logic, state, width);"
    if original.count(output) != 1:
        raise ValueError("could not locate the logic conversion in the foreign application")
    damaged = directory / "dropped_unknown.c"
    damaged.write_text(original.replace(output, "    state[0].d = 0;\n" + output), encoding="utf-8")
    checked([*command, *base_header, "-o", str(objects["dropped_unknown"]), str(damaged)])
    return objects


def shared_libraries(compiler: str, directory: Path, objects: dict) -> dict:
    darwin = sys.platform == "darwin"
    flags = ["-undefined", "dynamic_lookup"] if darwin else []
    suffix = ".dylib" if darwin else ".so"
    libraries = {name: directory / f"lib_{name}{suffix}" for name in objects}
    for name, library in libraries.items():
        checked([compiler, "-shared", *flags, str(objects[name]), "-o", str(library)])
    return libraries


def host_run(compiler: str, include: Path, directory: Path, host: Path, application: Path,
             host_layout: str, source_dependent: bool) -> dict:
    binary = directory / f"{host_layout}_{application.stem}"
    flags = ["-DBYTE_LAYOUT"] if host_layout == "bytes" else []
    if source_dependent:
        flags.append("-DCHECK_SOURCE_SHAPE")
    checked([compiler, "-std=c11", "-Wall", "-Wextra", "-Werror", "-I", str(include), *flags,
             str(host), str(application), "-o", str(binary)])
    run = execute([str(binary)], cwd=directory)
    lines = run.stdout.splitlines()
    layout = SHAPE.fullmatch(lines[0]) if lines else None
    return {"library_sha256": digest(application), "exit": run.returncode,
            "host_shape": list(map(int, layout.groups())) if layout else None, "stdout": lines[1:]}


def qualify_hosts(compiler: str, include: Path, directory: Path, host: Path, libraries: dict,
                  expected: list[str]) -> dict:
    replays = {layout: {
        name: host_run(compiler, include, directory, host, library, layout, name in LAYOUTS)
        for name, library in libraries.items()
    } for layout in LAYOUTS}
    baseline_hash = digest(libraries["opaque"])
    checks = {
        "both_hosts_have_distinct_shapes": all(replays[layout]["opaque"]["host_shape"] for layout in LAYOUTS)
        and replays["words"]["opaque"]["host_shape"] != replays["bytes"]["opaque"]["host_shape"],
        "opaque_library_reused_unchanged": all(
            replays[layout]["opaque"]["library_sha256"] == baseline_hash
            and replays[layout]["opaque"]["exit"] == 0 and replays[layout]["opaque"]["stdout"] == expected
            for layout in LAYOUTS),
        "recompiled_source_matches_each_host": all(
            replays[layout][layout]["exit"] == 0
            and replays[layout][layout]["stdout"] == ["source layout matches host=1", *expected]
            for layout in LAYOUTS),
        "cross_link_layout_mismatch_detected": all(
            replays[host_layout][app_layout]["exit"] == 3
            and replays[host_layout][app_layout]["stdout"] == ["source layout matches host=0"]
            for host_layout, app_layout in (("words", "bytes"), ("bytes", "words"))),
        "four_state_control_detected": all(
            replays[layout]["dropped_unknown"]["exit"] == 0
            and replays[layout]["dropped_unknown"]["stdout"]
            == [line.removesuffix("logic=1") + "logic=0" for line in expected]
            for layout in LAYOUTS),
    }
    return {"replays": replays, "checks": checks, "pass": all(checks.values())}


def qualify_ghost(ghost: str, profile: dict, directory: Path, fixture: Path, libraries: dict,
                  expected: list[str]) -> dict:
    results = {}
    for name in ("opaque", "words"):
        library = libraries[name]
        run = execute([ghost, *profile["arguments"], "--lib", str(library), str(fixture)],
                      cwd=directory, env={**os.environ, **profile["environment"]})
        output = run_ghost.normalize(run.stdout, profile).splitlines()
        results[name] = {"exit": run.returncode, "stdout": output,
                         "library_sha256": digest(library),
                         "pass": run.returncode == 0 and output == expected}
    return {"runs": results, "pass": all(run["pass"] for run in results.values())}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--include", required=True, type=Path, help="path containing svdpi.h")
    parser.add_argument("--simulator", help="optional Ghost executable for native DPI replay")
    parser.add_argument("--profile", type=Path, help="private Ghost runtime profile")
    parser.add_argument("--json", required=True, type=Path)
    args = parser.parse_args()
    if bool(args.simulator) != bool(args.profile):
        parser.error("--simulator and --profile must be used together")
    include = args.include.resolve()
    compilers = {language: shutil.which(os.environ.get(variable, default))
                 for language, variable, default in (("c", "CC", "cc"), ("c++", "CXX", "c++"))}
    simulator = shutil.which(args.simulator) if args.simulator else None
    if not all(compilers.values()) or (args.simulator and simulator is None):
        parser.error("a C or C++ compiler or the requested simulator is unavailable")
    tools = {name: Path(path).resolve() for name, path in compilers.items()}
    tools["svdpi.h"] = include / "svdpi.h"
    native_source_header = include / HEADER
    if native_source_header.is_file():
        tools[HEADER] = native_source_header
    if simulator:
        tools.update(ghost=Path(simulator).resolve(), profile=args.profile)
    if not all(path.is_file() for path in tools.values()):
        parser.error("svdpi.h or the profile is unavailable")
    fingerprints = {name: digest(path) for name, path in tools.items()}
    fixture = CASES[CASE]
    fixtures = fixture.parent / "legacy_source_layout"
    checker, inputs = checker_digest(), suite_results.input_digest(fixture)
    expected = suite_results.expected_output(fixture).splitlines()
    profile = json.loads(args.profile.read_bytes()) if simulator else None
    if profile and "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")

    with tempfile.TemporaryDirectory() as temporary:
        directory = Path(temporary)
        headers = qualify_headers(directory, include, fixtures, compilers)
        objects = application_objects(compilers["c"], include, directory, fixtures, fixture.with_suffix(".c"))
        libraries = shared_libraries(compilers["c"], directory, objects)
        object_hashes = {key: digest(value) for key, value in objects.items()}
        library_hashes = {key: digest(value) for key, value in libraries.items()}
        hosts = qualify_hosts(compilers["c"], include, directory, fixtures / "host.c", libraries, expected)
        ghost = qualify_ghost(str(tools["ghost"]), profile, directory, fixture,
                              libraries, expected) if simulator else None
        unchanged = (object_hashes == {key: digest(value) for key, value in objects.items()}
                     and library_hashes == {key: digest(value) for key, value in libraries.items()})
    if (fingerprints != {name: digest(path) for name, path in tools.items()}
            or checker != checker_digest() or inputs != suite_results.input_digest(fixture)
            or native_source_header.is_file() != (HEADER in tools)):
        parser.exit(2, "The qualification inputs changed during the run.\n")
    passed = unchanged and headers["pass"] and hosts["pass"] and (ghost is None or ghost["pass"])
    result = {"inputs_sha256": inputs, "headers": headers, "hosts": hosts,
              "application_artifacts_unchanged": unchanged, "native_source_header_available": HEADER in tools,
              "object_sha256": object_hashes, "library_sha256": library_hashes, "pass": passed}
    if ghost is not None:
        result["ghost"] = ghost
    report = {"profile": PROFILE, "checker_sha256": checker, "artifact_sha256": fingerprints,
              "compiler_versions": {lang: suite_results.tool_version([path, "--version"])
                                    for lang, path in compilers.items()},
              "tests": {CASE: result}}
    args.json.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"{'PASS' if passed else 'FAIL'}: header controls and two ABI replays"
          + (" plus Ghost" if simulator else ""))
    return int(not passed)


if __name__ == "__main__":
    raise SystemExit(main())
