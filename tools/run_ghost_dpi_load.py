#!/usr/bin/env python3
"""Check Annex J loading with separate user-built libraries and Ghost."""

import argparse
import hashlib
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

import suite_results


PROFILE = "ghost-dpi-object-loading"
CHECKER = "tools/run_ghost_dpi_load.py"
CASES = {
    "ch35/test_dpi_annex_j_calls_user_built_shared_objects": ("abcd", False),
    "ch35/test_dpi_annex_j_keeps_multiple_prebuilt_objects_available": ("dbac", False),
    "ch35/test_dpi_annex_j_combines_bootstrap_files_and_direct_libraries": ("abcd", True),
    "ch35/test_dpi_annex_j_resolves_roots_and_deduplicates_bootstrap_aliases": ("bacd", True),
}


def checker_digest() -> str:
    return hashlib.sha256((suite_results.ROOT / CHECKER).read_bytes()).hexdigest()


def options(switch: str, *values: str | Path) -> list[str]:
    return [item for value in values for item in (switch, str(value))]


def build_objects(compiler: str, source: Path, root: Path, suffix: str) -> dict[str, Path]:
    (root / "nested").mkdir(parents=True)
    objects = {letter: root / "nested" / f"libannex_j_{letter}{suffix}" for letter in "abcd"}
    for number, path in enumerate(objects.values(), 1):
        subprocess.run([compiler, "-shared", "-fPIC", f"-DANNEX_J_OBJECT={number}",
                        "-o", str(path), str(source)], cwd=root, capture_output=True,
                       timeout=60, check=True)
    return objects


def write_bootstrap(path: Path, entries: list[Path]) -> None:
    lines = ["#!SV_LIBRARIES"]
    for index, entry in enumerate(entries):
        if index:
            lines.extend(["# A comment may start in column one.", "   # Indentation is allowed."])
        lines.append(f" {'  ' * index}{entry}{'  ' * index}")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def invocation(simulator: Path, fixture: Path, cwd: Path, arguments: list[str], order: str) -> str:
    try:
        run = subprocess.run([str(simulator), "--quiet", "--lrm-strict", *arguments, str(fixture)],
                             cwd=cwd, capture_output=True, text=True, errors="replace", timeout=90)
    except subprocess.TimeoutExpired:
        return "timed_out"
    if run.returncode:
        messages = (run.stderr + run.stdout).lower()
        if run.returncode < 0:
            return "crashed"
        if "unknown option" in messages or "unexpected argument" in messages:
            return "unknown_option"
        if "failed to load" in messages:
            return "library_load_failed"
        return "nonzero_exit"
    observed = [line for line in run.stdout.splitlines() if line.startswith(("loaded Annex J ", "annex j "))]
    expected = [f"loaded Annex J {letter}" for letter in order]
    expected.extend(suite_results.expected_output(fixture).splitlines())
    return "pass" if observed == expected else "load_order_or_dpi_output_differs"


def annex_invocations(work: Path, root: Path, objects: dict[str, Path], order: str):
    first, second, third, fourth = [objects[letter] for letter in order]
    relative = [objects[letter].relative_to(root).with_suffix("") for letter in order]
    root_option = options("-sv_root", root)
    yield "direct_default_root", root, options("-sv_lib", *relative)
    yield "direct_selected_root", work, root_option + options("-sv_lib", *relative)

    # A relative name before the root switch exists only in the caller's cwd.
    before_root = Path("nested") / f"libbefore_root{first.suffix}"
    (work / before_root.parent).mkdir()
    (work / before_root).hardlink_to(first)
    yield "root_switch_order", work, (
        options("-sv_lib", before_root.with_suffix("")) + root_option
        + options("-sv_lib", relative[1], third.with_suffix(""), relative[3])
    )

    relative_list = Path("lists") / "first.libs"
    (root / relative_list.parent).mkdir()
    next_list = work / "second.libs"
    empty_list = work / "empty.libs"
    absolute_entry = work / third.name
    absolute_entry.hardlink_to(third)
    write_bootstrap(root / relative_list, relative[:2])
    write_bootstrap(next_list, [absolute_entry.with_suffix(""), relative[3]])
    write_bootstrap(empty_list, [])
    yield "bootstrap_files", work, root_option + options("-sv_liblist", relative_list, next_list)

    # The hard link and the exact repeated path both identify bootstrap objects.
    alias = root / "nested" / f"libannex_j_alias{second.suffix}"
    alias.hardlink_to(second)
    yield "bootstrap_before_direct", work, (
        root_option + options("-sv_lib", third.with_suffix(""), alias.with_suffix(""))
        + options("-sv_liblist", relative_list) + options("-sv_lib", relative[3])
        + options("-sv_liblist", empty_list) + options("-sv_lib", relative[0])
    )


def inspect_case(simulator: Path, compiler: str, fixture: Path, order: str, annex: bool) -> dict[str, str]:
    source = fixture.parent / suite_results.header(fixture)["dpi_c"].removeprefix("@")
    suffix = ".dylib" if sys.platform == "darwin" else ".so"
    with tempfile.TemporaryDirectory() as directory:
        work = Path(directory)
        root = work / "DPI objects"
        try:
            objects = build_objects(compiler, source, root, suffix)
        except (OSError, subprocess.SubprocessError):
            return {"build_separate_objects": "c_build_failed"}
        scenarios = {"explicit_suffix_control": invocation(
            simulator, fixture, work, options("-sv_lib", *(objects[letter] for letter in order)), order
        )}
        if annex:
            for name, cwd, arguments in annex_invocations(work, root, objects, order):
                scenarios[name] = invocation(simulator, fixture, cwd, arguments, order)
        return scenarios


def executable_hash(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--simulator", required=True, type=Path, help="private Ghost executable")
    parser.add_argument("--json", required=True, type=Path, help="write public results to this file")
    args = parser.parse_args()
    simulator = args.simulator.resolve()
    if not simulator.is_file() or not os.access(simulator, os.X_OK):
        parser.error("Ghost executable is unavailable")
    compiler = shutil.which(os.environ.get("CC", "cc"))
    if not compiler or sys.platform not in ("darwin", "linux"):
        parser.error("a Unix shared-library compiler is required")

    binary_hash = executable_hash(simulator)
    checker_hash = checker_digest()
    runner_hash = suite_results.runner_digest("ghost")
    fixtures = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in CASES}
    inputs = suite_results.fingerprints(list(fixtures.values()))
    results, observations = {}, {}
    for case, (order, annex) in CASES.items():
        scenarios = inspect_case(simulator, compiler, fixtures[case], order, annex)
        observations[case] = scenarios
        differences = ", ".join(f"{name}={status}" for name, status in scenarios.items() if status != "pass")
        results[case] = ("fail", differences) if differences else ("pass", "")
        print(f"{results[case][0].upper()} {case}" + (f" {differences}" if differences else ""))

    if binary_hash != executable_hash(simulator) or checker_hash != checker_digest():
        parser.exit(2, "Ghost or the loader checker changed during execution.\n")
    suite_results.write(args.json, "ghost", "Ghost", f"private build {binary_hash[:12]}", results,
                        inputs=inputs, runner_sha256=runner_hash,
                        configuration={"evidence_profile": PROFILE, "checker_sha256": checker_hash,
                                       "binary_sha256": binary_hash, "platform": sys.platform,
                                       "compiler": suite_results.tool_version([compiler, "--version"]),
                                       "scenarios": observations})
    return int(any(status != "pass" for status, _ in results.values()))


if __name__ == "__main__":
    raise SystemExit(main())
