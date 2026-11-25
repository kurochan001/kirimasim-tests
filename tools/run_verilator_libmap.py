#!/usr/bin/env python3
"""Run the Verilator cases that require library maps at compilation time."""

import argparse
import hashlib
import os
from pathlib import Path
import shlex
import shutil
import tempfile

import run_verilator
import suite_results


PROFILE = "verilator-library-map"
CHECKER = "tools/run_verilator_libmap.py"
CASE_MAPS = {
    "ch33/test_library_map_question_matches_exactly_one_character": ("libmap_wildcards/length.map",),
    "ch33/test_library_map_hierarchical_wildcard_matches_zero_and_nested_directories":
        ("libmap_wildcards/hierarchy.map",),
    "ch33/test_library_map_star_stays_within_a_path_component": ("libmap_star/name.map",),
    "ch33/test_library_maps_prefer_explicit_then_wildcard_then_directory":
        ("libmap_priority/directory.map", "libmap_priority/filenames.map"),
    "ch33/test_library_map_dot_and_parent_are_relative_to_the_map":
        ("libmap_relative/maps/deep/provider.map",),
    "ch33/test_library_map_include_preserves_its_own_relative_paths":
        ("libmap_relative/maps/main.map",),
    "ch33/test_nested_library_map_includes_restore_the_containing_directory":
        ("libmap_nested/maps/root.map",),
    "ch33/test_library_map_relative_directory_path_aliases":
        ("libmap_aliases/maps/directories.map", "libmap_aliases/maps/no_dot/names.map",
         "libmap_aliases/maps/with_dot/names.map"),
    "ch33/test_illegal_library_map_same_priority_file_match":
        ("libmap_ambiguity/conflicting.map",),
    "ch33/test_library_map_grammar_binds_config_and_local_include_lists":
        ("libmap_grammar/maps/main.map",),
    "ch33/test_library_map_order_selects_first_matching_cell":
        ("libmap_order/red.map", "libmap_order/blue.map"),
    "ch33/test_library_map_reversed_order_changes_selected_cell":
        ("libmap_order/blue.map", "libmap_order/red.map"),
    "ch33/test_illegal_library_map_contains_a_module_declaration":
        ("libmap_invalid_contents/invalid_contents.map",),
}


def checker_digest() -> str:
    return hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes()).hexdigest()


def run_case(test: Path, executable: str, maps: tuple[str, ...], seed: int) -> tuple[bool, str]:
    command = [executable]
    declared = suite_results.header(test).get("files", "").split()
    for name in maps:
        if name not in declared:
            raise ValueError(f"{test.name} must declare {name} in :files:")
        command.extend(("-libmap", str((test.parent / name).resolve())))
    with tempfile.TemporaryDirectory() as directory:
        launcher = Path(directory) / "verilator-with-library-maps"
        launcher.write_text(f'#!/bin/sh\nexec {shlex.join(command)} "$@"\n', encoding="utf-8")
        launcher.chmod(0o700)
        return run_verilator.run(test, str(launcher), seed, run_verilator.install_prefix(executable))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verilator", default="verilator", help="Verilator executable")
    parser.add_argument("--seed", type=int, default=1, help="simulation seed")
    parser.add_argument("--json", required=True, type=Path, help="write results to this file")
    args = parser.parse_args()
    executable = shutil.which(args.verilator)
    if executable is None:
        parser.error("Verilator executable is unavailable")
    launcher = Path(executable).resolve()
    backend = shutil.which(os.environ.get("VERILATOR_BIN", str(launcher.with_name("verilator_bin"))))
    binaries = {"launcher": launcher}
    if backend is not None:
        binaries["compiler"] = Path(backend).resolve()
    binary_hashes = {name: hashlib.sha256(path.read_bytes()).hexdigest() for name, path in binaries.items()}
    version = suite_results.tool_version([str(launcher), "--version"])
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest("verilator")
    tests = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in CASE_MAPS}
    inputs = suite_results.fingerprints(list(tests.values()))
    results = {}
    for case, maps in CASE_MAPS.items():
        passed, reason = run_case(tests[case], str(launcher), maps, args.seed)
        if passed:
            status = "pass"
        elif reason.startswith("build failed: %Error-UNSUPPORTED:"):
            status = "unsupported"
        else:
            status = "fail"
        results[case] = status, reason
        print(f"{status.upper()} {case}" + (f": {reason}" if reason else ""))

    if (any(binary_hashes[name] != hashlib.sha256(path.read_bytes()).hexdigest()
            for name, path in binaries.items()) or checker_hash != checker_digest()):
        parser.exit(2, "Verilator or the library-map checker changed during execution.\n")
    suite_results.write(args.json, "verilator", "Verilator", version, results,
                        inputs=inputs, runner_sha256=runner_hash,
                        configuration={"evidence_profile": PROFILE, "seed": args.seed,
                                       "checker_sha256": checker_hash, "binary_sha256": binary_hashes})
    return int(any(status != "pass" for status, _ in results.values()))


if __name__ == "__main__":
    raise SystemExit(main())
