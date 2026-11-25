#!/usr/bin/env python3
"""Qualify Chapter 34 pragma syntax against clean sources and single changes."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import run_slang
import suite_results


PROFILE = "slang-protect-pragma-syntax"
CHECKER = "tools/run_protect_pragma_syntax.py"
OPTIONS = (*run_slang.OPTIONS, "-Werror", "-Wno-protected-envelope")
PREFIX = "`pragma protect "
DELIMITERS = ("begin", "end", "reset")
AUTHORS = ("author", "author_info", "encrypt_agent", "encrypt_agent_info", "comment")
METHODS = (
    "data_keyowner", "data_method", "data_keyname", "digest_keyowner", "digest_key_method",
    "digest_keyname", "digest_method", "key_keyowner", "key_method", "key_keyname",
)
BLOCKS = (
    "data_public_key", "data_decrypt_key", "data_block", "digest_public_key",
    "digest_decrypt_key", "digest_block", "key_public_key", "key_block",
)
LICENSES = ("decrypt_license", "runtime_license", "viewport")
CASE_KEYWORDS = {
    "ch34/test_protect_standalone_envelope_delimiters_syntax": DELIMITERS,
    "ch34/test_protect_combined_envelope_delimiters_syntax": DELIMITERS,
    "ch34/test_protect_author_and_agent_string_syntax": AUTHORS,
    "ch34/test_protect_author_and_agent_strings_inside_envelope": AUTHORS,
    "ch34/test_protect_key_and_method_string_syntax": METHODS,
    "ch34/test_protect_key_and_method_strings_inside_envelope": METHODS,
    "ch34/test_protect_encoding_required_and_line_length_syntax": ("encoding",),
    "ch34/test_protect_encoding_bytes_and_both_numbers_syntax": ("encoding",),
    "ch34/test_protect_bare_keys_and_blocks_with_single_line_payloads": BLOCKS,
    "ch34/test_protect_bare_keys_and_blocks_with_wrapped_blocks": BLOCKS,
    "ch34/test_protect_license_and_viewport_minimal_syntax": LICENSES,
    "ch34/test_protect_license_optional_fields_and_viewport_string_syntax": LICENSES,
}
REQUIRED_FIELDS = {
    "encoding": ("enctype",),
    "decrypt_license": ("library", "entry", "feature"),
    "runtime_license": ("library", "entry", "feature"),
    "viewport": ("object", "access"),
}
NUMERIC_FIELDS = {"line_length", "bytes", "match"}


def checker_digest() -> str:
    digest = hashlib.sha256()
    for name in (CHECKER, "tools/run_slang.py", "tools/suite_results.py"):
        digest.update(name.encode() + b"\0")
        digest.update(hashlib.sha256((suite_results.ROOT / name).read_bytes()).digest())
    return digest.hexdigest()


def replacements(line: str, keyword: str):
    """Yield a defect label and a replacement for a single source line."""
    expression = line.removeprefix(PREFIX)
    if keyword in DELIMITERS:
        for match in re.finditer(r"\b" + keyword + r"\b", expression):
            yield "extra_argument", line[:len(PREFIX) + match.end()] + "=1" + expression[match.end():]
    elif keyword in BLOCKS:
        if expression == keyword:
            yield "extra_argument", line + "=1"
    elif expression.partition("=")[0].strip() == keyword:
        if keyword not in REQUIRED_FIELDS:
            yield "non_string_value", PREFIX + keyword + "=1"
            yield "missing_value", PREFIX + keyword
            return
        arguments = expression.partition("=")[2].strip().removeprefix("(").removesuffix(")")
        fields = dict(field.split("=", 1) for field in arguments.split(", "))
        required = REQUIRED_FIELDS[keyword]
        if not set(required) <= fields.keys():
            raise ValueError(f"incomplete valid fixture: {line}")

        def directive(values: dict[str, str]) -> str:
            arguments = ", ".join(f"{name}={value}" for name, value in values.items())
            return f"{PREFIX}{keyword}=({arguments})"

        for name, value in fields.items():
            invalid = '"1"' if name in NUMERIC_FIELDS else (
                value.strip('"') if name == "enctype" else "1")
            yield f"{name}_wrong_type", directive(fields | {name: invalid})
            if name in required:
                yield f"{name}_missing", directive({k: v for k, v in fields.items() if k != name})


def compile_source(executable: Path, source: Path, top: str) -> tuple[int | None, list[str]]:
    try:
        result = subprocess.run([str(executable), *OPTIONS, "--top", top, source.name],
                                cwd=source.parent, capture_output=True, text=True, errors="replace",
                                timeout=45)
    except subprocess.TimeoutExpired:
        return None, []
    errors = [run_slang.relative(line.strip(), str(source.parent))
              for line in (result.stdout + result.stderr).splitlines() if run_slang.ERROR.search(line)]
    return result.returncode, errors


def mismatch_status(returncode: int | None, errors: list[str], file: str, line: int) -> str:
    if returncode is None or returncode < 0:
        return "compiler_failure"
    if returncode == 0:
        return "accepted"
    if any(message.startswith(f"{file}:{line}:") and "pragma" in message for message in errors):
        return "rejected_at_line"
    return "rejected_elsewhere"


def qualify_case(fixture: Path, executable: Path, keywords: tuple[str, ...]) -> dict:
    lines = fixture.read_text(encoding="utf-8").splitlines()
    top = suite_results.top_module(fixture)
    if top is None:
        raise ValueError(f"{fixture.name} must declare a top module")
    mutations = []
    with tempfile.TemporaryDirectory() as directory:
        probe = Path(directory) / fixture.name
        probe.write_bytes(fixture.read_bytes())
        code, errors = compile_source(executable, probe, top)
        control = {"status": "accepted" if code == 0 and not errors else "failed"}
        if errors:
            control["diagnostics"] = errors

        for keyword in keywords:
            before = len(mutations)
            for index, original in enumerate(lines):
                if not original.startswith(PREFIX):
                    continue
                for label, replacement in replacements(original, keyword):
                    if replacement == original:
                        raise ValueError(f"{fixture.name}:{index + 1}: {label} did not change the input")
                    edited = lines.copy()
                    edited[index] = replacement
                    probe.write_text("\n".join(edited) + "\n", encoding="utf-8")
                    code, errors = compile_source(executable, probe, top)
                    status = mismatch_status(code, errors, fixture.name, index + 1)
                    mutations.append({"keyword": keyword, "line": index + 1, "change": label,
                                      "status": status, **({"diagnostics": errors} if errors else {})})
            if before == len(mutations):
                raise ValueError(f"{fixture.name} has no mutation checking {keyword}")
    return {"control": control, "mutations": mutations}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--slang", required=True, help="Slang compiler executable")
    parser.add_argument("--json", required=True, type=Path, help="qualification record to write")
    args = parser.parse_args()
    program = shutil.which(args.slang)
    if program is None:
        parser.error("Slang compiler is unavailable")
    executable = Path(program).resolve()
    binary_hash = hashlib.sha256(executable.read_bytes()).hexdigest()
    checker_hash = checker_digest()
    version = suite_results.tool_version([str(executable), "--version"])
    fixtures = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in CASE_KEYWORDS}
    inputs = suite_results.fingerprints(list(fixtures.values()))
    results = {case: qualify_case(fixtures[case], executable, keywords)
               for case, keywords in CASE_KEYWORDS.items()}
    if (binary_hash != hashlib.sha256(executable.read_bytes()).hexdigest()
            or checker_hash != checker_digest()
            or inputs != suite_results.fingerprints(list(fixtures.values()))):
        parser.exit(2, "Compiler, checker or input changed during qualification.\n")

    summaries = {
        "accepted_controls": sum(result["control"]["status"] == "accepted" for result in results.values()),
        "controls": len(results),
        "rejected_at_line": sum(item["status"] == "rejected_at_line" for result in results.values()
                                for item in result["mutations"]),
        "mutations": sum(len(result["mutations"]) for result in results.values()),
    }
    artifact = {"profile": PROFILE, "compiler": "Slang", "version": version, "options": list(OPTIONS),
                "binary_sha256": binary_hash, "checker_sha256": checker_hash, "summary": summaries,
                "tests": {key: {**result, "inputs_sha256": inputs[key]} for key, result in results.items()}}
    run_slang.write(args.json, artifact)
    print(f"{version}: {summaries['accepted_controls']}/{summaries['controls']} controls accepted, "
          f"{summaries['rejected_at_line']}/{summaries['mutations']} mutations rejected at the pragma")
    return int(summaries["accepted_controls"] != summaries["controls"]
               or summaries["rejected_at_line"] != summaries["mutations"])


if __name__ == "__main__":
    raise SystemExit(main())
