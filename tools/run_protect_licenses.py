#!/usr/bin/env python3
"""Qualify protect license metadata and test an independent gated consumer."""

import argparse
import ctypes
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

import run_protect_digests as digests
import run_protect_encryption as protect
import run_slang
import suite_results


PROFILE = "protect-licenses"
CHECKER = "tools/run_protect_licenses.py"
LIBRARY_SOURCE = "tools/protect_license_fixture.c"
RELEASE = "ch34/test_protect_license_checks_before_processing_and_execution"
NO_RELEASE = "ch34/test_protect_license_matches_without_release"
CASES = {RELEASE: "licensed body=37", NO_RELEASE: "no release body=62"}
PHASES = ("decrypt", "runtime")
GRANTED = {"decrypt": 37, "runtime": 0}
TRACE_NAME = "PROTECT_FIXTURE_LICENSE_TRACE"
DIAGNOSTIC_REQUIREMENTS = {
    "SV2023-34.5.28.2-EXTRACT-LICENSE-DENIAL",
    "SV2023-34.5.29.2-EXTRACT-LICENSE-DENIAL",
}
DIAGNOSTIC_ANCHOR = "def report_denial("


def checker_digest() -> str:
    content = hashlib.sha256()
    for name in (CHECKER, LIBRARY_SOURCE):
        content.update(name.encode() + b"\0")
        content.update(hashlib.sha256((suite_results.ROOT / name).read_bytes()).digest())
    content.update(digests.checker_digest().encode())
    return content.hexdigest()


def license_pragma(source: bytes, phase: str) -> tuple[bytes, dict[str, str]]:
    keyword = phase.encode() + b"_license"
    matches = [line for line in source.splitlines()
               if re.match(protect.PRAGMA + keyword + rb"\s*=", line)]
    if len(matches) != 1:
        raise ValueError(f"expected one {phase} license directive")
    return matches[0], {key.decode(): value.decode() for key, value in protect.fields(matches[0]).items()}


def append_trace(path: Path, event: str) -> None:
    with path.open("a", encoding="utf-8") as file:
        file.write(event + "\n")


def authorize(policy: dict[str, str], libraries: dict[str, str], release_callbacks: list) -> int:
    library = ctypes.CDLL(libraries[policy["library"]])
    entry = getattr(library, policy["entry"])
    entry.argtypes = [ctypes.c_char_p]
    entry.restype = ctypes.c_int
    result = entry(policy["feature"].encode())
    if "exit" in policy:
        release = getattr(library, policy["exit"])
        release.argtypes = []
        release.restype = None
        release_callbacks.append(release)
    return result


def report_denial(phase: str, returned: int) -> int:
    print(f"{phase}_license denied: entry returned {returned}", file=sys.stderr)
    return 5


def consume(manifest: Path) -> int:
    params = json.loads(manifest.read_text())
    trace = Path(os.environ[TRACE_NAME])
    releases = []
    try:
        # The fixture supplies decrypt policy before the consumer opens the ciphertext.
        decrypt_policy = params["decrypt_policy"]
        returned = authorize(decrypt_policy, params["libraries"], releases)
        if returned != int(decrypt_policy["match"]):
            return report_denial("decrypt", returned)

        append_trace(trace, "decrypt payload")
        encrypted = Path(params["protected"]).read_bytes()
        layout = protect.split(encrypted, protect.OUTPUT_BEGIN, protect.OUTPUT_END)
        if len(layout.bodies) != 1:
            raise ValueError("expected one protected range")
        body = protect.recover(params["openssl"], Path(params["private"]), protect.parse_blocks(layout.bodies[0]))
        cleartext = layout.clear[0] + body + layout.clear[1]
        runtime_policy = license_pragma(body, "runtime")[1]
        if license_pragma(body, "decrypt")[1] != decrypt_policy:
            raise ValueError("recovered decrypt policy differs from the preflight policy")

        source, executable = manifest.parent / "restored.sv", manifest.parent / "model.vvp"
        source.write_bytes(cleartext)
        append_trace(trace, "compile source")
        protect.invoke([params["iverilog"], "-g2012", "-s", params["top"], "-o", str(executable), str(source)])

        returned = authorize(runtime_policy, params["libraries"], releases)
        if returned != int(runtime_policy["match"]):
            return report_denial("runtime", returned)
        append_trace(trace, "execute model")
        output = protect.invoke([params["vvp"], str(executable)])
        sys.stdout.buffer.write(output)
        return 0
    finally:
        for release in reversed(releases):
            release()
        append_trace(trace, "leave consumer")


def build_libraries(work: Path) -> dict[str, Path]:
    extension, flag = (".dylib", "-dynamiclib") if sys.platform == "darwin" else (".so", "-shared")
    libraries = {}
    for phase, name in zip(PHASES, ("dec", "run")):
        library = work / (name + extension)
        subprocess.run([os.environ.get("CC", "cc"), flag, "-fPIC", "-Wall", "-Wextra", "-Werror",
                        f'-DLICENSE_PHASE="{phase}"', f"-DLICENSE_RETURN={GRANTED[phase]}",
                        str(suite_results.ROOT / LIBRARY_SOURCE),
                        "-o", str(library)], check=True, timeout=60)
        libraries[name] = library
    return libraries


def encrypt_fixture(python: str, openssl: str, private: Path, public: Path,
                    source: bytes, work: Path) -> tuple[bytes, dict]:
    variant, output = work / "license.sv", work / "native.sv"
    variant.write_bytes(source)
    encrypted = protect.encrypt(python, variant, public, output, (b"Qualification", b"fixture-only"))
    native = protect.split(encrypted, protect.OUTPUT_BEGIN, protect.OUTPUT_END, protect.FALLBACK_BEGIN)
    if len(native.bodies) != 1:
        raise ValueError("expected one native encrypted range")
    original = protect.split(source, protect.SOURCE_BEGIN, protect.SOURCE_END)
    envelope = native.bodies[0]
    blocks = protect.parse_blocks(envelope)
    recovered = protect.recover(openssl, private, blocks)
    checks = {}
    for phase in PHASES:
        line, _ = license_pragma(original.bodies[0], phase)
        checks[phase] = line in recovered.splitlines() and line not in encrypted.splitlines()
    # Keep the native key and data bytes. Provide canonical framing for the consumer probes.
    header = protect.fields(envelope)
    fields = (b"data_method", b"key_method", b"key_keyowner", b"key_keyname")
    framed = (native.clear[0] + b"`pragma protect begin_protected\n"
              + b"".join(b"`pragma protect " + field + b' = "' + header[field] + b'"\n' for field in fields)
              + b"".join(digests.encoded_block(kind, blocks[kind].decoded, b"base64") for kind in protect.BLOCKS)
              + b"`pragma protect end_protected" + native.clear[1])
    return framed, checks


def run_reference(manifest: Path, source: bytes, protected: Path, private: Path, tools: dict,
                  libraries: dict[str, Path], denial: str | None, expected: bytes) -> dict:
    trace = manifest.parent / "reference.trace"
    trace.unlink(missing_ok=True)
    policies = {phase: license_pragma(source, phase)[1] for phase in PHASES}
    manifest.write_text(json.dumps({
        **tools, "protected": str(protected), "private": str(private), "decrypt_policy": policies["decrypt"],
        "libraries": {key: str(path) for key, path in libraries.items()},
    }))
    run = subprocess.run([sys.executable, str(suite_results.ROOT / CHECKER), "--consumer", str(manifest)],
                         capture_output=True, timeout=120, env={**os.environ, TRACE_NAME: str(trace)})
    features = {phase: policies[phase]["feature"] for phase in PHASES}
    returns = {phase: GRANTED[phase] if feature == "allow" else 19 for phase, feature in features.items()}
    expected_events = [f"entry decrypt {features['decrypt']} {returns['decrypt']}"]
    entered = ["decrypt"]
    if denial != "decrypt":
        entered.append("runtime")
        expected_events.extend(("decrypt payload", "compile source",
                                f"entry runtime {features['runtime']} {returns['runtime']}"))
        if denial is None:
            expected_events.append("execute model")
    expected_events += [f"release {phase}" for phase in reversed(entered) if "exit" in policies[phase]]
    expected_events.append("leave consumer")
    events = trace.read_text().splitlines() if trace.is_file() else []
    executed = expected in run.stdout.splitlines()
    denial_message = (f"{denial}_license denied: entry returned {returns[denial]}".encode() in run.stderr.splitlines()
                      if denial is not None else False)
    return {"events": events, "executed": executed, "exit": run.returncode, "diagnostic_has_return_value": denial_message,
            "pass": (events == expected_events and run.returncode == (5 if denial else 0)
                     and executed == (denial is None) and denial_message == (denial is not None))}


def native_probe(ghost: str, tools: dict, protected: Path, expected: bytes) -> dict:
    trace = protected.parent / "native.trace"
    commands = {
        "ghost": [ghost, "--lrm-strict", "--quiet", str(protected)],
        "icarus": [tools["iverilog"], "-g2012", "-s", tools["top"], "-o",
                   str(protected.parent / "native.vvp"), str(protected)],
    }
    observations = {}
    for name, command in commands.items():
        trace.unlink(missing_ok=True)
        env = {**os.environ, TRACE_NAME: str(trace)}
        run = subprocess.run(command, capture_output=True, timeout=120, env=env)
        if name == "icarus" and run.returncode == 0:
            run = subprocess.run([tools["vvp"], str(protected.parent / "native.vvp")],
                                 capture_output=True, timeout=120, env=env)
        messages = (run.stdout + run.stderr).lower()
        events = trace.read_text().splitlines() if trace.is_file() else []
        observations[name] = {
            "exit": run.returncode, "executed": expected in run.stdout.splitlines(),
            "license_events": events,
            "protected_input_unresolved": any(term in messages for term in (
                b"unknown module", b"unknownmodule", b"protected envelope", b"unresolved", b"missing module",
            )),
            "protection_not_supported_reported": any(
                b"protected envelope" in line and b"not supported" in line for line in messages.splitlines()
            ),
            "syntax_error": b"syntax error" in messages,
            "fixture_decryption_key_configured": False,
        }
    return observations


def denied_input(source: bytes, phase: str) -> bytes:
    line, policy = license_pragma(source, phase)
    if "exit" in policy:
        altered = line.replace(b'feature="allow"', b'feature="deny"')
    else:
        altered = re.sub(rb"match=\d+", b"match=71", line)
    if altered == line:
        raise ValueError("fixture denial mutation did not change the license")
    return source.replace(line, altered, 1)


def qualify(python: str, ghost: str, tools: dict, fixture: Path, expected: bytes, work: Path) -> dict:
    private, public = protect.exchange_key(tools["openssl"], work, "fixture")
    libraries = build_libraries(work)
    source = fixture.read_bytes()
    tools = {**tools, "top": suite_results.header(fixture)["top_module"]}
    protected = work / "protected.sv"
    results = {}
    for label, phase in (("allowed", None), ("decrypt_denied", "decrypt"), ("runtime_denied", "runtime")):
        variant = denied_input(source, phase) if phase else source
        framed, preserved = encrypt_fixture(python, tools["openssl"], private, public, variant, work)
        protected.write_bytes(framed)
        reference = run_reference(work / "consumer.json", variant, protected, private, tools,
                                  libraries, phase, expected)
        results[label] = {"encrypted_metadata_preserved": preserved, "reference": reference}
        if phase is None:
            results[label]["native"] = native_probe(ghost, tools, protected, expected)
    return results


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--python", required=True, help="Python environment with hdl-encrypt installed")
    parser.add_argument("--openssl", default="openssl")
    parser.add_argument("--ghost", required=True, help="private simulator executable")
    parser.add_argument("--iverilog-bin", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    python, openssl, ghost = (shutil.which(name) for name in (args.python, args.openssl, args.ghost))
    if any(path is None for path in (python, openssl, ghost)):
        parser.error("Python, OpenSSL or Ghost is unavailable")
    ghost = str(Path(ghost).resolve())
    drivers = {name: str(args.iverilog_bin.resolve() / name) for name in ("iverilog", "vvp")}
    tools = {"openssl": openssl, **drivers}
    fixtures = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in CASES}
    fingerprints = suite_results.fingerprints(list(fixtures.values()))
    checker, tool = checker_digest(), protect.tool_info(python)
    tests = {}
    for case, fixture in fixtures.items():
        if suite_results.header(fixture).get("expected_stdout") != CASES[case]:
            parser.error(f"unexpected control output for {case}")
        with tempfile.TemporaryDirectory() as directory:
            variants = qualify(python, ghost, tools, fixture, CASES[case].encode(), Path(directory))
        tests[case] = {"inputs_sha256": fingerprints[case], "variants": variants}
    if (checker != checker_digest() or fingerprints != suite_results.fingerprints(list(fixtures.values()))
            or tool != protect.tool_info(python)):
        parser.exit(2, "Encryptor, checker or input changed during qualification.\n")
    run_slang.write(args.json, {
        "profile": PROFILE, "encryptor": tool, "checker_sha256": checker,
        "reference_decrypt_policy": "loaded from the fixture before opening ciphertext",
        "native_input": "canonical framing with native key and data bytes",
        "binary_sha256": {name: hashlib.sha256(Path(path).read_bytes()).hexdigest()
                          for name, path in {"ghost": ghost, **drivers}.items()},
        "openssl": protect.invoke([openssl, "version"]).decode().strip(), "tests": tests,
    })
    variants = [row for record in tests.values() for row in record["variants"].values()]
    native = [engine for row in variants for engine in row.get("native", {}).values()]
    print(f"License source preservation: {sum(all(row['encrypted_metadata_preserved'].values()) for row in variants)}/6")
    print(f"Independent consumer controls: {sum(row['reference']['pass'] for row in variants)}/6")
    print(f"Native protected body executions: {sum(row['executed'] for row in native)}/{len(native)}")
    return int(any(not all(row["encrypted_metadata_preserved"].values()) or not row["reference"]["pass"]
                   for row in variants) or not all(row["executed"] for row in native))


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "--consumer":
        raise SystemExit(consume(Path(sys.argv[2])))
    raise SystemExit(main())
