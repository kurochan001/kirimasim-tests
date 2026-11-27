#!/usr/bin/env python3
"""Qualify access to objects named by a viewport in its own envelope."""

import argparse
import hashlib
import json
from pathlib import Path
import shutil
import tempfile

import run_icarus
import run_protect_block_boundaries as boundaries
import run_protect_encryption as protect
import run_protect_pragma_syntax as slang
import suite_results


PROFILE = "protect-viewport"
CHECKER = "tools/run_protect_viewport.py"
PROBE = "tools/protect_viewport_probe.c"
CASE = "ch34/test_protect_viewport_uses_current_envelope"
REORDERED = "ch34/test_protect_viewport_keeps_access_after_reordering"
CASES = dict.fromkeys((CASE, REORDERED), "viewport values=21,42,38,70,68,13")
ENVELOPE_ORDERS = {CASE: (0, 1), REORDERED: (1, 0)}
TOP = "viewport_top"
MARKER = b"    // Viewport qualification operations"
REQUESTS = (
    ("read_east", 0, "east.opened", -1, "00000021"),
    ("write_readonly", 0, "east.opened", 88, "ffffffff"),
    ("read_custom", 0, "east.writable", -1, "00000042"),
    ("write_custom", 0, "east.writable", 91, None),
    ("read_unlisted", 0, "east.kept", -1, "ffffffff"),
    ("read_from_adjacent", 0, "west.opened", -1, "ffffffff"),
    ("read_west", 1, "west.opened", -1, "00000070"),
    ("read_clear_through_viewport", 0, "clear", -1, "ffffffff"),
)
POLICIES = {
    "tool_access_read": ({b"read only": 1, b"tool access": 1}, "ffffffff", "42"),
    "tool_access_read_write": ({b"read only": 1, b"tool access": 3}, "0000005b", "5b"),
}


class InvalidViewport(ValueError):
    def __init__(self, envelope: int, target: str):
        super().__init__(f"viewport object {target} is outside envelope {envelope}")
        self.envelope, self.target = envelope, target


def checker_digest() -> str:
    fingerprint = hashlib.sha256()
    for name in (CHECKER, PROBE):
        fingerprint.update(name.encode() + b"\0")
        fingerprint.update(hashlib.sha256((suite_results.ROOT / name).read_bytes()).digest())
    for component in (boundaries.checker_digest(), slang.checker_digest(), suite_results.runner_digest("icarus")):
        fingerprint.update(component.encode())
    return fingerprint.hexdigest()


def restore(python: str, openssl: str, fixture: Path, work: Path) -> tuple[bytes, dict]:
    source = fixture.read_bytes()
    layout = protect.split(source, protect.SOURCE_BEGIN, protect.SOURCE_END)
    private, public = protect.exchange_key(openssl, work, "viewport")
    wire = protect.encrypt(python, fixture, public, work / "native.sv", (b"Qualification", b"viewport"))
    _, recovered = boundaries.recovered_ranges(openssl, private, wire)
    expected = tuple(body.strip(b"\r\n") for body in layout.bodies)
    recovered = tuple(body.strip(b"\r\n") for body in recovered)
    if len(recovered) != 2 or recovered != expected:
        raise ValueError("wrong number or contents of recovered viewport bodies")
    cursor, chunks = 0, []
    for opening, closing, body in zip(
            protect.SOURCE_BEGIN.finditer(source), protect.SOURCE_END.finditer(source), recovered, strict=True):
        chunks.append(source[cursor:opening.end()] + b"\n" + body + b"\n")
        cursor = closing.start()
    chunks.append(source[cursor:])
    return b"".join(chunks), {
        "recovered_model_bodies": len(recovered),
        "viewport_expression_count_in_encrypted_output": wire.count(b"`pragma protect viewport"),
        "viewport_expressions_in_recovered_models": sum(body.count(b"`pragma protect viewport") for body in recovered),
    }


def variables(node: dict, scope: tuple[str, ...], source_name: str):
    kind = node["kind"]
    if kind == "Instance":
        yield from variables(node["body"], (*scope, node["name"]), source_name)
    elif kind == "Variable" and node.get("source_file") == source_name:
        yield ".".join((*scope, node["name"])), node["source_line"]
    for child in node.get("members", []):
        yield from variables(child, scope, source_name)


def envelope_objects(executable: Path, work: Path, source: bytes) -> dict[str, int | None]:
    variant = work / "restored.sv"
    variant.write_bytes(source)
    build = run_icarus.execute(
        [str(executable), *slang.OPTIONS, "--top", TOP, "--ast-json", "design.json", "--ast-json-source-info",
         variant.name], run_icarus.COMPILE_TIMEOUT, cwd=str(work))
    if build.returncode:
        raise ValueError(run_icarus.neutral(build.stderr, str(work)).strip() or "Slang elaboration failed")
    design = json.loads((work / "design.json").read_text(encoding="utf-8"))["design"]
    lines = [(source.count(b"\n", 0, opening.start()) + 1, source.count(b"\n", 0, closing.start()) + 1)
             for opening, closing in zip(protect.SOURCE_BEGIN.finditer(source),
                                         protect.SOURCE_END.finditer(source), strict=True)]
    return {name: next((index for index, (begin, end) in enumerate(lines) if begin < line < end), None)
            for name, line in variables(design, (), variant.name)}


def grants(source: bytes, objects: dict[str, int | None], policy: dict[bytes, int]) -> dict:
    layout = protect.split(source, protect.SOURCE_BEGIN, protect.SOURCE_END)
    result = {}
    for envelope, body in enumerate(layout.bodies):
        for expression in protect.DIRECTIVE.findall(body):
            if expression.partition(b"=")[0].strip() != b"viewport":
                continue
            fields = protect.attributes(expression)
            target = fields[b"object"].decode()
            if objects.get(target) != envelope:
                raise InvalidViewport(envelope, target)
            result[envelope, target] = policy[fields[b"access"]]
    return result


def observed_operations(bindir: Path, work: Path, source: bytes, permissions: dict,
                        envelope_order: tuple[int, int]) -> dict:
    if source.count(MARKER) != 1:
        raise ValueError("expected one location for viewport operations")
    statements = []
    for label, envelope, short_name, requested, _ in REQUESTS:
        name = f"{TOP}.{short_name}"
        access = permissions.get((envelope_order[envelope], name), 0)
        statements.append(f'    $display("viewport {label}=%08h", $viewport_probe("{name}", {access}, {requested}));')
    (work / "runtime.sv").write_bytes(source.replace(MARKER, "\n".join(statements).encode()))
    build = run_icarus.execute(
        [str(bindir / "iverilog"), "-g2012", "-s", TOP, "-o", "runtime.vvp", "runtime.sv"],
        run_icarus.COMPILE_TIMEOUT, cwd=str(work))
    if build.returncode:
        raise ValueError(run_icarus.neutral(build.stderr, str(work)).strip() or "Icarus compile failed")
    execution = run_icarus.execute(
        [str(bindir / "vvp"), "-M.", "-mviewport", "runtime.vvp"], run_icarus.RUN_TIMEOUT, cwd=str(work))
    return {"exit": execution.returncode, "stdout": [line for line in execution.stdout.splitlines()
                                                    if line.startswith("viewport ")]}


def reference_checks(bindir: Path, work: Path, restored: bytes, objects: dict,
                     envelope_order: tuple[int, int]) -> dict:
    probe = suite_results.ROOT / PROBE
    build = run_icarus.execute([str(bindir / "iverilog-vpi"), "--name=viewport", str(probe)],
                               run_icarus.VPI_BUILD_TIMEOUT, cwd=str(work))
    if build.returncode:
        raise ValueError(run_icarus.neutral(build.stderr, str(work)).strip() or "viewport probe build failed")
    policies = {}
    for name, (mapping, write_result, final_value) in POLICIES.items():
        permissions = grants(restored, objects, mapping)
        expected = [f"viewport {label}={write_result if value is None else value}"
                    for label, _, _, _, value in REQUESTS]
        expected.append(f"viewport values=21,{final_value},38,70,68,13")
        actual = observed_operations(bindir, work, restored, permissions, envelope_order)
        policies[name] = {
            "permissions": {f"{envelope}:{target}": value for (envelope, target), value in permissions.items()},
            "expected": expected, "actual": actual, "pass": actual == {"exit": 0, "stdout": expected},
        }
    return policies


def foreign_targets(slang_exe: Path, work: Path, source: bytes, objects: dict, east_envelope: int) -> dict:
    original = f'object="{TOP}.east.opened"'.encode()
    if source.count(original) != 1:
        raise ValueError("expected one viewport target to mutate")
    variants = {}
    for label, short_name in (("adjacent_envelope", "west.opened"), ("clear_source", "clear"),
                              ("missing_object", "east.missing")):
        target = f"{TOP}.{short_name}"
        variant = source.replace(original, f'object="{target}"'.encode())
        variant_path = work / f"{label}.sv"
        variant_path.write_bytes(variant)
        returncode, diagnostics = slang.compile_source(slang_exe, variant_path, TOP)
        try:
            grants(variant, objects, POLICIES["tool_access_read"][0])
        except InvalidViewport as error:
            rejected = (error.envelope, error.target) == (east_envelope, target)
        else:
            rejected = False
        variants[label] = {"target": target, "reference_rejected_at_viewport": rejected,
                           "slang_exit": returncode, "slang_errors": diagnostics}
    return variants


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--python", required=True, help="Python environment with hdl-encrypt installed")
    parser.add_argument("--slang", required=True, help="Slang executable")
    parser.add_argument("--openssl", default="openssl")
    parser.add_argument("--iverilog-bin", type=Path, required=True)
    parser.add_argument("--json", type=Path, required=True)
    args = parser.parse_args()
    python, slang_exe, openssl = map(shutil.which, (args.python, args.slang, args.openssl))
    bindir = args.iverilog_bin.resolve()
    if not (python and slang_exe and openssl
            and all((bindir / name).is_file() for name in ("iverilog", "iverilog-vpi", "vvp"))):
        parser.error("Python, OpenSSL, Slang or the Icarus tools are unavailable")
    slang_exe = Path(slang_exe).resolve()
    fixtures = {case: suite_results.ROOT / "tests" / (case + ".sv") for case in CASES}
    inputs = {case: suite_results.input_digest(fixture) for case, fixture in fixtures.items()}
    checker = checker_digest()
    encryptor = protect.tool_info(python)
    results = {}
    with tempfile.TemporaryDirectory() as directory:
        for case, fixture in fixtures.items():
            work = Path(directory) / fixture.stem
            work.mkdir()
            restored, native = restore(python, openssl, fixture, work)
            objects = envelope_objects(slang_exe, work, restored)
            envelope_order = ENVELOPE_ORDERS[case]
            policies = reference_checks(bindir, work, restored, objects, envelope_order)
            variants = foreign_targets(slang_exe, work, restored, objects, envelope_order[0])
            passed = (all(profile["pass"] for profile in policies.values())
                      and all(variant["reference_rejected_at_viewport"] for variant in variants.values()))
            results[case] = {"inputs_sha256": inputs[case], "objects": objects, "reference_policies": policies,
                             "target_variants": variants, "native_encryptor": native, "pass": passed}
            print(f"{case}: reference {'pass' if passed else 'fail'}, native encryptor {native}")
    if (checker != checker_digest() or encryptor != protect.tool_info(python)
            or any(inputs[case] != suite_results.input_digest(fixture) for case, fixture in fixtures.items())):
        parser.exit(2, "Tool, checker or fixture changed during qualification.\n")
    record = {"profile": PROFILE, "checker_sha256": checker, "encryptor": encryptor,
              "openssl": suite_results.tool_version([openssl, "version"]),
              "slang": suite_results.tool_version([str(slang_exe), "--version"]),
              "icarus": suite_results.tool_version([str(bindir / "iverilog"), "-V"]),
              "tests": results}
    args.json.parent.mkdir(parents=True, exist_ok=True)
    args.json.write_text(json.dumps(record, indent=2) + "\n", encoding="utf-8")
    return int(not all(case["pass"] for case in results.values()))


if __name__ == "__main__":
    raise SystemExit(main())
