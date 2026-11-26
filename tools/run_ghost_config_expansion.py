#!/usr/bin/env python3
"""Compare Annex A config syntax with an independent parser and Ghost bindings."""

import argparse
import hashlib
import importlib.metadata
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

import run_ghost
import suite_results


CHECKER = "tools/run_ghost_config_expansion.py"
PROFILE = "ghost-config-expansion-grammar"
CASE = "ch33/test_config_expansion_forms"
CASES = {CASE: suite_results.ROOT / "tests" / f"{CASE}.sv"}
GRAMMAR_REVISION = "1a298589a3168f87fe476f6347e0ded46344fbdf"
GRAMMAR_SHA256 = {
    "SystemVerilogLexer.g4": "4038f513ae2e5cca3da9cf686c55bc310d7fa734bbebd79277f3294540d3154b",
    "SystemVerilogParser.g4": "9b8321996c00b10a1f2eb878dc47bfd3ecc9a194dd388ac5af037e032426bbe6",
}
ANTLR_VERSION = "4.13.2"
ANTLR_SHA256 = "eae2dfa119a64327444672aff63e9ec35a20180dc5b8090b7a6ab85125df4d76"
NAMED = "use .P(11), .Q(12);"
COMBINED = "use work.expansion_replacement .P(13), .Q(14);"


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checker_digest() -> str:
    return digest(suite_results.ROOT / CHECKER)


def variants(source: str) -> dict[str, str]:
    if source.count(NAMED) != 1 or source.count(COMBINED) != 1:
        raise ValueError("could not isolate the two config use clauses")
    return {
        "standard": source,
        "parameter_suffixes": source.replace(NAMED, "use .P(11), .Q(12):config;").replace(
            COMBINED, "use work.expansion_nested .P(13), .Q(14):config;"),
        "hash_parameters": source.replace(NAMED, "use #(.P(11), .Q(12));"),
        "hash_after_cell": source.replace(COMBINED, "use work.expansion_replacement #(.P(13), .Q(14));"),
    }


def reference_parse(sources: dict[str, str], generated: Path) -> dict:
    from antlr4 import CommonTokenStream, InputStream
    from antlr4.error.ErrorListener import ErrorListener

    sys.path.insert(0, str(generated))
    try:
        from SystemVerilogLexer import SystemVerilogLexer
        from SystemVerilogParser import SystemVerilogParser
    finally:
        sys.path.pop(0)

    class Diagnostics(ErrorListener):
        def __init__(self):
            self.errors = []

        def syntaxError(self, recognizer, offendingSymbol, line, column, msg, e):
            self.errors.append({"line": line, "column": column,
                                "token": getattr(offendingSymbol, "text", None), "message": msg})

    observations = {}
    for mode, source in sources.items():
        listener = Diagnostics()
        lexer = SystemVerilogLexer(InputStream(source))
        lexer.removeErrorListeners()
        lexer.addErrorListener(listener)
        parser = SystemVerilogParser(CommonTokenStream(lexer))
        parser.removeErrorListeners()
        parser.addErrorListener(listener)
        parser.source_text()
        observations[mode] = listener.errors
    return observations


def ghost_run(ghost: Path, profile: dict, fixture: Path, source: str, work: Path) -> dict:
    test = work / fixture.name
    test.write_text(source, encoding="utf-8")
    result = subprocess.run([ghost, *profile["arguments"], "-top", suite_results.top_module(fixture), test.name],
                            cwd=work, env={**os.environ, **profile["environment"]}, capture_output=True,
                            text=True, errors="replace", timeout=30)
    return {"exit": result.returncode, "stdout": run_ghost.normalize(result.stdout, profile).splitlines()}


def observe(java: Path, antlr: Path, grammars: dict, ghost: Path, profile: dict, fixture: Path, work: Path) -> dict:
    for name, path in grammars.items():
        shutil.copyfile(path, work / name)
    generation = subprocess.run([java, "-jar", antlr, "-Dlanguage=Python3", "-no-listener", "-no-visitor", *grammars],
                                cwd=work, capture_output=True, text=True, timeout=60)
    if generation.returncode:
        raise ValueError(f"ANTLR generation failed ({generation.returncode})")
    sources = variants(fixture.read_text(encoding="utf-8"))
    grammar = reference_parse(sources, work)
    rejected_at_hash = {}
    for mode in ("hash_parameters", "hash_after_cell"):
        line_no, text = next((i, line) for i, line in enumerate(sources[mode].splitlines(), 1) if "#(" in line
                             and line.lstrip().startswith(("instance ", "use ")))
        rejected_at_hash[mode] = any((d["token"], d["line"], d["column"]) == ("#", line_no, text.index("#"))
                                     for d in grammar[mode])
    measured = {mode: ghost_run(ghost, profile, fixture, sources[mode], work)
                for mode in ("standard", "hash_parameters", "hash_after_cell")}
    expected = suite_results.expected_output(fixture).splitlines()
    passed = (not grammar["standard"] and not grammar["parameter_suffixes"] and all(rejected_at_hash.values())
              and measured["standard"] == {"exit": 0, "stdout": expected})
    return {"reference_diagnostics": grammar, "rejected_at_hash": rejected_at_hash,
            "ghost": measured, "pass": passed}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ghost", type=Path, required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--java", default="java")
    parser.add_argument("--antlr-jar", type=Path, required=True)
    parser.add_argument("--grammar-dir", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    parser.add_argument("--observations", type=Path, required=True)
    args = parser.parse_args()
    java = shutil.which(args.java)
    ghost = args.ghost.resolve()
    if java is None or not ghost.is_file():
        parser.error("Java and the Ghost executable are required")
    try:
        runtime = importlib.metadata.version("antlr4-python3-runtime")
    except importlib.metadata.PackageNotFoundError:
        parser.error(f"install antlr4-python3-runtime=={ANTLR_VERSION} in this Python environment")
    if runtime != ANTLR_VERSION:
        parser.error(f"the grammar requires ANTLR runtime {ANTLR_VERSION}")
    grammars = {name: args.grammar_dir.resolve() / name for name in GRAMMAR_SHA256}
    artifacts = {"ghost": ghost, "antlr": args.antlr_jar.resolve(), "java": Path(java).resolve(), **grammars}
    if not all(path.is_file() for path in artifacts.values()):
        parser.error("the ANTLR jar and both grammar files are required")
    hashes = {name: digest(path) for name, path in artifacts.items()}
    if hashes["antlr"] != ANTLR_SHA256 or any(hashes[name] != sha for name, sha in GRAMMAR_SHA256.items()):
        parser.error("ANTLR jar or grammar inputs differ from the pinned revisions")
    profile_bytes = args.profile.read_bytes()
    profile = json.loads(profile_bytes)
    if "--lrm-strict" not in profile["arguments"]:
        parser.error("the Ghost profile must use --lrm-strict")
    fixture = CASES[CASE]
    inputs = suite_results.fingerprints([fixture])
    checker, runner = checker_digest(), suite_results.runner_digest("ghost")
    try:
        with tempfile.TemporaryDirectory() as directory:
            result = observe(artifacts["java"], artifacts["antlr"], grammars, ghost, profile, fixture, Path(directory))
    except (OSError, ValueError, subprocess.TimeoutExpired) as error:
        parser.exit(2, f"Config grammar qualification stopped ({error}).\n")
    if (hashes != {name: digest(path) for name, path in artifacts.items()}
            or checker != checker_digest() or runner != suite_results.runner_digest("ghost")
            or inputs != suite_results.fingerprints([fixture]) or profile_bytes != args.profile.read_bytes()):
        parser.exit(2, "Tools or inputs changed during qualification.\n")

    version = f"private build {hashes['ghost'][:12]}"
    config = {"evidence_profile": PROFILE, "checker_sha256": checker, "grammar_revision": GRAMMAR_REVISION,
              "artifact_sha256": hashes, "antlr_python_runtime": runtime,
              "profile_sha256": hashlib.sha256(profile_bytes).hexdigest()}
    verdict = ("pass", "") if result["pass"] else ("fail", "config syntax or binding observations differed")
    suite_results.write(args.json, "ghost", "Ghost", version, {CASE: verdict}, inputs=inputs,
                        configuration=config, runner_sha256=runner)
    args.observations.parent.mkdir(parents=True, exist_ok=True)
    args.observations.write_text(json.dumps({"version": version, "configuration": config, "runner_sha256": runner,
        "tests": {CASE: {"inputs_sha256": inputs[CASE], **result}}}, indent=2) + "\n", encoding="utf-8")
    print(verdict[0], CASE)
    return int(not result["pass"])


if __name__ == "__main__":
    raise SystemExit(main())
